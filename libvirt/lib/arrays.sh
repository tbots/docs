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
