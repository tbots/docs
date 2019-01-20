#!/bin/bash

# Original command
#$XHOME/scripts/x/x_mainscript.bash $HOME/x/x/x.x `date "+%Y%m%d" -d "-1 day"` &> $HOME/logs/x/mainscript.`date "+%Y%m%d.%H%M%S"`.log

CMD=$XHOME/scripts/x/x_mainscript.bash
YESTERDAY=`date "+%Y%m%d" -d "-1 day"`
TIMESTAMP=`date "+%Y%m%d.%H%M%S"`
MESSAGE="Stderr captured: $YESTERDAY"
PRIORITY="local3.info"

_logfile=$HOME/logs/x/mainscript.${TIMESTAMP}.log

_cmd="$CMD $YESTERDAY > $_logfile"

_stderr=$( { eval $_cmd; } 2>&1 | head -1)

if [ -n "$_stderr" ]; then
    echo "logging"
    logger -p $PRIORITY "$MESSAGE $_stderr"
else
    echo "no logging"
fi