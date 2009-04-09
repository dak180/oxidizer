#import "OxidizerDelegate.h"
#import <sys/sysctl.h>


//
// Prints the type and value of the specified item on the Lua stack. The indent
// parameter is used to ensure that items inside nested tables are printed
// nicely, so you can just pass a value of 0 if you're calling this directly.
//

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


@implementation OxidizerDelegate 

+ (void)initialize {

	unsigned int cpuCount ;
	size_t len = sizeof(cpuCount);
	static int mib[2] = { CTL_HW, HW_NCPU };
	
	NSString *threads;
	
	if(sysctl(mib, 2,  &cpuCount, &len, NULL, 0) == 0 && len ==  sizeof(cpuCount)) {
		threads = [NSString stringWithFormat:@"%ld", cpuCount];
	} else {
		threads = @"1";
	}  

	
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
	
    NSString *applicationSupportFolder = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Oxidizer"];
	[[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportFolder attributes:nil];

}

- (void) awakeFromNib {
	
	_lastLuaScript = nil;

	[self setupToolbar];

}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier  willBeInsertedIntoToolbar:(BOOL)flag {

	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];

	if ( [itemIdentifier isEqualToString:@"open_flam3"] ) {
		[item setLabel:@"Open"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"document-open"]];
		[item setTarget:self];
		[item setAction:@selector(openFile:)];
    } else if ( [itemIdentifier isEqualToString:@"save_flam3"] ) {
		[item setLabel:@"Save"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"document-save"]];
		[item setTarget:self];
		[item setAction:@selector(saveFlam3:)];
    } else if ( [itemIdentifier isEqualToString:@"render_still"] ) {
		[item setLabel:@"Render"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"image-x-generic"]];
		[item setTarget:self];
		[item setAction:@selector(renderStill:)];
    } else if ( [itemIdentifier isEqualToString:@"render_movie"] ) {
		[item setLabel:@"Animate"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"video-x-generic"]];
		[item setTarget:self];
		[item setAction:@selector(renderMovie:)];
    } else if ( [itemIdentifier isEqualToString:@"render_stills"] ) {
		[item setLabel:@"Stills"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"stills"]];
		[item setTarget:self];
		[item setAction:@selector(renderStills:)];
    } else if ( [itemIdentifier isEqualToString:@"breed_flam3"] ) {
		[item setLabel:@"Breeder"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"oxidizer_dna"]];
		[item setTarget:self];
		[item setAction:@selector(showBreedingWindow:)];
    } else if ( [itemIdentifier isEqualToString:@"gene_pool"] ) {
		[item setLabel:@"Gene Pool"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"genepool"]];
		[item setTarget:self];
		[item setAction:@selector(showGenePoolWindow:)];
	} else if ( [itemIdentifier isEqualToString:@"lua_script"] ) {
		[item setLabel:@"Lua Script"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"text-x-script"]];
		[item setTarget:self];
		[item setAction:@selector(runLuaScript:)];
	} else if ( [itemIdentifier isEqualToString:@"transformation_editor"] ) {
		[item setLabel:@"XForm Editor"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"transform-scale"]];
		[item setTarget:self];
		[item setAction:@selector(showRectangleWindow:)];
	}
	
	return [item autorelease];
	
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {

	return [NSArray arrayWithObjects:@"open_flam3",
									 @"save_flam3",
									 NSToolbarSeparatorItemIdentifier,
								     @"render_still", 
									 @"render_movie", 
									 @"render_stills", 
									 NSToolbarSeparatorItemIdentifier,
									 @"transformation_editor", 
									 @"breed_flam3", 
									 @"gene_pool", 
									 NSToolbarSeparatorItemIdentifier,
									 @"lua_script", 
									 nil
		];
	
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {

	return [NSArray arrayWithObjects:@"open_flam3", 
									 @"save_flam3",
									 NSToolbarSeparatorItemIdentifier,
									 @"render_still", 
									 @"render_movie", 
									 @"render_stills", 
									 NSToolbarSeparatorItemIdentifier,
									 @"transformation_editor", 
									 @"breed_flam3", 
									 @"gene_pool", 
									 NSToolbarSeparatorItemIdentifier,
									 @"lua_script", 
									 nil
		];
	
}


- (void)setupToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"oxidizer_toolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [oxidizerWindow setToolbar:[toolbar autorelease]];
	if(![oxidizerWindow setFrameUsingName:@"oxidizer"]) {
		[oxidizerWindow center];	
	}
}


