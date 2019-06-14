#!/bin/bash
#
# Check if the CPU supports virtualization.
#

grep --quiet --extended-regexp '(vmx|svm)' --color=always /proc/cpuinfo
echo $?
