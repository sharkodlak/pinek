#!/usr/bin/env bash

#setup host color
echo "HOST_COLOR='\e[01;31m'" | tee -a /etc/bash.bashrc

# install packages
apt-get install -y nginx php5-fpm php5-xdebug #php7.0-fpm

# setup webserver
patch /etc/php5/fpm/pool.d/www.conf < /vagrant/etc/php5/fpm/pool.d/www.conf.patch --forward
#patch /etc/php/7.0/fpm/pool.d/www.conf < /vagrant/etc/php/7.0/fpm/pool.d/www.conf.patch --forward
cat /vagrant/etc/nginx/sites-available/default > /etc/nginx/sites-available/default
mkdir /var/log/www
chown www-data:adm /var/log/www
chmod 775 /var/log/www
service nginx reload
service php5-fpm restart
