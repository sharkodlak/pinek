#!/usr/bin/env bash

# allow vagrant to read common logs directly
usermod -a -G adm vagrant

# shell enhancements
ln -s /vagrant/provision/home/vagrant/.bash_aliases .bash_aliases
patch /home/vagrant/.bashrc < /vagrant/provision/home/vagrant/.bashrc.patch --forward

# set timezone
echo "Europe/Prague" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# prepare locales
cat /vagrant/provision/etc/locale.gen > /etc/locale.gen
locale-gen

#apt-get install -y git
curl -L https://bootstrap.saltstack.com -o install_salt.sh
