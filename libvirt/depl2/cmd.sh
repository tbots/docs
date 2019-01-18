#!/bin/bash
#
VARS=vars			# source from file
CMD=`echo $* | sed -n "/\s*\(-c\s*[^-]\S\+\|NGINX\|NAGIOS\|DPC\)\s*/s//-c $VARS /p" | sed  's/-h\s\+[^-]\S\+//; s/[[:upper:]]\+[^=]//'`

echo "CMD:   $CMD"
