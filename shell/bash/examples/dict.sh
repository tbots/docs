#!/bin/bash

source opt.sh

function usage() {
	echo "Usage: `basename $0 .sh` WORD [TRANSLATION]..."
	echo "Print word translation. Word translations can be specified in comma-separated list."
	echo ""
	echo "Options:"
	echo "  -q, --game [GAMES]       run in a game mode number of GAMES"
	echo "  -d, --dictionary [FILE]   set or print current dictionary file; if word is specified "
	echo "                            dictionary file is used as temporary otherwise used permanently"
	echo "  -h                        print usage and exit"
	exit 0
}


test "$1" || usage		# print usage and exit if no argument specified

DICT=en
while [ "$1" ]; do
# parse command line parameters
	case "$1" in 
		-h|--help)	usage ;;
		-g[0-9]|--game) game=1 
							get_arg GAME_MAX ${@:1:2} 1		# required=1
							echo "GAME_MAX: $GAME_MAX" ;;
		-d|--dictionary)
							get_arg DICT ${@:1:2} 
							if [ -n "$arg" ]
							then
									dict=$arg			
									rw=1
								else	# argument was not passed
								#  only print current dictionary file used
									echo "Dictionary file:  $dict"      # see lib.sh for the default value
									exit 0
								fi
		  ;;
		*) echo "invalid option: \`$1'" >&2
				echo "Try \``basename $0 .sh` --help' for more information." >&2
		 ;;
	esac

	shift $count
	count=1		
done
