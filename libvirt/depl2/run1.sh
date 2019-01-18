#!/bin/bash
#
# Deployment script for the UWSGI, NGINX and WEB2PY appliance
#

function error() {
	case $OPTARG in
		c) 	echo "Configuration file name should be specified with \`-c' option." >&2
				echo "Try \``basename $0` -h' for more information." >&2 ;;
			 	
	esac
	
	exit 1
}
while getopts ":c:" option
do
	case $option in 
		c)	CONF_DEP=$OPTARG;;
		:)	error
	esac
done

echo "CONF_DEP: $CONF_DEP"
