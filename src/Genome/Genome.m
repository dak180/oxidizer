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
#import "GenomeXMLParser.h"

#define flam3_nvariations 54

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
	@"secant2",
	@"twintrian",
	@"cross",
	@"disc2",
	@"super_shape",
	@"flower",
	@"conic",
	@"parabola"
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

	return [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint|NSXMLNodeCompactEmptyElement];

}




+ (NSXMLNode *)createXMLFromGenomeEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc forThumbnail:(BOOL)thumbnail {

	NSDate *start = [NSDate date];

	NSXMLElement *genome = [NSXMLElement elementWithName:@"flame"];

	NSArray *cmaps;
	NSArray *sortDescriptors;
	NSArray *xforms;

	NSSortDescriptor *sort;
	NSString *tempString;

	CGFloat red, green, blue;
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

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		int realWidth  = [[genomeEntity valueForKey:@"width"] intValue];
		int realHeight = [[genomeEntity valueForKey:@"height"] intValue];
		double realScale =  [[genomeEntity valueForKey:@"scale"] doubleValue];

		double scaleFactor = realHeight > realWidth ? [defaults doubleForKey:@"preview_size"] / realHeight : [defaults doubleForKey:@"preview_size"] / realWidth;

		[genome addAttribute:[NSXMLNode attributeWithName:@"size"
											  stringValue:[NSString stringWithFormat:@"%d %d",
												 (int)(realWidth * scaleFactor),
												 (int)(realHeight * scaleFactor)]]];

		[genome addAttribute:[NSXMLNode attributeWithName:@"scale"
										stringValue:[NSString stringWithFormat:@"%0.7f", (realScale * scaleFactor)]]];


		if([defaults boolForKey:@"limit_quality"]) {
			double maxQuality =  [defaults doubleForKey:@"preview_quality"];
			double zoom = [[genomeEntity valueForKey:@"zoom"] doubleValue];
			double actualQuality = [[genomeEntity valueForKey:@"quality"] doubleValue];
			double quality ;
			if (zoom > 0.0) {
				zoom = pow(2.0, zoom);
				zoom *= zoom;
				actualQuality *= zoom;
				if (actualQuality <= maxQuality) {
					quality = actualQuality;
				} else {
					quality = maxQuality / zoom;
				}
			} else {
				quality = actualQuality > maxQuality ? maxQuality : actualQuality;
			}

			[genome addAttribute:[NSXMLNode attributeWithName:@"quality" stringValue:[NSString stringWithFormat:@"%0.7f",quality]]];
		} else {
			[genome addAttribute:[NSXMLNode attributeWithName:@"quality" stringValue:[[genomeEntity valueForKey:@"quality"] stringValue]]];
		}


	} else {
		[genome addAttribute:[NSXMLNode attributeWithName:@"size"
											  stringValue:[NSString stringWithFormat:@"%d %d",
												  [[genomeEntity valueForKey:@"width"] intValue],
												  [[genomeEntity valueForKey:@"height"] intValue]]]];

		[genome addAttribute:[NSXMLNode attributeWithName:@"scale" stringValue:[[genomeEntity valueForKey:@"scale"] stringValue]]];


		[genome addAttribute:[NSXMLNode attributeWithName:@"quality" stringValue:[[genomeEntity valueForKey:@"quality"] stringValue]]];


	}

	if ([[genomeEntity valueForKey:@"zoom"] doubleValue] != 0.0) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"zoom" stringValue:[[genomeEntity valueForKey:@"zoom"] stringValue]]];
	}

	[genome addAttribute:[NSXMLNode attributeWithName:@"center"
									stringValue:[NSString stringWithFormat:@"%0.7f %0.7f",
										[[genomeEntity valueForKey:@"centre_x"] doubleValue],
										[[genomeEntity valueForKey:@"centre_y"] doubleValue]]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"supersample" stringValue:[[genomeEntity valueForKey:@"oversample"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"passes" stringValue:[[genomeEntity valueForKey:@"batches"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_samples" stringValue:[[genomeEntity valueForKey:@"jitter"] stringValue]]];

	NSString *filter = [genomeEntity valueForKey:@"temporal_filter_type"];
	if([filter isEqualToString:@"Box"]) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_filter_type" stringValue:@"box"]];
		[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_filter_width" stringValue:[[genomeEntity valueForKey:@"temporal_filter_width"] stringValue]]];
	} else if([filter isEqualToString:@"Gaussian"]) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_filter_width" stringValue:[[genomeEntity valueForKey:@"temporal_filter_width"] stringValue]]];
		[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_filter_type" stringValue:@"gaussian"]];
	} else if([filter isEqualToString:@"Exponent"]) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_filter_type" stringValue:@"exp"]];
		[genome addAttribute:[NSXMLNode attributeWithName:@"temporal_filter_exp" stringValue:[[genomeEntity valueForKey:@"temporal_filter_exp"] stringValue]]];
	}


	[genome addAttribute:[NSXMLNode attributeWithName:@"estimator_radius" stringValue:[[genomeEntity valueForKey:@"de_max_filter"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"estimator_minimum" stringValue:[[genomeEntity valueForKey:@"de_min_filter"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"estimator_curve" stringValue:[[genomeEntity valueForKey:@"de_alpha"] stringValue]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"gamma" stringValue:[[genomeEntity valueForKey:@"gamma"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"gamma_threshold" stringValue:[[genomeEntity valueForKey:@"gamma_threshold"] stringValue]]];

	NSColor *bc = [genomeEntity valueForKey:@"background"];
	NSColor *sc = [bc colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"];
	[sc getRed:&red green:&green blue:&blue alpha:NULL];

	[genome addAttribute:[NSXMLNode attributeWithName:@"background"
										  stringValue:[NSString stringWithFormat:@"%g %g %g", red , green, blue]]];


	[genome addAttribute:[NSXMLNode attributeWithName:@"hue" stringValue:[[genomeEntity valueForKey:@"hue"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"vibrancy" stringValue:[[genomeEntity valueForKey:@"vibrancy"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"brightness" stringValue:[[genomeEntity valueForKey:@"brightness"] stringValue]]];

	[genome addAttribute:[NSXMLNode attributeWithName:@"rotate" stringValue:[[genomeEntity valueForKey:@"rotate"] stringValue]]];
	[genome addAttribute:[NSXMLNode attributeWithName:@"contrast" stringValue:[[genomeEntity valueForKey:@"contrast"] stringValue]]];

	if ( [Genome getIntSymmetry:[genomeEntity valueForKey:@"symmetry"]] != 0) {
		NSXMLElement *symmetryElement = (NSXMLElement *)[NSXMLNode elementWithName:@"symmetry"];
		[symmetryElement addAttribute:[NSXMLNode attributeWithName:@"kind"
													   stringValue:[NSString stringWithFormat:@"%d",  [Genome getIntSymmetry:[genomeEntity valueForKey:@"symmetry"]]]]];
		[genome addChild:symmetryElement];
	}


	if([[genomeEntity valueForKey:@"interpolation"] intValue] == 1) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"interpolation" stringValue:@"smooth"]];
	}

	NSString *interpolation = [genomeEntity valueForKey:@"interpolation_type"];
	[genome addAttribute:[NSXMLNode attributeWithName:@"interpolation_type" stringValue:[interpolation lowercaseString]]];


//	if ([[genomeEntity valueForKey:@"motion_exp"] doubleValue] != 0.0) {
//		[genome addAttribute:[NSXMLNode attributeWithName:@"motion_exponent" stringValue:[[genomeEntity valueForKey:@"motion_exp"] stringValue]]];
//	}

	[genome addAttribute:[NSXMLNode attributeWithName:@"filter" stringValue:[[genomeEntity valueForKey:@"spatial_filter_radius"] stringValue]]];

	if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"B-Spline"]) {
		[genome addAttribute:[NSXMLNode attributeWithName:@"filter_shape" stringValue:@"bspline"]];
	} else {
		[genome addAttribute:[NSXMLNode attributeWithName:@"filter_shape" stringValue:[[genomeEntity valueForKey:@"spatial_filter_func"] lowercaseString]]];
	}

	[Genome createXMLForEditElement:genome usingEntity:genomeEntity];


	if([[genomeEntity valueForKey:@"use_palette"] boolValue] == FALSE) {

		sort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
		sortDescriptors = [NSArray arrayWithObject: sort];

		cmaps = [[[genomeEntity valueForKey:@"cmap"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];

		/* use the cmap */

		NSMutableArray *newCmaps = [PaletteController extrapolateArray:cmaps];
		[newCmaps retain];
		[Genome createXMLForCMap:newCmaps forElement:genome];
		[newCmaps release];
		[sort release];


	} else {
		[genome addAttribute:[NSXMLNode attributeWithName:@"palette" stringValue:[[[genomeEntity valueForKey:@"images"]  valueForKey:@"palette"] stringValue]]];
	}

	[genome addAttribute:[NSXMLNode attributeWithName:@"palette_mode" stringValue:[[genomeEntity valueForKey:@"palette_mode"] lowercaseString]]];

	/* xforms */


	sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	sortDescriptors = [NSArray arrayWithObject: sort];

	xforms = [[[genomeEntity valueForKey:@"xforms"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];

	[sort release];

	int old_num_xforms = [xforms count];

	for(i=0; i < old_num_xforms; i++) {

		[genome addChild:[Genome createXMLForXFormFromEntity:[xforms objectAtIndex:i] fromContext:moc]];

	}


	NSLog (@"genome time: %ld", [start timeIntervalSinceNow]);

	return genome;

}

+ (NSXMLNode *)createXMLForXFormFromEntity:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc {


	NSXMLElement *xform;

	if([[xformEntity valueForKey:@"final_xform"] boolValue] == YES) {

		xform = [NSXMLElement elementWithName:@"finalxform"];

	} else {

		xform = [NSXMLElement elementWithName:@"xform"];
		[xform addAttribute:[NSXMLNode attributeWithName:@"weight" stringValue:[[xformEntity valueForKey:@"density"] stringValue]]];

	}



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
/*
	NSPredicate * predicate;
	//	predicate = [NSPredicate predicateWithFormat:@"parent_xform.order == %ul", [[xformEntity valueForKey:@"order"] intValue]];
	predicate = [NSPredicate predicateWithFormat:@"parent_xform == %@", xformEntity];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"variation_index" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Variations" inManagedObjectContext:moc]];
	[fetch setPredicate: predicate];
	[fetch setSortDescriptors: sortDescriptors];

	NSError*	err	= [[NSError alloc] init];

	variations = [moc executeFetchRequest:fetch error:&err];
	[sort release];
	[fetch release];

	[err release];
*/
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"variation_index" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];

	variations = [[[xformEntity valueForKey:@"variations"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];

	[sort release];

	unsigned int i;

	NSManagedObject *variation;

	for(i=0; i<[variations count]; i++) {
		variation = [variations objectAtIndex:i];

		if([[variation valueForKey:@"in_use"] boolValue] == YES) {

			[xform addAttribute:[NSXMLNode attributeWithName:variationName[i] stringValue:[[variation valueForKey:@"weight"] stringValue]]];

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
				default:
					break;
			}

		}


	}

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

			if ([[colour valueForKey:@"red"]   intValue] > 255 || [[colour valueForKey:@"red"]   intValue] < 0) {
				NSLog(@"colour failed");
			}


			[colourElement addAttribute:[NSXMLNode attributeWithName:@"rgb"
														 stringValue:[NSString stringWithFormat:@"%d %d %d",
															 [[colour valueForKey:@"red"]   intValue],
															 [[colour valueForKey:@"green"]   intValue],
															 [[colour valueForKey:@"blue"]   intValue]]]];


			[genome addChild:colourElement];

	}

}



+ (void) createXMLForEditElement:(NSXMLElement *)genomeElement usingEntity:(NSManagedObject *)genome {

	NSXMLElement *newEditElement;
	NSXMLElement *oldRootElement;

	NSError *xmlError;

	NSString *date;
	NSMutableString *oldDocAsXML;

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


	if([xmlValue string] != nil && [[xmlValue string] compare:@""] != NSOrderedSame) {

		oldDocAsXML = [NSString stringWithFormat:@"%@%@%@", @"<dummy>", [xmlValue string], @"</dummy>"];

		NSXMLElement *oldEdits = [[NSXMLElement alloc] initWithXMLString:oldDocAsXML error:&xmlError];

		if(oldEdits == nil) {
			NSLog(@"%@\n", [xmlError localizedDescription]);
			[xmlError release];
		}

		int i, childCount = [oldEdits childCount];;

		for(i=0; i<childCount; i++) {
			oldRootElement = (NSXMLElement *)[oldEdits childAtIndex:0];
			[oldRootElement detach];
			[newEditElement addChild:oldRootElement];

		}

		[oldEdits release];

	}

	[genomeElement addChild:newEditElement];
	[newEditElement release];
	return;
}


+ (NSArray *)createGenomeEntitiesFromFile:(NSString *)xmlFileName inContext:(NSManagedObjectContext *)moc {

    NSURL *xmlURL = [NSURL fileURLWithPath:xmlFileName];
    NSXMLParser *newParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	GenomeXMLParser *gxp = [[GenomeXMLParser alloc] init];

	[newParser setDelegate:gxp];
	[gxp setManangedObjectContext:moc];
	[newParser parse]; // return value not used

	NSArray *newGenomes = [gxp getGenomes];
	[newGenomes retain];

	[gxp release];
	[newParser release];

	return [newGenomes autorelease];
}

+ (NSArray *)createGenomeEntitiesFromXML:(NSData *)xml inContext:(NSManagedObjectContext *)moc {

	NSArray *flameElements;
	NSMutableArray *genomes = [[NSMutableArray alloc] initWithCapacity:5];

	NSError *error;

//	NSLog(@"%@", @"called createGenomeEntitiesFromXML");
//	NSLog(@"%@", [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding]);


	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:xml options:0 error:&error];

	NSXMLElement *root = [doc rootElement];
	NSXMLElement *flameElement;



	if ([[root name] isEqualToString:@"flame"]) {
		flameElements = [NSArray arrayWithObject:root];
	} else {
		flameElements = [root elementsForName:@"flame"];
	}


	NSEnumerator *flameEnumerator = [flameElements objectEnumerator];


	NSManagedObject *genome;

	while ((flameElement = [flameEnumerator nextObject])) {
		genome = [Genome createGenomeEntitiesFromElement:flameElement inContext:moc];
		[genomes addObject:genome];
	}

	[doc release];

	[genomes autorelease];
	return genomes;
}


+ (NSManagedObject *)createGenomeEntitiesFromElement:(NSXMLElement *)genome inContext:(NSManagedObjectContext *)moc {

	NSManagedObject *newGenomeEntity = [Genome createDefaultGenomeEntityInContext:moc];
	NSManagedObject *newGenomeImageEntity = [Genome createDefaultGenomeImageEntityInContext:moc];

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
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"order"];
	}

	tempAttribute = [genome attributeForName:@"size"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithBool:NO] forKey:@"aspect_lock"];
		NSArray *split = [[tempAttribute stringValue] componentsSeparatedByString:@" "];
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[split objectAtIndex:0] intValue]] forKey:@"width"];
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[split objectAtIndex:1] intValue]] forKey:@"height"];
	    [newGenomeEntity setValue:[NSNumber numberWithBool:YES] forKey:@"aspect_lock"];
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

	/* another changed attribute */
	tempAttribute = [genome attributeForName:@"supersample"];
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


	tempAttribute = [genome attributeForName:@"temporal_filter_type"];
	if(tempAttribute != nil) {
		if([[tempAttribute stringValue] isEqualToString:@"box"]) {
			[newGenomeEntity setValue:@"Box"  forKey:@"temporal_filter_type"];
		} else if([[tempAttribute stringValue] isEqualToString:@"gaussian"]) {
			[newGenomeEntity setValue:@"Gaussian"  forKey:@"temporal_filter_type"];
		} else if([[tempAttribute stringValue] isEqualToString:@"exp"]) {
			[newGenomeEntity setValue:@"Exponent"  forKey:@"temporal_filter_type"];
		}
	}

	tempAttribute = [genome attributeForName:@"temporal_filter_width"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"temporal_filter_width"];
	}

	tempAttribute = [genome attributeForName:@"temporal_filter_exp"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"temporal_filter_exp"];
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
//		red   /= 255;
//		green /= 255;
//		blue  /= 255;

		[newGenomeEntity setValue:[NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0] forKey:@"background"];

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


	tempAttribute = [genome attributeForName:@"interpolation_type"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[[tempAttribute stringValue] capitalizedString] forKey:@"interpolation_type"];
	} else


	tempAttribute = [genome attributeForName:@"motion_exponent"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"temporal_filter_exp"];
		[newGenomeEntity setValue:@"Exponent"  forKey:@"temporal_filter_type"];
		[newGenomeEntity setValue:[NSNumber numberWithDouble:1.0] forKey:@"temporal_filter_width"];
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
	    [newGenomeImageEntity setValue:[NSNumber numberWithInt:[[tempAttribute stringValue] intValue]]  forKey:@"palette"];
	    [newGenomeEntity setValue:[NSNumber numberWithBool:YES]  forKey:@"use_palette"];
	} else {
	    [newGenomeEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"use_palette"];
		newColours = [[NSMutableSet alloc] initWithCapacity:256];
	}

	tempAttribute = [genome attributeForName:@"hue"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[tempAttribute stringValue] doubleValue]] forKey:@"hue"];
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
			[newXformEntity setValue:[NSNumber numberWithInt:[newTransforms count]+1] forKey:@"order"];
			[newTransforms addObject:newXformEntity];
			[newXformEntity release];
		} else if([[child name] isEqualToString:@"edit"]) {

			[newGenomeEntity setValue:[[child attributeForName:@"nick"] stringValue] forKey:@"nick"];
			[newGenomeEntity setValue:[[child attributeForName:@"url"] stringValue] forKey:@"url"];
			[newGenomeEntity setValue:[[child attributeForName:@"comm"] stringValue] forKey:@"comment"];

			if([child childCount] > 0) {

				NSEnumerator *childEnumerator = [[child children] objectEnumerator];
				NSXMLElement *editChild;

				NSMutableString *previousEdits = [NSMutableString stringWithCapacity:1];
				while(editChild = [childEnumerator nextObject]) {
					[previousEdits appendString:[editChild XMLStringWithOptions:NSXMLNodePrettyPrint|NSXMLNodeCompactEmptyElement]];
				}

				NSAttributedString *edits = [[NSAttributedString alloc] initWithString:previousEdits];
				[newGenomeEntity setValue:edits forKey:@"edits"];
				[edits release];

			} else {

				NSAttributedString *edits = [[NSAttributedString alloc] initWithString:@""];
				[newGenomeEntity setValue:edits forKey:@"edits"];
				[edits release];
			}

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

		[newGenomeImageEntity setValue:colourMapImage forKey: @"colour_map_image"];


		[colourMapImageRep release];
		[colourMapImage release];

	}
	[newGenomeEntity setValue:newColours forKey:@"cmap"];
	[newGenomeEntity setValue:newTransforms forKey:@"xforms"];
	[newGenomeEntity setValue:newGenomeImageEntity forKey:@"images"];

	if(newColours != nil) {
		[newColours release];
	}

	tempAttribute = [genome attributeForName:@"palette_mode"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[[tempAttribute stringValue] capitalizedString] forKey:@"palette_mode"];
	}

	[newTransforms release];
	[newGenomeEntity release];

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
		[xFormEntity setValue:[NSNumber numberWithDouble:[[attribute stringValue] doubleValue]] forKey:@"symmetry"];
	}

	if([[xform name] isEqualToString:@"finalxform"]) {
		[xFormEntity setValue:[NSNumber numberWithBool:YES] forKey:@"final_xform"];
	} else {
		[xFormEntity setValue:[NSNumber numberWithBool:NO] forKey:@"final_xform"];
	}


	[xFormEntity setValue:[Genome createVariationEntitiesFromElement:xform inContext:moc]  forKey:@"variations"];

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

	[variationSet autorelease];
	return variationSet;

}

