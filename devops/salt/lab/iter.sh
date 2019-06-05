cat vms | while read vm
do
	virsh start $vm
done
