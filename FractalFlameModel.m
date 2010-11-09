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
#import "GreaterThanThreeTransformer.h"
#import "ImageFormatIsJPEG.h"
#import "ImageFormatIsPNG.h"
#import "TemporalFilterIsExponent.h"
//#import "QuickTime/QuickTime.h"
#import "Genome/Genome.h"
#import "Genome/GenomeImages.h"

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
		[_stillsParameters setObject:@"PNG" forKey:@"image_format"];
		[_stillsParameters setObject:[NSNumber numberWithInt:90] forKey:@"jpeg_quality"];
		[_stillsParameters setObject:[NSNumber numberWithBool:NO] forKey:@"png_is_16bit"];


		_stillsFormatArray = [NSArray arrayWithObjects:@"PNG", @"JPEG", nil];
		[_stillsFormatArray retain];

		_interpolationTypes = [NSArray arrayWithObjects:@"Log", @"Linear", @"Old", @"Older", nil];
		[_interpolationTypes retain];

		_temporalFilters = [NSArray arrayWithObjects:@"Box", @"Gaussian", @"Exponent", nil];
		[_temporalFilters retain];

		_paletteModes =  [NSArray arrayWithObjects:@"Step", @"Linear", nil];
		[_paletteModes retain];
		
		unsigned int cpuCount ;
		size_t len = sizeof(cpuCount);
		static int mib[2] = { CTL_HW, HW_NCPU };
		
		NSString *threads;
		
		if(sysctl(mib, 2,  &cpuCount, &len, NULL, 0) == 0 && len ==  sizeof(cpuCount)) {
			threads = [NSString stringWithFormat:@"%ld", cpuCount];
		} else {
			threads = @"1";
		}  
		
		defaults = [NSUserDefaults standardUserDefaults];

		NSArray *paths = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
		
		NSString *applicationSupportFolder = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Oxidizer"];
		[[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportFolder attributes:nil];
		
		NSMutableArray *scripts = [NSMutableArray arrayWithCapacity:10];
		[scripts addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"first", @"file_name", @"path", @"file_path", nil]];
   	    [scripts addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"second", @"file_name", @"path2", @"file_path", nil]];
//		[scripts addObject:@"second"];
		
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
									NSUserName(),  @"nick",
									@"http://oxidizer.sf.net", @"url",
									@"Made by Oxidizer", @"comment",
									threads, @"threads",
									[NSNumber numberWithBool:NO], @"save_thumbnails",
									[NSNumber numberWithBool:NO], @"show_render",
									@"1", @"qs",
									@"1", @"ss",
									@"PAL 4:3", @"aspect",
									@"Double", @"buffer_type",
									[NSNumber numberWithBool:NO], @"use_alpha",
									[NSNumber numberWithBool:YES], @"float_preview",
									applicationSupportFolder, @"xml_folder",
									[NSNumber numberWithBool:YES], @"auto_save_on_render",
									[NSNumber numberWithBool:NO], @"render_preview_on_change",									
									[NSNumber numberWithBool:NO], @"limit_quality",									
									[NSNumber numberWithDouble:100.0], @"preview_quality",									
									[NSNumber numberWithDouble:128.0], @"preview_size",		
									scripts, @"MRU_scripts",
									nil]
		 ];
	
		_saveThumbnail = [defaults boolForKey:@"save_thumbnails"];
		
		_showRender = [defaults boolForKey:@"show_render"];
		
		_currentFilename = nil;
		
		
		GreaterThanThreeTransformer *gttt;
  
		gttt = [[[GreaterThanThreeTransformer alloc] init] autorelease];
		
		// register it with the name that we refer to it with
		[NSValueTransformer setValueTransformer:gttt
										forName:@"GreaterThanThree"];
		
		
  
		// create an autoreleased instance of our value transformer
		ImageFormatIsJPEG *ifij = [[[ImageFormatIsJPEG alloc] init] autorelease];
		
		// register it with the name that we refer to it with
		[NSValueTransformer setValueTransformer:ifij
										forName:@"ImageFormatIsJPEG"];
		
		// create an autoreleased instance of our value transformer
		ImageFormatIsPNG *ifip = [[[ImageFormatIsPNG alloc] init] autorelease];
		
		// register it with the name that we refer to it with
		[NSValueTransformer setValueTransformer:ifip
										forName:@"ImageFormatIsPNG"];
		
		TemporalFilterIsExponent *tfie = [[[TemporalFilterIsExponent alloc] init] autorelease];
		
		// register it with the name that we refer to it with
		[NSValueTransformer setValueTransformer:tfie
										forName:@"TemporalFilterIsExponent"];
		
		[NSBundle loadNibNamed:@"FileViews" owner:self];
		[NSBundle loadNibNamed:@"TaskProgress" owner:self];
