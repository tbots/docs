#!/bin/bash

echo $@
shift;
echo $@
echo "${@:1:2}"
echo ${@:2:3}
