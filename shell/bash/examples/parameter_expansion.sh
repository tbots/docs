#!/bin/bash
#
# Exploring parametr expansion constructs.

parameter='localhost'
var=10.2.2.1
echo "${parameter:-var}"    # localhost
unset parameter
echo "${parameter:-$var}"   # 10.2.2.1

pwd
echo ${PWD##*/}     # only current directory name without leading path

option=-n
cmd=-n10
echo ${cmd##$option}
