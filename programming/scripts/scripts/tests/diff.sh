#!/bin/bash

function change_timer(){
	echo -en "\r\e[K"
	echo -n `date +%M:%S`
}

sec=$(date +%S)
change_timer

while [ "1" ]; do
	# if second is changed
	next_sec=`date +%S`
	if [ "$next_sec" -gt "$sec" || "$sec" -eq 59 ]
	then 
		change_timer
		sec=$next_sec
	fi
done
