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
	NSString *key;
	NSString *keyPath = [bindInfo valueForKey:@"NSObservedKeyPath"];
	NSArray *keys = [keyPath componentsSeparatedByString:@"."];
	
	NSManagedObject *observedObject = [bindInfo valueForKey:@"NSObservedObject"];
	[self setObservedEntity:[self getEntity:observedObject keyArray:keys]];
	NSEntityDescription *entity = [_observedEntity entity];
	NSDictionary *attributes = [entity attributesByName];
	
	
	key = [[keyPath componentsSeparatedByString:@"."] lastObject];
	
	
	[self setKey:key];

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

	_originalValue = [[observedObject valueForKeyPath:keyPath] doubleValue];

	if(low == DBL_MAX) {
		low = 0.0;
	}

	if(high == DBL_MIN) {
		if (low == _originalValue) {
			high = _originalValue + 1.0;
		} else {
			high = _originalValue + (_originalValue - low);			
		}
	}
	
	if([(NSString *)[keys lastObject]  isEqualToString:@"rotate"]) {
		low = 0.0;
		high = 360.0;
	}
	
	[_min setDoubleValue:low];
	[_max setDoubleValue:high];
		
	[self renderRange:self];
} 


- (IBAction) renderRange:(id)sender {

	
	double low = [_min doubleValue];
	double high  = [_max doubleValue];
	double delta = (high - low) / 24.0;

	int i;
	for(i = 0 ; i < 25; i++) {
		
//		[observedObject setValue:[NSNumber numberWithDouble:low] forKeyPath:keyPath];
		[_observedEntity setValue:[NSNumber numberWithDouble:low] forKey:_key];
		[[_imagesArray objectAtIndex:i] setImage:[(FractalFlameModel *)_ffm renderThumbnail]];
		[[_imagesArray objectAtIndex:i] setQuickViewValue:low];
		[[_imagesArray objectAtIndex:i] setToolTip:[NSString stringWithFormat:@"value: %g", low]];
		[[_imagesArray objectAtIndex:i] display];
		low += delta;
		
	}
	
	[_observedEntity setValue:[NSNumber numberWithDouble:_originalValue] forKeyPath:_key];
	
}


- (IBAction) selectValue:(id) sender {
	
		[_observedEntity setValue:[NSNumber numberWithDouble:[(QuickViewImageView *)sender quickViewValue]] forKeyPath:_key];
		[_ffm previewCurrentFlame:self];
	

}
- (IBAction) restoreOriginalValue:(id) sender {
	
	
	[_observedEntity setValue:[NSNumber numberWithDouble:_originalValue] forKeyPath:_key];
	[_ffm previewCurrentFlame:self];

	
}

- (void) setObservedEntity:(NSManagedObject *)oe {
	
	if(oe != nil) {
		[oe retain];		
	}
	
	if(_observedEntity != nil) {
		[_observedEntity release];
	}
	
	_observedEntity = oe;
	
	return;

} 

- (void) setKey:(NSString *)kp {
	
	if(kp != nil) {
		[kp retain];		
	}
	
	if(_key != nil) {
		[_key release];
	}
	
	_key = kp;
	
	return;
	
} 

- (NSManagedObject *) getEntity:(id) observedObject keyArray:(NSArray *) keys {
	
	if ([keys count] > 1) {
		int i;
		NSManagedObject *obj;
		if([(NSString *)[keys objectAtIndex:0] isEqualToString:@"selection"]) {
			obj = [[observedObject selectedObjects] objectAtIndex:0];
		} else {
		    obj = [observedObject valueForKey:[keys objectAtIndex:0]];			
		}
		for(i=1; i<[keys count] - 1; i++) {
			obj = [obj valueForKey:[keys objectAtIndex:i]];
		}
		
		return obj;
		
	} else {
				return observedObject;
		
	}
	
	
//	if([observedObject isKindOfClass:[NSArrayController class]] == YES) {
//		return [[observedObject selectedObjects] objectAtIndex:0];
//	} else {
//		return observedObject;
//	}
	
}

@end
