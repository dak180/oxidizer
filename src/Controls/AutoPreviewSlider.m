//
//  AutoPreviewSlider.m
//  oxidizer
//
//  Created by David Burnett on 09/09/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AutoPreviewSlider.h"


@implementation AutoPreviewSlider

- (void)mouseDown:(NSEvent *)theEvent {

	[super mouseDown:theEvent];
	[ffm previewCurrentFlame:self];
}



@end
