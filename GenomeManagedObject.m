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

- (void)setName:(NSString *)newName {
	
    [self willChangeValueForKey: @"name"];
    [self setPrimitiveValue:[newName copy] forKey: @"name"];
    [self didChangeValueForKey: @"name"];

	[self willAccessValueForKey: @"parent"];
    NSString *parent = [self primitiveValueForKey: @"parent"];
    [self didAccessValueForKey: @"parent"];
	
	[self willChangeValueForKey: @"genome_path"];
    [self setPrimitiveValue:[NSString stringWithFormat:@"%@\n%@", newName, parent] forKey: @"genome_path"];
    [self didChangeValueForKey: @"genome_path"];
	
}

- (NSString *)name {
	
    NSString *name;

    [self willAccessValueForKey: @"name"];
    name = [self primitiveValueForKey: @"name"];
    [self didAccessValueForKey: @"name"];
	
	
    return name;
}

- (void)setParent:(NSString *)newParent {
	
    [self willChangeValueForKey: @"parent"];
    [self setPrimitiveValue:[newParent copy] forKey: @"parent"];
    [self didChangeValueForKey: @"parent"];

	[self willAccessValueForKey: @"name"];
    NSString *name = [self primitiveValueForKey: @"name"];
    [self didAccessValueForKey: @"name"];
	
	[self willChangeValueForKey: @"genome_path"];
    [self setPrimitiveValue:[NSString stringWithFormat:@"%@\n%@", name, newParent] forKey: @"genome_path"];
    [self didChangeValueForKey: @"genome_path"];
	
}

- (NSString *)parent {
	
    NSString *parent;
	
    [self willAccessValueForKey: @"parent"];
    parent = [self primitiveValueForKey: @"parent"];
    [self didAccessValueForKey: @"parent"];
	
    return parent;
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

- (NSColor *)background {

    NSColor *background;

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

- (void)setUse_palette:(BOOL)use {
	
	if(use == YES) {

		[self willAccessValueForKey: @"palette"];
		int index = [[self primitiveValueForKey: @"palette"] intValue];
		[self didAccessValueForKey: @"palette"];
		
		if(index < 0) {			
			[self willChangeValueForKey: @"palette"];
			[self setPrimitiveValue:[NSNumber numberWithInt:0] forKey: @"palette"];
			[self didChangeValueForKey: @"palette"];			
		}
	
	}
	
	[self willChangeValueForKey: @"use_palette"];
	[self setPrimitiveValue:[NSNumber numberWithBool:use] forKey: @"use_palette"];
	[self didChangeValueForKey: @"use_palette"];
	
	
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

- (void)setHeight:(double)newHeight {

	[self willAccessValueForKey: @"zoom_lock"];
    bool lock = [[self primitiveValueForKey: @"zoom_lock"] boolValue] ;
    [self didAccessValueForKey: @"zoom_lock"];
	
	
	if (lock) {
		
		[self willAccessValueForKey: @"height"];
		double oldHeight = [[self primitiveValueForKey: @"height"] doubleValue];
		[self didAccessValueForKey: @"height"];
	
		double scale = newHeight/oldHeight;

		[self willAccessValueForKey: @"scale"];
		double zoom = [[self primitiveValueForKey: @"scale"] doubleValue];
		[self didAccessValueForKey: @"scale"];
	
		[self willChangeValueForKey: @"scale"];
		[self setPrimitiveValue:[NSNumber numberWithDouble:(zoom * scale)] forKey: @"scale"];
		[self didChangeValueForKey: @"scale"];
	
	}

	[self willAccessValueForKey: @"aspect_lock"];
    lock = [[self primitiveValueForKey: @"aspect_lock"] boolValue] ;
    [self didAccessValueForKey: @"aspect_lock"];
	
	
	if (lock) {

		[self willAccessValueForKey: @"aspect_lock_aspect"];
		double aspect = [[self primitiveValueForKey: @"aspect_lock_aspect"] doubleValue] ;
		[self didAccessValueForKey: @"aspect_lock_aspect"];
			
		[self willChangeValueForKey: @"width"];
		[self setPrimitiveValue:[NSNumber numberWithDouble:(newHeight * aspect)] forKey: @"width"];
		[self didChangeValueForKey: @"width"];
		
	} else {
		
		/* update aspect */
		[self willAccessValueForKey: @"width"];
		double oldWidth = [[self primitiveValueForKey: @"width"] doubleValue];
		[self didAccessValueForKey: @"width"];
		
		
		[self willChangeValueForKey: @"aspect_lock_aspect"];
		[self setPrimitiveValue:[NSNumber numberWithDouble:(oldWidth / newHeight)] forKey:@"aspect_lock_aspect"] ;
		[self didChangeValueForKey: @"aspect_lock_aspect"];
		
	}	
	
	[self willChangeValueForKey: @"height"];
	[self setPrimitiveValue:[NSNumber numberWithDouble:newHeight] forKey: @"height"];
	[self didChangeValueForKey: @"height"];
	
}	
	
- (void)setWidth:(double)newWidth {
	

	[self willAccessValueForKey: @"aspect_lock"];
    bool lock = [[self primitiveValueForKey: @"aspect_lock"] boolValue] ;
    [self didAccessValueForKey: @"aspect_lock"];
		
	if (lock) {
		

		[self willAccessValueForKey: @"aspect_lock_aspect"];
		double aspect = [[self primitiveValueForKey: @"aspect_lock_aspect"] doubleValue] ;
		[self didAccessValueForKey: @"aspect_lock_aspect"];
		
		
		double newHeight = newWidth / aspect;
		

		/* we need to set the value for the height but can't call setHeight without
			changing up the aspect again leading to a change of width so
			copy some of setHeight's code
		*/
		
		[self willAccessValueForKey: @"zoom_lock"];
		bool lock = [[self primitiveValueForKey: @"zoom_lock"] boolValue] ;
		[self didAccessValueForKey: @"zoom_lock"];
		
		
		if (lock) {
						
			[self willAccessValueForKey: @"height"];
			double oldHeight = [[self primitiveValueForKey: @"height"] doubleValue];
			[self didAccessValueForKey: @"height"];
						
			double scale = newHeight/oldHeight;
			
			[self willAccessValueForKey: @"scale"];
			double zoom = [[self primitiveValueForKey: @"scale"] doubleValue];
			[self didAccessValueForKey: @"scale"];
			
			[self willChangeValueForKey: @"scale"];
			[self setPrimitiveValue:[NSNumber numberWithDouble:(zoom * scale)] forKey: @"scale"];
			[self didChangeValueForKey: @"scale"];
			
		}
		
		[self willChangeValueForKey: @"height"];
		[self setPrimitiveValue:[NSNumber numberWithDouble:newHeight] forKey: @"height"];
		[self didChangeValueForKey: @"height"];
		
		
	}  else {
		
		/* update aspect */
		[self willAccessValueForKey: @"height"];
		double oldHeight = [[self primitiveValueForKey: @"height"] doubleValue];
		[self didAccessValueForKey: @"height"];
		
		
		[self willChangeValueForKey: @"aspect_lock_aspect"];
		[self setPrimitiveValue:[NSNumber numberWithDouble:(newWidth/oldHeight)] forKey:@"aspect_lock_aspect"] ;
		[self didChangeValueForKey: @"aspect_lock_aspect"];
		
	}	
	
	
	[self willChangeValueForKey: @"width"];
	[self setPrimitiveValue:[NSNumber numberWithDouble:newWidth] forKey: @"width"];
	[self didChangeValueForKey: @"width"];
	
}	
@end
