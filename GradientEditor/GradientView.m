//
//  GradientView.m
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GradientView.h"
#import "GradientController.h"

#define NOT_SELECTED_GREY 0.5

@implementation GradientView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		gradientImage = [[NSImage alloc] init];
		gradientRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																	 pixelsWide:GRADIENT_IMAGE_WIDTH
																		pixelsHigh:GRADIENT_IMAGE_HEIGHT
																				   bitsPerSample:8
																				 samplesPerPixel:3
																						hasAlpha:NO 
																						isPlanar:NO
																				  colorSpaceName:NSDeviceRGBColorSpace
																					bitmapFormat:0
																					 bytesPerRow:3*GRADIENT_IMAGE_WIDTH
																					bitsPerPixel:24]; 
		memset([gradientRep bitmapData], 255, GRADIENT_IMAGE_WIDTH * GRADIENT_IMAGE_HEIGHT * 3);
		[gradientImage addRepresentation:gradientRep];
  		
    }
    return self;
}

-(void) awakeFromNib { 
	
	[[self window] setAcceptsMouseMovedEvents:YES]; 
	
} 

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	
	NSArray *selectedObjects =  [gradientArrayController selectedObjects];
	NSDictionary *selectedSwatch;
	
	if  ([selectedObjects count] > 0) {
		selectedSwatch = [selectedObjects objectAtIndex:0];	
	} else {
		if ([[gradientArrayController arrangedObjects] count] == 0) {
			
			[(GradientController *)delegate newGradient:self];
			selectedSwatch = [[gradientArrayController arrangedObjects] objectAtIndex:0];
		} else {
			
			selectedSwatch = nil;
		}
	}
	
	NSArray *gradientArray = [gradientArrayController arrangedObjects];

	CGContextRef context = [[NSGraphicsContext currentContext]graphicsPort];
	CGContextSaveGState(context);
	
	NSRect frame = [self frame];
	NSRect gradientRect;
	
	frame.origin.x = 0;
	frame.origin.y = 0;

	gradientRect.origin.x = (frame.size.width * 0.5) - ((float )GRADIENT_IMAGE_WIDTH);
	gradientRect.origin.y = (frame.size.height * 0.8);

	gradientRect.size.width = GRADIENT_IMAGE_WIDTH * 2.0;
	gradientRect.size.height = GRADIENT_IMAGE_HEIGHT * 2.0;
	
	[[NSColor blueColor] set];
	NSRectFill(gradientRect);
	
	[gradientImage drawInRect:gradientRect
			 fromRect: NSZeroRect
			operation: NSCompositeCopy
			 fraction: 1.0];
	
	
	CGFloat swatchScale = (frame.size.width - SWATCH_OFFSET - SWATCH_OFFSET) / 255.0;
	
	/* draw the swatches */
	NSDictionary *colourDict;

	int i, index;
	CGFloat red, green, blue;
	
	CGContextSetRGBStrokeColor (context, NOT_SELECTED_GREY, NOT_SELECTED_GREY, NOT_SELECTED_GREY, 1); 
		
	for(i = 0; i<[gradientArray count]; i++) {
	
		colourDict = [gradientArray objectAtIndex:i];
		if(colourDict == selectedSwatch) {
			continue;			
		} 
		
		red = [[colourDict objectForKey:@"red"] floatValue];
		green = [[colourDict objectForKey:@"green"] floatValue];
		blue = [[colourDict objectForKey:@"blue"] floatValue];
		index = [[colourDict objectForKey:@"index"] intValue];

		CGContextSetLineWidth(context, 2.0);

		CGContextMoveToPoint(context, gradientRect.origin.x + (index * 2.0)  , gradientRect.origin.y);
		CGContextAddLineToPoint(context, SWATCH_OFFSET + (index * swatchScale), SWATCH_OFFSET);
		CGContextClosePath(context);
		CGContextStrokePath(context);

		CGContextSetLineWidth(context, 1.0);
		
		CGContextSetRGBFillColor (context, red, green, blue, 1); 
		
		CGContextAddArc(context, SWATCH_OFFSET + (index * swatchScale), SWATCH_OFFSET, SWATCH_RADIUS, 0.0, 2.0 * M_PI, 0);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		
		
	}
	
	if (selectedSwatch != nil) {
		
		red = [[selectedSwatch objectForKey:@"red"] floatValue];
		green = [[selectedSwatch objectForKey:@"green"] floatValue];
		blue = [[selectedSwatch objectForKey:@"blue"] floatValue];
		index = [[selectedSwatch objectForKey:@"index"] intValue];

		CGContextSetLineWidth(context, 2.0);
		
		CGContextSetRGBStrokeColor (context, 0.0, 0.0, 0.0, 1); 
		
		CGContextMoveToPoint(context, gradientRect.origin.x + (index * 2.0)  , gradientRect.origin.y);
		CGContextAddLineToPoint(context, SWATCH_OFFSET + (index * swatchScale), SWATCH_OFFSET);
		CGContextClosePath(context);
		CGContextStrokePath(context);
		
		CGContextSetLineWidth(context, 1.0);
		
		CGContextSetRGBFillColor (context, red, green, blue, 1); 
		
		CGContextAddArc(context, SWATCH_OFFSET + (index * swatchScale), SWATCH_OFFSET, SWATCH_RADIUS, 0.0, 2.0 * M_PI, 0);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
	
	}	
	
	CGContextRestoreGState(context);

	
}


