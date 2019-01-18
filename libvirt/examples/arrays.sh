#!/bin/bash

# declare array ARRAY
declare -a ARRAY

# print number of elements in the array
echo "number of elements in the array:"
echo -e "\${#ARRAY[@]}:\t${#ARRAY[@]}"			# -e used to interpret \t as escape character

# assign three elements to the array
ARRAY=( "one" "two" "three" )

# print all the array elements
echo "array elements:"
echo -e "\${ARRAY[@]}:\t${ARRAY[@]}"				# one two three

# print number of elements in the array again
echo -e "\${#ARRAY[@]}:\t${#ARRAY[@]}"		#		3

# retrieve first element of the array
el=$ARRAY

echo -e "first element:\n\$el:\t$el"			# 	one

# retrieve element by index; computers start count from 0
el=${ARRAY[0]}
echo -e "\$el:\t$el"				#		one

# getting all the elements of the array
elements=${ARRAY[@]}

echo "array elements:"
echo -e "\$elements:\t$elements"				#		one two three
