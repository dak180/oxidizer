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
#import "FractalFlameModel.h"

@interface BreedingController : NSObject
{

    IBOutlet PaletteController *palette;
	IBOutlet FractalFlameModel *flameModel;
    IBOutlet NSArrayController *genome1;
    IBOutlet NSArrayController *genome2;
    IBOutlet NSArrayController *genomeResult;
    IBOutlet NSTableView *genomeTable1;
    IBOutlet NSTableView *genomeTable2;
    IBOutlet NSWindow *breedingWindow;
	
	NSManagedObjectContext *moc1;
	NSManagedObjectContext *moc2;
	NSManagedObjectContext *mocResult;

	NSArray *genomeSortDescriptors;
	
	NSDocumentController *docController;
	

}

- (BOOL) openFile:(NSManagedObjectContext *)moc;
- (void) deleteOldGenomesInContext:(NSManagedObjectContext *)moc;

- (BOOL) canBreed;
- (BOOL) canMutate;

- (IBAction)loadNewGenomeIntoMoc1:(id)sender;
- (IBAction)loadNewGenomeIntoMoc2:(id)sender;

- (IBAction)alternate:(id)sender;
- (IBAction)interpolate:(id)sender;
- (IBAction)doUnion:(id)sender;
- (IBAction)mutate:(id)sender;
- (IBAction)clone:(id)sender;
- (IBAction)sendResultToEditor:(id)sender;


- (IBAction)showBreedingWindow:(id)sender;

@end
