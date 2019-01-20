#!/bin/bash
#
# highlight the match parts within string
# -s
#			speify a string for substitution

if [ $# -lt 2 ]; then
	echo "Usage: `basename $0` pattern [replacement] filename"
	exit 1
fi

# initialize filename; expected to be the last argument on the commnand line
file=${!#}

# 
pattern=$1

until [ -z ${!OPTIND} ]
do
	while getopts ":s:e:" opt
	do
		case $opt in
			s)	rep=$OPTARG;;
			e)  pattern=$OPTARG;;
		esac
		if [ $OPTIND -gt 1 ]
		then
			shift $((OPTIND-1)); OPTIND=1
		else
			shift
		fi
	done

done
	
#
# DEBUG
#
echo -e "[DEBUG] pattern:\t$pattern"
echo -e "[DEBUG] file:\t$file"
echo -e "[DEBUG] rep:\t$rep"

if [ -z $pattern ]
then
	pattern=$1
fi

#A="`echo|tr '\012' '\001'`"
if [ -z $rep ]
then
	sed -e "s/\($pattern\)/|\1|/" $file
else
	sed -e "s/\($pattern\)/|$rep|/" $file
fi
