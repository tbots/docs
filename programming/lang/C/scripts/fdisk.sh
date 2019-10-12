#!/bin/bash

# Partitions manipulation script. Script is under work.

declare -A count
declare -A partion_name
declare -A mount_point

function usage() {
	echo "Usage: `basename $0` [OPTION]..."
	echo "List, mount and unmount partitions."
	echo 
	echo "  -l         list drives"
	echo "  -m         list mounted partitions (not implemented)"
	echo "  -u         unmount partitions (supports only prompt)"
	exit
}


#		list all the drives

function list() {

	i=0; m=0
	while [ "${dev[$i]}" ]; do

		echo "${dev[$i]}"
		while $(echo ${partition_name[$m]} | grep -q "${dev[$i]}")
		do
			echo -en "\t${partition_name[$m]}\t"
			test ${mount_point[${partition_name[$m]}]} &&\
				echo -e "${mount_point[${partition_name[$m]}]}" ||\
				echo -e "\033[2mnot mounted\033[0m"
			let	$((m+=1))
		done
		let $((i+=1))
	done
}


#		populate dev with the device nodes and partion_name with the partitions

function init_dev() {

	i=0; m=0

	for D in `fdisk -l | sed -n '/^Disk \(\/.*[^0-9]\):.*/s//\1/p'`
	do
		dev[$i]=$D

		for P in `fdisk -l | grep -o "${dev[$i]}[0-9]"`
		do
			partition_name[$m]=$P
			mount_point[${partition_name[$m]}]=`mount | grep ${partition_name[$m]} | awk '{print $3}'`
			let $((m += 1))
			let $((counter += 1))
		done
		count[${dev[$i]}]=$counter; counter=0
		let $((i+=1))
	done
}


# 	print partitions count for each device

function part_count() {

	i=0
	while [ ${dev[$i]} ]; do
		echo "$dev[$i] has ${count[${dev[$i]}]} partitions"
		let $((i+=1))
	done
}


#		issue a prompt to choose a device

function dev_query() {

	i=0
	while [ "${dev[$i]}" ]
	do
		echo "$((selection += 1)):   ${dev[$i]}"
		let $((i += 1))
	done
	echo -n "Enter a selection: "
	read selection
	disk_number=$((selection - 1)); selection=0
}


#		issue a prompt to choose a partition

function part_query() {

	m=0

	until $(echo ${partition_name[$m]} | grep -q ${dev[$disk_number]}); do
		let $((m += 1))
	done

	while $(echo ${partition_name[$m]} | grep -q ${dev[$disk_number]}); do
		echo -e "$((selection += 1)):\t${partition_name[$m]} : ${mount_point[${partition_name[$m]}]}"
		if [ ${partition_name[$((m + 1))]} ]
			then let $((m += 1))
			else break;
		fi

	done
	echo -n "Enter a selection m is $m: "
	read selection
	partition_number=$((selection - 1 + m)); selection=0
}


#		umount partition number partition_number from disk number disk_number
function u() {
	dev_query
	part_query 
	echo "Unmounting \`${partition_name[$partition_number]}' from the \`${mount_point[${partition_name[$partition_number]}]}'" 
}

init_dev

if [[ $* =~ ^(.+ +)*-h( +.+)*$ || $# -eq 0 ]]						#		help
then		usage

elif [[ $* =~ ^(.+ +)*-l( +.+)*$ ]]					# list
then		list
	
elif [[ $* =~ ^(.+ +)*-u( +.+)*$ ]]					# unmount
then		u
	
fi