- (void) setDelegate:(id)newDelegate {
	
	if(newDelegate != nil) {
		[newDelegate retain];
	}
	
	[delegate release];
	delegate = newDelegate;
	
	
}


-(NSBitmapImageRep *)getGradientRep {
	
	return gradientRep;
	
}


-(void) setGradientArrayController:(NSArrayController *)controller {
	
	if(controller != nil) {
		[controller retain];
	}
	
	[gradientArrayController release];
	gradientArrayController = controller;
	
}


-(void) setSelectedSwatch:(NSMutableDictionary *)swatch {

	/*
	if(swatch != nil) {
		[swatch retain];
	}
	
	[selectedSwatch release];
	selectedSwatch = swatch;
	 
	 
	selectedIndex = [[selectedSwatch  objectForKey:@"index"] intValue];
	*/ 
	[self display];

}

- (void)mouseDown:(NSEvent *)theEvent {
	
	NSArray *gradientArray = [gradientArrayController arrangedObjects];

	int i;
	NSDictionary *selectedSwatch = nil;
	NSDictionary *oldSelectedSwatch;
	
	NSArray *selectedObjects = [gradientArrayController selectedObjects];
	
	if(selectedObjects == nil || [selectedObjects count] == 0) {
		oldSelectedSwatch = nil;		
	} else {
		oldSelectedSwatch = [selectedObjects objectAtIndex:0];
	}	

	CGFloat swatchOffsetX, swatchOffsetY;

	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect frame = [self frame];

	CGFloat swatchScale = (frame.size.width - SWATCH_OFFSET - SWATCH_OFFSET) / 255.0;

	swatchOffsetY = SWATCH_OFFSET  - mousePoint.y;

	draggingSwatch = NO;

	for(i = 0; i<[gradientArray count]; i++) {
		
		swatchOffsetX = (SWATCH_OFFSET + ([[[gradientArray objectAtIndex:i] objectForKey:@"index"] intValue] * swatchScale)) - mousePoint.x;
		
		if((swatchOffsetX * swatchOffsetX) + (swatchOffsetY * swatchOffsetY) < (SWATCH_RADIUS * SWATCH_RADIUS)) {
			selectedSwatch = [gradientArray objectAtIndex:i];
			draggingSwatch = YES;
			break;
		}
		
	}
	
	
	if(oldSelectedSwatch != selectedSwatch && selectedSwatch != nil) {

		[(GradientController *)delegate setSelectedColour:selectedSwatch];
		[self display];
	} 
	
	
}

