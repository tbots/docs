#!/bin/bash
#
# An unitialized variable has a "null" value -- no assigned value at all (not zero!).
if [ -z "$unassigned" ]
then
	echo "\$unassigned is NULL."
fi		  # $unassigned is NULL.

# Using a variable before assigning a value to it may cause problems. It is nevertheless
# possible to perform arithmetic operations on an uninitialized variable.

echo "$uninitialized"			# (blank line)
let "uninitialized += 5"		# Add 5 to it.
echo "$uninitialized"			# 5 

# Conclusion:
# An uninitialized variable has no value,
# however it evaluates as 0 in an arithmetic operation.
