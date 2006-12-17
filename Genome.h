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
#import "flam3.h"

//NSManagedObjectContext *managedObjectContext();


@interface Genome : NSObject
{

	NSImage *_image;
	NSManagedObjectContext *_moc;
	NSManagedObject *_genomeEntity;
	flam3_genome *_genome;
	int _index;

}
 
+ (int) getIntSymmetry:(NSString *)value;
+ (NSString *) getStringSymmetry:(int)value;

/* Core data code */
+ (NSManagedObject *)createGenomeEntityFrom:(flam3_genome *)genome withImage:(NSImage *)image inContext:(NSManagedObjectContext *)moc;

+ (NSMutableSet *)createXFormEntitySetFromCGenome:(flam3_genome *)genome inContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createCMapEntitySetFromCGenome:(flam3_genome *)genome inContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createVariationsEntitySetFromCXForm:(flam3_xform *)xform inContext:(NSManagedObjectContext *)moc;

/* create default entities */
+ (NSManagedObject *)createDefaultGenomeEntityFromInContext:(NSManagedObjectContext *)moc;
+ (NSMutableSet *)createDefaultXFormEntitySetInContext:(NSManagedObjectContext *)moc; 
+ (NSMutableSet *)createDefaultVariationsEntitySetInContext:(NSManagedObjectContext *)moc; 


+ (flam3_genome *)populateAllCGenomesFromEntities:(NSArray *)entities fromContext:(NSManagedObjectContext *)moc;
+ (void )populateCGenome:(flam3_genome *)newGenome FromEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc;
+ (void )poulateXForm:(flam3_xform *)xform FromEntity:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc;
+ (void )poulateVariations:(flam3_xform *)xform FromEntityArray:(NSArray *)xformEntity;
+ (void )populateCMap:(flam3_palette )cmap FromEntityArray:(NSArray *)cmaps;
+ (xmlDocPtr) populateCEditDocFromEntity:(NSManagedObject *)genome;
+ (void) compareGenomesEntity:(NSManagedObject *)genomeEntity toCGenome:(flam3_genome *)genome fromContext:(NSManagedObjectContext *)moc;
+ (void) compareXForm:(flam3_xform *)of toXForm:(flam3_xform *)ff;

- (void)setCGenome:(flam3_genome *)cps;
- (flam3_genome *)getCGenome;

- (void)setManagedObjectContext:(NSManagedObjectContext *)moc;
- (NSManagedObjectContext *)getManagedObjectContext;

- (NSImage *)getImage;
- (void)setImage:(NSImage *)newImage;

- (NSManagedObject *)getGenomeEntity;
- (void)setGenomeEntity:(NSManagedObject *)genomeEntity;

- (void)createGenomeEntity;
  
@end
