/*
    flame - cosmic recursive fractal flames
    Copyright (C) 1992-2003  Scott Draves <source@flam3.com>

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

static char *docstring_c_id =
"@(#) $Id: docstring.c,v 1.3 2006/07/02 12:50:17 vargol Exp $";

#include "config.h"



char *docstring =
"flam3 - cosmic recursive fractal flames version " VERSION "\n"
"Scott Draves <readme@flam3.com>\n"
"This software is licensed under the GPL.  You should have access\n"
"to the source code; see http://www.fsf.org/licenses/gpl.html.\n"
"\n"
"This is free software to render fractal flames as described on\n"
"http://flam3.com.  Flam3-animate makes animations, and flam3-render\n"
"makes still images.  Flam3-genome creates and manipulates genomes\n"
"(parameter sets).  A C library is also installed.\n"
"\n"
"Note: the following instructions are written for Linux users.  Windows\n"
"users may have to install the cygwin package to get the \"env\"\n"
"command or set the envars in your windows command prompt manually.\n"
"That means instead of a command like\n"
"\n"
"    env dtime=5 prefix=foo. in=test.flame flam3-animate\n"
"\n"
"say\n"
"\n"
"    set dtime=5\n"
"    set prefix=foo.\n"
"    set in=test.flame\n"
"    flam3-animate\n"
"\n"
"Both programs get their options through environment variables.  An\n"
"easy way to set them is to invoke the program via the env command,\n"
"which allows you to give name=value pairs.\n"
"\n"
"envar		default		meaning\n"
"=====		=======		=======\n"
"prefix		\"\"		prefix names of output files with this string.\n"
"begin		j		time of first frame to render (j=first time specified in file) (animate only)\n"
"end 		n-1		time of last frame to render (n=last time specified in the input file) (animate only)\n"
"time		NA		time of first and last frame (ie do one frame) (animate only)\n"
"frame		NA		synonym for \"time\" (animate only)\n"
"in		stdin		name of input file\n"
"out		NA		name of output file (bad idea if rending more than one, use prefix instead)\n"
"template	NA		apply defaults based on this genome (genome only)\n"
"dtime		1		time between frames (animate only)\n"
"fields		0		if 1 then render fields, ie odd scanlines at time+0.5\n"
"nstrips		1		number of strips, ie render fractions of a frame at once (render only)\n"
"qs		1		quality scale, multiply quality of all frames by this\n"
"ss		1		size scale, multiply size (in pixels) of all frames by this\n"
"jpeg		NA		jpeg quality for compression, default is native jpeg default\n"
"format		jpg		jpg or ppm or png\n"
"pixel_aspect    1.0             aspect ratio of pixels (width over height), eg 0.90909 for NTSC\n"
"seed            random		integer seed for random numbers, defaults to time+pid\n"
"verbose		0		if non-zero then print progress meter on stderr\n"
"bits		33		also maybe 16, 32, or 64: sets bit-width of internal buffers\n"
"image		filename	replace palette with png, jpg, or ppm image\n"
"tries		50		number of tries to make to find a good genome.\n"
"use_vars	-1		comma separated list of variation #'s to use when generating a random flame (genome only)\n"
"method		NA		method for crossover: alternate, interpolate, or union.\n"
"symmetry	NA		set symmetry of result.\n"
"clone		NA		clone input (this is an alternative to mutate).\n"
"transparency	1		make bknd transparent, if format supports it\n"
"name_enable	0		use 'name' attr in <flame> to name image output if present (render only)\n"
"nick		\"\"		nickname to use in <edit> tags (genome only)\n"
"url		\"\"		url to use in <edit> tags (genome only)\n"
"comment		\"\"		comment string for <edit> tags (genome only)\n"
"use_mem		auto		floating point number of bytes of memory to use (render only)\n"
"\n"
"\n"
"for example:\n"
"\n"
"    env dtime=5 prefix=foo. in=test.flam3 flam3-animate\n"
"\n"
"means to render every 5th frame of parameter file foo.flam3, and store\n"
"the results in files named foo.XXXX.jpg.\n"
"\n"
"the flam3-convert program reads from stdin the old format created by\n"
"the GIMP and writes to stdout the new xml format.\n"
"\n"
"the flam3-genome program creates random parameter files. it also mutates,\n"
"rotates, and interpolates existing parameter files.  for example to\n"
"create 10 wholly new control points and render them at normal quality:\n"
"\n"
"    env template=vidres.flam3 repeat=10 flam3-genome > new.flam3\n"
"    flam3-render < new.flam3\n"
"\n"
"if you left out the \"template=vidres.flam3\" part then the size,\n"
"quality, etc parameters would be their default (small) values.  you\n"
"can set the symmetry group:\n"
"\n"
"    env template=vidres.flam3 symmetry=3 flam3-genome > new3.flam3\n"
"    env template=vidres.flam3 symmetry=-2 flam3-genome > new-2.flam3\n"
"    flam3-render < new3.flam3\n"
"    flam3-render < new-2.flam3\n"
"\n"
"Mutation is done by giving an input flame file to alter:\n"
"\n"
"    env template=vidres.flam3 flam3-genome > parent.flam3\n"
"    env prefix=parent. flam3-render < parent.flam3\n"
"    env template=vidres.flam3 mutate=vidres.flam3 repeat=10 flam3-genome > mutation.flam3\n"
"    flam3-render < mutation.flam3\n"
"\n"
"Normally one wouldn't use the same file for the template and the file\n"
"to mutate.  Crossover is handled similarly:\n"
"\n"
"    env template=vidres.flam3 flam3-genome > parent0.flam3\n"
"    env prefix=parent0. flam3-render < parent0.flam3\n"
"    env template=vidres.flam3 flam3-genome > parent1.flam3\n"
"    env prefix=parent1. flam3-render < parent1.flam3\n"
"    env template=vidres.flam3 cross0=parent0.flam3 cross1=parent1.flam3 flam3-genome > crossover.flam3\n"
"    flam3-render < crossover.flam3\n"
"\n"
"flam3-genome has 3 ways to produce parameter files for animation in\n"
"the style of electric sheep.  the highest level and most useful from\n"
"the command line is the sequence method.  it takes a collection of\n"
"control points and makes an animation that has each flame do fractal\n"
"rotation for 360 degrees, then make a smooth transition to the next.\n"
"for example:\n"
"\n"
"    env sequence=test.flam3 nframes=20 flam3-genome > seq.flam3\n"
"    flam3-animate < seq.flam3\n"
"\n"
"creates and renders a 60 frame animation.  there are two flames in\n"
"test.flam3, so the animation consists three stags: the first one\n"
"rotating, then a transition, then the second one rotating.  each stage\n"
"has 20 frames as specified on the command line.  but with only 20\n"
"frames to complete 360 degrees the shape will is moving quite quickly\n"
"so you will see strobing from the temporal subsamples used for\n"
"motion blur.  to eliminate them increase the number of batches by\n"
"editing test.flam3 and increasing it from 10 to 100.  if you want to\n"
"render only some fraction of a whole animation file, specify the begin\n"
"and end times:\n"
"\n"
"    env begin=20 end=40 flam3-animate < seq.flam3\n"
"\n"
"the other two methods are harder to use becaues they produce file that\n"
"are only good for one frame of animation.  the output consists of 3\n"
"control points, one for the time requested, one before and one after.\n"
"that allows proper motion blur.  for example:\n"
"\n"
"    env template=vidres.flam3 flam3-genome > rotme.flam3\n"
"    env rotate=rotme.flam3 frame=10 nframes=20 flam3-genome > rot10.flam3\n"
"    env frame=10 flam3-animate < rot10.flam3\n"
"\n"
"the file rot10.flam3 specifies the animation for just one frame, in\n"
"this case 10 out of 20 frames in the complete animation.  C1\n"
"continuous electric sheep genetic crossfades are created like this:\n"
"\n"
"    env inter=test.flam3 frame=10 nframes=20 flam3-genome > inter10.flam3\n"
"    env frame=10 flam3-animate < inter10.flam3\n"
"A preview of image fractalization is available by setting the image\n"
"envar to the name of a png (alpha supported), jpg, or ppm format file.\n"
"Note this interface will change!  This image is used as a 2D palette\n"
"to paint the flame.  The input image must be 256x256 pixels.  For\n"
"example:\n"
"\n"
"    env image=star.png flam3-render < test.flam3\n"
"\n"
"--\n"
"\n"
"The complete list of variations:\n"
"\n"
"  linear\n"
"  sinusoidal\n"
"  spherical\n"
"  swirl\n"
"  horseshoe\n"
"  polar\n"
"  handkerchief\n"
"  heart\n"
"  disc\n"
"  spiral\n"
"  hyperbolic\n"
"  diamond\n"
"  ex\n"
"  julia\n"
"  bent\n"
"  waves\n"
"  fisheye\n"
"  popcorn\n"
"  exponential\n"
"  power\n"
"  cosine\n"
"  rings\n"
"  fan\n"
"  blob\n"
"  pdj\n"
"  fan2\n"
"  rings2\n"
"  eyefish\n"
"  bubble\n"
"  cylinder\n"
"  perspective\n"
"  noise\n"
"  julian\n"
"  juliascope\n"
"  blur\n"
"\n"
"see http://flam3.com/flame.pdf for descriptions & formulas for each of\n"
"these.\n"
;