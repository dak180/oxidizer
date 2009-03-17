//
//  GradientNibController.h
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GradientController.h"


@interface GradientNibController : NSObject {

	IBOutlet GradientController *_gradientController;
	IBOutlet NSArrayController *_cmapController;
	IBOutlet id _fractalFlameModel;
	IBOutlet id _qvController;
	IBOutlet id _flameController;

@private
	
}

- (IBAction) showGradientWindow:(id)sender;
- (void) setCMapController:(NSArrayController *)controller;
- (void) setFlameController:(id)controller;
- (void) setFractalFlameModel:(id)model;
- (void) setQuickViewController:(id)qvc;


@end
