//
//  RALoaderItem.m
//  RapidAppSDK
//
//  Created by Anton Serebryakov on 29.11.12.
//  Copyright (c) 2012 iDEAST. All rights reserved.
//

#import "RALoaderItem.h"


#pragma mark - Loader (Privates)

@interface RALoader : NSObject
{
@private
	NSMutableDictionary *_items;
}

+ (RALoader *)shared;

// Методы для продления и укорачивания жизни загрузчика
- (void)registerLoaderItem:(RALoaderItem *)item forDelegate:(id)delegate;
- (void)unregisterAllLoaderItemsForDelegate:(id)delegate;
- (void)unregisterLoaderItem:(RALoaderItem *)item forDelegate:(id)delegate;
- (void)unregisterLoaderItem:(RALoaderItem *)item;
// Поиск загрузчика с имеющимся URL
- (RALoaderItem *)loaderItemWithURL:(NSURL *)url;

// Очередь для загрузчика по умолчанию
@property (nonatomic, readonly) dispatch_queue_t queue;

@end


#pragma mark - Loader Item (interface)

@interface RALoaderItem ()
{
@protected
	// Все делегаты для данного лоадера
	id *_delegates;
}

// Идентификатор загрузки в базе RALoader
@property (nonatomic, retain) NSString *token;
@property (nonatomic, assign) int delegatesCount;
// Индикатор процесса загрузки
@property (atomic, assign) BOOL loading;
// Надо установить переменную в YES, чтобы остановить загрузку элемента
@property (atomic, assign) BOOL stop;
// Параметры загружаемого объекта
@property (nonatomic, readwrite, retain) NSURL *url;
@property (nonatomic, readwrite, retain) NSDictionary *posts;
@property (nonatomic, readonly, retain) NSMutableURLRequest *urlRequest;
// Результаты загрузки
@property (nonatomic, retain) NSURL *cacheURL;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSError *error;
// Прогресс загрузки (от 0 до 1)
@property (nonatomic) float progress;

// Добавление и удаление делегатов
- (void)addDelegate:(id)delegate;
- (BOOL)removeDelegate:(id)delegate;
- (void)notifyDelegatesWithStatus:(RALoaderItemStatus)status;
@end


#pragma mark - Loader Item (item)

@implementation RALoaderItem
@synthesize urlRequest = _urlRequest;
@synthesize cacheURL = _cacheURL;

#pragma mark - Core fuctions

- (void)dealloc
{
	[[RALoader shared] unregisterLoaderItem:self];
	if (_delegates) free(_delegates);
	[_token release];
	[_url release];
	[_urlRequest release];
	[_cacheURL release];
	[_posts release];
	[_data release];
	[_date release];
	[_error release];
	[super dealloc];
}

+ (RALoaderItem *)itemWithURLString:(NSString *)urlString postParams:(NSDictionary *)posts
{
	NSURL *url = [NSURL URLWithString:urlString];
	if (!url)
		return nil;
	
    RALoaderItem *item = [[RALoader shared] loaderItemWithURL:url];
	if (!item)
	{
		item = [[self.class new] autorelease];
		item.url = url;
		item.posts = posts;
	}
	return item;
}

+ (RALoaderItem *)loadURLString:(NSString *)urlString withPostParams:(NSDictionary *)posts forDelegate:(id)delegate
{
	RALoaderItem *item = [self itemWithURLString:urlString postParams:posts];
	[[RALoader shared] registerLoaderItem:item forDelegate:delegate];
	[item startDelayed];
	return item;
}

+ (RALoaderItem *)loadURLString:(NSString *)urlString withPostKeys:(const NSString *[])keys postValues:(const id[])values count:(NSUInteger)count forDelegate:(id<RALoaderItemDelegate>)delegate
{
	NSDictionary *posts = [RAHelper dictionaryWithBadObjects:values forBadKeys:keys count:count];
	return [self loadURLString:urlString withPostParams:posts forDelegate:delegate];
}

#pragma mark - Canceller method

+ (void)cancelAllForDelegate:(id)delegate
{
	[[RALoader shared] unregisterAllLoaderItemsForDelegate:delegate];
}

- (void)cancel
{
	[[RALoader shared] unregisterLoaderItem:self];
}

#pragma mark - Delegates

- (BOOL)privateNeedToCache
{
	if ([_processDelegate respondsToSelector:@selector(needToCache)])
		return _processDelegate.needToCache;
	return NO;
}

- (BOOL)privateNeedToParse
{
	if ([_processDelegate respondsToSelector:@selector(needToParse)])
		return _processDelegate.needToParse;
	return NO;
}

