#!/bin/bash 
#
# Display prompt for the environments to be destroyed.
#
 

# Populate vms[] with the machine names
function set_vms() {
	vms=( `virsh list --name 2> /dev/null` )
	if [[ ! $vms ]]; then
		echo "no environment found"
		exit 1
	fi
}
	

# Populate processes[] with pid of the running machines
#
function set_proc() {
	declare -a vms; set_vms
	processes=( $( ps aux | grep --extended-regexp --word-regexp `echo ${vms[@]} | tr '\n' ' ' | sed 's/ \(\w\)/|\1/g'` | grep -v grep | awk '{print $2}' ) ) 
		 									# domain[[|domain]...]
}

# Print out all the environment path
#
function set_vm_path() {
	declare -a processes	# qemu processes array
	set_proc; for pid in ${processes[@]}
	do
		cmdline=/proc/${pid}/cmdline	# cmdline file name
	        vmpath+=( `cat $cmdline | tr '\000' ' ' | sed -n 's/.*-drive file=\([^,]\+\).*/\1/p'` )
	done
}



declare -a vmpath; set_vm_path

# Prepare select loop.
PS3="Please choose the environment: "; select vm_path in ${vmpath[@]} 
do 
	if [ $vm_path ]
	 then
	   break
	 fi
done

echo "Choice: $vm_path"
