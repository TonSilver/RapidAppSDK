//
//  RAHelper.m
//

#import "RAHelper.h"
#import "RAHelperPrivate.h"
#import "RASharedPrivate.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>


#pragma mark - Helper (Private)

@interface RAHelper ()
{
@private
	NSMutableDictionary *_objCache;
}
@end


#pragma mark - Implementations!

@implementation RAHelper
SHARED_METHOD_IMPLEMENTATION


#pragma mark - (Dictionary)

// Делает словарь из указанных объектов и ключей, в которых могут содержаться "нули" (nil, NULL)
+ (NSDictionary *)dictionaryWithBadObjects:(const id [])objects forBadKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:cnt];
	for (NSUInteger idx = 0; idx < cnt; idx++)
	{
		id value = objects[idx];
		if (value)
		{
			const id <NSCopying> key = keys[idx];
			if (key)
				[params setValue:value forKey:(id)key];
		}
	}
	NSDictionary *result = [[params copy] autorelease];
	[params release];
	return result;
}


#pragma mark - (Locale)

+ (NSString *)currentLocale
{
	NSArray *langs = [NSLocale preferredLanguages];
	NSString *langId = langs.count ? langs[0] : nil;
	return langId;
}



#pragma mark - UIImage

typedef enum {
    RAImageResizeCrop,	// analogous to UIViewContentModeScaleAspectFill, i.e. "best fit" with no space around.
    RAImageResizeCropStart,
    RAImageResizeCropEnd,
    RAImageResizeScale	// analogous to UIViewContentModeScaleAspectFit, i.e. scale down to fit, leaving space around if necessary.
} RAImageResizingMethod;

+ (UIImage *)imageFromImage:(UIImage *)image scaledToFitSize:(CGSize)size {
    return [self imageFromImage:image toFitSize:size usingMethod:RAImageResizeScale];
}

+ (UIImage *)imageFromImage:(UIImage *)image croopedToFitSize:(CGSize)size {
    return [self imageFromImage:image toFitSize:size usingMethod:RAImageResizeCrop];
}

+ (UIImage *)imageFromImage:(UIImage *)originalImg toFitSize:(CGSize)fitSize usingMethod:(RAImageResizingMethod)resizeMethod
{
    float imageScaleFactor = 1.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([originalImg respondsToSelector:@selector(scale)]) {
		imageScaleFactor = [originalImg scale];
	}
#endif
    
	float sourceWidth = originalImg.size.width * imageScaleFactor;
	float sourceHeight = originalImg.size.height * imageScaleFactor;
	float targetWidth = fitSize.width;
	float targetHeight = fitSize.height;
	BOOL cropping = !(resizeMethod == RAImageResizeScale);
    
	// Calculate aspect ratios
	float sourceRatio = sourceWidth / sourceHeight;
	float targetRatio = targetWidth / targetHeight;
    
	// Determine what side of the source image to use for proportional scaling
	BOOL scaleWidth = (sourceRatio <= targetRatio);
	// Deal with the case of just scaling proportionally to fit, without cropping
	scaleWidth = (cropping) ? scaleWidth : !scaleWidth;
    
	// Proportionally scale source image
	float scalingFactor, scaledWidth, scaledHeight;
	if (scaleWidth) {
		scalingFactor = 1.0 / sourceRatio;
		scaledWidth = targetWidth;
		scaledHeight = round(targetWidth * scalingFactor);
	} else {
		scalingFactor = sourceRatio;
		scaledWidth = round(targetHeight * scalingFactor);
		scaledHeight = targetHeight;
	}
	float scaleFactor = scaledHeight / sourceHeight;
    
	// Calculate compositing rectangles
	CGRect sourceRect, destRect;
	if (cropping) {
		destRect = CGRectMake(0, 0, targetWidth, targetHeight);
		float destX = 0, destY = 0;
		if (resizeMethod == RAImageResizeCrop) {
			// Crop center
			destX = round((scaledWidth - targetWidth) / 2.0);
			destY = round((scaledHeight - targetHeight) / 2.0);
		} else if (resizeMethod == RAImageResizeCropStart) {
			// Crop top or left (prefer top)
			if (scaleWidth) {
				// Crop top
				destX = 0.0;
				destY = 0.0;
			} else {
				// Crop left
				destX = 0.0;
				destY = round((scaledHeight - targetHeight) / 2.0);
			}
		} else if (resizeMethod == RAImageResizeCropEnd) {
			// Crop bottom or right
			if (scaleWidth) {
				// Crop bottom
				destX = round((scaledWidth - targetWidth) / 2.0);
				destY = round(scaledHeight - targetHeight);
			} else {
				// Crop right
				destX = round(scaledWidth - targetWidth);
				destY = round((scaledHeight - targetHeight) / 2.0);
			}
		}
		sourceRect = CGRectMake(destX / scaleFactor, destY / scaleFactor,
								targetWidth / scaleFactor, targetHeight / scaleFactor);
	} else {
		sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
		destRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
	}
    
	// Create appropriately modified image.
	UIImage *image = nil;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	CGImageRef sourceImg = nil;
	if ([UIScreen instancesRespondToSelector:@selector(scale)])
    {
		UIGraphicsBeginImageContextWithOptions(destRect.size, NO, 0.f); // 0.f for scale means "scale for device's main screen".
		sourceImg = CGImageCreateWithImageInRect(originalImg.CGImage, sourceRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:originalImg.imageOrientation]; // create cropped UIImage.
	}
    else
    {
		UIGraphicsBeginImageContext(destRect.size);
		sourceImg = CGImageCreateWithImageInRect(originalImg.CGImage, sourceRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg]; // create cropped UIImage.
	}
    
	CGImageRelease(sourceImg);
	[image drawInRect:destRect]; // the actual scaling happens here, and orientation is taken care of automatically.
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
#endif
    
	if (!image) {
		// Try older method.
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, scaledWidth, scaledHeight, 8, (scaledWidth * 4),
													 colorSpace, kCGImageAlphaPremultipliedLast);
		CGImageRef sourceImg = CGImageCreateWithImageInRect(originalImg.CGImage, sourceRect);
		CGContextDrawImage(context, destRect, sourceImg);
		CGImageRelease(sourceImg);
		CGImageRef finalImage = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		image = [UIImage imageWithCGImage:finalImage];
		CGImageRelease(finalImage);
	}
    
	return image;
}


