//
//  ImageFormatToHideTransform.m
//  oxidizer
//
//  Created by David Burnett on 05/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ImageFormatIsPNG.h"


@implementation ImageFormatIsPNG

+ (Class)transformedValueClass { return [NSNumber class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {

	NSString *format = (NSString *)value;
	if ([format compare:@"PNG"] == 0 ) {

		return [NSNumber numberWithBool:NO];
	}

	return[NSNumber numberWithBool:YES];


}



@end
