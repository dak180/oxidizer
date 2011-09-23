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
#define HUES_ROTATE 5
#define RANDOM_GRADIENTS 6


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
		_colourPreview = nil;
		_hue = 0.0;

	}
	return self;
}


- (void)awakeFromNib {
    // register for drag and drop
    [gradientTableView registerForDraggedTypes:[NSArray arrayWithObject:NSColorPboardType]];

}


- (IBAction)showWindow:(id)sender {


	[gradientView setDelegate:self];
	[self setColourArray:[cmap arrangedObjects]];
	[self gradientChanged];
	[gradientView setGradientArrayController:arrayController];
    [gradientView display];

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
		default:
			break;
	}

	[gradientView setSelectedSwatch:nil];
	[self gradientChanged];
	[gradientView display];

}


- (IBAction)applyNewPalette:(id)sender {


	NSManagedObject *cmapEntity;

	[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];
	int i;

	NSArray *newColourMap = [self getColourArray];

	for(i=0; i<[newColourMap count]; i++) {

		NSDictionary *colour = [newColourMap objectAtIndex:i];

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

		NSMutableDictionary *colour = [NSMutableDictionary dictionaryWithCapacity:6];
		[colour setObject:[NSNumber numberWithDouble:i] forKey:@"red"];
		[colour setObject:[NSNumber numberWithDouble:i] forKey:@"green"];
		[colour setObject:[NSNumber numberWithDouble:i] forKey:@"blue"];
		[colour setObject:[NSNumber numberWithInt:i*255] forKey:@"index"];

		[self addColourSquare:colour];

		[tempArray addObject:colour];


	}

	[arrayController addObjects:tempArray];
	[self gradientChanged];
	[arrayController setSelectionIndex:0];
	[tempArray release];

}

- (IBAction)randomGradient:(id)sender {

	[[arrayController content] removeAllObjects];

	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:255];


	srandom(time(NULL));

	int colourCount = (arc4random() & 7) + 3 ;
	int i;

	for(i=0; i<=colourCount; i++) {

		NSMutableDictionary *colour = [NSMutableDictionary dictionaryWithCapacity:6];
		[colour setObject:[NSNumber numberWithDouble:((arc4random() & 255) / 255.0)] forKey:@"red"];
		[colour setObject:[NSNumber numberWithDouble:((arc4random() & 255) / 255.0)] forKey:@"green"];
		[colour setObject:[NSNumber numberWithDouble:((arc4random() & 255) / 255.0)] forKey:@"blue"];
		[colour setObject:[NSNumber numberWithInt:i*(255.0 / colourCount)] forKey:@"index"];

		[self addColourSquare:colour];

		[tempArray addObject:colour];


	}

	[arrayController addObjects:tempArray];
	[self gradientChanged];
	[arrayController setSelectionIndex:0];
	[tempArray release];

}


- (IBAction)gradientSegmentedControl:(id)sender {

	NSSegmentedControl *segments = (NSSegmentedControl *)sender;


	switch([segments selectedSegment]) {
		case 0:

            [self newGradient:sender];

			break;
		case 1:
			[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:255]];

			_qvMin = 0.0;
			_qvMax = 1.0;

			_rotateType = HUES_ROTATE;
			[self rotateHues];

			[gradientView setSelectedSwatch:nil];
			[self gradientChanged];
			[gradientView display];
			break;
		case 2:

			[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:255]];

			_qvMin = 0.0;
			_qvMax = 255.0;

			_rotateType = INDEXES_ROTATE;
			[self rotateIndexes];
			[gradientView setSelectedSwatch:nil];
			[self gradientChanged];
			[gradientView display];

			break;
		case 3:
			[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:0]];

			_qvMin = 0.0;
			_qvMax = 0.0;

			_rotateType = RANDOM_GRADIENTS;

			[self randomGradients];

			[gradientView setSelectedSwatch:nil];
			[self gradientChanged];
			[gradientView display];
			break;
		case 4:
			[self randomGradient:sender];
			break;
	}


}

