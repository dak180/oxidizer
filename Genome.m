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

#import "Genome.h"
#import <libxml/parser.h>

@implementation Genome

+ (NSMutableDictionary *)makeDictionaryFrom:(flam3_genome *)genome withImage:(NSImage *)image {

	NSMutableArray *colours;

	NSMutableDictionary *genomeDictionary; 
	NSMutableDictionary *newColour;
	
	int i;

	genomeDictionary = [[NSMutableDictionary alloc] init];

	[genomeDictionary setObject:[NSString stringWithCString:genome->flame_name encoding:NSUTF8StringEncoding]  forKey:@"name"];
	[genomeDictionary setObject:[NSString stringWithCString:genome->parent_fname encoding:NSUTF8StringEncoding]  forKey:@"parent"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->time]  forKey:@"time"];
	[genomeDictionary setObject:[NSNumber numberWithInt:genome->palette_index]  forKey:@"palette"];
	[genomeDictionary setObject:[NSNumber numberWithInt:genome->height]  forKey:@"height"];
	[genomeDictionary setObject:[NSNumber numberWithInt:genome->width]  forKey:@"width"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->center[0]]  forKey:@"centre_x"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->center[1]]  forKey:@"centre_y"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->zoom]  forKey:@"zoom"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->pixels_per_unit]  forKey:@"scale"];
	[genomeDictionary setObject:[NSNumber numberWithInt:genome->spatial_oversample]  forKey:@"oversample"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->sample_density]  forKey:@"quality"];
	[genomeDictionary setObject:[NSNumber numberWithInt:genome->nbatches]  forKey:@"batches"];
	[genomeDictionary setObject:[NSNumber numberWithInt:genome->ntemporal_samples]  forKey:@"jitter"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->estimator_curve]  forKey:@"de_alpha"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->estimator]  forKey:@"de_max_filter"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->estimator_minimum]  forKey:@"de_min_filter"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->gamma]  forKey:@"gamma"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->gam_lin_thresh]  forKey:@"gamma_threshold"];
	[genomeDictionary setObject:[NSColor colorWithDeviceRed:genome->background[0] green:genome->background[1] blue:genome->background[2] alpha:1.0]  forKey:@"background"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->hue_rotation]  forKey:@"hue"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->vibrancy]  forKey:@"vibrancy"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->brightness]  forKey:@"brightness"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->rotate]  forKey:@"rotate"];
	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->spatial_filter_radius]  forKey:@"filter"];

	[genomeDictionary setObject:[NSNumber numberWithDouble:genome->contrast]  forKey:@"contrast"];
	[genomeDictionary setObject:[Genome  getStringSymmetry:genome->symmetry]  forKey:@"symmetry"];

	if(genome->edits != NULL) {
	
		xmlChar *doc;
		int xmlSize;
	
		xmlDocDumpMemory(genome->edits, &doc, &xmlSize); 

		NSAttributedString *edits = [[NSAttributedString alloc] initWithString:[NSString stringWithCString:doc encoding:NSUTF8StringEncoding]];		
		[genomeDictionary setObject:edits forKey:@"edits"];
		[edits release];
	}

	[genomeDictionary setObject:@"Vargol" forKey:@"nick"];
	[genomeDictionary setObject:@"http://oxidizer.sf.net" forKey:@"url"];
	[genomeDictionary setObject:@"Created by Oxidizer" forKey:@"comment"];

	[genomeDictionary setObject:image forKey:@"image"];
	
	[genomeDictionary setObject:[Genome createXformArrayFromCGenome:genome] forKey:@"xforms"];

    if(genome->palette_index < 0) {
		[genomeDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"use_palette"];
		/* use the cmap */
		colours = [[NSMutableArray alloc] initWithCapacity:256];
		for(i=0; i<256; i++) {
		
			newColour = [[NSMutableDictionary alloc] initWithCapacity:4];
			[newColour setObject:[NSNumber numberWithInt:i] forKey:@"index"];
			[newColour setObject:[NSNumber numberWithInt:(int)(genome->palette[i][0] * 255.0)] forKey:@"red"];
			[newColour setObject:[NSNumber numberWithInt:(int)(genome->palette[i][1] * 255.0)] forKey:@"green"];
			[newColour setObject:[NSNumber numberWithInt:(int)(genome->palette[i][2] * 255.0)] forKey:@"blue"];
			[colours addObject:newColour];
			[newColour release];
		}
	
		[genomeDictionary setObject:colours forKey:@"cmap"];
	} else {
		[genomeDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"use_palette"];
	}

	[genomeDictionary autorelease];

	return genomeDictionary;

}


