#!/bin/bash

# ZLIB library source install

source ~/opti/scripts/lib
source vars

wget http://zlib.net/$ZLIB_PKG &&\
tar -zxf $ZLIB_PKG 			   &&\
cd $ZLIB_PKG_DIR 			   &&\
./configure 				   &&\
make 						   &&\
make install 				   &&\
cd $TMP 					   &&\
rm -rf $ZLIB_PKG			   &&\

echo "Done."
