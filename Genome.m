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
#import <libxml/parser.h>
#import "Genome.h"
#import "GenomeManagedObject.h"
#import "PaletteController.h"

#define flam3_nvariations 56

NSString *variationName[1+flam3_nvariations] = {
	@"linear",
	@"sinusoidal",
	@"spherical",
	@"swirl",
	@"horseshoe",
	@"polar",
	@"handkerchief",
	@"heart",
	@"disc",
	@"spiral",
	@"hyperbolic",
	@"diamond",
	@"ex",
	@"julia",
	@"bent",
	@"waves",
	@"fisheye",
	@"popcorn",
	@"exponential",
	@"power",
	@"cosine",
	@"rings",
	@"fan",
	@"blob",
	@"pdj",
	@"fan2",
	@"rings2",
	@"eyefish",
	@"bubble",
	@"cylinder",
	@"perspective",
	@"noise",
	@"julian",
	@"juliascope",
	@"blur",
	@"gaussian_blur",
	@"radial_blur",
	@"pie",
	@"ngon",
	@"curl",
	@"rectangles",
	@"arch",
	@"tangent",
	@"square",
	@"rays",
	@"blade",
	@"secant",
	@"twintrian",
	@"cross",
	@"disc2",
	@"super_shape",
	@"flower",
	@"conic",
	@"parabola",
	@"split",
	@"move"
};

@implementation Genome


+ (NSData *)createXMLFromEntities:(NSArray *)entities fromContext:(NSManagedObjectContext *)moc forThumbnail:(BOOL)thumbnail {
	
	int genomeCount, i;
	
	genomeCount = [entities count];
	
	NSXMLElement *root;
	
	if (genomeCount > 1) {
		root = (NSXMLElement *)[NSXMLNode elementWithName:@"oxidizer"];
		for(i=0; i<genomeCount; i++) {
			[root addChild:[Genome createXMLFromGenomeEntity:[entities objectAtIndex:i] fromContext:moc forThumbnail:thumbnail]];
		}
	} else {
		root = (NSXMLElement *)[Genome createXMLFromGenomeEntity:[entities objectAtIndex:0] fromContext:moc forThumbnail:thumbnail];		
	}


	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
	[xmlDoc setVersion:@"1.0"];
	[xmlDoc setCharacterEncoding:@"UTF-8"];
	
	[xmlDoc autorelease];

	return [xmlDoc XMLDataWithOptions:NSXMLDocumentTidyXML];

}

