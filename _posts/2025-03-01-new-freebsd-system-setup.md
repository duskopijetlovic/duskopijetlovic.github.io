---
layout: post
title: "FreeBSD New System Setup"
date: 2025-03-01 23:04:52 -0700 
categories: boot dotfiles howto freebsd config sysadmin  
---

**[TODO]:** Add *See ( footnote_number )* notes. 

```
# pkg bootstrap
# pkg update
```

```
# cat /etc/rc.conf
zfs_enable="YES"
ifconfig_ue0="DHCP"
defaultrouter="192.168.1.254"
sshd_enable="YES"
```

```
# bectl list
BE      Active Mountpoint Space Created
default NR     /          655M  2025-03-01 17:42
```

```
# freebsd-update fetch
# freebsd-update install
```

```
# bectl list
BE                             Active Mountpoint Space Created
14.2-RELEASE_2025-03-01_190330 -      -          4.20M 2025-03-01 19:03
default                        NR     /          675M  2025-03-01 17:42
```

```
# zpool set cachefile=/etc/zfs/zpool.cache zroot
```

```
# reboot
```

`zdb(8)` is now not complaining with "cannot open /etc/zfs/zpool.cache: No such file or directory".

```
# zdb

zroot:
    version: 5000
    name: 'zroot'
    state: 0
---- snip ----
```

```
# freebsd-version
14.2-RELEASE-p2
```

```
# bectl create 14.2-p2-pre-xorg
```

```
# bectl list
BE                             Active Mountpoint Space Created
14.2-RELEASE_2025-03-01_190330 -      -          5.01M 2025-03-01 19:03
14.2-p2-pre-xorg               -      -          1K    2025-03-01 19:25
default                        NR     /          716M  2025-03-01 17:42
```

```
# pkg install xorg
```

See [5]. 

To create the `locate(1)` database `/var/db/locate.database`, run:

```
# /etc/periodic/weekly/310.locate
```

```
# adduser
### Add your user here
### The  username  for my user is  dusko
```

```
# pw groupmod video -m dusko
```

### Graphics Driver

```
# pciconf -lv | grep -B4 VGA
root@:~ # pciconf -lv | grep -B4 VGA
vgapci0@pci0:0:2:0:     class=0x030000 rev=0x0c hdr=0x00 vendor=0x8086 device=0x
46a6 subvendor=0x17aa subdevice=0x22ee
    vendor     = 'Intel Corporation'
    device     = 'Alder Lake-P GT2 [Iris Xe Graphics]'
    class      = display
    subclass   = VGA
```

Intel Graphics refers to the class of graphics chips that are integrated on the same die as an Intel CPU.
The graphics/drm-kmod package, [https://cgit.freebsd.org/ports/tree/graphics/drm-kmod/](https://cgit.freebsd.org/ports/tree/graphics/drm-kmod/), indirectly provides a range of kernel modules for use with Intel Graphics cards.

The Intel driver can be installed by executing the following command: ```# pkg install drm-kmod```.


However, for **14.2-RELEASE**, installing **drm-kmod** will not work so you have to apply  "drm-kmod Graphics Fix".

```
# bectl create 14.2-p2-pre-drm-kmod-fix
```

```
# bectl list
BE                             Active Mountpoint Space Created
14.2-RELEASE_2025-03-01_190330 -      -          5.01M 2025-03-01 19:03
14.2-p2-pre-drm-kmod-fix       -      -          1K    2025-03-01 20:50
14.2-p2-pre-xorg               -      -          222K  2025-03-01 19:25
default                        NR     /          2.02G 2025-03-01 17:42
```

```
# pkg install git
```

From:
[[Solved] FreeBSD 14.2 Graphics Fix](https://forums.freebsd.org/threads/freebsd-14-2-graphics-fix.96365/)
    and
[Bug 283123 - loading i915kms causes black screen (as per open issue)](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=283123):

```
# pkg remove drm-kmod
# pkg clean
# pkg autoremove
# ls /usr/
# ls /usr/src/
# ls /usr/ports/
# git clone --depth=1 --branch releng/14.2 https://git.FreeBSD.org/src.git /usr/src
# git clone --depth 1 https://git.FreeBSD.org/ports.git /usr/ports
# cd /usr/ports/
# git -C /usr/ports pull
# make fetchindex
# make search name=drm-kmod
# cd /usr/ports/graphics/drm-kmod
# make describe
# MAKE_JOBS_UNSAFE=yes
# make run-depends
# make install
# make clean
# cd /tmp
```

See [4].

```
# kldload i915kms
```

To configure the Intel driver in a configuration file [6]:

```
# cat << EOF > /usr/local/etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
    Identifier "Intel Iris Xe Card"
    Driver "intel"
EndSection
EOF
```

Try starting X (X Window System), aka X11 or Xorg.

```
# startx 
```

Or:

```
# xinit 
```

If the Intel driver is not working, then try using *modesetting*:

```
# cat /usr/local/etc/X11/xorg.conf.d/20-modesetting.conf
Section "Device"
    Identifier "Modesetting Intel Iris Xe"
    Driver "modesetting"
EndSection
```

```
# printf %s\\n 'kld_list="i915kms"' >> /etc/rc.conf 
```

```
# printf %s\\n 'hostname="tp14s.home.arpa"' >> /etc/rc.conf 
```


To configure the touchpad:

```
# cat << EOF > /usr/local/etc/X11/xorg.conf.d/30-touchpad.conf
Section "InputClass"
    Identifier "Touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "on"
EndSection
EOF
```

```
# reboot
```

See [7]:

```
# cp -i /usr/share/skel/* /usr/home/dusko/

# cd /usr/home/dusko/
# mv dot.cshrc .cshrc
# mv dot.login .login
# mv dot.login_conf .login_conf
# mv dot.mail_aliases .mail_aliases
# mv dot.mailrc .mailrc
# mv dot.profile .profile
# mv dot.shrc .shrc

# chown -R dusko /usr/home/dusko
```

```
# bectl create 14.2-p2-pre-FVWM
```

```
# bectl list
BE                             Active Mountpoint Space Created
14.2-RELEASE_2025-03-01_190330 -      -          5.01M 2025-03-01 19:03
14.2-p2-pre-FVWM               -      -          1K    2025-03-01 22:27
14.2-p2-pre-drm-kmod-fix       -      -          3.21M 2025-03-01 20:50
14.2-p2-pre-xorg               -      -          222K  2025-03-01 19:25
default                        NR     /          2.16G 2025-03-01 17:42
```

```
# pkg install fvwm
```

Log in as a regular user. 

```
% printf %s\\n "exec fvwm" >> ~/.xinitrc

% cat ~/.xinitrc
exec fvwm

% exec startx
```

----

# Programs and Fonts to Install

```
% sudo pkg install librewolf ungoogled-chromium firefox thunderbird
% sudo pkg install mutt aspell aspell-ispell en-aspell openconnect hsetroot 
% sudo pkg install xv feh slock keepassxc conky bash
% sudo pkg install ruby ruby32-gems rubygem-rake rubygem-jekyll rubygem-bundler
```

NOTE: *hsetroot* is needed because (as of time of this writing), *picom* is incompatible with ```xsetroot```'s ```-solid``` option, and a workaround is to use *hsetroot* to set the background color:


```
% hsetroot -solid gray
```

For my setup, the line ```hsetroot -solid gray``` goes to my ```.xinitrc```.

NOTE: The *taskwarrior*'s binary name is ```task```.

```
% sudo pkg install remind taskwarrior
```

```
% pkg query "%Fp" taskwarrior | wc -l
      82
 
% pkg query "%Fp" taskwarrior 
/usr/local/bin/task
---- snip ----
```

```
% sudo pkg install claws-mail claws-mail-plugins 
% sudo pkg install claws-mail-archive claws-mail-attachwarner \ 
 claws-mail-keyword_warner claws-mail-litehtml_viewer \
 claws-mail-managesieve claws-mail-notification claws-mail-pdf_viewer \
 claws-mail-perl claws-mail-rssyl claws-mail-vcalendar \
 clawsker
% sudo pkg install rsync cpuid sqlite3  sqlite-ext-miscfuncs sqlitebrowser \
 sqliteconvert sqlitemanager sqlitestudio
% sudo pkg install adminerevo php83-mysqli php83-pgsql php83-sqlite3
```

```
% sudo pkg install mame
```


Create a shell script ```mamestart.sh```.

```
% cat mamestart.sh
#!/bin/sh

mame -window -resolution 800x600 \
  -cfg_directory ~/.mame/cfg \
  -pluginspath ~/.mame/ \
  -rompath ~/.mame/roms
```

----

# Dotfiles to Transfer to New System

Directories:

```
~/.config ~/.fonts ~/.fvwm
```

Files:

```
~/.Xresources ~/.xinitrc ~/.cshrc ~/.shrc
```

----

# Dotfiles Not Needing Transfer as They are on the USB Flash Drive

* ```remind(1)```
* Taskwarrior (```task(1)```)
* ```today.pl```
* Recursive sticky notes
* GPG-encrypted private notes

----

# Other Files to Transfer

* Crontab for the regular user
* Crontab for root
* Password safe (KeePassXC)

----

# Scripts Not Needing Transfer as They are on the USB Flash Drive

```
/mnt/usbflashdrive/bin/startopenconnect.sh
/mnt/usbflashdrive/bin/closevpn.sh
```

----

# Accounts to Transfer or Re-Setup

* ```mutt(1)```

* Mozilla Thunderbird

* Mozilla Firefox

* IMAP (993), SMTP (465)         - mailx.example.com - Thunderbird
- Address book: LDAP (389)       - ldap.example.com  - Thunderbird

```Base DN: ou=People,dc=myunit,dc=example,dc=com``` 

* POP3 (993), SMTP (587 via VPN) - mail.example.com  - Thunderbird

* IMAP (993) outlook.office365.com, SMTP (587) smtp.outlook365.com, OAuth2, fn.ln@example.com
- For older versions of TLS, in Thunderbird: go to *Settings* > *Config Editor*. 

Change the preference ```security.tls.version.min```.  Set the value to ```1```. 


* To setup shared mailboxes on Thunderbird using Exchange Online: 

[Adding a shared mailbox to Thunderbird - Instructions for M365 Shared Mailboxes - University of Waterloo (UW)](https://uwaterloo.atlassian.net/wiki/spaces/ISTKB/pages/1921876010/Adding+a+shared+mailbox+to+Thunderbird+-+Instructions+for+M365+Shared+Mailboxes)

----

# Footnotes

[1] From `/usr/ports/graphics/drm-kmod/pkg-descr`:

```
amdgpu, i915, and radeon DRM modules for the linuxkpi-based KMS components on
amd64, i915 and radeonkms DRM modules from the former base DRM component on
other architectures.

Metaport for different versions of Linux DRM based on the FreeBSD version
in use. This port encompasses the recommendations of the FreeBSDDesktop team
of DRM versions for FreeBSD versions based on the last update to the LinuxKPI
in that code base. In general, the most recent supported stable DRM for a given
FreeBSD version will be installed. CURRENT receives the most recent
development DRM.

This port does not however hinder the expert user to make other decisions and
continue to install DRM ports directly.
```

[2]

```
===>   Registering installation for drm-61-kmod-6.1.128.1402000_1 as automatic
Installing drm-61-kmod-6.1.128.1402000_1...
The drm-61-kmod port can be enabled for amdgpu (for AMD
GPUs starting with the HD7000 series / Tahiti) or i915kms (for Intel
APUs starting with HD3000 / Sandy Bridge) through kld_list in
/etc/rc.conf. radeonkms for older AMD GPUs can be loaded and there are
some positive reports if EFI boot is NOT enabled.

For amdgpu: kld_list="amdgpu"
For Intel: kld_list="i915kms"
For radeonkms: kld_list="radeonkms"

Please ensure that all users requiring graphics are members of the
"video" group.

Please note that this package was built for FreeBSD 14.2.
If this is not your current running version, please rebuild
it from ports to prevent panics when loading the module.

===>   drm-kmod-20220907_3 depends on file: /boot/modules/drm.ko - found
===>   Returning to build of drm-kmod-20220907_3
```

[3]

Alternatively:

1. CFT: repository for kernel modules
<https://lists.freebsd.org/archives/freebsd-ports/2024-December/006997.html>

2. GhostBSD pkg(8) Repository on FreeBSD
<https://vermaden.wordpress.com/2025/02/13/ghostbsd-pkg-repository-on-freebsd/>

3. Boot hangs after loading i915kms
<https://forums.freebsd.org/threads/boot-hangs-after-loading-i915kms.95904/>

"I could only have one or the other installed; I'd try: `pkg install -f drm-515-kmod`."

Also:

Possible solution to the drm-kmod kernel mismatch after upgrade from Bapt
<https://forums.freebsd.org/threads/possible-solution-to-the-drm-kmod-kernel-mismatch-after-upgrade-from-bapt.96058/page-2#post-684565>

[4]

```
Then add the module to /etc/rc.conf file, executing the following command:
root@:~ #  printf %s\\n 'kld_list="i915kms"' >> /etc/rc.conf
Alternatively:
sysrc kld_list+=i915kms
```

**Xorg Configuration Files**

Xorg looks in several directories for configuration files.
`/usr/local/etc/X11/`  is the recommended directory for these files on FreeBSD.
Using this directory helps keep application files separate from operating system files.

**Single or Multiple Files**

It is easier to use multiple files that each configure a specific setting than the traditional single *xorg.conf*.
These files are stored in the `/usr/local/etc/X11/xorg.conf.d/` subdirectory.

**Tip**

The traditional single *xorg.conf* still works, but is neither as clear nor as flexible as multiple files in the `/usr/local/etc/X11/xorg.conf.d/` subdirectory.

[5] Message from *dejavu-2.37_3*:

--
Make sure that the freetype module is loaded.  If it is not, add the following
line to the "Modules" section of your X Windows configuration file:

        Load "freetype"

Add the following line to the "Files" section of X Windows configuration file:

        FontPath "/usr/local/share/fonts/dejavu/"

Note: your X Windows configuration file is typically /etc/X11/XF86Config
if you are using XFree86, and /etc/X11/xorg.conf if you are using X.
```

[6] aka, Select Intel video driver in a file.

[7] This is usually not needed -- Not sure what caused it this time.

Could it be because I chose "ZFS home directory encryption" when I used `adduser(8)`? 

----

