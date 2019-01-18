#!/bin/bash

# OpenSSL library source install

source ~/opti/scripts/lib
source vars

if_not_root


wget "http://www.openssl.org/source/$SSL_PKG" &&\
tar -zxf $SSL_PKG &&\
cd $SSL_PKG_DIR &&\
./config darwin64-x86_64-cc --prefix=/usr &&\
make &&\
make install &&\
cd $TMP &&\
rm -rf $SSL_PKG && echo "Done."
