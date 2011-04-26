//
//  ProgressIndicatorWithCancel.h
//  oxidizer
//
//  Created by David Burnett on 26/04/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProgressIndicatorWithCancel : NSProgressIndicator {

	BOOL _cancel;

}


- (void)setDoubleValueInMainThread:(NSNumber *)doubleValue;
- (void)__setDoubleValueInMainThread:(NSNumber *)doubleValue;

- (BOOL)shouldCancel;
- (void)setCancel:(BOOL)cancel;

@end
