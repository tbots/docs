#!/bin/bash
#
# if listen directive is not present, the default address is the current server address

conf=/etc/nginx/nginx.conf

declare -A ADDR

ini=0
IPADDR=$(hostname -I)

# 
# a():		print array elements
#
function a() {
	i=0
	while [ ${SRV[$i]} ]
	do
		echo "SRV[$i]: ${SRV[$i]}"
		let $((i += 1))
	done
}
	
#
# addr():		print ADDR array elements
#
function addr() {
	i=0
	while [ ${ADDR[$i]} ]
	do
		echo "ADDR[$i]: ${ADDR[$i]}:${ADDR[$i,0]}"
		let $((i += 1))
	done
}
	
#
# pp():		returns line number of the bracket closing directive
#
function pp() {
		
	c=1
	
	while [ $c -gt 0 ]
	do	
		if [[ `sed -n "${ALL[$i]}"p $conf` =~ '{' ]]
		then
			let $((c += 1))
		else
			let $((c -= 1))
		fi
	
		let $((i+=1))
	done

	res=${ALL[$((i-1))]}
}

# 
# offset():		count offset in ALL
#
function offset() {

	while [ ${ALL[$i]} -le ${SRV[$l]} ]
	do
		let $((i+=1))
	done

	# on exit ALL[i] is the next bracket found after SRV[l]
}

while getopts ":i:" opt
do
	case $opt in
		i) ini=$OPTARG;;
	esac
done

#
# ALL is now array of line addresses holding any of '{' or '}'
#
ALL=(`awk '/{|}/ {print NR}' $conf`)

i=0; m=0
while [ ${ALL[$i]} ]
do
	
	ADDR[$m]=${ALL[$i]}
	let $((i+=1))
	
	pp
	ADDR[$m,0]=$res
	let $((m+=1))

done

addr

# SRV is now all lines containing server
SRV=(`awk '/^ *server +/ {print NR}' $conf`)

# DEBUG
l=0
while [ ${SRV[$l]} ]
do
	echo "SRV[$l]: ${SRV[$l]}"
	let $((l+=1))
done

i=0		# ALL index
m=1 	# ADDR index
l=0		# SERV index
while [ ${ADDR[$m]} ]
# examine ranges ( ADDR[m]...ADDR[m,0] )
do
	if [ ${SRV[$l]} -lt ${ADDR[$m,0]} ]
	# server directive found within range
	then

		# learn protocol (top level directive)
		proto=`sed -n "${ADDR[$m]} s/\(\w\+\).*/\1/p" $conf`				

		# find index in ALL of the current SRV[$l]
		offset

		# res ls the address of closing bracket of server directive
		pp

		# DEBUG
		echo "[DEBUG] res: $res"

			
		if [ -z ${SERV=$(sed -n "${SRV[$l]},$res {/^\s*listen\s*\([^;]\+\).*/s//\1/p}" $conf)} ]
		# no listen directive specified in the current server directive examined
		then
			# default server address is the current ip address
			echo "no listen directive found"
	 fi
			
		# examine next server directive
		let $((l += 1))
	else
	# examine next range
			let $((m += 1))
	fi
	
	# break if no server directives to examine
	if [ -z ${SRV[$l]} ]; then break; fi
done
