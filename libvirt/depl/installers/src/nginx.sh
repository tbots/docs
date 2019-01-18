#!/bin/bash

# NGINX 	source install

wget http://nginx.org/download/$NGINX_PKG
tar -zxf $NGINX_PKG
cd $NGINX_PKG_DIR

./configure --with-debug \
	    --prefix=/etc/nginx \
	    --sbin-path=/usr/bin \
	    --conf-path=nginx.conf \
 	    --pid-path=logs/nginx.pid \
	    --error-log-path=logs/error.log \
	    --http-log-path=logs/access.log \
	    --user=nginx \
	    --user=nginx \
	    --with-http_ssl_module \
	    --with-pcre=$TMP/$PCRE_PKG_DIR \
	    --with-pcre-jit \
	    --with-zlib=$TMP/$ZLIB_PKG_DIR \

make
make install
