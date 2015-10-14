#!/bin/bash

SCRIPTDIR=$(dirname $(readlink -f ${0%/*}))

function inst {
    DIR=$1
    NAME=$2
    install ${DIR}/upstart/docker-${NAME}.conf /etc/init
    sed -i -e "s|%INSTALLDIR%|$SCRIPTDIR|g" /etc/init/docker-${NAME}.conf 
    service docker-${NAME} restart
}

#installation
inst $SCRIPTDIR apt-cacher-ng
inst $SCRIPTDIR dnsmasq