- (void)mouseDragged:(NSEvent *)theEvent { 

	if(draggingSwatch == NO) {
		return;
	}
	
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect frame = [self frame];

	CGFloat swatchScale = (frame.size.width - SWATCH_OFFSET - SWATCH_OFFSET) / 255.0;

	int colourIndex = (mousePoint.x - SWATCH_OFFSET) /  swatchScale;
	
	if(colourIndex < 0) {
		colourIndex = 0;
	} else if (colourIndex > 255) {
		colourIndex = 255;
	}

	NSMutableDictionary *selectedSwatch;
	
	NSArray *selectedObjects = [gradientArrayController selectedObjects];  
	
	if(selectedObjects == nil || [selectedObjects count] == 0) {
		return;		
	} else {
		selectedSwatch = [selectedObjects objectAtIndex:0];
	}	
	
	[selectedSwatch willChangeValueForKey:@"index"];
	[selectedSwatch setObject:[NSNumber numberWithInt:colourIndex] forKey:@"index"];
	[selectedSwatch didChangeValueForKey:@"index"];
		
	[(GradientController *)delegate fillGradientImageRep];
	[self display];
} 

- (void)mouseUp:(NSEvent *)theEvent { 
	
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect frame = [self frame];

	if(draggingSwatch == NO) {
		if([self isMouseEventInGradientImage:theEvent] == YES) {
			NSRect gradientRect;
			
			frame.origin.x = 0;
			frame.origin.y = 0;
			
			gradientRect.origin.x = (frame.size.width * 0.5) - ((float )GRADIENT_IMAGE_WIDTH);
			gradientRect.origin.y = (frame.size.height * 0.8);
			
			gradientRect.size.width = GRADIENT_IMAGE_WIDTH * 2.0;
			gradientRect.size.height = GRADIENT_IMAGE_HEIGHT * 2.0;
			
	//		int pointInArray = (mousePoint.x - gradientRect.origin.x) / 2.0;
			
			
		}
		return;
	}

	NSMutableDictionary *selectedSwatch;

	NSArray *selectedObjects = [gradientArrayController selectedObjects];
	
	if(selectedObjects == nil || [selectedObjects count] == 0) {
		return;		
	} else {
		selectedSwatch = [selectedObjects objectAtIndex:0];
	}	
	int selectedIndex = [gradientArrayController selectionIndex]; 
	NSArray *gradientArray = [gradientArrayController arrangedObjects];
		
	CGFloat swatchScale = (frame.size.width - SWATCH_OFFSET - SWATCH_OFFSET) / 255.0;
	
	int colourIndex = (mousePoint.x - SWATCH_OFFSET) /  swatchScale;
	
	if(colourIndex < 0) {
		colourIndex = 0;
	} else if (colourIndex > 255) {
		colourIndex = 255;
	}
	

	int i;
	
	for(i = 0; i < [gradientArray count] && [[[gradientArray objectAtIndex:i] objectForKey:@"index"] intValue] <= colourIndex; i++) {
		
		if([[[gradientArray objectAtIndex:i] objectForKey:@"index"] intValue] == colourIndex
			 && [gradientArray objectAtIndex:i] != selectedSwatch) {
			
			colourIndex++;
		}
		
	}

	if (colourIndex > 255) {
		NSBeep();
		colourIndex = selectedIndex;
	}
	
	[selectedSwatch willChangeValueForKey:@"index"];
	[selectedSwatch setObject:[NSNumber numberWithInt:colourIndex] forKey:@"index"];
	[selectedSwatch didChangeValueForKey:@"index"];

	[self display];
	
	[(GradientController *)delegate gradientChanged];

}


- (bool)isMouseEventInGradientImage:(NSEvent *)theEvent {
	
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect frame = [self frame];
	NSRect gradientRect;
	
	frame.origin.x = 0;
	frame.origin.y = 0;
	
	gradientRect.origin.x = (frame.size.width * 0.5) - ((float )GRADIENT_IMAGE_WIDTH);
	gradientRect.origin.y = (frame.size.height * 0.8);
	
	gradientRect.size.width = GRADIENT_IMAGE_WIDTH * 2.0;
	gradientRect.size.height = GRADIENT_IMAGE_HEIGHT * 2.0;
	
	if (mousePoint.x >= gradientRect.origin.x &&  mousePoint.x <= gradientRect.origin.x + gradientRect.size.width &&
		mousePoint.y >= gradientRect.origin.y &&  mousePoint.y <= gradientRect.origin.y + gradientRect.size.height) {
		
		return YES;
	} 
	
	return NO;
	
}

@end
