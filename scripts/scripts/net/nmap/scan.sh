#!/bin/bash
#
# Parse scan output.
#

source nmap.sh.l

hosts_list $1
echo `resolved_hosts_number $1` resolved hosts
echo `hosts_up $1` hosts up
