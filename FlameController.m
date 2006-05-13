/*
    oxidizer - cosmic recursive fractal flames
    Copyright (C) 2006  David Burnett <vargol@ntlworld.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import "FlameController.h"
#import "Genome.h"
#import "flam3.h"


@implementation FlameController : NSObject

- init
{
    
	
	if (self = [super init]) {
		
		_paletteWithHueRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
															pixelsWide:256
															pixelsHigh:10
														 bitsPerSample:8
													   samplesPerPixel:3
															  hasAlpha:NO 
															  isPlanar:NO
														colorSpaceName:NSDeviceRGBColorSpace
														  bitmapFormat:0
														   bytesPerRow:3*256
														  bitsPerPixel:24]; 

		_colourWithHueRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
															pixelsWide:256
															pixelsHigh:15
														 bitsPerSample:8
													   samplesPerPixel:3
															  hasAlpha:NO 
															  isPlanar:NO
														colorSpaceName:NSDeviceRGBColorSpace
														  bitmapFormat:0
														   bytesPerRow:3*256
														  bitsPerPixel:24]; 
		
	}
		
    
    return self;
}

-(void)removeFlameData {

//	[_flameRecords removeAllObjects];
	
}


-(void)addFlameData:(NSImage *)flameImage genome:(flam3_genome *)genome atIndex:(int )index inContext:(NSManagedObjectContext *)moc {


	NSManagedObject *test = [Genome createGenomeEntityFrom:genome withImage:flameImage inContext:moc];
	
//	[flames reloadData];
//	[flameValues reloadData];
	
	
}

- (IBAction)showXFormWindow:(id)sender
{

	NSManagedObject *xformEntity;
	NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	NSEnumerator *enumerator;
	NSArray *objects;
	int index;
	// NSManagedObject *selectedGenome;

	switch([segments selectedSegment]) {
	case 0:
		xformEntity = [NSEntityDescription insertNewObjectForEntityForName:@"XForm" inManagedObjectContext:[xformController managedObjectContext]];
		[xformEntity setValue:[Genome createDefaultVariationsEntitySetInContext:[xformController managedObjectContext]] forKey:@"variations"];

		index = [xformController selectionIndex];
		if(index == NSNotFound) {
			[xformController insert:xformEntity];
		} else {
			[xformController insertObject:xformEntity atArrangedObjectIndex:index+1];
			objects = [xformController arrangedObjects];
			enumerator = [objects objectEnumerator];
			index = 0;
			while (xformEntity = [enumerator nextObject]) {
				[xformEntity setValue:[NSNumber numberWithInt:index] forKey:@"order"];
				index++;
			}
		} 
		break;
	case 1:
	//		selectedGenome = [[genomeController selectedObjects] objectAtIndex:0];
		[xformWindow makeKeyAndOrderFront:self];
		
		break;
	case 2:
		[xformController remove:sender];
		objects = [xformController arrangedObjects];
		if([objects count] != 0) {
			enumerator = [objects objectEnumerator];
			index = 0;
			while (xformEntity = [enumerator nextObject]) {
				[xformEntity setValue:[NSNumber numberWithInt:index] forKey:@"order"];
				index++;
			}
		}
		break;
	default:
		break;
	}	



}




- (void)awakeFromNib
{
   
   NSImage *image;
    [PaletteController fillBitmapRep:_paletteWithHueRep withPalette:0 usingHue:0.0];
	image = [[NSImage alloc] init];
	[image addRepresentation:_paletteWithHueRep];
	[paletteWithHue setImage:image];
	[image release];
	colourImage = [[NSImage alloc] init];
	[colourImage addRepresentation:_colourWithHueRep];
	[colourWithHue setImage:colourImage];
    
}

- (void)addNewFlame:(NSManagedObject *)genomeEntity {

	unsigned int selectedIndex, time, time2, newIndex;
	NSArray *arrangedObjects;

	selectedIndex = [genomeController selectionIndex];
	arrangedObjects = [genomeController arrangedObjects];

	switch([arrangedObjects count]) {

		case 0:
			[genomeEntity setValue:[NSNumber numberWithInt:0] forKey:@"time"];
			newIndex = 0;
			break;
		case 1:
			time = [[[arrangedObjects objectAtIndex:selectedIndex] valueForKey:@"time"] intValue];
			[genomeEntity setValue:[NSNumber numberWithInt:time+50] forKey:@"time"];
			newIndex = 1;
			break;
		default:
			newIndex = selectedIndex + 1;
			time  = [[[arrangedObjects objectAtIndex:selectedIndex] valueForKey:@"time"] intValue];
			if([arrangedObjects count] == selectedIndex + 1) {
				// last object is selected
				time2 = time + 100;
			} else {
				time2 = [[[arrangedObjects objectAtIndex:newIndex] valueForKey:@"time"] intValue];
			}
			[genomeEntity setValue:[NSNumber numberWithInt:time + ((time2 - time) / 2)] forKey:@"time"];
			break;

	}  	
//	[genomeController insertObject:genomeEntity atArrangedObjectIndex:newIndex];
	[genomeController rearrangeObjects];
	
	[paletteWithHue setNeedsDisplay:YES];

}


- (void)showFlameWindow {

	[flameWindow makeKeyAndOrderFront:self];

}

- (void) removeFlame {

	[genomeController remove:self];

}

- (void) cancelChanges:(id)sender {

}

- (void)setValue:(id)value forKey:(NSString *)key {

	NSLog(@"setting value for %@\n", key);
	[super setValue:value forKey:key];

}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {

	NSLog(@"setting value for %@\n", keyPath);
	[super setValue:value forKeyPath:keyPath];

}




- (void)setPreviewForCurrentFlame:(NSImage *)preview {

	NSManagedObject *genome = [self getSelectedGenome];

//	[genome willChangeValueForKey:@"image"];
	[genome setValue:preview forKey:@"image"];
//	[genome didChangeValueForKey:@"image"];

}


- (IBAction)changePaletteAndHidePaletteWindow:(id)sender {

	NSManagedObject *genome = [self getSelectedGenome];
	
	int paletteNumber = [paletteController changePaletteAndHidePaletteWindow];
	
	[genome setValue:[NSNumber numberWithInt:paletteNumber]  forKey:@"palette"];

	[paletteWithHue setNeedsDisplay:YES];
}



- (NSManagedObject *)getSelectedGenome {

	NSArray *selectedGenomes = [genomeController selectedObjects];
	return [selectedGenomes objectAtIndex:0];

}

- (IBAction)showPaletteList:(id)sender {

	BOOL usePalette;
	NSManagedObject *genome = [self getSelectedGenome];
	
	usePalette = [[genome valueForKey:@"use_palette"] boolValue];
	if(usePalette) {
	
		[paletteWindow setIsVisible:TRUE]; 
	} else {
		[cmapWindow setIsVisible:TRUE]; 
		
	}
}

- (IBAction)changeColourMap:(id)sender {

	NSManagedObject *cmapEntity;
	NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	NSArray *arrangedObjects;
	NSColor *colour;
	int index, newIndex, order, order2;
	float red, green, blue;

	arrangedObjects = [cmapController arrangedObjects];

	switch([segments selectedSegment]) {
		case 0:

			index = [cmapController selectionIndex];
			if(index == NSNotFound) {
				cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmapController managedObjectContext]];
				[cmapEntity setValue:[NSNumber numberWithShort:0] forKey:@"index"];
				newIndex = 0;
			} else {
				switch([arrangedObjects count]) {
				
					case 0:
						cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmapController managedObjectContext]];
						[cmapEntity setValue:[NSNumber numberWithInt:0] forKey:@"index"];
						newIndex = 0;
						break;
					case 1:
						order  = [[[arrangedObjects objectAtIndex:index] valueForKey:@"index"] intValue];
						cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmapController managedObjectContext]];
						if(order != 255) {
							[cmapEntity setValue:[NSNumber numberWithInt:255] forKey:@"index"];
						} else {
							[cmapEntity setValue:[NSNumber numberWithInt:0] forKey:@"index"];
						}
						newIndex = 1;
						break;
					case 256:	
							NSBeep();
							return;
					default:
						order  = [[[arrangedObjects objectAtIndex:index] valueForKey:@"index"] intValue];
						if(order == 255) {
							NSBeep();
							return;
						}
						cmapEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:[cmapController managedObjectContext]];
						newIndex = index + 1;
						if([arrangedObjects count] == index + 1) {
							// last object is selected
							order2 = 255;
						} else {
							order2 = [[[arrangedObjects objectAtIndex:newIndex] valueForKey:@"index"] intValue];
						}
						[cmapEntity setValue:[NSNumber numberWithInt:order + ((order2 - order) / 2)] forKey:@"index"];
						
						break;				
				} 		
			} 
			colour = [colourWell color];
			[colour getRed:&red green:&green blue:&blue alpha:NULL];
			[cmapEntity setValue:[NSNumber numberWithDouble:red] forKey:@"red"];
			[cmapEntity setValue:[NSNumber numberWithDouble:green] forKey:@"green"];
			[cmapEntity setValue:[NSNumber numberWithDouble:blue] forKey:@"blue"];
			[cmapController insertObject:cmapEntity atArrangedObjectIndex:newIndex];
			break;
		case 1:
			index = [cmapController selectionIndex];
			cmapEntity = [arrangedObjects objectAtIndex:index];
			colour = [colourWell color];
			[colour getRed:&red green:&green blue:&blue alpha:NULL];
			[cmapEntity setValue:[NSNumber numberWithDouble:red] forKey:@"red"];
			[cmapEntity setValue:[NSNumber numberWithDouble:green] forKey:@"green"];
			[cmapEntity setValue:[NSNumber numberWithDouble:blue] forKey:@"blue"];
			break;
		case 2:
			index = [cmapController selectionIndex];
			[cmapController removeObjectAtArrangedObjectIndex:index];
//			[cmapController remove:sender];
			break;
		default:
			break;
	}	

	[cmapController rearrangeObjects];
	[PaletteController fillBitmapRep:_colourWithHueRep withColours:arrangedObjects forHeight:15];
	NSManagedObject *genome = [self getSelectedGenome];
	[genome willChangeValueForKey:@"colour_map_image"];
	[genome setValue:colourImage forKey:@"colour_map_image"]; 	 
	[genome didChangeValueForKey:@"colour_map_image"];
	[colourWithHue setNeedsDisplay:YES];

}

- (IBAction)changeColourMapAndHideWindow:(id)sender {

	[cmapWindow  setIsVisible:FALSE];

}







@end
