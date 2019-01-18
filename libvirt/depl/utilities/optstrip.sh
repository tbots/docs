#!/bin/bash
#

if [ $# -eq 0 ]
then
	echo "Test option argument striping."
	exit
fi

if [[ $* =~ ^(.+ +)*-l( +.+)*$ ]]
then
	echo "option: -l"
	echo $* | sed 's/.*-l *\([^ ]\+\).*$/\1/'
fi
