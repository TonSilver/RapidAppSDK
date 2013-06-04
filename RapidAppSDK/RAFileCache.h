//
//  RAFileCache.h
//

#import <Foundation/Foundation.h>


@interface RAFileCache : NSObject

// Единажды создает экземпляр данного класса
+ (instancetype)shared;

// Путь к файлу в кэше
+ (NSURL *)cacheURLForURL:(NSURL *)url;
+ (NSString *)cachePathStringForURLString:(NSString *)url;

// Запись в кеш по URL и с временем последнего изменения объекта
+ (BOOL)setCache:(NSData *)value withDate:(NSDate *)date forURL:(NSURL *)url;

// Проверяет есть ли такая запись в кэше (без извлечения данных)
+ (BOOL)isURLCached:(NSURL *)url;
+ (void)removeCacheForURL:(NSURL *)url;

// Получение значения из кеша
+ (NSData *)cacheForURL:(NSURL *)url;
+ (NSData *)cacheForURL:(NSURL *)url withDate:(NSDate **)date;

// Очистка кеша
+ (void)clear;

@end
