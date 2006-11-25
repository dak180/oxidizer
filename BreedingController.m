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

#import "BreedingController.h"
#import "Genome.h"
#import "flam3_tools.h"
#include "private.h"

@implementation BreedingController

+ (NSManagedObjectContext *) createManagedContext {

		NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
		
		// create persistant store and init with models main bundle 
		
		NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]]; 
		
		[moc setPersistentStoreCoordinator: coordinator];
		[coordinator release];
		
		NSString *STORE_TYPE = NSInMemoryStoreType;
		
		NSError *error;
		id newStore = [coordinator addPersistentStoreWithType:STORE_TYPE
												configuration:nil
														  URL:nil
													  options:nil
														error:&error];
		
		if (newStore == nil) {
			NSLog(@"Store Configuration Failure\n%@",
				  ([error localizedDescription] != nil) ?
				  [error localizedDescription] : @"Unknown Error");
		}

		[moc autorelease];

		return moc;
}

- init {
	 
    if (self = [super init]) {
		
		moc1      = [BreedingController createManagedContext];
		moc2      = [BreedingController createManagedContext];
		mocResult = [BreedingController createManagedContext];
		docController = [NSDocumentController sharedDocumentController];		
    }
	
    return self;
}


- (BOOL)openFile:(NSManagedObjectContext *) moc {

	NSOpenPanel *op;
	flam3_genome *genomes = NULL;
	int runResult;
	BOOL boolResult;
	int genomeCount;

	/* create or get the shared instance of NSSavePanel */
	op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"flam3"];
	
	/* display the NSOpenPanel */
	runResult = [op runModal];
	/* if successful, save file under designated name */
	if(runResult == NSOKButton && [op filename] != nil) {
		[self deleteOldGenomesInContext:moc];
		boolResult = [flameModel loadFlam3File:[op filename] intoCGenomes:&genomes returningCountInto:&genomeCount ];
		if(boolResult == YES) {
			[docController noteNewRecentDocumentURL:[NSURL URLWithString:[op filename]]];
			[flameModel generateAllThumbnailsForGenome:genomes withCount:genomeCount inContext:moc];
			[moc save:nil];

//			[flames setCurrentFlameForIndex:0];
		}
		return boolResult;
	} 
	
	return NO;
}


- (void) deleteOldGenomesInContext:(NSManagedObjectContext *)moc {

	NSArray *genomes;
	int i;
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	[fetch release];	  
	
	if(genomes != nil) {
	
			for(i=0; i<[genomes count]; i++) {
			
				[moc deleteObject:[genomes objectAtIndex:i]];
			
			}			
			[moc save:nil];	
	}

}

- (BOOL) canBreed {
	if([[genome1 selectedObjects] count] != 0 && [[genome1 selectedObjects] count] != 0) {
		return TRUE;
	} else {
		return FALSE;
	}
}

- (BOOL) canMutate {
	if([[genome1 selectedObjects] count] != 0 || [[genome1 selectedObjects] count] != 0){
		return TRUE;
	} else {
		return FALSE;
	}
}


- (IBAction)loadNewGenomeIntoMoc1:(id)sender {

	 NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	 switch([segments selectedSegment]) {
		case 0:
			[self openFile:moc1];
			break;
		case 1:
			[flameModel createRandomGenomeInContext:moc1];
			break;
		case 2:
			[genome1 remove:self];
			break;
	}
}

- (IBAction)loadNewGenomeIntoMoc2:(id)sender {
	 NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	 switch([segments selectedSegment]) {
		case 0:
			[self openFile:moc2];
			break;
		case 1:
			[flameModel createRandomGenomeInContext:moc2];
			break;
		case 2:
			[genome2 remove:self];
			break;
	}
}

- (IBAction)showBreedingWindow:(id)sender {
	[breedingWindow makeKeyAndOrderFront:self];
}

- (IBAction)alternate:(id)sender {

	flam3_genome selp0, selp1, *cp_save;
	
	
	memset(&selp0, 0, sizeof(flam3_genome));
	memset(&selp1, 0, sizeof(flam3_genome));

	[Genome populateCGenome:&selp0 FromEntity:[[genome1 selectedObjects] objectAtIndex:0] fromContext:moc1]; 	
	[Genome populateCGenome:&selp1 FromEntity:[[genome2 selectedObjects] objectAtIndex:0] fromContext:moc2]; 	
              
	cp_save = [BreedingController alternateCGenome:&selp0 withCGenome:&selp1];
	
	[self deleteOldGenomesInContext:mocResult];
	[flameModel generateAllThumbnailsForGenome:cp_save withCount:1 inContext:mocResult];
	
	[mocResult save:nil];
	
}


