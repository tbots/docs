#!/bin/bash


# NTP installation and configuration

source ~/opti/scripts/lib
source vars

if_not_root
dep.ntp

systemctl start ntpdate 1> /dev/null
systemctl enable ntpdate 1> /dev/null
