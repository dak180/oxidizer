//
//  ImageKitController.m
//  oxidizer
//
//  Created by David Burnett on 29/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "ImageKitController.h"


@implementation ImageKitController

- init {
	
    if (self = [super init]) {
		
	_imageProperties = [NSMutableDictionary dictionaryWithCapacity:5];
	[_imageProperties retain];
	
//	_imageUTType = kUTTypePNG;
	

	_savePanel = [NSSavePanel savePanel];
	[_savePanel retain];
	
		

	_filename = nil;
	
	}
	
	
	return self;
	
}

- (BOOL) showFileImageDialogue:(NSWindow *)owner delegate:(id)ffm{
	

	_saveOptions = [[IKSaveOptions alloc]
					initWithImageProperties: _imageProperties
					imageUTType: _imageUTType];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setTitle:@"Render file name..."];
	[savePanel setPrompt:@"Render"];
	[savePanel setCanSelectHiddenExtension:YES];

	[_saveOptions addSaveOptionsAccessoryViewToSavePanel:savePanel];

		
    [savePanel beginSheetForDirectory: NULL
								 file: nil
					   modalForWindow: owner
						modalDelegate: ffm
					   didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
						  contextInfo: NULL];
	
	/*
	runResult = [_savePanel runModal];
	
	
	if(runResult == NSOKButton && [_savePanel filename] != nil) {
		[self setFileName:[_savePanel filename]];
	} else {
		[self setFileName:nil];
		return NO;
	}
	*/
	
	return YES;
		 
}

- (void)saveNSImage:(NSImage *)nsImage {
			 
	NSString *newUTType = [_saveOptions imageUTType];
	
	CGImageSourceRef source;

	source = CGImageSourceCreateWithData((CFDataRef)[nsImage TIFFRepresentation], NULL);
	CGImageRef image =  CGImageSourceCreateImageAtIndex(source, 0, NULL);

	if (image) {

		NSURL * url = [NSURL fileURLWithPath:_filename];
		CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)url,
																	 (CFStringRef)newUTType, 1, NULL);
		if (dest) {
			
			CGImageDestinationAddImage(dest, image,
									   (CFDictionaryRef)[_saveOptions imageProperties]);
			CGImageDestinationFinalize(dest);
			CFRelease(dest);
			
		}
		
		CGImageRelease(image);
	} else {
		NSLog(@"*** saveImageToPath - no image");
	}
	
	 CFRelease(source);
	
	[_saveOptions release];

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




@end
