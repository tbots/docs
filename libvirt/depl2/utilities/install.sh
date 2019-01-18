#!/bin/bash
#
# print repositories name along to status
# test for already installed packages and write the log
# allow verbose output
#

#rpm --query `awk '!/PIP|CMD/ {print $1}' ../dep.l` 2> /dev/null
#awk '!/PIP|CMD/ {print $1}' ../dep.l

function usage() {
	echo "Usage: `basename $0` [OPTIONS]..."
	echo "Print and modify epel.repo status."
	echo
	echo "Options:"
	echo "  -l file [src]   list packages specified in a file"
	echo "  -i filename     install packages specified in file"
	echo "  -g              generate a package list found on the system"
	echo "  -e 0|1          set value of enable if /etc/yum.repos.d/epel.repo"
	echo "  -o filename     output filename to store package listing dump"
	echo "  -h              print usage and exit"
	exit 0
}

	while getopts ":hi:g:o:e:" opt
	do
		case $opt in
	
		# generate a package list #
	
			i)	
				eval "`sed -n \ '/RHL/s/\(\S\+\)\s.*/yum install -y \1/p;\
									 /EPL/s/\(\S\+\)\s.*/yum install --enablerepo=epel -y \1/p;\
									 /PIP/s/\(\S\+\)\s.*/pip install \1/p;\ 
									 /CMD/s/\s*\[.*$//p' $OPTARG`"
					
				exit ;;

				
			g)
				PKG_LST=$OPTARG
				let $((GEN += 1))
				;;
	
			o)
				FILE=$OPTARG;;
			
			e)	
					if [[ $OPTARG =~ 0|1 ]]
					then
						sed -i "0,/enabled/ {/\(enabled=\).*/s//\1$OPTARG/}" /etc/yum.repos.d/epel.repo
						exit 0
					else
						echo "Invalid value -- \`$OPTARG'" >&2 
						exit 1
					fi
					;;
			h)
					# print usage and exit
					usage;;
	
			*)
					echo "Invalid option -- \`$OPTARG'" >&2
					exit 1 ;;
		esac
			
	done

if [ $GEN ]
then
	if [ $FILE ]
	then
		rpm --query `awk '!/PIP|CMD/ {print $1}' $PKG_LST` > $FILE
	else
		rpm --query `awk '!/PIP|CMD/ {print $1}' $PKG_LST`
	fi
fi

# print enabled status
echo -e "[\e[4mepel.repo\e[0m]"
echo " `grep -m1 enabled /etc/yum.repos.d/epel.repo`"
# install packages
