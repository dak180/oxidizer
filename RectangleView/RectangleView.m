#import "RectangleView.h"

void applyCoeffsToPoint(CGFloat x, CGFloat y, CGFloat *rx, CGFloat *ry );

@implementation RectangleView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		scale =  80.0;
		_normalLength = sqrt(scale * scale * 2.0);
		_circeRadius = 0.05 * scale;
		_circeRadiusSquared = _circeRadius * _circeRadius;
		_transformMode = MOVE_MODE;
	}
	return self;
}

-(void) awakeFromNib { 

	[[self window] setAcceptsMouseMovedEvents:YES]; 
	
} 

- (void)drawRect:(NSRect)rect {
	
    CGContextRef myContext = [[NSGraphicsContext currentContext]graphicsPort];		
	
	CGContextSaveGState (myContext);
	
	CGContextTranslateCTM (myContext, [self frame].size.width * 0.5, [self frame].size.height * 0.5);
	CGContextScaleCTM(myContext, 1.0, -1.0);  // flip context so 0,0 s top left
	 
    [self drawTrianglesToContext:myContext];

    CGContextRestoreGState (myContext);
	 
		 
}

- (void) applyCoeffsToPointX:(CGFloat)xIn y:(CGFloat)yIn returnX:(CGFloat *)rx y:(CGFloat *)ry {
	
	*rx = (a * xIn) + (b * yIn) + c;
	*ry = (d * xIn) + (e * yIn) + f;
	
}  

- (void) drawTrianglesToContext:(CGContextRef)context {
	
	int i = 0;	

	/* draw transformed triangle */
	CGContextMoveToPoint(context, transformedTriangle[0][0], transformedTriangle[0][1]);
	CGContextAddLineToPoint(context, transformedTriangle[1][0] , transformedTriangle[1][1]);
	CGContextAddLineToPoint(context, transformedTriangle[2][0] , transformedTriangle[2][1]);
	CGContextClosePath(context);
	CGContextStrokePath(context);
	
	/* draw the controller circles */
	
	switch (_transformMode) {
		case MOVE_MODE:
			CGContextAddArc (context, transformedTriangle[1][0] , transformedTriangle[1][1], _circeRadius, 0.0, 2.0 * M_PI, 0);		
			CGContextClosePath(context);
			CGContextFillPath(context);
			break;
		case ROTATE_MODE:
			CGContextAddArc (context, transformedTriangle[1][0] , transformedTriangle[1][1], _circeRadius, 0.0, 2.0 * M_PI, 0);		
			CGContextClosePath(context);
			CGContextStrokePath(context);
			CGContextMoveToPoint(context, transformedTriangle[1][0], transformedTriangle[1][1]);
			CGContextAddLineToPoint(context, transformedTriangle[1][0] + _rotationStartX , transformedTriangle[1][1] - _rotationStartY);
			CGContextClosePath(context);
			CGContextStrokePath(context);
			CGContextAddArc (context, transformedTriangle[1][0] + _rotationStartX , transformedTriangle[1][1] - _rotationStartY, _circeRadius, 0.0, 2.0 * M_PI, 0);		
			CGContextClosePath(context);
			CGContextFillPath(context);
			break;
		case SCALE_MODE:
			CGContextAddArc (context, transformedTriangle[0][0] , transformedTriangle[0][1], _circeRadius, 0.0, 2.0 * M_PI, 0);		
			CGContextClosePath(context);
			CGContextFillPath(context);
			CGContextAddArc (context, transformedTriangle[2][0] , transformedTriangle[2][1], _circeRadius, 0.0, 2.0 * M_PI, 0);		
			CGContextClosePath(context);
			CGContextFillPath(context);
			break;
	}	
	

	
	/* draw the ghost triangle that stays at the origin */	
	CGContextAddArc (context, triangle[1][0] , triangle[1][1], _circeRadius, 0.0, 2.0 * M_PI, 0);		
	CGContextClosePath(context);
	CGContextStrokePath(context);

	float squarelineDash [2] = {6,3};
	float trianglelineDash [2] = {2,3};
	CGContextSetLineDash (context, 0.0, trianglelineDash , 2);
	
	CGContextMoveToPoint(context, 0, -scale);
	CGContextAddLineToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, scale, 0);
	CGContextClosePath(context);
	CGContextStrokePath(context);
	
	
	
	
	
	/* draw the squares */
	
	CGContextSetLineDash (context, 0.0, squarelineDash , 2);
	
	
	CGContextMoveToPoint(context, x[0][i], y[0][i]);
	CGContextAddLineToPoint(context, x[1][i], y[1][i]);
	CGContextAddLineToPoint(context, x[2][i], y[2][i]);
	CGContextAddLineToPoint(context, x[3][i], y[3][i]);
	CGContextClosePath(context);
	CGContextStrokePath(context);
	
	
	for (i=1; i<5; i++) {
		
		CGContextAddArc (context, x[4][i], y[4][i], _circeRadius, 0.0, 2.0 * M_PI, 0);		
		CGContextClosePath(context);
		CGContextStrokePath(context);
		CGContextMoveToPoint(context, x[0][i], y[0][i]);
		CGContextAddLineToPoint(context, x[1][i], y[1][i]);
		CGContextAddLineToPoint(context, x[2][i], y[2][i]);
		CGContextAddLineToPoint(context, x[3][i], y[3][i]);
		CGContextClosePath(context);
		CGContextStrokePath(context);
		
	}
	
	
}