- (void) setColourArray:(NSArray *)newArray {

	unsigned int selectedIndex = [arrayController selectionIndex];
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
	if(selectedIndex > [[arrayController content] count]) {
		selectedIndex = 0;
	}
	[arrayController setSelectionIndex:selectedIndex];
	[tempArray release];

}

- (void) fillGradientImageRep {

	NSBitmapImageRep *imageRep = [gradientView getGradientRep];

	[arrayController rearrangeObjects];

	[PaletteController fillBitmapRep:imageRep withColours:[self getColourArray] forHeight:GRADIENT_IMAGE_HEIGHT];

//	[PaletteController fillBitmapRep:imageRep withColours:[arrayController arrangedObjects] forHeight:GRADIENT_IMAGE_HEIGHT];


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
	[self gradientChanged];
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

		[paletteImage release];
		[paletteRep release];

	} else {
		NSBeep();
	}
}

- (NSArray *) getColourArray {

	return [PaletteController rotatedColourMap:[arrayController arrangedObjects] usingHue:_hue];
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

- (void) setFractalFlameModel:(id)model {

	if(model != nil) {
		[model retain];
	}

	[_model release];
	_model = model;

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

	CGFloat red, green, blue;

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

		[paletteImage release];
		[paletteRep release];

	}


	[colorWellColour getRed:&red green:&green blue:&blue alpha:NULL];

	[colourDictionary setObject:[NSNumber numberWithFloat:red] forKey:@"red"];
	[colourDictionary setObject:[NSNumber numberWithFloat:green] forKey:@"green"];
	[colourDictionary setObject:[NSNumber numberWithFloat:blue] forKey:@"blue"];

	[PaletteController fillColour:colourDictionary forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];

	[self gradientChanged];
	[gradientView display];

	if (op != NSTableViewDropOn) {
		[colourDictionary release];
	}

	return YES;
}

- (void) saveGradient:(NSString *)filename {


	NSXMLElement *root;

	root = (NSXMLElement *)[NSXMLNode elementWithName:@"gradient"];
	[root addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1"]];
	[PaletteController createXMLForGradient:[arrayController arrangedObjects] forElement:root];

	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
	[xmlDoc setVersion:@"1.0"];
	[xmlDoc setCharacterEncoding:@"UTF-8"];

	[xmlDoc autorelease];

	[[xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint|NSXMLNodeCompactEmptyElement] writeToFile:filename atomically:YES];

	return;

}


- (IBAction) saveGradientToFile:(id) sender {

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	/* set up new attributes */
	[savePanel setRequiredFileType:@"xml"];
	[savePanel setPrompt:@"Save"];
	BOOL runResult = [savePanel runModal];
	NSString *filename;

	if(runResult == NSOKButton && [savePanel filename] != nil) {
		filename = [savePanel filename];
		[filename retain];
	} else {
		filename = nil;
		return ;
	}

	[self saveGradient:filename];

}


- (IBAction) loadGradientFromFile:(id) sender {

	NSOpenPanel*op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"xml"];
	[op setPrompt:@"Load"];
	BOOL runResult = [op runModal];
	NSString *filename;

	if(runResult == NSOKButton && [op filename] != nil) {
		filename = [op filename];
		[filename retain];
	} else {
		filename = nil;
		return ;
	}

	BOOL result = [self loadGradient:filename];
	if(result == NO) {
		NSBeep();
		return;
	}

	[self getPreview];
	return;
}


- (bool) loadGradient:(NSString *) xmlFileName {

	NSMutableArray *newCmap;
	NSXMLDocument *xmlDoc;
    NSError *err=nil;
    NSURL *furl = [NSURL fileURLWithPath:xmlFileName];
    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", xmlFileName);
        return NO;
    }

    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
												  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
													error:&err];

	NSXMLNode *gradientNode = [xmlDoc rootElement];

	if([[gradientNode name] compare:@"gradient"] != 0) {
		[xmlDoc release];
		return NO;
	}

