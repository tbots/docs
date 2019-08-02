#!/bin/bash
#
# Initialization in the loop example.
#echo $j++

while [ $((++j)) ]
do
	echo "$j"
	if [ $j -eq 10 ]
	then
		break
	fi
done

j=1
while [ $j -ne 10 ]
do
	echo "$j"
	((j++))
done
