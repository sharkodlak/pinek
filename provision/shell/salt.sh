#!/usr/bin/env bash

installArgs=()

if [ -z $1 ]; then
	echo First parameter has to be 'master' or 'minion'.
	exit 1
elif [ "$1" == "master" ]; then
	master=1
	masterOrMinion="master"
	installArgs+=('-M')
else
	masterOrMinion="minion"
fi
shift

if [ "$masterOrMinion" == "minion" ]; then
	if [ -z $1 ]; then
		echo "First parameter is minion, so master's address have to be provided."
		exit 1
	else
		masterAddress=$1
		installArgs+=("-A $masterAddress")
	fi
	shift
fi

if [ -n $1 ]; then
	keys="$@"
fi

# Install salt
curl -L https://bootstrap.saltstack.com -o /root/install_salt.sh
sudo sh /root/install_salt.sh ${installArgs[@]}

# Set minion's master
if [ -n "$master" ]; then
	echo "master: $masterAddress" | tee /etc/salt/minion.d/99-master-address.conf 
fi

# Prepare directory for keys
mkdir -m 700 -p /etc/salt/pki/minions
chown -R root:root /etc/salt/pki

# Prepare tmp directory for keys
mkdir -m 664 -p /tmp/salt/keys
chown -R root:root /tmp/salt

# Copy keys
#cp provision/saltstack/filesystem/etc/salt/pki/minion/$keys /tmp/salt/keys
#chown -R root:root /tmp/salt/keys
