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



@implementation GenomeManagedObject

- (void)willSave {

    NSColor *tmpColour = [self primitiveValueForKey:@"background"];
    if (tmpColour != nil) {
        [self setPrimitiveValue:[NSArchiver archivedDataWithRootObject:tmpColour] forKey:@"backgroundData"];
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

    NSData *colourData = [self valueForKey:@"backgroundData"];
    if (colourData != nil) {
        NSColor *colour = [NSUnarchiver unarchiveObjectWithData:colourData];
        [self setPrimitiveValue:colour forKey:@"background"];
    }

    NSData *editsData = [self valueForKey:@"editsData"];
    if (editsData != nil) {
        NSAttributedString *edits = [NSUnarchiver unarchiveObjectWithData:editsData];
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


- (void)setUse_palette:(BOOL)use {

	if(use == YES) {

		[self willAccessValueForKey: @"images"];
		NSManagedObject *images = [self primitiveValueForKey: @"images"];
		[self didAccessValueForKey: @"images"];

		[images willAccessValueForKey: @"palette"];
		int index = [[images primitiveValueForKey: @"palette"] intValue];
		[images didAccessValueForKey: @"palette"];

		if(index < 0) {
			[images willChangeValueForKey: @"palette"];
			[images setPrimitiveValue:[NSNumber numberWithInt:0] forKey: @"palette"];
			[images didChangeValueForKey: @"palette"];
		}

	}

	[self willChangeValueForKey: @"use_palette"];
	[self setPrimitiveValue:[NSNumber numberWithBool:use] forKey: @"use_palette"];
	[self didChangeValueForKey: @"use_palette"];


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


- (void)setHeight:(double)newHeight {


	[self willAccessValueForKey: @"aspect_lock"];
    bool lock = [[self primitiveValueForKey: @"aspect_lock"] boolValue] ;
    [self didAccessValueForKey: @"aspect_lock"];

	if (lock) {


		[self willAccessValueForKey: @"aspect_lock_aspect"];
		double aspect = [[self primitiveValueForKey: @"aspect_lock_aspect"] doubleValue] ;
		[self didAccessValueForKey: @"aspect_lock_aspect"];


		double newWidth = newHeight * aspect;


		/* we need to set the value for the width but can't call setWidth without
		 changing up the aspect again leading to a change of width so
		 copy some of setWidth's code
		 */

		[self willAccessValueForKey: @"zoom_lock"];
		bool lock = [[self primitiveValueForKey: @"zoom_lock"] boolValue] ;
		[self didAccessValueForKey: @"zoom_lock"];


		if (lock) {

			[self willAccessValueForKey: @"width"];
			double oldWidth = [[self primitiveValueForKey: @"width"] doubleValue];
			[self didAccessValueForKey: @"width"];

			double scale = newWidth/oldWidth;

			[self willAccessValueForKey: @"scale"];
			double zoom = [[self primitiveValueForKey: @"scale"] doubleValue];
			[self didAccessValueForKey: @"scale"];

			[self willChangeValueForKey: @"scale"];
			[self setPrimitiveValue:[NSNumber numberWithDouble:(zoom * scale)] forKey: @"scale"];
			[self didChangeValueForKey: @"scale"];

		}

		[self willChangeValueForKey: @"width"];
		[self setPrimitiveValue:[NSNumber numberWithDouble:newWidth] forKey: @"width"];
		[self didChangeValueForKey: @"width"];


	}  else {

		/* update aspect */
		[self willAccessValueForKey: @"width"];
		double oldWidth = [[self primitiveValueForKey: @"width"] doubleValue];
		[self didAccessValueForKey: @"width"];


		[self willChangeValueForKey: @"aspect_lock_aspect"];
		[self setPrimitiveValue:[NSNumber numberWithDouble:(oldWidth/newHeight)] forKey:@"aspect_lock_aspect"] ;
		[self didChangeValueForKey: @"aspect_lock_aspect"];

	}


	[self willChangeValueForKey: @"height"];
	[self setPrimitiveValue:[NSNumber numberWithDouble:newHeight] forKey: @"height"];
	[self didChangeValueForKey: @"height"];

}



- (void)setTime:(int)newTime {

	[self willChangeValueForKey: @"time"];
	[self setPrimitiveValue:[NSNumber numberWithInt:newTime] forKey:@"time"] ;
	[self didChangeValueForKey: @"time"];

	[self willChangeValueForKey: @"order"];
	[self setPrimitiveValue:[NSNumber numberWithInt:newTime] forKey:@"order"] ;
	[self didChangeValueForKey: @"order"];

}


- (void)setHue:(double)newHue {

	NSManagedObject *images;


    [self willAccessValueForKey: @"images"];
    images = [self primitiveValueForKey: @"images"];
    [self didAccessValueForKey: @"images"];

	[images setValue:[NSNumber numberWithDouble:newHue] forKey:@"hue"];

	[self willChangeValueForKey: @"hue"];
	[self setPrimitiveValue:[NSNumber numberWithDouble:newHue] forKey: @"hue"];
	[self didChangeValueForKey: @"hue"];
}

- (NSManagedObject *)parent_genome {

    return self;
}
@end
