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

// Запись в кеш по URL и со временем последнего изменения объекта
+ (BOOL)setCache:(NSData *)value withDate:(NSDate *)date forURL:(NSURL *)url;
+ (BOOL)setCache:(NSData *)value withDate:(NSDate *)date forURL:(NSURL *)url withSuffix:(NSString *)suffix;

// Проверяет есть ли такая запись в кэше (без извлечения данных)
+ (BOOL)isURLCached:(NSURL *)url;
+ (void)removeCacheForURL:(NSURL *)url;

// Получение значения из кеша
+ (NSData *)cacheForURL:(NSURL *)url;
+ (NSData *)cacheForURL:(NSURL *)url withSuffix:(NSString *)suffix;
+ (NSData *)cacheForURL:(NSURL *)url withDate:(NSDate **)date;

// Получение картинки из кеша
+ (UIImage *)cacheImageForURL:(NSURL *)url;
+ (UIImage *)cacheImageForURL:(NSURL *)url withSuffix:(NSString *)suffix;

// Очистка кеша
+ (void)clear;

@end
