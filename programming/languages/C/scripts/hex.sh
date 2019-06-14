#!/bin/bash
#
# hex.sh
#
# When debugging a program, the desired result is to embed assembler dump with the source code.
# Each time found an instruction that modifies a stack pointer, stack will be printed inside the 
# source file.
#
# The hex.sh takes two arguments of filename (-o) and an address (-a) and modifies already existent
# addresses.
# 

# Options parsing.
#
# -o 		filename
# -a    address
#
while [ "$1" ]; do
	case $1 in
		'-o')	
			
			filename=$2;
			test -e $filename || { echo "\`$filename' does not exist" >&2; exit 1; }
			shift
			;;

		'-a')
			address=$2;
			# test address format
			shift
			;;

		#'-i')			# interactive mode; first display changes and propmt for appliance
			#;;
	esac	
	shift
done

echo "filename: $filename"
echo "address: $address"
# test for a filename existence
test "$filename" || { echo "no file name specified" >&2; exit 1; }

# initialize n to 1; the first line number
n=1

# initialise step to 0; step offset for the first memory address encountered
step=0

# store last line address
eof=`wc -l $filename | awk '{print $1}'`

# find the line number of the very first line containing memory address
n=`sed -n "$n,/^\s*0x[0-9a-fA-F]/{p;=}" $filename | tail -n1`

# store the memory address found on line n
m=`sed -n "$n {s/.*\(0x[0-9a-fA-F]\+\).*/\1/p}" $filename`
initial_address=$m

echo "eof: $eof"
while [ "1" ]; do
 
	# calculate lines that has a continious addresses 
	c=`sed -n "$n,$ {/$m/,/[0-9a-fA-F]/p}" $filename | wc -l`
	echo "c: |$c|"

	echo "step: $step"

	while [ "$c" -ne "0" ]; do
		sed -n "$n {/0x[0-9a-fA-F]\+/s//`printf "0x%08x" $((address + step))`/p}" $filename
		let $((step += 0x04, n += 1, c -=1))
	done

	# reset step
	step=0

	# find the line number of the next line containing memory address
	n=`sed -n "$n,/^\s*0x[0-9a-fA-F]/{p;=}" $filename | tail -n1`
	echo "n: |$n|"
	test $n || break;		# end of file or no addresses

	# store the memory address found on line n
	m=`sed -n "$n {s/.*\(0x[0-9a-fA-F]\+\).*/\1/p}" $filename`

	if [ "$initial_address" != "$m" ] 
	then 	
		let $((step = $m - $initial_address ))
	fi
	
done
