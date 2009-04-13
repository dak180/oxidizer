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

/* Genome */

#import <Cocoa/Cocoa.h>
#import "FlameController.h"
#import "PaletteController.h"

//NSManagedObjectContext *managedObjectContext();


@interface Genome : NSObject
{

	/*
	NSImage *_image;
	NSManagedObjectContext *_moc;
	NSManagedObject *_genomeEntity;
	flam3_genome *_genome;
	int _index;
*/
}
 
+ (int) getIntSymmetry:(NSString *)value;
+ (NSString *) getStringSymmetry:(int)value;

+ (NSData *)createXMLFromEntities:(NSArray *)entities fromContext:(NSManagedObjectContext *)moc forThumbnail:(BOOL)thumbnail; 
+ (NSXMLNode *)createXMLFromGenomeEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc forThumbnail:(BOOL)thumbnail;
+ (void) createXMLForXFormVariations:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc toElement:(NSXMLElement *)xform;
+ (NSXMLNode *)createXMLForXFormFromEntity:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc;
+ (void )createXMLForCMap:(NSArray *)cmaps forElement:(NSXMLElement *)genome;
+ (void) createXMLForEditElement:(NSXMLElement *)genomeElement usingEntity:(NSManagedObject *)genome;

+ (NSArray *)createGenomeEntitiesFromXML:(NSData *)xml inContext:(NSManagedObjectContext *)moc;
+ (NSArray *)createGenomeEntitiesFromFile:(NSString *)xml inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createGenomeEntitiesFromElement:(NSXMLElement *)genome inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createTransformEntitiesFromElement:(NSXMLElement *)xform inContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createVariationEntitiesFromElement:(NSXMLElement *)xform inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createVariationEntityFromElement:(NSXMLElement *)xform ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)moc;

+ (NSManagedObject *)createDefaultGenomeEntityInContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createDefaultGenomeImageEntityInContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createDefaultVariationsEntitySetInContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createDefaultXFormEntitySetInContext:(NSManagedObjectContext *)moc;

+ (NSManagedObject *)createEmptyGnomeInContext:(NSManagedObjectContext *)moc;

/* lua interface */
+ (NSArray *)createArrayFromEntities:(NSArray *)entities fromContext:(NSManagedObjectContext *)moc;
+ (NSMutableDictionary *)createDictionaryFromGenomeEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc;
+ (NSMutableDictionary *)createDictionaryFromTransformEntity:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc;
+ (NSMutableArray *)createArrayForTransformVariations:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc;
+ (NSMutableArray *)createArrayForCMap:(NSArray *)cmaps;
+ (NSMutableDictionary *) createDictionaryForEditUsingEntity:(NSManagedObject *)genome;

+ (NSArray *)createGenomeEntitiesFromArray:(NSArray *)genomeArray inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createGenomeEntityFromDictionary:(NSDictionary *)genome inContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createTransformEntitiesFromArray:(NSArray *)xforms inContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createVariationEntitiesFromArray:(NSArray *)variations inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createVariationEntityFromDictionary:(NSDictionary *)variationDictionary ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)mocPasteboardType;
+ (void) createColourMapFromArray:(NSArray *)colourMap forGenome:(NSManagedObject *)genomeEntity 
				   andImageEntity:(NSManagedObject *)genomeImageEntity 
						inContext:(NSManagedObjectContext *)moc;
/* event based parsing */
+ (NSManagedObject *) createColourMapFromAttributeDictionary:(NSDictionary *)colour inContext:(NSManagedObjectContext *)moc;	
+ (NSManagedObject *)createTransformEntity:(NSString *)name fromAttributeDictionary:(NSDictionary *)xform atPosition:(int)position inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createGenomeEntityFromAttributeDictionary:(NSDictionary *)genome inContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createVariationEntitiesFromAttributes:(NSDictionary *)xform inContext:(NSManagedObjectContext *)moc;				
+ (NSManagedObject *)createVariationEntityFromAttributeDictionary:(NSDictionary *)variationDictionary ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createGenomeImageEntityFromAttributeDictionary:(NSDictionary *)genome inContext:(NSManagedObjectContext *)moc;
+ (void) addEditsFromAttributeDictionary:(NSDictionary *)edits toGenome:(NSManagedObject *)genomeEntity;
+ (void) AppendEditStringFromAttributeDictionary:(NSDictionary *)edits toString:(NSMutableString *)previousEdits;
@end
