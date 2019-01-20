#!/bin/bash
#
# Compile C and GAS source files.
#
# ISSUE:	Process all command line arguments as a source files.
#
# Add a command line option to create only object files.
#

HELL=/dev/null 		# No return directory.
EXIT_SUCCESS=0		# Successful return status code.

if [ -n "$1" ]
# src file(s) specified as command line argument.
then
	cf=${1}
	# Process them instead of reading files from current directory.
else
	# Read src file(s) from the current directory.
	cf=`ls -1 *.c 2> ${HELL}`
fi

if [ -n "$cf" ]
# Compile .c (C source) files.
then
	for src in $cf
	do
		exe=`echo $src | cut -d\. -f1`
		gcc -Wall -g -O2 -o ${exe} ${src}
	done
fi

if [ -n "$af" ]
then
	for src in ${af}
	do
		obj=`basename ${src} .s`.o
		as -o ${obj} ${src}
		if [ "$?" -eq "$EXIT_SUCCESS" ]
		then
			exe=`basename ${obj} .o`
			ld -o ${exe} ${obj};
		fi
	done
fi

exit
