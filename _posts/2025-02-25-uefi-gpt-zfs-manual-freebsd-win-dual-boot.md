---
layout: post
title: "FreeBSD ZFS and Windows 11 Dual Boot [UEFI GPT] [Manual Setup]" 
date: 2025-02-25 23:06:27 -0700 
categories: zfs freebsd windows boot howto cli terminal shell disk 
---

aka: RootOnZFS, GPTZFSBoot, ZFSBoot

OS 1: FreeBSD 14   
OS 2: Windows 11 Pro

---

KEYWORDS: FreeBSD ZFS RootOnZFS GPTZFSBoot ZFSBOOT UEFI GPT dualboot
          boot bootloader bootmanager rEFInd readonly writeable
          gpart geom zpool zfs label labelclear
          unionfs tmpfs manualinstall live livesystem liveCD
          ramdisk md(4) mdconfig(8) mdmfs(8)

---

## Code Snippets 

```
Reboot
F12
Select 'USB HDD'
FreeBSD Loader starts
Select '1. Boot Installer [Enter]"
```

```
FreeBSD Installer


    +-------------------------------------------+
    | welcome to FreeBSD! Would you like to     |
    | begin an installation or use the live     |
    | system?                                   |
    +-------------------------------------------+
    | [  Install  ] [   Shell   ] [Live System] |
    +-------------------------------------------+
```

```
Select  [   Shell   ]

(It will show the following message:)
"When finished, type 'exit' to return to the installer."
```

```
# kldload unionfs
# mkdir /tmp/etc /tmp/root
# mount -t unionfs /tmp/etc /etc
# mount -t unionfs /tmp/root /root

# ifconfig
---- snip ---
re0: flags=1008802<BROADCAST,SIMPLEX,MULTICAST,LOWER_UP> metric 0 mtu 1500
---- snip ---

# dhclient re0
---- snip ---
bound to 192.168.1.7 -- renewal in 43200 seconds.

# printf %s\\n "PermitRootLogin yes" >> /etc/ssh/sshd_config
# service sshd onestart
# passwd
```

```
### From another machine on the same network, remotely log in with SSH
ssh root@192.168.1.7

# mkdir /tmp/zroot
# kldload zfs

### Check for existence of previous ZFS pools
# zpool import
no pools available to import
```


```
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### If there are any, destroy them and clear labels
# zpool import -o altroot=/tmp/zroot zroot
# zpool destroy zroot

# gpart show -lp nda1
### Example output:
=>        34  3907029101    nda1  GPT  (1.8T)
          34        2014          - free -  (1.0M)
        2048      532480  nda1p1  EFI system partition  (260M)
      534528       32768  nda1p2  Microsoft reserved partition  (16M)
      567296  1801259008  nda1p3  Basic data partition  (859G)
  1801826304     4096000  nda1p4  Basic data partition  (2.0G)
  1805922304    16777216  nda1p5  tPadE14-swap0  (8.0G)
  1822699520  2076180480  nda1p6  tPadE14-zfs0  (990G)
  3898880000     8149135          - free -  (3.9G)

# zpool labelclear -f /dev/nda1
# zpool labelclear -f /dev/nda1p1
# zpool labelclear -f /dev/nda1p2
# zpool labelclear -f /dev/nda1p3
# zpool labelclear -f /dev/nda1p4
# zpool labelclear -f /dev/nda1p5
# zpool labelclear -f /dev/nda1p6

### To check:
# zdb -llll -d /dev/nda1
# zdb -llll -d /dev/nda1p1
# zdb -llll -d /dev/nda1p2
# zdb -llll -d /dev/nda1p3
# zdb -llll -d /dev/nda1p4
# zdb -llll -d /dev/nda1p5
# zdb -llll -d /dev/nda1p6

# glabel stop /dev/gpt/tPadE14-swap0
# glabel stop /dev/gpt/tPadE14-zfs0
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

```
### Continue with installation

### From 'gpart show -lp nda1' example above, the previous installation attempt
### left partitions at index 5 and index 6.  They can be deleted for this
### new fresh installation.

# gpart delete -i5 nda1
# gpart delete -i6 nda1

# gpart show -lp nda1
=>        34  3907029101    nda1  GPT  (1.8T)
          34        2014          - free -  (1.0M)
        2048      532480  nda1p1  EFI system partition  (260M)
      534528       32768  nda1p2  Microsoft reserved partition  (16M)
      567296  1801259008  nda1p3  Basic data partition  (859G)
  1801826304     4096000  nda1p4  Basic data partition  (2.0G)
  1805922304  2101106831          - free -  (1.0T)


# sysctl vfs.zfs.min_auto_ashift=12

