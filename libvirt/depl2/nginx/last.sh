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

# Check if vars file was specified.
if [ -z $VARS ]; then echo "`basename $0`: specify vars file name"; exit 1; fi
# How I'm handeling proxy?

# source variables
export `cat $VARS`

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


# ------
#		NTP
# ------

echo -n "Configuring time....... "
yum install --assumeyes ntp ntpdate ntp-doc 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
systemctl start ntpdate 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
systemctl enable ntpdate 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done."

# --------------
# .bashrc .vimrc
# --------------
echo -n "Copying configuration files.....  "
cp --verbose $CONF_DIR/.vimrc $HOME 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
cp --verbose $CONF_DIR/bashrc $HOME/.bashrc 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done."


# ----------
# 		repos
# ----------
echo -n "Configuring repositories...... "

# epel
yum install --assumeyes epel-release 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# disable 
sed -i '0,/enabled/ {/\(enabled=\).*/s//\10/}' /etc/yum.repos.d/epel.repo 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }


# nginx
cp --verbose $CONF_DIR/$REPO_NGINX $REPO_SYSTEM 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# disable
sed -i '0,/enabled/ {/\(enabled=\).*/s//\10/}' /etc/yum.repos.d/$REPO_NGINX 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }


echo "Done."


#  Installing packages.
echo "Installing packages.... "
cat $PKG_LST | while read line
do

	package=`echo $line | sed -n 's/\s*\[.*//p'`

	echo "\`$package'"

	if echo $package | grep --quiet CMD
	#+ CMD 	specifies a command to execute
	then
		$package 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
	else
		if echo $line | grep --quiet RHL
		# + RHL		install from red hat repositories
		then
		 	yum install --assumeyes $package 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
		elif echo $line | grep --quiet EPL
		# + EPL		install from epel repositories (allow per installation)
		then
			yum install --assumeyes --disablerepo="*" --enablerepo=epel --enablerepo=base $package 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
		elif echo $line | grep --quiet NGX
		# + NGX		install from epel repositories (allow per installation)
		then
			yum install --assumeyes --disablerepo="*" --enablerepo=nginx --enablerepo=base $package 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
		elif echo $line | grep --quiet PIP
		# + PIP		install via python-pip
		then
			pip install $package	1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
		elif echo $line | grep --quiet SRC
		then
		# + SRC 	issues a script for source install of specified package
			$INSTALLERS/$package
		fi
	fi
done
echo "Done."


#  SELINUX 

#echo -n "Configuring SELinux...... "
#setenforce 0	1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#sed -i '/^\s*\(SELINUX=\).*/s//\1permissive/' $CONF_SEL 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#echo "Done."
#
#echo -n "Configuring firewalld........  "
#firewall-cmd --add-service=http --add-service=https 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#echo "Done."

# UWSGI
echo -n "Configuring UWSGI........ "

# /etc/uwsgi/sites
mkdir --verbose --parents $DIR_INI_UWSGI/$SITES_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# EMP_INI #
cp --verbose $CONF_DIR/$EMP_INI $DIR_INI_UWSGI  1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# uwsgi.service #
cp --verbose $CONF_DIR/$UNIT_UWSGI $UNIT_SYSTEM 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
echo "Done."


# /var/www #
test -d $WWW || mkdir --verbose --parents $WWW 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

###		WEB2PY
echo -n "Configuring web2py.......... "
git clone --recursive https://github.com/web2py/web2py.git $WWW/$DIR_2PY 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; } 
cp $WWW/$DIR_2PY/handlers/wsgihandler.py $WWW/$DIR_2PY 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done."


# LOTYLDA #
#cp --verbose --recursive $APP_DIR/$LOTYLDA $WWW/$DIR_2PY/$APP_2PY 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# web2py.ini #
cp --verbose $CONF_DIR/$WEB2PY_INI $DIR_INI_UWSGI/$SITES_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done."

###		FLASK
#echo -n "Configuring flask........... "
#mkdir --verbose $WWW/$DIR_FLSK 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }


# ~~~ APP ~~~
# 								+++			DATA_LOADER 
#cp --verbose --recursive $APP_DIR/$DATA_LOADER $WWW/$DIR_FLSK 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }


# flask.ini #
#cp --verbose --recursive $CONF_DIR/$FLASK_INI $DIR_INI_UWSGI/$SITES_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#echo "Done."

# NGINX
cp --verbose $CONF_DIR/$CONF_NGINX $DIR_CONF_NGINX 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# ------------------------------
# Creating user accounts.
# ------------------------------
#echo -n "Creaing users........ "
#grep --quiet $GID_UWSGI /etc/group || groupadd $GID_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#grep --quiet $UID_UWSGI /etc/passwd || useradd --no-create-home --gid $GID_UWSGI $UID_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#
#grep --quiet $GID_NGINX /etc/group || groupadd $GID_NGINX 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#grep --quiet $UID_NGINX /etc/passwd || useradd --no-create-home --gid $GID_NGINX $UID_NGINX 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#
#echo "Done."


# -------------------
# Setting permissions.
# -------------------
#echo -n "Setting permissions......... "
#chown -R $UID_UWSGI: $WWW 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }
#
#echo "Done"


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

echo "Done."
