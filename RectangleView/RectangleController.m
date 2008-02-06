#import "RectangleController.h"

@implementation RectangleController

- init {

	if (self = [super init]) {

//		NSSortDescriptor *sortGenomes = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
		NSSortDescriptor *sortXForms = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];

		_sortDescriptors = [NSArray arrayWithObject:sortXForms];

		[sortXForms  release]; 
//		[sortGenomes  release]; 

	}
	
    return self;
	
	
}

-(void) awakeFromNib { 
	
	[rectangleView setDelegate:self]; 
	_autoUpdatePreview = NO;

	
} 

- (IBAction)showWindow:(id)sender
{
	[rectangleWindow makeKeyAndOrderFront:sender];

	NSLog(@"%@", [fTextField delegate]);
	
}



- (IBAction)viewSizeChanged:(id)sender {
	
	
}



- (IBAction)coefficentChanged:(id)sender {

	if (sender == aTextField) {
		a = [aTextField floatValue];		
	} else if (sender == bTextField) {
		b = [bTextField floatValue];
	} else if (sender ==  cTextField) {
		c = [cTextField floatValue];
	} else if (sender ==  dTextField) {
		d = [dTextField floatValue];
	} else if (sender ==  eTextField) {
		e = [eTextField floatValue];
	} else if (sender ==  fTextField) {
		f = [fTextField floatValue];
	}

	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
}

- (IBAction)modeChanged:(id)sender {
	
	switch ([[sender selectedCell] tag]) {
			
		case 0:
			[rectangleView setTransformMode:MOVE_MODE];
			break;
		case 1:
			[rectangleView setTransformMode:ROTATE_MODE];
			break;
		case 2:	
			[rectangleView setTransformMode:SCALE_MODE];
			break;
	}
	
}

- (IBAction)rotationChanged:(id)sender {
	
	float rotation = radians(-[rotate floatValue]);

	float cosRotation = cos(rotation);
	float sinRotation = sin(rotation);
	

	
	CGFloat tmpA  = a;
	
	a = (a * cosRotation) - (d * sinRotation);
	d = (tmpA * sinRotation) + (d * cosRotation);

	CGFloat tmpB  = b;

	b = (b * cosRotation) - (e * sinRotation);
	e = (tmpB * sinRotation) + (e * cosRotation);

	[self setCoeffsA:a b:b c:c d:d e:e f:f];
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
	[self updatePreview:self];
	
}

- (IBAction)moveChanged:(id)sender {
	
	NSSegmentedCell *cellButton = [sender selectedCell];
	
	if([sender tag] == 0) {
		/* change x */
		switch ([cellButton selectedSegment]) {
			case 0:
				c += [moveX floatValue];
				break;
			case 1:
				c -= [moveX floatValue];
				break;
		}		
	} else {
		switch ([cellButton selectedSegment]) {
			case 0:
				f += [moveY floatValue];
				break;
			case 1:
				f -= [moveY floatValue];
				break;
		}			
		
	}			

	[self setCoeffsA:a b:b c:c d:d e:e f:f];
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
	[self updatePreview:self];

}


- (IBAction)scaleChanged:(id)sender {

	NSSegmentedCell *cellButton = [sender selectedCell];
	
	if([sender tag] == 0) {
		/* change p1 */
		switch ([cellButton selectedSegment]) {
			case 0:
				a *= [scaleP1 floatValue];
				d *= [scaleP1 floatValue];
				break;
			case 1:
				a /= [scaleP1 floatValue];
				d /= [scaleP1 floatValue];
				break;
		}		
	} else {
		switch ([cellButton selectedSegment]) {
			case 0:
				b *= [scaleP2 floatValue];
				e *= [scaleP2 floatValue];
				break;
			case 1:
				b /= [scaleP2 floatValue];
				e /= [scaleP2 floatValue];
				break;
		}			
		
	}			
	
	[self setCoeffsA:a b:b c:c d:d e:e f:f];	
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
	[self updatePreview:self];
	
	
}
- (void)controlTextDidChange:(NSNotification *)aNotification {
	
	if ([aNotification object] == aTextField) {
		a = [aTextField floatValue];		
	} else if ([aNotification object] == bTextField) {
		b = [bTextField floatValue];
	} else if ([aNotification object] ==  cTextField) {
		c = [cTextField floatValue];
	} else if ([aNotification object] ==  dTextField) {
		d = [dTextField floatValue];
	} else if ([aNotification object] ==  eTextField) {
		e = [eTextField floatValue];
	} else if ([aNotification object] ==  fTextField) {
		f = [fTextField floatValue];
	}
	
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	
		a = [aTextField floatValue];		
		b = [bTextField floatValue];
		c = [cTextField floatValue];
		d = [dTextField floatValue];
		e = [eTextField floatValue];
		f = [fTextField floatValue];
	
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
	
}


- (void) setCoeffsA:(CGFloat )aIn b:(CGFloat )bIn c:(CGFloat )cIn d:(CGFloat )dIn e:(CGFloat )eIn f:(CGFloat )fIn {

	
	a = aIn;
	b = bIn;
	c = cIn;
	d = dIn;
	e = eIn;
	f = fIn;
	
	[_currentTransform setValue:[NSNumber numberWithFloat:aIn] forKey:@"coeff_0_0"];
	[_currentTransform setValue:[NSNumber numberWithFloat:bIn] forKey:@"coeff_1_0"];
	[_currentTransform setValue:[NSNumber numberWithFloat:cIn] forKey:@"coeff_2_0"];
	[_currentTransform setValue:[NSNumber numberWithFloat:dIn] forKey:@"coeff_0_1"];
	[_currentTransform setValue:[NSNumber numberWithFloat:eIn] forKey:@"coeff_1_1"];
	[_currentTransform setValue:[NSNumber numberWithFloat:fIn] forKey:@"coeff_2_1"];
		
}



- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	
	if([[[[item observedObject] entity] name] isEqualToString:@"Genome"]) {
		return NO;
	}
	
	_currentTransform = [item observedObject];
//	[rectangleView setTransformMode:MOVE_MODE];
	
	return YES;
}

- (void)setFractalFlameModel:(FractalFlameModel *)ffm {

	if(ffm != nil) {
		[ffm retain];
	}
	[_ffm release];
	
	_ffm = ffm;
	
}

- (IBAction)updatePreview:(id)sender {
	
	if(_autoUpdatePreview || [sender class] == [NSButton class]) {

		NSManagedObject *genome = [_currentTransform valueForKey:@"parent_genome"];
		[NSThread detachNewThreadSelector:@selector(previewCurrentFlameInThread:) toTarget:_ffm withObject:[NSArray arrayWithObject:genome]]; 
		
	}


	
}

@end
