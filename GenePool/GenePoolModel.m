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
		genomeCanBreed = NULL;
	
	}
	
	return self;
}


- (bool) canGenomeBreed:(int)index {
	
	return genomeCanBreed[index];
	
}

- (NSImage *) createRandomGenome:(int)index {
	
	if(genomeCanBreed[index] == NO) {
		
				
		srandom(time(NULL));
		
		NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
		
		[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];
		[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
		[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
		
		[genomes replaceObjectAtIndex:index withObject:[BreedingController createRandomGenomeXMLwithEnvironment:env]];

		return [self makeImageForGenome:index];
		
	} else {
		
		return nil;
	}
	
	
}


- (NSImage *) makeImageForGenome:(int)index {
	
	srandom(time(NULL));
	
	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
	
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
	[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
	
	NSString *pngFileName = [Flam3Task createTemporaryPathWithFileName:@"gpm.png"];
	[pngFileName retain];
	[env setObject:pngFileName forKey:@"out"];
	
	
	
	[Flam3Task runFlam3RenderAsQuietTask:[genomes objectAtIndex:index] withEnvironment:env];
	
	NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:pngFileName]];

	[Flam3Task deleteTemporaryPathAndFile:pngFileName];
	
	[flameImage autorelease];
	[pngFileName release];
	return flameImage;
}	
	
- (void)toggleGenome:(int)index  {
	
	
	genomeCanBreed[index] = genomeCanBreed[index] ? FALSE:TRUE;
	
}

- (void) setGenomeCount:(unsigned int)count {
	
	int i;
	
	if(genomeCanBreed != NULL) {
		free(genomeCanBreed);
	}
	genomeCanBreed = (bool *)malloc(sizeof(bool) * count);
	
	for(i=0; i<count; i++) {		
		genomeCanBreed[i] = NO;
	}
	
	[genomes removeAllObjects];

	for(i=0; i<count; i++) {		
		[genomes addObject:[[NSData alloc] init]];
	}	

	genomeCount = count;
	
} 

- (bool) fill {

	int i, fillCount;

	fillCount = 0;
	
	for(i=0; i<genomeCount; i++) {
		if (genomeCanBreed[i] == NO) {
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
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
	[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
	
	
	for(i=0; i<genomeCount; i++) {
		if (genomeCanBreed[i] == NO) {
			[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Creating new Genome %d", i]];
			[genePoolProgressText displayIfNeeded];
			NSData *newGenome = [BreedingController createRandomGenomeXMLwithEnvironment:env];
			[genomes replaceObjectAtIndex:i withObject:newGenome];
			[genePoolProgress incrementBy:1.0];
			[genePoolProgress displayIfNeeded];

		}
	}
	
	[genePoolProgressWindow setIsVisible:NO];
	return YES;
	
}

- (bool) breed {
	
	unsigned int i;
	unsigned int breedingCount = 0;

	for(i=0; i<genomeCount; i++) {
		
		if(genomeCanBreed[i] == YES) {
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
		
		if(genomeCanBreed[i] == YES) {
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
					index = abs(random() % breedingCount);
					[genePoolProgressText setStringValue:[NSString stringWithFormat:@"Breeding Genome %d with Genome %d", breedingOrder[order[i]], breedingOrder[order[i+1]]]];
					[genePoolProgressText displayIfNeeded];
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
	
	return [genomes objectAtIndex:index];
	
				
}


@end

