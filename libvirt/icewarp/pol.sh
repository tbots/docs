#!/bin/bash

# Change password policy. 
#
# $1   ==   1			enable policy
# $1   !=   1			disable policy
#
function ch_pol(){
	test $1 -eq 1 && status=enabled || status=disabled
	$TOOL set system C_Accounts_Policies_Pass_Enable $1 &> /dev/null && echo "Password policy $status" ||\
										 { echo "Cann't change password policy"; exit 1; }
}
