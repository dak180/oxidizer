/* ProgressDetails */

#import <Cocoa/Cocoa.h>

@interface ProgressDetails : NSObject
{

	NSNumber *_thread;
	NSNumber *_progress;
	NSLevelIndicator *nsl;

}

- (NSNumber *)thread; 
- (NSNumber *)progress; 
- (void)setThread:(NSNumber *)threadNumber; 
- (void)setProgress:(NSNumber *)progressValue; 

- (void)setObject:(id)anObject forKey:(id)aKey;

@end
