#!/bin/bash
#
# Run against /etc/resolv.conf. Expected command line:
#
# sed -f addns.sed /etc/resolv.conf
#

$ a \ nameserver 8.8.8.8
/^\s*nameserver/ i nameserver 172.18.80.136
