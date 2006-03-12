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

 [xformWindow makeKeyAndOrderFront:self];

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

 [flameWindow makeKeyAndOrderFront:self];

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
