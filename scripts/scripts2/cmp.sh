#!/bin/bash
#
# Display the comparison operators by type.
# Accept command line options related to the language.

CMP=~/lng/cmp		# comparison table

if [ -n "$1" ]		# not empty
then
	op=$1		# comparison operator
	grep $op $CMP		# backtrics backtrics
else
	echo "No pattern to search. Displaying the table..."
	# Desired format:		operator (type)
	cat $CMP
fi
