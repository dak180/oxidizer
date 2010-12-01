//
//  GenePoolModel.m
//  oxidizer
//
//  Created by David Burnett on 12/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GenePoolModel.h"
#import "Flam3Task.h"
#import "BreedingController.h"


@implementation GenePoolModel

- init
{
	
    if (self = [super init]) {

		genomes = [[NSMutableArray alloc] initWithCapacity:16];
		genomeImages = [[NSMutableArray alloc] initWithCapacity:16];
		buttonState = NULL;
		hasGenome = NULL;
	}
	
	return self;
}


- (NSImage *) makeImageForGenome:(int)index {
	
	srandom(time(NULL));
	
	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  

	[env setObject:[NSNumber numberWithInt:64] forKey:@"bits"];
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
	[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
	
	NSString *pngFileName = [Flam3Task createTemporaryPathWithFileName:@"gpm.png"];
	[pngFileName retain];
	[env setObject:pngFileName forKey:@"out"];
	
	
	
	[Flam3Task runFlam3RenderAsQuietTask:[genomes objectAtIndex:index] withEnvironment:env];
	
	NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:pngFileName]];

	[Flam3Task deleteTemporaryPathAndFile:pngFileName];
	
	[genomeImages replaceObjectAtIndex:index withObject:flameImage];
	
	[flameImage release];
	[pngFileName release];
	[env release];
	
	return [genomeImages objectAtIndex:index];
}	
	
- (NSImage *) getImageForGenome:(int)index {
	if(index < [genomeImages count]) {
		return [genomeImages objectAtIndex:index];		
	} 	
	
	return nil;
}


- (void)setButton:(int)index toState:(unsigned int)state {
	
	
	buttonState[index] = state;
	
}

- (void) setGenomeCount:(unsigned int)count {
	
	int i;
	
	if(buttonState != NULL) {
		free(buttonState);
	}
	buttonState = (unsigned int *)malloc(sizeof(unsigned int) * count);

	if(hasGenome != NULL) {
		free(hasGenome);
	}
	hasGenome = (bool *)malloc(sizeof(bool) * count);
	
	
	for(i=0; i<count; i++) {		
		buttonState[i] = NSOnState;
		hasGenome[i] = NO;
	}
	
	[genomes removeAllObjects];

	for(i=0; i<count; i++) {		
//		[genomes addObject:[[NSData alloc] init]];
		[genomes addObject:[NSData data]];
	}	

	
	[genomeImages removeAllObjects];
	
	for(i=0; i<count; i++) {
		NSImage *newImage = [[NSImage alloc] init];
		[genomeImages addObject:newImage];
		[newImage release];
	}	
	
	genomeCount = count;
	
} 

- (bool) fill {


	int i, fillCount;

	fillCount = 0;
	
	for(i=0; i<genomeCount; i++) {
		if (buttonState[i] == NSOnState) {
			fillCount++;
		}
	}
	
	if(fillCount == 0) {		
		return NO;
	}
	
	[genePoolProgress setMaxValue:fillCount-1];
	[genePoolProgress setDoubleValue:0.0];
	[genePoolProgress setUsesThreadedAnimation:YES];

	if(![genePoolProgressWindow setFrameUsingName:@"gene_pool_progress"]) {
		[genePoolProgressWindow center];	
	}	[genePoolProgressWindow makeKeyAndOrderFront:self];

	
	NSMutableArray *threads = [[NSMutableArray alloc] init];
	
	int threadCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"threads"] integerValue];
	
	for(i=0; i<genomeCount; i++) {

		

		if (buttonState[i] == NSOnState) {

			NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
			[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
			
			[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
			[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];		
			[env setObject:[NSNumber numberWithInt:i] forKey:@"genome_index"];		
		
			if([threads count] < threadCount) {
				NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(createRandomGenomeXMLInThreadwithEnvironment:) object:env];
				[threads addObject:newThread];
				[newThread start];
				[newThread release];
			} else {
				bool threadsFull = YES;
				while (threadsFull == YES) {
					int j;
					for(j=0; j<threadCount; j++) {
						NSThread *thisThread = [threads objectAtIndex:j]; 
						if ([thisThread isFinished]) {
							NSThread *replacementThread = [[NSThread alloc] initWithTarget:self 
																				 selector:@selector(createRandomGenomeXMLInThreadwithEnvironment:) 
																				   object:env];
							[threads replaceObjectAtIndex:j 
											   withObject:replacementThread];
							
							[replacementThread start];
							
							[replacementThread release];
							
							threadsFull = NO;
							break;
						}
					}
					usleep(50000);
				}
			}
			[env autorelease];

		}
		
	}

	
	bool threadsFinished = NO;
	while (threadsFinished == NO) {
		int j;
		threadsFinished = YES;
		for(j=0; j<[threads count]; j++) {
			NSThread *thisThread = [threads objectAtIndex:j]; 
			if (![thisThread isFinished]) {
				threadsFinished = NO;
			}
		}
		usleep(50000);
	}
	
/*	
	int j;

	 for(j=0; j<[threads count]; j++) {
		NSThread *thisThread = [threads objectAtIndex:j]; 
		[thisThread release];
	}
*/	
	[threads release];
	[genePoolProgressWindow setIsVisible:NO];
	return YES;
	
}

