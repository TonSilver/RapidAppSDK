//
//  RAHelper.h
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


#define RA_SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#define RA_C255(NUM255) (NUM255 / 255.f)
#define RA_UICOLOR_FROM_RGBa(R, G, B, A) [UIColor colorWithRed:RA_C255(R) green:RA_C255(G) blue:RA_C255(B) alpha:A]
#define RA_UICOLOR_FROM_Wa(W, A) [UIColor colorWithWhite:RA_C255(W) alpha:A]
#define RA_ARE_OBJECTS_EQUAL(ONE, IS_EQUAL_SELECTOR, TWO) (!((!!ONE != !!TWO) || (ONE && TWO && ![ONE IS_EQUAL_SELECTOR TWO])))


extern CGRect ra_CGRectInsetWithEdges(CGRect rect, UIEdgeInsets inset);
extern CGRect ra_CGRectWithSizeCenteredInRect(CGRect rect, CGFloat width, CGFloat height);


typedef void (^RAAlertViewClickedButtonAtIndexAction)(UIAlertView *alertView, NSInteger buttonIndex);


@interface RAHelper : NSObject <UIAlertViewDelegate>

#pragma makr - Checking

// Проверка корректности емэйла
+ (BOOL)isEmailCorrect:(NSString *)string;

#pragma mark - (Dictionary)

// Делает словарь из указанных объектов и ключей, в которых могут содержаться "нули" (nil, NULL)
+ (NSDictionary *)dictionaryWithBadObjects:(const id [])objects forBadKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt;

#pragma mark - (Locale)

+ (NSString *)currentLocale;

#pragma mark - UIWebView

+ (void)webView:(UIWebView *)webView setLikeScrollView:(BOOL)likeScrollView;

#pragma mark - UIAlertView

+ (RAAlertViewClickedButtonAtIndexAction)alertViewClickedButtonAtIndexAction:(UIAlertView *)alertView;
+ (UIAlertView *)alertView:(UIAlertView *)alertView setClickedButtonAtIndexAction:(RAAlertViewClickedButtonAtIndexAction)action;

#pragma mark - UIImage

+ (UIImage *)imageFromImage:(UIImage *)image scaledToFitSize:(CGSize)size;
+ (UIImage *)imageFromImage:(UIImage *)image croopedToFitSize:(CGSize)size;

+ (UIImage *)resizableRoundedImageWithSize:(CGSize)size color:(UIColor *)color cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

+ (UIImage *)image:(UIImage *)image colorizedWithColor:(UIColor *)color;

+ (UIImage *)imageWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color;

#pragma mark - NSError

+ (NSError *)errorWithDescription:(NSString *)desc code:(NSInteger)code;

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
