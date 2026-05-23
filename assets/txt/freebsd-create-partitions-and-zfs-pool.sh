#!/bin/sh

set -e

DISK=nda1
SWAP_LABEL=swap0
ZFS_LABEL=zfs0
ROOT=/tmp/zroot

mkdir -p ${ROOT}

echo ">>> Loading ZFS"
kldload zfs || true
sysctl vfs.zfs.min_auto_ashift=12

echo ">>> Current partition layout"
gpart show ${DISK}

echo ">>> Creating FreeBSD partitions"
gpart add -a 1m -t freebsd-swap -s 16G -l ${SWAP_LABEL} ${DISK}
gpart add -a 1m -t freebsd-zfs -l ${ZFS_LABEL} ${DISK}

echo ">>> New partition layout"
gpart show ${DISK}

echo ">>> Creating ZFS pool"

zpool create -f \
  -o altroot=${ROOT} \
  -O compress=lz4 \
  -O atime=off\
  -m none \
  zroot /dev/gpt/${ZFS_LABEL}

echo ">>> Now test zpool export, then import"
echo ">>>"
echo ">>> RUN:"
echo ">>> # zpool export zroot"
echo ">>> # zpool import -o altroot=/tmp/zroot zroot"

exit 0
