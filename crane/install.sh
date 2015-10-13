#!/bin/bash

SCRIPTDIR=$(dirname $(readlink -f ${0%/*}))
NAMES="apt-cacher-ng dnsmasq"

function inst {
    DIR=$1
    NAME=$2
    install ${DIR}/docker-${NAME}.conf /etc/init
    sed -i -e "s|%INSTALLDIR%|$SCRIPTDIR|g" /etc/init/docker-${NAME}.conf 
    service docker-${NAME} start
}

#installation
inst apt-cacher-ng
inst dnsmasq
