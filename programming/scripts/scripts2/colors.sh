#!/bin/bash
#
# Explore 256 bit colors.
#
# 

if [ $1 ]
then
	for i in {0..255}
	do
		echo -e "\e[38;5;${i}m\t$1\t\e[0m[$i]"
	done
else
	for i in {0..255}
	do
		echo -e "\e[38;5;${i}m\t$i"
	done
fi
