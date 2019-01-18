#!/bin/bash
#
# List UWSGI related information
#

#
# u():		uwsgi.service path
#
function u() {
	
	# verify that unit file exist
	if [ -z ${UNIT_UWSGI=`systemctl show uwsgi 2> /dev/null | awk -F= '/FragmentPath/ {print $2}'`} ]
	then
		echo -e "\e[47mUNIT_UWSGI\e[0m:\t \e[36mnot set\e[0m"
		exit 1
	fi
}

#
# id():		uid gid
#
function id() {

	if [ $1 ]; then			# examine specific file
		echo "\e47m`basename $1`\e[0m"
		echo " `grep -E 'uid|gid|user' $1`"
	else
		# retrieve emperor arguments
		emp
		
		# retrieve monitoring directories
		mon
		
		for L in $MON_DIR/*.ini
		do
			echo -e "\e[47m`basename $L`\e[0m"
			grep -E 'uid|gid|user' $L | sed 's/^/ /'
		done
	fi
	exit
}

#
# dir():	any directory path found in file
#
function dir() {

	if [ $1 ]; then			# examine specific file
		echo -e "[\e[4m`basename $1`\e[0m]"
		for L in `grep -Eo '/[^ ]+' $1`
		do
			test -e $L && echo -e " \e[32m$L\e[0m" || echo -e " \e[31m$L\e[0m"
		done
	else
		# retrieve emperor option arguments
		emp
	
		# retrieve monitoring directories
		mon
	
		for L in $MON_DIR/*.ini
		# process each .ini file found under monitoring directory
		do
			echo -e "[\e[4m`basename $L`\e[0m]"
			for E in `grep -Eo '/[^ ]+' $L`
			do
				test -e $E && echo -e " \e[32m$E\e[0m" || echo -e " \e[31m$E\e[0m"
			done
		done
	fi
}

#
# ini():  print .ini files found under monitoring directory
#
function ini() {

	# retrieve emperor option arguments
	emp

	# retrieve monitoring directories
	mon

	if [ $EMP_INI ]; then
		echo -e "\e[4memp ini\e[0m:\t$EMP_INI"
	fi

	for L in `ls -1d $MON_DIR/*.ini`
	do
		echo -e "\e[4memp ini\e[0m:\t$L"
	done
}

#
# mon():	learn emperor monitoring directories
#
function mon() {

	# retrieve emperor option arguments
	emp
	
	for L in $EMP_ARGS
	do
		if [[ $L =~ .ini ]]			# emperor option argument is .ini file
		then
		
			if test -e $L 				# exist
			then

				EMP_INI=$L

				if [ ! -e ${MON_DIR=`sed -n 's/^ *emperor *= *\([^; ]\+\).*/\1/p' $EMP_INI`} ]
				# monitoring directory is missing
				then
					echo -e "\e[47m$MON_DIR\e[0m:\t \e[31missing\e[0m"
					exit 1
				fi
			fi
		else 

			# learn monitoring directories
			MON_DIR=$MON_DIR" $L"
		fi
	done

	# report monitoring directories
	if [ $1 ]; then
		for L in $MON_DIR; do echo -e "\e[4memp mon\e[0m:\t$L"; done 
	fi
}

# emp():	learn emperor option arguments and monitoring directories
function emp() {
	
	u			# uwsgi.service absolute path

	if [[ -z ${EMP_ARGS=`grep -Eo 'emperor +[^;| ]+' $UNIT_UWSGI | awk '{print $2}'`} ]]
	then
		echo -e "\e[47mEMP_ARGS\e[0m:\t \e[36mnot set\e[0m"
		exit 1
	else
		if [ $1 ]
		then
		# print arguments
			if [ $1 == "1" ]
			then
				for L in $EMP_ARGS; do echo -e "\e[4memp arg\e[0m:\t$L"; done 
				exit
			else
			# set argument
				sed -i "s|\(emperor \+\)[^; ]\+|\1$1|" $UNIT_UWSGI
			fi
		fi
	fi
	
}
	
#
# S():		print service information
#
function S() {

	echo -e "\e[47muwsgi.service\e[0m"

	u

	### path ###
	echo -e "\n  path:\t\t\e[32m$UNIT_UWSGI\e[0m" 


	###	active state ###
	echo -en "\n  state:\t"
	systemctl list-units --all `basename $UNIT_UWSGI` | awk 'NR == 2 \
																			{if ($3 == "inactive") printf "\033[31m%s\033[0m   ", $3; else if ($3 == "active") printf "\033[32m%s\033[0m   ", $3;\
																			if ($4 == "dead") printf "\033[31m%s\033[0m   ", $4; else if ($4 == "running") printf "\033[32m%s\033[0m   ", $4;\
																			if ($2 == "loaded") printf "\033[32m%s\033[0m\n", $2; else if ($2 == "not-found") printf "\033[31m%s\033[0m\n", $2;}'

	### unit file state ###
	echo -en "  unit file:\t"
	systemctl show `basename $UNIT_UWSGI` | awk -F= '/UnitFileState/ {if ($2 == "enabled") printf "\033[32m%s\033[0m\n", $2; else if ($2 == "disabled") printf "\033[33m%s\033[0m", $2;}'

		
}

function usage() {
	echo "Usage: `basename $0` [OPTIONS]..."
	echo "Reports different type of information related to post deployment process."
	echo
	echo "Options: "
	echo "  -U            information requsted for the UWSGI unit file"
	echo "  -m            print monitoring directories"
	echo "  -i            print configuration file names"
	echo "  -d [file]...  print any directories specified from the file or if ommitted from"
	echo "                all the files involved in project"
	echo "  -e [arg]...   print or set emperor argument(s). When trying to set an argument and more that"
	echo "                emperor option instances were found in the uwsgi unit file, "
	echo "                interactive prompt will be started when to determine the correct one"
	echo "  -u [uid] [file] print or set uid"
	echo "  -l [N] [F]    print N last lines from the log file F"
	echo "  -h            print usage"
	echo
	echo "If no specific section requested all available information is printed" 
	exit 0
}

if [ $# -eq 0 ]; then usage; fi

while getopts ":mfdUpsudehi" opt
do
	case $opt in
		h) usage ;;
		d) 
			dir "`echo $* | sed -n 's/.*-d\s*\([^- ]\+\).*$/\1/p'`";;
		u) id "`echo $* | sed -n 's/.*-u\s*\([^- ]\+\).*$/\1/p'`";;
		i) ini ;;


		e) ### emp arg ###

			# arg is now new emperor argument to be set, if not specified current
			# arguments will be printed
			if [ -z ${arg=`echo "$*" | sed -n 's/.*-e\s*\([^- ]\+\).*$/\1/p'`} ]
			then
				arg=1
			fi

			emp	$arg;;	# retrieve emperor args
		m) mon "1";;
		U) S ;;
		p) u ;;
		s) let $((FILE_STATE += 1)) ;;
	esac
done
