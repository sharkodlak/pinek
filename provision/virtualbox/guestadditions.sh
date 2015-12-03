#!/usr/bin/env bash

function run {
	read -r VM VM_STATUS PROVIDER <<< $1
	VBOXVM=$VM
	echo "$VM: $VM_STATUS";
	if [[ $VM_STATUS == 'saved' ]] ; then
		vagrant up $VM
	fi
	VERSION=$(vagrant ssh $VM -c "sudo modinfo vboxguest | awk '/^version/ { print \$2 }' | tr -dc '[[:print:]]'")
	if [ -n "$VERSION" ] && $(dpkg --compare-versions $VERSION '>=' $VERSION_TO_INSTALL) ; then
		echo "skip $VM because current installed version is greater or equal"
	else
		if [[ $VM_STATUS != 'poweroff' ]] ; then
			vagrant halt $VM
		fi
		vboxmanage storageattach $VBOXVM --storagectl 'IDE Controller' --port 0 --device 1 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso
		vagrant up $VM
		VERSION=$(vagrant ssh $VM -c "sudo modinfo vboxguest | awk '/^version/ { print \$2 }' | tr -dc '[[:print:]]'")
		if [ -n "$VERSION" ] && $(dpkg --compare-versions $VERSION '>=' $VERSION_TO_INSTALL) ; then
			echo "skip $VM because current installed version is greater or equal"
		else
			vagrant ssh $VM -c 'sudo apt-get install -y build-essential linux-headers-$(uname -r) && sudo mount /dev/cdrom /mnt && cd /mnt && sudo ./VBoxLinuxAdditions.run'
		fi
		vagrant halt $VM
		vboxmanage storageattach $VBOXVM --storagectl 'IDE Controller' --port 0 --device 1 --type dvddrive --medium none
		
	fi
	if [[ $VM_STATUS == 'running' ]] ; then
		vagrant up $VM
	elif [[ $VM_STATUS == 'saved' ]] ; then
		vagrant up $VM
		vagrant suspend $VM
	fi
}

export -f run
VERSION_TO_INSTALL=$(dpkg -l | grep virtualbox-guest-additions | grep -oP '\d+\.\d+\.\d+')
VM_STATUSES=$(vagrant status | grep -P '^\w+(?=\s{2,})')
echo 'Running guest additions install in parallel.'
printf "%s\n" "$VM_STATUSES[@]"
printf "%s\n" "$VM_STATUSES[@]" | parallel run