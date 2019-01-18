#!/bin/bash
#
# transform to the sed script

sudo sed -i '/^\s*nameserver/ i nameserver 172.18.80.136' /etc/resolv.conf
