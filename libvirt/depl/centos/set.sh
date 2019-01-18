#!/bin/bash
#
# Set environment used by nginx.sh.
#

if [[ $* =~ ^(.+ +)*-h( +.+)*$ ]]
then
	echo "Usage: `basename $0` [OPTIONS]... VAR[=[VAL]]"
	echo "Allows modification of variables file."
	echo "If only variable name found on the command line (without leading =), it will be"
	echo "triggered as a search pattern and all variables matches the pattern will be displayed."
	echo "If variable name follows \`=' without a value it will be unset, otherwise it will be reset with"
	echo "a new value."
	echo
	echo "Options:"
	echo "  -l             list all the variables"
	echo "  -h             print usage and exit"
	exit 0
elif [[ $* =~ ^(.+ +)*-l( +.+)*$ ]]
then
	cat ../nginx.dep vars; exit
elif [[ $* =~ ^(.+ +)*-d( +.+)*$ ]]
then
	for entry in `echo "$*" | grep -o '[A-Z_]\+'`
	do
		sed -i.bak "/$entry/"d vars
	done
	#sed -n "/`
	#`/"p vars
	#sed -n "/`echo $* | sed -n 's/-d\( \+\)\?//; s/\(\w\) \(\w\)/\1\\\|\2/gp'`/"d vars
	exit
fi

if [ -z $1 ]
then
	
	echo "Running interactive. Press \`q' in answer prompt to stop interactive mode."
	echo "Enter new value or press ENTER for the default:"
	for file in ../nginx.dep vars
	do
		for line in `cat $file`
		do
				variable=`echo $line | awk -F= '{print $1}'`
				value=`echo $line | awk -F= '{print $2}'`
	
				echo -n "$variable [$value]: ";read ANS
				if [ $ANS ]	# ! <ENTER>
				then
					if [[ $ANS =~ ^\ *q\ *$ ]]
					# exit on `q'
					then	
						exit 1
					fi
					sed -i "/^$variable=/ s|=\S\+|=$ANS|" $file
				fi
			done
		done

else

	for variable in $*
	do
		
			if ! [[ $variable =~ = ]]
			# -----------------------------------------------------
			# Trigger $variable as pattern to search in vars files.
			# -----------------------------------------------------
			then
				grep --no-filename --ignore-case $variable ../nginx.dep vars
			else
				value=`echo $variable | awk -F= '{print $2}'`
				variable=`echo $variable | sed -n "/=.*/s///p"`
	
				if grep --quiet --word-regexp ^$variable ../nginx.dep vars
				then
					for file in ../nginx.dep vars
					do
						sed -i "/^$variable=/ s|=\S*|=$value|" $file
					done
				else
					# ---------------------------------------------
					# Add a new variable, always to vars file.
					# ---------------------------------------------
					echo $variable=$value >> vars
				fi
		fi
	done
fi
