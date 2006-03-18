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

/* FlameController */

#import <Cocoa/Cocoa.h>
#import "flam3.h"
#import "PaletteController.h"


@interface FlameController : NSObject 
{
    IBOutlet NSWindow *xformWindow;
    IBOutlet NSWindow *flameWindow;
    IBOutlet NSTableView *flames;
    IBOutlet NSTableView *flameValues;
	IBOutlet PaletteController *paletteController;
    IBOutlet NSImageView *paletteWithHue;
    IBOutlet NSArrayController *genomeController;
    IBOutlet NSArrayController *xformController;

	 NSBitmapImageRep *_paletteWithHueRep;

}


- (IBAction)showXFormWindow:(id)sender;
- (IBAction)showFlameWindow:(id)sender;
- (IBAction)changePaletteAndHidePaletteWindow:(id)sender;
- (IBAction)showFlameWindow:(id)sender;


- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;

-(void)removeFlameData;
-(void)addFlameData:(NSImage *)flameImage genome:(flam3_genome *)genome atIndex:(int )index inContext:(NSManagedObjectContext *)moc;
-(void)setPreviewForCurrentFlame:(NSImage *)preview;
- (NSManagedObject *)getSelectedGenome;


@end