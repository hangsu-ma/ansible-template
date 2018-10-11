# -*- mode: ruby -*-
# vi: set ft=ruby :
# Copyright: (c) 2018, Hangsu Ma (hangsu@beag.biz)
# GNU General Public LICENSE v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

require 'yaml'
settings = YAML.load_file './vagrant/vagrant.yml'

if settings['proxy']['enable']
  require './vagrant/proxy.rb'
end

Vagrant.configure(2) do |config|
  config.vm.box = settings['vm']['box']
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: settings['vm']['ip']

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.name = settings['vm']['name']
    vb.memory = settings['vm']['memory']
    vb.customize ["modifyvm", :id, "--ioapic", "on", "--vram", "256", "--clipboard", "bidirectional"]
    vb.cpus = settings['vm']['cpu']
  end

  config.ssh.username = 'root'
  config.ssh.password = 'vagrant'
  config.ssh.insert_key = 'true'
  config.ssh.keep_alive = 'true'

  config.vm.provision "docker", type: "shell", inline: <<-SHELL
      yum remove docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-selinux \
        docker-engine-selinux \
        docker-engine
      yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2 \
        vim \
        dos2unix
      yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
      yum-config-manager --enable docker-ce-edge
      yum install -y docker-ce
      systemctl enable docker
      systemctl daemon-reload
      systemctl restart docker
  SHELL

  docker_repo = ENV["docker_repo"]?ENV["docker_repo"]:settings['proxy']['docker_repo_url']
  if settings['proxy']['enable'] && docker_repo && docker_repo != 'CORP_INTERNAL_DOCKEAR_REPO:PORT'
    config.vm.provision "docker-login", type: "shell", inline: <<-SHELL
      docker login #{docker_repo} -u #{$username} -p #{$password}
    SHELL
  end

  config.vm.provision "docker-base", type: "shell", inline: <<-SHELL
    docker build -f /vagrant/docker/base#{settings['proxy']['enable']?'-proxy':''}.dockerfile -t "ansible-sandbox-base" \
      /vagrant/docker --build-arg ANSIBLE_RELEASE=#{settings['dependency']['ansible_version']} #{settings['proxy']['enable']? \
    "--build-arg PROXY=http://#{$proxy_server_name}:#{$proxy_port}":''}
  SHELL

  config.vm.provision "docker-helloworld", type: "shell", inline: <<-SHELL
    [ -f /etc/profile.d/proxy.sh ] && source /etc/profile.d/proxy.sh || echo "No Proxy Configured"
    docker run hello-world
  SHELL
  config.vm.provision "vagrantrc", type: "file", source: "vagrant/vagrantrc.sh", destination: "/root/.vagrantrc"
  config.vm.provision "update_rc_files", type: "shell", inline: <<-SHELL
    dos2unix /root/.vagrantrc
    echo "ANSIBLE_VERSION=#{settings['dependency']['ansible_version']}" >> ~/.vagrantrc
    echo "source ~/.vagrantrc" >> ~/.bashrc
    echo "cd /vagrant" >> ~/.bashrc
  SHELL
end
