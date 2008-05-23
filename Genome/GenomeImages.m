//
//  ColourMapImages.m
//  oxidizer
//
//  Created by David Burnett on 22/05/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GenomeImages.h"
#import "PaletteController.h"

@implementation GenomeImages

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
																					  pixelsHigh:1
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
																					  pixelsHigh:1
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

- (void) setImageFromFile:(NSString *)filePath {
	
	NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
	
	[self willChangeValueForKey:@"image"];
	[self setValue:flameImage forKey:@"image"];
	[self didChangeValueForKey:@"image"];
	
	[flameImage release];	
	
}

@end
