#import "OxidizerDelegate.h"
#import <sys/sysctl.h>


//
// Prints the type and value of the specified item on the Lua stack. The indent
// parameter is used to ensure that items inside nested tables are printed
// nicely, so you can just pass a value of 0 if you're calling this directly.
//



@implementation OxidizerDelegate 

+ (void)initialize {

/*	unsigned int cpuCount ;
	size_t len = sizeof(cpuCount);
	static int mib[2] = { CTL_HW, HW_NCPU };
	
	NSString *threads;
	
	if(sysctl(mib, 2,  &cpuCount, &len, NULL, 0) == 0 && len ==  sizeof(cpuCount)) {
		threads = [NSString stringWithFormat:@"%ld", cpuCount];
	} else {
		threads = @"1";
	}  
*/
	
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
	} else if ( [itemIdentifier isEqualToString:@"lua_console"] ) {
		[item setLabel:@"Lua Console"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"utilities-terminal"]];
		[item setTarget:self];
		[item setAction:@selector(showLuaConsole:)];
	} else if ( [itemIdentifier isEqualToString:@"flame_clipboard"] ) {
		[item setLabel:@"Clipboard"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"edit-paste"]];
		[item setTarget:self];
		[item setAction:@selector(showClipboard:)];
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
									 @"lua_console",
									 @"flame_clipboard",
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
									 @"lua_console",
									 @"flame_clipboard", 
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
	
	[ffm makeLoopfromCurrentGenome]; 
}

- (IBAction)makeLoopFromAll:(id)sender {
	
	[ffm makeLoopFromAllGenomes]; 
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


	[rnc setTreeSelection];
	[rnc showRectangleWindow:sender]; 
}


- (IBAction)showClipboard:(id)sender {
	
	[_clipboardWindow makeKeyAndOrderFront:self];
}

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


- (IBAction)renderToPNG:(id)sender {
	
	if([[(NSMenuItem *)sender title] compare:@"16 bit"] == 0) {
		
		[ffm renderToPNG:16];
		
	} else {

		[ffm renderToPNG:8];

	}
	
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


	[_luaConsoleWindow makeKeyAndOrderFront:self];

	[_luaConsoleDelegate runLuaScript:_lastLuaScript];
	
	
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

- (IBAction) showLuaConsole:(id) sender {
	
	[_luaConsoleWindow makeKeyAndOrderFront:self];
	
}


- (int) renderFromLua:(NSArray *) genomes {
	
		[ffm deleteOldGenomes];
		[ffm appendGenomesFromLua:genomes]; 
		[ffm renderStill];

	return 0;
	
} 

- (int) renderGenome:(NSArray *)genomes toPng:(NSString *)filename {
	
	[ffm deleteOldGenomes];
	[ffm appendGenomesFromLua:genomes]; 
	return [ffm renderGenomeToPng:filename] ? 0 : 1;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	[NSBundle loadNibNamed:@"QuickView" owner:_qvc];
	if(rnc == nil) {
		rnc = [[RectangleNibController alloc] init];
		[NSBundle loadNibNamed:@"RectangleWindow" owner:rnc];
		[rnc setMOC:[ffm getNSManagedObjectContext]];
		[rnc setFFM:ffm];
		[rnc setQVC:_qvc];
	}

	[NSBundle loadNibNamed:@"LuaConsole" owner:self];
	[NSBundle loadNibNamed:@"Clipboard" owner:self];	

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	
	[_clipboardWindow close];
	[ffm closeMovieServer];
	
}

- (IBAction)appendNewEmptyGenome:(id)sender {
	
	[ffm AddEmptyGenomeToFlames]; 
}


- (void)callSetTreeSelection {

	[rnc setTreeSelection];

}

@end



