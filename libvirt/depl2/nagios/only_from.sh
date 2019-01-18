#!/bin/bash
#
# /etc/xinetd.conf			configuration file for xinetd
# 	includedir					directive for additional config files
#
# print only_from directive information from the nrpe config file
# within directory described within includedir
#
# /etc/xinetd.d					additional configuration files
#

conf=/etc/xinetd.d/xinetd

grep only_from $conf | awk -F= '{print $2}'
