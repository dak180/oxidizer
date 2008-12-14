//
//  QuickViewController.h
//  oxidizer
//
//  Created by David Burnett on 24/11/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QuickViewImageView.h"
#import "FractalFlameModel.h"

@interface QuickViewController : NSObject {

	IBOutlet FractalFlameModel *_ffm;
	
	IBOutlet QuickViewImageView *_div1;
	IBOutlet QuickViewImageView *_div2;
	IBOutlet QuickViewImageView *_div3;
	IBOutlet QuickViewImageView *_div4;
	IBOutlet QuickViewImageView *_div5;
	IBOutlet QuickViewImageView *_div6;
	IBOutlet QuickViewImageView *_div7;
	IBOutlet QuickViewImageView *_div8;
	IBOutlet QuickViewImageView *_div9;
	IBOutlet QuickViewImageView *_div10;
	IBOutlet QuickViewImageView *_div11;
	IBOutlet QuickViewImageView *_div12;
	IBOutlet QuickViewImageView *_div13;
	IBOutlet QuickViewImageView *_div14;
	IBOutlet QuickViewImageView *_div15;
	IBOutlet QuickViewImageView *_div16;
	IBOutlet QuickViewImageView *_div17;
	IBOutlet QuickViewImageView *_div18;
	IBOutlet QuickViewImageView *_div19;
	IBOutlet QuickViewImageView *_div20;	
	IBOutlet QuickViewImageView *_div21;
	IBOutlet QuickViewImageView *_div22;
	IBOutlet QuickViewImageView *_div23;
	IBOutlet QuickViewImageView *_div24;
	IBOutlet QuickViewImageView *_div25;
		
	IBOutlet NSWindow *_qvw;

	IBOutlet NSTextField *_min;
	IBOutlet NSTextField *_max;
	
	NSArray *_imagesArray;
		
	NSManagedObject *_observedEntity;
	NSString *_key;
	
	double _originalValue;
	
}

- (IBAction) buttonPressed:(id)sender; 
- (IBAction) renderRange:(id)sender;
- (IBAction) restoreOriginalValue:(id) sender;
- (IBAction) selectValue:(id) sender;


- (void) setObservedEntity:(NSManagedObject *)oe;
- (void) setKey:(NSString *)kp;
			
- (NSManagedObject *)getEntity:(id) observedObject;

@end
