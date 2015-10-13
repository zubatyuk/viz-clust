#!/bin/bash

apt-get install -y software-properties-common
add-apt-repository ppa:xorg-edgers/ppa -y
add-apt-repository ppa:graphics-drivers/ppa -y
apt-get update && apt-get upgrade -y
apt-get update && apt-get install -y nvidia-352 bumblebee mesa-vdpau-drivers
