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

#import "EnvironmentController.h"

@implementation EnvironmentController


- (void)awakeFromNib {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[self willChangeValueForKey:@"aspect"];
	aspect = [defaults stringForKey:@"aspect"];
	[self didChangeValueForKey:@"aspect"];

	[self willChangeValueForKey:@"bits"];
	bits = [defaults stringForKey:@"buffer_type"];
	[self didChangeValueForKey:@"bits"];

	[self willChangeValueForKey:@"qualityScale"];
	qualityScale = [defaults integerForKey:@"qs"];
	[self didChangeValueForKey:@"qualityScale"];

	[self willChangeValueForKey:@"sizeScale"];
	sizeScale = [defaults integerForKey:@"ss"];
	[self didChangeValueForKey:@"sizeScale"];

	[self willChangeValueForKey:@"seed"];
	seed = time(NULL);
	[self didChangeValueForKey:@"seed"];

	[self willChangeValueForKey:@"useAlpha"];
	useAlpha = [defaults boolForKey:@"use_alpha"];
	[self didChangeValueForKey:@"useAlpha"];

	[self willChangeValueForKey:@"nframes"];
	nframes = 10;
	[self didChangeValueForKey:@"nframes"];

	srandom(seed) ;

}

- (IBAction) randomSeed:(id)sender {

	[self willChangeValueForKey:@"seed"];
	seed = arc4random();
	[self didChangeValueForKey:@"seed"];

	[seedTextField setIntValue:seed];


}

- (int) getIntBits {


	if([bits compare:@"Float"] == NSOrderedSame) {

		return 33;
	}

	if([bits compare:@"Double"] ==  NSOrderedSame) {

		return 64;

	}


	if([bits compare:@"Long"] ==  NSOrderedSame) {

		return 32;
	}


	if([bits compare:@"Short"] ==  NSOrderedSame) {

		return 16;
	}

	return 33;

}


- (double) doubleAspect {

	NSScanner *scanner;
	int tmpValue;

	if([aspect compare:@"PAL 4:3"] == NSOrderedSame) {

		return 1.092592592593;
	}

	if([aspect compare:@"NTSC 4:3"] ==  NSOrderedSame) {

		return 0.909090909091;

	}

	if([aspect compare:@"PAL 16:9"] == NSOrderedSame) {

		return 1.456790123457;
	}

	if([aspect compare:@"NTSC 16:9"] ==  NSOrderedSame) {

		return 1.212121212121;

	}

	if([aspect compare:@"1:1"] ==  NSOrderedSame) {

		return 1.0;

	}

	scanner = [NSScanner scannerWithString:aspect];
	if([scanner scanInt:&tmpValue]) {

		return tmpValue;

	}

	return 1.0;


}

@end
