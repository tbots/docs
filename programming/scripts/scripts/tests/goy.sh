#!/bin/bash

function usage() {
	echo "`basename $0`: [OPTIONS]..."
	echo "Checks shabbat time against www.chabad.org and displays remained time till the shabbat start. Execution will"
	echo "fail if shabbat time is in effect now. If this is the case please run the script with the --non-kosher option"
	echo "to see remaining time till the end of shabbat."
	echo ""
	echo "Options"
	echo "  -j, --jump-to-future          set system time in future to emulate shabbat time behaviour"
	echo "  -k, --non-kosher              allow script execution in shabbat time to show left over time"
	echo "      --debug                   dump variables"
	echo "      --help                    display this help and exit"
	exit 0
}

function compare() {
	if [[ $shabbat -gt $now_time ]]
	then
		shabbat_starts								# shabbat time is in future; display its time


	# shabbat time is now or script was called with --jump-to-future
	
	elif [ "$non_kosher" ]					# if --non-kosher was specified display shabbat end time for goys
	then
		shabbat_ends
	else
		session_shabbat								# restrict usage of the script in shabbat :P
	fi
}

function jump_to_future() {
	now_time=`date +%Y%d%H%m -d 'next year'`
}

function shabbat_starts() {
	while [ "1" ]; do
		echo -en "\t\e[32m\e[1m!!! SHABBATH STARTS AT $shabbat_start !!!\e[0m"
		sleep 0.5
		echo -en "\r\033[K\e[0m"
		sleep 0.5
	done
}

function shabbat_ends(){
	while [ "1" ]; do
		echo -en "\t\e[31m\033[1m!!! GOY !!!\e[0m"
		sleep 0.5
		echo -en "\r\e[K\e[0m"
		sleep 0.5
		echo -en "\t\e[31m\033[1m!!! SHABBATH EXITS AT $shabbat_end !!!\e[0m"
		sleep 0.5
		echo -en "\r\e[K"
		sleep 0.5
	done
}
	

function session_shabbat(){
	echo -e "\t\e[31m\e[1m    !!! SHABBATH !!!"
	while [ "1" ]; do
		echo -en "\t\e[31m\e[7m!!! ACCESS DENIDED !!!\e[0m"
		sleep 0.5
		echo -en "\r\033[K\e[0m"
		sleep 0.5
	done
}
	

function debug() {
	echo "shabbat_start:  $shabbat_start"
	echo "shabbat_end: 		$shabbat_end"
	echo "now_time:       $now_time"
	exit 0
}
	

while [ "$1" ]
do
	case $1 in
		--help) 
			usage;;
		-j|--jump-to-future)
				jump_to_future;;
		-k|--non-kosher)
				let $((non_kosher += 1));;
		--debug)
				let $((debug += 1));;
		-*) 
				echo "invalid option \`$1'" >2 
				exit 1;;
	esac
	shift
done
	
time=`lynx -dump http://www.chabad.org/calendar/candleLighting_cdo/locationId/421/locationType/1/jewish/Candle-Lighting.htm |
				sed -n '/Torah\s\+Reading.*Tazria-Metzora/,$ {/\(Light\s\+Candles\s\+at\|Shabbat\s\+Ends\)/,/[0-9]/p}' |
				grep -m2 -o '[[:digit:]].*'` 

shabbat_start=`echo $time | sed -n '/\(\S\+\s\w\+\).*/s//\1/p'`
shabbat_end=`echo $time | sed -n '/.*\s\([0-9].*$\)/s//\1/p'`

	
# Convert shabbat time to the comparable one
shabbat=$(date +%Y%d%H%m --date "saturday $shabbat_start")

# Current time
test "$now_time" || now_time=$(date +%Y%d%H%m)

# Run debug otherwise compare
test $debug && debug || compare
