#!/bin/bash
#
# ask on stackoverflow.com
# ? disabled within quotes

#action='start restart stop'

#if [[ $action =~ start\s\?|restart\s\?|stop\s\? ]]
#then
#	echo "matched"
#else
#	echo "unmatched"
#fi

#input='stop nginx'

# until?
while ! [ -z $1 ]
do
	for pattern in $input
	do
		echo "processing $pattern|"
		#if [[ $pattern =~ start\s?|restart\s?|stop\s? ]]
	
		if [[ $pattern =~ \
									^(s(tart)?|r(estart)?)$ ]]
		then
			action=$pattern
		else
			service=$pattern
		fi
	done
		
	echo "action:\t$action"
	echo "service:\t$service"
	
