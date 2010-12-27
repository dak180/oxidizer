//
//  QTKitController.m
//  oxidizer
//
//  Created by David Burnett on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QTKitController.h"


@implementation QTKitController


- init {

	if (self = [super init]) {

		movieComponents = [[NSMutableArray alloc] initWithCapacity:10];
		[self availableComponents];
		_usePreviousSettings = NO;
		_savePanel = [NSSavePanel savePanel];
		[_savePanel retain];
	}

	return self;
}



- (BOOL) showQuickTimeFileMovieDialogue {

	int runResult;

//	NSSavePanel *savePanel = [NSSavePanel savePanel];

	[_savePanel setPrompt:@"Render"];
	[_savePanel setAccessoryView:movieExportPanel];

	int index = [movieExportController selectionIndex];
	NSDictionary *componentDictionary = [movieComponents objectAtIndex:index];
	[_savePanel setRequiredFileType:[componentDictionary objectForKey:@"extension"]];

	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

	runResult = [_savePanel runModal];

	if(runResult == NSOKButton && [_savePanel filename] != nil) {
		[self setFileName:[_savePanel filename]];

	}  else {
		[self setFileName:nil];
		return NO;
	}

	return YES;

}

- (NSArray *)availableComponents {

	NSMutableArray			*results = nil;
	ComponentDescription	cd = {};
	Component				c = NULL;
	ComponentResult			err;

	Handle					nameHandle = NewHandle(0);
	OSType					mediaType;

	if ( nameHandle == NULL )
		return( nil );

	cd.componentType = MovieExportType;
	cd.componentSubType = 0;
	cd.componentManufacturer = 0;
	cd.componentFlags = canMovieExportFiles;
	cd.componentFlagsMask = canMovieExportFiles;

	while((c = FindNextComponent(c, &cd))) 	{

		err = MovieExportGetSourceMediaType ((MovieExportComponent )c, &mediaType );
		if(err == noErr) {

			ComponentDescription exportCD;

			switch(mediaType) {
				case SoundMediaType:
				case TextMediaType:
					break;
				default:

					if ( GetComponentInfo( c, &exportCD, nameHandle, NULL, NULL ) == noErr ) {
						HLock( nameHandle );
						NSString	*nameStr = [[[NSString alloc] initWithBytes:(*nameHandle)+1 length:(int)**nameHandle encoding:NSMacOSRomanStringEncoding] autorelease];
						HUnlock( nameHandle );

						int extension;
						MovieExportGetFileNameExtension((MovieExportComponent) c, (OSType *) & extension);
						extension = EndianU32_NtoB(extension);
						NSString *extensionStr = [[NSString alloc] initWithBytes:&extension length:sizeof(int) encoding:NSMacOSRomanStringEncoding];

						NSNumber *type = [NSNumber numberWithLong:exportCD.componentType];
						NSNumber *subType = [NSNumber numberWithLong:exportCD.componentSubType];
						NSNumber *manufacturer = [NSNumber numberWithLong:exportCD.componentManufacturer];


						NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
													nameStr, @"name",
													[[extensionStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString], @"extension",
													[NSData dataWithBytes:&c length:sizeof(c)], @"component",
													type, @"type",
													subType, @"subtype",
													manufacturer, @"manufacturer", nil];

						[movieComponents addObject:dictionary];

						[extensionStr release];
					}
			}
		}
	}

	DisposeHandle( nameHandle );

	NSLog(@"%@", movieComponents);

	[_savePanel setRequiredFileType:[[movieComponents objectAtIndex:[movieExportController selectionIndex]] objectForKey:@"extension"]];


	return results;
}

- (IBAction) getExportSettings: (id) sender {

	Component c;
	int index = [movieExportController selectionIndex];
	NSDictionary *componentDictionary = [movieComponents objectAtIndex:index];

	memcpy(&c, [[componentDictionary objectForKey:@"component"] bytes], sizeof(c));

	MovieExportComponent exporter = OpenComponent(c);
	Boolean canceled;

	if (_usePreviousSettings) {
		MovieExportSetSettingsFromAtomContainer(exporter, _settings);
	}

	ComponentResult err = MovieExportDoUserDialog(exporter, NULL, NULL, 0, 0, &canceled);
	if(err)
	{
		NSLog(@"Got error %d when calling MovieExportDoUserDialog",err);
		CloseComponent(exporter);
		return;
	}
	if(canceled)
	{
		CloseComponent(exporter);
		return;
	}

	_usePreviousSettings = YES;

	err = MovieExportGetSettingsAsAtomContainer(exporter, &_settings);
	if(err)
	{
		NSLog(@"Got error %d when calling MovieExportGetSettingsAsAtomContainer",err);
		CloseComponent(exporter);
		return;
	}


	_subtype = [componentDictionary objectForKey:@"subtype"];
	_manufacturer = [componentDictionary objectForKey:@"manufacturer"];



	CloseComponent(exporter);

	return;
}

- (void)setFileName:(NSString *)filename {

	if(filename != nil) {
		[filename retain];
	}

	if(_filename != nil) {
		[_filename release];
	}

	_filename = filename;

	return;
}


- (NSDictionary *)getExportDictionary {

	// encode the QTATomContainer as NSData
//	NSData *settings = [NSData dataWithBytes:&_settings length:GetHandleSize(_settings)];

	if(_usePreviousSettings == NO) {
		Component c;
		int index = [movieExportController selectionIndex];
		NSDictionary *componentDictionary = [movieComponents objectAtIndex:index];

		memcpy(&c, [[componentDictionary objectForKey:@"component"] bytes], sizeof(c));

		MovieExportComponent exporter = OpenComponent(c);

		ComponentResult err = MovieExportGetSettingsAsAtomContainer(exporter, &_settings);
		if(err)
		{
			NSLog(@"Got error %d when calling MovieExportGetSettingsAsAtomContainer",err);
			CloseComponent(exporter);
			return nil;
		}

		_subtype = [componentDictionary objectForKey:@"subtype"];
		_manufacturer = [componentDictionary objectForKey:@"manufacturer"];

	}


	NSData *settings = [NSData dataWithBytes:*_settings length:GetHandleSize(_settings)];

	NSDictionary *settingsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:settings, @"settings",
																				  _filename, @"filename",
																				  _subtype, @"subtype",
										                                          _manufacturer, @"manufacturer",
																				  nil];

	return settingsDictionary;

}

- (IBAction) changeMovieFileType:(id )sender {

	int index = [movieExportController selectionIndex];
	NSDictionary *componentDictionary = [movieComponents objectAtIndex:index];

	[_savePanel setRequiredFileType:[componentDictionary objectForKey:@"extension"]];
	_subtype = [componentDictionary  objectForKey:@"subtype"];
	_manufacturer = [componentDictionary  objectForKey:@"manufacturer"];

	_usePreviousSettings = NO;


}

@end