+ (NSXMLNode *)createXMLFromGenomeEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc forThumbnail:(BOOL)thumbnail {
	
	NSXMLElement *genome = [NSXMLElement elementWithName:@"flame"];
	
	NSArray *cmaps;
	NSArray *sortDescriptors;
	NSArray *xforms; 
	
	NSFetchRequest *fetch;
	NSPredicate *predicate;						 
	NSSortDescriptor *sort;
	NSString *tempString;
	
	float red, green, blue;
	int i;
	
	tempString = [genomeEntity valueForKey:@"name"];
	if(tempString != nil) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:tempString]];
	}
	
	tempString = [genomeEntity valueForKey:@"parent"];
	if(tempString != nil) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"parent" stringValue:tempString]];
	}

	[genome addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[[genomeEntity valueForKey:@"time"] stringValue]]];
	
	if (thumbnail) {
		int realWidth  = [[genomeEntity valueForKey:@"width"] intValue];
		int realHeight = [[genomeEntity valueForKey:@"height"] intValue];
		double realScale =  [[genomeEntity valueForKey:@"scale"] doubleValue];
	
		double scaleFactor = realHeight > realWidth ? 128.0 / realHeight : 128.0 / realWidth;
		
		[genome addAttribute:[NSXMLNode attributeWithName:@"size" 
											  stringValue:[NSString stringWithFormat:@"%d %d",
												 (int)(realWidth * scaleFactor), 
												 (int)(realHeight * scaleFactor)]]];
		
		[genome addAttribute:[NSXMLNode attributeWithName:@"scale" 
										stringValue:[NSString stringWithFormat:@"%0.7f", (realScale * scaleFactor)]]];
		
		
	} else {
		[genome addAttribute:[NSXMLNode attributeWithName:@"size" 
											  stringValue:[NSString stringWithFormat:@"%d %d",
												  [[genomeEntity valueForKey:@"width"] intValue], 
												  [[genomeEntity valueForKey:@"height"] intValue]]]];

		[genome addAttribute:[NSXMLNode attributeWithName:@"scale" stringValue:[[genomeEntity valueForKey:@"scale"] stringValue]]];
	
	}


	[genome addAttribute:[NSXMLNode attributeWithName:@"center" 
									stringValue:[NSString stringWithFormat:@"%0.7f %0.7f",
										[[genomeEntity valueForKey:@"centre_x"] doubleValue], 
										[[genomeEntity valueForKey:@"centre_y"] doubleValue]]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"zoom" stringValue:[[genomeEntity valueForKey:@"zoom"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"oversample" stringValue:[[genomeEntity valueForKey:@"oversample"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"quality" stringValue:[[genomeEntity valueForKey:@"quality"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"passes" stringValue:[[genomeEntity valueForKey:@"batches"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_samples" stringValue:[[genomeEntity valueForKey:@"jitter"] stringValue]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"estimator_radius" stringValue:[[genomeEntity valueForKey:@"de_max_filter"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"estimator_minimum" stringValue:[[genomeEntity valueForKey:@"de_min_filter"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"estimator_curve" stringValue:[[genomeEntity valueForKey:@"de_alpha"] stringValue]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"gamma" stringValue:[[genomeEntity valueForKey:@"gamma"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"gamma_threshold" stringValue:[[genomeEntity valueForKey:@"gamma_threshold"] stringValue]]];


	[[genomeEntity valueForKey:@"background"] getRed:&red green:&green blue:&blue alpha:NULL];

	[genome addAttribute:[NSXMLNode attributeWithName:@"background" 
									stringValue:[NSString stringWithFormat:@"%d %d %d", red * 255, blue * 255, green * 255]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"hue" stringValue:[[genomeEntity valueForKey:@"hue"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"vibrancy" stringValue:[[genomeEntity valueForKey:@"vibrancy"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"brightness" stringValue:[[genomeEntity valueForKey:@"brightness"] stringValue]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"rotate" stringValue:[[genomeEntity valueForKey:@"rotate"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"contrast" stringValue:[[genomeEntity valueForKey:@"contrast"] stringValue]]];

	NSXMLElement *symmetryElement = (NSXMLElement *)[NSXMLNode elementWithName:@"symmetry"];
	[symmetryElement addAttribute:[NSXMLNode attributeWithName:@"kind" 
										           stringValue:[NSString stringWithFormat:@"%d",  [Genome getIntSymmetry:[genomeEntity valueForKey:@"symmetry"]]]]];

	[genome addChild:symmetryElement];
		
	[genome addAttribute:[NSXMLNode attributeWithName:@"interpolation" stringValue:[[genomeEntity valueForKey:@"interpolation"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"motion_exponent" stringValue:[[genomeEntity valueForKey:@"motion_exp"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"filter" stringValue:[[genomeEntity valueForKey:@"spatial_filter_radius"] stringValue]]];
	
	if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"B-Spline"]) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"filter_shape" stringValue:@"bspline"]];
	} else {
		[genome addAttribute:[NSXMLNode attributeWithName:@"filter_shape" stringValue:[[genomeEntity valueForKey:@"spatial_filter_func"] lowercaseString]]];
	}
	
	[Genome createXMLForEditElement:genome usingEntity:genomeEntity];

	
	if([[genomeEntity valueForKey:@"use_palette"] boolValue] == FALSE) {

		predicate = [NSPredicate predicateWithFormat:@"parent_genome == %@", genomeEntity];
							 
		sort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
		sortDescriptors = [NSArray arrayWithObject: sort];
		
		fetch = [[NSFetchRequest alloc] init];
		[fetch setEntity:[NSEntityDescription entityForName:@"CMap" inManagedObjectContext:moc]];
		[fetch setPredicate: predicate];
		[fetch setSortDescriptors: sortDescriptors];
		
		cmaps = [moc executeFetchRequest:fetch error:nil];
		[sort release];
		[fetch release];	
		/* use the cmap */
		if([cmaps count] < 256) {
			NSMutableArray *newCmaps = [PaletteController extrapolateArray:cmaps];
			[newCmaps retain];
			[Genome createXMLForCMap:newCmaps forElement:genome];
			[newCmaps release];
		} else {
			[Genome createXMLForCMap:cmaps forElement:genome];
		}
	} else {
		[genome addAttribute:[NSXMLNode attributeWithName:@"palette" stringValue:[[genomeEntity valueForKey:@"palette"] stringValue]]];
	}
	
		
	/* xforms */
	
	predicate = [NSPredicate predicateWithFormat:@"parent_genome == %@", genomeEntity];
	
	sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	sortDescriptors = [NSArray arrayWithObject: sort];
	
	fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"XForm" inManagedObjectContext:moc]];
	[fetch setPredicate: predicate];
	[fetch setSortDescriptors: sortDescriptors];
	
	xforms = [moc executeFetchRequest:fetch error:nil];
	[sort release];
	[fetch release];
	
	int old_num_xforms = [xforms count];
	
	for(i=0; i < old_num_xforms; i++) {
		
		[genome addChild:[Genome createXMLForXFormFromEntity:[xforms objectAtIndex:i] fromContext:moc]];
		if([[[xforms objectAtIndex:i] valueForKey:@"final_xform"] boolValue] == YES) {
//			newGenome->final_xform_index = i+newGenome->num_xforms;
		}
		
	}
	
	
	
	return genome;
	
}

+ (NSXMLNode *)createXMLForXFormFromEntity:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc {
	
	
	NSXMLElement *xform;
	
	if([[xformEntity valueForKey:@"final_xform"] boolValue] == YES) {

		xform = [NSXMLElement elementWithName:@"finalxform"];
		
	} else {

		xform = [NSXMLElement elementWithName:@"xform"];

	}
		
	
	[xform addAttribute:[NSXMLNode attributeWithName:@"weight" stringValue:[[xformEntity valueForKey:@"density"] stringValue]]];

	[xform addAttribute:[NSXMLNode attributeWithName:@"coefs" 
										  stringValue:[NSString stringWithFormat:@"%0.7f %0.7f %0.7f %0.7f %0.7f %0.7f",
											  [[xformEntity valueForKey:@"coeff_0_0"] doubleValue], 
											  [[xformEntity valueForKey:@"coeff_0_1"] doubleValue], 
											  [[xformEntity valueForKey:@"coeff_1_0"] doubleValue], 
											  [[xformEntity valueForKey:@"coeff_1_1"] doubleValue], 
											  [[xformEntity valueForKey:@"coeff_2_0"] doubleValue], 
											  [[xformEntity valueForKey:@"coeff_2_1"] doubleValue]]]];
	
	
	
	if([[xformEntity valueForKey:@"post_flag"] boolValue] == YES) {

		[xform addAttribute:[NSXMLNode attributeWithName:@"post" 
											 stringValue:[NSString stringWithFormat:@"%0.7f %0.7f %0.7f %0.7f %0.7f %0.7f",
												 [[xformEntity valueForKey:@"post_0_0"] doubleValue], 
												 [[xformEntity valueForKey:@"post_0_1"] doubleValue], 
												 [[xformEntity valueForKey:@"post_1_0"] doubleValue], 
												 [[xformEntity valueForKey:@"post_1_1"] doubleValue], 
												 [[xformEntity valueForKey:@"post_2_0"] doubleValue], 
												 [[xformEntity valueForKey:@"post_2_1"] doubleValue]]]];
		
	}
	
	[xform addAttribute:[NSXMLNode attributeWithName:@"color" stringValue:[[xformEntity valueForKey:@"colour_0"] stringValue]]];
	
	
	[xform addAttribute:[NSXMLNode attributeWithName:@"symmetry" stringValue:[[xformEntity valueForKey:@"symmetry"] stringValue]]];
	
	[Genome createXMLForXFormVariations:xformEntity fromContext:moc toElement:xform];
	
	return xform;
	
	
}


+ (void) createXMLForXFormVariations:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc toElement:(NSXMLElement *)xform {
	
	NSArray *variations;
	
	NSPredicate * predicate;
	//	predicate = [NSPredicate predicateWithFormat:@"parent_xform.order == %ul", [[xformEntity valueForKey:@"order"] intValue]];
	predicate = [NSPredicate predicateWithFormat:@"parent_xform == %@", xformEntity];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"variation_index" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Variations" inManagedObjectContext:moc]];
	[fetch setPredicate: predicate];
	[fetch setSortDescriptors: sortDescriptors];
	
	variations = [moc executeFetchRequest:fetch error:nil];
	[sort release];
	[fetch release];
	
	
	
	unsigned int i;
	
	NSManagedObject *variation;
	
	NSMutableString *weights = [NSMutableString stringWithCapacity:256];
	
	for(i=0; i<[variations count]; i++) {
		variation = [variations objectAtIndex:i];
		
		if([[variation valueForKey:@"in_use"] boolValue] == YES) {
			[weights appendString:[[variation valueForKey:@"weight"] stringValue]];
			[weights appendString:@" "];
		
			switch(i) {
				case 23:
					[xform addAttribute:[NSXMLNode attributeWithName:@"blob_high" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"blob_low" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"blob_waves" stringValue:[[variation valueForKey:@"parameter_3"] stringValue]]];
					break;
				case 24:
					[xform addAttribute:[NSXMLNode attributeWithName:@"pdj_a" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"pdj_b" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"pdj_c" stringValue:[[variation valueForKey:@"parameter_3"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"pdj_d" stringValue:[[variation valueForKey:@"parameter_4"] stringValue]]];
					break;
				case 25:
					[xform addAttribute:[NSXMLNode attributeWithName:@"fan2_x" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"fan2_y" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;				
				case 26:
					[xform addAttribute:[NSXMLNode attributeWithName:@"rings2_val" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					break;
				case 30:
					[xform addAttribute:[NSXMLNode attributeWithName:@"perspective_angle" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"perspective_dist" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;
				case 32:
					[xform addAttribute:[NSXMLNode attributeWithName:@"julian_dist" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"julian_power" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;
				case 33:
					[xform addAttribute:[NSXMLNode attributeWithName:@"juliascope_dist" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"juliascope_power" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 36:
					[xform addAttribute:[NSXMLNode attributeWithName:@"radial_blur_angle" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					break;	
				case 37:
					[xform addAttribute:[NSXMLNode attributeWithName:@"pie_slices" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"pie_rotation" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"pie_thickness" stringValue:[[variation valueForKey:@"parameter_3"] stringValue]]];
					break;	
				case 38:
					[xform addAttribute:[NSXMLNode attributeWithName:@"ngon_sides" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"ngon_power" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"ngon_circle" stringValue:[[variation valueForKey:@"parameter_3"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"ngon_corners" stringValue:[[variation valueForKey:@"parameter_4"] stringValue]]];
					break;	
				case 39:
					[xform addAttribute:[NSXMLNode attributeWithName:@"curl_c1" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"curl_c2" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 40:
					[xform addAttribute:[NSXMLNode attributeWithName:@"rectangles_x" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"rectangles_y" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 49:
					[xform addAttribute:[NSXMLNode attributeWithName:@"disc2_rot" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"disc2_twist" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 50:
					[xform addAttribute:[NSXMLNode attributeWithName:@"super_shape_rnd" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"super_shape_m" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"super_shape_n1" stringValue:[[variation valueForKey:@"parameter_3"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"super_shape_n2" stringValue:[[variation valueForKey:@"parameter_4"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"super_shape_n3" stringValue:[[variation valueForKey:@"parameter_5"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"super_shape_holes" stringValue:[[variation valueForKey:@"parameter_6"] stringValue]]];
					break;	
				case 51:
					[xform addAttribute:[NSXMLNode attributeWithName:@"flower_petals" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"flower_holes" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 52:
					[xform addAttribute:[NSXMLNode attributeWithName:@"conic_eccentricity" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"conic_holes" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 53:
					[xform addAttribute:[NSXMLNode attributeWithName:@"parabola_height" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"parabola_width" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 54:
					[xform addAttribute:[NSXMLNode attributeWithName:@"split_xsize" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"split_ysize" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				case 55:
					[xform addAttribute:[NSXMLNode attributeWithName:@"move_x" stringValue:[[variation valueForKey:@"parameter_1"] stringValue]]];
					[xform addAttribute:[NSXMLNode attributeWithName:@"move_y" stringValue:[[variation valueForKey:@"parameter_2"] stringValue]]];
					break;	
				default:
					break;
			}
		
		} else {
			[weights appendString:@"0 "];
		}
		
		
	}

	[xform addAttribute:[NSXMLNode attributeWithName:@"var" stringValue:weights]];

	return;
}


+ (void )createXMLForCMap:(NSArray *)cmaps forElement:(NSXMLElement *)genome {
	
	NSManagedObject *colour;
	NSXMLElement *colourElement;
	int i;
	
	for(i=0; i<256; i++) {

		colour = [cmaps objectAtIndex:i];

		colourElement = (NSXMLElement *)[NSXMLNode elementWithName:@"color"];
			
		[colourElement addAttribute:[NSXMLNode attributeWithName:@"index" stringValue:[NSString stringWithFormat:@"%d", i]]];
		
			if ([[colour valueForKey:@"red"]   doubleValue] > 1.0) {
				NSLog(@"colour failed");
			}
		
		[colourElement addAttribute:[NSXMLNode attributeWithName:@"rgb" 
											   stringValue:[NSString stringWithFormat:@"%d %d %d", 
												   (int)([[colour valueForKey:@"red"]   doubleValue] * 255),
												   (int)([[colour valueForKey:@"green"]   doubleValue] * 255),
												   (int)([[colour valueForKey:@"blue"]   doubleValue] * 255)]]];
		
		
		[genome addChild:colourElement];
		
	}
	
}



+ (void) createXMLForEditElement:(NSXMLElement *)genomeElement usingEntity:(NSManagedObject *)genome {
	
	NSXMLElement *newEditElement;
	NSXMLElement *oldRootElement;
	NSXMLDocument *oldDoc = nil;
	NSError *xmlError;
	NSString *date;
	NSString *oldDocAsXML;
	
	struct tm *localt;
	time_t mytime;
	char timestring[100];
	
	
	/* create a date stamp (change to use cocoa)*/
	mytime = time(NULL);
	localt = localtime(&mytime);
	/* XXX use standard time format including timezone */
	strftime(timestring, 100, "%a %b %e %H:%M:%S %Z %Y", localt);
	
	date = [NSString stringWithCString:timestring encoding:NSUTF8StringEncoding];
	
	/* create edit element with new details */ 
	newEditElement = [[NSXMLElement alloc] initWithName:@"edit"];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"nick" stringValue:[genome valueForKey:@"nick"]]];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"url" stringValue:[genome valueForKey:@"url"]]];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"comm" stringValue:[genome valueForKey:@"comment"]]];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"date" stringValue:date]];
	
	/* If there are old values add them as a child element of our edit element */
	
	NSAttributedString *xmlValue = [genome valueForKey:@"edits"];
	
	oldDocAsXML = [xmlValue string];
	
	if(oldDocAsXML != nil && [oldDocAsXML compare:@""] != NSOrderedSame) {
		
		oldDoc = [[NSXMLDocument alloc] initWithXMLString:oldDocAsXML options:NSXMLDocumentTidyXML error:&xmlError];
		if(oldDoc == nil) {
			NSLog(@"%@\n", [xmlError localizedDescription]);
			[xmlError release];
		}
		
		oldRootElement = [oldDoc rootElement];
		[oldRootElement detach];
		[newEditElement addChild:oldRootElement];
	}

	[genomeElement addChild:newEditElement];
	
	return;
}


+ (NSArray *)createGenomeEntitiesFromXML:(NSData *)xml inContext:(NSManagedObjectContext *)moc {
	
	NSArray *flameElements;
	NSMutableArray *genomes = [[NSMutableArray alloc] initWithCapacity:5];
	
	NSError *error;
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:xml options:0 error:&error];
	
	NSXMLElement *root = [doc rootElement];
	NSXMLElement *flameElement;
	
	
	
	if ([[root name] isEqualToString:@"flame"]) {
		flameElements = [NSArray arrayWithObject:root];
	} else {
		flameElements = [root elementsForName:@"flame"];		
	}
	

	NSEnumerator *flameEnumerator = [flameElements objectEnumerator];
	
	
	while ((flameElement = [flameEnumerator nextObject])) {
		[genomes addObject:[Genome createGenomeEntitiesFromElement:flameElement inContext:moc]]; 
	}
		
	[genomes autorelease];
	return genomes;
}

+ (NSManagedObject *)createGenomeEntitiesFromElement:(NSXMLElement *)genome inContext:(NSManagedObjectContext *)moc {
	
	NSManagedObject *newGenomeEntity = [Genome createDefaultGenomeEntityFromInContext:moc];
	NSXMLNode *tempAttribute;
	NSString *tempString;
	
	
	tempAttribute = [genome attributeForName:@"name"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[tempAttribute stringValue] forKey:@"name"];
	}
	
	tempAttribute = [genome attributeForName:@"parent"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[tempAttribute stringValue] forKey:@"parent"];
	}
	
	tempAttribute = [genome attributeForName:@"time"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"time"];
	}
	
	tempAttribute = [genome attributeForName:@"size"];
	if(tempAttribute != nil) {
		NSArray *split = [[tempAttribute stringValue] componentsSeparatedByString:@" "];
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[split objectAtIndex:0] intValue]] forKey:@"width"];
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[split objectAtIndex:1] intValue]] forKey:@"height"];
	}		
	
	tempAttribute = [genome attributeForName:@"scale"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"scale"];
	}
	
	tempAttribute = [genome attributeForName:@"center"];
	if(tempAttribute != nil) {
		NSArray *split = [[tempAttribute stringValue] componentsSeparatedByString:@" "];
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:0] doubleValue]] forKey:@"centre_x"];
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:1] doubleValue]] forKey:@"centre_y"];
	}		


	tempAttribute = [genome attributeForName:@"scale"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"scale"];
	}

	tempAttribute = [genome attributeForName:@"zoom"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"zoom"];
	}
	
	tempAttribute = [genome attributeForName:@"oversample"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"oversample"];
	}

	tempAttribute = [genome attributeForName:@"quality"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"quality"];
	}

	tempAttribute = [genome attributeForName:@"passes"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"batches"];
	}
	
	tempAttribute = [genome attributeForName:@"temporal_samples"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"jitter"];
	}
	
	tempAttribute = [genome attributeForName:@"estimator_radius"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"de_max_filter"];
	}

	tempAttribute = [genome attributeForName:@"estimator_minimum"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"de_min_filter"];
	}
	
	tempAttribute = [genome attributeForName:@"estimator_curve"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"de_alpha"];
	}
	
	tempAttribute = [genome attributeForName:@"gamma"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"gamma"];
	}
	
	tempAttribute = [genome attributeForName:@"gamma_threshold"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"gamma_threshold"];
	}

	tempAttribute = [genome attributeForName:@"background"];
	if(tempAttribute != nil) {
		NSArray *split = [[tempAttribute stringValue] componentsSeparatedByString:@" "];
		double red, green, blue;
		red =   [[split objectAtIndex:0] doubleValue];
		green = [[split objectAtIndex:1] doubleValue];
		blue =  [[split objectAtIndex:2] doubleValue];
		red   /= 255;
		green /= 255;
		blue  /= 255;

		[newGenomeEntity setValue:[NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0] forKey:@"background"];
		
	}

	tempAttribute = [genome attributeForName:@"hue"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"hue"];
	}
	tempAttribute = [genome attributeForName:@"vibrancy"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"vibrancy"];
	}
	tempAttribute = [genome attributeForName:@"brightness"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"brightness"];
	}	

	tempAttribute = [genome attributeForName:@"rotate"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"rotate"];
	}

	tempAttribute = [genome attributeForName:@"contrast"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"contrast"];
	}
	
	
	tempAttribute = [genome attributeForName:@"interpolation"];
	if([[tempAttribute stringValue] isEqualToString:@"smooth"]) {
		[newGenomeEntity setValue:[NSNumber numberWithInt:1]  forKey:@"interpolation"];
	} else {
		[newGenomeEntity setValue:[NSNumber numberWithInt:0]  forKey:@"interpolation"];
	}

	tempAttribute = [genome attributeForName:@"motion_exponent"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"motion_exp"];
	}
	

	tempAttribute = [genome attributeForName:@"filter"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]]  forKey:@"spatial_filter_radius"];
	}
	
	tempAttribute = [genome attributeForName:@"filter_shape"];
	if(tempAttribute != nil) {

		NSString *spatial_filter_func = [tempAttribute stringValue];
		
		if ([spatial_filter_func isEqualToString:@"bspline"]) {
			[newGenomeEntity setValue:@"B-Spline"  forKey:@"spatial_filter_func"];
		} else {
			[newGenomeEntity setValue:[spatial_filter_func capitalizedString]  forKey:@"spatial_filter_func"];		
		}
		
	}

	NSMutableSet *newColours = nil;

	tempAttribute = [genome attributeForName:@"palette"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"palette"];
	    [newGenomeEntity setValue:[NSNumber numberWithBool:YES]  forKey:@"use_palette"];
	} else {
	    [newGenomeEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"use_palette"];		
		newColours = [[NSMutableSet alloc] initWithCapacity:256];
	}
/* deal the flame children */	
	
	NSMutableSet *newTransforms = [[NSMutableSet alloc] initWithCapacity:5];
		
	NSEnumerator *elementEnumerator = [[genome children] objectEnumerator];
	NSXMLElement *child;
	

	double palette[256][3]; 
	double red, green, blue;
	int index;
	
	while ( (child = [elementEnumerator nextObject])) {

		if ([[child name] isEqualToString:@"symmetry"]) {
			
			tempAttribute = [child attributeForName:@"kind"];
			[newGenomeEntity setValue:[Genome getStringSymmetry:[[tempAttribute stringValue] intValue]]  forKey:@"symmetry"];
			
		} else if ([[child name] isEqualToString:@"color"] ) {
			
			NSManagedObject *newColour = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:moc];
			
			index  = [[[child attributeForName:@"index"] stringValue]intValue];
			
			[newColour setValue:[NSNumber numberWithInt:index] forKey:@"index"];
			
			tempString = [[child attributeForName:@"rgb"] stringValue];
			NSArray *split = [tempString componentsSeparatedByString:@" "];

			red =   [[split objectAtIndex:0] doubleValue];
			green = [[split objectAtIndex:1] doubleValue];
			blue =  [[split objectAtIndex:2] doubleValue];
			
			red   /= 255.0;
			green /= 255.0;
			blue  /= 255.0;			
			
			palette[index][0]= red;
			palette[index][1]= green;
			palette[index][2]= blue;
			
			if(red > 1) {
				NSLog(@"colour to big");
			}
			

			[newColour setValue:[NSNumber numberWithDouble:red] forKey:@"red"];
			[newColour setValue:[NSNumber numberWithDouble:green] forKey:@"green"];
			[newColour setValue:[NSNumber numberWithDouble:blue] forKey:@"blue"];
			
			[newColours addObject:newColour];
			[newColour release];  
		} else if ([[child name] isEqualToString:@"xform"] || [[child name] isEqualToString:@"finalxform"]) {

			NSManagedObject *newXformEntity = [Genome createTransformEntitiesFromElement:child inContext:moc]; 
			[newXformEntity setValue:[NSNumber numberWithInt:[newTransforms count]] forKey:@"order"];
			[newTransforms addObject:newXformEntity];
			[newXformEntity release];
		}
	
		
	}
			
	if (newColours != nil) {
		NSImage *colourMapImage = [[NSImage alloc] init];
		NSBitmapImageRep *colourMapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																					  pixelsWide:256
																					  pixelsHigh:15
																				   bitsPerSample:8
																				 samplesPerPixel:3
																						hasAlpha:NO 
																						isPlanar:NO
																				  colorSpaceName:NSDeviceRGBColorSpace
																					bitmapFormat:0
																					 bytesPerRow:3*256
																					bitsPerPixel:24]; 
		[PaletteController fillBitmapRep:colourMapImageRep withPalette:palette[0] forHeight:15]; 
		[colourMapImage addRepresentation:colourMapImageRep];
		
		[newGenomeEntity setValue:colourMapImage forKey: @"colour_map_image"];
		
		
		[colourMapImageRep release];
		[colourMapImage release];
		
	}
	[newGenomeEntity setValue:newColours forKey:@"cmap"];
	[newGenomeEntity setValue:newTransforms forKey:@"xforms"];
	
	[newGenomeEntity autorelease];
	
	return newGenomeEntity;
	
	
}

