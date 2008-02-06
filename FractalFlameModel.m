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

#import "FractalFlameModel.h"
#import "BreedingController.h"
#import "Flam3Task.h"
#import "Genome.h"
#import "GreaterThanThreeTransformer.h"
#import "ProgressDetails.h"
#import "QuickTime/QuickTime.h"

#include <sys/types.h>
#include <sys/sysctl.h>


int printProgress(void *nslPtr, double progress, int stage);



@implementation FractalFlameModel

- init
{
	NSSortDescriptor *sort;
		 
    if (self = [super init]) {
		
		_stillsParameters = [[NSMutableDictionary alloc] initWithCapacity:2];
		[_stillsParameters setObject:[NSNumber numberWithInt:0] forKey:@"first_frame"];
		[_stillsParameters setObject:[NSNumber numberWithInt:0] forKey:@"last_frame"];


		defaults = [NSUserDefaults standardUserDefaults];
		
	
		_saveThumbnail = [defaults boolForKey:@"save_thumbnails"];
		
		_showRender = [defaults boolForKey:@"show_render"];
		
		_currentFilename = nil;
		
		[NSBundle loadNibNamed:@"FileViews" owner:self];

		
		GreaterThanThreeTransformer *gttt;
		
	// create an autoreleased instance of our value transformer
		gttt = [[[GreaterThanThreeTransformer alloc] init] autorelease];
		
	// register it with the name that we refer to it with
		[NSValueTransformer setValueTransformer:gttt
                                forName:@"GreaterThanThree"];


  		
		
		moc = [[NSManagedObjectContext alloc] init];
		
		
		// create persistant store and init with models main bundle 
		
		coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]]; 
		
		[moc setPersistentStoreCoordinator: coordinator];
		
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
		
		sort = [[NSSortDescriptor alloc] initWithKey:@"variation_index" ascending:YES];
		variationSortDescriptors = [NSArray arrayWithObject: sort];
		[sort  release]; 
		
		sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
		xformSortDescriptors = [NSArray arrayWithObject: sort];
		[sort  release]; 

		sort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
		cmapSortDescriptors = [NSArray arrayWithObject: sort];
		[sort  release]; 
		
		docController = [NSDocumentController sharedDocumentController];
		
		_progressInd = [[NSMutableArray alloc] initWithCapacity:2];

		_saveThumbnail = [defaults boolForKey:@"save_thumbnails"];
		
		_showRender = [defaults boolForKey:@"show_render"];

		_spatialFilterArray = [NSArray arrayWithObjects:@"Gaussian", @"Hermite",@"Box", @"Triangle", @"Bell", 
			                                           @"B-Spline", @"Mitchell", @"Blackman", @"Catrom", @"Hanning", 
			                                           @"Hamming", @"Lanczos2", @"Lanczos3", @"Quadratic", nil];	
	
		
		
	}
	
    return self;
}


- (void)awakeFromNib {
	
	[previewWindow center];
	[taskProgressWindow center];
	
//	if([FractalFlameModel useProgressBar]) {
//		[taskFrameIndicator setStyle:NSProgressIndicatorBarStyle];
///		[taskFrameIndicator setControlSize:NSRegularControlSize];
		
//		[taskAllFramesIndicator setStyle:NSProgressIndicatorBarStyle];
//		[taskAllFramesIndicator setControlSize:NSRegularControlSize];
//	}
	
	
	savePanel = [NSSavePanel savePanel];
	[savePanel retain];
	
}


- (void)renderStill {

	BOOL doRender = [self okayToRender];

	if(doRender == NO) {
		return;
	}
	
	doRender = [qtController showQuickTimeFileImageDialogue];
                  
	if(doRender == NO) {
		return;
	}

   [NSThread detachNewThreadSelector:@selector(renderStillInNewThread:) toTarget:self withObject:qtController];


}
	
