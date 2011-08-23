//
//  Flam3Task.m
//  oxidizer
//
//  Created by David Burnett on 09/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Flam3Task.h"

@implementation Flam3Task


+ (NSString *)createTemporaryPathWithFileName:(NSString *)fileName {

	@synchronized(self) {
		
	[fileName retain];


	NSString *folder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	//	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSFileManager *fileManager = [[NSFileManager alloc] init];

	[fileManager createDirectoryAtPath:folder attributes:nil];

	NSString *pngFileName = [folder stringByAppendingPathComponent:fileName];
	
	
	[fileName release];

	[fileManager release];
	
	return pngFileName;
	}

}



+ (void)deleteTemporaryPathAndFile:(NSString *)fileName {


	[fileName retain];

	//	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSFileManager *fileManager = [[NSFileManager alloc] init];

	[fileManager removeFileAtPath:fileName handler:nil];
	[fileManager removeFileAtPath:[fileName stringByDeletingLastPathComponent] handler:nil];


	[fileName release];
	[fileManager release];

	return;
}


+ (NSString *)createTemporaryPath {

@synchronized(self) {
	
	
	NSString *folder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];

//	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSFileManager *fileManager = [[NSFileManager alloc] init];

	[fileManager createDirectoryAtPath:folder attributes:nil];
	[fileManager release];


	return folder;
}

}


