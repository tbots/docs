#!/bin/bash
#
# Find which file declares the function. Search current directory by default.
#

source c.sh
debug=1

_dfile $1
arr_d files[@]
