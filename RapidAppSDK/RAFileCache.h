//
//  RAFileCache.h
//  TNK-BP
//
//  Created by Anton Serebryakov on 29.11.12.
//  Copyright (c) 2012 iDEAST. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RAFileCache : NSObject

// Путь к файлу в кэше
+ (NSURL *)cacheURLForURL:(NSURL *)url;

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
