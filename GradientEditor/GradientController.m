//
//  GradientController.m
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GradientController.h"
#import "PaletteController.h"
#import "FlameController.h"

#define COLOUR_SQUARE_SIDE 20

int sortUsingIndex(id colour1, id colour2, void *context);

@implementation GradientController


- (id) init {
	
	if (self = [super init]) {
			colours = [NSMutableArray arrayWithCapacity:2];		
			[colours retain];
	}     
	return self;
}

- (void)awakeFromNib {
    // register for drag and drop
    [gradientTableView registerForDraggedTypes:[NSArray arrayWithObject:NSColorPboardType]];
 	
}


- (IBAction)showWindow:(id)sender {
	
	
	[gradientView setDelegate:self];
	[self fillGradientImageRep]; 
    [gradientView display];
	[gradientView setGradientArrayController:arrayController]; 

	[gradientWindow makeKeyAndOrderFront:self];

}


- (IBAction)editPalette:(id)sender {
	
	NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	
	switch([segments selectedSegment]) {
		case 0: 
			[self addColour];
			break;
		case 1:	
			[arrayController removeObjects:[arrayController selectedObjects]];
			break;
	}
	
	[arrayController rearrangeObjects];
	[gradientView setSelectedSwatch:nil];
	[self fillGradientImageRep];
	[gradientView display];

}


