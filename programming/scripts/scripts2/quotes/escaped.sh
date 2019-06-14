#!/bin/bash
# escaped.sh: escapes characters

###########################################
### Some basic escaped-character usage. ###
###########################################

# Escaping a newline.
# -----------------------------------------

echo ""

echo "This will print
as two lines."
# This will print
# as two lines.

echo "This will print \
as one line."
# This will print as one line.

echo; echo

echo "====================="

echo "\v\v\v\v"			# Prints \v\v\v\v literally. 
echo -e "\v\v\v\v"	
