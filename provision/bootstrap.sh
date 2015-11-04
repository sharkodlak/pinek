#!/usr/bin/env bash

# shell enhancements
if ! grep -q ll= /etc/bash.bashrc; then
	echo -e "\n" >> /etc/bash.bashrc
	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		echo -e "\nalias ls='ls --color=auto'" | tee -a /etc/bash.bashrc
		#alias dir='dir --color=auto'
		#alias vdir='vdir --color=auto'
		echo -e "\nalias grep='grep --color=auto'" | tee -a /etc/bash.bashrc
		echo -e "\nalias fgrep='fgrep --color=auto'" | tee -a /etc/bash.bashrc
		echo -e "\nalias egrep='egrep --color=auto'" | tee -a /etc/bash.bashrc
	fi
	echo -e "\nalias ll='ls -alF'" | tee -a /etc/bash.bashrc
fi

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
