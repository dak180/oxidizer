#import "TransformTableDelegate.h"

@implementation TransformTableDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	
	[_oxidizerDelegate callSetTreeSelection];
	
}

@end
