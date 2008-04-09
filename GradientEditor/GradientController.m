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
		
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
		cmapSortDescriptors = [NSArray arrayWithObject: sort];
		[sort  release]; 
		
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
	NSArray *selected;
	
	switch([segments selectedSegment]) {
		case 0: 
			[self addColour];
			break;
		case 1:	
			selected = [arrayController selectedObjects];
			if([selected count] < [[arrayController arrangedObjects] count]) {
				[arrayController removeObjects:selected];
			}
			break;
	}
	
	[gradientView setSelectedSwatch:nil];
	[self fillGradientImageRep];
	[gradientView display];

}


- (IBAction)applyNewPalette:(id)sender {
	NSManagedObject *cmapEntity;
	
	[cmap removeObjects:[cmap arrangedObjects]];
	int i;
	
	for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
		
		NSDictionary *colour = [[arrayController arrangedObjects] objectAtIndex:i];
		
		cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];
		
		[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[cmapEntity setValue:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]] forKey:@"index"];
		[cmap insertObject:cmapEntity atArrangedObjectIndex:i];
	}

	[(FlameController *)flameController changeColourMapAndHideWindow:self];
	

}

- (void) setColourArray:(NSArray *)newArray {

	[arrayController removeObjects:[arrayController arrangedObjects]];
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:255];
	
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
		
		[tempArray addObject:colour];
		
		[paletteImage release];
		[paletteRep release];

	}
	
	[arrayController addObjects:tempArray];
	[self fillGradientImageRep];
	[tempArray release];
	
}

- (void) fillGradientImageRep {

	NSBitmapImageRep *imageRep = [gradientView getGradientRep];
	
	[arrayController rearrangeObjects];
	
	[PaletteController fillBitmapRep:imageRep withColours:[arrayController arrangedObjects] forHeight:GRADIENT_IMAGE_HEIGHT];
	
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
	
	NSArray *colourArray = [arrayController arrangedObjects];
	
	NSDictionary *selectedColour = [[arrayController selectedObjects] objectAtIndex:0];
	int arrayIndexForSelected = [colourArray indexOfObject:selectedColour];
	
	int colourIndex = [[selectedColour objectForKey:@"index"] intValue];

	NSDictionary *nextColour;
	int nextIndex, newIndex;

	if( arrayIndexForSelected + 1 == [colourArray count]) {
		if (colourIndex == 255) {
			NSBeep();
			return;
		} else {
			nextColour = selectedColour;
			nextIndex = 256;
			newIndex = 255;
		}
	} else {
		nextColour = [colourArray objectAtIndex:arrayIndexForSelected+1];
		nextIndex = [[nextColour objectForKey:@"index"] intValue];	
		newIndex = (int)(colourIndex + ((nextIndex - colourIndex) / 2.0));
	}
	

	
	
	if(colourIndex + 1 != nextIndex) {
		
		NSMutableDictionary *colour = [NSMutableDictionary dictionaryWithCapacity:4];
		[colour setObject:[NSNumber numberWithDouble:[[selectedColour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[colour setObject:[NSNumber numberWithDouble:[[selectedColour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[colour setObject:[NSNumber numberWithDouble:[[selectedColour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[colour setObject:[NSNumber numberWithInt:newIndex] forKey:@"index"];

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

		[arrayController addObject:colour];
		[arrayController rearrangeObjects];
	} else {
		NSBeep();
	}
}

- (NSArray *) getColourArray {
	
	return [arrayController arrangedObjects];
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
		colourDictionary = [[arrayController arrangedObjects] objectAtIndex:row];
	} else {
		
		NSBitmapImageRep *paletteRep;
		NSImage *paletteImage;		
		
		NSMutableDictionary *colourDictionary1 = [[arrayController arrangedObjects] objectAtIndex:row-1];
		NSMutableDictionary *colourDictionary2 = [[arrayController arrangedObjects] objectAtIndex:row];
		
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
		
		[arrayController addObject:colourDictionary];
		
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
