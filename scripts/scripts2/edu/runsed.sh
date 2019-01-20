#!/bin/bash
#
# pickup scriptname from command line

for x
do
	if test ! $file = sedscr; then

		# -s   file exists and has a size greater than zero
		if test -s $x 
		then
			sed -f sedscr $x > /tmp/$x$$
			if test -s /tmp/$x$$
			then
				if cmp -s $x /tmp/$x$xx
				then
					echo "file not changed: "
				else
					mv $x $x.bak		# save original, just in case
					cp /tmp/$x$$ $x	# overwrite original file
					fi
					echo "done."
			else
				echo "sed produced an empty file\c"
				echo " - check your sedscript."
			fi
			rm -f /tmp/$x$$	
		else
			echo "original file is empty."
		fi
	fi
done
echo "all done"
