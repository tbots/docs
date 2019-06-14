#!/bin/bash
#
# Learn the hash numbers from the file.

if [ -n "$1" ]
then
	echo -e "Argument read: $1"
fi

let "MAX=(( $1 * $1 ))"
echo "Maximum value produced for $1: $MAX"

NUM=0

while [ $NUM -le $MAX ]
do
	echo -e "\$NUM:\t$NUM"

	# Magic
	if [ $NUM -eq 0 ]
	then
		echo -e "$NUM\tzero"
	let "NUM += 1"
done
