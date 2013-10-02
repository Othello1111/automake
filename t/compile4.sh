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

# Make sure 'compile' wraps the Microsoft C/C++ compiler (cl) correctly
# with respect to absolute paths.

required='cl'
. ./defs || Exit 1

get_shell_script compile

mkdir sub

cat >sub/foo.c <<'EOF'
int
foo ()
{
  return 0;
}
EOF

cat >main.c <<'EOF'
extern int foo ();
int
main ()
{
  return foo ();
}
EOF

absfoodir=`pwd`/sub
absmainc=`pwd`/main.c
absmainobj=`pwd`/main.obj

cat >> configure.ac << 'END'
AC_PROG_CC
AM_PROG_CC_C_O
AM_PROG_AR
AC_PROG_RANLIB
AC_CONFIG_FILES([sub/Makefile])
AC_OUTPUT
END

cat > Makefile.am << 'END'
SUBDIRS = sub
END

cat > sub/Makefile.am << 'END'
lib_LIBRARIES = libfoo.a
libfoo_a_SOURCES = foo.c
END

$ACLOCAL
$AUTOCONF
$AUTOMAKE -a
./configure
$MAKE

./compile cl $CPPFLAGS $CFLAGS -c -o "$absmainobj" "$absmainc"

# cl expects archives to be named foo.lib, not libfoo.a so
# make a simple copy here if needed. This is a severe case
# of badness, but ignore that since this is not what is
# being tested here...
if test -f sub/libfoo.a; then
  cp sub/libfoo.a sub/foo.lib
fi

# POSIX mandates that the compiler accepts a space between the -I,
# -l and -L options and their respective arguments.  Traditionally,
# this should work also without a space.  Try both usages.
for sp in '' ' '; do
  rm -f main

  ./compile cl $CFLAGS $LDFLAGS -L${sp}"$absfoodir" "$absmainobj" -o main -l${sp}foo

  ./main
done

:
