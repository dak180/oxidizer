//
//  GebePoolModel.h
//  oxidizer
//
//  Created by David Burnett on 12/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GenePoolModel : NSObject {

	IBOutlet NSWindow *genePoolProgressWindow;
	IBOutlet NSProgressIndicator *genePoolProgress;
	IBOutlet NSTextField *genePoolProgressText;
	
@private
	
/*	flam3_genome **genomes;
*/
	NSMutableArray     *genomes;
	NSMutableArray     *genomeImages;
	unsigned int       *buttonState;
	bool         *hasGenome;
	unsigned int genomeCount;					
}

- (NSImage *) setGenome:(NSData *)genome forIndex:(int)index;
- (NSData *) getGenomeForIndex:(int)index;
- (bool) hasGenomeForIndex:(int)index;

- (NSImage *) makeImageForGenome:(int)index;
- (NSImage *) getImageForGenome:(int)index;

- (void)setButton:(int)index toState:(unsigned int)state;
- (void) setGenomeCount:(unsigned int)count;
- (bool) breed;
- (bool) fill;

@end

