#!/bin/bash

if [ -z $1 ]; then
	echo "Usage: install.sh -i|-l file [pattern]"
	exit 0
fi

cmd=cat\ 
if 
	[[ $* =~ -i|-l ]]; then
	if [ -z ${file=`echo $* | sed -n 's/.*\-i\|-l \+\([^ ]\+\).*/\1/p'`} ]
	then
		echo "specify a filename"
		exit 1
	fi

	if [ ${pattern=`echo $* | sed -n "s#.*-i\|-l \+$file \+\([^ ]\+\).*#\1#p"`} ]
	then
		cmd="grep --ignore-case --no-filename $pattern $file"
	fi
fi
 
if 

#cat ../nginx/dep.l | while read line
#do
#	#echo "line: $line"
#	if [[ $line =~ RHL ]]; then 
#		eval `echo $line | sed -n 's/\(.*\)\s*\[.*/yum install --assumeyes \1/p'`
#	elif [[ $line =~ EPL ]]; then
#		eval `echo $line | sed -n 's/\(.*\)\s*\[.*/yum install --assumeyes --enablerepo=epel \1/p'`
#	elif [[ $line =~ PIP ]]; then
#		eval `echo $line | sed -n 's/\(.*\)\s*\[.*/pip install \1/p'`
#	elif [[ $line =~ CMD ]]; then
#		eval `echo $line | sed -n 's/\(.*\)\s*\[.*/\1/p'`
#	fi
#done
#				#eval "`sed -n '/RHL/s/\(\S\+\)\s.*/yum install -y \1/p;\ /EPL/s/\(\S\+\)\s.*/yum install --enablerepo=epel -y \1/p;\ /PIP/s/\(\S\+\)\s.*/pip install \1/p;\ /CMD/s/\s*\[.*$//p' ../nginx/dep.l`" 