- (void)renderStillToWindow {

	BOOL doRender = [self okayToRender];
	
	if(doRender == NO) {
		return;
	}
	
	[NSThread detachNewThreadSelector:@selector(renderStillToWindowInNewThread) toTarget:self withObject:nil];
	
}

- (void)renderStillToWindowInNewThread {

	BOOL realShowRender = _showRender;

	_showRender = YES;	
	[self renderStillInNewThread:nil]; 
	_showRender = realShowRender;
	
}

- (void)renderStillInNewThread:(QuickTimeController *)qt {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];									
	
	[moc lock];
	
	
	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
		
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"still.png", nil]];
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];	
	[taskEnvironment setObject:pngFileName forKey:@"out"];
	
	NSArray *genome = [NSArray arrayWithObject:[flames getSelectedGenome]];


	NSDate *start = [NSDate date];
	
	
	int returnCode = [self runFlam3StillRenderAsTask:[Genome createXMLFromEntities:genome fromContext:moc forThumbnail:NO] withEnvironment:taskEnvironment];
	
	if (returnCode != 0) {
			
		[moc unlock];
		[taskEnvironment release];
		[pool release];
		return;
	}	
	
	[moc unlock];

	NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:pngFileName]];
	

	if(qt != nil) {
		[qt saveNSImage:flameImage];		
	} 
	
	
	if (_showRender) {
		
		[previewView setImage:flameImage];
		[previewView setToolTip:@"Preview: This is the image you have just rendered. You can save a copy by dragging the image to the finder/desktop."];

		[self showPreviewWindow];
		

	}

	[flameImage release];
	
	NSBeep();
	
	if(qt != nil) {
		
	
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render finished!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:@"Time for render: %.2f seconds", -[start timeIntervalSinceNow]];
		[finishedPanel runModal];
	
	}

	BOOL returnBool;
	
	if ([fileManager fileExistsAtPath:pngFileName]) {
		returnBool = [fileManager removeFileAtPath:pngFileName handler:nil];
		returnBool = [fileManager removeFileAtPath:previewFolder handler:nil];
	}	
	
	[taskEnvironment release];
	[pool release];

}

- (void)renderAnimation {

	BOOL doRender = [qtController showQuickTimeFileMovieDialogue];
	if(doRender == NO) {
		return;
	}
	[NSThread detachNewThreadSelector:@selector(renderAnimationInNewThread) toTarget:self withObject:nil];

}

