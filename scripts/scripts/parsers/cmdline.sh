#!/bin/bash
#
# Script to parse cmdline found under /proc directory for the given process.
# 
# 1. Find out running machines ps(1).
# 2. Display in select loop all the machines that are running.
# 3. Dump cmdline of the selected machine from the using /proc/PID.

cmdline=$1

test $cmdline || { echo "missing cmdline path"; exit 1; }
cat $cmdline | tr '\000' ' ' | grep --only-matching ' \-\S\+\(\s[^-]\S*\)*'
