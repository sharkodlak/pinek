#!/usr/bin/env bash
function getVersion {
	local VERSION=$(vagrant ssh $1 -c "sudo modinfo vboxguest | awk '/^version/ { print \$2 }' | tr -dc '[[:print:]]'" < /dev/null)
	echo $VERSION
}

function isCurrentVersion {
	local VERSION=$(getVersion $1)
	echo $VERSION '>=' $VERSION_TO_INSTALL
	[ -n "$VERSION" ] && dpkg --compare-versions $VERSION '>=' $2
}

function run {
	read -r VM VM_STATUS PROVIDER REST <<< $1
	for VM_TO_INSTALL in $2; do
		if [[ $VM == $VM_TO_INSTALL ]]; then
			if [[ $VM_STATUS == 'not' ]]; then
				VM_STATUS="${VM_STATUS} ${PROVIDER}"
				PROVIDER="$REST"
			fi
			VBOXVM=$VM
			echo "$VM: $VM_STATUS, $PROVIDER";
			if [[ $VM_STATUS == 'saved' || $VM_STATUS == 'not created' ]]; then
				echo "Bring up '$VM' because it is stopped or not created"
				vagrant up $VM --no-provision
			fi
			if isCurrentVersion $VM $VERSION_TO_INSTALL; then
				echo "Skip '$VM' - current installed version is equal or greater"
			else
				if [[ $VM_STATUS != 'poweroff' ]] ; then
					echo "Halting '$VM'"
					vagrant halt $VM
				fi
				echo "Attach ISO to '$VM' and bring machine up"
				vboxmanage storageattach $VBOXVM --storagectl 'IDE Controller' --port 0 --device 1 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso
				vagrant up $VM --no-provision
				if isCurrentVersion $VM $VERSION_TO_INSTALL; then
					echo "Skip '$VM' because current installed version is equal or greater"
				else
					echo "Build guest additions on '$VM'"
					vagrant ssh $VM -c 'sudo apt-get install -y build-essential linux-headers-$(uname -r) && sudo mount /dev/cdrom /mnt && cd /mnt && sudo ./VBoxLinuxAdditions.run' < /dev/null
				fi
				echo "Halting machine '$VM' and detach ISO"
				vagrant halt $VM
				vboxmanage storageattach $VBOXVM --storagectl 'IDE Controller' --port 0 --device 1 --type dvddrive --medium none
			fi
			if [[ $VM_STATUS == 'running' ]]; then
				vagrant up $VM
			elif [[ $VM_STATUS == 'saved' ]]; then
				vagrant up $VM
				vagrant suspend $VM
			fi
		fi
	done
}

export -f run isCurrentVersion getVersion
export VERSION_TO_INSTALL=$(dpkg -l | grep virtualbox-guest-additions | grep -oP '\d+\.\d+\.\d+')
VM_STATUSES=$(vagrant status | grep -P '^\w+(?=\s{2,})')
echo 'Running guest additions install'
printf "%s\n" "${VM_STATUSES[@]}"
echo "Install on ${VMS_TO_INSTALL:=$@}"
printf "%s\n" "${VM_STATUSES[@]}" | parallel --jobs 0 run {} "'${VMS_TO_INSTALL[@]}'"
#printf "%s\n" "${VM_STATUSES[@]}" | while read -r VM_STATUS_LINE; do
#	run "${VM_STATUS_LINE[@]}" "${VMS_TO_INSTALL[@]}"
#done