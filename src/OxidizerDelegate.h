/* ToolbarController */

#import <Cocoa/Cocoa.h>
#import "FractalFlameModel.h"
#import "BreedingController.h"
#import "GenePoolController.h"
#import "GenePoolNibController.h"
#import "RectangleNibController.h"
#import "GradientNibController.h"
#import "QuickViewController.h"
#import "LuaConsoleDelegate.h"


@interface OxidizerDelegate : NSObject {

	IBOutlet NSWindow *oxidizerWindow;
	IBOutlet NSWindow *_clipboardWindow;
	IBOutlet BreedingController *bc;
    IBOutlet QuickViewController *_qvc;
    IBOutlet NSArrayController *_luaLibraryController;
    IBOutlet NSTextView *_luaConsole;
	IBOutlet NSWindow *_luaConsoleWindow;
	IBOutlet LuaConsoleDelegate *_luaConsoleDelegate;

@public
	IBOutlet FractalFlameModel *ffm;

@private

//	GenePoolController *gpc;
	GenePoolNibController *gpnc;
	RectangleNibController *rnc;

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
- (IBAction)showClipboard:(id)sender;
//- (IBAction)showGradientWindow:(id)sender;
- (IBAction)newFlame:(id)sender;
- (IBAction)renderStill:(id)sender;
- (IBAction)renderMovie:(id)sender;
- (IBAction)renderStillToWindow:(id)sender;
- (IBAction)renderStills:(id)sender;
- (IBAction)renderToPNG:(id)sender;
- (IBAction)makeLoop:(id)sender;
- (IBAction)makeLoopFromAll:(id)sender;
- (IBAction)appendNewEmptyGenome:(id)sender;

- (IBAction)runLuaScript:(id)sender;
- (IBAction)runLastLuaScript:(id) sender;
- (IBAction)luaLibraryAction:(id) sender;
- (IBAction) showLuaConsole:(id) sender;

- (void) setLastLuaScript: (NSString *)lls;
- (int) renderFromLua:(NSArray *) genomes;
- (int) renderGenome:(NSArray *)genomes toPng:(NSString *)filename;
- (void)callSetTreeSelection;

@end
