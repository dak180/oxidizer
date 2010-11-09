//
//  QTKitController.m
//  oxidizer
//
//  Created by David Burnett on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QTKitController.h"


@implementation QTKitController



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
	
- (void) setExportSettings:(NSDictionary *)newSettings {
	
	if(newSettings != nil) {
		[newSettings retain];		
	}

	
	if(_settings != nil) {
		[_settings release];
	}
	
	_settings = [newSettings objectForKey:@"settings"];
	
	if(_settings != nil) {
		[_settings retain];
	}
	
	if(_subtype != nil) {
		[_subtype release];
	}
	_subtype = [newSettings objectForKey:@"subtype"];
	[_subtype retain];
	
	if(_manufacturer != nil) {
		[_manufacturer release];
	}
	_manufacturer = [newSettings objectForKey:@"manufacturer"];
	[_manufacturer retain];

	
	[self setFileName:[newSettings objectForKey:@"filename"]];
	
	[newSettings release];
	
	return;
	
	
	
}

- (bool) createQTMovie {
	
	NSError *error;
	
	if(_movie != nil) {
		
		[_movie release];
	}
	
	
/*	
	NSString *tmpMovieFile = [NSString pathWithComponents:[NSArray arrayWithObjects:
															NSTemporaryDirectory(),
															[NSString stringWithCString:tempnam([NSTemporaryDirectory() cStringUsingEncoding:NSUTF8StringEncoding], "oxdizier_tmp_movie_") encoding:[NSString defaultCStringEncoding]],
															nil]];
*/
	NSString *tmpMovieFile  = [NSString stringWithCString:tempnam([NSTemporaryDirectory() cStringUsingEncoding:NSUTF8StringEncoding], "oxdizier_tmp_movie_") 
												 encoding:[NSString defaultCStringEncoding]];

	
	_movie = [[QTMovie alloc] initToWritableFile:tmpMovieFile error:&error];
	
	if(error != nil) {
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return YES;
	
}
- (QTMovie *) qtMovie {
	return _movie;
}

- (bool) exportQTMovie {
	
	NSLog (@"%@", _subtype);
	NSLog (@"%@", _manufacturer);
	NSLog (@"%@", _settings);
	
	[_movie updateMovieFile];
	
	NSError *error	= nil;

	
	
	
	bool exportOkay = [_movie writeToFile:_filename withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], QTMovieExport,
																   _subtype, QTMovieExportType,
																   _manufacturer, QTMovieExportManufacturer,
																   _settings, QTMovieExportSettings,
																   nil]
									error:&error];
	
	
	if (!exportOkay) {
		NSLog(@"%@", [error localizedFailureReason]);
		NSLog(@"%@", [error localizedDescription]);
	}
	
	[_movie detachFromCurrentThread];
	[_movie release]; 
	_movie = nil;
	

	return exportOkay;
}



@end
