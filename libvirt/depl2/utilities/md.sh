#!/bin/bash
#
declare -A init_		# top level context ranges
declare -A s				# listen directive and locations (redirections)

#
# e(): return 0 if application resides on the server
#
function exist() {
	ssh script@$1  "test -d $pth/$rapp &&  { exit 0; } || { exit 1; }"
	return $?
}

# 
# ans(): test for correct input
#
function ans() {
	while ! [[ $a =~ [Yy]([Ee][Ss])?$|[Nn]([Oo])?$|^$ ]]
	do
		echo "Invalid answer $a"
		echo -n "Do you want to overwrite $app directory on $rdr "; read a
	done

	if [[ $a =~ [Yy]([Ee][Ss])?$|^$ ]]
	then
		return 0
	else
		return 1
	fi
}

#
# prs():	report status of the applications
# 
function prs() {
	#ssh script@${s[$i,$m]

	# application path on the remote server
	pth=/home/script/web2py/applications/

	m=1			# m=0 is the listen directive of protocol specified in i
	until [ -z ${s[$i,$m]} ]
	do
		until [ -z ${s[$i,$m]} ]
		do
			app=${s[$i,$m]}
			src=${s[$i,$((m += 1))]}

			ssh script@$src "test -d $pth$app && { exit 0; } || { exit 1; }"
			n=`echo $? | sed 's/0/ok/; s/1/missing/'`

			echo -e "$app $src\t[$n]"
			let $((m += 1))
		done
		let $((i += 1))
	done
}


#
# edmd(): modify file itself
#
function edit() {

echo "writing new entry into file"

# execute ed (script mode)
echo \
"/$rpcl/
/listen[^a-zA-Z_]*$rlst/
/location/
i
	location /$rapp {
		proxy_pass http://$raddr;
	}

.
wq" | ed -s $conf 1> /dev/null
}

#
# app_hl(): 	handles all actions required by application
#
function app_hl() {

	pth=/home/script/web2py/applications		# application remote path

	i=0			# counter reset; start iterating from the first entry stored

	spcl=${pcl[$i]}			# protocol directive under which application resides in file
	slst=${s[$i,$m]}		# listen directive under which application resides in file

	until [ -z $spcl ]
	do
		sapp=${s[$i,$((m += 1))]}		# application name defined in file	
		saddr=${s[$i,$((m += 1))]}	# application address on which it redides defined in file

		until [[ -z $sapp ]]
		do
			#echo "${s[$i,$m]} ${s[$i,$((m += 1))]} ${c_bl}[$s]${c_rst} ${c_rd}[$p]${c_rst}"	|
			#grep -E "^$app" > /dev/null && { app_hl; break; }
			echo "$sapp $saddr [$slst] [$spcl]" | grep ^$rapp && { let $((set += 1)); break 2; }
			
			sapp=${s[$i,$((m += 1))]}		
			saddr=${s[$i,$((m += 1))]}	
		done
		m=0
		spcl=${pcl[$((i += 1))]}
		slst=${s[$i,$m]}		# listen directive under which application resides in file
	done

	if [ ! -z $flags ]
	# action required
	then

		# check if application runs on specified server
		#
		exist "$saddr" || { 
			echo "$rapp does not resides on $saddr";
			echo "Action can not performed.";
			exit 1; }

		if [ ! -z $pmt ] 
		# i (interactive) flag was specified
		then
			exist "$raddr" 
			echo "$rapp directory already exist on $raddr"
			echo -n "Do you want to overwrite it? [y\N]: " 
			read a
			if [ ans "$a" -eq "0" ]; then
				echo "Rewriting..."
			else
				echo "Aborted."; exit 0
			fi
		fi

		# run command on the source server
		#
		ssh script@$saddr "rsync -r -e ssh $pth/$app script@$raddr:$pth 2> /dev/null"

		if [ ! -z $mov ]
		then
			ssh script@$saddr "rm -rf $pth/$app"	
		fi
	else
		# no sence to modify config, till application does not resides on the
		# redirection server; issue an error message and exir
		#
		exist "$raddr" || { echo "$rapp is not resides on $raddr"; exit 1; }
			
		if [ -z $set ]
		then
			if [ -z $rlst ]
			then
				echo "missing remote listen directive"; exit 1
			elif [[ -z $rpcl ]]; then
				echo "missing remote protocol directive"; exit 1
			else
				edit
			fi
		else
			ln=`cat -n $conf | sed -n "/$spcl/,$"p | sed -n "/location.*$rapp/,/$saddr/"p | tail -n1 | awk '{print $1}'`
			sed -i "$ln s/$saddr/$raddr/" $conf
		fi
		nginx -s reload && { echo 'Done.'; }
	fi
	
	exit 0
}

