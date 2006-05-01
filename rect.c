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

/* this file is included into flam3.c once for each buffer bit-width */

/* 
 * for batch
 *   generate de filters
 *   for temporal_sample_batch
 *     interpolate
 *     compute colormap
 *     for subbatch
 *       compute samples
 *       buckets += cmap[samples]
 *   accum += time_filter[temporal_sample_batch] * log[buckets] * de_filter
 * image = filter(accum)
 */


/* allow this many iterations for settling into attractor */
#define FUSE 15

/* clamp spatial filter to zero at this std dev (2.5 ~= 0.0125) */
#define FILTER_CUTOFF 1.8

#define PREFILTER_WHITE 255
#define WHITE_LEVEL 255
#define SUB_BATCH_SIZE 10000
#define SBS_X4 (SUB_BATCH_SIZE*4)


static void render_rectangle(spec, out, out_width, field, nchan, transp)
   flam3_frame *spec;
   unsigned char *out;
   int out_width;
   int field;
   int nchan;
{
   int i, j, k, nbuckets, batch_num, temporal_sample_num;
   double nsamples, batch_size, sub_batch;
   bucket  *buckets;
   abucket *accumulate;
   double *points;
   double *filter, *temporal_filter, *temporal_deltas;
   double bounds[4], size[2], ppux, ppuy;
   double rot[2][2];
   int image_width, image_height;    /* size of the image to produce */
   int width, height;               /* size of histogram */
   int filter_width;
   int oversample = spec->genomes[0].spatial_oversample;
   int nbatches = spec->genomes[0].nbatches;
   int ntemporal_samples = spec->genomes[0].ntemporal_samples;
   bucket cmap[CMAP_SIZE];
   unsigned char *cmap2;
   int gutter_width;
   int sbc;
   double vibrancy = 0.0;
   double gamma = 0.0;
   double background[3];
   int vib_gam_n = 0;
   time_t progress_timer = 0, progress_began,
     progress_timer_history[64] = {0};
   double progress_history[64] = {0};
   int progress_history_mark = 0;
   int verbose = spec->verbose;
   char *fname = getenv("image");
   int gnm_idx,max_gnm_de_fw,de_offset;
   flam3_genome cp;
   double hs1, hb1s1;
   
   memset(&cp,0, sizeof(flam3_genome));
   
   if (nbatches < 1) {
       fprintf(stderr, "nbatches must be positive," " not %d.\n", nbatches);
       exit(1);
   }

   if (oversample < 1) {
       fprintf(stderr, "oversample must be positive," " not %d.\n", oversample);
       exit(1);
   }

   image_width = spec->genomes[0].width;
   if (field) {
      image_height = spec->genomes[0].height / 2;
      if (field == flam3_field_odd)
	 out += nchan * out_width;
      out_width *= 2;
   } else
      image_height = spec->genomes[0].height;

   if (1) {
       double fw =  (2.0 * FILTER_CUTOFF * oversample *
		     spec->genomes[0].spatial_filter_radius /
		     spec->pixel_aspect_ratio);
       double adjust;
       filter_width = ((int) fw) + 1;
      /* make sure it has same parity as oversample */
      if ((filter_width ^ oversample) & 1)
	 filter_width++;
      if (fw > 0.0)
	adjust = FILTER_CUTOFF * filter_width / fw;
      else
	adjust = 1.0;

#if 0
      fprintf(stderr, "fw = %g filter_width = %d adjust=%g\n",
	      fw, filter_width, adjust);
#endif

      filter = (double *) malloc(sizeof(double) * filter_width * filter_width);
      /* fill in the coefs */
      for (i = 0; i < filter_width; i++)
	 for (j = 0; j < filter_width; j++) {
	    double ii = ((2.0 * i + 1.0) / filter_width - 1.0) * adjust;
	    double jj = ((2.0 * j + 1.0) / filter_width - 1.0) * adjust;
	    if (field) jj *= 2.0;
	    jj /= spec->pixel_aspect_ratio;
	    filter[i + j * filter_width] =
	       exp(-2.0 * (ii * ii + jj * jj));
	 }

      if (normalize_vector(filter, filter_width * filter_width)) {
	  fprintf(stderr, "spatial filter value is too small: %g.\n",
		  spec->genomes[0].spatial_filter_radius);
	  exit(1);
      }
#if 0
      printf("vvvvvvvvvvvvvvvvvvvvvvvvvvvv\n");
      for (j = 0; j < filter_width; j++) {
	 for (i = 0; i < filter_width; i++) {
	   printf(" %5d", (int)(10000 * filter[i + j * filter_width]));
	 }
	 printf("\n");
      }
      printf("^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
      fflush(stdout);
#endif
   }
   
   /* Temporal filter: set to box filter September 2005 from exponential */
   temporal_filter = (double *) malloc(sizeof(double) * nbatches);
   temporal_deltas = (double *) malloc(sizeof(double) * nbatches * ntemporal_samples);
   if (nbatches*ntemporal_samples > 1) {

      /* fill in the coefs */
      for (i = 0; i < nbatches*ntemporal_samples; i++) {
         temporal_deltas[i] = (2.0 * ((double) i / ((nbatches*ntemporal_samples) - 1)) - 1.0)
                                    * spec->temporal_filter_radius;
      }
      for (i = 0; i < nbatches; i++) {
         temporal_filter[i] = 1.0;
      }

      if (normalize_vector(temporal_filter, nbatches)) {
         fprintf(stderr, "temporal filter value is too small: %g.\n",
                           spec->temporal_filter_radius);
         exit(1);
      }
   } else {
      temporal_filter[0] = 1.0;
      temporal_deltas[0] = 0.0;
   }

#if 0
   fprintf(stderr,"Temporal Deltas:\n");
   for (j = 0; j < nbatches*ntemporal_samples; j++)
      fprintf(stderr, "%4f\n", temporal_deltas[j]);
   fprintf(stderr,"Temporal Filter:\n");
   for (j = 0; j < nbatches; j++)
      fprintf(stderr, "%4f\n", temporal_filter[j]);
   fprintf(stderr, "\n");
#endif

   /* the number of additional rows of buckets we put at the edge so
      that the filter doesn't go off the edge */

   gutter_width = (filter_width - oversample) / 2;

    /* Check the size of the density estimation filter. */
    /* If the 'radius' of the density estimation filter is greater than the */
    /* gutter width, we have to pad with more.  Otherwise, we can use the same value. */
   max_gnm_de_fw=0;
   for (gnm_idx = 0; gnm_idx < spec->ngenomes; gnm_idx++) {
		
      int this_width = (int)ceil(spec->genomes[gnm_idx].estimator) * oversample;
      if (this_width > max_gnm_de_fw)
         max_gnm_de_fw = this_width;			
	}
	
   /* Add one for the 3x3 averaging at the edges, if it's > 0 already */
   if (max_gnm_de_fw>0)
      max_gnm_de_fw = max_gnm_de_fw + 1;
	
	/* max_gnm_de_fw is now the number of pixels of additional gutter      */
	/* necessary to appropriately perform the density estimation filtering */
	/* Check to see if it's greater than the gutter_width                  */
	
	if (max_gnm_de_fw > gutter_width) {
		de_offset = max_gnm_de_fw - gutter_width;
		gutter_width = max_gnm_de_fw;
	} else
		de_offset = 0;
	
   height = oversample * image_height + 2 * gutter_width;
   width  = oversample * image_width  + 2 * gutter_width;

   nbuckets = width * height;
   if (1) {
   
     char *last_block = NULL;
     int memory_rqd = (sizeof(bucket) * nbuckets +
		       sizeof(abucket) * nbuckets +
		       4 * sizeof(double) * SUB_BATCH_SIZE);
     last_block = (char *) malloc(memory_rqd);
     if (NULL == last_block) {
       fprintf(stderr, "render_rectangle: cannot malloc %d bytes.\n", memory_rqd);
       fprintf(stderr, "render_rectangle: h=%d w=%d nb=%d.\n", width, height, nbuckets);
       exit(1);
     }
     /* else fprintf(stderr, "render_rectangle: mallocked %dMb.\n", Mb); */

     buckets = (bucket *) last_block;
     accumulate = (abucket *) (last_block + sizeof(bucket) * nbuckets);
     points = (double *)  (last_block + (sizeof(bucket) + sizeof(abucket)) * nbuckets);
   }

   if (verbose) {
     fprintf(stderr, "chaos: ");
     progress_began = time(NULL);
   }
/*
   if (fname) {
      int len = strlen(fname);
      FILE *fin = fopen(fname, "rb");
      int w, h;
      cmap2 = NULL;
      if (len > 4) {
         char *ending = fname + len - 4;
         if (!strcmp(ending, ".png")) {
            cmap2 = read_png(fin, &w, &h);
         } else if  (!strcmp(ending, ".jpg")) {
            cmap2 = read_jpeg(fin, &w, &h);
         }
      }
      if (NULL == cmap2) {
         perror(fname);
         exit(1);
      }
      if (256 != w || 256 != h) {
         fprintf(stderr, "image must be 256 by 256, not %d by %d.\n", w, h);
         exit(1);
      }
   }
*/
   background[0] = background[1] = background[2] = 0.0;
   memset((char *) accumulate, 0, sizeof(abucket) * nbuckets);

   /* Batch Loop */
   for (batch_num = 0; batch_num < nbatches; batch_num++) {
      double de_time;
      double sample_density;
      int de_row_size, de_kernel_index, de_half_size;
      int de_cutoff_val;
      double *de_filter_coefs,*de_filter_widths;
      int num_de_filters=0,filtloop;
      double comp_max_radius,comp_min_radius;
      double k1, area, k2;
      double ws0,wb0s0;
            
      de_time = spec->time + temporal_deltas[batch_num*ntemporal_samples];
      
      memset((char *) buckets, 0, sizeof(bucket) * nbuckets);         
      
      /* interpolate and get a control point                      */
      /* ONLY FOR DENSITY FILTER WIDTH PURPOSES                   */
      /* additional interpolation will be done in the temporal_sample loop */
      flam3_interpolate(spec->genomes, spec->ngenomes, de_time, &cp);      
      
      /* if instructed to by the genome, create the density estimation */
      /* filter kernels.  Check boundary conditions as well.           */
      if (cp.estimator < 0.0 || cp.estimator_minimum < 0.0) {
         fprintf(stderr,"density estimator filter widths must be >= 0\n");
         exit(1);
      }

      if (cp.estimator > 0.0) {

	 if (cp.estimator_curve <= 0.0) {
	    fprintf(stderr,"estimator curve must be > 0\n");
	    exit(1);
	 }
         
         if (cp.estimator < cp.estimator_minimum) {
            fprintf(stderr,"estimator must be larger than estimator_minimum.\n");
            fprintf(stderr,"(%f > %f) ? \n",cp.estimator,cp.estimator_minimum);
            exit(1);
         }

         /* We should scale the filter width by the oversample          */
         /* The '+1' comes from the assumed distance to the first pixel */
         comp_max_radius = cp.estimator * oversample + 1;
         comp_min_radius = cp.estimator_minimum * oversample + 1;
   
         /* Calculate how many filter kernels we need based on the decay function */
         /*                                                                       */
         /*    num filters = (de_max_width / de_min_width)^(1/estimator_curve)           */
         /*                                                                       */
         num_de_filters = ceil(pow( comp_max_radius/comp_min_radius, (1.0/cp.estimator_curve) ));
         
         /* Allocate the memory for these filters */
         /* and the hit/width lookup vector       */
         de_row_size = 2*ceil(comp_max_radius)-1;
         de_half_size = (de_row_size-1)/2;
         de_kernel_index = (de_half_size+1)*(2+de_half_size)/2;

         de_filter_coefs = (double *) malloc (num_de_filters * de_kernel_index * sizeof(double));
         de_filter_widths = (double *) malloc (num_de_filters * sizeof(double));
         
         /* Generate the filter coefficients */
         de_cutoff_val = 0;
         for (filtloop=0;filtloop<num_de_filters;filtloop++) {
         
            double de_filt_sum=0.0, de_filt_d;
            double de_filt_h = comp_max_radius / pow(filtloop+1,cp.estimator_curve);
            double dej,dek;
            int filter_coef_idx;
            
            if (de_filt_h <= comp_min_radius) {
               de_filt_h = comp_min_radius;
               de_cutoff_val = filtloop;
            }
            
            de_filter_widths[filtloop] = de_filt_h;
   
            /* Calculate norm of kernel separately (easier) */
            for (dej=-de_half_size; dej<=de_half_size; dej++) {
               for (dek=-de_half_size; dek<=de_half_size; dek++) {
                  de_filt_d = sqrt( (double)(dej*dej+dek*dek) ) / de_filt_h;
                  if (de_filt_d<=1)
                     de_filt_sum += (1.0 - (de_filt_d * de_filt_d));
               }
            }
   
            filter_coef_idx = filtloop*de_kernel_index;
            
            /* Calculate the unique entries of the kernel */            
            for (dej=0; dej<=de_half_size; dej++) {
               for (dek=0; dek<=dej; dek++) {
                  de_filt_d = sqrt( (double)(dej*dej+dek*dek) ) / de_filt_h;
   
                  if (de_filt_d>1)
                     de_filter_coefs[filter_coef_idx] = 0.0;
                  else 
                     de_filter_coefs[filter_coef_idx] = (1.0 - (de_filt_d * de_filt_d))/de_filt_sum;
                  filter_coef_idx ++;
               }
            }
            
            if (de_cutoff_val>0)
               break;
         }
         
         if (de_cutoff_val==0)
         	de_cutoff_val = num_de_filters-1;
      }
      
      for (temporal_sample_num = 0; temporal_sample_num < ntemporal_samples; temporal_sample_num++) {
         double temporal_sample_time;
         
         temporal_sample_time = spec->time + temporal_deltas[batch_num*ntemporal_samples + temporal_sample_num];
         
         /* Interpolate and get a control point */
         flam3_interpolate(spec->genomes, spec->ngenomes, temporal_sample_time, &cp);      

         prepare_xform_fn_ptrs(&cp);
            
         /* compute the colormap entries.                             */
         /* the input colormap is 256 long with entries from 0 to 1.0 */
         if (!fname) {
            for (j = 0; j < CMAP_SIZE; j++) {
               for (k = 0; k < 3; k++) {
#if 1
                  cmap[j][k] = (int) (cp.palette[(j * 256) / CMAP_SIZE][k] * WHITE_LEVEL);
#else
                  /* monochrome if you don't have any cmaps */
                  cmap[j][k] = WHITE_LEVEL;
#endif
               }
               cmap[j][3] = WHITE_LEVEL;
            }
         }

         /* compute camera */
         if (1) {
            double t0, t1, shift, corner0, corner1;
            double scale;

            if (cp.sample_density <= 0.0) {
              fprintf(stderr,
                 "sample density (quality) must be greater than zero,"
                 " not %g.\n", cp.sample_density);
              exit(1);
            }

            scale = pow(2.0, cp.zoom);
            sample_density = cp.sample_density * scale * scale;

            ppux = cp.pixels_per_unit * scale;
            ppuy = field ? (ppux / 2.0) : ppux;
            ppux /=  spec->pixel_aspect_ratio;
            switch (field) {
               case flam3_field_both: shift =  0.0; break;
               case flam3_field_even: shift = -0.5; break;
               case flam3_field_odd:  shift =  0.5; break;
            }
            shift = shift / ppux;
            t0 = (double) gutter_width / (oversample * ppux);
            t1 = (double) gutter_width / (oversample * ppuy);
            corner0 = cp.center[0] - image_width / ppux / 2.0;
            corner1 = cp.center[1] - image_height / ppuy / 2.0;
            bounds[0] = corner0 - t0;
            bounds[1] = corner1 - t1 + shift;
            bounds[2] = corner0 + image_width  / ppux + t0;
            bounds[3] = corner1 + image_height / ppuy + t1 + shift;
            size[0] = 1.0 / (bounds[2] - bounds[0]);
            size[1] = 1.0 / (bounds[3] - bounds[1]);
            rot[0][0] = cos(cp.rotate * 2 * M_PI / 360.0);
            rot[0][1] = -sin(cp.rotate * 2 * M_PI / 360.0);
            rot[1][0] = -rot[0][1];
            rot[1][1] = rot[0][0];
            ws0 = width * size[0];
            wb0s0 = ws0 * bounds[0];
            hs1 = height * size[1];
            hb1s1 = hs1 * bounds[1];
            
         }

         nsamples = sample_density * (double) nbuckets / (oversample * oversample);
#if 0
         fprintf(stderr, "sample_density=%g nsamples=%g nbuckets=%d\n",
   	      sample_density, nsamples, nbuckets);
#endif

         batch_size = nsamples / (cp.nbatches * cp.ntemporal_samples);

         sbc = 0;

         /* Sub-batch Loop */
         for (sub_batch = 0; sub_batch < batch_size; sub_batch += SUB_BATCH_SIZE) {

	     if (spec->progress&&!(sbc++&7)) {
		 double sb_fract = sub_batch / (double)batch_size;
		 double ts_fract = temporal_sample_num / (double)ntemporal_samples;
		 double b_fract = batch_num / (double)nbatches;
		 double fract = (b_fract +
				 ts_fract / (double)nbatches +
				 sb_fract / (double)(nbatches * ntemporal_samples));
		if ((*spec->progress)(spec->progress_parameter, fract, 0))
                  return;
	     }

            if (verbose && time(NULL) != progress_timer) {
               double percent = 100.0 *
                     ((((sub_batch / (double) batch_size) + temporal_sample_num) / ntemporal_samples) + batch_num)/nbatches;
               double eta;
               int old_mark = 0;
	       int ticker = (progress_timer&1)?':':'.';

               fprintf(stderr, "\rchaos: %5.1f%%", percent);
               progress_timer = time(NULL);
               if (progress_timer_history[progress_history_mark] &&
                     progress_history[progress_history_mark] < percent)
                  old_mark = progress_history_mark;

               if (percent > 0) {
                  eta = (100 - percent) * (progress_timer - progress_timer_history[old_mark])
                        / (percent - progress_history[old_mark]);

	       if (eta < 1000) ticker = ':';
               if (eta > 100)
		   fprintf(stderr, "  ETA%c %.1f minutes", ticker, eta / 60);
               else
		   fprintf(stderr, "  ETA%c %ld seconds ", ticker, (long) ceil(eta));

               fprintf(stderr, "              \r");
               
               fflush(stderr);
               }

               progress_timer_history[progress_history_mark] = progress_timer;
               progress_history[progress_history_mark] = percent;
               progress_history_mark = (progress_history_mark + 1) % 64;
            }


            /* generate a sub_batch_size worth of samples */
            points[0] = flam3_random11();
            points[1] = flam3_random11();
            points[2] = flam3_random01();
            points[3] = flam3_random01();
            
/*            
            gettimeofday(&tp,NULL);
            t1 = (double)tp.tv_sec + 1.e-6*tp.tv_usec;
*/            
            
            flam3_iterate(&cp, SUB_BATCH_SIZE, FUSE, points);
/*
            gettimeofday(&tp,NULL);
            t2 = (double)tp.tv_sec + 1.e-6*tp.tv_usec;
            
            e1 += t2-t1;

            gettimeofday(&tp,NULL);
            t1 = (double)tp.tv_sec + 1.e-6*tp.tv_usec;
*/
            /* merge them into buckets, looking up colors */
            for (j = 0; j < SBS_X4; j+=4) {
               double p0, p1, p00, p11;
               int k, color_index0, color_index1;
               double *p = &points[j];
               bucket *b;
               
               if (cp.rotate != 0.0) {
                  p00 = p[0] - cp.rot_center[0];
                  p11 = p[1] - cp.rot_center[1];
                  p0 = p00 * rot[0][0] + p11 * rot[0][1] + cp.rot_center[0];
                  p1 = p00 * rot[1][0] + p11 * rot[1][1] + cp.rot_center[1];
               } else {
                  p0 = p[0];
                  p1 = p[1];
               }
               
               if (p0 >= bounds[0] && p1 >= bounds[1] && p0 <= bounds[2] && p1 <= bounds[3])
               {
               
                  if (fname) {
                     int ci;
                     color_index0 = (int) (p[2] * CMAP_SIZE);
                     color_index1 = (int) (p[3] * CMAP_SIZE);
                     
                     if (color_index0 < 0) color_index0 = 0;
                     else if (color_index0 > (CMAP_SIZE-1))
                        color_index0 = CMAP_SIZE-1;
                     
                     if (color_index1 < 0) color_index1 = 0;
                     else if (color_index1 > (CMAP_SIZE-1))
                        color_index1 = CMAP_SIZE-1;
                     
                     b = buckets +
                     (int) (width * (p0 - bounds[0]) * size[0]) +
                     width * (int) (height * (p1 - bounds[1]) * size[1]);
                     
                     ci = 4 * (CMAP_SIZE * color_index1 + color_index0);
                     
                     for (k = 0; k < 4; k++)
                        bump_no_overflow(b[0][k], cmap2[ci+k]);
                  } else {
                     
                     color_index0 = (int) (p[2] * CMAP_SIZE);
                     if (color_index0 < 0)
                        color_index0 = 0;
                     else if (color_index0 > CMAP_SIZE_M1)
                        color_index0 = CMAP_SIZE_M1;
                     
                     /* b = buckets +
                     (int) (width * (p0 - bounds[0]) * size[0]) +
                     width * (int) (height * (p1 - bounds[1]) * size[1]);*/
                     
                     b = buckets + (int)(ws0 * p0 - wb0s0) + width * (int)(hs1 * p1 - hb1s1);
                     
                     bump_no_overflow(b[0][0], cmap[color_index0][0]);
                     bump_no_overflow(b[0][1], cmap[color_index0][1]);
                     bump_no_overflow(b[0][2], cmap[color_index0][2]);
                     bump_no_overflow(b[0][3], cmap[color_index0][3]);
                     
                  }
               }
            }

/*
            gettimeofday(&tp,NULL);
            t2 = (double)tp.tv_sec + 1.e-6*tp.tv_usec;
            
            e2 += t2-t1;
*/
         } /* End Sub-Batch Loop */

         vibrancy += cp.vibrancy;
         gamma += cp.gamma;
         background[0] += cp.background[0];
         background[1] += cp.background[1];
         background[2] += cp.background[2];
         vib_gam_n++;

      } /* End Temporal_Sample Loop */
      
      k1 =(cp.contrast * cp.brightness *
	   PREFILTER_WHITE * 268.0 *
	   temporal_filter[batch_num]) / 256;
      area = image_width * image_height / (ppux * ppuy);
      k2 = (oversample * oversample * nbatches) /
	(cp.contrast * area * WHITE_LEVEL * sample_density);
/*
      printf("contrast=%f, brightness=%f, PREFILTER=%d, temporal_filter=%f\n", cp.contrast, cp.brightness, PREFILTER_WHITE, temporal_filter[batch_num]);
      printf("oversample=%d, nbatches=%d, area = %f, WHITE_LEVEL=%d, sample_density=%f\n", oversample, nbatches, area, WHITE_LEVEL, sample_density);
*/
      /* log intensity accumulation */

      /* Apply density estimation? */
      if (num_de_filters == 0) {

         /* Standard (original) histobinning code */	 
         for (j = 0; j < height; j++) {
            for (i = 0; i < width; i++) {

               abucket *a = accumulate + i + j * width;
               bucket *b = buckets + i + j * width;
               double c[4], ls;
               
               c[0] = (double) b[0][0];
               c[1] = (double) b[0][1];
               c[2] = (double) b[0][2];
               c[3] = (double) b[0][3];
               if (0.0 == c[3])
                  continue;
               
               ls = (k1 * log(1.0 + c[3] * k2))/c[3];
               c[0] *= ls;
               c[1] *= ls;
               c[2] *= ls;
               c[3] *= ls;
               
               abump_no_overflow(a[0][0], c[0]);
               abump_no_overflow(a[0][1], c[1]);
               abump_no_overflow(a[0][2], c[2]);
               abump_no_overflow(a[0][3], c[3]);
            }
         }
      } else {
	
         /* Density estimation code */
         /* Remember, we already padded with an extra pixel at the beginning */
         for (j = 1; j < height-1; j++) {
            for (i = 1; i < width-1; i++) {
				
               int ii,jj;
               double f_select=0.0;
               int f_select_int,f_coef_idx;
               int arr_filt_width;
               bucket *b;
               double c[4],ls;
               
               b = buckets + i + j*width;
               
               /* Don't do anything if there's no hits here */
               if (b[0][3] == 0)
                  continue;

               /* Count density in 3x3 area */					
               /* Might not be necessary.   */
#if 1
               for (ii=-1; ii<=1; ii++) {
                  for (jj=-1; jj<=1; jj++) {                  
                     b = buckets + (i + ii) + (j + jj)*width;
                     f_select += b[0][3]/255.0;
                  }
               }

               f_select /= 9.0;
#else					
               f_select = b[0][3]/255.0;
#endif
					
               f_select_int = (int)ceil(f_select)-1;
					
               b = buckets + i + j*width;
					
               /* If the filter selected below the min specified clamp it to the min */
               if (f_select_int >= de_cutoff_val)
                  f_select_int = de_cutoff_val;
                              
               /* We only have to calculate the values for ~1/8 of the square */
               f_coef_idx = f_select_int*de_kernel_index;
   
               arr_filt_width = (int)ceil(de_filter_widths[f_select_int])-1;
					
               for (jj=0; jj<=arr_filt_width; jj++) {
                  for (ii=0; ii<=jj; ii++) {
							
                     /* Skip if coef is 0 */
                     if (de_filter_coefs[f_coef_idx]==0.0) {
                        f_coef_idx++;
                        continue;
                     }
                        
                     c[0] = (double)b[0][0] * de_filter_coefs[f_coef_idx];
                     c[1] = (double)b[0][1] * de_filter_coefs[f_coef_idx];
                     c[2] = (double)b[0][2] * de_filter_coefs[f_coef_idx];
                     c[3] = (double)b[0][3] * de_filter_coefs[f_coef_idx];
                     
                     ls = (k1 * log(1.0 + c[3] * k2))/c[3];
                     
                     c[0] *= ls;
                     c[1] *= ls;
                     c[2] *= ls;
                     c[3] *= ls;
							
                     if (jj==0 && ii==0) {
                        add_c_to_accum(accumulate,i,ii,j,jj,width,height,c);
                     }
                     else if (ii==0) {
                        add_c_to_accum(accumulate,i,jj,j,0,width,height,c);
                        add_c_to_accum(accumulate,i,-jj,j,0,width,height,c);
                        add_c_to_accum(accumulate,i,0,j,jj,width,height,c);
                        add_c_to_accum(accumulate,i,0,j,-jj,width,height,c);
                     } else if (jj==ii) {
                        add_c_to_accum(accumulate,i,ii,j,jj,width,height,c);
                        add_c_to_accum(accumulate,i,-ii,j,jj,width,height,c);
                        add_c_to_accum(accumulate,i,ii,j,-jj,width,height,c);
                        add_c_to_accum(accumulate,i,-ii,j,-jj,width,height,c);
                     } else {
                        add_c_to_accum(accumulate,i,ii,j,jj,width,height,c);
                        add_c_to_accum(accumulate,i,-ii,j,jj,width,height,c);
                        add_c_to_accum(accumulate,i,ii,j,-jj,width,height,c);
                        add_c_to_accum(accumulate,i,-ii,j,-jj,width,height,c);
                        add_c_to_accum(accumulate,i,jj,j,ii,width,height,c);
                        add_c_to_accum(accumulate,i,-jj,j,ii,width,height,c);
                        add_c_to_accum(accumulate,i,jj,j,-ii,width,height,c);
                        add_c_to_accum(accumulate,i,-jj,j,-ii,width,height,c);
                     }
                     
                     f_coef_idx++;
							
                  }
               }
            }
	    if (verbose && time(NULL) != progress_timer) {
		progress_timer = time(NULL);
		fprintf(stderr, "\rdensity estimation: %d/%d          ", j, height);
		fflush(stderr);
	    }
	 
         }
	 
      } /* End density estimation loop */
		
		/* If allocated, free the de filter memory for the next batch */
      if (num_de_filters > 0.0) {
         free(de_filter_coefs);
         free(de_filter_widths);
      }
      
      /* Theoretical: filter accumulator down into image here. */
      
   } /* End main batch loop*/

   if (verbose) {
     fprintf(stderr, "\rchaos: 100.0%%  took: %ld seconds   \n", time(NULL) - progress_began);
/*     fprintf(stderr, "iterations took: %g seconds, merge took: %g seconds  \n",e1,e2);*/
     fprintf(stderr, "filtering...");
   }
 
   /*
    * filter the accumulation buffer down into the image
    */
   if (1) {
      int x, y;
      double t[4];
      double g = 1.0 / (gamma / vib_gam_n);
      double tmp;

      double linrange = cp.gam_lin_thresh;
      double funcval = pow(linrange,g);
      double frac;
      
      vibrancy /= vib_gam_n;
      background[0] /= vib_gam_n/256.0;
      background[1] /= vib_gam_n/256.0;
      background[2] /= vib_gam_n/256.0;
      y = de_offset;
      
      for (j = 0; j < image_height; j++) {
	  if (spec->progress && !(j&15))
	      if ((*spec->progress)(spec->progress_parameter,
				    j/(double)image_height, 1))
            return;
         x = de_offset;
         for (i = 0; i < image_width; i++) {
            int ii, jj;
            unsigned char *p;
            double ls, a;
            double alpha;
            t[0] = t[1] = t[2] = t[3] = 0.0;
            for (ii = 0; ii < filter_width; ii++) {
               for (jj = 0; jj < filter_width; jj++) {
                  double k = filter[ii + jj * filter_width];
                  abucket *a = accumulate + x + ii + (y + jj) * width;
                  
                  t[0] += k * a[0][0];
                  t[1] += k * a[0][1];
                  t[2] += k * a[0][2];
                  t[3] += k * a[0][3];
                  
               }
            }
            
            p = out + nchan * (i + j * out_width);
            
            if (t[3] > 0.0) {

               tmp = t[3]/PREFILTER_WHITE;

               if (tmp<=linrange) { 
                  /* Small Gamma Linearization */
                  frac = tmp/linrange;                  
                  alpha = (1.0-frac) * tmp * (funcval / linrange) + frac * pow(tmp,g);                  
               } else {
                  /* Standard */
                  alpha = pow(tmp, g);
               }

               ls = vibrancy * 256.0 * alpha / tmp;

               if (alpha < 0.0) 
                  alpha = 0.0;
               else if (alpha > 1.0) 
                  alpha = 1.0;
               

               
            } else {
               ls = 0.0;
               alpha = 0.0;
            }
            
            /* apply to rgb channels the relative scale from gamma of alpha channel */   
            /* red */
            a = ls * ((double) t[0] / PREFILTER_WHITE);
            a += (1.0-vibrancy) * 256.0 * pow((double) t[0] / PREFILTER_WHITE, g);
            if (nchan<=3 || transp==0)
               a += ((1.0 - alpha) * background[0]);
            else
               a /= alpha;
            
            if (a > 255)
               a = 255;
            if (a < 0)
               a = 0;

	    
            p[0] = (unsigned char) a;
            
            /* green */
            a = ls * ((double) t[1] / PREFILTER_WHITE);
            a += (1.0-vibrancy) * 256.0 * pow((double) t[1] / PREFILTER_WHITE, g);
            if (nchan<=3 || transp==0)
               a += ((1.0 - alpha) * background[1]);
            else
               a /= alpha;

            if (a > 255)
               a = 255;
            if (a < 0)
               a = 0;

            p[1] = (unsigned char) a;
            
            /* blue */
            a = ls * ((double) t[2] / PREFILTER_WHITE);
            a += (1.0-vibrancy) * 256.0 * pow((double) t[2] / PREFILTER_WHITE, g);
            if (nchan<=3 || transp==0)
               a += ((1.0 - alpha) * background[2]);
            else
               a /= alpha;

            if (a > 255)
               a = 255;
            if (a < 0)
               a = 0;

            p[2] = (unsigned char) a;
            
            /* alpha */
            if (nchan>3) {
	      if (transp==1)
		p[3] = (unsigned char) (alpha * 255.999);
	      else
		p[3] = 255;
	    }
            
            x += oversample;
         }
         y += oversample;
      }
   }
   
   free(filter);
   free(buckets);
   if (fname) free(cmap2);
}
