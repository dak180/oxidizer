#import "OxidizerDelegate.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

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

- (IBAction)renderStillToWindow:(id)sender {
	[ffm renderStillToWindow];
}

- (IBAction)renderMovie:(id)sender {

 	[ffm renderAnimation];

}

- (IBAction)runLuaScript:(id)sender {
	
	lua_State *L;
	
	L=lua_open();
	luaopen_base(L);	// load basic libs (eg. print)
	
	Flam3_Init(L);	// load the wrappered module
	
	int err = luaL_loadfile(L, "/Users/vargol/Source/oxidizer/test.lua"); 
	if (err == 0) {

		lua_pcall(L,0,0,0);

	} 	else {

		NSLog(@"unable to load %s\n", "/Users/vargol/Source/oxidizer/test.lua");

	}

	lua_close(L);
	return;
	
}

- (flam3_frame *)getFlam3Frame {
	
	return [ffm getFlam3Frame];
	
}

- (void)setFlam3Frame:(flam3_frame *)frame {

	[ffm setFlam3Frame:frame];

	return;
}


@end
