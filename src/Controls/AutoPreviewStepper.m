//
//  AutoPreviewStepper.m
//  oxidizer
//
//  Created by David Burnett on 08/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AutoPreviewStepper.h"


@implementation AutoPreviewStepper

- (void)mouseDown:(NSEvent *)theEvent {

	[super mouseDown:theEvent];
	[ffm previewCurrentFlame:self];
}


@end
