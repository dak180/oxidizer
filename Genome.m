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

- (void)createGenomeEntity {

	[self setGenomeEntity:[Genome createGenomeEntityFrom:_genome withImage:_image inContext:_moc]];
	
	return;
}
	

+ (NSManagedObject *)createGenomeEntityFrom:(flam3_genome *)genome withImage:(NSImage *)image inContext:(NSManagedObjectContext *)moc {


	GenomeManagedObject *genomeEntity;

	/* create a genome entity */
	genomeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Genome" inManagedObjectContext:moc];

	if(genome->flame_name[0] != '\0') {
		[genomeEntity setValue:[NSString stringWithCString:genome->flame_name encoding:NSUTF8StringEncoding]  forKey:@"name"];
	} else {
		[genomeEntity setValue:@"Oxidizer" forKey:@"name"];
	}
	
	if(genome->parent_fname[0] != '\0') {
		[genomeEntity setValue:[NSString stringWithCString:genome->parent_fname encoding:NSUTF8StringEncoding]  forKey:@"parent"];
	} else {
		[genomeEntity setValue:@"" forKey:@"parent"];
	}


	[genomeEntity setValue:[NSNumber numberWithDouble:genome->time]  forKey:@"time"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->palette_index]  forKey:@"palette"];
	[genomeEntity setValue:[NSNumber numberWithBool:FALSE]  forKey:@"aspect_lock"];	
	[genomeEntity setValue:[NSNumber numberWithInt:genome->height]  forKey:@"height"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->width]  forKey:@"width"];
	[genomeEntity setValue:[NSNumber numberWithDouble:genome->width/(double)genome->height]  forKey:@"aspect_lock_aspect"];
	[genomeEntity setValue:[NSNumber numberWithBool:TRUE]  forKey:@"aspect_lock"];	
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

	[genomeEntity setValue:[NSNumber numberWithDouble:genome->contrast]  forKey:@"contrast"];
	[genomeEntity setValue:[Genome  getStringSymmetry:genome->symmetry]  forKey:@"symmetry"];
	[genomeEntity setValue:[NSNumber numberWithInt:genome->interpolation]  forKey:@"interpolation"];

	[genomeEntity setValue:[NSNumber numberWithDouble:genome->motion_exp]  forKey:@"motion_exp"];

	[genomeEntity setValue:[NSNumber numberWithDouble:genome->spatial_filter_radius]  forKey:@"spatial_filter_radius"];
	if (genome->spatial_filter_func == Gaussian_filter) {
	   [genomeEntity setValue:@"Gaussian"  forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == hermite_filter) {
	   [genomeEntity setValue:@"Hermite" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == box_filter) {
		[genomeEntity setValue:@"Box" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == triangle_filter) {
		[genomeEntity setValue:@"Triangle" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == bell_filter) {
		[genomeEntity setValue:@"Bell" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == B_spline_filter) {
		[genomeEntity setValue:@"B-Spline" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == Mitchell_filter) {
		[genomeEntity setValue:@"Mitchell" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == Blackman_filter) {
		[genomeEntity setValue:@"Blackman" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == Catrom_filter) {
		[genomeEntity setValue:@"Catrom" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == Hanning_filter) {
		[genomeEntity setValue:@"Hanning" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == Hamming_filter) {
		[genomeEntity setValue:@"Hamming" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == Lanczos3_filter) {
		[genomeEntity setValue:@"Lanczos3" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == Lanczos2_filter) {
		[genomeEntity setValue:@"Lanczos2" forKey:@"spatial_filter_func"];
	} else if (genome->spatial_filter_func == quadratic_filter) {
		[genomeEntity setValue:@"Quadratic" forKey:@"spatial_filter_func"];
	}	

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

	NSImage *colourMapImage = [[NSImage alloc] init];
	NSBitmapImageRep *colourMapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
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

	
	
    if(genome->palette_index < 0) {
		[PaletteController fillBitmapRep:colourMapImageRep withPalette:genome->palette];
		[colourMapImage addRepresentation:colourMapImageRep];
		[PaletteController fillBitmapRep:paletteWithHueRep withPalette:0 usingHue:0.0];
		[paletteImage addRepresentation:paletteWithHueRep];
		[genomeEntity setValue:colourMapImage forKey:@"colour_map_image"];	
		[genomeEntity setValue:[NSNumber numberWithBool:NO] forKey:@"use_palette"];
		// use the cmap 	
		[genomeEntity setValue:[Genome createCMapEntitySetFromCGenome:genome inContext:moc] forKey:@"cmap"];		
		[genomeEntity setValue:paletteImage forKey:@"palette_image"];	
	} else {
		[PaletteController fillBitmapRep:paletteWithHueRep withPalette:genome->palette_index usingHue:genome->hue_rotation];
		[paletteImage addRepresentation:paletteWithHueRep];
		[genomeEntity setValue:paletteImage forKey:@"palette_image"];	
		[genomeEntity setValue:[NSNumber numberWithBool:YES] forKey:@"use_palette"];
		[genomeEntity setValue:nil forKey:@"cmap"];
	}
		
	[paletteWithHueRep release];
	[paletteImage release];
																										  												  													  

	
	[genomeEntity setValue:[Genome createXFormEntitySetFromCGenome:genome inContext:moc] forKey:@"xforms"];



	return genomeEntity;

}

+ (NSMutableSet *)createXFormEntitySetFromCGenome:(flam3_genome *)genome inContext:(NSManagedObjectContext *)moc {

	NSManagedObject *xFormEntity;
	
	NSMutableSet *xforms; 
	NSMutableSet *variations; 
	
	NSMutableString *name;
	
	int i, j, order;
	flam3_xform *xform;

	/* create a genome entity */

	xforms = [[NSMutableSet alloc] initWithCapacity:genome->num_xforms];
	
	order = 1;
	
	for(i=0; i<genome->num_xforms; i++) {
		
		xform = genome->xform+i;

		if ((xform->density > 0.0 || i==genome->final_xform_index) && !(genome->symmetry &&  xform->symmetry == 1.0)) {
			
		
		xFormEntity = [NSEntityDescription insertNewObjectForEntityForName:@"XForm" inManagedObjectContext:moc];


		[xFormEntity setValue:[NSNumber numberWithInt:order] forKey:@"order"];
		order++;
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
		
		if ((xform->post[0][0] == 1.0) &&
			  (xform->post[0][1] == 0.0) &&
			  (xform->post[1][0] == 0.0) &&
			  (xform->post[1][1] == 1.0) &&
			  (xform->post[2][0] == 0.0) &&
			  (xform->post[2][1] == 0.0)) {
			[xFormEntity setValue:[NSNumber numberWithBool:NO]  forKey:@"post_flag"];
		} else {
			[xFormEntity setValue:[NSNumber numberWithBool:YES]  forKey:@"post_flag"];
			
		}
		
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
			case 36:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

				[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
				[variation setValue:@"parameter 2" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				
				[variation setValue:[NSNumber numberWithDouble:xform->radialBlur_angle] forKey:@"parameter_1"];

				break;	
			case 37:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];
				
				[variation setValue:@"Slices:" forKey:@"parameter_1_name"];
				[variation setValue:@"Rotation:" forKey:@"parameter_2_name"];
				[variation setValue:@"Thickness:" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				
				[variation setValue:[NSNumber numberWithDouble:xform->pie_slices] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->pie_rotation] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:xform->pie_thickness] forKey:@"parameter_3"];

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
				
				[variation setValue:[NSNumber numberWithDouble:xform->ngon_sides] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->ngon_power] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:xform->ngon_circle] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:xform->ngon_corners] forKey:@"parameter_4"];

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

		[newColour setValue:[NSNumber numberWithDouble:genome->palette[i][0]] forKey:@"red"];
		[newColour setValue:[NSNumber numberWithDouble:genome->palette[i][1]] forKey:@"green"];
		[newColour setValue:[NSNumber numberWithDouble:genome->palette[i][2]] forKey:@"blue"];
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
	newGenome->rot_center[0] = [[genomeEntity valueForKey:@"centre_x"] doubleValue];
	newGenome->rot_center[1] = [[genomeEntity valueForKey:@"centre_y"] doubleValue];

	newGenome->contrast = [[genomeEntity valueForKey:@"contrast"] doubleValue];
	newGenome->symmetry = [Genome getIntSymmetry:[genomeEntity valueForKey:@"symmetry"]];
	newGenome->interpolation = [[genomeEntity valueForKey:@"interpolation"] intValue];
		
	newGenome->motion_exp             = [[genomeEntity valueForKey:@"motion_exp"] doubleValue];

	newGenome->spatial_filter_radius = [[genomeEntity valueForKey:@"spatial_filter_radius"] doubleValue];
	if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Gaussian"]) {
			newGenome->spatial_filter_func = Gaussian_filter;
			newGenome->spatial_filter_support = Gaussian_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Hermite"]) {
			newGenome->spatial_filter_func = hermite_filter;
			newGenome->spatial_filter_support = hermite_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Box"]) {
			newGenome->spatial_filter_func = box_filter;
			newGenome->spatial_filter_support = box_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Triangle"]) {
			newGenome->spatial_filter_func = triangle_filter;
			newGenome->spatial_filter_support = triangle_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Bell"]) {
			newGenome->spatial_filter_func = bell_filter;
			newGenome->spatial_filter_support = bell_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"B-Spline"]) {
			newGenome->spatial_filter_func = B_spline_filter;
			newGenome->spatial_filter_support = B_spline_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Mitchell"]) {
			newGenome->spatial_filter_func = Mitchell_filter;
			newGenome->spatial_filter_support = Mitchell_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Blackman"]) {
			newGenome->spatial_filter_func = Blackman_filter;
			newGenome->spatial_filter_support = Blackman_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Catrom"]) {
			newGenome->spatial_filter_func = Catrom_filter;
			newGenome->spatial_filter_support = Catrom_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Hanning"]) {
			newGenome->spatial_filter_func = Hanning_filter;
			newGenome->spatial_filter_support = Hanning_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Hamming"]) {
			newGenome->spatial_filter_func = Hamming_filter;
			newGenome->spatial_filter_support = Hamming_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Lanczos3"]) {
			newGenome->spatial_filter_func = Lanczos3_filter;
			newGenome->spatial_filter_support = Lanczos3_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Lanczos2"]) {
			newGenome->spatial_filter_func = Lanczos2_filter;
			newGenome->spatial_filter_support = Lanczos2_support;
	} else if ([[genomeEntity valueForKey:@"spatial_filter_func"] isEqualToString:@"Quadratic"]) {
			newGenome->spatial_filter_func = quadratic_filter;
			newGenome->spatial_filter_support = quadratic_support;
	}	
	
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
	
	int old_num_xforms = [xforms count];

	newGenome->num_xforms = 0;
	
	if(newGenome->symmetry != 0) {
		flam3_add_symmetry(newGenome, newGenome->symmetry);
		newGenome->xform = (flam3_xform *)realloc(newGenome->xform, sizeof(flam3_xform) * (newGenome->num_xforms + old_num_xforms));
	} else {
		newGenome->xform = (flam3_xform *)malloc(sizeof(flam3_xform) * old_num_xforms);		
	}
	
	newGenome->final_xform_index = -1;		
	for(i=0; i < old_num_xforms; i++) {
	
		[Genome poulateXForm:newGenome->xform+i+newGenome->num_xforms FromEntity:[xforms objectAtIndex:i] fromContext:moc];
		if([[[xforms objectAtIndex:i] valueForKey:@"final_xform"] boolValue] == YES) {
			newGenome->final_xform_index = i+newGenome->num_xforms;
		}
	
	}
	
	newGenome->num_xforms += old_num_xforms;
	
	if(newGenome->final_xform_index != -1) {
		newGenome->final_xform_enable = 1;
	} else {
		newGenome->final_xform_enable = 0;
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
	
	xform->density = [[xformEntity valueForKey:@"density"] doubleValue];
	
	xform->c[0][0] = [[xformEntity valueForKey:@"coeff_0_0"] doubleValue];
	xform->c[0][1] = [[xformEntity valueForKey:@"coeff_0_1"] doubleValue];
	xform->c[1][0] = [[xformEntity valueForKey:@"coeff_1_0"] doubleValue];
	xform->c[1][1] = [[xformEntity valueForKey:@"coeff_1_1"] doubleValue];
	xform->c[2][0] = [[xformEntity valueForKey:@"coeff_2_0"] doubleValue];
	xform->c[2][1] = [[xformEntity valueForKey:@"coeff_2_1"] doubleValue];
	
	if([[xformEntity valueForKey:@"post_flag"] boolValue] == YES) {

		xform->post[0][0] = [[xformEntity valueForKey:@"post_0_0"] doubleValue];
		xform->post[0][1] = [[xformEntity valueForKey:@"post_0_1"] doubleValue];
		xform->post[1][0] = [[xformEntity valueForKey:@"post_1_0"] doubleValue];
		xform->post[1][1] = [[xformEntity valueForKey:@"post_1_1"] doubleValue];
		xform->post[2][0] = [[xformEntity valueForKey:@"post_2_0"] doubleValue];
		xform->post[2][1] = [[xformEntity valueForKey:@"post_2_1"] doubleValue];
		
	} else {
		
		/* set post to id matrix */
		xform->post[0][0] = 1.0;
		xform->post[0][1] = 0.0;
		xform->post[1][0] = 0.0;
		xform->post[1][1] = 1.0;
		xform->post[2][0] = 0.0;
		xform->post[2][1] = 0.0;
	}
	

	xform->color[0] = [[xformEntity valueForKey:@"colour_0"] doubleValue];
	xform->color[1] = [[xformEntity valueForKey:@"colour_1"] doubleValue];

	xform->symmetry  = [[xformEntity valueForKey:@"symmetry"] doubleValue];

	[Genome poulateVariations:xform FromEntityArray:variations];
	
	
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
				tools_perspective_precalc(xform);
				break;
			case 32:
				xform->juliaN_dist = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->juliaN_power = [[variation valueForKey:@"parameter_2"] doubleValue];
				tools_juliaN_precalc(xform);
				break;
			case 33:
				xform->juliaScope_dist = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->juliaScope_power = [[variation valueForKey:@"parameter_2"] doubleValue];
				tools_juliaScope_precalc(xform);
				break;	
			case 36:
				xform->radialBlur_angle = [[variation valueForKey:@"parameter_1"] doubleValue];
				tools_radial_blur_precalc(xform);
				break;	
			case 37:
				xform->pie_slices = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->pie_rotation = [[variation valueForKey:@"parameter_2"] doubleValue];
				xform->pie_thickness = [[variation valueForKey:@"parameter_3"] doubleValue];
				break;	
			case 38:
				xform->ngon_sides = [[variation valueForKey:@"parameter_1"] doubleValue];
				xform->ngon_power = [[variation valueForKey:@"parameter_2"] doubleValue];
				xform->ngon_circle = [[variation valueForKey:@"parameter_3"] doubleValue];
				xform->ngon_corners = [[variation valueForKey:@"parameter_4"] doubleValue];
				break;	
			default:
				break;
				
		}
	
	}

	tools_waves_precalc(xform);


}

+ (void )populateCMap:(flam3_palette )cmap FromEntityArray:(NSArray *)cmaps {

		NSManagedObject *colour;
		int i;
		
		for(i=0; i<256; i++) {
		
			colour = [cmaps objectAtIndex:i];
			cmap[i][0] = [[colour valueForKey:@"red"]   doubleValue];
			cmap[i][1] = [[colour valueForKey:@"green"] doubleValue];
			cmap[i][2] = [[colour valueForKey:@"blue"]  doubleValue];	

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
/*				
				[variation setValue:[NSNumber numberWithDouble:xform->perspective_angle] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->perspective_dist] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];
*/				
				
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
/*				
				[variation setValue:[NSNumber numberWithDouble:xform->juliaN_dist] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->juliaN_power] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];
*/				
				
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
/*				
				[variation setValue:[NSNumber numberWithDouble:xform->juliaScope_dist] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->juliaScope_power] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];
*/				
				
				[variation setValue:@"JS Distance:" forKey:@"parameter_1_name"];
				[variation setValue:@"Power:" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				
				break;
			case 36:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];
				
				[variation setValue:@"Angle:" forKey:@"parameter_1_name"];
				[variation setValue:@"parameter 2" forKey:@"parameter_2_name"];
				[variation setValue:@"parameter 3" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
/*				
				[variation setValue:[NSNumber numberWithDouble:xform->radialBlur_angle] forKey:@"parameter_1"];
*/				
				break;	
			case 37:
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
				[variation setValue:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
				[variation setValue:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];
				
				[variation setValue:@"Slices:" forKey:@"parameter_1_name"];
				[variation setValue:@"Rotation:" forKey:@"parameter_2_name"];
				[variation setValue:@"Thickness:" forKey:@"parameter_3_name"];
				[variation setValue:@"parameter 4" forKey:@"parameter_4_name"];
				
/*				[variation setValue:[NSNumber numberWithDouble:xform->pie_slices] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->pie_rotation] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:xform->pie_thickness] forKey:@"parameter_3"];
*/				
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
				
/*				[variation setValue:[NSNumber numberWithDouble:xform->ngon_sides] forKey:@"parameter_1"];
				[variation setValue:[NSNumber numberWithDouble:xform->ngon_power] forKey:@"parameter_2"];
				[variation setValue:[NSNumber numberWithDouble:xform->ngon_circle] forKey:@"parameter_3"];
				[variation setValue:[NSNumber numberWithDouble:xform->ngon_corners] forKey:@"parameter_4"];
*/				
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

- (NSImage *)getImage {
	return _image;
}

- (void)setImage:(NSImage *)newImage {

	if(newImage != nil) {
		[newImage retain];
	}
	[_image release];

	_image = newImage;	
}

- (NSManagedObjectContext *)getManagedObjectContext {
	return _moc;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)moc {

	if(moc != nil) {
		[moc retain];
	}
	[moc release];

	_moc = moc;	
}

- (void)setCGenome:(flam3_genome *)cps {
	_genome = cps;
}

- (flam3_genome *)getCGenome {
	
	return _genome;

}

- (NSManagedObject *)getGenomeEntity {
	return _genomeEntity;
}

- (void)setGenomeEntity:(NSManagedObject *)genomeEntity  {

	if(genomeEntity != nil) {
		[genomeEntity retain];
	}
	[_genomeEntity release];

	_genomeEntity = genomeEntity;	
}

- (int)setIndex {
	return _index;
}

- (void)setIndex:(int)index  {
	
	index = _index;
	
}

+ (void) compareGenomesEntity:(NSManagedObject *)genomeEntity toCGenome:(flam3_genome *)genome fromContext:(NSManagedObjectContext *)moc {
	
	flam3_genome oxidizerGenome;

	NSLog(@"Comparing flames...");

	
	memset(&oxidizerGenome, '\0', sizeof(flam3_genome));
	
	[Genome populateCGenome:&oxidizerGenome FromEntity:genomeEntity fromContext:moc]; 
		
	if(oxidizerGenome.time != genome->time) {
		NSLog(@"time differs, Oxidizer %g, flam3 %g", oxidizerGenome.time, genome->time);
	}
	
	if(oxidizerGenome.interpolation != genome->interpolation) {
		NSLog(@"time differs, Oxidizer %g, flam3 %g", oxidizerGenome.interpolation, genome->interpolation);
	}
	if(oxidizerGenome.palette_interpolation != genome->palette_interpolation) {
		NSLog(@"palette_interpolation differs, Oxidizer %g, flam3 %g", oxidizerGenome.palette_interpolation, genome->palette_interpolation);
	}
	if(oxidizerGenome.num_xforms != genome->num_xforms) {
		NSLog(@"num_xforms differs, Oxidizer %g, flam3 %g", oxidizerGenome.num_xforms, genome->num_xforms);
	} else {
		int i;
		for(i=0; i < oxidizerGenome.num_xforms; i++) {
			NSLog(@"Comparing xform %d...", i);

			[Genome compareXForm:oxidizerGenome.xform+i toXForm:genome->xform+i]; 
		
		}
		
	}

	if(oxidizerGenome.final_xform_enable != genome->final_xform_enable) {
		NSLog(@"final_xform_enable differs, Oxidizer %g, flam3 %g", oxidizerGenome.final_xform_enable, genome->final_xform_enable);
	}
	
	if(oxidizerGenome.final_xform_index != genome->final_xform_index) {
		NSLog(@"final_xform_index differs, Oxidizer %g, flam3 %g", oxidizerGenome.final_xform_index, genome->final_xform_index);
	}

	if(oxidizerGenome.genome_index != genome->genome_index) {
		NSLog(@"genome_index differs, Oxidizer %g, flam3 %g", oxidizerGenome.genome_index, genome->genome_index);
	}

	if(oxidizerGenome.symmetry != genome->symmetry) {
		NSLog(@"symmetry differs, Oxidizer %g, flam3 %g", oxidizerGenome.symmetry, genome->symmetry);
	}
	
	if(oxidizerGenome.palette_index != genome->palette_index) {
		NSLog(@"palette_index differs, Oxidizer %g, flam3 %g", oxidizerGenome.palette_index, genome->palette_index);
	}

	if(oxidizerGenome.brightness != genome->brightness) {
		NSLog(@"brightness differs, Oxidizer %g, flam3 %g", oxidizerGenome.brightness, genome->brightness);
	}

	if(oxidizerGenome.contrast != genome->contrast) {
		NSLog(@"contrast differs, Oxidizer %g, flam3 %g", oxidizerGenome.contrast, genome->contrast);
	}
	
	if(oxidizerGenome.width != genome->width) {
		NSLog(@"width differs, Oxidizer %g, flam3 %g", oxidizerGenome.width, genome->width);
	}
	
	if(oxidizerGenome.height != genome->height) {
		NSLog(@"height differs, Oxidizer %g, flam3 %g", oxidizerGenome.height, genome->height);
	}

	if(oxidizerGenome.spatial_oversample != genome->spatial_oversample) {
		NSLog(@"spatial_oversample differs, Oxidizer %g, flam3 %g", oxidizerGenome.spatial_oversample, genome->spatial_oversample);
	}

	if(oxidizerGenome.contrast != genome->contrast) {
		NSLog(@"contrast differs, Oxidizer %g, flam3 %g", oxidizerGenome.contrast, genome->contrast);
	}

	if(oxidizerGenome.contrast != genome->contrast) {
		NSLog(@"contrast differs, Oxidizer %g, flam3 %g", oxidizerGenome.contrast, genome->contrast);
	}
	
}

+ (void) compareXForm:(flam3_xform *)of toXForm:(flam3_xform *)ff {
	
	
	int i;
	
	for(i=0; i<flam3_nvariations; i++) {
		if(of->var[i] != ff->var[i]) {
			NSLog(@"variation %d differs, Oxidizer %g, flam3 %g", i, of->var[i], ff->var[i]);
		}
	}

	if(of->c[0][0] != ff->c[0][0]) {
		NSLog(@"coef[0][0] differs, Oxidizer %g, flam3 %g", of->c[0][0], ff->c[0][0]);
	}
	if(of->c[0][1] != ff->c[0][1]) {
		NSLog(@"coef[0][1] differs, Oxidizer %g, flam3 %g", of->c[0][1], ff->c[0][1]);
	}
	if(of->c[0][2] != ff->c[0][2]) {
		NSLog(@"coef[0][2] differs, Oxidizer %g, flam3 %g", of->c[0][2], ff->c[0][2]);
	}
	if(of->c[1][0] != ff->c[1][0]) {
		NSLog(@"coef[1][0] differs, Oxidizer %g, flam3 %g", of->c[1][0], ff->c[1][0]);
	}
	if(of->c[1][1] != ff->c[1][1]) {
		NSLog(@"coef[1][1] differs, Oxidizer %g, flam3 %g", of->c[1][1], ff->c[1][1]);
	}
	if(of->c[1][2] != ff->c[1][2]) {
		NSLog(@"coef[1][2] differs, Oxidizer %g, flam3 %g", of->c[1][2], ff->c[1][2]);
	}
	
	if(of->post[0][0] != ff->post[0][0]) {
		NSLog(@"post[0][0] differs, Oxidizer %g, flam3 %g", of->post[0][0], ff->post[0][0]);
	}
	if(of->post[0][1] != ff->post[0][1]) {
		NSLog(@"post[0][1] differs, Oxidizer %g, flam3 %g", of->post[0][1], ff->post[0][1]);
	}
	if(of->post[0][2] != ff->post[0][2]) {
		NSLog(@"post[0][2] differs, Oxidizer %g, flam3 %g", of->post[0][2], ff->post[0][2]);
	}
	if(of->post[1][0] != ff->post[1][0]) {
		NSLog(@"post[1][0] differs, Oxidizer %g, flam3 %g", of->post[1][0], ff->post[1][0]);
	}
	if(of->post[1][1] != ff->post[1][1]) {
		NSLog(@"post[1][1] differs, Oxidizer %g, flam3 %g", of->post[1][1], ff->post[1][1]);
	}
	if(of->post[1][2] != ff->post[1][2]) {
		NSLog(@"post[1][2] differs, Oxidizer %g, flam3 %g", of->post[1][2], ff->post[1][2]);
	}
	
	
	if(of->color[0] != ff->color[0]) {
		NSLog(@"color[0] differs, Oxidizer %g, flam3 %g", of->color[0], ff->color[0]);
	}	
	if(of->color[1] != ff->color[1]) {
		NSLog(@"color[0] differs, Oxidizer %g, flam3 %g", of->color[1], ff->color[1]);
	}

	if(of->density != ff->density) {
		NSLog(@"density differs, Oxidizer %g, flam3 %g", of->density, ff->density);
	}	
	
	if(of->symmetry != ff->symmetry) {
		NSLog(@"symmetry differs, Oxidizer %g, flam3 %g", of->symmetry, ff->symmetry);
	}	
	
	if(of->precalc_sqrt_flag != ff->precalc_sqrt_flag) {
		NSLog(@"precalc_sqrt_flag differs, Oxidizer %g, flam3 %g", of->precalc_sqrt_flag, ff->precalc_sqrt_flag);
	}	
	if(of->precalc_angles_flag != ff->precalc_angles_flag) {
		NSLog(@"precalc_angles_flag differs, Oxidizer %g, flam3 %g", of->precalc_angles_flag, ff->precalc_angles_flag);
	}	
	
	if(of->blob_low != ff->blob_low) {
		NSLog(@"blob_low differs, Oxidizer %g, flam3 %g", of->blob_low, ff->blob_low);
	}	
	if(of->blob_high != ff->blob_high) {
		NSLog(@"symmetry differs, Oxidizer %g, flam3 %g", of->blob_high, ff->blob_high);
	}	
	if(of->blob_waves != ff->blob_waves) {
		NSLog(@"blob_waves differs, Oxidizer %g, flam3 %g", of->blob_waves, ff->blob_waves);
	}	

	if(of->pdj_a != ff->pdj_a) {
		NSLog(@"pdj_a differs, Oxidizer %g, flam3 %g", of->pdj_a, ff->pdj_a);
	}	
	if(of->pdj_b != ff->pdj_b) {
		NSLog(@"pdj_b differs, Oxidizer %g, flam3 %g", of->pdj_b, ff->pdj_b);
	}	
	if(of->pdj_c != ff->pdj_c) {
		NSLog(@"pdj_c differs, Oxidizer %g, flam3 %g", of->pdj_c, ff->pdj_c);
	}	
	if(of->pdj_d != ff->pdj_d) {
		NSLog(@"pdj_d differs, Oxidizer %g, flam3 %g", of->pdj_d, ff->pdj_d);
	}	
	
	if(of->fan2_x != ff->fan2_x) {
		NSLog(@"fan2_x differs, Oxidizer %g, flam3 %g", of->fan2_x, ff->fan2_x);
	}	
	if(of->fan2_y != ff->fan2_y) {
		NSLog(@"fan2_y differs, Oxidizer %g, flam3 %g", of->fan2_y, ff->fan2_y);
	}	
	
	if(of->rings2_val != ff->rings2_val) {
		NSLog(@"rings2_val differs, Oxidizer %g, flam3 %g", of->rings2_val, ff->rings2_val);
	}	
	
	if(of->perspective_angle != ff->perspective_angle) {
		NSLog(@"perspective_angle differs, Oxidizer %g, flam3 %g", of->perspective_angle, ff->perspective_angle);
	}	
	if(of->perspective_dist != ff->perspective_dist) {
		NSLog(@"perspective_dist differs, Oxidizer %g, flam3 %g", of->perspective_dist, ff->perspective_dist);
	}	
	
	if(of->juliaN_power != ff->juliaN_power) {
		NSLog(@"juliaN_power differs, Oxidizer %g, flam3 %g", of->juliaN_power, ff->juliaN_power);
	}	
	if(of->juliaN_dist != ff->juliaN_dist) {
		NSLog(@"juliaN_dist differs, Oxidizer %g, flam3 %g", of->juliaN_dist, ff->juliaN_dist);
	}	
	
	if(of->juliaScope_power != ff->juliaScope_power) {
		NSLog(@"juliaScope_power differs, Oxidizer %g, flam3 %g", of->juliaScope_power, ff->juliaScope_power);
	}	
	if(of->juliaScope_dist != ff->juliaScope_dist) {
		NSLog(@"juliaScope_dist differs, Oxidizer %g, flam3 %g", of->juliaScope_dist, ff->juliaScope_dist);
	}	
	
	if(of->radialBlur_angle != ff->radialBlur_angle) {
		NSLog(@"radialBlur_angle differs, Oxidizer %g, flam3 %g", of->radialBlur_angle, ff->radialBlur_angle);
	}	
	
	if(of->pie_slices != ff->pie_slices) {
		NSLog(@"pie_slices differs, Oxidizer %g, flam3 %g", of->pie_slices, ff->pie_slices);
	}	
	if(of->pie_rotation != ff->pie_rotation) {
		NSLog(@"pie_rotation differs, Oxidizer %g, flam3 %g", of->pie_rotation, ff->pie_rotation);
	}	
	if(of->pie_thickness != ff->pie_thickness) {
		NSLog(@"pie_thickness differs, Oxidizer %g, flam3 %g", of->pie_thickness, ff->pie_thickness);
	}	
	
	if(of->ngon_sides != ff->ngon_sides) {
		NSLog(@"ngon_sides differs, Oxidizer %g, flam3 %g", of->ngon_sides, ff->ngon_sides);
	}	
	if(of->ngon_power != ff->ngon_power) {
		NSLog(@"ngon_power differs, Oxidizer %g, flam3 %g", of->ngon_power, ff->ngon_power);
	}	
	if(of->ngon_circle != ff->ngon_circle) {
		NSLog(@"ngon_circle differs, Oxidizer %g, flam3 %g", of->ngon_circle, ff->ngon_circle);
	}	
	if(of->ngon_corners != ff->ngon_corners) {
		NSLog(@"ngon_corners differs, Oxidizer %g, flam3 %g", of->ngon_corners, ff->ngon_corners);
	}	
	
	if(of->persp_vsin != ff->persp_vsin) {
		NSLog(@"persp_vsin differs, Oxidizer %g, flam3 %g", of->persp_vsin, ff->persp_vsin);
	}	
	if(of->persp_vfcos != ff->persp_vfcos) {
		NSLog(@"persp_vfcos differs, Oxidizer %g, flam3 %g", of->persp_vfcos, ff->persp_vfcos);
	}	

	if(of->juliaN_rN != ff->juliaN_rN) {
		NSLog(@"juliaN_rN differs, Oxidizer %g, flam3 %g", of->juliaN_rN, ff->juliaN_rN);
	}	
	if(of->juliaN_cn != ff->juliaN_cn) {
		NSLog(@"juliaN_cn differs, Oxidizer %g, flam3 %g", of->juliaN_cn, ff->juliaN_cn);
	}	

	if(of->juliaScope_rN != ff->juliaScope_rN) {
		NSLog(@"juliaScope_rN differs, Oxidizer %g, flam3 %g", of->juliaScope_rN, ff->juliaScope_rN);
	}	
	if(of->juliaScope_cn != ff->juliaScope_cn) {
		NSLog(@"juliaScope_cn differs, Oxidizer %g, flam3 %g", of->juliaScope_cn, ff->juliaScope_cn);
	}	
	
	if(of->radialBlur_spinvar != ff->radialBlur_spinvar) {
		NSLog(@"radialBlur_spinvar differs, Oxidizer %g, flam3 %g", of->radialBlur_spinvar, ff->radialBlur_spinvar);
	}	
	if(of->radialBlur_zoomvar != ff->radialBlur_zoomvar) {
		NSLog(@"radialBlur_zoomvar differs, Oxidizer %g, flam3 %g", of->radialBlur_zoomvar, ff->radialBlur_zoomvar);
	}	

	if(of->waves_dx2 != ff->waves_dx2) {
		NSLog(@"waves_dx2 differs, Oxidizer %g, flam3 %g", of->waves_dx2, ff->waves_dx2);
	}	
	if(of->waves_dy2 != ff->waves_dy2) {
		NSLog(@"waves_dy2 differs, Oxidizer %g, flam3 %g", of->waves_dy2, ff->waves_dy2);
	}	
	
	
}

@end

