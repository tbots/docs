#!/bin/bash
#
### This is the upper level parsing.
#

LIBC=$HOME/src/glibc-2.24

#
# Find the location of all the include files.
#

# Handles the cas, when include directive is specified as a
# relative path (i.e. '#include <sys/mmap>').
function rel_path() {
	
	file=`basename $L`			# get the filename
	dir=${$L/\/$file/}			# strip filename portion from the path

	# find directories 
	for D in `find $LIBC -type d -name $L -print`
	do
		# search for files in this directories
		find $D -name $file -print
	done
}

# Assume space before and after a sharp
for L in `sed -n '/^ *# *include/ s/.*\("\|<\)\(.*\)\(>\|"\).*/\2/p' $1`; do
	if [[ $L =~ '/' ]]		# the include file contains slashes
	then
		rel_path "$L"
	else
		#find $LIBC -name $L -print
		find / -name $L -print
	fi
done
