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
   
}

- (IBAction)showFlameWindow:(id)sender
{

	unsigned int selectedIndex, time, time2, newIndex;
	NSArray *arrangedObjects;

	 NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	 switch([segments selectedSegment]) {
		case 0:
			selectedIndex = [genomeController selectionIndex];
			arrangedObjects = [genomeController arrangedObjects];
			
			
			NSManagedObjectContext *moc = 			[genomeController managedObjectContext];
			NSManagedObject *genomeEntity = [Genome createDefaultGenomeEntityFromInContext:moc];
			[genomeEntity retain];
			
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
			[genomeController insertObject:genomeEntity atArrangedObjectIndex:newIndex];
			[genomeEntity release];

			break;
		case 1:
			[flameWindow makeKeyAndOrderFront:self];
			break;
		case 2:
			[genomeController remove:sender];
			break;
		default:
			break;
	 }	

	[paletteWithHue setNeedsDisplay:YES];

}



-(void) cancelChanges:(id)sender {

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


@end