+ (NSManagedObject *)createTransformEntitiesFromElement:(NSXMLElement *)xform inContext:(NSManagedObjectContext *)moc {
	
	NSManagedObject *xFormEntity;
	
	NSXMLNode *attribute;
	
	NSString *tempString;
		
	xFormEntity = [NSEntityDescription insertNewObjectForEntityForName:@"XForm" inManagedObjectContext:moc];

	attribute = [xform attributeForName:@"weight"];
	if (attribute != nil) {
		[xFormEntity setValue:[NSNumber numberWithDouble:[[attribute stringValue] doubleValue]] forKey:@"density"];
	}
	
	
	
	attribute = [xform attributeForName:@"coefs"];
	if (attribute != nil) {
		tempString = [attribute stringValue];
		NSArray *split = [tempString componentsSeparatedByString:@" "];

		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:0] doubleValue]] forKey:@"coeff_0_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:1] doubleValue]] forKey:@"coeff_0_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:2] doubleValue]] forKey:@"coeff_1_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:3] doubleValue]] forKey:@"coeff_1_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:4] doubleValue]] forKey:@"coeff_2_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:5] doubleValue]] forKey:@"coeff_2_1"];

	}
			
	attribute = [xform attributeForName:@"color"];
	if (attribute != nil) {
		tempString = [attribute stringValue];
		NSArray *split = [tempString componentsSeparatedByString:@" "];
		
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:0] doubleValue]] forKey:@"colour_0"];
		
	}	

	double post[3][2] = {1.0, 0.0, 0.0, 1.0, 0.0, 0.0};

	[xFormEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"post_flag"];

	attribute = [xform attributeForName:@"post"];
	if (attribute != nil) {
		tempString = [attribute stringValue];
		NSArray *split = [tempString componentsSeparatedByString:@" "];
		
		post[0][0] = [[split objectAtIndex:0] doubleValue]; 
		post[0][1] = [[split objectAtIndex:1] doubleValue];
		post[1][0] = [[split objectAtIndex:2] doubleValue];
		post[1][1] = [[split objectAtIndex:3] doubleValue];
		post[2][0] = [[split objectAtIndex:4] doubleValue];
		post[2][1] = [[split objectAtIndex:5] doubleValue];
		
	}			
			
	if ((post[0][0] == 1.0) &&
		(post[0][1] == 0.0) &&
		(post[1][0] == 0.0) &&
		(post[1][1] == 1.0) &&
		(post[2][0] == 0.0) &&
		(post[2][1] == 0.0)) {
		[xFormEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"post_flag"];
	} else {
		[xFormEntity setValue:[NSNumber numberWithBool:YES]  forKey:@"post_flag"];
		
	}
	
	[xFormEntity setValue:[NSNumber numberWithDouble:post[0][0]] forKey:@"post_0_0"];
	[xFormEntity setValue:[NSNumber numberWithDouble:post[0][1]] forKey:@"post_0_1"];
	[xFormEntity setValue:[NSNumber numberWithDouble:post[1][0]] forKey:@"post_1_0"];
	[xFormEntity setValue:[NSNumber numberWithDouble:post[1][1]] forKey:@"post_1_1"];
	[xFormEntity setValue:[NSNumber numberWithDouble:post[2][0]] forKey:@"post_2_0"];
	[xFormEntity setValue:[NSNumber numberWithDouble:post[2][1]] forKey:@"post_2_1"];
	
	
	
	attribute = [xform attributeForName:@"symmetry"];
	if (attribute != nil) {
		[xFormEntity setValue:[NSNumber numberWithDouble:[[attribute stringValue] intValue]] forKey:@"symmetry"];
	}
						
	if([[xform name] isEqualToString:@"finalxform"]) {
		[xFormEntity setValue:[NSNumber numberWithBool:YES] forKey:@"final_xform"];
	} else {
		[xFormEntity setValue:[NSNumber numberWithBool:NO] forKey:@"final_xform"];
	}
			

	[xFormEntity setValue:[Genome createVariationEntitiesFromElement:xform inContext:moc]  forKey:@"variations"];
	
	
	[xFormEntity autorelease];
	
	return xFormEntity;	
	
}

