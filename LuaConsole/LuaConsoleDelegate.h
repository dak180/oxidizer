//
//  LuaConsoleDelegate.h
//  oxidizer
//
//  Created by David Burnett on 12/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "LuaObjCBridge/LuaObjCBridge.h"


@interface LuaConsoleDelegate : NSObject {

	IBOutlet NSTextView *_luaTextView;
	IBOutlet NSTextField *_luaTextField;
	IBOutlet id delegate;
	
	BOOL _ignoreDidBeginNotifiactions;
	NSString *_command;
	 
	lua_State* interpreter;
	lua_State* _interactive;
	
	int _commandStartIndex;
	
	id _ffm;

}

//- (void)textDidBeginEditing:(NSNotification *)aNotification;
//- (void)textDidEndEditing:(NSNotification *)aNotification;

- (void) startOutput;
- (void) stopOutput;

- (void) runLuaScript:(NSString *)script;

- (NSString *)command;
- (void) setCommand:(NSString *)command;

- (IBAction) runCommand:(id)sender;

/* interactive scripting option */

- (NSArray *)passGenomesToLua;
- (void)appendGenomesFromLua:(NSString *)globalName;
- (void)replaceWithGenomesFromLua:(NSString *)globalName;
@end
