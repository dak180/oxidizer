%module flam3
%{
	/* Includes the header in the wrapper code */
#include "flam3.h"
#include "flam3_tools.h"
	
	%}

%include "carrays.i"
%array_functions(flam3_genome , genome);
%array_functions(flam3_xform , xform);


typedef double flam3_palette[256][3];
int flam3_get_palette(int palette_index, flam3_palette p, double hue_rotation);

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
	
	/* Radial_Blur */
	double radialBlur_angle;
	
	/* Pie */
	double pie_slices;
	double pie_rotation;
	double pie_thickness;
	
	/* Ngon */
	double ngon_sides;
	double ngon_power;
	double ngon_circle;
	double ngon_corners;
	
	/* Image */
	/*
	 int image_id;
	 flam3_image_store *image_storage;
	 */
	
	/* Curl */
	double curl_c1;
	double curl_c2;
	
	/* Rectangles */
	double rectangles_x;
	double rectangles_y;
	
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
	
	/* If Radial_Blur is used, precalculate these values */
	double radialBlur_spinvar;
	double radialBlur_zoomvar;
	int radialBlur_randN;
	double radialBlur_rand[4];
	
	/* Precalculate these values for waves */
	double waves_dx2;
	double waves_dy2;
	
	
	/* function pointers for faster iterations */
	int num_active_vars;
	double active_var_weights[flam3_nvariations];
	flam3_iterator varFunc[flam3_nvariations];
	
} flam3_xform;

typedef struct {
	char flame_name[flam3_name_len+1]; /* 64 chars plus a null */
	double time;
	int interpolation;
	int palette_interpolation;
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
	double spatial_filter_radius; /* radius of spatial filter */
	double (*spatial_filter_func)(); /* spatial filter kernel function */
	double spatial_filter_support; /* size of standard kernel for specific function */
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
	
	double motion_exp; /* Motion blur parameter that controls how the colors are scaled */
	
	
} flam3_genome;

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


flam3_frame *getFlam3Frame(void);
flam3_genome *getGenomeFromFrame(flam3_frame *frame, int index);
flam3_xform *getXFormFromGenome(flam3_genome *genome, int index);
double getValueFromCoefficient(double coeff[][2], unsigned int index1, unsigned int index2);

void setFlam3Frame(flam3_frame *frame);


#define flam3_field_both  0
#define flam3_field_even  1
#define flam3_field_odd   2

