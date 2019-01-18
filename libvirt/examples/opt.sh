#!/bin/bash
#
# If option accepts an argument next argument should not start from '-' or be empty. Bellow is an example
# of the check for the non option argument.
#

test $# -eq 0 && { echo -e "Usage: `basename $0` -o <filename>"; exit 0; }
while [ "$1" ]; do
	case  "$1" in
		-o)    # expected filename argument
								if [[ -z "$2" || "$2" =~ ^\ *\- ]]
								then
									echo "error: \`-o' expects an argument"
									exit 1
								else
									filename=$2; shift
								fi
								 ;;

		*)					echo "error: unknown option \`$1'"; exit 1
								 ;;
	esac
	shift
done
