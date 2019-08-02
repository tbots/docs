#!/bin/bash
#
# Demonstration purposes

disks=( sda sdb )		# Indexed array
echo "Length of disks[]: ${#disks[@]}"
for disk in ${disks[@]}
do
	echo -e "\${disks[$i]}:\t${disks[$i]}"
done
