#!/bin/bash
#
# Seach for different types of data within file.
#
# Filenames.

[ -e "$1" ] || { echo "file name not exist" >&2; exit 1; }

grep -o '\(/[-a-z.,]\+\/\?\)\+' $1
