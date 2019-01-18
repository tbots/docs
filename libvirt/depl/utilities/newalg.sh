#!/bin/bash
#
# if listen directive is not present, the default address is the current server address

declare -A ADDR

IPADDR=$(hostname -I)
conf=/etc/nginx/nginx.conf

i=0			# ALL
m=0			# ADDR

ALL=(`awk '/{|}/ {print NR}' $conf`)

while [ ${ALL[$i]} ]
do
	ADDR[$m]=${ALL[$i]}

	c=1
	while [ $c -gt 0 ]
	do	
		let $((i += 1))
		echo "ALL[$i]: ${ALL[$i]}"
		if [[ `sed -n "${ALL[$i]}"p $conf` =~ '{' ]]
		then
			let $((c += 1))
		else
			let $((c -= 1))
		fi
	done

	ADDR[$m,0]=${ALL[$i]}
	let $((i += 1,m += 1))
done

m=0
while [ ${ADDR[$m]} ]
do
	echo "ADDR[$m]:   ${ADDR[$m]} : ${ADDR[$m,0]}"
	let $((m += 1))
done

function pp() {
	
	while [ ${ALL[$i]} -lt ${SRV[$l]} ]
	do
		let $((i += 1))
	done

	c=1
	while [ $c -gt 0 ]
	do	
		let $((i += 1))
		if [[ `sed -n "${ALL[$i]}"p $conf` =~ '{' ]]
		then
			let $((c += 1))
		else
			let $((c -= 1))
		fi
	done

	SRV_END=${ALL[$i]}
}
	

# 
# Read line numbers starting server directive
#
SRV=(`awk '/^\s*server +/ {print NR}' $conf`)
LC=(`awk '/^\s*location +/ {print NR}' $conf`)
echo "Locations: "
for L in ${LC[@]}
do
	echo "|$L"
done

i=0		# ALL index
m=1 	# ADDR index
l=0		# SERV index
n=0
while [ ${ADDR[$m]} ]
# examine ranges ( ADDR[m]...ADDR[m,0] )
do
	while [ ${SRV[$l]} -lt ${ADDR[$m,0]} ]
	# server directive found within range
	do

		# learn protocol (top level directive)
		proto=`sed -n "${ADDR[$m]} s/\(\w\+\).*/\1/p" $conf`				

		### 	DEBUG
		echo "[DEBUG] proto: $proto"
		# -------------------------------------
		# Find closing server address directive.
		# -------------------------------------
		pp
		
		
		# -----------------
		# Find server name.
		# -----------------
		server_name=`sed -n "${SRV[$l]},$SRV_END {/^\s*server_name\s\+\(\S\+\);.*/s//\1/p}" $conf`

		### 	DEBUG
		echo "[DEBUG] server_name: $server_name"

		# --------------------------
		# Find listend diretive name.
		# --------------------------
		listen=`sed -n "${SRV[$l]},${SRV[$l,0]} {/^\s*listen\s*\(.*\);.*$/s//\1/p}" $conf`

		while [ ${LC[$n]} -lt $SRV_END ]
		do
			echo "$proto   $server_name   $listen"
			echo " : ${LC[$n]}"
			
			i=0
			while [ ${ALL[$i]} -lt ${LC[$n]} ]
			do
				let $((i += 1))
			done

			c=1
			while [ $c -gt 0 ]
			do	
				let $((i += 1))
				if [[ `sed -n "${ALL[$i]}"p $conf` =~ '{' ]]
				then
					let $((c += 1))
				else
					let $((c -= 1))
				fi
			done

			echo "LC[$n]: ${LC[$n]} : ${ALL[$i]}"

			# location pass
			URI=`sed -n "${LC[$n]},${ALL[$i]}"p $conf | awk '/location/ {print $2}'`

			# socket
			socket=`sed -n "${LC[$n]},${ALL[$i]} {/^\s*\w\+pass\s*/s///p}" $conf | sed -n 's/\s*;\s*//p'`

			###		DEBUG
			echo "[DEBUG] socket:   $socket"

			# ----------------
			# Find socket port.
			# ----------------

			if [ ${port=`echo $socket | awk -F: '{print $2}'`} ]
			# Port found. Strip it from the socket address.
			then
				socket=`echo $socket | sed -n "/:$port/s///p"`
			fi

			echo " $URI    $socket    $port     $server_name    $listen    $proto"

			let $((n += 1))

			if ! [ ${LC[$n]} ]; then break; fi
		done

		if ! [ ${SRV[$((l+=1))]} ]; then break; fi
	done

	let $((m += 1))

done

		
#		if [ -z ${SERV=$(sed -n "${SRV[$l]},${ALL[$i]} {/^\s*listen\s*\([^;]\+\).*/s//\1/p}" $conf)} ]
#		# no listen directive specified in the current server directive examined
#		then
#			# default server address is the current ip address
#			echo "no listen directive found"
#	 fi
#			
#		# examine next server directive
#		let $((l += 1))
#	else
#	# examine next range
#			let $((m += 1))
#	fi
#	
#	# break if no server directives to examine
#	if [ -z ${SRV[$l]} ]; then break; fi
#done
