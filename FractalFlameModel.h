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
/* FractalFlameModel */

#import <Cocoa/Cocoa.h>
#import "EnvironmentController.h"
#import "FlameController.h"
#import "PaletteController.h"
#import "QTKit/QTKit.h"
#import "QuickTimeController.h"
#import "ProgressIndicatorWithCancel.h"

@interface FractalFlameModel : NSObjectController
{
    IBOutlet EnvironmentController *environment;
    IBOutlet FlameController *flames;
    IBOutlet PaletteController *palette;
    IBOutlet NSTableView *progessTable;
    IBOutlet NSTableView *flameTable;
    IBOutlet NSWindow *preferencesWindow;
    IBOutlet NSWindow *oxidizerWindow;
    IBOutlet NSWindow *previewWindow;
    IBOutlet NSLevelIndicator *frameIndicator;
    IBOutlet QuickTimeController *qtController;
	IBOutlet NSArrayController *progressController;
	IBOutlet NSView *saveThumbnailsView;
    IBOutlet NSImageView *previewView;

    IBOutlet NSWindow *taskProgressWindow;
    IBOutlet ProgressIndicatorWithCancel *taskAllFramesIndicator;
    IBOutlet ProgressIndicatorWithCancel *taskFrameIndicator;
    IBOutlet NSTextField *etaTextField;
	
	
	BOOL _saveThumbnail;
	BOOL _showRender;
	
	
	NSManagedObjectContext *moc;

	NSArray *genomeSortDescriptors;
	NSArray *xformSortDescriptors;
	NSArray *variationSortDescriptors;
	NSArray *cmapSortDescriptors;
	NSArray *_spatialFilterArray;
	NSArray *_stillsFormatArray;
	
	NSMutableArray *_progressInd;
	
	NSDocumentController *docController;

	NSUserDefaults *defaults;
	
	NSPersistentStoreCoordinator *coordinator;
	
	NSString *_currentFilename;
	
	NSMutableDictionary *_stillsParameters;

	int verbose;
	int bits;
	int seed;
	int transparency;
	double qs;
	double ss;
	double pixel_aspect;
	int channels;
	int nstrips;
			
	/* animation variables */
	int first_frame;
	int last_frame;
	int frame_time;
	int dtime;
	
	id objectBeginEdited;

@public

	double progress;
	int flameCount;
	int flameProgress;
	NSSavePanel *savePanel;
	IBOutlet NSArrayController *flameController;
	
	
}

- (IBAction)previewCurrentFlame:(id)sender;
- (IBAction)changePaletteAndHidePaletteWindow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)editGenomes:(id)sender;

- (BOOL)saveToFile:(NSBitmapImageRep *)rep;

//- (QTMovie *)QTMovieFromTempFile:(DataHandler *)outDataHandler error:(OSErr *)outErr;
- (NSManagedObject *) createRandomGenomeInContext:(NSManagedObjectContext *)context;
- (NSManagedObjectContext *)getNSManagedObjectContext;

- (void) deleteOldGenomes;

- (NSMutableArray *)progressIndicators;
- (void) renderStillInNewThread:(QuickTimeController *)qt;
- (void )renderStillToWindowInNewThread;
//- (void) saveNSBitmapImageRep:(NSBitmapImageRep *)rep;
- (void) previewCurrentFlameInThread:(NSArray *)genomes;
- (void) AddRandomGenomeToFlamesUsingContext:(NSManagedObjectContext *)context;
- (void) saveFlam3WithThumbnail;
- (void) saveAsFlam3WithThumbnail;

- (void) setCurrentFilename:(NSString *)filename;
- (NSString *) currentFilename;

- (void) newFlame;

- (void) renderStill;
- (void) renderAnimation;
- (void) renderAnimationStills; 
- (void) renderStillToWindow;

- (BOOL) okayToRender;

/* NSTask based version */
- (void)generateAllThumbnailsForGenomes:(NSArray *)genome;
- (void)generateAllThumbnailsForGenomesInThread:(NSArray *)genome;

- (int)runFlam3StillRenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary;
- (int)runFlam3MovieFrameRenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary; 
- (IBAction)cancelTask:(id)sender; 

- (void)createGenomesFromXMLFile:(NSString *)xmlFileName inContext:(NSManagedObjectContext *)thisMoc;
- (void)appendGenomesFromXMLFile:(NSString *)xmlFileName fromTime:(int)time inContext:(NSManagedObjectContext *)thisMoc;

- (NSMutableDictionary *)environmentDictionary;
- (NSArray *)fetchGenomes;
- (void) showPreviewWindow;

- (BOOL)openRecentFile:(NSString *)filename;
- (IBAction)openFile:(id)sender;
- (IBAction)appendFile:(id)sender;

/* lua interface */
- (NSArray *)passGenomesToLua;
- (void)createGenomesFromLua:(NSArray *)genomeArray;
- (BOOL)renderGenomeToPng:(NSString *)pngFileName;

+ (BOOL)useProgressBar;

@end
