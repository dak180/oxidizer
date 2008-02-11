/* RectangleController */

#import <Cocoa/Cocoa.h>
#import "RectangleView.h"
#import "FractalFlameModel.h"

@interface RectangleController : NSObject
{
    IBOutlet RectangleView *rectangleView;
    IBOutlet NSWindow *rectangleWindow;
    IBOutlet NSTextField *aTextField;
    IBOutlet NSTextField *bTextField;
    IBOutlet NSTextField *cTextField;
    IBOutlet NSTextField *dTextField;
    IBOutlet NSTextField *eTextField;
    IBOutlet NSTextField *fTextField;

	IBOutlet NSTextField *moveX;
	IBOutlet NSTextField *moveY;
	IBOutlet NSTextField *rotate;
	IBOutlet NSTextField *scaleP1;
	IBOutlet NSTextField *scaleP2;

	IBOutlet NSMatrix *modeMatrix;

	IBOutlet NSTreeController *treeController;

	IBOutlet NSButton *undoButton;
	IBOutlet NSButton *redoButton;

@private 
	
	
	CGFloat a ;
	CGFloat b;
	
	CGFloat d;
	CGFloat e;
	
	CGFloat c;
	CGFloat f;	
	
	NSManagedObject *_currentTransform;
	FractalFlameModel *_ffm;
	BOOL _autoUpdatePreview;
	NSArray *_sortDescriptors;
	BOOL _editPostTransformations;
	
	NSMutableArray *_undoStack;
	int _undoStackPointer;
	
}
- (IBAction)showWindow:(id)sender;
- (IBAction)viewSizeChanged:(id)sender;
- (IBAction)coefficentChanged:(id)sender;
- (IBAction)modeChanged:(id)sender;


- (IBAction)rotationChanged:(id)sender;
- (IBAction)moveChanged:(id)sender;
- (IBAction)scaleChanged:(id)sender;

- (IBAction)updatePreview:(id)sender;
- (IBAction)toggleTransformationType:(id)sender;

- (IBAction) undoEntry:(id)sender;
- (IBAction) redoEntry:(id)sender;

/* delegete messages */

- (void)controlTextDidChange:(NSNotification *)aNotification;
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
- (void)setCoeffsA:(CGFloat )aIn b:(CGFloat )bIn c:(CGFloat )cIn d:(CGFloat )dIn e:(CGFloat )eIn f:(CGFloat )fIn;

/* preview */
- (void)setFractalFlameModel:(FractalFlameModel *)ffm;

/* undo stack */
- (void) resetUndoStack;
- (void) addUndoEntry;

@end
