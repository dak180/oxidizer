AUTOMAKE_OPTIONS = foreign no-dependencies

AM_CFLAGS = -g -O3 -ffast-math -DPACKAGE_DATA_DIR=\"$(pkgdatadir)\"

bin_PROGRAMS = flam3-animate flam3-genome flam3-render flam3-convert
lib_LIBRARIES = libflam3.a
include_HEADERS = flam3.h

libflam3_a_SOURCES = flam3.c flam3-palettes.c jpeg.c png.c isaac.c

flam3_genome_SOURCES = flam3-genome.c docstring.c
flam3_genome_LDADD = libflam3.a -lm

flam3_animate_SOURCES = flam3-animate.c docstring.c
flam3_animate_LDADD = libflam3.a -lm

flam3_render_SOURCES = flam3-render.c docstring.c
flam3_render_LDADD = libflam3.a -lm

flam3_convert_SOURCES = flam3-convert.c docstring.c
flam3_convert_LDADD = libflam3.a -lm

pkgdata_DATA = flam3-palettes.xml

EXTRA_DIST = rect.c flam3.h private.h isaac.h isaacs.h img.h test.flam3 vidres.flam3 \
   flam3.dsw render.dsp animate.dsp genome.dsp convert.dsp \
   mkinstalldirs README.txt COPYING.txt flam3-palettes.xml

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = flam3.pc