- (IBAction)interpolate:(id)sender {
	
	flam3_genome selp0, selp1;
	flam3_genome *cp_save;

	
	memset(&selp0, 0, sizeof(flam3_genome));
	memset(&selp1, 0, sizeof(flam3_genome));

	[Genome populateCGenome:&selp0 FromEntity:[[genome1 selectedObjects] objectAtIndex:0] fromContext:moc1]; 	
	[Genome populateCGenome:&selp1 FromEntity:[[genome2 selectedObjects] objectAtIndex:0] fromContext:moc2]; 	

	cp_save = [BreedingController interpolateCGenome:&selp0 withCGenome:&selp1];

		
	[self deleteOldGenomesInContext:mocResult];
	[flameModel generateAllThumbnailsForGenome:cp_save withCount:1 inContext:mocResult];
	[mocResult save:nil];
	
}

- (IBAction)doUnion:(id)sender {
	
	flam3_genome selp0, selp1;
	flam3_genome *cp_save;
	
	
	memset(&selp0, 0, sizeof(flam3_genome));
	memset(&selp1, 0, sizeof(flam3_genome));
	
	[Genome populateCGenome:&selp0 FromEntity:[[genome1 selectedObjects] objectAtIndex:0] fromContext:moc1]; 	
	[Genome populateCGenome:&selp1 FromEntity:[[genome2 selectedObjects] objectAtIndex:0] fromContext:moc2]; 	
	
	cp_save = [BreedingController unionCGenome:&selp0 withCGenome:&selp1];
	
	
	[self deleteOldGenomesInContext:mocResult];
	[flameModel generateAllThumbnailsForGenome:cp_save withCount:1 inContext:mocResult];
	[mocResult save:nil];
	
}


- (IBAction)mutate:(id)sender {

	flam3_genome selp0, selp1;
	flam3_genome *cp_save;
	
	
	memset(&selp0, 0, sizeof(flam3_genome));
	memset(&selp1, 0, sizeof(flam3_genome));
	
	[Genome populateCGenome:&selp0 FromEntity:[[genome1 selectedObjects] objectAtIndex:0] fromContext:moc1]; 	
	
	cp_save = [BreedingController mutateCGenome:&selp0];
	
	
	[self deleteOldGenomesInContext:mocResult];
	[flameModel generateAllThumbnailsForGenome:cp_save withCount:1 inContext:mocResult];
	[mocResult save:nil];

}

- (IBAction)clone:(id)sender {
}

- (IBAction)sendResultToEditor:(id)sender {

	flam3_genome *newGenome = (flam3_genome *)malloc(sizeof(flam3_genome));
	
	[Genome populateCGenome:newGenome FromEntity:[[genomeResult arrangedObjects] objectAtIndex:0] fromContext:mocResult];

	[self deleteOldGenomesInContext:[flameModel getNSManagedObjectContext]];
	[flameModel generateAllThumbnailsForGenome:newGenome withCount:1 inContext:[flameModel getNSManagedObjectContext]];

}

