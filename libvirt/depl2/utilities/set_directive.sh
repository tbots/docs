#!/bin/bash
#
# test script
#
# Server description can be one of the listen or server_name
#
# -a [proto] [server] directive value

if [[ $* =~ ^(.+ +)*-a( +.+)*$ ]]
then
	params=`echo $* | sed -n 's/^.*-a\(.*\)\(-.*\)\?$/\1/p'`
	directive=`echo $params | sed -n 's/.*\(\w\+ \w\+\)/\1/p'`
	pattern=`echo $params | sed -n "s/\(.*\)$directive/\1/p"`
	echo "directive: $directive"
	echo "pattern: $pattern"
fi
