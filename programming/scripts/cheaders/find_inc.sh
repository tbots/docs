#!/bin/bash
#
# Find include statements needed by a function within a man page.

source c.sh
keep=1
debug=1

test $# -le 1 || { echo "Usage: get_inc FUNCTION [STATEMENTS[@]]"; exit 1; }

func=$1
get_inc func
