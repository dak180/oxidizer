/* ToolbarController */

#import <Cocoa/Cocoa.h>
#import "FractalFlameModel.h"
#import "BreedingController.h"

@interface OxidizerDelegate : NSObject {
	
	IBOutlet NSWindow *oxidizerWindow;
	IBOutlet FractalFlameModel *ffm;
	IBOutlet BreedingController *bc;
		
}


/* tool bar delegate  */
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;

/* recent file menu delegate */
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

/* instance */
- (void)setupToolbar;

@end
