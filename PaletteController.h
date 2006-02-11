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

/* PaletteController */

#import <Cocoa/Cocoa.h>

@interface PaletteController : NSObject
{
    IBOutlet NSTextField *textField;
    IBOutlet NSButton *usePalette;
    IBOutlet NSButton *pickPalette;
    IBOutlet NSTableView *colourTable;
    IBOutlet NSTableView *palatteTable;
    IBOutlet NSWindow *palatteWindow;
    IBOutlet NSArrayController *paletteList;
	
	BOOL _usePalette;
	int _paletteNumber;
	NSMutableArray *_colours;
	NSMutableArray *_palettes;
}
- (IBAction)setEnabled:(id)sender;
- (IBAction)setNumber:(id)sender;
- (IBAction)hidePaletteWindow:(id)sender;
- (IBAction)showPaletteList:(id)sender;

+ (void) fillBitmapRep:(NSBitmapImageRep *)paletteRep withPalette:(int)paletteNumber usingHue:(double)hue;
+ (void) fillBitmapRep:(NSBitmapImageRep *)paletteRep withColours:(NSMutableArray *)colours  forHeight:(int)height;
+ (NSMutableArray *) extrapolateArray:(NSMutableArray *)colours;

- (void) setPalette:(unsigned int )palette colourArray:(NSArray *)colours  usePalette:(BOOL)useThePaletteNumber;
- (int)changePaletteAndHidePaletteWindow;


@end
