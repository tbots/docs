#!/bin/bash
#

E_WORNGARGS=85			# The value provided is not in binary format.

case "$1" in
	""			 ) echo "Nothing to convert.";;
	*[!0-1]* ) echo "'$1' not a binary number.";
						 exit $E_WRONGARGS;;
	*				 ) echo -e "$1\t$(( 2#$1 ))";;
esac
