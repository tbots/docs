#!/bin/bash
#
# Print all device names under /proc/bus/input/devices

awk -F= '/Name/ {print $2}' /proc/bus/input/devices | sed 's/"//g'
