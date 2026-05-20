---
layout: post
title: "FreeBSD ZFS and Windows 11 Dual Boot [UEFI GPT] [Manual Setup]" 
date: 2025-02-25 23:06:27 -0700 
categories: zfs freebsd windows boot howto cli terminal shell disk 
---

Updated: 2026-05-17 - Added specifics about the new laptop, Lenovo ThinkPad E14 Gen 6


aka: RootOnZFS, GPTZFSBoot, ZFSBoot

OS 1: FreeBSD 14   
OS 2: Windows 11 Pro

PC: Lenovo ThinkPad E14 Gen 6 laptop AMD model, Type (Machine Type or MT) 21M3 - customized

---

KEYWORDS: FreeBSD ZFS RootOnZFS GPTZFSBoot ZFSBOOT UEFI GPT dualboot
          boot bootloader bootmanager rEFInd readonly writeable
          gpart geom zpool zfs label labelclear
          unionfs tmpfs manualinstall live livesystem liveCD
          ramdisk `md(4)` `mdconfig(8)` `mdmfs(8)`

---

FreeBSD can be installed manually by extracting the base and kernel tarballs and later creating the config files in the `/etc/` directory. 

---

## Collect Information 

My *Lenovo ThinkPad E14 Gen 6 AMD model, Type (Machine Type or MT) 21M3* laptop is customized, with the base model Product Number: 21M3CTO1WW, and with Windows 11 Professional pre-installed.

