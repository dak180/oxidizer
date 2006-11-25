//
//  GebePoolModel.h
//  oxidizer
//
//  Created by David Burnett on 12/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "flam3.h"


@interface GenePoolModel : NSObject {

	IBOutlet NSWindow *genePoolProgressWindow;
	IBOutlet NSProgressIndicator *genePoolProgress;
	IBOutlet NSTextField *genePoolProgressText;
	
@private
	
	flam3_genome **genomes;
	bool         *genomeCanBreed;
	unsigned int genomeCount;					
}

+(NSBitmapImageRep *)renderButtomImageRep:(flam3_genome *)cps;

- (bool) canGenomeBreed:(int)index;

- (NSImage *) setCGenome:(flam3_genome *)cGenome forIndex:(int)index;
- (flam3_genome *) getCGenomeForIndex:(int)index;

- (NSImage *) createRandomGenome:(int)index;
- (NSImage *) makeImageForGenome:(int)index;

- (void)toggleGenome:(int)index;
- (void) setGenomeCount:(unsigned int)count;
- (bool) breed;
- (bool) fill;

@end

