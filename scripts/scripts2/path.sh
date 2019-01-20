#!/bin/bash
#
# Print each directory in $PATH on the new line
#
echo $PATH | sed -e 's/:/\n/g'
