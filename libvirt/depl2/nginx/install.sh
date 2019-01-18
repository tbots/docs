#!/bin/bash
#
# Options:
#
#	rpm dump

cat dep.l | while read line
do

	if [[ $line =~ ^# ]]
	then
		continue
	fi


	package=`echo $line | sed -n 's/\s*\[.*//p'`

	echo -n "package: $package"

	if echo $line | grep --quiet CMD
	#+ CMD 	specifies a command to execute
	then
		$package
	else
		if echo $line | grep --quiet RHL
		# + RHL		install from red hat repositories
		then
			echo -n "\trhl"
			yum install --assumeyes $package || exit 1

		elif echo $line | grep --quiet EPL
		# + EPL		install from epel repositories (allow per installation)
		then
			echo -n "\tepl"
			yum install --assumeyes --enablerepo=epel  || exit 1

		elif echo $line | grep --quiet NGX
		# + EPL		install from epel repositories (allow per installation)
		then
			echo -n "\tnginx"
			yum install --assumeyes --enablerepo=epel  || exit 1

		elif echo $line | grep --quiet PIP
		# + PIP		install via python-pip
		then
			echo -n "\tpip"
			pip install $package || exit 1

		elif echo $line | grep --quiet SRC
		then
		# + SRC 	issues a script for source install of specified package

			echo -n "\tsrc"
			$INSTALLERS/$package

		fi
	fi
done
