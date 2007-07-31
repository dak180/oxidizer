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


#import <Cocoa/Cocoa.h>
#import "QTKit/QTKit.h"


@interface QuickTimeController : NSObject {

@private
	NSString *filename;
	QTMovie *qtMovie;
	QTTime frameTime;
	NSData *movieExportSettings;
	NSData *imageExportSettings;

	NSMutableDictionary *movieDict;

	int selectionIndex;
	
	DataHandler movieDataHandlerRef;
	Movie  tempMovie;
	
	BOOL useDefaultSettings;

	GraphicsExportComponent geExporter;

    /* take two, use low level quicktime */
	
	Rect	movieRect;	
	
    GWorldPtr movieGWorld;
    Handle compressedData;
    Ptr compressedDataPtr;
    ImageDescriptionHandle imageDesc;
    CGrafPtr oldPort;
    GDHandle oldGDeviceH;
	Media movieMedia;
	Track movieTrack;

	QTAtomContainer settings;

    short resRefNum;
    short resId;


@public
		
	IBOutlet NSMutableArray *movieComponents;
	IBOutlet NSArrayController *movieExportController;
	IBOutlet NSView *movieExportPanel;

	IBOutlet NSMutableArray *imageComponents;
	IBOutlet NSArrayController *imageExportController;
	IBOutlet NSView *imageExportPanel;
	IBOutlet NSView *stillsExportPanel;
	
}

- (BOOL) showQuickTimeFileMovieDialogue;
- (BOOL) showQuickTimeFileImageDialogue; 
- (BOOL) showQuickTimeFileStillsDialogue;
- (BOOL) CreateMovieGWorld;
- (void) availableComponentsForMovie;
- (void) availableComponentsForImage;
- (void) saveMovie;
- (void) saveNSBitmapImageRep:(NSBitmapImageRep *)rep;
- (void) addNSBitmapImageRepToMovie:(NSBitmapImageRep *)imageRepresentation;
- (NSString *) fileName;

- (IBAction) getMovieExportSettings:(id )sender;
- (IBAction) getImageExportSettings:(id )sender;

- (void) setMovieHeight:(int)height width:(int)width;

+ (FSSpec)getToFSSpecFromPath:(NSString *)path;

@end
