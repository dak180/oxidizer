//
//  QuickViewButton.h
//  oxidizer
//
//  Created by David Burnett on 24/11/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QuickViewButton : NSButton {

	IBOutlet id quickViewTarget;
	
}

- (id) getQuickViewTarget;

@end