//		[NSBundle loadNibNamed:@"QuickView" owner:_qvc];
		
		
		
		moc = [[NSManagedObjectContext alloc] init];
		
		
		// create persistant store and init with models main bundle 
		
		coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]]; 
		
		[moc setPersistentStoreCoordinator: coordinator];

/*		
		
		NSString *STORE_TYPE = NSInMemoryStoreType;
		//    NSString *STORE_FILENAME = @"flam3.genome";
		
		NSError *error;
		
		//    NSURL *url = [NSURL fileURLWithPath: [NSTemporaryDirectory() stringByAppendingPathComponent:STORE_FILENAME]];
		
		id newStore = [coordinator addPersistentStoreWithType:STORE_TYPE
												configuration:nil
														  URL:nil
													  options:nil
														error:&error];

*/
		NSError *error;
		
		NSString *appFolder = [defaults stringForKey:@"xml_folder"];
		
				
//		NSLog(@"appFolder %@", [defaults dictionaryRepresentation]);
		NSString *psPath = [appFolder stringByAppendingPathComponent: @"Oxidizer.sqliteO2"];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		[fileManager removeFileAtPath:psPath handler:nil];
		
		
		NSURL *url = [NSURL fileURLWithPath:psPath];
		
		id newStore = [coordinator addPersistentStoreWithType: NSSQLiteStoreType
												configuration: nil
														  URL: url
													  options: nil	
														error: &error];        		
		
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
		[docController retain];

		
		_progressInd = [[NSMutableArray alloc] initWithCapacity:2];

		_saveThumbnail = [defaults boolForKey:@"save_thumbnails"];
		
		_showRender = [defaults boolForKey:@"show_render"];

		_spatialFilterArray = [NSArray arrayWithObjects:@"Gaussian", @"Hermite",@"Box", @"Triangle", @"Bell", 
			                                           @"B-Spline", @"Mitchell", @"Blackman", @"Catrom", @"Hanning", 
			                                           @"Hamming", @"Lanczos2", @"Lanczos3", @"Quadratic", nil];	
	
		_imageSaveController = [[ImageKitController alloc] init];
		
		_qtKitController = [[QTKitController alloc] init];
		
		
	}
	
    return self;
}


- (void)awakeFromNib {

	if(![previewWindow setFrameUsingName:@"render_window"]) {
		[previewWindow center];	
	}

	if(![taskProgressWindow setFrameUsingName:@"render_progress"]) {
		[taskProgressWindow center];	
	}
	
	savePanel = [NSSavePanel savePanel];
	[savePanel retain];
	
	
	[[NSWorkspace sharedWorkspace] launchApplication:[NSString stringWithFormat:@"%@/Oxidizer_QT_Dialog_Server.app", 
													  [[ NSBundle mainBundle ] resourcePath ]]];
	
	
	NSConnection *theConnection;
	
	theConnection = [NSConnection connectionWithRegisteredName:@"OxidizerQTMovieDialog"
														  host:nil];
	_movieDialogServer  = [theConnection rootProxy]; 
	[_movieDialogServer retain];
	
}

