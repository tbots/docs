#!/bin/bash
#
# Configuration file parser. $2 accepts expression to filter file through (see lib file for the default expression used).
#

source lib
set_cf config

conf_vars $config
