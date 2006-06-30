//
//  GreaterThanThreeTransformer.m
//  oxidizer
//
//  Created by David Burnett on 30/06/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GreaterThanThreeTransformer.h"


@implementation GreaterThanThreeTransformer

+ (Class)transformedValueClass { return [NSNumber class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {

	if ([value selectionIndex] > 0 && [[value arrangedObjects] count] > 3 && [value selectionIndex] != [[value arrangedObjects] count] - 1) {


		return [NSNumber numberWithBool:YES];
	} 
	

	NSArray *selected  = [value selectedObjects]; 
	
	if(value != nil && [selected count] > 0) {	
//		[[[value selectedObjects] objectAtIndex:0] willChangeValueForKey:@"interpolation"];
		[[selected objectAtIndex:0] setPrimitiveValue:[NSNumber numberWithInt:0] forKey:@"interpolation"];
	}
		
	return[NSNumber numberWithBool:NO];


}

@end