- (void)renderAnimationInNewThread {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	
	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSLog(previewFolder);	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];
	
	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"frame.png", nil]];
	[taskEnvironment setObject:pngFileName forKey:@"out"];
	

	int ftime;
	
	double progressValue;
		
	NSArray *genomes;
	NSManagedObject *genome;
		
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];

	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
	[fetch setSortDescriptors: sortDescriptors];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	[fetch release];	  
	
	genome = [genomes objectAtIndex:0];
	
	
	[qtController setMovieHeight:[[genome valueForKey:@"height"] intValue] * environment->sizeScale 
						   width:[[genome valueForKey:@"width"] intValue] * environment->sizeScale];
	BOOL doRender = [qtController CreateMovieGWorld];

	
	dtime = 1;

	first_frame = (int) [[genome valueForKey:@"time"] intValue];
	last_frame = (int) [[[genomes lastObject] valueForKey:@"time"] intValue] - 1;
		
	if (last_frame < first_frame) {
		last_frame = first_frame;
	}
	
	progressValue = 0.0;

	[taskAllFramesIndicator setMaxValue:(last_frame - first_frame) / dtime];
	[taskAllFramesIndicator setDoubleValue:progressValue];
	
	[taskProgressWindow setTitle:@"Rendering Movie..."];	
	[taskProgressWindow makeKeyAndOrderFront:self];

	
	NSDate *start = [NSDate date];
	
	NSData *xml = [Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:NO];

	int imgRepresentationIndex;
	NSArray *repArray;
		
	for (ftime = first_frame; ftime <= last_frame; ftime += dtime) {

/* set time for environment */
		[taskEnvironment setObject:[NSNumber numberWithInt:ftime] forKey:@"frame"];

		[taskAllFramesIndicator setDoubleValue:progressValue];

		int returnCode = [self runFlam3MovieFrameRenderAsTask:xml withEnvironment:taskEnvironment];

		if (returnCode == 0) {
			NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:pngFileName]];

			repArray = [flameImage representations];
			for (imgRepresentationIndex = 0; imgRepresentationIndex < [repArray count]; ++imgRepresentationIndex) {
				if ([[repArray objectAtIndex:imgRepresentationIndex] isKindOfClass:[NSBitmapImageRep class]]) {
					[qtController addNSBitmapImageRepToMovie:[repArray objectAtIndex:imgRepresentationIndex]];
					break;
				}
			}
			
		} else {
			
			[taskProgressWindow setIsVisible:NO];
			[pool release];
			return;
			
		}
		
		progressValue += dtime;
	}

	[taskProgressWindow setTitle:@"Writing Movie to Disk..."];
	
	[qtController performSelectorOnMainThread:@selector(saveMovie) withObject:nil waitUntilDone:YES];

	[taskProgressWindow setIsVisible:NO];
	
	if ([fileManager fileExistsAtPath:pngFileName]) {
		BOOL returnBool = [fileManager removeFileAtPath:pngFileName handler:nil];
		returnBool = [fileManager removeFileAtPath:previewFolder handler:nil];
	}
	
	NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render finished!" 
									  defaultButton:@"Close"
									  alternateButton:nil 
									  otherButton:nil 
								      informativeTextWithFormat:@"Time for render: %.2f seconds", -[start timeIntervalSinceNow]];
	NSBeep();
	[finishedPanel runModal];
	
	
	[pool release];
}




- (void)renderAnimationStills {

	
	NSArray *genomes = [self fetchGenomes];
	
	
	NSManagedObject *genome = [genomes objectAtIndex:0];
	
	[self willChangeValueForKey:@"first_frame"];
	[_stillsParameters setObject:[genome valueForKey:@"time"] forKey:@"first_frame"];
	[self didChangeValueForKey:@"first_frame"];
	
	genome = [genomes lastObject];

	[self willChangeValueForKey:@"last_frame"];
	[_stillsParameters setObject:[genome valueForKey:@"time"] forKey:@"last_frame"];
	[self didChangeValueForKey:@"last_frame"];

	BOOL doRender = [qtController showQuickTimeFileStillsDialogue];

	[self didChangeValueForKey:@"prefix"];
	[_stillsParameters setObject:[qtController fileName] forKey:@"prefix"];
	[self didChangeValueForKey:@"prefix"];
	
	if(doRender == NO) {
		return;
	}
	
	
	
	
	[NSThread detachNewThreadSelector:@selector(renderAnimationStillsInNewThread:) toTarget:self withObject:_stillsParameters];
	
	
}

- (void)renderAnimationStillsInNewThread:(NSDictionary *)parameters {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[parameters retain];
	
	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];
	
	
	[taskEnvironment setObject:[parameters objectForKey:@"prefix"] forKey:@"prefix"];
	
	
	int ftime;
	
	double progressValue;
	
	NSArray *genomes = [self fetchGenomes];
	
	
	NSManagedObject *genome = [genomes objectAtIndex:0];
	
