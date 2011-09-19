/*
    FLAM3 - cosmic recursive fractal flames
    Copyright (C) 1992-2009 Spotworks LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef filters_included
#define filters_included

#include "private.h"

#define DE_THRESH   100

/* Spatial filter kernels */
#define flam3_gaussian_kernel 0
#define flam3_hermite_kernel 1
#define flam3_box_kernel 2
#define flam3_triangle_kernel 3
#define flam3_bell_kernel 4
#define flam3_b_spline_kernel 5
#define flam3_lanczos3_kernel 6
#define flam3_lanczos2_kernel 7
#define flam3_mitchell_kernel 8
#define flam3_blackman_kernel 9
#define flam3_catrom_kernel 10
#define flam3_hamming_kernel 11
#define flam3_hanning_kernel 12
#define flam3_quadratic_kernel 13

/* Temporal filters */
#define flam3_temporal_box 0
#define flam3_temporal_gaussian 1
#define flam3_temporal_exp 2

typedef struct {
   int max_filtered_counts;
   int max_filter_index;
   int kernel_size;
   double *filter_widths;
   double *filter_coefs;
} flam3_de_helper;

extern double flam3_spatial_support[flam3_num_spatialfilters];

double flam3_spatial_filter(int knum, double x);
int flam3_create_spatial_filter(flam3_frame *spec, int field, double **filter);
flam3_de_helper flam3_create_de_filters(double max_rad, double min_rad, double curve, int ss);
double flam3_create_temporal_filter(int numsteps, int filter_type, double filter_exp, double filter_width,
                                    double **temporal_filter, double **temporal_deltas);
 
#endif


