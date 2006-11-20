//
//  DnDButton.m
//  oxidizer
//
//  Created by David Burnett on 18/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DnDButton.h"
#import "DnDArrayController.h"
#import "Genome.h"
#import "flam3.h"


@implementation DnDButton

- (void)awakeFromNib
{
    // register for drag and drop
//	[super awakeFromNib];
	
    [self registerForDraggedTypes:
		[NSArray arrayWithObjects:@"GenePoolGenome", [DnDArrayController dragType], nil]];

}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {

	NSPasteboard *pboard;
	NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];

	pboard = [sender draggingPasteboard];
	
	if ([[pboard types] containsObject:[DnDArrayController dragType]]) {
		if ((sourceDragMask & NSDragOperationGeneric) != 0) {
			return NSDragOperationGeneric;
		}
	}
	
	return NSDragOperationNone;
	
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	
	NSManagedObject *sourceEntity;	
	NSManagedObjectContext *sourceMoc;
	
	NSPasteboard *pasteBoard = [sender draggingPasteboard];
	
	NSArray *moc = [pasteBoard propertyListForType:[DnDArrayController dragType]];
	NSData *genomeData;
	NSData *mocData = [moc objectAtIndex:0];
	
	sourceMoc = [NSManagedObjectContext alloc];
	[mocData getBytes:&sourceMoc];
	
	flam3_genome *genome = (flam3_genome *)malloc(sizeof(flam3_genome));
	memset(genome, 0, sizeof(flam3_genome));
		
	NSArray *rows = [[sender draggingPasteboard] propertyListForType:@"Genomes"];
	
	NSEnumerator *enumerator = [rows objectEnumerator];
	
	genomeData = [enumerator nextObject];
	[genomeData getBytes:&sourceEntity];
	[Genome populateCGenome:genome FromEntity:sourceEntity fromContext:sourceMoc];
	[genePoolController setButton:self withCGenome:genome];
	
	return YES;
	
	
}

@end