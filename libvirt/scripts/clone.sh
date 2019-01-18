#!/bin/bash
#
# Improve:
#
#		1. Update network configuration to be static for the already existent machines

template=$1; target=$2

#delete
target=$1

mac=mac.sh
mac=52:54:00:b2:fe:19
#sudo virt-clone -o $template -n $target --mac `cat mac` -f /var/lib/libvirt/images/$target.img
#add name
#sudo virt-sysprep -d$target --hostname $target 

# get the network
# sudo virsh net-update default add ip-dhcp-host --xml "<host ip='192.168.122.10' mac='$mac' name='$target' />" --config
# sudo virsh net-destroy default
# sudo virsh net-start 

grep -q $target /etc/hosts || sed -i.bak "$ a \ 192.168.122.10		$target" /etc/hosts
#sudo virsh start $target
ssh-copy-id costumer@$target
