#!/bin/bash
#
# Install nginx from source.
#
# Get rid from hardcoded values.
#


yum install --assumeyes epel-release openssl-devel gcc gcc-c++ wget ntp ntpdate ntp-doc

#
# NTP
#
systemctl start ntpdate
systemctl enable ntpdate 
cd /tmp

#
# NGINX
wget http://nginx.org/download/nginx-1.10.1.tar.gz
tar -zxf nginx-1.10.1.tar.gz

#
# PCRE
#
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
tar -zxf pcre-8.37.tar.gz

#
# ZLIB
#
wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxf zlib-1.2.8.tar.gz


###	Installing NGINX	###
cd nginx-1.10.1
./configure --with-debug \
	    --prefix=/etc/nginx \
	    --sbin-path=/usr/bin \
	    --pid-path=/var/run \
	    --error-log-path=/var/log/nginx \
	    --http-log-path=/var/log/nginx \
	    --user=nginx \
	    --user=nginx \
	    --with-http_ssl_module \
	    --with-pcre=/tmp/pcre-8.37 \
	    --with-zlib=/tmp/zlib-1.2.8

make
make install
