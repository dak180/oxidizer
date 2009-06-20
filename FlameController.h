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
#import "PaletteController.h"
#import "GradientNibController.h"

@interface FlameController : NSObject 
{
    IBOutlet NSWindow *xformWindow;
    IBOutlet NSWindow *flameWindow;
    IBOutlet NSWindow *paletteWindow;
    IBOutlet NSWindow *cmapWindow;
    IBOutlet NSTableView *flames;
    IBOutlet NSTableView *flameValues;
	IBOutlet PaletteController *paletteController;
    IBOutlet NSImageView *paletteWithHue;
    IBOutlet NSArrayController *genomeController;
    IBOutlet NSArrayController *cmapController;
    IBOutlet NSColorWell *colourWell;
    IBOutlet NSImageView *colourWithHue;
    IBOutlet id _qvc;
    IBOutlet GradientNibController *gnc;

	 NSBitmapImageRep *_paletteWithHueRep;
	 NSBitmapImageRep *_colourWithHueRep;
	 NSImage *colourImage;

@public 
    IBOutlet NSArrayController *xformController;

	
}

+ (void)attachImageToGenomeFromDictionary:(NSDictionary *)DictionaryInformation;


- (IBAction)showXFormWindow:(id)sender;
- (IBAction)changePaletteAndHidePaletteWindow:(id)sender;
- (IBAction)showPaletteList:(id)sender;
- (IBAction)changeColourMap:(id)sender;
- (IBAction)changeColourMapAndHideWindow:(id)sender;
- (IBAction)moveXForm:(id)sender;


- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;

- (void)removeFlameData;
- (void)setPreviewForCurrentFlame:(NSImage *)preview;
- (void)setPreviewForCurrentFlameFromFile:(NSString *)previewPath;

- (NSManagedObject *)getSelectedGenome;

- (void)addNewFlame:(NSManagedObject *)genomeEntity;
- (void)showFlameWindow;
- (void)removeFlame;

@end
