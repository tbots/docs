#!/bin/bash

echo -e "[DEBUG] Before the loop:\n"
echo -e "\tOPTIND: ${!OPTIND} 		$OPTIND"
echo -e "\tOPTERR: $OPTERR"
echo -e "\tOPTARG: $OPTARG\n"

until [ -z ${!OPTIND} ]				# until command line argument is not empty
do
	echo -e "[DEBUG] Inside the loop:\n"
	echo -e "\tOPTIND: ${!OPTIND} $OPTIND"
	echo -e "\tOPTARG: $OPTARG\n"

	while getopts "v" opt
	do
		case "$opt" in
			v)
				let "verbose += 1"		# set verbose flag to 1
				echo -e "[DEBUG] When the option recognized:\n"
				echo -e "\tOPTIND: ${!OPTIND} 		$OPTIND"
				echo -e "\tOPTARG: $OPTARG\n"
				;;
			\?)
				exit 1;;
		esac
	done

	echo -e "[DEBUG] Outside the loop:\n"
	echo -e "\tOPTIND: ${!OPTIND}\t[$OPTIND]"
	echo -e "\tOPTARG: $OPTARG\n"

	if [ -n ${!OPTIND} ]
	then
		USERS=$USERS\ $!{OPTIND}
	fi

	let "OPTIND += 1"
done
