# Copyright: (c) 2018, Hangsu Ma (hangsu@beag.biz)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)
FROM ubuntu:18.04
ARG ANSIBLE_RELEASE=2.7.0
RUN  apt-get update \
 && apt-get install software-properties-common vim -y \
 && apt-add-repository --yes --update ppa:ansible/ansible \
 && apt-get install -y ansible=${ANSIBLE_RELEASE}-1ppa~bionic \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN echo "cd /etc/ansible" >> ~/.bashrc

