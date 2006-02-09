/*
    flame - cosmic recursive fractal flames
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

static char *libifs_c_id =
"@(#) $Id: flam3.c,v 1.1 2006/02/09 13:41:07 vargol Exp $";


#include "private.h"
//#include "img.h"
#include <limits.h>


char *flam3_version() {
    return VERSION;
}


#define SUB_BATCH_SIZE     10000
#define CHOOSE_XFORM_GRAIN 10000

#define random_distrib(v) ((v)[random()%vlen(v)])

#define badvalue(x) (((x)!=(x))||((x)>1e10)||((x)<-1e10))


/* Variation functions */
static void var0_linear(void *, double);
static void var1_sinusoidal(void *, double);
static void var2_spherical(void *, double);
static void var3_swirl(void *, double);
static void var4_horseshoe(void *, double);
static void var5_polar(void *, double);
static void var6_handkerchief(void *, double);
static void var7_heart(void *, double);
static void var8_disc(void *, double);
static void var9_spiral(void *, double);
static void var10_hyperbolic(void *, double);
static void var11_diamond(void *, double);
static void var12_ex(void *, double);
static void var13_julia(void *, double);
static void var14_bent(void *, double);
static void var15_waves(void *, double);
static void var16_fisheye(void *, double);
static void var17_popcorn(void *, double);
static void var18_exponential(void *, double);
static void var19_power(void *, double);
static void var20_cosine(void *, double);
static void var21_rings(void *, double);
static void var22_fan(void *, double);
static void var23_blob(void *, double);
static void var24_pdj(void *, double);
static void var25_fan2(void *, double);
static void var26_rings2(void *, double);
static void var27_eyefish(void *, double);
static void var28_bubble(void *, double);
static void var29_cylinder(void *, double);
static void var30_perspective(void *, double);

void prepare_xform_fn_ptrs(flam3_genome *);

static void initialize_xforms(flam3_genome *thiscp, int start_here);

/*
 * VARIATION FUNCTIONS
 * must be of the form void (void *, double) 
 */
static void var0_linear (void *helper, double weight) {
   /* linear */
   /* nx = tx;
      ny = ty;
      p[0] += v * nx;
      p[1] += v * ny; */   
         
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   
   f->p0 += weight * f->tx;
   f->p1 += weight * f->ty;
}

static void var1_sinusoidal (void *helper, double weight) {
   /* sinusoidal */
   /* nx = sin(tx);
      ny = sin(ty);
      p[0] += v * nx;
      p[1] += v * ny; */
   
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   
   f->p0 += weight * sin(f->tx);
   f->p1 += weight * sin(f->ty);
}

static void var2_spherical (void *helper, double weight) {
   /* spherical */
   /* double r2 = tx * tx + ty * ty + 1e-6;
      nx = tx / r2;
      ny = ty / r2;
      p[0] += v * nx;
      p[1] += v * ny; */
   
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r2 = weight / ( (f->tx * f->tx) + (f->ty * f->ty) + 1e-6);

   f->p0 += r2 * f->tx;
   f->p1 += r2 * f->ty;
}
   
static void var3_swirl (void *helper, double weight) {
   /* swirl */
   /* double r2 = tx * tx + ty * ty;    /k here is fun
      double c1 = sin(r2);
      double c2 = cos(r2);
      nx = c1 * tx - c2 * ty;
      ny = c2 * tx + c1 * ty;
      p[0] += v * nx;
      p[1] += v * ny; */
   
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r2 = f->tx*f->tx + f->ty*f->ty;
   double c1 = sin(r2);
   double c2 = cos(r2);
   double nx = c1 * f->tx - c2 * f->ty;
   double ny = c2 * f->tx + c1 * f->ty;

   f->p0 += weight * nx;
   f->p1 += weight * ny;
}

static void var4_horseshoe (void *helper, double weight) {
   /* horseshoe */
   /* a = atan2(tx, ty);
      c1 = sin(a);
      c2 = cos(a);
      nx = c1 * tx - c2 * ty;
      ny = c2 * tx + c1 * ty;
      p[0] += v * nx;
      p[1] += v * ny;  */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
/*   double c1 = f->precalc_sina;
   double c2 = f->precalc_cosa;
   
   double nx = c1 * f->tx - c2 * f->ty;
   double ny = c2 * f->tx + c1 * f->ty;
   
   f->p0 += weight * nx;
   f->p1 += weight * ny;*/
   
   double r = weight / (f->precalc_sqrt + EPS);
   
   f->p0 += (f->tx - f->ty) * (f->tx + f->ty) * r;
   f->p1 += 2.0 * f->tx * f->ty * r;
}
   
static void var5_polar (void *helper, double weight) {
   /* polar */
   /* nx = atan2(tx, ty) / M_PI;
      ny = sqrt(tx * tx + ty * ty) - 1.0;
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double nx = f->precalc_atan * M_1_PI;
   double ny = f->precalc_sqrt - 1.0;
   
   f->p0 += weight * nx;
   f->p1 += weight * ny;
}

static void var6_handkerchief (void *helper, double weight) {
   /* folded handkerchief */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty);
      p[0] += v * sin(a+r) * r;
      p[1] += v * cos(a-r) * r; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double a = f->precalc_atan;
   double r = f->precalc_sqrt;
   
   f->p0 += weight * r * sin(a+r);
   f->p1 += weight * r * cos(a-r);
}

static void var7_heart (void *helper, double weight) {
   /* heart */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty);
      a *= r;
      p[0] += v * sin(a) * r;
      p[1] += v * cos(a) * -r; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;   
   double a = f->precalc_sqrt * f->precalc_atan;
   double r = weight * f->precalc_sqrt;
   
   f->p0 += r * sin(a);
   f->p1 += (-r) * cos(a);
}

static void var8_disc (void *helper, double weight) {
   /* disc */
   /* nx = tx * M_PI;
      ny = ty * M_PI;
      a = atan2(nx, ny);
      r = sqrt(nx*nx + ny*ny);
      p[0] += v * sin(r) * a / M_PI;
      p[1] += v * cos(r) * a / M_PI; */

   flam3_iter_helper *f = (flam3_iter_helper *)helper;   
   double nx = f->tx * M_PI;
   double ny = f->ty * M_PI;
   double a = atan2(nx,ny) * M_1_PI;
   double r = M_PI * f->precalc_sqrt;
   
   f->p0 += weight * sin(r) * a;
   f->p1 += weight * cos(r) * a;
}

static void var9_spiral (void *helper, double weight) {
   /* spiral */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty) + 1e-6;
      p[0] += v * (cos(a) + sin(r)) / r;
      p[1] += v * (sin(a) - cos(r)) / r; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;   
   double r = f->precalc_sqrt + 1e-6;
   double r1 = weight/r;

   f->p0 += r1 * (f->precalc_cosa + sin(r));
   f->p1 += r1 * (f->precalc_sina - cos(r));
}

static void var10_hyperbolic (void *helper, double weight) {
   /* hyperbolic */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty) + 1e-6;
      p[0] += v * sin(a) / r;
      p[1] += v * cos(a) * r; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;   
   double r = f->precalc_sqrt + 1e-6;

   f->p0 += weight * f->precalc_sina / r;
   f->p1 += weight * f->precalc_cosa * r;
}

static void var11_diamond (void *helper, double weight) {
   /* diamond */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty);
      p[0] += v * sin(a) * cos(r);
      p[1] += v * cos(a) * sin(r); */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r = f->precalc_sqrt;   

   f->p0 += weight * f->precalc_sina * cos(r);
   f->p1 += weight * f->precalc_cosa * sin(r);
}

static void var12_ex (void *helper, double weight) {
   /* ex */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty);
      n0 = sin(a+r);
      n1 = cos(a-r);
      m0 = n0 * n0 * n0 * r;
      m1 = n1 * n1 * n1 * r;
      p[0] += v * (m0 + m1);
      p[1] += v * (m0 - m1); */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double a = f->precalc_atan;
   double r = f->precalc_sqrt;

   double n0 = sin(a+r);
   double n1 = cos(a-r);
   
   double m0 = n0 * n0 * n0 * r;
   double m1 = n1 * n1 * n1 * r;

   f->p0 += weight * (m0 + m1);
   f->p1 += weight * (m0 - m1);
}

static void var13_julia (void *helper, double weight) {
   /* julia */
   /* a = atan2(tx, ty)/2.0;
      if (flam3_random_bit()) a += M_PI;
      r = pow(tx*tx + ty*ty, 0.25);
      nx = r * cos(a);
      ny = r * sin(a);
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r;
   double a = 0.5 * f->precalc_atan;
   
   if (flam3_random_bit())
      a += M_PI;
   
   r = weight * pow(f->tx * f->tx + f->ty * f->ty, 0.25);

   f->p0 += r * cos(a);
   f->p1 += r * sin(a);
}

static void var14_bent (void *helper, double weight) {
   /* bent */
   /* nx = tx;
      ny = ty;
      if (nx < 0.0) nx = nx * 2.0;
      if (ny < 0.0) ny = ny / 2.0;
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double nx = f->tx;
   double ny = f->ty;
   
   if (nx < 0.0)
      nx = nx * 2.0;
   if (ny < 0.0)
      ny = ny / 2.0;
   
   f->p0 += weight * nx;
   f->p1 += weight * ny;
}

static void var15_waves (void *helper, double weight) {
   /* waves */
   /* dx = coef[2][0];
      dy = coef[2][1];
      nx = tx + coef[1][0]*sin(ty/((dx*dx)+EPS));
      ny = ty + coef[1][1]*sin(tx/((dy*dy)+EPS));
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double c10 = f->xform->c[1][0];
   double c11 = f->xform->c[1][1];
   double dx = f->xform->c[2][0];
   double dy = f->xform->c[2][1];
   
   double nx = f->tx + c10 * sin( f->ty / ( (dx * dx) + EPS ) );
   double ny = f->ty + c11 * sin( f->tx / ( (dy * dy) + EPS ) );
   
   f->p0 += weight * nx;
   f->p1 += weight * ny;
}

static void var16_fisheye (void *helper, double weight) {
   /* fisheye */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty);
      r = 2 * r / (r + 1);
      nx = r * cos(a);
      ny = r * sin(a);
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r = f->precalc_sqrt;
   
   r = 2*r / (r+1);

   f->p0 += weight * r * f->precalc_cosa;
   f->p1 += weight * r * f->precalc_sina;
}

