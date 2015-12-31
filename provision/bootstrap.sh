#!/usr/bin/env bash

# allow vagrant to read common logs directly
usermod -a -G adm vagrant

# shell enhancements
ln -s -f /vagrant/provision/saltstack/filesystem/home/vagrant/.bash_aliases .bash_aliases
patch /home/vagrant/.bashrc < /vagrant/provision/saltstack/filesystem/home/vagrant/.bashrc.patch --forward

# set timezone
echo "Europe/Prague" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# prepare locales
cat /vagrant/provision/saltstack/filesystem/etc/locale.gen > /etc/locale.gen
locale-gen

curl -L https://bootstrap.saltstack.com -o install_salt.sh