+ (flam3_genome *)alternateCGenome:(flam3_genome *)selp0 withCGenome:(flam3_genome *)selp1 {
	
	flam3_frame f;
	flam3_genome cp_orig;
	flam3_genome *cp_save;
	
	int count = 0;
	int ntries = 10;
	int debug = 0;
	int i;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;
	
	char action[4096];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;
	
	
	cp_save = (flam3_genome *)calloc(1, sizeof(flam3_genome));
	memset(&cp_orig, 0, sizeof(flam3_genome));
	
	srandom(time(NULL) + getpid());
	
	f.temporal_filter_radius = 0.0;
	f.bits = 33;
	f.verbose = 0;
	f.genomes = &cp_orig;
	f.ngenomes = 1;
	f.pixel_aspect_ratio = 1.0;
	f.progress = 0;
	test_cp(&cp_orig);  // just for the width & height
	image = (unsigned char *) malloc(3 * cp_orig.width * cp_orig.height);
	
	
	int did_color;
	
	count = 0;
	
	do {
		did_color = 0;
		f.time = (double) 0.0;
		
		int rb, used_parent;
		char ministr[10];
		char trystr[1000];
		
		sprintf(action,"cross alernate");
		
		int got0, got1;
		/* each xform from a random parent,
			possible for one to be excluded */
		do {
			trystr[0] = 0;
			got0 = got1 = 0;
			rb = flam3_random_bit();
			sprintf(ministr," %d:",rb);
			strcat(trystr,ministr);
			
			/* Copy the parent, sorting the final xform to the end if it's present. */
			if (rb) 
				flam3_copyx(&cp_orig, selp1,
							selp1->num_xforms - (selp1->final_xform_index > 0),
							selp1->final_xform_enable);
			else
				flam3_copyx(&cp_orig, selp0,
							selp0->num_xforms - (selp0->final_xform_index > 0),
							selp0->final_xform_enable);
			
			used_parent = rb;
			
			/* Only replace non-final xforms */
			
			for (i = 0; i < cp_orig.num_xforms - cp_orig.final_xform_enable; i++) {
				rb = flam3_random_bit();
				
				/* Replace xform if bit is 1 */
				if (rb==1) {
					if (used_parent==0) {
						if (i < selp1->num_xforms && selp1->xform[i].density > 0) {
							cp_orig.xform[i] = selp1->xform[i];
							sprintf(ministr," 1");
							got1 = 1;
						} else {
							sprintf(ministr," 0");
							got0 = 1;
						}
					} else {
						if (i < selp0->num_xforms && selp0->xform[i].density > 0) {
							cp_orig.xform[i] = selp0->xform[i];
							sprintf(ministr," 0");
							got0 = 1;
						} else {
							sprintf(ministr," 1");
							got1 = 1;
						}
					}
				} else {
					sprintf(ministr," %d",used_parent);
					if (used_parent)
						got1 = 1;
					else
						got0 = 1;
				}
				strcat(trystr,ministr);
			}
		} while ((i > 1) && !(got0 && got1));
		strcat(action, trystr);
		
		
		
		/* find the last xform */
		/*               nxf = 0;
		for (i = 0; i < cp_orig.num_xforms; i++) {
			if (cp_orig.xform[i].density > 0.0) {
				nxf = i;
			}
		}
		*/
		/* reset color coords */
		if (cp_orig.num_xforms > 0) {
			for (i = 0; i < cp_orig.num_xforms; i++) {
				cp_orig.xform[i].color[0] = i&1;
				cp_orig.xform[i].color[1] = (i&2)>>1;
			}
		}
		
		
		
		truncate_variations(&cp_orig, 5, action);
		cp_orig.edits = create_new_editdoc(action, selp0, selp1);
		flam3_copy(cp_save, &cp_orig);
		test_cp(&cp_orig);
		flam3_render(&f, image, cp_orig.width, flam3_field_both, 3, 0);
        
		if (1) {
			int n, tot, totb, totw;
			n = 3 * cp_orig.width * cp_orig.height;
			tot = 0;
			totb = 0;
			totw = 0;
			for (i = 0; i < n; i++) {
				tot += image[i];
				if (0 == image[i]) totb++;
				if (255 == image[i]) totw++;
				
				// printf("%d ", image[i]);
			}
			
			avg_pix = (tot / (double)n);
			fraction_black = totb / (double)n;
			fraction_white = totw / (double)n;
			
			if (debug)
				fprintf(stderr,
						"avg_pix=%g fraction_black=%g fraction_white=%g n=%g\n",
						avg_pix, fraction_black, fraction_white, (double)n);
			
		} else {
			avg_pix = avg_thresh + 1.0;
			fraction_black = black_thresh + 1.0;
			fraction_white = white_limit - 1.0;
		}
		
		count++;
	} while ((avg_pix < avg_thresh ||
			  fraction_black < black_thresh ||
			  fraction_white > white_limit) &&
			 count < ntries);
	
	if (ntries == count) {
		fprintf(stderr, "warning: reached maximum attempts, giving up.\n");
	}
	
	if (!did_color && random()&1) {
		improve_colors(&cp_orig, 100, 0, 10);
		strcat(action," improved colors");
	}
	
	
	cp_save->time = 0;

	/* Free created documents */
	/* (Only free once, since the copy is a ptr to the original) */
	//	xmlFreeDoc(cp_save.edits);
	return cp_save;
	
}

