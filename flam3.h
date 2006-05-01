/*
    FLAM3 - cosmic recursive fractal flames
    Copyright (C) 1992-2006  Scott Draves <source@flam3.com>

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


#ifndef flam3_included
#define flam3_included

#include <stdio.h>
#include <libxml/parser.h>

static char *flam3_h_id =
"@(#) $Id: flam3.h,v 1.4 2006/07/02 12:50:18 vargol Exp $";

char *flam3_version();

#define flam3_palette_random       (-1)
#define flam3_palette_interpolated (-2)

#define flam3_defaults_on          (1)
#define flam3_defaults_off         (0)

#define flam3_name_len    64

typedef double flam3_palette[256][3];

int flam3_get_palette(int palette_index, flam3_palette p, double hue_rotation);


#define flam3_variation_random (-1)
#define flam3_variation_random_fromspecified (-2)

extern char *flam3_variation_names[];

#define flam3_nvariations 35
#define flam3_nxforms     12

#define flam3_parent_fn_len     30

#define flam3_interpolation_linear 0
#define flam3_interpolation_smooth 1


typedef void (*flam3_iterator)(void *, double);

typedef struct {
   double var[flam3_nvariations];   /* interp coefs between variations */
   double c[3][2];      /* the coefs to the affine part of the function */
   double post[3][2];   /* the post transform */
   double density;      /* probability that this function is chosen. 0 - 1 */
   double color[2];     /* color coords for this function. 0 - 1 */
   double symmetry;     /* 1=this is a symmetry xform, 0=not */
   
   int precalc_sqrt_flag;
   int precalc_angles_flag;

   /* Params for new parameterized variations */ 
   /* Blob */
   double blob_low;
   double blob_high;
   double blob_waves;
   
   /* PDJ */
   double pdj_a;
   double pdj_b;
   double pdj_c;
   double pdj_d;
   
   /* Fan2 */
   double fan2_x;
   double fan2_y;
   
   /* Rings2 */
   double rings2_val;
   
   /* Perspective */
   double perspective_angle;
   double perspective_dist;
   
   /* Julia_N */
   double juliaN_power;
   double juliaN_dist;
   
   /* Julia_Scope */
   double juliaScope_power;
   double juliaScope_dist;
   
   /* If perspective is used, precalculate these values */
   /* from the _angle and _dist                         */
   double persp_vsin;
   double persp_vfcos;
   
   /* If Julia_N is used, precalculate these values */
   double juliaN_rN;
   double juliaN_cn;

   /* If Julia_Scope is used, precalculate these values */
   double juliaScope_rN;
   double juliaScope_cn;

   /* function pointers for faster iterations */
   int num_active_vars;
   double active_var_weights[flam3_nvariations];
   flam3_iterator varFunc[flam3_nvariations];
   
} flam3_xform;

typedef struct {
   char flame_name[flam3_name_len+1]; /* 64 chars plus a null */
   double time;
   int interpolation;
   int num_xforms;
   int final_xform_index;
   int final_xform_enable;
   flam3_xform *xform;
   int genome_index;                   /* index into source file */
   char parent_fname[flam3_parent_fn_len];   /* base filename where parent was located */
   int symmetry;                /* 0 means none */
   flam3_palette palette;
   char *input_image;           /* preview/temporary! */
   int  palette_index;
   double brightness;           /* 1.0 = normal */
   double contrast;             /* 1.0 = normal */
   double gamma;
   int  width, height;          /* of the final image */
   int  spatial_oversample;
   double center[2];             /* of camera */
   double rot_center[2];         /* really the center */
   double rotate;                /* camera */
   double vibrancy;              /* blend between color algs (0=old,1=new) */
   double hue_rotation;          /* applies to cmap, 0-1 */
   double background[3];
   double zoom;                  /* effects ppu, sample density, scale */
   double pixels_per_unit;       /* vertically */
   double spatial_filter_radius; /* variance of gaussian */
   double sample_density;        /* samples per pixel (not bucket) */
   /* in order to motion blur more accurately we compute the logs of the 
   sample density many times and average the results. */
   /* nbatches is the number of times the buckets are filtered into 
   the abucket log accumulator */
   /* ntemporal_samples is the number of time steps per batch.  this many
   interpolated control points are used per batch and accumulated */
   int nbatches;
   int ntemporal_samples;
   
   /* Density estimation parameters for blurring low density hits */
   double estimator;             /* Filter width for bin with one hit */
   double estimator_curve;              /* Exponent on decay function ( MAX / a^(k-1) ) */
   double estimator_minimum;         /* Minimum filter width used -
                                    forces filter to be used of at least this width on all pts */

   /* XML Edit structure */
   xmlDocPtr edits;   
   
   /* Small-gamma linearization threshold */
   double gam_lin_thresh;
   
   /* for cmap_interpolated hack */
   int palette_index0;
   double hue_rotation0;
   int palette_index1;
   double hue_rotation1;
   double palette_blend;
} flam3_genome;

