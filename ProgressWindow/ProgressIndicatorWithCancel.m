//
//  ProgressIndicatorWithCancel.m
//  oxidizer
//
//  Created by David Burnett on 26/04/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ProgressIndicatorWithCancel.h"


@implementation ProgressIndicatorWithCancel


- (void)setDoubleValueInMainThread:(NSNumber *)value {
	
	[self performSelectorOnMainThread:@selector(__setDoubleValueInMainThread:) withObject:value waitUntilDone:NO];
	
}



- (void)__setDoubleValueInMainThread:(NSNumber *)value {
	
	[self setDoubleValue:[value doubleValue]];
	[self displayIfNeeded];
	
}

- (BOOL)shouldCancel {
	
	return _cancel;
	
}
- (void)setCancel:(BOOL)cancel {
	
	_cancel = cancel;
}



@end
