#!/bin/bash
# shift-past.sh

shift 3		# Shift 3 positions.
#  n = 3; shift $n
#  Has the same effect.

echo "$1"

exit 0

# ============================= #

# $ sh shift-past.sh 1 2 3 4 5
# 4

# However, attempting to 'shift' past the number of positional
# parameters ($#) returns an exit status of 1, and the positional
# parameters themselves do not change.
# This is possibly getting stuck in an endless loop. . . .
# For example:
#			until [ -z "$1" ]			# Until the condition is not true loop.
#			do
#				echo -n "$1 "
#				shift 20						# If less than 20 pos params,
#			done									# then loop never ends!
#
# When in doubt, add a sanity check. . . . 
#						shift 20 || break
#										 ^^^^^^^^
