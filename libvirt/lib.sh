# 
# Functions library.
#
# Functions listed within library (lib):
#
# if_not_root						exit if UID is not equal to 0 (root)
#	err 									print error message; prepended by 'error: '
#	find_disks 						need to be tested
#	create_log_files 			need to be tested
#	apt 									mistery
#	conf_vars							display all the variable definition strings within configuration file
#	show_char							show character on position (|char|
#	char_pos							find position of the character within string
#	include_optional_prompt	
#												run prompt to choose directory specified by the IncludeOptional directive
#												can raise further to the script that allows specification of the directive name
#	set_vars							set variable to value

# used by conf_vars()
VARIABLE_INDENT=20
COMMENT_INDENT=60
COMMENT_SYMBOL='[C]'


# Test for the root UID.
#
function if_not_root() {
	if [ $UID -ne 0 ]; then	
		echo "Must be root to run this script." >&2
		exit 1
	fi
}


#	Print an error message
#
function err() {
	echo "error: $1" >&2
	exit 1
}


# 	find disks
#
function find_disks() {
	for L in `fdisk -l | sed -n '/^Disk \(\/.*[^0-9]\):.*/s//\1/p'`
	do
		echo "$L"
	done
}


# Create INSTALL_LOG and ERROR_LOG variables with the {script}.install.log and {script}.error.log
# respectively. Empty files.

function create_log_files() {
	export INSTALL_LOG=$LOG_DIR/`basename -s .sh $0`.install.log 
	export ERR_LOG=$LOG_DIR/`basename -s .sh $0`.error.log 

	test -e $INSTALL_LOG && cat /dev/null > $INSTALL_LOG
	test -e $ERR_LOG && cat /dev/null > $ERR_LOG
	
	echo "INSTALL_LOG: $INSTALL_LOG"
	echo "ERR_LOG: $ERR_LOG"
}

#
# NO idea
function apt() {
	
	# 
	echo "[DEBUG]   reading package list from the \`$DEP/dep.`basename -s .sh $0`'"

	#

	$INSTS -o "$DEP/dep.`basename -s .sh $0`" 1>> $INSTALL_LOG 2>> $ERR_LOG || { echo "Failed."; exit 1; } 
}


# Print configuration file variables
#
# $1 pattern			'.'
# $2 commented		'[ \t]'
# $3 CONF

function conf_vars() {
	if test "${!1}" 
	 then	pattern=`echo ${!1} | sed 's/\(\w\) \(\w\)/\1\\|\2/'`
	 else pattern='.'
	fi
	test "$2" || commented='[ \t]'
	test "$3" || { echo "configuration file was not specified";
									exit 1; }
	CONF=$3
	sed --silent "/^$commented*[A-Z]\w\+\(\s\+\S\+\)\{1,2\}$/ { /$pattern/ { /#/s/^\W\+\(.*\)/\1\t[C]/; s/^\s*\(\w\+\)\s*/\1\t/p; } }" $CONF
}

# Display character on position surrounded by the "|" delimiter.
# Parameters:
#		$1	search string
#		$2  character position
#
function show_char(){
	string=$1
	pos=$2
	echo $string | sed "s/`echo ${string:$pos:1}`/|\0|/"
}

# Find character position withing string.
# Parameters:
#		$1 search string
#		$2 character to be searched
#
# Depends on:
#		show_char
#
function char_pos(){
	string=$1
	search_char=$2
	i=0	
	for char in `echo $string | grep -m1 -o '\w'`
	do
		[ $search_char == $char ] &&
			{ 
				show_char "$string" "$pos";
				 break;
		  }
		((pos+=1))
	done
}

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

# Prints spaces calculated from the difference of the string length and the total count set.
# Parameters:
#		$1		string
#		$2		total spaces count (100)
#		$3		optional text to print after spaces
function indent(){
	test "$1" || { echo "missing parameter in indent()" ; exit 1; }
	test "$2"   && total=$2 || total=100			# default spaces count
	spaces=$((total - ${#1}))		# default total value - length of the string specified by $1
	echo -n "$1"		#	print string without a new line
	while [ $((spaces--)) -gt 0 ]; do		# print spaces
		echo -n " "
	done
	echo -en "$3"			# optional string to print if it was set; does not print new line by default
}
# Get configuration file variables.
#
# $1 			pattern
# $2 			config file
# $3      debug flag
#
# First file is filtered with grep with the pattern that defines a variable string descritption.
# Commented line will set comment symbol. First var is set to the variable name and printed using indent().
function conf_vars() {

	# set debug flag
	debug=$3

	# find lines that defines a variable
	grep "$1" $2 | while read var_line
	do
		if [[ $var_line =~ ^\ *\# ]] 			# commented line
		then
			comment_symbol="[C]\n"		# set comment symbol
		fi

		# DEBUG #
		if [ $debug ]
		then
			echo "[DEBUG] processing |$var_line|"
		fi

		# Get variable name part
		var=`echo $var_line | sed 's/^\s*#\?\s*\(\w\+\(\(\s\+\S\+\)*:\)\?\).*$/\1/'` # s/://'`

		# DEBUG #
		if [ $debug ]; then
			echo "[DEBUG] var: $var"
		fi

		# print variable name with the whitespace indent
		indent "$var" "$VARIABLE_INDENT"	


		# get the value; all the rest of the string
		val=`echo $var_line | sed "s/$var:\?\s*//"`

		# DEBUG #
		if [ $debug ]; then
			echo "[DEBUG] val: $val"
		fi

		# Commented line will be printed out following indented $comment_symbol
		if [ $comment_symbol ]
		then
			indent  "$val" "$COMMENT_INDENT" "$comment_symbol"
			unset comment_symbol		# unset $comment_symbol for the next line
		else
			echo "$val"			# do not calculate indent for the not commented line
		fi
	done
}
