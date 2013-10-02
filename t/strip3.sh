#! /bin/sh
# Copyright (C) 2010-2012 Free Software Foundation, Inc.
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

# Ensure install-strip works when STRIP consists of more than one word.
# This test needs GNU binutils strip.  Libtool variant.

required='cc libtoolize strip'
. ./defs || Exit 1

cat >> configure.ac << 'END'
AC_PROG_CC
AM_PROG_AR
AC_PROG_LIBTOOL
AC_OUTPUT
END

cat > Makefile.am << 'END'
bin_PROGRAMS = foo
lib_LTLIBRARIES = libfoo.la
END

cat > foo.c << 'END'
int main () { return 0; }
END

cat > libfoo.c << 'END'
int foo () { return 0; }
END

libtoolize
$ACLOCAL
$AUTOCONF
$AUTOMAKE -a

prefix=`pwd`/inst
./configure --prefix="$prefix" STRIP='strip --verbose'
$MAKE
$MAKE install-strip

:
