//
//  RAHelper.h
//  RapidAppSDK
//
//  Created by Anton Serebryakov on 08.12.12.
//  Copyright (c) 2012 Bampukugan Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


#define RA_SHORTYFY(STR, CNT) ([STR length] > (CNT) ? [STR substringFromIndex:[STR length] - (CNT)] : STR)


#pragma mark - Макросы блоков для кеширования

// Начала для блока, кеширующего вывод
#define RA_CACHE_BEGIN return [[RAHelper shared] valueForKey:NSStringFromSelector(_cmd) withBlock:^id {
#define RA_CACHE_BEGIN_KEY(FORMAT, ...) return [[RAHelper shared] valueForKey:[NSStringFromSelector(_cmd) stringByAppendingFormat:FORMAT, ##__VA_ARGS__] withBlock:^id {
// Окончание для блока, кэширующих данные
#define RA_CACHE_END }];
// Кешируем и выдает значение одной команды
#define RA_CACHE(COMMAND) return [[RAHelper shared] valueForKey:NSStringFromSelector(_cmd) withBlock:^id { return COMMAND; }]
// Кширует и выдает значение одной команды записанной под определенным ключем
#define RA_CACHE_KEY(COMMAND, FORMAT, ...) return [[RAHelper shared] valueForKey:[NSStringFromSelector(_cmd) stringByAppendingFormat:FORMAT, ##__VA_ARGS__] withBlock:^id { return COMMAND; }]


@interface RAHelper : NSObject

#pragma mark - (Dictionary)

// Делает словарь из указанных объектов и ключей, в которых могут содержаться "нули" (nil, NULL)
+ (NSDictionary *)dictionaryWithBadObjects:(const id [])objects forBadKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt;

#pragma mark - (Locale)

+ (NSString *)currentLocale;

#pragma mark - UIImage

+ (UIImage *)imageFromImage:(UIImage *)image scaledToFitSize:(CGSize)size;
+ (UIImage *)imageFromImage:(UIImage *)image croopedToFitSize:(CGSize)size;

#pragma mark - NSString

// MD5 hash from string
+ (NSString *)md5FromString:(NSString *)string;
// Сделать дату из строки, используя формат
+ (NSDate *)dateWithFormat:(NSString *)dateFormat fromString:(NSString *)string;
// Сделать строку из даты, используя формат
+ (NSString *)stringWithFormat:(NSString *)dateFormat fromDate:(NSDate *)date;
// Возвращает дату из строки, используемой в HTTP-заголовках
+ (NSDate *)httpHeaderLastModifiedFromString:(NSString *)string;

@end
