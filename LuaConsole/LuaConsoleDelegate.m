//
//  LuaConsoleDelegate.m
//  oxidizer
//
//  Created by David Burnett on 12/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "LuaConsoleDelegate.h"
#import "OxidizerDelegate.h"
#import "FractalFlameModel.h"

#define LUA_PROMPT		"> "
#define LUA_PROMPT2		">> "


ConsoleView *_staticLuaConsole;
LuaConsoleDelegate *_staticLuaConsoleDelegate;

int print(lua_State *L);
void print_stack(lua_State* interpreter);
void print_value(lua_State* interpreter,int stack_index,int indent);
static void dotty (lua_State *L);

@implementation LuaConsoleDelegate

- (void) awakeFromNib {
	
	_ignoreDidBeginNotifiactions = NO;
	
	_staticLuaConsole = _luaTextView;
	_staticLuaConsoleDelegate = self;
	
//	[_luaTextView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	_command = @"";

	
	_interactive=lua_objc_init();
	
	_ffm = ((OxidizerDelegate *)self->delegate)->ffm;
	
	lua_objc_pushid(_interactive,_ffm);
	lua_setglobal(_interactive, "oxidizer");
		
	lua_objc_pushid(_interactive,self);
	lua_setglobal(_interactive, "oxidizer_api");
	
	NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
	
	[returnDictionary setValue:@"not_set" forKey:@"action"];
	[returnDictionary setValue:[NSNumber numberWithInt:0] forKey:@"code"];
	[returnDictionary setValue:@"" forKey:@"message"];
	
	lua_objc_pushpropertylist(_interactive,returnDictionary);

	lua_setglobal(_interactive, "oxidizer_status");
	
	lua_register(_interactive,"print",print);
		
}
	

- (IBAction) runCommand:(id)sender {
	
	[self setCommand:[_luaTextField stringValue]];
	[_luaTextView appendLine:_command];
	[_luaTextField setStringValue:@""];
	dotty (_interactive);
	[_luaTextView forceDisplay];
}

				
- (NSString *)command {
	
	return _command;
}


- (void) setCommand:(NSString *)command {

	if(command != nil) {
		
		[command retain];
		
	}
	
	[_command release];
	_command = command;
	
	
}


