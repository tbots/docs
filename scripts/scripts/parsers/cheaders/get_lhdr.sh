#!/bin/bash

source c.sh
grep --with-filename "^\s*\w\+\s*\**\s*usage\s*(.*;" {/usr/include,/usr/local/include,$C_INCLUDE_PATH,.}*.h 2> /dev/null #|\ tail -n 1 |\ awk -F: '{print $1}'

fn=usage
debug=1
get_lhdr 