# gpart add -a 1m -t freebsd-swap -s 16G -l tPadE14-swap0 nda1
# gpart add -a 1m -t freebsd-zfs -s 980G -l tPadE14-zfs0 nda1

# zpool create -f -o altroot=/tmp/zroot -O compress=lz4 -O atime=off -m none zroot /dev/gpt/tPadE14-zfs0

### Alternatively, you could have used ZFS partition name:
### zpool create -f -o altroot=/tmp/zroot -O compress=lz4 -O atime=off -m none zroot nda1p6

### Test zpool export, then import
# zpool export zroot
# zpool import -o altroot=/tmp/zroot zroot

# zfs create -o mountpoint=none zroot/ROOT
# zfs create -o mountpoint=/ zroot/ROOT/default
# zfs create -o mountpoint=/tmp -o exec=on -o setuid=off zroot/tmp
# zfs create -o mountpoint=/usr -o canmount=off zroot/usr
# zfs create zroot/usr/home
# zfs create -o setuid=off zroot/usr/ports
# zfs create -o mountpoint=/var -o canmount=off zroot/var
# zfs create -o exec=off -o setuid=off zroot/var/audit
# zfs create -o exec=off -o setuid=off zroot/usr/src
# zfs create -o exec=off -o setuid=off zroot/var/crash
# zfs create -o exec=off -o setuid=off zroot/var/log
# zfs create -o atime=on zroot/var/mail
# zfs create -o setuid=off zroot/var/tmp

# zpool set bootfs=zroot/ROOT/default zroot
# zpool set cachefile=/tmp/boot/zfs/zpool.cache zroot    ### [1] 

# chmod 1777 /tmp/zroot/tmp/
# chmod 1777 /tmp/zroot/var/tmp/

# cd /tmp/zroot/
# ln -s usr/home home

# tar xpJf /usr/freebsd-dist/base.txz
# tar xpJf /usr/freebsd-dist/lib32.txz
# tar xpJf /usr/freebsd-dist/kernel.txz

### Make sure that ZFS is started at boot.
### This mounts your filesystem datasets at boot.
# printf %s\\n 'zfs_enable="YES"' >> /tmp/zroot/etc/rc.conf

### Tell FreeBSD to load ZFS and related kernel modules at boot.
# printf %s\\n 'zfs_load="YES"' >> /tmp/zroot/boot/loader.conf

# printf %s\\n 'kern.geom.label.disk_ident.enable="0"' >> /tmp/zroot/boot/loader.conf
# printf %s\\n 'kern.geom.label.gptid.enable="0"' >> /tmp/zroot/boot/loader.conf

# printf "/dev/gpt/tPadE14-swap0\tnone\tswap\tsw\t0\t0\n" >> /tmp/zroot/etc/fstab

# cd /tmp/
# fetch https://netactuate.dl.sourceforge.net/project/refind/0.14.2/refind-bin-0.14.2.zip

# unzip refind-bin-0.14.2.zip
# rm -i refind-bin-0.14.2.zip

# mkdir /tmp/efi
# mount -t msdosfs /dev/gpt/EFI%20system%20partition /tmp/efi/

# cd /tmp/efi/EFI/Boot/
# mv bootx64.efi bootx64-win.efi
# cp -i /boot/loader.efi bootx64-freebsd.efi
# cp -i /tmp/refind-bin-0.14.2/refind/refind_x64.efi bootx64-refind.efi
# cp -i /tmp/refind-bin-0.14.2/refind/refind.conf-sample refind.conf
# cp -a /tmp/refind-bin-0.14.2/refind/icons .

# vi refind.conf

# tail refind.conf

menuentry "FreeBSD/amd64 -RELEASE" {
    loader \EFI\Boot\bootx64-freebsd.efi
    icon \EFI\Boot\icons\os_freebsd.png
}

menuentry "Windows 11 Professional x64" {
    loader \EFI\Boot\bootx64-windows11.efi
    icon \EFI\Boot\icons\os_win.png
}

# efibootmgr -v
---- snip ----

# efibootmgr --dry-run --verbose --create --activate --label "FreeBSD" --loader "/tmp/efi/EFI/Boot/bootx64-refind.efi"
# efibootmgr --verbose --create --activate --label "FreeBSD" --loader "/tmp/efi/EFI/Boot/bootx64-refind.efi"
# efibootmgr --create --loader "/tmp/efi/EFI/Boot/bootx64-refind.efi" --label "rEFInd" --activate --dry-run
# efibootmgr --create --loader "/tmp/efi/EFI/Boot/bootx64-refind.efi" --label "rEFInd" --activate

# efibootmgr -v
---- snip ----

