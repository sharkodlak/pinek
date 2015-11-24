#!/usr/bin/env bash

#setup host color
echo "HOST_COLOR='\e[01;31m'" | tee -a /etc/bash.bashrc

# add PHP7 repository
#cat /vagrant/provision/etc/apt/sources.list.d/dotdeb.list > /etc/apt/sources.list.d/dotdeb.list
#curl https://www.dotdeb.org/dotdeb.gpg | apt-key add -

# add phalcon repository
gpg --keyserver pgpkeys.mit.edu --recv-key 31F49B93
gpg -a --export 31F49B93 | apt-key add -
cat /vagrant/provision/etc/apt/sources.list.d/phalcon.list > /etc/apt/sources.list.d/phalcon.list

# install packages
apt-get update
apt-get install -y nginx php5-fpm php5-xdebug php5-phalcon #php7.0-fpm

# setup webserver
#patch /etc/php/7.0/fpm/pool.d/www.conf < /vagrant/provision/etc/php/7.0/fpm/pool.d/www.conf.patch --forward
patch /etc/php5/fpm/pool.d/www.conf < /vagrant/provision/etc/php5/fpm/pool.d/www.conf.patch --forward
cat /vagrant/provision/etc/php5/mods-available/xdebug.ini > /etc/php5/mods-available/xdebug.ini
cat /vagrant/provision/etc/nginx/sites-available/default > /etc/nginx/sites-available/default
cat /vagrant/provision/etc/logrotate.d/php5-fpm > /etc/logrotate.d/php5-fpm
mkdir -p /var/log/www
chown www-data:adm /var/log/www
chmod 775 /var/log/www
service nginx reload
service php5-fpm restart
