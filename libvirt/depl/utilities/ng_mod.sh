#!/bin/bash
#
# ng_mod.sh			nginx.conf wrapper script
#

# look for executable name from systemctl


function usage()
{
	echo "Usage: `basename $0` [PROTO] [PORT] [FLAGS]..."
	echo "Display PID's and related information about processes."
	echo "  -p         print information about processes that uses ports defined in"
	echo "             /etc/nginx/nginx.conf"
	echo "  -u				 print user that running nginx"
	echo "  -h         print this help message and exit"
	exit 1
}

# nginx config
conf=/etc/nginx/nginx.conf

# search for -h
if [[ $# -eq 0 || $* =~ ^(-?[a-z]+ )*-h( -?[a-z]+)*$ ]]; then
	usage			# print usage message and exit
fi

until [ -z $1 ]
do
	case $1 in
		-p)				

				# check if nginx is running

				# line address of the listen directive
				lst_drvs=`sed -n '/listen/=' $conf`

				if [ $lst_drvs ]
				# listen directive exist
				then
					for ln in $lst_drvs
					# act for each listen directive
					do
						port=`sed -n "$ln s/^\s*listen.*:\([0-9]\+\).*/\1/p" $conf`
						if [ -z $port ] 
						then 
							port=80			# default
						fi

						# read PID's that uses port
						pid=`fuser -a -n tcp $port 2> /dev/null | sed 's/\w\+.\w+:\s*//; s/\(\w\) /\1|/g'`
						echo "pid: $pid"
						
						# display detailed information
						ps -aux | grep -E $pid | grep --invert-match grep
					done
				fi
					
				shift 1
				exit 0
			 	;;
		
		-u)

# store directory pathes that includes bin in between
bin=`echo $PATH | sed 's/:/\n/g' | sed -n '/bin/p'`

if [ $# -eq 0 ]
then
	echo "print usage"
	exit
fi

until [ -z $1 ]
do
	case $1 in
		-b)		### binary name
					###
					exe=$2 ;;

		-u)		### user name
					###
					user=$2 ;;
	esac
	shift 2
done
					
pid=$(fuser `whereis -b -B $bin -f nginx | awk -F: '{print $2}'` 2> /dev/null | sed 's/\(\w\) /\1|/g')

# display detailed information
ps -aux | grep -E "$pid" | grep --invert-match grep | head -n1 | awk '{print $1}'
				# display user that runs nginx processes

	esac
done