+ (NSManagedObject *)createVariationEntityFromElement:(NSXMLElement *)xform ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)moc {

	[xform retain];
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
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"blob_low"] stringValue] doubleValue]]
						 forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[[xform attributeForName:@"blob_waves"] stringValue] doubleValue]]
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
		default:
			break;
	}

	[xform release];

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

		NSLog(@"String %@ converted too %d", value, tmpValue);

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
			NSLog(@"int %d converted too %@", value, [NSString stringWithFormat:@"%d", value]);

			return [NSString stringWithFormat:@"%d", value];
			break;
	}
}

+ (NSManagedObject *)createDefaultGenomeImageEntityInContext:(NSManagedObjectContext *)moc {

	NSManagedObject *genomeImageEntity = [NSEntityDescription insertNewObjectForEntityForName:@"GenomeImages" inManagedObjectContext:moc];

	NSImage *paletteImage = [[NSImage alloc] init];
	NSBitmapImageRep *paletteWithHueRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
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
	[PaletteController fillBitmapRep:paletteWithHueRep withPalette:1 usingHue:0.0 forHeight:15];
	[paletteImage addRepresentation:paletteWithHueRep];

	[genomeImageEntity setValue:paletteImage forKey: @"palette_image"];
	[genomeImageEntity setValue:paletteImage forKey: @"palette_image"];

	[paletteWithHueRep release];
	[paletteImage release];

	return genomeImageEntity;
}

