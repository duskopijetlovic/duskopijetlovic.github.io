---
layout: post
title: "Displaying Things in a Terminal"
date: 2022-02-20 10:12:22 -0700 
categories: font x11 xorg cli terminal xterm 
---

OS:     FreeBSD 13  
Shell:  csh

```
% freebsd-version
13.0-RELEASE-p5

% ps $$
  PID TT  STAT    TIME COMMAND
23662  3  Ss   0:00.14 -csh (csh)
```

### Quick CLI Overview of OpenType Features for a Font

```
% sudo pkg install harfbuzz harfbuzz-hb-view harfbuzz-icu
```

```
% pkg search imagemagick
ImageMagick6-6.9.12.34,1       Image processing tools (legacy version)
ImageMagick6-nox11-6.9.12.34,1 Image processing tools (legacy version)
ImageMagick7-7.1.0.19          Image processing tools
ImageMagick7-nox11-7.1.0.19    Image processing tools
fpc-imagemagick-3.2.2          Free Pascal interface to ImageMagick
```

```
% sudo pkg install imagemagick7
```

Output: 

```
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 9 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        ImageMagick7: 7.1.0.19
        ghostscript9-agpl-x11: 9.52
        gsfonts: 8.11_8
        liblqr-1: 0.4.2
        libraqm: 0.7.1
        libraw: 0.20.2_2
        libwmf: 0.2.12
        libzip: 1.7.3
        pkgconf: 1.8.0,1
---- snip ----

=====
Message from liblqr-1-0.4.2:

--
NOTE: In order to compile examples for liblqr, you will
also need pngwriter port (/usr/ports/graphics/pngwriter).
Examples are located in /usr/local/share/examples/liblqr-1
```


```
% sudo pkg install pngwriter
```


```
% sudo pkg install kitty
---- snip ----
New packages to be INSTALLED:
        kitty: 0.23.1_1
        ncurses: 6.3
---- snip ----
=====
Message from ncurses-6.3:

--
To get the terminfo database please install the terminfo-db package:
pkg install terminfo-db
```


```
% sudo pkg install terminfo-db
```

```
% locate .otf | wc -l
     987
```

```
% locate -i ".otf" | tail -3
/usr/local/share/texmf-dist/fonts/opentype/public/xcharter/XCharter-BoldItalic.otf
/usr/local/share/texmf-dist/fonts/opentype/public/xcharter/XCharter-Italic.otf
/usr/local/share/texmf-dist/fonts/opentype/public/xcharter/XCharter-Roman.otf
```

```
% cp -i \
/usr/local/share/texmf-dist/fonts/opentype/public/xcharter/XCharter-Roman.otf \
/tmp/
```

```
% otfinfo --features /tmp/XCharter-Roman.otf 
c2sc    Small Capitals From Capitals
cpsp    Capital Spacing
kern    Kerning
liga    Standard Ligatures
lnum    Lining Figures
onum    Oldstyle Figures
smcp    Small Capitals
sups    Superscript
```

```
% command -v hb-view
/usr/local/bin/hb-view
```


Based on 
[💡FAQ about displaying stuff in a terminal](https://twitter.com/thingskatedid/status/1316074032379248640)   

[Quick CLI overview of opentype features for a font you might use, 
without going to the trouble of installing it](https://twitter.com/thingskatedid/status/1288688482920013825)   


```
% vi hb-feat
```

```
% cat hb-feat
#!/bin/sh

hb-view --features="$2" -O svg $1 $3 | grep -v '<rect' | \
  sed 's/<g style="fill:rgb(0%,0%,0%);fill-opacity:1;">/ \
  <g style="fill:#eeeeee">/' | rsvg-convert | \
  convert -trim -resize '25%' - - | kitty icat --align=left
```

```
% chmod 0744 hb-feat
```

Location where I keep my helper binaries, useful tools and scripts:

```
% ls -ld /mnt/usbflashdrive/bin/
drwxr-xr-x  7 dusko  dusko  512 Feb  6 12:24 /mnt/usbflashdrive/bin/
```

```
% mv hb-feat /mnt/usbflashdrive/bin/
```

Launch an instance of kitty terminal emulator.

```
% kitty
```

In kitty terminal emulator:


```
% /mnt/usbflashdrive/bin/hb-feat /tmp/XCharter-Roman.otf +smcp,+onum 'Test'
% /mnt/usbflashdrive/bin/hb-feat /tmp/XCharter-Roman.otf -smcp,-onum 'Test'
% /mnt/usbflashdrive/bin/hb-feat /tmp/XCharter-Roman.otf +liga,+sups 'a2'
```

Output showing images of font preview:

![Quick CLI Overview of OpenType Features for a Font - small capitals and oldstyle figures](/assets/img/hb-view-font.png "Quick CLI Overview of OpenType Features for a Font - small capitals and oldstyle figures")

![Quick CLI Overview of OpenType Features for a Font - standard ligatures and superscript](/assets/img/hb-view-font-superscript.png "Quick CLI Overview of OpenType Features for a Font - standard ligatures and superscript")


Exit kitty terminal emulator. 

```
% exit
```


### Sixel for Terminal Graphics 


Xterm has supported graphical output for decades. It has a Tektronix 4014 mode. 
XTerm also supports Sixel (raster) and ReGIS (vector) graphics in the main window.   

From the man page for ```pkg-query(8)```: 

```
%O[kvdD]
    Expands to the list of options of the matched package, where k stands
    for option key, v for option value, d for option default value and D
    for option description.  
```

List all options (```%Ov```) for the xterm package and whether they have been 
changed from their default values (```%Od```).

```
% pkg query %Ok-%Ov-%Od xterm
256COLOR-on-on
DABBREV-off-off
DECTERM-off-off
GNOME-off-off
LOGGING-off-off
LUIT-on-on
NEXTAW-off-off
PCRE2-off-off
REGIS-off-off
SCRNDUMP-off-off
SIXEL-on-on
TOOLBAR-off-off
WCHAR-on-on
XAW-on-on
XAW3D-off-off
XAW3DXFT-off-off
XINERAMA-off-off
```

The SIXEL option is *on*. 

XTerm terminal emulator supports sixel. You need to run it by setting the 
terminal identifier to a sixel capable terminal; for example, VT340. 

Reference:  
[Sixel Graphics - XTerm Control Sequences - XTerm Documentation](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Sixel-Graphics)    
(Retrieved on Feb 20, 2022)   

```
% xterm -ti vt340
% cd /tmp
% fetch \ 
 https://raw.githubusercontent.com/saitoha/libsixel/master/images/snake.six
```

```
% cat /tmp/snake.six    
```

![cat command output in xterm with sixel support") ](/assets/img/xterm-sixel-cat-snake.png "cat command output in xterm with sixel support")


References:

[FAQ about displaying stuff in a terminal](https://twitter.com/thingskatedid/status/1316074032379248640)  
(Retrieved on Feb 20, 2002)  

[sixel for terminal graphics](https://konfou.xyz/posts/sixel-for-terminal-graphics/)   
(Retrieved on Feb 20, 2022)

