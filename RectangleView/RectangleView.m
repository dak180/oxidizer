#import "RectangleView.h"

#include <math.h>

static inline double radians (double degrees) {return degrees * M_PI/180;}
void applyCoeffsToPoint(CGFloat x, CGFloat y, CGFloat a, CGFloat b, CGFloat c, CGFloat d, CGFloat e, CGFloat f, CGFloat *rx, CGFloat *ry );

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
	
	double scale =  80.0;
	
    CGContextRef myContext = [[NSGraphicsContext currentContext]graphicsPort];		
	
	CGContextSaveGState (myContext);
	
	
	CGFloat x[5][5];
	CGFloat y[5][5];
	
	CGFloat triangle [3][2][2];

/*	
	CGFloat a = 1.0;
	CGFloat b = 0.86603;
	CGFloat c = 1.0;
	CGFloat d = -0.86603;
	CGFloat e = 0.5;
	CGFloat f = 0.25;

*/	
	 CGFloat a = 0.5;
	 CGFloat b = 0.86603;
	 
	 CGFloat d = -0.86603;
	 CGFloat e = 0.5;
	 
	 CGFloat c = 1.0;
	 CGFloat f = 1.0;	
	 
	
	triangle [0][0][0] = 0.0;
	triangle [0][1][0] = -scale * 0.5;
	triangle [1][0][0] = 0.0;
	triangle [1][1][0] = 0.0;
	triangle [2][0][0] = scale * 0.5;
	triangle [2][1][0] = 0.0;

	triangle [0][0][1] = (a + c) * scale;
	triangle [0][1][1] = (d + f) * -scale;
	triangle [1][0][1] = c * scale;
	triangle [1][1][1] = f * -scale;
	triangle [2][0][1] = (b + c) * scale;
	triangle [2][1][1] = (e + f) * -scale;
	
	

	

	
	
	x[0][0] = -0.5;
	y[0][0] = -0.5;
	
	x[1][0] = 0.5;
	y[1][0] = -0.5;

	x[2][0] = 0.5;
	y[2][0] = 0.5;

	x[3][0] = -0.5;
	y[3][0] = 0.5;
	
	x[4][0] = 0;
	y[4][0] = 0;
	
	int i;



	
	for(i=1; i<5; i++) {
		
		applyCoeffsToPoint(x[0][i-1], y[0][i-1], a, b, c, d, e, f, &x[0][i], &y[0][i]); 
		applyCoeffsToPoint(x[1][i-1], y[1][i-1], a, b, c, d, e, f, &x[1][i], &y[1][i]); 
		applyCoeffsToPoint(x[2][i-1], y[2][i-1], a, b, c, d, e, f, &x[2][i], &y[2][i]); 
		applyCoeffsToPoint(x[3][i-1], y[3][i-1], a, b, c, d, e, f, &x[3][i], &y[3][i]); 
		applyCoeffsToPoint(x[4][i-1], y[4][i-1], a, b, c, d, e, f, &x[4][i], &y[4][i]); 
				
	}

	for(i=0; i<5; i++) {
		
		x[0][i] *= scale;
		y[0][i] *= scale;
		
		x[1][i] *= scale;
		y[1][i] *= scale;
		
		x[2][i] *= scale;
		y[2][i] *= scale;
		
		x[3][i] *= scale;
		y[3][i] *= scale;
		
		x[4][i] *= scale;
		y[4][i] *= scale;
		
	}
	
	
	
	
	// draw grid and fixed rectangles
	
	// translate to middle of grid
	CGContextTranslateCTM (myContext, [self frame].size.width * 0.5, [self frame].size.height * 0.5);
	CGContextScaleCTM(myContext, 1.0, -1.0);  // flip context so 0,0 s top left
	

	i = 0;	

	/* draw cirle at corner of triangle */
	CGContextMoveToPoint(myContext, triangle[0][0][1], triangle[0][1][1]);
	CGContextAddLineToPoint(myContext, triangle[1][0][1] , triangle[1][1][1]);
	CGContextAddLineToPoint(myContext, triangle[2][0][1] , triangle[2][1][1]);
	CGContextClosePath(myContext);
	CGContextStrokePath(myContext);
	
	
	CGContextAddArc (myContext, x[4][i], y[4][i], 5.0, 0.0, 2.0 * M_PI, 0);		
	CGContextClosePath(myContext);
	CGContextFillPath(myContext);
	

	float squarelineDash [2] = {6,3};
	float trianglelineDash [2] = {2,3};
	CGContextSetLineDash (myContext, 0.0, trianglelineDash , 2);

	CGContextAddArc (myContext, triangle[1][0][1] , triangle[1][1][1], 5.0, 0.0, 2.0 * M_PI, 0);		
	CGContextClosePath(myContext);
	CGContextStrokePath(myContext);
	
	CGContextMoveToPoint(myContext, 0, -scale);
	CGContextAddLineToPoint(myContext, 0, 0);
	CGContextAddLineToPoint(myContext, scale, 0);
	CGContextClosePath(myContext);
	CGContextStrokePath(myContext);

	CGContextSetLineDash (myContext, 0.0, squarelineDash , 2);

	
	CGContextMoveToPoint(myContext, x[0][i], y[0][i]);
	CGContextAddLineToPoint(myContext, x[1][i], y[1][i]);
	CGContextAddLineToPoint(myContext, x[2][i], y[2][i]);
	CGContextAddLineToPoint(myContext, x[3][i], y[3][i]);
	CGContextClosePath(myContext);
	CGContextStrokePath(myContext);

	
	for (i=1; i<5; i++) {
		
		CGContextAddArc (myContext, x[4][i], y[4][i], 5.0, 0.0, 2.0 * M_PI, 0);		
		CGContextClosePath(myContext);
		CGContextStrokePath(myContext);
		CGContextMoveToPoint(myContext, x[0][i], y[0][i]);
		CGContextAddLineToPoint(myContext, x[1][i], y[1][i]);
		CGContextAddLineToPoint(myContext, x[2][i], y[2][i]);
		CGContextAddLineToPoint(myContext, x[3][i], y[3][i]);
		CGContextClosePath(myContext);
		CGContextStrokePath(myContext);
				
	}

    CGContextRestoreGState (myContext);
	 
		 
}

void applyCoeffsToPoint(CGFloat x, CGFloat y, CGFloat a, CGFloat b, CGFloat c, CGFloat d, CGFloat e, CGFloat f, CGFloat *rx, CGFloat *ry ) {
	
	*rx = (a * x) + (b * y) + c;
	*ry = (d * x) + (e * y) + f;
	
}  

@end
