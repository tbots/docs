#!/bin/bash
#
# Vagif task.
#
# Process each user on the server. Examine U_ForwardTo value. 
# Reset value for each non local domain.
#

source /etc/icewarp/icewarp.conf
TOOL=$IWS_INSTALL_DIR/tool.sh

# Get local domains. Filtered through D_Type.
DOMAINS_LC=`$TOOL get domain "*" D_Type | grep ':\s*0' -B1 | sed -n '{/^D\|-/d};p'`

# Process each user on the server.
for record in `$TOOL --filter="(U_Type='0')" get account "*@*" | sed '/^$/d'`		# record=user0@domain.com
do
	# Debug #
	#echo "|$record|"

	# Get only domain part of the U_ForwardTo variable value.
	forward_to=`$TOOL get account "$record" U_ForwardTo | awk -F '@' '/:/ {print $2}'`		# mordor.dark 

	# Debug #
	#echo "|$forward_to|"

	if [[ "$forward_to" ]]			# U_ForwardTo was set
  then

		for LOCAL_DOMAIN in $DOMAINS_LC	# Iterate local domains and 
		do															# compare them against value set in U_ForwardTo
			if [[ $LOCAL_DOMAIN = "$forward_to" ]]; then
				
				# Debug #
				echo "local domain found"

				((LOCAL_DOMAIN_FOUND++))		# match found; set the flag
				break												# and break the loop
			fi
		done

		#	U_ForwardTo points to the non local domain - reset it.
		[[ -n "$LOCAL_DOMAIN_FOUND" ]] || $TOOL set account "$record" U_ForwardTo

		# Reset flag for the next iteration.
		unset LOCAL_DOMAIN_FOUND
	fi
done
