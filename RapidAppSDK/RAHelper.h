//
//  RAHelper.h
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


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

#pragma mark - Caching

// Единажды создает экземпляр данного класса
+ (instancetype)shared;

// Через shared-object
- (id)valueForKey:(NSString *)key withBlock:(id(^)(void))block;

@end
