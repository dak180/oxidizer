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


#include "private.h"
#include "img.h"
#include "isaacs.h"

int main(int argc, char **argv) {
  char *ai, *fname;
  char flamename[256];
  char *prefix = args("prefix", "");
  int first_frame = argi("begin", 0);
  int last_frame = argi("end", 0);
  int frame_time = argi("time", 0);
  int dtime = argi("dtime", 1);
  int do_fields = argi("fields", 0);
  int write_genome = argi("write_genome",0);
  double qs = argf("qs", 1.0);
  double ss = argf("ss", 1.0);
  char *format = getenv("format");
  int verbose = argi("verbose", 1);
  int transparency = argi("transparency", 0);
  int bits = argi("bits", 33);
  int sub_batch_size = argi("sub_batch_size", 10000);
  int bpc = argi("bpc",8);
  int earlyclip = argi("earlyclip",0);
  int ftime, channels;
  unsigned char *image;
  flam3_genome *cps,center_cp;
  int i, ncps = 0;
  char *inf = getenv("in");
  double pixel_aspect = argf("pixel_aspect", 1.0);
  int num_threads = argi("nthreads",0);
  FILE *in,*fp,*genfp;
  flam3_frame f;
  flam3_img_comments fpc;
  stat_struct stats,stats2;

  char badval_string[64];
  char numiter_string[64];
  char rtime_string[64];
  
#ifdef WIN32
   
  char *slashloc;
  char exepath[256];
  char palpath[256];
  memset(exepath,0,256);
  memset(palpath,0,256);  
   slashloc = strrchr(argv[0],'\\');
	if (NULL==slashloc) {
	   sprintf(palpath,"flam3_palettes=flam3-palettes.xml");
	} else {
       strncpy(exepath,argv[0],slashloc-argv[0]+1);
	   sprintf(palpath,"flam3_palettes=%sflam3-palettes.xml",exepath);
	}
	putenv(palpath);

#endif         
  
  
  memset(&center_cp,0, sizeof(flam3_genome));

  if (1 != argc) {
      docstring();
      exit(0);
  }

   /* Init random number generators */
   flam3_init_frame(&f);
   flam3_srandom();

   /* Set the number of threads */
   if (num_threads==0) {
      num_threads = flam3_count_nthreads();
      if (verbose > 1)
         fprintf(stderr,"Automatically detected %d core(s)...\n",num_threads);
   } else{
      if (verbose)
         fprintf(stderr,"Manually specified %d thread(s)...\n",num_threads);
   }

  if (getenv("frame")) {
    if (getenv("time")) {
      fprintf(stderr, "cannot specify both time and frame.\n");
      exit(1);
    }
    if (getenv("begin") || getenv("end")) {
      fprintf(stderr, "cannot specify both frame and begin or end.\n");
      exit(1);
    }
    first_frame = last_frame = atoi(getenv("frame"));
  }

  if (getenv("time")) {
    if (getenv("begin") || getenv("end")) {
      fprintf(stderr, "cannot specify both time and begin or end.\n");
      exit(1);
    }
    first_frame = last_frame = frame_time;
  }

  if (NULL == format) format = "png";
  if (strcmp(format, "jpg") &&
      strcmp(format, "ppm") &&
      strcmp(format, "png")) {
      fprintf(stderr, "format must be either jpg, ppm, or png, not %s.\n", format);
      exit(1);
  }


   if (pixel_aspect <= 0.0) {
     fprintf(stderr, "pixel aspect ratio must be positive, not %g.\n",
        pixel_aspect);
     exit(1);
   }

  if (inf)
    in = fopen(inf, "rb");
  else
    in = stdin;
  if (NULL == in) {
    perror(inf);
    exit(1);
  }

  cps = flam3_parse_from_file(in, inf, flam3_defaults_on, &ncps);
  if (inf)
    fclose(in);
  if (NULL == cps) {
    fprintf(stderr," error reading genomes.\n");
    exit(1);
  }
  if (0 == ncps) {
    fprintf(stderr, "error: no genomes.\n");
    exit(1);
  }
  for (i = 0; i < ncps; i++) {
    cps[i].sample_density *= qs;
    cps[i].height = (int)(cps[i].height * ss);
    cps[i].width = (int)(cps[i].width * ss);
    cps[i].pixels_per_unit *= ss;
    if (cps[i].height<=0 || cps[i].width<=0) {
       fprintf(stderr,"output image has dimension <=0, aborting.\n");
       exit(1);
    }
    if (i > 0 && cps[i].time <= cps[i-1].time) {
   fprintf(stderr, "error: control points must be sorted by time, but %g <= %g, index %d.\n",
      cps[i].time, cps[i-1].time, i);
   exit(1);
    }
    if ((cps[i].width != cps[0].width) ||
   (cps[i].height != cps[0].height)) {
      fprintf(stderr, "warning: flame %d at time %g size mismatch.  "
         "(%d,%d) should be (%d,%d).\n",
         i, cps[i].time,
         cps[i].width, cps[i].height,
         cps[0].width, cps[0].height);
      cps[i].width = cps[0].width;
      cps[i].height = cps[0].height;
    }
  }
  if (!getenv("time") && !getenv("frame")) {
    if (!getenv("begin")) {
      first_frame = (int) cps[0].time;
    }
    if (!getenv("end")) {
      last_frame = (int) cps[ncps-1].time - 1;
      if (last_frame < first_frame) last_frame = first_frame;
    }
  }
  channels = strcmp(format, "png") ? 3 : 4;

   /* Check for 16-bit-per-channel processing */
   if ( (16 == bpc) && (strcmp(format,"png") != 0)) {
	fprintf(stderr,"Support for 16 bpc images is only present for the png format.\n");
	exit(1);
   } else if (bpc != 8 && bpc != 16) {
	fprintf(stderr,"Unexpected bpc specified (%d)\n",bpc);
	exit(1);
   }
   
//  f.temporal_filter_radius = argf("blur", 0.5);
  f.pixel_aspect_ratio = pixel_aspect;
  f.genomes = cps;
  f.ngenomes = ncps;
  f.verbose = verbose;
  f.bits = bits;
  f.progress = 0;
  f.earlyclip = earlyclip;
  f.nthreads = num_threads;
  f.sub_batch_size = sub_batch_size;

  if (16==bpc)
     f.bytes_per_channel = 2;
  else
     f.bytes_per_channel = 1;
         

  image = (void *) calloc((size_t)channels *
				   (size_t)cps[0].width *
				   (size_t)cps[0].height * f.bytes_per_channel, sizeof(char));

  if (dtime < 1) {
    fprintf(stderr, "dtime must be positive, not %d.\n", dtime);
    exit(1);
  }

  for (ftime = first_frame; ftime <= last_frame; ftime += dtime) {
    f.time = (double) ftime;

    if (verbose && ((last_frame-first_frame)/dtime) >= 1) {
       fprintf(stderr, "time = %d/%d/%d\n", ftime, last_frame, dtime);
    }

    if (do_fields) {
    
   if (flam3_render(&f, image, flam3_field_even, channels, transparency,&stats)) {
      fprintf(stderr,"error rendering image: aborting.\n");
      exit(1);
   }
   f.time += 0.5;
   if (flam3_render(&f, image, flam3_field_odd, channels, transparency,&stats2)) {
      fprintf(stderr,"error rendering image: aborting.\n");
      exit(1);
   }

   stats.badvals+=stats2.badvals;
   stats.render_seconds+=stats2.render_seconds;
   stats.num_iters+=stats2.num_iters;
    } else {
   if (flam3_render(&f, image, flam3_field_both, channels, transparency,&stats)) {
      fprintf(stderr,"error rendering image: aborting.\n");
      exit(1);
   }
    }

    if (getenv("out"))
       fname = getenv("out");
    else {
       fname = malloc(strlen(prefix) + 20);
       sprintf(fname, "%s%05d.%s", prefix, ftime, format);
    }

    if (verbose)
       fprintf(stderr, "writing %s...", fname);

    if (write_genome) {
       sprintf(flamename,"%s.flam3",fname);
   
       /* get center genome */
       flam3_interpolate(f.genomes, f.ngenomes, f.time, 0, &center_cp);
       
       /* write it out */
       genfp = fopen(flamename,"w");
       if (NULL == genfp) {
           perror(flamename);
           exit(1);
       }
       
       flam3_print(genfp, &center_cp, NULL, flam3_print_edits);
       
       fclose(genfp);
    }

    fp = fopen(fname, "wb");
    if (NULL == fp) {
       perror(fname);
       exit(1);
    }

    /* Get center cp for embedding in png file */
    flam3_interpolate(f.genomes, f.ngenomes, f.time, 0, &center_cp);
   
    /* Convert to string */
    fpc.genome = flam3_print_to_string(&center_cp);      
    sprintf(badval_string, "%g",stats.badvals/(double)stats.num_iters);
    fpc.badvals = badval_string;
    sprintf(numiter_string,"%g",(double)stats.num_iters);
    fpc.numiters = numiter_string;
    sprintf(rtime_string,"%d",stats.render_seconds);
    fpc.rtime = rtime_string;
   
    if (!strcmp(format, "png")) {
    
       write_png(fp, image, cps[0].width, cps[0].height, &fpc, f.bytes_per_channel);       
       
    } else if (!strcmp(format, "jpg")) {
    
       write_jpeg(fp, image, cps[0].width, cps[0].height, &fpc);

    } else {
	int size = 3 * cps[0].width * cps[0].height;
       fprintf(fp, "P6\n");
       fprintf(fp, "%d %d\n255\n", cps[0].width, cps[0].height);
       if (size != fwrite(image, 1, size, fp)) {
	   perror(fname);
       }
    }

    /* Free string */
    free(fpc.genome);
    
    clear_cp(&center_cp,0);

    fclose(fp);

    if (!getenv("out"))
       free(fname);

  }
  
  for (i = 0; i < ncps; i++) {
     xmlFreeDoc(cps[i].edits);
     clear_cp(&cps[i],0);
  }
  free(cps);

  free(image);
  
  if (verbose)
    fprintf(stderr, "done.\n");

  fflush(stderr);
  return 0;
}
