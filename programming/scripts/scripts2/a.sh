#!/bin/bash

declare -A a			# two dimension

a[0]=oleg
a[0,0]=sergiyuk

a[1]=mirek
a[1,0]=mmm

echo "a[0]: ${a[0]}"
echo "a[0,0]: ${a[0,0]}"
echo "a[1]:		${a[1]}"
echo "a[1,0]: ${a[1,0]}"



# a[0, --->
#							0
#							1
#							2
