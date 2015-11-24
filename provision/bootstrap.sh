#!/usr/bin/env bash

# allow vagrant to read common logs directly
usermod -a -G adm vagrant

# shell enhancements
ln -s /vagrant/home/vagrant/.bash_aliases .bash_aliases
patch /home/vagrant/.bashrc < /vagrant/home/vagrant/.bashrc.patch --forward

# set timezone
echo "Europe/Prague" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# prepare locales
cat /vagrant/etc/locale.gen > /etc/locale.gen
locale-gen

#apt-get install -y git
