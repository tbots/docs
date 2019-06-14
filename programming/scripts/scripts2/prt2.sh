#!/bin/bash
#
# Parse password file fields.
#

PASSWD=/etc/passwd	# the password file

case "$1" in
	""			) while [ -z "$LOGIN" ]		# Nothing on the command line.
						do
							echo "Enter username: "
							read LOGIN
						done;;
  *				) LOGIN=$1		
esac

FIELDS=$( grep ^"$LOGIN"$ $PASSWD || {			# No entry for the user.
	echo "`basename $0`: User \`$LOGIN' does not exists." >&2 
	exit 1
}

for FIELD in $FIELDS
