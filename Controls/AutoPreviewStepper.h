//
//  AutoPreviewStepper.h
//  oxidizer
//
//  Created by David Burnett on 08/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FractalFlameModel.h"

@interface AutoPreviewStepper : NSStepper {

	IBOutlet FractalFlameModel *ffm;
	
}

@end
