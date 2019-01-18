#!/bin/bash
#
# Hacking IceWarp constants.

declare -A entry

tool="/opt/icewarp/tool.sh"

# display all the domain variables
$tool search " U_*" | sed -n 's/\(\w\+\).*\(String\( \+\w\+=\w\+\)\?\|Enum\(.*)\)\|Bool\)/\1/p'

#for m in "aaa bbb"
#do
#	entry[0]=`echo $m | awk '{print $2}'`
#	entry[${entry[0]}]=`echo $m | awk '{print $1}'`
#
#done
#
#echo "${entry[0]}"
#echo "${entry[${entry[0]}]}"
