#!/bin/bash
# 
# find addresses of all locations
#
# 
declare -A dn

conf=/etc/nginx/nginx.conf

# array   directive_name:line number
n=`awk '/{/{print NR}' $conf`

i=0
for l in $n
do
	#
	# read directive name d[0]
	dn[$i]=`sed -n "$l s/^[^a-z]*\([a-z]\+\).*/\1/p" $conf`
	dn[${dn[$i]}]=$l
	let $((i += 1))
done

i=0
until [ -z ${dn[$i]} ]
do
	#	echo "dn[$i]: ${dn[$i]}"
	echo "dn[${dn[$i]}] : ${dn[${dn[$i]}]}"
	let $((i += 1))
done