+ (NSManagedObject *)createDefaultGenomeEntityInContext:(NSManagedObjectContext *)moc {

	NSManagedObject *genomeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Genome" inManagedObjectContext:moc];


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

	for(j=1; j<flam3_nvariations; j++) {

		variation = [Genome createVariationEntityFromElement:nil
											 ofVariationType:j
												   andWeight:0.0
												   inContext:moc];

		[variations addObject:variation];
//		[variation release];

	}

	[variations autorelease];
	return variations;
}

+ (NSManagedObject *)createEmptyGnomeInContext:(NSManagedObjectContext *)moc {

	NSManagedObject *genomeEntity = [Genome createDefaultGenomeEntityInContext:moc];
	[genomeEntity setValue:[Genome createDefaultXFormEntitySetInContext:moc] forKey: @"xforms"];
	[genomeEntity setValue:[Genome createDefaultGenomeImageEntityInContext:moc] forKey:@"images"];

	return genomeEntity;

}
+ (NSArray *)createArrayFromEntities:(NSArray *)entities fromContext:(NSManagedObjectContext *)moc {

	NSMutableArray *dictionaryArray = [NSMutableArray arrayWithCapacity:[entities count]];

	NSManagedObject *genome;
	NSEnumerator *genomeEnumerator = [entities objectEnumerator];


	while ((genome = [genomeEnumerator nextObject])) {
		[dictionaryArray insertObject:[Genome createDictionaryFromGenomeEntity:genome fromContext:moc] atIndex:[dictionaryArray count]];
	}

	return dictionaryArray;

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

	CGFloat red, green, blue;
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
	[genome setObject:[genomeEntity valueForKey:@"scale"] forKey:@"scale"];
	[genome setObject:[genomeEntity valueForKey:@"centre_x"] forKey:@"centre_x"];
	[genome setObject:[genomeEntity valueForKey:@"centre_y"] forKey:@"centre_y"];
	[genome setObject:[genomeEntity valueForKey:@"oversample"] forKey:@"supersample"];
	[genome setObject:[genomeEntity valueForKey:@"quality"] forKey:@"quality"];
	[genome setObject:[genomeEntity valueForKey:@"batches"] forKey:@"passes"];
	[genome setObject:[genomeEntity valueForKey:@"jitter"] forKey:@"temporal_samples"];
	[genome setObject:[genomeEntity valueForKey:@"temporal_filter_type"] forKey:@"temporal_filter_type"];
	[genome setObject:[genomeEntity valueForKey:@"temporal_filter_width"] forKey:@"temporal_filter_width"];
	[genome setObject:[genomeEntity valueForKey:@"temporal_filter_exp"] forKey:@"temporal_filter_exp"];
	[genome setObject:[genomeEntity valueForKey:@"de_max_filter"] forKey:@"estimator_radius"];
	[genome setObject:[genomeEntity valueForKey:@"de_min_filter"] forKey:@"estimator_minimum"];
	[genome setObject:[genomeEntity valueForKey:@"de_alpha"] forKey:@"estimator_curve"];
	[genome setObject:[genomeEntity valueForKey:@"gamma"] forKey:@"gamma"];
	[genome setObject:[genomeEntity valueForKey:@"gamma_threshold"] forKey:@"gamma_threshold"];


	NSColor *bc = [genomeEntity valueForKey:@"background"];
	[[bc colorUsingColorSpaceName:@"NSDeviceRGBColorSpace"] getRed:&red green:&green blue:&blue alpha:NULL];

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


	if([[genomeEntity valueForKey:@"interpolation"] intValue] == 1) {
		[genome setObject:@"smooth" forKey:@"interpolation"];
	} else {
		[genome setObject:@"linear" forKey:@"interpolation"];
	}

	[genome setObject:[[genomeEntity valueForKey:@"interpolation_type"] lowercaseString] forKey:@"interpolation_type"];

//	[genome setObject:[genomeEntity valueForKey:@"motion_exp"] forKey:@"motion_exponent"];
	[genome setObject:[genomeEntity valueForKey:@"spatial_filter_radius"] forKey:@"filter"];

	if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"B-Spline"]) {
		[genome setObject:@"bspline" forKey:@"filter_shape"];
	} else {
		[genome setObject:[[genomeEntity valueForKey:@"spatial_filter_func"] lowercaseString] forKey:@"filter_shape"];
	}

	[genome setObject:[[genomeEntity valueForKey:@"palette_mode"] lowercaseString] forKey:@"palette_mode"];

	[genome setObject:[Genome createDictionaryForEditUsingEntity:genomeEntity] forKey:@"edit"];

	if([[genomeEntity valueForKey:@"use_palette"] boolValue] == FALSE) {

		predicate = [NSPredicate predicateWithFormat:@"parent_genome == %@", genomeEntity];

		sort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
		sortDescriptors = [NSArray arrayWithObject: sort];

		fetch = [[NSFetchRequest alloc] init];
		[fetch setEntity:[NSEntityDescription entityForName:@"CMap" inManagedObjectContext:moc]];
		[fetch setPredicate: predicate];
		[fetch setSortDescriptors: sortDescriptors];

		NSError*	err	= [[NSError alloc] init];

		cmaps = [moc executeFetchRequest:fetch error:&err];
		[sort release];
		[fetch release];
		[err release];
	//	 use the cmap

		NSMutableArray *newCmaps = [PaletteController extrapolateArray:cmaps];
		[newCmaps retain];
		[genome setObject:[Genome createArrayForCMap:newCmaps] forKey:@"colors"];
		[newCmaps release];
		/*
		if([cmaps count] < 256) {
			NSMutableArray *newCmaps = [PaletteController extrapolateArray:cmaps];
			[newCmaps retain];
			[genome setObject:[Genome createArrayForCMap:newCmaps] forKey:@"colors"];
			[newCmaps release];
		} else {
			[genome setObject:[Genome createArrayForCMap:cmaps] forKey:@"colors"];
		}
		*/

	} else {
		[genome setObject:[[genomeEntity valueForKey:@"images"] valueForKey:@"palette"] forKey:@"palette"];
	}



	// xforms

	predicate = [NSPredicate predicateWithFormat:@"parent_genome == %@", genomeEntity];

	sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	sortDescriptors = [NSArray arrayWithObject: sort];

	fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"XForm" inManagedObjectContext:moc]];
	[fetch setPredicate: predicate];
	[fetch setSortDescriptors: sortDescriptors];

	NSError*	err	= [[NSError alloc] init];

	xforms = [moc executeFetchRequest:fetch error:&err];
	[sort release];
	[fetch release];
	[err release];

	int old_num_xforms = [xforms count];

	NSMutableArray *xformArray = [NSMutableArray arrayWithCapacity:old_num_xforms];

	for(i=0; i < old_num_xforms; i++) {

		[xformArray insertObject:[Genome createDictionaryFromTransformEntity:[xforms objectAtIndex:i] fromContext:moc] atIndex:i];

	}

	[genome setObject:xformArray forKey:@"xforms"];

	return genome;

}


