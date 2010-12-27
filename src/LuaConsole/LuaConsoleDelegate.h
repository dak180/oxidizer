//
//  LuaConsoleDelegate.h
//  oxidizer
//
//  Created by David Burnett on 12/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConsoleView.h"

#include "LuaObjCBridge/LuaObjCBridge.h"


@interface LuaConsoleDelegate : NSObject {

	IBOutlet ConsoleView *_luaTextView;
	IBOutlet NSTextField *_luaTextField;
	IBOutlet id delegate;

	BOOL _ignoreDidBeginNotifiactions;
	NSString *_command;

	NSMutableString *_selectedString;

	lua_State* interpreter;
	lua_State* _interactive;

	int _commandStartIndex;

	id _ffm;

}


- (void) runLuaScript:(NSString *)script;

- (NSString *)command;
- (void) setCommand:(NSString *)command;

- (IBAction) runCommand:(id)sender;
- (IBAction) copy:(id)sender;
- (IBAction) paste:(id)sender;

/* interactive scripting option */

- (NSArray *)passGenomesToLua;
- (void)appendGenomesFromLua:(NSString *)globalName;
- (void)replaceWithGenomesFromLua:(NSString *)globalName;
- (int) renderGenome:(NSArray *)genomes toPng:(NSString *)filename;

@end
