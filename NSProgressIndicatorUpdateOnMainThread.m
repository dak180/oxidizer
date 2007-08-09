//
//  NSProgressIndicatorUpdateOnMainThread.m
//  oxidizer
//
//  Created by David Burnett on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSProgressIndicatorUpdateOnMainThread.h"

@implementation NSProgressIndicator (NSProgressIndicatorUpdateOnMainThread) 

- (void)setDoubleValueInMainThread:(NSNumber *)value {
	
	[self performSelectorOnMainThread:@selector(__setDoubleValueInMainThread:) withObject:value waitUntilDone:NO];

}

- (void)__setDoubleValueInMainThread:(NSNumber *)value {

	[self setDoubleValue:[value doubleValue]];
	[self displayIfNeeded];
	
}

@end

