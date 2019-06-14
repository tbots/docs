#!/bin/bash
# single.sh
#
# Since even the escape character (\) gets a literal interpretation within single quotes, trying to
# enclose a single quote within single quotes will not yield the expected result.
#
var1=5
echo "Why can't I write 's between single qutoes."

# The roundabout method.
echo 'Why can'\''t I write '"'"'s between single quotes'
#		 |-------|  |----------|   |-----------------------|
# Three single-quoted strings, with escaped and quoted single quotes between.

echo \'				# Escaped metameaning of `'', just a '
# echo '			# Looking for matchin `''

echo 'Why can'\'
echo 'Why can \''
