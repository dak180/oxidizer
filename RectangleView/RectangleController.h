/* RectangleController */

#import <Cocoa/Cocoa.h>
#import "RectangleView.h"

@interface RectangleController : NSObject
{
    IBOutlet RectangleView *rectangleView;
    IBOutlet NSWindow *rectangleWindow;
}
- (IBAction)showWindow:(id)sender;
@end
