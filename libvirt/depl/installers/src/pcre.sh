#!/bin/bash

# PCRE library source install 

source ~/opti/scripts/lib
source vars

cd $TMP

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$PCRE_PKG &&\
tar -zxf $PCRE_PKG &&\
cd $PCRE_PKG_DIR &&\
./configure &&\
make &&\
make install &&\
cd $TMP &&\
rm -rf $PCRE_PKG
