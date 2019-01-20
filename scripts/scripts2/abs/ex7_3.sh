#!/bin/bash

echo

echo "Testing \"0\""
if [ 0 ]						# zero
then
	echo "0 is true."
else								# Or else ...
	echo "0 is false."
fi									# 0 is true

echo

echo "Testing \"1\""
if [ 1 ]						# one
then
	echo "1 is true."
else
	echo "1 is false."
fi

echo 

echo "Testing \"-1\""
if [ -1 ]						# one
then
	echo "-1 is true."
else
	echo "-1 is false."
fi

echo 

echo "Testing \"NULL\""
if [ ]				# NULL (empty condition)
then
	echo "NULL is true."
else
	echo "NULL is false."
fi						# NULL is false.

echo

echo "Testing \"xyz\""
if [ xyz ]		# string
then
	echo "Random string is true."
else
	echo "Random string is false."
fi						# Random string is true.

echo 

echo "Testing \"xyz\""
if [ $xyz ]		# Tests if $xyz is null, but...
							# it's only an unitialized variable.

	then echo "Uninitialized variable is true."
	else echo "Uninitialized variable is false."
fi

echo 

echo "Testing \"-n \$xyz\""
if [ -n "$xyz" ]			# More pedantically correct.
	then echo "Uninitialized variable is true."
	else echo "Uninitialized variable is false."
fi

echo

xyz=					# Initialized, but set to null value

echo "Testing \"-n \$xyz\""
if [ -n "$xyz" ]			# More pedantically correct.
	then echo "Null variable is true."
	else echo "Null variable is false."
fi

echo

# When is "false" true?

echo "Testing \"false\""
if [ "false" ]				# It seems that "false" is just a string ...
then
	echo "\"false\" is true."
else
	echo "\"false\" is false"
fi

echo "Testing true"
if [ $true ]				# It seems that "false" is just a string ...
then
	echo "$true is true"
else
	echo "$true is false"
fi
