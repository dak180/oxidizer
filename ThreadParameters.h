/* ThreadParameters */

#import <Cocoa/Cocoa.h>
#import "flam3.h"
#import <semaphore.h>

@interface ThreadParameters : NSObject
{

	int releaseCondition;
	int lockCondition;
	NSConditionLock *condition;
	NSConditionLock *endLock;
	flam3_frame *frames;
	double firstFrame;
	NSImage *image;
	NSBitmapImageRep *imageRep;


}

- (void)setReleaseCondition:(int)condition;
- (int)getReleaseCondition;
- (void)setLockCondition:(int)condition;
- (int)getLockCondition;
- (void)setConditionLock:(NSConditionLock *)newCondition;
- (NSConditionLock *)getConditionLock;

- (void)setEndLock:(NSConditionLock *)condition;
- (NSConditionLock *)getEndLock;


- (void)setFrames:(flam3_frame *)newFrame;
- (flam3_frame *)getFrames;
- (void)setFirstFrame:(double)first;					
- (double)getFirstFrame;

- (NSImage *)getImage;
- (NSBitmapImageRep *)getImageRep;
- (void)setImage:(NSImage *)newImage;
- (void)setImageRep:(NSBitmapImageRep *)newImageRep;



@end
