//
//  NSProgressIndicatorUpdateOnMainThread.h
//  oxidizer
//
//  Created by David Burnett on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <AppKit/NSProgressIndicator.h>


@interface NSProgressIndicator (NSProgressIndicatorUpdateOnMainThread)



- (void)setDoubleValueInMainThread:(NSNumber *)doubleValue;



- (void)__setDoubleValueInMainThread:(NSNumber *)doubleValue;

@end
