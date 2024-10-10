---
layout: default    ## If you don't want to display the page as "plain"
title: "Programs and Fonts to Install on a New FreeBSD Machine"
---

## Packages Available in FreeBSD Packages Collection  

```
texlive-base     TeX Live Typesetting System, base binaries
texlive-docs     TeX Live, documentation
texlive-texmf    TeX Live, macro packages and fonts
texlive-tlmgr    TeX Live, manager modules    [1] 
latex-mk         Collection of makefile and scripts for LaTeX documents
txt2tags         Convert simply formatted text into markup (e.g., LaTeX, HTML)
lyx              Document processor interfaced with LaTeX (nearly WYSIWYG)
setzer           LaTeX editor written in Python with Gtk

ipe              Extensible vector graphics editor with LaTeX support

uniutils         Unicode Description Utilities
uni              Query the Unicode database from the commandline
uchardet         Universal charset detection library
gucharmap        Unicode/ISO10646 character map and font viewer
ftfy             Fix some problems with Unicode text after the fact
dateutils        Command line utilities for working with dates

keepassxc        KeePass Cross-platform Community Edition

firefox          Web browser based on the browser portion of Mozilla
thunderbird      Standalone mail and news that stands above
mutt             Small but powerful text based program for read/writing e-mail

hs-arbtt         Completely automatic time tracker for X11 desktop

td-system-tools  Printing basic system information and system maintenance
arp-scan         ARP scanning and fingerprinting tool
py311-scapy      Powerful interactive packet manipulation program in python [2]

whatmask         Convert between common subnet mask notations
subnetcalc       IPv4/IPv6 Subnet Calculator

qtfm             Small, lightweight file manager based on pure Qt
(rox-filer       Simple and easy to use graphical file manager)
(catseye-fm      Clear, fast, powerful file browser using gtk+2.0)

xed              Small but powerful text editor for GTK (for X or X11/Xorg)

kitty            Cross-platform, fast, featureful, GPU-based terminal emulator
xdu              Graphically display the output of "du" in an X window
xdiskusage       Show where disk space is taken up
```

----


## Manual Downloads or Manual Installations 

### BackupFS

[TODO] - Continue 
2023_03_05_1900_freebsd_lenovo_x280_installed_backupfs_by_compiling_from_source_and_with_boost_cpp_libraries.txt


```
$ sudo pkg install boost-all
$ sudo pkg install boost_build
$ sudo pkg install gcc 
$ sudo pkg install gccmakedep 
$ sudo pkg install cmake
```

```
$ mkdir ~/backupf
$ cd ~/backupfs
```

```
$ fetch https://github.com/hariguchi/backupfs/archive/refs/heads/master.zip

$ mv master.zip backupfs.zip

$ unzip backupfs.zip
. . . 
```

```
$ mv backupfs-master backupfs

$ cd backupfs
```

### GraTeX

```
GraTeX         Visual graph creator for LaTeX (PGF & TikZ)    [3] 
```

```
$ fetch https://sourceforge.net/projects/gratex/files/GraTeX.jar
$ java -jar gratex.jar  
```

### File Browser (filebrowser) - Web File Browser

