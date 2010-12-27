//
//  untitled.m
//  oxidizer
//
//  Created by David Burnett on 05/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ImageFormatIsJPEG.h"

@implementation ImageFormatIsJPEG

+ (Class)transformedValueClass { return [NSNumber class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {

	NSString *format = (NSString *)value;
	if ([format compare:@"JPEG"] == 0 ) {

		return [NSNumber numberWithBool:NO];
	}

	return[NSNumber numberWithBool:YES];


}



@end
