#!/bin/bash
#
# Change configuration file values.
#
# Expected format is VARIABLE="VALUE"

function usage()
{ 
	echo "Usage: conf_vars.sh [VAR [VAL]] FILE";
	exit 0;
}

function print_vars() {

	# test args
	case $# in
		1)	file=$1;;
		2)	var=$1; file=$2;;

		*) 	echo "Usage: print_vars [VAR] FILE";
			exit 1;;
	esac

	# search for all the variables by default
	test $var || var='.*'
	
	sed --silent "/^$var/p" $file
}


function change_var() {
	
	# test args
	test $# -eq 3 || \
	{
		echo "Usage: change_var VAR VALUE FILE";
		exit 1;
	}
		
	variable=$1; value=$2; file=$3

	# rewrite variable value
	sudo sed --in-place=.bak "/$variable/ s/\([=\"]\)[a-zA-Z_]\+/\1$value/" $file

	# delete file on successfull rewrite
	if [ $? -eq 0 ]; then
		sudo rm $file.bak
	fi
}

case $# in
	1|2)	print_vars $1 $2   ;;
	3)	  change_var $1 $2 $3;;
	*)	  usage;;
esac
