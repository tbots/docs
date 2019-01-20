#!/bin/bash 
#
# Display path to the running MTE directory. Usefull for passing to destroy_env.sh script. 
# Author: Oleg Sergiyuk
#

declare -a machines=( `virsh list --name 2> /dev/null` ) 
declare -a processes=( $(ps aux | grep -E -w `echo ${machines[@]} | sed 's/ \(\w\)/|\1/g'` | grep -v grep | awk '{print $2}') ) 

function dump_env() {
	for PROC_ID in ${processes[@]}
	do
		cmdline=/proc/${PROC_ID}/cmdline
	        echo `cat $cmdline | tr '\000' ' '  | sed -n 's/.*-drive file=\([^,]\+\).*/\1/p' | sed 's/statedir.*//'`
	done
}

dump_env | uniq