+ (NSMutableDictionary *)createDictionaryFromTransformEntity:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc {

	NSMutableDictionary *xform = [NSMutableDictionary dictionaryWithCapacity:10];



	if([[xformEntity valueForKey:@"final_xform"] boolValue] == YES) {
		[xform setObject:@"Y" forKey:@"is_finalxform"];
	} else {

		[xform setObject:@"N" forKey:@"is_finalxform"];
	}

	[xform setObject:[xformEntity valueForKey:@"density"] forKey:@"weight"];

	NSMutableArray *coeffsArray = [NSMutableArray arrayWithCapacity:3];
	NSMutableArray *coeffs = [NSMutableArray arrayWithCapacity:2];

	[coeffs insertObject:[xformEntity valueForKey:@"coeff_0_0"]  atIndex:0];
	[coeffs insertObject:[xformEntity valueForKey:@"coeff_0_1"]  atIndex:1];
	[coeffsArray insertObject:coeffs  atIndex:0];

	coeffs = [NSMutableArray arrayWithCapacity:2];
	[coeffs insertObject:[xformEntity valueForKey:@"coeff_1_0"]  atIndex:0];
	[coeffs insertObject:[xformEntity valueForKey:@"coeff_1_1"]  atIndex:1];
	[coeffsArray insertObject:coeffs  atIndex:1];

	coeffs = [NSMutableArray arrayWithCapacity:2];
	[coeffs insertObject:[xformEntity valueForKey:@"coeff_2_0"]  atIndex:0];
	[coeffs insertObject:[xformEntity valueForKey:@"coeff_2_1"]  atIndex:1];
	[coeffsArray insertObject:coeffs  atIndex:2];

	[xform setObject:coeffsArray forKey:@"coefs"];

	coeffsArray = [NSMutableArray arrayWithCapacity:3];
	coeffs = [NSMutableArray arrayWithCapacity:2];

	[coeffs insertObject:[xformEntity valueForKey:@"post_0_0"]  atIndex:0];
	[coeffs insertObject:[xformEntity valueForKey:@"post_0_1"]  atIndex:1];
	[coeffsArray insertObject:coeffs  atIndex:0];

	coeffs = [NSMutableArray arrayWithCapacity:2];
	[coeffs insertObject:[xformEntity valueForKey:@"post_1_0"]  atIndex:0];
	[coeffs insertObject:[xformEntity valueForKey:@"post_1_1"]  atIndex:1];
	[coeffsArray insertObject:coeffs  atIndex:1];

	coeffs = [NSMutableArray arrayWithCapacity:2];
	[coeffs insertObject:[xformEntity valueForKey:@"post_2_0"]  atIndex:0];
	[coeffs insertObject:[xformEntity valueForKey:@"post_2_1"]  atIndex:1];
	[coeffsArray insertObject:coeffs  atIndex:2];

	[xform setObject:coeffsArray forKey:@"post"];

	[xform setObject:[xformEntity valueForKey:@"colour_0"] forKey:@"color"];
	[xform setObject:[xformEntity valueForKey:@"symmetry"] forKey:@"symmetry"];

	[xform setObject:[Genome createArrayForTransformVariations:xformEntity fromContext:moc] forKey:@"variations"];

	return xform;


}


+ (NSMutableArray *) createArrayForTransformVariations:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc {

	NSArray *variations;
	NSMutableArray *variationsArray;

	NSPredicate * predicate;
	//	predicate = [NSPredicate predicateWithFormat:@"parent_xform.order == %ul", [[xformEntity valueForKey:@"order"] intValue]];
	predicate = [NSPredicate predicateWithFormat:@"parent_xform == %@", xformEntity];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"variation_index" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject: sort];

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Variations" inManagedObjectContext:moc]];
	[fetch setPredicate: predicate];
	[fetch setSortDescriptors: sortDescriptors];

	NSError*	err	= [[NSError alloc] init];

	variations = [moc executeFetchRequest:fetch error:&err];
	[sort release];
	[fetch release];
	[err release];


	unsigned int i;

	NSManagedObject *variation;
	NSMutableDictionary *variationDictionary;
	variationsArray = [NSMutableArray arrayWithCapacity:[variations count]];


	for(i=0; i<[variations count]; i++) {
		variation = [variations objectAtIndex:i];

		if([[variation valueForKey:@"in_use"] boolValue] == YES) {
			variationDictionary = [NSMutableDictionary dictionaryWithCapacity:8];
			[variationDictionary setObject:variationName[i] forKey:@"name"];
			[variationDictionary setObject:[variation valueForKey:@"weight"] forKey:@"weight"];

			switch(i) {
				case 23:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"blob_high"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"blob_low"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_3"] forKey:@"blob_waves"];
					break;
				case 24:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"pdj_a"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"pdj_b"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_3"] forKey:@"pdj_c"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_4"] forKey:@"pdj_d"];
					break;
				case 25:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"fan2_x"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"fan2_y"];
					break;
				case 26:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"rings2_val"];
					break;
				case 30:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"perspective_angle"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"perspective_dist"];
					break;
				case 32:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"julian_dist"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"julian_power"];
					break;
				case 33:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"juliascope_dist"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"juliascope_power"];
					break;
				case 36:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"radial_blur_angle"];
					break;
				case 37:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"pie_slices"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"pie_rotation"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_3"] forKey:@"pie_thickness"];
					break;
				case 38:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"ngon_sides"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"ngon_power"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_3"] forKey:@"ngon_circle"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_4"] forKey:@"ngon_corners"];
					break;
				case 39:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"curl_c1"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"curl_c2"];
					break;
				case 40:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"rectangles_x"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"rectangles_y"];
					break;
				case 49:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"disc2_rot"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"disc2_twist"];
					break;
				case 50:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"super_shape_rnd"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"super_shape_m"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_3"] forKey:@"super_shape_n1"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_4"] forKey:@"super_shape_n2"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_5"] forKey:@"super_shape_n3"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_6"] forKey:@"super_shape_holes"];
					break;
				case 51:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"flower_petals"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"flower_holes"];
					break;
				case 52:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"conic_eccentricity"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"conic_holes"];
					break;
				case 53:
					[variationDictionary setObject:[variation valueForKey:@"parameter_1"] forKey:@"parabola_height"];
					[variationDictionary setObject:[variation valueForKey:@"parameter_2"] forKey:@"parabola_width"];
					break;
				default:
					break;
			}

			[variationsArray insertObject:variationDictionary atIndex:[variationsArray count]];
		}
	}

	return variationsArray;
}


+ (NSMutableArray *)createArrayForCMap:(NSArray *)cmaps {

	NSManagedObject *colour;
	NSMutableArray *colourArray = [NSMutableArray arrayWithCapacity:256];
	int i;

	for(i=0; i<256; i++) {

		colour = [cmaps objectAtIndex:i];

		NSMutableDictionary *colourDictionary = [NSMutableDictionary dictionaryWithCapacity:4];

		[colourDictionary setObject:[NSNumber numberWithInt:i] forKey:@"index"];
		[colourDictionary setObject:[colour valueForKey:@"red"] forKey:@"red"];
		[colourDictionary setObject:[colour valueForKey:@"green"] forKey:@"green"];
		[colourDictionary setObject:[colour valueForKey:@"blue"] forKey:@"blue"];
//      [colourDictionary setObject:[NSNumber numberWithInt:(int)([[colour valueForKey:@"blue"]   doubleValue] * 255.0)] forKey:@"blue"];

		[colourArray insertObject:colourDictionary atIndex:i];

	}

	return colourArray;

}



+ (NSMutableDictionary *) createDictionaryForEditUsingEntity:(NSManagedObject *)genome {

	NSMutableDictionary *newEdit = [NSMutableDictionary dictionaryWithCapacity:5];
	NSString *date;

	struct tm *localt;
	time_t mytime;
	char timestring[100];


	/* create a date stamp (change to use cocoa)*/
	mytime = time(NULL);
	localt = localtime(&mytime);
	/* XXX use standard time format including timezone */
	strftime(timestring, 100, "%a %b %e %H:%M:%S %Z %Y", localt);

	date = [NSString stringWithCString:timestring encoding:NSUTF8StringEncoding];

	NSAttributedString *xmlValue = [genome valueForKey:@"edits"];


	/* create edit element with new details */

	if([genome valueForKey:@"nick"] == nil) {
		[newEdit setObject:@"" forKey:@"nick"];
	} else {
		[newEdit setObject:[genome valueForKey:@"nick"] forKey:@"nick"];
	}

	if([genome valueForKey:@"url"] == nil) {
		[newEdit setObject:@"" forKey:@"url"];
	} else {
		[newEdit setObject:[genome valueForKey:@"url"] forKey:@"url"];
	}

	if([genome valueForKey:@"comment"] == nil) {
		[newEdit setObject:@"" forKey:@"comm"];
	} else {
		[newEdit setObject:[genome valueForKey:@"comment"] forKey:@"comm"];
	}

	[newEdit setObject:date forKey:@"date"];
	if([xmlValue string] != nil) {
		[newEdit setObject:[xmlValue string] forKey:@"previous_edits"];

	} else {

		[newEdit setObject:@"" forKey:@"previous_edits"];

	}



	return newEdit;
}

+ (NSArray *)createGenomeEntitiesFromArray:(NSArray *)genomeArray inContext:(NSManagedObjectContext *)moc {

	NSDictionary *genome;
	NSEnumerator *genomeEnumerator = [genomeArray objectEnumerator];
	NSMutableArray *genomes  = [NSMutableArray arrayWithCapacity:[genomeArray count]];


	while ((genome = [genomeEnumerator nextObject])) {
		[genomes addObject:[Genome createGenomeEntityFromDictionary:genome inContext:moc]];
	}

	return genomes;
}