- (void) runLuaScript:(NSString *)script {
	
	
	
	NSString *lastScript = [NSString stringWithContentsOfFile:script];
	int luaScriptLength = [lastScript lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	interpreter=lua_objc_init();
	
	FractalFlameModel *ffm = ((OxidizerDelegate *)self->delegate)->ffm;
	
	lua_objc_pushid(interpreter,ffm);
	lua_setglobal(interpreter, "oxidizer");
	
	lua_objc_pushpropertylist(interpreter,[ffm passGenomesToLua]);
	lua_setglobal(interpreter, "oxidizer_genomes");
	
	lua_objc_pushid(interpreter,self);
	lua_setglobal(interpreter, "oxidizer_delegate");
	
	NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
	
	[returnDictionary setValue:@"not_set" forKey:@"action"];
	[returnDictionary setValue:[NSNumber numberWithInt:0] forKey:@"code"];
	[returnDictionary setValue:@"" forKey:@"message"];
	
	lua_objc_pushpropertylist(interpreter,returnDictionary);
	lua_setglobal(interpreter, "oxidizer_status");
	
	lua_register(interpreter,"print",print);
	
	luaL_loadbuffer(interpreter,[lastScript cStringUsingEncoding:NSUTF8StringEncoding],luaScriptLength,"Main script");

//	[_luaTextView setEditable:YES];
	lua_pcall(interpreter,0,0,0);
//	[_luaTextView setEditable:NO];
	
	lua_getglobal(interpreter, "oxidizer_status");
	NSObject *returnThing = (NSString *)lua_objc_topropertylist(interpreter, 1);
	
	lua_getglobal(interpreter, "oxidizer_genomes");
	NSObject *returnObject = lua_objc_topropertylist(interpreter, 2);
	
	
//	print_stack(interpreter);
	
	if ([returnThing isKindOfClass:[NSString class]] && (![(NSString *)returnThing isEqualToString:@""]) ) {
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Lua Script failed!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:(NSString *)returnThing];
		[finishedPanel runModal];	
		
		lua_close(interpreter);
		interpreter = nil;
		return;
		
	}
	
	NSDictionary *returnValues = (NSDictionary *)returnThing;
	
	
	if ([[returnValues valueForKey:@"action"] isEqualToString:@"not_set"]) {
		
		
		/* treat it like the pre 0.4.2 return */
		
		if ([returnObject isKindOfClass:[NSArray class]]) {
			if([(NSArray *)returnObject count] > 0) {
				[ffm deleteOldGenomes];
				[ffm appendGenomesFromLua:(NSArray *)returnObject]; 			
			}
		} else if ([returnObject isKindOfClass:[NSString class]] && (![(NSString *)returnObject isEqualToString:@""]) ) {
			NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Lua Script failed!" 
													 defaultButton:@"Close"
												   alternateButton:nil 
													   otherButton:nil 
										 informativeTextWithFormat:(NSString *)returnObject];
			[finishedPanel runModal];	
		}
		
	} else if ([[returnValues valueForKey:@"action"] isEqualToString:@"replace"]) {
		
		/* action of replace, replaces the current genome with that generated from lua */
		
		if ([returnObject isKindOfClass:[NSArray class]]) {
			if([(NSArray *)returnObject count] > 0) {
				[ffm deleteOldGenomes];
				[ffm appendGenomesFromLua:(NSArray *)returnObject]; 			
			}
		}		
	} else if ([[returnValues valueForKey:@"action"] isEqualToString:@"append"]) {
		
		/* action of append, append the genome from lua to the current genome */
		
		if ([returnObject isKindOfClass:[NSArray class]]) {
			if([(NSArray *)returnObject count] > 0) {
				[ffm appendGenomesFromLua:(NSArray *)returnObject]; 			
			}
		}
	} else if ([[returnValues valueForKey:@"action"] isEqualToString:@"warning"]) {
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Lua Script warning!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:(NSString *)[returnValues valueForKey:@"message"]];
		[finishedPanel setAlertStyle:NSWarningAlertStyle];
		[finishedPanel runModal];	
		
	} else if ([[returnValues valueForKey:@"action"] isEqualToString:@"error"]) {
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Lua Script error!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:(NSString *)[returnValues valueForKey:@"message"]];
		[finishedPanel setAlertStyle:NSCriticalAlertStyle];
		[finishedPanel runModal];			
		
	}  else if ([[returnValues valueForKey:@"action"] isEqualToString:@"message"]) {
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Lua Script message" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:(NSString *)[returnValues valueForKey:@"message"]];
		[finishedPanel setAlertStyle:NSInformationalAlertStyle];
		[finishedPanel runModal];			
		
	}
	
	[_staticLuaConsole forceDisplay];

	lua_close(interpreter);
	
	interpreter = nil;
	
	return;
	
}


- (NSArray *)passGenomesToLua {
	
	
	return [(FractalFlameModel *)_ffm passGenomesToLua];
	
}

- (void)appendGenomesFromLua:(NSString *)globalName {
	
	
	lua_getglobal(_interactive, [globalName cStringUsingEncoding:NSUTF8StringEncoding]);
	
	int globaIndex = lua_gettop(_interactive);
	
	NSArray *newGenomes = lua_objc_topropertylist(_interactive, globaIndex);
	
	[newGenomes retain];
	
	[(FractalFlameModel *)_ffm appendGenomesFromLua:newGenomes];
	
	[newGenomes release];
		
	//	NSLog(@"%@", newGenome);
	
}

- (void)replaceWithGenomesFromLua:(NSString *)globalName {
	
	[(FractalFlameModel *)_ffm deleteOldGenomes];
	[self appendGenomesFromLua:globalName];
}


- (int) renderGenome:(NSArray *)genomes toPng:(NSString *)filename {
	
	[(FractalFlameModel *)_ffm deleteOldGenomes];
	[(FractalFlameModel *)_ffm appendGenomesFromLua:genomes]; 
	return [(FractalFlameModel *)_ffm renderGenomeToPng:filename] ? 0 : 1;
}

- (IBAction) copy:(id)sender {
	
	NSString *tmpString = [_luaTextView copy];
	
	[[NSPasteboard generalPasteboard] declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner:nil];
	[[NSPasteboard generalPasteboard] setString:tmpString forType: NSStringPboardType];	

	[tmpString release];


}

- (IBAction) paste:(id)sender {
	
	
}



@end



