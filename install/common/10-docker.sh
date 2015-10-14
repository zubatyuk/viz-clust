#!/bin/bash

#install docker
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update && apt-get install docker-engine curl

#add group for admin user
usermod -a -G docker admin 

#enable memory and swap on system
echo 'GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"' >> /etc/default/grub
update-grub

#docker-compose
curl -L https://github.com/docker/compose/releases/download/1.4.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#crane
bash -c "`curl -sL https://raw.githubusercontent.com/michaelsauter/crane/v2.0.1/download.sh`"
mv crane /usr/local/bin/crane

#pipework
apt-get install curl
curl -L https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework > /usr/local/bin/pipework
chmod +x /usr/local/bin/pipework

