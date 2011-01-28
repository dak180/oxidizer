//
//  SaveDialogProtocol.h
//  oxidizer
//
//  Created by David Burnett on 11/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol SaveDialogProtocol

- (BOOL) showQuickTimeFileMovieDialogue;
- (NSDictionary *)getExportDictionary;
- (void) closeServer;
- (id) retain;

@end
