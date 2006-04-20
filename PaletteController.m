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

#import "PaletteController.h"
#import "flam3.h"

@implementation PaletteController


- init {
	NSBitmapImageRep *paletteRep;
	NSImage *paletteImage;
	NSMutableDictionary *paletteDictionary;
	
	
	int paletteCount, i;
	
	if (self = [super init]) {
	
   
	paletteCount = 700;
	_colours = [[NSMutableArray alloc] initWithCapacity:256];
	_palettes = [[NSMutableArray alloc] initWithCapacity:paletteCount];
   
   
	for(i=0; i<paletteCount; i++) {
		
		paletteRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
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

		
		paletteImage = [[NSImage alloc] init];
		[paletteImage addRepresentation:paletteRep];
	
	    [PaletteController fillBitmapRep:paletteRep withPalette:i usingHue:0.0];
	
		paletteDictionary = [[NSMutableDictionary alloc] initWithCapacity:2]; 
		[paletteDictionary setValue:paletteImage forKey:@"paletteimage"];	
		[paletteDictionary setValue:[NSNumber numberWithInt:i] forKey:@"palettecount"];	
		[_palettes addObject:paletteDictionary]; 
		[paletteDictionary release];
		[paletteImage release];
		[paletteRep release];
	}
	
	[colourTable reloadData];
	
	}
	
	return self;
	
}
- (IBAction)setEnabled:(id)sender
{

	
	_usePalette = [sender state];
	[textField setEnabled:_usePalette];
	if(_usePalette == YES) {
		[colourTable setEnabled:NO];
	} else {
		[colourTable setEnabled:YES];
	}	

}

- (void)awakeFromNib
{

	_paletteNumber = 0;
	[paletteList setSelectionIndex:_paletteNumber];
	[pickPalette setImage:[[_palettes objectAtIndex:_paletteNumber] objectForKey:@"paletteimage"]];

}

- (IBAction)setNumber:(id)sender
{

	_paletteNumber = [sender intValue];
	[paletteList setSelectionIndex:_paletteNumber];
	[pickPalette setImage:[[_palettes objectAtIndex:_paletteNumber] objectForKey:@"paletteimage"]];



}

- (void) setPalette:(unsigned int )palette colourArray:(NSArray *)colours usePalette:(BOOL)useThePaletteNumber {

	[_colours removeAllObjects];	


	if(useThePaletteNumber == NO) {
		[_colours addObjectsFromArray:colours];		
	}
	
	_usePalette = useThePaletteNumber;
	[colourTable reloadData];

	
	if(_usePalette == YES) {
		_paletteNumber = palette;
		[paletteList setSelectionIndex:_paletteNumber];
		[pickPalette setImage:[[_palettes objectAtIndex:_paletteNumber] objectForKey:@"paletteimage"]];
		[colourTable setEnabled:NO];
	} else {
		[colourTable setEnabled:YES];
	}	
		

}

/*
- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    id theRecord, theValue;
 
    NSParameterAssert(rowIndex >= 0 && _colours != nil && rowIndex < [_colours count]);
    theRecord = [_colours objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
    return theValue;
}

- (void)tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    id theRecord;
 
    NSParameterAssert(rowIndex >= 0 && _colours != nil && rowIndex < [_colours count]);
    theRecord = [_colours objectAtIndex:rowIndex];
    [theRecord setObject:anObject forKey:[aTableColumn identifier]];
    return;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(_colours == nil) {
		return 0;
	} 
	return [_colours count];
}
	
*/

- (int)changePaletteAndHidePaletteWindow {

	int selectedIndex;
	NSArray *selected;
	


	selected = [paletteList selectedObjects];
	selectedIndex = [paletteList selectionIndex];

	[pickPalette setImage:[[selected objectAtIndex:0] objectForKey:@"paletteimage"]];
		
	[palatteWindow setIsVisible:FALSE];
	
	return selectedIndex;

}


