#!/usr/bin/env bash

# allow vagrant to read common logs directly
usermod -a -G adm vagrant

# install dependencies for salt
apt-get install python-apt

# copy salt keys
#mkdir -p -m 700 /tmp/salt/pki/minion
#cp /vagrant/provision/saltstack/filesystem/etc/salt/pki/minion/* /tmp/salt/pki/minion/