+ (NSMutableSet *)createVariationEntitiesFromElement:(NSXMLElement *)xform inContext:(NSManagedObjectContext *)moc {
	
	/* deal with the far to many ways that variations are defined */
	
	double weight;
	
	NSXMLNode *attribute;
	NSString *variationWeight;
	
	NSMutableSet *variationSet = [[NSMutableSet alloc] initWithCapacity:flam3_nvariations];
	
	attribute = [xform attributeForName:@"var"];
	if (attribute != nil) {
		NSString *tempString = [attribute stringValue];
		NSArray *split = [tempString componentsSeparatedByString:@" "];
		int kind = 0;
		NSEnumerator *variations = [split objectEnumerator];
		while ((variationWeight = [variations nextObject]) && kind < flam3_nvariations) {
			weight = [variationWeight doubleValue];
			NSManagedObject *newVariation = [Genome createVariationEntityFromElement:xform ofVariationType:kind andWeight:weight inContext:moc];
			[variationSet addObject:newVariation];
			kind++;
		}
	} else if ((attribute = [xform attributeForName:@"var1"])) {
		
		int kind = [[attribute stringValue] intValue];
		int i;
		NSManagedObject *newVariation;
		
		for (i = 0; i < flam3_nvariations; i++) {
			if (kind == i) {
				newVariation = [Genome createVariationEntityFromElement:xform
														 ofVariationType:i 
															   andWeight:1.0 
															   inContext:moc];
			} else {
				newVariation = [Genome createVariationEntityFromElement:xform
														 ofVariationType:i 
															   andWeight:0.0 
															   inContext:moc];
			}
			[variationSet addObject:newVariation];
		}

	} else {
		
		int i;
		NSManagedObject *newVariation;
		for (i = 0; i < flam3_nvariations; i++) {
			
			if ((attribute = [xform attributeForName:variationName[i]])) {
				newVariation = [Genome createVariationEntityFromElement:xform
														 ofVariationType:i
															   andWeight:[[attribute stringValue] doubleValue]  
															   inContext:moc];
			} else {
				newVariation = [Genome createVariationEntityFromElement:xform
													 ofVariationType:i 
														   andWeight:0.0 
														   inContext:moc];
			}
			[variationSet addObject:newVariation];
		}

		
	}

	
	return variationSet;
	
}

