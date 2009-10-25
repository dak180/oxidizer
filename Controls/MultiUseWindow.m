//
//  MultiUseWindow.m
//  oxidizer
//
//  Created by David Burnett on 24/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MultiUseWindow.h"


@implementation MultiUseWindow

- init {
	if (self = [super init]) {
		_showingCount = 0;
	}
	
	return self;
}

- (void)makeKeyAndOrderFront:(id)sender {
	
	
	_showingCount++;
	[super makeKeyAndOrderFront:sender];
	
}


- (void)setIsVisible:(BOOL)flag {
	if (flag) {
		_showingCount++;
	} else {
		_showingCount--;	
	}
	
	if (flag == NO && _showingCount == 0) {
		[super setIsVisible:NO];
	} else if (flag == YES) {
		[super setIsVisible:YES];
	}
		
}

@end
