//
//  ClipboardController.h
//  oxidizer
//
//  Created by David Burnett on 09/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ClipboardController : NSObject {


    IBOutlet NSArrayController *_genomes;
	IBOutlet NSManagedObjectContext *_moc;

	
}

- (IBAction) clearAllGenomes:(id) sender;
- (IBAction) deleteSelectedGenome:(id) sender;

@end
