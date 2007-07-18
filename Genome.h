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
+ (NSManagedObject *)createGenomeEntitiesFromElement:(NSXMLElement *)genome inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createTransformEntitiesFromElement:(NSXMLElement *)xform inContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createVariationEntitiesFromElement:(NSXMLElement *)xform inContext:(NSManagedObjectContext *)moc;
+ (NSManagedObject *)createVariationEntityFromElement:(NSXMLElement *)xform ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)moc;

+ (NSManagedObject *)createDefaultGenomeEntityFromInContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createDefaultVariationsEntitySetInContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createDefaultXFormEntitySetInContext:(NSManagedObjectContext *)moc;

/* lua interface */
+ (NSMutableDictionary *)createDictionaryFromGenomeEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc;
  
@end
