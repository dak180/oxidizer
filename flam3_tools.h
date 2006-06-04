//
//  flam3_tools.h
//  oxidizer
//
//  Created by David Burnett on 02/06/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "flam3.h"

void improve_colors(flam3_genome *g, int ntries, int change_palette, int color_resolution);
xmlDocPtr create_new_editdoc(char *action, flam3_genome *parent0, flam3_genome *parent1);
double try_colors(flam3_genome *g, int color_resolution);
int random_xform(flam3_genome *g, int excluded);
void change_colors(flam3_genome *g, int change_palette);

void truncate_variations(flam3_genome *g, int max_vars, char *action);
void test_cp(flam3_genome *cp);
