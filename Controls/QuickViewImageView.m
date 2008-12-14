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


#import "QuickViewImageView.h"
#import "QuickViewController.h"

@implementation QuickViewImageView

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal) return NSDragOperationCopy;
	return NSDragOperationCopy|NSDragOperationGeneric|NSDragOperationLink;
}

// The simple dragImage:at:offset:event:pasteboard:source:slideback: method
// is all we do to initiate and run the actual drag sequence
// But we only do this if we have an image and we successfully write our data
// to the pasteboard in copyDataTo: method

- (void)mouseDown:(NSEvent *)e
{
NSPoint location;
NSSize size;
NSPasteboard *pboard = [NSPasteboard pasteboardWithName:(NSString *) NSDragPboard];

	/* ignore this it is example code for later */
	
	NSDictionary *binding = [self infoForBinding:NSValueBinding];
	
	NSArrayController *breedGenomeController = [binding objectForKey:NSObservedObjectKey];
	NSManagedObject *mo = [[breedGenomeController selectedObjects] objectAtIndex:0];
	NSImage *image = [[mo valueForKey:@"images"] valueForKey:@"image"];
	
    NSArray *types = [NSArray arrayWithObjects:@"Genomes", @"GenomeMoc", nil];

	NSManagedObjectContext *moc = [breedGenomeController managedObjectContext] ;
	NSData *mocData = [NSData dataWithBytes:&moc length:sizeof(NSManagedObjectContext *)];

    NSArray *genomes = [NSArray arrayWithObject:[NSData dataWithBytes:&mo length:sizeof(NSManagedObject *)]];


	[pboard declareTypes:types owner:self];
	[pboard setPropertyList:genomes forType:@"Genomes"];
	[pboard setPropertyList:[NSArray arrayWithObject:mocData] forType: @"GenomeMoc"];



	if (image) {
		size = [image size];
		location.x = ([self bounds].size.width - size.width)/2;
		location.y = ([self bounds].size.height - size.height)/2;

		[self dragImage:image at:location offset:NSZeroSize event:(NSEvent *)e pasteboard:pboard source:self slideBack:YES];
	}
}

- (void)mouseUp:(NSEvent *)e {	
	[(QuickViewController *)delegate selectValue:self];	
}


- (void) setQuickViewValue:(double)val {	
	_value = val;	
} 

- (double) quickViewValue {	
	return _value;	
} 

@end
