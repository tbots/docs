#!/bin/bash
#
# Where do I backup my files?
# On each exit from the script backup updated file.
#
# Prompt for a name of a program if a dependencies a related
# to somewhat king of program
#
# echo "Are dependencies related to any package?"
FILE=~/.pkg
echo "Enter a package names to store separated by spaces:"
read PKG

#echo "$PKG"
echo $PKG | sed -e 's/ /\n/g' >> $FILE