/* lua helper functions */
void print_value(lua_State* interpreter,int stack_index,int indent){
	
	//
	// Use absolute stack indices to make sure we don't get confused later
	//
	
	if(stack_index<0){
		stack_index=lua_gettop(interpreter)+stack_index+1;
	}
	
	//
	// Print data about the value
	//
	
	switch(lua_type(interpreter,stack_index)){
		case LUA_TNIL:{
			fprintf(stderr,"nil");
			break;
		}
		case LUA_TNUMBER:{
			double number=lua_tonumber(interpreter,stack_index);
			if(floor(number)==number){
				fprintf(stderr,"number: %ld",lround(number));
			}
			else{
				fprintf(stderr,"number: %e",number);
			}
			break;
		}
		case LUA_TBOOLEAN:{
			fprintf(stderr,"boolean: %s",lua_toboolean(interpreter,stack_index)?"true":"false");
			break;
		}
		case LUA_TSTRING:{
			fprintf(stderr,"string: \"%s\"",lua_tostring(interpreter,stack_index));
			break;
		}
		case LUA_TTABLE:{
			int i;
			indent++;
			fprintf(stderr,"table: <%p> {",lua_topointer(interpreter,stack_index));
			
			//
			// Iterate through each key/value pair in the table
			//
			
			lua_pushnil(interpreter);
			while(lua_next(interpreter,stack_index)!=0){
				fprintf(stderr,"\n");
				
				//
				// Indent properly
				//
				
				for(i=0;i<=indent;i++){
					fprintf(stderr,"\t");
				}
				
				//
				// Print the key/value pair
				//
				
				print_value(interpreter,-2,indent+1);
				fprintf(stderr," => ");
				print_value(interpreter,-1,indent+1);
				lua_pop(interpreter,1);
			}
			fprintf(stderr,"\n");
			//lua_pop(interpreter,1);
			
			//
			// Print closing brace
			//
			
			for(i=0;i<=indent;i++){
				fprintf(stderr,"\t");
			}
			fprintf(stderr,"}");
			break;
		}
		case LUA_TFUNCTION:{
			fprintf(stderr,"function: <%p>",lua_topointer(interpreter,stack_index));
			break;
		}
		case LUA_TUSERDATA:{
			fprintf(stderr,"userdata: <%p>",lua_topointer(interpreter,stack_index));
			break;
		}
		case LUA_TTHREAD:{
			fprintf(stderr,"thread: <%p>",lua_topointer(interpreter,stack_index));
			break;
		}
		case LUA_TNONE:{
			fprintf(stderr,"bad index");
			break;
		}
		default:{
			fprintf(stderr,"unrecognised");
		}
	}
}

void print_stack(lua_State* interpreter){
	int stack_index=lua_gettop(interpreter);
	for(;stack_index!=0;stack_index--){
		fprintf(stderr,"%d: ",stack_index);
		print_value(interpreter,stack_index,0);
		fprintf(stderr,"\n");
	}
}


int print(lua_State *L)
{
	
	
	int n=lua_gettop(L);
	int i;
	for (i=1; i<=n; i++)
	{
		if (i>1) {
			[_staticLuaConsole buildString:@"\t"];
		}
		if (lua_isstring(L,i)) {
			[_staticLuaConsole buildString:[NSString stringWithCString:lua_tostring(L,i)]];
		}
		else {
			[_staticLuaConsole buildString:[NSString stringWithFormat:@"%s:%p",lua_typename(L,lua_type(L,i)),lua_topointer(L,i)]];
		}
	}

	[_staticLuaConsole appendBuiltString];
	[_staticLuaConsole displayIfNeeded];
	return 0;
}


// The code below is mostly copied from the lua interepter  

/*
 ** $Id: LuaConsoleDelegate.m,v 1.6 2010/12/01 14:29:30 vargol Exp $
 ** Lua stand-alone interpreter
 ** See Copyright Notice in lua.h
 */


#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(LUA_USE_READLINE)
#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>
#define lua_readline(L,b,p)     ((void)L, ((b)=readline(p)) != NULL)
#define lua_saveline(L,idx) \
if (lua_strlen(L,idx) > 0)  /* non-empty line? */ \
add_history(lua_tostring(L, idx));  /* add it to history */
#define lua_freeline(L,b)       ((void)L, free(b))
#else
#define lua_readline(L,b,p)     \
((void)L, fputs(p, stdout), fflush(stdout),  /* show prompt */ \
fgets(b, LUA_MAXINPUT, stdin) != NULL)  /* get line */
#define lua_saveline(L,idx)     { (void)L; (void)idx; }
#define lua_freeline(L,b)       { (void)L; (void)b; }
#endif

#define lua_c

/*
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "LuaConsoleApi.h"
*/


static lua_State *globalL = NULL;

static const char *progname = "Oxidizer Console";



static void lstop (lua_State *L, lua_Debug *ar) {
	(void)ar;  /* unused arg. */
	lua_sethook(L, NULL, 0, 0);
	luaL_error(L, "interrupted!");
}


