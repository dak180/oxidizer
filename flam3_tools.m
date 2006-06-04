//
//  flam3_tools.m
//  oxidizer
//
//  Created by David Burnett on 02/06/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "flam3_tools.h"

void improve_colors(flam3_genome *g, int ntries, int change_palette, int color_resolution) {
   int i;
   double best, b;
   flam3_genome best_genome;
   
   memset(&best_genome, 0, sizeof(flam3_genome));
   
   best = try_colors(g, color_resolution);
   flam3_copy(&best_genome,g);
   for (i = 0; i < ntries; i++) {
      change_colors(g, change_palette);
      b = try_colors(g, color_resolution);
      if (b > best) {
         best = b;
         flam3_copy(&best_genome,g);
      }
   }
   flam3_copy(g,&best_genome);
   
   free(best_genome.xform);
}

xmlDocPtr create_new_editdoc(char *action, flam3_genome *parent0, flam3_genome *parent1) {
   
   xmlDocPtr doc = NULL, comment_doc = NULL;
   xmlNodePtr root_node = NULL, node = NULL, nodecopy = NULL;
   xmlNodePtr root_comment = NULL;
   struct tm *localt;
   time_t mytime;

   char timestring[100];
   const char *nick;
   const char *url ;
   const char *comment;
   int sheep_gen = -1;
   int sheep_id = -1;
   char buffer[100];
   char comment_string[100];
   
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];

	nick =	  [[defaults stringForKey:@"nick"] cStringUsingEncoding:NSUTF8StringEncoding];
	url	=     [[defaults stringForKey:@"url"] cStringUsingEncoding:NSUTF8StringEncoding];
	comment = [[defaults stringForKey:@"comment"] cStringUsingEncoding:NSUTF8StringEncoding];

   
   
   doc = xmlNewDoc( (const xmlChar *)"1.0");
   
   /* Create the root node, called "edit" */
   root_node = xmlNewNode(NULL, (const xmlChar *)"edit");
   xmlDocSetRootElement(doc,root_node);
   /* Add the edit attributes */
   
   /* date */
   mytime = time(NULL);
   localt = localtime(&mytime);
   /* XXX use standard time format including timezone */
   strftime(timestring, 100, "%a %b %e %H:%M:%S %Z %Y", localt);
   xmlNewProp(root_node, (const xmlChar *)"date", (const xmlChar *)timestring);

   /* nick */
   if (nick) {
      xmlNewProp(root_node, (const xmlChar *)"nick", (const xmlChar *)nick);
   }
   
   /* url */
   if (url) {
      xmlNewProp(root_node, (const xmlChar *)"url", (const xmlChar *)url);
   }
   
   /* action */
   xmlNewProp(root_node, (const xmlChar *)"action", (const xmlChar *)action);
   
   /* sheep info */
   if (sheep_gen > 0 && sheep_id > 0) {
      /* Create a child node of the root node called sheep */
      node = xmlNewChild(root_node, NULL, (const xmlChar *)"sheep", NULL);
      
      /* Create the sheep attributes */
      sprintf(buffer, "%d", sheep_gen);
      xmlNewProp(node, (const xmlChar *)"generation", (const xmlChar *)buffer);
      
      sprintf(buffer, "%d", sheep_id);
      xmlNewProp(node, (const xmlChar *)"id", (const xmlChar *)buffer);
   }

   /* Check for the parents */
   /* If Parent 0 not specified, this is a randomly generated genome. */
   if (parent0) {
      if (parent0->edits) {
         /* Copy the node from the parent */
         node = xmlDocGetRootElement(parent0->edits);
         nodecopy = xmlCopyNode(node, 1);
         xmlNewProp(nodecopy,(const xmlChar *)"filename", (const xmlChar *)parent0->parent_fname);
         sprintf(buffer,"%d",parent0->genome_index);
         xmlNewProp(nodecopy,(const xmlChar *)"index", (const xmlChar *)buffer);
         xmlAddChild(root_node, nodecopy);      
      } else {
         /* Insert a (parent has no edit) message */
         nodecopy = xmlNewChild(root_node, NULL, (const xmlChar *)"edit",NULL);
         xmlNewProp(nodecopy,(const xmlChar *)"filename", (const xmlChar *)parent0->parent_fname);
         sprintf(buffer,"%d",parent0->genome_index);
         xmlNewProp(nodecopy,(const xmlChar *)"index", (const xmlChar *)buffer);
         
      }
   }
   
   if (parent1) {
      
      if (parent1->edits) {
         /* Copy the node from the parent */
         node = xmlDocGetRootElement(parent1->edits);
         nodecopy = xmlCopyNode(node, 1);
         xmlNewProp(nodecopy,(const xmlChar *)"filename", (const xmlChar *)parent1->parent_fname);
         sprintf(buffer,"%d",parent1->genome_index);
         xmlNewProp(nodecopy,(const xmlChar *)"index", (const xmlChar *)buffer);
         xmlAddChild(root_node, nodecopy);
      } else {
         /* Insert a (parent has no edit) message */
         nodecopy = xmlNewChild(root_node, NULL, (const xmlChar *)"edit",NULL);
         xmlNewProp(nodecopy,(const xmlChar *)"filename", (const xmlChar *)parent1->parent_fname);
         sprintf(buffer,"%d",parent1->genome_index);
         xmlNewProp(nodecopy,(const xmlChar *)"index", (const xmlChar *)buffer);
      }
   }

   /* Comment string */
   /* This one's hard, since we have to treat the comment string as   */
   /* a valid XML document.  Create a new document using the comment  */
   /* string as the in-memory document, and then copy all children of */
   /* the root node into the edit structure                           */
   /* Parsing the comment string should be done once and then copied  */
   /* for each call to create_new_editdoc, but that's for later.      */
   if (comment) {
      
      sprintf(comment_string,"<comm>%s</comm>",comment);
      
      comment_doc = xmlReadMemory(comment_string, strlen(comment_string), "comment.env", NULL, XML_PARSE_NONET);

      /* Check for errors */
      if (comment_doc==NULL) {
         fprintf(stderr, "Failed to parse comment into XML!\n");
         exit(1);
      }
      
      /* Loop through the children of the new document and copy */
      /* them into the root_node */
      root_comment = xmlDocGetRootElement(comment_doc);

      for (node=root_comment->children; node; node = node->next) { 

         nodecopy = xmlCopyNode(node,1);
         xmlAddChild(root_node, nodecopy);
      }
      
      /* Free the created document */
      xmlFreeDoc(comment_doc);
   }
      

   /* return the xml doc */   
   return(doc);
}

