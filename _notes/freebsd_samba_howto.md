---
layout: post
title: "FreeBSD - Samba Howto"
---

```
$ kldstat | grep smb
13    1 0xffffffff8302e000     3250 ichsmb.ko
14    1 0xffffffff83032000     2178 smbus.ko
```
 
```
$ sudo kldload smbfs
```

```
$ kldstat | grep smb
13    1 0xffffffff8302e000     3250 ichsmb.ko
14    1 0xffffffff83032000     2178 smbus.ko
26    1 0xffffffff83062000    18638 smbfs.ko
```

```
$ smbclient --list boxon --user=dusko
Password for [WORKGROUP\dusko]:

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        D$              Disk      Default share
        data$           Disk      
---- snip ----
        group-shared$   Disk      
---- snip ----
        SYSVOL          Disk      Logon server share 
        User Data$      Disk      
SMB1 disabled -- no workgroup available
```

```
$ smbclient '//boxon/group-shared$' --user=dusko
Password for [WORKGROUP\dusko]:
Try "help" to get a list of possible commands.
smb: \> 
smb: \> dir
  .                                   D        0  Mon Mar 25 11:40:27 2024
  ..                                  D        0  Mon Mar 25 11:40:27 2024
---- snip ----
  Documentation                       D        0  Mon Apr 24 20:03:10 2023
  Group Specific Items                D        0  Tue Sep 27 14:20:29 2022
---- snip ----

                1464838655 blocks of size 4096. 722254649 blocks available
smb: \> 
```

