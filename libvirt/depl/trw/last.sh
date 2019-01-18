#!/bin/bash
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  BENESHOV DEPLOYMENT SCRIPT
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#		All variables easly modified via set.sh.
#   
#		Directories:
#		-----------
#
#				1. PRJ/conf.files/				- configuration files to be copied to the system
#
#
# 	Script flow:
#		-----------
#
#				1. Processing command line options
#							-c <vars file>
#							-p <proxy address>
#
#				   * if vars file was not specified or not found, script will fall
#				   * if proxy address was specified, http_proxy variable will be set for the
#						 current session
#
#				2. Export variables to environment
#				
#				3. Reset logs location. Script starts within PRJ directory and since LOG_DIR refers
#					 to the log directory and INSTALL_LOG, and ERROR_LOG to install.log and error.log 
#					 respectively it is more convenient to retransform it to $LOG_DIR/$<NAME_LOG> (log/<name.log>)
#					 as scipt referes to this locations constantly.
#
#				4. Truncate logs. If logs files was not empty (test -s) truncate all the data.
#
#				5. Process remained command line arguments. Any match to VAR=VAL found will
#					 set VAR to VAL for the current session.
#
#				6. Copying vimrc file to /etc/vimrc
#
#				7. Configuring repositories
#
#				  7.1 Installing epel-release. After installation will be disabled.
#					7.2 Copying nginx.repo file. Disabling nginx repository.
#				
#				8. Installing packages. Packages read from PKG_LST and divided into sections:
#					- RPM			will use only default system repo
#					- EPL			will disable all repos except of def and epel
#					- NGX			will disable all repos except of def and nginx
#					- SRC			will start source installers (INSTALLERS)
#					- CMD			will issue the command
# 
#				9. UWSGI configuration
#					- Creating /etc/uwsgi/sites directory
#					- Copying emperor.ini under /etc/uwsgi
#					- Copying uwsgi.service file under /etc/systemd/system
#					
#				10. Configuring frameworks
#					- Creating /var/www directory
#					- Downloading web2py from   to /var/www
#					- Moving wsgihandler.py from /var/www/web2py/handlers to /var/www/web2py
#					- Copying CONF_DIR/2PY_INI to /etc/uwsgi/sites
#				
#				11. Configuring NGINX
#					- Copying nginx.conf to /etc/nginx/
#
#				12. Creating user accounts
#						- create UID_NGINX under GID_NGINX
#						- creaet UID_UWSGI under GID_NGINX
#
#				13. Setting permissions
#						- change owner of WWW as UID_UWSGI:GID_NGINX
#				
#				14. Configuring services
#						 - start uwsgi
#						 - start nginx
#						 - enable uwsgi
#						 - enable nginx


# DEFAULTS
#
# Environment file. Can be passed to script with -c.
# 
VARS=vars

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
	export $L
done


# ------
# .vimrc
# ------
echo -n "Copying \`vimrc'...... "
cp --verbose --force $CONF_DIR/$VIMRC $DIR_VIMRC 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done."


# ----------
#	repos
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


# web2py.ini #
cp --verbose $CONF_DIR/$WEB2PY_INI $DIR_INI_UWSGI/$SITES_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done."

# NGINX
cp --verbose $CONF_DIR/$CONF_NGINX $DIR_CONF_NGINX 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# ------------------------------
# Creating user accounts.
# ------------------------------
echo -n "Creaing users........ "

# user:			nginx		group:		nginx
grep --quiet $UID_NGINX /etc/passwd || useradd --no-create-home --gid $GID_NGINX $UID_NGINX 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

# user:			uwsgi		group:		nginx	
grep --quiet $UID_UWSGI /etc/passwd || useradd --no-create-home --gid $GID_NGINX $UID_UWSGI 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

echo "Done."


# -------------------
# Setting permissions.
# -------------------
echo -n "Setting permissions......... "

# dir:	/var/www	:		user: uwsgi			group:	nginx
chown -R $UID_UWSGI:$GID_NGINX $WWW 1>> $INSTALL_LOG 2>> $ERROR_LOG || { echo "Failed."; exit 1; }

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

echo "Done."