- (void)setCoordinates {
	
	
	triangle [0][0] = 0.0;
	triangle [0][1] = -scale * 0.5;
	triangle [1][0] = 0.0;
	triangle [1][1] = 0.0;
	triangle [2][0] = scale * 0.5;
	triangle [2][1] = 0.0;
	
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
	
	transformedTriangle [0][0] = (a + c) * scale;
	transformedTriangle [0][1] = (d + f) * -scale;
	transformedTriangle [1][0] = c * scale;
	transformedTriangle [1][1] = f * -scale;
	transformedTriangle [2][0] = (b + c) * scale;
	transformedTriangle [2][1] = (e + f) * -scale;
	
	
	
	int i;
	
	for(i=1; i<5; i++) {
		
		[self applyCoeffsToPointX:x[0][i-1] y:y[0][i-1] returnX:&x[0][i] y:&y[0][i]]; 
		[self applyCoeffsToPointX:x[1][i-1] y:y[1][i-1] returnX:&x[1][i] y:&y[1][i]]; 
		[self applyCoeffsToPointX:x[2][i-1] y:y[2][i-1] returnX:&x[2][i] y:&y[2][i]]; 
		[self applyCoeffsToPointX:x[3][i-1] y:y[3][i-1] returnX:&x[3][i] y:&y[3][i]]; 
		[self applyCoeffsToPointX:x[4][i-1] y:y[4][i-1] returnX:&x[4][i] y:&y[4][i]]; 
		
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
	
	
	
}	

- (void) setCoeffsA:(CGFloat )aIn b:(CGFloat )bIn c:(CGFloat )cIn d:(CGFloat )dIn e:(CGFloat )eIn f:(CGFloat )fIn {
	
	a = aIn;
	b = bIn;
	c = cIn;
	d = dIn;
	e = eIn;
	f = fIn;
	
	[self setCoordinates];
	[self display];
	
}

- (void)mouseDown:(NSEvent *)theEvent {
	
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mousePoint.x -= ([self frame].size.width * 0.5);
	mousePoint.y -= ([self frame].size.height * 0.5);

	mousePoint.y *= -1.0;
	
	CGFloat distanceFromPoint;
	
	switch (_transformMode) {
		case MOVE_MODE:
			distanceFromPoint = ((mousePoint.x - transformedTriangle[1][0]) * (mousePoint.x - transformedTriangle[1][0])) +  
			                    ((mousePoint.y - transformedTriangle[1][1]) * (mousePoint.y - transformedTriangle[1][1]));
			if(abs(distanceFromPoint) < _circeRadiusSquared) {
				_isDraggingPoint = YES;
				_draggingPoint = 1;
			}
			break;
		case ROTATE_MODE:
			distanceFromPoint = ((mousePoint.x - (transformedTriangle[1][0] + _rotationStartX)) * (mousePoint.x - (transformedTriangle[1][0] + _rotationStartX))) +  
								((mousePoint.y - (transformedTriangle[1][1] - _rotationStartY)) * (mousePoint.y - (transformedTriangle[1][1] - _rotationStartY)));
			if(abs(distanceFromPoint) < _circeRadiusSquared) {
				_isDraggingPoint = YES;
				_draggingPoint = 3;
			}
			break;
		case SCALE_MODE:
			distanceFromPoint = ((mousePoint.x - transformedTriangle[0][0]) * (mousePoint.x - transformedTriangle[0][0])) +  
								((mousePoint.y - transformedTriangle[0][1]) * (mousePoint.y - transformedTriangle[0][1]));
			if(abs(distanceFromPoint) < _circeRadiusSquared) {
				_isDraggingPoint = YES;
				_draggingPoint = 0;
			} else {
				
				distanceFromPoint = ((mousePoint.x - transformedTriangle[2][0]) * (mousePoint.x - transformedTriangle[2][0])) +  
									((mousePoint.y - transformedTriangle[2][1]) * (mousePoint.y - transformedTriangle[2][1]));
				
				if(abs(distanceFromPoint) < _circeRadiusSquared) {
					_isDraggingPoint = YES;
					_draggingPoint = 2;
				}
			}
			break;
	}
	

}
- (void)mouseUp:(NSEvent *)theEvent {

	[self movePoint:theEvent];
	if(_isDraggingPoint) {
		[_delegate updatePreview:self];
	}
	_isDraggingPoint = NO;

}

- (void)mouseDragged:(NSEvent *)theEvent { 
	
	[self movePoint:theEvent];
	
} 

- (void)movePoint:(NSEvent *)theEvent {
	
	if(_isDraggingPoint) {
		switch(_transformMode) {
				
			case MOVE_MODE:
				if(_isDraggingPoint) {
					
					NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
					
					c = mousePoint.x - ([self frame].size.width * 0.5);
					f = mousePoint.y - ([self frame].size.height * 0.5);
					
					c /= scale;
					f /= scale;
					
					[self setCoordinates];
					[self display];
				}
				break;
			case ROTATE_MODE:
				if(_isDraggingPoint) {
					
					NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
					
					float p0Length, p1Length, rotationLength, rotationX, rotationY, tmpX, tmpY;
					
					tmpX = mousePoint.x - ([self frame].size.width * 0.5) - (c * scale);
					tmpY = mousePoint.y - ([self frame].size.width * 0.5) - (f * scale);
					
					/* normalise mouse point */
					rotationLength = sqrt((tmpX * tmpX) + (tmpY * tmpY));
					
									
					float rotation = -acos(((tmpX * _rotationStartX) + (tmpY * _rotationStartY)) / (rotationLength * _normalLength));
					
					float debug = rotation * 180.0 / M_PI;					
					float cosRotation = cos(rotation);
					float sinRotation = sin(rotation);
					
					CGFloat tmpA  = a;
					
					a = (a * cosRotation) - (d * sinRotation);
					d = (tmpA * sinRotation) + (d * cosRotation);
					
					CGFloat tmpB  = b;
					
					b = (b * cosRotation) - (e * sinRotation);
					e = (tmpB * sinRotation) + (e * cosRotation);
					
					
					rotationX = tmpX * ( _normalLength / rotationLength );
					rotationY = tmpY * ( _normalLength / rotationLength );
				
					_rotationStartX = rotationX;
					_rotationStartY = rotationY;
					
				}
				break;
			case SCALE_MODE:
				if(_isDraggingPoint) {
					
					NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
					
					if(_draggingPoint == 0) {

						a = mousePoint.x - ([self frame].size.width * 0.5);
						d = mousePoint.y - ([self frame].size.height * 0.5);
						
						a /= scale;
						d /= scale;
						
						a -= c;
						d -= f;
						
						
					} else {

						b = mousePoint.x - ([self frame].size.width * 0.5);
						e = mousePoint.y - ([self frame].size.height * 0.5);
						
						b /= scale;
						e /= scale;

						b -= c;
						e -= f;
					}
					
				}
								
		}
		
		
		[self setCoordinates];
		[self display];
		//		NSLog(@"%@", mousePoint);
		
		[_delegate setCoeffsA:a b:b c:c d:d e:e f:f];
		
	}

}

 
- (void) setDelegate:(id) newDelegate {
	
	if(newDelegate != nil) {
		
		[newDelegate retain];
		
	}
	
	[_delegate release];
	_delegate = newDelegate;
	
}


- (void) setTransformMode:(unsigned int) newMode {
	
	_transformMode = newMode;
	if (newMode == ROTATE_MODE) {
		_rotationStartX = scale;
		_rotationStartY = scale;
	}
	[self setCoordinates];
	[self display];
	
}


- (id) delegate {
	return _delegate;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}  
@end
