#! /bin/sh
# Copyright (C) 1997-2012 Free Software Foundation, Inc.
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

# Test to make sure 3rd arg to AM_INIT_AUTOMAKE not picked up in
# version.  From Joel Weber.

. ./defs || Exit 1

cat > configure.ac << 'END'
AC_INIT
AM_INIT_AUTOMAKE([sh-utils], [1.12o], [no])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
END

: > Makefile.am

# Files required by Gnits.
: > INSTALL
: > NEWS
: > README
: > COPYING
: > AUTHORS
: > ChangeLog
: > THANKS

$ACLOCAL
$AUTOMAKE --gnits