# cd /tmp
# umount /tmp/efi/
# reboot
```

Unplug the FreeBSD Installer USB flash disk drive.

After reboot, you will need to create the root password (at this point, the root password is empty). 
Log in as root using the system's console, and continue setting up the new machine. 

```
FreeBSD/amd64 (Amnesiac) (ttyv0)
login:
```

It's not recommended to enable `PermitRootLogin` again but if you wanted to, you would need to perform the following steps.


```
# dhclient re0
# cp -i /etc/ssh/sshd_config /etc/ssh/sshd_config.ORIG
# printf %s\\n "PermitRootLogin yes" >> /etc/ssh/sshd_config
# service sshd onestart
# passwd
```

[1]: Can be changed; e.g.: to /etc/zfs/zpool.cache

----

## Overview

### General Overview

* Create a partition to reserve space for FreeBSD (to prevent the Windows installer from using the entire disk)
* Install Windows
* Install FreeBSD
* (Optional) Install an EFI boot manager (such as rEFInd), or use the bootmanager of the EFI firmware

- Shrink the disk from within Windows, then install FreeBSD.
- If the installer does not recognize the unallocated space, try manually partitioning from within the installer, and if that doesn't work, go to a live FreeBSD session to partition, then reboot and install.

----

## Tips and Tricks

* If you need network connection during FreeBSD installation, it's better to use Ethernet (wired networking) because WiFi (wireless network) can be unreliable.

* You just need a Live FreeBSD enviroment to conduct your manual install.
Make sure it is *11.0* or newer for UEFI *boot1 ZFS support*.
The *USB images* with FreeBSD 11.0 and later -RELEASE have UEFI support integrated so they are directly bootable on UEFI machines.
You could also use a CD/DVD or netboot.

* In FreeBSD installer, when you choose [Live System], then ```/mnt``` will be  read-only.
Similarly, when you choose [  Shell  ], then ```/mnt``` will also be  read-only.

You don't need ```/mnt``` to be writeable.
Instead, you can use *unionfs* for ```/etc``` and ```/root```.

```
# mkdir /tmp/etc /tmp/root
# mount -t unionfs /tmp/etc /etc
# mount -t unionfs /tmp/root /root
```

If do want a writeable ```/mnt```, you can unionfs for it too, or you can use *mdmfs, mount_mfs(8)* to configure and mount an *in-memory file system* using the md 4 driver (see ```man 4 md```) or the tmpfs 5 filesystem (see ```man 5 tmpfs```).

* In my tests, using *sed(1)* in FreeBSD installer for modifying ```sshd_config``` caused a crash.

```
# sed -i.bak "s/PermitRootLogin no/PermitRootLogin yes/" /etc/ssh/sshd_config
```

Using *vi(1)* to edit ```sshd_config``` worked. (```# vi /etc/ssh/sshd_config```)

----

## References

* [FreeBSD Mastery: ZFS - M.W. Lucas and Allan Jude](https://mwl.io/nonfiction/os#fmzfs)

* [FreeBSD UEFI Root on ZFS and Windows Dual Boot](http://kev009.com/wp/2016/07/freebsd-uefi-root-on-zfs-and-windows-dual-boot/)

* [Installing FreeBSD manually (no installer)](https://forums.freebsd.org/threads/installing-freebsd-manually-no-installer.63201/)

* [[UEFI/GPT] [Dual-Boot] How to install FreeBSD (with ZFS) alongside another OS (sharing the same disk)](https://forums.freebsd.org/threads/uefi-gpt-dual-boot-how-to-install-freebsd-with-zfs-alongside-another-os-sharing-the-same-disk.75734/)

* [FreeBSD Alongside Windows](https://vermaden.wordpress.com/2025/02/02/freebsd-alongside-windows/)

* [Install Environment](https://wiki.freebsd.org/MasonLoringBliss/InstallEnvironment)

* [ZFS and GELI by Hand](https://wiki.freebsd.org/MasonLoringBliss/ZFSandGELIbyHAND)

* [How To Dual Boot Windows 11 and FreeBSD 14 (GELI Encrypted ZFS Root + UFS Boot Drive)](https://forums.freebsd.org/threads/how-to-dual-boot-windows-11-and-freebsd-14-geli-encrypted-zfs-root-ufs-boot-drive.92472/)

* [Resources or guides for UEFI dual-boot with Windows? (self.freebsd)](https://old.reddit.com/r/freebsd/comments/x9znz8/resources_or_guides_for_uefi_dualboot_with_windows/)

* [zdb and zpool cache-files?](https://www.truenas.com/community/threads/zdb-and-zpool-cache-files.50760/)

----

