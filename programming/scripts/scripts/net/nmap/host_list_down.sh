#!/bin/bash
#
# List hosts that are down. $2 is the reference if specified.
#
source nmap.sh.l
host_list_down $1
