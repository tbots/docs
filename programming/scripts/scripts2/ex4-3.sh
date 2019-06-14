#!/bin/bash

a=23			# Simple case
echo $a		#
b=$a

echo $b

# Now, getting a little bit fancier (command substitution).

a=`echo Hello1`		# Assigning result of 'echo' command to 'a' ...
# Note that including an exclamation mark (!) within a
# command susbstitution construct will not work from the command-line,
# since this triggers the Bash "history mechanism."
# Inside a script, however, the history functions are disabled by default.

a=`ls -l`		# Assigning result of 'ls -l' command to 'a'
echo $a			# Unquoted, however, it removes tabs and newlines.
echo
echo "$a"		# The quoted variable preserves whitespace.

exit 0
