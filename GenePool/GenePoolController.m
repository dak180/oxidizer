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

	if ([button state] == NSOffState) {
		[button setImage:[model getImageForGenome:index]];
	} else {
		[button setImage:nil];			
	}

	[model setButton:index toState:[button state]];
	
//	NSLog(@"pressed button %d, %d", index, [button state]);
}


- (IBAction)breedPool:(id)sender {

	[NSThread detachNewThreadSelector:@selector(breedPoolInThread:) toTarget:self withObject:sender];

}

- (IBAction)breedPoolInThread:(id)sender {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[sender retain];
	
	[(NSControl *)sender setEnabled:NO];

	if([model breed] == NO) {
		
		return;
		
	}
	
	/* after breeding all genome can breed so set all buttons on */
	
	int i;
	
	for(i=0; i<[genePoolButtons count]; i++) {
		[self setButtonImage:[model makeImageForGenome:i] forIndex:i];
		[[genePoolButtons objectAtIndex:i] setState:NSOffState];
		[model setButton:i toState:NSOffState];
	}

	[(NSControl *)sender setEnabled:YES];
	
	[sender release];
	[pool release];	
	
}



- (IBAction)fillPool:(id)sender {
	
	[NSThread detachNewThreadSelector:@selector(fillPoolInThread:) toTarget:self withObject:sender];
	
}	


- (void)fillPoolInThread:(id)sender {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[sender retain];

	[(NSControl *)sender setEnabled:NO];
	
	int i;
	
	if([model fill]) {
		
		/* after filling genomes set to no-breed but have genomes are new */ 
		
		for(i=0; i<[genePoolButtons count]; i++) {
			
			if ([model hasGenomeForIndex:i]) {
				[self setButtonImage:[model makeImageForGenome:i] forIndex:i];
				[[genePoolButtons objectAtIndex:i] setState:NSOffState];
				[model setButton:i toState:NSOffState];
			} else {
				[[genePoolButtons objectAtIndex:i] setState:NSOnState];				
				[model setButton:i toState:NSOnState];				
			}
		}
		
	}	
	
	[(NSControl *)sender setEnabled:YES];

	[sender release];
	[pool release];
	
}
	


- (IBAction)moveSelectedToEditor:(id)sender {
	
	int i;
	int time = 0;

	NSMutableArray *newGenomes = [[NSMutableArray alloc] initWithCapacity:[genePoolButtons count]];
	
	NSManagedObjectContext *moc = [ffm getNSManagedObjectContext];

	NSArray *genomeArray;
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
	[fetch setSortDescriptors: sortDescriptors];
	
	genomeArray = [moc executeFetchRequest:fetch error:nil];
	
	if(genomeArray != nil && [genomeArray count] > 0) {
		
		time = [[[genomeArray objectAtIndex:0] valueForKey:@"time"] intValue];
		time += 15;
		
	}	
	[fetch release];	  
	[sort release];
	
	
	for(i=0; i<[genePoolButtons count]; i++) {
		if ([[genePoolButtons objectAtIndex:i] state] == NSOffState) {
			NSData *genomeXML = [model getGenomeForIndex:i];
			[genomeXML retain];
//			NSLog(@"%@", [[NSString alloc] initWithData:genomeXML encoding:NSUTF8StringEncoding]);
			NSArray *tmpGenomeArray = [Genome createGenomeEntitiesFromXML:genomeXML inContext:moc];
			[(NSManagedObject *)[tmpGenomeArray objectAtIndex:0] setValue:[NSNumber numberWithInt:time] forKey:@"time"];
			time += 15;
			[newGenomes addObjectsFromArray:tmpGenomeArray];
			
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
	NSButton *tempButton;
	
	for(i=0; i<[genePoolButtons count]; i++) {
		tempButton = [genePoolButtons objectAtIndex:i];  
		if ([tempButton state] == NSOnState) {
			[tempButton setImage:[model getImageForGenome:i]];
		} else {
			[tempButton setImage:nil];			
		}
		[tempButton setNextState];
		[model setButton:i toState:[tempButton state]];
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
			[tmpButton setNextState];
			[model setButton:i toState:[tmpButton state]];
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
