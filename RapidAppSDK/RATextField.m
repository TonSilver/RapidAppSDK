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
	return ra_CGRectInsetWithEdges(bounds, _ra_EdgeInsets);
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return ra_CGRectInsetWithEdges(bounds, _ra_EdgeInsets);
}
- (CGRect)borderRectForBounds:(CGRect)bounds {
	return ra_CGRectInsetWithEdges(bounds, _ra_EdgeInsets);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
	return ra_CGRectInsetWithEdges(bounds, _ra_EdgeInsets);
}

- (void)setRa_ErrorInText:(BOOL)yesNo
{
	if (yesNo && !_ra_ErrorInText)
	{
		self.layer.borderWidth = 1;
		self.layer.borderColor = [UIColor redColor].CGColor;
	}
	else if (!yesNo && _ra_ErrorInText)
	{
		self.layer.borderWidth = 0;
		self.layer.borderColor = NULL;
	}
	_ra_ErrorInText = yesNo;
}

@end
