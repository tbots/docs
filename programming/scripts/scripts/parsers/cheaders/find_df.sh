#!/bin/bash
#
# get_df() wrapper script.
#

source c.sh
debug=1

get_df $1

echo "Declaration file for function $1 is $dfile"
