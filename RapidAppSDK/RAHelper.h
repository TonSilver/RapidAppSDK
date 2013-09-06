//
//  RAHelper.h
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


#define RA_C255(NUM255) (NUM255 / 255.f)
#define RA_ARE_OBJECTS_EQUAL(ONE, IS_EQUAL_SELECTOR, TWO) (!((!!ONE != !!TWO) || (ONE && TWO && ![ONE IS_EQUAL_SELECTOR TWO])))


@interface RAHelper : NSObject

#pragma mark - (Dictionary)

// Делает словарь из указанных объектов и ключей, в которых могут содержаться "нули" (nil, NULL)
+ (NSDictionary *)dictionaryWithBadObjects:(const id [])objects forBadKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt;

#pragma mark - (Locale)

+ (NSString *)currentLocale;

#pragma mark - UIImage

+ (UIImage *)imageFromImage:(UIImage *)image scaledToFitSize:(CGSize)size;
+ (UIImage *)imageFromImage:(UIImage *)image croopedToFitSize:(CGSize)size;

+ (UIImage *)resizableRoundedImageWithSize:(CGSize)size color:(UIColor *)color cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

#pragma mark - NSDateFormatter

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)dateFormat;

#pragma mark - NSDate

+ (NSDate *)dateWithMonths:(NSInteger)months sinceDate:(NSDate *)date;

#pragma mark - NSString

// MD5 hash from string
+ (NSString *)md5FromString:(NSString *)string;
// Сделать дату из строки, используя формат
+ (NSDate *)dateWithFormat:(NSString *)dateFormat fromString:(NSString *)string;
// Сделать строку из даты, используя формат
+ (NSString *)stringWithFormat:(NSString *)dateFormat fromDate:(NSDate *)date;
// Возвращает дату из строки, используемой в HTTP-заголовках
+ (NSDate *)httpHeaderLastModifiedFromString:(NSString *)string;

// Возвращает не более N символов с конца строки
+ (NSString *)suffixOfString:(NSString *)string maxLength:(NSInteger)maxLength;

#pragma mark - Caching

// Единажды создает экземпляр данного класса
+ (instancetype)shared;

// Через shared-object
- (id)valueForKey:(NSString *)key withBlock:(id(^)(void))block;

#pragma mark - Debugging

+ (void)debug_setFileLogPath:(NSString *)path;
+ (void)debug_write:(NSData *)data inFile:(NSString *)fileName;

@end