[File Browser - Web File Browser](https://filebrowser.org/)

[File Browser on GitHub](https://github.com/filebrowser/filebrowser)


```
$ fetch https://raw.githubusercontent.com/filebrowser/get/master/get.sh
```

NOTE: Requires *bash*.

```
$ head -1 get.sh
#!/usr/bin/env bash
```

```
$ chmod 0744 get.sh
```

```
$ ./get.sh
```

The script will ask you to enter your root password.

Output:

```
Downloading File Browser for freebsd/amd64...
https://github.com/filebrowser/filebrowser/releases/download/v2.30.0/freebsd-amd
64-filebrowser.tar.gz
Extracting...
Putting filemanager in /usr/local/bin (may require password)

Password:

Successfully installed
```

```
$ ls -lh /usr/local/bin/filebrowser 
-rwxr-xr-x  1 dusko wheel   16M May 19 03:14 /usr/local/bin/filebrowser
```


Start it.

```
$ /usr/local/bin/filebrowser
2024/08/19 21:34:25 Warning: filebrowser.db can't be found. Initialing in /home/dusko/
2024/08/19 21:34:25 Using database: /home/dusko/filebrowser.db
2024/08/19 21:34:25 No config file used
2024/08/19 21:34:25 Listening on 127.0.0.1:8080
```

With your web browser, Mozilla Firefox, open:

```
http://localhost:8080
```

NOTE: The default username, password: *admin*, *admin*.

To stop it, press `Ctrl+c`.

```
^C

2024/08/19 21:36:51 Caught signal interrupt: shutting down.
```

If you want to configure [No Authentication](https://filebrowser.org/configuration/authentication-method#no-authentication):

```
$ filebrowser config set --auth.method=noauth
```

Output:

```
2024/08/19 21:39:04 Using database: /home/dusko/filebrowser.db
Sign up:          false
Create User Dir:  false
Auth method:      noauth
[ . . . ]
Server:
  Log:           stdout
  Port:          8080
[ . . . ] 
  Address:       127.0.0.1
[ . . . ]
```

```
$ ls -lh /home/dusko/filebrowser.db
-rw-------  1 dusko dusko   64K Aug 19 21:39 /home/dusko/filebrowser.db

$ date
Mon 19 Aug 2024 22:39:46 PDT

$ file /home/dusko/filebrowser.db
/home/dusko/filebrowser.db: FILE_SIZE=65536

$ wc -l /home/dusko/filebrowser.db
       5 /home/dusko/filebrowser.db

$ grep noauth /home/dusko/filebrowser.db
Binary file /home/dusko/filebrowser.db matches

$ strings /home/dusko/filebrowser.db | grep noauth | wc -l
       1
```

### gateway-finder-imp

[gateway-finder-imp -- Tool to identify routers on the local LAN and paths to the Internet](https://github.com/whitel1st/gateway-finder-imp)

----

## Fonts 

### Fonts Available in FreeBSD Packages Collection  

NOTE: `noto-basic` is an *automotic* package; that is, it *requires* other packages a.k.a. *dependencies*. It has five dependencies.

```
$ pkg rquery %#d noto-basic
5
```

```
$ pkg rquery %dn noto-basic
noto-serif
noto-sans-symbols2
noto-sans-symbols
noto-sans-mono
noto-sans
```

```
$ sudo pkg install noto-basic
[ . . . ]
New packages to be INSTALLED:
        noto-basic: 2.0_4
        noto-sans: 2.013
        noto-sans-mono: 2.014_1
        noto-sans-symbols: 2.008_1
        noto-sans-symbols2: 2.008
        noto-serif: 2.013
```

### Fonts Not Available in FreeBSD Packages Collection  


#### 0xProto

```
$ fc-match 0xProto
0xProto-Regular.otf: "0xProto" "Regular"
 
$ xterm -fa 0xProto -fs 14 &
```

```
$ mutt -F /mnt/usbflashdrive/mydotfiles/mutt-imap-ubc-chemistry/.muttrc.chem.ubc.ca.imap
```

----

## Footnotes

[1] This package contains the files needed to get the TeX Live tools (notably ```tlmgr```) running: *perl* modules, *xz* binaries, plus (sometimes) *tar* and *wget*.
These files end up in the standalone install packages, and in the *tlcritical* repository.

[2] As of time of this writting, *scapy* required Python *3.11*.

[3] [GraTeX - SourceForge.net](https://sourceforge.net/projects/gratex/)    
> Java application for creating graphs, with a simple and intuitive interface. Obtaining LaTeX code for designed graph is a single-click operation.
Allows creating less and more complicated graphs for LaTeX documents without any knowledge about TikZ library.
> 
> The program lets you design and edit vertices, edges and labels to your liking thanks to a wide range of variants adequate to TikZ library.
> 
> GraTeX incorporates common editing mechanisms like saving/loading projects, undo-redo & copy-paste operations, and many other useful features.
> 
> The application has been developed by two students of University of Science and Technology in Krakow, Poland.

----


## References

* [File Browser - Web File Browser](https://filebrowser.org/)
* [File Browser on GitHub](https://github.com/filebrowser/filebrowser)

