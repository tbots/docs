#!/bin/bash
#
# add an unset option

vars=/etc/openvpn/easy-rsa/2.0/vars

# test for the file existence
env=`grep -Po 'export\s+\K[A-Z]+(_[A-Z]+)?' $vars|perl -p -e 's/\n/|/'|sed -e 's/|$//'`

echo $env
echo UID: $UID
printenv|grep -E "$env"
