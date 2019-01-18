#!/bin/bash

while getopts ":o:" OPT
do
	case $OPT in
		o)	
			# copy files specified by the `-o' option argument to DEP_HOST
			echo "OPTARG: $OPTARG"
			#scp $OPTARG root@$DEP_HOST:/root
			exit 0;;
	esac
done
