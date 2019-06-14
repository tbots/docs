#!/bin/bash

true		# the "true" builtin
echo "exit status of \"true\" = $?"

! true
echo "exit status of \"! true\" = $?"
#
# "!" needs a space in between it and the command
#			!true		leads to the command not found error
#
# The '!' operator prefixing a command invokes the Bash history mechanism

true

# =========================================================== #
# preceding a _pipe_ with ! inverts the exit status returned
ls | bogus_command		# bash: bash_command: command not found	
echo $?								# 127

! ls | bogus_command	# bash: bash_command: command not found
echo $?								# 0
# Note that the ! does not change the execution of the pipe
# Only the exit status changes
# =========================================================== #
