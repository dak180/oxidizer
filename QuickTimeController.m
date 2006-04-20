//
//  QuickTimeController.m
//  oxidizer
//
//  Created by David Burnett on 14/04/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "QuickTimeController.h"


@implementation QuickTimeController

- init
{
	
    if (self = [super init]) {
		movieComponents = [[NSMutableArray alloc] initWithCapacity:10];
		[self availableComponentsForMovie];
		imageComponents = [[NSMutableArray alloc] initWithCapacity:10];
		[self availableComponentsForImage];
		frameTime = QTMakeTime(30, 60);
		movieDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"tiff" , QTAddImageCodecType,
						[NSNumber numberWithLong:codecHighQuality], QTAddImageCodecQuality,
						nil];
		[movieDict retain];

	}
	return self;
}


- (BOOL) showQuickTimeFileMovieDialogue {

	int runResult;

	OSErr outErr;
	useDefaultSettings = YES;

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAccessoryView:movieExportPanel];
	runResult = [savePanel runModal];
	
	if(runResult == NSOKButton && [savePanel filename] != nil) {

		Handle  dataRefH    = nil;
		OSType  dataRefType;
	

			// generate a name for our movie file
		NSString *tempName = [NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]];
		if (nil == tempName) {
			return NO;
		}


		// create a file data reference for our movie
		outErr = QTNewDataReferenceFromFullPathCFString((CFStringRef)tempName,
							  kQTNativeDefaultPathStyle,
							  0,
							  &dataRefH,
							  &dataRefType);
		if (outErr != noErr) {
			return NO;
		}


		// create a QuickTime movie from our file data reference
		tempMovie  = nil;
		CreateMovieStorage (dataRefH,
				dataRefType,
				'TVOD',
				smSystemScript,
				newMovieActive, 
				&movieDataHandlerRef,
				&tempMovie);
				
		outErr = GetMoviesError();
		if (outErr != noErr) {
			return NO;
		}
	
		qtMovie = [QTMovie movieWithQuickTimeMovie:tempMovie disposeWhenDone:YES error:nil];
		[qtMovie retain];	
		[qtMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];

		filename = [savePanel filename];
		
		
	}  else {
	
		filename = nil;
		return NO;
	}
	
	return YES;

}

- (BOOL) showQuickTimeFileImageDialogue {

	int runResult;

	useDefaultSettings = YES;

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAccessoryView:imageExportPanel];
	runResult = [savePanel runModal];
	
	if(runResult == NSOKButton && [savePanel filename] != nil) {
		filename = [savePanel filename];
	} else {
		filename = nil;
		return NO;
	}
	
	return YES;
}


- (void) availableComponentsForMovie {
	
	ComponentDescription cd;
	Component c;
	ComponentResult err;
	OSType mediaType; 
	
	cd.componentType = MovieExportType;

	cd.componentSubType = 0;
	cd.componentManufacturer = 0;
	cd.componentFlags = canMovieExportFiles;
	cd.componentFlagsMask = canMovieExportFiles | movieImportSubTypeIsFileExtension;
	
	
	[movieComponents removeAllObjects];
	
	while((c = FindNextComponent(c, &cd)))
	{
		
		err = MovieExportGetSourceMediaType ((MovieExportComponent )c, &mediaType );
		if(err == noErr) { 
			
			Handle name = NewHandle(4);
			ComponentDescription exportCD;

			switch(mediaType) {
				case SoundMediaType:
				case TextMediaType:
					break;
				default:	
					if (GetComponentInfo(c, &exportCD, name, nil, nil) == noErr) {
						unsigned char *namePStr = (unsigned char *)*name;
						NSString *nameStr = [[NSString alloc] initWithBytes:&namePStr[1] length:namePStr[0] encoding:NSMacOSRomanStringEncoding];
						
						NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
							nameStr, @"name",
							[NSData dataWithBytes:&c length:sizeof(c)], @"component",
							[NSNumber numberWithLong:exportCD.componentType], @"type",
							[NSNumber numberWithLong:exportCD.componentSubType], @"subtype",
							[NSNumber numberWithLong:exportCD.componentManufacturer], @"manufacturer",
							nil];
						[movieComponents addObject:dictionary];
						[nameStr release];
						DisposeHandle(name);

					}
			}
		}
	}
	return;
}

