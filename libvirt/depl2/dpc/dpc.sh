#!/bin/bash
#
# dpc.sh			DPC deployment script
#
#

TMP=/tmp				# directory for storing downloaded files
#WWW=/var/www		# web2py proper download location
#UNIT_SYSTEM=/etc/systemd/system		# system units directory
#REPO_SYSTEM=/etc/yum.repos.d			# yum repositories directory
#DIR_INI_UWSGI_SITES=/etc/uwsgi/sites/		# uwsgi ini files directory
#DIR_INI_UWSGI=/etc/uwsgi
#DIR_CONF_NGINX=/etc/nginx/
#
#UNIT_UWSGI=~/nginx/conf.files/uwsgi.service	# uwsgi unit file
#INI_UWSGI_WEB2PY=~/nginx/conf.files//web2py.ini
#INI_UWSGI_EMPEROR=~/nginx/conf.files/emperor.ini
#REPO_NGINX=~/nginx/conf.files/nginx.repo			# nginx repo file
#CONF_NGINX=~/nginx/conf.files/nginx.conf			# nginx config file
#
#USER_UWSGI=uwsgi
#USER_NGINX=nginx
#GROUP_NGINX=nginx

YUM_PKG_LIST=yum.l
PIP_PKG_LIST=pip.l

EPEL_RELEASE=http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm 

INSTALL_LOG=/var/log/install.log
ERROR_LOG=/var/log/error.log

if [ $UID -ne 0 ]; then echo "Must be root to run this script"; exit 1; fi

### 	emptying log files 
! test -e $INSTALL_LOG || cat /dev/null > $INSTALL_LOG
! test -e $ERROR_LOG || cat /dev/null > $ERROR_LOG

echo "Configuring repositories..."

### 	installing wget
yum install -y wget &> /dev/null && \
echo -e "wget\t\e[32minstalled\e[0m" >> $INSTALL_LOG \
|| { echo -e "wget:\t\e[31mfailed\e[0m" >> $ERROR_LOG; exit 1; }

### 	creating and switching to temporary directory
test -d $TMP || mkdir $TMP || { echo -e "\e[31mCann't create \`$TMP' directory\e[0m" >> $ERROR_LOG; exit 1; }
cd $tmp &> /dev/null || { echo -e "\e[31mCann't change to \`$TMP'\e[0m" >> $ERROR_LOG; exit 1; }

### epel-release 
CUR_REL=`rpm -qa | grep ^epel`		
if [ $? -eq 0 ]; then
# CUR_REL is the currently installed epel_release

	test `basename --suffix='.rpm' $EPEL_RELEASE` = $CUR_REL &&\
	{ echo "\``basename --suffix='.rpm' $EPEL_RELEASE`' already installed.";
		let $((epel += 1)) } ||\
	{\
	yum remove -y $CUR_REL; \
	rm --verbose -rf $REPO_SYSTEM/epel*; }
fi

if [ -z $epel ]; then
wget $EPEL_RELEASE &> /dev/null || { echo "Cann't download \`$EPEL_RELEASE'" >> $ERROR_LOG; exit 1; }
rpm --install epel-release-7-6.noarch.rpm &> /dev/null && \
echo -e "\``basename $EPEL_RELEASE`':\t \e[32msucceeded\e[0m" >> $INSTALL_LOG || \
{ echo "\``basename $EPEL_RELEASE`':\t \e[31mfailed\e[0m" >> $ERROR_LOG; exit 1; }
rm -v `basename $EPEL_RELEASE` || { echo "Cann't remove \``basename $EPEL_RELEASE`'" >> $ERROR_LOG; exit 1; };
fi

			###		installing required packages

req=`cat $YUM_PKG_LIST`

echo "Installing required packages..."
for pkg in $req; do
	rpm --query --all | grep ^$pkg 1> /dev/null || yum install -y $pkg &> /dev/null &&\
		echo -e "\`$pkg':\t \e[32msucceeded\e[0m" ||\
		{ echo -e "\`$pkg':\t \e[31mfailed\e[0m"; exit 1; }
done


### pip ###

echo -n "Upgrading \`pip'..."
pip install --upgrade pip &> /dev/null && echo -e "\t\e[32msucceeded\e[0m"

req=`cat $PIP_PKG_LIST`
for pkg in $req; do
	rpm --query --all | grep ^$pkg 1> /dev/null || pip install $pkg &&\
		echo -e "\`$pkg':\t \e[32msucceeded\e[0m" ||\
		{ echo -e "\`$pkg':\t \e[31mfailed\e[0m"; exit 1; }
done