static void var17_popcorn (void *helper, double weight) {
   /* popcorn */
   /* dx = tan(3*ty);
      dy = tan(3*tx);
      nx = tx + coef[2][0] * sin(dx);
      ny = ty + coef[2][1] * sin(dy);
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double dx = tan(3*f->ty);
   double dy = tan(3*f->tx);
   
   double nx = f->tx + f->xform->c[2][0] * sin(dx);
   double ny = f->ty + f->xform->c[2][1] * sin(dy);
   
   f->p0 += weight * nx;
   f->p1 += weight * ny;
}

static void var18_exponential (void *helper, double weight) {
   /* exponential */
   /* dx = exp(tx-1.0);
      dy = M_PI * ty;
      nx = cos(dy) * dx;
      ny = sin(dy) * dx;
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double dx = weight * exp(f->tx - 1.0);
   double dy = M_PI * f->ty;
   
   f->p0 += dx * cos(dy);
   f->p1 += dx * sin(dy);
}

static void var19_power (void *helper, double weight) {
   /* power */
   /* a = atan2(tx, ty);
      sa = sin(a);
      r = sqrt(tx*tx + ty*ty);
      r = pow(r, sa);
      nx = r * precalc_cosa;
      ny = r * sa;
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r = weight * pow(f->precalc_sqrt, f->precalc_sina);
   
   f->p0 += r * f->precalc_cosa;
   f->p1 += r * f->precalc_sina;
}

static void var20_cosine (void *helper, double weight) {
   /* cosine */
   /* nx = cos(tx * M_PI) * cosh(ty);
      ny = -sin(tx * M_PI) * sinh(ty);
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double nx =  cos(f->tx * M_PI) * cosh(f->ty);
   double ny = -sin(f->tx * M_PI) * sinh(f->ty);
   
   f->p0 += weight * nx;
   f->p1 += weight * ny;
}

static void var21_rings (void *helper, double weight) {
   /* rings */
   /* dx = coef[2][0];
	   dx = dx * dx + EPS;
	   r = sqrt(tx*tx + ty*ty);
	   r = fmod(r + dx, 2*dx) - dx + r*(1-dx);
	   a = atan2(tx, ty);
	   nx = cos(a) * r;
	   ny = sin(a) * r;
	   p[0] += v * nx;
	   p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double dx = f->xform->c[2][0] * f->xform->c[2][0] + EPS;
   double r = f->precalc_sqrt;
   r = weight * (fmod(r+dx, 2*dx) - dx + r * (1 - dx));
   
   f->p0 += r * f->precalc_cosa;
   f->p1 += r * f->precalc_sina;
}

static void var22_fan (void *helper, double weight) {
   /* fan */
   /* dx = coef[2][0];
      dy = coef[2][1];
      dx = M_PI * (dx * dx + EPS);
      dx2 = dx/2;
      a = atan(tx,ty);
      r = sqrt(tx*tx + ty*ty);
      a += (fmod(a+dy, dx) > dx2) ? -dx2 : dx2;
      nx = cos(a) * r;
      ny = sin(a) * r;
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double dx = M_PI * (f->xform->c[2][0] * f->xform->c[2][0] + EPS);
   double dy = f->xform->c[2][1];   
   double dx2 = 0.5 * dx;
   
   double a = f->precalc_atan;
   double r = weight * f->precalc_sqrt;
   
   a += (fmod(a+dy,dx) > dx2) ? -dx2 : dx2;
   
   f->p0 += r * cos(a);
   f->p1 += r * sin(a);
}

static void var23_blob (void *helper, double weight) {
   /* blob */
   /* a = atan2(tx, ty);
      r = sqrt(tx*tx + ty*ty);
      r = r * (bloblow + (blobhigh-bloblow) * (0.5 + 0.5 * sin(blobwaves * a)));
      nx = sin(a) * r;
      ny = cos(a) * r;
      
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r = f->precalc_sqrt;
   double a = f->precalc_atan;
   double bdiff = f->xform->blob_high - f->xform->blob_low;
   
   r = r * (f->xform->blob_low + 
            bdiff * (0.5 + 0.5 * sin(f->xform->blob_waves * a)));
   
   f->p0 += weight * f->precalc_sina * r;
   f->p1 += weight * f->precalc_cosa * r;
}

static void var24_pdj (void *helper, double weight) {
   /* pdj */
   /* nx1 = cos(pdjb * tx);
      nx2 = sin(pdjc * tx);
      ny1 = sin(pdja * ty);
      ny2 = cos(pdjd * ty);
         
      p[0] += v * (ny1 - nx1);
      p[1] += v * (nx2 - ny2); */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double nx1 = cos(f->xform->pdj_b * f->tx);
   double nx2 = sin(f->xform->pdj_c * f->tx);
   double ny1 = sin(f->xform->pdj_a * f->ty);
   double ny2 = cos(f->xform->pdj_d * f->ty);
   
   f->p0 += weight * (ny1 - nx1);
   f->p1 += weight * (nx2 - ny2);
}

static void var25_fan2 (void *helper, double weight) {
   /* fan2 */
   /* a = precalc_atan;
      r = precalc_sqrt;
         
      dy = fan2y;
      dx = M_PI * (fan2x * fan2x + EPS);
      dx2 = dx / 2.0;
         
      t = a + dy - dx * (int)((a + dy)/dx);
        
      if (t > dx2)
         a = a - dx2;
      else
         a = a + dx2;
         
      nx = sin(a) * r;
      ny = cos(a) * r;
         
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   
   double dy = f->xform->fan2_y;
   double dx = M_PI * (f->xform->fan2_x * f->xform->fan2_x + EPS);
   double dx2 = 0.5 * dx;
   double a = f->precalc_atan;
   double r = weight * f->precalc_sqrt;
   
   double t = a + dy - dx * (int)((a + dy)/dx);
   
   if (t>dx2)
      a = a-dx2;
   else
      a = a+dx2;
   
   f->p0 += r * sin(a);
   f->p1 += r * cos(a);
}

static void var26_rings2 (void *helper, double weight) {
   /* rings2 */
   /* r = precalc_sqrt;
      dx = rings2val * rings2val + EPS;
      r += dx - 2.0*dx*(int)((r + dx)/(2.0 * dx)) - dx + r * (1.0-dx);
      nx = precalc_sina * r;
      ny = precalc_cosa * r;
      p[0] += v * nx;
      p[1] += v * ny; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r = f->precalc_sqrt;
   double dx = f->xform->rings2_val * f->xform->rings2_val + EPS;
   
   r += -2.0*dx*(int)((r+dx)/(2.0*dx)) + r * (1.0-dx);
   
   f->p0 += weight * f->precalc_sina * r;
   f->p1 += weight * f->precalc_cosa * r;
}

static void var27_eyefish (void *helper, double weight) {
   /* eyefish */         
   /* r = 2.0 * v / (precalc_sqrt + 1.0);
      p[0] += r*tx;
      p[1] += r*ty; */
      
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r = (weight * 2.0) / (f->precalc_sqrt + 1.0);

   f->p0 += r * f->tx;
   f->p1 += r * f->ty;
}

static void var28_bubble (void *helper, double weight) {
   /* bubble */
   
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double r = weight / (0.25 * (f->tx*f->tx + f->ty*f->ty) + 1);

  f->p0 += r * f->tx;
  f->p1 += r * f->ty;
}

static void var29_cylinder (void *helper, double weight) {
   /* cylinder (01/06) */
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   
   f->p0 += weight * sin(f->tx);
   f->p1 += weight * f->ty;
}

static void var30_perspective (void *helper, double weight) {
   /* perspective (01/06) */
   flam3_iter_helper *f = (flam3_iter_helper *)helper;
   double t = 1.0 / (f->xform->perspective_dist - f->ty * f->xform->persp_vsin);
   
   f->p0 += weight * f->xform->perspective_dist * f->tx * t;
   f->p1 += weight * f->xform->persp_vfcos * f->ty * t;
}

void prepare_xform_fn_ptrs(flam3_genome *cp) {
   
   double d;
   int i,j,totnum;
   
   /* Loop over valid xforms */
   for (i = 0; i < cp->num_xforms; i++) {
      d = cp->xform[i].density;
      if (d < 0.0) {
         fprintf(stderr, "xform weight must be non-negative, not %g.\n", d);
         exit(1);
      }
      
      if (d == 0.0)
         continue;

      totnum = 0;
      cp->xform[i].precalc_angles_flag=0;
      cp->xform[i].precalc_sqrt_flag=0;
      
      for (j = 0; j < flam3_nvariations; j++) {
         
         if (cp->xform[i].var[j]!=0) {
            
            cp->xform[i].active_var_weights[totnum] = cp->xform[i].var[j];
            
            if (j==0)
               cp->xform[i].varFunc[totnum] = &var0_linear;
            else if (j==1)
               cp->xform[i].varFunc[totnum] = &var1_sinusoidal;
            else if (j==2)
               cp->xform[i].varFunc[totnum] = &var2_spherical;
            else if (j==3)
               cp->xform[i].varFunc[totnum] = &var3_swirl;
            else if (j==4) {
               cp->xform[i].varFunc[totnum] = &var4_horseshoe;
/*               cp->xform[i].precalc_angles_flag=1;*/
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==5) {
               cp->xform[i].varFunc[totnum] = &var5_polar;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==6) {
               cp->xform[i].varFunc[totnum] = &var6_handkerchief;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==7) {
               cp->xform[i].varFunc[totnum] = &var7_heart;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==8) {
               cp->xform[i].varFunc[totnum] = &var8_disc;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==9) {
               cp->xform[i].varFunc[totnum] = &var9_spiral;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==10) {
               cp->xform[i].varFunc[totnum] = &var10_hyperbolic;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==11) {
               cp->xform[i].varFunc[totnum] = &var11_diamond;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==12) {
               cp->xform[i].varFunc[totnum] = &var12_ex;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==13) {
               cp->xform[i].varFunc[totnum] = &var13_julia;
               cp->xform[i].precalc_angles_flag=1;
            } else if (j==14)
               cp->xform[i].varFunc[totnum] = &var14_bent;
            else if (j==15)
               cp->xform[i].varFunc[totnum] = &var15_waves;
            else if (j==16) {
               cp->xform[i].varFunc[totnum] = &var16_fisheye;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==17)
               cp->xform[i].varFunc[totnum] = &var17_popcorn;
            else if (j==18)
               cp->xform[i].varFunc[totnum] = &var18_exponential;
            else if (j==19) {
               cp->xform[i].varFunc[totnum] = &var19_power;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==20)
               cp->xform[i].varFunc[totnum] = &var20_cosine;
            else if (j==21) {
               cp->xform[i].varFunc[totnum] = &var21_rings;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==22) {
               cp->xform[i].varFunc[totnum] = &var22_fan;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==23) {
               cp->xform[i].varFunc[totnum] = &var23_blob;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==24)
               cp->xform[i].varFunc[totnum] = &var24_pdj;
            else if (j==25) {
               cp->xform[i].varFunc[totnum] = &var25_fan2;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==26) {
               cp->xform[i].varFunc[totnum] = &var26_rings2;
               cp->xform[i].precalc_angles_flag=1;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==27) {
               cp->xform[i].varFunc[totnum] = &var27_eyefish;
               cp->xform[i].precalc_sqrt_flag=1;
            } else if (j==28)
               cp->xform[i].varFunc[totnum] = &var28_bubble;
            else if (j==29)
               cp->xform[i].varFunc[totnum] = &var29_cylinder;
            else if (j==30)
               cp->xform[i].varFunc[totnum] = &var30_perspective;
               
               
            totnum++;
         }
      }
            
      cp->xform[i].num_active_vars = totnum;
   }
}

/*
 * run the function system described by CP forward N generations.  store
 * the N resulting 4-vectors in SAMPLES.  the initial point is passed in
 * SAMPLES[0..3].  ignore the first FUSE iterations.
 */
