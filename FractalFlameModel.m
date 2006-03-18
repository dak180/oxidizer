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

#import <sys/sysctl.h>
#import "FractalFlameModel.h"
#import "Genome.h"
#import "QuickTime/QuickTime.h"

int printProgress(void *nslPtr, double progress, int stage);

@implementation FractalFlameModel

- init
{
	NSUserDefaults *defaults;
	NSSortDescriptor *sort;
	
    if (self = [super init]) {


		defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
			NSUserName(),  @"nick",
			@"http://oxidizer.sf.net", @"url",
			@"Made by Oxidizer", @"comment",
			nil]
			];
		
		moc = [[NSManagedObjectContext alloc] init];
		
		
		// create persistant store and init with models main bundle 
		
		NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]]; 
		
		[moc setPersistentStoreCoordinator: coordinator];
		[coordinator release];
		
		NSString *STORE_TYPE = NSInMemoryStoreType;
		//    NSString *STORE_FILENAME = @"flam3.genome";
		
		NSError *error;
		
		//    NSURL *url = [NSURL fileURLWithPath: [NSTemporaryDirectory() stringByAppendingPathComponent:STORE_FILENAME]];
		
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
		
		sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
		genomeSortDescriptors = [NSArray arrayWithObject: sort];
		[genomeSortDescriptors retain];		
		[sort  release]; 
		
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"variation_index" ascending:YES];
		variationSortDescriptors = [NSArray arrayWithObject: sort];
		[sort  release]; 
		
		sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
		xformSortDescriptors = [NSArray arrayWithObject: sort];
		[sort  release]; 
		
		
    }
	
	
	
    return self;
}

- (IBAction)renderStill:(id)sender {

	NSBitmapImageRep *flameRep;
	
	flam3_frame frame;
	flam3_genome *genome;
	
	NSArray *genomes;
                        
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];

	genomes = [moc executeFetchRequest:fetch error:nil];
	[fetch release];

	
	genome = (flam3_genome *)malloc(sizeof(flam3_genome));
	
	[Genome populateCGenome:genome FromEntity:[flames getSelectedGenome] fromContext:moc];

	flam3_print(stderr, genome, NULL);


	frame.genomes = genome;
	[self EnvironmentInit:&frame];
	
	frame.time = 0.0;
	frame.ngenomes = 1;

	progress = 0.0;
	[progressIndicator setDoubleValue:0.0];
	
	[frameIndicator setMaxValue:1];
	[frameIndicator setIntValue:1];
	
	[progressWindow setTitle:@"Rendering Image"];
	[progressWindow makeKeyAndOrderFront:self];
	
	flameRep = [self renderSingleFrame:&frame withGemone:genome];
	
	[progressWindow setIsVisible:FALSE];

	
	[self saveToFile:flameRep];	

	[flameRep release];

}

