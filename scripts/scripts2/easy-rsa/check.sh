#!/bin/bash
#
# test 

EASY_RSA=/etc/openvpn/easy-rsa/2.0
cd $EASY_RSA

if [ `pwd` != $EASY_RSA ]
then
	echo Cann\'t switch to \`$EASY_RSA\' directory >&2; exit 1
fi

# if [ -exist $EASY_RSA/keys ]
# then
