#!/bin/bash
#
# sort ~/dict/en file and rewrite it

file=$HOME/dict/en
tmp=$HOME/dict/.tmp

# backup $file
cp $file $file.bak

sort --ignore-leading-blanks $file > $tmp
cat $tmp > $file && rm $file.bak
