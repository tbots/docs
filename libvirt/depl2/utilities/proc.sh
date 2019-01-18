#!/bin/bash
#
# Display processes information that runs on the currect port
#

ps aux | grep -E `fuser -n tcp $1 2>/dev/null | sed 's/\([0-9]\)\s\+\([0-9]\)/\1|\2/g'`
