#!/bin/bash
# What OPTIND returns when parsing is finished?

while getopts "v" option
do
	case $option in 
		v)	echo -e "\$option:\t$option"
				echo -e "\$OPTIND:\t$OPTIND"
				echo -e "OPTARG:\t$OPTARG";;
		*)	echo -e "\$option:\t$option"
				echo -e "\$OPTIND:\t$OPTIND"
				echo -e "OPTARG:\t$OPTARG";;
	esac
done
