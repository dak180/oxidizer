//
//  GenomeManagedObject.m
//  oxidizer
//
//  Created by David Burnett on 26/02/2006.
//  Copyright 2006 Vargolsoft. All rights reserved.
/*
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

#import "GenomeManagedObject.h"
#import "PaletteController.h"


@implementation GenomeManagedObject

- (void)willSave {

    NSImage *tmpImage = [self primitiveValueForKey:@"image"];
    if (tmpImage != nil) {
        [self setPrimitiveValue:[NSArchiver archivedDataWithRootObject:tmpImage] forKey:@"imageData"];
    } else {
        [self setPrimitiveValue:nil forKey:@"imageData"];
	}

    NSColor *tmpColour = [self primitiveValueForKey:@"background"];
    if (tmpColour != nil) {
        [self setPrimitiveValue:[NSArchiver archivedDataWithRootObject:tmpImage] forKey:@"backgroundData"];
    } else {
        [self setPrimitiveValue:nil forKey:@"backgroundData"];
	}

    NSAttributedString *tmpEdits = [self primitiveValueForKey:@"edits"];
    if (tmpEdits != nil) {
        [self setPrimitiveValue:[NSArchiver archivedDataWithRootObject:tmpEdits] forKey:@"editsData"];
    } else {
        [self setPrimitiveValue:nil forKey:@"editsData"];
	}
    [super willSave];
}

- (void)awakeFromFetch {

//	[super awakeFromFetch];

    NSData *imageData = [self valueForKey:@"imageData"];
    if (imageData != nil) {
        NSImage *image = [NSUnarchiver unarchiveObjectWithData:imageData];
        [self setPrimitiveValue:image forKey:@"image"];
    }

    NSData *colourData = [self valueForKey:@"backgroundData"];
    if (colourData != nil) {
        NSColor *colour = [NSUnarchiver unarchiveObjectWithData:colourData];
        [self setPrimitiveValue:colour forKey:@"background"];
    }

    NSData *editsData = [self valueForKey:@"editsData"];
    if (editsData != nil) {
        NSAttributedString *edits = [NSUnarchiver unarchiveObjectWithData:colourData];
        [self setPrimitiveValue:edits forKey:@"edits"];
    }
		
}



- (void)setImage:(NSImage *)newImage {

    [self willChangeValueForKey: @"image"];
    [self setPrimitiveValue:[newImage copy] forKey: @"image"];
    [self didChangeValueForKey: @"image"];
	
}

- (NSImage *)image {

    NSImage *image;

    [self willAccessValueForKey: @"image"];
    image = [self primitiveValueForKey: @"image"];
    [self didAccessValueForKey: @"image"];

    return image;
}

- (void)setBackground:(NSColor *)newColour {

    [self willChangeValueForKey: @"background"];
    [self setPrimitiveValue:[newColour copy] forKey: @"background"];
    [self didChangeValueForKey: @"background"];
	
}

- (NSImage *)background {

    NSImage *background;

    [self willAccessValueForKey: @"background"];
    background = [self primitiveValueForKey: @"background"];
    [self didAccessValueForKey: @"background"];

    return background;
}

- (void)setEdits:(NSAttributedString *)newEdits {

    [self willChangeValueForKey: @"edits"];
    [self setPrimitiveValue:[newEdits copy] forKey: @"edits"];
    [self didChangeValueForKey: @"edits"];
	
}

- (NSAttributedString *)edits {

    NSAttributedString *edits;

    [self willAccessValueForKey: @"edits"];
    edits = [self primitiveValueForKey: @"edits"];
    [self didAccessValueForKey: @"edits"];

    return edits;
}

- (double)hue {

	double newHue;

    [self willAccessValueForKey: @"hue"];
    newHue = [[self primitiveValueForKey: @"hue"] doubleValue];
    [self didAccessValueForKey: @"hue"];

	return newHue;
}

- (void)setHue:(double)newHue {

	int index;


    [self willAccessValueForKey: @"palette"];
    index = [[self primitiveValueForKey: @"palette"] intValue];
    [self didAccessValueForKey: @"palette"];

	if(index > -1) {
	[self willChangeValueForKey: @"palette_image"];

		NSImage *paletteImage = [[NSImage alloc] init];
		NSBitmapImageRep *paletteWithHueRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
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
		[PaletteController fillBitmapRep:paletteWithHueRep withPalette:index usingHue:newHue];
		[paletteImage addRepresentation:paletteWithHueRep];
		
		[self setPrimitiveValue:paletteImage forKey: @"palette_image"];
			
		[paletteWithHueRep release];
		[paletteImage release];
										    
		[self didChangeValueForKey: @"palette_image"];

	
	}
		
	[self willChangeValueForKey: @"hue"];
	[self setPrimitiveValue:[NSNumber numberWithDouble:newHue] forKey: @"hue"];
	[self didChangeValueForKey: @"hue"];
}


- (void)setPalette:(int)index {

	double hue;


    [self willAccessValueForKey: @"hue"];
    hue = [[self primitiveValueForKey: @"hue"] doubleValue];
    [self didAccessValueForKey: @"hue"];

	if(index > -1) {
		[self willChangeValueForKey: @"palette_image"];

		NSImage *paletteImage = [[NSImage alloc] init];
		NSBitmapImageRep *paletteWithHueRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
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
		[PaletteController fillBitmapRep:paletteWithHueRep withPalette:index usingHue:hue];
		[paletteImage addRepresentation:paletteWithHueRep];

		[self setPrimitiveValue:paletteImage forKey: @"palette_image"];
		
			
		[paletteWithHueRep release];
		[paletteImage release];
										    
		[self didChangeValueForKey: @"palette_image"];
	

	
	}
	
	[self willChangeValueForKey: @"palette"];
	[self setPrimitiveValue:[NSNumber numberWithInt:index] forKey: @"palette"];
	[self didChangeValueForKey: @"palette"];
}

- (void)setPalette_image:(NSImage *)newImage {

    [self willChangeValueForKey: @"palette_image"];
    [self setPrimitiveValue:[newImage copy] forKey: @"palette_image"];
    [self didChangeValueForKey: @"palette_image"];
	
}

- (NSImage *)palette_image {

    [self willAccessValueForKey: @"palette_image"];
    NSImage *image = [self primitiveValueForKey: @"palette_image"];
    [self didAccessValueForKey: @"palette_image"];

    return image;
}

- (void)setColour_map_image:(NSImage *)newImage {

    [self willChangeValueForKey: @"colour_map_image"];
    [self setPrimitiveValue:[newImage copy] forKey: @"colour_map_image"];
    [self didChangeValueForKey: @"colour_map_image"];
	
}

- (NSImage *)colour_map_image {

    [self willAccessValueForKey: @"colour_map_image"];
    NSImage *image = [self primitiveValueForKey: @"colour_map_image"];
    [self didAccessValueForKey: @"colour_map_image"];

    return image;
}


@end
