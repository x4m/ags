# contrib/ags/Makefile

MODULE_big = ags
OBJS = gist.o gistutil.o gistxlog.o gistvacuum.o gistget.o gistscan.o \
       gistproc.o gistsplit.o gistbuild.o gistbuildbuffers.o gistvalidate.o $(WIN32RES)

EXTENSION = ags
DATA = ags--1.0.sql
PGFILEDESC = "Advanced Generalized Search access method - GiST-based advanced index"

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/ags
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
