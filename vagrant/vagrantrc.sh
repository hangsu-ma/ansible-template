#!/usr/bin/env bash
alias build='docker build . -t ansible-sandbox'
alias br='build && run'
run () {
    PLAYBOOKS=$(_mountAllFiles "" "")
    TEST_HOSTVARS=$(_mountAllFiles "/inventories/test/host_vars" "/hosts/host_vars")
    DEV_HOSTVARS=$(_mountAllFiles "/inventories/dev/host_vars" "/hosts/host_vars")
    docker run -it \
        -v /vagrant/library:/etc/ansible/library \
        -v /vagrant/action_plugins:/etc/ansible/action_plugins \
        -v /vagrant/templates:/etc/ansible/templates \
        -v /vagrant/inventories/dev/hosts.yml:/etc/ansible/hosts/dev/hosts.yml \
        -v /vagrant/inventories/test/hosts:/etc/ansible/hosts/test/hosts  \
        -v /vagrant/inventories/dev/group_vars/dev.yml:/etc/ansible/hosts/group_vars/dev.yml \
        -v /vagrant/inventories/test/group_vars/test.yml:/etc/ansible/hosts/group_vars/test.yml \
        $PLAYBOOKS $TEST_HOSTVARS $DEV_HOSTVARS ansible-sandbox
}

_mountAllFiles() {
   cd /vagrant$1 && for f in *.yml; do echo -n "-v /vagrant$1/$f:/etc/ansible$2/$f "; done
}
