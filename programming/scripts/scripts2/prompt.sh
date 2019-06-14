#!/bin/bash
#
# Prompts for a word. Than prompts for a regex. 
#
# On the prompt you can specify two modifiers: w and re. Than prompt will change for keeping prompting
# regex or a word.
#

while :		# Test also while true
do
	echo "Enter an answer? [Y/n] "
	read answer

	echo "
	if [[ "$answer" =~ [Yy]([EeSs])?$|^$ ]]
	then
