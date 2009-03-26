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


#import "QuickTimeController.h"

#define		kVideoTimeScale 	600
#define		kNumVideoFrames 	1
#define		kPixelDepth 		32	/* bit depth */
#define		kNoOffset 			0
#define		kMgrChoose			kPixelDepth
#define		kSyncSample 		0
#define		kAddOneVideoSample	1
#define		kSampleDuration 	30	/* frame duration = 1/10 sec */
#define		kTrackStart			0
#define		kMediaStart			0

#define MOVIE 0
#define IMAGE 1

@implementation QuickTimeController

- init
{
	
    if (self = [super init]) {
		movieComponents = [[NSMutableArray alloc] initWithCapacity:10];
		[self availableComponentsForMovie];
		imageComponents = [[NSMutableArray alloc] initWithCapacity:10];
		[self availableComponentsForImage];
		frameTime = QTMakeTime(30, 600);
//		frameTime = QTMakeTime(0, 0);
		movieDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"tiff" , QTAddImageCodecType,
						[NSNumber numberWithLong:codecHighQuality], QTAddImageCodecQuality,
						nil];
		[movieDict retain];
		
		
		resRefNum = 0;
		resId = movieInDataForkResID;
		
		lastSelectionType = -1;
		lastSelectionIndex = -1;

	}
	return self;
}

- (void) setMovieHeight:(int)height width:(int)width {
	
	movieRect.top = 0;
	movieRect.left = 0;
	movieRect.bottom = height;
	movieRect.right = width;

}
- (BOOL) showQuickTimeFileMovieDialogue {

	int runResult;

	useDefaultSettings = YES;

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setPrompt:@"Render"];
	[savePanel setAccessoryView:movieExportPanel];
	runResult = [savePanel runModal];
	
	if(runResult == NSOKButton && [savePanel filename] != nil) {
		filename = [savePanel filename];
		[filename retain];
		
	}  else {
	
		filename = nil;
		return NO;
	}
	
	return YES;

}

-(BOOL) CreateMovieGWorld {

	OSErr outErr;
		Handle  dataRefH    = nil;
		OSType  dataRefType;
	

			// generate a name for our movie file
		NSString *tempName = [NSString stringWithCString:tempnam(nil, "oxidizer_qt_temp_") encoding:[NSString defaultCStringEncoding]];
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
	
		movieTrack = NewMovieTrack (tempMovie, FixRatio(movieRect.right,1), FixRatio(movieRect.bottom,1), kNoVolume);
			
		outErr = GetMoviesError();
		if (outErr != noErr) {
			return NO;
		}
			
		movieMedia = NewTrackMedia (movieTrack, VideoMediaType, kVideoTimeScale, nil,	0);

		outErr = GetMoviesError();
		if (outErr != noErr) {
			return NO;
		}

		outErr = BeginMediaEdits (movieMedia);
		if (outErr != noErr) {
			return NO;
		}

		long maxCompressedSize;

		// Create a graphics world
		outErr = QTNewGWorld (&movieGWorld, k32ARGBPixelFormat, &movieRect, nil, nil,	(GWorldFlags)0);	/* flags */
		if (outErr != noErr) {
			return NO;
		}

		// Lock the pixels
		LockPixels (GetGWorldPixMap(movieGWorld));

		// Determine the maximum size the image will be after compression.
		// Specify the compression characteristics, along with the image.
		outErr = GetMaxCompressionSize(GetGWorldPixMap(movieGWorld), &movieRect, kMgrChoose, codecHighQuality, kAnimationCodecType,	 (CompressorComponent)anyCodec, &maxCompressedSize);		    	/* returned size */
		if (outErr != noErr) {
			return NO;
		}
		// Create a new handle of the right size for our compressed image data
		compressedData = NewHandle(maxCompressedSize);
		outErr = GetMoviesError();
		if (outErr != noErr) {
			return NO;
		}
		
		
		MoveHHi( compressedData );
		HLock( compressedData );
		compressedDataPtr = *compressedData;

		// Create a handle for the Image Description Structure
		imageDesc = (ImageDescriptionHandle)NewHandle(4);
		outErr = GetMoviesError();
		if (outErr != noErr) {
			return NO;
		}
		
		// Change the current graphics port to the GWorld
		GetGWorld(&oldPort, &oldGDeviceH);
		SetGWorld(movieGWorld, nil);


	
	return YES;

}

- (BOOL) showQuickTimeFileImageDialogue {

	int runResult;

	useDefaultSettings = YES;

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setPrompt:@"Render"];
	[savePanel setAccessoryView:imageExportPanel];
	runResult = [savePanel runModal];
	
	if(runResult == NSOKButton && [savePanel filename] != nil) {
		filename = [savePanel filename];
		[filename retain];
	} else {
		filename = nil;
		return NO;
	}
	
	return YES;
}

