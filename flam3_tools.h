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


#import "flam3.h"

void improve_colors(flam3_genome *g, int ntries, int change_palette, int color_resolution);
xmlDocPtr create_new_editdoc(char *action, flam3_genome *parent0, flam3_genome *parent1);
double try_colors(flam3_genome *g, int color_resolution);
int random_xform(flam3_genome *g, int excluded);
void change_colors(flam3_genome *g, int change_palette);

void truncate_variations(flam3_genome *g, int max_vars, char *action);
void test_cp(flam3_genome *cp);


void tools_perspective_precalc(flam3_xform *xf);
void tools_juliaN_precalc(flam3_xform *xf);
void tools_juliaScope_precalc(flam3_xform *xf);
void tools_radial_blur_precalc(flam3_xform *xf);
void tools_waves_precalc(flam3_xform *xf);

/* scripting functions */

flam3_frame *getFlam3Frame(void);
flam3_genome *getGenomeFromFrame(flam3_frame *frame, int index);
flam3_xform *getXFormFromGenome(flam3_genome *genome, int index);
double getValueFromCoefficient(double coeff[][2], unsigned int index1, unsigned int index2);

void setFlam3Frame(flam3_frame *frame);
#define EPS (1e-10)
