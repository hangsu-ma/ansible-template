# Ansible Sandbox 
This project contains a template project for Ansible module, plugin and playbook development.<br>

## what does it do
  * bring up a vagrant CentOS 7.4 box on Windows machine, the vagrant box can be configured through a yaml file.
  Located at vagrant/vagrant.yml
  * provision a docker image for Ansible development on the linux vagrant box.
  * the default username password to access the vagrant box is __root:vagrant__
## setup
  * install latest version of [Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  * install [Vagrant](https://www.vagrantup.com/downloads.html)
  * clone this repo to your working dir
  * replace tokens in  _vagrant/vagrant.yml_ with real values
  * proxy related settings can also be populated by environment variables.  
  This is the recommended approach to prevent accidental check in of your precious easy-to-guess same-for-all-site 
  credentials in _vagrant/vagrant.yml_
    * user_id: proxy user name, also used for internal docker repo user if configured.
    * user_password: proxy password, also used for internal docker repo if configured.
    * proxy_server_name: proxy server name, example: proxy.example.com
    * proxy_port: proxy port.
    * http_proxy: example in windows: http://%user_id%:%user_password%@%proxy_server_name%:%proxy_port% 
    * https_proxy: example in linux: http://${user_id}:${user_password}@{proxy_server_name}:${proxy_port}
    * no_proxy: comma separated list of servers should be accessed without proxy.  
    This typically includes: _192.168.*,localhost,127.0.0.1_
  * run `vagrant up` in your cloned repo
  * run `vagrant ssh` login to the vm, or use _root:vagrant_ to log onto the vm
  * use alias 'build'(`docker build . -t ansible-sandbox`) to build docker image from _Dockerfile_ 
  * use alias 'run'(`docker run -it ansible-sandbox`) to run the built docker image

**NOTE**: the run method mount files into docker image, so they will be updated without re-build the image.
If you can using _docker run_ to start the image, you will need to _docker build_ image everytime a file is changed.

**NOTE**: this template supports self-signed corp proxy, drop in your certs in _vagrant/_. You need both the crt and pem files.
See details in _vagrant/proxy.rb_