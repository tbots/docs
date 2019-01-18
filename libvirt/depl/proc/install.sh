#!/bin/bash
#
# install procedure

PKG_LST=dep.l
eval "`sed -n  '/RHL/s/\(\S\+\)\s.*/yum install -y \1/p;\
	  /EPL/s/\(\S\+\)\s.*/yum install --enablerepo=epel -y \1/p;\
	  /PIP/s/\(\S\+\)\s.*/pip install \1/p;\
	  /CMD/s/\s*\[.*$//p' $PKG_LST`"