#
# 
function parse_ctx() {

		## write protocol name 
		# +++++++++++++++++++
		#
		s[$i,$m]=`sed -n "$ctx_strt,/listen/"'s/^[^0-9]*\(\([0-9]\+\.\?\)\{4\}\).*/\1/p' $conf`
		let $((m += 1))

		# 
		# start looking for the end of listen directive context
		#
		drv_end=`cat -n $conf | sed -n "$ctx_strt,/}/p" | tail -n1 | awk '{print $1}'`
	
		#
		# find additional opening bracket following context start
		#
		nst_strt=`cat -n $conf | sed -n "$ctx_strt,/{/{$ctx_strt!p}" | tail -n1 | awk '{print $1}'`
	
		#
		# loop till nst_strt is pointing to the nested directive # --
		# exit after nst_strt is beyond closing bracket; at exit drv_end is end of the
		# listen directive context
		#
		while [[ ! -z $nst_strt	&&\
							$nst_strt -lt $drv_end ]]; do
		
			nst_strt=`cat -n $conf | sed -n "$nst_strt,/{/{$nst_strt!p}" | tail -n1 | awk '{print $1}'`
			drv_end=`cat -n $conf | sed -n "$drv_end,/}/{$drv_end!p}" | tail -n1 | awk '{print $1}'`
		done

		#
		# rd is now line address of each location directive in current listen context
		#
		rd=`cat -n $conf | sed -n "$ctx_strt,$drv_end{/\s*location/p}" | awk '{print $1}'`

		for lc in $rd
		do
			#
			# application name
			#
			for app_name in `sed -n "$lc,/}/{s/.*location\W\+\(\w\+\W*\)\s*{.*/\1/p;
																s/^[^0-9]*\(\([0-9]\+\.\?\)\{4\}\).*/\1/p}" $conf`
			do

				s[$i,$m]=$app_name 
				let $((m += 1))
			
			done

			
			#
			# append redirection address to application name
			#


			# 
			# store it into s on index corresponding to current protocol
			# under m, that is current listen directive address
			#
		done

		#
		# find next listen directive following end of the previous listen directive
		# within context examined
		#
		ctx_strt=`cat -n $conf | sed -n "$drv_end,/\s*listen/{/{/p}" | tail -n1 | awk '{print $1}'`

		m=0
		let $((i += 1))
	done
}


#
# flags(): 
#
function flags() {

	# app1[:src][:lst][:pcl]:rdr[:pcl][:flags]
	# app1:rdr:lst:pcl[:flags]

	# test if address is specified in correct format
	echo $rpth | grep -E '^\w+[0-9]*:([0-9]+.){3}[0-9]+' > /dev/null || {
						echo "Incorrect address format"
						exit 1; }

	#
	# application name
	#
	rapp=`echo $rpth | awk -F: '{if ($1 == "") {print "missing application name"; exit 1;}
													else print $1}'` || exit 1

	#	vrt=`echo $rpth | awk -F: '{if ($3 != "") print $3}'`
	#	if [ -z $vrt ]; then
#		echo "vrt not specified"
#	else
#		echo "vrt: $vrt"
#	fi

	# protocol directive
#	spcl=`echo $rpth | awk -F: '{if ($4 != "") print $4}'`
#	if [ -z $spcl ]; then
#		echo "spcl not specified"
#	else
#		echo "spcl: $spcl"
#	fi

	# redirection server address
	raddr=`echo $rpth | awk -F: '{if ($2 == "") {print "missing redirection server address"; exit 1;}
															else print $2}'` || exit 1


	# listen directive name
	rlst=`echo $rpth | awk -F: '{if ($3 != "") print $3}'`
#	if [ -z $rlst ]; then
#		echo "listen directive not specified for redirection"
#	else
#		echo "rlst: $rlst"
#	fi

	# redirection protocol directive name
	rpcl=`echo $rpth | awk -F: '{if ($4 != "") print $4}'`
#	if [ -z $rpcl ]; then
#		echo "protocol directive not specified for redirection"
#	else
#		echo "lst: $lst"
#	fi

	
	init
	app_hl
}

