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
#import "SymmetryController.h"
#import "XFormController.h"
#import "QTKit/QTKit.h"

#import "flam3.h"


@interface FractalFlameModel : NSObject
{
    IBOutlet EnvironmentController *environment;
    IBOutlet FlameController *flames;
    IBOutlet PaletteController *palette;
    IBOutlet SymmetryController *symmetry;
    IBOutlet XFormController *xForm;
    IBOutlet NSTableView *flameImages;
    IBOutlet NSWindow *progressWindow;
    IBOutlet NSWindow *preferencesWindow;
    IBOutlet NSLevelIndicator *frameIndicator;
    IBOutlet NSLevelIndicator *progressIndicator;
	

	NSMutableArray *thumbnails;
	
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

- (IBAction)renderStill:(id)sender;
- (IBAction)renderAnimation:(id)sender;
- (IBAction)openFile:(id)sender;
- (IBAction)previewCurrentFlame:(id)sender;
- (IBAction)changePaletteAndHidePaletteWindow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;


- (BOOL)generateAllThumbnailsForGenome:(flam3_genome *)cps withCount:(int)ncps;
- (BOOL)loadFlam3File:(NSString *)filename intoCGenomes:(flam3_genome **)genomes returningCountInto:(int *)count;
- (BOOL)saveToFile:(NSBitmapImageRep *)rep;
- (BOOL)EnvironmentInit:(flam3_frame *)f;
- (void)rebuildflame:(flam3_genome *)cps count:(int)ncps;
- (void)renderFlames:(flam3_genome *)cps numberOfFlames:(int)ncps;
 - (NSBitmapImageRep *)renderSingleFrame:(flam3_frame *)f withGemone:(flam3_genome *)cps;
 - (NSBitmapImageRep *)renderThumbnail:(flam3_genome *)cps; 
-(QTMovie *)QTMovieFromTempFile:(DataHandler *)outDataHandler error:(OSErr *)outErr;
@end
