#!/bin/bash
#
# services.sh		list services information

function usage() {
	echo "Usage: `basename $0` service..."
	echo "Print units and services info."
	exit 0
}

# print usage if no arguments provided
if [ $# -eq 0 ]; then usage; fi


while [ $1 ]; do
	
	# add `.service' suffix if missing
	service=`echo $1 | sed '/\.service/! s/$/\.service/'`

	echo -e "\e[4m$service\e[0m"
	echo -n "  path:"
	if systemctl list-unit-files | grep --quiet $service
	then
		echo "  `systemctl show $service | awk -F= '/FragmentPath/ {printf "\033[32m%s\033[0m", $2}'`"
	else
		echo -e "  \e[31mmissing\e[0m"
		shift 

		# print additional new line between reporting each service status
		if [ $# -gt 0 ]; then echo; fi

		continue
	fi	

	#	print active state
	echo -en "  state:\t"
	systemctl list-units --all $service | awk 'NR == 2 \
																					{if ($3 == "inactive") printf "\033[31m%s\033[0m   ", $3; else if ($3 == "active") printf "\033[32m%s\033[0m   ", $3;\
																					if ($4 == "dead") printf "\033[31m%s\033[0m   ", $4; else if ($4 == "running") printf "\033[32m%s\033[0m   ", $4;\
																					if ($2 == "loaded") printf "\033[32m%s\033[0m\n", $2; else if ($2 == "not-found") printf "\033[31m%s\033[0m\n", $2;}'

	# print unit file state
	echo -en "  unit file:\t"
	systemctl show $service | awk -F= '/UnitFileState/ {if ($2 == "enabled") printf "\033[32m%s\033[0m\n", $2; else if ($2 == "disabled") printf "\033[33m%s\033[0m", $2;}'

	if [ $# -gt 0 ]; then echo; fi
	shift
done
