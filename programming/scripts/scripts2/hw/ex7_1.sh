#!/bin/bash
#
# accept input
#
# make script as much informative as possible

(( 1 && 1 ))				# Logical AND
echo $?	| sed 's/0/TRUE/; s/1/FALSE/'