+ (NSManagedObject *)createGenomeEntityFromDictionary:(NSDictionary *)genome inContext:(NSManagedObjectContext *)moc {

	NSManagedObject *newGenomeEntity = [Genome createDefaultGenomeEntityInContext:moc];
	NSManagedObject *newGenomeImageEntity = [Genome createDefaultGenomeImageEntityInContext:moc];
	NSObject *tempObject;
	NSString *tempString;


	tempObject = [genome objectForKey:@"name"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject  forKey:@"name"];
	}

	tempObject = [genome objectForKey:@"parent"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"parent"];
	}

	tempObject = [genome objectForKey:@"time"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject  forKey:@"time"];
	}

	[newGenomeEntity setValue:[NSNumber numberWithBool:NO] forKey:@"aspect_lock"];
	tempObject = [genome objectForKey:@"width"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"width"];
	}
	tempObject = [genome objectForKey:@"height"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"height"];
	}
	[newGenomeEntity setValue:[NSNumber numberWithBool:YES] forKey:@"aspect_lock"];

	tempObject = [genome objectForKey:@"scale"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"scale"];
	}

	tempObject = [genome objectForKey:@"centre_x"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"centre_x"];
	}

	tempObject = [genome objectForKey:@"centre_y"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"centre_y"];
	}

	tempObject = [genome objectForKey:@"zoom"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"zoom"];
	}

	tempObject = [genome objectForKey:@"oversample"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"oversample"];
	}

	tempObject = [genome objectForKey:@"supersample"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"oversample"];
	}

	tempObject = [genome objectForKey:@"quality"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"quality"];
	}

	tempObject = [genome objectForKey:@"passes"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"batches"];
	}

	tempObject = [genome objectForKey:@"temporal_samples"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"jitter"];
	}


	tempObject = [genome objectForKey:@"temporal_filter_type"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"temporal_filter_type"];
	}

	tempObject = [genome objectForKey:@"temporal_filter_width"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"temporal_filter_width"];
	}

	tempObject = [genome objectForKey:@"temporal_filter_exp"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"temporal_filter_exp"];
	}

	tempObject = [genome objectForKey:@"estimator_radius"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"de_max_filter"];
	}


	tempObject = [genome objectForKey:@"estimator_minimum"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"de_min_filter"];
	}

	tempObject = [genome objectForKey:@"estimator_curve"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"de_alpha"];
	}

	tempObject = [genome objectForKey:@"gamma"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"gamma"];
	}

	tempObject = [genome objectForKey:@"gamma_threshold"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"gamma_threshold"];
	}

	NSDictionary *tempDictionary = [genome objectForKey:@"background"];
	if(tempDictionary != nil) {
		double red, green, blue;
		red =   [[tempDictionary objectForKey:@"red"] doubleValue];
		green = [[tempDictionary objectForKey:@"green"] doubleValue];
		blue =  [[tempDictionary objectForKey:@"blue"] doubleValue];
		red   /= 255;
		green /= 255;
		blue  /= 255;

		[newGenomeEntity setValue:[NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0] forKey:@"background"];
	}

	tempObject = [genome objectForKey:@"vibrancy"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"vibrancy"];
	}
	tempObject = [genome objectForKey:@"brightness"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"brightness"];
	}

	tempObject = [genome objectForKey:@"rotate"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"rotate"];
	}

	tempObject = [genome objectForKey:@"contrast"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"contrast"];
	}


	tempString = [genome objectForKey:@"interpolation"];
	if([tempString isEqualToString:@"smooth"]) {
		[newGenomeEntity setValue:[NSNumber numberWithInt:1]  forKey:@"interpolation"];
	} else {
		[newGenomeEntity setValue:[NSNumber numberWithInt:0]  forKey:@"interpolation"];
	}

	tempString = [genome objectForKey:@"interpolation_type"];
	[newGenomeEntity setValue:[tempString capitalizedString]  forKey:@"interpolation_type"];

	tempObject = [genome objectForKey:@"motion_exponent"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"temporal_filter_exp"];
	    [newGenomeEntity setValue:@"Exponent" forKey:@"temporal_filter_type"];
	    [newGenomeEntity setValue:[NSNumber numberWithDouble:1.0] forKey:@"temporal_filter_width"];
	}


	tempObject = [genome objectForKey:@"filter"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"spatial_filter_radius"];
	}

	NSString *spatial_filter_func = [genome objectForKey:@"filter_shape"];
	if(spatial_filter_func != nil) {

		if ([spatial_filter_func isEqualToString:@"bspline"]) {
			[newGenomeEntity setValue:@"B-Spline"  forKey:@"spatial_filter_func"];
		} else {
			[newGenomeEntity setValue:[spatial_filter_func capitalizedString]  forKey:@"spatial_filter_func"];
		}

	} else {
		[newGenomeEntity setValue:@"Gaussian"  forKey:@"spatial_filter_func"];
	}

	tempObject = [genome objectForKey:@"symmetry"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"symmetry"];
	}

	tempObject = [genome objectForKey:@"palette"];
	if(tempObject != nil) {
	    [newGenomeImageEntity setValue:tempObject forKey:@"palette"];
	    [newGenomeEntity setValue:[NSNumber numberWithBool:YES]  forKey:@"use_palette"];
	} else {
	    [newGenomeEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"use_palette"];
	}

	[newGenomeEntity setValue:newGenomeImageEntity forKey:@"images"];

	tempObject = [genome objectForKey:@"hue"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:tempObject forKey:@"hue"];
	}

	tempObject = [genome objectForKey:@"palette_mode"];
	if(tempObject != nil) {
	    [newGenomeEntity setValue:[(NSString *)tempObject capitalizedString] forKey:@"palette_mode"];
	}

	/* deal the flame children */

	NSArray *xforms = [genome objectForKey:@"xforms"];
	NSMutableSet *newTransforms = [Genome createTransformEntitiesFromArray:xforms inContext:moc];

	NSArray *colourMap = [genome objectForKey:@"colors"];
	if (colourMap != nil) {
		[Genome createColourMapFromArray:colourMap forGenome:newGenomeEntity andImageEntity:newGenomeImageEntity inContext:moc];
	}


	NSDictionary *edits = [genome objectForKey:@"edit"];
	NSAttributedString *previousEdits;
	NSString *pEdits =  [edits objectForKey:@"previous_edits"];
	if(pEdits == nil) {
		previousEdits = [[NSAttributedString alloc] initWithString:@""];

	} else {
		previousEdits = [[NSAttributedString alloc] initWithString:pEdits];

	}

	[newGenomeEntity setValue:previousEdits forKey:@"edits"];

	[newGenomeEntity setValue:[edits objectForKey:@"nick"] forKey:@"nick"];
	[newGenomeEntity setValue:[edits objectForKey:@"url"] forKey:@"url"];
	[newGenomeEntity setValue:[edits objectForKey:@"comm"] forKey:@"comment"];

	[previousEdits release];


	[newGenomeEntity setValue:newTransforms forKey:@"xforms"];

	return newGenomeEntity;


}