void flam3_iterate(flam3_genome *cp, int n, int fuse,  double *samples) {
   int i, j;
   char xform_distrib[CHOOSE_XFORM_GRAIN];
   double p[4], t, r, dr, s, s1;
   flam3_iter_helper f;
   
   p[0] = samples[0];
   p[1] = samples[1];
   p[2] = samples[2];
   p[3] = samples[3];
   
   /*
   * first, set up xform, which is an array that converts a uniform random
   * variable into one with the distribution dictated by the density
   * fields 
   */
   dr = 0.0;
   for (i = 0; i < cp->num_xforms; i++) {
      double d = cp->xform[i].density;
      if (d < 0.0) {
         fprintf(stderr, "xform weight must be non-negative, not %g.\n", d);
         exit(1);
      }
      dr += d;
   }
   if (dr == 0.0) {
      fprintf(stderr, "cannot iterate empty flame.\n");
      exit(1);
   }
   dr = dr / CHOOSE_XFORM_GRAIN;
   
   j = 0;
   t = cp->xform[0].density;
   r = 0.0;
   for (i = 0; i < CHOOSE_XFORM_GRAIN; i++) {
      while (r >= t) {
         j++;
         t += cp->xform[j].density;
      }
      xform_distrib[i] = j;
      r += dr;
   }

   for (i = -4*fuse; i < 4*n; i+=4) {
      int fn = xform_distrib[random() % CHOOSE_XFORM_GRAIN];
      double tx, ty;
      int var_n;
      
      /* first compute the color coord */
      s = cp->xform[fn].symmetry;
/*      s1 = 0.5*(1.0 - s);*/
      s1 = 0.5 - 0.5 * s;
      p[2] = (p[2] + cp->xform[fn].color[0]) * s1 + s * p[2];
      p[3] = (p[3] + cp->xform[fn].color[1]) * s1 + s * p[3];
      
      /* then apply the affine part of the function */
      f.tx = cp->xform[fn].c[0][0] * p[0] + cp->xform[fn].c[1][0] * p[1] + cp->xform[fn].c[2][0];
      f.ty = cp->xform[fn].c[0][1] * p[0] + cp->xform[fn].c[1][1] * p[1] + cp->xform[fn].c[2][1];
      
      /* Check to see if we can precalculate any parts */
      /* Precalculate atan, sin, cos */
      if (cp->xform[fn].precalc_angles_flag > 0) {
         f.precalc_atan = atan2(f.tx,f.ty);
         f.precalc_sina = sin(f.precalc_atan);
         f.precalc_cosa = cos(f.precalc_atan);
      }
      
      /* Check for sqrt */
      if (cp->xform[fn].precalc_sqrt_flag > 0) {
         f.precalc_sqrt = sqrt(f.tx*f.tx + f.ty*f.ty);
      }
            
      f.p0 = 0.0;
      f.p1 = 0.0;      
      f.xform = &(cp->xform[fn]);

      for (var_n=0; var_n < cp->xform[fn].num_active_vars; var_n++) {
         (*cp->xform[fn].varFunc[var_n])(&f, cp->xform[fn].active_var_weights[var_n]);
      }
      
      /* apply the post transform */
      if (cp->xform[fn].post_flag > 0) {
         tx = cp->xform[fn].post[0][0] * f.p0 + cp->xform[fn].post[1][0] * f.p1 + cp->xform[fn].post[2][0];
         ty = cp->xform[fn].post[0][1] * f.p0 + cp->xform[fn].post[1][1] * f.p1 + cp->xform[fn].post[2][1];
      } else {
         tx = f.p0;
         ty = f.p1;
      }
      
      if (badvalue(tx) || badvalue(ty)) {
         tx = flam3_random11();
         ty = flam3_random11();
      }

      p[0] = tx;
      p[1] = ty;
      
      /* if fuse over, store it */
      if (i >= 0) {
         samples[i] = p[0];
         samples[i+1] = p[1];
         samples[i+2] = p[2];
         samples[i+3] = p[3];
      }
   }
}


/* correlation dimension, after clint sprott.
   computes slope of the correlation sum at a size scale
   the order of 2% the size of the attractor or the camera. */
double flam3_dimension(flam3_genome *cp, int ntries, int clip_to_camera) {
  double fd;
  double *hist;
  double bmin[2];
  double bmax[2];
  double d2max;
  int i, n1=0, n2=0, got, nclipped;

  if (ntries < 2) ntries = 3000*1000;

  if (clip_to_camera) {
    double scale, ppux, corner0, corner1;
    scale = pow(2.0, cp->zoom);
    ppux = cp->pixels_per_unit * scale;
    corner0 = cp->center[0] - cp->width / ppux / 2.0;
    corner1 = cp->center[1] - cp->height / ppux / 2.0;
    bmin[0] = corner0;
    bmin[1] = corner1;
    bmax[0] = corner0 + cp->width  / ppux;
    bmax[1] = corner1 + cp->height / ppux;
  } else {
    flam3_estimate_bounding_box(cp, 0.0, 0, bmin, bmax);
  }

  d2max =
    (bmax[0] - bmin[0]) * (bmax[0] - bmin[0]) +
    (bmax[1] - bmin[1]) * (bmax[1] - bmin[1]);

  //  fprintf(stderr, "d2max=%g %g %g %g %g\n", d2max,
  //  bmin[0], bmin[1], bmax[0], bmax[1]);

  hist = malloc(2 * ntries * sizeof(double));

  got = 0;
  nclipped = 0;
  while (got < 2*ntries) {
    double subb[4*SUB_BATCH_SIZE];
    int i4, clipped;
    subb[0] = flam3_random11();
    subb[1] = flam3_random11();
    subb[2] = 0.0;
    subb[3] = 0.0;
    prepare_xform_fn_ptrs(cp);
    flam3_iterate(cp, SUB_BATCH_SIZE, 20, subb);
    i4 = 0;
    for (i = 0; i < SUB_BATCH_SIZE; i++) {
      if (got == 2*ntries) break;
      clipped = clip_to_camera &&
	((subb[i4] < bmin[0]) ||
	 (subb[i4+1] < bmin[1]) ||
	 (subb[i4] > bmax[0]) ||
	 (subb[i4+1] > bmax[1]));
      if (!clipped) {
	hist[got] = subb[i4];
	hist[got+1] = subb[i4+1];
	got += 2;
      } else {
	nclipped++;
	if (nclipped > 10 * ntries) {
	    fprintf(stderr, "warning: too much clipping, "
		    "flam3_dimension giving up.\n");
	    return sqrt(-1.0);
	}
      }
      i4 += 4;
    }
  }
  if (0)
    fprintf(stderr, "cliprate=%g\n", nclipped/(ntries+(double)nclipped));

  for (i = 0; i < ntries; i++) {
    int ri;
    double dx, dy, d2;
    double tx, ty;
    
    tx = hist[2*i];
    ty = hist[2*i+1];
    
    do {
      ri = 2 * (random() % ntries);
    } while (ri == i);

    dx = hist[ri] - tx;
    dy = hist[ri+1] - ty;
    d2 = dx*dx + dy*dy;
    if (d2 < 0.004 * d2max) n2++;
    if (d2 < 0.00004 * d2max) n1++;
  }

  fd = 0.434294 * log(n2 / (n1 - 0.5));

  if (0)
    fprintf(stderr, "n1=%d n2=%d\n", n1, n2);

  free(hist);
  return fd;
}

double flam3_lyapunov(flam3_genome *cp, int ntries) {
  double p[4];
  double x, y;
  double xn, yn;
  double xn2, yn2;
  double dx, dy, r;
  double eps = 1e-5;
  int i;
  double sum = 0.0;

  if (ntries < 1) ntries = 10000;

  for (i = 0; i < ntries; i++) {
    x = flam3_random11();
    y = flam3_random11();

    p[0] = x;
    p[1] = y;
    p[2] = 0.0;
    p[3] = 0.0;

    // get into the attractor
    prepare_xform_fn_ptrs(cp);
    flam3_iterate(cp, 1, 20+(random()%10), p);

    x = p[0];
    y = p[1];

    // take one deterministic step
    srandom(i);
    
    prepare_xform_fn_ptrs(cp);
    flam3_iterate(cp, 1, 0, p);

    xn = p[0];
    yn = p[1];

    do {
      dx = flam3_random11();
      dy = flam3_random11();
      r = sqrt(dx * dx + dy * dy);
    } while (r == 0.0);
    dx /= r;
    dy /= r;

    dx *= eps;
    dy *= eps;

    p[0] = x + dx;
    p[1] = y + dy;
    p[2] = 0.0;

    // take the same step but with eps
    srandom(i);
    prepare_xform_fn_ptrs(cp);
    flam3_iterate(cp, 1, 0, p);

    xn2 = p[0];
    yn2 = p[1];

    r = sqrt((xn-xn2)*(xn-xn2) + (yn-yn2)*(yn-yn2));

    sum += log(r/eps);
  }
  return sum/(log(2.0)*ntries);
}

/* args must be non-overlapping */
static void mult_matrix(double s1[2][2], double s2[2][2], double d[2][2]) {
   d[0][0] = s1[0][0] * s2[0][0] + s1[1][0] * s2[0][1];
   d[1][0] = s1[0][0] * s2[1][0] + s1[1][0] * s2[1][1];
   d[0][1] = s1[0][1] * s2[0][0] + s1[1][1] * s2[0][1];
   d[1][1] = s1[0][1] * s2[1][0] + s1[1][1] * s2[1][1];
}

/* BY is angle in degrees */
void flam3_rotate(flam3_genome *cp, double by) {
   int i;
   for (i = 0; i < cp->num_xforms; i++) {
      double r[2][2];
      double T[2][2];
      double U[2][2];
      double dtheta = by * 2.0 * M_PI / 360.0;

      /* hmm */
      if (cp->xform[i].symmetry > 0.0) continue;

      r[1][1] = r[0][0] = cos(dtheta);
      r[0][1] = sin(dtheta);
      r[1][0] = -r[0][1];
      T[0][0] = cp->xform[i].c[0][0];
      T[1][0] = cp->xform[i].c[1][0];
      T[0][1] = cp->xform[i].c[0][1];
      T[1][1] = cp->xform[i].c[1][1];
      mult_matrix(r, T, U);
      cp->xform[i].c[0][0] = U[0][0];
      cp->xform[i].c[1][0] = U[1][0];
      cp->xform[i].c[0][1] = U[0][1];
      cp->xform[i].c[1][1] = U[1][1];
   }
}

static double det_matrix(double s[2][2]) {
   return s[0][0] * s[1][1] - s[0][1] * s[1][0];
}

static int id_matrix(double s[3][2]) {
  return
    (s[0][0] == 1.0) &&
    (s[0][1] == 0.0) &&
    (s[1][0] == 0.0) &&
    (s[1][1] == 1.0) &&
    (s[2][0] == 0.0) &&
    (s[2][1] == 0.0);
}

/* element-wise linear */
static void interpolate_matrix(double t, double m1[3][2],
			       double m2[3][2], double m3[3][2]) {
   double s = 1.0 - t;

   m3[0][0] = s * m1[0][0] + t * m2[0][0];
   m3[0][1] = s * m1[0][1] + t * m2[0][1];

   m3[1][0] = s * m1[1][0] + t * m2[1][0];
   m3[1][1] = s * m1[1][1] + t * m2[1][1];

   m3[2][0] = s * m1[2][0] + t * m2[2][0];
   m3[2][1] = s * m1[2][1] + t * m2[2][1];

}

static void interpolate_cmap(double cmap[256][3], double blend,
			     int index0, double hue0, int index1, double hue1) {
  double p0[256][3];
  double p1[256][3];
  int i, j;

  flam3_get_palette(index0, p0, hue0);
  flam3_get_palette(index1, p1, hue1);
  
  for (i = 0; i < 256; i++) {
    double t[3], s[3];
    rgb2hsv(p0[i], s);
    rgb2hsv(p1[i], t);
    for (j = 0; j < 3; j++)
      t[j] = ((1.0-blend) * s[j]) + (blend * t[j]);
    hsv2rgb(t, cmap[i]);
  }
}

#define INTERP(x)  result->x = c0 * cps[i1].x + c1 * cps[i2].x
#define INTERI(x)  result->x = (int)floor(0.5 + c0 * cps[i1].x + c1 * cps[i2].x)
#define XFINTERP(x)  result->x = c0 * cpi1.x + c1 * cpi2.x
#define XFINTERI(x)  result->x = (int)floor(0.5 + c0 * cpi1.x + c1 * cpi2.x)