+ (flam3_genome *)interpolateCGenome:(flam3_genome *)selp0 withCGenome:(flam3_genome *)selp1  {
	
	flam3_frame f;
	flam3_genome *cp_orig;
	flam3_genome *cp_save;
	
	int count = 0;
	int ntries = 10;
	int debug = 0;
	int i;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;
	
	char action[4096];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;
	
	cp_save = (flam3_genome *)malloc(sizeof(flam3_genome));
	cp_orig = (flam3_genome *)malloc(sizeof(flam3_genome));
	
	memset(cp_save, 0, sizeof(flam3_genome));
	memset(cp_orig, 0, sizeof(flam3_genome));
	
	srandom(time(NULL) + getpid());
	
	f.temporal_filter_radius = 0.0;
	f.bits = 33;
	f.verbose = 0;
	f.genomes = cp_orig;
	f.ngenomes = 1;
	f.pixel_aspect_ratio = 1.0;
	f.progress = 0;
	test_cp(cp_orig);  // just for the width & height
	image = (unsigned char *) malloc(3 * cp_orig->width * cp_orig->height);
	
	
	int did_color;
	
	count = 0;
	
	do {
		did_color = 0;
		f.time = (double) 0.0;
		
		int rb;
		char ministr[11];
		flam3_genome parents[2];
		double t = flam3_random01();
		
		sprintf(action,"cross interpolate");
		
		/* linearly interpolate somewhere between the two */
		
		memset(parents, 0, 2*sizeof(flam3_genome));
		
		flam3_copy(parents, selp0);
		flam3_copy(parents+1, selp1);	
		
//		sprintf(ministr," %g",t);
//		strcat(action,ministr);
		
		parents[0].time = 0.0;
		parents[1].time = 1.0;
		flam3_interpolate(parents, 2, t, cp_orig);
		
		/* except pick a simple palette */
		rb = flam3_random_bit();
//		sprintf(ministr," %d",rb);
//		strcat(action,ministr);
		cp_orig->palette_index = rb ? parents->palette_index : parents[1].palette_index;
		
		free(parents[0].xform);
		free(parents[1].xform);
		
		
		
		/* reset color coords */
		if (cp_orig->num_xforms > 0) {
			for (i = 0; i < cp_orig->num_xforms; i++) {
				cp_orig->xform[i].color[0] = i&1;
				cp_orig->xform[i].color[1] = (i&2)>>1;
			}
		}
		
		truncate_variations(cp_orig, 5, action);
		cp_orig->edits = create_new_editdoc(action, parents, parents+1);
		flam3_copy(cp_save, cp_orig);
		test_cp(cp_orig);
		flam3_render(&f, image, cp_orig->width, flam3_field_both, 3, 0);
        
		int n, tot, totb, totw;
		n = 3 * cp_orig->width * cp_orig->height;
		tot = 0;
		totb = 0;
		totw = 0;
		for (i = 0; i < n; i++) {
			tot += image[i];
			if (0 == image[i]) totb++;
			if (255 == image[i]) totw++;
			
			// printf("%d ", image[i]);
		}
		
		avg_pix = (tot / (double)n);
		fraction_black = totb / (double)n;
		fraction_white = totw / (double)n;
		
		if (debug)
			fprintf(stderr,
					"avg_pix=%g fraction_black=%g fraction_white=%g n=%g\n",
					avg_pix, fraction_black, fraction_white, (double)n);
		
		count++;
	} while ((avg_pix < avg_thresh ||
			  fraction_black < black_thresh ||
			  fraction_white > white_limit) &&
			 count < ntries);
	
	if (ntries == count) {
		fprintf(stderr, "warning: reached maximum attempts, giving up.\n");
	}
	
	if (!did_color && random()&1) {
		improve_colors(cp_orig, 100, 0, 10);
		strcat(action," improved colors");
	}
	
	
	cp_save->time = 0;

	return cp_save;
	
}

+ (flam3_genome *)unionCGenome:(flam3_genome *)selp0 withCGenome:(flam3_genome *)selp1 {
	
	
	flam3_frame f;
	flam3_genome cp_orig;
	flam3_genome *cp_save;
	flam3_genome *aselp0, *aselp1;
	
	int count = 0;
	int ntries = 10;
	int debug = 0;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;
	
	char action[4096];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;
	
	cp_save = (flam3_genome *)malloc(sizeof(flam3_genome));
	
	memset(cp_save, 0, sizeof(flam3_genome));
	memset(&cp_orig, 0, sizeof(flam3_genome));
	
	srandom(time(NULL) + getpid());
	
	f.temporal_filter_radius = 0.0;
	f.bits = 33;
	f.verbose = 0;
	f.genomes = &cp_orig;
	f.ngenomes = 1;
	f.pixel_aspect_ratio = 1.0;
	f.progress = 0;
	test_cp(&cp_orig);  // just for the width & height
	image = (unsigned char *) malloc(3 * cp_orig.width * cp_orig.height);
	
	
	int did_color;
	
	do {
		did_color = 0;
		f.time = (double) 0.0;
		
		
		
		sprintf(action,"cross union");
		
		aselp0 = selp0;
		aselp1 = selp1;
		
		/* union */
		flam3_copy(&cp_orig, selp0);
		
		int j, i = 0;
		for (j = 0; j < selp1->num_xforms; j++) {
			/* Skip over the final xform, if it's present.    */
			/* Default behavior keeps the final from parent0. */
			if (selp1->final_xform_index == j)
				continue;
			flam3_add_xforms(&cp_orig, 1);
			cp_orig.xform[cp_orig.num_xforms-1] = selp1->xform[j];
		}
		
		
		/* reset color coords */
		if (cp_orig.num_xforms > 0) {
			for (i = 0; i < cp_orig.num_xforms; i++) {
				cp_orig.xform[i].color[0] = i&1;
				cp_orig.xform[i].color[1] = (i&2)>>1;
			}
		}
		
		
		truncate_variations(&cp_orig, 5, action);
		cp_orig.edits = create_new_editdoc(action, aselp0, aselp1);
		flam3_copy(cp_save, &cp_orig);
		test_cp(&cp_orig);
		flam3_render(&f, image, cp_orig.width, flam3_field_both, 3, 0);
        
		int n, tot, totb, totw;
		n = 3 * cp_orig.width * cp_orig.height;
		tot = 0;
		totb = 0;
		totw = 0;
		for (i = 0; i < n; i++) {
			tot += image[i];
			if (0 == image[i]) totb++;
			if (255 == image[i]) totw++;
			
			// printf("%d ", image[i]);
		}
		
		avg_pix = (tot / (double)n);
		fraction_black = totb / (double)n;
		fraction_white = totw / (double)n;
		
		if (debug)
			fprintf(stderr,
					"avg_pix=%g fraction_black=%g fraction_white=%g n=%g\n",
					avg_pix, fraction_black, fraction_white, (double)n);
		
		count++;
	} while ((avg_pix < avg_thresh ||
			  fraction_black < black_thresh ||
			  fraction_white > white_limit) &&
			 count < ntries);
	
	if (ntries == count) {
		fprintf(stderr, "warning: reached maximum attempts, giving up.\n");
	}
	
	if (!did_color && random()&1) {
		if (debug)
			fprintf(stderr,"improving colors...\n");
		improve_colors(cp_save, 100, 0, 10);
		strcat(action," improved colors");
	}
	
    
	cp_save->time = 0;
	
	return cp_save;
	
}

