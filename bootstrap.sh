#!/usr/bin/env bash

# set timezone
echo "Europe/Prague" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# prepare locales
cat /vagrant/etc/locale.gen | sudo tee /etc/locale.gen
locale-gen

# add dotdeb repository
ln -s /etc/apt/sources.list.d/dotdeb.list /vagrant/etc/apt/sources.list.d/dotdeb.list
curl https://www.dotdeb.org/dotdeb.gpg | apt-key add -

# uninstall mess and install needed packages
apt-get update
apt-get purge -y apache2
apt-get install -y nginx php7.0-fpm