double try_colors(flam3_genome *g, int color_resolution) {
    int *hist;
    int i, hits, res = color_resolution;
    int res3 = res * res * res;
    flam3_frame f;
    unsigned char *image, *p;
    flam3_genome saved;
    
    memset(&saved, 0, sizeof(flam3_genome));
    
    flam3_copy(&saved, g);

    g->sample_density = 1;
    g->spatial_oversample = 1;
    g->estimator = 0.0;
    g->width = 100; // XXX keep aspect ratio
    g->height = 100;
    g->pixels_per_unit = 50;
    g->nbatches = 1;
    g->ntemporal_samples = 1;
    
    f.temporal_filter_radius = 0.0;
    f.bits = 32;
    f.verbose = 0;
    f.genomes = g;
    f.ngenomes = 1;
    f.pixel_aspect_ratio = 1.0;
    f.progress = 0;

    image = (unsigned char *) calloc(g->width * g->height, 3);
    flam3_render(&f, image, g->width, flam3_field_both, 3, 0);

    hist = calloc(sizeof(int), res3);
    p = image;
    for (i = 0; i < g->height * g->width; i++) {
       hist[(p[0] * res / 256) + 
            (p[1] * res / 256) * res +
            (p[2] * res / 256) * res * res]++;
       p += 3;
    }

    if (0) {
       int j, k;
       for (i = 0; i < res; i++) {
          fprintf(stderr, "\ni=%d: \n", i);
          for (j = 0; j < res; j++) {
             for (k = 0; k < res; k++) {
                fprintf(stderr, " %5d", hist[i * res * res + j * res + k]);
             }
             fprintf(stderr, "\n");
          }
       }
    }

    hits = 0;
    for (i = 0; i < res3; i++) {
       if (hist[i]) hits++;
    }
    
    free(hist);
    free(image);
    
    g->sample_density = saved.sample_density;
    g->width = saved.width;
    g->height = saved.height;
    g->spatial_oversample = saved.spatial_oversample;
    g->pixels_per_unit = saved.pixels_per_unit;
    g->nbatches = saved.nbatches;
    g->ntemporal_samples = saved.ntemporal_samples;
    g->estimator = saved.estimator;
    
    /* Free xform storage */
    free(saved.xform);
    
    return (double) hits / res3;
}

