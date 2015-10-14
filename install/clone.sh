#!/bin/bash

#script to install ubuntu-core on HDD

DEVICE=$1
ARCHIVE=$2
CLUSTER=$3
IP=$4

GITTREE=$(readlink -f $(dirname $(readlink -f $0))/../)

if [[ -z $1 || -z $2 || -z $3 || -z $4 ]]; then
  echo "Usage: script device archive cluster ip"
  exit 1
fi

set -e
#cleanup disk
dd if=/dev/zero of=/dev/${DEVICE} bs=1M count=100

#partition disk
parted -s /dev/${DEVICE} mktable gpt
parted -s /dev/${DEVICE} mklabel gpt
parted -s /dev/${DEVICE} mkpart primary 1049kB 15.7MB
parted -s /dev/${DEVICE} mkpart primary 15.7MB 16.0GB
parted -s /dev/${DEVICE} mkpart primary 16.0GB 100%
parted -s /dev/${DEVICE} set 1 bios_grub on 

#create btrfs
mkfs.btrfs -f /dev/${DEVICE}3
UUID_BTRFS_ROOT=`blkid -s UUID -o value /dev/${DEVICE}3`
mkswap -f /dev/${DEVICE}2
UUID_SWAP=`blkid -s UUID -o value /dev/${DEVICE}2`

#transfer system image
mkdir /mnt/${DEVICE}3
mount -o compress=lzo /dev/${DEVICE}3 /mnt/${DEVICE}3
btrfs subvolume create /mnt/${DEVICE}3/@
umount /mnt/${DEVICE}3
mount -o subvol=@,compress=lzo /dev/${DEVICE}3 /mnt/${DEVICE}3

d=`pwd`
cd /mnt/${DEVICE}3
tar -xpzf ${ARCHIVE}

#chroot and configure
##fstab and boot
mount --bind /dev  /mnt/${DEVICE}3/dev
mount --bind /proc /mnt/${DEVICE}3/proc
mount --bind /sys  /mnt/${DEVICE}3/sys
cat > /mnt/${DEVICE}3/etc/fstab << EOF
UUID=$UUID_BTRFS_ROOT / btrfs defaults,subvol=@,compress=lzo 0 1
UUID=$UUID_SWAP swap swap defaults 0 0
EOF
mkdir -p /mnt/${DEVICE}3/boot/grub
echo "(hd0)   /dev/${DEVICE}" > /mnt/${DEVICE}3/boot/grub/device.map
echo 'nameserver 8.8.8.8' > /mnt/${DEVICE}3/etc/resolv.conf
export DEBIAN_FRONTEND=noninteractive
chroot /mnt/${DEVICE}3 apt-get update 
chroot /mnt/${DEVICE}3 apt-get -y install vlan bridge-utils tasksel grub-pc acpid \
                        linux-headers-3.19.0-25-generic linux-image-3.19.0-25-generic \
                        openssh-server openssh-client openssh-blacklist openssh-blacklist-extra 
                     
chroot /mnt/${DEVICE}3 grub-install /dev/${DEVICE}
chroot /mnt/${DEVICE}3 update-grub

#root passwd and ssh keys
chroot /mnt/${DEVICE}3 usermod -p '$6$.WL1Wdmxj$UyjSmspA988qUw2jTdrNBDicWt9QPa0TlQL6gzEFIdX8n./sFEjkh9IoKAhpuNn4T/XZGAOSiiWwQ.TAnUUi4/' root
mkdir -p > /mnt/${DEVICE}3/root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVIcYnwPY552HdRFMvk/eCFnjbWPuWtHaLgC1OpEY7Gsvgx/A7pHGXN35kHwrBRbjzU37roaf+3S4aP+5H/sgJ1cLPZyoHSk9ZsH2vfKqsKPmsMX++AltoFRcCU1qIAId8FMAw5DHVKMPh0zANqN9Z8d1x/ek3DFef1HvFd3T/WfzewfsiTbFeLKTIl0sdA4O23Pyvz8xcxXUcAtcms0NvrmcZ0L4pJQQ5IRJO1f76myAXom1yPWwf36KNcfTAlW/nFU3EmVmb2hgmKr/fkaG1L1S5vw2BwohchpHA6x0d+2kJRZ40qcFMAjfy2wneMpneC30SWX0d2uHaJCUS/fy5 root@viz"  > /mnt/${DEVICE}3/root/.ssh/authorized_keys
chmod -R go-r /mnt/${DEVICE}3/root/.ssh

##network
cat > /mnt/${DEVICE}3/etc/network/interfaces << EOF
auto lo
   iface lo inet loopback

source /etc/network/interfaces.d/*.cfg
EOF
if [ ! -d /mnt/${DEVICE}3/etc/network/interfaces.d ]; then
    mkdir /mnt/${DEVICE}3/etc/network/interfaces.d
fi
cp $GITTREE/config/net-*-${CLUSTER}.cfg /mnt/${DEVICE}3/etc/network/interfaces.d
for f in /mnt/${DEVICE}3/etc/network/interfaces.d/*.cfg; do
    perl -i -pe "s/address 192\.168\.\d+\.XX/address 192.168.0.$IP/"  /mnt/${DEVICE}3/etc/network/interfaces.d/net-br-lan-${CLUSTER}.cfg
done

cd $d

###
echo "Success!!"
#echo "Run commands to umount image:"
umount /mnt/${DEVICE}3/proc
umount /mnt/${DEVICE}3/sys
umount /mnt/${DEVICE}3/dev
umount /mnt/${DEVICE}3
rmdir /mnt/${DEVICE}3
