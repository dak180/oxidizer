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
#import "flam3.h"

@interface Genome : NSObject
{
}

+ (void)populateCGenome:(flam3_genome *)newGenome From:(NSMutableDictionary *)genomeDictionary;
+ (NSMutableDictionary *)makeDictionaryFrom:(flam3_genome *)genome withImage:(NSImage *)image;
+ (void )poulateXForm:(flam3_xform *)xform FromDictionary:(NSMutableDictionary *)xformDictionary;
+ (flam3_genome *)createAllCGenomes:(NSArray *)genome;
+ (NSMutableArray *)createXformArrayFromCGenome:(flam3_genome *)genome;
+ (BOOL)testXMLFrame:(char *)filename againstOxizdizerFrame:(flam3_frame *)new; 
+ (BOOL)testCGenome:(flam3_genome *)old againstOxizdizerCGenome:(flam3_genome *)new;

+ (int) getIntSymmetry:(NSString *)value;
+ (NSString *) getStringSymmetry:(int)value;

@end
