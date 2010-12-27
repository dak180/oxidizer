//
//  Oxidizer_QT_Dialog_ServerAppDelegate.h
//  Oxidizer_QT_Dialog_Server
//
//  Created by David Burnett on 07/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QTKitController.h"
#import "../SaveDialogs/SaveDialogProtocol.h"

@interface Oxidizer_QT_Dialog_ServerAppDelegate : NSObject <SaveDialogProtocol> {

    IBOutlet NSWindow *window;
    IBOutlet QTKitController *qtKitController;
	NSConnection *_serverConnection;


}


- (IBAction) showQuickTimeFileMovieDialogue:(id) sender;


/* API */

- (bool) showQuickTimeFileMovieDialogue;
- (NSDictionary *)getExportDictionary;
- (void) closeServer;

@end