//	double qs = [[NSUserDefaults standardUserDefaults] do]
	
	
	[qtController setMovieHeight:[[genome valueForKey:@"height"] intValue] * environment->sizeScale 
						   width:[[genome valueForKey:@"width"] intValue] * environment->sizeScale];
	BOOL doRender = [qtController CreateMovieGWorld];
	
	
	dtime = 1;
	
	first_frame = (int) [[parameters valueForKey:@"first_frame"] intValue];
	last_frame = (int) [[parameters valueForKey:@"last_frame"] intValue] - 1;
	
	if (last_frame < first_frame) {
		last_frame = first_frame;
	}
	
	progressValue = 0.0;
	
	[taskAllFramesIndicator setMaxValue:(last_frame - first_frame) / dtime];
	[taskAllFramesIndicator setDoubleValue:progressValue];
	
	[taskProgressWindow setTitle:@"Rendering Movie..."];	
	[taskProgressWindow makeKeyAndOrderFront:self];
	
	
	NSDate *start = [NSDate date];
	
	NSData *xml = [Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:NO];
	
	
	for (ftime = first_frame; ftime <= last_frame; ftime += dtime) {
		
		/* set time for environment */
		[taskEnvironment setObject:[NSNumber numberWithInt:ftime] forKey:@"frame"];
		
		[taskAllFramesIndicator setDoubleValue:progressValue];
		
		int returnCode = [self runFlam3MovieFrameRenderAsTask:xml withEnvironment:taskEnvironment];

		progressValue += dtime;
	}
	
	
	[taskProgressWindow setIsVisible:NO];
		
	NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render finished!" 
											 defaultButton:@"Close"
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:@"Time for render: %.2f seconds", -[start timeIntervalSinceNow]];
	NSBeep();
	[finishedPanel runModal];
	
	[parameters release];

	[pool release];
}



- (IBAction)previewCurrentFlame:(id)sender {

	NSArray *genomes = [NSArray arrayWithObject:[flames getSelectedGenome]];

	[NSThread detachNewThreadSelector:@selector(previewCurrentFlameInThread:) toTarget:self withObject:genomes]; 

}

- (void ) previewCurrentFlameInThread:(NSArray *)genomes  {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSError *error;
	
	[genomes retain];
	
	BOOL worked = [moc save:&error];

	/* generate a temp folder */
	
		
	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSLog(previewFolder);	

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"preview.png", nil]];

//	NSLog(@"%@", pngFileName);
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];	
	[taskEnvironment setObject:pngFileName forKey:@"out"];
	
//	NSArray *genome = [NSArray arrayWithObject:[flames getSelectedGenome]];
	
	int returnCode = [self runFlam3StillRenderAsTask:[Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:YES] withEnvironment:taskEnvironment];
	
	if (returnCode == 0) {

		
//		[flames performSelectorOnMainThread:@selector(setPreviewForCurrentFlameFromFile:) withObject:pngFileName waitUntilDone:YES];
		[[genomes objectAtIndex:0] performSelectorOnMainThread:@selector(setImageFromFile:) withObject:pngFileName waitUntilDone:YES];
		
		
		BOOL returnBool;
		
//		if ([fileManager fileExistsAtPath:pngFileName]) {
//			returnBool = [fileManager removeFileAtPath:pngFileName handler:nil];
//			returnBool = [fileManager removeFileAtPath:previewFolder handler:nil];
//		}
		
	} else {
		
		NSLog(@"Render Failed");
		
	}
	
	[genomes release];
	
	[pool release];	

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



- (IBAction)editGenomes:(id)sender {

	 NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	 switch([segments selectedSegment]) {
		case 0: 
			[NSThread detachNewThreadSelector:@selector(AddRandomGenomeToFlamesUsingContext:) toTarget:self withObject:moc];
			if(_currentFilename == nil) {
				[self setCurrentFilename:@""];
			}
			break;
		case 1:		
			[flames showFlameWindow];
			break;
		case 2:
			[flames  removeFlame];
			break;
	}
		
	

}

- (void)AddRandomGenomeToFlamesUsingContext:(NSManagedObjectContext *)context {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[context lock];
	
	NSManagedObject *genome = [self createRandomGenomeInContext:context];
	[genome retain];

	[flames performSelectorOnMainThread:@selector(addNewFlame:) withObject:genome waitUntilDone:YES];

	[context performSelectorOnMainThread:@selector(processPendingChanges)  withObject:nil waitUntilDone:YES];

	[context unlock];

	[genome release];

	[pool release];

}

