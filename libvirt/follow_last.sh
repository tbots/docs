#!/bin/bash
#
# tail -f last modified file in the provided directories

tail -f $1/`ls -t1 $1 | head -n2 | tail -n1`
