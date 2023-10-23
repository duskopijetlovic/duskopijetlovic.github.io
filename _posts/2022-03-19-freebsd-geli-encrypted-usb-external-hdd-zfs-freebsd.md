---
layout: post
title: "How to Setup an External GELI Encrypted USB Hard Drive as a ZFS Backup Disk in FreeBSD"
date: 2022-03-19 10:13:21 -0700 
categories: zfs freebsd snapshot backup 
---

* OS:  FreeBSD 13.0   
* Shell:  csh  
* External hard disk drive: WD (WesternDigital) Easystore 14TB USB 3.0 Desktop External Hard Drive, Model:  [WDBAMA0140HBK-NESE](https://www.bestbuy.ca/en-ca/product/wd-easystore-14tb-usb-3-0-desktop-external-hard-drive-wdbama0140hbk-nese-black-only-at-best-buy/14936770)
  * Possibly, a variation of a model [WDBAMA0140HBK-NESN](https://www.westerndigital.com/products/portable-drives/wd-easystore-desktop-usb-3-0-hdd#WDBAMA0140HBK-NESN)    

---

## Preparation

Install packages `zxfer` and `zfstools`.

```
$ sudo pkg install zxfer zfstools
```

The zfstools package has the `zfs-auto-snapshot` tool that creates and 
manages ZFS snapshots.  

The zxfer package is a shell script that uses `zfs-send(8)` for sending 
snapshots and `zfs-receive(8)` for receiving them in the external USB hard 
disk drive.


## Enabling Automatic ZFS Filesystem Snapshotting

Use `zfs list` and `zpool list` to check the ZFS filesystems in your pool.  

```
$ zfs list
NAME                 USED  AVAIL     REFER  MOUNTPOINT
zroot                189G   710G       88K  /zroot
zroot/ROOT          58.5G   710G       88K  none
zroot/ROOT/default  58.5G   710G     52.6G  /
zroot/tmp           24.4G   710G     24.4G  /tmp
zroot/usr            101G   710G       88K  /usr
zroot/usr/home       101G   710G      101G  /usr/home
zroot/usr/ports       88K   710G       88K  /usr/ports
zroot/usr/src         88K   710G       88K  /usr/src
zroot/var           2.81M   710G       88K  /var
zroot/var/audit       88K   710G       88K  /var/audit
zroot/var/crash       88K   710G       88K  /var/crash
zroot/var/log       1.47M   710G     1.47M  /var/log
zroot/var/mail       144K   710G      144K  /var/mail
zroot/var/tmp        964K   710G      964K  /var/tmp
```

```
$ zpool list
NAME   SIZE  ALLOC  FREE CKPOINT EXPANDSZ  FRAG  CAP DEDUP  HEALTH  ALTROOT
zroot  928G   189G  739G       -        -    6%  20% 1.00x  ONLINE  -
```

The default ZFS layout with a fresh FreeBSD 13 sets up the 
following filesystems in the pool (not counting zroot, zroot/ROOT, 
zroot/usr, and zroot/var, which are containers for children filesystems, 
not used directly for data storage): 

zroot/ROOT/default   
zroot/tmp   
zroot/usr/home   
zroot/usr/ports   
zroot/usr/src   
zroot/var/audit   
zroot/var/crash   
zroot/var/log   
zroot/var/mail   
zroot/var/tmp   


Filesystems and their content: <sup>[1](#footnotes)</sup>

* zroot/ROOT/default: Configurations and root's home directory.
* zroot/usr/home: User home directory. 
* zroot/var/log: System log files.
* zroot/var/mail: Mail spools for your user account and root.

* zroot/tmp: Temporary files, which are usually not preserved across 
             a system reboot.
* zroot/usr/ports: FreeBSD Ports Collection. 
* zroot/usr/src:   FreeBSD source code for both the kernel and the userland.
* zroot/var/audit: Audit logging not enabled by default.
* zroot/var/crash: Kernel core dumps.
* zroot/var/tmp: Temporary files, which are usually preserved across 
                 a system reboot, unless /var is a memory-based file system.


Based on that, I chose to snapshot:   
* zroot/ROOT/default
* zroot/usr/home
* zroot/var/log
* zroot/var/mail

Zfstools looks at the ZFS user property `com.sun:auto-snapshot` to 
determine whether to snapshot a filesystem or not.  On a new 
system, this property is unset, neither true nor false, neither 
local nor inherited. 

From the `/usr/local/share/doc/zfstools/README.md`:

```
#### Dataset setup

Only datasets with the `com.sun:auto-snapshot` property set to `true` will 
be snapshotted.

    zfs set com.sun:auto-snapshot=true DATASET
```


Use `zfs get com.sun:auto-snapshot` to see its status for all ZFS 
filesystems. 

```
$ zfs get -r com.sun:auto-snapshot zroot
NAME                     PROPERTY               VALUE   SOURCE
zroot                    com.sun:auto-snapshot  -       -
zroot/ROOT               com.sun:auto-snapshot  -       -
zroot/ROOT/default       com.sun:auto-snapshot  -       -
zroot/tmp                com.sun:auto-snapshot  -       -
zroot/usr                com.sun:auto-snapshot  -       -
zroot/usr/home           com.sun:auto-snapshot  -       -
zroot/usr/ports          com.sun:auto-snapshot  -       -
zroot/usr/src            com.sun:auto-snapshot  -       -
zroot/var                com.sun:auto-snapshot  -       -
zroot/var/audit          com.sun:auto-snapshot  -       -
zroot/var/crash          com.sun:auto-snapshot  -       -
zroot/var/log            com.sun:auto-snapshot  -       -
zroot/var/mail           com.sun:auto-snapshot  -       -
zroot/var/tmp            com.sun:auto-snapshot  -       -
```

Set the ZFS property `com.sun:auto-snapshot` to false on ZFS filesystems 
that you don't want `zfstools` to snapshot.  In this example, 
the command is:

```
$ sudo zfs set \
com.sun:auto-snapshot=false \
zroot/tmp \
zroot/usr/ports \
zroot/usr/src \
zroot/var/audit \
zroot/var/crash \
zroot/var/tmp
```

See `zfs-set(8)`, `zfs-inherit(8)`, and the "User Properties" section 
of `zfsprops(8)` for details.

Next, turn on snapshotting for the rest of the pool:

```
$ sudo zfs set com.sun:auto-snapshot=true zroot
```

Now the `com.sun:auto-snapshot` property for all ZFS filesystems looks like this:

```
$ zfs get -r com.sun:auto-snapshot zroot
NAME                     PROPERTY               VALUE   SOURCE
zroot                    com.sun:auto-snapshot  true    local
zroot/ROOT               com.sun:auto-snapshot  true    inherited from zroot
zroot/ROOT/default       com.sun:auto-snapshot  true    inherited from zroot
zroot/tmp                com.sun:auto-snapshot  false   local
zroot/usr                com.sun:auto-snapshot  true    inherited from zroot
zroot/usr/home           com.sun:auto-snapshot  true    inherited from zroot
zroot/usr/ports          com.sun:auto-snapshot  false   local
zroot/usr/src            com.sun:auto-snapshot  false   local
zroot/var                com.sun:auto-snapshot  true    inherited from zroot
zroot/var/audit          com.sun:auto-snapshot  false   local
zroot/var/crash          com.sun:auto-snapshot  false   local
zroot/var/log            com.sun:auto-snapshot  true    inherited from zroot
zroot/var/mail           com.sun:auto-snapshot  true    inherited from zroot
zroot/var/tmp            com.sun:auto-snapshot  false   local
```


The `zfstools` relies on `zfs-auto-snapshot` and `zfs-cleanup-snapshots`, 
which are located in `/usr/local/sbin/`:

```
$ command -v zfs-auto-snapshot; type zfs-auto-snapshot; \
whereis zfs-auto-snapshot; which zfs-auto-snapshot
/usr/local/sbin/zfs-auto-snapshot
zfs-auto-snapshot is /usr/local/sbin/zfs-auto-snapshot
zfs-auto-snapshot: /usr/local/sbin/zfs-auto-snapshot
/usr/local/sbin/zfs-auto-snapshot
```

```
$ command -v zfs-cleanup-snapshots; type zfs-cleanup-snapshots \
? whereis zfs-cleanup-snapshots; which zfs-cleanup-snapshots
/usr/local/sbin/zfs-cleanup-snapshots
zfs-cleanup-snapshots is /usr/local/sbin/zfs-cleanup-snapshots
whereis is /usr/bin/whereis
zfs-cleanup-snapshots is a tracked alias for /usr/local/sbin/zfs-cleanup-snapshots
/usr/local/sbin/zfs-cleanup-snapshots
```


To get a brief usage message for these two tools:

```
$ /usr/local/sbin/zfs-auto-snapshot usage
Usage: /usr/local/sbin/zfs-auto-snapshot [-dknpuv] <INTERVAL> <KEEP>
    -d              Show debug output.
    -k              Keep zero-sized snapshots.
    -n              Do a dry-run. Nothing is committed. Only show what would be done.
    -p              Create snapshots in parallel.
    -P pool         Act only on the specified pool.
    -u              Use UTC for snapshots.
    -v              Show what is being done.
    INTERVAL        The interval to snapshot.
    KEEP            How many snapshots to keep.
```

```
$ /usr/local/sbin/zfs-cleanup-snapshots usage
Usage: /usr/local/sbin/zfs-cleanup-snapshots [-dnv]
    -d              Show debug output.
    -n              Do a dry-run. Nothing is committed. Only show what would be done.
    -p              Create snapshots in parallel.
    -P pool         Act only on the specified pool.
    -v              Show what is being done.
```


The pkg-message for `zfstools` gives an example for enabling automatic 
snapshots by placing a set of cron commands into **/etc/crontab**, which 
is the system crontab.  

```
$ pkg info --pkg-message --regex zfstools
zfstools-0.3.6_2:
On install:
To enable automatic snapshots, place lines such as these into /etc/crontab:

    PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
    15,30,45 * * * * root /usr/local/sbin/zfs-auto-snapshot frequent  4
    0        * * * * root /usr/local/sbin/zfs-auto-snapshot hourly   24
    7        0 * * * root /usr/local/sbin/zfs-auto-snapshot daily     7
    14       0 * * 7 root /usr/local/sbin/zfs-auto-snapshot weekly    4
    28       0 1 * * root /usr/local/sbin/zfs-auto-snapshot monthly  12

This will keep 4 15-minutely snapshots, 24 hourly snapshots, 7 daily snapshots,
4 weekly snapshots and 12 monthly snapshots. Any resulting zero-sized snapshots
will be automatically cleaned up.

Enable snapshotting on a dataset or top-level pool with:

    zfs set com.sun:auto-snapshot=true DATASET

Children datasets can be disabled for snapshot with:

    zfs set com.sun:auto-snapshot=false DATASET

Or for specific intervals:

    zfs set com.sun:auto-snapshot:frequent=false DATASET

See website and command usage output for further details.
```

The FreeBSD Handbook, Section [12.3. Configuring cron(8)](https://docs.freebsd.org/en/books/handbook/config/#configtuning-cron) (retrieved on Mar 19, 2022) advises against modifying the system crontab.  Instead, it recommends using user crontabs. 

Order of `crontab` fields (also see `man 5 crontab`):

```
$ grep command /etc/crontab
#minute hour    mday    month   wday    who     command
```

**NOTE:**
From the FreeBSD Handbook:  
> The format of the system crontab, **/etc/crontab** includes a **who** column 
> which does not exist in user crontabs.


Create a user crontab for the root user.

```
$ sudo crontab -e -u root
```

Check the root user crontab schedule:

```
$ sudo crontab -l
SHELL=/bin/sh
PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#minute  hour mday month wday command
15,30,45 *    *    *     *    /usr/local/sbin/zfs-auto-snapshot frequent  4
0        *    *    *     *    /usr/local/sbin/zfs-auto-snapshot hourly   24
7        0    *    *     *    /usr/local/sbin/zfs-auto-snapshot daily     7
14       0    *    *     7    /usr/local/sbin/zfs-auto-snapshot weekly    4
28       0    1    *     *    /usr/local/sbin/zfs-auto-snapshot monthly  12
```

## Preparing the Backup Drive

```
$ freebsd-version
13.0-RELEASE-p7
```

Connect one end of the USB cable to your system and the other end to 
the hard drive. 

Use `dmseg` to find the external drive's device node name (in this 
example, `da0`) and use `gpart destroy` to remove any old partition 
table that might be on the drive.

```
$ dmesg | tail -25
[...]
ugen0.4: <Western Digital easystore 264D> at usbus0
umass0 on uhub0
umass0: <Western Digital easystore 264D, class 0/0, rev 3.10/30.12, addr 58> on usbus0
umass0:  SCSI over Bulk-Only; quirks = 0xc001
umass0:7:0: Attached to scbus7
da0 at umass-sim0 bus 0 scbus7 target 0 lun 0
da0: <WD easystore 264D 3012> Fixed Direct Access SPC-4 SCSI device
da0: Serial Number 123D45678901234B
da0: 400.000MB/s transfers
da0: 13351936MB (27344764928 512 byte sectors)
da0: quirks=0x2<NO_6_BYTE>
ses1 at umass-sim0 bus 0 scbus7 target 0 lun 1
ses1: <WD SES Device 3012> Fixed Enclosure Services SPC-4 SCSI device
ses1: Serial Number 123D45678901234B
ses1: 400.000MB/s transfers
ses1: SES Device
```

```
$ dmesg | grep -i easy | grep -i store
ugen0.4: <Western Digital easystore 264D> at usbus0
umass0: <Western Digital easystore 264D, class 0/0, rev 3.10/30.12, addr 3> on usbus0
da0: <WD easystore 264D 3012> Fixed Direct Access SPC-4 SCSI device
ugen0.4: <Western Digital easystore 264D> at usbus0
umass0: <Western Digital easystore 264D, class 0/0, rev 3.10/30.12, addr 3> on usbus0
da0: <WD easystore 264D 3012> Fixed Direct Access SPC-4 SCSI device
```

```
$ sudo usbconfig show_ifdrv | grep umass0
ugen0.4.0: umass0: <Western Digital easystore 264D, class 0/0, rev 3.10/30.12, addr 58>
```

```
$ sudo usbconfig dump_info | grep ugen0.4
ugen0.4: <Western Digital easystore 264D> at usbus0, cfg=0 md=HOST spd=SUPER (5 Gbps) pwr=ON (2mA)
```

```
$ sudo usbconfig list | grep ugen0.4
ugen0.4: <Western Digital easystore 264D> at usbus0, cfg=0 md=HOST spd=SUPER (5 Gbps) pwr=ON (2mA)
```

```
$ sudo camcontrol devlist
---- snip ----
<WD easystore 264D 3012>           at scbus7 target 0 lun 0 (da0,pass3)
---- snip ----
```

```
$ geom disk list
---- snip ----
Geom name: da0
Providers:
1. Name: da0
   Mediasize: 14000519643136 (13T)
   Sectorsize: 512
   Stripesize: 4096
   Stripeoffset: 0
   Mode: r0w0e0
   descr: WD easystore 264D
   lunname: WD      easystore 264D  9MH60Y1K
   lunid: 5000cca290d0d53f
   ident: 394D48363059314B
   rotationrate: 7200
   fwsectors: 63
   fwheads: 255
---- snip ----
```


```
$ gpart list | grep -w da0
```

```
$ gpart list da0
[...]
```

```
$ gpart show | grep -w da0
```

```
$ gpart show da0
[...]
```

```
$ glabel list | grep da0
```

This is a brand new disk so `gpart list <geom_name>` complains: 

```
$ glabel list da0
glabel: Class 'LABEL' does not have an instance named 'da0'.
```


Similarly, `gpart destroy` complains too:

```
$ sudo gpart destroy -F da0
gpart: arg0 'da0': Invalid argument
```

**NOTE:**  If the disk was previously configured and in use
(that is, it had a partitioning scheme on it),
the `gpart destroy -F <geom_name>` command 
would destroy the geom and report `<geom_name> destroyed`.


**NOTE:**   
Q: Why the use of `gpart destroy -F <geom_name>` command?   
A: From the manpage for `gpart(8)`:    

```
Rather than deleting each partition and then destroying the partitioning
scheme, the -F option can be given with destroy to delete all of the
partitions before destroying the partitioning scheme.  This is equivalent
to the previous example:
  
      /sbin/gpart destroy -F da0
```


After `gpart destroy` (or with a brand new hard disk drive):

```
$ gpart show da0
gpart: No such geom: da0.
 
$ gpart list da0
gpart: Class 'PART' does not have an instance named 'da0'.
```


First, create a GPT partition table (partition table with **gpt** partitioning 
scheme) on disk `da0`.

```
$ sudo gpart create -s gpt da0
da0 created
```

```
$ gpart show da0
=>         40  27344764848  da0  GPT  (13T)
           40  27344764848       - free -  (13T)
```

```
$ gpart list da0 | wc -l
      17
```

```
$ gpart list da0
Geom name: da0
---- snip ----
```


Having created a partitioning scheme on the disk, you now can create 
a new ZFS partition (on disk `da0`, on 1MB boundaries).  In this example, 
I decided to use a label named **external**.   

```
$ sudo gpart add -a 1m -l external -t freebsd-zfs da0
da0p1 added
```

Explanation:     
* The FreeBSD Handbook, Section [18.2. Adding Disks](https://docs.freebsd.org/en/books/handbook/disks/#disks-adding) (retrieved on Mar 19, 2022) recommends alignment on 1MB boundaries:

    > To improve performance on newer disks with larger hardware block sizes, 
    > the partition is aligned to one megabyte boundaries.

* From the manpage for `gpart(8)`, under section PARTITION TYPES: 

    > freebsd-zfs:    A FreeBSD partition that contains a ZFS volume. 


```
$ gpart show da0
=>         40  27344764848  da0  GPT  (13T)
           40         2008       - free -  (1.0M)
         2048  27344760832    1  freebsd-zfs  (13T)
  27344762880         2008       - free -  (1.0M)
```

```
$ gpart list da0 | wc -l
      34
```

```
$ gpart list da0
Geom name: da0
---- snip ----
scheme: GPT
Providers:
1. Name: da0p1
   Mediasize: 14000517545984 (13T)
   Sectorsize: 512
   Stripesize: 4096
---- snip ----
   label: external
---- snip -----
   type: freebsd-zfs
---- snip ----
Consumers:
1. Name: da0
   Mediasize: 14000519643136 (13T)
   Sectorsize: 512
   Stripesize: 4096
---- snip ----
```

```
$ ls -lh /dev/gpt/external
crw-r-----  1 root  operator  0x1dd Mar 19 15:53 /dev/gpt/external 
```

```
$ date
Sat 19 Mar 2022 15:53:28 PDT
```


To use the `geli(8)` utility, you first need to load the `GEOM_ELI` module. 

  
```
$ sudo geli load
```

```
$ geli status
```


To load the GEOM_ELI module at boot time, add the following line to your `loader.conf(5)`:

```
$ printf %s\\n 'geom_eli_load="YES"' | sudo tee -a /boot/loader.conf
```


Create an encrypted provider (initialize a provider which is going to be 
encrypted with a passphrase) on the disk.   
Use the AES-XTS encryption algorithm (the default and recommended by the 
manpage for `geli(8)` - here used explicitely for the sake of this example), 
key length of 256, and 4kB sector size.   

```
$ sudo geli init -e AES-XTS -l 256 -s 4096 "/dev/gpt/external"
Enter new passphrase:
Reenter new passphrase:
```

Output:

```
Metadata backup for provider /dev/gpt/external can be found in 
  /var/backups/gpt_external.eli
and can be restored with the following command:

        # geli restore /var/backups/gpt_external.eli /dev/gpt/external
```


Attach the provider (in this example, `/dev/gpt/external`).  

```
$ sudo geli attach /dev/gpt/external
Enter passphrase:
```


```
$ geli status
            Name  Status  Components
gpt/external.eli  ACTIVE  gpt/external
```


List all available ZFS pools on the system before adding a new zpool:

```
$ zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zroot   928G   189G   739G        -         -     6%    20%  1.00x    ONLINE  -
```

Create a new zpool in the geli partition called **external**. 
Name the new pool **external**. 


```
$ sudo zpool create external gpt/external.eli
```

It's possible to use the pool named **external** as the destination for 
`zxfer` directly; however, in this example create a new dataset inside 
the pool, and name it after the source machine's hostname.  This will 
help identify backup data and allow multiple hosts to back up to the 
same drive.  Since the source machine's hostname in this example 
is **fbsd1**, the backup destination for zxfer will be **backup/fbsd1**. 

```
$ hostname
fbsd1.mydomain.com
```

Trim off any domain information from the printed name of the current host:

```
$ hostname -s
fbsd1
```


The list of all available ZFS pools on the system now includes the new 
zpool (named **external**):  

```
$ zpool list
NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
external  12.7T   468K  12.7T        -         -     0%     0%  1.00x    ONLINE  -
zroot      928G   189G   739G        -         -     6%    20%  1.00x    ONLINE  -
```

```
$ zfs list
NAME                 USED  AVAIL     REFER  MOUNTPOINT
external             372K  12.3T       96K  /external
zroot                176G   723G       88K  /zroot
---- snip ----
```


Create a ZFS dataset (file system) named **external/fbsd1**. <sup>[2](#footnotes)</sup>

```
$ sudo zfs create external/fbsd1
``` 


```
$ zfs list
NAME                 USED  AVAIL     REFER  MOUNTPOINT
external             504K  12.3T       96K  /external
external/fbsd1        96K  12.3T       96K  /external/fbsd1
zroot                189G   710G       88K  /zroot
---- snip ----
```


```
$ sudo zpool import
no pools available to import
```

Run `zpool export` and `geli detach` to simulate the drive removal from 
the system. 

```
$ sudo zpool export external
```

Confirm that the zpool named **external** has been exported:  

```
$ zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zroot   928G   189G   739G        -         -     6%    20%  1.00x    ONLINE  -
```

```
$ sudo zpool import
   pool: external
     id: 1234567890123456789
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        external            ONLINE
          gpt/external.eli  ONLINE
```

```
% geli status
            Name  Status  Components
gpt/external.eli  ACTIVE  gpt/external
```

```
$ sudo geli detach /dev/gpt/external
```

```
$ geli status
```

Disconnect the external drive from the system.


## Performing the First Backup 

Connect one end of the USB cable to your system and the other end to 
the hard drive. 

```
$ geli status
```


Attach the provider (in this example, `/dev/gpt/external`) with `geli(8)`.

```
$ sudo geli attach /dev/gpt/external
Enter passphrase: 
```

```
$ geli status
            Name  Status  Components
gpt/external.eli  ACTIVE  gpt/external
```

Import the zpool named **external**.

```
$ sudo zpool import
   pool: external
     id: 1234567890123456789
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        external            ONLINE
          gpt/external.eli  ONLINE
```

```
$ sudo zpool import external
```

```
$ zpool list
NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
external  12.7T   696K  12.7T        -         -     0%     0%  1.00x    ONLINE  -
zroot      928G   189G   739G        -         -     6%    20%  1.00x    ONLINE  -
```

```
$ zfs list
NAME                 USED  AVAIL     REFER  MOUNTPOINT
external             588K  12.3T       96K  /external
external/fbsd1        96K  12.3T       96K  /external/fbsd1
zroot                189G   710G       88K  /zroot
---- snip ----
```


```
$ ls -alh /external/
total 10
drwxr-xr-x   3 root  wheel     3B Mar 19 15:59 .
drwxr-xr-x  21 root  wheel    28B Mar 19 16:06 ..
drwxr-xr-x   2 root  wheel     2B Mar 19 15:59 fbsd1

$ ls -alh /external/fbsd1/
total 1
drwxr-xr-x  2 root  wheel     2B Mar 19 15:59 .
drwxr-xr-x  3 root  wheel     3B Mar 19 15:59 ..
```


In the manpage for `zxfer(8)`, the first example (**Ex1 - Backup a pool
(including snapshots and properties)**) offers a use case for replicating
the entire `zroot` pool from the host system to the backup drive.

Use `zfs list | awk` to confirm that none of the dataset names 
contain spaces. <sup>[3](#footnotes)</sup>

```
$ zfs list -H | \
cut -f1 | \
awk '/[[:space:]]/{printf("Error! Dataset name contains spaces: %s\n",$0)}'
```

Switch to the root user.

```
$ su
Password:
# 
```


The root user's shell is `csh`:

```
# ps $$
  PID TT  STAT    TIME COMMAND
17578  4  S    0:00.01 _su (csh)
 
# printf %s\\n "$SHELL"
/bin/csh
```

So, for defining shell variables, you need to use the `set` built-in shell command.  

As per [GELI Encrypted USB Backup of ZFS Filesystems in FreeBSD 13](https://thornton2.com/unix/freebsd/geli-encrypted-usb-backup.html) (Retrieved on 
Mar 19, 2022), exclude the following ZFS properties 
(note: I'm not excluding `com.sun:auto-snapshot:015m`).

```
# set exclude="com.sun:auto-snapshot"
# set exclude="${exclude},objsetid"
# set exclude="${exclude},keylocation"
# set exclude="${exclude},keyformat"
# set exclude="${exclude},pbkdf2iters"
```

```
# printf %s\\n "$exclude"
com.sun:auto-snapshot,objsetid,keylocation,keyformat,pbkdf2iters
```

[At the beginning](#enabling-automatic-zfs-filesystem-snapshotting), 
you set `com.sun:auto-snapshot` property to true for any dataset that you 
want the `zfstools` to snapshot.  When running `zxfer` to copy snapshots 
to a locally-mounted backup pool, you need to use the `-I` option for 
properties that will be ignored in order to prevent that property from 
being copied to the backup data.  If this option is not specified, `zxfer` 
will copy the property to the data in the backup pool and the system will 
begin taking snapshots of the backup data, which can prevent files from 
replicating properly.  This option may not be necessary for replication 
to a remote server or if the backup is only applied to specific datasets 
rather than the entire `zroot`.


Confirm that the file system `external/fbsd1` is mounted: 

```
# df -hT
Filesystem      Type       Size    Used   Avail Capacity  Mounted on
[...]
external        zfs        1.8T     96K    1.8T     0%    /external
external/fbsd1  zfs        1.8T     96K    1.8T     0%    /external/fbsd1
```

Backup the pool `zroot` to `external/fbsd1` 

```
# zxfer -dFkPv -I $exclude -R zroot external/fbsd1
---- snip ----
```

From the manpage for `zxfer(8)`: 

```
     Modifying an example first is a good way to start using the script, as
     there are some options (e.g. -d and -F in normal mode) that are in
     practice always used.

[...]

EXAMPLES
     Note that some of these example commands are lengthy, so be sure to fix
     the line wrapping appropriately. Also if you wonder why zxfer isn't
     transferring anything, please read the section titled SNAPSHOTS.
  
  Ex1 - Backup a pool (including snapshots and properties)
[...] 

                [-d] deleting stale snapshots that don't exist on the source
                (e.g. if using a snapshot management script such as
                zfs-snapshot-mgmt(8), snapshots are regularly taken and
                regularly deleted to leave a range of frequencies of snapshots
                at different vintages. If you are regularly backing up to
                another pool which is stored off-site as is highly recommended,
                you may want to delete the stale snapshots on the backup pool
                without having to manage the snapshots there too. This is
                especially true for those pools that are usually not connected
                to a machine, e.g. if you are using HDD as backup media. Note
                that zfs send will also refuse to work if you have newer
                snapshots on destination than the most recent common snapshot
                on both, so it's easier to just enable it.)

                [-F] forcing a rollback of destination to the most recent
                snapshot. Given even mounting the filesystem will cause a
                change and hence cause zfs receive to fail with an error,
                enabling this is the way to go. Otherwise you would be
                modifying(!) a backup, wanting to keep the changes you are
                making(!?) and also wanting to copy more stuff to the backup
                (hence it's still being used as a backup)... well if that's
                what you want then don't use this option.

                [-k] storing the original filesystem properties in the file
                external/fbsd1/.zxfer_backup_info.zroot

                [-P] copying across the properties of each filesystem

                [-v] seeing lots of output (verbose)
```


For this example, it took around 35 minutes to complete. 

```
$ ls -alh /external/fbsd1/
total 34
drwxr-xr-x  3 root  wheel     4B Mar 19 16:53 .
drwxr-xr-x  3 root  wheel     3B Mar 19 15:59 ..
-rw-r--r--  1 root  wheel    28K Mar 19 16:53 .zxfer_backup_info.zroot
drwxr-xr-x  7 root  wheel     7B Mar 19 16:53 zroot
```

```
$ zfs list
NAME                                USED  AVAIL     REFER  MOUNTPOINT
external                           37.7G  12.3T       96K  /external
external/fbsd1                     37.7G  12.3T      136K  /external/fbsd1
external/fbsd1/zroot               37.7G  12.3T      152K  /external/fbsd1/zroot
---- snip ----
zroot                               189G   710G       88K  /zroot
zroot/ROOT                         58.5G   710G       88K  none
---- snip ---
```

```
$ df -hT
Filesystem                         Type       Size    Used   Avail Capacity  Mounted on
zroot/ROOT/default                 zfs        763G     53G    710G     7%    /
---- snip ----
external                           zfs         12T     96K     12T     0%    /external
external/fbsd1                     zfs         12T    136K     12T     0%    /external/fbsd1
external/fbsd1/zroot               zfs         12T    152K     12T     0%    /external/fbsd1/zroot
---- snip ----
```


You can now scrub the external backup drive to make sure everything is good.
(From the manpage for `zpool-scrub(8)`: for the option `-w` :  Wait until 
scrub has completed before returning.  This is so you to know when you 
get the shell prompt back that the scrube is done.)  The scrub takes at least 
as long as the first backup because it examines all data in the external 
pool to verify that it checksums correctly.

```
$ sudo zpool scrub -w external
```

The `zpool status` command reports the progress of the scrub.
From a separate shell:  

```
$ zpool status external
  pool: external
 state: ONLINE
  scan: scrub in progress since Sat Mar 19 19:42:44 2022
        69.2G scanned at 68.2M/s, 32.7G issued at 32.2M/s, 69.2G total
        0B repaired, 47.27% done, 00:19:20 to go
config:

        NAME                STATE     READ WRITE CKSUM
        external            ONLINE       0     0     0
          gpt/external.eli  ONLINE       0     0     0

errors: No known data errors
```

```
$ zpool list
NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
external  12.7T  37.7G  12.7T        -         -     0%     0%  1.00x    ONLINE  -
zroot      928G   189G   739G        -         -     6%    20%  1.00x    ONLINE  -
```


When the scrub is done:

```
% zpool status external
  pool: external
 state: ONLINE
  scan: scrub repaired 0B in 00:35:28 with 0 errors on Sat Mar 19 20:18:12 2022
config:

        NAME                STATE     READ WRITE CKSUM
        external            ONLINE       0     0     0
          gpt/external.eli  ONLINE       0     0     0

errors: No known data errors
```

## Scripting the Regular Backup 

Download the script `extbackup.sh`: 
* [extbackup.sh]({{ site.url }}/assets/txt/extbackup.sh)

Remember to edit the line `backupdev="da0"`, and replace `da0` with the 
drive matching your system. 

Now when it comes time to run a backup, all you have to do is plug in the
external backup drive, get root, and run `./extbackup.sh`.  

```
$ sudo ./extbackup.sh
[ OK ]  Attaching external backup drive.
Enter passphrase: 
[ OK ]  Importing external pool.
[ OK ]  Mounting 'external/fbsd1'.
[ OK ]  Commencing backup.
[...]
```

When it's done, the script also unmounts the external backup drive and 
does geli detach.  After that unplug the external backup drive and put it away.

```
$ zpool list | grep external
```

```
$ zfs list | grep external
```

```
$ sudo zpool import
no pools available to import
```

```
$ geli status
```

```
$ df -hT | grep external
```

## Performing Subsequent Backups 

Attach the external hard disk drive to the system.

Run the external backup script `./extbackup.sh` 

```
$ sudo ./extbackup.sh
[ OK ]  Attaching external backup drive.
Enter passphrase: 
[ OK ]  Importing external pool.
[ OK ]  Mounting 'external/fbsd1'.
[ OK ]  Commencing backup.
[...]
[ OK ]  Backup completed successfully.
[ OK ]  Unmounted 'external/fbsd1' cleanly.
[ OK ]  Exporting external pool.
[ OK ]  Detaching external backup drive.
[ OK ]  Done.
```

## Recovering a File from ZFS Snapshot on the External USB Geli Encrypted Hard Disk Drive

If you now mount a file system on the external USB drive 
`external/fbsd1/somefilesystem` and check a file on this 
filesystem's snapshot with for example 
`less /external/fbsd1/somefilesystem/.zfs/snapshot/zfs-auto-snap_hourly-2022-03-19-20h00/somefile`, 
you'll see the contents of that file if it existed 
in `zroot/somefilesystem` at that time.  

```
$ sudo geli attach /dev/gpt/external
Enter passphrase: 
```

```
$ geli status
            Name  Status  Components
gpt/external.eli  ACTIVE  gpt/external
```

```
$ sudo zpool import
   pool: external
     id: 12345678901234567890
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        external            ONLINE
          gpt/external.eli  ONLINE
```

```
$ sudo zpool import external
```
 
```
$ sudo zpool import
no pools available to import
```

```
$ zfs list | grep external
external                     1.19T  11.1T     1.02T  /external
external/fbsd1                172G  11.1T      172K  /external/fbsd1
external/fbsd1/zroot          172G  11.1T      152K  /external/fbsd1/zroot
[...]
```

```
$ zpool list | grep external
external  12.7T  1.19T  11.5T      -       -    0%    9%  1.00x    ONLINE  -
``` 

``` 
$ df -hT | grep external
external                         zfs   12T   1.0T  11T  8%  /external
external/fbsd1                   zfs   11T   172K  11T  0%  /external/fbsd1
external/fbsd1/zroot             zfs   11T   152K  11T  0%  /external/fbsd1/zroot
external/fbsd1/zroot/usr/ports   zfs   11T    96K  11T  0%  /external/fbsd1/zroot/usr/ports
[...]
```

```
$ ls -alh /external/fbsd1/zroot/usr/home/
total 34
drwxr-xr-x   3 root   wheel     3B Dec 26  2021 .
drwxr-xr-x   5 root   wheel     5B Mar 18 19:26 ..
drwxr-xr-x  42 dusko  dusko   112B Mar 19 20:36 dusko
```

```
$ ls -alh /external/fbsd1/zroot/usr/home/.zfs/
total 1
dr-xr-xr-x+  3 root  wheel     3B Dec 24  2021 .
drwxr-xr-x   3 root  wheel     3B Dec 26  2021 ..
dr-xr-xr-x+ 28 root  wheel    28B Mar 19 19:54 snapshot
```

```
$ ls -alh /external/fbsd1/zroot/usr/home/.zfs/snapshot/
total 13
dr-xr-xr-x+ 28 root wheel 28B Mar 19 19:54 .
dr-xr-xr-x+  3 root wheel  3B Dec 24  2021 ..
drwxr-xr-x   3 root wheel  3B Dec 26  2021 zfs-auto-snap_daily-2022-03-19-20h07
drwxr-xr-x   3 root wheel  3B Dec 26  2021 zfs-auto-snap_frequent-2022-03-19-19h45
[...]
drwxr-xr-x   3 root wheel  3B Dec 26  2021 zfs-auto-snap_hourly-2022-03-19-20h00
[...]
```


Unmount `external/fbsd1` after you're done with it.

```
$ sudo zpool import
no pools available to import
```

```
$ zpool list | grep external
external  12.7T  1.19T  11.5T      -       -    0%    9%  1.00x    ONLINE  -
```

```
$ sudo zpool export external
``` 

``` 
$ zpool list | grep external
```

```
$ sudo zpool import
   pool: external
     id: 12345678901234567890
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        external            ONLINE
          gpt/external.eli  ONLINE
```

```
$ zfs list | grep external
```

```
$ df -hT | grep external
```

```
$ geli status
            Name  Status  Components
gpt/external.eli  ACTIVE  gpt/external
```

```
$ sudo geli detach /dev/gpt/external
``` 

``` 
$ geli status
```


## Add a Backup Directory for a New Host that You Don't Need to Snapshot Automatically

Assumptions:

* The backup drive: 
  - is big enough for backing up another computer;
  - stays plugged into the first computer;
  - is a destination for archiving regular backups from the second computer, and snapshotting those backups is not necessary.
* The second computer's name: host2.mydomain.com.

```
$ sudo mkdir /external/host2 
```

```
$ sudo chown dusko /external/host2/ 
```

```
$ cd /external/host2/
```

```
$ scp dusko@host2.mydomain.com:/backup/stuff.tar.gz .
```

---

## Footnotes

[1] For details, refer to:    
* FreeBSD Handbook, Section [3.5 Directory Structure](https://docs.freebsd.org/en/books/handbook/book/#dirstructure) (Retrieved on Mar 19, 2022)  
* `hier(7)` manpage   
* man page for `bsdinstall(8)`    

From the man page for `bsdinstall(8)`: 

```
ZFSBOOT_BEROOT_NAME      Name for the boot environment parent dataset.
                         This is a non-mountable dataset meant to be a
                         parent dataset where different boot environment
                         are going to be created.  Default: "ROOT"

[...]

ZFSBOOT_BOOTFS_NAME      Name for the primary boot environment, which
                         will be the default boot environment for the
                         system.  Default: "default"

[...]

ZFSBOOT_DATASETS         ZFS datasets to be created on the root zpool, it
                         requires the following datasets: /tmp, /var/tmp,
                         /$ZFSBOOT_BEROOT_NAME/$ZFSBOOT_BOOTFS_NAME.  See
                         ZFS DATASETS for more information about who to
                         write this variable and to take a look into the
                         default value of it.

[...]

zfsboot                  Provides a ZFS-only automatic interactive disk
                         partitioner.  Creates a single zpool with
                         separate datasets for /tmp, /usr, /usr/home,
                         /usr/ports, /usr/src, and /var.  Optionally can
                         set up geli(8) to encrypt the disk.

[...]

ZFS DATASETS
  The zfsboot partitioning takes the ZFSBOOT_DATASETS variable to create
  the datasets on the base system.  This variable can get pretty huge if
  the pool contains a lot of datasets.  The default value of the
  ZFSBOOT_DATASETS looks like this:

        # DATASET       OPTIONS (comma or space separated; or both)

        # Boot Environment [BE] root and default boot dataset
        /$ZFSBOOT_BEROOT_NAME                           mountpoint=none
        /$ZFSBOOT_BEROOT_NAME/$ZFSBOOT_BOOTFS_NAME      mountpoint=/

        # Compress /tmp, allow exec but not setuid
        /tmp            mountpoint=/tmp,exec=on,setuid=off

        # Do not mount /usr so that 'base' files go to the BEROOT
        /usr            mountpoint=/usr,canmount=off

        # Home directories separated so they are common to all BEs
        /usr/home       # NB: /home is a symlink to /usr/home

        # Ports tree
        /usr/ports      setuid=off

        # Source tree (compressed)
        /usr/src

        # Create /var and friends
        /var            mountpoint=/var,canmount=off
        /var/audit      exec=off,setuid=off
        /var/crash      exec=off,setuid=off
        /var/log        exec=off,setuid=off
        /var/mail       atime=on
        /var/tmp        setuid=off

The first column if the dataset to be created on the top of the
ZFSBOOT_POOL_NAME and the rest of the columns are the options to be set
on each dataset.  The options must be written on a coma or space
separated list, or both.  And everything behind a pound/hash character is
ignored as a comment.
```


[2] From the man page for `zfs(8)`: 

```
DESCRIPTION
     The zfs command configures ZFS datasets within a ZFS storage pool, as
     described in zpool(8).  A dataset is identified by a unique path within
     the ZFS namespace.  For example:
             pool/{filesystem,volume,snapshot}
  
     where the maximum length of a dataset name is MAXNAMELEN (256B) and the
     maximum amount of nesting allowed in a path is 50 levels deep.

     A dataset can be one of the following:
  
           file system  Can be mounted within the standard system namespace
                        and behaves like other file systems.  While ZFS file
                        systems are designed to be POSIX-compliant, known
                        issues exist that prevent compliance in some cases.
                        Applications that depend on standards conformance
                        might fail due to non-standard behavior when checking
                        file system free space.
  
           volume       A logical volume exported as a raw or block device.
                        This type of dataset should only be used when a block
                        device is required.  File systems are typically used
                        in most environments.
  
           snapshot     A read-only version of a file system or volume at a
                        given point in time.  It is specified as
                        filesystem@name or volume@name.

           bookmark     Much like a snapshot, but without the hold on on-disk
                        data.  It can be used as the source of a send (but not
                        for a receive).  It is specified as filesystem#name or
                        volume#name.
  
    See zfsconcepts(7) for details.
```


[3] From the man page for `zxfer(8)`:

> Note that at present, the usage of spaces in zfs(8) filesystem names is
> NOT supported. There is no plan to support it without someone else doing
> the coding or a good funding proposal coming my way.

---

### References

* [FreeBSD ZFS snapshots with zfstools](https://mwl.io/archives/2140) 
(Posted on Aug 6, 2014) (Retrieved on Mar 19, 2022)  

* [GELI Encrypted USB Backup of ZFS Filesystems in FreeBSD 13](https://thornton2.com/unix/freebsd/geli-encrypted-usb-backup.html) (Posted on Dec 22, 2021 - edited on Dec 23, 2021) (Retrieved on Mar 19, 2022)  

* [Back Up ZFS to a Removable Drive Using zxfer](https://www.ccammack.com/posts/back-up-zfs-to-a-removable-drive-using-zxfer/)
(Posted on Mar 30, 2020) (Retrieved on Mar 19, 2022)  
