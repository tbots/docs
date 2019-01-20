#!/bin/bash
#
# Get nameserver A records.
#

nslookup -debug -type=ns $1 | sed -n '/-\+$/,/-\+$/p' | grep -o '\([0-9]\+\.\)\{3\}[0-9]\+'
