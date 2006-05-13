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

@implementation Genome


	

+ (NSManagedObject *)createGenomeEntityFrom:(flam3_genome *)genome withImage:(NSImage *)image inContext:(NSManagedObjectContext *)moc {


	GenomeManagedObject *genomeEntity;

	/* create a genome entity */
	genomeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Genome" inManagedObjectContext:moc];

	if(genome->flame_name[0] != '\0') {
		[genomeEntity setValue:[NSString stringWithCString:genome->flame_name encoding:NSUTF8StringEncoding]  forKey:@"name"];
	} else {
		[genomeEntity setValue:@"wibble" forKey:@"name"];
	}
	
	if(genome->parent_fname[0] != '\0') {
		[genomeEntity setValue:[NSString stringWithCString:genome->parent_fname encoding:NSUTF8StringEncoding]  forKey:@"parent"];
	} else {
		[genomeEntity setValue:@"" forKey:@"parent"];
	}


	[genomeEntity setValue:[NSNumber numberWithDouble:genome->time]  forKey:@"time"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->palette_index]  forKey:@"palette"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->height]  forKey:@"height"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->width]  forKey:@"width"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->center[0]]  forKey:@"centre_x"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->center[1]]  forKey:@"centre_y"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->zoom]  forKey:@"zoom"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->pixels_per_unit]  forKey:@"scale"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->spatial_oversample]  forKey:@"oversample"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->sample_density]  forKey:@"quality"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->nbatches]  forKey:@"batches"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->ntemporal_samples]  forKey:@"jitter"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->estimator_curve]  forKey:@"de_alpha"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->estimator]  forKey:@"de_max_filter"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->estimator_minimum]  forKey:@"de_min_filter"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->gamma]  forKey:@"gamma"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->gam_lin_thresh]  forKey:@"gamma_threshold"];
	[genomeEntity setValue:[NSColor colorWithDeviceRed:genome->background[0] green:genome->background[1] blue:genome->background[2] alpha:1.0]  forKey:@"background"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->hue_rotation]  forKey:@"hue"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->vibrancy]  forKey:@"vibrancy"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->brightness]  forKey:@"brightness"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->rotate]  forKey:@"rotate"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->spatial_filter_radius]  forKey:@"filter"];

	[genomeEntity setValue:[NSNumber numberWithDouble:genome->contrast]  forKey:@"contrast"];
	[genomeEntity setValue:[Genome  getStringSymmetry:genome->symmetry]  forKey:@"symmetry"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->interpolation]  forKey:@"interpolation"];


	if(genome->edits != NULL) {
	
		xmlChar *doc;
		int xmlSize;
	
		xmlDocDumpMemory(genome->edits, &doc, &xmlSize); 

		NSAttributedString *edits = [[NSAttributedString alloc] initWithString:[NSString stringWithCString:doc encoding:NSUTF8StringEncoding]];		
		[genomeEntity setValue:edits forKey:@"edits"];
		[edits release];
	} else {
		NSAttributedString *edits = [[NSAttributedString alloc] initWithString:@""];		
		[genomeEntity setValue:edits forKey:@"edits"];
	}
	
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];

	[genomeEntity setValue:[defaults stringForKey:@"nick"] forKey:@"nick"];
	[genomeEntity setValue:[defaults stringForKey:@"url"] forKey:@"url"];
	[genomeEntity setValue:[defaults stringForKey:@"comment"] forKey:@"comment"];

	[genomeEntity setValue:image forKey:@"image"];
	
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
	[PaletteController fillBitmapRep:paletteWithHueRep withPalette:genome->palette_index usingHue:genome->hue_rotation];
	[paletteImage addRepresentation:paletteWithHueRep];
	
	[genomeEntity setValue:paletteImage forKey:@"palette_image"];	
		
	[paletteWithHueRep release];
	[paletteImage release];
																										  												  													  

	
	[genomeEntity setValue:[Genome createXFormEntitySetFromCGenome:genome inContext:moc] forKey:@"xforms"];


    if(genome->palette_index < 0) {
		[genomeEntity setValue:[NSNumber numberWithBool:NO] forKey:@"use_palette"];
		// use the cmap 	
		[genomeEntity setValue:[Genome createCMapEntitySetFromCGenome:genome inContext:moc] forKey:@"cmap"];
	} else {
		[genomeEntity setValue:[NSNumber numberWithBool:YES] forKey:@"use_palette"];
		[genomeEntity setValue:nil forKey:@"cmap"];
	}

