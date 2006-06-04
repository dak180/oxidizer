/* BreedingController */

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
