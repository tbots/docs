#!/bin/bash
#
# /etc/services parser

sed -n "s/^\s*\(\w*$1\w*\)\s\+\(\w\+\).*/\1\t\t\2/p" /etc/services
