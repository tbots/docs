#!/bin/bash

variable1="a variable containing five words"
echo this is $variable1		# Executes echo with 7 arguments:
													# "This" "is" "a" "variable" "containing" "five" "words"

echo "this is $variable1"	# Executes command with 1 argument:
													# "This is a variable containing five words"

variable2=""							# Empty.

echo $variable2 $variable2 $variable2
													# No arguments, just new line.

echo "|$variable2|" "|$variable2|" "|$variable2|"
													# Three empty arguments.

echo "|$variable2 $variable2 $variable2|"
													# 1 argument (2 spaces).
