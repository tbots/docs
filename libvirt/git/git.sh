#!/bin/bash
# Git setup.
#
# Recognize a specific key and print related information.
#
# key=--global
# key=--system
# git config $key user.name
# git config $key user.mail
# git config $key core.editor
# git config --list
#

# Report an option on its init
echo -e "OPTIND:\t$OPTIND"
echo -e "OPTERR:\t$OPTERR"
echo -e "OPTARG:\t$OPTARG"

while getopts "nme" option
do
	case $option in
		
		# user.name  
		n) 
			echo -en "user.name\t"; git config user.name;;

		# user.mail
		m)
			echo -en "user.mail\t"; git config user.mail;;
			
		# core.editor
		e)
			echo -en "core.editor\t"; git config core.editor;;

		# unrecognized option
		\?)
			echo "Invalid option -$OPTARG" >&2; exit 1;;
	
	esac
done
