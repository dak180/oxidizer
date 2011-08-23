//
//  Flam3Task.h
//  oxidizer
//
//  Created by David Burnett on 09/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressIndicatorWithCancel.h"


@interface Flam3Task : NSObject {

}

+ (NSString *)createTemporaryPathWithFileName:(NSString *)fileName;
+ (void)deleteTemporaryPathAndFile:(NSString *)fileName;
+ (NSData *)runFlam3GenomeAsTask:(NSData *)xml withEnvironment:(NSMutableDictionary *)environmentDictionary;
+ (int)runFlam3RenderAsQuietTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary;
+ (int)runFlam3RenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary
								  usingTaskFrameIndicator:(ProgressIndicatorWithCancel *)taskFrameIndicator
											usingETALabel:(NSTextField *)etaLabel;
+ (int)runFlamAnimateAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary
								  usingTaskFrameIndicator:(ProgressIndicatorWithCancel *)taskFrameIndicator
											usingETALabel:(NSTextField *)etaTextField;

@end