- (void)renderToPNG:(int)pngBits {
	
	BOOL doRender = [self okayToRender];
	
	if(doRender == NO) {
		return;
	}

	[savePanel setRequiredFileType:@"png"];
	int runResult = [savePanel runModalForDirectory:nil file:nil];

	
	if(runResult == NSCancelButton || [savePanel filename] == nil) {
		return;
	}
	
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	
	[taskEnvironment setObject:[savePanel filename] forKey:@"out"];
	[taskEnvironment setObject:[NSNumber numberWithInt:pngBits] forKey:@"bpc"];
	

	[NSThread detachNewThreadSelector:@selector(renderToPNGInNewThread:) toTarget:self withObject:taskEnvironment];
	
	
}


- (void)renderToPNGInNewThread:(NSDictionary *)taskEnvironment {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	

	[taskEnvironment retain];
		
	[moc lock];
	
	NSArray *genome = [NSArray arrayWithObject:[flames getSelectedGenome]];
	
	
	NSDate *start = [NSDate date];
	
	
	int returnCode = [self runFlam3StillRenderAsTask:[Genome createXMLFromEntities:genome fromContext:moc forThumbnail:NO] withEnvironment:taskEnvironment];
	
	[moc unlock];

	
	
	if (returnCode == 0) {
	
		if (_showRender) {

			NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[taskEnvironment objectForKey:@"out"]]];
			[previewView setImage:flameImage];
			[previewView setToolTip:@"Preview: This is the image you have just rendered. You can save a copy by dragging the image to the finder/desktop."];
			
			[self  performSelectorOnMainThread:@selector(showPreviewWindow) withObject:nil waitUntilDone:YES];
			[flameImage release];
			
		}
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render finished!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:@"Time for render: %.2f seconds", -[start timeIntervalSinceNow]];
		[finishedPanel runModal];
		
		NSBeep();
	} 
	
		

	[taskEnvironment release];
	[pool release];
	
	return;
	
}

- (void)renderStill {

	BOOL doRender = [self okayToRender];
	
	if(doRender == NO) {
		return;
	}

//	if(doRender == NO) {
//		return;
//	}
	
//	doRender = [qtController showQuickTimeFileImageDialogue];
	doRender = [_imageSaveController showFileImageDialogue:oxidizerWindow delegate:self];
	
                  
//	if(doRender == NO) {
//		return;
//	}

//   [NSThread detachNewThreadSelector:@selector(renderStillInNewThread:) toTarget:self withObject:qtController];
//	[NSThread detachNewThreadSelector:@selector(renderStillInNewThread:) toTarget:self withObject:_imageSaveController];


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

- (void)renderStillInNewThread:(id)qt {

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
		[qt performSelectorOnMainThread:@selector(saveNSImage:) withObject:flameImage waitUntilDone:YES];
		//[qt saveNSImage:flameImage];		
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

//  BOOL doRender = [qtController showQuickTimeFileMovieDialogue];
	
	BOOL doRender  = [_movieDialogServer showQuickTimeFileMovieDialogue];
	
	if(doRender == NO) {
		return;
	}
	
	NSDictionary *movieSettings = [_movieDialogServer getExportDictionary];

    
	[_qtKitController setExportSettings:movieSettings];
	[_qtKitController createQTMovie];
	
	[[_qtKitController qtMovie] detachFromCurrentThread];
	
	[NSThread detachNewThreadSelector:@selector(renderAnimationInNewThread:) toTarget:self withObject:_qtKitController];
	
	

	
	
}



- (void)renderAnimationInNewThread:(QTKitController *)qtkc  {

	
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[qtkc retain];
	
	QTMovie *movie = [qtkc qtMovie];

	[QTMovie enterQTKitOnThread];
	
    [movie attachToCurrentThread];

	QTTime frameDuration = QTMakeTime(1, 30);
	
	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSLog(@"%@", previewFolder);	
	
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
	[sort release];
	[fetch setSortDescriptors: sortDescriptors];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	[fetch release];	  
	
	genome = [genomes objectAtIndex:0];
	
/*	
	[qtController setMovieHeight:[[genome valueForKey:@"height"] intValue] * environment->sizeScale 
						   width:[[genome valueForKey:@"width"] intValue] * environment->sizeScale];
	BOOL doRender = [qtController CreateMovieGWorld];
*/
	
	dtime = 1;

	first_frame = (int) [[genome valueForKey:@"time"] intValue];
	last_frame = (int) [[[genomes lastObject] valueForKey:@"time"] intValue];
		
	if (last_frame < first_frame) {
		last_frame = first_frame;
	}
	
	progressValue = 0.0;

	[taskAllFramesIndicator setMaxValue:(last_frame - first_frame) / dtime];
	[taskAllFramesIndicator setDoubleValue:progressValue];
	
	[taskProgressWindow setTitle:@"Rendering Movie..."];	
	[taskProgressWindow makeKeyOrderFrontAndCount:self];

	
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

			/*
			repArray = [flameImage representations];
			for (imgRepresentationIndex = 0; imgRepresentationIndex < [repArray count]; ++imgRepresentationIndex) {
				
				if ([[repArray objectAtIndex:imgRepresentationIndex] isKindOfClass:[NSBitmapImageRep class]]) {
//					[qtController addNSBitmapImageRepToMovie:[repArray objectAtIndex:imgRepresentationIndex]];
					break;
				}
			}
			*/

			NSAutoreleasePool *looppool = [[NSAutoreleasePool alloc] init];

			[movie addImage:flameImage forDuration:frameDuration withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
																				 @"png ", QTAddImageCodecType,
																				 nil]];
			
			[looppool release];

			
			[flameImage release];
			
		} else {
			
			[taskProgressWindow setIsVisible:NO];
			[pool release];
			return;
			
		}
		
		progressValue += dtime;
	}

	[taskProgressWindow setTitle:@"Writing Movie to Disk..."];
	
