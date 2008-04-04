//
//  GradientView.h
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define GRADIENT_IMAGE_HEIGHT 20
#define GRADIENT_IMAGE_WIDTH 256

#define SWATCH_OFFSET 20.0
#define SWATCH_RADIUS 10.0

@interface GradientView : NSView {

	
@private
	
	NSArray *gradientArray;
	NSBitmapImageRep *gradientRep;
	NSImage *gradientImage;
	NSMutableDictionary *selectedSwatch;
	
	id delegate;
	
	int selectedIndex;
	
}

-(NSBitmapImageRep *) getGradientRep;
-(void) setGradientArray:(NSArray *)array;
-(void) setSelectedSwatch:(NSMutableDictionary *)swatch;

- (void) mouseDown:(NSEvent *)theEvent;
- (void) mouseDragged:(NSEvent *)theEvent;

- (void) setDelegate:(id)newDelegate;

@end
