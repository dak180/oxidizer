//
//  GenomeXMLParser.m
//  oxidizer
//
//  Created by David Burnett on 11/05/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Genome.h"
#import "GenomeXMLParser.h"


@implementation GenomeXMLParser

- (void) setManangedObjectContext:(NSManagedObjectContext *)manangedObjectContext {
	
	if(manangedObjectContext != nil) {
		[manangedObjectContext retain];
	}
	
	[_moc release];
	_moc = manangedObjectContext;
	
}

- (NSArray *) getGenomes {
	
	return _genomes; 
}


- (void)parserDidStartDocument:(NSXMLParser *)parser {
	
	if (_genomes != nil) {
		[_genomes release]; 
	} 
	_genomes = [[NSMutableArray alloc] initWithCapacity:5];
	
	_transformCount = 0;

}




- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"flame"]) {
		_currentGenome = [Genome createGenomeEntityFromAttributeDictionary:attributeDict inContext:_moc];
		_currentTransforms = [[NSMutableSet alloc] initWithCapacity:5];
		_currentColours = [[NSMutableArray alloc] initWithCapacity:256];
		useColourMap = NO;
	} else if([elementName isEqualToString:@"xform"] || [elementName isEqualToString:@"finalxform"])  {
		_transformCount++;
		_currentTransform = [Genome createTransformEntity:elementName fromAttributeDictionary:attributeDict atPosition:_transformCount inContext:_moc];
		[_currentTransform retain];
	} else if([elementName isEqualToString:@"color"]) {
		_currentColour = [Genome createColourMapFromAttributeDictionary:attributeDict inContext:_moc];
		int index; 
		
		index = [[_currentColour valueForKey:@"index"] intValue];
		palette[index][0] = [[_currentColour valueForKey:@"red"] doubleValue];
		palette[index][1] = [[_currentColour valueForKey:@"green"] doubleValue];
		palette[index][2] = [[_currentColour valueForKey:@"blue"] doubleValue];
				  
		[_currentTransform retain];
		
		useColourMap = YES;

	} else if([elementName isEqualToString:@"symmetry"]) {
		[_currentGenome setValue:[attributeDict objectForKey:@"kind"] forKey:@"symmetry"];
	} else if([elementName isEqualToString:@"edits"]) {
		[Genome addEditsFromAttributeDictionary:attributeDict toGenome:_currentGenome];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	

	if([elementName isEqualToString:@"flame"]) {
		/* add the xforms and colours to the genome */
		[_currentGenome setValue:_currentTransforms forKey:@"xforms"];
		[_currentGenome setValue:[NSSet setWithArray:_currentColours] forKey:@"cmap"];
		
		if(useColourMap) {
			
			NSImage *colourMapImage = [[NSImage alloc] init];
			NSBitmapImageRep *colourMapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																						  pixelsWide:256
																						  pixelsHigh:1
																					   bitsPerSample:8
																					 samplesPerPixel:3
																							hasAlpha:NO 
																							isPlanar:NO
																					  colorSpaceName:NSDeviceRGBColorSpace
																						bitmapFormat:0
																						 bytesPerRow:3*256
																						bitsPerPixel:24]; 
			[PaletteController fillBitmapRep:colourMapImageRep withPalette:palette[0] forHeight:1]; 
			[colourMapImage addRepresentation:colourMapImageRep];
			
			[[_currentGenome valueForKey:@"images"] setValue:colourMapImage forKey: @"colour_map_image"];
					
			[colourMapImageRep release];
			[colourMapImage release];

		}

        /* add the genome to the array */
		[_genomes addObject:_currentGenome];
		[_currentGenome release];
		[_currentTransforms release];		
		[_currentColours release];		
	} else if([elementName isEqualToString:@"xform"] || [elementName isEqualToString:@"finalxform"])  {
		/* add the xform to the set */
		[_currentTransforms addObject:_currentTransform];
		[_currentTransform release];
	} else if([elementName isEqualToString:@"color"])  {
		[_currentColours addObject:_currentColour];
		[_currentColour release];
	}
	
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
	

}


@end
