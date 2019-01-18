#!/bin/bash
#
#		WEB2PY

test -d /var/www || mkdir /var/www
cd /var/www
git clone --recursive https://github.com/web2py/web2py.git 
cd web2py
cp handlers/wsgihandler.py .