+ (NSMutableSet *)createTransformEntitiesFromArray:(NSArray *)xforms inContext:(NSManagedObjectContext *)moc {

	NSMutableSet *newTransforms = [[NSMutableSet alloc] initWithCapacity:5];
	int i;
	for(i=0; i<[xforms count]; i++) {

		NSManagedObject *xFormEntity;
		NSObject *tempObject;
		NSDictionary *xform = [xforms objectAtIndex:i];


		xFormEntity = [NSEntityDescription insertNewObjectForEntityForName:@"XForm" inManagedObjectContext:moc];

		[xFormEntity setValue:[NSNumber numberWithInt:i+1] forKey:@"order"];

		tempObject = [xform objectForKey:@"weight"];
		if (tempObject != nil) {
			[xFormEntity setValue:tempObject forKey:@"density"];
		}



		NSArray *coefs = [xform objectForKey:@"coefs"];
		if (coefs != nil) {

			[xFormEntity setValue:[[coefs objectAtIndex:0] objectAtIndex:0] forKey:@"coeff_0_0"];
			[xFormEntity setValue:[[coefs objectAtIndex:0] objectAtIndex:1] forKey:@"coeff_0_1"];
			[xFormEntity setValue:[[coefs objectAtIndex:1] objectAtIndex:0] forKey:@"coeff_1_0"];
			[xFormEntity setValue:[[coefs objectAtIndex:1] objectAtIndex:1] forKey:@"coeff_1_1"];
			[xFormEntity setValue:[[coefs objectAtIndex:2] objectAtIndex:0] forKey:@"coeff_2_0"];
			[xFormEntity setValue:[[coefs objectAtIndex:2] objectAtIndex:1] forKey:@"coeff_2_1"];

		}

		double post[3][2] = {1.0, 0.0, 0.0, 1.0, 0.0, 0.0};

		[xFormEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"post_flag"];

		NSArray *postArray = [xform objectForKey:@"post"];
		if (postArray != nil) {

			post[0][0] = [[[postArray objectAtIndex:0] objectAtIndex:0] doubleValue];
			post[0][1] = [[[postArray objectAtIndex:0] objectAtIndex:1] doubleValue];
			post[1][0] = [[[postArray objectAtIndex:1] objectAtIndex:0] doubleValue];
			post[1][1] = [[[postArray objectAtIndex:1] objectAtIndex:1] doubleValue];
			post[2][0] = [[[postArray objectAtIndex:2] objectAtIndex:0] doubleValue];
			post[2][1] = [[[postArray objectAtIndex:2] objectAtIndex:1] doubleValue];

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


		tempObject = [xform objectForKey:@"color"];
		if (tempObject != nil) {
			[xFormEntity setValue:tempObject forKey:@"colour_0"];
		}


		tempObject = [xform objectForKey:@"symmetry"];
		if (tempObject != nil) {
			[xFormEntity setValue:tempObject forKey:@"symmetry"];
		}

		NSString *tempString = [xform objectForKey:@"is_finalxform"];
		if ([tempString isEqualToString:@"Y"]) {
			[xFormEntity setValue:[NSNumber numberWithBool:YES] forKey:@"final_xform"];
		} else {
			[xFormEntity setValue:[NSNumber numberWithBool:NO] forKey:@"final_xform"];
		}


		NSArray *variations = [xform objectForKey:@"variations"];
		if (variations != nil) {
			[xFormEntity setValue:[Genome createVariationEntitiesFromArray:variations inContext:moc]  forKey:@"variations"];
		}

		[newTransforms addObject:xFormEntity];
//		[xFormEntity release];

	}

	return [newTransforms autorelease];

}

+ (NSMutableSet *)createVariationEntitiesFromArray:(NSArray *)variations inContext:(NSManagedObjectContext *)moc {

	NSMutableSet *variationSet = [[NSMutableSet alloc] initWithCapacity:flam3_nvariations];

	int i, j;
	NSManagedObject *newVariation = nil;

	int totalVariations = [variations count];

	for (i = 0; i < flam3_nvariations; i++) {

		for (j = 0; j < totalVariations; j++) {

			NSDictionary *variation = [variations objectAtIndex:j];

			NSString *name = [variation objectForKey:@"name"];


			if([name isEqualToString:variationName[i]]) {
				newVariation = [Genome createVariationEntityFromDictionary:variation
														   ofVariationType:i
																 andWeight:[[variation objectForKey:@"weight"] doubleValue]
																 inContext:moc];
				break;
			}
		}

		if (j == totalVariations) {
				newVariation = [Genome createVariationEntityFromDictionary:nil
														   ofVariationType:i
																 andWeight:0.0
																 inContext:moc];
		}
		[variationSet addObject:newVariation];
	}


	return [variationSet autorelease];

}

+ (NSManagedObject *)createVariationEntityFromDictionary:(NSDictionary *)variationDictionary ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)moc {

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

			[variation setValue:[variationDictionary objectForKey:@"blob_high"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"blob_low"] forKey:@"parameter_2"];
			[variation setValue:[variationDictionary objectForKey:@"blob_waves"] forKey:@"parameter_3"];

			[variation setValue:@"Blob High:" forKey:@"parameter_1_name"];
			[variation setValue:@"Blob Low:" forKey:@"parameter_2_name"];
			[variation setValue:@"Blob Wave:" forKey:@"parameter_3_name"];
			break;
		case 24:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];

			[variation setValue:[variationDictionary objectForKey:@"pdj_a"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"pdj_b"] forKey:@"parameter_2"];
			[variation setValue:[variationDictionary objectForKey:@"pdj_c"] forKey:@"parameter_3"];
			[variation setValue:[variationDictionary objectForKey:@"pdj_d"] forKey:@"parameter_4"];

			[variation setValue:@"PDJ A:" forKey:@"parameter_1_name"];
			[variation setValue:@"PDJ B:" forKey:@"parameter_2_name"];
			[variation setValue:@"PDJ C:" forKey:@"parameter_3_name"];
			[variation setValue:@"PDJ D:" forKey:@"parameter_4_name"];

			break;
		case 25:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[variationDictionary objectForKey:@"fan2_x"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"fan2_y"] forKey:@"parameter_2"];

			[variation setValue:@"Fan2 x:" forKey:@"parameter_1_name"];
			[variation setValue:@"Fan2 y:" forKey:@"parameter_2_name"];

			break;
		case 26:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];

			[variation setValue:[variationDictionary objectForKey:@"rings2_val"] forKey:@"parameter_1"];

			[variation setValue:@"Rings2:" forKey:@"parameter_1_name"];

			break;
		case 30:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[variationDictionary objectForKey:@"perspective_angle"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"perspective_dist"] forKey:@"parameter_2"];

			[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
			[variation setValue:@"Distance:" forKey:@"parameter_2_name"];

			break;
		case 32:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[variationDictionary objectForKey:@"julian_dist"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"julian_power"] forKey:@"parameter_2"];

			[variation setValue:@"Distance:" forKey:@"parameter_1_name"];
			[variation setValue:@"Power:" forKey:@"parameter_2_name"];

			break;
		case 33:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[variationDictionary objectForKey:@"juliascope_dist"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"juliascope_power"] forKey:@"parameter_2"];

			[variation setValue:@"JS Distance:" forKey:@"parameter_1_name"];
			[variation setValue:@"Power:" forKey:@"parameter_2_name"];

			break;
		case 36:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];

			[variation setValue:@"Angle:" forKey:@"parameter_1_name"];

			[variation setValue:[variationDictionary objectForKey:@"radial_blur_angle"] forKey:@"parameter_1"];

			break;
		case 37:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];

			[variation setValue:@"Slices:" forKey:@"parameter_1_name"];
			[variation setValue:@"Rotation:" forKey:@"parameter_2_name"];
			[variation setValue:@"Thickness:" forKey:@"parameter_3_name"];

			[variation setValue:[variationDictionary objectForKey:@"pie_slices"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"pie_rotation"] forKey:@"parameter_2"];
			[variation setValue:[variationDictionary objectForKey:@"pie_thickness"] forKey:@"parameter_3"];
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

			[variation setValue:[variationDictionary objectForKey:@"ngon_sides"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"ngon_power"] forKey:@"parameter_2"];
			[variation setValue:[variationDictionary objectForKey:@"ngon_circle"] forKey:@"parameter_3"];
			[variation setValue:[variationDictionary objectForKey:@"ngon_corners"] forKey:@"parameter_4"];
			break;

		case 39:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"c1:" forKey:@"parameter_1_name"];
			[variation setValue:@"c2:" forKey:@"parameter_2_name"];

			[variation setValue:[variationDictionary objectForKey:@"curl_c1"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"curl_c2"] forKey:@"parameter_2"];
			break;

		case 40:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"x:" forKey:@"parameter_1_name"];
			[variation setValue:@"y:" forKey:@"parameter_2_name"];

			[variation setValue:[variationDictionary objectForKey:@"rectangles_x"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"rectangles_y"] forKey:@"parameter_2"];
			break;

		case 49:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Rotation:" forKey:@"parameter_1_name"];
			[variation setValue:@"Twist:" forKey:@"parameter_2_name"];

			[variation setValue:[variationDictionary objectForKey:@"disc2_rot"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"disc2_twist"] forKey:@"parameter_2"];
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

			[variation setValue:[variationDictionary objectForKey:@"super_shape_rnd"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"super_shape_m"] forKey:@"parameter_2"];
			[variation setValue:[variationDictionary objectForKey:@"super_shape_n1"] forKey:@"parameter_3"];
			[variation setValue:[variationDictionary objectForKey:@"super_shape_n2"] forKey:@"parameter_4"];
			[variation setValue:[variationDictionary objectForKey:@"super_shape_n3"] forKey:@"parameter_5"];
			[variation setValue:[variationDictionary objectForKey:@"super_shape_holes"] forKey:@"parameter_6"];
			break;

		case 51:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Petals:" forKey:@"parameter_1_name"];
			[variation setValue:@"Holes:" forKey:@"parameter_2_name"];

			[variation setValue:[variationDictionary objectForKey:@"flower_petals"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"flower_holes"] forKey:@"parameter_2"];
			break;

		case 52:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Eccentricity:" forKey:@"parameter_1_name"];
			[variation setValue:@"Holes:" forKey:@"parameter_2_name"];

			[variation setValue:[variationDictionary objectForKey:@"conic_eccentricity"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"conic_holes"] forKey:@"parameter_2"];
			break;

		case 53:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Height:" forKey:@"parameter_1_name"];
			[variation setValue:@"Width:" forKey:@"parameter_2_name"];

			[variation setValue:[variationDictionary objectForKey:@"parabola_height"] forKey:@"parameter_1"];
			[variation setValue:[variationDictionary objectForKey:@"parabola_width"] forKey:@"parameter_2"];
			break;

		default:
			break;
	}

//	[variation autorelease];

	return variation;
}

+ (void) createColourMapFromArray:(NSArray *)colourMap forGenome:(NSManagedObject *)genomeEntity
												  andImageEntity:(NSManagedObject *)genomeImageEntity
						                               inContext:(NSManagedObjectContext *)moc {

	int i, index;
	double red, green, blue;

	NSMutableArray *tempColours = [NSMutableArray arrayWithCapacity:256];

	for(i=0; i<[colourMap count]; i++) {

		NSDictionary *colour = [colourMap objectAtIndex:i];
		NSManagedObject *newColour = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:moc];

		index  = [[colour objectForKey:@"index"] intValue];
		red  = [[colour objectForKey:@"red"] doubleValue];
		green  = [[colour objectForKey:@"green"] doubleValue];
		blue  = [[colour objectForKey:@"blue"] doubleValue];

		red /= 255.0;
		green /= 255.0;
		blue /= 255.0;

		[newColour setValue:[NSNumber numberWithInt:index] forKey:@"index"];
		[newColour setValue:[NSNumber numberWithDouble:red] forKey:@"red"];
		[newColour setValue:[NSNumber numberWithDouble:green] forKey:@"green"];
		[newColour setValue:[NSNumber numberWithDouble:blue] forKey:@"blue"];

		[tempColours insertObject:newColour atIndex:[tempColours count]];
//		[newColour release];


	}

	[genomeEntity setValue:[NSMutableSet setWithArray:tempColours] forKey:@"cmap"];


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

	[PaletteController fillBitmapRep:colourMapImageRep withColours:tempColours forHeight:15];
	[colourMapImage addRepresentation:colourMapImageRep];

	[genomeImageEntity setValue:colourMapImage forKey:@"colour_map_image"];

	[colourMapImageRep release];
	[colourMapImage release];

	return;

}


