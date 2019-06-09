#!/bin/bash
# Lists all the disks and their mount points. Maybe we want to display also flags?
#
declare -a disks=( $(sudo fdisk -l | sed -n '/Disk/ s/^[^\/]\+\(\/[^:0-9]\+\)\+:.*/\1/p') )	# sda, sdb.. not loop20 or sda1
declare -A mounts
for disk in ${disks[@]}
do
	j=1
	# /dev/sda -> \/dev\/sda
	disk_esc=$(echo ${disk} | sed 's/\//\\\//g')
	while grep -q "${disk_esc}${j}" /etc/mtab 
	do
		mounts[$disk$j]=$(grep "${disk_esc}${j}" /etc/mtab | awk '{print $2}')
		echo "mounts[$disk$j]:   ${mounts[$disk$j]}"
		((j++))
	done
	# ^^^ how to convert it all to the for loop
done

for disk in ${disks[@]} 
do
	echo "Disk :$disk"
	j=1
	while [ ${mounts[$disk$j]} ]
	do
		echo -e "$disk$j:\t${mounts[$disk$j]}"
		((j++))
	done
	echo ""
done