+ (NSManagedObject *)createVariationEntityFromElement:(NSXMLElement *)xform ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)moc {
	
	NSManagedObject *variation = [NSEntityDescription insertNewObjectForEntityForName:@"Variations" inManagedObjectContext:moc];
	
	[variation setValue:variationName[kind] forKey:@"name"]; 
	[variation setValue:[NSNumber numberWithInt:kind] forKey:@"variation_index"];
	
	if(weight != 0.0) {
		[variation setValue:[NSNumber numberWithBool:YES] forKey:@"in_use"];
	} else {
		[variation setValue:[NSNumber numberWithBool:NO] forKey:@"in_use"];
	}
	[variation setValue:[NSNumber numberWithDouble:weight] forKey:@"weight"];					

	switch(kind) {
		case 23:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"blob_high"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"blob_high"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"blob_wave"] stringValue] doubleValue]] 
						 forKey:@"parameter_3"];
			

			[variation setValue:@"Blob High:" forKey:@"parameter_1_name"];
			[variation setValue:@"Blob Low:" forKey:@"parameter_2_name"];
			[variation setValue:@"Blob Wave:" forKey:@"parameter_3_name"];
			break;
		case 24:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"pdj_a"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"pdj_b"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"pdj_c"] stringValue] doubleValue]] 
						 forKey:@"parameter_3"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"pdj_d"] stringValue] doubleValue]] 
						 forKey:@"parameter_4"];	
			
			[variation setValue:@"PDJ A:" forKey:@"parameter_1_name"];
			[variation setValue:@"PDJ B:" forKey:@"parameter_2_name"];
			[variation setValue:@"PDJ C:" forKey:@"parameter_3_name"];
			[variation setValue:@"PDJ D:" forKey:@"parameter_4_name"];
			
			break;
		case 25:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"fan2_x"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"fan2_y"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			
			
			[variation setValue:@"Fan2 x:" forKey:@"parameter_1_name"];
			[variation setValue:@"Fan2 y:" forKey:@"parameter_2_name"];
			
			break;				
		case 26:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"rings2_val"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
		
			
			[variation setValue:@"Rings2:" forKey:@"parameter_1_name"];
			
			break;
		case 30:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"perspective_angle"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"perspective_dist"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			
			
			[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
			[variation setValue:@"Distance:" forKey:@"parameter_2_name"];
			
			break;
		case 32:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"julian_dist"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"julian_power"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			
			
			[variation setValue:@"Distance:" forKey:@"parameter_1_name"];
			[variation setValue:@"Power:" forKey:@"parameter_2_name"];
			
			break;
		case 33:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"juliascope_dist"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"juliascope_power"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			
			
			[variation setValue:@"JS Distance:" forKey:@"parameter_1_name"];
			[variation setValue:@"Power:" forKey:@"parameter_2_name"];
			
			break;
		case 36:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			
			[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"radial_blur_angle"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			
			break;	
		case 37:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
			
			[variation setValue:@"Slices:" forKey:@"parameter_1_name"];
			[variation setValue:@"Rotation:" forKey:@"parameter_2_name"];
			[variation setValue:@"Thickness:" forKey:@"parameter_3_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"pie_slices"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"pie_rotation"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"pie_thickness"] stringValue] doubleValue]] 
						 forKey:@"parameter_3"];
				
			break;	
		case 38:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];
			
			[variation setValue:@"Sides:" forKey:@"parameter_1_name"];
			[variation setValue:@"Power:" forKey:@"parameter_2_name"];
			[variation setValue:@"Circle:" forKey:@"parameter_3_name"];
			[variation setValue:@"Corners:" forKey:@"parameter_4_name"];

			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"ngon_sides"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"ngon_power"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"ngon_circle"] stringValue] doubleValue]] 
						 forKey:@"parameter_3"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"ngon_corners"] stringValue] doubleValue]] 
						 forKey:@"parameter_4"];
			
		
			break;	
		case 39:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"c1:" forKey:@"parameter_1_name"];
			[variation setValue:@"c2:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"curl_c1"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"curl_c2"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			
			break;	
		case 40:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"x:" forKey:@"parameter_1_name"];
			[variation setValue:@"y:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"rectangles_x"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"rectangles_y"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			
			break;	
		case 49:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"Rotation:" forKey:@"parameter_1_name"];
			[variation setValue:@"Twist:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"disc2_rot"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"disc2_twist"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			break;	
		case 50:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_5"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_6"];

			[variation setValue:@"Random:" forKey:@"parameter_1_name"];
			[variation setValue:@"M:" forKey:@"parameter_2_name"];
			[variation setValue:@"N1:" forKey:@"parameter_3_name"];
			[variation setValue:@"N2:" forKey:@"parameter_4_name"];
			[variation setValue:@"N3:" forKey:@"parameter_5_name"];
			[variation setValue:@"Holes:" forKey:@"parameter_6_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"super_shape_rnd"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"super_shape_m"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"super_shape_n1"] stringValue] doubleValue]] 
						 forKey:@"parameter_3"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"super_shape_n2"] stringValue] doubleValue]] 
						 forKey:@"parameter_4"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"super_shape_n3"] stringValue] doubleValue]] 
						 forKey:@"parameter_5"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"super_shape_holes"] stringValue] doubleValue]] 
						 forKey:@"parameter_6"];
			
			break;	
		case 51:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"Petals:" forKey:@"parameter_1_name"];
			[variation setValue:@"Holes:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"flower_petals"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"flower_holes"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			break;	
		case 52:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"Eccentricity:" forKey:@"parameter_1_name"];
			[variation setValue:@"Holes:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"conic_eccentricity"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"conic_holes"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			break;	
		case 53:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"Height:" forKey:@"parameter_1_name"];
			[variation setValue:@"Width:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"parabola_height"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"parabola_width"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			break;	
		case 54:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"X Size:" forKey:@"parameter_1_name"];
			[variation setValue:@"Y Size:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"split_xsize"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"split_ysize"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			break;	
		case 55:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			
			[variation setValue:@"Move X:" forKey:@"parameter_1_name"];
			[variation setValue:@"Move Y:" forKey:@"parameter_2_name"];
			
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"move_x"] stringValue] doubleValue]] 
						 forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"move_y"] stringValue] doubleValue]] 
						 forKey:@"parameter_2"];
			break;	
		default:
			break;
	}

	[variation autorelease];
	
	return variation;
}

