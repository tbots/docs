#
# Library of function to manipulate a C source files.
#
# The fnc() function is at the core of the library functionality and is used by various functions to initialize functions array with the functions
# to be processed.
# 
# Variables:
#
#		duplicate       set to 1 if duplication of the element found in array, used by dup()
# 	fn 	   					function name
#		header					header file name; returned by get_lhdr							
#
#

#C_BASE=						base directory to search for a source files

declare -a declarations
declare -a functions
declare -a dfile

source vars


 ###         ###												###           ###
 ###         ###  System library calls  ###           ###
###         ###                        ###           ###


# 
# get_man - copy and unzip man page related to the function 
#
# usage: 				get_man FUNCTION
#
# variables: 		fn		function name for which man page will be searched
#								man		man page name
#
# success:			man page is copied to the current directory 
#               man variable is set to the man page name without extension
# 
function get_man() {

	fname=$1

	test $fname || { echo "function name for the man page was not specified"; exit 1; }

	# find man page location
	man=`whereis -M /usr/share/man/man2 /usr/share/man/man3 -f $fname | grep --only-matching '\S\+$'` 	# pick up last man page

	if [ ! -n "$man" ]
	then
		echo "error: man page for the function '$fn' was not found"
		exit 1
	fi

	# debug
	if [ $debug ]
	then
		echo "In get_man(), searching for man page for the function '$fname'"
		echo "found man page at \"$man\""
	fi

	# copy man page to the current directory
	cp $CMD_ARGS $man .

	# strip full path for gunzip to understand it correctly
	man=`basename $man`

	# unzip man page 
	gunzip --force $man

	# modify man page name for the further search of the include directives

	# find extension
	ext=${man/*./.}

	# strip extension
	man=`basename $man $ext`
}




#
# Populates lines array with the line numbers where include statements were
# found in the man page.
#
# usage:      get_inc  FUNCTION STATEMENTS[] 
#
#	variables:	fn				function name
#							line			line number of the first function declaration in a man page
#							man				man page of the function
#             statement include statement found within man page
#							lines[]		lines where include statements were found
#							li				tracks last index in lines[]
#							bl				tracks "before last" index in lines[]
#							
#
# calls:			get_man		copy man page of the function call
#
# success:		updated headers[] array with all include statements needed by a
#             function
#
#
function _inc() {
	
	local -a statements
	local -a lines
	local line

	# debug 
	if [ $debug ]
	then
		echo "In _inc():"
		echo "fn: $fn"
	fi

	fname=$fn						# default man page for the function
	until [ $line ] 		# until line where function is declared not found
	do 
		# get man page for the function
		get_man $fname

		# find line number of the first declaration of the function 
		line=`grep --max-count=1 --line-number $man -e "^[^a-z]*\([a-z_*]\+\s*\)\{1,2\}\<$fn\>\s*([^)]\+\();\)\?" | awk -F: '{print $1}'`

		if [ ! $line ]			# fprintf(3); 
		then
			fname=`sed -n "/\.so/ s/.*\/\(\w\+\)\..*/\1/p" $man`			# linked man page

			if [ $debug ]
			then
				echo "linked function name: $fname"
			fi
		fi
	done

	if [ $debug ] 
	then echo "function found at: $line"
			 echo "function definition: `sed -n "$line p" $man`"
			 echo "include statements preceding the function:"
			 sed -n "1,$line p" $man | grep --line-number '#include'	
	fi 

	# get an array of all the line numbers where include statements were found before the actual function declaration
	lines=( `sed -n "1,$line p" $man | grep --line-number '#include' | awk -F: '{print $1}'` )

	# set up first search range
	li=1		# -$li is the last index in include
	bl=2 		# -$bl is the index before last element index in include

	while [ $bl -le ${#lines[@]} ]
# while it is a range to examine
	do
			# debug
			if [ $debug ]
			then echo "examining range in between:"
					 echo "-$bl element: ${lines[-$bl]}"
					 echo "-$li element: ${lines[-$li]}"
					 echo ""
			fi

			# start of the search range 
			start=${lines[-$bl]}

			# end of the search range 
			end=${lines[-$li]}
		
			# debug
			if [ $debug ]
			then 
				echo "searched portion of the file"
				echo "----------------------------"
				sed  -n "$start,$end p" $man
				echo -e "----------------------------\n"
			fi

			# examine range in between two include statements; if found another
			# function declaration, include on index of bl belongs to another function
			# and should not be learned
			sed -n "$start,$end p" $man | grep --quiet '^[^a-z]*\(\S\+\s*\)\{2\}(' 


			# check exit status of grep
			
			if [ $? -eq 0 ]; then
	
			# another function declaration found
			
				if [ $debug ]
				then 
					echo "Another function declaration was found:"
					echo "`sed -n "$start,$end p" $man | grep --color '^[^a-z]*\(\S\+\s*\)\{2\}('`"
					echo 
				fi
				break; 	# stop search; li index is the last to be learned
			fi

			# be ready to process next range
			let li=(bl++)
	done

	if [ "$debug" ]
		then echo "index in the end of loop: $li -> ${lines[-$li]}"
	fi
		
	# convert to positive index
	let "li=(${#lines[@]} - $li)"; 
		
	# only lines to be processed
	lines=( "${lines[@]:$li}" )


	# learn include statements on the specified lines
	for line in ${lines[@]}
	do
		# get include statement
		statement=`sed -n "$line s/.*\(\#include\)\s*\(<\S\+>\).*/\1 \2/p" $man`

		# debug 
		if [ $debug ] 
		then 
			echo "include statement: '$statement'"
		fi

		statements+=( "$statement" )

	done
	

	# check statment for the duplicity and if uniq store it to headers[]
	# save it to headers
	for statement in "${statements[@]}"
	do
		dup "$statement" headers[@] 
		if [ ! $duplicate ] 
		then

			# debug 
			if [ $debug ]
			then
				echo "include statement '$statement' was not written yet"
			fi

			headers+=( "$statement" )

		else

			# debug 
			if [ $debug ]
			then
				echo "include statement '$statement' was already stored to be written."
			fi
		fi

	done

	# debug
	if [ $debug ]; then
		arr_d headers[@]
	fi

	# delete man page
	if [ ! $keep ] 
	then
		rm $CMD_ARGS $man
	fi
}





 ###         ###												###           ###
 ###         ###  Local function calls  ###           ###
###         ###                        ###           ###

# Create link to the file if not in current directory if not in current directory
function link_file() {
		if [ $debug ]
		then
			echo "in link_file(); checking if need to link $file..."
		fi
		test -e `basename $file` || ln --symbolic $CMD_ARGS $file .
}

# Link source files into current directory
function link_src_files() {

	recurse_files		# init files array
	for file in ${files[@]}
	do
		if [ $debug ]
		then
			echo "creating link to $file"
		fi
		link_file
	done
	exit 0
}



# List files recursively
function list_src() {
	recurse_files 
	arr_d files[@]
	exit 0
}

function recurse_files() {

	while [ ${files[$i]} ]
	do 
		file=${files[$i]}

		if [ $debug ]
		then
			echo "processing file: $file"
		fi

		recurse_file
		((i++))
	done 
}


# Find files recursively, depends on the function calls. Add each file
# that is function source code to the functions[].
#
function recurse_file() {
	fnc --local
	for fn in ${functions[@]}
	do
		if [ $debug ]
		then	
			echo "in recurse_file()"
			echo -e "processing function '$fn'\n"
		fi
		_dfile
	done

	if [ $debug ]
	then
		echo "in recurse_file()"
		arr_d files[@]
	fi
}


#
# Find header with function definition.
function get_lhdr() {
	
	# try to find a header that declares a function; the last wins; think what gonna happen if it is multiple headers?
	header=`grep --with-filename "^\s*\w\+\s*\**\s*$fn\s*(.*;" {/usr/include,/usr/local/include,$C_INCLUDE_PATH,.}*.h 2> /dev/null | tail -n 1 | awk -F: '{print $1}'` 
	if [ $debug ]
	then
		echo "in get_lhdr()"
		echo -n "header file for the '$fn' function"
		if [ $header ]
		then
			echo ": $header"
		else
			echo " was not found"
		fi
	fi
}

#
# Find a header that declares the local function call.
# Search for local headers in the current directory and C_INCLUDE_PATH.
#
# usage:      find_lhdr FUNCTION HEADER HEADERS[@]
#
# variables:  fn        function name
#             header    header file name
#             HEADER    default header name
#
# success:    updated headers[] array
#
function _lhdr() {

	# Debug
	if [ $debug ]
	then
		echo "in _lhdr"
		echo "C_INCLUDE_PATH: $C_INCLUDE_PATH"
	fi

	get_lhdr		# set header

	# header file for the function was not found
	if [ ! $header ]	
	then

		# debug
		if [ $debug ]
		then
			echo "header was not found" 
		fi

		if [ $HEADER ]		# use default header if one was specified
		then
			if [ $debug ]
			then
			 echo "using a default one - \"$HEADER\""
			fi
			# set header to the one specified by an option 
			header=$HEADER
		fi
	else
		# debug
		if [ $debug ]
		then
			echo "in find_header()"
			echo "$header is the header file that declares the function $fn"
			echo ""
		fi
	fi


	if [ $header ]			# header was found or set
	then
		# set to #include "$header"
		header=${header/*/#include \"$header\"}
	
		# debug 
		if [ $debug ]
		then
			echo "modified header: $header"
			echo "checking for the duplication in the headers[]..."
		fi
	
		# check for the duplicated header file
		dup "$header" headers[@]
	
		if [ ! $duplicate ]
		then
			# debug
			if [ $debug ]
			then
				echo "statement '$header' was not written yet"
			fi
	
			# append local header to the headers array
			headers+=( "$header" )
	
		else
			# debug
			if [ $debug ]
			then
				echo "header file $header_file was already included"
			fi
		fi
	else
		if [ $debug ]
		then
			echo "header file for the function '$fn' was not found"
		fi
	fi
}
			

# Popuate declarations[] with the function declarations found in file. Used by header_wr.
#
# usage:				_dec FILE
#
# variables:		file							file name to learn declarations from
#								declarations[] 		function declarations
#
# success:			declarations[]
# 
function _dec() {
	
	if [ $debug ]; then
		echo "in _dec()"
		echo "searching declarations in $file"
		echo -e "declarations found: "
		sed -n '/\<\(while\|main\|if\|else\)\>/! s/^\s*\(\w\+\>\)\s*\(\**\)\s*\([a-zA-Z_]\+\)\s*\((.*)\)\s*{\?\s*$/\1 \2\3\4;/p' $file
	fi

	# store new declarations
	while IFS='\n' read -r line;
	do
		declarations+=( "$line" )
	done < <(sed -n '/\<\(while\|main\|if\|else\)\>/! s/^\s*\(\w\+\>\)\s*\(\**\)\s*\([a-zA-Z_]\+\)\s*\((.*)\)\s*{\?\s*$/\1 \2\3\4;/p' $file)
		

	# Debug
	if [ $debug ]
	then
		arr_d declarations[@]
	fi
}

#
# Find file that declares function call. Expects function name on input. Special variable $C_BASE can be set to search for C source files.
# 
# usage:      _dfile FUNCTION
#
# variables:  fn      function name
#							multi_file
#             dfile[] declaration file(s) 
#    
# success:    files[]
#
function _dfile()
{
	
	test $fn || fn=$1

	# debug 
	if [ $debug ]
	then 
		echo "in _dfile()"
			echo "C_BASE: $C_BASE"
			echo -e "source files found\n`\
			grep --recursive --binary-files=without-match "^\s*\w\+\s*\**\s*$fn\s*([^;]*\({.*\)\?$" {$C_BASE,.} | sed '/return/d'`\n"
	fi
			
	# find file that declares function
	dfile=( `grep --files-with-matches --binary-files=without-match --recursive "^\s*\w\+\s*\**\s*\<$fn\>\s*([^;]*\({.*\)\?$" {$C_BASE,.} |\
					 sed '/return/d'` )
		
	if [ ${#dfile[@]} -eq 0 ]
	then
		echo "file that declares $fn was not found"
		exit 1

	elif [ ${#dfile[@]} -eq 2 ]
	then
		# in which case two files are accepted?
		test ${dfile[0]} -ef ${dfile[1]} || ((multi_file++))
		dfile=`basename ${dfile[0]}`

	elif [ ${#dfile[@]} -gt 2 ]
	then
		((multi_file++))
	fi

	if [ $multi_file ]
	then
		echo "multiple files declares function $fn"
		exit 1
	fi

	# here all the tests that ensure the existense of the declaraion file
	# are handled

	# check if file that declares the function was already stored
	dup ${dfile[0]} files[@]		
	
	if [ ! $duplicate ] 
	#
	# file that declares the function was not stored yet
	then
	
		# debug 
		if [ $debug ]; then
			echo -e "$dfile was not stored yet..storing for the further parsing\n"
		fi
	
		# store file in the files array to be parsed after
		files+=( $dfile )		
	else

		# debug
		if [ $debug ]; then
			echo -e "file $dfile was already stored\n"
		fi
	fi
}


#
# Create header file.
#
# usage: create_hdr files[@]..
#
function create_hdr() {
	header_wr
	recurse_file
}


#
# Write include statements and header file if specified.
#
#
function editc() {

	declare -a headers
	#
	fnc; for fn in ${functions[@]}
	do
		# debug
		if [ $debug ]
		then
			echo "in editc()"
			echo "processing function: $fn"
		fi

		if whatis $fn &> /dev/null		# system call
		then
			_inc 			#include statements from the man page will be added to headers[]
		else
			_lhdr			# header file found will be added to headers[]
			if [ $recursive ]
			then 
				_dfile		# function source file found will be added to files[]
			fi
		fi
	done

	if [ $debug ]
	then
		echo "in editc()"
		echo "all the function in file '$file' are processed"
		arr_d headers[@]
	fi

	inc_wr
	header_wr	
	if [ $recursive ]
	then
		link_file
	fi
}



 ###         ###			    	        ###           ###
 ###         ###   Function Calls   ###           ###
###         ###                    ###           ###


# Populate functions[] with the function names found in the file. 
#
# Fucking get from here everything!
function fnc() {
	call=$1

	unset functions

	for fn in `sed 's/\/\s*\*[^*]*\*\s*\///g; /\/\s*\*/,/\*\s*\//d;' $file |\
								# delete comments part
						grep -o '\(^\s*\|[;(!+=]\s*\)\w\+\s*(' | grep -o '\w\+' | sort -u |\
								# dump function names and filter through unique
						sed '/if\|while\|for\|main\|switch\|sizeof/d'` 
								# delete C keywords 
	do
		case "$call" in
			local )	whatis $fn &> /dev/null || functions+=( $fn );;
			system)	whatis $fn &> /dev/null && functions+=( $fn ) ;;
			all|'')	functions+=( $fn ) ;;
			*     ) echo "call: $call"; echo "in fnc(): invalid call specification (should be one of all/local/system)"
							exit 1;;
		esac
	done
	
	if [ $debug ]
	then
		echo "in fnc()"
		arr_d functions[@]
	fi
}

# Print out all the function calls found in a file
#
function lfnc() {

	fnc $call		# init

	echo -e "$file\n---"	# formatting
	for fn in ${functions[@]}
	do
		echo " $fn"
	done

	if [ ${#files[@]} -ne 1 ]		# print new line to separate each file
	then
		echo ""	
	fi
}


 ###         ###									 ###           ###
 ###         ###   Edit Files      ###           ###
###         ###                   ###           ###



# include directives 

function inc_wr() 
{
	# Debug
	if [ $debug ]
	then
		echo -e "\nin inc_wr()"
	fi

	line=`cat -n $file | grep '#include' | tail -n1 | awk '{print $1}'`
	if [ $line ]
	then
		# Debug
		if [ $debug ]
		then
			echo "include directive found; inserting on the line '$line'"
		fi

		((line++))
	else

		# Debug
		if [ $debug ]
		then
			echo "include statement was not found; searching for the define directive"
		fi

		line=`cat -n $file | grep --max-count=1 '/#define/' | awk '{print $1}'`
		if [ $line ]
		then
			((line--))
			if [[ $line -eq 0 ]]
			then
				line=1
			fi
			
			# Debug
			if [ $debug ]
			then
				echo "define directive was found; writing at line '$line'"
			fi
		else

			# Debug
			if [ $debug ]
			then
				echo "define directive was not found, searching for the first commented part: */"
			fi

			line=`cat -n $file | grep --max-count=1 '^\s*[0-9]\+.*\*\/' | awk '{print $1}'`
			if [ $line ]
			then
				((line++))

				# Debug
				if [ $debug ]
				then
					echo "first uncommented part was found; writing at line '$line'"
				fi
			else
				line=1

				# Debug
				if [ $debug ]
				then
					echo "first uncommented part was not found; writing at line '$line'"
				fi
				
			fi
		fi
	fi
	
	# Debug
	if [ $debug ]
	then
		echo "in inc_wr()"
		arr_d headers[@]
	fi

	for header in "${headers[@]}"
	do
		if [ $debug ]
		then
			echo "in inc_wr()"
			echo "processing header '$header'"
		fi

		if ! grep --silent "$header" $file
		then
			if [ $debug ]
			then
				echo "inserting new header: \"$header\""
			fi
			sed -i "$line i\\$header" $file
			((line++))
		else
			if [ $debug ]
			then
				echo "header \"$header\" was already included"
			fi
		fi
	done

	if sed -n "$line p" $file | grep --silent --invert-match '^\s*$'
	then
		echo -e "$line\ni\n\n.\nwq\n" | ed --silent $file 2> /dev/null
	fi

	if [ $debug ]
	then
		echo -e "***\n"
	fi
}
		

#
# Write header file for the function declarations found in a file.
#
function header_wr() {
	
	if [ $debug ]
	then
		echo "in header_wr()"
	fi

	_dec
	
	if [[ $action = editc || $HEADER ]]
	then

		if [ $HEADER ]
		then
			if [ -f $HEADER ]
			then
				sed --in-place '/^\s*$/d' $HEADER
			else
				touch $HEADER
			fi
		fi

		for declaration in "${declarations[@]}"
		do
			fn=`echo $declaration | sed -n 's/^\w\+\s\(\w\+\).*/\1/p'`
			if [ $debug ]
			then
				echo "processing declaration: '$declaration' for the function '$fn'"
			fi

			if [[ $action = editc ]]
			then
				get_lhdr
				if [ $header ]
				then
	
					# Debug
					if [ $debug ]
					then
						echo "header file for the function '$fn' already exists"
						echo "rewriting declarations, do not create a new header ..."
					fi
		
					sed --in-place "/\<$fn\>/ c\\$declaration" $header
					continue
				fi
			fi
	
			if [ $HEADER ]
			then
				if [ $debug ]
				then
					echo "writing default header '$HEADER'"
					echo "searching for the '$fn' function declaration"
				fi
				if grep --silent "$declaration" $HEADER
				then
					if [ $debug ]
					then
						echo "declaration for the '$fn' was already stored in the '$HEADER'"
						echo "rewriting it..."
					fi
					sed --in-place "/$fn/ c\\$declaration" $HEADER
				else
					if [ $debug ]
					then
						echo "declaration for the '$fn' was not found in '$HEADER'"
						echo "appending at the end"
					fi
					echo -e "$\ni\n$declaration\n.\nwq\n" | ed --silent $HEADER 2> /dev/null
				fi
			fi
		done
	fi
}


			
	
	


 ###         ###									   ###           ###
 ###         ###   Array Functions   ###           ###
###         ###                     ###           ###



# Find out if ELEMENT was already stored in ARRAY. If found duplicate
# is set to 1.
function dup() {
	test -n "$1" -a "$2" || { echo "usage: dup element array"; exit 1; }
	element=$1; array=$2
	unset duplicate		# reset duplicate before the check

	for e in "${!array}"
	do
		if [[ $e = $element ]]		# literal match
		then 
			((duplicate++)); break
		fi
	done
}


# Debug functions. Array library functions.

# Print members of the array.
function arr_d() {
	test -n "$1" || { echo "usage: arr_d array"; exit 1; }

	if [ $debug ]
	then 
		echo "elements of '$1' array:"
	fi

	for el in "${!1}"
	do	
		echo "$el"
	done

	if [ $debug ]
	then
		echo""
	fi
}