//	[genomeEntity autorelease];

	return genomeEntity;

}

+ (NSMutableSet *)createXFormEntitySetFromCGenome:(flam3_genome *)genome inContext:(NSManagedObjectContext *)moc {

	NSManagedObject *xFormEntity;
	
	NSMutableSet *xforms; 
	NSMutableSet *variations; 
	
	NSMutableString *name;
	
	int i, j;
	flam3_xform *xform;

	/* create a genome entity */

	xforms = [[NSMutableSet alloc] initWithCapacity:genome->num_xforms];
	
	for(i=0; i<genome->num_xforms; i++) {
		xFormEntity = [NSEntityDescription insertNewObjectForEntityForName:@"XForm" inManagedObjectContext:moc];

		xform = genome->xform+i;

		[xFormEntity setValue:[NSNumber numberWithInt:i] forKey:@"order"];
		
				//genome->
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->density] forKey:@"density"];

		[xFormEntity setValue:[NSNumber numberWithDouble:xform->c[0][0]] forKey:@"coeff_0_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->c[0][1]] forKey:@"coeff_0_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->c[1][0]] forKey:@"coeff_1_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->c[1][1]] forKey:@"coeff_1_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->c[2][0]] forKey:@"coeff_2_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->c[2][1]] forKey:@"coeff_2_1"];

		[xFormEntity setValue:[NSNumber numberWithDouble:xform->color[0]] forKey:@"colour_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->color[1]] forKey:@"colour_1"];
		
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->post[0][0]] forKey:@"post_0_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->post[0][1]] forKey:@"post_0_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->post[1][0]] forKey:@"post_1_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->post[1][1]] forKey:@"post_1_1"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->post[2][0]] forKey:@"post_2_0"];
		[xFormEntity setValue:[NSNumber numberWithDouble:xform->post[2][1]] forKey:@"post_2_1"];

		[xFormEntity setValue:[NSNumber numberWithDouble:xform->symmetry] forKey:@"symmetry"];

/*		if(xform->post_flag == 1) {
			[xFormEntity setValue:[NSNumber numberWithBool:YES] forKey:@"post_flag"];
		} else {
			[xFormEntity setValue:[NSNumber numberWithBool:NO] forKey:@"post_flag"];
		}
*/					
		
		name = [[NSMutableString alloc] init];
		
		for(j=0; j<flam3_nvariations; j++) {

			if(xform->var[j] != 0.0) {
				[name appendFormat:@"%@ ", [NSString stringWithCString:flam3_variation_names[j] encoding:NSUTF8StringEncoding]]; 
			}
		}	

		[xFormEntity setValue:name forKey:@"name"];
		[name release];
		
		variations = [Genome createVariationsEntitySetFromCXForm:xform inContext:moc];	
		[xFormEntity setValue:variations forKey:@"variations"];
//		[variations release];
		
		if(genome->final_xform_index == i && genome->final_xform_enable == 1) {
			[xFormEntity setValue:[NSNumber numberWithBool:YES] forKey:@"final_xform"];
		} else {
			[xFormEntity setValue:[NSNumber numberWithBool:NO] forKey:@"final_xform"];
		}

		[xforms addObject:xFormEntity];
	
		[xFormEntity release];
	}
	
//	[xforms autorelease];
	return xforms;

}

