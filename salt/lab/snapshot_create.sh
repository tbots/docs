#!/bin/bash
#
# Create snapshot for all the vm's listed in a vms file.
cat vms | while read vm
do
	virsh destroy $vm
	virsh snapshot-create-as $vm 
done
