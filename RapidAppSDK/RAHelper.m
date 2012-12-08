//
//  RAHelper.m
//  RapidAppSDK
//
//  Created by Anton Serebryakov on 08.12.12.
//  Copyright (c) 2012 Bampukugan Corp. All rights reserved.
//

#import "RAHelper.h"
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

+ (id)shared
{
	static RAHelper *SharedHelper = nil;
	if (!SharedHelper)
		SharedHelper = [RAHelper new];
	return SharedHelper;
}

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
	NSUInteger count = _objCache.count;
	[_objCache release]; _objCache = nil;
	NSLog(@"[RAHelper] Cleared cache for %i objects", count);
}

@end
