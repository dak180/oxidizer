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
#import "QuickViewController.h"

#define COLOUR_SQUARE_SIDE 20

#define INDEX_ROTATE 0
#define RED_ROTATE 1
#define BLUE_ROTATE 2
#define GREEN_ROTATE 3
#define INDEXES_ROTATE 4


int sortUsingIndex(id colour1, id colour2, void *context);

@implementation GradientController


- (id) init {
	
	if (self = [super init]) {
			colours = [NSMutableArray arrayWithCapacity:2];		
			[colours retain];
		
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
		cmapSortDescriptors = [NSArray arrayWithObject: sort];
		[sort  release]; 
		_qvMin = 0.0;
		_qvMax = 255.0;
		
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
		case 2:
			[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:255]];
			
			_qvMin = 0.0;
			_qvMax = 255.0;
			
			_rotateType = INDEXES_ROTATE;
			[self rotateIndexes];
			break;
	}
	
	[gradientView setSelectedSwatch:nil];
	[self fillGradientImageRep];
	[gradientView display];

}


- (IBAction)applyNewPalette:(id)sender {
	NSManagedObject *cmapEntity;
	
	[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];
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

- (IBAction)newGradient:(id)sender {
	
	[[arrayController content] removeAllObjects];

	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:255];

	int i;
	
 	for(i=0; i<2; i++) {
		
		NSBitmapImageRep *paletteRep;
		NSImage *paletteImage;
		
		NSMutableDictionary *colour = [NSMutableDictionary dictionaryWithCapacity:6];
		[colour setObject:[NSNumber numberWithDouble:i] forKey:@"red"];
		[colour setObject:[NSNumber numberWithDouble:i] forKey:@"green"];
		[colour setObject:[NSNumber numberWithDouble:i] forKey:@"blue"];
		[colour setObject:[NSNumber numberWithInt:i*255] forKey:@"index"];
		
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
	[arrayController setSelectionIndex:0];
	[tempArray release];
	
}

- (void) setColourArray:(NSArray *)newArray {

	/* this appears to be a safe way yo remove everything */
	[[arrayController content] removeAllObjects];
	
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
	[arrayController setSelectionIndex:0];
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

- (void)setQuickViewController:(id)qvc {

	if(qvc != nil) {
		[qvc retain];
	}
	
	[_qvc release];
	_qvc = qvc;
	
	_qvc = qvc;
	
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
		
		NSArray *colourArray = [arrayController arrangedObjects];

		NSMutableDictionary *colourDictionary1 = [colourArray objectAtIndex:row-1];
		int index1 = [[colourDictionary1 objectForKey:@"index"] intValue];

		NSMutableDictionary *colourDictionary2;   
		int index2;
		
		if(row < [colourArray count]) {			
			colourDictionary2 = [[arrayController arrangedObjects] objectAtIndex:row];
			index2 = [[colourDictionary2 objectForKey:@"index"] intValue];
		} else {
			index2 = index1 + ((255 - index1) * 2);
		}
		
		
		if( index1 == 255 || index1 == index2 - 1) {
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

- (void) saveGradient {
	
	
	NSXMLElement *root;
		
	root = (NSXMLElement *)[NSXMLNode elementWithName:@"gradient"];
	[root addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1"]];	
	[PaletteController createXMLForGradient:[arrayController arrangedObjects] forElement:root];

	return;
	
}


/* quickView Protocol */

-(void) setMinimum:(double) min andMaximum:(double) max {
	
	_qvMin = min;
	_qvMax = max;
	
	
}

-(void) renderQuickViews {

	switch(_rotateType) {
		case INDEX_ROTATE:
			[self rotateIndex];
			break;
		case INDEXES_ROTATE:
			[self rotateIndexes];
			break;
		case RED_ROTATE:
			[self rotateColour:@"red"];
			break;
		case GREEN_ROTATE:
			[self rotateColour:@"green"];
			break;
		case BLUE_ROTATE:
			[self rotateColour:@"blue"];
			break;
	}
}


-(void) resetToOriginalValue {
	int i;
	
	switch(_rotateType) {
		case INDEX_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithInt:[(NSNumber *)_qvOriginalValue intValue]] forKey:@"index"] ;
			break;
		case INDEXES_ROTATE:
			for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
				
				NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];
				[colour setObject:[NSNumber numberWithInt:[[_qvOriginalValue objectAtIndex:i] intValue]] forKey:@"index"] ;
				
			}	
			[self setColourArray:[arrayController arrangedObjects]];
			break;
		case RED_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue doubleValue]] forKey:@"red"] ;
			break;
		case GREEN_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue doubleValue]] forKey:@"green"] ;
			break;
		case BLUE_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue doubleValue]] forKey:@"blue"] ;
			break;
	}
	
}

