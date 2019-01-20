#!/bin/bash
#
# Nmap wrapper scripts library.
#

source expr.sh.l


#
# Print all ip range that was scanned.
#
function host_list_all(){
	out=`nmap -sL $1 | grep -o '\([0-9]\+\.\)\{3\}[0-9]\+'`
	if [ $2 ]
		then eval $2="'$out'"
		else echo "$out"
	fi
}

#
# Prints out resolved host names.
#
function host_list_res()
{
	out=`nmap -sL $1 | sed -n 's/.* \(\w\+\.\S\+\) ([0-9].*/\1/p'`
	if [ $2 ]
		then eval $2="'$out'"
		else echo "$out"
	fi
}

#
# Print all the scanned ip's along with resolved hosts names.
#
function host_list_res_all()
{
	out=`nmap -sL $1 | sed -n '/Nmap scan report for /s///p' | sed 's/\(.*\) (\(.*\))/\2\t\t\1/'`
	if [ $2 ]
	 	then eval $2="'$out'"
		else echo "$out"
	fi
}

#
# Print number of resolved hosts.
#
function host_num_res()
{
	out=`host_list_res $1 | wc -l`
	if [ $2 ]
		then eval $2="'$out'"
		else echo "$out"
	fi
}

#
# Prints number of the hosts that are up.
#
function host_num_up()
{
	out=`nmap -sP $1 | sed -n 's/.*(\([0-9]\+\) hosts up.*/\1/p'`
	if [ "$2" ]
		then eval $2="'$out'"
		else echo "$out"
	fi
}

#
# Print addresses and resolved host names for the hosts that are up.
#
function host_list_res_up(){
	out=`nmap -sn -R $1 | sed -n 's/Nmap scan report for //p' | sed 's/\(.*\) (\(.*\))/\2\t\t\1/'`
	if [ $2 ]
		then eval $2="'$out'"
		else echo "$out"
	fi
}

#
# Print addresses for the hosts that are up.
#
function host_list_up(){
	out=`nmap -sn $1 | grep -o '\([0-9]\+\.\)\{3\}[0-9]\+'`
	if [ $2 ]
		then eval $2="'$out'"
		else echo "$out"
	fi
}

#
# List hosts that are down.
#
function host_list_down(){
	host_list_up $1 up
	chain up
	host_list_all $1 | grep --invert-match --word-regexp $up
}

#
# List addresses along to resolved host names that are down.
#
function host_list_res_down(){
	host_list_up $1 up
	chain up
	host_list_res_all $1 | grep --invert-match --word-regexp $up
}
