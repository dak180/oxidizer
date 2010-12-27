//
//  ConsoleView.m
//  oxidizer
//
//  Created by David Burnett on 23/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConsoleView.h"


#define LINE_HEIGHT 18
#define LINE_WIDTH 1000
#define MAX_LINES 1000000


@implementation ConsoleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		array = [[[NSMutableArray alloc] init] retain];
		_attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Osaka-Mono" size:14.0], NSFontAttributeName, nil];
		[_attributes retain];
		_selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Osaka-Mono" size:14.0], NSFontAttributeName,
							                                             [NSColor selectedTextBackgroundColor],NSBackgroundColorAttributeName,
																		 nil];
		[_selectedAttributes retain];
		_buildString = [NSMutableString string];
		[_buildString retain];
		_characterLength = [@"X" sizeWithAttributes:_attributes].width;
    }
    return self;
}

- (void)dealloc {
	[array release];
	[_attributes release];
	[super dealloc];
}

- (BOOL)isFlipped { return YES; } // first line at the top

- (void)drawRect:(NSRect)rect {

	int startLine = rect.origin.y/LINE_HEIGHT;
	int endLine = 1 + (rect.origin.y+rect.size.height)/LINE_HEIGHT;
	if(startLine < 0) startLine = 0;
	if(endLine > [array count]) endLine = [array count];
	int i;
	for(i = startLine; i < endLine; i++) { // only draw the changed lines
		NSString *str = [array objectAtIndex:i];

		int selectStart = (int)(floor(_selectedStart / _characterLength));
		int selectEnd = (int)(ceil(_selectedEnd / _characterLength));

		selectEnd = selectEnd > [str length] ? [str length] : selectEnd;
		selectStart = selectStart > [str length] ? [str length] : selectStart;

		if(i == _selectedLinesStart && _selectedLinesStart ==_selectedLinesEnd) {


			if(selectStart > selectEnd) {

				int tmp = selectStart;
				selectStart = selectEnd;
				selectEnd = tmp;
			}

			NSRange selected = NSMakeRange(selectStart, selectEnd-selectStart);

			[[str substringToIndex:selectStart] drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_attributes];
			[[str substringWithRange:selected] drawAtPoint:NSMakePoint(selectStart * _characterLength, i * LINE_HEIGHT) withAttributes:_selectedAttributes];
			[[str substringFromIndex:selectEnd] drawAtPoint:NSMakePoint(selectEnd * _characterLength, i * LINE_HEIGHT) withAttributes:_attributes];

			 continue;
		}

		if(_selectedLinesEnd > _selectedLinesStart) {


			/* normal selection */
			if(i == _selectedLinesStart) {

				[[str substringToIndex:selectStart] drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_attributes];
				[[str substringFromIndex:selectStart] drawAtPoint:NSMakePoint(selectStart * _characterLength, i * LINE_HEIGHT) withAttributes:_selectedAttributes];
				continue;
			}

			if(i >_selectedLinesStart && i <_selectedLinesEnd) {

				[str drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_selectedAttributes];
				continue;

			}

			if(i ==_selectedLinesEnd) {

				[[str substringToIndex:selectEnd] drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_selectedAttributes];
				[[str substringFromIndex:selectEnd] drawAtPoint:NSMakePoint(selectEnd * _characterLength, i * LINE_HEIGHT) withAttributes:_attributes];
				continue;

			}

			[str drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_attributes];

			continue;
		}


		/* reverse selection */

		if(selectEnd > selectStart) {

			int tmp = selectStart;
			selectStart = selectEnd;
			selectEnd = tmp;
		}

		if(i ==_selectedLinesEnd) {

			/* start of selection, right side is selected */

			[[str substringToIndex:selectStart] drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_attributes];
			[[str substringFromIndex:selectStart] drawAtPoint:NSMakePoint(selectStart * _characterLength, i * LINE_HEIGHT) withAttributes:_selectedAttributes];
			continue;
		}

		if(i >_selectedLinesEnd && i < _selectedLinesStart) {

			[str drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_selectedAttributes];
			continue;

		}

		if(i ==_selectedLinesStart) {

			/* end of selection, left side is selected */

			[[str substringToIndex:selectEnd] drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_selectedAttributes];
			[[str substringFromIndex:selectEnd] drawAtPoint:NSMakePoint(selectEnd * _characterLength, i * LINE_HEIGHT) withAttributes:_attributes];
			continue;

		}

		[str drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_attributes];

	}		/* end */

}