//	NSArray *colors = [gradientNode children];

	newCmap = [NSMutableArray arrayWithCapacity:[colours count]];

//	int i = 0;

	NSEnumerator *elementEnumerator = [[gradientNode children] objectEnumerator];
	NSXMLElement *colourNode;

	while ( (colourNode = [elementEnumerator nextObject])) {

//	for(i=0; i<[colours count]; i++) {
		//		NSXMLElement *colourNode = [colors objectAtIndex:i];

		NSMutableDictionary *colour = [NSMutableDictionary dictionaryWithCapacity:4];

		[colour setObject:[[colourNode attributeForName:@"index"] stringValue] forKey:@"index"];
		[colour setObject:[[colourNode attributeForName:@"red"] stringValue] forKey:@"red"];
		[colour setObject:[[colourNode attributeForName:@"green"] stringValue] forKey:@"green"];
		[colour setObject:[[colourNode attributeForName:@"blue"] stringValue] forKey:@"blue"];

		[newCmap addObject:colour];
	}
	[self setColourArray:newCmap];

	[xmlDoc release];

	return YES;
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
		case HUES_ROTATE:
			[self rotateHues];
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
		case RANDOM_GRADIENTS:
			[self randomGradients];
			break;
	}
}


-(void) resetToOriginalValue {

	switch(_rotateType) {
		case INDEX_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithInt:[(NSNumber *)_qvOriginalValue intValue]] forKey:@"index"] ;
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
		case INDEXES_ROTATE:
		case HUES_ROTATE:
		case RANDOM_GRADIENTS:
			[self setColourArray:_qvOriginalValue];
			break;
		case RED_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue doubleValue]] forKey:@"red"] ;
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
		case GREEN_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue doubleValue]] forKey:@"green"] ;
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
		case BLUE_ROTATE:
			[_qvOriginalValuesObject setObject:[NSNumber numberWithDouble:[(NSNumber *)_qvOriginalValue doubleValue]] forKey:@"blue"] ;
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
	}

	[arrayController rearrangeObjects];
	[self fillGradientImageRep];
	[gradientView display];

}

-(void) setToValue:(id) value {

//	int oldIndex;
	int i;

	switch(_rotateType) {
		case INDEX_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"index"];
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
		case INDEXES_ROTATE:
			[self setColourArray:value];
			break;
		case HUES_ROTATE:
			for(i=0; i<[[arrayController arrangedObjects] count]; i++) {

				NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];
				NSMutableDictionary *newColour = (NSMutableDictionary *)[(NSArray *)value objectAtIndex:i];

				[colour addEntriesFromDictionary:newColour];

				[PaletteController fillColour:colour forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];

			}
			break;
		case RANDOM_GRADIENTS:
			[self setColourArray:value];
			break;
		case RED_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"red"] ;
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
		case GREEN_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"green"] ;
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
		case BLUE_ROTATE:
			[_qvOriginalValuesObject setObject:value forKey:@"blue"] ;
			[PaletteController fillColour:_qvOriginalValue forWidth:COLOUR_SQUARE_SIDE andHeight:COLOUR_SQUARE_SIDE];
			break;
	}


	[arrayController rearrangeObjects];
	[self willChangeValueForKey:@"_hue"];
	_hue = 0.0;
	[self didChangeValueForKey:@"_hue"];
	[self gradientChanged];
	[gradientView display];

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

	[self saveCmap];

	[(QuickViewController *)_qvc setExternalQuickViewObject:self];

	[_qvc showWindow];

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

	[self restoreCmap];
	[self resetToOriginalValue];


}


