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


+ (NSString *)createTemporaryPath {
	
	
	NSString *folder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:folder attributes:nil];
	
	return folder;
} 


+ (NSData *)runFlam3GenomeAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {
		
	NSString *tempPath = [self createTemporaryPath];
	NSString *stdoutFile = [tempPath  stringByAppendingPathComponent:@"stdoutFile"];
	NSString *stderrFile = [tempPath  stringByAppendingPathComponent:@"stderrFile"];
	[stdoutFile retain];
	[stderrFile retain];
    [[NSFileManager defaultManager] createFileAtPath:stdoutFile contents:nil attributes:nil];
    [[NSFileManager defaultManager] createFileAtPath:stderrFile contents:nil attributes:nil];

	
	NSTask *task;
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-genome", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
	NSFileHandle *flam3Error = [NSFileHandle fileHandleForWritingAtPath:stderrFile];
    [task setStandardError:flam3Error];
	
	NSFileHandle *flam3Output = [NSFileHandle fileHandleForWritingAtPath:stdoutFile];
    [task setStandardOutput:flam3Output];
	
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
			
	
	[task waitUntilExit];

	if(xml != nil) {		
		[stdInPipe release];
	}
	
	int taskStatus = [task terminationStatus];
	
	if(taskStatus != 0) {
		
		NSString *string;
		NSData *errorData = [NSData dataWithContentsOfFile:stderrFile];
		
		if ([errorData length] != 0) {
			string = [[NSString alloc] initWithData: errorData encoding: NSUTF8StringEncoding];
			NSLog(@"got: %@", string);		
		} else {
			string = [[NSString alloc] initWithString:@""];
		}

		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Genome failed!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:string];
		NSLog(@"env: %@", environmentDictionary);		
		
		[finishedPanel runModal];	
		
		[string release];
		
	}
	

	
	[task release];
	
	
	NSData *genomeXML = [NSData dataWithContentsOfFile:stdoutFile];

	[Flam3Task deleteTemporaryPathAndFile:stderrFile];
	[Flam3Task deleteTemporaryPathAndFile:stdoutFile];

	[stderrFile release];
	[stdoutFile release];
	
	
	return genomeXML;
}


+ (int)runFlam3RenderAsQuietTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {

	
	[xml writeToFile:[[[NSUserDefaults standardUserDefaults] stringForKey:@"xml_folder"] stringByAppendingPathComponent:[[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d%H%M%S%F.xml"
																																							timeZone:nil
																																							  locale:nil]]
		  atomically:YES];
	
	NSTask *task;
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-render", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
	NSPipe *stdOutPipe = [[NSPipe alloc] init];
    [task setStandardOutput:stdOutPipe];
    NSFileHandle *flam3Output = [stdOutPipe fileHandleForReading];
	
	
    NSPipe *stdInPipe = [[NSPipe alloc] init];
    [task setStandardInput:stdInPipe];
    NSFileHandle *flam3Input = [stdInPipe fileHandleForWriting];

	NSPipe *stdErrPipe = [[NSPipe alloc] init];
    [task setStandardError:stdErrPipe];
    NSFileHandle *flam3Error = [stdErrPipe fileHandleForReading];
	
	[task launch];
	
	[flam3Input writeData:xml];
	[flam3Input closeFile];
		
	[task waitUntilExit];
	
	int taskStatus = [task terminationStatus];
	
	if(taskStatus != 0) {
		
		NSString *string;
		NSData *errorData = [flam3Output readDataToEndOfFile];
		
		if ([errorData length] != 0) {
			string = [[NSString alloc] initWithData: errorData encoding: NSUTF8StringEncoding];
			NSLog(@"got: %@", string);		
		} else {
			string = [[NSString alloc] initWithString:@""];
		}
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Genome failed!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:string];
		[finishedPanel runModal];	
		
		[string release];
		
	}
	
	[flam3Output closeFile];	
	[flam3Error closeFile];	

	[stdInPipe release];
	[stdOutPipe release];
	[stdErrPipe release];

	[task release];
	
	return taskStatus;
	
}


