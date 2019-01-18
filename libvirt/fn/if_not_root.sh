#
# Test for the root UID(0).
#
function if_not_root() {
	if [ $UID -ne 0 ]; then	
		echo "Must be root to run this script." >&2
		exit 1
	fi
}
