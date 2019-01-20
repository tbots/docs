#!/bin/bash
#
# Display only uncommented lines.

test -e $1 || { echo "Usage: `basename $0` FILE"; exit 1; }
sed 's/\/\s*\*[^*]*\*\s*\///g; /\/\s*\*/,/\*\s*\//d' $1 