- (NSManagedObject *) createRandomGenomeInContext:(NSManagedObjectContext *)context {

	[taskProgressWindow setTitle:@"Generating Random Genome"];
	[taskProgressWindow makeKeyAndOrderFront:self];
	
	/* generate random XML */
	NSData *newGenome = [BreedingController createRandomGenomeXMLwithEnvironment:[self environmentDictionary]];
	
	NSArray *genomeEntity = [Genome createGenomeEntitiesFromXML:newGenome inContext:context];	

	/* fix up a few values before rendering the flame */
	
	[[genomeEntity objectAtIndex:0] setValue:[NSNumber numberWithInt:50] forKey:@"quality"];
	
	[self generateAllThumbnailsForGenomesInThread:genomeEntity];	
	[context performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
	
	return [genomeEntity objectAtIndex:0];


}

- (NSManagedObjectContext *)getNSManagedObjectContext {
	return moc;
}

- (IBAction)saveAsFlam3WithThumbnail {

	NSString *filename;
	
	int runResult;
	
	
	[savePanel setRequiredFileType:@"flam3"];
	if([savePanel accessoryView] != saveThumbnailsView) {
		[savePanel setAccessoryView:saveThumbnailsView];		
	}
	
	if(_currentFilename != nil && ![_currentFilename isEqualToString:@""]) {
		runResult = [savePanel runModalForDirectory:nil file:[[_currentFilename pathComponents] objectAtIndex:[[_currentFilename pathComponents] count]-1]];	
	} else {
		runResult = [savePanel runModalForDirectory:nil file:nil];
	}
	

	if(runResult == NSOKButton && [savePanel filename] != nil) {
		filename = [savePanel filename];
	} else {
		return;
	}
	
	[self setCurrentFilename:[savePanel filename]];
	[self saveFlam3WithThumbnail];

	return;
}

- (IBAction)saveFlam3WithThumbnail {

	NSString *filename;
	NSArray *genomes;
	
	int runResult;

	if(_currentFilename != nil && ![_currentFilename isEqualToString:@""]) {
		filename = _currentFilename;
	} else {		
//		NSSavePanel *savePanel = [NSSavePanel savePanel];
		[savePanel setRequiredFileType:@"flam3"];
		[savePanel setAccessoryView:saveThumbnailsView];
		
		runResult = [savePanel runModalForDirectory:nil file:_currentFilename];

		if(runResult == NSOKButton && [savePanel filename] != nil) {
			filename = [savePanel filename];
		} else {
			return;
		}
		
		[self setCurrentFilename:[savePanel filename]];
	}

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];

	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
	[fetch setSortDescriptors: sortDescriptors];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	[fetch release];	  
	
	[[Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:NO] writeToFile:[savePanel filename] atomically:YES];
		
	
	if(_saveThumbnail) {
		NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
		[taskEnvironment retain];
		[taskEnvironment setObject:[filename stringByAppendingString:@"_"] forKey:@"prefix"];
			
			int returnCode = [self runFlam3StillRenderAsTask:[Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:YES] withEnvironment:taskEnvironment];
			
			if (returnCode != 0) {
					
				NSLog(@"Render Failed");
				
			}
			
		
	}

	return;
}

- (NSMutableArray *)progressIndicators {

	return _progressInd;
}


- (void)setProgressIndicators:(NSMutableArray *)indicators {
	
	if(indicators != nil) {
		[indicators retain];
	}
	
	[_progressInd release];
	
	_progressInd = indicators;   
	
	return;
}

//-(void) saveNSBitmapImageRep:(NSBitmapImageRep *)rep {

//	[qtController saveNSBitmapImageRep:rep]; 
//}





