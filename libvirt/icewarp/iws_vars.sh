#!/bin/bash
#
# Print variable values set in the /etc/icewarp/icewarp.conf
#
IWS_CONF=/etc/icewarp/icewarp.conf
for iws_var in `sed -n 's/^\s*\([A-Z_]\+\).*/\1/p' $IWS_CONF`; do
	echo -e "$iws_var\t${!iws_var}"
done