+ (int)runFlam3RenderAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary 
									   usingTaskFrameIndicator:(NSProgressIndicator *)taskFrameIndicator 
									   usingETALabel:(NSTextField *)etaLabel {
	
	
	NSLog(@"env: %@\n", environmentDictionary);

	[xml writeToFile:[[[NSUserDefaults standardUserDefaults] stringForKey:@"xml_folder"] stringByAppendingPathComponent:[[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d%H%M%S%F.xml"
																																							timeZone:nil
																																							  locale:nil]]
	     atomically:YES];
	
	NSTask *task; 
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-render", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
    NSPipe *stdOutPipe = [[NSPipe alloc] init];
    [task setStandardOutput:stdOutPipe];
    NSFileHandle *flam3Output = [stdOutPipe fileHandleForReading];

	NSPipe *stdErrPipe =  [[NSPipe alloc] init];
    [task setStandardError:stdErrPipe];
    NSFileHandle *flam3Error = [stdErrPipe fileHandleForReading];
	
	
    NSPipe *stdInPipe = [[NSPipe alloc] init];
    [task setStandardInput:stdInPipe];
    NSFileHandle *flam3Input = [stdInPipe fileHandleForWriting];
	
	[task launch];
	
	[flam3Input writeData:xml];
	[flam3Input closeFile];
	
	
	[taskFrameIndicator setMaxValue:100.0];
	[taskFrameIndicator setDoubleValue:0.0];
	
	NSData *data = [flam3Error availableData];
	NSMutableString *errorMessage = [NSMutableString stringWithCapacity:1000];
	
	
	double progressValue;	
	
	while([data length] > 0) {
		NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		
//		NSLog(@"%@", string);
		
		if([string hasPrefix:@"\rchaos: "]) {
			
			progressValue = [[string substringFromIndex:7] floatValue];

			[taskFrameIndicator setDoubleValueInMainThread:[NSNumber numberWithDouble:progressValue]];
		} else if([string hasPrefix:@"  ETA: "]) {
			
			[etaLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:[string substringFromIndex:6] waitUntilDone:NO];

		}
													
		
		if([errorMessage length] > 256) {
			[errorMessage setString:string];
			
		} else {
			[errorMessage appendString:string];
		}

		[string release];
		data = [flam3Error availableData];
	} 
	
	[task waitUntilExit];
		
	int taskStatus = [task terminationStatus];
	
	if(taskStatus != 0) {
		
		NSLog(@"flam3 Error message: %@", errorMessage);		

		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render failed!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:errorMessage];
		[finishedPanel runModal];	
				
	}
	
	[flam3Output closeFile];	
	[flam3Error closeFile];	
		
		
	[stdInPipe release];
	[stdOutPipe release];
	[stdErrPipe release];

	[task release];
	
	return taskStatus;	
}


+ (int)runFlamAnimateAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary 
	                                      usingTaskFrameIndicator:(NSProgressIndicator *)taskFrameIndicator
			                              usingETALabel:(NSTextField *)etaLabel {
	
	NSTask *task;
    task = [[NSTask alloc] init];
	
    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-animate", [[ NSBundle mainBundle ] resourcePath ]]];
	[task setEnvironment:environmentDictionary]; 
	
    NSPipe *stdOutPipe = [[NSPipe alloc] init];
    [task setStandardOutput:stdOutPipe];
    NSFileHandle *flam3Output = [stdOutPipe fileHandleForReading];

	NSPipe *stdErrPipe =  [[NSPipe alloc] init];
    [task setStandardError:stdErrPipe];
    NSFileHandle *flam3Error = [stdErrPipe fileHandleForReading];	
	
    NSPipe *stdInPipe = [[NSPipe  alloc] init];
    [task setStandardInput:stdInPipe];
    NSFileHandle *flam3Input = [stdInPipe fileHandleForWriting];
	
	[task launch];
	
	[flam3Input writeData:xml];
	[flam3Input closeFile];
	
	
	[taskFrameIndicator setMaxValue:100.0];
	[taskFrameIndicator setDoubleValue:0.0];
		
	NSData *data = [flam3Error availableData];
	
	double progressValue;	
	
	NSMutableString *errorMessage = [NSMutableString stringWithCapacity:1000];

	while([data length] > 0) {
		NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		//		NSLog (@"got:%@\n", string);
		
		if([string hasPrefix:@"\rchaos: "]) {
			
			progressValue = [[string substringFromIndex:7] floatValue];
			
			[taskFrameIndicator setDoubleValueInMainThread:[NSNumber numberWithDouble:progressValue]];
			
		} else if([string hasPrefix:@"  ETA: "]) {
			
			[etaLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:[string substringFromIndex:6] waitUntilDone:NO];
			
		}
		
		[errorMessage appendString:string];
		[string release];
		data = [flam3Error availableData];
	} 
	
	[task waitUntilExit];
	
	int taskStatus = [task terminationStatus];
	
	if(taskStatus != 0) {
		
		
		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render failed!" 
												 defaultButton:@"Close"
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:errorMessage];
		[finishedPanel runModal];	
		
	}
	
	[flam3Output closeFile];	
	[flam3Error closeFile];	
	
	[stdInPipe release];
	[stdOutPipe release];
	[stdErrPipe release];

	[task release];
	
	return taskStatus;		
}

@end