//	[qtController performSelectorOnMainThread:@selector(saveMovie) withObject:nil waitUntilDone:YES];

	[qtkc exportQTMovie];
	
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
	

	[QTMovie exitQTKitOnThread];

	[taskEnvironment release];

	[qtkc release];
	
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


	int runResult;
			
	[savePanel setPrompt:@"Render"];
	[savePanel setAccessoryView:_stillsExportView];
	runResult = [savePanel runModal];
	
	if(runResult == NSOKButton && [savePanel filename] != nil) {
		[self didChangeValueForKey:@"prefix"];
		[_stillsParameters setObject:[savePanel filename] forKey:@"prefix"];
		[self didChangeValueForKey:@"prefix"];
		
		[NSThread detachNewThreadSelector:@selector(renderAnimationStillsInNewThread:) toTarget:self withObject:_stillsParameters];
	} else {
		return;
	}	
	
	
	
	
	
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
	if([(NSString *)[parameters objectForKey:@"image_format"] compare:@"PNG"] == 0) {
		[taskEnvironment setObject:@"png" forKey:@"format"];
		if([[parameters objectForKey:@"png_is_16bit"] boolValue]) {
			[taskEnvironment setObject:@"bpc" forKey:@"16"];			
		}
	} else {
		[taskEnvironment setObject:@"jpg" forKey:@"format"];		
		[taskEnvironment setObject:[parameters objectForKey:@"jpeg_quality"] forKey:@"jpeg"];		
	}
	
	
	int ftime;
	
	double progressValue;
	
	NSArray *genomes = [self fetchGenomes];
	

	dtime = 1;
	
	first_frame = (int) [[parameters valueForKey:@"first_frame"] intValue];
	last_frame = (int) [[parameters valueForKey:@"last_frame"] intValue];
	
	if (last_frame < first_frame) {
		last_frame = first_frame;
	}
	
	progressValue = 0.0;
	
	[taskAllFramesIndicator setMaxValue:(last_frame - first_frame) / dtime];
	[taskAllFramesIndicator setDoubleValue:progressValue];
	
	[taskProgressWindow setTitle:@"Rendering Movie..."];	
	[taskProgressWindow makeKeyOrderFrontAndCount:self];
	
	
	NSDate *start = [NSDate date];
	
	NSData *xml = [Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:NO];
	
	
	for (ftime = first_frame; ftime <= last_frame; ftime += dtime) {
		
		/* set time for environment */
		[taskEnvironment setObject:[NSNumber numberWithInt:ftime] forKey:@"frame"];
		
		[taskAllFramesIndicator setDoubleValue:progressValue];
		
		int returnCode = [self runFlam3MovieFrameRenderAsTask:xml withEnvironment:taskEnvironment];
		
		if(returnCode != 0) {
			
			break;
		}

		progressValue += dtime;
	}
	
	[taskEnvironment release];
	
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

