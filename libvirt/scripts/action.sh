#!/bin/bash
#
# Start/stop specific project.

test $# -eq 2 || \
	{ echo "Usage: `basename $0` stop|start|pause <FILE>";\
		exit 1;\
	}	# note no ';' 
source $2		# vms[] is set
for vm in ${vms[@]}; do
	virsh $1 $vm
done
