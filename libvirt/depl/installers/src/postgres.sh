#!/bin/bash

source $LIB

if_not_root
create_log_files

cp --verbose $PGDGR $REPO_DIR \
	1>> $INSTALL_LOG 2>> $ERR_LOG || { echo "Failed."; exit 1; }

wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
	1>> $INSTALL_LOG 2>> $ERR_LOG || { echo "Failed."; exit 1; }

apt-get update \
	1>> $INSTALL_LOG 2>> $ERR_LOG || { echo "Failed."; exit 1; }

apt
echo "Done."
