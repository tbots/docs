#!/bin/bash

if [ -z "$2" -o $2 =~ ^- ]
then
  echo "no argument found"
else
  echo "argument catched: $2"
fi
