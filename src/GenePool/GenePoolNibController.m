#import "GenePoolNibController.h"

@implementation GenePoolNibController

- (void)setFractalFlameModel:(FractalFlameModel *)ffm {

	[genePoolController setFractalFlameModel:ffm];

}

- (void) showGenePoolWindow:(id)sender {

	[genePoolController	showGenePoolWindow:sender];
}

@end
