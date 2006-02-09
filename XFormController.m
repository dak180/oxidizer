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

#import "XFormController.h"


@implementation XFormController

- init {

    if (self = [super init]) {

		_xformRecords = [[NSMutableArray alloc] init];
;
	}
	return self;
}

- (void)awakeFromNib
{
   [self loadTestDataFlameData];
}

- (void) setXformsArray:(NSMutableArray *)array {


	unsigned int i, end;
	
	end = [array count];

	[self willChangeValueForKey:@"_xformRecords"];
	
	[_xformRecords removeAllObjects];
	
	for(i=0; i<end; i++) { 	
			[_xformRecords addObject:[array objectAtIndex:i]]; 
	}
			
	[self didChangeValueForKey:@"_xformRecords"]; 
	

	[self willChangeValueForKey:@"_variations"];
	_variations = [[_xformRecords objectAtIndex:0] objectForKey:@"variations"];
	[self didChangeValueForKey:@"_variations"];
	
	[xforms reloadData];

}

-(void)loadTestDataFlameData {

	NSMutableDictionary *record = [[NSMutableDictionary alloc] init]; 
	[record setObject:@"0" forKey:@"use"];
	[record setObject:@"linear" forKey:@"variation"];
	[record setObject:@"0.5" forKey:@"coefficient"];

	[_xformRecords addObject:record];
	
	[record release];

}

-(void)loadFlameData:(flam3_genome *)genome numberOfGenes:(int )count {

	NSMutableDictionary *record; 
	int i;


	[_xformRecords removeAllObjects];
	
	for(i=0; i<count; i++) {
		record = [[NSMutableDictionary alloc] init];
		//genome->
		[record setObject:@"0" forKey:@"use"];
		[record setObject:@"linear" forKey:@"variation"];
		[record setObject:@"0.5" forKey:@"coefficient"];

		[_xformRecords addObject:record];
	
		[record release];
	}
	

}



- (void)setValue:(id)value forKey:(NSString *)key {

	NSLog(@"setting value for %@\n", key);
	[super setValue:value forKey:key];

}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {

	NSLog(@"setting value for %@\n", keyPath);
	[super setValue:value forKeyPath:keyPath];

}


- (IBAction)showXFormWindow:(id)sender
{

 [xformWindow makeKeyAndOrderFront:self];

}


- (IBAction)setCurrentVariation:(id)sender {


	[self willChangeValueForKey:@"_variations"];
	_variations = [[_xformRecords objectAtIndex:[sender selectedRow]] objectForKey:@"variations"];
	[self didChangeValueForKey:@"_variations"];


}
@end