Collect information from one of these three sources: 
* [User Guide - ThinkPad E14 Gen 6 and ThinkPad E16 Gen 2 - Lenovo](https://support.lenovo.com/ca/en/documentation/e14_g6_e16_g2), or
* [Lenovo ThinkPad E14 Gen 6 laptop AMD model (14-inch), Type (Machine Type or MT) 21M3 - Product Home](https://pcsupport.lenovo.com/ca/en/products/laptops-and-netbooks/thinkpad-edge-laptops/thinkpad-e14-gen-6-type-21m3-21m4/21m3/21m3cto1ww/), or
* Your Lenovo Account Order Details - Log in to your Lenovo account: [https://account.lenovo.com/](https://account.lenovo.com/), or
* Windows 11: PC and Windows 11 information, disk information, display settings. [<sup>[1](#footnotes)</sup>].

**Tech Specs (after/with my customizations) of this ThinkPad E14 Gen 6 AMD model** are listed in Footnotes [<sup>[2](#footnotes)</sup>].


## Any Other Preparation Steps 

For example, I had to:

* Move Windows Recovery partion to end of disk [<sup>[3](#footnotes)</sup>]
* Remove stale UEFI firmware boot entry (NVRAM entry) from my previous FreeBSD test installation. [<sup>[4](#footnotes)</sup>]


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
### [1]: Can be changed; e.g.: to /etc/zfs/zpool.cache

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

If you do want a writeable ```/mnt```, you can use *unionfs* for it too, or you can use *mdmfs, mount_mfs(8)* to configure and mount an *in-memory file system* using the md 4 driver (see ```man 4 md```) or the tmpfs 5 filesystem (see ```man 5 tmpfs```).

* In my tests, using *sed(1)* in FreeBSD installer for modifying ```sshd_config``` caused a crash.

```
# sed -i.bak "s/PermitRootLogin no/PermitRootLogin yes/" /etc/ssh/sshd_config
```

Using `vi(1)` to edit ```sshd_config``` worked. (```# vi /etc/ssh/sshd_config```)

----

## Footnotes

[1] **PC and Windows 11 Information, disk information, display settings**

This laptop (Lenovo ThinkPad E14 Gen 6 AMD model) comes with Windows 11 Professional pre-installed.

In Windows: Press **Window key** + **E** to open Windows Explorer.
Right-click on *This PC*, click on *Properties*

```
Device specifications

Processor: AMD Ryzen 7 7735U with Radeon Graphics   2.70 GHZ
Installed RAM: 32.0 GB (30.8 GB usable)
. . . 
Pen and touch: Touch support with 10 touch points 

Device specifications

Edition: Windows 11 Pro 
```

Press **Windows Key** + **R** to open Windows Run Command Dialog Box, and then type in:

```
msinfo32
```

In *System information* window, under *System Summary*: 

```
Processor: AMD Ryzen 7 7735U with Radeon Graphics, 2701 Mhz, 8 Core(s), 16 Logical Processor(s) 
```


**Disk Information**

Press **Windows Key** + **R** to open Windows Run Dialog, and then type in:

```
diskmgmt.msc
```

From the *Disk Management* utility:

```
Disk 0 - 1863 GB: EFI 260 MB | D: 1860 GB NTFS | Recovery ~2 GB
Disk 1 - 1863 GB: EFI 260 MB | C: 236 GB NTFS (BitLocker Encrypted) | Recovery ~2 GB | Unallocated 1624 GB
```

Includes: Volume labels (C:, D:), Filesystem (NTFS), BitLocker status, Capacity + unallocated space, Visual/logical layout.


Press **Windows Key** + **R** to open Windows Run Dialog, and then type in:

```
diskpart
```

In the DiskPart, run the following commands:


```
list disk
select disk 0
list partition
detail disk
select disk 1
list partition
detail disk
list volume 
exit
```

From the output of the *diskpart* commands:

```
Disk 0
  Partition 1  System    260 MB   (EFI)
  Partition 2  Reserved   16 MB   (MSR)
  Partition 3  Primary  1860 GB   (D: NTFS)
  Partition 4  Recovery 2000 MB

Disk 1
  Partition 1  System    260 MB   (EFI)
  Partition 2  Reserved   16 MB   (MSR)
  Partition 3  Primary   236 GB   (C: NTFS, BitLocker)
  Partition 4  Recovery 2000 MB
```

Includes: Partition map (exact partition numbering), Hidden structures (MSR).

Disk 1 cannot be extended due to layout constraints. 
Constraint: Recovery partition blocks extension of C: into unallocated space.
Key rule: A partition can only be extended if unallocated space is immediately to its right.

NOTE: MSR = Microsoft Reserved Partition.
It's always a small (~16 MB), hidden partition that exists on GPT disks (on both disks), and that Windows reserves for internal disk management operations. 

**Note:** DiskPart doesn't display unallocated space in `list partition` or `detail disk`.  
It is inferred from `list disk` (Free column) and partition ordering (i.e., space after the last partition).

Current layout:

```
C: -> Recovery -> Unallocated
```

Required layout for extension:

```
C: -> Unallocated
```

Implication: The Recovery partition must be moved or removed.

Options:
* Delete Recovery -> extend C: -> recreate Recovery
* Move Recovery (requires third-party tool)
* Create a new volume from unallocated space (leave C: as-is)

In short: Recovery partition blocks extension.
C: must be adjacent to unallocated space.
Options: delete/move Recovery partition, or create new volume.

The current Disk 1 layout is actually helpful for installing FreeBSD alongside Windows, and the above constraint is not a problem for dual boot: 

```
EFI -> MSR -> C: -> Recovery -> Unallocated
```

I decided to create a "textbook"layout; that is:

```
EFI -> MSR -> C: -> Free space -> Recovery (last)
```

To do this, the Recovery partition needs to be moved to disk end by disabling WinRE (Windows Recovery Partition), deleting partition, extending C:, recreating WinRE partition, and re-enabling WinRE.
For steps on how to do, see [<sup>[3](#footnotes)</sup>] below.


**Display Settings**

Right-click anywhere on the desktop.
Select *Display settings*

Under *Scale & Layout*:

```
Scale: 150% (Recommended)
Display resolution: 1920 x 1200 (Recommended)
```


[2] My Lenovo ThinkPad E14 Gen 6 AMD - Tech Specifications

* Processor: AMD Ryzen 7 7735U Processor (2.70 GHz up to 4.75 GHz) - selected upgrade
* Storage: Dual M.2 slots - See ***Note*** below
* First Solid State Drive: 256 GB SSD M.2 2242 PCIe Gen4 TLC Opal - See ***Note*** below
* Second Solid State Drive: None - See ***Note*** below
* Operating System: Windows 11 Pro 64 - selected upgrade
* Memory (RAM): 32 GB DDR5-4800MHz (SODIMM) - (2 x 16 GB) - selected upgrade
* Display: 14-inch WUXGA (1920 x 1200), IPS, Anti-Glare, Touch, 45%NTSC, 300 nits, 60Hz, with 16:10 aspect ratio - selected upgrade
* Graphic Card: Integrated Graphics
* Camera: 1080P FHD RGB with Microphone and Privacy Shutter - selected upgrade
* Wireless: Realtek Wi-Fi 6 RTL8852BE 2x2 AX & Bluetooth® 5.1 or above
* Ethernet: Wired Ethernet
* Fingerprint Reader: No Fingerprint Reader
* Keyboard: Backlit, Black - English (US) - selected upgrade
* TPM Setting: Enabled Discrete TPM2.0
* Absolute BIOS Selection: BIOS Absolute Enabled
* Battery: 3 Cell Li-Polymer 57Wh - selected upgrade
* Power Cord: 65W USB-C Low Cost 90% PCC 2pin AC Adapter - US

**NOTE:** I've replaced the first SSD with a 2TB SDD and also installed another 2TB SSD in the second M.2 slot.
So, this laptop has 2 x 2TB SSDs.


[3] **Moving Windows Recovery Partion to End of Disk**

Backup important data.

Press **Win+R** to open Windows Run Dialog, and then type in:

```
cmd
```

Instead of pressing Enter, press **Ctrl + Shift + Enter** to launch an elevated Command Prompt (aka Run As Administrator).

Confirm BitLocker status:

```
manage-bde -status C:
```

If enabled, suspend protection before proceeding:

```
manage-bde -protectors -disable C:
```

Check WinRE (Windows Recovery) status:

```
reagentc /info
```

You should see:

```
Windows RE status: Enabled
```

Disable Windows Recovery (this detaches WinRE from the existing Recovery partition):

```
reagentc /disable
```

Delete Recovery partition

```
diskpart
select disk 1
list partition
select partition 4
delete partition override
exit
```

Result:

```
EFI -> MSR -> C: -> Unallocated
```

Start the Disk Management Utility:

```
diskmgmt
```

In the *Disk Management* utility, you should see:

```
Disk 0 - 1863 GB: EFI 260 MB | D: 1860 GB NTFS | Recovery ~2 GB
Disk 1 - 1863 GB: EFI 260 MB | C: 236 GB NTFS (BitLocker Encrypted) | Unallocated 1626 GB
```

Check WinRE (Windows Recovery) status:

```
reagentc /info
```

You should see: 

```
Windows RE status: Disabled
```

Create a partition for FreeBSD (leave ~2 GB for WinRE):

```
diskpart
list disk
```

Confirm: ~1626 GB Free


```
Free space: 1626 GB => 1,626,000 MB
Leave:            ~2,048 MB
```

So:

```
1626000 - 2048 = 1623950 MB
```

If you want a small safety buffer, you can do:

```
select disk 1
create partition primary size=1623000
```

which leaves a bit more than 2 GB.

Quick verification:

```
list partition
list disk
```

Result:

```
EFI -> MSR -> C: -> FreeBSD placeholder partition -> Unallocated (~40 GB)
```


Create a partition for WinRE (Windows Recovery):

```
create partition primary size=2048
```

```
list partition
```

showed:

```
list partition

  Partition ###  Type              Size     Offset
  -------------  ----------------  -------  -------
  Partition 1    System             260 MB  1024 KB
  Partition 2    Reserved            16 MB   261 MB
  Partition 3    Primary            236 GB   277 MB
  Partition 4    Primary           1585 GB   236 GB
* Partition 5    Primary           2048 MB  1822 GB
```

Select the WinRE partition:

```
select partition 5
```

Format this new partition:

```
format quick fs=ntfs label="WinRE"
```

Set it as a Recovery partition: 

```
set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
gpt attributes=0x8000000000000001
```

It makes it recognized by Windows as Recovery (`set id=...`), hidden and protected (`gpt attributes=...`).

Exit DiskPart:

```
exit
```

Then:

```
reagentc /enable
reagentc /info
```


Start the Disk Management Utility:

```
diskmgmt
```

In the *Disk Management* utility, you should see:

```
Disk 0 - 1863 GB: EFI 260 MB | D: 1860 GB NTFS | Recovery ~2 GB
Disk 1 - 1863 GB: EFI 260 MB | C: 236 GB NTFS (BitLocker Encrypted) | 1585 GB RAW | 2 GB | 38 GB Unallocated
```


[4] Remove stale UEFI firmware boot entry (NVRAM entry) from a previous FreeBSD test installation


Verify UEFI mode 

```
$ [ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
```

Expected output:

```
UEFI
```

List current UEFI boot entries

```
$ efibootmgr
```

Example output

```
BootCurrent: 001D
BootOrder: 0000,0001,0018,0019,001A,001B,001D,001C,001E,001F,0020
Boot0000* Windows Boot Manager
Boot0001* FreeBSD
. . . 

Boot0011 Boot Menu
Boot0012 Diagnostics Splash Menu
. . . 
```

Delete the entry

```
$ sudo efibootmgr -b 0001 -B
```

Verify removal:

```
$ efibootmgr
```


----

## References

* [FreeBSD Mastery: ZFS - M.W. Lucas and Allan Jude](https://mwl.io/nonfiction/os#fmzfs)

* [FreeBSD UEFI Root on ZFS and Windows Dual Boot](http://kev009.com/wp/2016/07/freebsd-uefi-root-on-zfs-and-windows-dual-boot/)

* [HOWTO: FreeBSD ZFS Madness - by vermaden - FreeBSD Forums - Start date Apr 26, 2012](https://forums.freebsd.org/threads/howto-freebsd-zfs-madness.31662/)

* [ThinkPad E14 Gen 6 and ThinkPad E16 Gen 2 - User Guide - Lenovo](https://support.lenovo.com/ca/en/documentation/e14_g6_e16_g2)

* [Lenovo ThinkPad E14 Gen 6 laptop AMD model (14-inch), Type (Machine Type or MT) 21M3 - Product Home](https://pcsupport.lenovo.com/ca/en/products/laptops-and-netbooks/thinkpad-edge-laptops/thinkpad-e14-gen-6-type-21m3-21m4/21m3/21m3cto1ww/)

* [Lenovo ThinkPad E14 Gen 6 (Type 21M3, 21M4), E16 Gen 2 (Type 21M5, 21M6) - Setup Guide in PDF](https://download.lenovo.com/pccbbs/mobiles_pdf/e14_g6_e16_g2_amd_sg_en_pl_pt_bg_pt-br_es.pdf) 

* [Lenovo ThinkPad E14 Gen 6 (14-inch AMD) Laptop - Sleek & powerful 14 inch entry-level SMB laptop - Lenovo CA](https://www.lenovo.com/ca/en/p/laptops/thinkpad/thinkpade/lenovo-thinkpad-e14-gen-6-14-inch-amd/len101t0095)

* [Lenovo ThinkPad E14 Gen 6 / ThinkPad E - Setup Guide in PDF](https://download.lenovo.com/pccbbs/mobiles_pdf/e14_g6_e16_g2_sg_en_it_nl_de_fr_ar_el.pdf)

* [Lenovo ThinkPad E14 Gen 6 and ThinkPad E16 Gen 2 Hardware Maintenance Manual - in PDF](https://download.lenovo.com/pccbbs/mobiles_pdf/e14_g6_e16_g2_hmm_en.pdf)

* [Lenovo ThinkPad E14 Gen 6 and ThinkPad E16 Gen 2 - User Guide - Download in HTML Format](https://download.lenovo.com/km/dita/prod/202602/e14_g6_e16_g2/f6e052abe49520d0c61655b8ab2e98e1_e14_g6_e16_g2/en/e14_g6_e16_g2.zip) 

* [Lenovo ThinkPad E14 Gen 6 and ThinkPad E16 Gen 2 - Safety and Warranty Guide - in PDF](https://download.lenovo.com/pccbbs/mobiles_pdf/class_b_ml_swg_en_fr_ar.pdf)

* [Lenovo ThinkPad E14 Gen 6 and ThinkPad E16 Gen 2 - Generic Safety and Compliance Notices (includes accessibility and ergonomic information, and cleaning and maintenance) - in PDF](https://download.lenovo.com/pccbbs/pubs/safety_compliance_notices/generic_notices_class_b_en.pdf) 

* Lenovo - Documentation content is subject to change without notice. To get the latest documentation, go to [https://pcsupport.lenovo.com](https://pcsupport.lenovo.com).

* [Installing FreeBSD manually (no installer)](https://forums.freebsd.org/threads/installing-freebsd-manually-no-installer.63201/)

* [Procedure for manual installation - FreeBSD Forums - Start date Jan 28, 2018](https://forums.freebsd.org/threads/procedure-for-manual-installation.64370/)

* [Disk Setup On FreeBSD - Warren Block - Archived on 2025-01-09](https://web.archive.org/web/20250109023806/http://www.wonkity.com/~wblock/docs/html/disksetup.html)
> 
> ```
> # gpart add -t freebsd da0
> # gpart set -a active -i 1 da0
> # gpart create -s bsd da0s1
> # gpart bootcode -b /boot/boot da0s1 
> ```

* [[UEFI/GPT] [Dual-Boot] How to install FreeBSD (with ZFS) alongside another OS (sharing the same disk)](https://forums.freebsd.org/threads/uefi-gpt-dual-boot-how-to-install-freebsd-with-zfs-alongside-another-os-sharing-the-same-disk.75734/)

* [[Solved] manually installing FreeBSD (without bsdinstall) - FreeBSD Forums - Mar 7, 2025](https://forums.freebsd.org/threads/manually-installing-freebsd-without-bsdinstall.97092/)

* [How to manually install FreeBSD on a remote server (with UFS, ZFS, encryption...)](https://stanislas.blog/2018/12/how-to-install-freebsd-server/)

* [FreeBSD Alongside Windows - vermaden](https://vermaden.wordpress.com/2025/02/02/freebsd-alongside-windows/)

* [Install FreeBSD with One Command - vermaden](https://vermaden.wordpress.com/2024/11/10/install-freebsd-with-one-command/)

* [Bug 279622 - Change Default bsdinstall(8) Partition Sizes for Auto (ZFS) Option - FreeBSD Bugzilla](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=279622)

* [ZFS and GELI by Hand - Mason Loring Bliss - FreeBSD Wiki](https://wiki.freebsd.org/MasonLoringBliss/ZFSandGELIbyHAND)

* [Install Environment - Mason Loring Bliss - FreeBSD Wiki](https://wiki.freebsd.org/MasonLoringBliss/InstallEnvironment)
> I tend to use my install docs by copying and pasting the lines in, adjusting as needed.
>
> I boot from the install ISO, generally a memstick image for physical machines, and go into a live session.
> 
> From the live session, I want to ssh in from an established system to do the install.
> However, running sshd is a small challenge. To overcome this, I do the following: 
>
> . . .
>

* [How do I boot FreeBSD from GRUB on a UEFI system? -aka- Booting FreeBSD from UEFI GRUB - by Mason Loring Bliss - FreeBSD Wiki](https://wiki.freebsd.org/MasonLoringBliss/BootingFreeBSDfromUEFIGRUB)

* [ZFS and GELI by Hand](https://wiki.freebsd.org/MasonLoringBliss/ZFSandGELIbyHAND)

* [How To Dual Boot Windows 11 and FreeBSD 14 (GELI Encrypted ZFS Root + UFS Boot Drive)](https://forums.freebsd.org/threads/how-to-dual-boot-windows-11-and-freebsd-14-geli-encrypted-zfs-root-ufs-boot-drive.92472/)

* [Installing FreeBSD Alongside Ubuntu and Windows - FreeBSD Forums - Start date Oct 11, 2019](https://forums.freebsd.org/threads/installing-freebsd-alongside-ubuntu-and-windows.72610/) 

* [FreeBSDInstallationGuide - How to install and setup FreeBSD - Daniel Tameling on GitHub](https://github.com/daniel-tameling/FreeBSDInstallationGuide)

* [How do I install FreeBSD 11.2 manually in a desktop PC (without bsd installer - AKA: bsdinstall(8) - system installer)](https://forum.level1techs.com/t/how-do-i-install-freebsd-11-2-manually-in-a-desktop-pc-without-bsd-installer/133864)

* [Remote Installation of the FreeBSD Operating System Without a Remote Console - FreeBSD Documentation - Articles](https://docs.freebsd.org/en/articles/remote-install/)

* [Linux system possible to install FreeBSD using a mfsBSD image - FreeBSD Forums - Start date Aug 9, 2022](https://forums.freebsd.org/threads/linux-system-possible-to-install-freebsd-using-a-mfsbsd-image.86107/)

* [mfsBSD and mfslinux](https://mfsbsd.vx.sk/)
> This is a set of scripts that generates a bootable image (and/or ISO file), that creates a working minimal installation of FreeBSD (mfsBSD) or Linux (mfslinux).
> 
> It is completely loaded into memory.
> 
> Mfslinux is based on [OpenWrt](https://openwrt.org/).

* [depenguin-run -- Installer script for mfsBSD image to install FreeBSD with zfs-on-root using qemu](https://github.com/depenguin-me/depenguin-run)

* [Solved - Installing FreeBSD in Hetzner - The FreeBSD Forums - Jul 13, 2022](https://forums.freebsd.org/threads/installing-freebsd-in-hetzner.85399/#post-574863)

* [depenguin.me - Follow these instructions to Install FreeBSD on a dedicated server from a Linux rescue environment](https://depenguin.me/)
>
> 1. Boot into the rescue console for your dedicated server
>
> * Hetzner Rescue - [Hetzner Rescue System](https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/)
> * OVHCloud Rescue - [Rescue Mode on a Dedicated Server](https://help.ovhcloud.com/csm/en-dedicated-servers-ovhcloud-rescue?id=kb_article_view&sysparm_article=KB0043949)
> * Xneelo Rescue - [How to use the Linux Rescue system on your Self-Managed Server](https://xneelo.co.za/help-centre/control-panel/linux-rescue-system-self-managed-server/)
> 
> SSH into the rescue control as root.
> Prepare file path or URL of SSH public key.
>
> . . . 
>

* [depenguin.me - ELI5 - explain like I'm 5](https://depenguin.me/eli5.html)
> **ELI5** 
> 
> **Booting**
> 
> Computers can boot from CDROM, hard drives and USB drives.
> 
> A server can also boot from the network. This is how a rescue console is provided on servers.
> 
> **Rescue Console / Recovery Console**
> 
> The provider's control panel is used to send a signal to the server to use network boot on next reboot.
> 
> This might be a minimal Linux distribution, or minimal windows environment.
> 
> The server is rebooted into the configured rescue environment with networking and disk access.

* [Install FreeBSD (Short and Sweet Version)](https://www.dwarmstrong.org/freebsd-install/)

* [How To Install FreeBSD 15 Step-by-Step](https://ostechnix.com/install-freebsd/)

* [FreeBSD on Hetzner dedicated servers - VX Weblog](https://blog.vx.sk/archives/353)

* [Installing FreeBSD with OpenZFS via the Linux rescue system](https://community.hetzner.com/tutorials/freebsd-openzfs-via-linux-rescue)

* [Installing FreeBSD on older dedicated servers via the Linux rescue system](https://community.hetzner.com/tutorials/freebsd-with-qemu-via-linux-rescue)

* [Resources or guides for UEFI dual-boot with Windows? (self.freebsd)](https://old.reddit.com/r/freebsd/comments/x9znz8/resources_or_guides_for_uefi_dualboot_with_windows/)

* [zdb and zpool cache-files?](https://www.truenas.com/community/threads/zdb-and-zpool-cache-files.50760/)

* [Chapter 2. Installing FreeBSD - 2.1. Synopsis (bsdinstall) - FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/bsdinstall/)

* [How do I install FreeBSD without bsdinstall?](https://unix.stackexchange.com/questions/242136/how-do-i-install-freebsd-without-bsdinstall)
> Look at the boot_command of this file ... 
>
> [github.com/jlduran/packer-FreeBSD/blob/main/packer.pkr.hcl](https://github.com/jlduran/packer-FreeBSD/blob/main/packer.pkr.hcl) for hints.

* [packer-FreeBSD - packer.pkr.hcl](https://github.com/jlduran/packer-FreeBSD/blob/main/packer.pkr.hcl)

* [InstallFest How-To Guide - FreeBSD Foundation - Part 1 of 2](https://freebsdfoundation.org/freebsd-project/resources/installfest-how-to-guide/)

* [InstallFest How-To Guide - Part 2 of 2](https://freebsdfoundation.org/freebsd-project/resources/installfest-how-to-guide-p2/)
> This Walkthrough is a Continuation of Part 1 of the InstallFest How-To Guide
> 
> [Follow the link here for part 1](https://freebsdfoundation.org/freebsd-project/resources/installfest-how-to-guide/)

----


