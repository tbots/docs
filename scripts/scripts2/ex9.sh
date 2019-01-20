#!/bin/bash
# ex9.sh

# Variables: assignment and substitution

a=375
hello=$a
#   ^ ^
#------------------------------------------------------------------------
# No space permitted on either of = sign when initializing variables.
# What happens if there is a space?

# "VARIABLE =value"
#          ^
# Script tries to run "VARIABLE" command with one argument, "=value".

# "VARIABLE= value"
#
# Script tries to run "value" command with 
# environemntal variable "VARIABLE" set to "".
#------------------------------------------------------------------------

echo hello		# hello
# Not a variable reference, just the string "hello"...

echo $hello		# 375
#    ^			  This *is* a variable reference.

echo ${hello}	# 375
#                Likewise a variable reference, as above.

# Quoting . . .
echo "$hello"		# 375
echo "${hello}"	# 375

echo

hello="A B  C   D"
echo $hello			# A B C D
echo "$hello"		# A B  C   D
# =========================================
# Quoting a variable preserves whitespaces.
# =========================================

echo

echo '$hello'		# $hello
#	  ^      ^
# Variable referencing disabled (escaped) by single quotes,
# which causes the "$" to be interpreted literaly.

hello=			# Setting it to a a null value.
echo "\$hello (null value) = $hello"		# $hello (null value) =
# Note that setting a variable to a null value is not the same as
# unsetting it, although the end result is the same.

#------------------------------------------------------------------------

# It is permissible to set multiple valriables on the same line,
# if separated by white space.
# However, this may reduce legibility, and may not be portable.

var1=21 var2= var3=$V3
echo
echo "var1=$var1   var2=$var2   var3=$var3"

echo; echo

numbers="one two three"
#
other_numbers="1 2 3"
#               ^ ^
# If there is whitespace embedded withing a variable,
# then quotes are necessary.
# other_numbers=1 2 3				# Gives an error message.
echo "numbers = $numbers"
echo "other_numbers = $other_numbers"	# other_numbers = 1 2 3
# Escaping the whitespace also works.
mixed_bag=2\ ---\ Whatever
#           ^    ^ Space after escape (\).

echo "$mixed_bag"				# 2 --- Whatever

echo; echo

echo "uninitialized_variable = $uninitialized_variable"
# Uninitialized variable has a null value (no value at all!).
uninitialized_variable= 	# Declaring, but not initializing it --
									# same as setting it to a null value, as above.
echo "uninitialized_variable = $uninitialized_variable"
									# It still has a null value.

uninitialized_variable=23		# Set it.
unset uninitialized_variable	# Unset it.
echo "uninitialized_variable = $uninitialized_variable"
										# uninitialized_variable=
										# It still has a null value.

echo

exit 0
