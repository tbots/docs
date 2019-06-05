#!/bin/bash
#
# Installation script for docker-ce
#

#apt update --assume-yes
#apt upgrade --assume-yes

#apt install --assume-yes \
#	apt-transport-https \
#	ca-certificates \
#	curl \
#	gnupg-agent \
#	software-properties-common 

#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#apt update

apt install --assume-yes \
	docker-ce \
	docker-ce-cli \
	containerd.io
