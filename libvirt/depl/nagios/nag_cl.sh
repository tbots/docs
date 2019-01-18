#!/bin/bash
#
# NRPE Client Side
# Don't forget password for the user
#
# groups nagios: nagcmd
# deluser nagios
# nagios deployement script
#
# PROC:
#
#			disable creation of mail spool !!!
#			moving to /tmp
#			installing wget git tar unzip gcc openssl-devel
#			downloading nagios nrpe
#			untaring it
#			deleting archive 
#			changing directory
#			./configure
#			make
#			make install
#			installing xinetd
#			make install-xinetd
#
#			modify /etc/xinetd.d/nrpe		"only_from"
#
#			configure firewall-cmd
#				--list-all
#
#			
# 		Rewrite at the end all configuration files in one place

# test if not root
if [ $UID -ne 0 ]; then echo "Must be root to run this script"; exit 1; fi

req="wget git httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip openssl-devel"

echo "Installing required packages..."
for pkg in $req; do
	rpm --query --all | grep ^$pkg 1> /dev/null || yum install -y $pkg 1> /dev/null  || missing=$missing" $pkg"
done

# updating system
#yum update -y

# tmp directory for storing configuration files
tmp=/tmp

# lastest version
url=https://sourceforge.net/projects/nagios/files/nagios-4.x/nagios-4.1.1/nagios-4.1.1.tar.gz

# if /tmp does not exist, create it 
if ! test -d $tmp; then mkdir --verbose /tmp | sed 's/\w*:\s*//; s/\(\w\)/\U\1/'; fi
