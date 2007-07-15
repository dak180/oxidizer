#import "GenePoolController.h"
#import "Genome.h"

@implementation GenePoolController

- (void)awakeFromNib {
	
	genePoolButtons = [NSArray arrayWithObjects:geneButton0, geneButton1, geneButton2,
												geneButton3, geneButton4, geneButton5,
												geneButton6, geneButton7, geneButton8, 
												geneButton9, geneButton10, geneButton11, 
												geneButton12, geneButton13, geneButton14, 
												geneButton15, nil];
	
	[genePoolButtons retain];
	
	[model setGenomeCount:[genePoolButtons count]];
	
}

- (IBAction)toggleGenome:(id)sender  {

	NSButton *button = (NSButton *)sender;
	
	int index = [button tag];
	
	[model toggleGenome:index];
	
//	NSLog(@"pressed button %d, %d", index, [button state]);
}


- (IBAction)breedPool:(id)sender {
	
	if([model breed] == NO) {
		
		return;
		
	}
	
	int i;
	
	for(i=0; i<[genePoolButtons count]; i++) {
		[self setButtonImage:[model makeImageForGenome:i] forIndex:i];
		if ([model canGenomeBreed:i] == YES) {
			[model toggleGenome:i];
			[[genePoolButtons objectAtIndex:i] setNextState];
		}
	}
	
}


- (IBAction)fillPool:(id)sender {
	
	int i;
	
	if([model fill]) {
		
		for(i=0; i<[genePoolButtons count]; i++) {
			if ([model canGenomeBreed:i] == NO) {
				[self setButtonImage:[model makeImageForGenome:i] forIndex:i];
			}
		}
		
	}	
	
}


- (IBAction)moveSelectedToEditor:(id)sender {
	
	int i;
	
	NSMutableArray *newGenomes = [[NSMutableArray alloc] initWithCapacity:[genePoolButtons count]];
	
	NSManagedObjectContext *moc = [ffm getNSManagedObjectContext];
	
	for(i=0; i<[genePoolButtons count]; i++) {
		if ([[genePoolButtons objectAtIndex:i] state] == NSOffState) {
			NSData *genomeXML = [model getGenomeForIndex:i];
			[genomeXML retain];
			NSLog(@"%@", [[NSString alloc] initWithData:genomeXML encoding:NSUTF8StringEncoding]);
			[newGenomes addObjectsFromArray:[Genome createGenomeEntitiesFromXML:genomeXML inContext:moc]];
			[genomeXML release];
		}
	}
	

	if ([newGenomes count] > 0) {

		[moc performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
		[ffm generateAllThumbnailsForGenomes:newGenomes];
		
	}
	
	[newGenomes release];
	
}


- (IBAction)toggleButtons:(id)sender  {
	
	int i;
	
	for(i=0; i<[genePoolButtons count]; i++) {
		[model toggleGenome:i];
		[[genePoolButtons objectAtIndex:i] setNextState];
	}
	
	//	NSLog(@"pressed button %d, %d", index, [button state]);
}


-(void) setButtonImage:(NSImage *)image forIndex:(int)index {
	
	NSButton *button = [genePoolButtons objectAtIndex:index];
	[button setImage:image];
	
} 


- (void)setButton:(NSButton *)button withGenome:(NSData *)genome {
	
	int i;
	
	NSButton *tmpButton;
	
	for(i=0; i<[genePoolButtons count]; i++) {
		tmpButton = [genePoolButtons objectAtIndex:i];
		if (button == tmpButton) {
			[self setButtonImage:[model setGenome:genome forIndex:i] forIndex:i];
		}
	}
	
}


- (void) showGenePoolWindow:(id)sender {
	
	[genePoolWindow makeKeyAndOrderFront:sender];
	
}


- (void) setFractalFlameModel:(FractalFlameModel *)ffmodel {
	
	if(ffmodel != nil) {
		[ffmodel retain];
	}
	[ffm release];
	
	ffm = ffmodel;
	
}

@end
