/*
    oxidizer - cosmic recursive fractal flames
    Copyright (C) 2006  David Burnett <vargol@ntlworld.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import "BreedingController.h"
#import "Genome.h"
#import "Flam3Task.h"

@implementation BreedingController

+ (NSManagedObjectContext *) createManagedContext {

		NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
		
		// create persistant store and init with models main bundle 
		
		NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]]; 
		
		[moc setPersistentStoreCoordinator: coordinator];
		[coordinator release];
		
		NSString *STORE_TYPE = NSInMemoryStoreType;
		
		NSError *error;
		id newStore = [coordinator addPersistentStoreWithType:STORE_TYPE
												configuration:nil
														  URL:nil
													  options:nil
														error:&error];
		
		if (newStore == nil) {
			NSLog(@"Store Configuration Failure\n%@",
				  ([error localizedDescription] != nil) ?
				  [error localizedDescription] : @"Unknown Error");
		}

		[moc autorelease];

		return moc;
}

- init {
	 
    if (self = [super init]) {
		
		moc1      = [BreedingController createManagedContext];
		moc2      = [BreedingController createManagedContext];
		mocResult = [BreedingController createManagedContext];
		docController = [NSDocumentController sharedDocumentController];		
    }
	
    return self;
}


- (BOOL)openFile:(NSManagedObjectContext *) moc {

	NSOpenPanel *op;
	int runResult;

	/* create or get the shared instance of NSSavePanel */
	op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"flam3"];
	
	/* display the NSOpenPanel */
	runResult = [op runModal];
	/* if successful, save file under designated name */
	if(runResult == NSOKButton && [op filename] != nil) {
		[self deleteOldGenomesInContext:moc];
		[docController noteNewRecentDocumentURL:[NSURL URLWithString:[op filename]]];
//		NSArray *newGenomes = [Genome createGenomeEntitiesFromXML:[NSData dataWithContentsOfFile:[op filename]] inContext:moc]; 
		NSArray *newGenomes = [Genome createGenomeEntitiesFromXML:[NSData dataWithContentsOfFile:[op filename]] inContext:moc]; 
		[moc processPendingChanges];			
		[BreedingController makeImageForGenomes:newGenomes];
		[moc save:nil];
		
		return YES;
	} 
	
	return NO;
}


- (void) deleteOldGenomesInContext:(NSManagedObjectContext *)moc {

	NSArray *genomes;
	int i;
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Genome" inManagedObjectContext:moc]];
	
	genomes = [moc executeFetchRequest:fetch error:nil];
	[fetch release];	  
	
	if(genomes != nil) {
	
			for(i=0; i<[genomes count]; i++) {
			
				[moc deleteObject:[genomes objectAtIndex:i]];
			
			}			
			[moc save:nil];	
	}

}

- (BOOL) canBreed {
	if([[genome1 selectedObjects] count] != 0 && [[genome1 selectedObjects] count] != 0) {
		return TRUE;
	} else {
		return FALSE;
	}
}

- (BOOL) canMutate {
	if([[genome1 selectedObjects] count] != 0 || [[genome1 selectedObjects] count] != 0){
		return TRUE;
	} else {
		return FALSE;
	}
}


- (IBAction)loadNewGenomeIntoMoc1:(id)sender {

	 NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	 switch([segments selectedSegment]) {
		case 0:
			[self openFile:moc1];
			break;
		case 1:
			[flameModel createRandomGenomeInContext:moc1];
			break;
		case 2:
			[genome1 remove:self];
			break;
	}
}

- (IBAction)loadNewGenomeIntoMoc2:(id)sender {
	 NSSegmentedControl *segments = (NSSegmentedControl *)sender;
	 switch([segments selectedSegment]) {
		case 0:
			[self openFile:moc2];
			break;
		case 1:
			[flameModel createRandomGenomeInContext:moc2];
			break;
		case 2:
			[genome2 remove:self];
			break;
	}
}

- (IBAction)showBreedingWindow:(id)sender {
	[breedingWindow makeKeyAndOrderFront:self];
}