- (void) availableComponentsForImage {
	
	ComponentDescription cd;
	Component c;
	
	cd.componentType = GraphicsExporterComponentType;
	cd.componentSubType = 0;
	cd.componentManufacturer = 0;
	cd.componentFlags = 0;
	cd.componentFlagsMask = graphicsExporterIsBaseExporter;
	
	[imageComponents removeAllObjects];
	
	while((c = FindNextComponent(c, &cd)))
	{
		Handle name = NewHandle(4);
		ComponentDescription exportCD;
		
		if (GetComponentInfo(c, &exportCD, name, nil, nil) == noErr)
		{
			unsigned char *namePStr = (unsigned char *)*name;
			NSString *nameStr = [[NSString alloc] initWithBytes:&namePStr[1] length:namePStr[0] encoding:NSMacOSRomanStringEncoding];
			
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
				nameStr, @"name",
				[NSData dataWithBytes:&c length:sizeof(c)], @"component",
				[NSNumber numberWithLong:exportCD.componentType], @"type",
				[NSNumber numberWithLong:exportCD.componentSubType], @"subtype",
				[NSNumber numberWithLong:exportCD.componentManufacturer], @"manufacturer",
				nil];
			[imageComponents addObject:dictionary];
			[nameStr release];
		}
		
		DisposeHandle(name);
	}
}

- (IBAction) getMovieExportSettings:(id )sender {

	Boolean canceled;
	QTAtomContainer settings;
	Component c;
	ComponentResult err;
	MovieExportComponent exporter;
	
	int componentIndex = [movieExportController selectionIndex];
	
	memcpy(&c, [[[movieComponents objectAtIndex:componentIndex] objectForKey:@"component"] bytes], sizeof(c));
//	[movieDict setObject:[[movieComponents objectAtIndex:componentIndex] objectForKey:@"subtype"] forKey:QTAddImageCodecType];
	
	exporter = OpenComponent(c);
	err = MovieExportGetSettingsAsAtomContainer(exporter, &settings);
	err = MovieExportDoUserDialog(exporter, NULL, NULL, 0, 0, &canceled);
	
	if(err) {
		NSLog(@"Got error %d when calling MovieExportDoUserDialog", err);
		CloseComponent(exporter);
		return;
	}
	if(canceled) {
		CloseComponent(exporter);
		return;
	}
	
	err = MovieExportGetSettingsAsAtomContainer(exporter, &settings);
	if(err) {
		NSLog(@"Got error %d when calling MovieExportGetSettingsAsAtomContainer");
		CloseComponent(exporter);
		return;
	}
	
	if(movieExportSettings != nil) {
		[movieExportSettings release];
	}
	
	movieExportSettings = [NSData dataWithBytes:*settings length:GetHandleSize(settings)];
	[movieExportSettings retain];

	DisposeHandle(settings);

	CloseComponent(exporter);
	
	useDefaultSettings = NO;

	
	return;

}

- (IBAction) getImageExportSettings:(id )sender {

	Boolean canceled;
	Component c;
	ComponentResult err;
	
	int componentIndex = [imageExportController selectionIndex];
	
	memcpy(&c, [[[imageComponents objectAtIndex:componentIndex] objectForKey:@"component"] bytes], sizeof(c));
	

	geExporter = OpenComponent(c);

	if(CallComponentCanDo(geExporter, kGraphicsExportRequestSettingsSelect)) {
		err = GraphicsExportRequestSettings(geExporter, NULL, NULL);
		if(err != noErr) {
			NSLog(@"Got error %d when calling GraphicsExportRequestSettings", err);
			CloseComponent(geExporter);
			return;
		}
	}

/*
	Handle theText;
	err = GraphicsExportGetSettingsAsText (geExporter, &theText );
*/


	return;
}


