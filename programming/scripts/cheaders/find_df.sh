#!/bin/bash
#
# get_df() wrapper script.
#

test $1 || exit 1

source c.sh
debug=1

_dfile $1

echo "Declaration file for function $1 is $dfile"
