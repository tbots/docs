#!/bin/bash
#
# EPEL_RELEASE installation script

TMP=/tmp
REPO_SYSTEM=/etc/yum.repos.d

### url
EPEL_RELEASE=http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm 	

CUR_REL=`rpm -qa | grep ^epel`
if [ $? -eq 0 ]; then
# EPEL_RELEASE repo is already installed CUR_REL

	test `basename --suffix='.rpm' $EPEL_RELEASE` = $CUR_REL && {\
	echo "\``basename --suffix='.rpm' $EPEL_RELEASE`' already installed.";
	exit 0; } || {\
	yum remove -y $CUR_REL; \
	rm --verbose -rf $REPO_SYSTEM/epel*; }
fi

### intall wget
rpm -qa | grep -q ^wget || yum install -y wget || { echo "Error installing \`wget'"; exit 1; }

### create /tmp
test -d $TMP || mkdir -v $TMP || { echo "Cann't create \`$TMP' directory"; exit 1; }

### chdir /tmp
cd $TMP || { echo "Cann't change directory to \`$TMP'"; exit 1; }

### download epel_release
wget $EPEL_RELEASE /dev/null || { echo "Cann't download \`$epel_release'"; exit 1; }

### install epel_release
rpm --install epel-release-7-6.noarch.rpm || { echo "Cann't install \``basename $EPEL_RELEASE`'"; exit 1; }

### remove previously downloaded epel_release.rpm 
rm -v `basename $EPEL_RELEASE` || { echo "Cann't remove \``basename $epel_release`'"; exit 1; };
