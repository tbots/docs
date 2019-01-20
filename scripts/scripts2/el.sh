#!/bin/bash
#
# Print all the elements on the command line.
echo -e "Elements count:\t$#"
echo -e "\$OPTIND:\t$OPTIND"

until [ -z ${!OPTIND} ]
do
	echo -e "#$OPTIND:\t${!OPTIND}"
	let $(( OPTIND += 1))
done