-(void) setToValue:(id) value {

	int oldIndex;
	int i;
	
	switch(_rotateType) {
		case INDEX_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"index"];
			break;
		case INDEXES_ROTATE:
			for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
				
				NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];
				oldIndex = [[(NSArray *)value objectAtIndex:i] intValue];
				[colour setObject:[NSNumber numberWithInt:oldIndex] forKey:@"index"] ;
			}	
				
			break;
		case RED_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"red"] ;
			[self controlTextDidEndEditing:nil];
			break;
		case GREEN_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"green"] ;
			[self controlTextDidEndEditing:nil];
			break;
		case BLUE_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"blue"] ;
			[self controlTextDidEndEditing:nil];
			break;
	}
	
	[arrayController rearrangeObjects];	
	
}


- (IBAction)qvRotateIndex:(id)sender {
	
	[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:255]];
	
	_qvMin = 0.0;
	_qvMax = 255.0;
	
	_rotateType = INDEX_ROTATE;
	
	[self  rotateIndex];
	
}

- (void) rotateIndex {
	
	NSManagedObject *cmapEntity;
	
	[(QuickViewController *)_qvc setExternalQuickViewObject:self];
	
	int qvIndex;
	int i;
    int colourIndex;
	
	double qvDelta = (_qvMax - _qvMin) / ([_qvc quickViewCount] - 1.0);
	
	NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController selectedObjects] objectAtIndex:0];
	[self setOriginalValuesObject:colour]; 

	[self setOriginalValue:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]]];

	
	for (qvIndex =0; qvIndex < [_qvc quickViewCount]; qvIndex++) {
		
		
		[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];
		
						
		colourIndex = [[colour objectForKey:@"index"] intValue];
		colourIndex += qvDelta;
		colourIndex &= 255;
		[colour setObject:[NSNumber numberWithInt:colourIndex] forKey:@"index"] ;
		
		[arrayController rearrangeObjects];
		
		for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
			
			NSDictionary *colour = [[arrayController arrangedObjects] objectAtIndex:i];
			
			cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];
			
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[cmapEntity setValue:[NSNumber numberWithInt: [[colour objectForKey:@"index"] intValue]] forKey:@"index"];
			[cmap insertObject:cmapEntity atArrangedObjectIndex:i];
		}
		
		[(QuickViewController *)_qvc renderForIndex:qvIndex withValue:[NSNumber numberWithInt:colourIndex]];
		
	} 
	
//	[colour setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue intValue]] forKey:@"index"] ;
	[self resetToOriginalValue];

	
}




