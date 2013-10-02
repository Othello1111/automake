#! /bin/sh
# Copyright (C) 2003-2012 Free Software Foundation, Inc.
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

# Test to make sure config files are distributed, and only once.
# This tries to distribute a file from a subdirectory, with
# a Makefile in that directory.  distcom4.test performs the same
# test without Makefile in the directory.

. ./defs || Exit 1

extract_distcommon ()
{
  sed -n -e '/^DIST_COMMON =.*\\$/ {
    :loop
    p
    n
    t clear
    :clear
    s/\\$/\\/
    t loop
    p
    n
    }' -e '/^DIST_COMMON =/ p' ${1+"$@"}
}

cat >> configure.ac << 'END'
   AC_CONFIG_FILES([tests/autoconf:tests/wrapper.in],
                   [chmod +x tests/autoconf])
   AC_CONFIG_FILES([tests/autoheader:tests/wrapper.in],
                   [chmod +x tests/autoheader])
   AC_CONFIG_FILES([tests/autom4te:tests/wrapper.in],
                   [chmod +x tests/autom4te])
   AC_CONFIG_FILES([tests/autoreconf:tests/wrapper.in],
                   [chmod +x tests/autoreconf])
   AC_CONFIG_FILES([tests/autoscan:tests/wrapper.in],
                   [chmod +x tests/autoscan])
   AC_CONFIG_FILES([tests/autoupdate:tests/wrapper.in],
                   [chmod +x tests/autoupdate])
   AC_CONFIG_FILES([tests/ifnames:tests/wrapper.in],
                   [chmod +x tests/ifnames])
   AC_CONFIG_FILES([tests/Makefile])
   AC_OUTPUT
END

mkdir tests
: > tests/wrapper.in
: > tests/Makefile.am
cat > Makefile.am << 'END'
SUBDIRS = tests
.PHONY: test
test: distdir
	test -f $(distdir)/tests/wrapper.in
END

$ACLOCAL
$AUTOCONF
$AUTOMAKE --add-missing
./configure
$MAKE test

extract_distcommon Makefile.in > top.txt
extract_distcommon tests/Makefile.in > inner.txt

# Might be useful for debugging.
cat top.txt
cat inner.txt

test 0 = `grep tests top.txt | wc -l`
test 1 = `grep wrapper inner.txt | wc -l`

:
