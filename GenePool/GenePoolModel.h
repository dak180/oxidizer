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
	bool         *genomeCanBreed;
	unsigned int genomeCount;					
}

//+ (NSString *)createTemporaryPathWithFileName:(NSString *)fileName;

- (bool) canGenomeBreed:(int)index;

- (NSImage *) setGenome:(NSData *)genome forIndex:(int)index;
- (NSData *) getGenomeForIndex:(int)index;

- (NSImage *) createRandomGenome:(int)index;
- (NSImage *) makeImageForGenome:(int)index;

- (void)toggleGenome:(int)index;
- (void) setGenomeCount:(unsigned int)count;
- (bool) breed;
- (bool) fill;

@end