+ (NSManagedObject *)createGenomeEntityFromAttributeDictionary:(NSDictionary *)genome inContext:(NSManagedObjectContext *)moc {

	NSManagedObject *newGenomeEntity = [Genome createDefaultGenomeEntityInContext:moc];
	NSString *tempAttribute;

	NSManagedObject *genomeImageEntity = [Genome createGenomeImageEntityFromAttributeDictionary:genome inContext:moc];
	[newGenomeEntity setValue:genomeImageEntity forKey:@"images"];

	tempAttribute = [genome objectForKey:@"name"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:tempAttribute forKey:@"name"];
	}

	tempAttribute = [genome objectForKey:@"parent"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:tempAttribute forKey:@"parent"];
	}

	tempAttribute = [genome objectForKey:@"time"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"time"];
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"order"];
	}

	tempAttribute = [genome objectForKey:@"size"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithBool:NO] forKey:@"aspect_lock"];
		NSArray *split = [tempAttribute componentsSeparatedByString:@" "];
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[split objectAtIndex:0] intValue]] forKey:@"width"];
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[[split objectAtIndex:1] intValue]] forKey:@"height"];
	    [newGenomeEntity setValue:[NSNumber numberWithBool:YES] forKey:@"aspect_lock"];
	}

	tempAttribute = [genome objectForKey:@"scale"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"scale"];
	}

	tempAttribute = [genome objectForKey:@"center"];
	if(tempAttribute != nil) {
		NSArray *split = [tempAttribute componentsSeparatedByString:@" "];
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:0] doubleValue]] forKey:@"centre_x"];
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:1] doubleValue]] forKey:@"centre_y"];
	}


	tempAttribute = [genome objectForKey:@"scale"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"scale"];
	}

	tempAttribute = [genome objectForKey:@"zoom"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"zoom"];
	}

	tempAttribute = [genome objectForKey:@"oversample"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"oversample"];
	}

	tempAttribute = [genome objectForKey:@"supersample"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"oversample"];
	}

	tempAttribute = [genome objectForKey:@"quality"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"quality"];
	}

	tempAttribute = [genome objectForKey:@"passes"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"batches"];
	}

	tempAttribute = [genome objectForKey:@"temporal_samples"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"jitter"];
	}



	tempAttribute = [genome objectForKey:@"temporal_filter_type"];
	if(tempAttribute != nil) {
		if([tempAttribute isEqualToString:@"box"]) {
			[newGenomeEntity setValue:@"Box"  forKey:@"temporal_filter_type"];
		} else if([tempAttribute isEqualToString:@"gaussian"]) {
			[newGenomeEntity setValue:@"Gaussian"  forKey:@"temporal_filter_type"];
		} else if([tempAttribute isEqualToString:@"exp"]) {
			[newGenomeEntity setValue:@"Exponent"  forKey:@"temporal_filter_type"];
		}
	}

	tempAttribute = [genome objectForKey:@"temporal_filter_width"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"temporal_filter_width"];
	}

	tempAttribute = [genome objectForKey:@"temporal_filter_exp"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"temporal_filter_exp"];
	}

	tempAttribute = [genome objectForKey:@"estimator_radius"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"de_max_filter"];
	}

	tempAttribute = [genome objectForKey:@"estimator_minimum"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"de_min_filter"];
	}

	tempAttribute = [genome objectForKey:@"estimator_curve"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"de_alpha"];
	}

	tempAttribute = [genome objectForKey:@"gamma"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"gamma"];
	}

	tempAttribute = [genome objectForKey:@"gamma_threshold"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"gamma_threshold"];
	}

	tempAttribute = [genome objectForKey:@"background"];
	if(tempAttribute != nil) {
		NSArray *split = [tempAttribute componentsSeparatedByString:@" "];
		double red, green, blue;
		red =   [[split objectAtIndex:0] doubleValue];
		green = [[split objectAtIndex:1] doubleValue];
		blue =  [[split objectAtIndex:2] doubleValue];
		//		red   /= 255;
		//		green /= 255;
		//		blue  /= 255;

		[newGenomeEntity setValue:[NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0] forKey:@"background"];

	}

	tempAttribute = [genome objectForKey:@"hue"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"hue"];
	}
	tempAttribute = [genome objectForKey:@"vibrancy"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"vibrancy"];
	}
	tempAttribute = [genome objectForKey:@"brightness"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"brightness"];
	}

	tempAttribute = [genome objectForKey:@"rotate"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"rotate"];
	}

	tempAttribute = [genome objectForKey:@"contrast"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"contrast"];
	}


	tempAttribute = [genome objectForKey:@"interpolation"];
	if([tempAttribute isEqualToString:@"smooth"]) {
		[newGenomeEntity setValue:[NSNumber numberWithInt:1]  forKey:@"interpolation"];
	} else {
		[newGenomeEntity setValue:[NSNumber numberWithInt:0]  forKey:@"interpolation"];
	}

	tempAttribute = [genome objectForKey:@"interpolation_type"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[tempAttribute capitalizedString]  forKey:@"interpolation_type"];
	}

	tempAttribute = [genome objectForKey:@"motion_exponent"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]] forKey:@"temporal_filter_exp"];
		[newGenomeEntity setValue:@"Exponent"  forKey:@"temporal_filter_type"];
		[newGenomeEntity setValue:[NSNumber numberWithDouble:1.0] forKey:@"temporal_filter_width"];
	}



	tempAttribute = [genome objectForKey:@"filter"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithDouble:[tempAttribute doubleValue]]  forKey:@"spatial_filter_radius"];
	}

	tempAttribute = [genome objectForKey:@"filter_shape"];
	if(tempAttribute != nil) {

		NSString *spatial_filter_func = tempAttribute;

		if ([spatial_filter_func isEqualToString:@"bspline"]) {
			[newGenomeEntity setValue:@"B-Spline"  forKey:@"spatial_filter_func"];
		} else {
			[newGenomeEntity setValue:[spatial_filter_func capitalizedString]  forKey:@"spatial_filter_func"];
		}

	}

	tempAttribute = [genome objectForKey:@"palette"];
	if(tempAttribute != nil) {
	    [newGenomeEntity setValue:[NSNumber numberWithBool:YES]  forKey:@"use_palette"];
	} else {
	    [newGenomeEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"use_palette"];
	}


	tempAttribute = [genome objectForKey:@"palette_mode"];
	if(tempAttribute != nil) {
		[newGenomeEntity setValue:[tempAttribute capitalizedString] forKey:@"palette_mode"];
	}

	[newGenomeEntity autorelease];

	return newGenomeEntity;


}


+ (NSManagedObject *)createGenomeImageEntityFromAttributeDictionary:(NSDictionary *)genome inContext:(NSManagedObjectContext *)moc {

	NSManagedObject *newGenomeImageEntity = [Genome createDefaultGenomeImageEntityInContext:moc];
	NSString *tempAttribute;


	tempAttribute = [genome objectForKey:@"palette"];
	if(tempAttribute != nil) {
	    [newGenomeImageEntity setValue:[NSNumber numberWithInt:[tempAttribute intValue]]  forKey:@"palette"];
	}
//	[newGenomeImageEntity autorelease];

	return newGenomeImageEntity;


}


+ (NSManagedObject *)createTransformEntity:(NSString *)name fromAttributeDictionary:(NSDictionary *)xform atPosition:(int)position inContext:(NSManagedObjectContext *)moc {


	NSManagedObject *xFormEntity;
	NSString *tempObject;


	xFormEntity = [NSEntityDescription insertNewObjectForEntityForName:@"XForm" inManagedObjectContext:moc];

	[xFormEntity setValue:[NSNumber numberWithInt:position] forKey:@"order"];


	if([name isEqualToString:@"finalxform"]) {
		[xFormEntity setValue:[NSNumber numberWithBool:YES] forKey:@"final_xform"];
	} else {
		[xFormEntity setValue:[NSNumber numberWithBool:NO] forKey:@"final_xform"];
		tempObject = [xform objectForKey:@"weight"];
		if (tempObject != nil) {
			[xFormEntity setValue:[NSNumber numberWithDouble:[tempObject doubleValue]] forKey:@"density"];
		}
	}



	NSString *attribute = [xform objectForKey:@"coefs"];
	if (attribute != nil) {

		NSArray *split = [attribute componentsSeparatedByString:@" "];

		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:0] doubleValue]] forKey:@"coeff_0_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:1] doubleValue]] forKey:@"coeff_0_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:2] doubleValue]] forKey:@"coeff_1_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:3] doubleValue]] forKey:@"coeff_1_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:4] doubleValue]] forKey:@"coeff_2_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:[[split objectAtIndex:5] doubleValue]] forKey:@"coeff_2_1"];

	}


	double post[3][2] = {1.0, 0.0, 0.0, 1.0, 0.0, 0.0};

	[xFormEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"post_flag"];

	attribute = [xform objectForKey:@"post"];
	if (attribute != nil) {

		NSArray *split = [attribute componentsSeparatedByString:@" "];

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

	tempObject = [xform objectForKey:@"color"];
	if (tempObject != nil) {
		[xFormEntity setValue:[NSNumber numberWithDouble:[tempObject doubleValue]] forKey:@"colour_0"];
	}


	tempObject = [xform objectForKey:@"symmetry"];
	if (tempObject != nil) {
		[xFormEntity setValue:[NSNumber numberWithDouble:[tempObject doubleValue]] forKey:@"symmetry"];
	}

	[xFormEntity setValue:[Genome createVariationEntitiesFromAttributes:xform inContext:moc] forKey:@"variations"];

	//	return [xFormEntity autorelease];
	return xFormEntity;

}

