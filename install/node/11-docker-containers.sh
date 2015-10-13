#!/bin/bash

containers="xorg-nvidia-352 sage2-client-chrome"

cd $HOME
git clone https://github.com/zubatyuk/docker-containers.git
cd docker-containers
git pull

for container in $containers; do
  echo "Buiding $container"

  cd $container

  rm Dockerfile.1
  set -o noglob
  cat Dockerfile | while read line; do
    echo $line >> Dockerfile.1
    if [[ $line == FROM* ]] ; then
        echo "ADD https://raw.githubusercontent.com/zubatyuk/docker-containers/master/aptproxy.sh /tmp/" >> Dockerfile.1
        echo "RUN chmod 777 /tmp/aptproxy.sh && /tmp/aptproxy.sh" >> Dockerfile.1
    fi
  done
  echo "RUN /tmp/aptproxy.sh clean && rm /tmp/aptproxy.sh" >> Dockerfile.1

  docker build --rm -t zubatyuk/$container -f ./Dockerfile.1 .
  rm ./Dockerfile.1
  cd ..

done
