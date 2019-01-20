#!/bin/bash
#
# Run as root. Copy executable files to the /usr/local/bin.

sudo mkdir /etc/sh/
sudo cp lib /etc/sh

declare -a files=( hdr.sh )
cd /usr/local/bin
for file in ${files[@]}
do
	test ! -e $file || sudo unlink $file		# unlink file if exist
	sudo ln --symbolic $OLDPWD/$file .
done
