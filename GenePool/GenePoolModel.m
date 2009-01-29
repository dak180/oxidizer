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
		[genomes addObject:[[NSData alloc] init]];
	}	

	
	[genomeImages removeAllObjects];
	
	for(i=0; i<count; i++) {		
		[genomeImages addObject:[[NSImage alloc] init]];
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
	[genePoolProgressWindow center];
	[genePoolProgressWindow makeKeyAndOrderFront:self];

	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
	[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
	
	
	for(i=0; i<genomeCount; i++) {

		[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
		[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];				

		if (buttonState[i] == NSOnState) {
			[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Creating new Genome %d", i]];
			[genePoolProgressText displayIfNeeded];
			NSData *newGenome = [BreedingController createRandomGenomeXMLwithEnvironment:env];
			[genomes replaceObjectAtIndex:i withObject:newGenome];
			[genePoolProgress incrementBy:1.0];
			[genePoolProgress displayIfNeeded];
			hasGenome[i] = YES; 
		}
	}
	
	[genePoolProgressWindow setIsVisible:NO];
	return YES;
	
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
	[genePoolProgressWindow center];
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
				[newGenomes addObject:[BreedingController mutateGenome:[genomes objectAtIndex:breedingOrder[0]]]]; 
				newGenomeCount++;
				[genePoolProgress setDoubleValue:newGenomeCount];
				[genePoolProgress displayIfNeeded];
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
					index = abs(random() % 3);
					[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Breeding Genome %d with Genome %d", breedingOrder[order[i]], breedingOrder[order[i+1]]]];
					[genePoolProgressText displayIfNeeded];
					
					/*
						If the genomes are big avoid union as the genome lengths get added together and before you 
					    know it they are taking Gigabytes to breed
					*/
					if ([[genomes objectAtIndex:breedingOrder[order[i]]] length] > 100 * 1024 && 
						[[genomes objectAtIndex:breedingOrder[order[i+1]]] length] > 100 * 1204) {
						index = (random() & 1) + 1;
					} 
					switch(index) {
						case 1:
							/* interpolate */
							[newGenomes addObject:[BreedingController interpolateGenome:[genomes objectAtIndex:breedingOrder[order[i]]] 
																			 withGenome:[genomes objectAtIndex:breedingOrder[order[i+1]]]]]; 
							break;
						case 2:
							/* alternate */
							[newGenomes addObject:[BreedingController alternateGenome:[genomes objectAtIndex:breedingOrder[order[i]]] 
																			 withGenome:[genomes objectAtIndex:breedingOrder[order[i+1]]]]]; 
							break;
						default:
							/* union */
							[newGenomes addObject:[BreedingController unionGenome:[genomes objectAtIndex:breedingOrder[order[i]]] 
																			 withGenome:[genomes objectAtIndex:breedingOrder[order[i+1]]]]]; 
							
					}
					newGenomeCount++;
					[genePoolProgress setDoubleValue:newGenomeCount];
					[genePoolProgress displayIfNeeded];

				}	
				
				
			}
	}
	

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

