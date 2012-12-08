//
//  RALoaderItem.h
//  RapidAppSDK
//
//  Created by Anton Serebryakov on 28.11.12.
//  Copyright (c) 2012 iDEAST. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	RALoaderItemStatusCache = 0x01, // First status [1]
	RALoaderItemStatusProgress = 0x02, // Intermediate status [n]
	RALoaderItemStatusOk = 0x04,   // Final status [1]
	RALoaderItemStatusFail = 0x08, // Final status [1]
	RALoaderItemStatusComplete = RALoaderItemStatusOk | RALoaderItemStatusFail, // Final status for both: "Ok" & "Fail" [1]
} RALoaderItemStatus;


#pragma mark - LoaderItem (delegate)

@class RALoaderItem;
@protocol RALoaderItemDelegate <NSObject>
@required
- (void)loaderItem:(RALoaderItem *)loaderItem
            status:(RALoaderItemStatus)status
               url:(NSURL *)url
              data:(NSData *)data
          cacheURL:(NSURL *)cacheURL
              date:(NSDate *)date
             error:(NSError *)error
          progress:(float)progress;
@end


#pragma mark - LoaderItem (protocol)

@protocol RALoaderItemProcessDelegate <NSObject>
@optional
// Очередь для загрузчиков данного класса
@property (nonatomic, readonly) BOOL needToCache;
@property (nonatomic, readonly) BOOL needToParse;
@property (nonatomic, readonly) dispatch_queue_t queue;
- (void)modifyReqeust:(NSMutableURLRequest *)request;
- (void)parseResponseData:(NSData *)data;
@end


#pragma mark - LoaderItem (core)

@interface RALoaderItem : NSObject

// Отменить все загрузки для указанного делегата
+ (void)cancelAllForDelegate:(id)delegate;
// Отменить текущую загрузку
- (void)cancel;

// Загрузить данные посредством POST-запроса
+ (RALoaderItem *)loadURLString:(NSString *)urlString withPostParams:(NSDictionary *)params forDelegate:(id<RALoaderItemDelegate>)delegate;
+ (RALoaderItem *)loadURLString:(NSString *)urlString withPostKeys:(const NSString *[])keys postValues:(const id[])values count:(NSUInteger)count forDelegate:(id<RALoaderItemDelegate>)delegate;

// Делегат для управления ходом загрузки
@property (nonatomic, assign) id<RALoaderItemProcessDelegate> processDelegate;

// Параметры загрузки
@property (nonatomic, readonly, retain) NSURL *url;
@property (nonatomic, readonly, retain) NSDictionary *posts;

// Метод, использующийся для загрузки данных из интернета
//- (NSData *)loadRequest:(NSURLRequest *)request response:(NSURLResponse **)response error:(NSError **)anError;

@end
