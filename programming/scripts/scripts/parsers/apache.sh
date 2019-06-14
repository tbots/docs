#!/bin/bash

sites-enabled=/etc/apache2/sites-enabled

[ -n "$1" ] || { echo "Usage: apache.sh SITE [DIRECTIVE]"; exit 1; }
[ -n "$2" ] && directive=$2 || directive=DocumentRoot
grep -i "$2" \
$( grep -i "servername.*$1" $sites-enabled/* | awk -F: '{print $1}' )
