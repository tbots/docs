#!/bin/bash
#
# flask installer

#mkdir -p /var/www/lotylda/ 
#cd /var/www/lotylda
#virtualenv lotylda

#yum install --assumeyes epel-release python-pip python-devel gcc gcc-c++ nginx

#pip install --upgrade pip 2>/dev/null
#pip install virtualenv
#pip install uwsgi flask

cp conf.files/lotylda.py /var/www/lotylda
cp conf.files/wsgi.py /var/www/lotylda
