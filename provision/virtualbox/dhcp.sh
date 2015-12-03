#!/usr/bin/env bash

vboxmanage dhcpserver add --netname diocese --ip 172.16.123.1 --netmask 255.255.255.0 --lowerip 172.16.123.10 --upperip 172.16.123.254 --enable
