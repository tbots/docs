#!/bin/bash
#
# check proper configuration settings
#

files=\
'/usr/local/nagios/etc/htpasswd.users 
/usr/local/nagios/libexec/eventhandlers
/usr/local/nagios/libexec/check_nrpe'

for f in $files
do
	if [ -e $f ]
	then
		# check with awk the correct permissions set
		echo -e "$f\t\t`ls -ld $f | awk '{print $3 "\t" $4}'`"
	else
		echo -e "$f\t[ missing ]"
	fi
done

echo "nagios admin user"
awk -F: '{print $1}' /usr/local/nagios/etc/htpasswd.users
