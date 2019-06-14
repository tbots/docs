#!/bin/bash

tags='short_open_tag\|asp_tags'

sed -n "/^\s*$tags/p" /etc/php5/cli/php.ini
