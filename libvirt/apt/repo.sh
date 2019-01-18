#!/bin/bash
#
# /etc/apt/source.list parser
#

src=/etc/apt/sources.list			# used repositories

function usage() {
	echo "Usage: `basename $0` [OPTIONS]..."
	echo "Retrieve different piece of information from the repository files. If no option"
	echo "is specified, list all the servers used."
	echo ""
	echo "Mandatory arguments to long options, are mandatory for short options too."
	echo "  -l, --list           list all the servers"
	echo "  -h, --help           display this help and exit"
}

function opterr() {		# invalid option
	echo "`basename $0 .sh`: invalid option \`$1'" >&2
	echo "Try \``basename $0` --help' for more information." >&2
	exit 1
}
function list_servers() {			# print used repositories
	sed -n '/^\s*deb\S*\s\+\(.*\)/s//\1/p' $src
}
	
if [ $# -eq 0 ]; then 		# default action is print all the servers
	list_servers
fi	

while [ "$1" ]; do
	case $1 in 
		'-l')		list_servers;;
		'-h')   usage;;
		*		)		opterr "$1";;
	esac
	shift		# process next element here
done
