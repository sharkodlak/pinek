#!/usr/bin/env bash

vboxmanage dhcpserver add --netname diocese --ip 172.22.222.1 --netmask 255.255.255.0 --lowerip 172.22.222.10 --upperip 172.22.222.254 --enable
