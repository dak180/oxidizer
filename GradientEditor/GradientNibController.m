//
//  GradientNibController.m
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GradientNibController.h"


@implementation GradientNibController

- (void) awakeFromNib {
	
	[_gradientController setCMapController:_cmapController];
	[_gradientController setFlameController:_flameController];
	[_gradientController setQuickViewController:_qvController];
	[_gradientController setFractalFlameModel:_fractalFlameModel];
	
}
- (IBAction)showGradientWindow:(id)sender {
	
	[_gradientController showWindow:sender];

}

- (void)setCMapController:(NSArrayController *)controller {
	
	[_gradientController setCMapController:controller];
	
}

- (void) setFlameController:(id)controller {
	
	[_gradientController setFlameController:controller];
}

- (void)setQuickViewController:(id)qvc {
	
	[_gradientController setQuickViewController:qvc];	
}

- (void) setFractalFlameModel:(id)model {
	
	[_gradientController setFractalFlameModel:model];	
}

@end
