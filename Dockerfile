#Debian 9 stretch
FROM ansible-sandbox-base:latest

COPY docker/ansible.cfg /etc/ansible/ansible.cfg
COPY library /etc/ansible/library
COPY action_plugins /etc/ansible/action_plugins
COPY templates /etc/ansible/templates
COPY *.yml /etc/ansible/

RUN rm -rf /etc/ansible/hosts
COPY inventories/*/group_vars/*.yml /etc/ansible/hosts/group_vars/
COPY inventories/*/host_vars/*.yml /etc/ansible/hosts/host_vars/
COPY inventories/dev/hosts.yml /etc/ansible/hosts/dev/hosts.yml
COPY inventories/test/hosts /etc/ansible/hosts/test/hosts

RUN echo "cd /etc/ansible" >> ~/.bashrc
