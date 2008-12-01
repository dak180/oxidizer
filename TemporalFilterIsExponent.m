//
//  TemporalFilterIsExponent.m
//  oxidizer
//
//  Created by David Burnett on 15/11/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TemporalFilterIsExponent.h"


@implementation TemporalFilterIsExponent

+ (Class)transformedValueClass { return [NSNumber class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
	
	NSString *format = (NSString *)value;
	if ([format compare:@"Exponent"] == 0 ) {
		
		return [NSNumber numberWithBool:YES];
	} 
	
	return[NSNumber numberWithBool:NO];
	
	
}

@end