- (void)hideProgressWindow {
	
	[progressWindow setIsVisible:NO];
	
}


- (void)initProgressController:(NSNumber *)threadsCount {
	
	int i, threads;
	
	threads = [threadsCount intValue];
	
	[progressController removeObjects:[progressController arrangedObjects]];
	
	
	for(i=0; i<threads; i++) {
		ProgressDetails *progressDict = [[ProgressDetails alloc] init];
		
		[progressDict setThread:[NSNumber numberWithInt:i]]; 
		[progressDict setProgress:[NSNumber numberWithDouble:0.0]]; 
		
		[progressController insertObject:progressDict atArrangedObjectIndex:i];
	}	
}

- (void) newFlame {
	
	[self deleteOldGenomes];
	if(![oxidizerWindow isVisible]) {
		
		[oxidizerWindow makeKeyAndOrderFront:self];
	}
}

- (IBAction)deleteGenomes:(id)sender {

	[flames  removeFlame];

}



- (IBAction)openFile:(id)sender {
	
	NSOpenPanel *op;
	
	/* create or get the shared instance of NSSavePanel */
	op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"flam3"];
	
	/* display the NSOpenPanel */
	int runResult = [op runModal];
	/* if successful, save file under designated name */
	if(runResult == NSOKButton && [op filename] != nil) {
		[self deleteOldGenomes];
		[docController noteNewRecentDocumentURL:[NSURL URLWithString:[op filename]]];
		[self createGenomesFromXMLFile:[op filename] inContext:moc];
		
	} 
	
	[self setCurrentFilename:[op filename]];
	[moc save:nil];
	
	return;
	
}


- (IBAction)appendFile:(id)sender {
	
	NSOpenPanel *op;
	int runResult, lastTime;
	
	/* create or get the shared instance of NSSavePanel */
	op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"flam3"];
	
	/* display the NSOpenPanel */
	runResult = [op runModal];
	/* if successful, save file under designated name */
	if(runResult == NSOKButton && [op filename] != nil) {
		
		/* get the current flames and find the max time */
		NSArray *genomeArray;
		
		NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
		
		[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
		[fetch setSortDescriptors: sortDescriptors];
		
		genomeArray = [moc executeFetchRequest:fetch error:nil];
		
		if(genomeArray != nil && [genomeArray count] > 0) {
			
			lastTime = [[[genomeArray objectAtIndex:0] valueForKey:@"time"] intValue];
			lastTime += 50;
			
		} else {
			
			lastTime = 0;
		}
		
		[docController noteNewRecentDocumentURL:[NSURL URLWithString:[op filename]]];
		[self appendGenomesFromXMLFile:[op filename] fromTime:lastTime inContext:moc];
		[moc save:nil];
		
		
		[fetch release];	  
		[sort release];
		
	} 
	
	return;
}

- (BOOL)openRecentFile:(NSString *)filename {
	
	
	[self deleteOldGenomes];
	
	[self createGenomesFromXMLFile:filename inContext:moc];
	[self setCurrentFilename:filename];
	[moc save:nil];
	
	return TRUE;
	
}


- (NSString *) currentFilename {
	
	return _currentFilename;
}


- (void) setCurrentFilename:(NSString *)filename {
	
	[filename retain];
	
	if(_currentFilename != nil) {
		
		[_currentFilename release];
	}
	
	[self willChangeValueForKey:@"_currentFilename"];
	_currentFilename = filename;
	[self didChangeValueForKey:@"_currentFilename"];
	
	return;
}

- (void)generateAllThumbnailsForGenomes:(NSArray *)genomes {
	
	
	[NSThread detachNewThreadSelector:@selector(generateAllThumbnailsForGenomesInThread:) 
							 toTarget:self 
						   withObject:genomes];
	
	
	return ;
	
	
}



