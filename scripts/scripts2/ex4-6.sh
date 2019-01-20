#!/bin/bash

# Does a 'whois domain-name' lookup on any of 3 alternate servers:
#							ripe.net, cw.net, radb.net

# Place this script -- renamed 'wh' -- in /usr/local/bin

# Requires symbolic links:
# ln -s /usr/local/bin/wh /usr/local/bin/wh-ripe
# ln -s /usr/local/bin/wh /usr/local/bin/wh-apnic
# ln -s /usr/local/bin/wh /usr/local/bin/wh-tucows
#
# ln - make links between files
#
# ln [OPTION]... [-T] TARGET LINK_NAME
#								create a link to TARGET with the name LINK_NAME
#
# ln [OPTION]... TARGET
#								create a link to TARGET in the current directory
#
# ln [OPTION]... TARGET DIRECTORY
# ln [OPTION]... -t DIRECTORY TARGET
#								create a links to each TARGET in a DIRECTORY
#
# Create hard links by default, symbolic links with --symbolic. When creating hard links, each TARGET must exist.
# Symbolic links can hold arbitrary text; if later resolved, a relative link is interpreted in relation to its parent
# directory.
#
# --backup[=CONTROL]
#			make a backup for each existing destination file

E_NOARGS=75

if [ -z "$1" ]
then
	echo "Usage: `basename $0` [domain-name]"
	exit $E_NOARGS
fi

# Check script name and call proper server.
case `basename $0` in		# Or:		case ${0##*/} in
	"wh"			) whois $1@whois.tucows.com;;
	"wh-ripe"	) whois $1@whois.ripe.net;;
	"wh-apnic"	) whois $1@whois.apnic.net;;
	"wh-cw"		) whois $1@whois.cw.net;;
	*				) echo "Usage: `basename $0` [domain-name]";;
esac

exit $?
