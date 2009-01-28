//
//  GradientController.h
//  oxidizer
//
//  Created by David Burnett on 11/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GradientView.h"
#import "QuickViewProtocol.h"

@interface GradientController : NSObject  <QuickViewProtocol> {

	IBOutlet GradientView *gradientView;
    IBOutlet NSWindow *gradientWindow;
    IBOutlet NSArrayController *arrayController;
	IBOutlet NSTableView *gradientTableView;
	

@private 
	
	NSMutableArray *cmapSortDescriptors;
	NSMutableArray *colours;
	NSArrayController *cmap;
	id flameController;
	id _qvc;
	
	double _qvMin;
	double _qvMax;
	id _qvOriginalValue;
	id _qvOriginalValuesObject;
	
	unsigned int _rotateType;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (void)controlTextDidEndEditing:(NSNotification *)aNotification;

- (IBAction)showWindow:(id)sender;
- (IBAction)editPalette:(id)sender;
- (IBAction)applyNewPalette:(id)sender;
- (IBAction)newGradient:(id)sender;
- (IBAction)qvRotateIndex:(id)sender;
- (IBAction)qvRotateRed:(id)sender;
- (IBAction)qvRotateGreen:(id)sender;
- (IBAction)qvRotateBlue:(id)sender;

- (void) fillGradientImageRep; 

- (NSArray *) getColourArray;
- (void) setCMapController:(NSArrayController *)newCmap;
- (void) setFlameController:(id)controller;
- (void) setColourArray:(NSArray *)newArray;
- (void) setSelectedColour:(NSDictionary *)colour;

- (void) addColour;

- (void)setQuickViewController:(id)qvc;
- (void) rotateIndex;
- (void) rotateIndexes;
- (void) rotateColour:(NSString *)colourKey;
- (void)setOriginalValue:(id)value;
- (void)setOriginalValuesObject:(id)value;
- (void)addColourSquare:(NSMutableDictionary *)colour;

@end
