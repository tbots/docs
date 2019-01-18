#!/bin/bash

CONF=/boot/config.txt
BAK=$HOME/.config.txt
cp $CONF $BAK

if [ $1 == '-1' ]; then
	val=1
elif [ $1 == '-2' ]; then
	val=2
elif [ $1 == '-3' ]; then
	val=3
elif [ $1 == '-h' ]; then
	val='0x10000'
elif [ $1 == '-v' ]; then
	val='0x20000'
else
	echo "Usage: disp {-1|-2|-3|-h|-v}"
	echo " -1	90"
	echo " -2	180"
	echo " -3	270"
	echo " -h	horizontal flip"
	echo " -v	vertical flip"
fi
sed -i "/\(display_rotate=\).*/s//\1$val/" $CONF