- (dispatch_queue_t)privateQueue
{
	if ([_processDelegate respondsToSelector:@selector(queue)])
		return _processDelegate.queue;
	return [RALoader shared].queue;
}

- (void)privateModifyReqeust:(NSMutableURLRequest *)request
{
	if ([_processDelegate respondsToSelector:@selector(modifyReqeust:)])
		[_processDelegate modifyReqeust:request];
}

- (void)privateParseResponseData:(NSData *)data
{
	if ([_processDelegate respondsToSelector:@selector(parseResponseData:)])
		[_processDelegate parseResponseData:data];
}

#pragma mark - Process

- (void)startDelayed
{
	if (!self.loading)
	{
		// Отмечаем, что загрузка началась
		self.loading = YES;
		// Берем из кеша, если надо
		if (self.privateNeedToCache)
		{
			[self fetchFromCacheAndPrecomplete];
		}
		// Стартуем операцию с опозданием (в текущем потоке)
		dispatch_async(dispatch_get_current_queue(), ^{
			[self start];
		});
	}
}

- (void)start
{
    // Стартуем загрузку в фоне
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Выбираем нужную очередь в зависимости от типа загрузки
        dispatch_queue_t queue = self.privateQueue;
		// Затем стартуем операцию в очереди всех загрузок
		if (queue)
			dispatch_async(queue, ^{ [self process]; });
		else
			self.loading = NO;
    });
}

static NSString *ParamsString(const NSDictionary *params)
{
	NSMutableString *buff = [NSMutableString new];
	for (NSString *key in params.allKeys)
	{
		id val = params[key];
		if (![val isKindOfClass:[NSString class]])
			val = [val description];
		val = [val stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[buff appendFormat:@"%@=%@&", key, val];
	}
	return [buff autorelease];
}

static NSMutableURLRequest *MakeRequest(NSURL *url, const NSDictionary *posts)
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	if (posts)
	{
		NSString *buff = ParamsString(posts);
		[request setHTTPBody:[buff dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return request;
}

- (NSMutableURLRequest *)urlRequest
{
	if (!_urlRequest)
	{
		_urlRequest = [MakeRequest(_url, _posts) retain];
		[self privateModifyReqeust:_urlRequest];
	}
	return _urlRequest;
}

// Процесс загрузки и обработки загруженного можно прервать установив self.stop в NO
- (void)process
{
	float step = 1. / (2 + self.privateNeedToCache + self.privateNeedToParse);
	if (_stop) return;
	self.progress = 0;
	[self notifyDelegatesWithStatus:RALoaderItemStatusProgress];
	[self load];
	self.progress += step;
	[self notifyDelegatesWithStatus:RALoaderItemStatusProgress];
	if (_stop) return;
	if (self.privateNeedToCache)
	{
		[self cache];
		self.progress += step;
		[self notifyDelegatesWithStatus:RALoaderItemStatusProgress];
	}
	if (self.privateNeedToParse)
	{
		[self privateParseResponseData:_data];
		self.progress += step;
		[self notifyDelegatesWithStatus:RALoaderItemStatusProgress];
	}
	self.progress = 1;
	[self complete];
	
	// Выписываем себя из очереди загрузки
	dispatch_sync(dispatch_get_main_queue(), ^{
		[[RALoader shared] unregisterLoaderItem:self];
	});
}

#pragma mark - Load

- (void)load
{
	NSHTTPURLResponse *response = nil;
	self.data = [self loadRequest:self.urlRequest response:&response error:&_error];
	NSString *dateString = response.allHeaderFields[@"Last-Modified"];
	self.date = [RAHelper httpHeaderLastModifiedFromString:dateString];
}

- (NSData *)loadRequest:(NSURLRequest *)request response:(NSURLResponse **)response error:(NSError **)anError
{
	NSData *data = [NSURLConnection sendSynchronousRequest:self.urlRequest returningResponse:response error:&_error];
	return data;
}

#pragma mark - Cache

- (void)fetchFromCacheAndPrecomplete
{
	if ([RAFileCache isURLCached:self.url])
	{
		self.data = [RAFileCache cacheForURL:self.url];
		[self precomplete];
	}
}

- (void)cache
{
	NSDate *lastModified = self.date ?: [NSDate date];
	[RAFileCache setCache:self.data withDate:lastModified forURL:self.url];
}

- (NSURL *)cacheURL
{
	if (!_cacheURL && _url)
		_cacheURL = [[RAFileCache cacheURLForURL:_url] retain];
	return _cacheURL;
}

#pragma mark - Delegates

- (void)addDelegate:(id)delegate
{
	// Ищем индекс делегата
	for (int i = 0; i < _delegatesCount; i++)
		if (delegate == _delegates[i])
			return;
	// Если не нашли, то добавляем делегат
	if (!_delegates)
		_delegates = calloc(1, sizeof(id));
	else
		_delegates = realloc(_delegates, _delegatesCount + 1);
	_delegates[_delegatesCount] = delegate;
	// Увеличиваем счетчик делегатов
	_delegatesCount++;
}

- (BOOL)removeDelegate:(id)delegate
{
	int i = 0;
	// Ищем индекс удаляемого делегата
	for (; i < _delegatesCount; i++)
		if (delegate == _delegates[i])
			break;
	// Если делегат не найден, то ничего не делаем
	if (i >= _delegatesCount)
		return FALSE;
	// Иначе, перемещаем все делегаты после на одну позицию вбок
	for (; i < _delegatesCount - 1; i++)
		_delegates[i] = _delegates[i+1];
	if (_delegatesCount <= 1)
		free(_delegates);
	else
		_delegates = realloc(_delegates, _delegatesCount-1);
	_delegatesCount--;
	return YES;
}

- (void)notifyDelegatesWithStatus:(RALoaderItemStatus)status
{
	// Уведомления надо рассылать только в главном потоке
	if (![NSThread isMainThread])
	{
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self notifyDelegatesWithStatus:status];
		});
		return;
	}
	// Перебираем все делегаты и рассылаем им уведомления
	for (int i = 0; i < _delegatesCount; i++)
	{
		id<RALoaderItemDelegate> delegate = _delegates[i];
		[delegate loaderItem:self status:status url:self.url data:self.data cacheURL:self.cacheURL date:self.date error:self.error progress:self.progress];
	}
}

