/* GenePoolController */

#import <Cocoa/Cocoa.h>
#import "GenePoolModel.h"
#import "FractalFlameModel.h"

@interface GenePoolController : NSObject
{

@public
    
	IBOutlet NSButton *geneButton0;
    IBOutlet NSButton *geneButton1;
    IBOutlet NSButton *geneButton2;
    IBOutlet NSButton *geneButton3;
    IBOutlet NSButton *geneButton4;
    IBOutlet NSButton *geneButton5;
    IBOutlet NSButton *geneButton6;
    IBOutlet NSButton *geneButton7;
    IBOutlet NSButton *geneButton8;
    IBOutlet NSButton *geneButton9;
	IBOutlet NSButton *geneButton10;
    IBOutlet NSButton *geneButton11;
    IBOutlet NSButton *geneButton12;
    IBOutlet NSButton *geneButton13;
    IBOutlet NSButton *geneButton14;
    IBOutlet NSButton *geneButton15;
	
	IBOutlet GenePoolModel *model;
	IBOutlet FractalFlameModel *ffm;

	IBOutlet NSWindow *genePoolWindow;
	

@private

	NSArray *genePoolButtons;
}


- (IBAction)breedPool:(id)sender;
- (IBAction)fillPool:(id)sender;
- (IBAction)toggleGenome:(id)sender;
- (IBAction)moveSelectedToEditor:(id)sender;

- (void) setButtonImage:(NSImage *)image forIndex:(int)index;
- (void) setButton:(NSButton *)button withCGenome:(flam3_genome *)genome;
- (void) showGenePoolWindow:(id)sender;

@end
