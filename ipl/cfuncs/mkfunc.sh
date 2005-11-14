#!/bin/sh
#
#  mkfunc libname file.o ...
#
#  looks at the corresponding C files and generates an Icon procedure
#  corresponding to each C function header that matches the pattern below.
#
#  If a function name begins with "icon_", those characters are removed
#  to form the procedure name.  Otherwise, the name is copied verbatim.

LIB=${1?"usage: $0 libname obj..."}
shift

cat <<ENDHDR
############################################################################
#
#	File:     cfunc.icn
#
#	Subject:  Procedures implemented in C
#
#	Author:   Gregg M. Townsend
#
#	Date:     June 8, 2001
#
############################################################################
#
#     These Icon procedures transparently load and execute functions
#  implemented in C.  Each procedure is a simple stub.  The first call
#  to a stub causes it to replace itself with the corresponding
#  dynamically loaded C function, after which the C function processes
#  the arguments and returns a result (or fails).  Subsequent calls
#  go straight to the C function without involving the Icon stub.
#
#     C functions are loaded from a file "$LIB" that is found by
#  searching \$FPATH.  The default \$FPATH is set by iconx to include
#  this library.
#
############################################################################
#
#  Requires:  Dynamic loading
#
############################################################################

#  DO NOT EDIT THIS FILE DIRECTLY.
#  It was created mechanically by the shell file "$0".
#  Edit that instead.

link io

\$define LIB "$LIB"
ENDHDR

LC_ALL=POSIX
export LC_ALL

for i
do
   FNAME=`basename $i .o`
   echo ""
   echo "# $FNAME.c:"
   sed '
s/	/ /g
s/^int  *//
/^[a-z][a-z0-9_]* *(.*argc.*argv.*).*\/\*:.*\*\//!d
s/\([a-z0-9_]*\).*)\(.*\)$/\1(a[])\2@   return(\1:=pathload(LIB,"\1"))!a;end/
s/^[a-z]/procedure &/
s/\([^"]\)icon_/\1/g
s/)[ 	]*\/\*\(.*\)\*\/.*@/)      		#\1@/
   ' $FNAME.c | tr '@' '\012'
done

echo ""
echo "#---"
