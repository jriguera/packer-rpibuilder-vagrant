Vagrant.configure("2") do |config|
  #config.ssh.insert_key = false
  #config.vm.synced_folder '.', '/vagrant'
  #config.ssh.username = "vagrant"
  #config.ssh.password = "vagrant"

  config.vm.define "virtualbox" do |virtualbox|
    virtualbox.vm.hostname = "rpibuilder"
    virtualbox.vm.box = "file://builds/buster-10.0_rpibuilder-1_virtualbox.box"
    config.vm.provider :virtualbox do |v|
      # v.gui = false
      # v.memory = 4096
      # v.cpus = 2
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    config.vm.provision "shell", inline: "echo Hello, World"
  end
end
