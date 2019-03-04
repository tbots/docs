#!/bin/bash

STEP=$1
test -n "$1" || STEP=2

for i in {0..255} 
do
  #printf("\x1b[38;5;${i}mcolour${i} ");
  echo -n "A" 
  echo "$i % $STEP:  $(( i % STEP))"
  if [[ $((i % $STEP)) -eq $((STEP-1)) ]]
   then printf "\n" 
  fi
done
