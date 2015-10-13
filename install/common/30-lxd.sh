#!/bin/bash

add-apt-repository ppa:ubuntu-lxc/lxd-stable
apt-get update
apt-get dist-upgrade
apt-get install lxd

usermod -a -G lxd admin
