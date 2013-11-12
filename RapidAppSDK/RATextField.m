//
//  RATextField.m
//  RapidAppSDK
//
//  Created by Anton Serebryakov on 12.11.13.
//  Copyright (c) 2013 Bampukugan Corp. All rights reserved.
//

#import "RATextField.h"
#import "RAHelper.h"


@implementation RATextField

- (CGRect)textRectForBounds:(CGRect)bounds {
	return ra_CGRectInsetWithEdges(bounds, self.ra_EdgeInsets);
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return ra_CGRectInsetWithEdges(bounds, self.ra_EdgeInsets);
}
- (CGRect)borderRectForBounds:(CGRect)bounds {
	return ra_CGRectInsetWithEdges(bounds, self.ra_EdgeInsets);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
	return ra_CGRectInsetWithEdges(bounds, self.ra_EdgeInsets);
}

@end