+ (NSMutableSet *)createVariationsEntitySetFromCXForm:(flam3_xform *)xform inContext:(NSManagedObjectContext *)moc {

	NSMutableSet *variations;
	NSManagedObject *variation;
	int j;
	
	

	/* create a genome entity */

	variations = [[NSMutableSet alloc] initWithCapacity:flam3_nvariations];

	for(j=0; j<flam3_nvariations; j++) {
		variation = [NSEntityDescription insertNewObjectForEntityForName:@"Variations" inManagedObjectContext:moc];
		
		[variation setValue:[NSString stringWithCString:flam3_variation_names[j] encoding:NSUTF8StringEncoding] forKey:@"name"]; 
		[variation setValue:[NSNumber numberWithInt:j] forKey:@"variation_index"];

		if(xform->var[j] != 0.0) {
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"in_use"];
		} else {
			[variation setValue:[NSNumber numberWithBool:NO] forKey:@"in_use"];
		}
		[variation setValue:[NSNumber numberWithDouble:xform->var[j]] forKey:@"weight"];					
		switch(j) {
			case 23:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:xform->blob_high] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->blob_low] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:xform->blob_waves] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


				[variation setValue:@"Blob High:" forKey:@"parameter_1_name"];
				[variation setValue:@"Blob Low:" forKey:@"parameter_2_name"];
				[variation setValue:@"Blob Wave:" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				break;
			case 24:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:xform->pdj_a] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->pdj_b] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:xform->pdj_c] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:xform->pdj_d] forKey:@"parameter_4"];


				[variation setValue:@"PDJ A:" forKey:@"parameter_1_name"];
				[variation setValue:@"PDJ B:" forKey:@"parameter_2_name"];
				[variation setValue:@"PDJ C:" forKey:@"parameter_3_name"];
				[variation setValue:@"PDJ D:" forKey:@"parameter_4_name"];

				break;
			case 25:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:xform->fan2_x] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->fan2_y] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


				[variation setValue:@"Fan2 x:" forKey:@"parameter_1_name"];
				[variation setValue:@"Fan2 y:" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;				
			case 26:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:xform->rings2_val] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


				[variation setValue:@"Rings2:" forKey:@"parameter_1_name"];
				[variation setValue:@"parameter 2" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;
			case 30:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:xform->perspective_angle] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->perspective_dist] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


				[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
				[variation setValue:@"Distance:" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;
			case 32:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:xform->juliaN_dist] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->juliaN_power] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


				[variation setValue:@"Distance:" forKey:@"parameter_1_name"];
				[variation setValue:@"Power:" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;
			case 33:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:xform->juliaScope_dist] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->juliaScope_power] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


				[variation setValue:@"JS Distance:" forKey:@"parameter_1_name"];
				[variation setValue:@"Power:" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;
			default:
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


				[variation setValue:@"parameter 1" forKey:@"parameter_1_name"];
				[variation setValue:@"parameter 2" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				break;
		}
		[variations addObject:variation];
		[variation release];

	}

	[variations autorelease];
	return variations;
	
}

+ (NSMutableSet *)createCMapEntitySetFromCGenome:(flam3_genome *)genome inContext:(NSManagedObjectContext *)moc {

	int i;
	NSManagedObject *newColour;
	NSMutableSet *colours = [[NSMutableSet alloc] initWithCapacity:256];
	
	for(i=0; i<256; i++) {
		
		newColour = [NSEntityDescription insertNewObjectForEntityForName:@"CMap" inManagedObjectContext:moc];

		[newColour setValue:[NSNumber numberWithInt:i] forKey:@"index"];
		[newColour setValue:[NSNumber numberWithInt:(int)(genome->palette[i][0] * 255.0)] forKey:@"red"];
		[newColour setValue:[NSNumber numberWithInt:(int)(genome->palette[i][1] * 255.0)] forKey:@"green"];
		[newColour setValue:[NSNumber numberWithInt:(int)(genome->palette[i][2] * 255.0)] forKey:@"blue"];
		[colours addObject:newColour];
		[newColour release];
	}
	
	[colours autorelease];
	return colours;
}



+ (flam3_genome *)populateAllCGenomesFromEntities:(NSArray *)entities fromContext:(NSManagedObjectContext *)moc {

	int genomeCount, i;
	flam3_genome *cGenomes;
	
	 genomeCount = [entities count];
	 
	 cGenomes = (flam3_genome *)malloc(sizeof(flam3_genome) * genomeCount);
	 
	 for(i=0; i<genomeCount; i++) {
	 
		[Genome populateCGenome:cGenomes+i FromEntity:[entities objectAtIndex:i]  fromContext:moc];
		cGenomes[i].genome_index = i;
	 }

	return cGenomes;
}



