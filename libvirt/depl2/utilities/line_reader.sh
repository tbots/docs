#!/bin/bash

CONF=/etc/nginx/nginx.conf

cat -n $CONF | sed -n "$1,$2s/\s*//p" 
