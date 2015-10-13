#!/bin/bash

containers="apt-cacher-ng dnsmasq sage2-server"

cd $HOME
git clone https://github.com/zubatyuk/docker-containers.git
cd docker-containers

for container in $containers; do

  cd $container

  rm Donerfile.1
  cat Dockerfile | while read line; do
    echo $line >> Dockerfile.1
    if [[ $line == "FROM" ]] ; then
        echo "ADD https://raw.githubusercontent.com/zubatyuk/docker-containers/master/aptproxy.sh /root/" >> Dockerfile.1
        echo "RUN /bin/bash /root/aptproxy.sh" >> Dockerfile.1
    fi
  done
  echo "RUN /bin/bash /root/aptproxy.sh clean && rm /root/aptproxy.sh" >> Dockerfile.1
  
  docker build --rm zybatyuk/$container .

  cd ..
done



