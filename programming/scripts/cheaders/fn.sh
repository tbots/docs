#!/bin/bash
#
# Find all the functions called. functions[] holds all the function calls found.
#

source c.sh

function usage() {
	echo "Usage: $0 [OPTIONS]... FILE..."
	echo "Print out all, local or system function names called"
	echo "in the C source file(s)." 
	echo ""
	echo "  -l, --local           local function calls"
	echo "  -s, --system          system function calls"
	exit 1
}

call=all
for arg; do
	case $arg in
		-*) call=$arg		  ;;
		 *)	files+=( $arg )  ;;
	esac
done

for file in ${files[@]}
do
	fnc $call
	echo "$file"
	echo "---"
	arr_d functions[@]
	if [ ${#files[@]} -gt 1 ]
	then
		echo ""
	fi
done
