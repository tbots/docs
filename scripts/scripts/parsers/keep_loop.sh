#!/bin/bash

# Prints command line arguments.
#for i; do echo "$i|"; done

#!/bin/bash
#
# Keep array inside loop.
server_root=/etc/apache2
conf=$server_root/apache2.conf
declare -a arr; num=1

# After loop arr holds all the files with the VirtualHost directive set.
for inc in `grep -i '^\s*include' $conf | awk '{print $2}' | sed "s;.*;$server_root/&;g"`; do
	if grep --silent --ignore-case '<\s*virtualhost' "$inc"; then
		arr[$num]=$inc
		let num++
	fi
done

num=1
for entry in ${arr[@]}; do
	echo "[$num] ${arr[$num]}"
	let num++
done
read num
echo "arr: ${arr[$num]}"
#echo "arr: ${arr[@]}"
#echo 
#
#echo
#for i in *; do
#	echo "$i|"
#done
#echo "arr: ${arr[@]}"
#echo 
#
#for i in a b c; do 
#	arr[$num]=$i
#	let num++
#done
#
#echo "arr: ${arr[@]}"
