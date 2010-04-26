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


#import "DragDropAndSaveImageView.h"

@implementation DragDropAndSaveImageView

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal) return NSDragOperationCopy;
	return NSDragOperationCopy|NSDragOperationGeneric|NSDragOperationLink;
}

// The simple dragImage:at:offset:event:pasteboard:source:slideback: method
// is all we do to initiate and run the actual drag sequence
// But we only do this if we have an image and we successfully write our data
// to the pasteboard in copyDataTo: method

- (void)mouseDown:(NSEvent *)event
{

	NSPoint location;
	NSSize size;
	NSPasteboard *pboard = [NSPasteboard pasteboardWithName:(NSString *) NSDragPboard];
	
	[pboard declareTypes:[NSArray arrayWithObject:NSFilesPromisePboardType] owner:self];
	[pboard addTypes:[NSArray arrayWithObject:@"tiff_data"] owner:self];

	NSImage *image = [self image];
	
	/*
	   
	 NSImage *thumbImage = [[NSImage alloc] initWithData:[image TIFFRepresentation]];
	 
	 NSAffineTransform *at = [NSAffineTransform transform];
	 
	 [thumbImage setScalesWhenResized:YES];
	 
	 double scale;
	 
	 double heightFactor = 128.0/[image size].height;
	 double widthFactor = 128.0/[image size].width;
	 if(heightFactor > widthFactor){
	 scale = widthFactor;
	 } else {
	 scale = heightFactor;
	 }
	 
	 [at scaleBy:scale];
	 
	 
	 [thumbImage setSize:[at transformSize:[image size]]];
	 */ 
	
	NSAffineTransform *at = [NSAffineTransform transform];

	double scale;
	
	double heightFactor = 128.0/[image size].height;
	double widthFactor = 128.0/[image size].width;
	if(heightFactor > widthFactor){
		scale = widthFactor;
	} else {
		scale = heightFactor;
	}
	
	[at scaleBy:scale];
	
	
	NSImage *thumbImage = [[NSImage alloc] initWithSize:[at transformSize:[image size]]];
	
	[thumbImage setScalesWhenResized:YES];
	
	[thumbImage lockFocus];
	
	[image drawInRect:NSMakeRect(0.0, 0.0, [thumbImage size].width, [thumbImage size].width)
			 fromRect:NSMakeRect(0.0, 0.0, [image size].width, [image size].width)
			operation:NSCompositeCopy
			 fraction:1.0];

	[thumbImage unlockFocus];
	
	if (thumbImage) {
		size = [thumbImage size];
		location = [self convertPoint:[event locationInWindow] fromView:nil];
		location.x -= (size.width / 2.0f );
		location.y -= (size.height / 2.0f );
		[self dragImage:thumbImage at:location  offset:NSZeroSize event:(NSEvent *)event pasteboard:pboard source:self slideBack:YES];
	}
	
	[thumbImage autorelease];
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type {

	if([type isEqualToString:@"tiff_data"] == YES) {
		
	
	//	NSImage *image = [self image];
	//	[sender setData:[image TIFFRepresentation] forType:NSPDFPboardType];
	
	} else if([type isEqualToString:NSFilesPromisePboardType]) {
		
		[sender setPropertyList:[NSArray arrayWithObject:@"png"] forType:NSFilesPromisePboardType];

	}
}

- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination {

	
	NSFileManager		*fm;
	NSString			*basePath;
	NSString			*path;
	
	// determine a valid name for the file to write to
	fm = [NSFileManager defaultManager];

	basePath = [[dropDestination path] stringByAppendingPathComponent:@"Oxidizer"];
	path = [basePath stringByAppendingPathExtension:@"png"];
	
	int i = 1;
	while ([fm fileExistsAtPath:path])	{
		path = [[basePath stringByAppendingFormat:@"-%i", i++] stringByAppendingPathExtension:@"png"];
	}
	
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[[self image] TIFFRepresentation]];
	[[bitmap representationUsingType:NSPNGFileType properties:nil] 
						 writeToFile:path 
						atomically:YES];	

	[bitmap release]; 
	
	return [NSArray arrayWithObject:[path lastPathComponent]];	
	
}

@end