#pragma mark - (DateFormatter)

// Получить форматтер нужного формата
+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)dateFormat
{
	RA_CACHE_BEGIN_KEY(dateFormat)
	NSDateFormatter *formatter = [NSDateFormatter new];
	[formatter setDateFormat:dateFormat];
	NSString *langId = [self currentLocale];
	if (langId)
	{
		NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:langId] autorelease];
		[formatter setLocale:locale];
	}
	return [formatter autorelease];
	RA_CACHE_END
}


#pragma mark - (String)

// MD5 hash from string
+ (NSString *)md5FromString:(NSString *)string
{
	if (!string)
		return nil;
	
	const char *cStr = [string UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, strlen(cStr), result);
	NSMutableString *resultStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[resultStr appendFormat:@"%02x", result[i]];
	return [[resultStr copy] autorelease];
}

// Сделать дату из строки, используя формат
+ (NSDate *)dateWithFormat:(NSString *)dateFormat fromString:(NSString *)string
{
	return [[self dateFormatterWithFormat:dateFormat] dateFromString:string];
}

// Сделать строку из даты, используя формат
+ (NSString *)stringWithFormat:(NSString *)dateFormat fromDate:(NSDate *)date
{
	return [[self dateFormatterWithFormat:dateFormat] stringFromDate:date];
}

// Возвращает дату из строки, используемой в HTTP-заголовках
+ (NSDate *)httpHeaderLastModifiedFromString:(NSString *)string
{
	static NSString *DateRFC822Format = @"EEE, dd LLL yyyy HH:mm:ss z";
	static NSString *DateRFC850Format = @"EEEE, dd-LLL-yy HH:mm:ss z";
	NSDate *date = [self dateWithFormat:DateRFC822Format fromString:string];
	if (!date)
		return date = [self dateWithFormat:DateRFC850Format fromString:string];
	return nil;
}

// Возвращает не более N символов с конца строки
+ (NSString *)suffixOfString:(NSString *)string maxLength:(NSInteger)maxLength
{
	if (string)
	{
		NSInteger len = string.length;
		if (len <= maxLength)
			return string;
		else
		{
			if (maxLength > 3)
				maxLength -= 3;
			return [@"..." stringByAppendingString:[string substringFromIndex:len - maxLength]];
		}
	}
	return nil;
}


#pragma mark - Cache

- (id)valueForKey:(NSString *)key withBlock:(id(^)(void))block
{
	if (!_objCache)
		_objCache = [NSMutableDictionary new];
	
	id value = _objCache[key];
	if (!value && block)
		if ((value = block()))
			_objCache[key] = value;
	return value;
}

#pragma mark - Core

- (void)dealloc
{
	[_objCache release];
	[super dealloc];
}

- (id)init
{
	if ((self = [super init]))
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"[RAHelper] Clear cache for %i objects", _objCache.count);
	[_objCache release];
	_objCache = nil;
}

@end
