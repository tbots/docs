#!/bin/bash
#
# Get all the variable names defined in form.
#
# Next step would be to prompt interactively for the form name the user is interested in and
# then display variables related to the specific form.
#
# sed -n '/action\W\+script/,/</form>/p {/\/form/{q}} 
#
# Library should start to be organized.

declare -a forms


# Report array details

function arr_dump(){
	echo "array elements count: ${#forms[@]}"
}


# learn all form action scripts names
#forms=( `sed -n '1,$ {/form/,/action/ s/.*action\W\+\(\S\+\w\).*/\1/p}' $1` )

#arr_dump
sed -n '/input/s/.*name\s*=.\(\w\+\)..*/\1/p' $1
