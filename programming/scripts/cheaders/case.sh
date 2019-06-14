#!/bin/bash

var=
case $var in
	a|'') echo "a or empty";;
	*)  echo "something else";;
esac