+ (NSMutableSet *)createVariationEntitiesFromAttributes:(NSDictionary *)xform inContext:(NSManagedObjectContext *)moc {

	/* deal with the far to many ways that variations are defined */

	double weight;

	NSString *attribute;
	NSString *variationWeight;

	NSMutableSet *variationSet = [[NSMutableSet alloc] initWithCapacity:flam3_nvariations];

	attribute = [xform objectForKey:@"var"];
	if (attribute != nil) {
		NSArray *split = [attribute componentsSeparatedByString:@" "];
		int kind = 0;
		NSEnumerator *variations = [split objectEnumerator];
		while ((variationWeight = [variations nextObject]) && kind < flam3_nvariations) {
			weight = [variationWeight doubleValue];
			NSManagedObject *newVariation = [Genome createVariationEntityFromAttributeDictionary:xform ofVariationType:kind andWeight:weight inContext:moc];
			[variationSet addObject:newVariation];
			kind++;
		}
	} else if ((attribute = [xform objectForKey:@"var1"])) {

		int kind = [attribute  intValue];
		int i;
		NSManagedObject *newVariation;

		for (i = 0; i < flam3_nvariations; i++) {
			if (kind == i) {
				newVariation = [Genome createVariationEntityFromAttributeDictionary:xform
														   ofVariationType:i
																 andWeight:1.0
																 inContext:moc];
			} else {
				newVariation = [Genome createVariationEntityFromAttributeDictionary:xform
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

			if ((attribute = [xform objectForKey:variationName[i]])) {
				newVariation = [Genome  createVariationEntityFromAttributeDictionary:xform
														   ofVariationType:i
																 andWeight:[attribute doubleValue]
																 inContext:moc];
			} else {
				newVariation = [Genome createVariationEntityFromAttributeDictionary:xform
														   ofVariationType:i
																 andWeight:0.0
																 inContext:moc];
			}
			[variationSet addObject:newVariation];
		}


	}

	[variationSet autorelease];
	return variationSet;

}


+ (NSManagedObject *)createVariationEntityFromAttributeDictionary:(NSDictionary *)variationDictionary ofVariationType:(int)kind andWeight:(double)weight inContext:(NSManagedObjectContext *)moc {

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

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"blob_high"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"blob_low"] doubleValue]] forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"blob_waves"] doubleValue]] forKey:@"parameter_3"];

			[variation setValue:@"Blob High:" forKey:@"parameter_1_name"];
			[variation setValue:@"Blob Low:" forKey:@"parameter_2_name"];
			[variation setValue:@"Blob Wave:" forKey:@"parameter_3_name"];
			break;
		case 24:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"pdj_a"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"pdj_b"] doubleValue]] forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"pdj_c"] doubleValue]] forKey:@"parameter_3"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"pdj_d"] doubleValue]] forKey:@"parameter_4"];

			[variation setValue:@"PDJ A:" forKey:@"parameter_1_name"];
			[variation setValue:@"PDJ B:" forKey:@"parameter_2_name"];
			[variation setValue:@"PDJ C:" forKey:@"parameter_3_name"];
			[variation setValue:@"PDJ D:" forKey:@"parameter_4_name"];

			break;
		case 25:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"fan2_x"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"fan2_y"] doubleValue]] forKey:@"parameter_2"];

			[variation setValue:@"Fan2 x:" forKey:@"parameter_1_name"];
			[variation setValue:@"Fan2 y:" forKey:@"parameter_2_name"];

			break;
		case 26:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"rings2_val"] doubleValue]] forKey:@"parameter_1"];

			[variation setValue:@"Rings2:" forKey:@"parameter_1_name"];

			break;
		case 30:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"perspective_angle"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"perspective_dist"] doubleValue]] forKey:@"parameter_2"];

			[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
			[variation setValue:@"Distance:" forKey:@"parameter_2_name"];

			break;
		case 32:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"julian_dist"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"julian_power"] doubleValue]] forKey:@"parameter_2"];

			[variation setValue:@"Distance:" forKey:@"parameter_1_name"];
			[variation setValue:@"Power:" forKey:@"parameter_2_name"];

			break;
		case 33:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"juliascope_dist"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"juliascope_power"] doubleValue]] forKey:@"parameter_2"];

			[variation setValue:@"JS Distance:" forKey:@"parameter_1_name"];
			[variation setValue:@"Power:" forKey:@"parameter_2_name"];

			break;
		case 36:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];

			[variation setValue:@"Angle:" forKey:@"parameter_1_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"radial_blur_angle"] doubleValue]] forKey:@"parameter_1"];

			break;
		case 37:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];

			[variation setValue:@"Slices:" forKey:@"parameter_1_name"];
			[variation setValue:@"Rotation:" forKey:@"parameter_2_name"];
			[variation setValue:@"Thickness:" forKey:@"parameter_3_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"pie_slices"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"pie_rotation"] doubleValue]] forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"pie_thickness"] doubleValue]] forKey:@"parameter_3"];
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

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"ngon_sides"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"ngon_power"] doubleValue]] forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"ngon_circle"] doubleValue]] forKey:@"parameter_3"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"ngon_corners"] doubleValue]] forKey:@"parameter_4"];
			break;

		case 39:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"c1:" forKey:@"parameter_1_name"];
			[variation setValue:@"c2:" forKey:@"parameter_2_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"curl_c1"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"curl_c2"] doubleValue]] forKey:@"parameter_2"];
			break;

		case 40:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"x:" forKey:@"parameter_1_name"];
			[variation setValue:@"y:" forKey:@"parameter_2_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"rectangles_x"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"rectangles_y"] doubleValue]] forKey:@"parameter_2"];
			break;

		case 49:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Rotation:" forKey:@"parameter_1_name"];
			[variation setValue:@"Twist:" forKey:@"parameter_2_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"disc2_rot"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"disc2_twist"] doubleValue]] forKey:@"parameter_2"];
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

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"super_shape_rnd"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"super_shape_m"] doubleValue]] forKey:@"parameter_2"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"super_shape_n1"] doubleValue]] forKey:@"parameter_3"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"super_shape_n2"] doubleValue]] forKey:@"parameter_4"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"super_shape_n3"] doubleValue]] forKey:@"parameter_5"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"super_shape_holes"] doubleValue]] forKey:@"parameter_6"];
			break;

		case 51:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Petals:" forKey:@"parameter_1_name"];
			[variation setValue:@"Holes:" forKey:@"parameter_2_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"flower_petals"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"flower_holes"] doubleValue]] forKey:@"parameter_2"];
			break;

		case 52:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Eccentricity:" forKey:@"parameter_1_name"];
			[variation setValue:@"Holes:" forKey:@"parameter_2_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"conic_eccentricity"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"conic_holes"] doubleValue]] forKey:@"parameter_2"];
			break;

		case 53:
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];

			[variation setValue:@"Height:" forKey:@"parameter_1_name"];
			[variation setValue:@"Width:" forKey:@"parameter_2_name"];

			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"parabola_height"] doubleValue]] forKey:@"parameter_1"];
			[variation setValue:[NSNumber numberWithDouble:[[variationDictionary objectForKey:@"parabola_width"] doubleValue]] forKey:@"parameter_2"];
			break;

		default:
			break;
	}

//	[variation autorelease];

	return variation;
}


+ (NSManagedObject *) createColourMapFromAttributeDictionary:(NSDictionary *)colour inContext:(NSManagedObjectContext *)moc {

	int index;
	double red, green, blue;


	NSManagedObject *newColour = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:moc];

	index  = [[colour objectForKey:@"index"] intValue];

	NSString *tempString = [colour objectForKey:@"rgb"];
	NSArray *split = [tempString componentsSeparatedByString:@" "];

	red =   [[split objectAtIndex:0] doubleValue];
	green = [[split objectAtIndex:1] doubleValue];
	blue =  [[split objectAtIndex:2] doubleValue];

	red /= 255.0;
	green /= 255.0;
	blue /= 255.0;

	[newColour setValue:[NSNumber numberWithInt:index] forKey:@"index"];
	[newColour setValue:[NSNumber numberWithDouble:red] forKey:@"red"];
	[newColour setValue:[NSNumber numberWithDouble:green] forKey:@"green"];
	[newColour setValue:[NSNumber numberWithDouble:blue] forKey:@"blue"];

//	return [newColour autorelease];
	return newColour;

}

+ (void) addEditsFromAttributeDictionary:(NSDictionary *)edits toGenome:(NSManagedObject *)genomeEntity {


	/* create edit element with new details */
	[genomeEntity setValue:[edits objectForKey:@"nick"] forKey:@"nick"];
	[genomeEntity setValue:[edits objectForKey:@"url"] forKey:@"url"];
	[genomeEntity setValue:[edits objectForKey:@"comm"] forKey:@"comment"];

}


+ (void) AppendEditStringFromAttributeDictionary:(NSDictionary *)edits toString:(NSMutableString *)previousEdits {

	[previousEdits appendString:@"<edit "];

	if([edits objectForKey:@"nick"] != nil) {
		[previousEdits appendString:@"nick=\""];
		[previousEdits appendString:[edits objectForKey:@"nick"]];
		[previousEdits appendString:@"\" "];
	}

	if([edits objectForKey:@"url"] != nil) {
		[previousEdits appendString:@"url=\""];
		[previousEdits appendString:[edits objectForKey:@"url"]];
		[previousEdits appendString:@"\" "];
	}

	if([edits objectForKey:@"comment"] != nil) {
		[previousEdits appendString:@"comment=\""];
		[previousEdits appendString:[edits objectForKey:@"comment"]];
		[previousEdits appendString:@"\" "];
	}

	if([edits objectForKey:@"date"] != nil) {
		[previousEdits appendString:@"date=\""];
		[previousEdits appendString:[edits objectForKey:@"date"]];
		[previousEdits appendString:@"\" "];
	}

	if([edits objectForKey:@"action"] != nil) {
		[previousEdits appendString:@"action=\""];
		[previousEdits appendString:[edits objectForKey:@"action"]];
		[previousEdits appendString:@"\" "];
	}

	[previousEdits appendString:@">"];

}

@end
