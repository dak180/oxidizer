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
- (void) addNSImageToMovie:(NSImage *)image;

- (IBAction) getMovieExportSettings:(id )sender;
- (IBAction) getImageExportSettings:(id )sender;

+ (FSSpec)getToFSSpecFromPath:(NSString *)path;

@end