- (void) rotateIndexes {
		
	NSManagedObject *cmapEntity;
	
	[(QuickViewController *)_qvc setExternalQuickViewObject:self];
	
	int qvIndex;
	int i;
    int colourIndex;
	
	double qvDelta = (_qvMax - _qvMin) / (255.0 / [_qvc quickViewCount]);
	
	[self setOriginalValue:[NSMutableArray arrayWithCapacity:10]];

	for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
		
		NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];
		
		[(NSMutableArray *)_qvOriginalValue addObject:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]]];
	}	
	
	
	for (qvIndex =0; qvIndex < [_qvc quickViewCount]; qvIndex++) {
		
		NSMutableArray *indexValues = [NSMutableArray arrayWithCapacity:[_qvc quickViewCount]];
		
		[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];
		
		for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
			
			NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];
			
			colourIndex = [[colour objectForKey:@"index"] intValue];
			colourIndex += qvDelta;
			colourIndex &= 255;
			NSNumber *newIndex = [NSNumber numberWithInt:colourIndex];
			[colour setObject:newIndex forKey:@"index"] ;
			[indexValues addObject:newIndex];
		}	
		
		[arrayController rearrangeObjects];
		
		for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
			
			NSDictionary *colour = [[arrayController arrangedObjects] objectAtIndex:i];
			
			cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];
			
			colourIndex = [[colour objectForKey:@"index"] intValue];
			
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[cmapEntity setValue:[NSNumber numberWithInt:colourIndex] forKey:@"index"];
			[cmap insertObject:cmapEntity atArrangedObjectIndex:i];
		}
		
		[(QuickViewController *)_qvc renderForIndex:qvIndex withValue:indexValues];
		
	} 

	[self resetToOriginalValue];

}


- (IBAction)qvRotateRed:(id)sender {
	
	[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:1]];
	
	_qvMin = 0.0;
	_qvMax = 1.0;
	
	_rotateType = RED_ROTATE;
	
	[self  rotateColour:@"red"];
	
}


- (IBAction)qvRotateGreen:(id)sender {
	
	[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:1]];
	
	_qvMin = 0.0;
	_qvMax = 1.0;
	
	_rotateType = GREEN_ROTATE;
	
	[self  rotateColour:@"green"];
	
}


- (IBAction)qvRotateBlue:(id)sender {
	
	[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:1]];
	
	_qvMin = 0.0;
	_qvMax = 1.0;
	
	_rotateType = BLUE_ROTATE;
	
	[self  rotateColour:@"blue"];
	
}

- (void) rotateColour:(NSString *)colourKey {
	
	NSManagedObject *cmapEntity;
	
	[(QuickViewController *)_qvc setExternalQuickViewObject:self];
	
	int qvIndex;
	int i;
    double colourIndex;
	
	double qvDelta = (_qvMax - _qvMin) / (double)([_qvc quickViewCount] - 1);
	
	NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController selectedObjects] objectAtIndex:0];

	[self setOriginalValuesObject:colour]; 
	[self setOriginalValue:[NSNumber numberWithDouble:[[colour objectForKey:colourKey] doubleValue]]];
	
	for (qvIndex =0; qvIndex < [_qvc quickViewCount]; qvIndex++) {
		
		
		[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];
				
		colourIndex = _qvMin + (qvIndex * qvDelta);
		[colour setObject:[NSNumber numberWithDouble:colourIndex] forKey:colourKey] ;
		
//		[arrayController rearrangeObjects];
		
		for(i=0; i<[[arrayController arrangedObjects] count]; i++) {
			
			NSDictionary *colour = (NSDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];
			
			cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];
						
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[cmapEntity setValue:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]] forKey:@"index"];
			[cmap insertObject:cmapEntity atArrangedObjectIndex:i];
		}
		
		[(QuickViewController *)_qvc renderForIndex:qvIndex withValue:[NSNumber numberWithDouble:colourIndex]];
		
	} 

//	[colour setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue doubleValue]] forKey:colourKey] ;
	[self resetToOriginalValue];

}


- (void)setOriginalValue:(id)value {
	
	if(value != nil) {
		[value retain];
	}
	
	[_qvOriginalValue release];
	
	_qvOriginalValue = value;
		
}

- (void)setOriginalValuesObject:(id)value {
	
	if(value != nil) {
		[value retain];
	}
	
	[_qvOriginalValuesObject release];
	
	_qvOriginalValuesObject = value;
	
}

@end
