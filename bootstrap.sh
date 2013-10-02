#! /bin/sh -
#  This is not a starconf component bootstrap file; it should be maintained
#  as a copy of buildsupport/starconf/bootstrap.buildsupport:
#   $Source$
#   $Revision: 14708 $
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Don't ignore failures.
set -e

# Set program basename.
me=`echo "$0" | sed 's,^.*/,,'`

# Let user choose which version of autoconf, autom4te and perl to use.
: ${AUTOCONF=autoconf}
export AUTOCONF  # might be used by aclocal and/or automake
: ${AUTOM4TE=autom4te}
export AUTOM4TE  # ditto
: ${PERL=perl}

# Variables to substitute.
VERSION=`sed -ne '/AC_INIT/s/^[^[]*\[[^[]*\[\([^]]*\)\].*$/\1/p' configure.ac`
PACKAGE=automake
datadir=.
PERL_THREADS=0
# This should be automatically updated by the 'update-copyright'
# rule of our Makefile.
RELEASE_YEAR=2012

# Override SHELL.  This is required on DJGPP so that Perl's system()
# uses bash, not COMMAND.COM which doesn't quote arguments properly.
# It's not used otherwise.
if test -n "$DJDIR"; then
  BOOTSTRAP_SHELL=/dev/env/DJDIR/bin/bash.exe
else
  BOOTSTRAP_SHELL=/bin/sh
fi

# Read the rule for calculating APIVERSION and execute it.
apiver_cmd=`sed -ne 's/\[\[/[/g;s/\]\]/]/g;/^APIVERSION=/p' configure.ac`
eval "$apiver_cmd"

# Sanity checks.
if test -z "$VERSION"; then
  echo "$me: cannot find VERSION" >&2
  exit 1
fi

if test -z "$APIVERSION"; then
  echo "$me: cannot find APIVERSION" >&2
  exit 1
fi

# Make a dummy versioned directory for aclocal.
rm -rf aclocal-$APIVERSION
mkdir aclocal-$APIVERSION
if test -d automake-$APIVERSION; then
  find automake-$APIVERSION -exec chmod u+wx '{}' ';'
fi
rm -rf automake-$APIVERSION
# Can't use "ln -s lib automake-$APIVERSION", that would create a
# lib.exe stub under DJGPP 2.03.
mkdir automake-$APIVERSION
cp -rf lib/* automake-$APIVERSION

dosubst ()
{
  rm -f $2
  in=`echo $1 | sed 's,^.*/,,'`
  sed -e "s%@APIVERSION@%$APIVERSION%g" \
      -e "s%@PACKAGE@%$PACKAGE%g" \
      -e "s%@PERL@%$PERL%g" \
      -e "s%@PERL_THREADS@%$PERL_THREADS%g" \
      -e "s%@SHELL@%$BOOTSTRAP_SHELL%g" \
      -e "s%@VERSION@%$VERSION%g" \
      -e "s%@datadir@%$datadir%g" \
      -e "s%@RELEASE_YEAR@%$RELEASE_YEAR%g" \
      -e "s%@configure_input@%Generated from $in; do not edit by hand.%g" \
      $1 > $2
  chmod a-w $2
}

# Create temporary replacement for lib/Automake/Config.pm.
dosubst automake-$APIVERSION/Automake/Config.in \
        automake-$APIVERSION/Automake/Config.pm

# Create temporary replacement for aclocal.
dosubst aclocal.in aclocal.tmp

# Overwrite amversion.m4.
dosubst m4/amversion.in m4/amversion.m4

# Create temporary replacement for automake.
dosubst automake.in automake.tmp

# Create required makefile snippets.
$PERL ./gen-testsuite-part > t/testsuite-part.tmp
chmod a-w t/testsuite-part.tmp
mv -f t/testsuite-part.tmp t/testsuite-part.am

# Run the autotools.
# Use '-I' here so that our own *.m4 files in m4/ gets included,
# not copied, in aclocal.m4.
$PERL ./aclocal.tmp -I m4 --automake-acdir m4 --system-acdir m4/acdir
$AUTOCONF
$PERL ./automake.tmp

# Remove temporary files and directories.
rm -rf aclocal-$APIVERSION automake-$APIVERSION
rm -f aclocal.tmp automake.tmp