- (void)generateAllThumbnailsForGenomesInThread:(NSArray *)genomes {
	
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSLog(previewFolder);	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];

	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"preview.png", nil]];
	[taskEnvironment setObject:pngFileName forKey:@"out"];
		
	NSManagedObjectContext *thisMoc = [[genomes objectAtIndex:0] managedObjectContext];
	
	int i;
	for(i=0; i<[genomes count]; i++) {
		
		NSArray *genome = [NSArray arrayWithObject:[genomes objectAtIndex:i]];
		
		int returnCode = [self runFlam3StillRenderAsTask:[Genome createXMLFromEntities:genome fromContext:thisMoc forThumbnail:YES] withEnvironment:taskEnvironment];
		
		if (returnCode == 0) {
			
			NSDictionary *genomeDict = [NSDictionary dictionaryWithObjectsAndKeys:[genomes objectAtIndex:i], @"genome", pngFileName, @"filename", nil];
			[FlameController performSelectorOnMainThread:@selector(attachImageToGenomeFromDictionary:) withObject:genomeDict waitUntilDone:YES];
			
			
		} else {
			
			NSLog(@"Render Failed");
			
		}
		
	}
	
	
	BOOL returnBool;
	
	if ([fileManager fileExistsAtPath:pngFileName]) {
		returnBool = [fileManager removeFileAtPath:pngFileName handler:nil];
		returnBool = [fileManager removeFileAtPath:previewFolder handler:nil];
	}

	[taskEnvironment release];
	[pool release];
	
}





- (int)runFlam3StillRenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {


	[taskAllFramesIndicator setMaxValue:1.0];
	[taskAllFramesIndicator setDoubleValue:1.0];

	[taskProgressWindow setTitle:@"Rendering Image"];
	[taskProgressWindow makeKeyAndOrderFront:self];
	
	int returnValue =  [Flam3Task runFlam3RenderAsTask:xml withEnvironment:environmentDictionary usingTaskFrameIndicator:taskFrameIndicator];
	
	[taskProgressWindow setIsVisible:NO];

	return returnValue;

}


- (int)runFlam3MovieFrameRenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {

	return [Flam3Task runFlamAnimateAsTask:xml withEnvironment:environmentDictionary usingTaskFrameIndicator:taskFrameIndicator];

}



- (void) setTaskFrameProgress:(NSNumber *)value {

	[taskFrameIndicator setDoubleValue:[value doubleValue]];
	[taskFrameIndicator displayIfNeeded];
	
}  



