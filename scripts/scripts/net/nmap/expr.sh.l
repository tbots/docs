#!/bin/bash
#
# Library for modifiying expressions.
#

#
# Chain space separated values.
#
function chain(){
	eval $1="'`echo ${!1} | sed -n 's/^.*$/\\\(&\\\)/; s/ /\\\|/gp'`'" 
}
