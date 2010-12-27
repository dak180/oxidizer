//
//  Oxidizer_QT_Dialog_ServerAppDelegate.m
//  Oxidizer_QT_Dialog_Server
//
//  Created by David Burnett on 07/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Oxidizer_QT_Dialog_ServerAppDelegate.h"

@implementation Oxidizer_QT_Dialog_ServerAppDelegate



- (void) awakeFromNib {

	NSPort *newPort = [NSPort port];

    _serverConnection = [NSConnection connectionWithReceivePort:newPort sendPort:newPort];

	[_serverConnection retain];
    [_serverConnection setRootObject:self];
    [_serverConnection registerName:@"OxidizerQTMovieDialog"];


}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (bool) showQuickTimeFileMovieDialogue {

	bool didDialog = [qtKitController showQuickTimeFileMovieDialogue];

	return didDialog;

}

- (IBAction) showQuickTimeFileMovieDialogue:(id) sender {

	bool didDialog = [qtKitController showQuickTimeFileMovieDialogue];



}

- (NSDictionary *)getExportDictionary {
	return [qtKitController getExportDictionary];
}

- (void) closeServer {

	[NSApp terminate:self];

}

@end
