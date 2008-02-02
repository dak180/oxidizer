#import "RectangleController.h"

@implementation RectangleController

-(void) awakeFromNib { 
	
	[rectangleView setDelegate:self]; 
	
} 

- (IBAction)showWindow:(id)sender
{
	[rectangleWindow makeKeyAndOrderFront:sender];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(controlTextDidChange:)
//												 name:@"ConverterAdded" object:nil];

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
	
	[currentTransform setValue:[NSNumber numberWithFloat:aIn] forKey:@"coeff_0_0"];
	[currentTransform setValue:[NSNumber numberWithFloat:bIn] forKey:@"coeff_1_0"];
	[currentTransform setValue:[NSNumber numberWithFloat:cIn] forKey:@"coeff_2_0"];
	[currentTransform setValue:[NSNumber numberWithFloat:dIn] forKey:@"coeff_0_1"];
	[currentTransform setValue:[NSNumber numberWithFloat:eIn] forKey:@"coeff_1_1"];
	[currentTransform setValue:[NSNumber numberWithFloat:fIn] forKey:@"coeff_2_1"];
		
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	
	if([[[[item observedObject] entity] name] isEqualToString:@"Genome"]) {
		return NO;
	}
	
	currentTransform = [item observedObject];
	[rectangleView setTransformMode:MOVE_MODE];
	
	return YES;
}



@end
