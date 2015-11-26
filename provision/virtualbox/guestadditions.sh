#!/usr/bin/env bash

for VM in $(vagrant status | grep -Po '^\w+(?=\s{2,})')
do
	VBOXVM=$VM
	vagrant halt $VM
	vboxmanage storageattach $VBOXVM --storagectl 'IDE Controller' --port 0 --device 1 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso
	vagrant up $VM
	vagrant ssh $VM -c 'sudo apt-get install -y linux-headers-$(uname -r) && sudo mount /dev/cdrom /mnt && cd /mnt && sudo ./VBoxLinuxAdditions.run'
	vagrant halt $VM
	vboxmanage storageattach $VBOXVM --storagectl 'IDE Controller' --port 0 --device 1 --type dvddrive --medium none
done