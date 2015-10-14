#!/bin/bash

useradd -m -U admin
mkdir -p /home/admin/.ssh
cat >> /home/admin/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVIcYnwPY552HdRFMvk/eCFnjbWPuWtHaLgC1OpEY7Gsvgx/A7pHGXN35kHwrBRbjzU37roaf+3S4aP+5H/sgJ1cLPZyoHSk9ZsH2vfKqsKPmsMX++AltoFRcCU1qIAId8FMAw5DHVKMPh0zANqN9Z8d1x/ek3DFef1HvFd3T/WfzewfsiTbFeLKTIl0sdA4O23Pyvz8xcxXUcAtcms0NvrmcZ0L4pJQQ5IRJO1f76myAXom1yPWwf36KNcfTAlW/nFU3EmVmb2hgmKr/fkaG1L1S5vw2BwohchpHA6x0d+2kJRZ40qcFMAjfy2wneMpneC30SWX0d2uHaJCUS/fy5 admin@viz
EOF
chmod -R go- /home/admin/.ssh
chown -R admin:admin /home/admin/.ssh

