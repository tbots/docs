#!/bin/bash

CODE_LIST_A="45911, 65912, 55721, 85331, 79041, 53242, 75051"
CODE_LIST_B="99411, 84712, 95521, 93731, 17241, 16042, 61651"
CODE_LIST_A_FILENAME=code_list_a.lst
CODE_LIST_B_FILENAME=code_list_b.lst
LOG_FILE=timestamps.log
DATE=$(date +"%Y-%m-%d_%H%M%S")
IP=$(curl -s checkip.dyndns.org|sed -e 's/.Current IP Address: //' -e 's/<.$//')

is_code_in_var() {
grep -qP "(,|^)\s*$1(,|$)" <<< "$2"
}

is_code_in_file() {
grep -qP "^$1$" "$2"
}

while [ 1 ]; do 
	# Maybe add a double check for the proper directory shift?
	cd /home/pi/Desktop/chino
	python3 hello-code.py
	echo "Enter the code:"
	read CODE
	
	is_code_in_var "$CODE" "$CODE_LIST_A"
	# File check could be used as well. Added only as an example.
	#is_code_in_file "$CODE" "$CODE_LIST_A_FILENAME"
	IS_WASHER_CODE=$?
	
	is_code_in_var "$CODE" "$CODE_LIST_B"
	#is_code_in_file "$CODE" "$CODE_LIST_B_FILENAME"
	IS_DRYER_CODE=$?
	
	[ $IS_WASHER_CODE -ne 0 -a $IS_DRYER_CODE -ne 0 ] && { echo "The code not found. Try again"; continue; }
	echo "The code found." 
	echo "$(date): $CODE" >> "$LOG_FILE"
	
	if [ "$IS_WASHER_CODE" -eq 0 ]; then 
	# Place the Washer_Python script here
	fi
	
	if [ "$IS_DRYER_CODE" -eq 0 ]; then 
	# Place the Dryer_Python script here
	fi
	/bin/echo Send gmail note here
done
