//
//  GradientNibController.h
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GradientController.h>


@interface GradientNibController : NSObject {

	IBOutlet GradientController *gradientController;

@private
	
}

- (IBAction)showGradientWindow:(id)sender;
- (void)setCMapController:(NSArrayController *)controller;
- (void) setFlameController:(id)controller;

@end
