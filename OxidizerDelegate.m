#import "OxidizerDelegate.h"
#include "LuaObjCBridge/LuaObjCBridge.h"

@implementation OxidizerDelegate 

- (void) awakeFromNib {
	
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
	}
	
	return [item autorelease];
	
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {

	return [NSArray arrayWithObjects:@"open_flam3",
									 @"save_flam3",
									 NSToolbarSeparatorItemIdentifier,
								     @"render_still", 
									 @"render_movie", 
									 NSToolbarSeparatorItemIdentifier,
									 @"breed_flam3", 
									 @"gene_pool", 
									 nil
		];
	
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {

	return [NSArray arrayWithObjects:@"open_flam3", 
									 @"save_flam3",
									 NSToolbarSeparatorItemIdentifier,
									 @"render_still", 
									 @"render_movie", 
									 NSToolbarSeparatorItemIdentifier,
									 @"breed_flam3", 
									 @"gene_pool", 
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

- (IBAction)newFlame:(id)sender {
	[ffm newFlame];
}	

- (IBAction)renderStill:(id)sender {
	
	[ffm renderStill];
}

- (IBAction)renderStillUsingFlam3:(id)sender {
	
	[ffm renderStillUsingFlam3];
}

- (IBAction)renderStillToWindow:(id)sender {
	[ffm renderStillToWindow];
}

- (IBAction)renderMovie:(id)sender {

 	[ffm renderAnimation];

}



- (IBAction)runLuaScript:(id)sender {
	
	lua_State* interpreter=lua_objc_init();
		
	lua_objc_pushid(interpreter,ffm);
	lua_setglobal(interpreter, "oxidizer");
	
	lua_objc_pushpropertylist(interpreter,[ffm passSelectedGenomeToLua]);
	lua_setglobal(interpreter, "selected_flame");
	
	
	NSString *luaScript = [NSString stringWithContentsOfFile:@"/Users/vargol/Source/oxidizer/test.lua"];
	
	int luaScriptLength = [luaScript lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	luaL_loadbuffer(interpreter,[luaScript cStringUsingEncoding:NSUTF8StringEncoding],luaScriptLength,"Main script");
	lua_pcall(interpreter,0,0,0);
	
	//
	// Put further C code which you want to test here
	//
	
	
	
	//
	// Clean up and exit
	//
	
	lua_close(interpreter);
	return;
	
}

@end
