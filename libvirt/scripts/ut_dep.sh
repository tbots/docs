#!/bin/bash


virt-install --name ut0\
						 --memory 1024\
						 --vcpus=1\
						 --disk /var/lib/libvirt/images/t0.qcow2\
						 --cdrom /home/oleg/Downloads/ubuntu-16.04.3-server-i386.iso\
						 --graphics vnc,listen=0.0.0.0\
						 --noautoconsole\
						 #--import			# to create a system from the already installed drive
