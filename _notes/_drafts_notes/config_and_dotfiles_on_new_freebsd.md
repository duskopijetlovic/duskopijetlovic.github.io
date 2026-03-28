---
layout: page ## If you don't want to display the page as "plain"
# layout: default    ## If you don't want to display the page as "plain"
title: "Configuration and Dotfiles on a New FreeBSD Machine"
categories: freebsd dotfiles config
---


```
kern.msgbufsize=524288
verbose_loading="YES"
boot_verbose="YES"
```

`kern.msgbufsize=524288` for 512 KiB:

```
% printf %s\\n "scale = 2; 512 * 1024" | bc
524288
```


From the man page for `rc.conf(5)`:

```
The /etc/rc.conf file is included from the file /etc/defaults/rc.conf,
which specifies the default settings for all the available options.
```

From the man page for `loader.conf(5)`:

```
FILES
     /boot/defaults/loader.conf  Default settings - do not change this file.
```

From the man page for `dmesg(8)`: 

```
SYSCTL VARIABLES
     The following sysctl(8) variables control how the kernel timestamps
     entries in the message buffer: The default value is shown next to each
     variable.

     kern.msgbuf_show_timestamp: 0
             If set to 0, no timetamps are added.  If set to 1, then a
             1-second granularity timestamp will be added to most lines in the
             message buffer.  If set to 2, then a microsecond granularity
             timestamp will be added.  This may also be set as a boot
             loader(8) tunable.  The timestamps are placed at the start of
             most lines that the kernel generates.  Some multi-line messages
             will have only the first line tagged with a timestamp.
```

```
% grep verbose /boot/defaults/loader.conf 
verbose_loading="NO"            # Set to YES for verbose loader output
#boot_verbose=""        # -v: Causes extra debugging information to be printed
#debug.ktr.verbose="1"          # Enable console dump of KTR events


% grep "kern.msgbufsize" /boot/defaults/loader.conf 
#kern.msgbufsize="65536"        # Set size of kernel message buffer
```

Before changes:

```
% sysctl kern.msgbufsize
kern.msgbufsize: 98304

% sysctl kern.msgbuf_show_timestamp
kern.msgbuf_show_timestamp: 0

% sysctl kern.msgbuf_show_timestamp
kern.msgbuf_show_timestamp: 0
```

```
% kenv | grep verbose_loading
verbose_loading="NO"

% kenv | grep boot_verbose
```


```
% sysrc -a | grep rc_debug

% sysrc -a | grep rc_info
```

Changes:

```
% printf %s\\n 'kern.msgbufsize=524288' | sudo tee -a /boot/loader.conf
kern.msgbufsize=524288

% printf %s\\n 'verbose_loading="YES"' | sudo tee -a /boot/loader.conf
verbose_loading="YES"

% printf %s\\n 'boot_verbose="YES"' | sudo tee -a /boot/loader.conf
boot_verbose="YES"

% printf %s\\n 'kern.msgbuf_show_timestamp="1"' | sudo tee -a /boot/loader.conf
```

Reboot:

```
% sudo reboot
```

After reboot:

```
$ sysrc -a | grep rc_debug
rc_debug: YES

$ sysrc -a | grep rc_info
rc_info: YES
```


```
% sysctl kern.msgbufsize
kern.msgbufsize: 524288

% sysctl -a | grep boot | grep verbose
debug.bootverbose: 1

% sysctl -d debug.bootverbose
debug.bootverbose: Control the output of verbose kernel messages

% sysctl -a | grep load | grep verbose

% sysctl kern.msgbuf_show_timestamp
kern.msgbuf_show_timestamp: 1
```


The `kenv(1)` provides information for `verbose_loading` too: 

```
% kenv kern.msgbufsize
524288
 
% kenv verbose_loading
YES
 
% kenv boot_verbose
YES

% kenv kern.msgbuf_show_timestamp
1
```

```
% sysrc -c rc_debug
% printf %s\\n $?
0
```

```
% sysrc -e rc_debug
rc_debug="YES"
 
% sysrc -e rc_info
rc_info="YES"
```
 

## References

* man `rc.conf(5)`
* man `loader.conf(5)`
* man `kenv(1)`
* man `dmesg(8)`
* [Not all boot msgs in dmesg](https://forums.freebsd.org/threads/not-all-boot-msgs-in-dmesg.89928/)
