---
layout: post 
title: "How To Take Screenshots with xwd(1), Pixmap Size (Depth) of 24 and 32 and Convert It To png" 
date: 2022-02-05 14:33:21 -0700 
categories: freebsd dotfiles x11 
---

Operating system: FreeBSD 13.0 

**Note:**   
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.


Install **py-png** package. 
At the time of writing, python version is **3.8**.   


```
$ sudo pkg install py38-png
```


Install **netpbm** - a toolkit for conversion of images between different formats.
  
```
$ sudo pkg install netpbm
```


```
% ls /usr/local/include/netpbm
colorname.h     pammap.h        pgm.h           pm_system.h
mallocvar.h     pbm.h           pm_c_util.h     pm.h      
pam.h           pbmfont.h       pm_config.h     pnm.h           
pamdraw.h       pbmfontdata.h   pm_gamma.h      ppm.h           
ppmcmap.h       runlength.h
ppmdfont.h      shhopt.h
ppmdraw.h
ppmfloyd.h
```


```
% man -k netpbm | wc -l
      64
```


```
% man -k pbm | wc -l
     143
```


```
% xdpyinfo | wc -l
    4270
 
% xdpyinfo | grep -n -i pixmap
10:number of supported pixmap formats:    7
11:supported pixmap formats:
 
% xdpyinfo | head -20
name of display:    :0.0
version number:    11.0
vendor string:    The X.Org Foundation
vendor release number:    12011000
X.Org version: 1.20.11
maximum request size:  16777212 bytes
motion buffer size:  256
bitmap unit, bit order, padding:    32, LSBFirst, 32
image byte order:    LSBFirst
number of supported pixmap formats:    7
supported pixmap formats:
    depth 1, bits_per_pixel 1, scanline_pad 32
    depth 4, bits_per_pixel 8, scanline_pad 32
    depth 8, bits_per_pixel 8, scanline_pad 32
    depth 15, bits_per_pixel 16, scanline_pad 32
    depth 16, bits_per_pixel 16, scanline_pad 32
    depth 24, bits_per_pixel 32, scanline_pad 32
    depth 32, bits_per_pixel 32, scanline_pad 32
keycode range:    minimum 8, maximum 255
focus:  window 0x40000c, revert to PointerRoot
```


```
% xwininfo -root | wc -l
      24

% xwininfo -root | grep -i depth
  Depth: 24
```


For a window with a **depth of 24**

```
% xwininfo | grep 'Window id'
xwininfo: Window id: 0x1e0000f "LibreOffice"
 
% xwininfo | grep -i depth
  Depth: 24
```

piping ```xwd(1)``` with ```xwdtopnm(0)``` and ```pnmtopng(0)``` works:


```
% xwd | xwdtopnm | pnmtopng > screenshot.png
xwdtopnm: writing PPM file

% ls -lh screenshot.png
-rw-r--r--  1 dusko  dusko    23K Feb  6 12:01 screenshot.png

% file screenshot.png
screenshot.png: PNG image data, 830 x 391, 8-bit/color RGB, non-interlaced
```

Open the screenshot.

```
% xv screenshot.png
```


For a window with a **depth > 24**

```
% xwininfo | grep 'Window id'
xwininfo: Window id: 0x1402c2d "Mozilla Firefox"
 
% xwininfo | grep -i depth
  Depth: 32
 
% xwd | xwdtopnm | pnmtopng > screenshot.png
xwdtopnm: can't handle X11 pixmap_depth > 24
pnmtopng: Error reading first byte of what is expected to be a Netpbm 
  magic number.  Most often, this means your input file is empty
```

piping ```xwd(1)``` with ```xwdtopnm(0)``` and ```pnmtopng(0)``` doesn't work. 


#### Workaround for Taking Screenshots with xwd(1) with Pixmap Size (Depth) Bigger than 24


Modify and use a tool xwd2png (convert output of xwd to PNG), https://github.com/drj11/xwd2png. 


**NOTE:**   
This is a quick and dirty workaround.  For example, I'm removing Python 
exception handling, NotImplementedError. although there is a possibility 
that the author of the source code left it to perhaps indicate a TODO 
placeholder, as a reminder to implement handling other cases (that is 
visual classes different than 4) later. 


Location where I keep my helper binaries, useful tools and scripts:

```
% ls -ld /mnt/usbflashdrive/bin
drwxr-xr-x  6 dusko  dusko  512 Dec  9 12:27 /mnt/usbflashdrive/bin
```


```
% cd /mnt/usbflashdrive/bin/xwd2png
 
% fetch https://raw.githubusercontent.com/drj11/xwd2png/main/XWDFile.h
XWDFile.h                                     4031  B   22 MBps    00s
 
% fetch https://raw.githubusercontent.com/drj11/xwd2png/main/xwd.py
xwd.py                                        7958  B   34 MBps    00s
```

Python version:

```
% ls -ld /usr/local/bin/python*
-r-xr-xr-x  1 root  wheel  5248 Nov  3 18:13 /usr/local/bin/python3.8
-r-xr-xr-x  1 root  wheel  3153 Nov  3 18:13 /usr/local/bin/python3.8-config
lrwxr-xr-x  1 root  wheel    50 Jan  1 18:31 /usr/local/bin/pythontex -> ../share/texmf-dist/scripts/pythontex/pythontex.py
```


```
% cp -i xwd.py xwd.py.original.bak
```


```
% vi xwd.py
```

```
% diff --unified=0 xwd.py.original.bak xwd.py
--- xwd.py.original.bak 2022-02-06 12:35:23.701781000 -0800
+++ xwd.py      2022-02-06 12:36:15.213548000 -0800
@@ -1 +1 @@
-#!/usr/bin/env python3
+#!/usr/bin/env python3.8
@@ -57,15 +56,0 @@
-        # Check visual_class.
-        # The following table from http://www.opensource.apple.com/source/tcl/tcl-87/tk/tk/xlib/X11/X.h is assumed:
-        # StaticGray    0
-        # GrayScale     1
-        # StaticColor   2
-        # PseudoColor   3
-        # TrueColor     4
-        # DirectColor   5
-
-        if self.visual_class != 4:
-            # TrueColor
-            raise NotImplemented(
-                "Cannot handle visual_class {!r}".format(self.visual_class)
-            )
-
@@ -291 +276 @@
-        apng.write(out)
+        apng.save(out)
```


```
% xwininfo | grep 'Window id'
xwininfo: Window id: 0x1402c2d "Mozilla Firefox"

% xwininfo | grep -i depth
  Depth: 32
```


```
% xwd | /mnt/usbflashdrive/bin/xwd2png/xwd.py > ~/screenshot.png
 
% ls -lh ~/screenshot.png
-rw-r--r--  1 dusko  dusko   580K Feb  6 12:47 /home/dusko/screenshot.png
 
% file ~/screenshot.png
/home/dusko/screenshot.png: PNG image data, 1260 x 1079, 
  8-bit/color RGB, non-interlaced
```


Open the screenshot.

```
% xv ~/screenshot.png
```


Alternatively:  
Install ImageMagick (```sudo pkg install ImageMagick7```) and use one of 
its tools, ```import``` for taking screenshots.  

