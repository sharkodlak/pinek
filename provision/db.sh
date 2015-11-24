#!/usr/bin/env bash

#setup host color
echo "HOST_COLOR='\e[01;35m'" | tee -a /etc/bash.bashrc

# install packages
apt-get update
apt-get install -y postgresql
