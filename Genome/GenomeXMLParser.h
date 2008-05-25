//
//  GenomeXMLParser.h
//  oxidizer
//
//  Created by David Burnett on 11/05/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GenomeXMLParser : NSObject {

	NSManagedObject *_currentGenome;
	NSManagedObject *_currentTransform;
	NSManagedObject *_currentColour;
	NSManagedObject *_currentGenomeImages;
	
	NSMutableString *_previousEdits;
	
	
	NSMutableSet *_currentTransforms;
//	NSMutableSet *_currentColours;

	NSMutableArray *_currentColours;	
	NSMutableArray *_genomes;
	
	NSManagedObjectContext *_moc;	
	
	unsigned  int _transformCount;
	unsigned  int _editDepth;
	
	double palette[256][3]; 
	
	BOOL   useColourMap;


}

- (void)parserDidStartDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parserDidEndDocument:(NSXMLParser *)parser;

- (void) setManangedObjectContext:(NSManagedObjectContext *)manangedObjectContext;
- (NSArray *) getGenomes;


@end
