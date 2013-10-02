#! /bin/sh
# Copyright (C) 2012 Free Software Foundation, Inc.
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

# Check that rules generated by user recursion are apt to be wrapped
# by other makefiles.

required=GNUmake
. test-init.sh

cat >> configure.ac << 'END'
AM_EXTRA_RECURSIVE_TARGETS([extra])
AC_CONFIG_FILES([src/Makefile])
AC_OUTPUT
END

mkdir src
echo SUBDIRS = src > Makefile.am
echo 'bar: ; : > $@ ' > src/Makefile.am

$ACLOCAL
$AUTOCONF
$AUTOMAKE

./configure

$MAKE extra
test ! -f extra-local
test ! -f src/bar

cat > GNUmakefile << 'END'
.DEFAULT_GOAL = all
extra-local:
	: > $@
include ./Makefile
END

cat > src/GNUmakefile << 'END'
include ./Makefile
extra-local: bar
END

$MAKE extra
test -f extra-local
test -f src/bar

:
