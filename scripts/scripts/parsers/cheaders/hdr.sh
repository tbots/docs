#!/bin/bash
#
# Edit C source files with the required include statements. Create header file 
# for the function definitions.
#
# HEADER   default header file name
#


source c.sh

declare -a headers
declare -a functions


function usage() {
	echo "Usage: `basename $0` [OPTION]... FILE..."
	echo "Process function calls found in a C source file."
	echo ""
	echo "  -i, --write-include          write include statements and header file"
	echo "  -H, --header HEADER          header file name"
	echo "  -c, --create-header-file     create header file for the function definitions"
	echo "  -r, --recursive              process files recursively"
	echo "  -s, --strict                 always assure that it is a header for the local function call"
	echo "  -l, --list all|local|system  list function calls"
	echo "  -p, --keep                   keep man page"
	echo "  -d, --debug                  display debug information"
	exit 1
}


while [ $1 ] 
do
	case "$1" in

		-l*|--list)
				get_arg call $1 $2

				case $call in 
					all|local|system) 
						FN_ARGS=--$call
					;;

					*)			 echo "wrong call specification, should be one of all, local, or system"
									 exit 1;;
				esac
		;;

		-c|--create-header)
				action 'header_wr'
		;;

		-i|--write-include)
				action='editc'			
		;;

		-r|--recursive)
				((recursive++))
		;;

		-s|--strict)
				((strict++))
		;;

		-p|--keep)	# do not remove man page
				((keep++)) 					
		;;

		-H*|--header)
				# set header file name

				get_arg HEADER $1 $2 1
		;;

		-d|--debug) 
				# set debug flag
				((debug++)) 				

				# set debug flag for the commands execution
				CMD_ARGS="$CMD_ARGS"\ --verbose 			
		;;

		-*) # invalid option
				# print usage and exit 
				usage				  			;; 

				# treat all other arguments as the source files
		 *)	 files+=( $1 )		;;

	esac
	shift $count; count=1		# reset count
done
			
test $files  || { usage; }
test $action || { usage; }

if [[ $strict || $action == 'header_wr' ]]
then
		test $HEADER || usage 
fi

declare -a functions


# debug
if [ $debug ]
then	
	echo "running with '$CMD_ARGS' flag for the commands"
	echo "action: $action"
	echo -e "header: $HEADER\n"
fi 
# debug


while [ ${files[$i]} ]
do

	file=${files[$i]}

	# debug 
	if [ $debug ]
	then 
		echo "*** in hdr() ***"
		echo "processing file '$file'"
	fi
	
	# Run action
	eval $action

	((i++))
done
