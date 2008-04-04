//
//  GradientNibController.m
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GradientNibController.h"


@implementation GradientNibController

- (IBAction)showGradientWindow:(id)sender {
	
	[gradientController showWindow:sender];

}

- (void)setCMapController:(NSArrayController *)controller {
	
	[gradientController setCMapController:controller];
	
}

- (void) setFlameController:(id)controller {
	
	[gradientController setFlameController:controller];
}

@end
