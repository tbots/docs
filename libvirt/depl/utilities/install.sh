#!/bin/bash 	
# 
# Install packages specified in *.dep files
#
# Supported flags:
#
#	[SRC]		bash $SRC_DIR/$li

source $LIB

if_not_root

echo "[DEBUG] in $0"
echo "[DEBUG] INSTALL_LOG:   $INSTALL_LOG"
echo "[DEBUG] ERR_LOG:   $ERR_LOG"

while [ "$1" ]; do
	opt=$1; shift
	case $opt in
		'-o')
			if ! test -e ${DEP_FILE=$1}; then err "\`$DEP_FILE' does not exist"; fi; shift;;
		*)
			err "invalid option \`$opt'"
	esac
done 

if [ -z $DEP_FILE ]; then
	err "deployment file not specified"
fi

eval "$( sed -n '{ 
		s/\(.*\)\s*\[BLD_DEP.*/apt-get build-dep -y \1/p
		s/\(.*\)\s*\[APT.*/apt-get install -y \1/p 	}' $DEP_FILE )" 1>> $INSTALL_LOG 2>> $ERR_LOG || { echo "Failed."; exit 1; }
