#!/bin/bash

echo -n "Enter a file name: "; read FILE
echo -n "Enter repo: "; read REPO
echo -n "Enter package name: "; read PKG
echo "$PKG" >> $FILE.l
