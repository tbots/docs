#!/bin/bash

function print_arr() {
	
	echo "${1[0]}"
#	arr=$1
#	arr=( ${!arr} )
#
#	echo "$1 len: ${#arr[@]}"
#	i=0
#	while [ ${arr[$i]} ]
#	do
#		echo "[$i]:  ${arr[$i]}"
#		let $((i += 1))
#	done
}

open=(10 20)
echo ${open[@]}
unset open[1]

open=( ${open[@]} )
