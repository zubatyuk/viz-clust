#!/bin/bash

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
tar --acls --xattrs --keep-directory-symlink --numeric-owner --selinux -xzf ${ARCHIVE}

#chroot and configure
##fstab and boot
mount --bind /dev  /mnt/${DEVICE}3/dev
mount --bind /proc /mnt/${DEVICE}3/proc
mount --bind /sys  /mnt/${DEVICE}3/sys
cat > /mnt/${DEVICE}3/etc/fstab << EOF
UUID=$UUID_BTRFS_ROOT / btrfs defaults,subvol=@,compress=lzo 0 1
UUID=$UUID_SWAP swap swap defaults 0 0
EOF
echo "(hd0)   /dev/${DEVICE}" > /mnt/${DEVICE}3/boot/grub/device.map
echo 'nameserver 8.8.8.8' > /mnt/${DEVICE}3/etc/resolv.conf
chroot /mnt/${DEVICE}3 apt-get update 
chroot /mnt/${DEVICE}3 apt-get -y install vlan bridge-utils tasksel grub2 acpid linux-headers-3.19.0-25-generic linux-image-3.19.0-25-generic 
chroot /mnt/${DEVICE}3 grub-install /dev/${DEVICE}
chroot /mnt/${DEVICE}3 update-grub

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
    python $GITTREE/scripts/net-rand-xx.py $f
done

## reconfig ssh keys
rm -f //mnt/${DEVICE}3/etc/ssh/ssh_host_*
cat > /mnt/${DEVICE}3/etc/rc.local << EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

if [ -f /firstboot ]; then
  dpkg-reconfigure openssh-server

  rm /firstboot
fi

exit 0
EOF
touch /mnt/${DEVICE}3/firstboot

cd $d

###
echo "Success!!"
echo "Run commands to umount image:"
echo umount /mnt/${DEVICE}3/dev
echo umount /mnt/${DEVICE}3/proc
echo umount /mnt/${DEVICE}3/sys
echo umount /mnt/${DEVICE}3
echo rmdir /mnt/${DEVICE}3
