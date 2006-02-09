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
		_flameRecords = [[NSMutableArray alloc] init];
		_currentFlame = [[NSMutableDictionary alloc] init];
		_xforms = [[NSMutableArray alloc] init];
		

		
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
	[_flameRecords removeAllObjects];
}

-(NSArray *)getFlames {

	id key;
	NSMutableDictionary *tempFlame;
	NSMutableDictionary *tempFlameValues;

	NSEnumerator *enumerator;

	/* check update flame array is upto date first*/
	tempFlame = [_flameRecords objectAtIndex:_currentFlameIndex];
	tempFlameValues = [tempFlame objectForKey:@"dictionary"];
	
	enumerator = [tempFlameValues keyEnumerator];
	
	while ((key = [enumerator nextObject])) {
		[tempFlameValues setObject:[_currentFlame objectForKey:key] forKey:key];
	}
		

	return _flameRecords;
}

-(void)addFlameData:(NSImage *)flameImage genome:(flam3_genome *)genome atIndex:(int )index {

	NSMutableDictionary *record; 
	NSMutableDictionary *genomeDictionary; 

	record = [[NSMutableDictionary alloc] init];


	genomeDictionary = [Genome makeDictionaryFrom:genome withImage:flameImage];

	

	[record setObject:flameImage forKey:@"flame"];
	[record setObject:genomeDictionary forKey:@"dictionary"];

	[_flameRecords insertObject:record atIndex:index];
	
	[record release];
	
	[flames reloadData];
	[flameValues reloadData];
	NSLog(@"dictionary references %ld\n", [genomeDictionary retainCount]);
	
	
}

- (IBAction)showXFormWindow:(id)sender
{

 [xformWindow makeKeyAndOrderFront:self];

}

- (IBAction)test:(id)sender
{

	 flam3_genome genome;	

	 NSLog(@"time: %@",[_currentFlame objectForKey:@"time"]);
	 NSLog(@"time: %@",_currentFlame);


	[Genome populateCGenome:&genome From:_currentFlame];

	 NSLog(@"time: %f", genome.hue_rotation);
	 
 

}


- (void)awakeFromNib
{
   
   NSImage *image;
   _flameRecords = [[NSMutableArray alloc] init];
    [PaletteController fillBitmapRep:_paletteWithHueRep withPalette:0 usingHue:0.0];
	image = [[NSImage alloc] init];
	[image addRepresentation:_paletteWithHueRep];
	[paletteWithHue setImage:image];
   
}

- (IBAction)showFlameWindow:(id)sender
{

 [flameWindow makeKeyAndOrderFront:self];

}

- (void )setCurrentFlameForIndex:(int )newIndex {

	id key;
	NSMutableDictionary *tempFlame;
	NSMutableDictionary *tempFlameValues;

	NSEnumerator *enumerator;
	int paletteNumber;

	if(newIndex != _currentFlameIndex) {
		
		
		tempFlame = [_flameRecords objectAtIndex:_currentFlameIndex];
		tempFlameValues = [tempFlame objectForKey:@"dictionary"];
		
		enumerator = [tempFlameValues keyEnumerator];
		
		while ((key = [enumerator nextObject])) {
			[tempFlameValues setObject:[_currentFlame objectForKey:key] forKey:key];
			[self didChangeValueForKey:key];
		}
		
	}

   tempFlame = [_flameRecords objectAtIndex:newIndex];
   tempFlameValues = [tempFlame objectForKey:@"dictionary"];

	enumerator = [tempFlameValues keyEnumerator];
	
	while ((key = [enumerator nextObject])) {
		// code that uses the returned key  
		[self willChangeValueForKey:key];
	}
		

	enumerator = [tempFlameValues keyEnumerator];

	while ((key = [enumerator nextObject])) {
		[_currentFlame setObject:[tempFlameValues objectForKey:key] forKey:key];
		[_currentFlame setObject:[[tempFlameValues objectForKey:key] copy] forKey:key];
		[self didChangeValueForKey:key];
	}
	
	paletteNumber = [[_currentFlame objectForKey:@"palette"] intValue];
	
	[paletteController setPalette:paletteNumber colourArray:nil usePalette:YES];

	[PaletteController fillBitmapRep:_paletteWithHueRep 
	                   withPalette:paletteNumber 
					   usingHue:[[_currentFlame objectForKey:@"hue"] doubleValue]]; 
					   
	[paletteWithHue setNeedsDisplay:YES];
					   
	_currentFlameIndex = newIndex;
	
	[xFormController setXformsArray:[_currentFlame objectForKey:@"xforms"]];
	
} 

- (IBAction) setCurrentFlame:(id )sender {


	[self setCurrentFlameForIndex:[sender selectedRow]]; 

}



-(void) cancelChanges:(id)sender {



	NSMutableDictionary *tempFlame;
	NSMutableDictionary *tempFlameValues;

   tempFlame = [_flameRecords objectAtIndex:_currentFlameIndex];
   tempFlameValues = [tempFlame objectForKey:@"dictionary"];

	[tempFlameValues setDictionary:_currentFlame];

}

- (void)setValue:(id)value forKey:(NSString *)key {

	NSLog(@"setting value for %@\n", key);
	[super setValue:value forKey:key];

}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {

	NSLog(@"setting value for %@\n", keyPath);
	[super setValue:value forKeyPath:keyPath];

}

- (flam3_genome *)getSelectedFlame {


	flam3_genome *flame = (flam3_genome *)malloc(sizeof(flam3_genome));
	[Genome populateCGenome:flame From:_currentFlame];
	
	return flame;

}


- (void)setPreviewForCurrentFlame:(NSImage *)preview {

	[self willChangeValueForKey:@"image"];
	[_currentFlame setObject:preview forKey:@"image"];
	[self didChangeValueForKey:@"image"];

}


- (IBAction)changePaletteAndHidePaletteWindow:(id)sender {


	int paletteNumber = [paletteController changePaletteAndHidePaletteWindow];
	
	[PaletteController fillBitmapRep:_paletteWithHueRep 
	                   withPalette:paletteNumber 
					   usingHue:[[_currentFlame objectForKey:@"hue"] doubleValue]];

	[_currentFlame setObject:[NSNumber numberWithInt:paletteNumber]  forKey:@"palette"];

	[paletteWithHue setNeedsDisplay:YES];
}


- (void) setHue:(double)newHue {

	[_currentFlame setObject:[NSNumber numberWithDouble:newHue]  forKey:@"hue"];
		[PaletteController fillBitmapRep:_paletteWithHueRep 
	                   withPalette:[[_currentFlame objectForKey:@"palette"] intValue] 
					   usingHue:newHue]; 
					   
	[paletteWithHue setNeedsDisplay:YES];

}

- (double) hue {

	return [[_currentFlame objectForKey:@"hue"] doubleValue];

}



@end
