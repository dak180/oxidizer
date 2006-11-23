//
//  GebePoolModel.m
//  oxidizer
//
//  Created by David Burnett on 12/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GenePoolModel.h"
#import "BreedingController.h"


@implementation GenePoolModel

- init
{
	
    if (self = [super init]) {

		genomes = NULL;
		genomeCanBreed = NULL;
	
	}
	
	return self;
}


- (bool) canGenomeBreed:(int)index {
	
	return genomeCanBreed[index];
	
}

- (NSImage *) createRandomGenome:(int)index {
	
	if(genomeCanBreed[index] == NO) {
		
		if(genomes[index] != NULL) {
			free(genomes[index]);
		}
		genomes[index] = [BreedingController createRandomCGenome];
//		genomeCanBreed[index] = YES;
		NSImage *flameImage = [self makeImageForGenome:index];
		return flameImage;
		
	} else {
		
		return nil;
	}
	
	
}


- (NSImage *) makeImageForGenome:(int)index {
	
		NSBitmapImageRep *imageRep = [GenePoolModel renderButtomImageRep:genomes[index]];
		NSImage *flameImage = [[NSImage alloc] init];
		[flameImage addRepresentation:imageRep];
		return flameImage;
}	
	
- (void)toggleGenome:(int)index  {
	
	
	genomeCanBreed[index] = genomeCanBreed[index] ? FALSE:TRUE;
	
}

- (void) setGenomeCount:(unsigned int)count {
	
	int i;
	
	if(genomes != NULL) {
		for(i=0; i<genomeCount; i++) {
			free(genomes);				
		}
		free(genomeCanBreed);
	}
	
	genomes        = (flam3_genome **)malloc(sizeof(flam3_genome *) * count);
	
	genomeCanBreed = (bool *)malloc(sizeof(bool) * count);
	
	for(i=0; i<count; i++) {
		
		genomes[i] = NULL;
		genomeCanBreed[i] = NO;
	}
	
	genomeCount = count;
	
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
	
	flam3_genome **newGenomes = (flam3_genome **)malloc(sizeof(flam3_genome *) * genomeCount);
	for(i=0; i<genomeCount; i++) {
		newGenomes[i] = NULL;
	}	
	

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
		case 1:
			while(newGenomeCount < genomeCount) {
				newGenomes[newGenomeCount] = [BreedingController mutateCGenome:genomes[breedingOrder[0]]]; 
				newGenomeCount++;
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
					switch(index) {
						case 1:
							/* interpolate */
							newGenomes[newGenomeCount] = [BreedingController interpolateCGenome:genomes[breedingOrder[order[i]]] withCGenome:genomes[breedingOrder[order[i+1]]]]; 
							break;
						case 2:
							newGenomes[newGenomeCount] = [BreedingController alternateCGenome:genomes[breedingOrder[order[i]]] withCGenome:genomes[breedingOrder[order[i+1]]]]; 
							/* alternate */
							break;
						default:
							newGenomes[newGenomeCount] = [BreedingController unionCGenome:genomes[breedingOrder[order[i]]] withCGenome:genomes[breedingOrder[order[i+1]]]]; 
							
					}
					newGenomeCount++;
				}	
				
				
			}
	}
	
	for(i=0; i<genomeCount; i++) {
		if(genomes[i] != NULL) {
			free(genomes[i]);
		}
		genomes[i] = newGenomes[i];
	}	
	
	free(newGenomes);
	
	return YES;
	
}


- (NSImage *) setCGenome:(flam3_genome *)cGenome forIndex:(int)index {
	
	if(genomes[index] != NULL) {
		free(genomes[index]);
	}

	genomes[index] = cGenome;

	NSImage *flameImage = [self makeImageForGenome:index];
	return flameImage;
				
}

- (flam3_genome *) getCGenomeForIndex:(int)index {
	
	/* return a copy */
	flam3_genome *copy = (flam3_genome *)malloc(sizeof(flam3_genome));
	memset(copy, 0, sizeof(flam3_genome));
	flam3_copy(copy, genomes[index]);
	copy->edits =  xmlCopyDoc(genomes[index]->edits, 1);
	return copy;
				
}


+(NSBitmapImageRep *)renderButtomImageRep:(flam3_genome *)cps {
	
	NSBitmapImageRep *flameRep;
	
	flam3_frame frame;
	
	
	frame.genomes = cps;
	
	frame.time = 0.0;
	frame.temporal_filter_radius = 0.0;
	frame.ngenomes = 1;
	frame.bits = 33;
	frame.verbose = 0;
	frame.genomes = cps;
	frame.pixel_aspect_ratio = 1.0;
	frame.progress = 0;
	
	int realHeight, realWidth;
	double realScale;
	
	double scaleFactor;
	
	
	realHeight = cps->height;
	realWidth = cps->width;
	realScale = cps->pixels_per_unit;
	
	scaleFactor = realHeight > realWidth ? 72.0 / realHeight : 72.0 / realWidth; 
	
	cps->height *= scaleFactor;
	cps->width *= scaleFactor;
	cps->pixels_per_unit *= scaleFactor;
	
	
	flameRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
													  pixelsWide:cps->width
													  pixelsHigh:cps->height
												   bitsPerSample:8
												 samplesPerPixel:3
														hasAlpha:NO 
														isPlanar:NO
												  colorSpaceName:NSDeviceRGBColorSpace
													bitmapFormat:0
													 bytesPerRow:3*cps->width
													bitsPerPixel:8*3];
	
	unsigned char *image =[flameRep bitmapData];
	
	flam3_render(&frame, image, cps->width, flam3_field_both, 3, 0);
	
	cps->height = realHeight;
	cps->width = realWidth;
	cps-> pixels_per_unit = realScale;
	
	return flameRep;
}


@end

