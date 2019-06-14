#!/bin/bash
#
# Apache configuration file parser.
# Keep array inside loop.

server_root=/etc/apache2
conf=$server_root/apache2.conf

#grep -i '^\s*include' $conf | awk '{print $2}'		# all the included files and directories from the apache config

#echo 
#grep -i '^\s*include' $conf | sed "s;.*;$server_root/&;g"		# full path to all the directories and files specified in apache config

for inc in `grep -i '^\s*include' $conf | awk '{print $2}' | sed "s;.*;$server_root/&;g"`; do
	grep --silent --ignore-case '<\s*virtualhost' "$inc" && echo "$inc"
done
