#!/bin/bash
#
# troubleshooting script
# 
# checks system to fir nginx requirements

services=`firewall-cmd --list-services`
must='http https'

for s in $services
do
	for m in $must
	do
		if [[ $s =~ ^$m$ ]]
		then
			eval $m=1			# <service_name=1>
		fi
	done
done

for m in $must
do
	if [ -z ${!m} ]
	then
		firewall-cmd --add-service=$m 1> /dev/null
	fi
done