- (IBAction)customizeToolbar:(id)sender {
	
    [[oxidizerWindow toolbar] runCustomizationPalette:sender]; 
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item {
	
	if([[item itemIdentifier] isEqualToString:@"save_flam3"]) {
		
		if([ffm currentFilename] == nil) {
			
			return NO;
		}
	}
	
	return YES;
	
}


- (BOOL)validateMenuItem:(NSMenuItem *)item {
	
	if([[item  title] isEqualToString:@"Save"]) {
		
		if([ffm currentFilename] == nil) {
			
			return NO;
		}
	}
	
	return YES;
	
}


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
	
	return [ffm openRecentFile:filename];
	
}


/*Actions */

- (IBAction)openFile:(id)sender {
	
	[ffm openFile:sender]; 
	
}

- (IBAction)saveFlam3:(id)sender {
	
	[ffm saveFlam3WithThumbnail]; 
}

- (IBAction)saveAsFlam3:(id)sender {
	
	[ffm saveAsFlam3WithThumbnail]; 
}

- (IBAction)makeLoop:(id)sender {
	
	[ffm makeLoopfromCurrentFlame]; 
}



- (IBAction)showBreedingWindow:(id)sender {
	
	[bc showBreedingWindow:sender]; 
}

- (IBAction)showGenePoolWindow:(id)sender {
	

	if(gpnc == nil) {
		gpnc = [[GenePoolNibController alloc] init];
		[NSBundle loadNibNamed:@"GenePool" owner:gpnc];
		[gpnc setFractalFlameModel:ffm];
	}
		
	[gpnc showGenePoolWindow:sender]; 
}

- (IBAction)showRectangleWindow:(id)sender {
	
	if(rnc == nil) {
		rnc = [[RectangleNibController alloc] init];
		[NSBundle loadNibNamed:@"RectangleWindow" owner:rnc];
	}
	
	[rnc setMOC:[ffm getNSManagedObjectContext]];
	[rnc setFFM:ffm];
	[rnc setQVC:_qvc];
	[rnc showRectangleWindow:sender]; 
}

/*
- (IBAction)showGradientWindow:(id)sender {
	
	if(gnc == nil) {
		gnc = [[GradientNibController alloc] init];
		[NSBundle loadNibNamed:@"GradientWindow" owner:gnc];
	}
	
	[gnc showGradientWindow:sender]; 
}
*/

- (IBAction)newFlame:(id)sender {
	[ffm newFlame];
}	

- (IBAction)renderStill:(id)sender {
	
	[ffm renderStill];
}

- (IBAction)renderStills:(id)sender {
	
	[ffm renderAnimationStills];
}

- (IBAction)renderStillToWindow:(id)sender {
	[ffm renderStillToWindow];
}

- (IBAction)renderMovie:(id)sender {

 	[ffm renderAnimation];

}



- (IBAction)runLuaScript:(id)sender {
	
	
	NSOpenPanel *op;
	
	/* create or get the shared instance of NSSavePanel */
	op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"lua"];
	
	/* display the NSOpenPanel */
	int runResult = [op runModal];
	/* if successful, save file under designated name */
	if(runResult == NSCancelButton || [op filename] == nil) {
		return;	
	} 
	
	[_luaLibraryController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[op filename] lastPathComponent], @"file_name", 
									  [[op filename] stringByDeletingLastPathComponent], @"file_path", 
									  nil]]; 				