- (IBAction)alternate:(id)sender {

	NSData *newGenomeXML;
	NSArray *newGenome;
	
	if([genome1 selectionIndex] == NSNotFound || [genome2 selectionIndex] == NSNotFound) {
		NSBeep();
		return;
	}
	
	newGenomeXML =[BreedingController alternateGenome:[Genome createXMLFromEntities:[genome1 selectedObjects] fromContext:moc1 forThumbnail:YES] 
										   withGenome:[Genome createXMLFromEntities:[genome2 selectedObjects] fromContext:moc2 forThumbnail:YES]];
	[newGenomeXML retain];

	[self deleteOldGenomesInContext:mocResult];
	newGenome = [Genome createGenomeEntitiesFromXML:newGenomeXML inContext:mocResult];
	[mocResult processPendingChanges];
	[BreedingController makeImageForGenomes:newGenome];
	[mocResult processPendingChanges];
	[mocResult save:nil];
	
	[newGenomeXML release];
	
}


- (IBAction)interpolate:(id)sender {
	
	NSData *newGenomeXML;
	NSArray *newGenome;
	
	if([genome1 selectionIndex] == NSNotFound || [genome2 selectionIndex] == NSNotFound) {
		NSBeep();
		return;
	}
	
	newGenomeXML =[BreedingController interpolateGenome:[Genome createXMLFromEntities:[genome1 selectedObjects] fromContext:moc1 forThumbnail:YES] 
										   withGenome:[Genome createXMLFromEntities:[genome2 selectedObjects] fromContext:moc2 forThumbnail:YES]];
	[newGenomeXML retain];
	
	[self deleteOldGenomesInContext:mocResult];
	newGenome = [Genome createGenomeEntitiesFromXML:newGenomeXML inContext:mocResult];
	
	[newGenomeXML release];
	
	[mocResult processPendingChanges];
	[BreedingController makeImageForGenomes:newGenome];
	[mocResult processPendingChanges];
	[mocResult save:nil];
	
	
	
	
}

- (IBAction)doUnion:(id)sender {
	
	NSData *newGenomeXML;
	NSArray *newGenome;
	
	if([genome1 selectionIndex] == NSNotFound || [genome2 selectionIndex] == NSNotFound) {
		NSBeep();
		return;
	}
	
	newGenomeXML =[BreedingController unionGenome:[Genome createXMLFromEntities:[genome1 selectedObjects] fromContext:moc1 forThumbnail:YES] 
										   withGenome:[Genome createXMLFromEntities:[genome2 selectedObjects] fromContext:moc2 forThumbnail:YES]];
	[newGenomeXML retain];
	
	[self deleteOldGenomesInContext:mocResult];
	newGenome = [Genome createGenomeEntitiesFromXML:newGenomeXML inContext:mocResult];
	[mocResult processPendingChanges];
	[BreedingController makeImageForGenomes:newGenome];
	[mocResult processPendingChanges];
	[mocResult save:nil];

	[newGenomeXML release];
	
	
}


- (IBAction)mutate:(id)sender {

	NSData *newGenomeXML;
	NSArray *newGenome;
	
		
	if([genome1 selectionIndex] == NSNotFound && [genome2 selectionIndex] == NSNotFound) {
		NSBeep();
		return;
	}
		
	newGenomeXML =[BreedingController mutateGenome:[Genome createXMLFromEntities:[genome1 selectedObjects] fromContext:moc1 forThumbnail:YES]];
	[newGenomeXML retain];
	
	[self deleteOldGenomesInContext:mocResult];
	newGenome = [Genome createGenomeEntitiesFromXML:newGenomeXML inContext:mocResult];
	[mocResult processPendingChanges];
	[BreedingController makeImageForGenomes:newGenome];
	[mocResult processPendingChanges];
	[mocResult save:nil];
	
	[newGenomeXML release];


}

- (IBAction)clone:(id)sender {
}

- (IBAction)sendResultToEditor:(id)sender {


	NSArray *newGenome = [Genome createGenomeEntitiesFromXML:[Genome createXMLFromEntities:[genomeResult arrangedObjects] fromContext:mocResult forThumbnail:YES] 
								  inContext:[flameModel getNSManagedObjectContext]];

	[[flameModel getNSManagedObjectContext] processPendingChanges];
	[BreedingController makeImageForGenomes:newGenome];
	[[flameModel getNSManagedObjectContext] processPendingChanges];
	

}

