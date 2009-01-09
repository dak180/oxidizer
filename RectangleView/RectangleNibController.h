//
//  RectangleNibController.h
//  oxidizer
//
//  Created by David Burnett on 12/01/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RectangleController.h>


@interface RectangleNibController : NSObject {

	IBOutlet RectangleController *rectangleController;
	IBOutlet NSTreeController *treeController;
	
	NSManagedObjectContext *_moc;
	
}

- (IBAction)showRectangleWindow:(id)sender;
- (void)setMOC:(NSManagedObjectContext *)moc;
- (void)setFFM:(FractalFlameModel *)ffm;
- (void)setQVC:(QuickViewController *)qvc;

@end
