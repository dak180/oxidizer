//
//  QuickViewController.m
//  oxidizer
//
//  Created by David Burnett on 24/11/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QuickViewController.h"
#import "QuickViewButton.h"
#import "FractalFlameModel.h"


@implementation QuickViewController

- (void)awakeFromNib {
	
	_imagesArray = [NSArray arrayWithObjects: _div1, _div2, _div3, _div4, _div5,
				   _div6,  _div7, _div8, _div9, _div10, _div11, _div12,
				   _div13, _div14, _div15, _div16, _div17, _div18,
				   _div19, _div20, _div21, _div22, _div23, _div24,
				   _div25, nil];
	
	[_imagesArray retain];
	
}


- (IBAction) buttonPressed:(id)sender {
	
	QuickViewButton *qvb = (QuickViewButton *)sender;
	
	NSDictionary *bindInfo = [[qvb getQuickViewTarget] infoForBinding:NSValueBinding];
	
	NSManagedObject *observedObject = [bindInfo valueForKey:@"NSObservedObject"];
	NSEntityDescription *entity =  [[self getEntity:observedObject] entity];
	NSDictionary *attributes = [entity attributesByName];
	
	NSString *keyPath =  [bindInfo valueForKey:@"NSObservedKeyPath"];
	NSString *key = [[keyPath componentsSeparatedByString:@"."] lastObject];

	NSAttributeDescription *description = [attributes objectForKey:key];
	NSArray *predicates = [description validationPredicates];
	double high = DBL_MIN;
	double low = DBL_MAX;

	NSEnumerator *predicateEnumerator = [predicates objectEnumerator];
	NSPredicate *predicate;
	while(predicate = [predicateEnumerator nextObject]) {
		
		if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
			NSComparisonPredicate *compare = (NSComparisonPredicate *)predicate;
			
			if ([compare predicateOperatorType] == NSGreaterThanOrEqualToPredicateOperatorType) {
				low = [[[compare rightExpression] constantValue] doubleValue];
			} else if ([compare predicateOperatorType] == NSLessThanOrEqualToPredicateOperatorType) {
				high = [[[compare rightExpression] constantValue] doubleValue];				
			}
		}
		
	}
	
	NSArray *selected = [(NSArrayController *)observedObject selectedObjects]; 
	
	NSLog (@"%@",selected);
	
	[_qvw makeKeyAndOrderFront:self];
		
	NSLog (@"%@",bindInfo);

	double number = [[observedObject valueForKeyPath:keyPath] doubleValue];

	if(low == DBL_MAX) {
		low = 0.0;
	}

	if(high == DBL_MIN) {
		if (low == number) {
			high = number + 1.0;
		} else {
			high = number + (number - low);			
		}
	}
	
	double delta = (high - low) / 25.0;
	
	int i;
	for(i = 0 ; i < 25; i++) {

		[observedObject setValue:[NSNumber numberWithDouble:low] forKeyPath:keyPath];
		[[_imagesArray objectAtIndex:i] setImage:[(FractalFlameModel *)_ffm renderThumbnail]];
		[[_imagesArray objectAtIndex:i] display];
		low += delta;
		
	}
	
	[observedObject setValue:[NSNumber numberWithDouble:number] forKeyPath:keyPath];
	
	
	
} 

- (NSManagedObject *) getEntity:(id) observedObject {
	
	if([observedObject isKindOfClass:[NSArrayController class]] == YES) {
		
		return [[observedObject selectedObjects] objectAtIndex:0];
		
	} else {
		return observedObject;
	}
	
}

@end