- (void) rotateIndexes {

	NSManagedObject *cmapEntity;

	[self saveCmap];

	[(QuickViewController *)_qvc setExternalQuickViewObject:self];

	[_qvc showWindow];

	int qvIndex;
	int i;
    int colourIndex;

	double qvDelta = (_qvMax - _qvMin) / ([_qvc quickViewCount] - 1);

	NSMutableArray *coloursCopy = [NSMutableArray arrayWithCapacity:10];

	[self setOriginalValue:[NSMutableArray arrayWithCapacity:10]];

	for(i=0; i<[[arrayController arrangedObjects] count]; i++) {

		NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];

		NSMutableDictionary *oldColour = [NSMutableDictionary dictionaryWithCapacity:4];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[oldColour setObject:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]] forKey:@"index"];
		[_qvOriginalValue addObject:oldColour];

		NSMutableDictionary *colourCopy = [NSMutableDictionary dictionaryWithCapacity:4];
		[colourCopy setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[colourCopy setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[colourCopy setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[colourCopy setObject:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]] forKey:@"index"];
		[coloursCopy addObject:colourCopy];

	}



	NSArray *tmp = [PaletteController extrapolateDoubleArray:[arrayController arrangedObjects]];
	[self setColourArray:tmp];

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
			//			[indexValues addObject:newIndex];


		}

		[arrayController rearrangeObjects];

		BOOL hasZero = FALSE;
		BOOL has255 = FALSE;

		for(i=0; i<[coloursCopy count]; i++) {

			NSMutableDictionary *colour = (NSMutableDictionary *)[coloursCopy objectAtIndex:i];

			colourIndex = [[colour objectForKey:@"index"] intValue];
			colourIndex += qvDelta;
			colourIndex &= 255;

			if(colourIndex == 0) {
				hasZero = TRUE;
			} else if(colourIndex == 255) {
				has255 = TRUE;
			}

			NSNumber *newIndex = [NSNumber numberWithInt:colourIndex];
			[colour setObject:newIndex forKey:@"index"] ;

			NSMutableDictionary *newColour = [NSMutableDictionary dictionaryWithCapacity:4];
			[newColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[newColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[newColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[newColour setObject:[NSNumber numberWithInt:colourIndex] forKey:@"index"];
			[indexValues addObject:newColour];

		}

		if(!hasZero) {

			NSDictionary *colour0 = [[arrayController arrangedObjects] objectAtIndex:0];
			NSMutableDictionary *newColour0 = [NSMutableDictionary dictionaryWithCapacity:4];
			[newColour0 setObject:[NSNumber numberWithDouble:[[colour0 objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[newColour0 setObject:[NSNumber numberWithDouble:[[colour0 objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[newColour0 setObject:[NSNumber numberWithDouble:[[colour0 objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[newColour0 setObject:[NSNumber numberWithInt:[[colour0 objectForKey:@"index"] intValue]] forKey:@"index"];
			[indexValues insertObject:newColour0 atIndex:0];

		}

		if(!has255) {

			NSDictionary *colour255 = [[arrayController arrangedObjects] objectAtIndex:255];
			NSMutableDictionary *newColour255 = [NSMutableDictionary dictionaryWithCapacity:4];
			[newColour255 setObject:[NSNumber numberWithDouble:[[colour255 objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[newColour255 setObject:[NSNumber numberWithDouble:[[colour255 objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[newColour255 setObject:[NSNumber numberWithDouble:[[colour255 objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[newColour255 setObject:[NSNumber numberWithInt:[[colour255 objectForKey:@"index"] intValue]] forKey:@"index"];
			[indexValues addObject:newColour255];
		}


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

	[self restoreCmap];
	[self resetToOriginalValue];

}


- (void) randomGradients {


	NSManagedObject *cmapEntity;

	[self saveCmap];

	[(QuickViewController *)_qvc setExternalQuickViewObject:self];

	[_qvc showWindow];

	int qvIndex;
	int i;


	for(i=0; i<[[arrayController arrangedObjects] count]; i++) {

		NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];

		NSMutableDictionary *oldColour = [NSMutableDictionary dictionaryWithCapacity:4];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[oldColour setObject:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]] forKey:@"index"];
		[_qvOriginalValue addObject:oldColour];

	}

	[[arrayController content] removeAllObjects];



	srandom(time(NULL));




//	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:10];

	for (qvIndex =0; qvIndex < [_qvc quickViewCount]; qvIndex++) {

		NSMutableArray *indexValues = [NSMutableArray arrayWithCapacity:[_qvc quickViewCount]];

		[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];

		int colourCount = (arc4random() & 7) + 3 ;
		int i;

		double red, green, blue;

		int index;

//		[tmp removeAllObjects];

		for(i=0; i<=colourCount; i++) {


			red = ((arc4random() & 255) / 255.0);
			green = ((arc4random() & 255) / 255.0);
			blue = ((arc4random() & 255) / 255.0);

			index = i*(255.0 / colourCount);

			cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];

			[cmapEntity setValue:[NSNumber numberWithDouble:red] forKey:@"red"];
			[cmapEntity setValue:[NSNumber numberWithDouble:green] forKey:@"green"];
			[cmapEntity setValue:[NSNumber numberWithDouble:blue] forKey:@"blue"];
			[cmapEntity setValue:[NSNumber numberWithInt:index] forKey:@"index"];
			[cmap insertObject:cmapEntity atArrangedObjectIndex:i];

			NSMutableDictionary *newColour = [NSMutableDictionary dictionaryWithCapacity:4];
			[newColour setObject:[NSNumber numberWithDouble:red] forKey:@"red"];
			[newColour setObject:[NSNumber numberWithDouble:green] forKey:@"green"];
			[newColour setObject:[NSNumber numberWithDouble:blue] forKey:@"blue"];
			[newColour setObject:[NSNumber numberWithInt:index] forKey:@"index"];
			[indexValues addObject:newColour];

		}



		[(QuickViewController *)_qvc renderForIndex:qvIndex withValue:indexValues];

	}

	[self restoreCmap];
	[self resetToOriginalValue];

}


- (IBAction)qvRotateRed:(id)sender {

	[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:1]];

	_qvMin = 0.0;
	_qvMax = 1.0;

	_rotateType = RED_ROTATE;

	[_qvc showWindow];
	[self  rotateColour:@"red"];

}


- (IBAction)qvRotateGreen:(id)sender {

	[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:1]];

	_qvMin = 0.0;
	_qvMax = 1.0;

	_rotateType = GREEN_ROTATE;

	[_qvc showWindow];
	[self  rotateColour:@"green"];

}


- (IBAction)qvRotateBlue:(id)sender {

	[(QuickViewController *)_qvc setMinimum:[NSNumber numberWithInt:0] andMaximum:[NSNumber numberWithInt:1]];

	_qvMin = 0.0;
	_qvMax = 1.0;

	_rotateType = BLUE_ROTATE;

	[_qvc showWindow];
	[self  rotateColour:@"blue"];

}

- (void) rotateColour:(NSString *)colourKey {

	NSManagedObject *cmapEntity;

	[self saveCmap];


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

	[self restoreCmap];
	[self resetToOriginalValue];

}


- (void) rotateHues {

	NSManagedObject *cmapEntity;

	[self saveCmap];

	[(QuickViewController *)_qvc setExternalQuickViewObject:self];

	[_qvc showWindow];

	int qvIndex;
	int i;
    int colourIndex;


	double qvDelta = (_qvMax - _qvMin) / ([_qvc quickViewCount] - 1);

	[self setOriginalValue:[NSMutableArray arrayWithCapacity:10]];

	for(i=0; i<[[arrayController arrangedObjects] count]; i++) {

		NSMutableDictionary *colour = (NSMutableDictionary *)[[arrayController arrangedObjects] objectAtIndex:i];

		NSMutableDictionary *oldColour = [NSMutableDictionary dictionaryWithCapacity:4];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[oldColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[oldColour setObject:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]] forKey:@"index"];
		[_qvOriginalValue addObject:oldColour];

	}


	for (qvIndex =0; qvIndex < [_qvc quickViewCount]; qvIndex++) {

		NSMutableArray *indexValues = [NSMutableArray arrayWithCapacity:[_qvc quickViewCount]];

		[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];

		[PaletteController rotateColourMap:[arrayController arrangedObjects] usingHue:qvDelta];

//		[arrayController rearrangeObjects];

		for(i=0; i<[[arrayController arrangedObjects] count]; i++) {

			NSDictionary *colour = [[arrayController arrangedObjects] objectAtIndex:i];

			cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];

			colourIndex = [[colour objectForKey:@"index"] intValue];

			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[cmapEntity setValue:[NSNumber numberWithInt:colourIndex] forKey:@"index"];
			[cmap insertObject:cmapEntity atArrangedObjectIndex:i];

			NSMutableDictionary *newColour = [NSMutableDictionary dictionaryWithCapacity:4];
			[newColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
			[newColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
			[newColour setObject:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
			[newColour setObject:[NSNumber numberWithInt:colourIndex] forKey:@"index"];
			[indexValues addObject:newColour];

		}

		[(QuickViewController *)_qvc renderForIndex:qvIndex withValue:indexValues];

	}

	[self restoreCmap];
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

- (void)setColourPreview:(NSImage *)image {

	if(image != nil) {
		[image retain];
	}

	[_colourPreview release];

	_colourPreview = image;

}

- (void) addColourSquare:(NSMutableDictionary *)colour {

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

	[paletteImage release];
	[paletteRep release];

}

- (void) getPreview {

	int rotateType = _rotateType;
	_rotateType = RANDOM_GRADIENTS;

	int i;

	[self saveCmap];

	[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];

	NSManagedObject *cmapEntity;

	NSArray *newCmap = [self getColourArray];

	for(i=0; i<[newCmap count]; i++) {

		NSDictionary *colour = (NSDictionary *)[newCmap objectAtIndex:i];

		cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];

		[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"red"] doubleValue]] forKey:@"red"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"green"] doubleValue]] forKey:@"green"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[colour objectForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[cmapEntity setValue:[NSNumber numberWithInt:[[colour objectForKey:@"index"] intValue]] forKey:@"index"];
		[cmap insertObject:cmapEntity atArrangedObjectIndex:i];
	}

	[self willChangeValueForKey:@"_colourPreview"];

	[self setColourPreview:[(FractalFlameModel *)_model renderThumbnail]];

	[self didChangeValueForKey:@"_colourPreview"];

	[self restoreCmap];
	_rotateType = rotateType;


}


-(void) gradientChanged {

	[self fillGradientImageRep];
	[self getPreview];

}

- (void) restoreCmap {

	int i;
	NSManagedObject *cmapEntity;

	[cmap removeObjects:[NSArray arrayWithArray:[cmap arrangedObjects]]];

	for(i=0; i<[_cmapStore count]; i++) {

		cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmap managedObjectContext]];

		[cmapEntity setValue:[NSNumber numberWithDouble:[[[_cmapStore objectAtIndex:i] valueForKey:@"red"] doubleValue]] forKey:@"red"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[[_cmapStore objectAtIndex:i] valueForKey:@"green"] doubleValue]] forKey:@"green"];
		[cmapEntity setValue:[NSNumber numberWithDouble:[[[_cmapStore objectAtIndex:i] valueForKey:@"blue"] doubleValue]] forKey:@"blue"];
		[cmapEntity setValue:[NSNumber numberWithInt:[[[_cmapStore objectAtIndex:i] valueForKey:@"index"] intValue]] forKey:@"index"];
		[cmap insertObject:cmapEntity atArrangedObjectIndex:i];
	}

	[_cmapStore release];

}

- (void) saveCmap {

	_cmapStore = [NSMutableArray arrayWithArray:[cmap arrangedObjects]];
	[_cmapStore retain];
	//	[self setOriginalValue:[NSMutableArray arrayWithArray:[cmap arrangedObjects]]];

}

-(void) sliderValueChanged {

	[self gradientChanged];

}

@end
