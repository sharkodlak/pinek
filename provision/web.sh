#!/usr/bin/env bash

# install packages
apt-get install -y nginx php7.0-fpm

# setup webserver
patch /etc/php/7.0/fpm/pool.d/www.conf < /vagrant/etc/php/7.0/fpm/pool.d/www.conf.patch --forward
