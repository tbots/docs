#!/bin/bash
#
# NGINX WEB2PY FLASK UWSGI deployment script

### -c vars
if [[ $* =~ ^(.+ +)*-c( +.+)*$ ]]
then
	VARS=`echo $* | sed -n 's/.*-c \+\([^-]\S\+\).*$/\1/p'`
	if [ $VARS ]
	then 
		test -e $VARS || { echo "\`$VARS' is not exist" >> $ERROR_LOG; exit 1; }
	else
		echo "`basename $0`: vars file name need to follow \`-c' option"; exit 1
	fi
fi	

### -p proxy
if [[ $* =~ ^(.+ +)*-p( +.+)*$ ]]
then
	PROXY=`echo $* | sed -n 's/.*-p \+\([^-]\S\+\).*$/\1/p'`
	if [ -z $PROXY ]
	then 
		echo "`basename $0`: proxy server address need to follow \`-p' option"; exit 1
	fi
fi	

# source variables
source $VARS

# reset logs location
INSTALL_LOG=$LOG_DIR/$INSTALL_LOG 
ERROR_LOG=$LOG_DIR/$ERROR_LOG


# empty logs
! test -s $INSTALL_LOG || cat /dev/null > $INSTALL_LOG
! test -s $ERROR_LOG || cat /dev/null > $ERROR_LOG


## VAR=VAL,...
for L in `echo $* | grep -Eo "[[:upper:]]+(_[[:upper:]]+)?=\S+"`
do
	eval $(echo $L | awk -F= '{print $1}')=$(echo $L | awk -F= '{print $2}')
done

echo -n "Copying configuration files.....  "
cp --verbose $CONF_DIR/.vimrc $HOME 1>> $INSTALL_LOG 2>> $ERROR_LOG || EX=1
cp --verbose $CONF_DIR/bashrc $HOME/.bashrc 1>> $INSTALL_LOG 2>> $ERROR_LOG || EX=1 
test $EX -eq 0 && echo "Done." || { echo "Failed."; exit 1; }

echo -n "Configuring repositories...... "
yum install --assumeyes epel-release 1>> $INSTALL_LOG 2>> $ERROR_LOG || EX=1
sed -i '0,/enabled/ {/\(enabled=\).*/s//\10/}' /etc/yum.repos.d/epel.repo 1>> $INSTALL_LOG 2>> $ERROR_LOG || EX=1
test $EX -eq 0 && echo "Done." || { echo "Failed."; exit 1; }

#  Installing packages.
echo -n "Installing packages.... "
cat $PKG_LST | while read line
do

	package=`echo $line | sed -n 's/\s*\[.*//p'`

	if echo $package | grep --quiet CMD
	then
		$package 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
	else
		if echo $line | grep --quiet RHL
		then
		 	yum install --assumeyes $package 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
		elif echo $line | grep --quiet EPL
		then
			yum install --assumeyes --enablerepo=epel $package 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
		elif echo $line | grep --quiet PIP
		then
			pip install $package	1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
		fi
	fi
done
echo "Done."

#  SELINUX 

echo -n "Configuring SELinux...... "
setenforce 0	1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
sed -i '/^\s*\(SELINUX=\).*/s//\1permissive/' $CONF_SEL 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
echo "Done."

echo -n "Configuring firewalld........  "
firewall-cmd --add-service=http --add-service=https 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
echo "Done."

# UWSGI
echo -n "Configuring UWSGI........ "
groupadd $GID_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
useradd --no-create-home --gid $GID_UWSGI $UID_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

mkdir --verbose --parents $DIR_INI_UWSGI/$SITES_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

cp --verbose $CONF_DIR/$EMP_INI $DIR_INI_UWSGI  1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

cp --verbose $CONF_DIR/$UNIT_UWSGI $UNIT_SYSTEM 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
echo "Done."


###		WEB2PY
echo -n "Configuring web2py.......... "
test -d $WWW || mkdir --verbose --parents $WWW 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
git clone --recursive https://github.com/web2py/web2py.git $WWW/$DIR_2PY 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; } 
cp $WWW/$DIR_2PY/handlers/wsgihandler.py $WWW/$DIR_2PY 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
cp --verbose --recursive $APP_DIR/$LOTYLDA $WWW/$DIR_2PY/$APP_2PY 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
cp --verbose $CONF_DIR/$WEB2PY_INI $DIR_INI_UWSGI/$SITES_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
echo "Done."

###		FLASK
echo -n "Configuring flask........... "
mkdir --verbose $WWW/$DATA_LOADER 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
cp --verbose --recursive $APP_DIR/$DATA_LOADER $WWW/ 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
cp --verbose --recursive $CONF_DIR/$FLASK_INI $DIR_INI_UWSGI/$SITES_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
echo "Done."

### 	NGINX
echo -n "Configuring NGINX........... "
cp --verbose $CONF_DIR/$CONF_NGINX $DIR_CONF_NGINX 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
echo "Done."

# -------------------
# Setting permissions.
# -------------------
echo -n "Setting permissions......... "
chown -R $UID_UWSGI: $WWW 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done"


# ------------------
# Configure services.
# ------------------
echo -n "Starging UWSGI.......... "
systemctl start uwsgi 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; } 

echo "Done."

echo -n "Starting NGINX......  "
systemctl start nginx 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; } 

echo "Done."

echo -n "Configuring system startup....... "
systemctl enable uwsgi 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
systemctl enable nginx 2>> $ERROR_LOG | tee -a $INSTALL_LOG || { echo "Failed."; exit 1; }
