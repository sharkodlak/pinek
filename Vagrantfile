# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	# All Vagrant configuration is done here. The most common configuration
	# options are documented and commented below. For a complete reference,
	# please see the online documentation at vagrantup.com.

	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.box = "debian/jessie64"

	# If true, then any SSH connections made will enable agent forwarding.
	# Default value: false
	# config.ssh.forward_agent = true

	# Share an additional folder to the guest VM. The first argument is
	# the path on the host to the actual folder. The second argument is
	# the path on the guest to mount the folder. And the optional third
	# argument is a set of non-required options.

	# Provider-specific configuration so you can fine-tune various
	# backing providers for Vagrant. These expose provider-specific options.
	# Example for VirtualBox:
	#
	config.vm.provider "virtualbox" do |vb|
		# Use VBoxManage to customize the VM. For example to change memory:
		# User can define these settings in his Vagrantfile in ~/.vagrant.d
	end
	#
	# View the documentation for the provider you're using for more
	# information on available options.


	# Provision Vagrant by shell scripts
	config.vm.provision "shell" do |sh|
		sh.path = "provision/bootstrap.sh"
	end
	machineConfigs = {
		"balancer" => {},
		"www" => {
			name: "cathedral",
			synced_folders: [
				{host: "www", guest: "/var/www", owner: "www-data"},
			],
			forwarded_ports: [
				{host: 8080, guest: 80},
				{host: 8443, guest: 443},
			],
		},
		"db" => {
			numberOfMachines: 2,
		},
		"queue" => {},
		"search" => {},
		"worker" => {},
	}
	primaryMachine = "www"
	networkIpByte = 10
	machineConfigs.each do |provisionName, machineConfig|
		numberOfMachines = machineConfig[:numberOfMachines] || 1
		for machineNumber in 0..numberOfMachines
			config.vm.define provisionName, primary: primaryMachine == provisionName do |machine|
				machine.vm.hostname = machineConfig[:name] || provisionName
				machine.vm.provider "virtualbox" do |vb|
					vb.name = machineConfig[:name] || provisionName
				end
				machine.vm.provision "shell" do |sh|
					sh.path = "provision/#{provisionName}.sh"
				end
				Array(machineConfig[:synced_folders]).each do |folder|
					machine.vm.synced_folder folder[:host], folder[:guest], owner: folder[:owner]
				end
				Array(machineConfig[:forwarded_ports]).each do |ports|
					machine.vm.network "forwarded_port", guest: ports[:guest], host: ports[:host]
				end
				machine.vm.network "private_network", ip: "10.10.10.#{networkIpByte}"
			end
		end 
	end
end