+ (int) getIntSymmetry:(NSString *)value {
	
	NSScanner *scanner;
	int tmpValue;
	
	if([value compare:@"No Symmetry"] == NSOrderedSame) {
		
		return 1;
	}
	
	if([value compare:@"Dihedral Symmetry"] ==  NSOrderedSame) {
		
		return -1;
		
	}
	
	
	if([value compare:@"Random"] ==  NSOrderedSame) {
		
		return 0;
	}
	
	scanner = [NSScanner scannerWithString:value];
	if([scanner scanInt:&tmpValue]) {
		
		return tmpValue;
		
	}
	
	return 1;
}


+ (NSString *) getStringSymmetry:(int)value {
	
	switch(value) {
		case 1:
			return @"No Symmetry";
			break;
		case -1:
			return @"Dihedral Symmetry";
			break;
		case 0:
			return @"Random";
			break;
		default:
			return [NSString stringWithFormat:@"%ld", value];	
			break;
	}
}

+ (NSManagedObject *)createDefaultGenomeEntityFromInContext:(NSManagedObjectContext *)moc {
	
	NSManagedObject *genomeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Genome" inManagedObjectContext:moc];
	
	NSImage *paletteImage = [[NSImage alloc] init];
	NSBitmapImageRep *paletteWithHueRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																				  pixelsWide:256
																				  pixelsHigh:10
																			   bitsPerSample:8
																			 samplesPerPixel:3
																					hasAlpha:NO 
																					isPlanar:NO
																			  colorSpaceName:NSDeviceRGBColorSpace
																				bitmapFormat:0
																				 bytesPerRow:3*256
																				bitsPerPixel:24]; 
	[PaletteController fillBitmapRep:paletteWithHueRep withPalette:1 usingHue:0.0];
	[paletteImage addRepresentation:paletteWithHueRep];
	
	[genomeEntity setValue:paletteImage forKey: @"palette_image"];
	
	
	[paletteWithHueRep release];
	[paletteImage release];
	
	[genomeEntity setValue:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0] forKey: @"background"];
	
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	
	[genomeEntity setValue:[defaults stringForKey:@"nick"] forKey:@"nick"];
	[genomeEntity setValue:[defaults stringForKey:@"url"] forKey:@"url"];
	[genomeEntity setValue:[defaults stringForKey:@"comment"] forKey:@"comment"];
	
	
