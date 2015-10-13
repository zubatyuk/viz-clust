#!/bin/bash

NAME=dnsmasq

docker pull zubatyuk/${NAME}
curl -L https://raw.githubusercontent.com/zubatyuk/docker-containers/master/${NAME}/docker-${NAME}.conf > /etc/init/docker-${NAME}.conf
mkdir /root/crane
curl -L https://raw.githubusercontent.com/zubatyuk/docker-containers/master/${NAME}/crane.yaml > /root/.crane/${NAME}.yaml

crane -c /root/.crane/${NAME}.yaml pull ${NAME}
service docker-${NAME} start