# 
# MAIN  :))) better was written in C, really
#
conf=/etc/nginx/nginx.conf
i=0
a=''
flag=''

if [[ $* =~ ^(-?[a-z]+ )*-h( -?[a-z]+)*$|^$ ]]
then
	echo "Usage: `basename $0` [OPTIONS]..."
	echo "nginx configuration file wrapper script"
	echo "  -r app:srv[:lst][:pcl]         reset redirection information for the application, according to params"
	echo "  -a action                      action can be on of"
	echo "                                   m    will move application from the server currently specified in the file"
	echo "                                        to the server specified by -r option"
	echo "                                   c    will copy application from the server currently specified in the"
	echo "                                        configuration file to the server specified by -r option"
	echo "                                 if  i  argument specified along to action option, confirmation prompt will"
	echo "                                 be issued when application directory exists on redirection server and will be overwrited"
	echo "  -f filename          filename with the redirection information"
	echo "  -l [pattern]         list location directives; pattern can be used to sort output"
	echo "  -c                   query servers about application status"
	echo "  -h                   print usage"
	echo
	echo "Parameters for the -r options has the following syntax: "
	echo "  application:server[:listen][:proto][:flags]"
	echo 
	echo "  server -   new proxy server address for the application"
	echo "  listen -   name of the listen directive under which application will be set in the file"
	echo "  proto  -   name of the protocol directive under which listen directive will reside"
	echo "  flags  -   specify an action along to redirection information"
	echo 
	echo "Flags are as follows: "
	echo "  m   move application from the source server to the new server"
	echo "  c   copy application from the source server to the new server"
	echo "  f   force action (suppress warning when rewriting application directory)"
	echo "  a   append new entry for the application"
	exit 0
fi


until [ -z $1 ]
do
	case $1 in
		-f)	
				echo "read redirection information from the file"
				echo "still not implemented"
				exit 0
				rfl=$2			# file to read redirection from
				echo "rd_fil:\t$rd_fil"
				;;
		-r)
				rpth=$2		# redirection path
				flags			# check flags
				;;
		-a)
				flags=`echo $2 | sed 's/\(\w\)/\0\n/g'`
					case "$flags" in 
						i) let $((pmt += 1));;
						m) let $((mov += 1));;
						c) ;;
						*) echo "unrecognized flag";;
					esac
				;;
		-c)
				let $((check += 1));;
		-l)
				let $((list += 1));;
		-e)
				echo "display existence of all applications on all the servers"
				;;
		 *)
		 		echo "Invalid option or argument: $1" >&2
				exit 1
				;;
	esac
	shift 2 || break
done

init			# initialize all contexts that has listen directive

# reset counters here
i=0; m=0

if ! [ -z $check ]; then
	prs			# report the status of all the applications
elif [ ! -z $list ] 
then

	until [[ -z ${pcl[$i]} ]]
	do
	
		p=${pcl[$i]}			# protocol
		s=${s[$i,$m]}			# listen directive address
		
		let $((m += 1))
	
		until [[ -z ${s[$i,$m]} ]]
		do
			echo "${s[$i,$m]} ${s[$i,$((m + 1))]}"\
					 "${c_bl}[$s]${c_rst}"\
					 "${c_rd}[$p]${c_rst}"	
			let $((m += 2))
		done
	
		m=0; let $((i += 1))
	done
fi
