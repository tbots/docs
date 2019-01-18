#
# Functions and definitions used by parsers.
# 

source expr.sh.l

# constants 

# space indent 

VAR_IND=40							# variable
COM_IND=50							# comment


# Any function can use check_vars() wrapper to check if variable 
# it expects was passed. check_vars() will test $1 variable, and
# if empty will print error message specified by $2 variable 
# and exit with exit status of 1.
function check_vars(){
	test -n "$1" || { echo "$2"; exit 1; }
}

# Get full path of the apache configuration file. Retrieved path will be stored in $1.
#
# Usage: set_cf FILENAME
#
function set_cf(){

	# Check for variable name to hold an apache configuration file path.
	#
	check_vars "$1" "in set_cf(): missing configuration file name"

	out=`\
	apachectl -V 2>/dev/null |
	sed -n '/HTTPD_ROOT\|SERVER_CONFIG_FILE/ s/.*"\(.*\)".*/\1/p' |
	tr '\n' '/' |
	sed 's/\/$//'\
	` 
	eval $1="'$out'"
}

#
# Print $1 (variable) following by $2 - ${#1} spaces. New line is not printed.
# 
function indent(){
	spaces=$(($2 - ${#1}))
	f="$1"
	while [ $((spaces--)) -gt 0 ]; do
		f="$f "
	done
	echo -n "$f"
}

# 
# Print configuration file variables.
#
# Usage: conf_vars FILE [EXPR]
# 
function conf_vars() {

	# Construct expression.
	test $2 || exp='^\s*\w\+'

	# Read matched lines into line array.
	grep -i $exp $1 | while read -a line
	do 		
	# Print variable name followed by space indent.
	#
		indent "${line[0]}" "$VAR_IND" 	
	#
	# Print value part (all the rest of the string).
	#
		echo "${line[@]:1}"	
	done
}

#
# Get apache configuraion file accepted directives list.
#
function get_directive_list(){
	url=curl\ https://httpd.apache.org/docs/2.4/mod/directives.html
	eval $1="'$(echo `curl $url 2> /dev/null | sed  -n '/<div.*directive-list/,/<\/dir/ {/a/ s/.*>\(\w\+\)<.*/\1/p}'`)'"
}

#
# Print out ServerRoot directive value. $2 is the reference if specified.
# Function should evolve to:
#
# 	server_root file variable 
#
# The value returns in the variable.
#

# Convert dir/f1 dir/f2 output to dir/{f1,f2}.
function chain_glob(){
	base=`dirname ${dir[0]}`
	eval $2=`echo ${dir[@]} | sed "/ / {s/$base\///g; s/ /,/g; s/.*/$base\/{&}/}"`
}

function print_cf(){
	set_cf config
	echo "Configuration file: $config"
}

function set_root(){
		
	# Get ServerRoot
	serverroot=`grep -i '^\s*serverroot' $config | awk '{print $2}' | sed 's/"//g'`
	if [ -z $serverroot ]; then
		serverroot=`apachectl -V | sed -n 's/.*HTTPD_ROOT="\(.*\)".*/\1/p'`
	fi
}