- (void) createGenomesFromXMLFile:(NSString *)xmlFileName inContext:(NSManagedObjectContext *)thisMoc {
	

	NSArray *newGenomes = [Genome createGenomeEntitiesFromXML:[NSData dataWithContentsOfFile:xmlFileName] inContext:thisMoc]; 
	
	if ([newGenomes count] == 0) {

		NSBeep();
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Open failed, please check the file is a flam3 XML file!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:xmlFileName];
		[finishedPanel runModal];	
		
		return;
	}
	
	[moc performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
	[moc performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
	
	[self generateAllThumbnailsForGenomes:newGenomes];
	
	
}


- (void) appendGenomesFromXMLFile:(NSString *)xmlFileName fromTime:(int)time inContext:(NSManagedObjectContext *)thisMoc{
		

	NSArray *newGenomes = [Genome createGenomeEntitiesFromXML:[NSData dataWithContentsOfFile:xmlFileName] inContext:thisMoc];

	if ([newGenomes count] == 0) {
		
		NSBeep();
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Open failed, please check the file is a flam3 XML file!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:xmlFileName];
		[finishedPanel runModal];	
		
		return;
	}
	
	
	NSEnumerator *genomeEnumerator = [newGenomes objectEnumerator];
	NSManagedObject *genome;
	while ((genome = [genomeEnumerator nextObject])) {
		[genome setValue:[NSNumber numberWithInt:[[genome valueForKey:@"time"] intValue]+time] forKey:@"time"];
	}
	[moc performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
	[self generateAllThumbnailsForGenomes:newGenomes];
	
	
}

- (NSMutableDictionary *)environmentDictionary {

	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
	
	[env setObject:[NSNumber numberWithInt:1] forKey:@"verbose"];
	[env setObject:[NSNumber numberWithInt:environment->qualityScale] forKey:@"qs"];
	[env setObject:[NSNumber numberWithInt:environment->sizeScale] forKey:@"ss"];
	[env setObject:[NSNumber numberWithInt:[environment getIntBits]] forKey:@"bits"];
	[env setObject:[NSNumber numberWithInt:environment->seed] forKey:@"seed"];
	[env setObject:[NSNumber numberWithInt:environment->seed] forKey:@"isaac_seed"];
	[env setObject:[NSNumber numberWithDouble:[environment doubleAspect]] forKey:@"pixel_aspect"];
	
	if(environment->useAlpha == YES) {
		[env setObject:[NSNumber numberWithInt:1] forKey:@"transparency"];
	} else {
		[env setObject:[NSNumber numberWithInt:0] forKey:@"transparency"];
	}

	[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
	
	[env autorelease];
	
	return env;

}



- (NSArray *)passGenomesToLua {
	
	NSArray *genomes = [self fetchGenomes];
	
	if ([genomes count] == 0  ) {
		return [NSArray array];
	}
	
	return [Genome createArrayFromEntities:genomes fromContext:moc];
	
}


- (void)createGenomesFromLua:(NSArray *)genomeArray {
	

	NSArray *newGenomes = [Genome createGenomeEntitiesFromArray:genomeArray inContext:moc];
	
	[moc save:nil];
	
	[self generateAllThumbnailsForGenomes:newGenomes];
	
//	NSLog(@"%@", newGenome);
	
}

- (BOOL)renderGenomeToPng:(NSString *)pngFileName {
	
	[moc lock];
		

	NSArray *genomes;
	
	genomes = [self fetchGenomes];
	if([genomes count] != 1) {
		return NO;
	}
				
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];	
	[taskEnvironment setObject:pngFileName forKey:@"out"];
	
	int returnCode = [self runFlam3StillRenderAsTask:[Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:NO] withEnvironment:taskEnvironment];
	
	[moc unlock];
	[taskEnvironment release];

	if (returnCode != 0) {
		
		return NO;
	}	
	
	return YES;	
}

- (NSArray *)fetchGenomes {
	
	NSArray *genomes;
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
	[fetch setSortDescriptors: sortDescriptors];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	
	[fetch release];	  
	
	return genomes;
	
}

- (void) showPreviewWindow {
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"float_preview"]) {		
		[previewWindow setLevel:NSFloatingWindowLevel];
	} 
	
	[previewWindow makeKeyAndOrderFront:self];
	
}


+ (BOOL)useProgressBar
{

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	NSString *versionString = [dict objectForKey:@"ProductVersion"];
	NSArray *array = [versionString componentsSeparatedByString:@"."];
	int count = [array count];
	int major = (count >= 1) ? [[array objectAtIndex:0] intValue] : 0;
	int minor = (count >= 2) ? [[array objectAtIndex:1] intValue] : 0;
	
	if (major > 10 || major == 10 && minor >= 5) {
		return YES;
	}
	
	return NO;
	
}


- (BOOL )okayToRender {
	
	
	if ([flames getSelectedGenome] == nil) {
		
		NSAlert *dohPanel = [NSAlert alertWithMessageText:@"You have not selected a Genome to Render!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:@"You need to select a Genome in the Genome Window.\nIf there are no Genomes there you can either...\n\nOpen a new one from a file.\nCreate a new by adding a random genome using the + button under the Genome list.\nBreed new ones in the Gene Pool or Breeder and copy them into the Editor using the Edit button."];
		[dohPanel runModal];	
		
		return NO;
	}
	
	return YES;
} 
@end


