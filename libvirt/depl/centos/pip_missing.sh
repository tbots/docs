#!/bin/bash
#
list=`pip list`
for L in `./install.sh -r PIP`
do
 	echo "$list" | grep -qi $L || echo "\`$L' not installed"
done