//	[genomeEntity setValue:[Genome createDefaultXFormEntitySetInContext:moc] forKey: @"xforms"];
	
	return genomeEntity;
	
}

+ (NSMutableSet *)createDefaultXFormEntitySetInContext:(NSManagedObjectContext *)moc {
	
	NSManagedObject *xformEntity = [NSEntityDescription insertNewObjectForEntityForName:@"XForm" inManagedObjectContext:moc];
	[xformEntity setValue:[Genome createDefaultVariationsEntitySetInContext:moc] forKey:@"variations"];
	return [NSMutableSet setWithObject:xformEntity];
	
}

+ (NSMutableSet *)createDefaultVariationsEntitySetInContext:(NSManagedObjectContext *)moc {
	
	int j;
	
	NSManagedObject *variation;
	NSMutableSet *variations = [[NSMutableSet alloc] initWithCapacity:flam3_nvariations];

	variation = [Genome createVariationEntityFromElement:nil 
										 ofVariationType:0 andWeight:1.0 inContext:moc];	

	[variations addObject:variation];
	[variation release];
		
	for(j=1; j<flam3_nvariations; j++) {
		
		variation = [Genome createVariationEntityFromElement:nil 
											 ofVariationType:j 
												   andWeight:0.0 
												   inContext:moc];	
		
		[variations addObject:variation];
		[variation release];
	
	}		
			
	[variations autorelease];
	return variations;
} 