+ (void )populateCGenome:(flam3_genome *)newGenome FromEntity:(NSManagedObject *)genomeEntity fromContext:(NSManagedObjectContext *)moc {


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
		strncpy(newGenome->flame_name, [tempString cStringUsingEncoding:NSUTF8StringEncoding], flam3_name_len);
	} else {
		newGenome->flame_name[0] = '\0'; 
	}

	newGenome->flame_name[flam3_name_len + 1] = '\0';

	tempString = [genomeEntity valueForKey:@"parent"];
	if(tempString != nil) {
		strncpy(newGenome->parent_fname, [tempString cStringUsingEncoding:NSUTF8StringEncoding], flam3_name_len);
	} else {
		newGenome->flame_name[0] = '\0'; 
	}
	newGenome->parent_fname[flam3_name_len + 1] = '\0';

	newGenome->time = [[genomeEntity valueForKey:@"time"] doubleValue];
	newGenome->height = [[genomeEntity valueForKey:@"height"] intValue];
	newGenome->width = [[genomeEntity valueForKey:@"width"] intValue];
	newGenome->center[0] = [[genomeEntity valueForKey:@"centre_x"] doubleValue];
	newGenome->center[1] = [[genomeEntity valueForKey:@"centre_y"] doubleValue];
	newGenome->rot_center[0] = newGenome->center[0];
	newGenome->rot_center[1] = newGenome->center[1];
	newGenome->zoom = [[genomeEntity valueForKey:@"zoom"] doubleValue];
	newGenome->pixels_per_unit = [[genomeEntity valueForKey:@"scale"] doubleValue];
	newGenome->spatial_oversample = [[genomeEntity valueForKey:@"oversample"] intValue];
	newGenome->sample_density = [[genomeEntity valueForKey:@"quality"] doubleValue];
	newGenome->nbatches = [[genomeEntity valueForKey:@"batches"] intValue];
	newGenome->ntemporal_samples = [[genomeEntity valueForKey:@"jitter"] intValue];
	newGenome->estimator_curve = [[genomeEntity valueForKey:@"de_alpha"] doubleValue];
	newGenome->estimator = [[genomeEntity valueForKey:@"de_max_filter"] doubleValue];
	newGenome->estimator_minimum = [[genomeEntity valueForKey:@"de_min_filter"] doubleValue];
	newGenome->gamma = [[genomeEntity valueForKey:@"gamma"] doubleValue];
	newGenome->gam_lin_thresh = [[genomeEntity valueForKey:@"gamma_threshold"] doubleValue];
	[[genomeEntity valueForKey:@"background"] getRed:&red green:&green blue:&blue alpha:NULL];
	newGenome->background[0] = (double)red;
	newGenome->background[1] = (double)green;
	newGenome->background[2] = (double)blue;
	newGenome->hue_rotation = [[genomeEntity valueForKey:@"hue"] doubleValue];
	newGenome->vibrancy = [[genomeEntity valueForKey:@"vibrancy"] doubleValue];
	newGenome->brightness = [[genomeEntity valueForKey:@"brightness"] doubleValue];
	newGenome->rotate = [[genomeEntity valueForKey:@"rotate"] doubleValue];
	newGenome->spatial_filter_radius = [[genomeEntity valueForKey:@"filter"] doubleValue];

	newGenome->contrast = [[genomeEntity valueForKey:@"contrast"] doubleValue];
	newGenome->symmetry = [Genome getIntSymmetry:[genomeEntity valueForKey:@"symmetry"]];
	newGenome->interpolation = [[genomeEntity valueForKey:@"interpolation"] intValue];
	
	newGenome->edits = [Genome populateCEditDocFromEntity:genomeEntity];

	if([[genomeEntity valueForKey:@"use_palette"] boolValue] == FALSE) {
		newGenome->palette_index = -1;
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
		if([cmaps count] < 255) {
			NSMutableArray *newCmaps = [PaletteController extrapolateArray:cmaps];
			[newCmaps retain];
			[Genome populateCMap:newGenome->palette FromEntityArray:newCmaps];
			[newCmaps release];
		} else {
			[Genome populateCMap:newGenome->palette FromEntityArray:cmaps];
		}
	} else {
		newGenome->palette_index = [[genomeEntity valueForKey:@"palette"] intValue];
		flam3_get_palette(newGenome->palette_index, newGenome->palette, newGenome->hue_rotation);
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
	
	newGenome->num_xforms = [xforms count];
	newGenome->xform = (flam3_xform *)malloc(sizeof(flam3_xform) * newGenome->num_xforms);
	
	
	newGenome->final_xform_index = -1;		
	for(i=0; i<newGenome->num_xforms; i++) {
	
		[Genome poulateXForm:newGenome->xform+i FromEntity:[xforms objectAtIndex:i] fromContext:moc];
		if([[[xforms objectAtIndex:i] valueForKey:@"final_xform"] boolValue] == YES) {
			newGenome->final_xform_index = i;
		}
	
	}
	
	if(newGenome->final_xform_index != -1) {
		newGenome->final_xform_enable = 1;
	} else {
		newGenome->final_xform_enable = 0;
	}		
	
	if(newGenome->symmetry != 0) {
		flam3_add_symmetry(newGenome, newGenome->symmetry);
	}
	
	return;
}

