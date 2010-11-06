//
//  ImageKitController.h
//  oxidizer
//
//  Created by David Burnett on 29/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface ImageKitController : NSObject {
	

	NSSavePanel *_savePanel;
	IKSaveOptions *_saveOptions;
	NSMutableDictionary *_imageProperties;
	NSString *_imageUTType;	
	NSString *_filename;
}


- (BOOL) showFileImageDialogue:(NSWindow *)owner delegate:(id)delegate; 
- (void) saveNSImage:(NSImage *)nsImage;
- (void) setFileName:(NSString *)filename;


@end
