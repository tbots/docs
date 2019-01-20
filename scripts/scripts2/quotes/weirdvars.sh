#!/bin/bash
# weirdvars.sh:	Echoing weird variables.

echo

var="'(]\\{}\$\""
echo $var					# '(]\{}$"
echo "$var"				# '(]\{}$"		Doesn't make a difference.

echo

IFS='\'
echo $var					# '(] {}$"		\ converted to space. Why?
echo "$var"				# '(]\{}$"		

echo

var2="\\\\\""
echo $var2				# 	"
echo "$var2"			#	\\"
echo
# But ... var2="\\\\"" is illegal. Why?
var3='\\\\'
echo "$var3"			# \\\\
# Strong quoting works, though.

# ************************************************************** #
# As the first example above shows, nesting quotes is permitted.

echo "$(echo '"')"			# "
# 	 ^					 ^

# At times this comes in useful.

var1="Two bits"
echo "\$var1 = "$var1""	# $var1 = Two bits
#		 ^								^

# Or, as Chris Hiestand points out ...

if [[ "$(du "$My_File1")" -gt "$(du "My_File2")" ]]
#			^									^			^								 ^
then
	...
fi
# ************************************************************** #
# Single quotes ('') operate similarly to double quotes, but do not permit referencing variables, since the special
# meaning of $ is turned off. Within single quotes, every special character except ' gets interpreted literally.
# Consider single quotes ("full quoting") to be stricter method of quoting that double quotes ("partial quoting").
