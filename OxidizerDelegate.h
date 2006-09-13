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

/* Actions */
- (IBAction)openFile:(id)sender;
- (IBAction)saveFlam3:(id)sender;
- (IBAction)saveAsFlam3:(id)sender;
- (IBAction)showBreedingWindow:(id)sender;
- (IBAction)newFlame:(id)sender;
- (IBAction)renderStill:(id)sender;
- (IBAction)renderMovie:(id)sender;
- (IBAction)renderStillToWindow:(id)sender;	

@end
