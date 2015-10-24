#!/usr/bin/env bash

# shell enhancements
if ! grep -q ll= /etc/bash.bashrc; then
	echo -e '\n\nalias ll="ls -la"' | tee -a /etc/bash.bashrc
fi

# set timezone
echo "Europe/Prague" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# prepare locales
cat /vagrant/etc/locale.gen > /etc/locale.gen
locale-gen

# add dotdeb repository
cat /vagrant/etc/apt/sources.list.d/dotdeb.list > /etc/apt/sources.list.d/dotdeb.list
curl https://www.dotdeb.org/dotdeb.gpg | apt-key add -

# uninstall mess and install needed packages
apt-get update
apt-get purge -y apache2
apt-get install -y nginx php7.0-fpm

# setup webserver
patch /etc/php/7.0/fpm/pool.d/www.conf < /vagrant/etc/php/7.0/fpm/pool.d/www.conf.patch --forward