/*
 * create a control point that interpolates between the control points
 * passed in CPS.  for now just do linear.  in the future, add control
 * point types and other things to the cps.  CPS must be sorted by time.
 */
void flam3_interpolate(flam3_genome cps[], int ncps,
		       double time, flam3_genome *result) {
   int i, j, i1, i2;
   double c0, c1;
   double ang;
   flam3_genome cpi1, cpi2;
   
   memset(&cpi1,0,sizeof(flam3_genome));
   memset(&cpi2,0,sizeof(flam3_genome));   
   
   if (1 == ncps) {
      copy_cp(result, &(cps[0]));
      return;
   }
   if (cps[0].time >= time) {
      i1 = 0;
      i2 = 1;
   } else if (cps[ncps - 1].time <= time) {
      i1 = ncps - 2;
      i2 = ncps - 1;
   } else {
      i1 = 0;
      while (cps[i1].time < time)
         i1++;

      i1--;
      i2 = i1 + 1;

      if (time - cps[i1].time > -1e-7 && time - cps[i1].time < 1e-7) {
         copy_cp(result, &(cps[i1]));
         return;
      }
   }

   c0 = (cps[i2].time - time) / (cps[i2].time - cps[i1].time);
   c1 = 1.0 - c0;

   result->time = time;

   for (i = 0; i < 256; i++) {
     double t[3], s[3];
     rgb2hsv(cps[i1].palette[i], s);
     rgb2hsv(cps[i2].palette[i], t);
     for (j = 0; j < 3; j++)
       t[j] = c0 * s[j] + c1 * t[j];
     hsv2rgb(t, result->palette[i]);
     for (j = 0; j < 3; j++) {
	 if (result->palette[i][j] < 0.0) {
	     result->palette[i][j] = 0.0;
	 }
     }
   }

   result->palette_index = flam3_palette_random;
   result->symmetry = 0;
   INTERP(brightness);
   INTERP(contrast);
   INTERP(gamma);
   INTERP(vibrancy);
   INTERP(hue_rotation);
   INTERI(width);
   INTERI(height);
   INTERI(spatial_oversample);
   INTERP(center[0]);
   INTERP(center[1]);
   result->rot_center[0] = result->center[0];
   result->rot_center[1] = result->center[1];
   INTERP(background[0]);
   INTERP(background[1]);
   INTERP(background[2]);
   INTERP(pixels_per_unit);
   INTERP(spatial_filter_radius);
   INTERP(sample_density);
   INTERP(zoom);
   INTERP(rotate);
   INTERI(nbatches);
   INTERI(ntemporal_samples);

   /* Density Estimation interpolation */
   INTERP(estimator);
   INTERP(estimator_minimum);
   INTERP(estimator_curve);
   
   /* Small gamma linearization */
   INTERP(gam_lin_thresh);

   /* To interpolate the xforms, we will make copies of the source cps  */
   /* and ensure that they both have the same number before progressing */
   copy_cp(&cpi1,&(cps[i1]));
   copy_cp(&cpi2,&(cps[i2]));
   
   if (cpi1.num_xforms < cpi2.num_xforms)
      add_xforms_to_cp(&cpi1, cpi2.num_xforms - cpi1.num_xforms);
   else if (cpi2.num_xforms < cpi1.num_xforms)
      add_xforms_to_cp(&cpi2, cpi1.num_xforms - cpi2.num_xforms);
   
   /* Clear any existing xforms in result */
   if (result->num_xforms > 0 && result->xform != NULL) {
      free(result->xform);
      result->num_xforms = 0;
   }
   
   /* Add the correct number */
   add_xforms_to_cp(result, cpi1.num_xforms);
   
   /* Now interpolate between these two */
   for (i = 0; i < cpi1.num_xforms; i++) {
      XFINTERP(xform[i].density);
      XFINTERP(xform[i].color[0]);
      XFINTERP(xform[i].color[1]);
      XFINTERP(xform[i].symmetry);
      XFINTERP(xform[i].blob_low);
      XFINTERP(xform[i].blob_high);
      XFINTERI(xform[i].blob_waves);
      XFINTERP(xform[i].pdj_a);
      XFINTERP(xform[i].pdj_b);
      XFINTERP(xform[i].pdj_c);
      XFINTERP(xform[i].pdj_d);
      XFINTERP(xform[i].fan2_x);
      XFINTERP(xform[i].fan2_y);
      XFINTERP(xform[i].rings2_val);
      XFINTERP(xform[i].perspective_angle);
      XFINTERP(xform[i].perspective_dist);

      /* Precalculate two additional params for perspective */
      ang = result->xform[i].perspective_angle * M_PI / 2.0;
      result->xform[i].persp_vsin = sin(ang);
      result->xform[i].persp_vfcos = result->xform[i].perspective_dist * cos(ang);

      
      for (j = 0; j < flam3_nvariations; j++)
         XFINTERP(xform[i].var[j]);

      interpolate_matrix(c1, cpi1.xform[i].c, cpi2.xform[i].c, result->xform[i].c);
      interpolate_matrix(c1, cpi1.xform[i].post, cpi2.xform[i].post, result->xform[i].post);
   }
   
   /* Free up the two allocated xform arrays.     */
   /* Everything else will be freed automagically */
   free(cpi1.xform);
   free(cpi2.xform);
}

static int compare_xforms(const void *av, const void *bv) {
   flam3_xform *a = (flam3_xform *) av;
   flam3_xform *b = (flam3_xform *) bv;
   double aa[2][2];
   double bb[2][2];
   double ad, bd;
   
   aa[0][0] = a->c[0][0];
   aa[0][1] = a->c[0][1];
   aa[1][0] = a->c[1][0];
   aa[1][1] = a->c[1][1];
   bb[0][0] = b->c[0][0];
   bb[0][1] = b->c[0][1];
   bb[1][0] = b->c[1][0];
   bb[1][1] = b->c[1][1];
   ad = det_matrix(aa);
   bd = det_matrix(bb);
   
   if (a->symmetry < b->symmetry) return 1;
   if (a->symmetry > b->symmetry) return -1;
   if (a->symmetry) {
      if (ad < 0) return -1;
      if (bd < 0) return 1;
      ad = atan2(a->c[0][0], a->c[0][1]);
      bd = atan2(b->c[0][0], b->c[0][1]);
   }
   
   if (ad < bd) return -1;
   if (ad > bd) return 1;
   return 0;
}


static void initialize_xforms(flam3_genome *thiscp, int start_here) {
   
   int i,j;
   
   for (i = start_here ; i < thiscp->num_xforms ; i++) {
       thiscp->xform[i].density = 0.0;
       thiscp->xform[i].symmetry = 0;
       thiscp->xform[i].color[0] = i&1;
       thiscp->xform[i].color[1] = (i&2)>>1;
       thiscp->xform[i].var[0] = 1.0;
       for (j = 1; j < flam3_nvariations; j++)
          thiscp->xform[i].var[j] = 0.0;
       thiscp->xform[i].c[0][0] = 1.0;
       thiscp->xform[i].c[0][1] = 0.0;
       thiscp->xform[i].c[1][0] = 0.0;
       thiscp->xform[i].c[1][1] = 1.0;
       thiscp->xform[i].c[2][0] = 0.0;
       thiscp->xform[i].c[2][1] = 0.0;
       thiscp->xform[i].post[0][0] = 1.0;
       thiscp->xform[i].post[0][1] = 0.0;
       thiscp->xform[i].post[1][0] = 0.0;
       thiscp->xform[i].post[1][1] = 1.0;
       thiscp->xform[i].post[2][0] = 0.0;
       thiscp->xform[i].post[2][1] = 0.0;
       thiscp->xform[i].blob_low = 0.0;
       thiscp->xform[i].blob_high = 0.0;
       thiscp->xform[i].blob_waves = 0;
       thiscp->xform[i].pdj_a = 0.0;
       thiscp->xform[i].pdj_b = 0.0;
       thiscp->xform[i].pdj_c = 0.0;
       thiscp->xform[i].pdj_d = 0.0;
       thiscp->xform[i].fan2_x = 0.0;
       thiscp->xform[i].fan2_y = 0.0;
       thiscp->xform[i].rings2_val = 0.0;
       thiscp->xform[i].perspective_angle = 0.0;
       thiscp->xform[i].perspective_dist = 0.0;
       thiscp->xform[i].persp_vsin = 0.0;
       thiscp->xform[i].persp_vfcos = 0.0;
   }
}

/* Xform support functions */
void add_xforms_to_cp(flam3_genome *thiscp, int num_to_add) {
   
   int old_num = thiscp->num_xforms;
   
   if (thiscp->num_xforms > 0)
      thiscp->xform = (flam3_xform *)realloc(thiscp->xform, (thiscp->num_xforms + num_to_add) * sizeof(flam3_xform));
   else
      thiscp->xform = (flam3_xform *)malloc(num_to_add * sizeof(flam3_xform));
   
   thiscp->num_xforms += num_to_add;

   /* Initialize all the new xforms */
   initialize_xforms(thiscp, old_num);
   
}

/* Copy one control point to another */
void copy_cp(flam3_genome *dest, flam3_genome *src) {
   
   /* If there are any xforms in dest before the copy, clean them up */
   if (dest->num_xforms > 0 && dest->xform!=NULL) {
      free(dest->xform);
      dest->num_xforms = 0;
   }
   
   /* Copy main contents of genome */
   memcpy(dest, src, sizeof(flam3_genome));
   
   /* Only the pointer to the xform was copied, not the actual xforms. */
   /* We need to create new xform memory storage for this new cp       */   
   dest->num_xforms = 0;
   dest->xform = NULL;
   
   add_xforms_to_cp(dest, src->num_xforms);
   memcpy(dest->xform, src->xform, dest->num_xforms * sizeof(flam3_xform));
}

static flam3_genome xml_current_cp;
static flam3_genome *xml_all_cp;
static int xml_all_ncps;

static void clear_current_cp(int default_flag) {
    int i, j;
    flam3_genome *cp = &xml_current_cp;
    
    cp->palette_index = flam3_palette_random;
    cp->center[0] = 0.0;
    cp->center[1] = 0.0;
    cp->rot_center[0] = 0.0;
    cp->rot_center[1] = 0.0;
    cp->gamma = 4.0;
    cp->vibrancy = 1.0;
    cp->contrast = 1.0;
    cp->brightness = 4.0;
    cp->nbatches = 1;
    cp->ntemporal_samples = 1;
    cp->symmetry = 0;
    cp->hue_rotation = 0.0;
    cp->rotate = 0.0;
    cp->edits = NULL;
    cp->pixels_per_unit = 50;
    
    cp->genome_index = 0;
    memset(cp->parent_fname,0,parent_fn_len);
    
    if (default_flag==flam3_defaults_on) {
       /* If defaults are on, set to reasonable values */
       cp->background[0] = 0.0;
       cp->background[1] = 0.0;
       cp->background[2] = 0.0;
       cp->width = 100;
       cp->height = 100;
       cp->spatial_oversample = 1;
       cp->spatial_filter_radius = 0.5;
       cp->zoom = 0.0;
       cp->sample_density = 1;       
       /* Density estimation stuff defaulting to ON */
       cp->estimator = 5.0;
       cp->estimator_minimum = 0.0;
       cp->estimator_curve = 0.6;
       cp->gam_lin_thresh = 0.01;
       
    } else {       
       /* Defaults are off, so set to UN-reasonable values. */
       cp->background[0] = -1.0;
       cp->background[1] = -1.0;
       cp->background[2] = -1.0;
       cp->zoom = 999999999;
       cp->spatial_oversample = -1;
       cp->spatial_filter_radius = -1;
       cp->nbatches = -1;
       cp->ntemporal_samples = -1;
       cp->width = -1;
       cp->height = -1;
       cp->sample_density = -1;
       cp->estimator = -1;
       cp->estimator_minimum = -1;
       cp->estimator_curve = -1;
       cp->gam_lin_thresh = -1;
    }
       
    if (cp->xform != NULL && cp->num_xforms > 0) {
       free(cp->xform);
       cp->num_xforms = 0;
    }
}

