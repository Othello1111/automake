#! /bin/sh
# Copyright (C) 2006-2012 Free Software Foundation, Inc.
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

# See how well the rebuild rule handles an aclocal.m4 that was
# generated for another version of autoconf.

. ./defs || Exit 1

echo AC_OUTPUT >>configure.ac

touch Makefile.am

$ACLOCAL
$AUTOCONF
$AUTOMAKE
./configure
$MAKE

sed '1,20 s/m4_defn(\[AC_AUTOCONF_VERSION\]),/9999,/' < aclocal.m4 > aclocal.tmp
cmp aclocal.m4 aclocal.tmp && Exit 1

mv aclocal.tmp aclocal.m4

$MAKE 2>stderr || { cat cat stderr >&2; Exit 1; }
cat stderr >&2
grep 'You have another version of autoconf' stderr
grep 'aclocal.m4:.*this file was generated for' stderr

$MAKE 2>stderr || { cat cat stderr >&2; Exit 1; }
cat stderr >&2
grep 'You have another version of autoconf' stderr && Exit 1
grep 'aclocal.m4:.*this file was generated for' stderr && Exit 1

:
