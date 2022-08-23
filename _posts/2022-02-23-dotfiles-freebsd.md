---
layout: post
title: "Dotfiles"
date: 2022-02-23 19:14:33 -0700 
categories: dotfiles freebsd
---

OS: FreeBSD 13     
Shell: csh   


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
pf_enable="YES"
gateway_enable="YES"
dnsmasq_enable="YES"
```

```
% cat /etc/rc.conf.wireless
zfs_enable="YES"
dumpdev="AUTO"
powerd_enable="YES"
ifconfig_ue0="DHCP"
defaultrouter="192.168.1.254"
kld_list="i915kms"
hostname="fbsd1.home.arpa"
vm_enable="YES"
vm_dir="zfs:zroot/vm"
pf_enable="YES"
gateway_enable="YES"
dnsmasq_enable="YES"
wlans_iwm0="wlan0"
ifconfig_wlan0="wpa DHCP"
```

--- 

## X11 aka X Window System - My Dotfiles

From the man page for X(7):

```
The X.Org Foundation requests that the following names be used when
referring to this software:

                                   X
                            X Window System
                             X Version 11
                      X Window System, Version 11
                                  X11
```




### X11 Global Settings 

```
% grep -n Path /var/log/Xorg.0.log
28:[1065569.793] (==) FontPath set to:
36:[1065569.793] (==) ModulePath set to "/usr/local/lib/xorg/modules"
```

```
% grep -n FontPath /var/log/Xorg.0.log
28:[1065569.793] (==) FontPath set to:
```

```
% sed -n 28,35p /var/log/Xorg.0.log
[1065569.793] (==) FontPath set to:
        /usr/local/share/fonts/misc/,
        /usr/local/share/fonts/TTF/,
        /usr/local/share/fonts/OTF/,
        /usr/local/share/fonts/Type1/,
        /usr/local/share/fonts/100dpi/,
        /usr/local/share/fonts/75dpi/,
        catalogue:/usr/local/etc/X11/fontpath.d
```

```
% grep -n ModulePath /var/log/Xorg.0.log
36:[1065569.793] (==) ModulePath set to "/usr/local/lib/xorg/modules"
```


#### Directory:  /usr/local/etc/X11/ 

```
% ls -alh /usr/local/etc/X11/ | wc -l
       6
 
% ls -lh /usr/local/etc/X11/ | wc -l
       4
```


```
% ls -lh /usr/local/etc/X11/
total 2
drwxr-xr-x  2 root  wheel     4B Oct 18  2021 fontpath.d
drwxr-xr-x  3 root  wheel     4B Aug 17  2021 xinit
drwxr-xr-x  2 root  wheel     6B Jan  4  2022 xorg.conf.d
```

```
% ls -alh /usr/local/etc/X11/fontpath.d/ | wc -l
       5
 
% ls -lh /usr/local/etc/X11/fontpath.d/ | wc -l
       3
```

```
% ls -lh /usr/local/etc/X11/fontpath.d/ 
total 1
lrwxr-xr-x  1 root  wheel    27B Sep 25  2021 ipamjm:pri=60 -> ../../../share/fonts/ipamjm
lrwxr-xr-x  1 root  wheel    29B Jul 25  2021 vlgothic:pri=60 -> ../../../share/fonts/vlgothic
```

```
% ls -alh /usr/local/etc/X11/xinit/ | wc -l
       5
 
% ls -lh /usr/local/etc/X11/xinit/ | wc -l
       3
```

```
% ls -lh /usr/local/etc/X11/xinit/ 
total 5
-rw-r--r--  1 root  wheel   780B Jul 24  2021 xinitrc
drwxr-xr-x  2 root  wheel     3B Feb  3 11:03 xinitrc.d
```

```
% wc -l /usr/local/etc/X11/xinit/xinitrc
      56 /usr/local/etc/X11/xinit/xinitrc
