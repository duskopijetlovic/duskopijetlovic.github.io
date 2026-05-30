#!/bin/sh

set -e

# !!!!!!!!!!
# In all commands below, replace  nda1  with your actual device.
# Double-check -- Writing to the wrong device destroys data. 
# !!!!!!!!!!

#
# If needed, adjust
#     ZFS_PARTITION_SIZE, and/or
#     SWAP_SIZE
#

DISK=nda1
SWAP_LABEL=swap0
SWAP_SIZE=2G
ZFS_LABEL=zfs0
ZFS_PARTITION_SIZE=1T
ROOT=/tmp/zroot

mkdir -p ${ROOT}

echo ">>> Loading ZFS"
kldload zfs || true
sysctl vfs.zfs.min_auto_ashift=12

echo ">>> Current partition layout"
gpart show ${DISK}

echo ">>> Creating FreeBSD partitions"
gpart add -a 1m -t freebsd-swap -s ${SWAP_SIZE} -l ${SWAP_LABEL} ${DISK}
# For creating a freebsd-zfs partition occupying the rest of disk space:
#gpart add -a 1m -t freebsd-zfs -l ${ZFS_LABEL} ${DISK}
# For creating a freebsd-zfs partition by specifying the size of the partition:
gpart add -a 1m -t freebsd-zfs -s ${ZFS_PARTITION_SIZE} -l ${ZFS_LABEL} ${DISK}

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
