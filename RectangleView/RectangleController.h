/* RectangleController */

#import <Cocoa/Cocoa.h>
#import "RectangleView.h"

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

	IBOutlet NSMatrix *modeMatrix;

@private 
	
	
	CGFloat a ;
	CGFloat b;
	
	CGFloat d;
	CGFloat e;
	
	CGFloat c;
	CGFloat f;	
	
	NSManagedObject *currentTransform;
	
}
- (IBAction)showWindow:(id)sender;
- (IBAction)viewSizeChanged:(id)sender;
- (IBAction)coefficentChanged:(id)sender;
- (IBAction)modeChanged:(id)sender;

/* delegete messages */

- (void)controlTextDidChange:(NSNotification *)aNotification;
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
- (void) setCoeffsA:(CGFloat )aIn b:(CGFloat )bIn c:(CGFloat )cIn d:(CGFloat )dIn e:(CGFloat )eIn f:(CGFloat )fIn;
@end
