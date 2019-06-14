#!/bin/bash
#
# option parsing function routines
#
# the expected option parsing loop in the main
# script should be:
#
# for option; do
#		case $option in
#			 '-a')	action;;
#		esac
#		shift $count
#		count=1
#
#
# variables:		count		shift step
#
# 

argument_required=
count=1

#
# Set variable to an option argument
#
# usage: get_arg variable $1 $2 
#
# cases:
# 	get_arg VAR --opt value
# 	get_arg VAR -ovalue
# 	get_arg VAR -o value
#
function get_arg() {

	argument_required=$4

	if [[ $2 =~ ^-- ]]		# long option/ --opt value
	then

		arg=$3
	else									

		# try to strip a short option 
		arg=${2/${2:0:2}}		# -ovalue
		if [ ! $arg ]		
		then						# -o value
			arg=$3	
		fi
	fi

	if [[ ! $arg || $arg =~ ^- ]]		# was not set or set to the following option
	then
		if [ $argument_required ]
		then
				echo "argument required for the \`$2' option"
				exit 1
		fi
	else
		eval "$1=$arg"
		count=2
	fi
}