char *flam3_variation_names[1+flam3_nvariations] = {
  "linear",
  "sinusoidal",
  "spherical",
  "swirl",
  "horseshoe",
  "polar",
  "handkerchief",
  "heart",
  "disc",
  "spiral",
  "hyperbolic",
  "diamond",
  "ex",
  "julia",
  "bent",
  "waves",
  "fisheye",
  "popcorn",
  "exponential",
  "power",
  "cosine",
  "rings",
  "fan",
  "blob",
  "pdj",
  "fan2",
  "rings2",
  "eyefish",
  "bubble",
  "cylinder",
  "perspective",
  0
};


static int var2n(const char *s) {
  int i;
  for (i = 0; i < flam3_nvariations; i++)
    if (!strcmp(s, flam3_variation_names[i])) return i;
  return flam3_variation_none;
}

static void parse_flame_element(xmlNode *flame_node) {
   flam3_genome *cp = &xml_current_cp;
   xmlNode *chld_node;
   xmlNodePtr edit_node;
   xmlAttrPtr att_ptr, cur_att;
   char *att_str;
   char *cpy;
   int i;
   
   /* Store this flame element in the current cp */
   
   /* The top level element is a flame element. */
   /* Read the attributes of it and store them. */
   att_ptr = flame_node->properties;
   
   if (att_ptr==NULL) {
      fprintf(stderr, "Error : <flame> element has no attributes!\n");
      exit(1);
   }
   
   memset(cp->flame_name,0,flame_name_len+1);
   
   for (cur_att = att_ptr; cur_att; cur_att = cur_att->next) {
      
       att_str = (char *) xmlGetProp(flame_node,cur_att->name);
      
      /* Compare attribute names */
      if (!xmlStrcmp(cur_att->name, (const xmlChar *)"time")) {
         cp->time = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"name")) {
         strncpy(cp->flame_name, att_str, flame_name_len);
         i = strlen(cp->flame_name)-1;
         while(i-->0) {
            if (isspace(cp->flame_name[i]))
               cp->flame_name[i] = '_';
         }
         
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"palette")) {
         cp->palette_index = atoi(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"size")) {
         sscanf(att_str, "%d %d", &cp->width, &cp->height);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"center")) {
         sscanf(att_str, "%lf %lf", &cp->center[0], &cp->center[1]);
         cp->rot_center[0] = cp->center[0];
         cp->rot_center[1] = cp->center[1];
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"scale")) {
         cp->pixels_per_unit = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"rotate")) {
         cp->rotate = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"zoom")) {
         cp->zoom = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"oversample")) {
         cp->spatial_oversample = atoi(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"filter")) {
         cp->spatial_filter_radius = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"quality")) {
         cp->sample_density = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"batches")) {
         cp->nbatches = atoi(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"temporal_samples")) {
         cp->ntemporal_samples = atoi(att_str);		
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"background")) {
         sscanf(att_str, "%lf %lf %lf", &cp->background[0], &cp->background[1], &cp->background[2]);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"brightness")) {
         cp->brightness = atof(att_str);
/*      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"contrast")) {
         cp->contrast = atof(att_str);*/
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"gamma")) {
         cp->gamma = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"vibrancy")) {
         cp->vibrancy = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"hue")) {
         cp->hue_rotation = fmod(atof(att_str), 1.0);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"estimator")) {
         cp->estimator = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"estimator_minimum")) {
         cp->estimator_minimum = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"estimator_curve")) {
         cp->estimator_curve = atof(att_str);
      } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"gamma_threshold")) {
         cp->gam_lin_thresh = atof(att_str);
      }
      
      xmlFree(att_str);
      
   }
   
   /* Finished with flame attributes.  Now look at children of flame element. */
   for (chld_node=flame_node->children; chld_node; chld_node = chld_node->next) {
      
      /* Is this a color node? */
      if (!xmlStrcmp(chld_node->name, (const xmlChar *)"color")) {
         int index = -1;
         double r=0.0,g=0.0,b=0.0;
         
         /* Loop through the attributes of the color element */
         att_ptr = chld_node->properties;
         
         if (att_ptr==NULL) {
            fprintf(stderr,"Error!  No attributes for color element!\n");
            exit(1);
         }
         
         for (cur_att=att_ptr; cur_att; cur_att = cur_att->next) {
            
            att_str = (char *) xmlGetProp(chld_node,cur_att->name);
            
            if (!xmlStrcmp(cur_att->name, (const xmlChar *)"index")) {
               index = atoi(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"rgb")) {
               sscanf(att_str, "%lf %lf %lf", &r, &g, &b);
            } else {
               fprintf(stderr,"Error!  Unknown color attribute '%s'\n",cur_att->name);
               exit(1);
            }
            
            xmlFree(att_str);
         }
         
         if (index >= 0 && index < 256) {
            cp->palette[index][0] = r / 255.0;
            cp->palette[index][1] = g / 255.0;
            cp->palette[index][2] = b / 255.0;
         } else {
            fprintf(stderr,"Error!  Color element with bad/missing index attribute (%d)\n",index);
            exit(1);
         }

      } else if (!xmlStrcmp(chld_node->name, (const xmlChar *)"palette")) {
         
         int index0, index1;
         double hue0, hue1;
         double blend = 0.5;
         index0 = index1 = flam3_palette_random;
         hue0 = hue1 = 0.0;
         
         /* Loop through the attributes of the palette element */
         att_ptr = chld_node->properties;
         
         if (att_ptr==NULL) {
            fprintf(stderr,"Error!  No attributes for palette element!\n");
            exit(1);
         }
         
         for (cur_att=att_ptr; cur_att; cur_att = cur_att->next) {

            att_str = (char *) xmlGetProp(chld_node,cur_att->name);
            
            if (!xmlStrcmp(cur_att->name, (const xmlChar *)"index0")) {
               index0 = atoi(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"index1")) {
               index1 = atoi(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"hue0")) {
               hue0 = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"hue1")) {
               hue1 = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"blend")) {
               blend = atof(att_str);
            } else {
               fprintf(stderr,"Error!  Unknown palette attribute '%s'\n",cur_att->name);
               exit(1);
            }
            
            xmlFree(att_str);
         }
         
         interpolate_cmap(cp->palette, blend, index0, hue0, index1, hue1);
         
      } else if (!xmlStrcmp(chld_node->name, (const xmlChar *)"symmetry")) {
         
         int kind=0;
         
         /* Loop through the attributes of the symmetry element */
         att_ptr = chld_node->properties;
         
         if (att_ptr==NULL) {
            fprintf(stderr,"Error!  No attributes for symmetry element!\n");
            exit(1);
         }
         
         for (cur_att=att_ptr; cur_att; cur_att = cur_att->next) {
            
            att_str = (char *) xmlGetProp(chld_node,cur_att->name);
            
            if (!xmlStrcmp(cur_att->name, (const xmlChar *)"kind")) {
               kind = atoi(att_str);
            } else {
               fprintf(stderr,"Error!  Unknown symmetry attribute '%s'\n",cur_att->name);
               exit(1);
            }
            
            xmlFree(att_str);
         }
         
         flam3_add_symmetry(cp,kind);
         
      } else if (!xmlStrcmp(chld_node->name, (const xmlChar *)"xform")) {

         int j,k,xf;
         int perspective_used = 0;
         
         xf = cp->num_xforms;
         add_xforms_to_cp(cp, 1);
         
         for (j = 0; j < flam3_nvariations; j++) {
            cp->xform[xf].var[j] = 0.0;
         }
         
         /* Loop through the attributes of the xform element */
         att_ptr = chld_node->properties;
         
         if (att_ptr==NULL) {
            fprintf(stderr,"Error!  No attributes for xform element!\n");
            exit(1);
         }
         
         for (cur_att=att_ptr; cur_att; cur_att = cur_att->next) {
            

            att_str = (char *) xmlGetProp(chld_node,cur_att->name);
            
            cpy = att_str;

            if (!xmlStrcmp(cur_att->name, (const xmlChar *)"weight")) {
               cp->xform[xf].density = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"symmetry")) {
               cp->xform[xf].symmetry = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"color")) {
               cp->xform[xf].color[1] = 0.0;
               sscanf(att_str, "%lf %lf", &cp->xform[xf].color[0], &cp->xform[xf].color[1]);
               sscanf(att_str, "%lf", &cp->xform[xf].color[0]);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"var1")) {
               for (j=0; j < flam3_nvariations; j++) {
                  cp->xform[xf].var[j] = 0.0;
               }               
               j = atoi(att_str);
               
               if (j < 0 || j >= flam3_nvariations) {
                  fprintf(stderr,"Error!  Bad variation (%d)\n",j);
                  j=0;
               }
               
               cp->xform[xf].var[j] = 1.0;
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"var")) {
               for (j=0; j < flam3_nvariations; j++) {
                  cp->xform[xf].var[j] = strtod(cpy, &cpy);
               }
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"coefs")) {
               for (k=0; k<3; k++) {
                  for (j=0; j<2; j++) {
                     cp->xform[xf].c[k][j] = strtod(cpy, &cpy);
                  }
               }
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"post")) {
               for (k = 0; k < 3; k++) {
                  for (j = 0; j < 2; j++) {
                     cp->xform[xf].post[k][j] = strtod(cpy, &cpy);
                  }
               }
               cp->xform[xf].post_flag = 1;
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"blob_low")) {
               cp->xform[xf].blob_low = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"blob_high")) {
               cp->xform[xf].blob_high = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"blob_waves")) {
               cp->xform[xf].blob_waves = atoi(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"pdj_a")) {
               cp->xform[xf].pdj_a = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"pdj_b")) {
               cp->xform[xf].pdj_b = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"pdj_c")) {
               cp->xform[xf].pdj_c = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"pdj_d")) {
               cp->xform[xf].pdj_d = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"fan2_x")) {
               cp->xform[xf].fan2_x = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"fan2_y")) {
               cp->xform[xf].fan2_y = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"rings2_val")) {
               cp->xform[xf].rings2_val = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"perspective_angle")) {
               cp->xform[xf].perspective_angle = atof(att_str);
            } else if (!xmlStrcmp(cur_att->name, (const xmlChar *)"perspective_dist")) {
               cp->xform[xf].perspective_dist = atof(att_str);
               perspective_used = 1;
               
            } else {
               int v = var2n((char *) cur_att->name);
               if (v != flam3_variation_none)
                  cp->xform[xf].var[v] = atof(att_str);
            }
            
            xmlFree(att_str);
         }
         
         /* Perspective uses some meta-parameters, so calculate the real params here */
         if (perspective_used>0) {
            double ang = cp->xform[xf].perspective_angle * M_PI / 2.0;
            cp->xform[xf].persp_vsin = sin(ang);
            cp->xform[xf].persp_vfcos = cp->xform[xf].perspective_dist * cos(ang);
         }
         
      } else if (!xmlStrcmp(chld_node->name, (const xmlChar *)"edit")) {
         
         /* Create a new XML document with this edit node as the root node */
         cp->edits = xmlNewDoc( (const xmlChar *)"1.0");
         edit_node = xmlCopyNode( chld_node, 1 );
         xmlDocSetRootElement(cp->edits, edit_node);
         
      } 
   } /* Done parsing flame element. */
}

