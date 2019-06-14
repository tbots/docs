#!/bin/bash
#
# Append a project id to the users csv file

IFS=$'\n'
lines=($(sed '1d; s/,\s*$//' users))		# here lines[] is an array of lines starting from the second line
																				# last field if empty truncated

for((i=0; i < ${#lines[@]}; i++))
do
	# get project name
	fields_count=$( echo "${lines[$i]}" | awk -F, '{print NF}' )
	test $fields_count -eq 2 || continue		# third field already set to the project id
																					# do not process lines with the id set

	prj=$( echo "${lines[$i]}" | awk -F, '{print $NF}' )
	echo "\$prj: $prj"		# get project name

	# get line number from the projects file (corresponding foreign key)
	project_id=$( sed '1d' projects | grep -m1 -n "^$prj" | awk -F: '{print $1}' )
	echo "project_id: $project_id"

	#sed -n "s/,\?$/,$project_id/p" users

	line=$((i+2))	# 2 because of the first line that is description
	sed -i "$line s/,\?$/,$project_id/" users
done