static void laction (int i) {
	signal(i, SIG_DFL); /* if another SIGINT happens before lstop,
	 terminate process (default action) */
	lua_sethook(globalL, lstop, LUA_MASKCALL | LUA_MASKRET | LUA_MASKCOUNT, 1);
}


static void print_usage (void) {
	fprintf(stderr,
			"usage: %s [options] [script [args]].\n"
			"Available options are:\n"
			"  -e stat  execute string " LUA_QL("stat") "\n"
			"  -l name  require library " LUA_QL("name") "\n"
			"  -i       enter interactive mode after executing " LUA_QL("script") "\n"
			"  -v       show version information\n"
			"  --       stop handling options\n"
			"  -        execute stdin and stop handling options\n"
			,
			progname);
	fflush(stderr);
}


static void l_message (const char *pname, const char *msg) {
	
	if (pname) fprintf(stderr, "%s: ", pname);
	fprintf(stderr, "%s\n", msg);
	fflush(stderr);

	[_staticLuaConsole insertText:[NSString stringWithFormat:@"%s: ", pname]];
	[_staticLuaConsole insertText:[NSString stringWithFormat:@"%s\n", msg]];
}


static int report (lua_State *L, int status) {
	if (status && !lua_isnil(L, -1)) {
		const char *msg = lua_tostring(L, -1);
		if (msg == NULL) msg = "(error object is not a string)";
		l_message(progname, msg);
		lua_pop(L, 1);
	}
	return status;
}


static int traceback (lua_State *L) {
	lua_getfield(L, LUA_GLOBALSINDEX, "debug");
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		return 1;
	}
	lua_getfield(L, -1, "traceback");
	if (!lua_isfunction(L, -1)) {
		lua_pop(L, 2);
		return 1;
	}
	lua_pushvalue(L, 1);  /* pass error message */
	lua_pushinteger(L, 2);  /* skip this function and traceback */
	lua_call(L, 2, 1);  /* call debug.traceback */
	return 1;
}


static int docall (lua_State *L, int narg, int clear) {
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	signal(SIGINT, laction);
	status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
	signal(SIGINT, SIG_DFL);
	lua_remove(L, base);  /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
	return status;
}


static void print_version (void) {
	l_message(NULL, LUA_VERSION "  " LUA_COPYRIGHT);
}


static int getargs (lua_State *L, char **argv, int n) {
	int narg;
	int i;
	int argc = 0;
	while (argv[argc]) argc++;  /* count total number of arguments */
	narg = argc - (n + 1);  /* number of arguments to the script */
	luaL_checkstack(L, narg + 3, "too many arguments to script");
	for (i=n+1; i < argc; i++)
		lua_pushstring(L, argv[i]);
	lua_createtable(L, narg, n + 1);
	for (i=0; i < argc; i++) {
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i - n);
	}
	return narg;
}


static int dofile (lua_State *L, const char *name) {
	int status = luaL_loadfile(L, name) || docall(L, 0, 1);
	return report(L, status);
}


static int dostring (lua_State *L, const char *s, const char *name) {
	int status = luaL_loadbuffer(L, s, strlen(s), name) || docall(L, 0, 1);
	return report(L, status);
}


static int dolibrary (lua_State *L, const char *name) {
	lua_getglobal(L, "require");
	lua_pushstring(L, name);
	return report(L, lua_pcall(L, 1, 0, 0));
}


static const char *get_prompt (lua_State *L, int firstline) {
	const char *p;
	lua_getfield(L, LUA_GLOBALSINDEX, firstline ? "_PROMPT" : "_PROMPT2");
	p = lua_tostring(L, -1);
	if (p == NULL) p = (firstline ? LUA_PROMPT : LUA_PROMPT2);
	lua_pop(L, 1);  /* remove global */
	return p;
}


static int incomplete (lua_State *L, int status) {
	if (status == LUA_ERRSYNTAX) {
		size_t lmsg;
		const char *msg = lua_tolstring(L, -1, &lmsg);
		const char *tp = msg + lmsg - (sizeof(LUA_QL("<eof>")) - 1);
		if (strstr(msg, LUA_QL("<eof>")) == tp) {
			lua_pop(L, 1);
			return 1;
		}
	}
	return 0;  /* else... */
}


