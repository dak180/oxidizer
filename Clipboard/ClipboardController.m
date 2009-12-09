//
//  ClipboardController.m
//  oxidizer
//
//  Created by David Burnett on 09/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ClipboardController.h"


@implementation ClipboardController

- init {
	
    if (self = [super init]) {

		// create persistant store and init with models main bundle 
		_moc = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]]; 
		
		[_moc setPersistentStoreCoordinator: coordinator];
		
		NSError *error;
		
		NSString *appFolder = [[NSUserDefaults standardUserDefaults] stringForKey:@"xml_folder"];
		
		NSString *psPath = [appFolder stringByAppendingPathComponent: @"OxidizerClipboard.sqliteO2"];
		
		//	NSFileManager *fileManager = [NSFileManager defaultManager];
		//	[fileManager removeFileAtPath:psPath handler:nil];
		
		NSURL *url = [NSURL fileURLWithPath:psPath];
		
		id newStore = [coordinator addPersistentStoreWithType: NSSQLiteStoreType
												configuration: nil
														  URL: url
													  options: nil	
														error: &error];        		
		
		
		
		if (newStore == nil) {
			NSLog(@"Store Configuration Failure\n%@",
				  ([error localizedDescription] != nil) ?
				  [error localizedDescription] : @"Unknown Error");
		}
		
    }
	
    return self;
}


- (void)windowWillClose:(NSNotification *)aNotification {

	[_moc processPendingChanges];
	[_moc save:NULL];
}

- (void) createManagedContext {
	

	
}


@end
