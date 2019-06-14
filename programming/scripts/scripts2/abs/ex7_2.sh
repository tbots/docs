#!/bin/bash
#

# an if can test any command, not just conditions enclosed within brackets
if cmp f1 f2 & > /dev/null			# suppress output
then echo "Files f1 and f2 are identical."
else echo "Files f1 and f2 differ."
fi

# The very useful "if-grep" construct:
if grep -q Bash file
	then	echo "File contains at least one occurences of Bash."
fi

word=Linux
letter_sequence=inu
if echo "$word" | grep -q "$letter_sequence"
# The "-q" option to grep suppresses output
then
	echo "$letter_sequence found in $word"
else
	echo "$letter_sequence not found in $word"
fi

if COMMAND_WHOSE_EXIT_STATUS_IS_0_UNLESS_ERROR_OCCURED
	then	echo "command succeeded"
	else	echo "command failed"
fi
