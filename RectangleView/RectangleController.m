#import "RectangleController.h"

@implementation RectangleController

- init {

	if (self = [super init]) {

		NSSortDescriptor *sortXForms = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
		_sortDescriptors = [NSArray arrayWithObject:sortXForms];
		[sortXForms  release]; 

		_undoStack = [[NSMutableArray alloc]  initWithCapacity:20] ;
		_undoStackPointer = -1;
	}
	
    return self;
	
	
}

-(void) awakeFromNib { 
	
	[rectangleView setDelegate:self]; 
	_autoUpdatePreview = NO;
	_editPostTransformations = NO;


	
} 

- (IBAction)showWindow:(id)sender
{
	[rectangleWindow makeKeyAndOrderFront:sender];
	
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

	[self addUndoEntry];

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

	[self addUndoEntry];

}

- (IBAction)moveChanged:(id)sender {
	
	[self addUndoEntry];

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
	[self addUndoEntry];
	
	
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
	[self addUndoEntry];
}

- (IBAction)toggleTransformationType:(id)sender {
	
	if([sender state] == 0) {
		[aTextField unbind:@"value"];
		[aTextField bind:@"value" toObject:treeController withKeyPath:@"selection.coeff_0_0" options:nil];	
		[bTextField unbind:@"value"];
		[bTextField bind:@"value" toObject:treeController withKeyPath:@"selection.coeff_1_0" options:nil];	
		[cTextField unbind:@"value"];
		[cTextField bind:@"value" toObject:treeController withKeyPath:@"selection.coeff_2_0" options:nil];	
		[dTextField unbind:@"value"];
		[dTextField bind:@"value" toObject:treeController withKeyPath:@"selection.coeff_0_1" options:nil];	
		[eTextField unbind:@"value"];
		[eTextField bind:@"value" toObject:treeController withKeyPath:@"selection.coeff_1_1" options:nil];	
		[fTextField unbind:@"value"];
		[fTextField bind:@"value" toObject:treeController withKeyPath:@"selection.coeff_2_1" options:nil];	
		_editPostTransformations = NO;
	} else {
		[aTextField unbind:@"value"];
		[aTextField bind:@"value" toObject:treeController withKeyPath:@"selection.post_0_0" options:nil];
		[bTextField unbind:@"value"];
		[bTextField bind:@"value" toObject:treeController withKeyPath:@"selection.post_1_0" options:nil];	
		[cTextField unbind:@"value"];
		[cTextField bind:@"value" toObject:treeController withKeyPath:@"selection.post_2_0" options:nil];	
		[dTextField unbind:@"value"];
		[dTextField bind:@"value" toObject:treeController withKeyPath:@"selection.post_0_1" options:nil];	
		[eTextField unbind:@"value"];
		[eTextField bind:@"value" toObject:treeController withKeyPath:@"selection.post_1_1" options:nil];	
		[fTextField unbind:@"value"];
		[fTextField bind:@"value" toObject:treeController withKeyPath:@"selection.post_2_1" options:nil];	
		[_currentTransform setValue:[NSNumber numberWithBool:YES] forKey:@"post_flag"];
		_editPostTransformations = YES;
	}
	
	[self outlineViewSelectionDidChange:nil];
	[self resetUndoStack];

}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	
		a = [aTextField floatValue];		
		b = [bTextField floatValue];
		c = [cTextField floatValue];
		d = [dTextField floatValue];
		e = [eTextField floatValue];
		f = [fTextField floatValue];
	
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
	[self resetUndoStack];
	
}


- (void) setCoeffsA:(CGFloat )aIn b:(CGFloat )bIn c:(CGFloat )cIn d:(CGFloat )dIn e:(CGFloat )eIn f:(CGFloat )fIn {

	
	a = aIn;
	b = bIn;
	c = cIn;
	d = dIn;
	e = eIn;
	f = fIn;
	
	if(_editPostTransformations) {
		[_currentTransform setValue:[NSNumber numberWithFloat:aIn] forKey:@"post_0_0"];
		[_currentTransform setValue:[NSNumber numberWithFloat:bIn] forKey:@"post_1_0"];
		[_currentTransform setValue:[NSNumber numberWithFloat:cIn] forKey:@"post_2_0"];
		[_currentTransform setValue:[NSNumber numberWithFloat:dIn] forKey:@"post_0_1"];
		[_currentTransform setValue:[NSNumber numberWithFloat:eIn] forKey:@"post_1_1"];
		[_currentTransform setValue:[NSNumber numberWithFloat:fIn] forKey:@"post_2_1"];
		
	} else {	
		[_currentTransform setValue:[NSNumber numberWithFloat:aIn] forKey:@"coeff_0_0"];
		[_currentTransform setValue:[NSNumber numberWithFloat:bIn] forKey:@"coeff_1_0"];
		[_currentTransform setValue:[NSNumber numberWithFloat:cIn] forKey:@"coeff_2_0"];
		[_currentTransform setValue:[NSNumber numberWithFloat:dIn] forKey:@"coeff_0_1"];
		[_currentTransform setValue:[NSNumber numberWithFloat:eIn] forKey:@"coeff_1_1"];
		[_currentTransform setValue:[NSNumber numberWithFloat:fIn] forKey:@"coeff_2_1"];
	}
		
}



- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	
	/* there's no public Tiger method to get observed object, so we use a private one */
	if([[[[item observedObject] entity] name] isEqualToString:@"Genome"]) {
		return NO;
	}
	
	_currentTransform = [item observedObject];
	
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


- (void) addUndoEntry {
	
	
	NSMutableDictionary *newEntry = [NSMutableDictionary dictionary];
	
	[newEntry setObject:[NSNumber numberWithFloat:a] forKey:@"a"];
	[newEntry setObject:[NSNumber numberWithFloat:b] forKey:@"b"];
	[newEntry setObject:[NSNumber numberWithFloat:c] forKey:@"c"];
	[newEntry setObject:[NSNumber numberWithFloat:d] forKey:@"d"];
	[newEntry setObject:[NSNumber numberWithFloat:e] forKey:@"e"];
	[newEntry setObject:[NSNumber numberWithFloat:f] forKey:@"f"];
	[newEntry setObject:[NSNumber numberWithBool:_editPostTransformations] forKey:@"edit_post"];

	if(_undoStackPointer < [_undoStack count]-1) {
		/* all the redo's are no nolonger valid */
		_undoStackPointer++;
		while(_undoStackPointer >= [_undoStack count]) {
			[_undoStack removeLastObject];
		}
		[redoButton setEnabled:NO];
	} else {
		
		_undoStackPointer++;
	}
	
	[_undoStack addObject:newEntry];

	if([_undoStack count] > 1) {
		/* the first entry is the original value 
		   so you can't undo it, so if its the only
		   entry disable the undo button
		*/
		[undoButton setEnabled:YES];		
	}
	
	
	
}

- (IBAction) undoEntry:(id)sender {

	/* The first entry can't be undone, should not be able to get here 
	   as the undo button should be disabled so this belt and braces code
	*/
	if(_undoStackPointer == 0) {
		return;
	}

	/* the top value is the current value */
	_undoStackPointer--; 

	NSMutableDictionary *entry = [_undoStack objectAtIndex:_undoStackPointer];
	
	a = [[entry objectForKey:@"a"] floatValue];
	b = [[entry objectForKey:@"b"] floatValue];
	c = [[entry objectForKey:@"c"] floatValue];
	d = [[entry objectForKey:@"d"] floatValue];
	e = [[entry objectForKey:@"e"] floatValue];
	f = [[entry objectForKey:@"f"] floatValue];
	
	_editPostTransformations = [[entry objectForKey:@"edit_post"] boolValue];

	[self setCoeffsA:a b:b c:c d:d e:e f:f];
	
	
	/* enable redo button */
	[redoButton setEnabled:YES];

	if(_undoStackPointer < 1) {
		[undoButton setEnabled:NO];
	}
	
	/* redraw the editor */
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
	[self updatePreview:self];


}

- (IBAction) redoEntry:(id)sender {
	
	_undoStackPointer++; 

	NSMutableDictionary *entry = [_undoStack objectAtIndex:_undoStackPointer];
	
	a = [[entry objectForKey:@"a"] floatValue];
	b = [[entry objectForKey:@"b"] floatValue];
	c = [[entry objectForKey:@"c"] floatValue];
	d = [[entry objectForKey:@"d"] floatValue];
	e = [[entry objectForKey:@"e"] floatValue];
	f = [[entry objectForKey:@"f"] floatValue];
	
	_editPostTransformations = [[entry objectForKey:@"edit_post"] boolValue];
	
	[self setCoeffsA:a b:b c:c d:d e:e f:f];
	
	if(_undoStackPointer == [_undoStack count] - 1) {
		[redoButton setEnabled:NO];
	} 

	/* redraw the editor */
	[rectangleView setCoeffsA:a b:b c:c d:d e:e f:f];
	[self updatePreview:self];

	/* if we've redo-ed then there's something to undo */
	[undoButton setEnabled:YES];

}

- (void) resetUndoStack {
	
	[_undoStack removeAllObjects];
	_undoStackPointer = -1;
	[self addUndoEntry];
	
	[undoButton setEnabled:NO];
	[redoButton setEnabled:NO];
	
}


@end
