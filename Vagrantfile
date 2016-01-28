# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'optparse' # for temporarily disable shared folders (until guest box additins are instaled)
require 'yaml' # for writing salt files

options = {
	sharedFolders: true,
}
optParser = OptionParser.new do |opts|
	opts.on("--[no-]shared-folders", "Share folders") do |a|
		options[:sharedFolders] = a
	end
end
begin optParser.parse!
rescue OptionParser::InvalidOption => e
end


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

	# Configure roles for machines
	roles = {
		balancer: {},
		ci: {
			forwarded_ports: [
				{host: 8081, guest: 8081},
			],
		},
		db: {
			forwarded_ports: [
				{host: 5432, guest: 5432},
			],
		},
		queue: {},
		salt: {
			saltMaster: true,
			synced_folders: [
				{host: ".", guest: "/vagrant.root"},
				{host: "provision/saltstack", guest: "/srv/salt"},
				{host: "provision/saltstack/pillar", guest: "/srv/pillar"},
			],
		},
		search: {},
		worker: {},
		www: {
			synced_folders: [
				{host: "src", guest: "/var/www", owner: "www-data"},
			],
			forwarded_ports: [
				{host: 8080, guest: 80},
				{host: 8443, guest: 443},
			],
		},
	}
	rolesToMachines = {
		ci: :minion1,
		db: [
			:salt,
		],
		salt: :salt,
		www: :salt,
	}
	machineConfigs = {
		salt: { # With another name it doesn't work, also it has to be first entry to lease first DHCP IP
			mac: "8427CE000000",
			color: "\\e[0;31m"
		},
	}
	rolesToMachines.each do |role, machines|
		if !machines.respond_to?(:each)
			machines = [machines]
		end
		machines.each do |machineName|
			if !machineConfigs[machineName]
				machineConfigs[machineName] = {}
			end
			machineConfigs[machineName] = machineConfigs[machineName].merge(roles[role]) {
				|key, old, new|
				if old.respond_to?(:push)
					old.push(*new)
				else
					new
				end
			}
			if !machineConfigs[machineName][:roles]
				machineConfigs[machineName][:roles] = []
			end
			machineConfigs[machineName][:roles] = machineConfigs[machineName][:roles].push(role.to_s)
		end
	end
	primaryMachine = :www
	if ! machineConfigs[primaryMachine]
		primaryMachine = machineConfigs.keys[0]
	end
	machineConfigs.each do |machineName, machineConfig|
		config.vm.define machineName.to_s, primary: primaryMachine == machineName do |machine|
			machine.vm.provider "virtualbox" do |vb|
				vb.name = machineName.to_s
			end
			machine.vm.hostname = machineConfig[:name] || machineName.to_s
			if options[:sharedFolders]
				Array(machineConfig[:synced_folders]).each do |folder|
					if folder[:owner]
						machine.vm.synced_folder folder[:host], folder[:guest], owner: folder[:owner]
					else
						machine.vm.synced_folder folder[:host], folder[:guest]
					end
				end
			end
			machine.vm.provision :shell, inline: "mkdir -m 664 -p /tmp/salt && chown root:root /tmp/salt && mkdir -m 700 -p /etc/salt/pki/minions"
			machine.vm.provision :salt do |salt|
				saltArgs = []
				saltArgs[0] = machineConfig[:saltMaster] ? "master" : "minion"
				if ! machineConfig[:saltMaster]
					saltArgs[1] = "'#{DHCP_FIRST_IP}'"
				end
				machine.vm.provision :shell, path: "provision/shell/salt.sh", args: saltArgs
				minionConfigFile = "provision/saltstack/minions/#{machineName.to_s}"
				grainsFile = minionConfigFile + ".grains"
				grains = {}
				if File.file?(grainsFile)
					grains = YAML.load_file(grainsFile)
				end
				grains[:roles.to_s] = (grains[:roles.to_s] || []) | machineConfig[:roles]
				grains[:color.to_s] = machineConfig[:color] || grains[:color.to_s] || ""
				grainsFileTmp = "/tmp/#{machineName.to_s}.grains"
				File.write(grainsFileTmp, grains.to_yaml)
				machine.vm.provision :file, source: grainsFileTmp, destination: "/tmp/salt.grains"
				machine.vm.provision :shell, inline: "chown root:root /tmp/salt.grains && cp /tmp/salt.grains /etc/salt/grains"
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
