#!/bin/bash # # Not efficient

declare -a machines=( `virsh list --name 2> /dev/null` ) 
declare -a processes=( $(ps aux | grep -E -w `echo ${machines[@]} | sed 's/ \(\w\)/|\1/g'` | grep -v grep | awk '{print $2}') ) 

for proc in ${processes[@]}
do
	echo "proc: $proc"
done

select machine in ${machines[@]}
do
	if [[ $REPLY -le ${#machines[@]} ]]
	then
		PROC_ID=${processes[(( REPLY - 1 ))]}
		break
	fi
done
	
cmdline=/proc/${PROC_ID}/cmdline
cat $cmdline | tr '\000' ' ' | grep --only-matching ' \-\S\+\(\s[^-]\S*\)*'
