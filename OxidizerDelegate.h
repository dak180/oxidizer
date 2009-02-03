/* ToolbarController */

#import <Cocoa/Cocoa.h>
#import "FractalFlameModel.h"
#import "BreedingController.h"
#import "GenePoolController.h"
#import "GenePoolNibController.h"
#import "RectangleNibController.h"
#import "GradientNibController.h"
#import "QuickViewController.h"
#include "LuaObjCBridge/LuaObjCBridge.h"

@interface OxidizerDelegate : NSObject {
	
	IBOutlet NSWindow *oxidizerWindow;
	IBOutlet FractalFlameModel *ffm;
	IBOutlet BreedingController *bc;
    IBOutlet QuickViewController *_qvc;
    IBOutlet NSArrayController *_luaLibraryController;
	
	
@private
	
	GenePoolController *gpc;
	GenePoolNibController *gpnc;
	RectangleNibController *rnc;
	

	lua_State* interpreter;
	
	NSString *_lastLuaScript;
	
}


/* tool bar delegate  */
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;

/* recent file menu delegate */
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

/* instance */
- (void)setupToolbar;

/* Actions */
- (IBAction)customizeToolbar:(id)sender;
- (IBAction)openFile:(id)sender;
- (IBAction)saveFlam3:(id)sender;
- (IBAction)saveAsFlam3:(id)sender;
- (IBAction)showBreedingWindow:(id)sender;
- (IBAction)showGenePoolWindow:(id)sender;
- (IBAction)showRectangleWindow:(id)sender;
//- (IBAction)showGradientWindow:(id)sender;
- (IBAction)newFlame:(id)sender;
- (IBAction)renderStill:(id)sender;
- (IBAction)renderMovie:(id)sender;
- (IBAction)renderStillToWindow:(id)sender;	
- (IBAction)renderStills:(id)sender;

- (IBAction)runLuaScript:(id)sender;
- (IBAction)runLastLuaScript:(id) sender;
- (IBAction)luaLibraryAction:(id) sender;

- (void) setLastLuaScript: (NSString *)lls;
- (int) renderFromLua:(NSArray *) genomes;
- (int) renderGenome:(NSArray *)genomes toPng:(NSString *)filename;

@end