- (NSImage *) renderThumbnail {
	
	
	
	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
															NSTemporaryDirectory(),
															[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
															nil]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"thumbnail.png", nil]];
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];	
	
	[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"qs"];
	[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"ss"];
	
	[taskEnvironment setObject:pngFileName forKey:@"out"];
	
	NSArray *genome = [NSArray arrayWithObject:[flames getSelectedGenome]];
	
	
//	NSDate *start = [NSDate date];
	
	int returnCode =  [Flam3Task runFlam3RenderAsTask:[Genome createXMLFromEntities:genome fromContext:moc forThumbnail:YES] 
								 withEnvironment:taskEnvironment 
							     usingTaskFrameIndicator:taskFrameIndicator 
								 usingETALabel:etaTextField];
	

	[taskEnvironment release];
	
	if (returnCode != 0) {
		
		[moc unlock];
		return nil;
	}	
	
	[moc unlock];
	
	NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:pngFileName]];
	
	if ([fileManager fileExistsAtPath:pngFileName]) {
		bool returnBool = [fileManager removeFileAtPath:pngFileName handler:nil];
		returnBool = [fileManager removeFileAtPath:previewFolder handler:nil];
	}	
	
	return [flameImage autorelease];
	
}


- (IBAction)previewCurrentFlame:(id)sender {

	if([defaults  boolForKey:@"render_preview_on_change"] || [sender class] == [NSButton class]) {

		NSDate *start = [NSDate date];
		NSArray *genomes = [NSArray arrayWithObject:[flames getSelectedGenome]];
		[NSThread detachNewThreadSelector:@selector(previewCurrentFlameInThread:) toTarget:self withObject:genomes]; 
		NSLog (@"total: %f", [[NSDate date] timeIntervalSinceDate:start]);
	}
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
	
	NSLog(@"%@", previewFolder);	

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"preview.png", nil]];

