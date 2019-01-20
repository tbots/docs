#!/bin/bash

BASE_DIR=/var/ad-ioc

function log_dir() {
	zip=`date +%G-%m`.zip
	log_dir=$BASE_DIR/`date +%G`/`date +%m`	
	log_file=$log_dir/`date +%F`
	mkdir --parents $log_dir
	cur_d=`date +%d`
}

function record_usage() {
	free -h |\
	sed -n '/Mem/s/[[:upper:]]//gp' |\
	awk '{printf "%s,",$3;system("date +%T")}' >> $log_file
}

function log_zip() {
	zip $log_dir/$zip $log_file
}

log_dir
while true; do
	if [ $cur_d -ne `date +%d` ]; then
		log_zip""
		log_dir""	
	fi
	record_usage
	sleep 5				# modify frequency of checking here
done
