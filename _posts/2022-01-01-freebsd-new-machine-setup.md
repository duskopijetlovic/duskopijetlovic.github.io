---
layout: post
title: "Set Up a New Machine with UEFI FreeBSD RootOnZFS Dual Boot with Windows 10"
date: 2022-01-01 09:03:41 -0700 
categories: freebsd dotfiles zfs  
---

Hardware and operating systems:   

Laptop: [Lenovo ThinkPad X280 - Ultraportable 12.5'' Business Laptop](https://www.lenovo.com/us/en/p/laptops/thinkpad/thinkpadx/thinkpad-x280/22tp2tx2800)     
Disk:  1 TB NVMe SSD   [WDC PC SN730 SDBQNTY-1T00-1001 - Form Factor: M.2 2280 M-S3](https://www.westerndigital.com/products/internal-drives/pc-sn730-ssd#SDBQNTY-1TOO)    
FreeBSD 13.0   
Windows 10 Professional   


**Note:**   
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.


---- 

Start with a pre-installed Windows 10 that's already on the 
machine.  In this case, I wanted to start from a clean slate 
so I used the Lenovo factory recovery USB key to reformat the 
hard drive and reinstall Windows 10 Pro.  [¹](#footnotes) 
 
---- 

Some of the disk's 1 TB capacity is used for formatting and 
other functions and is not available for data storage. 
Windows reported that the C: volume's capacity is 953 GB.   

Log into Windows, and shrink the C: volume (Windows NTFS partition) to 
get some free space.   

After shrinking the C: volume, the disk is split like:

```
Reported by Windows Disk Management: 
Disk 0, Type: Basic, Size: 953.85 GB
WDC PC SN730 SDBQNTY-1T00-1001    
Device type:  Disk drives    
Location:     Location 4 (Bus Number 0, Target Id 0, LUN 0)    

+----------------------+--------+-----------+---------------+
| Volume               | File   | Capacity  | Partition     |
|                      | System |           | Type          |
+----------------------+--------+-----------+---------------+
| (Disk 0 partition 1) |        | 260 MB    | EFI           |
+----------------------+--------+-----------+---------------+
| (Disk 0 partition 4) |        | 1000 MB   | ms-recovery   |
+----------------------+--------+-----------+---------------+
| Windows (C:)         |  NTFS  | 220.20 GB | ms-basic-data |
+----------------------+--------+-----------+---------------+
| Unallocated          |        | 732.42 GB | - free -      |
+----------------------+--------+-----------+---------------+
```

Now you have free space so you can boot up with FreeBSD installer 
and install FreeBSD in that space.

Download FreeBSD CD ISO installer image for the amd64 architecture.

```
$ fetch \
https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/13.0/FreeBSD-13.0-RELEASE-amd64-disc1.iso
```

Insert a USB flash drive into an available USB slot on your workstation.

You can use [NomadBSD](https://www.nomadbsd.org/) for writing the FreeBSD 
installer image on the USB flash drive. 

NomadBSD is a FreeBSD-derived operating system distribution.    
> It's a persistent live system for USB flash drives.  Together with 
> automatic hardware detection and setup, it is configured to be used 
> as a desktop system that works out of the box, but can also be used 
> for data recovery, for educational purposes, or to test FreeBSD's 
> hardware compatibility.

```
% dmesg | tail
umass1 on uhub2
umass1: <Lexar USB Flash Drive, class 0/0, rev 2.00/11.00, addr 3> on usbus1
umass1:  SCSI over Bulk-Only; quirks = 0x8100
umass1:6:1: Attached to scbus6
da1 at umass-sim1 bus 1 scbus6 target 0 lun 0
da1: <Lexar USB Flash Drive 1100> Removable Direct Access SPC-2 SCSI device
da1: Serial Number AA3ZKR4IVHT7LBGW
da1: 40.000MB/s transfers
da1: 15263MB (31258624 512 byte sectors)
da1: quirks=0x2<NO_6_BYTE>
```

Create the FreeBSD installer USB stick.  
Write the **.iso** file to the inserted USB thumb drive with ```dd(1)``` command.

```
% sudo dd if=FreeBSD-13.0-RELEASE-amd64-disc1.iso of=/dev/da1 bs=1M conv=sync
```

Remove the installer USB stick.

You might need to adjust the BIOS configuration on the computer where 
you are installing FreeBSD to boot from the FreeBSD installer USB stick. 
Insert the installer USB stick into an available USB slot on the computer 
where you are installing FreeBSD.


Follow the prompts as per the FreeBSD Handbook's instructions.  [²](#footnotes)
 


The FreeBSD Boot Loader Menu similar to the following is displayed.    

```
   ______               ____   _____ _____
  |  ____|             |  _ \ / ____|  __ \
  | |___ _ __ ___  ___ | |_) | (___ | |  | |
  |  ___| '__/ _ \/ _ \|  _ < \___ \| |  | |
  | |   | | |  __/  __/| |_) |____) | |__| |
  | |   | | |    |    ||     |      |      |
  |_|   |_|  \___|\___||____/|_____/|_____/
                                                 ```                        `
 +-----------Welcome to FreeBSD------------+    s` `.....---.......--.```   -/
 |                                         |    +o   .--`         /y:`      +.
 |  1. Boot Multi user [Enter]             |     yo`:.            :o      `+-
 |  2. Boot Single user                    |      y/               -/`   -o/
 |  3. Escape to loader prompt             |     .-                  ::/sy+:.
 |  4. Reboot                              |     /                     `--  /
 |                                         |    `:                          :`
 |  Options:                               |    `:                          :`
 |  5. Kernel: default/kernel (1 of 1)     |     /                          /
 |  6. Boot Options                        |     .-                        -.
 |                                         |      --                      -.
 |                                         |       `:`                  `:`
 |                                         |         .--             `--.
 +-----------------------------------------+            .---.....----.

   Autoboot in 9 seconds, hit [Enter] to boot or any other key to stop
```

In the FreeBSD Boot Loader Menu, select 1. Boot Multi User [Enter]. 


[Tip - FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/bsdinstall/#bsdinstall-start):   
> To review the boot messages, including the hardware device probe, 
> press the upper- or lower-case **S** and then **Enter** to access a shell. 
> At the shell prompt, type more ```/var/run/dmesg.boot``` and use the space 
> bar to scroll through the messages.  When finished, type ```exit``` to 
> return to the welcome menu.


For details, see the FreeBSD Handbook instructions:

[2.4.4. FreeBSD Boot Menu - Chapter 2. Installing FreeBSD](https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/bsdinstall-start.html)

Once the boot is complete, the ``Welcome Menu'' is displayed.   
```
Welcome
Welcome to FreeBSD! Would you
like to begin an installation
or use the live CD?

<Install> < Shell > <Live CD>
```

Choose ```Shell```.  (When finished, you can type ```exit``` to return 
to the installer and continue installation, or to restart the system.)

```
# cd /tmp
```

If you would like to have a log of everything printed on your terminal 
during FreeBSD installation, start the ```script(1)``` utility.

```
# script
```

```
# mkdir /tmp/etc /tmp/root
# mount_unionfs /tmp/etc /etc
# mount_unionfs /tmp/root /root
# printf %s\\n 'PermitRootLogin yes' >> /etc/ssh/sshd_config
# passwd
# service sshd onestart
```

Add three FreeBSD slices (called partitions in other operating systems).   
The third partition is a ZFS slice, occupying the rest of the available 
free disk space. 

Label all three partitions with **GPT Labels**.  


```
# gpart add -a 4k -l swap0 -s 1G -t freebsd-swap nvd0
# gpart add -a 4k -l swap1 -s 4G -t freebsd-swap nvd0
# gpart add -a 4k -l zfs0 -t freebsd-zfs nvd0
```

Explanation:   
```-a 4k```:                align a partition on 4KB boundaries   
```-l <label_name>```:      create the label attached to the partition \<label_name\>   
```-s <partition_size>```:  create a partition of size \<partition_size\>   
```-t <partition_type>```:  create the partition type of \<partition_type\>   
(List of partition types is included in the man page for ```gpart(8)```)    


```
# gpart show
=>        34  2000409197  nvd0  GPT  (954G)
          34        2014        - free -  (1.0M)
        2048      532480     1  efi  (260M)
      534528       32768     2  ms-reserved  (16M)
      567296   461793280     3  ms-basic-data  (220G)
   462360576     2097152     5  freebsd-swap  (1.0G)
   464457728     8388608     6  freebsd-swap  (4.0G)
   472846336  1525514240     7  freebsd-zfs  (727G)
  1998360576     2048000     4  ms-recovery  (1.0G)
  2000408576         655        - free -  (328K)
```

Load the zfs module, create a ZFS pool, and export it.   


```
# kldload zfs
# sysctl vfs.zfs.min_auto_ashift=12
# mkdir /tmp/zroot
# zpool create -f -o altroot=/tmp/zroot -O compress=lz4 -O atime=off -m none zroot /dev/gpt/zfs0
# zpool export zroot
```

**Note:**    
To force ZFS to choose 4K disk blocks when creating zpools, set the 
tunable ```sysctl vfs.zfs.min_auto_ashift``` to 12. 

(If you want to make it permanent, add the following line 
 to ```/etc/sysctl.conf``` so that any future zpools created on 
 your system are created with 4K disk blocks):    

```
sysctl vfs.zfs.min_auto_ashift=12
```


Create ZFS datasets compatible with **BE (Boot Environment)** by placing 
the root dataset under ROOT.

```
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
# chmod 1777 /tmp/zroot/tmp
# chmod 1777 /tmp/zroot/var/tmp
```


Here you are installing FreeBSD manually so you need to extract a minimum 
FreeBSD installation, which includes three components: 
```base``` (Base system), ```lib32``` (32-bit compatibility 
libraries), ```kernel``` (Kernel).    

```
# cd /tmp/zroot
# ln -s usr/home home
# tar xvJpf /usr/freebsd-dist/base.txz
# tar xvJpf /usr/freebsd-dist/lib32.txz
# tar xvJpf /usr/freebsd-dist/kernel.txz
```

Ensure the ZFS module will be loaded by the loader.   

```
# printf %s\\n 'zfs_enable="YES"' >> /tmp/zroot/etc/rc.conf
# printf %s\\n 'zfs_load="YES"' >> /tmp/zroot/boot/loader.conf
```

To disable Disk ID labels and GPT GUID (GPT ID) labels,
add the following two lines in ```/boot/loader.conf``` 
so that disks are always ```gpt/<your_gpt_label_here>``` 
and never ```DISK-<disk_serial_number_here>```.  [³](#footnotes) 


```
# printf %s\\n 'kern.geom.label.disk_ident.enable="0"' >> /tmp/zroot/boot/loader.conf
# printf %s\\n 'kern.geom.label.gptid.enable="0"'  >> /tmp/zroot/boot/loader.conf
```

```
# printf %s\\n 'dumpdev="AUTO"' >> /tmp/zroot/etc/rc.conf
# printf %s\\n 'powerd_enable="YES"' >> /tmp/zroot/etc/rc.conf
```

Make a note of swap partitions.    

```
# printf "/dev/gpt/swap0\tnone\tswap\tsw\t0\t0\n" >> /tmp/zroot/etc/fstab
# printf "/dev/gpt/swap1\tnone\tswap\tsw\t0\t0\n" >> /tmp/zroot/etc/fstab
```

Set UTC to Yes or No, and select your time zone.

```
# tzsetup -C /tmp/zroot 
```

```
# chroot /tmp/zroot/
```

```
# passwd
```

Installing the FreeBSD boot manager overwrites the Windows boot code, 
resulting in an unbootable Windows.  To work around that, install 
**rEFInd**, an EFI boot manager utility, and configure it for a dual boot 
with FreeBSD and Windows 10.   

Note:   
If the steps outlined below don't work because you still don't have 
network connection, download **rEFInd** on a separate machine and copy 
it to the system you are installing FreeBSD on.  [⁴](#footnotes) 

```
# cd /tmp
# fetch https://iweb.dl.sourceforge.net/project/refind/0.13.2/refind-bin-0.13.2.zip
# unzip refind-bin-0.13.2.zip 
# rm refind-bin-0.13.2.zip
```

````
# mkdir /tmp/efi
# mount_msdosfs /dev/gpt/EFI%20system%20partition /tmp/efi/
# cd /tmp/efi/EFI/Boot
# mv bootx64.efi bootx64-windows-10.efi
# cp /boot/boot1.efi bootx64-freebsd.efi
# cp -a /tmp/refind-bin-0.13.2/refind/icons .
# cp -a /tmp/refind-bin-0.13.2/refind/refind_x64.efi bootx64.efi
# cp /tmp/refind-bin-0.13.2/refind/refind.conf-sample refind.conf
```


```
cat << EOF >> refind.conf

menuentry "FreeBSD/amd64 -RELEASE" {
    loader \EFI\Boot\bootx64-freebsd.efi
    icon \EFI\Boot\icons\os_freebsd.png
}

menuentry "Windows 10 x64" {
    loader \EFI\Boot\bootx64-windows-10.efi
    icon \EFI\Boot\icons\os_win.png
}
EOF
```

```
# cd
# reboot
```

----

First login into FreeBSD after fresh install.   

```
# ps $$
 PID TT  STAT    TIME COMMAND
1543  0  Ss   0:00.01 /bin/csh -i
```

```
# df -hT
Filesystem          Type     Size    Used   Avail Capacity  Mounted on
zroot/ROOT/default  zfs      701G    717M    701G     0%    /
devfs               devfs    1.0K    1.0K      0B   100%    /dev
zroot/tmp           zfs      701G    9.6M    701G     0%    /tmp
zroot/var/log       zfs      701G    140K    701G     0%    /var/log
zroot/usr/ports     zfs      701G     96K    701G     0%    /usr/ports
zroot/usr/home      zfs      701G     96K    701G     0%    /usr/home
zroot/var/crash     zfs      701G     96K    701G     0%    /var/crash
zroot/var/audit     zfs      701G     96K    701G     0%    /var/audit
zroot/usr/src       zfs      701G     96K    701G     0%    /usr/src
zroot/var/mail      zfs      701G     96K    701G     0%    /var/mail
zroot/var/tmp       zfs      701G     96K    701G     0%    /var/tmp
```

```
# zfs list
NAME                 USED  AVAIL     REFER  MOUNTPOINT
zroot                729M   701G       96K  none
zroot/ROOT           717M   701G       96K  none
zroot/ROOT/default   717M   701G      717M  /
zroot/tmp           9.59M   701G     9.59M  /tmp
zroot/usr            288K   701G       96K  /usr
zroot/usr/home        96K   701G       96K  /usr/home
zroot/usr/ports       96K   701G       96K  /usr/ports
zroot/usr/src         96K   701G       96K  /usr/src
zroot/var            620K   701G       96K  /var
zroot/var/audit       96K   701G       96K  /var/audit
zroot/var/crash       96K   701G       96K  /var/crash
zroot/var/log        140K   701G      140K  /var/log
zroot/var/mail        96K   701G       96K  /var/mail
zroot/var/tmp         96K   701G       96K  /var/tmp
```

```
# cat /boot/loader.conf
zfs_load="YES"
kern.geom.label.disk_ident_enable="0"
kern.geom.label.gptid.enable="0"
```

```
# cat /etc/rc.conf
zfs_enable="YES"
dumpdev="AUTO"
powerd_enable="YES"
```


NOTE:  The hostname has not been set.

```
# hostname

```

```
# uname -a
FreeBSD  13.0-RELEASE FreeBSD 13.0-RELEASE #0 
  releng/13.0-n244733-ea31abc261f: Fri Apr  9 04:24:09 UTC 2021
  root@releng1.nyi.freebsd.org:/usr/obj/usr/src/amd64.amd64/sys/GENERIC  am
```

```
# sysctl -a | grep -i realtek
dev.ure.0.%desc: Realtek USB 10/100 LAN, class 0/0, rev 3.00/30.00, addr 9
dev.pcm.1.%desc: Realtek ALC257 (Right Analog Mic)
dev.pcm.0.%desc: Realtek ALC257 (Analog 2.0+HP/2.0)
dev.hdaa.0.%desc: Realtek ALC257 Audio Function Group
dev.hdacc.0.%desc: Realtek ALC257 HDA CODEC
```

```
# man -k Ethernet | grep -i adapter | grep -i realtek
re, if_re(4) - RealTek 8139C+/8169/816xS/811xS/8168/810xE/8111 PCI/PCIe Ethernet adapter drive
```

```
# sysctl -a | grep 'dev.ure.0'
dev.ure.0.chipver: 5c30
dev.ure.0.%parent: uhub3
dev.ure.0.%pnpinfo: vendor=0x0bda product=0x8153 devclass=0x00 
  devsubclass=0x00 devproto=0x00 sernum="000001" release=0x3000 mode=host 
  intclass=0xff intsubclass=0xff intprotocol=0x00
dev.ure.0.%location: bus=0 hubaddr=9 port=1 devaddr=10 interface=0 ugen=ugen0.10
dev.ure.0.%driver: ure
dev.ure.0.%desc: Realtek USB 10/100 LAN, class 0/0, rev 3.00/30.00, addr 9
```

```
# service netif stop
```

```
# printf %s\\n "nameserver 192.168.1.254" > ure0_resolv.conf
```

```
# cat ure0_resolv.conf
nameserver 192.168.1.254
```

```
# cat /etc/resolv.conf
cat: /etc/resolv.conf: No such file or directory
```

```
# resolvconf -I
# resolvconf -a ure0 < ure0_resolv.conf
# resolvconf -u
```

```
# cat /etc/resolv.conf
# Generated by resolvconf
nameserver 192.168.1.254
```


```
# printf %s\\n 'defaultrouter="192.168.1.254"' >> /etc/rc.conf
```

```
# cat /etc/rc.conf
zfs_enable="YES"
dumpdev="AUTO"
powerd_enable="YES"
ifconfig_ue0="DHCP"
defaultrouter="192.168.1.254"
```

```
# netstat -rn
Routing tables

Internet6:
Destination             Gateway     Flags     Netif Expire
::/96                   ::1         UGRS        lo0
::ffff:0.0.0.0/96       ::1         UGRS        lo0
fe80::/10               ::1         UGRS        lo0
ff02::/16               ::1         UGRS        lo0
```

NOTE: 
Not needed: ```route add default 192.168.1.254``` as with the 
following ```netif``` restart, it will pick up the default router 
from ```/etc/rc.conf```. 

```
# service netif restart ue0
```

```
# ping -c2 freebsd.org
PING freebsd.org (96.47.72.84): 56 data bytes
64 bytes from 96.47.72.84: icmp_seq=0 ttl=56 time=74.684 ms
64 bytes from 96.47.72.84: icmp_seq=1 ttl=56 time=75.789 ms

--- freebsd.org ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 74.684/75.237/75.789/0.553 ms
```

```
# cat /etc/resolv.conf
# Generated by resolvconf
nameserver 192.168.1.254
nameserver 75.153.176.9
```

```
# freebsd-version
13.0-RELEASE

# freebsd-version -k
13.0-RELEASE

# freebsd-version -u
13.0-RELEASE

# freebsd-version -r
13.0-RELEASE

# uname -a
FreeBSD  13.0-RELEASE FreeBSD 13.0-RELEASE #0 
  releng/13.0-n244733-ea31abc261f: Fri Apr  9 04:24:09 UTC 2021
  root@releng1.nyi.freebsd.org:/usr/obj/usr/src/amd64.amd64/sys/GENERIC  amd64
```


```
# freebsd-update fetch
```

```
# freebsd-update install
```

```
# pkg
The package management tool is not yet installed on your system.
Do you want to fetch and install it now? [y/N]: y
```

```
# pkg-static upgrade -f pkg
```

```
# pkg upgrade -f
```

```
# freebsd-version
13.0-RELEASE-p5

# freebsd-version -k
13.0-RELEASE-p4

# freebsd-version -u
13.0-RELEASE-p5

# freebsd-version -r
13.0-RELEASE
```


```
# uname -a
FreeBSD  13.0-RELEASE FreeBSD 13.0-RELEASE #0 
  releng/13.0-n244733-ea31abc261f: Fri Apr  9 04:24:09 UTC 2021
  root@releng1.nyi.freebsd.org:/usr/obj/usr/src/amd64.amd64/sys/GENERIC  amd64
```


Correct system time. 

```
# date
Sat Dec 25 21:39:51 PST 2021
```

```
# date 1342
Sat Dec 25 13:42:00 PST 2021
```

```
# date
Sat Dec 25 13:42:02 PST 2021
```


```
# shutdown -r now
```

Add a user and add it to group ```wheel```.  

```
# pw useradd dusko -G wheel -m -s csh
# passwd dusko
```

Create a hostname:

```
# printf %s\\n 'hostname="fbsd1.home.arpa"' >> /etc/rc.conf
```


Install **xorg** metapackage. [⁵](#footnotes) 


```
# pkg info | wc -l
1
```

```
# pkg install xorg  
```

Messages from two packages mentioned two environment variables 
(which I chose not to create): Package freetype2 mentioned the environment 
variable "FREETYPE_PROPERTIES". Package wayland mentioned "XDG_RUNTIME_DIR" 
environment variable.  


**Note:**    
Your X Windows configuration file is typically /etc/X11/XF86Config
if you are using XFree86, and /etc/X11/xorg.conf if you are using X.Org.

In FreeBSD:  ```/usr/local/etc/X11/```.

```
/usr/local/etc/X11/fontpath.d/
/usr/local/etc/X11/xinit/
/usr/local/etc/X11/xorg.conf.d/
```

To make sure that the freetype module is loaded, add the following line 
to the "Modules" section of the X Window System configuration file.

```
# vi /usr/local/etc/X11/xorg.conf.d/modules.conf
```

```
# cat /usr/local/etc/X11/xorg.conf.d/modules.conf
Section "Module"
    Load "freetype"
EndSection
```


For the DejaVu fonts (font family), add the following line to the "Files" 
section of your X Window System configuration file.  


```
# vi /usr/local/etc/X11/xorg.conf.d/fonts.conf
```

```
# cat /usr/local/etc/X11/xorg.conf.d/fonts.conf
Section "Files"
    FontPath "/usr/local/share/fonts/dejavu/"
EndSection
```

```
# vi /usr/local/etc/X11/xorg.conf.d/card.conf 
```

**Note:**  
Did not need to add ```Option "DPMS"``` explicitly to enable 
Display Power Management Signaling extension. 
(DPMS enables the X server to reduce monitor power consumption 
when not in use.)


```
# cat /usr/local/etc/X11/xorg.conf.d/card.conf 
Section "Device"
    Identifier "Card0"
    Driver "modesetting"
EndSection
```

Multi-keyboard layout. 

```
# vi /usr/local/etc/X11/xorg.conf.d/keyboard.conf
```

```
# cat /usr/local/etc/X11/xorg.conf.d/keyboard.conf
Section "InputClass"
    Identifier "All Keyboards"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "us, rs(latinunicode), rs"
    Option "XkbOptions" "ctrl:nocaps,grp:rctrl_toggle"
EndSection
```


```
card.conf     (Did not need to add "DPMS" explicitly)
fonts.conf
module.conf
keyboard.conf
```

Add your regular user to group ```video```.

```
# pw usermod -L video -n dusko
```

Install the metaport of DRM modules for the linuxkpi-based KMS components. 
Installing ```drm-kmod``` installs three packages: drm-fbsd13-kmod, 
drm-kmod, gpu-firmware-kmod.   


```
# pkg install drm-kmod
```

Index the man pages (UNIX manuals), to make keywords available for fast 
retrieval by apropos(1), whatis(1), and man(1)'s -k option.


```
# makewhatis
```


```
# pkg install sudo
```

Use ```visudo(8)``` to edit the sudoers file (/usr/local/etc/sudoers) 


```
# cp -i /usr/local/etc/sudoers /tmp/sudoers.original.bak
```

Allow members of group wheel to execute any command.   

```
# visudo
```

```
# diff --unified=0 /tmp/sudoers.original.bak /usr/local/etc/sudoers
--- /tmp/sudoers.original.bak   2021-12-26 21:11:43.646443000 -0800
+++ /usr/local/etc/sudoers      2021-12-26 21:12:41.517985000 -0800
@@ -90 +90 @@
-# %wheel ALL=(ALL) ALL
+%wheel ALL=(ALL) ALL
```

```
# cp -i /etc/login.conf /tmp/login.conf
```

```
# vi /etc/login.conf
```

```
# diff --unified=0 /tmp/login.conf /etc/login.conf
--- /tmp/login.conf     2021-12-26 21:25:11.745352000 -0800
+++ /etc/login.conf     2021-12-26 21:27:30.345516000 -0800
@@ -332,0 +333,5 @@
+
+video:\
+       :charset=UTF-8:\
+       :lang=en_CA.UTF-8:\
+       :tc=default:
```

```
# cap_mkdb /etc/login.conf
```

```
# shutdown -r now
```

```
% sudo pkg install xlsfonts xfontsel xfd xloadimage xv
```

```
% sudo pkg install vdesk
% sudo pkg install slock dmenu
% sudo pkg install vim-gtk3
```

```
% sudo pkg install tea
```

[TODO]    
Add links to dotfiles.   

Create ```~/.xinitrc``` (xrdb, fonts, beep, xsetroot, xrandr, twm, xclock, xload)    
Create ```~/.twmrc```   
Create ```~/.Xresources``` ->  ```xrdb ~/.Xresources```


```
% sudo pkg install taskwarrior
% sudo pkg install remind
```

```
% sudo pkg install cheat
```

In ~/.cshrc:
  
Modify ```~/.cshrc```

```alias man man -P less -IMFXRJj4```, prompt, 
vi key binding, taskrc, history,   
locale -> LC_ALL, LC_CTYPE, LC_MESSAGES, LC_TIME, LANG   
Add the line ```setenv  TASKRC  /mnt/usbflashdrive/mydotfiles/.taskrc``` 
to ~/.cshrc


```
% printf %s\\n "$CHEAT_CONFIG_PATH"
CHEAT_CONFIG_PATH: Undefined variable.
```

```
% grep CHEAT_CONFIG_PATH ~/.cshrc
setenv CHEAT_CONFIG_PATH /mnt/usbflashdrive/mydotfiles/cheat/conf.yml
```

Add the line ```setenv CHEAT_CONFIG_PATH /mnt/usbflashdrive/mydotfiles/cheat/conf.yml```
to ~/.cshrc

```
% vi ~/.cshrc
```

```
% grep CHEAT_CONFIG_PATH ~/.cshrc
setenv CHEAT_CONFIG_PATH /mnt/usbflashdrive/mydotfiles/cheat/conf.yml
```

```
% source ~/.cshrc
```

```
% printf %s\\n "$CHEAT_CONFIG_PATH"
/mnt/usbflashdrive/mydotfiles/cheat/conf.yml
```

```
% wc -l /mnt/usbflashdrive/mydotfiles/cheat/conf.yml
      69 /mnt/usbflashdrive/mydotfiles/cheat/conf.yml
```

```
% sed '/^[[:space:]]*$/d' \
 /mnt/usbflashdrive/mydotfiles/cheat/conf.yml | grep -v \#
---
editor: vim
colorize: true
style: monokai
formatter: terminal16m
pager: less -FRX
cheatpaths:
  - name: community
    path: /mnt/usbflashdrive/mydotfiles/cheat/cheatsheets/community
    tags: [ community ]
    readonly: true
  - name: personal
    path: /mnt/usbflashdrive/mydotfiles/cheat/cheatsheets/personal
    tags: [ personal ]
    readonly: false
```

Create the ```.taskrc``` file.

```
% wc -l /mnt/usbflashdrive/mydotfiles/.taskrc
      30 /mnt/usbflashdrive/mydotfiles/.taskrc
```

```
% sed '/^[[:space:]]*$/d' \
 /mnt/usbflashdrive/mydotfiles/.taskrc | \
 grep -v \#
data.location=/mnt/usbflashdrive/mydotfiles/.task
```

The related directory, ```.task``` will be created automatically by the 
takswarrior (note: the binary is named ```task```). 

```
% ls -ld /mnt/usbflashdrive/mydotfiles/.task
drwxr-xr-x  3 dusko  dusko  512 Aug  7  2020 /mnt/usbflashdrive/mydotfiles/.task
```

```
% ls -lh /mnt/usbflashdrive/mydotfiles/.task
total 112
-rw-r--r--  1 dusko  dusko    34K Aug  7  2020 backlog.data
-rw-r--r--  1 dusko  dusko    10K Aug  7  2020 completed.data
drwxr-xr-x  2 dusko  dusko   512B Aug  7  2020 hooks
-rw-r--r--  1 dusko  dusko   4.9K Aug  7  2020 pending.data
-rw-r--r--  1 dusko  dusko    49K Aug  7  2020 undo.data
```


Create crontab.

```
% crontab -e
```

```
% crontab -l
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

40 9 * * * env DISPLAY=:0 /mnt/usbflashdrive/scripts/csh/showtasks.sh 2>&1
40 9 * * * env DISPLAY=:0 /mnt/usbflashdrive/scripts/csh/remindgxmsgtcsh.sh 2>&1
```

```
% ls -lh /mnt/usbflashdrive/scripts/csh/remindgxmsgtcsh.sh
-rwxr--r--  1 dusko  dusko   1.2K Oct 27 21:26 /mnt/usbflashdrive/scripts/csh/remindgxmsgtcsh.sh
```

```
% cat /mnt/usbflashdrive/scripts/csh/remindgxmsgtcsh.sh
#!/bin/csh 

remind -c /mnt/usbflashdrive/mydotfiles/.reminders | \
 xmessage -bg black -fg gold -buttons OK:1 -default OK -file -

remind -c+1 /mnt/usbflashdrive/mydotfiles/.reminders | \
 mail -s "weekly reminder" dusko
```

```
% ls -lh /mnt/usbflashdrive/scripts/csh/showtasks.sh
-rwxr--r--  1 dusko  dusko   1.0K Aug  5 10:04 /mnt/usbflashdrive/scripts/csh/showtasks.sh
```


```
% cat /mnt/usbflashdrive/scripts/csh/showtasks.sh
#!/bin/csh

setenv DISPLAY :0
setenv TASKRC /mnt/usbflashdrive/mydotfiles/.taskrc

/usr/local/bin/xterm -fa gallant -fs 14 \
 -geometry 150x38+0+0 -hold \
 -e /bin/csh -c /usr/local/bin/task
```

Modify ```~/.shrc```    
Create ```~/.vimrc```    

```
% cat ~/.vimrc
set noruler
set nohlsearch
set noincsearch
```

```
% sudo pkg install firefox
(some of dependent packages installed:
adwaita-icon-theme, cairo, cups, dbus, ffmpeg, gtk3, harfbuzz,
hicolor-icon-theme, lame, libxkbcommon, pango, wayland-protocols)
```

```
% sudo pkg install chromium
(some of dependent packages installed:
consolekit2, flac, dconf, noto-basic, pulseaudio, xdg-utils)
```

```
% sudo pkg install thunderbird   
(some of dependent packages installed: gtk2)
```

Add an LDAP address book.   
Click Address Book button (inside Mail Toolbar, which is underneath Menu Bar).   
File > New > LDAP Directory... > 'General' tab   

Name:  aNameMeaningfulToYou   
Hostname:  ldap.dept.example.com   
Base DN:  ou=People,dc=dept,dc=example,dc=com    
Port number: 389   
Bind DN:    
[ ]  Use secure connection (SSL)   

Click OK   


```
% sudo pkg install libreoffice en_GB-libreoffice
(some of dependency packages installed:
apr (Apache Portable Runtime project), alsa-lib, boost-libs,  
curl, cyrus-sasl, db5, iso-codes, javavmwrapper, openjdk11, openjpeg,
openldap24-client, poppler, qt5-core, qt5-dbus, qt5-gui,
twemoji-color-font-ttf, vulkan-headers, xcb-util-image,
xcb-util-keysyms, twemoji-color-font-ttf;
fonts: linuxlibertine-g, liberation-fonts-ttf, GentiumBasic,
crosextrafonts-carlito, crosextrafonts-caladea)
```

Add "FontPath" sections for fonts installed by LibreOffice.   

```
% cat /usr/local/etc/X11/xorg.conf.d/fonts.conf
Section "Files"
    FontPath "/usr/local/share/fonts/dejavu/"
EndSection
```

```
% sudo vi /usr/local/etc/X11/xorg.conf.d/fonts.conf
```


```
% cat /usr/local/etc/X11/xorg.conf.d/fonts.conf
Section "Files"
    FontPath "/usr/local/share/fonts/dejavu/"
    FontPath "/usr/local/share/fonts/LinLibertineG/"
    FontPath "/usr/local/share/fonts/Liberation/"
    FontPath "/usr/local/share/fonts/GentiumBasic/"
    FontPath "/usr/local/share/fonts/Carlito/"
    FontPath "/usr/local/share/fonts/Caladea/"
EndSection
```

The OpenJDK implementation installed by libreoffice package 
requires ```fdescfs(5)``` mounted on ```/dev/fd``` 
and ```procfs(5)``` mounted on ```/proc```.  You need to add the 
following two lines in ```/etc/fstab```.

```
% cat /etc/fstab
/dev/gpt/swap0/ none    swap    sw      0       0
/dev/gpt/swap1/ none    swap    sw      0       0
```

``` 
% sudo vi /etc/fstab
```

```
% cat /etc/fstab
/dev/gpt/swap0/ none    swap    sw      0       0
/dev/gpt/swap1/ none    swap    sw      0       0
fdesc           /dev/fd fdescfs rw      0       0
proc            /proc   procfs  rw      0       0
```

```
% sudo pkg install zathura zathura-pdf-poppler zathura-ps
(some of dependency packages installed:
ghostscript9-agpl-base, girara, libnotify, tex-kpathsea, tex-synctex)
```

Message from ghostscript9-agpl-base:

```
This package installs a script named dvipdf that depends on dvips.
If you want to use this script you need to install print/tex-dvipsk.
```

```
% sudo pkg install tex-dvipsk
(some of dependency packages installed:
libgd, libpotrace, mpfr, openjpeg15, psutils,
teckit, tex-dvipsk, tex-ptexenc, tex-web2c, texlive-base,
texlive-texmf, texlive-tlmgr, xpdfopen, zziplib)
```


```
% sudo pkg install tex-xetex 
```


```
% sudo pkg install jmk-x11-fonts
```

```
% cp -i /usr/local/etc/X11/xorg.conf.d/fonts.conf /tmp/
```

```
% sudo vi /usr/local/etc/X11/xorg.conf.d/fonts.conf
```

```
% xlsfonts | grep -i jmk | wc -l
       0

% xlsfonts | grep -i neep | wc -l
       0
```

```
% xset fp+ /usr/local/share/fonts/jmk-x11-fonts/
% xset fp rehash
```

```
% xlsfonts | grep -i jmk | wc -l
     144

% xlsfonts | grep -i neep | wc -l
     136
```


```
% diff \
 --unified=0 \
 /tmp/fonts.conf.bak \
 /usr/local/etc/X11/xorg.conf.d/fonts.conf
--- /tmp/fonts.conf.bak 2022-01-02 15:33:23.417190000 -0800
+++ /usr/local/etc/X11/xorg.conf.d/fonts.conf   2022-01-02 15:49:01.359673000 -0800
@@ -7,0 +8 @@
+    FontPath "/usr/local/share/fonts/jmk-x11-fonts/"
```


```
% cat /usr/local/etc/X11/xorg.conf.d/fonts.conf
Section "Files"
    FontPath "/usr/local/share/fonts/dejavu/"
    FontPath "/usr/local/share/fonts/LinLibertineG/"
    FontPath "/usr/local/share/fonts/Liberation/"
    FontPath "/usr/local/share/fonts/GentiumBasic/"
    FontPath "/usr/local/share/fonts/Carlito/"
    FontPath "/usr/local/share/fonts/Caladea/"
    FontPath "/usr/local/share/fonts/jmk-x11-fonts/"
EndSection
```


```
% sudo pkg install tex-luatex
(also installs the following dependency packages: 
tex-basic-engines, tex-formats, tex-libtexlua, tex-libtexluajit)
```

```
% sudo pkg install symbola courier-prime libertinus firacode
```

```
% mkdir /tmp/toextract

% cd /tmp/toextract

% fetch https://www.fontsquirrel.com/fonts/download/courier-prime-sans
```

```
% ls -lh
total 217
-rw-r--r--  1 dusko  wheel   204K Jan  9 19:51 courier-prime-sans

% file courier-prime-sans
courier-prime-sans: Zip archive data, at least v2.0 to extract
```


```
% mv courier-prime-sans courier-prime-sans.zip
% unzip courier-prime-sans.zip
% rm -i courier-prime-sans.zip

% cd ..

% pwd
/tmp

% mv toextract courierprimesans

% sudo mv /tmp/courierprimesans /usr/local/share/fonts/
% sudo chown -R root /usr/local/share/fonts/courierprimesans/
```

```
% fc-list | grep -i courier | grep -i prime | grep -i sans
/usr/local/share/fonts/courierprimesans/Courier Prime Sans Italic.ttf: Courier Prime Sans:style=Italic
/usr/local/share/fonts/courierprimesans/Courier Prime Sans Bold Italic.ttf: Courier Prime Sans:style=Bold Italic
/usr/local/share/fonts/courierprimesans/Courier Prime Sans Bold.ttf: Courier Prime Sans:style=Bold
/usr/local/share/fonts/courierprimesans/Courier Prime Sans.ttf: Courier Prime Sans:style=Regular 
```

```
% cd /usr/local/share/fonts/courierprimesans/

% sudo mkfontdir
% sudo mkfontscale

% cd
```

```
% xset fp+ /usr/local/share/fonts/symbola/
% xset fp+ /usr/local/share/fonts/courier-prime/
% xset fp+ /usr/local/share/fonts/libertinus/
% xset fp+ /usr/local/share/fonts/firacode/
% xset fp+ /usr/local/share/fonts/courierprimesans/
```

```
% xset fp rehash
```

```
% cp -i /usr/local/etc/X11/xorg.conf.d/fonts.conf /tmp/
```

```
% sudo vi /usr/local/etc/X11/xorg.conf.d/fonts.conf 
```

```
% diff \
 --unified=0 \
 /tmp/fonts.conf \
 /usr/local/etc/X11/xorg.conf.d/fonts.conf
--- /tmp/fonts.conf     2022-01-09 20:33:45.476371000 -0800
+++ /usr/local/etc/X11/xorg.conf.d/fonts.conf   2022-01-09 20:32:32.612990000 -0800
@@ -8,0 +9,5 @@
+    FontPath "/usr/local/share/fonts/symbola/"
+    FontPath "/usr/local/share/fonts/courier-prime/"
+    FontPath "/usr/local/share/fonts/libertinus/"
+    FontPath "/usr/local/share/fonts/firacode/"
+    FontPath "/usr/local/share/fonts/courierprimesans/"
```


Install Mutt, a text based MUA (Mail User Agent). 

 
```
% sudo pkg install mutt
(some of dependency packages installed:
 gnupg, gpgme, mime-support, pinentry, urlview)
```

Create the ```muttrc``` configuration file.  
As I keep my ```muttrc``` in a non-home directory, I start ```mutt``` 
with the ```-F``` option:    

```
% mutt -F /path/to/my/muttrc
```

Install ```aspell-ispell```, Ispell compatibility script for aspell.

```
% sudo pkg install aspell-ispell
```

Install Aspell English dictionaries.

```
% sudo pkg install en-aspell
```

----


```
% sudo pkg install beadm
```

```
% sudo pkg install keepassxc openconnect rsync
```

```
% sudo pkg install graphviz
```


Install the netpbm suite, a toolkit for conversion of images between different formats.


```
% sudo pkg install netpbm
```

In the X Window System, the program xwd (X Window dump) captures the 
content of a screen or of a window (a.k.a. takes a screenshot). 
The file generated by xwd can then be read by various other X utilities 
such as xwud or xv. 

To take a screenshot (a.k.a. screen capture) and convert it to png format:

```
$ xwd | xwdtopnm | pnmtopng > screenshot.png
```

**Note:**    
If you get this error:

```
% xwd | xwdtopnm | pnmtopng > screenshot.png
xwdtopnm: can't handle X11 pixmap_depth > 24
pnmtopng: Error reading first byte of what is expected to be a Netpbm 
magic number.  Most often, this means your input file is empty
```

a) try a different program (for example, instead of taking a screenshot 
of firefox browser, try taking a screenshot of chromium browser)   
b) exit X session, and start it with a different colur depth, for example:

```
% exec startx -- -depth 16
```


Install wireshark.

```
% sudo pkg install wireshark  
```

In order for wireshark be able to capture packets when used by unprivileged
user, /dev/bpf should be in network group and have read-write permissions:

```
% sudo chgrp network /dev/bpf*
% sudo chmod g+r /dev/bpf*
% sudo chmod g+w /dev/bpf*
```


In order for this to persist across reboots, add the following to
/etc/devfs.conf:

```
own  bpf* root:network
perm bpf* 0660
```

```
% sudo cp -i /etc/devfs.conf /etc/devfs.conf.original.bak
```


Install dia, diagram creation program.

```
% sudo pkg install dia 
```


```
% printf %s\\n | sudo tee -a /etc/devfs.conf

% printf %s\\n 'In order for wireshark be able to capture packets when used by' \
 | sudo tee -a /etc/devfs.conf

% printf %s\\n 'unprivileged user, /dev/bpf should be in network group and have' \
 | sudo tee -a /etc/devfs.conf

% printf %s\\n 'read-write permissions.' | sudo tee -a /etc/devfs.conf

% printf %s\\n 'own  bpf* root:network' | sudo tee -a /etc/devfs.conf

% printf %s\\n 'perm bpf* 0660' | sudo tee -a /etc/devfs.conf
```


Create a Trash directory. 

```
% mkdir ~/trash
```

Install git.

```
% sudo pkg install git
```

```
% git config --global user.name "duskopijetlovic"
% git config --global user.email "username@yourdomain.com"
```

Clone a git repository that you would like to update.  

```
% git \
 clone \
 https://github.com/duskopijetlovic/duskopijetlovic.github.io.git \
 duskopijetlovic.github.io
```

```
% sudo pkg install ruby
```

```
% sudo pkg install ruby27-gems
% sudo pkg install rubygem-irb rubygem-rake rubygem-bundler rubygem-jekyll
```

```
% cd duskopijetlovic.github.io/
% bundle exec jekyll serve
```


Configure ```cpan(1)``` module [⁶](#footnotes) so that it can be used by 
non-root users for installing Perl modules.

```
% cpan -l
```

In "What approach do you want?  (Choose 'local::lib', 'sudo' or 'manual')", 
enter ```sudo```.

```
Loading internal logger. Log::Log4perl recommended for better logging

CPAN.pm requires configuration, but most of it can be done automatically.
If you answer 'no' below, you will enter an interactive dialog for each
configuration option instead.

Would you like to configure as much as possible automatically? [yes] yes

Warning: You do not have write permission for Perl library directories.

To install modules, you need to configure a local Perl library directory or
escalate your privileges.  CPAN can help you by bootstrapping the local::lib
module or by configuring itself to use 'sudo' (if available).  You may also
resolve this problem manually if you need to customize your setup.

What approach do you want?  (Choose 'local::lib', 'sudo' or 'manual')
 [local::lib] sudo

---- snip ----
```

Configuration is written to: 

```
~/.cpan/CPAN/MyConfig.pm
```

----

[TODO]    
Try dual boot without rEFInd; that is, try it with only UEFI's boot loader:   
[Dual-booting Windows 10 alongside FreeBSD 11.0-RELEASE - FreeBSD Forum](https://forums.freebsd.org/threads/dual-booting-windows-10-alongside-freebsd-11-0-release.59427/#post-341619)

> Adding yet another boot loader to the chain is (probably) unnecessary 
> if you're using UEFI.  Most motherboard firmwares already provide 
> a menu for selecting between EFI boot entries.  The only thing that 
> may not be obvious is how to add an entry for FreeBSD to this menu so 
> that it lives alongside Windows Boot Manager.  Now, if you don't have 
> a fancy boot menu you can access with the press of a key at startup 
> then you're going to have to look into using something like GRUB 
> or rEFInd.  You might consider using such an option even if you do 
> have a working boot menu provided by your firmware.

----

#### Footnotes

 
[¹] [How can I create Recovery Media (DVD or USB), or order Recovery Media (DVD or USB) from Lenovo](https://support.lenovo.com/ca/en/solutions/ht035659)   

(Retrieved on Dec 12, 2021)   

> Recovery Media is DVD or USB media containing a backup of the original 
> factory condition of a computer as configured by Lenovo, or a PC 
> system user.  Recovery Media allows you to reformat the hard drive, 
> reinstall the operating system and reset the system to the original 
> Lenovo factory condition.
> 
> Note:  Before you start the recovery process, back up all the data 
> that you want to keep.  During the recovery, all files on your hard 
> disk drive (HDD), and all system settings will be deleted.

----

[²] For more details about FreeBSD boot process, see:   

[13.2. FreeBSD Boot Process - FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/boot/#boot-introduction)

[2.4. Starting the Installation - FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/bsdinstall/#bsdinstall-start)

(Retrieved on Dec 12, 2021)   

> 2.4.1. Booting on i386(TM) and amd64
> 
> These architectures provide a BIOS menu for selecting the boot device. 
> Depending upon the installation media being used, select the CD/DVD or 
> USB device as the first boot device.  Most systems also provide a key 
> for selecting the boot device during startup without having to enter 
> the BIOS.  Typically, the key is either F10, F11, F12, or Escape.
> 
> If the computer loads the existing operating system instead of the 
> FreeBSD installer, then either:
> 
> * The installation media was not inserted early enough in the boot 
> process.  Leave the media inserted and try restarting the computer.
> * The BIOS changes were incorrect or not saved.  Double-check that 
> the right boot device is selected as the first boot device.
> * This system is too old to support booting from the chosen media. 
> In this case, 
> the Plop Boot Manager (<http://www.plop.at/en/bootmanagers.html>) 
> can be used to boot the system from the selected media.


[³]  Disk Labeling     
(From "Absolute FreeBSD, 3rd Edition: The Complete Guide to FreeBSD"   
By Michael W. Lucas):     
* **Disk ID Labels**: a physical machine offers labels not available 
  on virtual machines. 
  - Viewing Labels   
  To view labels, use ```glabel(8)```, a shortcut for ```geom label```.  

  ```
  % glabel list
  Geom name: nvd0p1
  Geom name: nvd0p1
  Providers:
  1. Name: . . . 
  ---- snip ----
  Consumers:
  1. Name: nvd0p1
  ---- snip ----
  ---- snip ----

  Geom name: nvd0
  Providers:
     Name: diskid/DISK-20232D8612345
     Mediasize: 1024209543168 (954G)
     Sectorsize: 512
     Mode: r0w0e0
     secoffset: 0
     offset: 0
     seclength: 2000409264
     length: 1024209543168
     index: 0
  Consumers:
  1. Name: nvd0
     Mediasize: 1024209543168 (954G)
     Sectorsize: 512
     Mode: r0w0e0
  ```

  Names of ```Disk ID Label``` geoms are in the format 
  of ```diskid/DISK-<hard_drive_serial_number```.  For example:
  ```
  % ls -lh /dev/diskid/
  total 0
  crw-r-----  1 root  operator   0xa7 Dec 31 12:42 DISK-20232D8612345
  ```
  
  In this case, this partition would be labelled 
  as ```diskid/DISK-20232D8612345```. 

  Disk ID labels are hard to read and write.  To eliminate them, 
  set the tunable ```kern.geom.label.disk_ident.enable``` to 0 
  in ```/boot/loader.conf```.


* **GPT GUID (GPT ID) Labels**: every GPT partition includes a GUID.    
  FreeBSD can treat the GUID as a label.  Using a GPT ID label makes 
  sense when you have many automatically configured disks, such as 
  large storage arrays.  On smaller systems, the 128-bit GUID is not 
  practical because of its length.   To disable these labels, set the 
  tunable ```kern.geom.label.gptid.enable``` to 0 
  in ```/boot/loader.conf```.  


* **GPT Labels**: GPT partitions let you *manually* assign a label name 
  within the partition table.  These labels are physically stored on the 
  disk partition. -- It's **recommended** to use GPT labels whenever possible.   


* **GEOM Labels**: The ```glabel(8)``` command lets you configure 
   GEOM labels.   A GEOM label is specific to FreeBSD's GEOM 
   infrastructure and appears in ```/dev/label```.   

----

[⁴]  Boot from [NomadBSD](https://www.nomadbsd.org/).    

Download rEFInd.  

```
% fetch https://iweb.dl.sourceforge.net/project/refind/0.13.2/refind-bin-0.13.2.zip 
```

Copy the **rEFInd** .zip file to an external USB flash drive. 

Reboot.  

```
% sudo shutdown -r now
```

Return to the machine on which you are installing FreeBSD.

Before mounting the USB flash drive with the **rEFInd**, you have to 
mount the device file system (```devfs```):  

```
# mount -t devfs devfs /dev
```

Now you can mount the USB flash disk as usual.  


[⁵]  Packages installed as dependencies of the **xorg** metapackage:  
> **twm** - Tab Window Manager for the X Window System   
> 
> *Programming languages, compilers, header files, APIs*:   
> llvm12, glib, lua53, perl5, python38, py38-evdev, py38-pyudev, 
> py38-setuptools, py38-six, pcre, fontconfig, evdev-proto  
> 
> *Utilities, tools, applications*:   
> pciids, xbitmaps, xcmsdb, xkeyboard-config, gettext-runtime, encodings, 
> indexinfo, expat  
> 
> *xorg-apps (X.org apps metapackage)*, consists of the following packages:  
> appres, bitmap, iceauth, mkfontscale, sessreg, setxkbmap, smproxy, 
> x11perf, xauth, xbacklight, xcalc, xclock, xconsole, xcursor-themes, 
> xcursorgen, xdpyinfo, xdriinfo, xev, xf86dga, xgamma, xgc, xhost, xinit, 
> xinput, xkbcomp, xkbevd, xkbutils, xkill, xlsatoms, xlsclients, 
> xmessage, xmodmap, xpr, xprop, xrandr, xrdb, xrefresh, xset, xsetroot, 
> xterm, xvinfo, xwd, xwininfo, xwud  
> 
> *Drivers*:  
> mesa-dri, mesa-libs, 
> *xorg-drivers (X.org drivers metapackage)*, consists of the following packages:   
> xf86-input-keyboard, xf86-input-libinput, xf86-input-mouse, 
> xf86-video-scfb, xf86-video-vesa  
> 
> *Fonts*:   
> font-adobe-100dpi, font-adobe-75dpi, font-adobe-utopia-100dpi, 
> font-adobe-utopia-75dpi, font-adobe-utopia-type1, font-alias, 
> font-arabic-misc, font-bh-100dpi, font-bh-75dpi, 
> font-bh-lucidatypewriter-100dpi, font-bh-lucidatypewriter-75dpi, 
> font-bh-ttf, font-bh-type1, font-bitstream-100dpi, font-bitstream-75dpi, 
> font-bitstream-type1, font-cronyx-cyrillic, font-cursor-misc, 
> font-daewoo-misc, font-dec-misc, font-ibm-type1, font-isas-misc, 
> font-jis-misc, font-micro-misc, font-misc-cyrillic, font-misc-ethiopic, 
> font-misc-meltho, font-misc-misc, font-mutt-misc, font-schumacher-misc, 
> font-screen-cyrillic, font-sony-misc, font-sun-misc, 
> font-winitzki-cyrillic, font-xfree86-type1, xorg-fonts, 
> xorg-fonts-100dpi, xorg-fonts-75dpi, xorg-fonts-cyrillic, 
> xorg-fonts-miscbitmaps, xorg-fonts-truetype, xorg-fonts-type1, dejavu  
> 
> *Libraries*:  
> libFS, libICE, libSM, libX11, libXScrnSaver, libXau, libXaw, 
> libXcomposite, libXcursor, libXdamage, libXdmcp, libXext, libXfixes, 
> libXfont, libXfont2, libXft, libXi, libXinerama, libXmu, libXpm, 
> libXrandr, libXrender, libXres, libXt, libXtst, libXv, libXvMC, 
> libXxf86dga, libXxf86vm, libdmx, libdrm, libedit, libepoll-shim, 
> libepoxy, libevdev, libffi, libfontenc, libglvnd, libgudev, libiconv, 
> libinput, liblz4, libmtdev, libpciaccess, libpthread-stubs, libudev-devd, 
> libunwind, libwacom, libxcb, libxkbfile, libxml2, libxshmfence, pixman, 
> png, readline, xcb-util, xcb-util-wm, xtrans, xorg-libraries, freetype2, 
> mpdecimal   
> 
> xorg-docs, xorg-server, xorgproto, wayland, zstd    


[⁶]  What is CPAN?   
The CPAN Frequently Asked Questions - www.cpan.org  
(Retrieved on Jan 1, 2022):   
> CPAN is the Comprehensive Perl Archive Network, a large collection of 
> Perl software and documentation. You can begin exploring from either 
> http://www.cpan.org/ or any of the mirrors listed at 
> http://www.cpan.org/SITES.html.
> 
> CPAN is also the name of a Perl module, CPAN.pm, which is used to 
> download and install Perl software from the CPAN archive.  This FAQ 
> covers only a little about the CPAN module and you may find the 
> documentation for it by using perldoc CPAN via the command line or on 
> the web at https://metacpan.org/pod/CPAN. 


#### References

[Once something opens one of da or gpt/name, the other goes away](https://twitter.com/allanjude/status/1058770910176575488) 

[Adjusting the drive locations](https://gist.github.com/dlangille/be9bea06795fe60579a648863a75f659)

