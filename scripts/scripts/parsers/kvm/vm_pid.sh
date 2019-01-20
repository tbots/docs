#!/bin/bash
#
# Get a list of the virtual machine process id.

ps aux | grep -E `virsh list --name | tr '\n' ' ' | sed 's/ \(\w\)/|\1/g'` | grep -v grep | awk '{print $2}'