- (IBAction)renderAnimation:(id)sender {
	
	//          NSData *data;
    //        QTDataReference *dataRef;
   	NSBitmapImageRep *flameRep;
	NSImage *flameImage;
	QTMovie *movie;
	OSErr outErr;
	
	int ftime, frameCount;
	unsigned char *image;
	DataHandler mDataHandlerRef;
	
	flam3_genome *cps;
	flam3_frame f;	
	int i, ncps = 0;
	
	
	NSArray *genomes;
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	[fetch release];	  
	
	channels = 4;
	
  	ncps = [genomes count];
	cps = [Genome populateAllCGenomesFromEntities:genomes fromContext:moc];
	
	dtime = 1;
	
	[self EnvironmentInit:&f];
	
	QTTime curTime = QTMakeTime(30, 60);
	
	NSDictionary *myDict = [NSDictionary dictionaryWithObjectsAndKeys:@"tiff" ,
		QTAddImageCodecType,
		[NSNumber numberWithLong:codecHighQuality],
		QTAddImageCodecQuality,
		nil];
	
	
	movie = [self QTMovieFromTempFile:&mDataHandlerRef error:&outErr];
	[movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];	
	
	
	srandom(seed ? seed : (time(0) + getpid()));
	
	if (pixel_aspect <= 0.0) {
		fprintf(stderr, "pixel aspect ratio must be positive, not %g.\n",
				pixel_aspect);
		exit(1);
	}
	
	if (NULL == cps) {
		exit(1);
	}
	if (0 == ncps) {
		fprintf(stderr, "error: no genomes.\n");
		exit(1);
	}
	
	for (i = 0; i < ncps; i++) {
		cps[i].sample_density *= qs;
		cps[i].height = (int)(cps[i].height * ss);
		cps[i].width = (int)(cps[i].width * ss);
		cps[i].pixels_per_unit *= ss;
		if ((cps[i].width != cps[0].width) ||
			(cps[i].height != cps[0].height)) {
			fprintf(stderr, "warning: flame %d at time %g size mismatch.  "
					"(%d,%d) should be (%d,%d).\n",
					i, cps[i].time,
					cps[i].width, cps[i].height,
					cps[0].width, cps[0].height);
			cps[i].width = cps[0].width;
			cps[i].height = cps[0].height;
		}
	}
	
	
	first_frame = (int) cps[0].time;
	
	last_frame = (int) cps[ncps-1].time - 1;
	
	
	if (last_frame < first_frame) last_frame = first_frame;
	
	f.temporal_filter_radius = 0.5;
	f.pixel_aspect_ratio = pixel_aspect;
	f.genomes = cps;
	f.ngenomes = ncps;
	f.verbose = verbose;
	f.bits = bits;
	f.progress = 0;
	
	flameRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
													  pixelsWide:cps->width
													  pixelsHigh:cps->height
												   bitsPerSample:8
												 samplesPerPixel:channels
														hasAlpha:channels == 4 ? YES : NO 
														isPlanar:NO
												  colorSpaceName:NSDeviceRGBColorSpace
													bitmapFormat:0
													 bytesPerRow:channels*cps->width
													bitsPerPixel:8*channels];
	image =[flameRep bitmapData];
	
	flameImage = [[NSImage alloc] init];
	[flameImage addRepresentation:flameRep];
	
	
	
	if (dtime < 1) {
		fprintf(stderr, "dtime must be positive, not %d.\n", dtime);
		exit(1);
	}
	
	f.verbose = 0;
	
	[progressIndicator setDoubleValue:0.0];
	
	[frameIndicator setMaxValue:(last_frame - first_frame) / dtime];
	frameCount = 0;
	[frameIndicator setIntValue:0];
	
	[progressWindow setTitle:@"Rendering Movie..."];
	
	[progressWindow makeKeyAndOrderFront:self];

	f.progress = printProgress;
	f.progress_parameter = progressIndicator;
	
	
	for (ftime = first_frame; ftime <= last_frame; ftime += dtime) {
		f.time = (double) ftime;
		
		[frameIndicator setIntValue:++frameCount];
		[frameIndicator displayIfNeeded];
		
//		fprintf(stderr, "time = %d/%d/%d\n", ftime, last_frame, dtime);
		
		flam3_render(&f, image, cps[0].width, flam3_field_both, channels, transparency);		
		
		[movie addImage:flameImage forDuration:curTime withAttributes:myDict];	
		
    }
	
	[progressWindow setTitle:@"Writing Movie to Disk..."];
	
	ConvertMovieToFile ([movie quickTimeMovie],     /* identifies movie */
		0,                /* all tracks */
		0,                /* no output file */
		0,                  /* no file type */
		0,                  /* no creator */
		smSystemScript,     /* script */
		0,                /* no resource ID */
		createMovieFileDeleteCurFile |
		showUserSettingsDialog |
		movieToFileOnlyExport,
		0);


	if (mDataHandlerRef) {
		CloseMovieStorage(mDataHandlerRef);
	}

	[progressWindow setIsVisible:NO];

}