//	NSLog(@"%@", pngFileName);
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];	
	[taskEnvironment setObject:pngFileName forKey:@"out"];
	[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"qs"];
	[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"ss"];
	

	NSDate *start = [NSDate date];
	int returnCode = [self runFlam3StillRenderAsTask:[Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:YES] withEnvironment:taskEnvironment];
	NSLog (@"render time: %f", [[NSDate date] timeIntervalSinceDate:start]);
	
	if (returnCode == 0) {

		GenomeImages *images = [[genomes objectAtIndex:0] valueForKey:@"images"];
		
		[images performSelectorOnMainThread:@selector(setImageFromFile:) withObject:pngFileName waitUntilDone:YES];
		
		
		BOOL returnBool;
		
		if ([fileManager fileExistsAtPath:pngFileName]) {
			returnBool = [fileManager removeFileAtPath:pngFileName handler:nil];
			returnBool = [fileManager removeFileAtPath:previewFolder handler:nil];
		}
		
	} else {
		
		NSLog(@"Render Failed");
		
	}
	
	[genomes release];
	
	[pool release];	

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

	if ([sender isKindOfClass:[NSSegmentedControl class]]) {
		
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
		
	} else {
		[flames showFlameWindow];		
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
	[taskProgressWindow makeKeyOrderFrontAndCount:self];
	
	srandom(time(NULL));
	/* generate random XML */
	NSData *newGenome = [BreedingController createRandomGenomeXMLwithEnvironment:[self environmentDictionary]];
	
	NSArray *genomeEntity = [Genome createGenomeEntitiesFromXML:newGenome inContext:context];	

	/* fix up a few values before rendering the flame */
	
	[[genomeEntity objectAtIndex:0] setValue:[NSNumber numberWithInt:50] forKey:@"quality"];
	
	[self generateAllThumbnailsForGenomesInThread:genomeEntity];	
	[context performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
	
	[taskProgressWindow setIsVisible:NO];
	
	return [genomeEntity objectAtIndex:0];

}

- (void)AddEmptyGenomeToFlames {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[moc lock];
	
	NSManagedObject *genome = [self createEmptyGenomeInContext:moc];
	[genome retain];
	
	[flames performSelectorOnMainThread:@selector(addNewFlame:) withObject:genome waitUntilDone:YES];
	
	[moc performSelectorOnMainThread:@selector(processPendingChanges)  withObject:nil waitUntilDone:YES];
	
	[moc unlock];
	
	[genome release];
	
	[pool release];
	
}


- (NSManagedObject *) createEmptyGenomeInContext:(NSManagedObjectContext *)context {
	
	[taskProgressWindow setTitle:@"Generating Empty Genome"];
	[taskProgressWindow makeKeyOrderFrontAndCount:self];
	
	srandom(time(NULL));
	/* generate random XML */
	
	NSArray *genomeEntity = [NSArray arrayWithObject:[Genome createEmptyGnomeInContext:context]];	
	
	/* fix up a few values before rendering the flame */
	
	[[genomeEntity objectAtIndex:0] setValue:[NSNumber numberWithInt:50] forKey:@"quality"];
	
	[self generateAllThumbnailsForGenomesInThread:genomeEntity];	
	[context performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
	
	[taskProgressWindow setIsVisible:NO];
	
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
			[self setCurrentFilename:[savePanel filename]];
		} else {
			return;
		}
	}

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];

	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
	[fetch setSortDescriptors: sortDescriptors];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	
	[sort release];	  
	[fetch release];	  
	
	[[Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:NO] writeToFile:filename atomically:YES];
		
	
	if(_saveThumbnail) {
		NSMutableDictionary *taskEnvironment = [self environmentDictionary];
		[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"qs"];
		[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"ss"];

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



- (void) newFlame {
	
	[self deleteOldGenomes];
	[self AddEmptyGenomeToFlames];
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
		
		[docController noteNewRecentDocumentURL:[NSURL fileURLWithPath:[op filename]]];

		[self createGenomesFromXMLFile:[op filename] inContext:moc];
		
	} 
	
	[self setCurrentFilename:[op filename]];
	[moc save:nil];
	
	return;
	
}


- (void)appendFromFile:(NSString *)filename inContext:(NSManagedObjectContext *)thisMoc{

	int lastTime;
	
	/* get the current flames and find the max time */
	NSArray *genomeArray;
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:thisMoc]];
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
	

	[docController noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];

	
	[self appendGenomesFromXMLFile:filename fromTime:lastTime inContext:thisMoc];
	[moc save:nil];
	
	
	[fetch release];	  
	[sort release];	
	
	
}



