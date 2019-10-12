#!/bin/bash

call=x

if ! [[ $call =~ all|system ]]
then
	echo good
else
	echo bad
fi
