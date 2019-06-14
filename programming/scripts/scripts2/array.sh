#!/bin/bash

function array_print() {
	echo "ARRAY length: ${#ARRAY[@]}"
	i=0
	n=${#ARRAY[@]}		# length of ARRAY
	while [ $n -gt 0 ]
	do
		echo "ARRAY[$i]:   ${ARRAY[$i]}"
		if [ ${ARRAY[$i]} ]
		then	
			let $((n -= 1))
		fi
		let $((i += 1))
	done
}

i=0
for m in 1 2 3
do
	ARRAY[$i]=$m
	let $((i += 1))
done

array_print

#ARRAY+=(2 3 4)
ARRAY+=([4]=4 [5]=5)
array_print
