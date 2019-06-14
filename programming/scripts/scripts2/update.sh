#!/bin/bash
#

ROOT_UID=0		# Only users with $UID 0 has a root proveleges.

if [ "$UID" -ne "$ROOT_UID" ]
then
	echo "Must to be root to run this script." >&2
	exit 1
fi

apt-get update -y &&\
apt-get upgrade -y &&\
apt-get dist-upgrade -y