+ (NSData *)createRandomGenomeXMLwithEnvironment:(NSMutableDictionary *)environmentDictionary {
	
	/* generate random XML */
	
//	srandom(time(NULL));
	
	[environmentDictionary setValue:[NSNumber numberWithLong:random()] forKey:@"seed"];
	[environmentDictionary setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				

	
	/* fiddle symmetry to be a value between -8 and -1 and 1 and 8 */
	int symmetry;
	
	if (random() & 3) {
		symmetry = 1;
	} else {
		symmetry = random() & 7;
		symmetry++;
		if (random() & 2) {
			symmetry *= -1;
		}
		
	}
	
	NSData *templateData = [[NSData alloc] initWithBytes:"<flame quality=\"50\"/>" length:21];
	NSString *template = [Flam3Task createTemporaryPathWithFileName:@"template"];

	[templateData writeToFile:template atomically:YES];

	[environmentDictionary setObject:template forKey:@"template"];
	
	[environmentDictionary setValue:[NSNumber numberWithInt:symmetry] forKey:@"symmetry"];
	
	NSData *newGenome = [Flam3Task runFlam3GenomeAsTask:nil withEnvironment:environmentDictionary];
	
	if (newGenome == nil) {
		NSLog(@"runFlam3GenomeAsTask returned nil");
	}
	
	[newGenome retain];

	[templateData release];
	
	[newGenome autorelease];
	
	return newGenome;
	
}

+ (NSData *)alternateGenome:(NSData *)selp0 withGenome:(NSData *)selp1 {

	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
	[env setObject:@"alternate" forKey:@"method"];
	
	/*
	 env cross0=A.flame cross1=B.flame method=alternate repeat=20	
	 */
	
	NSData *newGenome = [BreedingController Flam3Cross:selp0 With:selp1 usingEnvironment:env];
	[newGenome retain];
	
	[env release];
	
	[newGenome autorelease];
	
	return newGenome;
}

+ (NSData *)interpolateGenome:(NSData *)selp0 withGenome:(NSData *)selp1 {
	
	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
	[env setObject:@"interpolate" forKey:@"method"];
	
	/*
	 env cross0=A.flame cross1=B.flame method=alternate repeat=20	
	 */
	
	NSData *newGenome = [BreedingController Flam3Cross:selp0 With:selp1 usingEnvironment:env];
	[newGenome retain];
	
	[env release];
	
	[newGenome autorelease];
	
	return newGenome;
}

+ (NSData *)unionGenome:(NSData *)selp0 withGenome:(NSData *)selp1 {
	
	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  
	[env setObject:@"union" forKey:@"method"];
	
	
	NSData *newGenome = [BreedingController Flam3Cross:selp0 With:selp1 usingEnvironment:env];
	[newGenome retain];
	
	[env release];
	
	[newGenome autorelease];
	
	return newGenome;
}



+ (NSData *)Flam3Cross:(NSData *)selp0 With:(NSData *)selp1 usingEnvironment:(NSMutableDictionary *)env {
	
	NSString *file0, *file1;
	
	file0 = [Flam3Task createTemporaryPathWithFileName:@"selp0"];
	file1 = [Flam3Task createTemporaryPathWithFileName:@"selp1"];
	
	[file0 retain];
	[file1 retain];
	
	[selp0 writeToFile:file0 atomically:YES];
	[selp1 writeToFile:file1 atomically:YES];
	
	[env setObject:file0 forKey:@"cross0"];
	[env setObject:file1 forKey:@"cross1"];

	srandom(time(NULL));
	
	[env setObject:[NSNumber numberWithInt:33] forKey:@"bits"];
	[env setObject:[NSNumber numberWithInt:3] forKey:@"print_edit_depth"];
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
	[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[env setObject:[defaults stringForKey:@"nick"] forKey:@"nick"];	
	[env setObject:[defaults stringForKey:@"url"] forKey:@"url"];	

	/* fiddle symmetry to be a value between -8 and -1 and 1 and 8 */
	int symmetry;
	
	if (random() & 3) {
		symmetry = 1;
	} else {
		symmetry = random() & 7;
		symmetry++;
		if (random() & 2) {
			symmetry *= -1;
		}
		
	}	

	[env setValue:[NSNumber numberWithInt:symmetry] forKey:@"symmetry"];
	
	NSData *newGenome = [Flam3Task runFlam3GenomeAsTask:nil withEnvironment:env];
	 
	if(newGenome == nil || [newGenome length] == 0) {
		NSLog(@"%@", [NSString stringWithContentsOfFile:file0]);
		NSLog(@"%@", [NSString stringWithContentsOfFile:file1]);
	}

	[newGenome retain];
	 
	 [Flam3Task deleteTemporaryPathAndFile:file0];
	 [Flam3Task deleteTemporaryPathAndFile:file1];
	 
	 [file0 release];
	 [file1 release];

	 [newGenome autorelease];
	 
	 return newGenome;
	
}


+ (NSData *)mutateGenome:(NSData *)selp0 {

	[selp0 retain];
	
	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];  

	NSString *file0;
	
	file0 = [Flam3Task createTemporaryPathWithFileName:@"selp0"];
	
	[file0 retain];
	
	[selp0 writeToFile:file0 atomically:YES];
	
	[env setObject:file0 forKey:@"mutate"];
	
	srandom(time(NULL));
	
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];
	[env setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
	[env setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[env setObject:[defaults stringForKey:@"nick"] forKey:@"nick"];	
	[env setObject:[defaults stringForKey:@"url"] forKey:@"url"];	
	
	/* fiddle symmetry to be a value between -8 and -1 and 1 and 8 */
	int symmetry;
	
	if (random() & 3) {
		symmetry = 1;
	} else {
		symmetry = random() & 7;
		symmetry++;
		if (random() & 2) {
			symmetry *= -1;
		}
		
	}	
	[env setValue:[NSNumber numberWithInt:symmetry] forKey:@"symmetry"];
	
	NSData *newGenome = [Flam3Task runFlam3GenomeAsTask:nil withEnvironment:env];
	
	[newGenome retain];
	
//	NSLog(@"mutate: %@", [[NSString alloc] initWithData:newGenome encoding:NSUTF8StringEncoding] );
	
	[Flam3Task deleteTemporaryPathAndFile:file0];
	
	[file0 release];
	
	[env release];
	
	[newGenome autorelease];
	
	return newGenome;	
	
}


+ (void) makeImageForGenomes:(NSArray *)genomes {
	

	NSString *previewFolder = [NSString pathWithComponents:[NSArray arrayWithObjects:
		NSTemporaryDirectory(),
		[[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] lastPathComponent],
		nil]];
	
	NSLog(@"%@", previewFolder);	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager createDirectoryAtPath:previewFolder attributes:nil];
	
	srandom(time(NULL));
	
	NSMutableDictionary *taskEnvironment = [[NSMutableDictionary alloc] init];  
	
	[taskEnvironment setObject:[NSNumber numberWithLong:random()] forKey:@"seed"];
	[taskEnvironment setObject:[NSNumber numberWithLong:random()] forKey:@"isaac_seed"];				
	[taskEnvironment setObject:[NSString stringWithFormat:@"%@/flam3-palettes.xml", [[ NSBundle mainBundle ] resourcePath ]] forKey:@"flam3_palettes"];
	
	
	NSString *pngFileName = [NSString pathWithComponents:[NSArray arrayWithObjects:previewFolder, @"bc.png", nil]];
	[taskEnvironment setObject:pngFileName forKey:@"out"];
	
	NSManagedObjectContext *thisMoc = [[genomes objectAtIndex:0] managedObjectContext];
	
	int i;
	for(i=0; i<[genomes count]; i++) {
		
		NSArray *genome = [NSArray arrayWithObject:[genomes objectAtIndex:i]];
		
		int returnCode = [Flam3Task runFlam3RenderAsQuietTask:[Genome createXMLFromEntities:genome fromContext:thisMoc forThumbnail:YES] 
											  withEnvironment:taskEnvironment];
		
		if (returnCode == 0) {
			
			NSImage *flameImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:pngFileName]];
			[[[genome objectAtIndex:0] valueForKey:@"images"] setValue:flameImage forKey:@"image"];
			[flameImage release];

		}		
	}
	
	
	BOOL returnBool;
	
	if ([fileManager fileExistsAtPath:pngFileName]) {
		returnBool = [fileManager removeFileAtPath:pngFileName handler:nil];
		returnBool = [fileManager removeFileAtPath:previewFolder handler:nil];
	}
	
	[taskEnvironment release];
	
	
}	


@end

