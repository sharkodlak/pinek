#!/usr/bin/env bash

# shell enhancements
ln -s /vagrant/home/vagrant/.bash_aliases .bash_aliases
patch /home/vagrant/.bashrc < /vagrant/home/vagrant/.bashrc.patch --forward

# set timezone
echo "Europe/Prague" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# prepare locales
cat /vagrant/etc/locale.gen > /etc/locale.gen
locale-gen

# add dotdeb repository
cat /vagrant/etc/apt/sources.list.d/dotdeb.list > /etc/apt/sources.list.d/dotdeb.list
curl https://www.dotdeb.org/dotdeb.gpg | apt-key add -
apt-get update
apt-get install -y git
