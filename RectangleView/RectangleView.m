#import "RectangleView.h"

#include <math.h>

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation RectangleView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		;
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	
	double scale =  10.0;
	
    CGContextRef myContext = [[NSGraphicsContext currentContext]graphicsPort];		
	
	CGContextSaveGState (myContext);
	
	// draw grid and fixed rectangles
	
	// translate to middle of grid
	CGContextTranslateCTM (myContext, [self frame].size.width * 0.5, [self frame].size.height * 0.5);
	
	/* draw five rectangles */
	
	CGRect aRect;
	
	aRect.origin.x = -0.5 * scale;
	aRect.origin.x = -0.5 * scale;
	aRect.size.width = 1.0 * scale;
	aRect.size.height = 1.0 * scale;
	
	CGContextStrokeRect(myContext, aRect);
	
	int i;
	
	for (i=0; i<4; i++) {
		
		CGContextTranslateCTM (myContext, 5 * scale, 5 * -scale);
		CGContextRotateCTM (myContext, radians(60));
		CGContextScaleCTM (myContext, 2, 2);
		CGContextStrokeRect(myContext, aRect);
				
	}

    CGContextRestoreGState (myContext);
	 
		 
}

@end
