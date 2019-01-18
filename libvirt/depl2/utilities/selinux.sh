#!/bin/bash
#
# add an option to print current file config mode

# disable selinux; change made in the configuration file and will remain permanent accross
# reboots

CONF=/etc/selinux/config

sed -i '0,/^\s*SELINUX=/ {/^\s*\(SELINUX=\).*/s//\1permissive/}' $CONF
