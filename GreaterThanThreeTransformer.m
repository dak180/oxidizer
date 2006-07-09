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


#import "GreaterThanThreeTransformer.h"


@implementation GreaterThanThreeTransformer

+ (Class)transformedValueClass { return [NSNumber class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {

	if ([value selectionIndex] > 0 && [[value arrangedObjects] count] > 3 && [value selectionIndex] != [[value arrangedObjects] count] - 1) {


		return [NSNumber numberWithBool:YES];
	} 
	

	NSArray *selected  = [value selectedObjects]; 
	
	if(value != nil && [selected count] > 0) {	
//		[[[value selectedObjects] objectAtIndex:0] willChangeValueForKey:@"interpolation"];
		[[selected objectAtIndex:0] setPrimitiveValue:[NSNumber numberWithInt:0] forKey:@"interpolation"];
	}
		
	return[NSNumber numberWithBool:NO];


}

@end

