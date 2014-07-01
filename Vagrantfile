# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

conf = YAML.load_file('config.yml')

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.hostname = "vagrant.example.com"

  if conf['vm']['ip'] == 'dhcp'
    config.vm.network :private_network, type: "dhcp"
  else
    config.vm.network :private_network, ip: conf['vm']['ip']
  end

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--memory", conf['vm']['memory']]
    vbox.gui = conf['vm']['gui']
  end

  config.vm.provision "shell" do |s|
    s.path = "puppet/setup.sh"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path    = "puppet/manifests"
    puppet.manifest_file     = "site.pp"
    puppet.module_path       = "puppet/modules"
    puppet.working_directory = "/vagrant"
    puppet.hiera_config_path = "puppet/hiera.yaml"
    puppet.facter = {
      # Fix https://tickets.puppetlabs.com/browse/MODULES-428
      "vcsrepo" => "dummy"
    }
  end
end