- (IBAction)applyNewPalette:(id)sender {
	NSManagedObject *cmapEntity;
	
	[cmap removeObjects:[cmap arrangedObjects]];
	int i;
	
	for(i=0; i<[colours count]; i++) {
		cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];
		
		[cmapEntity setValue:[NSNumber numberWithDouble:[[[colours objectAtIndex:i] objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[[colours objectAtIndex:i] objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[[colours objectAtIndex:i] objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[cmapEntity setValue:[NSNumber numberWithInt:[[[colours objectAtIndex:i] objectForKey:@"index"] intValue]] forKey:@"index"];
		[cmap insertObject:cmapEntity atArrangedObjectIndex:i];
	}

	[(FlameController *)flameController changeColourMapAndHideWindow:self];
	

}

- (void) setColourArray:(NSArray *)newArray {

	[colours removeAllObjects];
	
	int i;
	
	for(i=0; i<[newArray count]; i++) {

		NSBitmapImageRep *paletteRep;
		NSImage *paletteImage;
		
		NSMutableDictionary *colour = [NSMutableDictionary dictionaryWithCapacity:6];
		NSManagedObject *gradientColour = [newArray objectAtIndex:i];
		[colour setObject:[NSNumber numberWithDouble:[[gradientColour valueForKey:@"red"] doubleValue]] forKey:@"red"];
		[colour setObject:[NSNumber numberWithDouble:[[gradientColour valueForKey:@"green"] doubleValue]] forKey:@"green"];
		[colour setObject:[NSNumber numberWithDouble:[[gradientColour valueForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[colour setObject:[NSNumber numberWithInt:[[gradientColour valueForKey:@"index"] intValue]] forKey:@"index"];

		paletteRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
															pixelsWide:COLOUR_SQUARE_SIDE
															pixelsHigh:COLOUR_SQUARE_SIDE
														 bitsPerSample:8
													   samplesPerPixel:3
															  hasAlpha:NO 
															  isPlanar:NO
														colorSpaceName:NSDeviceRGBColorSpace
														  bitmapFormat:0
														   bytesPerRow:3*256
														  bitsPerPixel:24]; 
		
		paletteImage = [[NSImage alloc] init];
		[paletteImage addRepresentation:paletteRep];
				
		[colour setObject:paletteRep forKey:@"bitmapRep"];
		[colour setObject:paletteImage forKey:@"image"];
		
		[PaletteController fillColour:colour forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
		
		
		[colours addObject:colour];
		
		[paletteImage release];
		[paletteRep release];

	}
	
	[self fillGradientImageRep];
	
}

- (void) fillGradientImageRep {

	NSBitmapImageRep *imageRep = [gradientView getGradientRep];
	
	[colours sortUsingFunction:sortUsingIndex context:nil];
	
	[arrayController rearrangeObjects];
	
	[PaletteController fillBitmapRep:imageRep withColours:colours forHeight:GRADIENT_IMAGE_HEIGHT];
	
}

int sortUsingIndex(id colour1, id colour2, void *context) {
	
	if ([[colour1 objectForKey:@"index"] intValue] < [[colour2 objectForKey:@"index"] intValue]) {
	return NSOrderedAscending;
	} else if ([[colour1 objectForKey:@"index"] intValue] > [[colour2 objectForKey:@"index"] intValue]) {
		return NSOrderedDescending;
	}  
	
	return NSOrderedSame;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	
	[gradientView setSelectedSwatch:[[arrayController selectedObjects] objectAtIndex:0]];
	
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
	
	[PaletteController fillColour:[[arrayController selectedObjects] objectAtIndex:0] forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
	[self fillGradientImageRep];
	[gradientView display];
}

- (void) setSelectedColour:(NSDictionary *)colour {
	
	[arrayController setSelectedObjects:[NSArray arrayWithObject:colour]];
	
}

- (void) addColour {
	
	NSDictionary *selectedColour = [[arrayController selectedObjects] objectAtIndex:0];
	int arrayIndexForSelected = [colours indexOfObject:selectedColour];
	
	if( arrayIndexForSelected + 1 >= [colours count] ) {
		NSBeep();
		return;
	}

	int colourIndex = [[selectedColour objectForKey:@"index"] intValue];
	
	NSDictionary *nextColour = [colours objectAtIndex:arrayIndexForSelected+1];
	int nextIndex = [[nextColour objectForKey:@"index"] intValue];
	
	if(colourIndex + 1 != nextIndex) {
		
		NSMutableDictionary *colour = [NSMutableDictionary dictionaryWithCapacity:4];
		[colour setObject:[NSNumber numberWithDouble:[[selectedColour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[colour setObject:[NSNumber numberWithDouble:[[selectedColour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[colour setObject:[NSNumber numberWithDouble:[[selectedColour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[colour setObject:[NSNumber numberWithInt:(int)(colourIndex + ((nextIndex - colourIndex) / 2.0)) ] forKey:@"index"];

		NSBitmapImageRep *paletteRep;
		NSImage *paletteImage;

		paletteRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
															pixelsWide:COLOUR_SQUARE_SIDE
															pixelsHigh:COLOUR_SQUARE_SIDE
														 bitsPerSample:8
													   samplesPerPixel:3
															  hasAlpha:NO 
															  isPlanar:NO
														colorSpaceName:NSDeviceRGBColorSpace
														  bitmapFormat:0
														   bytesPerRow:3*256
														  bitsPerPixel:24]; 
		
		paletteImage = [[NSImage alloc] init];
		[paletteImage addRepresentation:paletteRep];
		
		[colour setObject:paletteRep forKey:@"bitmapRep"];
		[colour setObject:paletteImage forKey:@"image"];
		
		[PaletteController fillColour:colour forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];

		[colours addObject:colour];
	} else {
		NSBeep();
	}
}

- (NSArray *) getColourArray {
	
	return colours;
}

- (void) setCMapController:(NSArrayController *)newCmap {

	if(newCmap != nil) {
		[newCmap retain];
	}
	
	[cmap release];
	cmap = newCmap;
	
	[self setColourArray:[cmap arrangedObjects]];
   
}

- (void) setFlameController:(id)controller {
	
	if(controller != nil) {
		[controller retain];
	}
	
	[flameController release];
	flameController = controller;
	
	
}


- (NSDragOperation)tableView:(NSTableView*)aTableView
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op {
    
    NSDragOperation dragOp = NSDragOperationCopy;
    
	
    return dragOp;
}


- (BOOL)tableView:(NSTableView*)aTableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op {
	
	
	
	if(row == 0 && op == NSTableViewDropAbove) {
		return FALSE;
	}
	
	NSPasteboard *pasteBoard = [info draggingPasteboard];

	NSColor *colorWellColour = [[NSColor colorFromPasteboard:pasteBoard] colorUsingColorSpaceName:@"NSDeviceRGBColorSpace"];

	float red, green, blue;

	NSMutableDictionary *colourDictionary;
	
	if (op == NSTableViewDropOn) {
		colourDictionary = [colours objectAtIndex:row];
	} else {
		
		NSBitmapImageRep *paletteRep;
		NSImage *paletteImage;		
		
		NSMutableDictionary *colourDictionary1 = [colours objectAtIndex:row-1];
		NSMutableDictionary *colourDictionary2 = [colours objectAtIndex:row];
		
		int index1 = [[colourDictionary1 objectForKey:@"index"] intValue];
		int index2 = [[colourDictionary2 objectForKey:@"index"] intValue];
		
		if( index1 == index2 - 1) {
			return FALSE;
		}
		
		colourDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
		
		[colourDictionary setObject:[NSNumber numberWithInt:(index1 + ((index2 - index1) / 2))] forKey:@"index"];
		
		paletteRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
															pixelsWide:COLOUR_SQUARE_SIDE
															pixelsHigh:COLOUR_SQUARE_SIDE
														 bitsPerSample:8
													   samplesPerPixel:3
															  hasAlpha:NO 
															  isPlanar:NO
														colorSpaceName:NSDeviceRGBColorSpace
														  bitmapFormat:0
														   bytesPerRow:3*256
														  bitsPerPixel:24]; 
		
		paletteImage = [[NSImage alloc] init];
		[paletteImage addRepresentation:paletteRep];
		
		[colourDictionary setObject:paletteRep forKey:@"bitmapRep"];
		[colourDictionary setObject:paletteImage forKey:@"image"];
		
		[colours addObject:colourDictionary];
		
	}

	
	[colorWellColour getRed:&red green:&green blue:&blue alpha:NULL];

	[colourDictionary setObject:[NSNumber numberWithFloat:red] forKey:@"red"];
	[colourDictionary setObject:[NSNumber numberWithFloat:green] forKey:@"green"];
	[colourDictionary setObject:[NSNumber numberWithFloat:blue] forKey:@"blue"];

	[PaletteController fillColour:colourDictionary forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];

	[self fillGradientImageRep];
	[gradientView display];

	return YES;
}

@end