/* xform manipulation */
void flam3_add_xforms(flam3_genome *cp, int num_to_add);
void flam3_delete_xform(flam3_genome *thiscp, int idx_to_delete);
void flam3_copy(flam3_genome *dest, flam3_genome *src);
void flam3_copyx(flam3_genome *dest, flam3_genome *src, int num_std, int num_final);

/* samples is array nsamples*4 long of x,y,color triples.
   using (samples[0], samples[1]) as starting XY point and
   (samples[2], samples[3]) as starting color coordinate,
   perform fuse iterations and throw them away, then perform
   nsamples iterations and save them in the samples array */
void flam3_iterate(flam3_genome *g, int nsamples, int fuse, double *samples);

/* genomes is array ngenomes long, with times set and in ascending order.
   interpolate to the requested time and return in result */
void flam3_interpolate(flam3_genome *genomes, int ngenomes, double time, flam3_genome *result);

/* barycentric coordinates in c */
void flam3_interpolate_n(flam3_genome *result, int ncp, flam3_genome *cpi, double *c);

/* print genome to given file with extra_attributes if not NULL */
void flam3_print(FILE *f, flam3_genome *g, char *extra_attributes);

/* ivars is a list of variations to use, or flam3_variation_random     */
/* ivars_n is the number of values in ivars to select from.            */
/* sym is either a symmetry group or 0 meaning random or no symmetry   */
/* spec_xforms specifies the number of xforms to use, setting to 0 makes the number random. */
void flam3_random(flam3_genome *g, int *ivars, int ivars_n, int sym, int spec_xforms);

/* return NULL in case of error */
flam3_genome *flam3_parse(char *s, int *ncps);
flam3_genome *flam3_parse_xml2(char *s, char *fn, int default_flag, int *ncps);
flam3_genome *flam3_parse_from_file(FILE *f, char *fn, int default_flag, int *ncps);

void flam3_add_symmetry(flam3_genome *g, int sym);

void flam3_estimate_bounding_box(flam3_genome *g, double eps, int nsamples,
				 double *bmin, double *bmax);
void flam3_rotate(flam3_genome *g, double angle); /* angle in degrees */

double flam3_dimension(flam3_genome *g, int ntries, int clip_to_camera);
double flam3_lyapunov(flam3_genome *g, int ntries);

void flam3_apply_template(flam3_genome *cp, flam3_genome *templ);

typedef struct {
   double         temporal_filter_radius;
   double         pixel_aspect_ratio;    /* width over height of each pixel */
   flam3_genome  *genomes;
   int            ngenomes;
   int            verbose;
   int            bits;
   double         time;
   int            (*progress)(void *, double, int);
   void          *progress_parameter;
} flam3_frame;


#define flam3_field_both  0
#define flam3_field_even  1
#define flam3_field_odd   2

/* out is pixel array with stride of out_width.
   pixels are rgb or rgba if nchan is 3 or 4. */
void flam3_render(flam3_frame *f, unsigned char *out, int out_width, int field, int nchan, int transp);

double flam3_render_memory_required(flam3_frame *f);


double flam3_random01();
double flam3_random11();
int flam3_random_bit();


#endif