- (void) saveMovie {

	int componentIndex = [movieExportController selectionIndex];
	NSDictionary *component = [movieComponents objectAtIndex:componentIndex];
	
	if(useDefaultSettings) {
		QTAtomContainer settings;
		Component c;
		ComponentResult err;
		MovieExportComponent exporter;
		
		int componentIndex = [movieExportController selectionIndex];
		
		memcpy(&c, [[[movieComponents objectAtIndex:componentIndex] objectForKey:@"component"] bytes], sizeof(c));

		exporter = OpenComponent(c);
		err = MovieExportGetSettingsAsAtomContainer(exporter, &settings);
		
		if(movieExportSettings != nil) {
			[movieExportSettings release];
		}
		
		movieExportSettings = [NSData dataWithBytes:*settings length:GetHandleSize(settings)];
		
		[movieExportSettings retain];
		
		DisposeHandle(settings);

		CloseComponent(exporter);

	}
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], QTMovieExport,
		[component objectForKey:@"subtype"], QTMovieExportType,
		[component objectForKey:@"manufacturer"], QTMovieExportManufacturer,
//		[NSNumber numberWithBool:YES], QTMovieFlatten,
		movieExportSettings, QTMovieExportSettings,
		nil];
		
	/* there's no turning back now */
	[[NSFileManager defaultManager] removeFileAtPath:filename handler:nil];	

	
	BOOL result = [qtMovie writeToFile:filename withAttributes:attributes];
	if(!result)
	{
		NSLog(@"Couldn't write movie to file");
		return;
	}
	
	if (movieDataHandlerRef) {
		CloseMovieStorage(movieDataHandlerRef);
	}
	
	[qtMovie release];	

	return;

	
}

-(void) saveNSBitmapImageRep:(NSBitmapImageRep *)rep {

	Component c;
	ComponentResult cErr;

	unsigned long actualSizeWritten;
	
	NSData *tiff;

	
	tiff = [[rep TIFFRepresentation] retain];
	
	MovieImportComponent tiffImportComponent = OpenDefaultComponent( GraphicsImporterComponentType, kQTFileTypeTIFF );
	
	PointerDataRef dataReference = (PointerDataRef)NewHandle( sizeof(PointerDataRefRecord) );
	
	(**dataReference).data = (void *) [tiff bytes];
	(**dataReference).dataLength = [tiff length];
	
	GraphicsImportSetDataReference( tiffImportComponent, (Handle)dataReference, PointerDataHandlerSubType );
	
	int componentIndex = [imageExportController selectionIndex];
	
	memcpy(&c, [[[imageComponents objectAtIndex:componentIndex] objectForKey:@"component"] bytes], sizeof(c));

/*
	Handle theText;
	cErr = GraphicsExportGetSettingsAsText (geExporter, &theText );
*/
		
	cErr = GraphicsExportSetInputGraphicsImporter (geExporter, tiffImportComponent);
	
	FSSpec spec = [QuickTimeController getToFSSpecFromPath:filename];
	
	cErr = GraphicsExportSetOutputFile(geExporter, &spec);
	cErr = GraphicsExportDoExport (geExporter, &actualSizeWritten );
		
	CloseComponent(geExporter);
	CloseComponent(tiffImportComponent);
	

}


- (void) addNSImageToMovie:(NSImage *)image {

		[qtMovie addImage:image forDuration:frameTime withAttributes:movieDict];	

}

+ (FSSpec)getToFSSpecFromPath:(NSString *)path { 

 	FSRef ref;
 	FSSpec spec;
	NSFileManager *nsfm;

	nsfm = [NSFileManager defaultManager];
	if(![nsfm fileExistsAtPath:path]){
		FILE *file = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "wb");
		fclose(file);
	}
	
//	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
	CFURLRef url = CFURLCreateFromFileSystemRepresentation(
						kCFAllocatorDefault, 
						(const UInt8 *)[path cStringUsingEncoding:NSUTF8StringEncoding],
						[path lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
						false);
						
/*	
	NSURL *cocoaurl;
	cocoaurl = url;
*/						
 	OSErr err = noErr;
 	
 	if(!CFURLGetFSRef((CFURLRef)url, &ref))
 		NSLog(@"error %d occured when creating the FSRef", err); 	else
 	{
 		err = FSGetCatalogInfo(&ref, kFSCatInfoNone, NULL, NULL, &spec, NULL);
 		if(err != noErr)
 			NSLog(@"error %d occured when getting the FSSpec", err);
 	}
 	CFRelease(url);
 	return spec;
 }

@end
