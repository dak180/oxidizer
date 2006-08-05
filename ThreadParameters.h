/* ThreadParameters */
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

#import <Cocoa/Cocoa.h>
#import "flam3.h"
#import <semaphore.h>

@interface ThreadParameters : NSObject
{

	int releaseCondition;
	int lockCondition;
	NSConditionLock *condition;
	NSConditionLock *endLock;
	flam3_frame *frames;
	double firstFrame;
	NSImage *image;
	NSBitmapImageRep *imageRep;
	unsigned char *stripStart;
	NSMutableDictionary *progress;
//	flam3_genome *genome;

}

- (void)setReleaseCondition:(int)condition;
- (int)getReleaseCondition;
- (void)setLockCondition:(int)condition;
- (int)getLockCondition;
- (void)setConditionLock:(NSConditionLock *)newCondition;
- (NSConditionLock *)getConditionLock;

- (void)setEndLock:(NSConditionLock *)condition;
- (NSConditionLock *)getEndLock;


- (void)setFrames:(flam3_frame *)newFrame;
- (flam3_frame *)getFrames;
- (void)setFirstFrame:(double)first;					
- (double)getFirstFrame;

- (NSImage *)getImage;
- (NSBitmapImageRep *)getImageRep;
- (void)setImage:(NSImage *)newImage;
- (void)setImageRep:(NSBitmapImageRep *)newImageRep;

- (void)setStripStart:(unsigned char *)strip;
- (unsigned char *)getStripStart;

/*
- (void)setGenome:(flam3_genome *)cps;
- (flam3_genome *)getGenome;
*/

@end
