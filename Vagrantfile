Vagrant.configure("2") do |config|
  config.vm.define "vm1" do |vm1|
    vm1.vm.box = "centos/8"
    vm1.vm.network "private_network", ip: "192.168.50.12"
    vm1.vm.hostname = "vm1"
    vm1.vm.provision :shell, path: "script.sh"
    vm1.vm.provision :shell, path: "client.sh"
    vm1.vm.synced_folder "shares/", "/mnt/nfs_shares/docs/", type: "nfs"
    vm1.vm.provider :virtualbox do |vb|
      vb.customize [ 'modifyvm', :id, '--memory', '2048' ]
      vb.customize [ 'modifyvm', :id, '--cpus', '2' ]
    end
  end

  config.vm.define "vm2" do |vm2|
    vm2.vm.box = "centos/8"
    vm2.vm.network "private_network", ip: "192.168.50.13"
    vm2.vm.hostname = "vm2"
    vm2.vm.provision :shell, path: "script.sh"
    vm2.vm.provision :shell, path: "client.sh"
    vm2.vm.synced_folder "shares/", "/mnt/nfs_shares/docs/", type: "nfs"
    vm2.vm.provider :virtualbox do |vb|
      vb.customize [ 'modifyvm', :id, '--memory', '2048' ]
      vb.customize [ 'modifyvm', :id, '--cpus', '2' ]
    end
  end
end
