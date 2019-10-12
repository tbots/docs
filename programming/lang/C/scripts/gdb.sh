#!/bin/bash
#
# Change gdb syntax for the current user.

gdbinit=$HOME/.gdbinit

function usage() {
	echo "Usage: `basename $0` [set {att|intel}|-h]"
	echo "Change gdb(1) disassembler syntax or if set argument omitted, display"
	echo "current settings. With no options display this help and exit."
	exit 0
}

function invalid() {
	echo "Usage: `basename $0` [set {att|intel}|-h]" >&2
	exit 1
}

( test $# -eq 0 || test "$1" = "-h" ) && usage
test "$1" = "set" || invalid
shift

if [ "$1" ]
then
	case $1 in 
		att|at ) 			;;			# AT&T syntax style
		intel  ) 			;;			# Intel syntax style
	
		*)	invalid		;;
	esac
	test -e $gdbinit || touch $gdbinit			# Create file if not exist.
	sed -i "/\(set disas[^ ]*\).*/s//\1 $1/" $gdbinit
else
	sed -n 's/.*\s\(\w*\)\s*$/Current syntax:   \1/p' $gdbinit
fi
		