- (void)  createRandomGenomeXMLInThreadwithEnvironment:(NSMutableDictionary *)env {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[env retain];
	
	int i = [[env objectForKey:@"genome_index"] integerValue];
	
	
	[env removeObjectForKey:@"genome_index"];
	
	[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Creating new Genome %d", i]];
	[genePoolProgressText displayIfNeeded];
	NSData *newGenome = [BreedingController createRandomGenomeXMLwithEnvironment:env];
	[genomes replaceObjectAtIndex:i withObject:newGenome];
	[genePoolProgress incrementBy:1.0];
	[genePoolProgress displayIfNeeded];
	hasGenome[i] = YES; 
	
	[env release];
	[pool release];
	
	
}




- (bool) breed {
	
	unsigned int i;
	unsigned int breedingCount = 0;

	for(i=0; i<genomeCount; i++) {
		NSData *genomeCheck = [genomes objectAtIndex:i];
		if(buttonState[i] == NSOffState && [genomeCheck length] > 0) {
			breedingCount++;	
		}
		
	}
	
	if(breedingCount == 0) {
		return NO;
	}
	
	
	[genePoolProgress setMaxValue:genomeCount-1];
	[genePoolProgress setDoubleValue:0.0];
	[genePoolProgress setUsesThreadedAnimation:YES];
	if(![genePoolProgressWindow setFrameUsingName:@"gene_pool_progress"]) {
		[genePoolProgressWindow center];	
	}	[genePoolProgressWindow makeKeyAndOrderFront:self];
	[genePoolProgressWindow makeKeyAndOrderFront:self];
	
	
	NSMutableArray *newGenomes = [[NSMutableArray alloc] initWithCapacity:genomeCount];

	unsigned int *order = malloc(sizeof(unsigned int) * breedingCount);
	unsigned int *breedingOrder = malloc(sizeof(unsigned int) * breedingCount);

	unsigned int index = 0;
	unsigned int tmp;
	unsigned int newGenomeCount = 0;

	srandom(time(NULL));
	
	for(i=0; i<genomeCount; i++) {
		
		NSData *genomeCheck = [genomes objectAtIndex:i];
		if(buttonState[i] == NSOffState && [genomeCheck length] > 0) {
			breedingOrder[index] = i;
			order[index] = index;
			index++;
		}
		
	}


	NSMutableArray *threads = [[NSMutableArray alloc] init];
	
	int threadCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"threads"] integerValue];
	
	
	switch (breedingCount) {
		case 0:
			[newGenomes release];
			[genePoolProgressWindow setIsVisible:NO];
			return NO;
			break;
		case 1:
			[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Mutating Genome %d", breedingOrder[0]]];
			[genePoolProgressText displayIfNeeded];
			
			
			while(newGenomeCount < genomeCount) {
				
				
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
				[dict setObject:newGenomes forKey:@"genome_array"];
				[dict setObject:[genomes objectAtIndex:breedingOrder[0]] forKey:@"old_genome"];
				[dict setObject:[NSNumber numberWithInt:newGenomeCount] forKey:@"genome_index"];
				
				
				if([threads count] < threadCount) {
					NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMutateGenome:) object:dict];
					[threads addObject:newThread];
					[newThread start];
					[newThread release];
				} else {
					bool threadsFull = YES;
					while (threadsFull == YES) {
						int j;
						for(j=0; j<threadCount; j++) {
							NSThread *thisThread = [threads objectAtIndex:j]; 
							if ([thisThread isFinished]) {
								NSThread *replacementThread = [[NSThread alloc] initWithTarget:self 
																					  selector:@selector(threadMutateGenome:) 
																						object:dict];
								[threads replaceObjectAtIndex:j 
												   withObject:replacementThread];
								
								[replacementThread start];
								
								[replacementThread release];
								
								threadsFull = NO;
								break;
							}
						}
						usleep(50000);
					}
				}
				 
				newGenomeCount++;
				[dict autorelease];
				 
			}
			break;
		default:		
				
			while(newGenomeCount < genomeCount) {
				
				/* quick monte carlo */
				for(i=0; i<breedingCount; i++) {
					tmp = order[i];
					index = abs(random() % breedingCount);
					order[i] = order[index];
					order[index] = tmp;					
				}	
				
				for(i=0; i+1<breedingCount && newGenomeCount < genomeCount; i+=2) {

					NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
					[dict setObject:newGenomes forKey:@"genome_array"];
					[dict setObject:[genomes objectAtIndex:breedingOrder[order[i]]] forKey:@"old_genome_1"];
					[dict setObject:[genomes objectAtIndex:breedingOrder[order[i+1]]] forKey:@"old_genome_2"];
					[dict setObject:[NSNumber numberWithInt:breedingOrder[order[i]]] forKey:@"genome_index_1"];
					[dict setObject:[NSNumber numberWithInt:breedingOrder[order[i+1]]] forKey:@"genome_index_2"];				
					
					index = abs(random() % 3);

					/*
						If the genomes are big avoid union as the genome lengths get added together and before you 
					    know it they are taking Gigabytes to breed
					*/
					if ([[genomes objectAtIndex:breedingOrder[order[i]]] length] > 100 * 1024 && 
						[[genomes objectAtIndex:breedingOrder[order[i+1]]] length] > 100 * 1204) {
						index = (random() & 1) + 1;
					} 
					
					
					if([threads count] < threadCount) {
						
						NSThread *newThread;
						
						switch(index) {
							case 1:
								/* interpolate */
								newThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadInterpolateGenome:) object:dict];
								break;
							case 2:
								/* alternate */
								newThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadAlternateGenome:) object:dict];
								break;
							default:
								/* union */
								newThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadUnionGenome:) object:dict];
								
						}
						
						[threads addObject:newThread];
						[newThread start];
						[newThread release];
						
					} else {
						bool threadsFull = YES;
						while (threadsFull == YES) {
							int j;
							for(j=0; j<threadCount; j++) {
								NSThread *thisThread = [threads objectAtIndex:j]; 
								if ([thisThread isFinished]) {
									
														
									NSThread *replacementThread;
									
									switch(index) {
										case 1:
											/* interpolate */
											replacementThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadInterpolateGenome:) object:dict];
											break;
										case 2:
											/* alternate */
											replacementThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadAlternateGenome:) object:dict];
											break;
										default:
											/* union */
											replacementThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadUnionGenome:) object:dict];
											
									}									
									
									
									[threads replaceObjectAtIndex:j 
													   withObject:replacementThread];
									
									[replacementThread start];
									
									[replacementThread release];
									
									threadsFull = NO;
									break;
								}
							}
							usleep(50000);
						}
					}
					
					[dict release];

					newGenomeCount++;

				}	
				
				
			}
	}
	
	bool threadsFinished = NO;
	while (threadsFinished == NO) {
		int j;
		threadsFinished = YES;
		for(j=0; j<[threads count]; j++) {
			NSThread *thisThread = [threads objectAtIndex:j]; 
			if (![thisThread isFinished]) {
				threadsFinished = NO;
			}
		}
		usleep(50000);
	}

