#!/bin/bash
#
#	@ #  logical expressions
#
# Last element is file to be searched in.
#
# To do:
#
#		Accept several file names.

test -e ${!#} || { echo "error: \`${!#}' does not exist" >&2; exit 1; }

# loop till the examined element is not the last (searched file)
until [ "$1" == ${!#}  ]; do

	if [[ ! $1 =~ ^- ]] 
		then echo "error: not an option -- \`$1'" >&2
				 exit 1
		fi
	
	case "$1" in
		'-function_definition')		
			grep '^\s*\w\+\s\+\w\+(.*{' ${!#}
			;;

		*)
			echo "error: logical expression \`$1' is not defined" >&2
			exit 1;;
	esac	

	shift
done