+ (void )poulateXForm:(flam3_xform *)xform FromEntity:(NSManagedObject *)xformEntity fromContext:(NSManagedObjectContext *)moc {


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

	[Genome poulateVariations:xform FromEntityArray:variations];
	
	xform->density = [[xformEntity valueForKey:@"density"] doubleValue];
	
	xform->c[0][0] = [[xformEntity valueForKey:@"coeff_0_0"] doubleValue];
	xform->c[0][1] = [[xformEntity valueForKey:@"coeff_0_1"] doubleValue];
	xform->c[1][0] = [[xformEntity valueForKey:@"coeff_1_0"] doubleValue];
	xform->c[1][1] = [[xformEntity valueForKey:@"coeff_1_1"] doubleValue];
	xform->c[2][0] = [[xformEntity valueForKey:@"coeff_2_0"] doubleValue];
	xform->c[2][1] = [[xformEntity valueForKey:@"coeff_2_1"] doubleValue];
	
	xform->post[0][0] = [[xformEntity valueForKey:@"post_0_0"] doubleValue];
	xform->post[0][1] = [[xformEntity valueForKey:@"post_0_1"] doubleValue];
	xform->post[1][0] = [[xformEntity valueForKey:@"post_1_0"] doubleValue];
	xform->post[1][1] = [[xformEntity valueForKey:@"post_1_1"] doubleValue];
	xform->post[2][0] = [[xformEntity valueForKey:@"post_2_0"] doubleValue];
	xform->post[2][1] = [[xformEntity valueForKey:@"post_2_1"] doubleValue];

	xform->color[0] = [[xformEntity valueForKey:@"colour_0"] doubleValue];
	xform->color[1] = [[xformEntity valueForKey:@"colour_1"] doubleValue];

	xform->symmetry  = [[xformEntity valueForKey:@"symmetry"] doubleValue];
	
	/*	
	if( [[xformEntity valueForKey:@"post_flag"] boolValue] == YES) {
		xform->post_flag = 1;
	} else {
		xform->post_flag = 0;
	}
	*/
	return;


}

+ (void )poulateVariations:(flam3_xform *)xform FromEntityArray:(NSArray *)variations {

	int i;

	NSManagedObject *variation;

	for(i=0; i<flam3_nvariations; i++) {
		variation = [variations objectAtIndex:i];
		
		if([[variation valueForKey:@"in_use"] boolValue] == YES) {
			xform->var[i] = [[variation valueForKey:@"weight"] doubleValue];
		} else {
			xform->var[i] = 0.0;
		}
		
		switch(i) {
			case 23:
				xform->blob_high = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->blob_low = [[variation valueForKey:@"parameter_2"] doubleValue];
				xform->blob_waves = [[variation valueForKey:@"parameter_3"] doubleValue];
				break;
			case 24:
				xform->pdj_a = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->pdj_b = [[variation valueForKey:@"parameter_2"] doubleValue];
				xform->pdj_c = [[variation valueForKey:@"parameter_3"] doubleValue];
				xform->pdj_d = [[variation valueForKey:@"parameter_4"] doubleValue];
				break;
			case 25:
				xform->fan2_x = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->fan2_y = [[variation valueForKey:@"parameter_2"] doubleValue];
				break;				
			case 26:
				xform->rings2_val = [[variation valueForKey:@"parameter_1"] doubleValue];
				break;
			case 30:
				xform->perspective_angle = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->perspective_dist = [[variation valueForKey:@"parameter_2"] doubleValue];
				break;
			case 32:
				xform->juliaN_power = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->juliaN_dist = [[variation valueForKey:@"parameter_2"] doubleValue];
				break;
			case 33:
				xform->juliaScope_power = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->juliaScope_dist = [[variation valueForKey:@"parameter_2"] doubleValue];
				break;	
			default:
				break;

		}
	}


}

