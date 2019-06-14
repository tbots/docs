#!/bin/bash
#
# Prints Python keywords
#
# 

# still doesn't prints correct
python kwl.py | sed -e 's/[[:punct:]]*\(\w\+\)*[:punct:]*\s*/\1\n/g'