- (BOOL) showQuickTimeFileStillsDialogue {
	
	int runResult;
	
	useDefaultSettings = YES;
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setPrompt:@"Render"];
	[savePanel setAccessoryView:stillsExportPanel];
	runResult = [savePanel runModal];
	
	if(runResult == NSOKButton && [savePanel filename] != nil) {
		filename = [savePanel filename];
		[filename retain];
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
	Component c;
	ComponentResult err;
	MovieExportComponent exporter;
	QTAtom tmplAtom = 0;
	QTAtom videAtom = 0;
   SCTemporalSettings temporalSetting;

	
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
	
	lastSelectionType = MOVIE;
	lastSelectionIndex = selectionIndex;
	
	videAtom = QTFindChildByID(settings, kParentAtomIsContainer, kQTSettingsVideo, 1, NULL );
	tmplAtom = QTFindChildByID(settings, videAtom, scTemporalSettingsType, 1, NULL );
	QTGetAtomDataPtr(settings, tmplAtom, nil, 
                                    (Ptr *)&temporalSetting);
	
	float framerate = FixedToFloat(temporalSetting.frameRate);

	err = SCGetInfo (exporter, scTemporalSettingsType, &temporalSetting);


	framerate = FixedToFloat(temporalSetting.frameRate);

		
	if(movieExportSettings != nil) {
		[movieExportSettings release];
	}
	
	movieExportSettings = [NSData dataWithBytes:*settings length:GetHandleSize(settings)];
	[movieExportSettings retain];

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
	

	if(lastSelectionType != IMAGE || lastSelectionIndex != componentIndex) {
		CloseComponent(geExporter);
        geExporter = NULL;
	} 
	
	if(geExporter == NULL) {
		geExporter = OpenComponent(c);				
	} 
	
	lastSelectionType = IMAGE;
	lastSelectionIndex = componentIndex;

	if(CallComponentCanDo(geExporter, kGraphicsExportRequestSettingsSelect)) {
		err = GraphicsExportRequestSettings(geExporter, NULL, NULL);
		if(err != noErr) {
			NSLog(@"Got error %d when calling GraphicsExportRequestSettings", err);
//			CloseComponent(geExporter);
//			geExporter = NULL;
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

	OSErr err;

    UnlockPixels (GetGWorldPixMap(movieGWorld)/*GetPortPixMap(theGWorld)*/);

    SetGWorld (oldPort, oldGDeviceH);

    // Dealocate our previously alocated handles and GWorld
    if (imageDesc) {
        DisposeHandle ((Handle)imageDesc);
    }

    if (compressedData) {
        DisposeHandle (compressedData);
    }

    if (movieGWorld) {
        DisposeGWorld (movieGWorld);
    }
	

    err = EndMediaEdits (movieMedia);

    err = InsertMediaIntoTrack (movieTrack,		/* track specifier */
        kTrackStart,	/* track start time */
        kMediaStart, 	/* media start time */
        GetMediaDuration(movieMedia), /* media duration */
        fixed1);		/* media rate ((Fixed) 0x00010000L) */

			
	int componentIndex = [movieExportController selectionIndex];
	NSDictionary *component = [movieComponents objectAtIndex:componentIndex];
	
	Component c;
	MovieExportComponent exporter;
		
		
	memcpy(&c, [[component objectForKey:@"component"] bytes], sizeof(c));

	exporter = OpenComponent(c);
	
	if(useDefaultSettings == NO) {

		ComponentResult err;
		err = MovieExportSetSettingsFromAtomContainer(exporter, settings);

	}
	

    err = AddMovieResource (tempMovie, resRefNum, &resId, nil);


	if (movieDataHandlerRef) {
		CloseMovieStorage(movieDataHandlerRef);
	}
	
	FSSpec spec = [QuickTimeController getToFSSpecFromPath:filename];

    ConvertMovieToFile (tempMovie,     /* identifies movie */
    0,                /* all tracks */
    &spec,                /* no output file */
    0,                  /* no file type */
    0,                  /* no creator */
    -1,                 /* script */
    0,                /* no resource ID */
    createMovieFileDeleteCurFile |
    movieToFileOnlyExport,
    exporter);

	err =GetMoviesError();

    if (settings) {
        DisposeHandle (settings);
    }	

	CloseComponent(exporter);
	
	return;

	
}

-(void) saveNSImage:(NSImage *)image {

	Component c;
	Component gec;
	ComponentResult cErr;

	unsigned long actualSizeWritten;
	
	NSData *tiff;

	
	tiff = [[image TIFFRepresentation] retain];
	
	MovieImportComponent tiffImportComponent = OpenDefaultComponent( GraphicsImporterComponentType, kQTFileTypeTIFF );
	
	PointerDataRef dataReference = (PointerDataRef)NewHandle( sizeof(PointerDataRefRecord) );
	
	(**dataReference).data = (void *) [tiff bytes];
	(**dataReference).dataLength = [tiff length];
	
	cErr = GraphicsImportSetDataReference( tiffImportComponent, (Handle)dataReference, PointerDataHandlerSubType );
	if(cErr != noErr) {	
		NSLog(@"GraphicsImportSetDataReference failed with error %ld", cErr);
		[tiff release];
		return;
	}	

	int componentIndex = [imageExportController selectionIndex];
	
	memcpy(&c, [[[imageComponents objectAtIndex:componentIndex] objectForKey:@"component"] bytes], sizeof(c));

/*
	Handle theText;
	cErr = GraphicsExportGetSettingsAsText (geExporter, &theText );
*/
	
	if(geExporter == NULL) {
		int index = [imageExportController selectionIndex];
		memcpy(&gec, [[[imageComponents objectAtIndex:index] objectForKey:@"component"] bytes], sizeof(c));
		geExporter = OpenComponent(gec);
	}
	
				
	cErr = GraphicsExportSetInputGraphicsImporter (geExporter, tiffImportComponent);
	if(cErr != noErr) {	
		NSLog(@"GraphicsExportSetInputGraphicsImporter failed with error %ld", cErr);

		[tiff release];
		CloseComponent(tiffImportComponent);
		return;
	}
	
	
	FSSpec spec = [QuickTimeController getToFSSpecFromPath:filename];
	
	cErr = GraphicsExportSetOutputFile(geExporter, &spec);
	if(cErr != noErr) {	
		NSLog(@"GraphicsExportSetOutputFile failed with error %ld", cErr);
		[tiff release];
		CloseComponent(tiffImportComponent);
		return;
	}
	cErr = GraphicsExportDoExport (geExporter, &actualSizeWritten );
	if(cErr != noErr) {	
		NSLog(@"GraphicsExportDoExport failed with error %ld", cErr);
		[tiff release];
		CloseComponent(tiffImportComponent);
		return;
	}
	
	if(actualSizeWritten == 0) {
		NSLog(@"GraphicsExportDoExport wrote %ld bytes", actualSizeWritten);		
		[tiff release];
		CloseComponent(tiffImportComponent);
		return;
	}
	
	[tiff release];

//	CloseComponent(geExporter);
//	geExporter = NULL;
	CloseComponent(tiffImportComponent);
	

}


- (void) addNSBitmapImageRepToMovie:(NSBitmapImageRep *)imageRepresentation {

    PixMapHandle 	pixMapHandle;
    unsigned char *pixBaseAddr;
	OSErr err;

    // Lock the pixels
    pixMapHandle = GetGWorldPixMap(movieGWorld);
    LockPixels (pixMapHandle);
    pixBaseAddr = (unsigned char *)GetPixBaseAddr(pixMapHandle);

	unsigned char * bitMapDataPtr = [imageRepresentation bitmapData];

	if ((bitMapDataPtr != nil) && (pixBaseAddr != nil)) {
		int i,j;
		int pixmapRowBytes = GetPixRowBytes(pixMapHandle);
		NSSize imageSize = [(NSBitmapImageRep *)imageRepresentation size];
		for (i=0; i< imageSize.height; i++) {
			unsigned char *src = bitMapDataPtr + i * [(NSBitmapImageRep *)imageRepresentation bytesPerRow];
			unsigned char *dst = pixBaseAddr + i * pixmapRowBytes;
			for (j = 0; j < imageSize.width; j++) {
 /* alpha */	dst[0] = src[3]; 
 /* red */		dst[1] = src[0];  
 /* green */	dst[2] = src[1];
 /* blue */		dst[3] = src[2];
				dst+=4;
				src+=4;
//				*dst++ =  *src++;		// X - our src is 24-bit only
//				*dst++ = 255;		// X - our src is 24-bit only
//				*dst++ = *src++;	// Red component
//				*dst++ = *src++;	// Green component
//				*dst++ = *src++;	// Blue component
			}
		}
	}
   
    UnlockPixels(pixMapHandle);

        // Use the ICM to compress the image
        err = CompressImage(GetGWorldPixMap(movieGWorld), &movieRect, codecHighQuality,	kAnimationCodecType,imageDesc, compressedDataPtr);	/* pointer to a location to recieve the compressed image data */
		if(err != noErr) {
			NSLog(@"Got error %d when calling CompressImage", err);
			return;
		}
        // Add sample data and a description to a media
        err = AddMediaSample(movieMedia, compressedData, kNoOffset, (**imageDesc).dataSize,  kSampleDuration,  
						     (SampleDescriptionHandle)imageDesc, kAddOneVideoSample, kSyncSample, nil);	
		if(err != noErr) {
			NSLog(@"Got error %d when calling AddMediaSample", err);
			return;
		}
 
}


- (NSString *) fileName {
	return filename;
}

+ (FSSpec)getToFSSpecFromPath:(NSString *)path { 

 	FSRef ref;
 	FSSpec spec;
	NSFileManager *nsfm;
	
	BOOL returnBool;

	nsfm = [NSFileManager defaultManager];
	if(![nsfm fileExistsAtPath:path]){
		returnBool = [nsfm removeFileAtPath:path handler:nil];
		[nsfm createFileAtPath:path contents:nil attributes:nil];

	} else {
		
		returnBool = [nsfm removeFileAtPath:path handler:nil];
		[nsfm createFileAtPath:path contents:nil attributes:nil];
		
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
