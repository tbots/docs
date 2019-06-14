#!/bin/bash
#echo 192.164.133.84 | grep -E --color=always '^.*([0-9]+.){3}[0-9]+\s*$' &&\

# match octets digits
#  number that occurs one or three times following a dot
#  or that raises till the end of the line
#

address=$1
echo "address: $address"
echo $address | grep -E --color=always -w '1([0-9]){0,2}\.\|2' && echo "matched" || echo "not matched"



#grep -E --color=always --word-regexp '[0-2]{1}([0-5]{1,3}\.){3}[0-9]{1,3}' &&\
#															128
