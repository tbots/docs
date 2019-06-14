#!/bin/bash

server_root=/etc/apache2
conf=$server_root/apache2.conf
declare -a arr; num=1

declare -a arr; num=1
#grep --ignore-case "^\s*servername" $( grep --ignore-case '^\s*include' $conf | awk '{print $2}' | sed "s;.*;$server_root/&;g" ) | while read virt
while read virt
do
	arr[$num]="$virt"
	echo "[$num]:   ${arr[$num]}"
	let num++
done < <( grep --ignore-case --line-number --with-filename \
					"^\s*servername" \
					` grep --ignore-case '^\s*include' $conf | awk '{print $2}' | sed "s;.*;$server_root/&;g" ` 
				)

echo -n "Choose website: "; read choice

echo "arr[$choice]: ${arr[$choice]}"