static void scan_for_flame_nodes(xmlNode *cur_node, char *parent_file, int default_flag) {
   
   xmlNode *this_node = NULL;
   size_t f3_storage;

   /* Loop over this level of elements */
   for (this_node=cur_node; this_node; this_node = this_node->next) { 

      /* Check to see if this element is a <flame> element */
      if (this_node->type == XML_ELEMENT_NODE && !xmlStrcmp(this_node->name, (const xmlChar *)"flame")) {
         
         /* This is a flame element.  Parse it. */
         clear_current_cp(default_flag);
         
         parse_flame_element(this_node);
         
         /* Copy this cp into the array */
         f3_storage = (1+xml_all_ncps)*sizeof(flam3_genome);
         xml_all_cp = realloc(xml_all_cp, f3_storage);
         /* Clear out the realloc'd memory */
         memset(&(xml_all_cp[xml_all_ncps]),0,sizeof(flam3_genome));
         
         if (xml_current_cp.palette_index != flam3_palette_random) {
            flam3_get_palette(xml_current_cp.palette_index, xml_current_cp.palette, 
               xml_current_cp.hue_rotation);
         }
         
         xml_current_cp.genome_index = xml_all_ncps;
         memset(xml_current_cp.parent_fname, 0, parent_fn_len);
         strncpy(xml_current_cp.parent_fname,parent_file,parent_fn_len-1);
         
         copy_cp(&(xml_all_cp[xml_all_ncps]), &xml_current_cp);
         xml_all_ncps ++;

      } else {         
         /* Check all of the children of this element */
         scan_for_flame_nodes(this_node->children, parent_file, default_flag);
      }
   }
}

flam3_genome *flam3_parse_xml2(char *xmldata, char *xmlfilename, int default_flag, int *ncps) {
   
   xmlDocPtr doc; /* Parsed XML document tree */
   xmlNode *rootnode;
   char *bn;
   
   /* Parse XML string into internal document */
   /* Forbid network access during read       */
   doc = xmlReadMemory(xmldata, strlen(xmldata), xmlfilename, NULL, XML_PARSE_NONET);

   /* Check for errors */
   if (doc==NULL) {
      fprintf(stderr, "Failed to parse %s\n", xmlfilename);
      return NULL;
   }
   
   /* What is the root node of the document? */
   rootnode = xmlDocGetRootElement(doc);
   
   /* Scan for <flame> nodes, starting with this node */
   xml_all_cp = NULL;
   xml_all_ncps = 0;
   
   bn = basename(xmlfilename);   
   scan_for_flame_nodes(rootnode, bn, default_flag);
   
   xmlFreeDoc(doc);
   
   *ncps = xml_all_ncps;
   return xml_all_cp;
}

flam3_genome * flam3_parse_from_file(FILE *f, char *fname, int default_flag, int *ncps) {
   int i, c, slen = 5000;
   char *s;
   
   /* Incrementally read XML file into a string */
   s = malloc(slen);
   i = 0;
   do {
      c = getc(f);
      if (EOF == c) 
         break;
      s[i++] = c;
      if (i == slen-1) {
         slen *= 2;
         s = realloc(s, slen);
      }
   } while (1);
   
   /* Null-terminate the read XML data */
   s[i] = 0;
   
   /* Parse the XML string */
   if (fname) {
      return flam3_parse_xml2(s, fname, default_flag, ncps);
   } else
      return flam3_parse_xml2(s, "stdin", default_flag, ncps);
   
}

static void flam3_edit_print(FILE *f, xmlNodePtr editNode, int tabs, int formatting) {
   
   char *tab_string = "   ";
   int ti,strl;
   xmlAttrPtr att_ptr=NULL,cur_att=NULL;
   xmlNodePtr chld_ptr=NULL, cur_chld=NULL;
   int edit_or_sheep = 0, indent_printed = 0;
   
   char *att_str,*cont_str,*cpy_string;
      
   /* If this node is an XML_ELEMENT_NODE, print it and it's attributes */
   if (editNode->type==XML_ELEMENT_NODE) {
      
      /* Print the node at the tab specified */
      if (formatting) {
         for (ti=0;ti<tabs;ti++) 
            fprintf(f,"%s",tab_string);
      }
      
      fprintf(f,"<%s",editNode->name);
      
      /* This can either be an edit node or a sheep node */
      /* If it's an edit node, add one to the tab        */
      if (!xmlStrcmp(editNode->name, (const xmlChar *)"edit")) {
         edit_or_sheep = 1;
         tabs ++;
      } else if (!xmlStrcmp(editNode->name, (const xmlChar *)"sheep")) 
         edit_or_sheep = 2;
      else
         edit_or_sheep = 0;
      
      
      /* Print the attributes */
      att_ptr = editNode->properties;
   
      for (cur_att = att_ptr; cur_att; cur_att = cur_att->next) {

         att_str = (char *) xmlGetProp(editNode,cur_att->name);         
         fprintf(f," %s=\"%s\"",cur_att->name,att_str);
         xmlFree(att_str);
      }
      
      /* Does this node have children? */
      if (!editNode->children) {
         /* Close the tag and subtract the tab */
         fprintf(f,"/>");
         if (formatting)
            fprintf(f,"\n");         
         tabs--;
      } else {
         
         /* Close the tag */
         fprintf(f,">");
         
         if (formatting)
            fprintf(f,"\n");
         
         /* Loop through the children and print them */
         chld_ptr = editNode->children;
         
         indent_printed = 0;
         
         for (cur_chld=chld_ptr; cur_chld; cur_chld = cur_chld->next) {

            /* If child is an element, indent first and then print it. */
            if (cur_chld->type==XML_ELEMENT_NODE && 
               (!xmlStrcmp(cur_chld->name, (const xmlChar *)"edit") || (!xmlStrcmp(cur_chld->name, (const xmlChar *)"sheep")))) {

               if (indent_printed) {
                  indent_printed = 0;
                  fprintf(f,"\n");
               }
                  
               flam3_edit_print(f, cur_chld, tabs, 1);

            } else {
               
               /* Child is a text node.  We don't want to indent more than once. */
               if (xmlIsBlankNode(cur_chld))
                  continue;
               
               if (indent_printed==0 && formatting==1) {
                  for (ti=0;ti<tabs;ti++) 
                     fprintf(f,"%s",tab_string);
                  indent_printed = 1;
               }
               
               /* Print nodes without formatting. */
               flam3_edit_print(f, cur_chld, tabs, 0);
               
            }
         }
           
         if (indent_printed && formatting)
            fprintf(f,"\n");
         
         /* Tab out. */
         tabs --;
         if (formatting) {
            for (ti=0;ti<tabs;ti++) 
               fprintf(f,"%s",tab_string);
         }

         /* Close the tag */
         fprintf(f,"</%s>",editNode->name);
         
         if (formatting) {
            fprintf(f,"\n");
         }         
      }

   } else if (editNode->type==XML_TEXT_NODE) {

      /* Print text node */      
      cont_str = (char *) xmlNodeGetContent(editNode);
      cpy_string = &(cont_str[0]);
      while (isspace(*cpy_string))
         cpy_string++;
      
      strl = strlen(cont_str)-1;
      
      while (isspace(cont_str[strl]))
         strl--;
      
      cont_str[strl+1] = 0;
      
      fprintf(f,"%s",cpy_string);
      
   }
}

void flam3_apply_template(flam3_genome *cp, flam3_genome *templ) {
   
   /* Check for invalid values - only replace those with valid ones */        
   if (templ->background[0] >= 0)
      cp->background[0] = templ->background[0];
   if (templ->background[1] >= 0) 
      cp->background[1] = templ->background[1];
   if (templ->background[1] >= 0) 
      cp->background[2] = templ->background[2];
   if (templ->zoom < 999999998)
      cp->zoom = templ->zoom;
   if (templ->spatial_oversample > 0)
      cp->spatial_oversample = templ->spatial_oversample;
   if (templ->spatial_filter_radius >= 0)
      cp->spatial_filter_radius = templ->spatial_filter_radius;
   if (templ->sample_density > 0)
      cp->sample_density = templ->sample_density;
   if (templ->nbatches > 0)
      cp->nbatches = templ->nbatches;
   if (templ->ntemporal_samples > 0)
      cp->ntemporal_samples = templ->ntemporal_samples;
   if (templ->width > 0) {
      /* preserving scale should be an option */
      cp->pixels_per_unit = cp->pixels_per_unit * templ->width / cp->width;
      cp->width = templ->width;
   }
   if (templ->height > 0)
      cp->height = templ->height;
   if (templ->estimator >= 0)
      cp->estimator = templ->estimator;
   if (templ->estimator_minimum >= 0)
      cp->estimator_minimum = templ->estimator_minimum;
   if (templ->estimator_curve >= 0)
      cp->estimator_curve = templ->estimator_curve;
   if (templ->gam_lin_thresh >= 0)
      cp->gam_lin_thresh = templ->gam_lin_thresh;
}   
   

