# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
DHCP_FIRST_IP = "172.22.222.10"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	# All Vagrant configuration is done here. The most common configuration
	# options are documented and commented below. For a complete reference,
	# please see the online documentation at vagrantup.com.

	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.box = "debian/jessie64"

	# If true, then any SSH connections made will enable agent forwarding.
	# Default value: false
	# config.ssh.forward_agent = true


	# Provision Vagrant by shell scripts
	config.vm.provision "shell" do |sh|
		sh.path = "provision/bootstrap.sh"
	end
	machineConfigs = {
		"salt" => { # With another name it doesn't work
			mac: "8427CE000000",
			saltMaster: true,
			synced_folders: [
				{host: "provision/saltstack", guest: "/srv/salt"},
				{host: "provision/saltstack/pillar", guest: "/srv/pillar"},
			#],
		#},
		#"www" => {
			#synced_folders: [
				{host: "www", guest: "/var/www", owner: "www-data"},
			],
			forwarded_ports: [
				{host: 8080, guest: 80},
				{host: 8443, guest: 443},
			#],
		#},
		#"db" => {
			#forwarded_ports: [
				{host: 5432, guest: 5432},
			],
			#numberOfMachines: 2,
		},
		#"balancer" => {},
		#"queue" => {},
		#"search" => {},
		#"worker" => {},
	}
	primaryMachine = "www"
	machineConfigs.each do |provisionName, machineConfig|
		numberOfMachines = machineConfig[:numberOfMachines] || 1
		(1..numberOfMachines).each do |machineNumber|
			config.vm.define provisionName, primary: primaryMachine == provisionName do |machine|
				machine.vm.hostname = machineConfig[:name] || provisionName
				machine.vm.provider "virtualbox" do |vb|
					vb.name = provisionName
				end
				Array(machineConfig[:synced_folders]).each do |folder|
					if folder[:owner]
						machine.vm.synced_folder folder[:host], folder[:guest], owner: folder[:owner]
					else
						machine.vm.synced_folder folder[:host], folder[:guest]
					end
				end
				#saltInstallCommand = "sh install_salt.sh" + (machineConfig[:saltMaster] ? " -M" : " -A #{DHCP_FIRST_IP}")
				#machine.vm.provision "shell", inline: saltInstallCommand
				machine.vm.provision :salt do |salt|
					salt.install_master = machineConfig[:saltMaster] || false
					salt.install_type = "stable"
					salt.colorize = true
					salt.verbose = true
				end
				machine.vm.provision "shell" do |sh|
					sh.path = "provision/#{provisionName}.sh"
				end
				Array(machineConfig[:forwarded_ports]).each do |ports|
					machine.vm.network "forwarded_port", guest: ports[:guest], host: ports[:host]
				end
				if machineConfig[:ip]
					machine.vm.network "private_network", name: "diocese", virtualbox__intnet: "diocese", mac: machineConfig[:mac], ip: machineConfig[:ip]
				else
					machine.vm.network "private_network", name: "diocese", virtualbox__intnet: "diocese", mac: machineConfig[:mac], type: "dhcp"
				end
			end
		end 
	end
end
