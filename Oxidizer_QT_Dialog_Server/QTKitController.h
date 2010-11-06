//
//  QTKitController.h
//  oxidizer
//
//  Created by David Burnett on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTimeComponents.h>


@interface QTKitController : NSObject {

	@private
	
	NSString *_filename;
	NSNumber *_subtype;
	NSNumber *_manufacturer;
	NSSavePanel *_savePanel;

	QTAtomContainer _settings;

	int _selectedComponentIndex;
	BOOL _usePreviousSettings;

	IBOutlet NSMutableArray *movieComponents;
	IBOutlet NSArrayController *movieExportController;
	IBOutlet NSView *movieExportPanel;
	
	
}

- (BOOL) showQuickTimeFileMovieDialogue;
- (void) setFileName:(NSString *)filename;
- (NSArray *)availableComponents;
- (NSDictionary *)getExportDictionary;

- (IBAction) getExportSettings: (id) sender;
- (IBAction) changeMovieFileType:(id )sender;

	

@end
