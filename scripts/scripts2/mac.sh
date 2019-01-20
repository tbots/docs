#!/bin/bash

ifconfig eth0 | awk '/ether/ {print $2}'


nfig eth0 | awk '/ether/ {print $2}'`
cmac=`awk -F= '/HW/ {print $2}' /etc/sysconfig/network-scripts/ifcfg-eth0`

echo -e "mac:\t$mac"
echo -e "cmac:\t$cmac"

if [ $mac != $cmac ]
then
	echo "writing correct MAC address"
		sed -i "/HW/s/\(HWADDR=\).*/\1$mac/" /etc/sysconfig/network-scripts/ifcfg-eth0
		fi

# find out public ip address
ip addr show eth0 | grep inet | awk '{print $2;}' | sed 's/\/.*$//'
