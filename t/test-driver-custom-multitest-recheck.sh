#! /bin/sh
# Copyright (C) 2011-2012 Free Software Foundation, Inc.
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

# Custom test drivers: try the "recheck" functionality with test protocols
# that allow multiple testcases in a single test script.  This test not
# only checks implementation details in Automake's custom test drivers
# support, but also serves as a "usability test" for our APIs.
# See also related tests 'test-driver-custom-multitest-recheck2.test'
# and 'parallel-tests-recheck-override.test'.
# Keep in sync with 'tap-recheck.test'.

am_parallel_tests=yes
. ./defs || Exit 1

cp "$am_testauxdir"/trivial-test-driver . \
  || fatal_ "failed to fetch auxiliary script trivial-test-driver"

cat >> configure.ac << 'END'
AC_OUTPUT
END

cat > Makefile.am << 'END'
TEST_LOG_DRIVER = $(SHELL) $(srcdir)/trivial-test-driver
TESTS = a.test b.test c.test d.test
END

cat > a.test << 'END'
#! /bin/sh
echo PASS: aa
echo PASS: AA
: > a.run
END

cat > b.test << 'END'
#! /bin/sh
echo PASS:
if test -f b.ok; then
  echo PASS:
else
  echo ERROR:
fi
: > b.run
END

cat > c.test << 'END'
#! /bin/sh
if test -f c.pass; then
  echo PASS: c0
else
  echo FAIL: c0
fi
if test -f c.xfail; then
  echo XFAIL: c1
else
  echo XPASS: c1
fi
echo XFAIL: c2
: > c.run
END

cat > d.test << 'END'
#! /bin/sh
echo SKIP: who cares ...
(. ./d.extra) || echo FAIL: d.extra failed
: > d.run
END

chmod a+x *.test

$ACLOCAL
$AUTOCONF
$AUTOMAKE

do_recheck ()
{
  case $* in
    --fail) on_bad_rc='&&';;
    --pass) on_bad_rc='||';;
         *) fatal_ "invalid usage of function 'do_recheck'";;
  esac
  rm -f *.run
  eval "\$MAKE recheck >stdout $on_bad_rc { cat stdout; ls -l; Exit 1; }; :"
  cat stdout; ls -l
}

for vpath in : false; do
  if $vpath; then
    mkdir build
    cd build
    srcdir=..
  else
    srcdir=.
  fi

  $srcdir/configure

  : A "make recheck" in a clean tree should run no tests.
  do_recheck --pass
  cat test-suite.log
  test ! -r a.run
  test ! -r a.log
  test ! -r b.run
  test ! -r b.log
  test ! -r c.run
  test ! -r c.log
  test ! -r d.run
  test ! -r d.log
  count_test_results total=0 pass=0 fail=0 xpass=0 xfail=0 skip=0 error=0

  : Run the tests for the first time.
  $MAKE check >stdout && { cat stdout; Exit 1; }
  cat stdout
  ls -l
  # All the test scripts should have run.
  test -f a.run
  test -f b.run
  test -f c.run
  test -f d.run
  count_test_results total=9 pass=3 fail=2 xpass=1 xfail=1 skip=1 error=1

  : Let us make b.test pass.
  echo OK > b.ok
  do_recheck --fail
  # a.test has been successful the first time, so no need to re-run it.
  # Similar considerations apply to similar checks, below.
  test ! -r a.run
  test -f b.run
  test -f c.run
  test -f d.run
  count_test_results total=7 pass=2 fail=2 xpass=1 xfail=1 skip=1 error=0

  : Let us make the first part of c.test pass.
  echo OK > c.pass
  do_recheck --fail
  test ! -r a.run
  test ! -r b.run
  test -f c.run
  test -f d.run
  count_test_results total=5 pass=1 fail=1 xpass=1 xfail=1 skip=1 error=0

  : Let us make also the second part of c.test pass.
  echo KO > c.xfail
  do_recheck --fail
  test ! -r a.run
  test ! -r b.run
  test -f c.run
  test -f d.run
  count_test_results total=5 pass=1 fail=1 xpass=0 xfail=2 skip=1 error=0

  : Nothing changed, so only d.test should be run.
  for i in 1 2; do
    do_recheck --fail
    test ! -r a.run
    test ! -r b.run
    test ! -r c.run
    test -f d.run
    count_test_results total=2 pass=0 fail=1 xpass=0 xfail=0 skip=1 error=0
  done

  : Let us make d.test run more testcases, and experience _more_ failures.
  unindent > d.extra <<'END'
    echo SKIP: s
    echo FAIL: f 1
    echo PASS: p 1
    echo FAIL: f 2
    echo XPASS: xp
    echo FAIL: f 3
    echo FAIL: f 4
    echo ERROR: e 1
    echo PASS: p 2
    echo ERROR: e 2
END
  do_recheck --fail
  test ! -r a.run
  test ! -r b.run
  test ! -r c.run
  test -f d.run
  count_test_results total=11 pass=2 fail=4 xpass=1 xfail=0 skip=2 error=2

  : Let us finally make d.test pass.
  echo : > d.extra
  do_recheck --pass
  test ! -r a.run
  test ! -r b.run
  test ! -r c.run
  test -f d.run
  count_test_results total=1 pass=0 fail=0 xpass=0 xfail=0 skip=1 error=0

  : All tests have been successful or skipped, nothing should be re-run.
  do_recheck --pass
  test ! -r a.run
  test ! -r b.run
  test ! -r c.run
  test ! -r d.run
  count_test_results total=0 pass=0 fail=0 xpass=0 xfail=0 skip=0 error=0

  cd $srcdir

done

:
