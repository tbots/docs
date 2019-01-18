#!/bin/bash
#
# run.sh			executes deployment script on the remote machine
#
# Execution flow:
#					look for a -c option argument that will point to the deployement file
#					holds project specific variables
#					
#					PRJ=<dir_name>					the name of the project directory
#					DEP_HOST=<remote_host>			host address on which deployment should run
#					PRJ_BASE=<project_base_dir>		base directory where all the projects are located
#					SCRIPT=<script_name>			deployment script name for the project
#					VARS=<variables_file>			variables used by the actual deployment script
#
#

if [ $# -eq 0 ]
then
	echo "Usage: `basename $0` -c dep_file|PRJ [-h target] [-p proxy] [VAR=VAL,...]|[-l VAL...]|[-s VAR=VAL,...|-i]"
	echo "Issues deployment script on the remote host."
	echo "Script requires .dep file to be specified where it lists all required variables for the further deployment."
	echo 
	echo "Options:"
	echo "  -h DEP_HOST       target host address"
	echo "  -p PROXY          proxy server address"
	echo "  -c DEP_FILE       specify dep config file"
	echo "  -o [file]...      do not start deployment, only copy"
	echo "  -l [VAR],...	  print all variables used, output can be limited to the specific VAR"
	echo "  -d VAR,...      delete VAR"
	echo "  -s VAR=VAL,...|-i     sets VAR to VAL or if specified with -i, issues"
	echo "                        interactive prompt for each variable"
	echo
	echo "dep files can be specified by a shortcut/alias:"
	echo
	echo "  NAGIOS - nagios.dep"
	echo "  NGINX  - nginx.dep"
	echo "  DPC    - dpc.dep"
	echo 
	echo "Examples:"
	echo "  ./run.sh -c nginx
	echo "             execute script pointed by $PRJ_PTH/$SCRIPT on $DEP_HOST
	echo "  ./run.sh -c nginx.dep TMP=/home/user "
	echo "             execute script on remote host and initialize TMP to /home/user only for current execution"
	echo "  ./run.sh -c nginx.dep -s WWW=/etc/uwsgi"
	echo "             set WWW to new value - /etc/uwsgi; will not run the script"
	echo 
	echo "The work flow is as follows:"
	echo "First public key is copied to the remote machine allowing passwordless authentication."
	echo "Then directory with deployement scripts is copied on the remote machine and script is issued."
	echo "All the variables are stored in \$PRJ_PTH/\$VARS"
	exit 0
fi


if [[ $* =~ ^(.+ +)*-c( +.+)*$ ]]
then
	CONF_DEP=`echo $* | sed -n 's/.*-c \+\([^-]\S\+\).*$/\1/p'`
	if [ $CONF_DEP ]
		then test -e $CONF_DEP || { echo "\`$CONF_DEP' is not exist"; exit 1; }
		else echo "`basename $0`: conf file name need to follow \`-c' option"; exit 1
	fi

# 	accept aliases
elif [[ $* =~ ^(.+ +)*NGINX( +.+)*$ ]]
then
	CONF_DEP=nginx.dep
elif [[ $* =~ ^(.+ +)*NAGIOS( +.+)*$ ]]
then
	CONF_DEP=nagios.dep
elif [[ $* =~ ^(.+ +)*DPC( +.+)*$ ]]
then
	CONF_DEP=dpc.dep

# error
else
	echo "`basename $0`: specify config file"
	exit 1
fi


#	 source variables

source $CONF_DEP
source $PRJ/$VARS		



# 	Options parsing


# 	~~~ 	host	~~~
if [[ $* =~ ^(.+ +)*-h( +.+)*$ ]]
then
  DEP_HOST=`echo $* | sed -n 's/.*-h \([^-][^ ]\+\).*$/\1/p'`
if [ -z $DEP_HOST ] 
	then echo "`basename $0`: target host address need to follow \`-h' option"; exit 1; fi

	# test for the correct ip address format
	echo $DEP_HOST | grep -qEwo '([0-9]{1,3}\.){3}[0-9]{1,3}'
	if [ $? -ne 0 ]; then echo "`basename $0`: target host address is incorrect"; exit 1; fi
fi

# 	~~~	   proxy   ~~~ 

if [[ $* =~ ^(.+ +)*-p( +.+)*$ ]]
then
	
	PROXY=`echo $* | sed -n 's/.*-p \([^-][^ ]\+\).*$/\1/p'`
	if [ -z $PROXY ]; then echo "`basename $0`: proxy server address need to follow \`-p' option"; exit 1; fi

	echo $PROXY | grep -qEow '([0-9]{1,3}\.){3}[0-9]{1,3}'
	if [ $? -ne 0 ]; then echo "`basename $0`: proxy server address is incorrect"; exit 1; fi
fi


#	~~~	  run time variables	~~~
if [[ $* =~ ^(.+ +)*-s( +.+)*$ ]]
then

	vars=`echo $* | sed -n 's/.*-s \([^-][^ ]\+\).*$/\1/p' | sed 's/,/ /g'`
	if [ -z $vars ]
	then 

		echo "running interactive..."

		echo "Enter new value or press ENTER for the default:"
		for F in $CONF_DEP $PRJ_PTH/$VARS
		do
			for line in `cat $F`
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
					sed -i "/^$variable=/ s|=\S\+|=$ANS|" $F
				fi
			done
		done

	else

		for L in $vars
		do
		
			# check for the proper syntax
			if ! [[ $L =~ = ]] 
			then 
				echo "`basename $0`: incorrect syntax \`$variable'" 
				exit 1 
			fi
		
			# read variable portion
			variable=`echo $L | awk -F= '{print $1}'`
		
			# read value portion
			value=`echo $L | awk -F= '{print $2}'`

			if grep -q -w ^$variable $CONF_DEP
			then
					sed -i "/^$variable=/ s|=\S*|=$value|" $CONF_DEP
			elif grep -w -q ^$variable $PRJ_PTH/$VARS; then
					sed -i "/^$variable=/ s|=\S*|=$value|" $PRJ_PTH/$VARS
			else
					echo "$L" >> $VARS
			fi
		done
	fi
	exit
fi


#######################
### 	list values	  ###
#######################

if [[ $* =~ ^(.+ +)*-l( +.+)*$ ]]
then

	# read variables if any

	vars=`echo $* | sed -n 's/.*-l \([^-][^ ]\+\).*$/\1/p' | sed 's/,/ /g'`

	if [ "$vars" ]
	then

		#
		# variables were specified on the command line
		#

		grep -Eh "^`echo $vars | sed 's/\(\w\) \(\w\)/\1|\2/g'`\s*" $CONF_DEP $PRJ_PTH/$VARS | awk -F= '{print $1 "\t\t" $2}'
	else
		# print all variables set
		awk -F= '{print $1 "\t\t" $2}' $CONF_DEP $PRJ_PTH/$VARS 
	fi

	exit 0
fi

CMD=`echo $* | sed -n "/\s*\(-c\s*[^-]\S\+\|NGINX\|NAGIOS\|DPC\)\s*/s//-c $VARS /p" | sed  's/-h\s\+[^-]\S\+//'`
echo "CMD:   $CMD"

#if [[ $* =~ ^(.+ +)*-s( +.+)*$ ]]



#
# copy public key to the test machine
#

echo "Copying public key on \`$DEP_HOST'..."
cat ~/.ssh/id_rsa.pub | ssh root@$DEP_HOST 'mkdir -p .ssh; cat > .ssh/authorized_keys'


if ! [[ $* =~ ^(.+ +)*-o( +.+)*$ ]]
then

#	run the script
	echo "Copying \`$PRJ' directory to \`$DEP_HOST'..."
	scp -r $PRJ root@$DEP_HOST:/root 1> /dev/null || { echo "failed to copy script"; exit 1; }
	ssh root@$DEP_HOST "cd $PRJ; bash "$SCRIPT $CMD""
else

#	only copy files

	if [ -z ${args=`echo $* | sed -n 's/.*-o \([^-][^ ]\+\).*$/\1/p' | sed 's/,/ /g'`} ]
	then
		echo "\`-o' requires a file list to be copied to \`$DEP_HOST'" >&2 
		exit 1
	else
		scp -r $args root@$DEP_HOST:/root 1>/dev/null && echo "Copied."
	fi
fi
