#!/usr/bin/env bash

# allow vagrant to read common logs directly
usermod -a -G adm vagrant

# shell enhancements
ln -s -f /vagrant/provision/saltstack/filesystem/home/vagrant/.bash_aliases .bash_aliases
patch /home/vagrant/.bashrc < /vagrant/provision/saltstack/filesystem/home/vagrant/.bashrc.patch --forward

# install saltstack
curl -L https://bootstrap.saltstack.com -o install_salt.sh
