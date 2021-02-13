#!/bin/bash


createNodes(){
nb_vm=1
[ "$1" != "" ] && nb_vm=$1
echo "$nb_vm  vms"
echo "
# -*- mode: ruby -*-
# vi: set ft=ruby :
nbServer=$nb_vm
Vagrant.configure("2") do |config|
    (1..nbServer).each do |i|
    config.vm.define \"node#{i}\" do |node|
        node.vm.box = \"debian/buster64\"
        node.vm.hostname =\"node#{i}\"
        node.vm.box_url = \"debian/buster64\"
        node.vm.network :private_network, ip: \"192.168.100.1#{i}\"
        node.vm.provider :virtualbox do |v|
        v.customize [\"modifyvm\", :id, \"--natdnshostresolver1\", \"on\"]
        v.customize [\"modifyvm\", :id, \"--natdnsproxy1\", \"on\"]
        v.customize [\"modifyvm\", :id, \"--memory\", 3072]
        v.customize [\"modifyvm\", :id, \"--name\", \"node#{i}\"]
        v.customize [\"modifyvm\", :id, \"--cpus\", \"1\"]
        end
        config.vm.provision \"shell\", inline: <<-SHELL
        sed -i \"s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g\" /etc/ssh/sshd_config    
        service ssh restart
        SHELL
    end
  end
end  

">>Vagrantfile
vagrant up

}


dropNodes(){
echo "drop all vms"
vagrant -f destroy

} 

#si option --create
if [ "$1" == "--create" ]; then
	createNodes $2

# si option --drop
else [ "$1" == "--drop" ]
	dropNodes

fi