- (BOOL)EnvironmentInit:(flam3_frame *)f {

	verbose = 1;
	transparency = 1;
	qs = environment->qualityScale;
	ss = environment->sizeScale;
	bits = [environment getIntBits];
	seed = environment->seed;
	pixel_aspect = [environment doubleAspect];
	channels = 3;
	if(environment->useAlpha == YES) {
		channels = 4;
	} else {
		channels = 3;
	}
	
	f->bits = bits;

	srandom(seed);
	
		
	if (getenv("nstrips")) {
		nstrips = atoi(getenv("nstrips"));
	} else {
		nstrips = calc_nstrips(f);
	}
	
	return TRUE;

}

- (BOOL)loadFlam3File:(NSString *)filename intoCGenomes:(flam3_genome **)genomes returningCountInto:(int *)count {

	char *utf8Filename;

	
	utf8Filename = strdup([filename cStringUsingEncoding:NSUTF8StringEncoding]);
	
	FILE *flam3;
	
	flam3 = fopen(utf8Filename, "rb");
	if (NULL == flam3) {
		perror(utf8Filename);
		return FALSE;
	}
	
	*genomes = flam3_parse_from_file(flam3, utf8Filename, flam3_defaults_on, count);
	if (NULL == *genomes) {
		return NO;
	}
	
//	flam3_print(stderr, *genomes, NULL);

	return YES; 

}

- (BOOL)generateAllThumbnailsForGenome:(flam3_genome *)cps withCount:(int)ncps {

	NSBitmapImageRep *flameRep;
	NSImage *flameImage;
		
	int i;
	
	progress = 0.0;
	[progressIndicator setDoubleValue:0.0];
	
	[frameIndicator setMaxValue:ncps];
	[progressWindow setTitle:@"Rendering Thumbnails..."];
	
	[progressWindow makeKeyAndOrderFront:self];
	
	for (i = 0; i < ncps; i++) {

		[frameIndicator setIntValue:i+1];	
		[frameIndicator displayIfNeeded];
	
		flameRep = [self renderThumbnail:cps+i];
		flameImage = [[NSImage alloc] init];
		[flameImage addRepresentation:flameRep];
		[flames addFlameData:flameImage genome:cps+i atIndex:i inContext:moc];  


		[flameImage release];
		[flameRep release];

	}

	
	[flameImages reloadData];
	[progressWindow setIsVisible:FALSE];
	
	free(cps);


	return TRUE;

}

-(NSBitmapImageRep *)renderThumbnail:(flam3_genome *)cps {

	NSBitmapImageRep *flameRep;
	
	flam3_frame frame;
	
	int realHeight, realWidth;
	double realScale;

	double scaleFactor;
	
	
	realHeight = cps->height;
	realWidth = cps->width;
	realScale = cps->pixels_per_unit;
	
	scaleFactor = realHeight > realWidth ? 128.0 / realHeight : 128.0 / realWidth; 
	
	cps->height *= scaleFactor;
	cps->width *= scaleFactor;
	cps->pixels_per_unit *= scaleFactor;

	frame.genomes = cps;
	[self EnvironmentInit:&frame];
	
	frame.time = 0.0;
	frame.temporal_filter_radius = 0.0;
	frame.ngenomes = 1;
	
	progress = 0.0;

	[progressWindow makeKeyAndOrderFront:self];
	
	flameRep = [self renderSingleFrame:&frame withGemone:cps];
	
	cps->height = realHeight;
	cps->width = realWidth;
	cps-> pixels_per_unit = realScale;
	
	return flameRep;
}

- (IBAction)openFile:(id)sender {

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
		[self deleteOldGenomes];
		boolResult = [self loadFlam3File:[op filename] intoCGenomes:&genomes returningCountInto:&genomeCount ];
		if(boolResult == YES) {
			[self generateAllThumbnailsForGenome:genomes withCount:genomeCount];
//			[flames setCurrentFlameForIndex:0];
		}
	} 
	
	return;
}



