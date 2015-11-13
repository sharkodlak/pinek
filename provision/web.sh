#!/usr/bin/env bash

#setup host color
echo "HOST_COLOR='\e[01;31m'" | tee -a /etc/bash.bashrc

# install packages
apt-get install -y nginx php7.0-fpm

# setup webserver
patch /etc/php/7.0/fpm/pool.d/www.conf < /vagrant/etc/php/7.0/fpm/pool.d/www.conf.patch --forward
