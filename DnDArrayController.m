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


#import "DnDArrayController.h"
#import "Genome.h"

NSString *mocPasteboardType = @"GenomeMoc";

@implementation DnDArrayController

- (void)awakeFromNib
{
    // register for drag and drop
    [tableView registerForDraggedTypes:
		[NSArray arrayWithObjects:@"Genomes", mocPasteboardType, nil]];

	[super awakeFromNib];
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard { 

	
	NSMutableArray *genomes = [[NSMutableArray alloc] initWithCapacity:[rowIndexes count]];
	
    NSArray *types = [NSArray arrayWithObjects:@"Genomes", mocPasteboardType, nil];

	NSManagedObjectContext *moc = [self managedObjectContext] ;
	NSData *mocData = [NSData dataWithBytes:&moc length:sizeof(NSManagedObjectContext *)];
	NSManagedObject *mo;

	unsigned index = [rowIndexes firstIndex];
    while ( index != NSNotFound ) {
		mo = [[self arrangedObjects] objectAtIndex:index];
        [genomes addObject:[NSData dataWithBytes:&mo length:sizeof(NSManagedObject *)]];            
        index = [rowIndexes indexGreaterThanIndex: index];
    }

	[pboard declareTypes:types owner:self];
	[pboard setPropertyList:genomes forType:@"Genomes"];
	[pboard setPropertyList:[NSArray arrayWithObject:mocData] forType:mocPasteboardType];

	return YES;
}



- (NSDragOperation)tableView:(NSTableView*)aTableView
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op {
    
    NSDragOperation dragOp = NSDragOperationMove;
    
	if(row == -1) {
		row = 0;
	}
    [aTableView setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return dragOp;
}

- (BOOL)tableView:(NSTableView*)aTableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op {

	NSManagedObject *sourceEntity;	
	NSManagedObjectContext **sourceMoc;
	NSManagedObjectContext *destinationMoc = [self managedObjectContext];
	
	NSPasteboard *pasteBoard = [info draggingPasteboard];
	
	NSArray *moc = [pasteBoard propertyListForType:mocPasteboardType];
	NSData *genomeData;
	NSData *mocData = [moc objectAtIndex:0];

	[mocData getBytes:&sourceMoc];

	flam3_genome genome;
	
	NSArray *rows = [[info draggingPasteboard] propertyListForType:@"Genomes"];
	
	NSEnumerator *enumerator = [rows objectEnumerator];

	while (genomeData = [enumerator nextObject]) {
		[genomeData getBytes:&sourceEntity];
		[Genome populateCGenome:&genome FromEntity:sourceEntity fromContext:sourceMoc];
		[Genome createGenomeEntityFrom:&genome withImage:[sourceEntity valueForKey:@"image"] inContext:destinationMoc];
	}
	
	[self rearrangeObjects];
	
	return YES;

}



@end