/*	
	
	int j;
	
	for(j=0; j<[threads count]; j++) {
		NSThread *thisThread = [threads objectAtIndex:j]; 
		[thisThread release];
	}
*/
	
	[threads release];
	
	
	[genomes removeAllObjects];
	[genomes addObjectsFromArray:newGenomes];
	
	for(i=0; i<genomeCount; i++) {		
		hasGenome[i] = YES;
	}
	
	[newGenomes removeAllObjects];
	[newGenomes release];
	
	free(order);
	free(breedingOrder);

	[genePoolProgressWindow setIsVisible:NO];

	
	return YES;
	
}


- (void)threadMutateGenome:(NSDictionary *)dict {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[dict retain];
	
	NSMutableArray *newGenomes = [dict objectForKey:@"genome_array"];
	NSData *oldGenome = [dict objectForKey:@"old_genome"];

	int i = [[dict objectForKey:@"genome_index"] integerValue];
	
	[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Mutating Genome %d", i]];
	[genePoolProgressText displayIfNeeded];

	[newGenomes addObject:[BreedingController mutateGenome:oldGenome]]; 
	
	[genePoolProgress incrementBy:1.0];
	[genePoolProgress displayIfNeeded];
	
	[dict release];
	[pool release];
	
}

- (void)threadInterpolateGenome:(NSDictionary *)dict {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[dict retain];
	
	NSMutableArray *newGenomes = [dict objectForKey:@"genome_array"];
	NSData *oldGenome1 = [dict objectForKey:@"old_genome_1"];
	NSData *oldGenome2 = [dict objectForKey:@"old_genome_2"];
	
	int i = [[dict objectForKey:@"genome_index_1"] integerValue];
	int j = [[dict objectForKey:@"genome_index_2"] integerValue];

	[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Breeding Genome %d with Genome %d", i,j]];
	[genePoolProgressText displayIfNeeded];
	

	[newGenomes addObject:[BreedingController interpolateGenome:oldGenome1 
													 withGenome:oldGenome2]]; 

	[genePoolProgress incrementBy:1.0];
	[genePoolProgress displayIfNeeded];
	
	[dict release];
	[pool release];	
	
}

- (void)threadAlternateGenome:(NSDictionary *)dict {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[dict retain];
	
	NSMutableArray *newGenomes = [dict objectForKey:@"genome_array"];
	
	NSData *oldGenome1 = [dict objectForKey:@"old_genome_1"];
	NSData *oldGenome2 = [dict objectForKey:@"old_genome_2"];
	
	int i = [[dict objectForKey:@"genome_index_1"] integerValue];
	int j = [[dict objectForKey:@"genome_index_2"] integerValue];
	
	[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Breeding Genome %d with Genome %d", i,j]];
	[genePoolProgressText displayIfNeeded];
	
	
	[newGenomes addObject:[BreedingController alternateGenome:oldGenome1 
													 withGenome:oldGenome2]]; 
	
	[genePoolProgress incrementBy:1.0];
	[genePoolProgress displayIfNeeded];
	
	[dict release];
	[pool release];		
	
}

- (void)threadUnionGenome:(NSDictionary *)dict {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[dict retain];
	

	NSMutableArray *newGenomes = [dict objectForKey:@"genome_array"];
	NSData *oldGenome1 = [dict objectForKey:@"old_genome_1"];
	NSData *oldGenome2 = [dict objectForKey:@"old_genome_2"];
	
	int i = [[dict objectForKey:@"genome_index_1"] integerValue];
	int j = [[dict objectForKey:@"genome_index_2"] integerValue];
	
	[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Breeding Genome %d with Genome %d", i,j]];
	[genePoolProgressText displayIfNeeded];
	
	
	[newGenomes addObject:[BreedingController unionGenome:oldGenome1 
													 withGenome:oldGenome2]]; 
	
	[genePoolProgress incrementBy:1.0];
	[genePoolProgress displayIfNeeded];
	
	[dict release];
	[pool release];		
	
}


- (NSImage *) setGenome:(NSData *)genome forIndex:(int)index {
	

	[genomes replaceObjectAtIndex:index withObject:genome];

	NSImage *flameImage = [self makeImageForGenome:index];
	return flameImage;
				
}

- (NSData *) getGenomeForIndex:(int)index {
	
	if(index < [genomeImages count]) {
		return [genomes objectAtIndex:index];		
	} 
	
	return nil;			
}

- (bool) hasGenomeForIndex:(int)index {
	
	if(index < genomeCount) {
		return hasGenome[index];		
	} 
	
	return NO;			
}

@end

