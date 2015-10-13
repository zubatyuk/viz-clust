#!/bin/bash

#timezone
echo 'US/Central' > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