+ (NSMutableDictionary *)createDictionaryFromGenomeEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc {
	
	NSMutableDictionary *genome = [NSMutableDictionary  dictionaryWithCapacity:20];
	
	NSArray *cmaps;
	NSArray *sortDescriptors;
	NSArray *xforms; 
	
	NSFetchRequest *fetch;
	NSPredicate *predicate;						 
	NSSortDescriptor *sort;
	NSString *tempString;
	
	float red, green, blue;
	int i;
	
	
	tempString = [genomeEntity valueForKey:@"name"];
	if(tempString != nil) {
		[genome setObject:tempString forKey:@"name"];
	} else {
		[genome setObject:@"" forKey:@"name"];
	}

	[genome setObject:[genomeEntity valueForKey:@"time"] forKey:@"time"];
	[genome setObject:[genomeEntity valueForKey:@"width"] forKey:@"width"];
	[genome setObject:[genomeEntity valueForKey:@"height"] forKey:@"height"];
	[genome setObject:[genomeEntity valueForKey:@"zoom"] forKey:@"zoom"];
	[genome setObject:[genomeEntity valueForKey:@"oversample"] forKey:@"oversample"];
	[genome setObject:[genomeEntity valueForKey:@"quality"] forKey:@"quality"];
	[genome setObject:[genomeEntity valueForKey:@"batches"] forKey:@"passes"];
	[genome setObject:[genomeEntity valueForKey:@"jitter"] forKey:@"temporal_samples"];
	[genome setObject:[genomeEntity valueForKey:@"de_max_filter"] forKey:@"estimator_radius"];
	[genome setObject:[genomeEntity valueForKey:@"de_min_filter"] forKey:@"estimator_minimum"];
	[genome setObject:[genomeEntity valueForKey:@"de_alpha"] forKey:@"estimator_curve"];
	[genome setObject:[genomeEntity valueForKey:@"gamma"] forKey:@"gamma"];
	[genome setObject:[genomeEntity valueForKey:@"gamma_threshold"] forKey:@"gamma_threshold"];		

	
	[[genomeEntity valueForKey:@"background"] getRed:&red green:&green blue:&blue alpha:NULL];

	NSMutableDictionary *background = [NSMutableDictionary dictionaryWithCapacity:3];
	
	[background setObject:[NSNumber numberWithInt:(int)(red * 255)] forKey:@"red"];		
	[background setObject:[NSNumber numberWithInt:(int)(green * 255)] forKey:@"green"];		
	[background setObject:[NSNumber numberWithInt:(int)(blue * 255)] forKey:@"blue"];
	
	[genome setObject:background forKey:@"background"];		

	[genome setObject:[genomeEntity valueForKey:@"hue"] forKey:@"hue"];
	[genome setObject:[genomeEntity valueForKey:@"vibrancy"] forKey:@"vibrancy"];
	[genome setObject:[genomeEntity valueForKey:@"brightness"] forKey:@"brightness"];
	[genome setObject:[genomeEntity valueForKey:@"rotate"] forKey:@"rotate"];
	[genome setObject:[genomeEntity valueForKey:@"contrast"] forKey:@"contrast"];

	[genome setObject:[genomeEntity valueForKey:@"symmetry"] forKey:@"symmetry"];

	[genome setObject:[genomeEntity valueForKey:@"interpolation"] forKey:@"interpolation"];
	[genome setObject:[genomeEntity valueForKey:@"motion_exp"] forKey:@"motion_exponent"];
	[genome setObject:[genomeEntity valueForKey:@"spatial_filter_radius"] forKey:@"filter"];
	
	if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"B-Spline"]) {
		[genome setObject:@"bspline" forKey:@"filter_shape"];
	} else {
		[genome setObject:[[genomeEntity valueForKey:@"spatial_filter_func"] lowercaseString] forKey:@"filter_shape"];
	}

/*	
	[Genome createXMLForEditElement:genome usingEntity:genomeEntity];
	
	
	if([[genomeEntity valueForKey:@"use_palette"] boolValue] == FALSE) {
		
		predicate = [NSPredicate predicateWithFormat:@"parent_genome == %@", genomeEntity];
							 
		sort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
		sortDescriptors = [NSArray arrayWithObject: sort];
		
		fetch = [[NSFetchRequest alloc] init];
		[fetch setEntity:[NSEntityDescription entityForName:@"CMap" inManagedObjectContext:moc]];
		[fetch setPredicate: predicate];
		[fetch setSortDescriptors: sortDescriptors];
		
		cmaps = [moc executeFetchRequest:fetch error:nil];
		[sort release];
		[fetch release];	
	//	 use the cmap 
		if([cmaps count] < 256) {
			NSMutableArray *newCmaps = [PaletteController extrapolateArray:cmaps];
			[newCmaps retain];
			[Genome createXMLForCMap:newCmaps forElement:genome];
			[newCmaps release];
		} else {
			[Genome createXMLForCMap:cmaps forElement:genome];
		}
	} else {
		[genome addAttribute:[NSXMLNode attributeWithName:@"palette" stringValue:[[genomeEntity valueForKey:@"palette"] stringValue]]];
	}
	
	
	// xforms 
	
	predicate = [NSPredicate predicateWithFormat:@"parent_genome == %@", genomeEntity];
	
	sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	sortDescriptors = [NSArray arrayWithObject: sort];
	
	fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"XForm" inManagedObjectContext:moc]];
	[fetch setPredicate: predicate];
	[fetch setSortDescriptors: sortDescriptors];
	
	xforms = [moc executeFetchRequest:fetch error:nil];
	[sort release];
	[fetch release];
	
	int old_num_xforms = [xforms count];
	
	for(i=0; i < old_num_xforms; i++) {
		
		[genome addChild:[Genome createXMLForXFormFromEntity:[xforms objectAtIndex:i] fromContext:moc]];
		if([[[xforms objectAtIndex:i] valueForKey:@"final_xform"] boolValue] == YES) {
			//			newGenome->final_xform_index = i+newGenome->num_xforms;
		}
		
	}
	
*/	
	
	return genome;
	
}

@end

