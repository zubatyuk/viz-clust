#!/bin/bash

wd=$(dirname $(readlink -f ${0%/*}))

for script in $(find $wd/{common,$1} -name "*.sh" |awk -vFS=/ -vOFS=/ '{ print $NF,$0 }' |sort -n -t / |cut -f2- -d/); do
    bash $script
done
