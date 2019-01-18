#!/bin/bash
#
# Options:
#
#	rpm dump

PKG_LST=dep.l

if [[ $# -eq 0 || $* =~ ^(.+ +)*-h( +.+)*$ ]]
then
	echo "Install packages from $PKG_LST"
	echo
	echo "Options:"
	echo "  -l [pattern]        print packages matching pattern"
	echo "  -r [repo]           print packages installed from <repo> or if"
	echo "                      omitted print available repo labels"
	echo "  -h                  print this help and exit"
	echo "  -i                  install packages; if specified with -l or -r install"
	echo "                      packages filtered through pattern or repo"
	echo "  -dump               dump packages status"
	echo "  -dry                dry run; display commands that should be executed" 
fi
# strip the pattern
pattern=`echo $* | sed -n 's/-\w *//gp' | sed 's/\(\w\) \(\w\)/\1|\2/g'`
echo pattern: $pattern

# parse options
for L in `echo $* | sed -n 's/-\(\w\)\([^-]\+ *\)\?/\1 /gp'`
do
	echo "$L|"
	case $L in
		l)			# list packages (optionally matcging pattern)
			if [ "$pattern" ]
			then
					# print all the packages matching pattern
					grep -iE $pattern $PKG_LST | sed 's/\[\|\]//g; s/[[:upper:]]\+/\L\0/'
			else
				sed -n '/^\s*[^#]|^$/! s/\[\|\]//g; s/[[:upper:]]\+/\L\0/'p $PKG_LST
			fi
			;;

		r) 	
			if [ "$pattern" ]
			then
				# print all packages matching repo	

				grep -iwE \\[$pattern\\] $PKG_LST | sed 's/\s*\[.*$//'
			else

				# print available repo labels 

				sed -n 's/.*\[\(.*\)\].*/\1/p' $PKG_LST | sort | uniq
			fi
				 
			let $((repo+=1))		# set the flag; will be used by install option to distinguish
													# raw pattern from the exact repo name
			;;
	esac
done

#### 	dump
#if [[ $* =~ ^(.+ +)*-dump( +.+)*$ ]]
#then
#	cat $list | while read line
#	do
#		package=`echo $line | sed -n 's/\s*\[.*//p'`
#
#		if echo $line | grep --quiet --extended-regexp RHL|EPL|NGX
#		then
#			rpm --query $(echo `sed -n '/^#|^$/! s/\s*\[.*//p' $PKG_LST`)
#
#		elif echo $line | grep --quiet --extended-regexp PIP
#			pip 
#			
#	else
#		
#	exit
#else
#	echo "$list"
#	exit
#fi
#
#	else
#	exit
#fi
#
#	
#cat dep.l | while read line
#do
#	if [[ $line =~ ^# ]]
#	then
#		continue
#	fi
#
#
#	package=`echo $line | sed -n 's/\s*\[.*//p'`
#
#	echo -n "package: $package"
#
#	if echo $line | grep --quiet CMD
#	#+ CMD 	specifies a command to execute
#	then
#		$package
#	else
#		if echo $line | grep --quiet RHL
#		# + RHL		install from red hat repositories
#		then
#			echo -n "\trhl"
#			yum install --assumeyes $package || exit 1
#
#		elif echo $line | grep --quiet EPL
#		# + EPL		install from epel repositories (allow per installation)
#		then
#			echo -n "\tepl"
#			yum install --assumeyes --enablerepo=epel  || exit 1
#
#		elif echo $line | grep --quiet NGX
#		# + EPL		install from nginx repositories (allow per installation)
#		then
#			echo -n "\tnginx"
#			yum install --assumeyes --enablerepo=nginx  || exit 1
#
#		elif echo $line | grep --quiet PIP
#		# + PIP		install via python-pip
#		then
#			echo -n "\tpip"
#			pip install $package || exit 1
#
#		elif echo $line | grep --quiet SRC
#		then
#		# + SRC 	issues a script for source install of specified package
#
#			echo -n "\tsrc"
#			$INSTALLERS/$package
#
#		fi
#	fi
#done
