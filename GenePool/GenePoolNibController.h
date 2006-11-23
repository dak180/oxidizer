/* GenePoolNibController */

#import <Cocoa/Cocoa.h>
#import "GenePoolController.h"
#import "FractalFlameModel.h"

@interface GenePoolNibController : NSObject
{
    IBOutlet GenePoolController *genePoolController;
}

- (void) setFractalFlameModel:(FractalFlameModel *)ffm;
- (void) showGenePoolWindow:(id)sender;

@end
