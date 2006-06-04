//
//  QuickTimeController.h
//  oxidizer
//
//  Created by David Burnett on 14/04/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

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
	
}

- (BOOL) showQuickTimeFileMovieDialogue;
- (BOOL) showQuickTimeFileImageDialogue; 
- (void) availableComponentsForMovie;
- (void) availableComponentsForImage;
- (void) saveMovie;
- (void) saveNSBitmapImageRep:(NSBitmapImageRep *)rep;
- (void) addNSBitmapImageRepToMovie:(NSBitmapImageRep *)imageRepresentation;

- (IBAction) getMovieExportSettings:(id )sender;
- (IBAction) getImageExportSettings:(id )sender;

- (void) setMovieHeight:(int)height width:(int)width;

+ (FSSpec)getToFSSpecFromPath:(NSString *)path;

@end
