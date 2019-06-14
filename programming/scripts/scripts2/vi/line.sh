#!/bin/bash
#
# grep the word and open vim on that line
# accept more options to perform an action, i.e. d

vi +`grep -m1 -n $1 $2 | awk -F: '{print $1}'` $2
