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

/* EnvironmentController */

#import <Cocoa/Cocoa.h>

@interface EnvironmentController : NSObject
{


	IBOutlet NSTextField *seedTextField;

@public

	double qualityScale;
	double sizeScale;
	NSString *aspect;
	int seed;
	NSString *bits;
	bool useAlpha;
	int nframes;


}

- (IBAction) randomSeed:(id)sender;
- (int) getIntBits;
- (double) doubleAspect;
@end
