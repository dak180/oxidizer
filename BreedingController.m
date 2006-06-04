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
}

- (IBAction)interpolate:(id)sender {
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

