//
//  QuickViewController.h
//  oxidizer
//
//  Created by David Burnett on 24/11/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DnDImageView.h"
#import "FractalFlameModel.h"

@interface QuickViewController : NSObject {

	IBOutlet FractalFlameModel *_ffm;
	
	IBOutlet DnDImageView *_div1;
	IBOutlet DnDImageView *_div2;
	IBOutlet DnDImageView *_div3;
	IBOutlet DnDImageView *_div4;
	IBOutlet DnDImageView *_div5;
	IBOutlet DnDImageView *_div6;
	IBOutlet DnDImageView *_div7;
	IBOutlet DnDImageView *_div8;
	IBOutlet DnDImageView *_div9;
	IBOutlet DnDImageView *_div10;
	IBOutlet DnDImageView *_div11;
	IBOutlet DnDImageView *_div12;
	IBOutlet DnDImageView *_div13;
	IBOutlet DnDImageView *_div14;
	IBOutlet DnDImageView *_div15;
	IBOutlet DnDImageView *_div16;
	IBOutlet DnDImageView *_div17;
	IBOutlet DnDImageView *_div18;
	IBOutlet DnDImageView *_div19;
	IBOutlet DnDImageView *_div20;	
	IBOutlet DnDImageView *_div21;
	IBOutlet DnDImageView *_div22;
	IBOutlet DnDImageView *_div23;
	IBOutlet DnDImageView *_div24;
	IBOutlet DnDImageView *_div25;
	
	IBOutlet NSWindow *_qvw;
	
	NSArray *_imagesArray;
	
	
	
}

- (IBAction) buttonPressed:(id)sender; 

@end