#pragma mark - Complete

- (void)precomplete {
	[self notifyDelegatesWithStatus:RALoaderItemStatusCache];
}
- (void)complete {
	if (!self.error)
		[self success];
	else
		[self fail];
	self.loading = NO;
}
- (void)success {
	[self notifyDelegatesWithStatus:RALoaderItemStatusOk];
}
- (void)fail {
	[self notifyDelegatesWithStatus:RALoaderItemStatusFail];
}

@end


#pragma mark - Loader (manager)

@implementation RALoader
@synthesize queue = _queue;

#pragma mark Core

+ (RALoader *)shared
{
	static RALoader *SharedLoader = nil;
	if (!SharedLoader)
		SharedLoader = [RALoader new];
	return SharedLoader;
}

- (void)dealloc
{
	if (_queue)
		dispatch_release(_queue);
	[_items release];
	[super dealloc];
}

#pragma mark Searching

- (RALoaderItem *)loaderItemWithURL:(NSURL *)url
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"url == %@", url];
    NSArray *items = [[_items allValues] filteredArrayUsingPredicate:pred];
	RALoaderItem *item = items.count ? items[0] : nil;
    return item;
}

#pragma mark Registering

- (void)registerLoaderItem:(RALoaderItem *)item forDelegate:(id)delegate
{
	if (!_items)
		_items = [NSMutableDictionary new];
	if (!item.token)
	{
		NSString *token = [NSString stringWithFormat:@"%@/%x", NSStringFromClass([item class]), (int)item];
		item.token = token;
	}
	[item addDelegate:delegate];
	_items[item.token] = item;
}

- (void)unregisterLoaderItem:(RALoaderItem *)item forDelegate:(id)delegate
{
	if (delegate)
		[item removeDelegate:delegate];
	// Удалем элемент, если делегат не был указан или делегаты элемента кончились
	if ((item.delegatesCount < 1) || !delegate)
	{
		if (item.token)
			[_items removeObjectForKey:item.token];
	}
}

- (void)unregisterLoaderItem:(RALoaderItem *)item
{
	[self unregisterLoaderItem:item forDelegate:nil];
}

- (void)unregisterAllLoaderItemsForDelegate:(id)delegate
{
	[_items.allValues enumerateObjectsUsingBlock:^(RALoaderItem *item, NSUInteger idx, BOOL *stop) {
		[self unregisterLoaderItem:item forDelegate:delegate];
	}];
}

#pragma mark Queue

- (dispatch_queue_t)queue
{
	if (!_queue)
		_queue = dispatch_queue_create("RapidAppSDK.Loader.Queue", DISPATCH_QUEUE_SERIAL);
	return _queue;
}

@end
