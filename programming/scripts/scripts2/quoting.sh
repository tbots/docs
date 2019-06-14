#!/bin/bash
#
# An argument enclosed in double quotes presents itself as a single word, even if it contains
# whitespace separators.

list="one two three"

for a in $list			# Splits the variable in parts at whitespaces.
do
	echo "$a"
done
# one
# two
# three

echo "---"

for a in "$list"			# Splits the variable in parts at whitespaces.
do
	echo "$a"
done
# one two three
