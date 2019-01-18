#!/bin/bash
#
# Change password policy test.

source lib

if [[ $1 =~ [^01] ]]
then
		echo "Usage: ch_pol [0|1]" 
		exit 0
fi

ch_pol $1
