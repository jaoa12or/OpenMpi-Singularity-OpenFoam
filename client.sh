#!/usr/bin/env bash

sudo yum install nfs-utils nfs4-acl-tools -y
sudo systemctl start nfs-server.service
sudo systemctl enable nfs-server.service
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo yum update
sudo yum install htop -y