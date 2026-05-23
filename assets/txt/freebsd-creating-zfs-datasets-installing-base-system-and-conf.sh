#!/bin/sh

set -e

DISK=nda1
SWAP_LABEL=swap0
ZFS_LABEL=zfs0
ROOT=/tmp/zroot

zfs create -o mountpoint=none zroot/ROOT
zfs create -o mountpoint=/ zroot/ROOT/default
zfs create -o mountpoint=/tmp -o exec=on -o setuid=off zroot/tmp
zfs create -o mountpoint=/usr -o canmount=off zroot/usr
zfs create zroot/usr/home
zfs create -o setuid=off zroot/usr/ports
zfs create -o mountpoint=/var -o canmount=off zroot/var
zfs create -o exec=off -o setuid=off zroot/var/audit
zfs create -o exec=off -o setuid=off zroot/usr/src
zfs create -o exec=off -o setuid=off zroot/var/crash
zfs create -o exec=off -o setuid=off zroot/var/log
zfs create -o atime=on zroot/var/mail
zfs create -o setuid=off zroot/var/tmp

echo ">>> Setting permissions"
# chmod 1777 ${ROOT}/tmp/
# chmod 1777 ${ROOT}/var/tmp/

echo ">>> Creating /home symlink"
ln -sf usr/home ${ROOT}/home
 
echo ">>> Installing base system"
tar xpf /usr/freebsd-dist/base.txz -C ${ROOT}
tar xpf /usr/freebsd-dist/kernel.txz -C ${ROOT}
tar xpf /usr/freebsd-dist/lib32.txz -C ${ROOT}

zpool set bootfs=zroot/ROOT/default zroot
# cachefile - Can be changed; e.g.: to /etc/zfs/zpool.cache
zpool set cachefile=/tmp/zroot/boot/zfs/zpool.cache zroot

echo ">>> Basic configuration"

# Make sure that ZFS is started at boot.
# This mounts your filesystem datasets at boot.
printf %s\\n 'zfs_enable="YES"' >> ${ROOT}/etc/rc.conf
 
# Tell FreeBSD to load ZFS and related kernel modules at boot.
printf %s\\n 'zfs_load="YES"' >> ${ROOT}/boot/loader.conf
 
printf %s\\n 'kern.geom.label.disk_ident.enable="0"' >> ${ROOT}/boot/loader.conf
printf %s\\n 'kern.geom.label.gptid.enable="0"' >> ${ROOT}/boot/loader.conf
 
printf "/dev/gpt/${SWAP_LABEL}\tnone\tswap\tsw\t0\t0\n" >> ${ROOT}/etc/fstab

exit 0
