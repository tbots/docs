#!/bin/bash

function usage() {
	echo "--expression-step-track           uncomment file and expression steps"	
	exit "0"
}

if [ -z $1 ]; then
	usage
fi

while [ "$1" ]; do
	case $1 in 
		'--expression-step-track')
			# print file currently examined character and cursor position on each call to 
			# rcs()
			sed -i '/\/\/\s*exch/,/\/\/\s*crstat/ {
				s/\/\///;
			}' matches.c

			sed -i '/^\s*step/s/.*/\/\/\0/' matches.c			# comment step fuction call
			sed -i '/\/\/\s*\/* DEBUG/s/\/\///' matches.c			
			;;

		*)	usage
			;;
			
	esac
	shift
done
#			sed -i '/^\s*exch/,/^\s*crstat/ {
#						s/.*/\/\/\0/}' matches.c
#
