#!/bin/bash
#
# umod.sh				allows to modify uwsgi values
#
# -o  regexp 		will open ini file matched 
# work on delete option
# 

UNIT_UWSGI=/etc/systemd/system/uwsgi.service

function usage() {
	echo "Usage; `basename $0` [OPTIONS]... FILE"
	echo "uwsgi() wrapper."
	echo "Options:"
	echo "  -e [arg]     if no arg specified display emperor option"
	echo "               arguments, otherwise set it"
	echo "  -d [arg]     delete one instance of \`--emperor argument', arg is used"
	echo "               as a search pattern to find an instance that should be deleted, if"
	echo "               no args were specified, interactive prompt is issued"
	echo "  -f file      specify a file name to operate on"
	echo "  -u [uid]       print or set uid value in file"
	echo "  -g [gid]       print or set gid value in file"
	echo "  -p [file]    print file contents to the stdout"
	echo "  -v           print verbose information"
	echo
	echo "FILE is the file where the change is requested"
	exit 
}

# print usage if `-h'
if [[ $* =~ \
		^(.+ +)*-h( +.+)*$ ]]; then usage; fi

if [[ $* =~ ^(.+ +)*-p( +.+)*$ ]]
then
	cat $UNIT_UWSGI; exit
fi

# file
if [[ $* =~ ^(.+ +)*-f( +.+)*$ ]]
then

	if [[ -z ${file=`echo "$*" | sed -n 's|.*-f \+||; /^[^ ]\+/p'`} ]]
	then
		echo "missing file argument"
		exit 1
	fi
fi

if [[ $* =~ ^(.+ +)*-e( +.+)*$ ]]
then

	if test ${arg=`echo "$*" | sed -n 's|.*-e \+||; /^[^- ]\+/p'`}
	then
	# specified argument
		sed -i.tmp "s|\(emperor \+\)[^; ]\+|\1$arg|" $UNIT_UWSGI
	else
		for L in `grep -Eo 'emperor +[^;| ]+' $UNIT_UWSGI | awk '{print $2}'`
		do
			echo -e "\e[4m$L\e[0m"
		done
	fi
fi

# uid
if [[ $* =~ ^(.+ +)*-u( +.+)*$ ]]; then

	if test ${arg=`echo "$*" | sed -n 's|.*-u \+||; s/^\([^- ]\+\).*/\1/p'`}
	then
	# specified argument
		sed -i "s|\(^uid *= *\).*|\1$arg|" $file
	else

		echo -en "\e[4muid\e[0m:\t"
		if grep -q -w uid $file
	 	then
	 		sed -n 's/^ *uid *= *\([^; ]\+\)[; ]*/\1/p' $file 
	 	else
	 	 	echo "not set"
	 	fi
	fi
fi

# gid
if [[ $* =~ ^(.+ +)*-g( +.+)*$ ]]; then
	 echo -en "\e[4mgid\e[0m:\t"
 	 if grep -q -w gid $file
	 then
		 sed -n 's/^ *gid *= *\([^; ]\+\)[; ]*/\1/p' $file 
	 else
	 	 echo "not set"
	 fi
fi
#else
#	echo "`basename $0`: no emperor option was set" >&2
#	exit 1
#fi
