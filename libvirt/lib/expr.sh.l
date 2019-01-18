#!/bin/bash
#
# Library for modifiying expressions.
#

#
# Chain space separated values.
#
# abc='a b c'
# chain abc
#
# abc='\(a\|b\|c\)'
#
function chain(){
	eval $1="'`echo ${!1} | sed 's/^.*$/\\\(&\\\)/; s/ /\\\|/g'`'" 
}
