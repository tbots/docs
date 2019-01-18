#!/bin/bash
#
# Don't forget password for the user
#
# groups nagios: nagcmd
# deluser nagios
# nagios deployement script

# test if not root
if [ $UID -ne 0 ]; then echo "Must be root to run this script"; exit 1; fi

req="wget git httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip openssl-devel"

echo "Installing required packages..."
for pkg in $req; do
	rpm --query --all | grep ^$pkg 1> /dev/null || yum install -y $pkg 1> /dev/null  || missing=$missing" $pkg"
done

# updating system
#yum update -y

# tmp directory for storing configuration files
tmp=/tmp

# lastest version
url=https://sourceforge.net/projects/nagios/files/nagios-4.x/nagios-4.1.1/nagios-4.1.1.tar.gz

# if /tmp does not exist, create it 
if ! test -d $tmp; then mkdir --verbose /tmp | sed 's/\w*:\s*//; s/\(\w\)/\U\1/'; fi

# chaning directory to $tmp
cd $tmp || { echo "Cann't change directory"; exit 1; }

# download nagios
echo "Downloading `basename $url` to $tmp..."
wget $url &> /dev/null

# report download status
if [ $? -ne 0 ]; then echo 'Bad download completition... exiting...'; exit 1; fi

# create a group
grep nagcmd /etc/group 1> /dev/null || { echo "Creating group nagcmd..."; groupadd nagcmd; }
if [ $? -eq 0 ]; then echo 'Done.'; else echo "Cann't create group for the user... exiting..."; exit 1; fi

# create a user under nagcmd
#
# allow using of useradd.sh
grep nagios /etc/passwd 1> /dev/null 
if [ $? -eq 1 ]
then
	echo "Creating user account for \`nagios'..."
	useradd --create-home --shell /bin/bash -U -G nagcmd nagios 
	if [ $? -ne 0 ] 
	then 
		echo "Cann't create user account for \`nagios'"; exit 1
	fi
fi

#
echo "Configuring `basename --suffix=.tar.gz $url`..."
tar zxvf `basename $url` &> /dev/null || { echo "Cann't extract files."; exit 1; }
rm -rf `basename $url` || { echo "Cann't remove archive"; exit 1; }
cd `basename --suffix=.tar.gz $url` || { echo "Cann't change directory"; exit 1; }
./configure --with-command-group=nagcmd &> /dev/null ||  { echo "./configure --with-command-group=nagcmd : $?"; exit 1; } 
make all &> /dev/null || { echo "error: make all: $?"; exit 1; }
make install &> /dev/null || { echo "error: make install: $?"; exit 1; }
make install-init &> /dev/null || { echo "make install-init: $?"; exit 1; }
make install-config &> /dev/null || { echo "make install-config: $?"; exit 1; }
make install-commandmode &> /dev/null || { echo "make install-commandmode: $?"; exit 1; }
make install-webconf &> /dev/null  || { echo "make install-webconf: $?"; exit 1; }
###
echo "*** Compilation finished ***"

echo "Copying necessary files..."
cp -R contrib/eventhandlers /usr/local/nagios/libexec/

echo "Setting permissions..."
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers

cd ../			# going back to /tmp
if [ `pwd` != $tmp ]; then echo "Jumped to incorrect directory: '`pwd`'"; exit 1; fi

# 
# Installing nagios plugins
#
url=http://nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz

# download nagios
echo "Downloading `basename $url` to $tmp..."
wget $url &> /dev/null || { echo "error downloading `basename $usr`"; exit 1; }

echo "Configuring `basename --suffix=.tar.gz $url`..."
tar zxvf `basename $url` &> /dev/null || { echo "Cann't extract files."; exit 1; }
rm -rf `basename $url` || { echo "Cann't remove archive"; exit 1; }

cd `basename --suffix=.tar.gz $url` || { echo "Cann't change directory"; exit 1; }
./configure --with-nagios-user=nagios --with-nagios-group=nagios &> /dev/null || { echo "./configure --with-nagios-user=nagios --with-nagios-group=nagios: $?"; exit 1; }
make &> /dev/null || { echo "make: $?"; exit 1; }
make install &> /dev/null || { echo "make install: $?"; exit 1; }
echo "*** Compilation finished ***"

echo "chkconfig --add nagios..."
chkconfig --add nagios

echo "chkconfig --level 35 nagios on..."
chkconfig --level 35 nagios on

cd ../			# going back to /tmp
if [ `pwd` != $tmp ]; then echo "Jumped to incorrect directory: '`pwd`'"; exit 1; fi

# Installing NRPE
url=https://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.14/nrpe-2.14.tar.gz

echo "Downloading `basename $url` to $tmp"
wget $url &> /dev/null || { echo "error downloading `basename $usr`"; exit 1; }

echo "Configuring `basename --suffix=.tar.gz $url`..."
tar zxvf `basename $url` &> /dev/null || { echo "Cann't extract files."; exit 1; }
rm -rf `basename $url` || { echo "Cann't remove archive"; exit 1; }

cd `basename --suffix=.tar.gz $url` || { echo "Cann't change directory"; exit 1; }
./configure &> /dev/null || { echo "configure: $?";; exit 1; }
make all &> /dev/null {  echo "make: $?"; exit 1; }
make install-plugin &> /dev/null {  echo "make install: $?"
echo "*** Compilation finished ***"

# configure nagiosadmin
echo -e "\nPlease run\`htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin' to create a password for the echo NAGIOS Core web interface."

cd ../
# report missing packages
if [ $missing ]; then echo "missing packages: $missing"; fi
