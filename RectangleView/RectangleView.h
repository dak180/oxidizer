/* RectangleView */

#import <Cocoa/Cocoa.h>

#define MOVE_MODE   0 
#define ROTATE_MODE 1 
#define SCALE_MODE  2 

#include <math.h>

static inline double radians (double degrees) {return degrees * M_PI/180;}


@interface RectangleView : NSView
{
	
	@private
	
	CGFloat a;
	CGFloat b;
	CGFloat c;
	CGFloat d;
	CGFloat e;
	CGFloat f;

	CGFloat x[5][5];
	CGFloat y[5][5];
	
	CGFloat triangle [3][2];
	CGFloat transformedTriangle [3][2];
	
	CGFloat scale;

	CGFloat _circeRadius;
	CGFloat _circeRadiusSquared;
	
	CGFloat _rotationStartX;
	CGFloat _rotationStartY;
	CGFloat _normalLength;
		
	unsigned int _transformMode;
	BOOL _isDraggingPoint;
	id _delegate;
	unsigned int _draggingPoint;
}


- (void) setCoordinates;
- (void) drawTrianglesToContext:(CGContextRef)context;
- (void) drawAxisToContext:(CGContextRef )context;

- (void) applyCoeffsToPointX:(CGFloat)xIn y:(CGFloat)yIn returnX:(CGFloat *)rx y:(CGFloat *)ry;
- (void) setCoeffsA:(CGFloat )aIn b:(CGFloat )bIn c:(CGFloat )cIn d:(CGFloat )dIn e:(CGFloat )eIn f:(CGFloat )fIn;
- (void) setDelegate:(id) newDelegate;
- (void) setTransformMode:(unsigned int) newMode;
- (void) movePoint:(NSEvent *)theEvent;
- (id) delegate;
@end