int calc_nstrips(flam3_frame *spec) {
  double mem_required;
  double mem_available;
  int nstrips;
  
  unsigned int physmem;
  size_t len = sizeof(physmem);
  static int mib[2] = { CTL_HW, HW_PHYSMEM };


  if (sysctl (mib, sizeof (mib), &physmem, &len, NULL, 0) == 0 && len == sizeof (physmem)) {
	  mem_available = (double )physmem;
  } else {
	  fprintf(stderr, "warning: unable to determine physical memory.\n");
	  mem_available = 2e9;
  }
 	  
 
  mem_available *= 0.8;
  mem_required = flam3_render_memory_required(spec);
  
  if (mem_available >= mem_required) {
	  return 1;
  }
  
  nstrips = (int) ceil(mem_required / mem_available);
  
  return nstrips;
}

- (void)renderFlames:(flam3_genome *)cps numberOfFlames:(int)ncps {

	NSBitmapImageRep *flameRep;
	
	flam3_frame frame;
	
	int i;


	frame.genomes = cps;

	[self EnvironmentInit:&frame];
	
	frame.time = 0.0;
	frame.temporal_filter_radius = 0.0;
	frame.ngenomes = 1;


	for (i = 0; i < ncps; i++) {
		
		flameRep = [self renderSingleFrame:&frame withGemone:cps+i];
		[[flameRep representationUsingType:NSPNGFileType properties:nil] writeToFile:@"testOutput.png" atomically:YES];								 		
		[flameRep release];

	}
	
	return;

}


 - (NSBitmapImageRep *)renderSingleFrame:(flam3_frame *)f withGemone:(flam3_genome *)cps {

	
	unsigned char *image;
	int strip;
	double center_y, center_base;
	double zoom_scale;

	
	/* replace this next group with values from EnvironmentController */

	
//	NSImage *flameImage;
	NSBitmapImageRep *flameRep;
	
	flam3_print(stderr, cps, NULL);
	
	
	cps->sample_density *= qs;
	cps->height = (int)(cps->height * ss);
	cps->width = (int)(cps->width * ss);
	cps->pixels_per_unit *= ss;
	
	int real_height;
	
	f->genomes = cps;
	f->verbose = verbose;
	f->bits = bits;
	f->pixel_aspect_ratio = pixel_aspect;
	f->progress = printProgress;

	f->progress_parameter = progressIndicator;
	
	if (nstrips > cps->height) {
		fprintf(stderr, "cannot have more strips than rows but %d>%d.\n",
				nstrips, cps->height);
		exit(1);
	}
	
	flameRep= [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
													  pixelsWide:cps->width
													  pixelsHigh:cps->height
												   bitsPerSample:8
												 samplesPerPixel:channels
														hasAlpha:channels == 4 ? YES : NO 
														isPlanar:NO
												  colorSpaceName:NSDeviceRGBColorSpace
													bitmapFormat:0
													 bytesPerRow:channels*cps->width
													bitsPerPixel:8*channels];
	image =[flameRep bitmapData];
	
	
	cps->sample_density *= nstrips;
	real_height = cps->height;
	cps->height = (int) ceil(cps->height / (double) nstrips);
	center_y = cps->center[1];
	zoom_scale = pow(2.0, cps->zoom);
	center_base = center_y - ((nstrips - 1) * cps->height) /
		(2 * cps->pixels_per_unit * zoom_scale);
	
	for (strip = 0; strip < nstrips; strip++) {
		unsigned char *strip_start =
		image + cps->height * strip * cps->width * channels;
		cps->center[1] = center_base +
			cps->height * (double) strip /
			(cps->pixels_per_unit * zoom_scale);
		
		if ((cps->height * (strip + 1)) > real_height) {
			int oh = cps->height;
			cps->height = real_height - oh * strip;
			cps->center[1] -= 
				(oh - cps->height) * 0.5 /
				(cps->pixels_per_unit * zoom_scale);
		}
		
		if (verbose && nstrips > 1) {
			fprintf(stderr, "strip = %d/%d\n", strip+1, nstrips);
		}

	
		flam3_render(f, strip_start, cps->width, flam3_field_both, channels, transparency);
		
		
		
	}
	
	/* restore the cps values to their original values */
	cps->sample_density /= nstrips;
	cps->height = real_height;
	cps->center[1] = center_y;
	
	
	if (verbose) {
		fprintf(stderr, "done.\n");
	}
	
	return flameRep;

}


 
 
