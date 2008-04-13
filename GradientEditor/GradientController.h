//
//  GradientController.h
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GradientView.h>


@interface GradientController : NSObject {

	IBOutlet GradientView *gradientView;
    IBOutlet NSWindow *gradientWindow;
    IBOutlet NSArrayController *arrayController;
	IBOutlet NSTableView *gradientTableView;

@private 
	
	NSMutableArray *cmapSortDescriptors;
	NSMutableArray *colours;
	NSArrayController *cmap;
	id flameController;
	
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (void)controlTextDidEndEditing:(NSNotification *)aNotification;

- (IBAction)showWindow:(id)sender;
- (IBAction)editPalette:(id)sender;
- (IBAction)applyNewPalette:(id)sender;
- (IBAction)newGradient:(id)sender;


- (void) fillGradientImageRep; 

- (NSArray *) getColourArray;
- (void) setCMapController:(NSArrayController *)newCmap;
- (void) setFlameController:(id)controller;
- (void) setColourArray:(NSArray *)newArray;
- (void) setSelectedColour:(NSDictionary *)colour;

- (void) addColour;
@end
