#!/bin/bash
#
# Install ntp service.

yum install --assumeyes ntp ntpdate ntp-doc 1> /dev/null
systemctl start ntpdate 1> /dev/null
systemctl enable ntpdate 1> /dev/null
