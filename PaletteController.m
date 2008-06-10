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

void rgb2hsv(double *rgb, double *hsv);
void hsv2rgb(double *rgb, double *hsv);

static double *_paletteData = NULL;


@implementation PaletteController


- init {
	NSBitmapImageRep *paletteRep;
	NSImage *paletteImage;
	NSMutableDictionary *paletteDictionary;
	
	
	int paletteCount, i;
	
	
	if (self = [super init]) {
   
		[[NSFileManager defaultManager] changeCurrentDirectoryPath:[[ NSBundle mainBundle ] resourcePath ]]; 
   
//		getcwd(buffer, 255);		
//		fprintf(stderr, "%s\n", buffer);

   
	paletteCount = 700;
	_colours = [[NSMutableArray alloc] initWithCapacity:256];
	_palettes = [[NSMutableArray alloc] initWithCapacity:paletteCount];
   
   
	for(i=0; i<paletteCount; i++) {
		
		paletteRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
															pixelsWide:256
															pixelsHigh:1
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
	
	    [PaletteController fillBitmapRep:paletteRep withPalette:i usingHue:0.0 forHeight:1];
	
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


+(void) fillBitmapRep:(NSBitmapImageRep *)paletteRep withPalette:(int)paletteNumber usingHue:(double)hue forHeight:(int)height {

	double rgbValues[3];
	double hsv[3];
	
	if (_paletteData == NULL) {
		_paletteData = initialisePalettes();
	} 
	
		double *palette = _paletteData + (paletteNumber * 768) ;
		
		unsigned char *paletteData;
		
		int j;
		
		paletteData = [paletteRep bitmapData];
		
		for(j=0; j<256; j++) {
			
			rgb2hsv(palette + (3 * j), hsv);
			hsv[0] += hue * 6.0;
			hsv2rgb(hsv, rgbValues);
			
			*paletteData = (unsigned char)(255.0 * rgbValues[0]);
			paletteData++;
			*paletteData = (unsigned char)(255.0 * rgbValues[1]);
			paletteData++;
			*paletteData = (unsigned char)(255.0 * rgbValues[2]);
			paletteData++;
			
		}																								

	paletteData = [paletteRep bitmapData];

	for(j=1; j<height; j++) {
		memcpy(paletteData+(256*j*3), paletteData, 256*3);
	}

}

+(void) fillBitmapRep:(NSBitmapImageRep *)paletteRep withPalette:(double *)palette forHeight:(int)height {
	
	unsigned char *paletteData;
	
	int j;
	
	paletteData = [paletteRep bitmapData];
		
	for(j=0; j<256; j++) {
		
		*paletteData = (unsigned char)(255.0 * *(palette + (3 * j)));
		paletteData++;
		*paletteData = (unsigned char)(255.0 * *(palette + (3 * j) + 1));
		paletteData++;
		*paletteData = (unsigned char)((255.0 * *(palette + (3 * j) + 2)));
		paletteData++;
		
	}																								
	
	paletteData = [paletteRep bitmapData];
	
	for(j=1; j<height; j++) {
		memcpy(paletteData+(256*j*3), paletteData, 256*3);
	}
	
}


+(void) fillBitmapRep:(NSBitmapImageRep *)paletteRep withColours:(NSArray *)colours forHeight:(int)height {

		NSMutableArray *finalColours;
		NSMutableDictionary *colour;
		
		unsigned char *paletteData;	
		int j;
		
		paletteData = [paletteRep bitmapData];
		

//		if([colours count] < 256) {
			finalColours = [PaletteController extrapolateArray:colours];
//		}  else {
//			finalColours = [NSMutableArray arrayWithArray:colours];
//		}
		
		
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

+(void) fillColour:(NSDictionary *)colour forWidth:(int)width andHeight:(int)height {
	
	unsigned char *paletteData;	
	int j;
	
	unsigned char red, green, blue;
	
	paletteData = [[colour objectForKey:@"bitmapRep"] bitmapData];
	
	red = (unsigned char)([[colour objectForKey:@"red"] doubleValue] * 255.0);
	green = (unsigned char)([[colour objectForKey:@"green"] doubleValue] * 255.0);
	blue = (unsigned char)([[colour objectForKey:@"blue"] doubleValue] * 255.0);
	
	for(j=0; j<width; j++) {
		
		*paletteData = red;
		paletteData++;
		*paletteData = green;
		paletteData++;
		*paletteData = blue;
		paletteData++;
		
	}																								
	
	paletteData = [[colour objectForKey:@"bitmapRep"] bitmapData];
	
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
	[newColour setObject:[NSNumber numberWithInt:index] forKey:@"index"];
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

		}
			/* add the object from the colours array */
		red   = [[colour valueForKey:@"red"] doubleValue];
		green = [[colour valueForKey:@"green"] doubleValue];
		blue  = [[colour valueForKey:@"blue"] doubleValue];

		lastRed = red;
		lastGreen = green;
		lastBlue = blue;
		
		newColour = [[NSMutableDictionary alloc] initWithCapacity:4];

		[newColour setObject:[NSNumber numberWithInt:index] forKey:@"index"];
		[newColour setObject:[NSNumber numberWithInt:round(red * 255)] forKey:@"red"];
		[newColour setObject:[NSNumber numberWithInt:round(green * 255)] forKey:@"green"];
		[newColour setObject:[NSNumber numberWithInt:round(blue * 255)] forKey:@"blue"];
		[newColours addObject:newColour];
		[newColour release];
				
		lastIndex = index;

	}  

	

	if (index < 255) {
			
		/* if we run out of colours so fade to black */	
			
		redDelta = red / (double)(255 - index);  	
		greenDelta = green / (double)(255 - index);  	
		blueDelta = blue / (double)(255 - index);  	

		for(i=index+1; i<256; i++) {
			
			newColour = [[NSMutableDictionary alloc] initWithCapacity:4];

			red -=redDelta;
			green -= greenDelta;
			blue -= blueDelta;
	
			
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


+ (void )createXMLForGradient:(NSArray *)cmaps forElement:(NSXMLElement *)gradient {
	
	NSDictionary *colour;
	NSXMLElement *colourElement;
	
    NSEnumerator *enumerator = [cmaps objectEnumerator];
	

	while((colour = [enumerator nextObject])) {
		colourElement = (NSXMLElement *)[NSXMLNode elementWithName:@"color"];
		
		[colourElement addAttribute:[NSXMLNode attributeWithName:@"index" stringValue:[[colour  objectForKey:@"index"] stringValue]]];	
		[colourElement addAttribute:[NSXMLNode attributeWithName:@"red" stringValue:[[colour  objectForKey:@"red"] stringValue]]];	
		[colourElement addAttribute:[NSXMLNode attributeWithName:@"green" stringValue:[[colour  objectForKey:@"green"] stringValue]]];	
		[colourElement addAttribute:[NSXMLNode attributeWithName:@"blue" stringValue:[[colour  objectForKey:@"blue"] stringValue]]];	
		
		[gradient addChild:colourElement];
		
	}
	
}


@end

double *initialisePalettes(void) {
	
	NSError *error;
	
	NSString *pathToXML = [NSString pathWithComponents:[NSArray arrayWithObjects:[[ NSBundle mainBundle ] resourcePath ], @"flam3-palettes.xml", nil]];
	NSXMLDocument *paletteDoc = [[NSXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:pathToXML] 
															options:0 
															  error:&error];
	NSXMLElement *root = [paletteDoc rootElement];
	NSArray *palettes = [root children];
	NSEnumerator *paletteEnumerator = [palettes objectEnumerator];
	NSXMLElement *palette;
	
	int i, j;
	
	int red, green, blue;
	
	NSRange range;
	
	_paletteData = (double *)malloc(256 * 3 * [palettes count] * sizeof(double));
	
	while((palette = [paletteEnumerator nextObject])) {
		
		int index = [[[palette attributeForName:@"number"] stringValue] intValue];
		NSString *data = [[palette attributeForName:@"data"] stringValue];
		range.length = 8;
		range.location = 0;
		
		int itemCount = 0;
		
		for(i=0; i<32; i++) {
			for(j=0; j<8; j++) {
				unsigned int argb = 0;
				NSScanner *paletteScanner = [NSScanner scannerWithString:[data substringWithRange:range]];
				[paletteScanner scanHexInt:&argb];
				blue = (argb & 0x000000FF);
				green = ((argb & 0x0000FF00) >> 8);
				red = ((argb & 0x00FF0000) >> 16);
				*(_paletteData + (index * 768) + (itemCount * 3)) = red / 255.0 ;
				*(_paletteData + (index * 768) + (itemCount * 3) + 1) = green / 255.0;
				*(_paletteData + (index * 768) + (itemCount * 3) + 2) = blue / 255.0;
				range.location += 8;
				itemCount++;
			}
			range.location++;
		}
	}
	
	return _paletteData; 
}

void rgb2hsv(double *rgb, double *hsv) {

	double rd, gd, bd, h, s, v, max, min, del, rc, gc, bc;
	
	rd = rgb[0];
	gd = rgb[1];
	bd = rgb[2];
	
	/* compute maximum of rd,gd,bd */
	if (rd>=gd) { if (rd>=bd) max = rd;  else max = bd; }
	else { if (gd>=bd) max = gd;  else max = bd; }
	
	/* compute minimum of rd,gd,bd */
	if (rd<=gd) { if (rd<=bd) min = rd;  else min = bd; }
	else { if (gd<=bd) min = gd;  else min = bd; }
	
	del = max - min;
	v = max;
	if (max != 0.0) s = (del) / max;
	else s = 0.0;
	
	h = 0;
	if (s != 0.0) {
		rc = (max - rd) / del;
		gc = (max - gd) / del;
		bc = (max - bd) / del;
		
		if      (rd==max) h = bc - gc;
		else if (gd==max) h = 2 + rc - bc;
		else if (bd==max) h = 4 + gc - rc;
		
		if (h<0) h += 6;
	}
	
	hsv[0] = h;
	hsv[1] = s;
	hsv[2] = v;
}


/* h 0 - 6, s 0 - 1, v 0 - 1
rgb 0 - 1 */
void hsv2rgb(double *hsv, double *rgb) {
	
	double h = hsv[0], s = hsv[1], v = hsv[2];
	int    j;
	double rd, gd, bd;
	double f, p, q, t;
	
	while (h >= 6.0) h = h - 6.0;
	while (h <  0.0) h = h + 6.0;
	j = (int) floor(h);
	f = h - j;
	p = v * (1-s);
	q = v * (1 - (s*f));
	t = v * (1 - (s*(1 - f)));
	
	switch (j) {
		case 0:  rd = v;  gd = t;  bd = p;  break;
		case 1:  rd = q;  gd = v;  bd = p;  break;
		case 2:  rd = p;  gd = v;  bd = t;  break;
		case 3:  rd = p;  gd = q;  bd = v;  break;
		case 4:  rd = t;  gd = p;  bd = v;  break;
		case 5:  rd = v;  gd = p;  bd = q;  break;
		default: rd = v;  gd = t;  bd = p;  break;
	}
	
	rgb[0] = rd;
	rgb[1] = gd;
	rgb[2] = bd;
}