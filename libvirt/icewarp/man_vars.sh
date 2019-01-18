#!/bin/bash
#
# Print all the variables and their values that were set via ~/.bashrc
#

./iws_vars.sh	# print variables set specified by the /etc/icewarp/icewarp.conf

for var in `sed -n 's/^\s*export\s*\([A-Z_]\+\).*$/\1/p' ~/.bashrc`; do
#
# print all the variables that were exported manually via ~/.bashrc
	echo -e "$var\t${!var}"
done
