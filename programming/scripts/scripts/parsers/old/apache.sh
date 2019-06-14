#!/bin/bash
#
# apache configuration file parser
#

source lib


# Learns IncludeOptional directives.
#
function include_optional_prompt() {
	for DIR in $(dirname `sed -n '/IncludeOptional\s*/s///p' $APACHE_CONF` | uniq)		# only directory name sites-enabled{/*.conf} 
	do
		echo "[$((i+=1))] ${IncludeOptional[$i]=$DIR}"
	done
	echo -e "\nPlease choose a directory:"
	read i
	DIR=${IncludeOptional[$i]}
	i=0			# reset $i for the further prompts
}

# Display prompt of the files in a directory.
# Parameters:
#		$1		search directory
#
function file_selection_prompt(){
	error_on_not_exists "$1" "-d"
	cd $1					# change directory?
	echo "Please choose selection for the configuration file: "
	for FILE in `ls`; do
		echo "[$((i+=1))] ${CONF[$i]=$FILE}"
	done
	read i
	conf_vars "$pattern" "$commented" "${CONF[$i]}"	
}

# ports.conf
function port() {
	sed -n '/\s*Listen\s*/s///p' ports.conf
}

# Issue a prompts for the directories specified by the Include Optional directive and files in within.
#
function include_optional(){
	include_optional_prompt
	file_selection_prompt "$DIR"
}

# DOES NOT WORK or work...
# ...tired
#
function set_vars(){
	test "$2" || 
			{ echo "configuration file was not specified";
				exit 1; }
	CONF=$2
	i=0
	while [[ ${!1:$i} ]]
	do
		variable=${vars[$((i++))]}
		value=${vars[$((i++))]}

		echo "variable: $variable"
		echo "value: $value"
		#sed -n "/^\s*\<$variable\>/ s/\S\+/$value/2p" $CONF
	done
}


# Print usage and exit with exit code of 0.
#
function usage() {
	echo "Usage: `basename $0 .sh` [OPTIONS]... [VAR"
	echo "apache2.conf parser. By default prints all the variables from the /etc/apache2/apache2.conf."
	echo ""
	echo "  --include-optional                list \`IncludeOptional' directives"
	echo "  --sites-enabled                   list enabled sites details (jumps over IncludeOptional)"
	echo "  --port                            port bindings"
	exit 0
}

########
# MAIN #
########

while [ $1 ]; do
	case $1 in
		--include-optional)   action=include_opional
													;;
		--sites-enabled)			action=sites_enabled ""		 
													;;

		--port)               port ""							 
													;;

		--set )							 	action='set_vars vars[@] $CONF'
													;;

		--commented)					((commented++))
													;;

		-h)										usage
													;;

		-*) 									echo "invalid option: \`$1'" >&2 
													usage
													;;

		[a-zA-Z]*)						vars=$vars\ $1
													;;

	esac
	shift
done


set_cf config		# set config to the apache configuration file path

if [ ! "$action" ]; then
	action='conf_vars $config $exp'	
fi

if [ ! "$vars" ]; then 			# no directive names were specified on the command line
	get_directive_list vars		# get the list of all the apache directives
fi
vars=`echo $vars | sed 's/ /\\\|/g'`
exp="^\s*\w*\($vars\)\w*\(\s\+\S\+\)\+\s*$"

if [ "$commented" ]; then
	exp=${exp/\\s\*/\\s*#*\\s*}
fi

# DEBUG
#echo "vars: $vars"
echo "exp: '$exp'"; 
#exit

eval "$action"
