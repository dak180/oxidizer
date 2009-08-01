//
//  ConsoleView.h
//  oxidizer
//
//  Created by David Burnett on 23/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConsoleView : NSView {
	
	IBOutlet NSMenu *_contextMenu;
	
@private
	NSMutableArray *array;
	NSDictionary *_attributes;
	NSDictionary *_selectedAttributes;
	NSMutableString *_buildString;
	
	int _selectedLinesStart;
	int _selectedLinesEnd;
	float _selectedStart;
	float _selectedEnd;
	float _characterLength;
	
}

- (void)buildString:(NSString*)line;
- (void)appendBuiltString;
- (void)appendLine:(NSString*)line;
- (void)forceDisplay;
- (NSMutableString *) copy;


@end
