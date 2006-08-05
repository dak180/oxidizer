#import "ProgressDetails.h"

@implementation ProgressDetails

- init
{
		 
    if (self = [super init]) {
		_thread = [NSNumber numberWithInt:-1];
		[_thread retain];
		
		_progress = [NSNumber numberWithDouble:0.0];
		[_progress retain];
	}
	return self;
}		

- (NSNumber *)thread {

	return _thread;

} 

- (NSNumber *)progress {

	return _progress;
} 

- (void)setThread:(NSNumber *)threadNumber {

	if(threadNumber != nil) {
		[threadNumber retain];
	}
	
	[_thread release];
	_thread = threadNumber;
	
} 
- (void)setProgress:(NSNumber *)progressValue {

	if(progressValue != nil) {
		[progressValue retain];
	}
	
	[_progress release];
	_progress = progressValue;

}

- (void)setObject:(id)anObject forKey:(id)aKey {
	

}
@end
