#! /bin/sh
# This file has been automatically generated.  DO NOT EDIT BY HAND!
. ./defs-static || exit '99';
am_tap_implementation=perl
# In the spirit of VPATH, we prefer a test in the build tree
# over one in the source tree.
for dir in . "$am_top_srcdir"; do
  if test -f "$dir/t/tap-planskip.sh"; then
    echo "$0: will source $dir/t/tap-planskip.sh"
    . "$dir/t/tap-planskip.sh"; exit "$?"
  fi
done
echo "$0: cannot find wrapped test 't/tap-planskip.sh'" >&2
exit '99'