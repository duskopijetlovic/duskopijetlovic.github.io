---
layout: post
title: "How to Setup an External USB Hard Drive as a ZFS Backup Disk in FreeBSD"
date: 2022-03-19 10:13:21 -0700 
categories: zfs freebsd snapshot backup 
---

* OS:  FreeBSD 13.0   
* Shell:  csh  
* External hard disk drive: WD (WesternDigital) Easystore 14TB USB 3.0 Desktop External Hard Drive, Model:  [WDBAMA0140HBK-NESE](https://www.bestbuy.ca/en-ca/product/wd-easystore-14tb-usb-3-0-desktop-external-hard-drive-wdbama0140hbk-nese-black-only-at-best-buy/14936770)
  * Possibly, a variation of a model [WDBAMA0140HBK-NESN](https://www.westerndigital.com/products/portable-drives/wd-easystore-desktop-usb-3-0-hdd#WDBAMA0140HBK-NESN)    

---

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
$ gpart show | grep -w da0
```

```
$ glabel list | grep da0
```

```
$ glabel list da0
glabel: Class 'LABEL' does not have an instance named 'da0'.
```

This is a brand new disk so `gpart destroy` complains: 

```
$ sudo gpart destroy -F da0
gpart: arg0 'da0': Invalid argument
```

Otherwise, if the disk was previously configured and had a partitioning 
scheme on it:

```
$ sudo gpart destroy -F da0
da0 destroyed
```


```
$ sudo gpart add -a 1m -l external -t freebsd-zfs "da0"
gpart: No partitioning scheme found on geom da0. Create one first using 'gpart create'.
```

Create the partition table with **gpt** partitioning scheme (on disk `da0`). 

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


Create a new ZFS partition with the GPT label **external**.

```
$ sudo gpart add -a 1m -l external -t freebsd-zfs "da0"
da0p1 added
```

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

```
$ geli status
geli: Command 'status' not available; try 'load' first.

$ geli load
geli: cannot load geom_eli: Operation not permitted

$ sudo geli status
Password:
geli: Command 'status' not available; try 'load' first.

$ sudo geli load
```

```
$ geli status
```

```
$ sudo geli attach /dev/gpt/external
Enter passphrase:
```


```
$ geli status
            Name  Status  Components
gpt/external.eli  ACTIVE  gpt/external
```

Create a new zpool in the geli partition called **external**. 

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

```
$ zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zroot   928G   189G   739G        -         -     6%    20%  1.00x    ONLINE  -
```

```
$ sudo zpool create external gpt/external.eli
```

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

```
$ sudo zpool export external
```

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
$ sudo geli detach /dev/gpt/external
```

```
$ geli status
```

Disconnect the external drive from the system.

Connect one end of the USB cable to your system and the other end to 
the hard drive. 


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

```
$ zfs list -H | \
cut -f1 | \
awk '/[[:space:]]/{printf("Error! Dataset name contains spaces: %s\n",$0)}'
```

```
$ sudo pkg install zxfer 
```

```
$ set exclude="com.sun:auto-snapshot"
$ set exclude="${exclude},com.sun:auto-snapshot:015m"
$ set exclude="${exclude},objsetid"
$ set exclude="${exclude},keyformat"
$ set exclude="${exclude},keylocation"
$ set exclude="${exclude},pbkdf2iters"
```

```
$ printf %s\\n "$exclude"
com.sun:auto-snapshot,com.sun:auto-snapshot:015m,objsetid,keyformat,keylocation,pbkdf2iters
```

```
$ sudo zxfer -dFkPv -I ${exclude} -R zroot external/fbsd1
---- snip ----
```

In this example, it took around five minutes to complete. 


```
$ ls -alh /external/fbsd1/
total 34
drwxr-xr-x  3 root  wheel     4B Mar 19 16:53 .
drwxr-xr-x  3 root  wheel     3B Mar 19 15:59 ..
-rw-r--r--  1 root  wheel    28K Mar 19 16:53 .zxfer_backup_info.zroot
drwxr-xr-x  7 root  wheel     7B Mar 19 16:53 zroot
```

```
$ ls -alh /external/fbsd1/zroot/
total 12
drwxr-xr-x  7 root  wheel     7B Mar 19 16:53 .
drwxr-xr-x  3 root  wheel     4B Mar 19 16:53 ..
drwxr-xr-x  2 root  wheel     2B Mar 19 16:49 ROOT
drwxr-xr-x  2 root  wheel     2B Mar 19 16:53 tmp
drwxr-xr-x  5 root  wheel     5B Mar 19 16:53 usr
drwxr-xr-x  7 root  wheel     7B Mar 19 16:53 var
drwxr-xr-x  3 root  wheel     3B Mar 19 16:53 vm
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

```
$ printf %s\\n Testing > /external/fbsd1/test
/external/fbsd1/test: Permission denied.

$ printf %s\\n Testing | sudo tee -a /external/fbsd1/test
Testing

$ ls -lh /external/fbsd1/test
-rw-r--r--  1 root  wheel     8B Mar 19 17:13 /external/fbsd1/test

$ date
Sat 19 Mar 2022 17:13:10 PDT

$ cat /external/fbsd1/test
Testing

$ sudo rm -i /external/fbsd1/test
remove /external/fbsd1/test? y

$ ls -lh /external/fbsd1/test
ls: /external/fbsd1/test: No such file or directory
```

```
$ sudo zpool scrub external
```

```
$ zpool status external
  pool: external
 state: ONLINE
  scan: scrub in progress since Sat Mar 19 18:08:51 2022
        37.7G scanned at 1.45G/s, 5.13G issued at 202M/s, 37.7G total
        0B repaired, 13.60% done, 00:02:45 to go
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


```
$ zpool status external
  pool: external
 state: ONLINE
  scan: scrub repaired 0B in 00:03:13 with 0 errors on Sat Mar 19 18:12:04 2022
config:

        NAME                STATE     READ WRITE CKSUM
        external            ONLINE       0     0     0
          gpt/external.eli  ONLINE       0     0     0

errors: No known data errors
```

---