```

```
% sed '/^[[:space:]]*$/d' /usr/local/etc/X11/xinit/xinitrc | grep -v \# | wc -l
      27
```


```
% sed '/^[[:space:]]*$/d' /usr/local/etc/X11/xinit/xinitrc | grep -v \#
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/usr/local/etc/X11/xinit/.Xresources
sysmodmap=/usr/local/etc/X11/xinit/.Xmodmap
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi
if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi
if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi
if [ -d /usr/local/etc/X11/xinit/xinitrc.d ] ; then
        for f in /usr/local/etc/X11/xinit/xinitrc.d/?*.sh ; do
                [ -x "$f" ] && . "$f"
        done
        unset f
fi
twm &
xclock -geometry 50x50-1+1 &
xterm -geometry 80x50+494+51 &
xterm -geometry 80x20+494-0 &
exec xterm -geometry 80x66+0+0 -name login
```

```
% ls -lh /usr/local/etc/X11/xinit/.Xmodmap
ls: /usr/local/etc/X11/xinit/.Xmodmap: No such file or directory
```

```
% ls -ld /usr/local/etc/X11/xinit/xinitrc.d
drwxr-xr-x  2 root  wheel  3 Feb  3 11:03 /usr/local/etc/X11/xinit/xinitrc.d
```

```
% ls -alh /usr/local/etc/X11/xinit/xinitrc.d/ | wc -l
       4

% ls -lh /usr/local/etc/X11/xinit/xinitrc.d/ | wc -l
       2
```

```
% ls -lh /usr/local/etc/X11/xinit/xinitrc.d/
total 5
-r-xr-xr-x  1 root  wheel   1.0K Jan 29  2022 90-consolekit
```


#### Directory:  /usr/local/share/X11/

```
% ls -alh /usr/local/share/X11/ | wc -l
       7
 
% ls -lh /usr/local/share/X11/ | wc -l
       5
```

```
% ls -alh /usr/local/etc/X11/xorg.conf.d/ | wc -l
       7

% ls -lh /usr/local/etc/X11/xorg.conf.d/ | wc -l
       5
```

```
% ls -lh /usr/local/etc/X11/xorg.conf.d/ 
total 14
-rw-r--r--  1 root  wheel   404B Jan  4  2022 card.conf
-rw-r--r--  1 root  wheel   140B Jan  4  2022 layout.conf
-rw-r--r--  1 root  wheel    48B Aug 18  2021 modules.conf
-rw-r--r--  1 root  wheel   1.0K Jan  4  2022 monitors.conf
```

```
% ls -lh /usr/local/share/X11/ 
total 18
drwxr-xr-x  2 root  wheel    18B Sep 16  2021 app-defaults
drwxr-xr-x  2 root  wheel     3B Aug 17  2021 twm
drwxr-xr-x  8 root  wheel     9B Feb  3 11:02 xkb
drwxr-xr-x  2 root  wheel     5B Feb  3 11:03 xorg.conf.d
```

```
% ls -alh /usr/local/share/X11/xorg.conf.d/ | wc -l
       6
 
% ls -lh /usr/local/share/X11/xorg.conf.d/ | wc -l
       4
```

```
% ls -lh /usr/local/share/X11/xorg.conf.d/ 
total 14
-rw-r--r--  1 root  wheel   1.3K Jan 26  2022 10-quirks.conf
-rw-r--r--  1 root  wheel   152B Jan 26  2022 20-evdev-kbd.conf
-rw-r--r--  1 root  wheel   1.4K Aug 13  2021 40-libinput.conf
```


#### Directory:  /usr/local/etc/fonts/ 

```
% ls -ld /usr/local/etc/fonts/
drwxr-xr-x  4 root  wheel  7 Feb  3  2022 /usr/local/etc/fonts/

% ls -alh /usr/local/etc/fonts/ | wc -l
       8

% ls -lh /usr/local/etc/fonts/ | wc -l
       6
```

```
% ls -lh /usr/local/etc/fonts/
total 79
drwxr-xr-x  2 root  wheel    51B Feb  3  2022 conf.avail
drwxr-xr-x  2 root  wheel    33B Feb  3  2022 conf.d
-rw-r--r--  1 root  wheel   2.6K Jan 21  2022 fonts.conf
-rw-r--r--  1 root  wheel   2.6K Jan 21  2022 fonts.conf.sample
-rw-r--r--  1 root  wheel   8.1K Dec  3  2020 fonts.dtd
```


### X11 User Settings 


In my home directory:

```
% ls ~/.xinitrc
/home/dusko/.xinitrc
```

Create a symlink from `~/.xinitrc` to `~/.xsession`:

```
% ln -s ~/.xinitrc ~/.xsession
```

```
% file ~/.xsession
/home/dusko/.xsession: symbolic link to /home/dusko/.xinitrc
```

```
% ls -lh $HOME/.Xresources
-rw-r--r--  1 dusko  dusko   5.2K Jan 26 11:44 /home/dusko/.Xresources
```

```
% ls -lh $HOME/.Xmodmap
ls: /home/dusko/.Xmodmap: No such file or directory
```

```
% ls -lh /usr/local/etc/X11/xinit/.Xresources
ls: /usr/local/etc/X11/xinit/.Xresources: No such file or directory
```


### xset(1) - User Preference Utility for X

For status information:


```
% xset -q | wc -l
      27

% xset q | wc -l
      27
```

```
% xset -q 
Keyboard Control:
  auto repeat:  on    key click percent:  0    LED mask:  00000000
  XKB indicators:
    00: Caps Lock:   off    01: Num Lock:    off    02: Scroll Lock: off
    03: Compose:     off    04: Kana:        off    05: Sleep:       off
    06: Suspend:     off    07: Mute:        off    08: Misc:        off
    09: Mail:        off    10: Charging:    off    11: Shift Lock:  off
    12: Group 2:     off    13: Mouse Keys:  off
  auto repeat delay:  660    repeat rate:  25
  auto repeating keys:  00ffffffdffffbbf
                        fadfffefffedffff
                        9fffffffffffffff
                        fff7ffffffffffff
  bell percent:  0    bell pitch:  400    bell duration:  100
Pointer Control:
  acceleration:  2/1    threshold:  4
Screen Saver:
  prefer blanking:  yes    allow exposures:  yes
  timeout:  600    cycle:  600
Colors:
  default colormap:  0x22    BlackPixel:  0x0    WhitePixel:  0xffffff
Font Path:
  /usr/local/share/fonts/misc/,/usr/local/share/fonts/TTF/,/usr/local/share/fonts/OTF/,/usr/local/share/fonts/Type1/,/usr/local/share/fonts/100dpi/,/usr/local/share/fonts/75dpi/,catalogue:/usr/local/etc/X11/fontpath.d,built-ins,/usr/local/share/fonts/100dpi,/usr/local/share/fonts/75dpi,/usr/local/share/fonts/adobe-cmaps,/usr/local/share/fonts/bitstream-vera,/usr/local/share/fonts/Caladea,/usr/local/share/fonts/cantarell,/usr/local/share/fonts/Carlito,/usr/local/share/fonts/ChromeOS,/usr/local/share/fonts/comic-neue,/usr/local/share/fonts/cyrillic,/usr/local/share/fonts/dejavu,/usr/local/share/fonts/GentiumBasic,/usr/local/share/fonts/gnu-unifont,/usr/local/share/fonts/ipamjm,/usr/local/share/fonts/jmk-x11-fonts,/usr/local/share/fonts/Liberation,/usr/local/share/fonts/LinLibertineG,/usr/local/share/fonts/misc,/usr/local/share/fonts/Monoid,/usr/local/share/fonts/nanum-coding-ttf,/usr/local/share/fonts/nanum-ttf,/usr/local/share/fonts/noto,/usr/local/share/fonts/OTF,/usr/local/share/fonts/SourceCodePro,/usr/local/share/fonts/SourceHanSans,/usr/local/share/fonts/SourceHanSansK,/usr/local/share/fonts/SourceHanSansSC,/usr/local/share/fonts/SourceHanSansTC,/usr/local/share/fonts/SourceSansPro,/usr/local/share/fonts/symbola,/usr/local/share/fonts/terminus-font,/usr/local/share/fonts/TerminusTTF,/usr/local/share/fonts/TTF,/usr/local/share/fonts/twemoji-color-font-ttf,/usr/local/share/fonts/Type1,/usr/local/share/fonts/uw-ttyp0,/usr/local/share/fonts/vlgothic,/usr/local/share/fonts/wqy,/usr/home/dusko/.fonts/knxt
