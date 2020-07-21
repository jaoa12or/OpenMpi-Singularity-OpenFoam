#!/usr/bin/env bash

sudo yum install nfs-utils nfs4-acl-tools -y
sudo systemctl start nfs-server.service
sudo systemctl enable nfs-server.service