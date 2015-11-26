#!/usr/bin/env bash

vboxmanage dhcpserver add --netname diocese --ip 10.1.1.1 --netmask 255.255.255.0 --lowerip 10.1.1.10 --upperip 10.1.1.254 --enable