void flam3_print(FILE *f, flam3_genome *cp, char *extra_attributes) {
   int i, j;
   char *p = "";
   
   fprintf(f, "%s<flame time=\"%g\"", p, cp->time);

/*   if (0 <= cp->palette_index)
      fprintf(f, " palette=\"%d\"", cp->palette_index);*/

   fprintf(f, " size=\"%d %d\"", cp->width, cp->height);

   fprintf(f, " center=\"%g %g\"", cp->center[0], cp->center[1]);
   
   fprintf(f, " scale=\"%g\"", cp->pixels_per_unit);

   if (cp->zoom != 0.0)
      fprintf(f, " zoom=\"%g\"", cp->zoom);

   fprintf(f, " rotate=\"%g\"", cp->rotate);

   fprintf(f, " oversample=\"%d\"", cp->spatial_oversample);

   fprintf(f, " filter=\"%g\"", cp->spatial_filter_radius);
   fprintf(f, " quality=\"%g\"", cp->sample_density);

   fprintf(f, " batches=\"%d\"", cp->nbatches);

   fprintf(f, " temporal_samples=\"%d\"", cp->ntemporal_samples);
   fprintf(f, " background=\"%g %g %g\"", cp->background[0], cp->background[1], cp->background[2]);
   fprintf(f, " brightness=\"%g\"", cp->brightness);
/*   fprintf(f, " contrast=\"%g\"", cp->contrast);*/
   fprintf(f, " gamma=\"%g\"", cp->gamma);

   fprintf(f, " vibrancy=\"%g\"", cp->vibrancy);

/* Now never put in put in hue */   
/*   if (0 <= cp->palette_index && cp->hue_rotation != 0.0)
      fprintf(f, " hue=\"%g\"", cp->hue_rotation);*/
   fprintf(f," hue=\"0.0\"");

   /* Always put in the filter settings */
/*   if (cp->estimator >= 0.0)*/
   fprintf(f, " estimator=\"%g\" estimator_minimum=\"%g\" estimator_curve=\"%g\"",
      cp->estimator, cp->estimator_minimum, cp->estimator_curve);

   if (extra_attributes)
      fprintf(f, " %s", extra_attributes);
   
   fprintf(f, ">\n");
   

/* We will always list the colors now instead of the indices */   
/*   if (flam3_palette_interpolated == cp->palette_index) {
      fprintf(f, "%s   <palette blend=\"%g\" index0=\"%d\" hue0=\"%g\" ",
                  p, cp->palette_blend, cp->palette_index0, cp->hue_rotation0);
      fprintf(f, "index1=\"%d\" hue1=\"%g\"/>\n",
                  cp->palette_index1, cp->hue_rotation1);
   }*/
   

   if (cp->symmetry)
      fprintf(f, "%s   <symmetry kind=\"%d\"/>\n", p, cp->symmetry);
   for (i = 0; i < cp->num_xforms; i++) {
      int blob_var=0,pdj_var=0,fan2_var=0,rings2_var=0,perspective_var=0;
      if (cp->xform[i].density > 0.0 && !(cp->symmetry &&  cp->xform[i].symmetry == 1.0)) {
         fprintf(f, "%s   <xform weight=\"%g\" color=\"%g",
            p, cp->xform[i].density, cp->xform[i].color[0]);
         if (0 && 0.0 != cp->xform[i].color[1]) {
            fprintf(f, " %g\" ", cp->xform[i].color[1]);
         } else {
            fprintf(f, "\" ");
         }

         fprintf(f, "symmetry=\"%g\" ", cp->xform[i].symmetry);

         for (j = 0; j < flam3_nvariations; j++) {
            double v = cp->xform[i].var[j];
            if (0.0 != v) {
               fprintf(f, "%s=\"%g\" ", flam3_variation_names[j], v);
               if (j==23)
                  blob_var=1;
               else if (j==24)
                  pdj_var=1;
               else if (j==25)
                  fan2_var=1;
               else if (j==26)
                  rings2_var=1;
               else if (j==30)
                  perspective_var=1;
            }
         }
         
         if (blob_var==1) {
            fprintf(f, "blob_low=\"%g\" ", cp->xform[i].blob_low);
            fprintf(f, "blob_high=\"%g\" ", cp->xform[i].blob_high);
            fprintf(f, "blob_waves=\"%d\" ", cp->xform[i].blob_waves);
         }
         
         if (pdj_var==1) {
            fprintf(f, "pdj_a=\"%g\" ", cp->xform[i].pdj_a);
            fprintf(f, "pdj_b=\"%g\" ", cp->xform[i].pdj_b);
            fprintf(f, "pdj_c=\"%g\" ", cp->xform[i].pdj_c);
            fprintf(f, "pdj_d=\"%g\" ", cp->xform[i].pdj_d);
         }
         
         if (fan2_var==1) {
            fprintf(f, "fan2_x=\"%g\" ", cp->xform[i].fan2_x);
            fprintf(f, "fan2_y=\"%g\" ", cp->xform[i].fan2_y);
         }
         
         if (rings2_var==1) {
            fprintf(f, "rings2_val=\"%g\" ", cp->xform[i].rings2_val);
         }

         if (perspective_var==1) {
            fprintf(f, "perspective_angle=\"%g\" ", cp->xform[i].perspective_angle);
            fprintf(f, "perspective_dist=\"%g\" ", cp->xform[i].perspective_dist);
         }

         fprintf(f, "coefs=\"");
         for (j = 0; j < 3; j++) {
            if (j) fprintf(f, " ");
            fprintf(f, "%g %g", cp->xform[i].c[j][0], cp->xform[i].c[j][1]);
         }
         fprintf(f, "\"");
         if (!id_matrix(cp->xform[i].post)) {
            fprintf(f, " post=\"");
            for (j = 0; j < 3; j++) {
               if (j) fprintf(f, " ");
               fprintf(f, "%g %g", cp->xform[i].post[j][0], cp->xform[i].post[j][1]);
            }
            fprintf(f, "\"");
         }
         fprintf(f, "/>\n");
         
      }
   }
   
   /* Always put the palette in */
   for (i = 0; i < 256; i++) {
      int r, g, b;
      r = (int) (cp->palette[i][0] * 255.0);
      g = (int) (cp->palette[i][1] * 255.0);
      b = (int) (cp->palette[i][2] * 255.0);
      printf("%s   <color index=\"%d\" rgb=\"%d %d %d\"/>\n",
      p, i, r, g, b);
   }

   /* Edit section */
   if (cp->edits != NULL) {
      
      /* We need a custom script for printing these */
      /* and it needs to be recursive               */      
      xmlNodePtr elem_node = xmlDocGetRootElement(cp->edits);
      flam3_edit_print(f,elem_node, 1, 1);            
   }
   fprintf(f, "%s</flame>\n", p);
      
}

/* returns a uniform variable from 0 to 1 */
double flam3_random01() {
   return (random() & 0xfffffff) / (double) 0xfffffff;
}

double flam3_random11() {
   return ((random() & 0xfffffff) - 0x7ffffff) / (double) 0x7ffffff;
}

int flam3_random_bit() {
  static int n = 0;
  static int l;
  if (0 == n) {
    l = random();
    n = 20;
  } else {
    l = l >> 1;
    n--;
  }
  return l & 1;
}


/* sum of entries of vector to 1 */
static int normalize_vector(double *v, int n) {
    double t = 0.0;
    int i;
    for (i = 0; i < n; i++)
	t += v[i];
    if (0.0 == t) return 1;
    t = 1.0 / t;
    for (i = 0; i < n; i++)
	v[i] *= t;
    return 0;
}



static double round6(double x) {
  x *= 1e6;
  if (x < 0) x -= 1.0;
  return 1e-6*(int)(x+0.5);
}

/* sym=2 or more means rotational
   sym=1 means identity, ie no symmetry
   sym=0 means pick a random symmetry (maybe none)
   sym=-1 means bilateral (reflection)
   sym=-2 or less means rotational and reflective
*/
void flam3_add_symmetry(flam3_genome *cp, int sym) {
   int i, j, k;
   double a;
   int result = 0;
   
   if (0 == sym) {
      static int sym_distrib[] = {
         -4, -3,
         -2, -2, -2,
         -1, -1, -1,
         2, 2, 2,
         3, 3,
         4, 4,
      };
      if (random()&1) {
         sym = random_distrib(sym_distrib);
      } else if (random()&31) {
         sym = (random()%13)-6;
      } else {
         sym = (random()%51)-25;
      }
   }
   
   if (1 == sym || 0 == sym) return;
   
   cp->symmetry = sym;
   
   if (sym < 0) {
      
      i = cp->num_xforms;
      add_xforms_to_cp(cp,1);
      
      cp->xform[i].density = 1.0;
      cp->xform[i].symmetry = 1.0;
      cp->xform[i].var[0] = 1.0;
      for (j = 1; j < flam3_nvariations; j++)
         cp->xform[i].var[j] = 0;
      cp->xform[i].color[0] = 1.0;
      cp->xform[i].color[1] = 1.0;
      cp->xform[i].c[0][0] = -1.0;
      cp->xform[i].c[0][1] = 0.0;
      cp->xform[i].c[1][0] = 0.0;
      cp->xform[i].c[1][1] = 1.0;
      cp->xform[i].c[2][0] = 0.0;
      cp->xform[i].c[2][1] = 0.0;
      
      result++;
      sym = -sym;
   }
   
   a = 2*M_PI/sym;
   
   for (k = 1; k < sym; k++) {
      
      i = cp->num_xforms;
      add_xforms_to_cp(cp, 1);
      
      cp->xform[i].density = 1.0;
      cp->xform[i].var[0] = 1.0;
      cp->xform[i].symmetry = 1.0;
      for (j = 1; j < flam3_nvariations; j++)
         cp->xform[i].var[j] = 0;
      cp->xform[i].color[1] = /* XXX */
      cp->xform[i].color[0] = (sym<3) ? 0.0 : ((k-1.0)/(sym-2.0));
      cp->xform[i].c[0][0] = round6(cos(k*a));
      cp->xform[i].c[0][1] = round6(sin(k*a));
      cp->xform[i].c[1][0] = round6(-cp->xform[i].c[0][1]);
      cp->xform[i].c[1][1] = cp->xform[i].c[0][0];
      cp->xform[i].c[2][0] = 0.0;
      cp->xform[i].c[2][1] = 0.0;
      
      result++;
   }
   
   qsort((char *) &cp->xform[cp->num_xforms-result], result,
	   sizeof(flam3_xform), compare_xforms);
   
}

static int random_var() {
  return random() % flam3_nvariations;
}

static int random_varn(int n) {
   return random() % n;
}

void flam3_random(flam3_genome *cp, int *ivars, int ivars_n, int sym, int spec_xforms) {

   int i, nxforms, var, samed, multid, samepost, postid;   

   static int xform_distrib[] = {
     2, 2, 2, 2,
     3, 3, 3, 3,
     4, 4, 4,
     5, 5,
     6
   };
   
   memset(cp->parent_fname,0,parent_fn_len);
   
   cp->hue_rotation = (random()&7) ? 0.0 : flam3_random01();
   cp->palette_index = flam3_get_palette(flam3_palette_random, cp->palette, cp->hue_rotation);
   cp->time = 0.0;
   
   /* Choose the number of xforms */
   if (spec_xforms>0)
      nxforms = spec_xforms;
   else
      nxforms = random_distrib(xform_distrib);
   
   /* Clear old xforms in this cp, if necessary */
   if (cp->num_xforms>0 && cp->xform != NULL) {
      free(cp->xform);
      cp->num_xforms = 0;
   }
   
   add_xforms_to_cp(cp,nxforms);

   /* If first input variation is 'flam3_variation_random' */
   /* choose one to use or decide to use multiple    */
   if (flam3_variation_random == ivars[0]) {
      if (flam3_random_bit()) {
         var = random_var();
      } else {
         var = flam3_variation_random;
      }
   } else {
      var = flam3_variation_random_fromspecified;
   }
   
   
   samed = flam3_random_bit();
   multid = flam3_random_bit();
   postid = flam3_random01() < 0.6;
   samepost = flam3_random_bit();
   
   /* Loop over xforms */
   for (i = 0; i < nxforms; i++) {
      int j, k;
      cp->xform[i].density = 1.0 / nxforms;
      cp->xform[i].color[0] = i&1;
      cp->xform[i].color[1] = (i&2)>>1;
      cp->xform[i].symmetry = 0.0;
      for (j = 0; j < 3; j++) {
         for (k = 0; k < 2; k++) {
            cp->xform[i].c[j][k] = flam3_random11();
            cp->xform[i].post[j][k] = (double)(k==j);
         }
      }
      if (!postid) {
         for (j = 0; j < 3; j++)
	      for (k = 0; k < 2; k++) {
            if (samepost || (i==0))
               cp->xform[i].post[j][k] = flam3_random11();
            else
               cp->xform[i].post[j][k] = cp->xform[0].post[j][k];
	      }
      }
      
      /* Clear all variation coefs */
      for (j = 0; j < flam3_nvariations; j++)
         cp->xform[i].var[j] = 0.0;
   
      if (flam3_variation_random != var && flam3_variation_random_fromspecified != var) {

         /* Use only one variation specified for all xforms */
         cp->xform[i].var[var] = 1.0;

      } else if (multid && flam3_variation_random == var) {

         /* Choose a random var for this xform */
         if (flam3_variation_random == var)
            cp->xform[i].var[random_var()] = 1.0;
         else
            cp->xform[i].var[ivars[random_varn(ivars_n)]] = 1.0;
         

      } else {
         int n;
         double sum;
         if (samed && i > 0) {
            
            /* Copy the same variations from the previous xform */
            for (j = 0; j < flam3_nvariations; j++)
               cp->xform[i].var[j] = cp->xform[i-1].var[j];
            
         } else {
            
            /* Choose a random number of vars to use, at least 2 */
            /* but less than flam3_nvariations.Probability leans */
            /* towards fewer variations.                         */
            n = 2;
            while ((flam3_random_bit()) && (n<flam3_nvariations))
               n++;

            /* Randomly choose n variations, and change their weights. */
            /* A var can be selected more than once, further reducing  */
            /* the probability that multiple vars are used.            */
            for (j = 0; j < n; j++) {
               if (flam3_variation_random == var)
                  cp->xform[i].var[random_var()] = flam3_random01();
               else
                  cp->xform[i].var[ivars[random_varn(ivars_n)]] = flam3_random01();
            }
            
            /* Normalize weights to 1.0 total. */
            sum = 0.0;
            for (j = 0; j < flam3_nvariations; j++)
               sum += cp->xform[i].var[j];
            if (sum == 0.0)
               cp->xform[i].var[random_var()] = 1.0;
            else {
               for (j = 0; j < flam3_nvariations; j++)
                  cp->xform[i].var[j] /= sum;
            }
         }
      }
         
      /* Generate random params for parametric variations, if selected. */
      if (cp->xform[i].var[23] > 0) {
         /* Create random params for blob */
         cp->xform[i].blob_low = 0.2 + 0.5 * flam3_random01();
         cp->xform[i].blob_high = 0.8 + 0.4 * flam3_random01();
         cp->xform[i].blob_waves = 2 + 5 * flam3_random01();
      }
      
      if (cp->xform[i].var[24] > 0) {
         /* Create random params for PDJ */
         cp->xform[i].pdj_a = 3.0 * flam3_random11();
         cp->xform[i].pdj_b = 3.0 * flam3_random11();
         cp->xform[i].pdj_c = 3.0 * flam3_random11();
         cp->xform[i].pdj_d = 3.0 * flam3_random11();
      }
      
      if (cp->xform[i].var[25] > 0) {
         /* Create random params for fan2 */
         cp->xform[i].fan2_x = flam3_random11();
         cp->xform[i].fan2_y = flam3_random11();
      }
      
      if (cp->xform[i].var[26] > 0) {
         /* Create random params for rings2 */
         cp->xform[i].rings2_val = 2*flam3_random01();
      }
      
      if (cp->xform[i].var[30] > 0) {
         double ang;
         
         /* Create random params for perspective */
         cp->xform[i].perspective_angle = flam3_random01();
         cp->xform[i].perspective_dist = 2*flam3_random01() + 1.0;
         
         /* Calculate the other params from these */
         ang = cp->xform[i].perspective_angle * M_PI / 2.0;
         cp->xform[i].persp_vsin = sin(ang);
         cp->xform[i].persp_vfcos = cp->xform[i].perspective_dist * cos(ang);
         
      }
      
   }
   
   /* Randomly add symmetry */   
   if (sym || !(random()%4))
      flam3_add_symmetry(cp, sym);
   else
      cp->symmetry = 0;
   
   /* Necessary with defaults? */
   cp->gamma = 4.0;
   cp->vibrancy = 1.0;
   cp->contrast = 1.0;
   cp->brightness = 4.0;
   
   qsort((char *) cp->xform, cp->num_xforms, sizeof(flam3_xform), compare_xforms);

}