DPMS (Energy Star):
  Standby: 600    Suspend: 600    Off: 600
  DPMS is Enabled
  Monitor is On
```


### Starting X

```
% exec startx
```

Or:

```
% exec xinit
```

--- 

## Mutt - My Dotfiles

### Mutt MUA (Mail User Agent)*


[*] aka Email Client or Mail Reader


Starting mutt with my `muttrc` configuration file:

```
$ mutt -F /mnt/usbflashdrive/mydotfiles/mutt-imap/.muttrc.example.com.imap
```

**Note 1:**    
Per these excerpts from the `muttrc` file:

```
set mailcap_path = /mnt/usbflashdrive/mydotfiles/mutt-common-files/mailcap

set alias_file = /mnt/usbflashdrive/mydotfiles/mutt-common-files/muttaliases
source /mnt/usbflashdrive/mydotfiles/mutt-common-files/muttaliases

set query_command="/mnt/usbflashdrive/mydotfiles/mutt-common-files/muttldap.pl %s"

macro index \el "!/mnt/usbflashdrive/mydotfiles/mutt-common-files/muttalias.sh"
```

you'll need the following additional files: `.muttrc.example.com.imap`, `muttaliases`, `muttldap.pl`, `muttalias.sh`, `mailcap`.     


The content of those files for download (you'll need to adjust them for your environment):

`.muttrc.example.com.imap` file:  [.muttrc.example.com.imap]({{ site.url }}/assets/txt/dot.muttrc) 

`muttaliases` file: [muttaliases]({{ site.url }}/assets/txt/muttaliases)

`muttldap.pl` file: [muttldap.pl]({{ site.url }}/assets/txt/muttldap.pl)

`muttalias.sh` file: [muttalias.sh]({{ site.url }}/assets/txt/muttalias.sh)

`mailcap` file: [mailcap]({{ site.url }}/assets/txt/mailcap)


**Note 2:**    
As per another excerpt from the `muttrc` file:

```
set header_cache = /mnt/usbflashdrive/muttcache/example.com.dusko/cache
set message_cachedir = /mnt/usbflashdrive/muttcache/example.com.dusko/cache/bodies
```

you'll need to create a `muttcache` directory structure.

In my case:

```
% mkdir -p /mnt/usbflashdrive/muttcache/example.com.dusko/cache/bodies
```

which creates four directories inside `/mnt/usbflashdrive` directory:

`/mnt/usbflashdrive/muttcache/`   
`/mnt/usbflashdrive/muttcache/example.com.dusko/`    
`/mnt/usbflashdrive/muttcache/example.com.dusko/cache`   
`/mnt/usbflashdrive/muttcache/example.com.dusko/cache/bodies`    


**Note 3:**    
Message bodies are in `bodies` **directory**:     
`/mnt/usbflashdrive/muttcache/example.com.dusko/cache/bodies`    

Message headers are in `headers` **file**:     
`/mnt/usbflashdrive/muttcache/example.com.dusko/cache/headers`    


**Note 4:**    
As of time of this writing, I'm not using 
`/mnt/usbflashdrive/mydotfiles/mutt-common-files/gpg.rc` so I'm not listing its content.   

---