/*	
	id defaultValues = [NSUserDefaults standardUserDefaults];
	id scripts = [defaultValues objectForKey:@"MRU_scripts"];
	NSMutableArray *newScripts = [NSMutableArray arrayWithArray:scripts];
	[newScripts addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[op filename] lastPathComponent], @"file_name", [[op filename] stringByDeletingLastPathComponent], @"file_path", nil]];
	[defaultValues setObject:newScripts forKey:@"MRU_scripts"];
*/
	
	[self setLastLuaScript:[op filename]];
	
	[self runLastLuaScript:self];
	
}

- (void) setLastLuaScript: (NSString *)lls {
	
	if(lls != nil) {
		[lls retain];
	}
	
	[_lastLuaScript release];
	
	_lastLuaScript = lls;
}

- (IBAction) runLastLuaScript:(id) sender {


	NSString *lastScript = [NSString stringWithContentsOfFile:_lastLuaScript];
	int luaScriptLength = [lastScript lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	interpreter=lua_objc_init();
		
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

	
	luaL_loadbuffer(interpreter,[lastScript cStringUsingEncoding:NSUTF8StringEncoding],luaScriptLength,"Main script");
	lua_pcall(interpreter,0,0,0);

	lua_getglobal(interpreter, "oxidizer_status");
	NSObject *returnThing = (NSString *)lua_objc_topropertylist(interpreter, 1);

	lua_getglobal(interpreter, "oxidizer_genomes");
	NSObject *returnObject = lua_objc_topropertylist(interpreter, 2);

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
				[ffm createGenomesFromLua:(NSArray *)returnObject]; 			
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
				[ffm createGenomesFromLua:(NSArray *)returnObject]; 			
			}
		}		
	} else if ([[returnValues valueForKey:@"action"] isEqualToString:@"append"]) {
		
		/* action of append, append the genome from lua to the current genome */
		
		if ([returnObject isKindOfClass:[NSArray class]]) {
			if([(NSArray *)returnObject count] > 0) {
				[ffm createGenomesFromLua:(NSArray *)returnObject]; 			
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

	
	lua_close(interpreter);
	
	interpreter = nil;
	
	return;
	
}

- (IBAction) luaLibraryAction:(id) sender {

	NSString *filename;
	NSDictionary *script;
	
	NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	switch([segments selectedSegment]) {
		case 0: 
			script = [[_luaLibraryController selectedObjects] lastObject];
			filename = [[script objectForKey:@"file_path"] stringByAppendingPathComponent:[script objectForKey:@"file_name"]];
			[self setLastLuaScript:filename];
			[self runLastLuaScript:self];
			break;
		case 1:		
			{
				NSOpenPanel *op;
				
				/* create or get the shared instance of NSSavePanel */
				op = [NSOpenPanel openPanel];
				/* set up new attributes */
				[op setRequiredFileType:@"lua"];
				
				/* display the NSOpenPanel */
				int runResult = [op runModal];
				/* if successful, save file under designated name */
				if(runResult == NSCancelButton || [op filename] == nil) {
					break;	
				} 
				
				[_luaLibraryController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[op filename] lastPathComponent], @"file_name", 
												                                                    [[op filename] stringByDeletingLastPathComponent], @"file_path", 
												                                                    nil]]; 				
			}
			break;
		case 2:
			[_luaLibraryController  remove:sender];
			break;
	}
	
}

- (int) renderFromLua:(NSArray *) genomes {
	
		[ffm deleteOldGenomes];
		[ffm createGenomesFromLua:genomes]; 
		[ffm renderStill];

	return 0;
	
} 

- (int) renderGenome:(NSArray *)genomes toPng:(NSString *)filename {
	
	[ffm deleteOldGenomes];
	[ffm createGenomesFromLua:genomes]; 
	return [ffm renderGenomeToPng:filename] ? 0 : 1;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	
	[NSBundle loadNibNamed:@"QuickView" owner:_qvc];

	
}
@end





