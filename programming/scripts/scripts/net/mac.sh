#!/bin/bash

 hexchars="0123456789ABCDEF"
	  echo "52:54:00$( for i in {1..6}; do echo -n ${hexchars:$(( $RANDOM % 16 )):1}; done | sed -e 's/\(..\)/:\1/g' )"