+ (void)populateCGenome:(flam3_genome *)newGenome From:(NSMutableDictionary *)genomeDictionary {

	NSMutableArray *cmap;		
	NSDictionary *colour;
	NSArray *xforms; 
	float red, green, blue;
	int i;
	

//	flam3_genome *newGenome  = (flam3_genome *)malloc(sizeof(flam3_genome));

	strncpy(newGenome->flame_name, [[genomeDictionary objectForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding], flame_name_len);
	newGenome->flame_name[flame_name_len + 1] = '\0';
	strncpy(newGenome->parent_fname, [[genomeDictionary objectForKey:@"parent"] cStringUsingEncoding:NSUTF8StringEncoding], flame_name_len);
	newGenome->parent_fname[flame_name_len + 1] = '\0';
	newGenome->time = [[genomeDictionary objectForKey:@"time"] doubleValue];
	newGenome->palette_index = [[genomeDictionary objectForKey:@"palette"] intValue];
	newGenome->height = [[genomeDictionary objectForKey:@"height"] intValue];
	newGenome->width = [[genomeDictionary objectForKey:@"width"] intValue];
	newGenome->center[0] = [[genomeDictionary objectForKey:@"centre_x"] doubleValue];
	newGenome->center[1] = [[genomeDictionary objectForKey:@"centre_y"] doubleValue];
	newGenome->rot_center[0] = newGenome->center[0];
	newGenome->rot_center[1] = newGenome->center[1];
	newGenome->zoom = [[genomeDictionary objectForKey:@"zoom"] doubleValue];
	newGenome->pixels_per_unit = [[genomeDictionary objectForKey:@"scale"] doubleValue];
	newGenome->spatial_oversample = [[genomeDictionary objectForKey:@"oversample"] intValue];
	newGenome->sample_density = [[genomeDictionary objectForKey:@"quality"] doubleValue];
	newGenome->nbatches = [[genomeDictionary objectForKey:@"batches"] intValue];
	newGenome->ntemporal_samples = [[genomeDictionary objectForKey:@"jitter"] intValue];
	newGenome->estimator_curve = [[genomeDictionary objectForKey:@"de_alpha"] doubleValue];
	newGenome->estimator = [[genomeDictionary objectForKey:@"de_max_filter"] doubleValue];
	newGenome->estimator_minimum = [[genomeDictionary objectForKey:@"de_min_filter"] doubleValue];
	newGenome->gamma = [[genomeDictionary objectForKey:@"gamma"] doubleValue];
	newGenome->gam_lin_thresh = [[genomeDictionary objectForKey:@"gamma_threshold"] doubleValue];
	[[genomeDictionary objectForKey:@"background"] getRed:&red green:&green blue:&blue alpha:NULL];
	newGenome->background[0] = (double)red;
	newGenome->background[1] = (double)green;
	newGenome->background[2] = (double)blue;
	newGenome->hue_rotation = [[genomeDictionary objectForKey:@"hue"] doubleValue];
	newGenome->vibrancy = [[genomeDictionary objectForKey:@"vibrancy"] doubleValue];
	newGenome->brightness = [[genomeDictionary objectForKey:@"brightness"] doubleValue];
	newGenome->rotate = [[genomeDictionary objectForKey:@"rotate"] doubleValue];
	newGenome->spatial_filter_radius = [[genomeDictionary objectForKey:@"filter"] doubleValue];

	newGenome->contrast = [[genomeDictionary objectForKey:@"contrast"] doubleValue];
	newGenome->symmetry = [Genome getIntSymmetry:[genomeDictionary objectForKey:@"symmetry"]];
	newGenome->edits = [Genome createCEditDocFromDictionary:genomeDictionary];
	
	if(newGenome->palette_index < 0) {
		/* use the cmap */
		cmap = [genomeDictionary objectForKey:@"cmap"]; 
		for(i=0; i<256; i++) {
		
			colour = [cmap objectAtIndex:i];
			newGenome->palette[i][0] = [[colour objectForKey:@"red"]   doubleValue] / 255.0;
			newGenome->palette[i][1] = [[colour objectForKey:@"green"] doubleValue] / 255.0;
			newGenome->palette[i][2] = [[colour objectForKey:@"blue"]  doubleValue] / 255.0;	

		}
	} else {
		flam3_get_palette(newGenome->palette_index, newGenome->palette, newGenome->hue_rotation);
	}
	
	
	/* xforms */
	
	xforms = [genomeDictionary objectForKey:@"xforms"];
	
	newGenome->num_xforms = [xforms count];
	newGenome->xform = (flam3_xform *)malloc(sizeof(flam3_xform) * newGenome->num_xforms);
	
	
	for(i=0; i<newGenome->num_xforms; i++) {
		
		[Genome poulateXForm:newGenome->xform+i FromDictionary:[xforms objectAtIndex:i]];
	
	}
	
	if(newGenome->symmetry != 0) {
		flam3_add_symmetry(newGenome, newGenome->symmetry);
	}
	
	return;
}



+ (void )poulateXForm:(flam3_xform *)xform FromDictionary:(NSMutableDictionary *)xformDictionary {

	unsigned int i;

	NSMutableArray *tempArray;
	NSDictionary *tempDictonary;

	tempArray = [xformDictionary objectForKey:@"variations"];

	
	for(i=0; i<flam3_nvariations; i++) {
		tempDictonary = [tempArray objectAtIndex:i];
		
		if([[tempDictonary objectForKey:@"in_use"] boolValue] == YES) {
			xform->var[i] = [[tempDictonary objectForKey:@"weight"] doubleValue];
		} else {
			xform->var[i] = 0.0;
		}
		
		switch(i) {
			case 23:
				xform->blob_high = [[tempDictonary objectForKey:@"parameter_1"] doubleValue];
				xform->blob_low = [[tempDictonary objectForKey:@"parameter_2"] doubleValue];
				xform->blob_waves = [[tempDictonary objectForKey:@"parameter_3"] doubleValue];
				break;
			case 24:
				xform->pdj_a = [[tempDictonary objectForKey:@"parameter_1"] doubleValue];
				xform->pdj_b = [[tempDictonary objectForKey:@"parameter_2"] doubleValue];
				xform->pdj_c = [[tempDictonary objectForKey:@"parameter_3"] doubleValue];
				xform->pdj_d = [[tempDictonary objectForKey:@"parameter_4"] doubleValue];
				break;
			case 25:
				xform->fan2_x = [[tempDictonary objectForKey:@"parameter_1"] doubleValue];
				xform->fan2_y = [[tempDictonary objectForKey:@"parameter_2"] doubleValue];
				break;				
			case 26:
				xform->rings2_val = [[tempDictonary objectForKey:@"parameter_1"] doubleValue];
				break;
			case 30:
				xform->perspective_angle = [[tempDictonary objectForKey:@"parameter_1"] doubleValue];
				xform->perspective_dist = [[tempDictonary objectForKey:@"parameter_2"] doubleValue];
				break;
			default:
				break;

		}
	}
	
	xform->density = [[xformDictionary objectForKey:@"density"] doubleValue];
	
	xform->c[0][0] = [[xformDictionary objectForKey:@"coeff_0_0"] doubleValue];
	xform->c[0][1] = [[xformDictionary objectForKey:@"coeff_0_1"] doubleValue];
	xform->c[1][0] = [[xformDictionary objectForKey:@"coeff_1_0"] doubleValue];
	xform->c[1][1] = [[xformDictionary objectForKey:@"coeff_1_1"] doubleValue];
	xform->c[2][0] = [[xformDictionary objectForKey:@"coeff_2_0"] doubleValue];
	xform->c[2][1] = [[xformDictionary objectForKey:@"coeff_2_1"] doubleValue];
	
	xform->post[0][0] = [[xformDictionary objectForKey:@"post_0_0"] doubleValue];
	xform->post[0][1] = [[xformDictionary objectForKey:@"post_0_1"] doubleValue];
	xform->post[1][0] = [[xformDictionary objectForKey:@"post_1_0"] doubleValue];
	xform->post[1][1] = [[xformDictionary objectForKey:@"post_1_1"] doubleValue];
	xform->post[2][0] = [[xformDictionary objectForKey:@"post_2_0"] doubleValue];
	xform->post[2][1] = [[xformDictionary objectForKey:@"post_2_1"] doubleValue];

	xform->color[0] = [[xformDictionary objectForKey:@"colour_0"] doubleValue];
	xform->color[1] = [[xformDictionary objectForKey:@"colour_1"] doubleValue];

	xform->symmetry  = [[xformDictionary objectForKey:@"symmetry"] doubleValue];
	
	if( [[xformDictionary objectForKey:@"post_flag"] boolValue] == YES) {
		xform->post_flag = 1;
	} else {
		xform->post_flag = 0;
	}
	return;


}

+ (flam3_genome *)createAllCGenomes:(NSArray *)genomes {

	int genomeCount, i;
	flam3_genome *cGenomes;
	
	 genomeCount = [genomes count];
	 
	 cGenomes = (flam3_genome *)malloc(sizeof(flam3_genome) * genomeCount);
	 
	 for(i=0; i<genomeCount; i++) {
	 
		[Genome populateCGenome:cGenomes+i From:[[genomes objectAtIndex:i] objectForKey:@"dictionary"]];
		cGenomes[i].genome_index = i;
	 }

	return cGenomes;
}


+ (BOOL)testXMLFrame:(char *)filename againstOxizdizerFrame:(flam3_frame *)new {
flam3_frame *old;
	int i, ncps;
    FILE *xmlFile = fopen(filename, "rb");


	old = (flam3_frame *)malloc(sizeof(flam3_frame));
	
	fprintf(stderr, "checking frame\n");
	



   old->genomes = flam3_parse_from_file(xmlFile, filename, flam3_defaults_on, &ncps);



   if(old->temporal_filter_radius != new->temporal_filter_radius) {
		fprintf(stderr, "temporal_filter_radius error: %ld != %ld\n",
					 old->temporal_filter_radius, new->temporal_filter_radius);
	}

   if(old->pixel_aspect_ratio != new->pixel_aspect_ratio)     
		fprintf(stderr, "temporal_filter_radius error: %ld != %ld\n",
			old->pixel_aspect_ratio, old->pixel_aspect_ratio);    

   if(old->ngenomes != new->ngenomes) 
		fprintf(stderr, "ngenomes error: %ld != %ld\n",
			old->ngenomes, new->ngenomes);

   if(old->verbose != new->verbose) 
		fprintf(stderr, "verbose error: %ld != %ld\n",
			old->verbose, new->verbose);

   if(old->bits != new->bits) 
		fprintf(stderr, "bits error: %ld != %ld\n",
			old->bits, new->bits);

   if(old->time != new->time) 
		fprintf(stderr, "time error: %f != %f\n",
			old->time, new->time);

//   old->progress;
//   void          *progress_parameter;
	fprintf(stderr, "\nchecking genomes\n");

	for(i=0; i<old->ngenomes; i++) {
	
		[Genome testCGenome:old->genomes+i againstOxizdizerCGenome:new->genomes+i];
	
	}

	return TRUE;


}

+ (BOOL)testCGenome:(flam3_genome *)old againstOxizdizerCGenome:(flam3_genome *)new {

return TRUE;

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
	
+ (NSMutableArray *)createXformArrayFromCGenome:(flam3_genome *)genome {

	NSMutableDictionary *record; 
	NSMutableDictionary *variation; 
	NSMutableArray *variations; 
	NSMutableArray *xforms; 
	NSMutableString *name;
	
	int i, j;
	flam3_xform *xform;

	xforms = [[NSMutableArray alloc] initWithCapacity:genome->num_xforms];
	
	for(i=0; i<genome->num_xforms; i++) {
		record = [[NSMutableDictionary alloc] init];
		xform = genome->xform+i;

		[record setObject:[NSNumber numberWithInt:i] forKey:@"order"];
		
				//genome->
		[record setObject:[NSNumber numberWithDouble:xform->density] forKey:@"density"];

		[record setObject:[NSNumber numberWithDouble:xform->c[0][0]] forKey:@"coeff_0_0"];
		[record setObject:[NSNumber numberWithDouble:xform->c[0][1]] forKey:@"coeff_0_1"];
		[record setObject:[NSNumber numberWithDouble:xform->c[1][0]] forKey:@"coeff_1_0"];
		[record setObject:[NSNumber numberWithDouble:xform->c[1][1]] forKey:@"coeff_1_1"];
		[record setObject:[NSNumber numberWithDouble:xform->c[2][0]] forKey:@"coeff_2_0"];
		[record setObject:[NSNumber numberWithDouble:xform->c[2][1]] forKey:@"coeff_2_1"];

		[record setObject:[NSNumber numberWithDouble:xform->color[0]] forKey:@"colour_0"];
		[record setObject:[NSNumber numberWithDouble:xform->color[1]] forKey:@"colour_1"];
		
		[record setObject:[NSNumber numberWithDouble:xform->post[0][0]] forKey:@"post_0_0"];
		[record setObject:[NSNumber numberWithDouble:xform->post[0][1]] forKey:@"post_0_1"];
		[record setObject:[NSNumber numberWithDouble:xform->post[1][0]] forKey:@"post_1_0"];
		[record setObject:[NSNumber numberWithDouble:xform->post[1][1]] forKey:@"post_1_1"];
		[record setObject:[NSNumber numberWithDouble:xform->post[2][0]] forKey:@"post_2_0"];
		[record setObject:[NSNumber numberWithDouble:xform->post[2][1]] forKey:@"post_2_1"];

		[record setObject:[NSNumber numberWithDouble:xform->symmetry] forKey:@"symmetry"];

		if(xform->post_flag == 1) {
			[record setObject:[NSNumber numberWithBool:YES] forKey:@"post_flag"];
		} else {
			[record setObject:[NSNumber numberWithBool:NO] forKey:@"post_flag"];
		}
					
		variations = [[NSMutableArray alloc] initWithCapacity:flam3_nvariations];
		
		name = [[NSMutableString alloc] init];
		
		for(j=0; j<flam3_nvariations; j++) {
			variation = [[NSMutableDictionary alloc] init];
			
			[variation setObject:[NSString stringWithCString:flam3_variation_names[j] encoding:NSUTF8StringEncoding] forKey:@"name"]; 

			if(xform->var[j] != 0.0) {
				[variation setObject:[NSNumber numberWithBool:YES] forKey:@"in_use"];
				[name appendFormat:@"%@ ", [NSString stringWithCString:flam3_variation_names[j] encoding:NSUTF8StringEncoding]]; 
			} else {
				[variation setObject:[NSNumber numberWithBool:NO] forKey:@"in_use"];
			}
			[variation setObject:[NSNumber numberWithDouble:xform->var[j]] forKey:@"weight"];					
			switch(j) {
				case 23:
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

					[variation setObject:[NSNumber numberWithDouble:xform->blob_high] forKey:@"parameter_1"];
					[variation setObject:[NSNumber numberWithDouble:xform->blob_low] forKey:@"parameter_2"];
					[variation setObject:[NSNumber numberWithDouble:xform->blob_waves] forKey:@"parameter_3"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


					[variation setObject:@"Blob High:" forKey:@"parameter_1_name"];
					[variation setObject:@"Blob Low:" forKey:@"parameter_2_name"];
					[variation setObject:@"Blob Wave:" forKey:@"parameter_3_name"];
					[variation setObject:@"parameter 4" forKey:@"parameter_4_name"];
					break;
				case 24:
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_3"];
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_4"];

					[variation setObject:[NSNumber numberWithDouble:xform->pdj_a] forKey:@"parameter_1"];
					[variation setObject:[NSNumber numberWithDouble:xform->pdj_b] forKey:@"parameter_2"];
					[variation setObject:[NSNumber numberWithDouble:xform->pdj_c] forKey:@"parameter_3"];
					[variation setObject:[NSNumber numberWithDouble:xform->pdj_d] forKey:@"parameter_4"];


					[variation setObject:@"PDJ A:" forKey:@"parameter_1_name"];
					[variation setObject:@"PDJ B:" forKey:@"parameter_2_name"];
					[variation setObject:@"PDJ C:" forKey:@"parameter_3_name"];
					[variation setObject:@"PDJ D:" forKey:@"parameter_4_name"];

					break;
				case 25:
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

					[variation setObject:[NSNumber numberWithDouble:xform->fan2_x] forKey:@"parameter_1"];
					[variation setObject:[NSNumber numberWithDouble:xform->fan2_y] forKey:@"parameter_2"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


					[variation setObject:@"Fan2 x:" forKey:@"parameter_1_name"];
					[variation setObject:@"Fan2 y:" forKey:@"parameter_2_name"];
					[variation setObject:@"parameter 3" forKey:@"parameter_3_name"];
					[variation setObject:@"parameter 4" forKey:@"parameter_4_name"];

					break;				
				case 26:
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

					[variation setObject:[NSNumber numberWithDouble:xform->rings2_val] forKey:@"parameter_1"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_2"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


					[variation setObject:@"Rings2:" forKey:@"parameter_1_name"];
					[variation setObject:@"parameter 2" forKey:@"parameter_2_name"];
					[variation setObject:@"parameter 3" forKey:@"parameter_3_name"];
					[variation setObject:@"parameter 4" forKey:@"parameter_4_name"];

					break;
				case 30:
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_1"];
					[variation setObject:[NSNumber numberWithBool:YES] forKey:@"use_parameter_2"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

					[variation setObject:[NSNumber numberWithDouble:xform->perspective_angle] forKey:@"parameter_1"];
					[variation setObject:[NSNumber numberWithDouble:xform->perspective_dist] forKey:@"parameter_2"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


					[variation setObject:@"Angle:" forKey:@"parameter_1_name"];
					[variation setObject:@"Distance:" forKey:@"parameter_2_name"];
					[variation setObject:@"parameter 3" forKey:@"parameter_3_name"];
					[variation setObject:@"parameter 4" forKey:@"parameter_4_name"];

					break;
				default:
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_1"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_2"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_3"];
					[variation setObject:[NSNumber numberWithBool:NO] forKey:@"use_parameter_4"];

					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_1"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_2"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_3"];
					[variation setObject:[NSNumber numberWithDouble:0.0] forKey:@"parameter_4"];


					[variation setObject:@"parameter 1" forKey:@"parameter_1_name"];
					[variation setObject:@"parameter 2" forKey:@"parameter_2_name"];
					[variation setObject:@"parameter 3" forKey:@"parameter_3_name"];
					[variation setObject:@"parameter 4" forKey:@"parameter_4_name"];
					break;
			}
			[variations addObject:variation];
			[variation release];

		}
		[record setObject:name forKey:@"name"];
		[name release];

		[record setObject:variations forKey:@"variations"];
		[variations release];
		

		[xforms addObject:record];
	
		[record release];
	}
	
	[xforms autorelease];
	return xforms;

}


+ (xmlDocPtr) createCEditDocFromDictionary:(NSDictionary *)genome {
   
	NSXMLElement *newEditElement;
	NSXMLElement *oldRootElement;
	NSError *xmlError;
	NSString *date;
	NSString *oldDocAsXML;
	NSString *newDocAsXML;

	xmlDocPtr newEdit;

	struct tm *localt;
	time_t mytime;
	char timestring[100];
	
	NSXMLDocument *oldDoc = nil;


	/* create a date stamp (change to use cocoa)*/
	mytime = time(NULL);
	localt = localtime(&mytime);
	/* XXX use standard time format including timezone */
	strftime(timestring, 100, "%a %b %e %H:%M:%S %Z %Y", localt);

	date = [NSString stringWithCString:timestring encoding:NSUTF8StringEncoding];
  
   /* create edit element with new details */ 
	newEditElement = [[NSXMLElement alloc] initWithName:@"edit"];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"nick" stringValue:[genome objectForKey:@"nick"]]];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"url" stringValue:[genome objectForKey:@"url"]]];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"comm" stringValue:[genome objectForKey:@"comment"]]];
	[newEditElement addAttribute:[NSXMLNode attributeWithName:@"date" stringValue:date]];

	/* If there are old values add them as a child element of our edit element */

	oldDocAsXML = [[genome objectForKey:@"edits"] string];

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
		[oldDocAsXML release];
		[oldDoc release];
	}
	[date release];

	/* return the xml doc */   	
	return(newEdit);
}


@end
