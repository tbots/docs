#!/bin/bash
#
# Dump function names from the shell script files.
file=$1
awk '/^\s*function\>/ {print $2 }' $file | tr -d "()"
