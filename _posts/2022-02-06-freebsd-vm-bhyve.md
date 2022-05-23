---
layout: post
title: "Setup vm-bhyve and Install a GNU/Linux Debian VM on FreeBSD 13"
date: 2022-02-06 07:02:01 -0700 
categories: freebsd bhyve virtualization
---

Operating system:  FreeBSD 13.0 

**Note:**   
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.

```
% zfs list
NAME                 USED  AVAIL     REFER  MOUNTPOINT
zroot               27.9G   674G       96K  none
zroot/ROOT          5.20G   674G       96K  none
zroot/ROOT/default  5.20G   674G     5.20G  /
zroot/tmp            833M   674G      833M  /tmp
zroot/usr           21.8G   674G       96K  /usr
zroot/usr/home      21.8G   674G     21.8G  /usr/home
zroot/usr/ports       96K   674G       96K  /usr/ports
zroot/usr/src         96K   674G       96K  /usr/src
zroot/var           1.18M   674G       96K  /var
zroot/var/audit       96K   674G       96K  /var/audit
zroot/var/crash       96K   674G       96K  /var/crash
zroot/var/log        548K   674G      548K  /var/log
zroot/var/mail       216K   674G      216K  /var/mail
zroot/var/tmp        152K   674G      152K  /var/tmp
```

```
% zpool list
NAME   SIZE  ALLOC  FREE  CKPOINT  EXPANDSZ  FRAG  CAP  DEDUP  HEALTH  ALTROOT
zroot  724G  27.9G  696G        -         -    2%   3%  1.00x  ONLINE  -
```

```
% command -v bhyve
/usr/sbin/bhyve

% command -v bhyvectl
/usr/sbin/bhyvectl

% command -v bhyveload
/usr/sbin/bhyveload
```

```
% file /usr/sbin/bhyve
/usr/sbin/bhyve: ELF 64-bit LSB executable, x86-64, version 1 (FreeBSD), 
  dynamically linked, interpreter /libexec/ld-elf.so.1, 
  for FreeBSD 13.0 (1300139), FreeBSD-style, stripped

% file /usr/sbin/bhyvectl
/usr/sbin/bhyvectl: ELF 64-bit LSB executable, x86-64, version 1 (FreeBSD), 
  dynamically linked, interpreter /libexec/ld-elf.so.1, 
  for FreeBSD 13.0 (1300139), FreeBSD-style, stripped

% file /usr/sbin/bhyveload
/usr/sbin/bhyveload: ELF 64-bit LSB executable, x86-64, version 1 (FreeBSD), 
  dynamically linked, interpreter /libexec/ld-elf.so.1, 
  for FreeBSD 13.0 (1300139), FreeBSD-style, stripped
```


bhyve, bhyvectl and bhyveload binaries are part of FreeBSD 13 base system.


```
% pkg which /usr/sbin/bhyve
/usr/sbin/bhyve was not found in the database

% pkg which /usr/sbin/bhyvectl
/usr/sbin/bhyvectl was not found in the database

% pkg which /usr/sbin/bhyveload
/usr/sbin/bhyveload was not found in the database
```


```
% ls -lh /usr/share/examples/bhyve/
total 9
-r--r--r--  1 root  wheel   9.6K Apr  8  2021 vmrun.sh

% file /usr/share/examples/bhyve/vmrun.sh
/usr/share/examples/bhyve/vmrun.sh: POSIX shell script, ASCII text executable

% wc -l /usr/share/examples/bhyve/vmrun.sh
     395 /usr/share/examples/bhyve/vmrun.sh
```


```
% pkg search bhyve
bhyve+-0.1.0                   BHyVe with unofficial extensions
bhyve-firmware-1.0_1           Collection of Firmware for bhyve
bhyve-rc-3                     FreeBSD RC script for starting bhyve guests in tmux
grub2-bhyve-0.40_8             Grub-emu loader for bhyve
rubygem-vagrant-bhyve-0.1.0    Vagrant provider plugin to support bhyve
uefi-edk2-bhyve-g20210226,2    UEFI EDK2 firmware for bhyve
uefi-edk2-bhyve-csm-0.2_3,1    UEFI EDK2 firmware for bhyve with CSM (16-bit BIOS)
vm-bhyve-1.4.2                 Management system for bhyve virtual machines
```


Based on 
[churchers/vm-bhyve.](https://github.com/churchers/vm-bhyve)(Retrieved on Feb 6, 2022). 


Install vm-bhyve.

```
% sudo pkg install vm-bhyve
---- snip ----

=====
Message from vm-bhyve-1.4.2:

--
To enable vm-bhyve, please add the following lines to rc.conf,
depending on whether you are using ZFS storage or not. Please note
that the directory or dataset specified should already exist.

    vm_enable="YES"
    vm_dir="zfs:pool/dataset"

OR

    vm_enable="YES"
    vm_dir="/directory/path"

Then run 'vm init'.
```


```
% ls -lh /usr/local/share/examples/vm-bhyve/
total 85
-rw-r--r--  1 root  wheel   437B Jan 14  2020 alpine.conf
-rw-r--r--  1 root  wheel   280B Jan 14  2020 arch.conf
-rw-r--r--  1 root  wheel   354B Jan 14  2020 centos6.conf
-rw-r--r--  1 root  wheel   163B Jan 14  2020 centos7.conf
-rw-r--r--  1 root  wheel    16K Jan 14  2020 config.sample
-rw-r--r--  1 root  wheel   331B Jan 14  2020 coreos.conf
-rw-r--r--  1 root  wheel   177B Jan 14  2020 debian.conf
-rw-r--r--  1 root  wheel   136B Jan 14  2020 default.conf
-rw-r--r--  1 root  wheel   441B Jan 14  2020 dragonfly.conf
-rw-r--r--  1 root  wheel   156B Jan 14  2020 freebsd-zvol.conf
-rw-r--r--  1 root  wheel   755B Jan 14  2020 freepbx.conf
-rw-r--r--  1 root  wheel   151B Jan 14  2020 linux-zvol.conf
-rw-r--r--  1 root  wheel   213B Jan 14  2020 netbsd.conf
-rw-r--r--  1 root  wheel   243B Jan 14  2020 openbsd.conf
-rw-r--r--  1 root  wheel   222B Jan 14  2020 resflash.conf
-rw-r--r--  1 root  wheel   131B Jan 14  2020 ubuntu.conf
-rw-r--r--  1 root  wheel   566B Jan 14  2020 windows.conf
```

```
% sudo zfs create zroot/vm
```


```
% zfs list | tail -1
zroot/vm              96K   674G       96K  none
```


```
% ls -ld /vm
ls: /vm: No such file or directory
```


```
% zfs get all zroot/vm | wc -l
      73

% zfs get all zroot/vm | grep compression
zroot/vm  compression      lz4             inherited from zroot

% zfs get all zroot/vm | grep -w atime
zroot/vm  atime            off             inherited from zroot

% zfs get all zroot/vm | grep mountpoint
zroot/vm  mountpoint       none            inherited from zroot
```


```
% sudo zfs set mountpoint=/vm zroot/vm
```

```
% zfs get all zroot/vm | grep mountpoint
zroot/vm  mountpoint       /vm             local
```


```
% ls -ld /vm
drwxr-xr-x  2 root  wheel  2 Jan 29 19:30 /vm
```

```
% date
Sat 29 Jan 2022 19:38:49 PST

% file /vm
/vm: directory
```


```
% zfs get all zroot/vm
NAME      PROPERTY       VALUE                  SOURCE
zroot/vm  type           filesystem             -
zroot/vm  creation       Sat Jan 29 19:30 2022  -
zroot/vm  used           96K                    -
zroot/vm  available      674G                   -

---- snip ----
```


```
% zfs mount
zroot/ROOT/default              /
zroot/tmp                       /tmp
zroot/usr/ports                 /usr/ports
zroot/usr/home                  /usr/home
zroot/var/crash                 /var/crash
zroot/var/mail                  /var/mail
zroot/var/tmp                   /var/tmp
zroot/var/audit                 /var/audit
zroot/usr/src                   /usr/src
zroot/var/log                   /var/log
zroot/vm                        /vm
```

```
% sudo cp -i /etc/rc.conf /etc/rc.conf.original.bak
```

```
% printf %s\\n 'vm_enable="YES"' | sudo tee -a /etc/rc.conf
% printf %s\\n 'vm_dir="zfs:zroot/vm"' | sudo tee -a /etc/rc.conf
```

```
% diff \
 --unified=0 \
 /etc/rc.conf.original.bak \
 /etc/rc.conf
--- /etc/rc.conf.original.bak   2022-01-29 19:17:50.236339000 -0800
+++ /etc/rc.conf        2022-01-29 20:24:22.277037000 -0800
@@ -7,0 +8,2 @@
+vm_enable="YES"
+vm_dir="zfs:zroot/vm"
```

```
% type vm
vm is /usr/local/sbin/vm
```

```
% file /usr/local/sbin/vm
/usr/local/sbin/vm: POSIX shell script, ASCII text executable

% wc -l /usr/local/sbin/vm
      51 /usr/local/sbin/vm
```


```
% ls -lh /usr/local/lib/vm-bhyve
total 133
-rw-r--r--  1 root  wheel   2.4K Jan 14  2020 vm-base
-rw-r--r--  1 root  wheel   7.7K Jan 14  2020 vm-cmd
-rw-r--r--  1 root  wheel   5.9K Jan 14  2020 vm-config
-rw-r--r--  1 root  wheel    32K Jan 14  2020 vm-core
-rw-r--r--  1 root  wheel    14K Jan 14  2020 vm-datastore
-rw-r--r--  1 root  wheel   7.3K Jan 14  2020 vm-guest
-rw-r--r--  1 root  wheel    14K Jan 14  2020 vm-info
-rw-r--r--  1 root  wheel    10K Jan 14  2020 vm-migration
-rw-r--r--  1 root  wheel   3.4K Jan 14  2020 vm-rctl
-rw-r--r--  1 root  wheel    33K Jan 14  2020 vm-run
-rw-r--r--  1 root  wheel    13K Jan 14  2020 vm-switch
-rw-r--r--  1 root  wheel   4.6K Jan 14  2020 vm-switch-manual
-rw-r--r--  1 root  wheel    11K Jan 14  2020 vm-switch-standard
-rw-r--r--  1 root  wheel   3.4K Jan 14  2020 vm-switch-vale
-rw-r--r--  1 root  wheel   6.3K Jan 14  2020 vm-switch-vxlan
-rw-r--r--  1 root  wheel    11K Jan 14  2020 vm-util
-rw-r--r--  1 root  wheel    18K Jan 14  2020 vm-zfs
```


```
% ls -alh /vm
total 9
drwxr-xr-x   2 root  wheel     2B Jan 29 19:30 .
drwxr-xr-x  19 root  wheel    25B Jan 29 19:38 ..
```

```
% kldstat | grep vmm
% kldstat | grep nmdm
```

Virtual machines can only be managed by root.

```
% sudo vm init
```


```
% ls -alh /vm
total 11
drwxr-xr-x   6 root  wheel     6B Jan 29 20:27 .
drwxr-xr-x  19 root  wheel    25B Jan 29 19:38 ..
drwxr-xr-x   2 root  wheel     4B Jan 29 20:27 .config
drwxr-xr-x   2 root  wheel     2B Jan 29 20:27 .img
drwxr-xr-x   2 root  wheel     2B Jan 29 20:27 .iso
drwxr-xr-x   2 root  wheel     3B Jan 29 20:27 .templates
```

```
% kldstat | grep vm
25    1 0xffffffff83000000   53a420 vmm.ko

% kldstat | grep nmdm
26    1 0xffffffff82e49000     21cc nmdm.ko
```


```
% kldstat | tail -4
25    1 0xffffffff83000000   53a420 vmm.ko
26    1 0xffffffff82e49000     21cc nmdm.ko
27    1 0xffffffff82e4c000     7638 if_bridge.ko
28    1 0xffffffff82e54000     50d8 bridgestp.ko
```


```
% service vm status
vm is not running.
```

```
% sudo vm list
Password:
NAME  DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
```

```
% sudo vm info
```

```
% sudo vm datastore list
NAME            TYPE        PATH                      ZFS DATASET
default         zfs         /vm                       zroot/vm
```


```
% sudo vm switch info
```


For Linux guests, install grub2-bhyve.


```
% sudo pkg install grub2-bhyve
```


For UEFI support, install bhyve-firmware.

```
% sudo pkg install bhyve-firmware
```


```
% ls -alh /vm/
total 11
drwxr-xr-x   6 root  wheel     6B Jan 29 20:27 .
drwxr-xr-x  19 root  wheel    25B Jan 29 21:58 ..
drwxr-xr-x   2 root  wheel     4B Jan 29 20:27 .config
drwxr-xr-x   2 root  wheel     2B Jan 29 20:27 .img
drwxr-xr-x   2 root  wheel     2B Jan 29 20:27 .iso
drwxr-xr-x   2 root  wheel     3B Jan 29 20:27 .templates
```

```
% ls -alh /vm/.templates/
total 6
drwxr-xr-x  2 root  wheel     3B Jan 29 20:27 .
drwxr-xr-x  6 root  wheel     6B Jan 29 20:27 ..
-rw-r--r--  1 root  wheel   136B Jan 29 20:27 default.conf
```


```
% cat /usr/local/share/examples/vm-bhyve/default.conf
loader="bhyveload"
cpu=1
memory=256M
network0_type="virtio-net"
network0_switch="public"
disk0_type="virtio-blk"
disk0_name="disk0.img"
```


```
% cat /vm/.templates/default.conf
loader="bhyveload"
cpu=1
memory=256M
network0_type="virtio-net"
network0_switch="public"
disk0_type="virtio-blk"
disk0_name="disk0.img"
```


```
% sudo cp -i /usr/local/share/examples/vm-bhyve/* /vm/.templates/
overwrite /vm/.templates/default.conf? (y/n [n]) y
```

```
% ls -alh /vm/.templates/
total 94
drwxr-xr-x  2 root  wheel    19B Jan 29 22:31 .
drwxr-xr-x  6 root  wheel     6B Jan 29 20:27 ..
-rw-r--r--  1 root  wheel   437B Jan 29 22:31 alpine.conf
-rw-r--r--  1 root  wheel   280B Jan 29 22:31 arch.conf
-rw-r--r--  1 root  wheel   354B Jan 29 22:31 centos6.conf
-rw-r--r--  1 root  wheel   163B Jan 29 22:31 centos7.conf
-rw-r--r--  1 root  wheel    16K Jan 29 22:31 config.sample
-rw-r--r--  1 root  wheel   331B Jan 29 22:31 coreos.conf
-rw-r--r--  1 root  wheel   177B Jan 29 22:31 debian.conf
-rw-r--r--  1 root  wheel   136B Jan 29 22:31 default.conf
-rw-r--r--  1 root  wheel   441B Jan 29 22:31 dragonfly.conf
-rw-r--r--  1 root  wheel   156B Jan 29 22:31 freebsd-zvol.conf
-rw-r--r--  1 root  wheel   755B Jan 29 22:31 freepbx.conf
-rw-r--r--  1 root  wheel   151B Jan 29 22:31 linux-zvol.conf
-rw-r--r--  1 root  wheel   213B Jan 29 22:31 netbsd.conf
-rw-r--r--  1 root  wheel   243B Jan 29 22:31 openbsd.conf
-rw-r--r--  1 root  wheel   222B Jan 29 22:31 resflash.conf
-rw-r--r--  1 root  wheel   131B Jan 29 22:31 ubuntu.conf
-rw-r--r--  1 root  wheel   566B Jan 29 22:31 windows.conf
```

```
% ifconfig
em0: flags=8822<BROADCAST,SIMPLEX,MULTICAST> metric 0 mtu 1500
        options=481249b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,VLAN_HWCSUM,
          LRO,WOL_MAGIC,VLAN_HWFILTER,NOMAP>
---- snip ----
        media: Ethernet autoselect
        status: no carrier
        nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
        options=680003<RXCSUM,TXCSUM,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x2
        inet 127.0.0.1 netmask 0xff000000
        groups: lo
        nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
ue0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
        options=68009b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,VLAN_HWCSUM,
          LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
---- snip ----
        inet 192.168.1.65 netmask 0xffffff00 broadcast 192.168.1.255
        media: Ethernet autoselect (1000baseT <full-duplex>)
        status: active
        nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
```


```
% sudo vm switch list
NAME  TYPE  IFACE  ADDRESS  PRIVATE  MTU  VLAN  PORTS
```

```
% sudo vm switch create -a 192.168.8.1/24 public
```


```
% sudo vm switch list
Password:
NAME    TYPE      IFACE      ADDRESS         PRIVATE  MTU  VLAN  PORTS
public  standard  vm-public  192.168.8.1/24  no       -    -     -
```

```
% sudo vm switch info
------------------------
Virtual Switch: public
------------------------
  type: standard
  ident: vm-public
  vlan: -
  physical-ports: -
  bytes-in: 37302 (36.427K)
  bytes-out: 5550 (5.419K)
```

NOTE:  Some instructions include running
```sudo vm switch add public ue0``` at this point but when I did it, 
the guest VM wasn't able to obtain an IP address from dnsmasq
(although it obtained an IP address from the same DHCP server that the 
FreeBSD host obtaines it from). 


```
% ifconfig
em0: flags=8822<BROADCAST,SIMPLEX,MULTICAST> metric 0 mtu 1500
        options=481249b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,
          VLAN_HWCSUM,LRO,WOL_MAGIC,VLAN_HWFILTER,NOMAP>
---- snip ----  
        media: Ethernet autoselect
        status: no carrier
        nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
        options=680003<RXCSUM,TXCSUM,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x2
        inet 127.0.0.1 netmask 0xff000000
        groups: lo
        nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
ue0: flags=8943<UP,BROADCAST,RUNNING,PROMISC,SIMPLEX,MULTICAST> metric 0 mtu 1500
        options=68009b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,
          VLAN_HWCSUM,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
---- snip ---- 
        inet 192.168.1.65 netmask 0xffffff00 broadcast 192.168.1.255
        media: Ethernet autoselect (1000baseT <full-duplex>)
        status: active
        nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
vm-public: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
        ether 1e:77:56:53:11:0f
        inet 192.168.8.1 netmask 0xffffff00 broadcast 192.168.8.255
        id 00:00:00:00:00:00 priority 32768 hellotime 2 fwddelay 15
        maxage 20 holdcnt 6 proto rstp maxaddr 2000 timeout 1200
        root id 00:00:00:00:00:00 priority 32768 ifcost 0 port 0
        groups: bridge vm-switch viid-4c918@
        nd6 options=9<PERFORMNUD,IFDISABLED>
```


### Internal NAT Configuration  

If you want or need to internal NAT, you need to configure it manually.


From [NAT Configuration - vm-bhyve Wiki](https://github.com/churchers/vm-bhyve/wiki/NAT-Configuration)    
(Retrieved on Feb 6, 2022)   

> Unfortunately, internal NAT configuration has been removed as of v1.2. 
> As a shell script, we relied on configuring external systems such as 
> pf and dnsmasq to provide NAT functions. Some users want to use other 
> tools/firewalls, and many users found NAT broken due to existing 
> pf or dnsmasq configuration they had in place. It has come to the point 
> where it's arguably easier and less error-prone to manually configure 
> NAT than to try and enable it via vm-bhyve, then manually install/tweak 
> the generated configuration.


```
% vm version
vm-bhyve: Bhyve virtual machine management v1.4.2 (rev. 104002)
```


```
% cat /etc/rc.conf
zfs_enable="YES"
dumpdev="AUTO"
powerd_enable="YES"
ifconfig_ue0="DHCP"
defaultrouter="192.168.1.254"
kld_list="i915kms"
hostname="fbsd1.home.arpa"
vm_enable="YES"
vm_dir="zfs:zroot/vm"
```


```
% ifconfig
em0: flags=8822<BROADCAST,SIMPLEX,MULTICAST> metric 0 mtu 1500
        options=481249b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,
          VLAN_HWCSUM,LRO,WOL_MAGIC,VLAN_HWFILTER,NOMAP>
---- snip ---- 
        status: no carrier
        nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
        options=680003<RXCSUM,TXCSUM,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x2
        inet 127.0.0.1 netmask 0xff000000
        groups: lo
        nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
ue0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
        options=68009b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,
          VLAN_HWCSUM,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
---- snip ----
        inet 192.168.1.65 netmask 0xffffff00 broadcast 192.168.1.255
        media: Ethernet autoselect (1000baseT <full-duplex>)
        status: active
        nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
```

List all available interfaces on the system.

```
% ifconfig -l
em0 lo0 ue0
```

List only interfaces that are down.

```
% ifconfig -l -d
em0
```

List only interfaces that are up.
```
% ifconfig -l -u
lo0 ue0
```

```
% ls -lh /etc/pf.conf
ls: /etc/pf.conf: No such file or directory
```

```
% printf %s\\n \
 'nat on ue0 from {192.168.8.0/24} to any -> (ue0)' \
 | sudo tee -a /etc/pf.conf
```


**NOTE:**  
I use a shell script with ```openconnect(8)``` ("multi-protocol VPN client 
for Cisco AnyConnect VPNs and others") for connecting to a VPN.
This creates a network interface named **tun0** so I need to add another 
line for it to ```pf.conf```:

```
% printf %s\\n \
 'nat on tun0 from {192.168.8.0/24} to any -> (tun0)' \
 | sudo tee -a /etc/pf.conf
```

```
% cat /etc/pf.conf
nat on ue0 from {192.168.8.0/24} to any -> (ue0)
nat on tun0 from {192.168.8.0/24} to any -> (tun0)
```

Bhyve networking section - based on 
[vm-bhyve wiki - NAT How-To](https://github.com/churchers/vm-bhyve/wiki/NAT-Configuration)
(Retrieved on Feb 6, 2022).


```
% sudo pkg install dnsmasq

---- snip ----

=====
Message from dnsmasq-2.86_2,1:

--
To enable dnsmasq, edit /usr/local/etc/dnsmasq.conf and
set dnsmasq_enable="YES" in /etc/rc.conf[.local]

Further options and actions are documented inside
/usr/local/etc/rc.d/dnsmasq
```


```
% ls -lh /usr/local/etc/rc.d/dnsmasq
-rwxr-xr-x  1 root  wheel   2.7K Jan 13 04:03 /usr/local/etc/rc.d/dnsmasq

% file /usr/local/etc/rc.d/dnsmasq
/usr/local/etc/rc.d/dnsmasq: POSIX shell script, ASCII text executable

% wc -l /usr/local/etc/rc.d/dnsmasq
      97 /usr/local/etc/rc.d/dnsmasq
```


```
% printf %s\\n 'pf_enable="YES"' | sudo tee -a /etc/rc.conf
% printf %s\\n 'gateway_enable="YES"' | sudo tee -a /etc/rc.conf
% printf %s\\n 'dnsmasq_enable="YES"' | sudo tee -a /etc/rc.conf
```


```
% diff \
 --unified=0 \
 /etc/rc.conf.original.bak \
 /etc/rc.conf
--- /etc/rc.conf.original.bak   2022-01-29 19:17:50.236339000 -0800
+++ /etc/rc.conf        2022-01-29 21:42:58.697928000 -0800
@@ -7,0 +8,5 @@
+vm_enable="YES"
+vm_dir="zfs:zroot/vm"
+pf_enable="YES"
+gateway_enable="YES"
+dnsmasq_enable="YES"
```

```
% ls -lh /usr/local/etc/dnsmasq*
-rw-r--r--  1 root  wheel    27K Jan 13 04:03 /usr/local/etc/dnsmasq.conf
-rw-r--r--  1 root  wheel    27K Jan 13 04:03 /usr/local/etc/dnsmasq.conf.sample

% diff \
 /usr/local/etc/dnsmasq.conf.sample \ 
 /usr/local/etc/dnsmasq.conf
```

```
% sudo vi /usr/local/etc/dnsmasq.conf
```

```
% cat /usr/local/etc/dnsmasq.conf
port=0
domain-needed
no-resolv
except-interface=lo0
bind-interfaces
local-service
dhcp-authoritative
 
interface=vm-public
dhcp-range=192.168.8.10,192.168.8.254
```


```
% sudo cp -i /boot/loader.conf /boot/loader.conf.original.bak
```


```
% printf %s\\n 'if_bridge_load="YES"' | sudo tee -a /boot/loader.conf
```

```
% diff \
 --unified=0 \
 /boot/loader.conf.original.bak \
 /boot/loader.conf
--- /boot/loader.conf.original.bak      2022-01-29 21:46:19.799847000 -0800
+++ /boot/loader.conf   2022-01-29 21:47:08.625437000 -0800
@@ -5,0 +6 @@
+if_bridge_load="YES"
```

Based on 
[vm-bhyve wiki - How-To Running Linux](https://github.com/churchers/vm-bhyve/wiki/Guest-example:-Alpine-Linux)(Retrieved on Feb 6, 2022):


```
% sudo cp -i /etc/sysctl.conf /etc/sysctl.conf.original.bak
```

```
% printf %s\\n 'net.link.tap.up_on_open=1' | sudo tee -a /etc/sysctl.conf
% printf %s\\n 'net.link.bridge.pfil_bridge=0' | sudo tee -a /etc/sysctl.conf
% printf %s\\n 'net.link.bridge.pfil_member=0' | sudo tee -a /etc/sysctl.conf
% printf %s\\n 'net.inet.ip.forwarding=1' | sudo tee -a /etc/sysctl.conf
```


```
% diff \
 --unified=0 \
 /etc/sysctl.conf.original.bak \
 /etc/sysctl.conf
--- /etc/sysctl.conf.original.bak       2022-01-29 21:51:56.741050000 -0800
+++ /etc/sysctl.conf    2022-01-29 21:53:29.508938000 -0800
@@ -9,0 +10,4 @@
+net.link.tap.up_on_open=1
+net.link.bridge.pfil_bridge=0
+net.link.bridge.pfil_member=0
+net.inet.ip.forwarding=1
```

Reboot the system.

```
% sudo shutdown -r now
```


After restart:


```
% ls -alh /vm/.config/
total 2
drwxr-xr-x  2 root  wheel     4B Jan 29 20:27 .
drwxr-xr-x  6 root  wheel     6B Jan 29 20:27 ..
-rw-r--r--  1 root  wheel     0B Jan 29 20:27 null.iso
-rw-r--r--  1 root  wheel    63B Jan 29 22:34 system.conf
```


```
% ls -alh /vm/.config/null.iso
-rw-r--r--  1 root  wheel     0B Jan 29 20:27 /vm/.config/null.iso

% cat /vm/.config/system.conf 
switch_list="public"
type_public="standard"
addr_public="192.168.8.1/24"
ports_public=""
```

```
% ls -alh /vm/.img/
total 1
drwxr-xr-x  2 root  wheel     2B Jan 29 20:27 .
drwxr-xr-x  6 root  wheel     6B Jan 29 20:27 ..
 
% ls -alh /vm/.iso/
total 1
drwxr-xr-x  2 root  wheel     2B Jan 29 20:27 .
drwxr-xr-x  6 root  wheel     6B Jan 29 20:27 ..
```

```
% cat /vm/.templates/debian.conf
loader="grub"
cpu=1
memory=512M
network0_type="virtio-net"
network0_switch="public"
disk0_type="ahci-hd"
disk0_name="disk0.img"
grub_run_partition="1"
grub_run_dir="/boot/grub"
```


```
% sudo \ 
 vm \
 iso \
 https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.2.0-amd64-netinst.iso
```

```
% ls -alh /vm/.iso/
total 380110
drwxr-xr-x  2 root  wheel     3B Jan 29 22:52 .
drwxr-xr-x  6 root  wheel     6B Jan 29 20:27 ..
-rw-r--r--  1 root  wheel   378M Dec 18 05:24 debian-11.2.0-amd64-netinst.iso
```


Create a VM named 'debianvm1' by using a template 'debian'.

```
% sudo vm create -t debian debianvm1
```

```
% ls -alh /vm/
total 36
drwxr-xr-x   7 root  wheel     7B Jan 29 22:58 .
drwxr-xr-x  19 root  wheel    25B Jan 29 21:58 ..
drwxr-xr-x   2 root  wheel     4B Jan 29 20:27 .config
drwxr-xr-x   2 root  wheel     2B Jan 29 20:27 .img
drwxr-xr-x   2 root  wheel     3B Jan 29 22:52 .iso
drwxr-xr-x   2 root  wheel    19B Jan 29 22:31 .templates
drwxr-xr-x   2 root  wheel     7B Jan 29 23:03 debianvm1
```


```
% ls -alh /vm/debianvm1/
total 28
drwxr-xr-x  2 root  wheel     7B Jan 29 23:03 .
drwxr-xr-x  7 root  wheel     7B Jan 29 22:58 ..
-rw-r--r--  1 root  wheel   254B Jan 29 22:58 debianvm1.conf
-rw-r--r--  1 root  wheel    77B Jan 29 23:03 device.map
-rw-------  1 root  wheel    20G Jan 29 22:58 disk0.img
-rw-r--r--  1 root  wheel    16B Jan 29 23:03 run.lock
-rw-r--r--  1 root  wheel   1.4K Jan 29 23:12 vm-bhyve.log
```

```
% sudo vm list
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    512M    -    No         Stopped
```

Install GNU Linux Debian. 

```
% sudo vm install -f debianvm1 debian-11.2.0-amd64-netinst.iso
```


### Fixing GNU GRUB 

NOTE: Strictly speaking, it's GRUB 2 (as opposed to GRUB, a.k.a. GRUB Legacy).      


After reboot, Debian booted into GRUB prompt, which means it can't find root partition.

```
                     GNU GRUB  version 2.00

Minimal BASH-like line editing is supported. For the first word, TAB
lists possible command completions. Anywhere else TAB lists possible
device or file completions.

grub>
```

In grub prompt, press TAB:

```
Possible commands are:
      
. [ authenticate background_color background_image blocklist boot break 
cat clear cmp configfile continue crc cryptomount date dump echo exit 
export extract_entries_configfile extract_entries_source
extract_legacy_entries_configfile extract_legacy_entries_source false
functional_test gettext gptsync halt hashsum hello help hexdump initrd 
initrd16 insmod keymap keystatus kfreebsd kfreebsd_loadenv 
kfreebsd_module kfreebsd_module_elf knetbsd knetbsd_module 
knetbsd_module_elf kopenbsd kopenbsd_ramdisk legacy_check_password 
legacy_configfile legacy_initrd legacy_initrd_nounzip legacy_kernel 
legacy_password legacy_source linux linux16 list_env load_env 
loadfont loopback ls lsfonts lsmmap lsmod md5sum menuentry module 
multiboot net_add_addr net_add_dns net_add_route net_bootp net_del_addr
net_del_dns net_del_route net_get_dhcp_option net_ipv6_autoconf 
net_ls_addr net_ls_cards net_ls_dns net_ls_routes net_nslookup normal 
normal_exit parttool password password_pbkdf2 probe read read_byte 
read_dword read_word reboot regexp
return rmmod save_env search search.file search.fs_label search.fs_uuid 
serial set setparams sha1sum sha256sum sha512sum shift sleep source 
submenu terminal_input terminal_output terminfo test test_blockarg 
testload time true unset videoinfo videotest write_byte write_dword 
write_word xnu_uuid zfs-bootfs zfsinfo zfskey

grub>
grub> ls
(hd0) (hd0,msdos5) (hd0,msdos1) (host) (lvm/debianvm1--vg-swap_1) 
  (lvm/debianvm1--vg-root)

grub> ls (hd0,msdos5)
        Partition hd0,msdos5: No known filesystem detected 
        Partition start at 1001472 - Total size 40939520 sectors

grub> ls (hd0,msdos5)/
error: unknown filesystem.

grub> ls (hd0,msdos1)
        Partition hd0,msdos1: Filesystem type ext* 
        Last modification time 2022-01-30 07:47:05 Sunday, 
        UUID 650acfe0-f659-4c0d-a877-27d1fae2d455
        Partition start at 2048 - Total size 997376 sectors

grub> ls (hd0,msdos1)/
lost+found/ config-5.10.0-10-amd64 vmlinuz-5.10.0-10-amd64 
  config-5.10.0-11-amd64 grub/ System.map-5.10.0-10-amd64 
  initrd.img-5.10.0-10-amd64 vmlinuz-5.10.0-11-amd64 
  System.map-5.10.0-11-amd64 initrd.img-5.10.0-11-amd64

grub> ls (host)
Device host: Filesystem type hostfs - Total size 0 sectors

grub> ls (host)/
entropy var/ boot/ dev/ libexec/ media/ root/ proc/ sys COPYRIGHT tmp/ 
  mnt/ lib/ home/ vm/ sbin/ etc/ net/ bin/ usr/ rescue/

grub> ls (lvm/debianvm1--vg-swap_1)
Device lvm/debianvm1--vg-swap_1: No known filesystem detected
Total size 1048576 sectors

grub> ls (lvm/debianvm1--vg-swap_1)/
error: unknown filesystem.

grub> ls (lvm/debianvm1--vg-root)
Device lvm/debianvm1--vg-root: Filesystem type ext*
Last modification time 2022-01-30 07:47:05 Sunday, 
UUID b4113067-fbfd-4471-b7dc-671e3dec3483
Total size 39886848 sectors

grub> ls (lvm/debianvm1--vg-root)/
lost+found/ boot/ etc/ media/ vmlinuz.old var/ bin usr/ sbin lib lib32 
  lib64 libx32 dev/ home/ proc/ root/ run/ sys/ tmp/ mnt/ srv/ opt/ 
  initrd.img.old vmlinuz initrd.img

grub> ls (hd0,msdos1)/grub/
unicode.pf2 i386-pc/ locale/ fonts/ grubenv grub.cfg

grub> ls (host)/boot/
dtb/ loader.conf.original.bak efi/ firmware/ check-password.4th 
  brand-fbsd.4th loader_4th isoboot delay.4th menu-commands.4th 
  boot1 loader_4th.efi logo-orb.4th looader_4th isoboot delay.4th 
  menu-commands.4th boot1 loader_4th.efi logo-orb.4th loader.conf 
  userboot_lua.so brand.4th userboot_4th.so screen.4th support.4th 
  color.4th beastie.4th pxeboot gptboot.efi mbr frames.4th boot2 
  fonts/ uboot/ logo-beastiebw.4th entropy zfs/ lua/ loader.4th 
  loader_lua.efi loader userboot.so loader.rc version.4th boot0 
  menusets.4th cdboot kernel.old/ gptzfsboot modules/ kernel/ 
  logo-orbbw.4th boot0sio images/ loader_lua zfsloader loader_simp 
  menu.4th defaults/ zfsboot boot1.efi boot pmbr loader.efi 
  logo-fbsdbw.4th gptboot device.hints efi.4th shortcuts.4th menu.rc 
  loader.conf.d/ loader_simp.efi logo-beastie.4th

grub> ls (lvm/debianvm1--vg-root)/boot/

grub> 
grub> set prefix=(hd0,msdos1)/grub
grub> set root=(hd0,msdos1)
grub> insmod linux
grub> insmod normal
grub> normal
```

After pressing  ENTER  (after the last line with 'normal'), Debian started normally:


```
Loading Linux 5.10.0-11-amd64 ...
Loading initial ramdisk ...
```

```
                   GNU GRUB  version 2.00

 +--------------------------------------------------------------+
 |Debian GNU/Linux                                              |
 |Advanced options for Debian GNU/Linux                         |
 |                                                              |
 |                                                              |
 |                                                              |
 |                                                              |
 +--------------------------------------------------------------+

  Use the ^ and v keys to select which entry is highlighted.

  Press enter to boot the selected OS, `e' to edit the commands
  before booting or `c' for a command-line.

---- snip ----
```


Log in to Debian VM.

```
Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login:
----------------
```


```
dusko@debianvm1:~$
dusko@debianvm1:~$ uptime
 00:02:34 up 1 min,  1 user,  load average: 0.08, 0.05, 0.01
```


Then issue command to fix grub.

```
$ groups
dusko cdrom floppy audio dip video plugdev netdev bluetooth scanner

$ groups | grep sudo

$ su
Password:
         
# usermod -aG sudo dusko
bash: usermod: command not found

# command -v usermod

# command -V usermod
bash: command: usermod: not found

# type -a usermod
bash: type: usermod: not found

# type usermod
bash: type: usermod: not found

# which usermod

# whereis usermod
usermod: /usr/sbin/usermod /usr/share/man/man8/usermod.8.gz

# /usr/sbin/usermod -aG sudo dusko

# groups dusko
dusko : dusko cdrom floppy sudo audio dip video plugdev netdev bluetooth scanner

# groups dusko | grep sudo
dusko : dusko cdrom floppy sudo audio dip video plugdev netdev bluetooth lpadmin scanner

# exit
exit

$ groups
dusko cdrom floppy audio dip video plugdev netdev bluetooth lpadmin scanner

$ groups | grep sudo
```

Refresh shell environment without logging out:

```
$ exec su - dusko
Password:
```

Log in back to Debian VM.

```
$ groups | grep sudo
dusko cdrom floppy sudo audio dip video plugdev netdev bluetooth lpadmin scanner
```

You can now run update-grub as root with sudo(8).

```
$ sudo update-grub
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.10.0-11-amd64
Found initrd image: /boot/initrd.img-5.10.0-11-amd64
Found linux image: /boot/vmlinuz-5.10.0-10-amd64
Found initrd image: /boot/initrd.img-5.10.0-10-amd64
done
```

```
$ sudo reboot
```

However, after reboot, the system booted into grub prompt again.


```
                         GNU GRUB  version 2.00

Minimal BASH-like line editing is supported. For the first word, 
TAB lists possible command completions. Anywhere else TAB lists 
possible device or file completions.


grub>
```


Exit the GRUB prompt:

```
grub> exit
```


[FIX] Debian installs boot to 2nd partition but with default 
bhyve configuration, GRUB looks for boot in 1st partition.


On the FreeBSD host:


```
% sudo cp -i /vm/debianvm1/debianvm1.conf /vm/debianvm1/debianvm1.conf.original.bak
```

```
% sudo vi /vm/debianvm1/debianvm1.conf
```

```
% diff \
 --unified=0 \
 /vm/debianvm1/debianvm1.conf.original.bak \
 /vm/debianvm1/debianvm1.conf
--- /vm/debianvm1/debianvm1.conf.original.bak   2022-01-30 00:17:47.121434000 -0
800
+++ /vm/debianvm1/debianvm1.conf        2022-01-30 00:19:25.190592000 -0800
@@ -8,2 +8,2 @@
-grub_run_partition="1"
-grub_run_dir="/boot/grub"
+grub_run_partition="msdos1"
+grub_run_dir="/grub"
```

```
% cat /vm/debianvm1/debianvm1.conf
loader="grub"
cpu=1
memory=512M
network0_type="virtio-net"
network0_switch="public"
disk0_type="ahci-hd"
disk0_name="disk0.img"
grub_run_partition="msdos1"
grub_run_dir="/grub"
uuid="fc62f0ca-8199-11ec-aa36-e86a64ba6be0"
network0_mac="58:9c:fc:0a:ab:4f"
```

```
% sudo vm list
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    512M    -    No         Stopped
```

It worked.

```
% sudo vm start -f debianvm1
```

```
Loading Linux 5.10.0-11-amd64 ...
Loading initial ramdisk ...
```

```
                      GNU GRUB  version 2.00

 +-------------------------------------------------------------+
 |Debian GNU/Linux                                             |
 |Advanced options for Debian GNU/Linux                        |
 |                                                             |
 |                                                             |
 |                                                             |
 |                                                             |
 |                                                             |
 |                                                             |
 |                                                             |
 |                                                             |
 +-------------------------------------------------------------+

 Use the ^ and v keys to select which entry is highlighted.
 Press enter to boot the selected OS, `e' to edit the commands before
 booting or `c' for a command-line.

---- snip ----
```


```
Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login:
----------------
```


Log in to the VM.


```
$ sudo reboot
[sudo] password for dusko:
```

```
Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login: 
----------------
```


#### Starting the VM  

If you specifty the -f option, the guest will start in the foreground on stdio, 
and you will not be able to access it through the console 
(```sudo vm console debianvm1```).

```
% sudo vm start -f debianvm1
```

If you want to access it via the console (```sudo vm console debianvm1```), 
start the VM without the -f option:

```
% sudo vm start debianvm1
```

and then, you can access the vm through the console:

```
% sudo vm console debianvm1
```

Output shows:

```
Connected
```

Press ```Enter``` here, and after that the VM presents the login screen:

```
Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login: 
```

To disconnect, that is, to exit the console and return to the host,
press ```~+Ctrl-D```  (```tilde```, then ```Ctrl+d```). 
It's also written as 
```tilde```, then ```^D```; or: ```tilde```, then ```Control-d```).


Output:

```
 ~
[EOT]
```

