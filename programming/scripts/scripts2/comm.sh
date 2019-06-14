#!/bin/bash
#
# Comment lines marked with [DEBUG].

# Print the line before it is substituted.
sed -i '/\[DEBUG\]/s/\w.*/\/\/\0/' $1
