//
//  RASharedPrivate.h
//

#import <Foundation/Foundation.h>

#define SHARED_METHOD_IMPLEMENTATION \
+ (instancetype)shared { \
	static id SharedInstance = nil; \
	if (!SharedInstance) \
		SharedInstance = [self new]; \
	return SharedInstance; \
}