static int pushline (lua_State *L, int firstline) {

	NSString *command = [_staticLuaConsoleDelegate command];
	size_t l = [command lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	char *b = (char *)malloc(l+1);
	memcpy(b, [command UTF8String], l+1);

	const char *prompt = get_prompt(L, firstline);
	[_staticLuaConsole buildString:[NSString stringWithCString:prompt]];

	if (l == 0)
		return 0;  /* no input */
	if (l > 0 && b[l-1] == '\n')  /* line ends with newline? */
		b[l-1] = '\0';  /* remove it */
	if (firstline && b[0] == '=')  /* first line starts with `=' ? */
		lua_pushfstring(L, "return %s", b+1);  /* change it to `return' */
	else
		lua_pushstring(L, b);
	lua_freeline(L, b);

	[_staticLuaConsoleDelegate setCommand:@""];

	return 1;
}


static int loadline (lua_State *L) {
	int status;
	lua_settop(L, 0);
	if (!pushline(L, 1))
		return -1;  /* no input */
	for (;;) {  /* repeat until gets a complete line */
		status = luaL_loadbuffer(L, lua_tostring(L, 1), lua_strlen(L, 1), "=stdin");
		if (!incomplete(L, status)) break;  /* cannot try to add lines? */
		if (!pushline(L, 0))  /* no more input? */
			return -1;
		lua_pushliteral(L, "\n");  /* add a new line... */
		lua_insert(L, -2);  /* ...between the two lines */
		lua_concat(L, 3);  /* join them */
	}
	lua_saveline(L, 1);
	lua_remove(L, 1);  /* remove line */
	return status;
}


static void dotty (lua_State *L) {
	
	print_stack(L);
	
	int status;
	const char *oldprogname = progname;
	progname = NULL;
	while ((status = loadline(L)) != -1) {
		if (status == 0) status = docall(L, 0, 0);
		report(L, status);
		if (status == 0 && lua_gettop(L) > 0) {  /* any result to print? */
			lua_getglobal(L, "print");
			lua_insert(L, 1);
			if (lua_pcall(L, lua_gettop(L)-1, 0, 0) != 0)
				l_message(progname, lua_pushfstring(L,
													"error calling " LUA_QL("print") " (%s)",
													lua_tostring(L, -1)));
		} 
	}
	lua_settop(L, 0);  /* clear stack */

//	[_staticLuaConsole insertText:@"\n"];

	progname = oldprogname;
}


static int handle_script (lua_State *L, char **argv, int n) {
	int status;
	const char *fname;
	int narg = getargs(L, argv, n);  /* collect arguments */
	lua_setglobal(L, "arg");
	fname = argv[n];
	if (strcmp(fname, "-") == 0 && strcmp(argv[n-1], "--") != 0) 
		fname = NULL;  /* stdin */
	status = luaL_loadfile(L, fname);
	lua_insert(L, -(narg+1));
	if (status == 0)
		status = docall(L, narg, 0);
	else
		lua_pop(L, narg);      
	return report(L, status);
}


static int collectargs (char **argv, int *pi, int *pv, int *pe) {
	int i;
	for (i = 1; argv[i] != NULL; i++) {
		if (argv[i][0] != '-')  /* not an option? */
			return i;
		switch (argv[i][1]) {  /* option */
			case '-': return (argv[i+1] != NULL ? i+1 : 0);
			case '\0': return i;
			case 'i': *pi = 1;  /* go through */
			case 'v': *pv = 1; break;
			case 'e': *pe = 1;  /* go through */
			case 'l':
				if (argv[i][2] == '\0') {
					i++;
					if (argv[i] == NULL) return -1;
				}
				break;
			default: return -1;  /* invalid option */
		}
	}
	return 0;
}


static int runargs (lua_State *L, char **argv, int n) {
	int i;
	for (i = 1; i < n; i++) {
		if (argv[i] == NULL) continue;
		lua_assert(argv[i][0] == '-');
		switch (argv[i][1]) {  /* option */
			case 'e': {
				const char *chunk = argv[i] + 2;
				if (*chunk == '\0') chunk = argv[++i];
				lua_assert(chunk != NULL);
				if (dostring(L, chunk, "=(command line)") != 0)
					return 1;
				break;
			}
			case 'l': {
				const char *filename = argv[i] + 2;
				if (*filename == '\0') filename = argv[++i];
				lua_assert(filename != NULL);
				if (dolibrary(L, filename))
					return 1;  /* stop if file fails */
				break;
			}
			default: break;
		}
	}
	return 0;
}


static int handle_luainit (lua_State *L) {
	const char *init = getenv("LUA_INIT");
	if (init == NULL) return 0;  /* status OK */
	else if (init[0] == '@')
		return dofile(L, init+1);
	else
		return dostring(L, init, "=LUA_INIT");
}



