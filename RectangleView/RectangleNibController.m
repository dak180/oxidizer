//
//  RectangleNibController.m
//  oxidizer
//
//  Created by David Burnett on 12/01/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RectangleNibController.h"


@implementation RectangleNibController

- (IBAction)showRectangleWindow:(id)sender
{
	[rectangleController showWindow:sender];
}

- (void)setMOC:(NSManagedObjectContext *)moc {
	
	if(moc != nil) {
		[moc retain];
	}
	[_moc release];
	
	_moc = moc;

	[treeController setManagedObjectContext:_moc];
	[treeController prepareContent];

}

/*
- (id)copyWithZone:(NSZone *)zone {
	
	return nil;
}
*/

@end