+ (void )populateCMap:(flam3_palette )cmap FromEntityArray:(NSArray *)cmaps {

		NSManagedObject *colour;
		int i;
		
		for(i=0; i<256; i++) {
		
			colour = [cmaps objectAtIndex:i];
			cmap[i][0] = [[colour valueForKey:@"red"]   doubleValue] / 255.0;
			cmap[i][1] = [[colour valueForKey:@"green"] doubleValue] / 255.0;
			cmap[i][2] = [[colour valueForKey:@"blue"]  doubleValue] / 255.0;	

		}

}


+ (xmlDocPtr) populateCEditDocFromEntity:(NSManagedObject *)genome {
   
	NSXMLElement *newEditElement;
	NSXMLElement *oldRootElement;
	NSXMLDocument *oldDoc = nil;
	NSError *xmlError;
	NSString *date;
	NSString *oldDocAsXML;
	NSString *newDocAsXML;

	xmlDocPtr newEdit;

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


	/* now create the libxml2 Doc */
	newDocAsXML = [newEditElement XMLString];    
	newEdit = xmlParseMemory([newDocAsXML cStringUsingEncoding:NSUTF8StringEncoding], [newDocAsXML cStringLength]); 

	if(oldDoc != nil) {
		[oldDoc release];
	}
	[date release];

	/* return the xml doc */   	
	return(newEdit);
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
/*		case 0:
			return @"Random";
			break;*/
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


		[genomeEntity setValue:[Genome createDefaultXFormEntitySetInContext:moc] forKey: @"xforms"];
		
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

	for(j=0; j<flam3_nvariations; j++) {
		variation = [NSEntityDescription insertNewObjectForEntityForName:@"Variations" inManagedObjectContext:moc];
		
		[variation setValue:[NSString stringWithCString:flam3_variation_names[j] encoding:NSUTF8StringEncoding] forKey:@"name"]; 
		[variation setValue:[NSNumber numberWithInt:j] forKey:@"variation_index"];

		if(j == 0) {
			[variation setValue:[NSNumber numberWithBool:YES] forKey:@"in_use"];
			[variation setValue:[NSNumber numberWithDouble:1.0] forKey:@"weight"];					
		} else {
			[variation setValue:[NSNumber numberWithBool:NO] forKey:@"in_use"];
			[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"weight"];					

		}

		[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_1"];
		[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_2"];
		[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
		[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];

		switch(j) {
			case 23:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];



				[variation setValue:@"Blob High:" forKey:@"parameter_1_name"];
				[variation setValue:@"Blob Low:" forKey:@"parameter_2_name"];
				[variation setValue:@"Blob Wave:" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				break;
			case 24:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];


				[variation setValue:@"PDJ A:" forKey:@"parameter_1_name"];
				[variation setValue:@"PDJ B:" forKey:@"parameter_2_name"];
				[variation setValue:@"PDJ C:" forKey:@"parameter_3_name"];
				[variation setValue:@"PDJ D:" forKey:@"parameter_4_name"];

				break;
			case 25:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:@"Fan2 x:" forKey:@"parameter_1_name"];
				[variation setValue:@"Fan2 y:" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;				
			case 26:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];


				[variation setValue:@"Rings2:" forKey:@"parameter_1_name"];
				[variation setValue:@"parameter 2" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;
			case 30:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
				[variation setValue:@"Distance:" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];

				break;
			default:
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:@"parameter 1" forKey:@"parameter_1_name"];
				[variation setValue:@"parameter 2" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				break;
		}
		[variations addObject:variation];
		[variation release];

	}

	[variations autorelease];
	return variations;
} 




@end

