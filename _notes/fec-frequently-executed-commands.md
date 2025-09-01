---
layout: page
title: "FEC - Frequently Executed Commands [WIP]"
---

```
$ exec xinit  # OR: exec startx
```

On laptop:

```
$ ./mirror_ext_monitor_xrandr.sh
```

```
$ cat mirror_ext_monitor_xrandr.sh 
#!/bin/sh

# Based on 
#   <https://wiki.archlinux.org/title/Xrandr>

intern=eDP-1
extern=HDMI-1 

xrandr --output "$intern" --primary --auto --output "$extern" --same-as "$intern" --auto
```

```
$ dmesg | tail -11
ugen0.5: <Kingston DT microDuo 3C> at usbus0
umass1 on uhub0
umass1: <Kingston DT microDuo 3C, class 0/0, rev 3.10/1.10, addr 13> on usbus0
umass1:  SCSI over Bulk-Only; quirks = 0x8100
umass1:9:1: Attached to scbus9
da1 at umass-sim1 bus 1 scbus9 target 0 lun 0
da1: <Kingston DT microDuo 3C PMAP> Removable Direct Access SPC-4 SCSI device
da1: Serial Number 408D................071A
da1: 400.000MB/s transfers
da1: 59136MB (121110528 512 byte sectors)
da1: quirks=0x2<NO_6_BYTE>

$ sudo mount /dev/da1 /mnt/usbflashdrive
 
$ df -hT
Filesystem           Type   Size    Used   Avail Capacity  Mounted on
zroot/ROOT/default   zfs    329G    100G    230G    30%    /
[ . . . ]
/dev/da1             ufs     56G     16G     35G    32%    /mnt/usbflashdrive
```

```
$ fc-match 0xProto
0xProto-Regular.otf: "0xProto" "Regular"
 
$ xterm -fa 0xProto -fs 14 &

$ mutt -F /mnt/usbflashdrive/mydotfiles/mutt-imap-ubc-chemistry/.muttrc.chem.ubc.ca.imap

$ mail
$ sudo mail

$ claws-mail 
$ thunderbird
$ firefox
```

