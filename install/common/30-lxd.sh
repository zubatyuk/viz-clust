#!/bin/bash

add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
apt-get update
apt-get dist-upgrade -y
apt-get install lxd -y

usermod -a -G lxd admin
