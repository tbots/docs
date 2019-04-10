#!/bin/bash
#
# Find location of the docker image.

find /var/lib/docker -name $( docker images --no-trunc -q  | awk -F: '{print $2; if (NR == 1) exit; }' ) -exec dirname {} \;
