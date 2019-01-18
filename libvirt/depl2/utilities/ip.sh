#!/bin/bash
#
# Retrive ip, as it should be substituted by default server used by nginx.conf

awk -F= '/IPADDR/ {print $2}' `ls -1 /etc/sysconfig/network-scripts/ifcfg-* | grep -v lo`
