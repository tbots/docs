#!/bin/bash
#

for i in {0..255}
do
	echo -n "$i "
	if [[ $(( i % 4 )) -eq 3 ]]
	#if [[ $(( i % 4 )) == 0 ]]		# not good because first 0 triggers a new line after him and we need before :P
	then
		echo -en "\n"
	fi
done