- (IBAction)hidePaletteWindow:(id)sender {
		[palatteWindow setIsVisible:FALSE];
}


+(void) fillBitmapRep:(NSBitmapImageRep *)paletteRep withPalette:(int)paletteNumber usingHue:(double)hue {

		flam3_palette  palette;
		
		unsigned char *paletteData;
		
		int j;
		
		paletteData = [paletteRep bitmapData];
		
		flam3_get_palette(paletteNumber, palette, hue);
		
		for(j=0; j<256; j++) {
			
			*paletteData = (unsigned char)(255.0*palette[j][0]);
			paletteData++;
			*paletteData = (unsigned char)(255.0*palette[j][1]);
			paletteData++;
			*paletteData = (unsigned char)(255.0*palette[j][2]);
			paletteData++;
			
		}																								
		
		paletteData = [paletteRep bitmapData];
		
		for(j=1; j<10; j++) {
			memcpy(paletteData+(256*j*3), paletteData, 256*3);
		}

}


+(void) fillBitmapRep:(NSBitmapImageRep *)paletteRep withColours:(NSArray *)colours forHeight:(int)height {

		NSMutableArray *finalColours;
		NSMutableDictionary *colour;
		
		unsigned char *paletteData;	
		int j;
		
		paletteData = [paletteRep bitmapData];
		

		if([colours count] < 256) {
			finalColours = [PaletteController extrapolateArray:colours];
		}  else {
			finalColours = colours;
		}
		
		
		for(j=0; j<256; j++) {
			
			colour = [finalColours objectAtIndex:j];
			
			
			*paletteData = (unsigned char)([[colour objectForKey:@"red"] intValue]);
			paletteData++;
			*paletteData = (unsigned char)([[colour objectForKey:@"green"] intValue]);
			paletteData++;
			*paletteData = (unsigned char)([[colour objectForKey:@"blue"] intValue]);
			paletteData++;
			
		}																								
		
		paletteData = [paletteRep bitmapData];
		
		for(j=1; j<height; j++) {
			memcpy(paletteData+(256*j*3), paletteData, 256*3);
		}

}