- (IBAction)appendFile:(id)sender {
	
	NSOpenPanel *op;
	int runResult;
	
	/* create or get the shared instance of NSSavePanel */
	op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"flam3"];
	
	/* display the NSOpenPanel */
	runResult = [op runModal];
	/* if successful, save file under designated name */
	if(runResult == NSOKButton && [op filename] != nil) {
		
		[self appendFromFile:[op filename] inContext:moc];
		
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
	
	if(filename != nil) {
		[filename retain];		
	}
	
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
	
	NSLog(@"%@", previewFolder);	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];

	[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"qs"];
	[taskEnvironment setObject:[NSNumber numberWithInt:1]  forKey:@"ss"];

	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"preview.png", nil]];
	[taskEnvironment setObject:pngFileName forKey:@"out"];
		
	NSManagedObjectContext *thisMoc = [[genomes objectAtIndex:0] managedObjectContext];
	
	[taskAllFramesIndicator setMaxValue:[genomes count]];
	
	[taskProgressWindow setTitle:@"Rendering Image"];
	[taskProgressWindow performSelectorOnMainThread:@selector(makeKeyOrderFrontAndCount:) withObject:self waitUntilDone:YES];

	
	int i;
	for(i=0; i<[genomes count]; i++) {

		[taskAllFramesIndicator setDoubleValue:i];

		NSArray *genome = [NSArray arrayWithObject:[genomes objectAtIndex:i]];
		
		
		NSDate *reftime = [NSDate date];
		NSData *genomeXML = [Genome createXMLFromEntities:genome fromContext:thisMoc forThumbnail:YES];
		NSLog(@"time to create XML: %f", [[NSDate date] timeIntervalSinceDate:reftime]);
		[genomeXML retain];
		NSDate *reftime2 = [NSDate date];
		
		
		int returnCode = [Flam3Task runFlam3RenderAsTask:genomeXML withEnvironment:taskEnvironment usingTaskFrameIndicator:taskFrameIndicator usingETALabel:etaTextField];
		
//		int returnCode = [self runFlam3StillRenderAsTask:genomeXML withEnvironment:taskEnvironment];
		NSLog(@"time to create thumbnail: %f", [[NSDate date] timeIntervalSinceDate:reftime2]);
		[genomeXML release];
		
		if (returnCode == 0) {
			
			NSDictionary *genomeDict = [NSDictionary dictionaryWithObjectsAndKeys:[genomes objectAtIndex:i], @"genome", pngFileName, @"filename", nil];
			[FlameController performSelectorOnMainThread:@selector(attachImageToGenomeFromDictionary:) withObject:genomeDict waitUntilDone:YES];
			
			
		} else {
			
			NSLog(@"Render Failed");
			
		}
				
	}
	
	[taskProgressWindow setIsVisible:NO];
	
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
	[taskProgressWindow makeKeyOrderFrontAndCount:self];
	
	int returnValue =  [Flam3Task runFlam3RenderAsTask:xml withEnvironment:environmentDictionary usingTaskFrameIndicator:taskFrameIndicator usingETALabel:etaTextField];
	
	[taskProgressWindow setIsVisible:NO];

	return returnValue;

}


- (int)runFlam3MovieFrameRenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {

	return [Flam3Task runFlamAnimateAsTask:xml withEnvironment:environmentDictionary usingTaskFrameIndicator:taskFrameIndicator usingETALabel:etaTextField];

}



- (void) setTaskFrameProgress:(NSNumber *)value {

	[taskFrameIndicator setDoubleValue:[value doubleValue]];
	[taskFrameIndicator displayIfNeeded];
	
}  



- (void) createGenomesFromXMLFile:(NSString *)xmlFileName inContext:(NSManagedObjectContext *)thisMoc {
	

	NSArray *newGenomes = [Genome createGenomeEntitiesFromFile:xmlFileName inContext:thisMoc]; 
	
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
	
	[newGenomes release];
	
	
}


