#!/bin/bash
#
# Loop.

declare -a arr=( 5 )

echo "arr[0]: ${arr[0]}"
for((i=0; ${arr[$i]} < 25; i++)); 
do
echo "$i"
done