+(NSMutableArray *) extrapolateArray:(NSArray *)colours {

	int i, j;
	int index, lastIndex;
	double red, green, blue;
	double lastRed, lastGreen, lastBlue;
	double redDelta, greenDelta, blueDelta;
	
	NSMutableDictionary *colour;
	NSMutableDictionary *newColour;

	NSMutableArray *newColours = [[NSMutableArray alloc] initWithCapacity:256]; 
	
	NSEnumerator *colourEnumerator = [colours objectEnumerator];
	
	if([colours count] == 0) {
		index = 255;
		red   = 0;
		green = 0;
		blue  = 0;
	} else {
		colour = [colourEnumerator nextObject];
		index = [[colour valueForKey:@"index"] intValue];
		red   = [[colour valueForKey:@"red"] doubleValue];
		green = [[colour valueForKey:@"green"] doubleValue];
		blue  = [[colour valueForKey:@"blue"] doubleValue];
	}
	
	
	if (index > 0) {
	
		
		redDelta = red / (double)(index - 1);  	
		greenDelta = green / (double)(index - 1);  	
		blueDelta = blue / (double)(index - 1);  	

		lastRed = 0.0;
		lastGreen = 0.0;
		lastBlue = 0.0;

		for(i=0; i<index; i++) {
			
			newColour = [[NSMutableDictionary alloc] initWithCapacity:4];
			
			[newColour setObject:[NSNumber numberWithInt:i] forKey:@"index"];
			[newColour setObject:[NSNumber numberWithInt:(int)(lastRed * 255)] forKey:@"red"];
			[newColour setObject:[NSNumber numberWithInt:(int)(lastGreen * 255)] forKey:@"green"];
			[newColour setObject:[NSNumber numberWithInt:(int)(lastBlue * 255)] forKey:@"blue"];
		
			[newColours addObject:newColour];
			[newColour release];
			
			lastRed += redDelta;
			lastGreen += greenDelta;
			lastBlue += blueDelta;
		}
	
	}
	
	/* add the first colour from the array */
	newColour = [[NSMutableDictionary alloc] initWithCapacity:4];
	[newColour setObject:[NSNumber numberWithInt:i] forKey:@"index"];
	[newColour setObject:[NSNumber numberWithInt:round(red * 255)] forKey:@"red"];
	[newColour setObject:[NSNumber numberWithInt:round(green * 255)] forKey:@"green"];
	[newColour setObject:[NSNumber numberWithInt:round(blue * 255)] forKey:@"blue"];
	[newColours addObject:newColour];
	[newColour release];

	lastRed   = red;
	lastGreen = green;
	lastBlue  = blue;
	lastIndex = index;
			
	for(i=1; i<[colours count]; i++) {

		colour = [colourEnumerator nextObject];	
		index = [[colour valueForKey:@"index"]  intValue];
		
		if(lastIndex + 1 != index) { 
		
			red   = [[colour valueForKey:@"red"] doubleValue];
			green = [[colour valueForKey:@"green"] doubleValue];
			blue  = [[colour valueForKey:@"blue"] doubleValue];
			
			redDelta = (red - lastRed) / (double)(index - lastIndex);  	
			greenDelta = (green  - lastGreen) / (double)(index - lastIndex);  	
			blueDelta = (blue  - lastBlue)/ (double)(index - lastIndex);  	

			for(j = lastIndex + 1; j < index; j++) {
			
				lastRed += redDelta;
				lastGreen += greenDelta;
				lastBlue += blueDelta;
				
				newColour = [[NSMutableDictionary alloc] initWithCapacity:4];
				
				[newColour setObject:[NSNumber numberWithInt:j] forKey:@"index"];
				[newColour setObject:[NSNumber numberWithInt:round(lastRed * 255)] forKey:@"red"];
				[newColour setObject:[NSNumber numberWithInt:round(lastGreen * 255)] forKey:@"green"];
				[newColour setObject:[NSNumber numberWithInt:round(lastBlue * 255)] forKey:@"blue"];
			
				[newColours addObject:newColour];
				[newColour release];
				
			
			}

			/* add the object from the colours array */
			newColour = [[NSMutableDictionary alloc] initWithCapacity:4];

			[newColour setObject:[NSNumber numberWithInt:index] forKey:@"index"];
			[newColour setObject:[NSNumber numberWithInt:round(red * 255)] forKey:@"red"];
			[newColour setObject:[NSNumber numberWithInt:round(green * 255)] forKey:@"green"];
			[newColour setObject:[NSNumber numberWithInt:round(blue * 255)] forKey:@"blue"];
			[newColours addObject:newColour];
			[newColour release];
		}
				
		lastIndex = index;

	}  

	

	if (index < 255) {
			
		/* if we run out of colours so fade to black */	
			
		redDelta = red / (double)(255 - index);  	
		greenDelta = green / (double)(255 - index);  	
		blueDelta = blue / (double)(255 - index);  	

		for(i=0; i<index; i++) {
			
			newColour = [[NSMutableDictionary alloc] initWithCapacity:4];

			red -=redDelta;
			green -= redDelta;
			blue -= redDelta;
	
			
			[newColour setObject:[NSNumber numberWithInt:i] forKey:@"index"];
			[newColour setObject:[NSNumber numberWithInt:round(red * 255)] forKey:@"red"];
			[newColour setObject:[NSNumber numberWithInt:round(green * 255)] forKey:@"green"];
			[newColour setObject:[NSNumber numberWithInt:round(blue * 255)] forKey:@"blue"];
		
			[newColours addObject:newColour];
			[newColour release];
		}
	
	}


	[newColours autorelease];
	return newColours;
}
@end
