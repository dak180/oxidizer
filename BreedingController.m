#import "BreedingController.h"
#import "Genome.h"
#import "flam3_tools.h"

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

	flam3_frame f;
	flam3_genome cp_orig;
	flam3_genome cp_save;
	flam3_genome selp0, selp1;
	
	int seed;
	int count = 0;
	int ntries = 10;
	int debug = 0;
	int i;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;
	
	char action[1024];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;
	
	
	memset(&cp_save, 0, sizeof(flam3_genome));
	memset(&cp_orig, 0, sizeof(flam3_genome));
	memset(&selp0, 0, sizeof(flam3_genome));
	memset(&selp1, 0, sizeof(flam3_genome));
	
	
	srandom(seed ? seed : (time(0) + getpid()));
	
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
			[Genome populateCGenome:&selp0 FromEntity:[[genome1 selectedObjects] objectAtIndex:0] fromContext:moc1]; 	
			[Genome populateCGenome:&selp1 FromEntity:[[genome2 selectedObjects] objectAtIndex:0] fromContext:moc2]; 	
              
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
			   flam3_copyx(&cp_orig, &selp1,
				       selp1.num_xforms - (selp1.final_xform_index > 0),
				       selp1.final_xform_enable);
		       else
			   flam3_copyx(&cp_orig, &selp0,
				       selp0.num_xforms - (selp0.final_xform_index > 0),
				       selp0.final_xform_enable);
                  
		       used_parent = rb;
                  
		       /* Only replace non-final xforms */
		      
		       for (i = 0; i < cp_orig.num_xforms - cp_orig.final_xform_enable; i++) {
			   rb = flam3_random_bit();
                     
			   /* Replace xform if bit is 1 */
			   if (rb==1) {
			       if (used_parent==0) {
				   if (i < selp1.num_xforms && selp1.xform[i].density > 0) {
				       cp_orig.xform[i] = selp1.xform[i];
				       sprintf(ministr," 1");
				       got1 = 1;
				   } else {
				       sprintf(ministr," 0");
				       got0 = 1;
				   }
			       } else {
				   if (i < selp0.num_xforms && selp0.xform[i].density > 0) {
				       cp_orig.xform[i] = selp0.xform[i];
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
            cp_orig.edits = create_new_editdoc(action, &selp0, &selp1);
            flam3_copy(&cp_save, &cp_orig);
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
	
	
	cp_save.time = 0;
	[self deleteOldGenomesInContext:mocResult];
	[flameModel generateAllThumbnailsForGenome:&cp_save withCount:1 inContext:mocResult];
	[mocResult save:nil];
	
	/* Free created documents */
	/* (Only free once, since the copy is a ptr to the original) */
	xmlFreeDoc(cp_save.edits);
				   

}

- (IBAction)interpolate:(id)sender {
	
	flam3_frame f;
	flam3_genome *cp_orig;
	flam3_genome *cp_save;
	flam3_genome selp0, selp1;
	
	int seed;
	int count = 0;
	int ntries = 10;
	int debug = 0;
	int i;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;
	
	char action[1024];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;
	
	cp_save = (flam3_genome *)malloc(sizeof(flam3_genome));
	cp_orig = (flam3_genome *)malloc(sizeof(flam3_genome));
	
	memset(cp_save, 0, sizeof(flam3_genome));
	memset(cp_orig, 0, sizeof(flam3_genome));
	memset(&selp0, 0, sizeof(flam3_genome));
	memset(&selp1, 0, sizeof(flam3_genome));
	
	
	srandom(seed ? seed : (time(0) + getpid()));
	
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
		char ministr[10];
		flam3_genome parents[2];
		double t = flam3_random01();
		
		sprintf(action,"cross interpolate");
		
		/* linearly interpolate somewhere between the two */
		
		memset(parents, 0, 2*sizeof(flam3_genome));
		
		[Genome populateCGenome:parents FromEntity:[[genome1 selectedObjects] objectAtIndex:0] fromContext:moc1]; 	
		[Genome populateCGenome:parents+1 FromEntity:[[genome2 selectedObjects] objectAtIndex:0] fromContext:moc2]; 	
		
		
		sprintf(ministr," %g",t);
		strcat(action,ministr);
		
		parents[0].time = 0.0;
		parents[1].time = 1.0;
		flam3_interpolate(parents, 2, t, cp_orig);
		
		/* except pick a simple palette */
		rb = flam3_random_bit();
		sprintf(ministr," %d",rb);
		strcat(action,ministr);
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
	[self deleteOldGenomesInContext:mocResult];
	[flameModel generateAllThumbnailsForGenome:cp_save withCount:1 inContext:mocResult];
	[mocResult save:nil];
	
	/* Free created documents */
	/* (Only free once, since the copy is a ptr to the original) */
	xmlFreeDoc(cp_save->edits);
	
}

- (IBAction)doUnion:(id)sender {


	flam3_frame f;
	flam3_genome cp_orig;
	flam3_genome *cp_save;
	flam3_genome selp0, selp1;
	flam3_genome *aselp0, *aselp1;
	
	int seed;
	int count = 0;
	int ntries = 10;
	int debug = 0;
	
	double avg_pix, fraction_black, fraction_white;
	double avg_thresh = 20.0;
	double black_thresh = 0.01;
	double white_limit =  0.05;

	char action[1024];  /* Ridiculously large, but still not that big */
	
	unsigned char *image;

   cp_save = (flam3_genome *)malloc(sizeof(flam3_genome));
   
   memset(cp_save, 0, sizeof(flam3_genome));
   memset(&cp_orig, 0, sizeof(flam3_genome));
   memset(&selp0, 0, sizeof(flam3_genome));
   memset(&selp1, 0, sizeof(flam3_genome));


	srandom(seed ? seed : (time(0) + getpid()));
	
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

			[Genome populateCGenome:&selp0 FromEntity:[[genome1 selectedObjects] objectAtIndex:0] fromContext:moc1]; 	
			[Genome populateCGenome:&selp1 FromEntity:[[genome2 selectedObjects] objectAtIndex:0] fromContext:moc2]; 	
					
			aselp0 = &selp0;
			aselp1 = &selp1;
			
			/* union */
			flam3_copy(&cp_orig, &selp0);
			
			int j, i = 0;
			for (j = 0; j < selp1.num_xforms; j++) {
				/* Skip over the final xform, if it's present.    */
				/* Default behavior keeps the final from parent0. */
				if (selp1.final_xform_index == j)
					continue;
				flam3_add_xforms(&cp_orig, 1);
				cp_orig.xform[cp_orig.num_xforms-1] = selp1.xform[j];
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

	[self deleteOldGenomesInContext:mocResult];
	[flameModel generateAllThumbnailsForGenome:cp_save withCount:1 inContext:mocResult];
	[mocResult save:nil];
	
	/* Free created documents */
	/* (Only free once, since the copy is a ptr to the original) */
	xmlFreeDoc(cp_save->edits);
	



}

- (IBAction)mutate:(id)sender {
}

- (IBAction)clone:(id)sender {
}

- (IBAction)sendResultToEditor:(id)sender {

	flam3_genome newGenome;
	
	[Genome populateCGenome:&newGenome FromEntity:[[genomeResult arrangedObjects] objectAtIndex:0] fromContext:mocResult];

	[self deleteOldGenomesInContext:[flameModel getNSManagedObjectContext]];
	[flameModel generateAllThumbnailsForGenome:&newGenome withCount:1 inContext:[flameModel getNSManagedObjectContext]];

}

@end

