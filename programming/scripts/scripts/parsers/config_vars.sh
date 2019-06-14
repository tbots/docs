#!/bin/bash
#
# Change configuration file values.
#
# Expected format is VARIABLE="VALUE"

test $# -ne 0 || { echo "Usage: conf_vars.sh <variable> <value> <file>"; exit 0; }

variable=$1; value=$2; file=$3

sudo sed --in-place=.bak "/$variable/ s/\([=\"]\)[a-zA-Z_]\+/\1$value/" $file &&\
# delete backup file on success
rm --verbose $file.bak
