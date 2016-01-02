#!/usr/bin/env bash

# allow vagrant to read common logs directly
usermod -a -G adm vagrant

# install saltstack
curl -L https://bootstrap.saltstack.com -o install_salt.sh
