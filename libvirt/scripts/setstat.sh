#!/bin/bash


vms=( salt-minion-0 salt-minion-1 salt-minion-2 )
host=20

for vm in ${vms[@]}
do
	info=( $(	sudo virsh domiflist $vm | sed '/^$/d' | tail -n1 ) )
	mac=${info[4]}
	cmd="sudo virsh net-update default add ip-dhcp-host --xml \"<host mac='$mac' name='$vm' ip='192.168.122.$host' />\" --current"
	echo "executing $cmd"
	eval $cmd
	((host++))
done