static int sort_by_x(const void *av, const void *bv) {
    double *a = (double *) av;
    double *b = (double *) bv;
    if (a[0] < b[0]) return -1;
    if (a[0] > b[0]) return 1;
    return 0;
}

static int sort_by_y(const void *av, const void *bv) {
    double *a = (double *) av;
    double *b = (double *) bv;
    if (a[1] < b[1]) return -1;
    if (a[1] > b[1]) return 1;
    return 0;
}


/*
 * find a 2d bounding box that does not enclose eps of the fractal density
 * in each compass direction.
 */
void flam3_estimate_bounding_box(flam3_genome *cp, double eps, int nsamples,
				 double *bmin, double *bmax) {
   int i;
   int low_target, high_target;
   double min[2], max[2];
   double *points;

   if (nsamples <= 0) nsamples = 10000;
   low_target = (int)(nsamples * eps);
   high_target = nsamples - low_target;
   
   points = (double *) malloc(sizeof(double) * 4 * nsamples);
   points[0] = flam3_random11();
   points[1] = flam3_random11();
   points[2] = 0.0;
   points[3] = 0.0;
   
   prepare_xform_fn_ptrs(cp);
   flam3_iterate(cp, nsamples, 20, points);

   min[0] = min[1] =  1e10;
   max[0] = max[1] = -1e10;
   
   for (i = 0; i < nsamples; i++) {
      double *p = &points[4*i];
      if (p[0] < min[0]) min[0] = p[0];
      if (p[1] < min[1]) min[1] = p[1];
      if (p[0] > max[0]) max[0] = p[0];
      if (p[1] > max[1]) max[1] = p[1];
   }

   if (low_target == 0) {
      bmin[0] = min[0];
      bmin[1] = min[1];
      bmax[0] = max[0];
      bmax[1] = max[1];
      free(points);
      return;
   }

   qsort(points, nsamples, sizeof(double) * 4, sort_by_x);
   bmin[0] = points[4 * low_target];
   bmax[0] = points[4 * high_target];
   
   qsort(points, nsamples, sizeof(double) * 4, sort_by_y);
   bmin[1] = points[4 * low_target + 1];
   bmax[1] = points[4 * high_target + 1];
   free(points);
}





typedef double bucket_double[4];
typedef double abucket_double[4];
typedef unsigned int bucket_int[4];
typedef unsigned int abucket_int[4];
typedef unsigned short bucket_short[4];
typedef unsigned short abucket_short[4];
typedef float bucket_float[4];
typedef float abucket_float[4];


/* 64-bit datatypes */
#define B_ACCUM_T double
#define A_ACCUM_T double
#define bucket bucket_double
#define abucket abucket_double
#define bump_no_overflow(dest, delta) {dest += delta;}
#define abump_no_overflow(dest, delta) {dest += delta;}
#define add_c_to_accum(acc,i,ii,j,jj,wid,hgt,c) { \
	if ( (j) + (jj) >=0 && (j) + (jj) < (hgt) && (i) + (ii) >=0 && (i) + (ii) < (wid)) { \
	abucket *a = (acc) + ( (i) + (ii) ) + ( (j) + (jj) ) * (wid); \
	abump_no_overflow(a[0][0],(c)[0]); \
	abump_no_overflow(a[0][1],(c)[1]); \
	abump_no_overflow(a[0][2],(c)[2]); \
	abump_no_overflow(a[0][3],(c)[3]); \
	} \
}
#define render_rectangle render_rectangle_double
#include "rect.c"
#undef render_rectangle
#undef add_c_to_accum
#undef A_ACCUM_T
#undef B_ACCUM_T
#undef bucket
#undef abucket
#undef bump_no_overflow
#undef abump_no_overflow

/* 32-bit datatypes */
#define B_ACCUM_T unsigned int
#define A_ACCUM_T unsigned int
#define bucket bucket_int
#define abucket abucket_int
#define bump_no_overflow(dest, delta) { \
   if (UINT_MAX - dest > delta) dest += delta; \
}
#define abump_no_overflow(dest, delta) { \
   if (UINT_MAX - dest > delta) dest += delta; \
}
#define add_c_to_accum(acc,i,ii,j,jj,wid,hgt,c) { \
	if ( (j) + (jj) >=0 && (j) + (jj) < (hgt) && (i) + (ii) >=0 && (i) + (ii) < (wid)) { \
	abucket *a = (acc) + ( (i) + (ii) ) + ( (j) + (jj) ) * (wid); \
	abump_no_overflow(a[0][0],(c)[0]); \
	abump_no_overflow(a[0][1],(c)[1]); \
	abump_no_overflow(a[0][2],(c)[2]); \
	abump_no_overflow(a[0][3],(c)[3]); \
	} \
}
#define render_rectangle render_rectangle_int
#include "rect.c"
#undef render_rectangle
#undef add_c_to_accum
#undef A_ACCUM_T
#undef B_ACCUM_T
#undef bucket
#undef abucket
#undef bump_no_overflow
#undef abump_no_overflow

/* experimental 32-bit datatypes (called 33) */
#define B_ACCUM_T unsigned int
#define A_ACCUM_T float
#define bucket bucket_int
#define abucket abucket_float
#define bump_no_overflow(dest, delta) { \
   if (UINT_MAX - dest > delta) dest += delta; \
}
#define abump_no_overflow(dest, delta) {dest += delta;}
#define add_c_to_accum(acc,i,ii,j,jj,wid,hgt,c) { \
	if ( (j) + (jj) >=0 && (j) + (jj) < (hgt) && (i) + (ii) >=0 && (i) + (ii) < (wid)) { \
	abucket *a = (acc) + ( (i) + (ii) ) + ( (j) + (jj) ) * (wid); \
	abump_no_overflow(a[0][0],(c)[0]); \
	abump_no_overflow(a[0][1],(c)[1]); \
	abump_no_overflow(a[0][2],(c)[2]); \
	abump_no_overflow(a[0][3],(c)[3]); \
	} \
}
#define render_rectangle render_rectangle_float
#include "rect.c"
#undef render_rectangle
#undef add_c_to_accum
#undef A_ACCUM_T
#undef B_ACCUM_T
#undef bucket
#undef abucket
#undef bump_no_overflow
#undef abump_no_overflow


/* 16-bit datatypes */
#define B_ACCUM_T unsigned short
#define A_ACCUM_T unsigned short
#define bucket bucket_short
#define abucket abucket_short
#define MAXBUCKET (1<<14)
#define bump_no_overflow(dest, delta) { \
   if (USHRT_MAX - dest > delta) dest += delta; \
}
#define abump_no_overflow(dest, delta) { \
   if (USHRT_MAX - dest > delta) dest += delta; \
}
#define add_c_to_accum(acc,i,ii,j,jj,wid,hgt,c) { \
	if ( (j) + (jj) >=0 && (j) + (jj) < (hgt) && (i) + (ii) >=0 && (i) + (ii) < (wid)) { \
	abucket *a = (acc) + ( (i) + (ii) ) + ( (j) + (jj) ) * (wid); \
	abump_no_overflow(a[0][0],(c)[0]); \
	abump_no_overflow(a[0][1],(c)[1]); \
	abump_no_overflow(a[0][2],(c)[2]); \
	abump_no_overflow(a[0][3],(c)[3]); \
	} \
}
#define render_rectangle render_rectangle_short
#include "rect.c"
#undef render_rectangle
#undef add_c_to_accum
#undef A_ACCUM_T
#undef B_ACCUM_T
#undef bucket
#undef abucket
#undef bump_no_overflow
#undef abump_no_overflow

double flam3_render_memory_required(flam3_frame *spec)
{
  flam3_genome *cps = spec->genomes;
  int real_bits = spec->bits;

  if (33 == real_bits) real_bits = 32;

  /* note 4 channels * 2 buffers cancels out 8 bits per byte */
  /* does not yet include memory for density estimation filter */

  return
    (double) cps[0].spatial_oversample * cps[0].spatial_oversample *
    (double) cps[0].width * cps[0].height * real_bits;
}

void flam3_render(flam3_frame *spec, unsigned char *out,
		  int out_width, int field, int nchan, int trans) {
  switch (spec->bits) {
  case 16:
    render_rectangle_short(spec, out, out_width, field, nchan, trans);
    break;
  case 32:
    render_rectangle_int(spec, out, out_width, field, nchan, trans);
    break;
  case 33:
    render_rectangle_float(spec, out, out_width, field, nchan, trans);
    break;
  case 64:
    render_rectangle_double(spec, out, out_width, field, nchan, trans);
    break;
  default:
    fprintf(stderr, "bad bits, must be 16, 32, 33, or 64 not %d.\n", spec->bits);
    exit(1);
    break;
  }
}