- (void) appendGenomesFromXMLFile:(NSString *)xmlFileName fromTime:(int)time inContext:(NSManagedObjectContext *)thisMoc{
		

	NSArray *newGenomes = [Genome createGenomeEntitiesFromFile:xmlFileName inContext:thisMoc];

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
	[env setObject:[NSNumber numberWithInt:environment->nframes] forKey:@"nframes"];
	
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




- (void)appendGenomesFromLua:(NSArray *)genomeArray {
	

	NSArray *newGenomes = [Genome createGenomeEntitiesFromArray:genomeArray inContext:moc];
	
	[moc save:nil];
	
	[self generateAllThumbnailsForGenomes:newGenomes];
	
//	NSLog(@"%@", newGenome);
	
}


- (void)replaceWithGenomesFromLua:(NSArray *)genomeArray {

	[self deleteGenomes:self];
	[self appendGenomesFromLua:genomeArray];
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

	[sort release];
	
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

- (IBAction)cancelTask:(id)sender {
	
	[taskFrameIndicator setCancel:TRUE];
	
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


- (void)controlTextDidChange:(NSNotification *)aNotification {
		
	objectBeginEdited = [aNotification object];
		
}
- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
	
	/*
	Paste number 56333: NSSlider mouseUp handling
	http://paste.lisp.org/display/56333
	*/
	if(objectBeginEdited != nil) {
		[self previewCurrentFlame:self];		
	}
	
	objectBeginEdited = nil;
	
	
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
	
		[self previewCurrentFlame:self];		
	
}

- (void) makeLoopfromCurrentGenome {

	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];	

	NSData *original = [Genome createXMLFromEntities:[NSArray arrayWithObject:[flames getSelectedGenome]]  fromContext:moc forThumbnail:YES];
	[original retain];
	
	NSString *genomePath = [Flam3Task createTemporaryPathWithFileName:@"original_genome.flam3"];
	[genomePath  retain];
	
	[original writeToFile:genomePath atomically:YES];
	
	[genomePath release];

//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[taskEnvironment setObject:[defaults stringForKey:@"nick"] forKey:@"nick"];	
	[taskEnvironment setObject:[defaults stringForKey:@"url"] forKey:@"url"];	
	[taskEnvironment setObject:genomePath forKey:@"sequence"];
	
//	NSDate *start = [NSDate date];
	NSData *newGenomes = [Flam3Task runFlam3GenomeAsTask:nil withEnvironment:taskEnvironment];
	
	[taskEnvironment release];
	
	if (newGenomes == nil || [newGenomes length] == 0) {
		NSBeep();
		[original release];
		return;
	}
	
	[newGenomes retain];
	[self deleteOldGenomes];
	NSArray *newEntities = [Genome createGenomeEntitiesFromXML:newGenomes inContext:moc];
	[self generateAllThumbnailsForGenomesInThread:newEntities];	
//	[context performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
	[moc processPendingChanges];
	
	[newGenomes release];
	[original release];

}

- (void) makeLoopFromAllGenomes {
	
	NSArray *genomes;
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
	[fetch setSortDescriptors: sortDescriptors];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	  
	[sort release];	
	[fetch release];	  
	
	
	NSMutableDictionary *taskEnvironment = [self environmentDictionary];	
	[taskEnvironment retain];	
	
	NSData *original = [Genome createXMLFromEntities:genomes fromContext:moc forThumbnail:NO];
	[original retain];
		
	NSString *genomePath = [Flam3Task createTemporaryPathWithFileName:@"original_genome.flam3"];
	[genomePath  retain];
	
	[original writeToFile:genomePath atomically:YES];

	[original release];
	
	[genomePath release];

	//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[taskEnvironment setObject:[defaults stringForKey:@"nick"] forKey:@"nick"];	
	[taskEnvironment setObject:[defaults stringForKey:@"url"] forKey:@"url"];	
	[taskEnvironment setObject:genomePath forKey:@"sequence"];
	
	//	NSDate *start = [NSDate date];
	NSData *newGenomes = [Flam3Task runFlam3GenomeAsTask:nil withEnvironment:taskEnvironment];
	
	[taskEnvironment release];
	
	if (newGenomes == nil || [newGenomes length] == 0) {
		NSBeep();
		return;
	}
	
	[newGenomes retain];
	[self deleteOldGenomes];
	NSArray *newEntities = [Genome createGenomeEntitiesFromXML:newGenomes inContext:moc];
	[self generateAllThumbnailsForGenomesInThread:newEntities];	
	//	[context performSelectorOnMainThread:@selector(processPendingChanges) withObject:nil waitUntilDone:YES];
	[moc processPendingChanges];
	
	[newGenomes release];

}

- (void)savePanelDidEnd: (NSSavePanel *)sheet
             returnCode: (int)returnCode
            contextInfo: (void *)contextInfo {
    if (returnCode == NSOKButton) {
		
		[_imageSaveController setFileName:[sheet filename]];
		[NSThread detachNewThreadSelector:@selector(renderStillInNewThread:) toTarget:self withObject:_imageSaveController];
    }
	
	
	
}

- (void) closeMovieServer {
	
	[_movieDialogServer closeServer];
	
}



@end


