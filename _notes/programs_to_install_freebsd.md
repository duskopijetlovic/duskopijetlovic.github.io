---
layout: default    ## If you don't want to display the page as "plain"
title: "Programs and Fonts to Install on a New FreeBSD Machine"
---

## Packages Available in FreeBSD Packages Collection  

```
texlive-base   TeX Live Typesetting System, base binaries
texlive-docs   TeX Live, documentation
texlive-texmf  TeX Live, macro packages and fonts
texlive-tlmgr  TeX Live, manager modules    [1] 
latex-mk       Collection of makefile and scripts for LaTeX documents
txt2tags       Convert simply formatted text into markup (e.g., LaTeX, HTML)
lyx            Document processor interfaced with LaTeX (nearly WYSIWYG)
setzer         LaTeX editor written in Python with Gtk

ipe            Extensible vector graphics editor with LaTeX support

mutt           Small but powerful text based program for read/writing e-mail

whatmask       Convert between common subnet mask notations

qtfm           Small, lightweight file manager based on pure Qt
(rox-filer     Simple and easy to use graphical file manager)
(catseye-fm    Clear, fast, powerful file browser using gtk+2.0)

xed            Small but powerful text editor for GTK (for X or X11/Xorg)

kitty          Cross-platform, fast, featureful, GPU-based terminal emulator
xdu            Graphically display the output of "du" in an X window
xdiskusage     Show where disk space is taken up
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
GraTeX         Visual graph creator for LaTeX (PGF & TikZ)    [2] 
```

```
$ fetch https://sourceforge.net/projects/gratex/files/GraTeX.jar
$ java -jar gratex.jar  
```

----

## Fonts 


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

[2] [GraTeX - SourceForge.net](https://sourceforge.net/projects/gratex/)    
> Java application for creating graphs, with a simple and intuitive interface. Obtaining LaTeX code for designed graph is a single-click operation.
Allows creating less and more complicated graphs for LaTeX documents without any knowledge about TikZ library.
> 
> The program lets you design and edit vertices, edges and labels to your liking thanks to a wide range of variants adequate to TikZ library.
> 
> GraTeX incorporates common editing mechanisms like saving/loading projects, undo-redo & copy-paste operations, and many other useful features.
> 
> The application has been developed by two students of University of Science and Technology in Krakow, Poland.
