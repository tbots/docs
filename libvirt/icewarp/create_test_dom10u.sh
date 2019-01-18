#!/bin/bash

# Change password policy. $1 is the variable value.
#
function ch_pol(){
	test $1 -eq 1 && status=enabled || status=disabled
	$TOOL set system C_Accounts_Policies_Pass_Enable $1 &> /dev/null && echo "Password policy $status" ||\
										 { echo "Cann't change password policy"; exit 1; }
}

TOOL=/opt/icewarp/tool.sh
DOMAIN=test.com
USERNAME=user
pass=a

$TOOL get domain $DOMAIN 1>/dev/null && $TOOL delete domain $DOMAIN	# delete domain if exists
$TOOL create domain $DOMAIN D_Description "created by script" || exit 1	# create domain

#ch_pol "1"		# disable password policy

for N in `seq 0 10`; do			# create ten users
	USER=$USERNAME$N		# user1 user2 user3...
	./tool.sh create account "$USER@$DOMAIN" U_Password $pass
done
#ch_pol "0"		# enable password policy

