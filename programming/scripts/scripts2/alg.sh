#!/bin/bash

declare -A addr

conf=test.conf

# print address array
function print_addr() {
	
	m=0
	echo "addr len: ${#addr[@]} "
	while [ ${addr[$m]} ]
	do
		echo -e "[$m]\t${addr[$m]} : ${addr[$m,0]}"
		let $((m += 1))
	done
}
	
# read open bracket addresses
open=( `awk "/{/ {print NR}" $conf` )

# read close bracket addresses
close=( `awk "/}/ {print NR}" $conf` )

# print open array element
i=0
while [ ${open[$i]} ]
do
	echo "open[$i]: ${open[$i]}"
	let $((i += 1))
done

# print close array elements
i=0
while [ ${close[$i]} ]
do
	echo "close[$i]: ${close[$i]}"
	let $((i += 1))
done

let $(( lst = ${#open[@]} - 1 ))
echo "index of the last element within open: $lst"

addr[0]=${open[0]}
print_addr

i=1
n=0
while [ $i -le $lst ]
do
	echo "processing '${open[$i]}'"
	let $((i += 1))
done

echo "unsetting open[$((i-1))]"
unset open[$((i-1))]
open=( ${open[@]} )

echo "unsetting close[$n]"
unset close[$n]
close=( ${close[@]} )

# print open array element
i=0
while [ ${open[$i]} ]
do
	echo "open[$i]: ${open[$i]}"
	let $((i += 1))
done
