//
//  MultiUseWindow.h
//  oxidizer
//
//  Created by David Burnett on 24/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MultiUseWindow : NSWindow {
	
	unsigned int _showingCount;

}

- (void)makeKeyOrderFrontAndCount:(id)sender;

@end
