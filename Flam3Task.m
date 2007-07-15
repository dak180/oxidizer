//
//  Flam3Task.m
//  oxidizer
//
//  Created by David Burnett on 09/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Flam3Task.h"
#import "NSProgressIndicatorUpdateOnMainThread.h"

@implementation Flam3Task


+ (NSString *)createTemporaryPathWithFileName:(NSString *)fileName {
	
	[fileName retain]; 
	
	NSString *folder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:folder attributes:nil];
	
	NSString *pngFileName = [folder stringByAppendingPathComponent:fileName];
	
	[fileName release]; 
	
	return pngFileName;
} 



+ (void)deleteTemporaryPathAndFile:(NSString *)fileName {
	
	[fileName retain]; 
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager removeFileAtPath:fileName handler:nil];
	[fileManager removeFileAtPath:[fileName stringByDeletingLastPathComponent] handler:nil];
	
	
	[fileName release]; 
	
	return;
} 

+ (NSData *)runFlam3GenomeAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {
	
	
	/* we need an auto release pool for the NSPipes do not get released and we run out of file descriptors */
	
	NSTask *task;
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-genome", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
    NSPipe *stdErrPipe =  [[NSPipe alloc] init];
    [task setStandardError:stdErrPipe];
    NSFileHandle *flam3Error = [stdErrPipe fileHandleForReading];
	
    NSPipe *stdOutPipe =  [[NSPipe alloc] init];
    [task setStandardOutput:stdOutPipe];
    NSFileHandle *flam3Output = [stdOutPipe fileHandleForReading];
	
	
	NSPipe *stdInPipe;
	NSFileHandle *flam3Input;
	
	if(xml != nil) {		
		stdInPipe = [[NSPipe alloc] init];
		[task setStandardInput:stdInPipe];
		flam3Input = [stdInPipe fileHandleForWriting];
	}
	
	[task launch];
	
	if(xml != nil) {		
		[flam3Input writeData:xml];
		[flam3Input closeFile];
	}	
	
	NSData *genomeXML = [flam3Output readDataToEndOfFile];
	NSData *errorData = [flam3Error readDataToEndOfFile];
	
	if ([errorData length] != 0) {
		NSString *string = [[NSString alloc] initWithData: errorData encoding: NSUTF8StringEncoding];
		NSLog(@"got: %@", string);		
	}
	
	[task waitUntilExit];
	
	[flam3Output closeFile];	
	[flam3Error closeFile];	
	if(xml != nil) {		
		[stdInPipe release];
	}
	[stdOutPipe release];
	[stdErrPipe release];
	
	int taskStatus = [task terminationStatus];
	
	[task release];
	
	return genomeXML;
}


+ (int)runFlam3RenderAsQuietTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {
	
	NSTask *task;
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-render", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
    NSPipe *stdOutPipe = [NSPipe pipe];
    [task setStandardError:stdOutPipe];
    NSFileHandle *flam3Output = [stdOutPipe fileHandleForReading];
	
	
    NSPipe *stdInPipe = [NSPipe pipe];
    [task setStandardInput:stdInPipe];
    NSFileHandle *flam3Input = [stdInPipe fileHandleForWriting];
	
	[task launch];
	
	[flam3Input writeData:xml];
	[flam3Input closeFile];
	
	NSData *data = [flam3Output availableData];
	
	
	while([data length] > 0) {
		data = [flam3Output availableData];
	} 
	
	[task waitUntilExit];
	
	return [task terminationStatus];
	
}


+ (int)runFlam3RenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary 
									   usingTaskFrameIndicator:(NSProgressIndicator *)taskFrameIndicator {
	
	NSTask *task;
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-render", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
    NSPipe *stdOutPipe = [NSPipe pipe];
    [task setStandardError:stdOutPipe];
    NSFileHandle *flam3Output = [stdOutPipe fileHandleForReading];
	
	
    NSPipe *stdInPipe = [NSPipe pipe];
    [task setStandardInput:stdInPipe];
    NSFileHandle *flam3Input = [stdInPipe fileHandleForWriting];
	
	[task launch];
	
	[flam3Input writeData:xml];
	[flam3Input closeFile];
	
	
	[taskFrameIndicator setMaxValue:100.0];
	[taskFrameIndicator setDoubleValue:0.0];
	
	NSData *data = [flam3Output availableData];
	
	double progressValue;	
	
	while([data length] > 0) {
		NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		//		NSLog (@"got:%@\n", string);
		
		if([string hasPrefix:@"\rchaos: "]) {
			
			progressValue = [[string substringFromIndex:7] floatValue];

			[taskFrameIndicator setDoubleValueInMainThread:[NSNumber numberWithDouble:progressValue]];
		}
		
		[string release];
		data = [flam3Output availableData];
	} 
	
	[task waitUntilExit];
		
	return [task terminationStatus];
	
}


+ (int)runFlamAnimateAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary 
	usingTaskFrameIndicator:(NSProgressIndicator *)taskFrameIndicator {
	
	NSTask *task;
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-animate", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
    NSPipe *stdOutPipe = [NSPipe pipe];
    [task setStandardError:stdOutPipe];
    NSFileHandle *flam3Output = [stdOutPipe fileHandleForReading];
	
	
    NSPipe *stdInPipe = [NSPipe pipe];
    [task setStandardInput:stdInPipe];
    NSFileHandle *flam3Input = [stdInPipe fileHandleForWriting];
	
	[task launch];
	
	[flam3Input writeData:xml];
	[flam3Input closeFile];
	
	
	[taskFrameIndicator setMaxValue:100.0];
	[taskFrameIndicator setDoubleValue:0.0];
	
	NSData *data = [flam3Output availableData];
	
	double progressValue;	
	
	while([data length] > 0) {
		NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		//		NSLog (@"got:%@\n", string);
		
		if([string hasPrefix:@"\rchaos: "]) {
			
			progressValue = [[string substringFromIndex:7] floatValue];
			
			[taskFrameIndicator setDoubleValueInMainThread:[NSNumber numberWithDouble:progressValue]];
		}
		
		[string release];
		data = [flam3Output availableData];
	} 
	
	[task waitUntilExit];
	
	return [task terminationStatus];
	
}

@end
