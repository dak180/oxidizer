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

#import "flam3.h"


@interface FractalFlameModel : NSObject
{
    IBOutlet EnvironmentController *environment;
    IBOutlet FlameController *flames;
    IBOutlet PaletteController *palette;
    IBOutlet NSTableView *progessTable;
    IBOutlet NSTableView *flameTable;
    IBOutlet NSWindow *progressWindow;
    IBOutlet NSWindow *preferencesWindow;
    IBOutlet NSWindow *oxidizerWindow;
    IBOutlet NSWindow *previewWindow;
    IBOutlet NSLevelIndicator *frameIndicator;
    IBOutlet QuickTimeController *qtController;
	IBOutlet NSArrayController *progressController;
	IBOutlet NSArrayController *flameController;
	IBOutlet NSView *saveThumbnailsView;
    IBOutlet NSImageView *previewView;
	
	BOOL _saveThumbnail;
	BOOL _showRender;
	
	
	NSManagedObjectContext *moc;

	NSArray *genomeSortDescriptors;
	NSArray *xformSortDescriptors;
	NSArray *variationSortDescriptors;
	NSArray *cmapSortDescriptors;
	NSArray *_spatialFilterArray;
	
	NSMutableArray *_progressInd;
	
	NSDocumentController *docController;

	NSUserDefaults *defaults;
	
	NSPersistentStoreCoordinator *coordinator;
	
	NSString *_currentFilename;

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

@public

	double progress;
	int flameCount;
	int flameProgress;

}

- (IBAction)openFile:(id)sender;
- (IBAction)previewCurrentFlame:(id)sender;
- (IBAction)changePaletteAndHidePaletteWindow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)editGenomes:(id)sender;
- (IBAction)appendFile:(id)sender;

- (BOOL)generateAllThumbnailsForGenome:(flam3_genome *)cps withCount:(int)ncps inContext:(NSManagedObjectContext *)thisMoc;
- (BOOL)loadFlam3File:(NSString *)filename intoCGenomes:(flam3_genome **)genomes returningCountInto:(int *)count;
- (BOOL)saveToFile:(NSBitmapImageRep *)rep;
- (BOOL)EnvironmentInit:(flam3_frame *)f threadCount:(int)threads;
- (BOOL)openRecentFile:(NSString *)filename;

- (void)renderFlames:(flam3_genome *)cps numberOfFlames:(int)ncps;
- (NSBitmapImageRep *)renderSingleFrame:(flam3_frame *)f withGemone:(flam3_genome *)cps;
- (NSBitmapImageRep *)renderThumbnail:(flam3_genome *)cps; 
- (QTMovie *)QTMovieFromTempFile:(DataHandler *)outDataHandler error:(OSErr *)outErr;
- (NSManagedObject *) createRandomGenomeInContext:(NSManagedObjectContext *)context;
- (NSManagedObjectContext *)getNSManagedObjectContext;

- (void) deleteOldGenomes;

- (NSMutableArray *)progressIndicators;
- (void) renderStillInNewThread:(QuickTimeController *)qt;
- (void )renderStillToWindowInNewThread;
- (void) saveNSBitmapImageRep:(NSBitmapImageRep *)rep;
- (void) previewCurrentFlameInThread;
- (void) AddRandomGenomeToFlamesUsingContext:(NSManagedObjectContext *)context;
- (void) hideProgressWindow;
- (void) initProgressController:(NSNumber *)threadsCount;
- (void) saveFlam3WithThumbnail;
- (void) saveAsFlam3WithThumbnail;

- (void) setCurrentFilename:(NSString *)filename;
- (NSString *) currentFilename;

- (void) newFlame;

- (void)renderStill;
- (void)renderAnimation;
- (void)renderStillToWindow;


@end
