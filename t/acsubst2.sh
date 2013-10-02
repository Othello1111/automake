#! /bin/sh
# Copyright (C) 2002-2012 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. ./defs || Exit 1

cat >> configure.ac << 'END'
AC_PROG_CC
AM_PROG_CC_C_O
AC_SUBST([FOOBAR_CFLAGS],[blablabla])
END

cat > Makefile.am << 'END'
bin_PROGRAMS = mumble
mumble_SOURCES = a.c b.c d.h
mumble_CFLAGS = $(FOOBAR_CFLAGS)
END

$ACLOCAL
$AUTOMAKE -a
