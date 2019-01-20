#!/bin/bash

expr=$1

pattern=[[:alpha:]]

if [[ $expr =~ $pattern ]]
then
	echo "'a' matched to $pattern"
else
	echo "'a' does not matches the $pattern"
fi
