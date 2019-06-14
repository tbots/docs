#!/bin/bash

BASE_DIR=/var/ad-ioc

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# log_dir()
#
# Change logs storage related information.
# Log directory follows the following format:
#  $BASE_DIR/{year}/{month}
# each time function is called attempt made to create a directory,
# thus if month or year is changed new directory is created. If attempt
# is failed no error is generated. 
# Current month day is remembered in cur_d variable.
# Function will be called by while loop (:32) to check if date (the current day) is differs from the previous,
# stored in cur_d meaning new day. Next log file name will be generated in YYYY-MM-DD format add following statistics will
# be recorded already in separate file. It will allow us to manage files on the year, month and day levels.
# The resulting structure is as follows:
#
#  $BASE_DIR/{year}/{month}/{date}
#  $BASE_DIR/{year}/{month}/{new_date} <-- date changed - new date log file is created
#  $BASE_DIR/{year}/{new_month}/{new_date} <-- month changed - new folder for month is created under current year and with new date log file inside
#  $BASE_DIR/{new_year}/{new_month}/{new_date}	<-- year changed - new folder for year is created with the new month folder that contains new date log file inside
#
# Each time new file is created, the previous one is archived and stored under month directory.
#  $BASE_DIR/{new_year}/{new_month}/{YYYY-MM}.zip
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function log_dir() {
	zip=`date +%G-%m`.zip
	log_dir=$BASE_DIR/`date +%G`/`date +%m`	
	log_file=$log_dir/`date +%F`
	mkdir --parents $log_dir
	cur_d=`date +%d`
}

# record usage; write a log file in the following format:
#   U{SED_}M{EMORY},YY-MM-DD
#
function record_usage() {
	free -h |\
	sed -n '/Mem/s/[[:upper:]]//gp' |\
	awk '{printf "%s,",$3;system("date +%T")}' >> $log_file
}

# Add log file to .zip archive.
# Each month root directory holds archives for the each day.
function log_zip() {
	zip $log_dir/$zip $log_file
}

#
# MAIN
#
log_dir
while true; do
	if [ $cur_d -ne `date +%d` ]; then
		log_zip""
		log_dir""	
	fi
	record_usage
	sleep 2
done
