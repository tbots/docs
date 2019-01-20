#!/bin/bash
#
# Parse php.ini file.
#
# Tags of interest:
#		short_open_tag = [On|Off]
#	  asp_tags = [On|Off]
#
# 1. Check for case-sensivity.

PHP_INI=/etc/php5/cli/php.ini

tags='short_open_tag\|asp_tags'

function usage() {
	echo "`basename $0`: [OPTIONS]... [FILE]..."
	echo "Display php configuration file variables. If value for the variable was omitted, current value from the "
	echo "configuration file will be printed."
	echo "Options"
	echo "  -T, --tags            			 		 show tags related variables"
	echo "      --short-open-tag[=On|Off]    set short open tag variable"
	echo "      --asp-tags[=On|Off]					 set asp tags variable"
	echo "      --help                       print this help and exit"
	exit 0
}

if [ $# -eq 0 ]; then
	usage
else
	while [ "$1" ]
	do
		case $1 in 
			--help)
				usage
				;;

			--short-open-tag|--asp-tags)
				
				# convert --short-open-tag to short_open_tag
				tag=`echo $1 | sed -n '/^--/s///; {s/-/_/g;p}'`
				if [[ $2 =~ ^(-|$) ]]; then	
				  sed -n "/^\s*$tag\s\+=\s\+\(\S\+\).*$/s//$tag\t\1/p" $PHP_INI
				 else
					if [[ $2 =~ ^(On|Off)$ ]] 
					 then
						echo 'replacing'
						#sed --in-place "/^\s*\($tag\).*/s//\1 = $2/" $PHP_INI
					 else
					 	echo "\`$2' illegal value"
						exit 1
					fi
					shift
				fi
				;;

			-T|--tags)

				echo 'hit here?'
				sed -n "/^\s*\($tags\)\s\+=\s\+\(\S\+\).*$/s//\1\t\2/p" $PHP_INI
				;;

			-*)
				echo "invalid option - \`$1'" 1>&2
				exit 1
		esac
		shift
	done
fi