+ (NSData *)runFlam3GenomeAsTask:(NSData *)xml withEnvironment:(NSMutableDictionary *)environmentDictionary {

	bool openOutOkay;
	
	[environmentDictionary setValue:[NSNumber numberWithInt:1] forKey:@"flam27"];

	NSLog(@"%@", environmentDictionary);
	
//	NSString *stdoutFile = [[self createTemporaryPath]  stringByAppendingPathComponent:@"stdoutFile"];
//	NSString *stderrFile = [[self createTemporaryPath]  stringByAppendingPathComponent:@"stderrFile"];
	NSString *stdoutFile = [Flam3Task createTemporaryPathWithFileName:@"stdoutFile"];
	NSString *stderrFile = [Flam3Task createTemporaryPathWithFileName:@"stderrFile"];
	[stdoutFile retain];
	[stderrFile retain];
	
	NSFileManager *fileManager = [[NSFileManager alloc] init];

	[fileManager createFileAtPath:stdoutFile contents:nil attributes:nil];
	[fileManager createFileAtPath:stderrFile contents:nil attributes:nil];
	
//	NSLog(@"%@", stdoutFile);
//	NSLog(@"%@", stderrFile);
	
	
	NSTask *task;
    task = [[NSTask alloc] init];

    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-genome", [[[ NSBundle mainBundle ] executablePath ] stringByDeletingLastPathComponent]]];
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

	NSString *string;
	NSData *errorData = [NSData dataWithContentsOfFile:stderrFile];

	if(taskStatus != 0)
//		|| [errorData length] > 0)
	{


		if ([errorData length] != 0) {
			string = [[NSString alloc] initWithData: errorData encoding: NSUTF8StringEncoding];
			NSLog(@"flam3-genome failed, got: %ld %@", taskStatus, string);
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

	if(genomeXML == nil) {
		NSLog(@"genomeXML nil");
	}

	[Flam3Task deleteTemporaryPathAndFile:stderrFile];
	[Flam3Task deleteTemporaryPathAndFile:stdoutFile];

	[stderrFile release];
	[stdoutFile release];

	[fileManager release];

	return genomeXML;
}


+ (int)runFlam3RenderAsQuietTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if([defaults boolForKey:@"auto_save_on_render"]) {
		NSLog(@"env: %@\n", environmentDictionary);

		[xml writeToFile:[[defaults stringForKey:@"xml_folder"] stringByAppendingPathComponent:[[NSDate date]
																 descriptionWithCalendarFormat:@"%Y%m%d%H%M%S%F.xml"
																					  timeZone:nil
																					    locale:nil]]
			  atomically:YES];
	}


	NSTask *task;
    task = [[NSTask alloc] init];

    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-render",[[[ NSBundle mainBundle ] executablePath ] stringByDeletingLastPathComponent]]];
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
		NSData *errorData = [flam3Error readDataToEndOfFile];

		if ([errorData length] != 0) {
			string = [[NSString alloc] initWithData: errorData encoding: NSUTF8StringEncoding];
			NSLog(@"got: %@", string);
		} else {
			string = [[NSString alloc] initWithString:@""];
		}

		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Genome render failed!"
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
									   usingTaskFrameIndicator:(ProgressIndicatorWithCancel *)taskFrameIndicator
									   usingETALabel:(NSTextField *)etaLabel {


	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if([defaults boolForKey:@"auto_save_on_render"]) {
		NSLog(@"env: %@\n", environmentDictionary);

		[xml writeToFile:[[defaults stringForKey:@"xml_folder"] stringByAppendingPathComponent:[[NSDate date]
																 descriptionWithCalendarFormat:@"%Y%m%d%H%M%S%F.xml"
																					  timeZone:nil
																						locale:nil]]
	     atomically:YES];
	}

	NSTask *task;
    task = [[NSTask alloc] init];

    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-render",[[[ NSBundle mainBundle ] executablePath ] stringByDeletingLastPathComponent]]];
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

	double progressFactor = 1.0;

	double progressValue = 0.0;

	[taskFrameIndicator setDoubleValueInMainThread:[NSNumber numberWithDouble:progressValue]];
	[etaLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:@"" waitUntilDone:NO];

	double currentStrip = 1.0;
	double stripCount = 1.0;

    double stripProgress = 0.0;
    double totalPercent = 0.0;

	time_t start = time(NULL);
	time_t now;

	while([data length] > 0) {
		NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

//		NSLog(@"%@", string);

		if([string hasPrefix:@"\rchaos: "]) {

			stripProgress = [[string substringFromIndex:7] floatValue];
			progressValue = (stripProgress + totalPercent) * progressFactor;

			now = time(NULL);

			double eta = (now - start)  / progressValue;
			eta *= (100.0 - progressValue);

			if(eta > 60 && progressValue > 0.0 ) {
				[etaLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:[NSString stringWithFormat:@"%.1f minutes", eta/60.0] waitUntilDone:NO];
			} else if(progressValue > 0) {
				[etaLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:[NSString stringWithFormat:@"%.0f seconds", eta] waitUntilDone:NO];
			}

			[taskFrameIndicator setDoubleValueInMainThread:[NSNumber numberWithDouble:progressValue]];


		} else if([string hasPrefix:@"strip = "]) {

			NSArray *stripDetails = [[string substringFromIndex:8] componentsSeparatedByString:@"/"];

			currentStrip = [[stripDetails objectAtIndex:0] doubleValue];
			stripCount = [[stripDetails objectAtIndex:1] doubleValue];
			progressFactor = 1.0 / stripCount;

			totalPercent = (currentStrip - 1) * 100.0;

		} else if([string hasPrefix:@"\rdensity"]){
			[etaLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:[string substringFromIndex:1] waitUntilDone:NO];
		}

		if([taskFrameIndicator shouldCancel]) {

			[task terminate];
			[string release];
			break;

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

	if(taskStatus != 0 && [taskFrameIndicator shouldCancel] == NO) {

		NSLog(@"flam3 Error message: %@", errorMessage);


		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render failed!"
												 defaultButton:@"Close"
											   alternateButton:nil
												   otherButton:nil
									 informativeTextWithFormat:errorMessage];
		[finishedPanel runModal];

	}

	[taskFrameIndicator setCancel:NO];


	[flam3Output closeFile];
	[flam3Error closeFile];


	[stdInPipe release];
	[stdOutPipe release];
	[stdErrPipe release];

	[task release];

	return taskStatus;
}


+ (int)runFlamAnimateAsTask:(NSData *)xml withEnvironment:(NSDictionary *)environmentDictionary
	                                      usingTaskFrameIndicator:(ProgressIndicatorWithCancel *)taskFrameIndicator
			                              usingETALabel:(NSTextField *)etaLabel {

	/*
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if([defaults boolForKey:@"auto_save_on_render"]) {
		NSLog(@"env: %@\n", environmentDictionary);

		[xml writeToFile:[[defaults stringForKey:@"xml_folder"] stringByAppendingPathComponent:[[NSDate date]
																								descriptionWithCalendarFormat:@"%Y%m%d%H%M%S%F.xml"
																								timeZone:nil
																								locale:nil]]
			  atomically:YES];
	}
	*/

	NSTask *task;
    task = [[NSTask alloc] init];

    [task setLaunchPath: [NSString stringWithFormat:@"%@/flam3-animate",[[[ NSBundle mainBundle ] executablePath ] stringByDeletingLastPathComponent]]];
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

		if([taskFrameIndicator shouldCancel]) {
			[string release];
			[task terminate];
			break;

		}

		[errorMessage appendString:string];
		[string release];
		data = [flam3Error availableData];
	}

	[task waitUntilExit];

	int taskStatus = [task terminationStatus];

	if(taskStatus != 0 && [taskFrameIndicator shouldCancel] == NO) {


		NSAlert *finishedPanel = [NSAlert alertWithMessageText:@"Render failed!"
												 defaultButton:@"Close"
											   alternateButton:nil
												   otherButton:nil
									 informativeTextWithFormat:errorMessage];
		[finishedPanel runModal];

		taskStatus = 99;

	}

	[taskFrameIndicator setCancel:NO];

	[flam3Output closeFile];
	[flam3Error closeFile];

	[stdInPipe release];
	[stdOutPipe release];
	[stdErrPipe release];

	[task release];

	return taskStatus;
}

@end