- (void)appendLine:(NSString*)line {

	if([array count] > MAX_LINES) {
		[array removeObjectAtIndex:0];
	} // limit the number of lines

	NSString *new_line;
	if([_buildString length] > 0) {
		new_line = [NSString stringWithFormat:@"%@%@", _buildString, line];
		[array addObject:[new_line stringByReplacingOccurrencesOfString:@"\t" withString:@"    "]];
		[_buildString setString:@""];
	} else {
		[array addObject:[line stringByReplacingOccurrencesOfString:@"\t" withString:@"    "]];
	}

	int i = [array count];

	if( (i & 63) == 63) {
		[self setFrame:NSMakeRect(0, 0, [self frame].size.width , i*LINE_HEIGHT)]; // increase the frame size
		[self scrollRectToVisible:NSMakeRect(0, (i-1)*LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)]; // show the last line
		[self setNeedsDisplay:YES];
	}
}

- (void)forceDisplay {

	int i = [array count];
	[self setFrame:NSMakeRect(0, 0, [self frame].size.width , i*LINE_HEIGHT)]; // increase the frame size
	[self scrollRectToVisible:NSMakeRect(0, (i-1)*LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)]; // show the last line
	[self display];
}

- (void)buildString:(NSString*)line {

	[_buildString appendString:line];

}

- (void)appendBuiltString {

	[self appendLine:@""];

}


-(void)mouseDown:(NSEvent *)theEvent {

	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

	_selectedLinesStart = mousePoint.y / LINE_HEIGHT;
	_selectedLinesEnd = mousePoint.y / LINE_HEIGHT;

//	NSLog(@"%d, %d", _selectedLinesStart, _selectedLinesEnd);

	_selectedStart = mousePoint.x;
	_selectedEnd = mousePoint.x;

}

-(void)mouseUp:(NSEvent *)theEvent {

	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];


	if (_selectedLinesStart ==(int)( mousePoint.y / LINE_HEIGHT) && _selectedStart == mousePoint.x) {
		_selectedStart = mousePoint.x;
		_selectedEnd = mousePoint.x;
		_selectedLinesStart = mousePoint.y / LINE_HEIGHT;
		_selectedLinesEnd = mousePoint.y / LINE_HEIGHT;

		[self display];
	}

}


-(void)mouseDragged:(NSEvent *)theEvent {

	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];


	_selectedLinesEnd = mousePoint.y / LINE_HEIGHT;
	_selectedEnd = mousePoint.x;


//	NSLog(@"%d, %d", _selectedLinesStart, _selectedLinesEnd);

	[self display];


}


- (NSMenu *)menuForEvent:(NSEvent *)theEvent {

	return _contextMenu;

}

- (NSMutableString *) copy {

	int startLine, endLine, i;

	NSMutableString *selectedString = [NSMutableString stringWithString:@""];
	[selectedString retain];

	if(_selectedLinesEnd > _selectedLinesStart) {
		startLine = _selectedLinesStart;
		endLine = _selectedLinesEnd;
	} else {
		endLine = _selectedLinesStart;
		startLine = _selectedLinesEnd;
	}


	for(i = startLine; i < endLine; i++) {

		NSString *str = [array objectAtIndex:i];

		int selectStart = (int)(floor(_selectedStart / _characterLength));
		int selectEnd = (int)(ceil(_selectedEnd / _characterLength));

		selectEnd = selectEnd > [str length] ? [str length] : selectEnd;
		selectStart = selectStart > [str length] ? [str length] : selectStart;

		if(i == _selectedLinesStart && _selectedLinesStart ==_selectedLinesEnd) {


			if(selectStart > selectEnd) {

				int tmp = selectStart;
				selectStart = selectEnd;
				selectEnd = tmp;
			}

			NSRange selected = NSMakeRange(selectStart, selectEnd-selectStart);

			[selectedString appendString:[str substringWithRange:selected]];

			continue;
		}

		if(_selectedLinesEnd > _selectedLinesStart) {


			/* normal selection */
			if(i == _selectedLinesStart) {

				[selectedString appendString:[str substringFromIndex:selectStart]];
				continue;
			}

			if(i >_selectedLinesStart && i <_selectedLinesEnd) {

				[selectedString appendString:str];

				continue;

			}

			if(i ==_selectedLinesEnd) {

				[selectedString appendString:[str substringToIndex:selectEnd]];
				continue;

			}

			[str drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:_attributes];

			continue;
		}


		/* reverse selection */

		if(selectEnd > selectStart) {

			int tmp = selectStart;
			selectStart = selectEnd;
			selectEnd = tmp;
		}

		if(i ==_selectedLinesEnd) {

			/* start of selection, right side is selected */
			[selectedString appendString:[str substringFromIndex:selectStart]];

			continue;
		}

		if(i >_selectedLinesEnd && i < _selectedLinesStart) {

			[selectedString appendString:str];
			continue;

		}

		if(i ==_selectedLinesStart) {

			/* end of selection, left side is selected */

			[selectedString appendString:[str substringToIndex:selectEnd]];
			continue;

		}

	}		/* end */

	return [selectedString autorelease];
}

@end
