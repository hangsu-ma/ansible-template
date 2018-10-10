# -*- mode: ruby -*-
# vi: set ft=ruby :
# Copyright: (c) 2018, Hangsu Ma (hangsu@beag.biz)
# GNU General Public LICENSE v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

require 'yaml'
settings = YAML.load_file './vagrant/vagrant.yml'

# global var used in main Vagrantfile
$username = ENV["user_id"]?ENV["user_id"]:settings['proxy']['username']
$password = ENV["user_password"]?ENV["user_password"]:settings['proxy']['password']
$proxy_server_name = ENV["proxy_server_name"]?ENV["proxy_server_name"]:settings['proxy']['server_name']
$proxy_port = ENV["proxy_port"]?ENV["proxy_port"]:settings['proxy']['port']

Vagrant.configure("2") do |config|
  if settings['proxy']['enable']
    proxy_http = ENV["http_proxy"]?ENV["http_proxy"]:"http://#{settings['proxy']['username']}:#{settings['proxy']['password']}@#{settings['proxy']['server_name']}:#{settings['proxy']['port']}"
    proxy_https = ENV["https_proxy"]?ENV["https_proxy"]:"http://#{settings['proxy']['username']}:#{settings['proxy']['password']}@#{settings['proxy']['server_name']}:#{settings['proxy']['port']}"
    no_proxy = ENV["no_proxy"]?ENV["no_proxy"]:settings['proxy']['no_proxy']

    config.vm.provision "proxy", type: "shell", inline: <<-SHELL
      rm -rf /etc/profile.d/proxy.sh
      echo 'export http_proxy="#{proxy_http}"' >> /etc/profile.d/proxy.sh
      echo 'export https_proxy="#{proxy_https}"' >> /etc/profile.d/proxy.sh
      echo 'export no_proxy="#{no_proxy}"' >> /etc/profile.d/proxy.sh
      echo 'export GIT_SSL_NO_VERIFY=true' >> /etc/profile.d/proxy.sh
      chmod 644 /etc/profile.d/proxy.sh
      source /etc/profile.d/proxy.sh
    SHELL

    if(File.exist?('vagrant/cacert.pem'))
      config.vm.provision "file", source: "vagrant/cacert.pem", destination: "/tmp/cacert.pem"
      config.vm.provision "cacert", type: "shell", inline: <<-SHELL
        mkdir -p /opt/cacerts
        cp /tmp/cacert.pem /opt/cacerts/.
        chmod 664 /opt/cacerts/cacert.pem
        rm /tmp/cacert.pem
        echo 'export SSL_CERT_FILE=/opt/cacerts/cacert.pem' >> /etc/profile.d/proxy.sh
      SHELL
    end

    if settings['vm']['box'].match(/centos/)
      config.vm.provision "yum-proxy", type: "shell", inline: <<-SHELL
        echo "proxy=http://#{$proxy_server_name}:#{$proxy_port}" >> /etc/yum.conf
        echo "proxy_username=#{$username}" >> /etc/yum.conf
        echo "proxy_password=#{$password}" >> /etc/yum.conf
      SHELL
    end

    if settings['vm']['box'].match(/centos-7/)
      config.vm.provision "centos-7-certs", type: "shell", inline: <<-SHELL
        yum install ca-certificates -y -q
        update-ca-trust force-enable
      SHELL
      if(File.exist?('vagrant/self.crt'))
        config.vm.provision "file", source: "vagrant/self.crt", destination: "/tmp/self.crt"
        config.vm.provision "centos-7-self-certs", type: "shell", inline: <<-SHELL
          mkdir -p /etc/pki/ca-trust/source/anchors/
          cp /tmp/*.crt /etc/pki/ca-trust/source/anchors/.
          update-ca-trust extract
          rm /tmp/*.crt
        SHELL
      end
    end

    config.vm.provision "docker-proxy", type: "shell", inline: <<-SHELL
    mkdir -p /etc/systemd/system/docker.service.d
    echo '[Service]' > /etc/systemd/system/docker.service.d/http-proxy.conf
    echo 'Environment="HTTP_PROXY=#{proxy_http}" "NO_PROXY=#{no_proxy}"' >> /etc/systemd/system/docker.service.d/http-proxy.conf
    SHELL
  end
end