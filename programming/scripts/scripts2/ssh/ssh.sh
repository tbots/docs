#!/bin/bash
#
# read the host from command line
# check if .ssh directory exists on the remote host

cat ~/.ssh/id_rsa.pub | ssh root@192.168.133.84 'cat >> .ssh/id_rsa.pub'
