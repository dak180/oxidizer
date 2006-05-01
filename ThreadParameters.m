#import "ThreadParameters.h"

@implementation ThreadParameters


- (void)setReleaseCondition:(int)newCondition {
	releaseCondition = newCondition;
}
- (int)getReleaseCondition {
	return releaseCondition;
}
- (void)setLockCondition:(int)newCondition {
	lockCondition = newCondition;
}
- (int)getLockCondition {
	return lockCondition;
}


- (void)setConditionLock:(NSConditionLock *)newCondition {

	if(newCondition != nil) {
		[newCondition retain];
	}
	[condition release];
	condition = newCondition; 
}

- (NSConditionLock *)getConditionLock {
	return condition;
}

- (void)setFrames:(flam3_frame *)newFrames {
	frames = newFrames;
}
					
- (flam3_frame *)getFrames {
	return frames;
}


- (void)setFirstFrame:(double)first {
	firstFrame = first;
}
					
- (double)getFirstFrame {
	return firstFrame;
}


- (NSImage *)getImage {
	return image;
}

- (NSBitmapImageRep *)getImageRep {
	return imageRep;
}

- (void)setImageRep:(NSBitmapImageRep *)newImageRep {
	
	if(newImageRep != nil) {
		[newImageRep retain];
	}
	[imageRep release];

	imageRep = newImageRep;	
}

- (void)setImage:(NSImage *)newImage {

	if(newImage != nil) {
		[newImage retain];
	}
	[image release];

	image = newImage;	
}

- (void)setEndLock:(NSConditionLock *)newEndLock {

	if(newEndLock != nil) {
		[newEndLock retain];
	}
	[endLock release];
	endLock = newEndLock; 
	
}
- (NSConditionLock *)getEndLock {
	return endLock;
}


- (void)dealloc 
{
	[self setConditionLock:nil];
	[super dealloc];
}

@end
