#!/bin/bash
#
# Usage: apt.sh [OPTIONS]... <package_name> 
#
# Install, remove or purge packages. 
# With -v shows available package versions.
# With -a shows all packages that contains *package_name*
#

# files to be sourced
lib=$HOME/admin/scripts/lib

# source files
source $lib

function usage() {
	echo "`basename $0`: [OPTIONS]... <package_name>"
	echo "Install, remove or purge specific versions of the package."
	echo "All available versions are displayed. The action applied to the version"
	echo "corresponding to the current selection."
	echo "   -l          seach global; treat package name as a shell pattern *package_name*"
	echo "   -i          install package"
	echo "   -r          remove package"
	echo "   -h          print this help and exit"
	exit 0
}

action='install'		# default action
if [ -z "$1" ]; then usage; fi
while [ "$1" ]; do
	case $1 in 
		'-i') ;;		# act='install'
		'-r') act='remove';;
		'-l') let $((search_global+=1));;
		'-h') usage;;
		-*) echo "invalid option \`$1'" >&2; usage;;
		[a-z]*) pack_name=$1
	esac
	shift
done
		

# options parsed, run further only if root
if_not_root

search_expression=$pack_name
if [ $search_global ] 
	then search_expression=*$pack_name*
fi
echo "$search_expression"
cmd="apt list $search_expression -a --installed"

if [ $action == 'install' ]; then
	cmd=${cmd/ --installed/}
fi
echo "cmd: $cmd"

for v in `$cmd 2> /dev/null | sed -n "/$pack_name/ s/\(.*\)\/.*\s\([0-9]\S*\).*/\1=\2/p"` 

do
	ver[$i]=$v
	let $((i+=1))
done

i=0
for v in ${ver[@]}; do
	echo -n "$((i+=1)):   "
	echo $v | sed 's/\(\w.*\)=\(\S*\)/\2\t\1/'
done

echo -n "Choose selection:   "; read choice
while [[ -z "$choice" ||\
	 ("$choice" -le 0 || "$choice" -gt ${#ver[@]}) ||\
	 $choice =~ [a-zA-Z] ]]

do 
echo -n "Choose selection:   "; read choice; done

pack_name=${ver[$((choice-=1))]}
echo "pack_name: $pack_name"
echo "action:    $action"

apt $action $pack_name			# run the command
