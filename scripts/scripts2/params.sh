#!/bin/bash

for p in $*
do
	let "$(( n += 1 ))"
	echo -e "#$n:\t$p"
done