int random_xform(flam3_genome *g, int excluded) {
   int ntries = 0;
   while (ntries++ < 100) {
      int i = random() % g->num_xforms;
      if (g->xform[i].density > 0.0 && i != excluded)
         return i;
   }
   return -1;
}

void change_colors(flam3_genome *g, int change_palette) {
   int i;
   int x0, x1;
   if (change_palette) {
      g->hue_rotation = 0.0;
      g->palette_index = flam3_get_palette(flam3_palette_random, g->palette, 0.0);
   }
   for (i = 0; i < g->num_xforms; i++) {
      g->xform[i].color[0] = flam3_random01();
   }
   x0 = random_xform(g, -1);
   x1 = random_xform(g, x0);
   if (x0 >= 0 && (random()&1)) g->xform[x0].color[0] = 0.0;
   if (x1 >= 0 && (random()&1)) g->xform[x1].color[0] = 1.0;
}

void test_cp(flam3_genome *cp) {
   cp->time = 0.0;
   cp->interpolation = flam3_interpolation_linear;
   cp->background[0] = 0.0;
   cp->background[1] = 0.0;
   cp->background[2] = 0.0;
   cp->center[0] = 0.0;
   cp->center[1] = 0.0;
   cp->rotate = 0.0;
   cp->pixels_per_unit = 64;
   cp->width = 128;
   cp->height = 128;
   cp->spatial_oversample = 1;
   cp->spatial_filter_radius = 0.5;
   cp->zoom = 0.0;
   cp->sample_density = 25;
   cp->nbatches = 1;
   cp->ntemporal_samples = 1;
   cp->estimator = 0.0;
   cp->estimator_minimum = 0.0;
   cp->estimator_curve = 0.6;
}

void truncate_variations(flam3_genome *g, int max_vars, char *action) {
   int i, j, nvars, smallest;
   double sv;
   char trunc_note[30];
   
   for (i = 0; i < g->num_xforms; i++) {
      double d = g->xform[i].density;
      
/*      if (0.0 < d && d < 0.001) */

      if (d < 0.001 && (g->final_xform_index != i)) {
         sprintf(trunc_note," trunc_density %d",i);
         strcat(action,trunc_note);
         flam3_delete_xform(g, i);

/*         g->xform[i].density = 0.0;
      } else if (d > 0.0) {
*/
      } else {
         do {
            nvars = 0;
            smallest = -1;
            for (j = 0; j < flam3_nvariations; j++) {
               double v = g->xform[i].var[j];
               if (v != 0.0) {
                  nvars++;
                  if (-1 == smallest || fabs(v) < sv) {
                     smallest = j;
                     sv = fabs(v);
                  }
               }
            }
            if (nvars > max_vars) {
               sprintf(trunc_note," trunc %d %d",i,smallest);
               strcat(action,trunc_note);
               g->xform[i].var[smallest] = 0.0;
            }
         } while (nvars > max_vars);
      }
   }
}



