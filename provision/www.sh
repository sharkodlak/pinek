#!/usr/bin/env bash

#setup host color
echo "HOST_COLOR='\e[01;31m'" | tee -a /etc/bash.bashrc

# setup webserver
#patch /etc/php/7.0/fpm/pool.d/www.conf < /vagrant/provision/etc/php/7.0/fpm/pool.d/www.conf.patch --forward
patch /etc/php5/fpm/pool.d/www.conf < /vagrant/provision/etc/php5/fpm/pool.d/www.conf.patch --forward
cat /vagrant/provision/etc/php5/mods-available/xdebug.ini > /etc/php5/mods-available/xdebug.ini
cat /vagrant/provision/etc/nginx/sites-available/default > /etc/nginx/sites-available/default
cat /vagrant/provision/etc/logrotate.d/php5-fpm > /etc/logrotate.d/php5-fpm
