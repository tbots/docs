#!/bin/bash

echo hello
echo $?				# exit status 0 returned because command executed successfully

lskdf					# unrecognized command
echo $?				# non-zero exit status returned -- command failed to execute

echo

exit 113			# will return 113 to shell