- (IBAction)previewCurrentFlame:(id)sender {

	NSBitmapImageRep *flameRep;
	NSImage *flameImage;
	flam3_genome *flame = (flam3_genome *)malloc(sizeof(flam3_genome));
	
	[Genome populateCGenome:flame FromEntity:[flames getSelectedGenome] fromContext:moc];

	[progressIndicator setDoubleValue:0.0];	
	[frameIndicator setMaxValue:1];
	[progressWindow setTitle:@"Rendering Preview..."];
	
	flameRep = [self renderThumbnail:flame];
	
	[progressWindow setIsVisible:NO];

	flameImage = [[NSImage alloc] init];
	[flameImage addRepresentation:flameRep];

	[flames setPreviewForCurrentFlame:flameImage];
	
	[flameImage release];
	[flameRep release];
	free(flame);		
		

}

-(BOOL) saveToFile:(NSBitmapImageRep *)rep {

	NSData *tiff;
	
//	ImageDescriptionHandle imageDescriptionHandle;
	
	tiff = [[rep TIFFRepresentation] retain];
	
	MovieImportComponent tiffImportComponent = OpenDefaultComponent( GraphicsImporterComponentType, kQTFileTypeTIFF );
	
	PointerDataRef dataReference = (PointerDataRef)NewHandle( sizeof(PointerDataRefRecord) );
	
	(**dataReference).data = (void *) [tiff bytes];
	(**dataReference).dataLength = [tiff length];
	
	GraphicsImportSetDataReference( tiffImportComponent, (Handle)dataReference, PointerDataHandlerSubType );
	
//	GraphicsImportGetImageDescription( tiffImportComponent, &image_description_handle );
	
	
	// do something with the image description and tiff data
	//
	GraphicsImportDoExportImageFileDialog(
            tiffImportComponent, nil, nil, nil, nil, nil, nil);

	CloseComponent( tiffImportComponent);
//	DisposeHandle( image_description_handle );
	
	[tiff release];
	
	return TRUE;
}



-(QTMovie *)QTMovieFromTempFile:(DataHandler *)outDataHandler error:(OSErr *)outErr
{
  *outErr = -1;
  
  Handle  dataRefH    = nil;
  OSType  dataRefType;
  
  // generate a name for our movie file
  NSString *tempName = [NSString stringWithCString:tmpnam(nil) 
              encoding:[NSString defaultCStringEncoding]];
  if (nil == tempName) {
	return FALSE;
  };
   

  // create a file data reference for our movie
  *outErr = QTNewDataReferenceFromFullPathCFString((CFStringRef)tempName,
                          kQTNativeDefaultPathStyle,
                          0,
                          &dataRefH,
                          &dataRefType);
  if (*outErr != noErr) {
	return FALSE;
	}

  
  // create a QuickTime movie from our file data reference
  Movie  qtMovie  = nil;
  CreateMovieStorage (dataRefH,
            dataRefType,
            'TVOD',
            smSystemScript,
            newMovieActive, 
            outDataHandler,
            &qtMovie);
  *outErr = GetMoviesError();
  if (*outErr != noErr) {
	return FALSE;
	}
	
return [QTMovie movieWithQuickTimeMovie:qtMovie disposeWhenDone:YES error:nil];
  
}


- (void) deleteOldGenomes {

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


- (IBAction)changePaletteAndHidePaletteWindow:(id)sender {


	[palette changePaletteAndHidePaletteWindow];
	

}

- (IBAction)showPreferencesWindow:(id)sender {
	[preferencesWindow makeKeyAndOrderFront:self];
}



	
@end

int printProgress(void *nslPtr, double progress, int stage) {
	
	NSLevelIndicator *nsl = nslPtr;

	[nsl setDoubleValue:progress * 100.0];
	[nsl displayIfNeeded];

//	fprintf(stderr, "Progress value: %f\n", progress); 
//	fprintf(stderr, "Stage: %s\n", stage ? "filtering" : "chaos"); 
	
	return 0;
}

