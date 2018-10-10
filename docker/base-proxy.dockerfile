# Copyright: (c) 2018, Hangsu Ma (hangsu@beag.biz)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)
FROM ubuntu:18.04
ARG ANSIBLE_RELEASE=2.7.0
ARG PROXY
RUN  export http_proxy="${PROXY}" \
 && export https_proxy="${PROXY}" \
 && apt-get update \
 && apt-get install software-properties-common vim -y \
 && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver-options http-proxy="${PROXY}" --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 \
 && apt-get update \
 && apt-get install -y ansible=${ANSIBLE_RELEASE}-1ppa~bionic \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN echo "cd /etc/ansible" >> ~/.bashrc