+ (flam3_genome *)mutateCGenome:(flam3_genome *)selp0 {
	
	flam3_frame f;
	flam3_genome cp_orig;
	flam3_genome *cp_save;
    flam3_genome *aselp0, *aselp1;
	
	int count = 0;
	int ntries = 10;
	int debug = 0;
	int i, j;
	int verbose = 0;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;
	double speed = 0.1;
	
	char action[4096];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;
	int ivars[max_specified_vars];
	int num_ivars = 0;
	int sym = 0;
	
	
	ivars[0] = -1;
	num_ivars = 1;
	srandom(time(NULL) + getpid());
	
	cp_save = (flam3_genome *)calloc(1, sizeof(flam3_genome));
	
	f.temporal_filter_radius = 0.0;
	f.bits = 33;
	f.verbose = 0;
	f.genomes = &cp_orig;
	f.ngenomes = 1;
	f.pixel_aspect_ratio = 1.0;
	f.progress = 0;
	test_cp(&cp_orig);  // just for the width & height
	image = (unsigned char *) malloc(3 * cp_orig.width * cp_orig.height);
	
	memset(&cp_orig, 0, sizeof(flam3_genome));
	
	int did_color;
	
	do {
		did_color = 0;
		f.time = (double) 0.0;
		
		
		flam3_genome mutation;
		double r = flam3_random01();
		
		memset(&mutation, 0, sizeof(flam3_genome));
		
		flam3_copy(&cp_orig, selp0);
		aselp0 = selp0;
		aselp1 = NULL;
		
		if (r < 0.1) {
			int done = 0;
			if (debug) fprintf(stderr, "mutating variation\n");
			sprintf(action,"mutate variation");
			// randomize the variations, usually a large visual effect
			do {
				/* Create a random flame, and use the variations */
				/* to replace those in the original              */
				flam3_random(&mutation, ivars, num_ivars, sym, cp_orig.num_xforms);
				for (i = 0; i < cp_orig.num_xforms; i++) {
					
					/* Replace if density > 0 or this is the final xform */
					/*if (cp_orig.xform[i].density > 0.0 || (cp_orig.final_xform_enable==1 && cp_orig.final_xform_index==i)) {*/
					for (j = 0; j < flam3_nvariations; j++) {
						if (cp_orig.xform[i].var[j] != mutation.xform[i].var[j]) {
							cp_orig.xform[i].var[j] = mutation.xform[i].var[j];
							
							/* We only want to copy param var coefs for this one */                                
							if (j==23) {
								/* Blob */
								cp_orig.xform[i].blob_low = mutation.xform[i].blob_low;
								cp_orig.xform[i].blob_high = mutation.xform[i].blob_high;
								cp_orig.xform[i].blob_waves = mutation.xform[i].blob_waves;
							} else if (j==24) {
								/* PDJ */
								cp_orig.xform[i].pdj_a = mutation.xform[i].pdj_a;
								cp_orig.xform[i].pdj_b = mutation.xform[i].pdj_b;
								cp_orig.xform[i].pdj_c = mutation.xform[i].pdj_c;
								cp_orig.xform[i].pdj_d = mutation.xform[i].pdj_d;
							} else if (j==25) {
								/* Fan2 */
								cp_orig.xform[i].fan2_x = mutation.xform[i].fan2_x;
								cp_orig.xform[i].fan2_y = mutation.xform[i].fan2_y;
							} else if (j==26) {
								/* Rings2 */
								cp_orig.xform[i].rings2_val = mutation.xform[i].rings2_val;
							} else if (j==30) {
								/* Perspective */
								cp_orig.xform[i].perspective_angle = mutation.xform[i].perspective_angle;
								cp_orig.xform[i].perspective_dist = mutation.xform[i].perspective_dist;
								cp_orig.xform[i].persp_vsin = mutation.xform[i].persp_vsin;
								cp_orig.xform[i].persp_vfcos = mutation.xform[i].persp_vfcos;
							} else if (j==32) {
								/* Julia_N */
								cp_orig.xform[i].juliaN_power = mutation.xform[i].juliaN_power;
								cp_orig.xform[i].juliaN_dist = mutation.xform[i].juliaN_dist;
								cp_orig.xform[i].juliaN_rN = mutation.xform[i].juliaN_rN;
								cp_orig.xform[i].juliaN_cn = mutation.xform[i].juliaN_cn;
							} else if (j==33) {
								/* Julia_Scope */
								cp_orig.xform[i].juliaScope_power = mutation.xform[i].juliaScope_power;
								cp_orig.xform[i].juliaScope_dist = mutation.xform[i].juliaScope_dist;
								cp_orig.xform[i].juliaScope_rN = mutation.xform[i].juliaScope_rN;
								cp_orig.xform[i].juliaScope_cn = mutation.xform[i].juliaScope_cn;
							}  else if (j==36) {
								/* Radial Blur */
								cp_orig.xform[i].radialBlur_angle = mutation.xform[i].radialBlur_angle;
								
							} else if (j==37) {
								/* Pie */
								cp_orig.xform[i].pie_slices = mutation.xform[i].pie_slices;
								cp_orig.xform[i].pie_rotation = mutation.xform[i].pie_rotation;
								cp_orig.xform[i].pie_thickness = mutation.xform[i].pie_thickness;
							} else if (j==38) {
								/* Ngon */
								cp_orig.xform[i].ngon_sides = mutation.xform[i].ngon_sides;
								cp_orig.xform[i].ngon_power = mutation.xform[i].ngon_power;
								cp_orig.xform[i].ngon_corners = mutation.xform[i].ngon_corners;
								cp_orig.xform[i].ngon_circle = mutation.xform[i].ngon_circle;
							}
							
							done = 1;
						}
					}
					/*}*/
				}
			} while (!done);
		} else if (r < 0.3) {
			// change one xform coefs but not the vars
			int xf, nxf = 0;
			if (debug) fprintf(stderr, "mutating one xform\n");
			sprintf(action,"mutate xform");
			flam3_random(&mutation, ivars, num_ivars, sym, 2);
			/*for (i = 0; i < cp_orig.num_xforms; i++) {
				if (cp_orig.xform[i].density > 0.0) {
					nxf++;
				}
			}*/
			
			nxf = cp_orig.num_xforms;
			
			if (0 == nxf) {
				fprintf(stderr, "no xforms in control point.\n");
				exit(1);
			}
			xf = random()%nxf;
			
			// if only two xforms, then change only the translation part
			if (2 == nxf) {
				for (j = 0; j < 2; j++)
					cp_orig.xform[xf].c[2][j] = mutation.xform[0].c[2][j];
			} else {
				for (i = 0; i < 3; i++)
					for (j = 0; j < 2; j++)
                        cp_orig.xform[xf].c[i][j] = mutation.xform[0].c[i][j];
			}
		} else if (r < 0.5) {
			if (debug) fprintf(stderr, "adding symmetry\n");
			sprintf(action,"mutate symmetry");
			flam3_add_symmetry(&cp_orig, 0);
		} else if (r < 0.6) {
			int b = 1 + random()%6;
			int same = random()&3;
			if (debug) fprintf(stderr, "setting post xform\n");
			sprintf(action,"mutate post");
			for (i = 0; i < cp_orig.num_xforms; i++) {
				int copy = (i > 0) && same;
				/*                     if (cp_orig.xform[i].density == 0.0) continue;*/
				if (copy) {
					for (j = 0; j < 3; j++) {
						cp_orig.xform[i].post[j][0] = cp_orig.xform[0].post[j][0];
						cp_orig.xform[i].post[j][1] = cp_orig.xform[0].post[j][1];
					}
				} else {
					if (b&1) {
						double f = M_PI * flam3_random11();
						double t[2][2];
						t[0][0] = (cp_orig.xform[i].c[0][0] * cos(f) +
								   cp_orig.xform[i].c[0][1] * -sin(f));
						t[0][1] = (cp_orig.xform[i].c[0][0] * sin(f) +
								   cp_orig.xform[i].c[0][1] * cos(f));
						t[1][0] = (cp_orig.xform[i].c[1][0] * cos(f) +
								   cp_orig.xform[i].c[1][1] * -sin(f));
						t[1][1] = (cp_orig.xform[i].c[1][0] * sin(f) +
								   cp_orig.xform[i].c[1][1] * cos(f));
						
						cp_orig.xform[i].c[0][0] = t[0][0];
						cp_orig.xform[i].c[0][1] = t[0][1];
						cp_orig.xform[i].c[1][0] = t[1][0];
						cp_orig.xform[i].c[1][1] = t[1][1];
						
						f *= -1.0;
						
						t[0][0] = (cp_orig.xform[i].post[0][0] * cos(f) +
								   cp_orig.xform[i].post[0][1] * -sin(f));
						t[0][1] = (cp_orig.xform[i].post[0][0] * sin(f) +
								   cp_orig.xform[i].post[0][1] * cos(f));
						t[1][0] = (cp_orig.xform[i].post[1][0] * cos(f) +
								   cp_orig.xform[i].post[1][1] * -sin(f));
						t[1][1] = (cp_orig.xform[i].post[1][0] * sin(f) +
								   cp_orig.xform[i].post[1][1] * cos(f));
						
						cp_orig.xform[i].post[0][0] = t[0][0];
						cp_orig.xform[i].post[0][1] = t[0][1];
						cp_orig.xform[i].post[1][0] = t[1][0];
						cp_orig.xform[i].post[1][1] = t[1][1];
						
					}
					if (b&2) {
						double f = 0.2 + flam3_random01();
						double g;
						if (random()&1) f = 1.0 / f;
						if (random()&1) {
							g = 0.2 + flam3_random01();
							if (random()&1) g = 1.0 / g;
						} else
							g = f;
						cp_orig.xform[i].c[0][0] /= f;
						cp_orig.xform[i].c[0][1] /= f;
						cp_orig.xform[i].c[1][1] /= g;
						cp_orig.xform[i].c[1][0] /= g;
						cp_orig.xform[i].post[0][0] *= f;
						cp_orig.xform[i].post[1][0] *= f;
						cp_orig.xform[i].post[0][1] *= g;
						cp_orig.xform[i].post[1][1] *= g;
					}
					if (b&4) {
						double f = flam3_random11();
						double g = flam3_random11();
						cp_orig.xform[i].c[2][0] -= f;
						cp_orig.xform[i].c[2][1] -= g;
						cp_orig.xform[i].post[2][0] += f;
						cp_orig.xform[i].post[2][1] += g;
					}
				}
			}
		} else if (r < 0.7) {
			double s = flam3_random01();
			did_color = 1;
			// change just the color
			if (debug) fprintf(stderr, "mutating color\n");
			if (s < 0.4) {
				improve_colors(&cp_orig, 100, 0, 10);
				sprintf(action,"mutate color coords");
			} else if (s < 0.8) {
				improve_colors(&cp_orig, 25, 1, 10);
				sprintf(action,"mutate color all");
			} else {
				cp_orig.palette_index = flam3_get_palette(flam3_palette_random, cp_orig.palette, cp_orig.hue_rotation);
				sprintf(action,"mutate color palette");
			}
		} else if (r < 0.8) {
			int nx = 0;
			
			if (debug) fprintf(stderr, "deleting an xform\n");
			sprintf(action,"mutate delete");
			/*                  for (i = 0; i < cp_orig.num_xforms; i++) {
				if (cp_orig.xform[i].density > 0.0)
				nx++;
			}*/
			
			nx = cp_orig.num_xforms;
			
			if (nx > 1) {
				
				nx = random()%nx;
				flam3_delete_xform(&cp_orig,nx);
				
				/*                  if (nx > 1) {
					nx = random()%nx;
				for (i = 0; i < cp_orig.num_xforms; i++) {
					if (nx == ny) {
						cp_orig.xform[i].density = 0;
						break;
					}
					if (cp_orig.xform[i].density > 0.0)
						ny++;
				}*/
				} else {
					if (verbose)
                        fprintf(stderr, "not enough xforms to delete one.\n");
				}
			} else {
				int x;
				if (debug) fprintf(stderr, "mutating all coefs\n");
				sprintf(action,"mutate all");
				flam3_random(&mutation, ivars, num_ivars, sym, cp_orig.num_xforms);
				
				// change all the coefs by a little bit
				for (x = 0; x < cp_orig.num_xforms; x++) {
					/*                     if (cp_orig.xform[x].density > 0.0) {*/
					for (i = 0; i < 3; i++) {
						for (j = 0; j < 2; j++) {
							cp_orig.xform[x].c[i][j] += speed * mutation.xform[x].c[i][j];
							/* Eventually, we can mutate the parametric variation coefs here. */
						}
					}
					/*                     }*/
				}
			}
		
		if (random()&1) {
			double bmin[2], bmax[2];
			flam3_estimate_bounding_box(&cp_orig, 0.001, 100000, bmin, bmax);
			cp_orig.center[0] = (bmin[0] + bmax[0]) / 2.0;
			cp_orig.center[1] = (bmin[1] + bmax[1]) / 2.0;
			cp_orig.pixels_per_unit = cp_orig.width / (bmax[0] - bmin[0]);
			strcat(action," reframed");
		}	       
		
		
		truncate_variations(&cp_orig, 5, action);
		cp_orig.edits = create_new_editdoc(action, aselp0, aselp1);
		flam3_copy(cp_save, &cp_orig);
		test_cp(&cp_orig);
		flam3_render(&f, image, cp_orig.width, flam3_field_both, 3, 0);
        
		if (1) {
			int n, tot, totb, totw;
			n = 3 * cp_orig.width * cp_orig.height;
			tot = 0;
			totb = 0;
			totw = 0;
			for (i = 0; i < n; i++) {
				tot += image[i];
				if (0 == image[i]) totb++;
				if (255 == image[i]) totw++;
				
				// printf("%d ", image[i]);
			}
			
			avg_pix = (tot / (double)n);
			fraction_black = totb / (double)n;
			fraction_white = totw / (double)n;
			
			if (debug)
				fprintf(stderr,
						"avg_pix=%g fraction_black=%g fraction_white=%g n=%g\n",
						avg_pix, fraction_black, fraction_white, (double)n);
			
		} else {
			avg_pix = avg_thresh + 1.0;
			fraction_black = black_thresh + 1.0;
			fraction_white = white_limit - 1.0;
		}
		
		count++;
		
		} while ((avg_pix < avg_thresh ||
				  fraction_black < black_thresh ||
				  fraction_white > white_limit) &&
				 count < ntries);
	
	if (ntries == count) {
		fprintf(stderr, "warning: reached maximum attempts, giving up.\n");
	}
	
	if (!did_color && random()&1) {
		if (debug)
			fprintf(stderr,"improving colors...\n");
		improve_colors(&cp_orig, 100, 0, 10);
		strcat(action," improved colors");
	}
	
	cp_save->time = 0;
	
	return cp_save;
	
}
+ (flam3_genome *)createRandomCGenome {
	
	flam3_genome cp_orig, *cp_save;
	
	int sym = 0;
	
	int ivars[flam3_nvariations];
	int num_ivars = 0;
	int i;
	int count = 0;
	int ntries = 10;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;
	
	flam3_frame f;
	char action[4096];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;
	
	
	cp_save = (flam3_genome *)malloc(sizeof(flam3_genome));
	memset(&cp_orig, 0, sizeof(flam3_genome));
	memset(cp_save, 0, sizeof(flam3_genome));
	
	test_cp(&cp_orig);  // just for the width & height
	image = (unsigned char *) malloc(3 * cp_orig.width * cp_orig.height);
	
	
	srandom(time(NULL) + getpid());
	
	f.temporal_filter_radius = 0.0;
	f.bits = 33;
	f.verbose = 0;
	f.genomes = &cp_orig;
	f.ngenomes = 1;
	f.pixel_aspect_ratio = 1.0;
	f.progress = 0;
	test_cp(&cp_orig);  // just for the width & height
	image = (unsigned char *) malloc(3 * cp_orig.width * cp_orig.height);
	
	/* Set first var to -1 for totally random */
	ivars[0] = -1;
	num_ivars = 1;
	
	f.time = (double) 0.0;
	
	do {
		sprintf(action,"random");
		flam3_random(&cp_orig, ivars, num_ivars, sym, 0);
		
		cp_orig.spatial_filter_func = Gaussian_filter;
		cp_orig.spatial_filter_support = Gaussian_support;
		
		double bmin[2], bmax[2];
		flam3_estimate_bounding_box(&cp_orig, 0.001, 100000, bmin, bmax);
		cp_orig.center[0] = (bmin[0] + bmax[0]) / 2.0;
		cp_orig.center[1] = (bmin[1] + bmax[1]) / 2.0;
		cp_orig.pixels_per_unit = cp_orig.width / (bmax[0] - bmin[0]);
		strcat(action," reframed");
		
		
		truncate_variations(&cp_orig, 5, action);
		cp_orig.edits = create_new_editdoc(action, NULL, NULL);
		flam3_copy(cp_save, &cp_orig);
		test_cp(&cp_orig);
		flam3_render(&f, image, cp_orig.width, flam3_field_both, 3, 0);
		
		int n, tot, totb, totw;
		n = 3 * cp_orig.width * cp_orig.height;
		tot = 0;
		totb = 0;
		totw = 0;
		for (i = 0; i < n; i++) {
			tot += image[i];
			if (0 == image[i]) totb++;
			if (255 == image[i]) totw++;
			
			// printf("%d ", image[i]);
		}
		
		avg_pix = (tot / (double)n);
		fraction_black = totb / (double)n;
		fraction_white = totw / (double)n;
		count++;
	} while ((avg_pix < avg_thresh ||
			  fraction_black < black_thresh ||
			  fraction_white > white_limit) &&
			 count < ntries);
	
	return cp_save;
}


@end

