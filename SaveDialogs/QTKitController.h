//
//  QTKitController.h
//  oxidizer
//
//  Created by David Burnett on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface QTKitController : NSObject {

	@private
	
	NSString *_filename;
	NSNumber *_subtype;
	NSNumber *_manufacturer;

	NSData *_settings;
	
	QTMovie *_movie;
	

	
	
}

- (BOOL) showQuickTimeFileMovieDialogue;
- (void) setFileName:(NSString *)filename;
- (bool) createQTMovie;
- (QTMovie *) qtMovie;
- (bool) exportQTMovie;
- (void) setExportSettings:(NSDictionary *)newSettings;


@end
