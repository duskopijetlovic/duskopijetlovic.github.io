---
layout: post
title: "Simple X11 Setup - Notes"
date: 2025-08-31 12:38:13 -0700 
categories: x11 xorg xterm config dotfiles howto font freebsd utf8 unicode unix 
            cli terminal shell tip 
---

# My Notes from [How to configure X11 in a simple way](https://eugene-andrienko.com/it/2025/07/24/x11-configuration-simple.html) by Eugene Andrienko
(Posted on 2025-07-24. Retrieved on 2025-08-31.)

# My Primary Concerns 

* High DPI (HighDPI or HiDPI) display 
* Fonts
  * Shell, terminal - XTerm
  * Proportional vs. monospace(d) vs. bitmap (pixel fonts) vs. fixed bitmap vs. TrueType (Xft) [<sup>[1](#footnotes)</sup>]
  * Unicode
* Brightness


## Laptop - Main Screen (Built-In Display)

# High DPI (HighDPI or HiDPI) Display 

How to setup X server to operate with HighDPI display?

Laptop (and screen/display) used for this setup: **Lenovo ThinkPad T14s Gen3**

* Lenovo ThinkPad T14s Gen3
* Screen: 14.0" WUXGA (1920 x 1200), IPS, Anti-Glare, Touch, 100%sRGB, 500 nits, ePrivacy Filter
* Display size: 14 inch (diagonal)
* Display aspect ratio: 16:10
* Resolution (Pixel format): 1920 (H) x 1200 (V)
* Active area: 301mm (H) x 188mm (V)

* CPU: 12th Gen Intel Core i7-1280P
* RAM: 32 GB

* OS: FreeBSD 14
* Shell: csh
* Window Manager: fvwm3 1.1.0

----

# Brightness


Add the following two lines to ```/boot/loader.conf```:

```
acpi_ibm_load="YES"
acpi_video_load="YES"
```

Current brightness:

```
% backlight
brightness: 32
```

Change brightness:

```
% backlight 80
```

```
% pkg search gammy
gammy-0.9.64_1  Adaptive screen brightness and temperature for Windows and Unix
```

```
% sudo pkg install gammy
```

Start gammy:

```
% gammy
```

----

# DPI


```
% xrandr | wc -l
      47
 
% xrandr --verbose | wc -l
     440

% xrandr | grep "connected primary"
eDP-1 connected primary 1920x1200+0+0 (normal left inverted right x axis y axis) 301mm x 188mm
```

So, with active area dimensions 301mm x 188mm, my ```/usr/local/etc/X11/xorg.conf.d/10-intel.conf``` file looks like this: 

```
% cat /usr/local/etc/X11/xorg.conf.d/10-intel.conf
Section "Monitor"
    Identifier  "MainMonitor"
    Option      "Primary" "true"
    DisplaySize 301 188
EndSection

Section "Device"
    Identifier  "intel"
    Option      "Monitor-eDP-1"   "MainMonitor"
    Option      "Monitor-HDMI-1"  "ExternalMonitor"
EndSection

Section "Screen"
    Identifier "MainScreen"
    Device     "intel"
    Monitor    "MainMonitor"
EndSection
```

Before the change, DPI on this system was set to 110: 

```
% grep "Xft.dpi" ~/.Xresources
Xft.dpi:    110
```

```
% xrdb -query | grep dpi 
Xft.dpi:        110
```

What should be DPI for this laptop's screen?

To calculate, use a DPI calculator/PPI calculator; for example:

[https://www.sven.de/dpi/](https://www.sven.de/dpi/)

For this laptop's monitor:

* Horizontal resolution: 1920 pixels
* Vertical resolution: 1200 pixels
* Diagonal: 14 inches 
* Aspect ratio: 16:10

The result is:

```
Display size:
11.87" × 7.42" = 88.09in (30.15cm × 18.85cm = 568.32cm) at 
161.73 PPI, 0.1571mm dot pitch, 26155 PPI
```

That is: **DPI** is **161.73** 

Edit the ```~/.Xresources``` file, and change it from 110 to 161.73.

```
% grep "Xft.dpi" ~/.Xresources
Xft.dpi:    161.73
```

After that, run ```xrdb(1)``` to reload the ```.Xresources``` and replace current settings: 

```
% xrdb ~/.Xresources
```

DPI is now set to 161.73:

```
% xrdb -query | grep dpi
Xft.dpi:        161.73
```

----

# Useful Commands and Examples for Exploring Hardware

```
% sudo dmidecode | wc -l
     975

% sudo dmidecode | grep "Version: ThinkPad"
      Version: ThinkPad T14s Gen 3

% sudo dmidecode | grep "SKU Number: LENOVO"
      SKU Number: LENOVO_MT_21BR_BU_Think_FM_ThinkPad T14s Gen 3

% sudo dmidecode | sed -n 608,616p
System Information
      Manufacturer: LENOVO
      Product Name: 21BR000NUS
      Version: ThinkPad T14s Gen 3
      Serial Number: [redacted]
      UUID: [redacted]
      Wake-up Type: Power Switch
      SKU Number: LENOVO_MT_21BR_BU_Think_FM_ThinkPad T14s Gen 3
      Family: ThinkPad T14s Gen 3

% sudo dmidecode | grep Intel | grep Version
      Version: 12th Gen Intel(R) Core(TM) i7-1280P

% sudo dmidecode | sed -n 517,521p
Processor Information
      Socket Designation: U3E1
      Type: Central Processor
      Family: Core i7
      Manufacturer: Intel(R) Corporation

% sudo dmidecode | grep i7 | grep Version
        Version: 12th Gen Intel(R) Core(TM) i7-1280P
```

```
% sysctl hw.physmem
hw.physmem: 34007212032

% printf %s\\n "34359738368 / 1024 / 1024" | bc
32768
 
% printf %s\\n "34359738368 / 1024 / 1024 / 1024" | bc
32
```

```
% dmesg | grep "real memory"
real memory  = 34359738368 (32768 MB)
```

```
% pciconf -lv | grep -B3 display
vgapci0@pci0:0:2:0:	class=0x030000 rev=0x0c hdr=0x00 vendor=0x8086 device=0x46a6 subvendor=0x17aa subdevice=0x22ee
    vendor     = 'Intel Corporation'
    device     = 'Alder Lake-P GT2 [Iris Xe Graphics]'
    class      = display
 
% xdpyinfo | grep "number of screens"
number of screens:    1

% xdpyinfo | grep -B2 resolution
screen #0:
  dimensions:    1920x1200 pixels (294x184 millimeters)
  resolution:    166x166 dots per inch
```

```
% ls /dev/backlight/
backlight0              intel_backlight0
```


```
% fc-list | wc -l
    1895

% fc-list :scalable=true:spacing=mono:family | wc -l
     175

% fc-list :scalable=true:spacing=mono:family | less
---- snip ----

% fc-list :scalable=true:spacing=mono:family | grep mono | wc -l
      60

% fc-list :scalable=true:spacing=mono:family | grep mono | less
---- snip ----
```

```
% fc-match | wc -l
       1

% fc-match
NotoSans-Regular.ttf: "Noto Sans" "Regular"

% fc-match SomeFont
NotoSans-Regular.ttf: "Noto Sans" "Regular"
 
% fc-match "Some Font"
NotoSans-Regular.ttf: "Noto Sans" "Regular"

% fc-match 0xProto
0xProto-Regular.otf: "0xProto" "Regular"
 
% fc-match 0xPROTO
0xProto-Regular.otf: "0xProto" "Regular"

% fc-match '*0xProto*'
NotoSans-Regular.ttf: "Noto Sans" "Regular"
 
% fc-match "*0xProto*"
NotoSans-Regular.ttf: "Noto Sans" "Regular"
```


```
% fc-list | grep 0xProto
/home/dusko/.fonts/0xProto-Regular.otf: 0xProto:style=Regular
/home/dusko/.fonts/0xProto-Regular.ttf: 0xProto:style=Regular

% find ~/.fonts -iname '*0xProto*'
/home/dusko/.fonts/0xProto-Regular.otf
/home/dusko/.fonts/0xProto-Regular.ttf
```


```
% fc-list | grep -i 0xProto
/home/dusko/.fonts/0xProto-Regular.otf: 0xProto:style=Regular
/home/dusko/.fonts/0xProto-Regular.ttf: 0xProto:style=Regular

% fc-list -v 0xProto | grep -i file
        file: "/home/dusko/.fonts/0xProto-Regular.ttf"(s)
        file: "/home/dusko/.fonts/0xProto-Regular.otf"(s)
```


To get detailed information about 0xProto:

```
% fc-list -v 0xProto | wc -l
      88
 
% fc-list -v 0xProto | grep postscriptname
        postscriptname: "0xProto-Regular"(s)
        postscriptname: "0xProto-Regular"(s)
```


```
% fc-match
NotoSans-Regular.ttf: "Noto Sans" "Regular"
 
% fc-list | grep "NotoSans-Regular.ttf"
/usr/local/share/fonts/noto/NotoSans-Regular.ttf: Noto Sans:style=Regular

% find /usr/local/share/fonts -iname '*Noto*' | wc -l
     366

% find /usr/local/share/fonts -iname '*Noto*' 
/usr/local/share/fonts/noto
/usr/local/share/fonts/noto/NotoSerifDisplay-BlackItalic.ttf
/usr/local/share/fonts/noto/NotoSerifCJKsc-ExtraLight.otf
---- snip ----
/usr/local/share/fonts/noto/NotoSans-BoldItalic.ttf
/usr/local/share/fonts/noto/NotoSans-SemiCondensedExtraLightItalic.ttf
/usr/local/share/fonts/noto/NotoSans-BlackItalic.ttf
```


```
% pkg search --regex ^xfontsel
xfontsel-1.1.1    Point and click selection of X11 font names

% pkg search --regex --full ^xfontsel
xfontsel-1.1.1
Name           : xfontsel
---- snip ----

Description    :
This package contains xfontsel, an application which provides 
a simple way to display fonts known to your X server.
```

```
% sudo pkg install xfontsel
```

```
% xfontsel -help
usage:  xfontsel [-options ...] -fn font

where options include:
    -display dpy           X server to contact
    -geometry geom         size and location of window
    -pattern fontspec      font name pattern to match against
    -print                 print selected font name on exit
    -sample string         sample text to use for 1-byte fonts
    -sample16 string       sample text to use for 2-byte fonts
    -sampleUCS string      sample text to use for ISO10646 fonts
    -scaled                use scaled instances of fonts
plus any standard toolkit options
```

```
% xfontsel -pattern 'mono' -print

#  The  xfontsel  window displayed:
#    no names match

% xfontsel -pattern '*mono*' -print
        
#  The  xfontsel  window displayed:
#    106 names match

#  After quitting xfontsel(1):

-*-dejavu sans mono-*-*-*-*-*-*-*-*-*-*-*-*%
```


```
% pkg search xlsfonts
xlsfonts-1.0.8    Server font list displayer for X

% sudo pkg install xlsfonts
```

```
% xlsfonts -h
xlsfonts: unrecognized argument -h

usage:  xlsfonts [-options] [-fn pattern]
where options include:
    -l[l[l]]                 give long info about each font
    -m                       give character min and max bounds
    -C                       force columns
    -1                       force single column
    -u                       keep output unsorted
    -o                       use OpenFont/QueryFont instead of ListFonts
    -w width                 maximum width for multiple columns
    -n columns               number of columns if multi column
    -display displayname     X server to contact
    -d displayname           (alias for -display displayname)
    -v                       print program version
```

```
% xlsfonts | wc -l
   23232

% xlsfonts "*" | wc -l
   23232
```

```
% xlsfonts "mono" | wc -l
xlsfonts: pattern "mono" unmatched
       0

% xlsfonts "*mono*" | wc -l
    6962

% xlsfonts "*mono*" | head
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-ascii-0
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-cns11643-1
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-cns11643-2
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-cns11643-3
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-gb18030.2000-0
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-gb2312.1980-0
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-iso10646-1
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-iso8859-1
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-jisx0201.1976-0
-adobe-noto sans mono cjk jp-bold-r-normal--0-0-0-0-p-0-jisx0208.1983-0
```


```
% xlsfonts | wc -l
   23232

% xlsfonts | grep -i monospaced | wc -l
       0
 
% xlsfonts | grep -i monospace | wc -l
       0

% xlsfonts | grep -i fixed | wc -l
    1014

% xlsfonts | grep -i fixed | tail
-sony-fixed-medium-r-normal--24-170-100-100-c-120-jisx0201.1976-0
-sony-fixed-medium-r-normal--24-230-75-75-c-120-iso8859-1
-sony-fixed-medium-r-normal--24-230-75-75-c-120-iso8859-1
-sony-fixed-medium-r-normal--24-230-75-75-c-120-jisx0201.1976-0
-sony-fixed-medium-r-normal--24-230-75-75-c-120-jisx0201.1976-0
fixed
fixed
fixed
fixed
koi-fixed
 
% xlsfonts | grep -i fixed | grep ^fixed | wc -l
       4
 
% xlsfonts | grep -i fixed | grep -i ^fixed | wc -l
       4
 
% xlsfonts | grep -i fixed | grep ^fixed
fixed
fixed
fixed
fixed
```

```
% sudo pkg install xfd 
```

```
% pkg info xfd
---- snip ----
Comment        : Display all characters in an X font
---- snip ----
Description    :
This package contains xfd, an applications used for displying all
characters in an X font.
```

```
% xfd -fa gallant

#   xfd(1) loaded Noto Sans-12:style=Regular
#   WHY?
#   This is why:

% fc-match
NotoSans-Regular.ttf: "Noto Sans" "Regular"

% fc-match gallant
NotoSans-Regular.ttf: "Noto Sans" "Regular"
```

```
% fc-list | wc -l
    1895

% sudo pkg install xscreensaver

% fc-list | wc -l
    1900

% fc-list | grep -i gallant
/usr/local/share/fonts/xscreensaver/gallant12x22.ttf: gallant12x22:style=Medium

% xfd -fa gallant12x22

#   xfd(1) loaded the correct font, that is:
#     gallant12x22-12:style=Medium

% xfd -fn gallant12x22
Warning: Cannot convert string "gallant12x22" to type FontStruct
xfd:  no font to display
```


```
% xrdb -query | wc -l
      47

% xrdb -query | grep -i font | wc -l
       1
 
% xrdb -query | grep -i font
XTerm*boldFont: -adobe-courier-bold-r-normal--18-180-75-75-m-110-iso8859-1
```

```
% sudo pkg install appres
appres-1.0.7    Program to list application's resources
```

```
% pkg info appres
appres-1.0.7
---- snip ----

Description    :
The appres program prints the resources seen by an application
(or subhierarchy of an application) with the specified class and
instance names.  It can be used to determine which resources a 
particular program will load.
```

```
% appres XTerm xterm | wc -l
     175

% appres XTerm xterm
---- snip ----
```


```
% locate "app-defaults" | grep -i xterm
/usr/local/lib/X11/app-defaults/KOI8RXTerm
/usr/local/lib/X11/app-defaults/KOI8RXTerm-color
/usr/local/lib/X11/app-defaults/UXTerm
/usr/local/lib/X11/app-defaults/UXTerm-color
/usr/local/lib/X11/app-defaults/XTerm
/usr/local/lib/X11/app-defaults/XTerm-color
 
% wc -l /usr/local/lib/X11/app-defaults/XTerm
     272 /usr/local/lib/X11/app-defaults/XTerm

% grep -v \! /usr/local/lib/X11/app-defaults/XTerm | wc -l
     149

% grep -i font /usr/local/lib/X11/app-defaults/XTerm | grep -i fix | wc -l
       8

% grep -i font /usr/local/lib/X11/app-defaults/XTerm | grep -i fixed
*VT100.utf8Fonts.font2: -misc-fixed-medium-r-normal--8-80-75-75-c-50-iso10646-1
*VT100.utf8Fonts.font:  -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
*VT100.utf8Fonts.font3: -misc-fixed-medium-r-normal--14-130-75-75-c-70-iso10646-1
*VT100.utf8Fonts.font4: -misc-fixed-medium-r-normal--13-120-75-75-c-80-iso10646-1
*VT100.utf8Fonts.font5: -misc-fixed-medium-r-normal--18-120-100-100-c-90-iso10646-1
*VT100.utf8Fonts.font6: -misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1
! The default fixed font and font2-font6 are commonly aliased to iso106461 (Unicode)
!*VT100.utf8Fonts.font7: -sony-fixed-medium-r-normal--24-170-100-100-c-120-iso8859-1
```

```
% grep -i font /usr/local/lib/X11/app-defaults/XTerm | grep -i default
*fontMenu*fontdefault*Label:    Default
! The default fixed font and font2-font6 are commonly aliased to iso106461 (Unicode)
!                                             fontdefault/SmeBSB
!                                             fontdefault/SmeBSB
! xterm can switch at runtime between bitmap (default) and TrueType fonts.
```


---

## Laptop with an External Monitor - TODO


---

## References

**References - HiDPI and X11 (Xorg) Setup**

* [How to configure X11 in a simple way](https://eugene-andrienko.com/it/2025/07/24/x11-configuration-simple.html) by Eugene Andrienko
(Posted on 2025-07-24. Retrieved on 2025-08-31.)

* [HiDPI - ArchWiki](https://wiki.archlinux.org/title/HiDPI) 

* [HOWTO set DPI in Xorg - LinuxReviews](https://linuxreviews.org/HOWTO_set_DPI_in_Xorg)

* [Using X For A High Resolution Console On FreeBSD - By Warren Block (Last updated 2011-05-26)](https://web.archive.org/web/20241231155337/http://www.wonkity.com/~wblock/docs/pdf/hiresconsole.pdf)

* [Configure unreadable, tiny, small, ..., huge XTerm fonts](https://unix.stackexchange.com/questions/332316/configure-unreadable-tiny-small-huge-xterm-fonts)


**References - Lenovo ThinkPad T14s Gen 3 (Intel) Specifications, details**

* [ThinkPad T14 Gen 3 (14" Intel) - Powerful, portable business laptop - Lenovo website](https://www.lenovo.com/ca/en/p/laptops/thinkpad/thinkpadt/thinkpad-t14-gen-3-(14-inch-intel)/len101t0014)

* [Lenovo ThinkPad T14 Gen 3 (Intel) - PSREF (Product Specifications Reference)](https://psref.lenovo.com/syspool/Sys/PDF/ThinkPad/ThinkPad_T14_Gen_3_Intel/ThinkPad_T14_Gen_3_Intel_Spec.pdf)

* [Lenovo ThinkPad T14 Gen 3 (Intel) - The Lenovo StoryHub (Note: *i* is for Intel)](https://news.lenovo.com/wp-content/uploads/2022/02/ThinkPad-T14-Gen-3-i-Datasheet.pdf) 

* [Lenovo ThinkPad T14s Gen 3 (Intel) - NanoReview](https://nanoreview.net/en/laptop/lenovo-thinkpad-t14s-gen-3-intel?m=c%7e2043.d%7e2.r%7e32)

* [Lenovo ThinkPad T14s Gen 3 (21BR) - full specs, details and review - Product in Detail (www.productindetail.com)](https://www.productindetail.com/pn/lenovo-thinkpad-t14s-gen-3-21br)


**Reference - DPI Calculator / PPI Calculator**

* [DPI Calculator / PPI Calculator](https://www.sven.de/dpi/)

For the laptop from this post, enter: 
- Horizontal resolution: 1920 pixels
- Vertical resolution: 1200 pixels
- Diagonal: 14 inches (35.56cm)
- Aspect ratio (it was already prepopulated and was not editable): 16:10

Result:

Display size: 11.87" × 7.42" = 88.09in² (30.15cm × 18.85cm = 568.32cm²) at 161.73 PPI (pixels per inch), 0.1571mm [dot pitch](https://en.wikipedia.org/wiki/Dot_pitch), 26155 PPI² (pixels per square inch)


**References - Fractional scaling, font size, DPI (font scaling)** 

* [Best display for T14/P14s Gen 3 - About unavialibility of Fractional scaling in X11 under *NIX](https://old.reddit.com/r/thinkpad/comments/wib0t0/best_display_for_t14p14s_gen_3/)

* [FreeBSD Desktop - Part 3 - X11 Window System - by vermaden](https://vermaden.wordpress.com/2018/05/22/freebsd-desktop-part-3-x11-window-system/)


**References - Some people had issues with T14s' screen** 

* [Regretting Buying T14s](https://old.reddit.com/r/thinkpad/comments/1n0jhxn/regretting_buying_t14s/)
> Got a used T14s gen 1 and am kind of regretting the purchase, mainly because of the screen quality.
> 
> First few days of using it gave me such eye strain and dizziness, I seriously considered going back to a MacBook, even though I don't really like the OS. Watching videos are fine but somehow text appears fuzzy, how has this not been mentioned more online?


**References - Larger XTerm fonts on HiDPI displays, Unicode, Bitmap**

* [Larger XTerm fonts on HIDPI displays](https://unix.stackexchange.com/questions/219370/larger-xterm-fonts-on-hidpi-displays)

- PS8: vncdesk <https://github.com/feklee/vncdesk> is a good tool to use to scale up a single window:
-- [How to use Xfig on high DPI screen?](https://unix.stackexchange.com/questions/192493/how-to-use-xfig-on-high-dpi-screen#202277)

* [How to increase the default font size? - FreeBSD Forums](https://forums.freebsd.org/threads/how-to-increase-the-default-font-size.73261/)

* [Courier New-like font with Unicode support?](https://graphicdesign.stackexchange.com/questions/5697/courier-new-like-font-with-unicode-support)

* [Per-application window scaling in Xorg for high DPI display](https://superuser.com/questions/950794/per-application-window-scaling-in-xorg-for-high-dpi-display)

* [XTERM - Terminal emulator for the X Window System - Thomas E. Dickey's software development projects -- invisible-island.net](https://invisible-island.net/xterm/)
> Thomas Dickey is the maintainer/developer of xterm, the standard terminal emulator for the X Window System.
> This page gives some background and pointers to xterm resources.
>
>
> From [XTerm FAQ](https://invisible-island.net/xterm/xterm.faq.html):
> 
> **What is XTerm?**
> 
> From the manual page:
>
> ```
> The xterm program is a terminal emulator for the X Window System. It provides DEC VT102/VT220 and selected features from higher-level terminals such as VT320/VT420/VT520 (VTxxx). It also provides Tektronix 4014 emulation for programs that cannot use the window system directly. If the underlying operating system supports terminal resizing capabilities (for example, the SIGWINCH signal in systems derived from 4.3bsd), xterm will use the facilities to notify programs running in the window whenever it is resized.
> ```
> 
> That is, xterm (pronounced "*eks*-term") is a *specific* program, not a generic item.
> It is the *standard* X terminal emulator program.
> 
> [ . . . ]
> 
> As a stylistic convention, the capitalized form is "*XTerm*", which *corresponds* to the *X resource class name*.
> Similarly, *uxterm* becomes "*UXTerm*".
> 
> **The bold font is ugly**
>
> XTerm lets you directly specify one bold font, which is assumed to correspond to the default font.
> Older versions of xterm make a fake bold font for the other choices via the fonts menu by drawing the characters offset by one pixel.
> I modified xterm to ask the font server for a bold font that corresponds to each font (other than the default one).
> Usually that works well.
> However, sometimes the font server gives a poor match.
> Xterm checks for differences in the alignment and size, but the font server may give incorrect information about the font size.
> The scaled bitmap font feature gives poor results for the smaller fonts.
> In your X server configuration file, that can be fixed by disabling the feature, e.g., by appending ":unscaled" to the path:
>
> ``` 
> FontPath    "/usr/lib/X11/fonts/100dpi/:unscaled"
> FontPath    "/usr/lib/X11/fonts/75dpi/:unscaled"
> FontPath    "/usr/lib/X11/fonts/misc/:unscaled"
> ``` 
> 
> You can suppress xterm's overstriking for bold fonts using the ```alwaysBoldMode``` and related resources.
> However, rendering ugly bold fonts is a "feature" of the font server.
> In particular, the TrueType interface provides less ability to the client for determining if a particular font supports a bold form.

* [Hidden gems of XTerm](https://lukas.zapletalovi.com/posts/2013/hidden-gems-of-xterm/)
> One important note for users with **bitmap fonts**:
> Always select sizes which the fonts are prepared for.
> If you don't stick with this rule, you will end up with slow and ugly resampled fonts which is something you don't want to see. 
> In my case, make sure the sizes match installed fonts (the directory can differ in you distribution - this is Fedora 19):
>
> ```
> grep medium /usr/share/fonts/terminus/fonts.dir | grep iso10646
> ter-x12n.pcf.gz -xos4-terminus-medium-r-normal--12-120-72-72-c-60-iso10646-1
> ter-x14n.pcf.gz -xos4-terminus-medium-r-normal--14-140-72-72-c-80-iso10646-1
> ter-x16n.pcf.gz -xos4-terminus-medium-r-normal--16-160-72-72-c-80-iso10646-1
> ter-x18n.pcf.gz -xos4-terminus-medium-r-normal--18-180-72-72-c-100-iso10646-1
> ter-x20n.pcf.gz -xos4-terminus-medium-r-normal--20-200-72-72-c-100-iso10646-1
> ter-x22n.pcf.gz -xos4-terminus-medium-r-normal--22-220-72-72-c-110-iso10646-1
> ter-x24n.pcf.gz -xos4-terminus-medium-r-normal--24-240-72-72-c-120-iso10646-1
> ter-x28n.pcf.gz -xos4-terminus-medium-r-normal--28-280-72-72-c-140-iso10646-1
> ter-x32n.pcf.gz -xos4-terminus-medium-r-normal--32-320-72-72-c-160-iso10646-1
> ```
> 
> As you can see sizes for the Terminus font are 12, 14, 16, 18, 20, 22, 24, 28 and 32.
> Note there are keyboard shortcuts for font size, more about them later on.
>
> [ . . . ]


* [Electronic Font Open Laboratory - /efont/](http://openlab.ring.gr.jp/efont/)
> Distributions
> 
> * efont-unicode-bdf/
>   The **Bitmap** Font for Unicode.
> * shinonome-font/
>   BDF **bitmap** font by Yasuyuki Furukawa. Contains 12, 14 and 16 dot fonts. 
> * efont-japanese-bdf-collection/
>   The archive which includes Japanese (i.e. JISX0201, 0208 and 0213) and Roman (ISO8859-1) Fonts of some sizes.
> * efont-serif/
>   The **modifiable** and **distributable** outline font which is based on Roman type and Mincho type. We are planning to distribute it in TrueType and CID Type-1 formats. The development started on November 29, 2000. Designers and testers are wanted.
> * bdfresize/
>    Bdfresize is a command to magnify or reduce fonts which are described with the standard BDF format. The original author Hiroto Kagotani was pleased to hand over its maintenance to the /efont/. 

* [Fixed (typeface) -- misc-fixed -- a collection of monospace bitmap fonts distributed with the X Window System -- Wikipedia](https://en.wikipedia.org/wiki/Fixed_(typeface))
(Retrieved on Aug 31, 2025.)
> **misc-fixed** is a collection of monospace bitmap fonts that is distributed with the X Window System.
> It is a set of independent bitmap fonts which—apart from all being sans-serif fonts—cannot be described as belonging to a single font family.
> The misc-fixed fonts were the first fonts available for the X Window System.
> Their individual origin is not attributed, but it is likely that many of them were created in the early or mid 1980s as part of MIT's Project Athena, or at its industrial partner, DEC.
> The misc-fixed fonts are in the public domain.
>
> The individual fonts in the collection have a short name that matches their respective pixel dimensions, plus a letter that indicates a bold or oblique variant.
> They can also be accessed using their (much longer) *X Logical Font Description* string:
> 
> ``` 
> 5x7 	-Misc-Fixed-Medium-R-Normal--7-70-75-75-C-50-ISO10646-1
> 5x8 	-Misc-Fixed-Medium-R-Normal--8-80-75-75-C-50-ISO10646-1
> [ . . . ]
> ``` 
>
> The "6x13" font is usually also available under the alias "fixed", a font name that is expected to be available on every X server.
>
> The fonts originally covered only the ASCII repertoire, and were in the early 1990s extended to cover all characters in ISO 8859-1.
> In 1997, Markus Kuhn initiated and headed a project to extend the misc-fixed fonts to as large a subset of *Unicode/ISO 10646* as is feasible for each of the available font sizes
>  This project's goal was to get Linux developers interested in abandoning the 1990s dominant ISO 8859-1 encoding, in favour of using UTF-8 instead, which happened indeed within a few years.
> 
> [ . . . ]
> 
> The 6x13, 8x13, 9x15, 9x18, and 10x20 fonts cover a much larger repertoire, that covers in addition the comprehensive CEN MES-3A European Unicode 3.2 subset, the International Phonetic Alphabet, Armenian, Georgian, Thai, Yiddish, all Latin, Greek, and Cyrillic characters, all mathematical symbols (including the entire TeX repertoire), APL, Braille, Runes, and much more. 9x15 and 10x20 also cover Ethiopic.
> 
> The misc-fixed fonts have been much less commonly used since support for scalable outline font formats such as *Type 1*, *TrueType* and *OpenType* has become available for X.
> However, they are still commonly used with terminal emulators, such as *XTerm*, and as a fallback font for the many Unicode characters not yet found in common outline fonts.
> 
> The fonts are distributed in the *BDF* format and are currently maintained by Markus Kuhn.
>
> [ . . . ]
> 
> External links
> 
> * [Simon Tatham's Fonts Page](http://www.chiark.greenend.org.uk/~sgtatham/fonts) has, amongst other things, a Windows .FON bitmap font of the "fixed" (i.e. 6x13) font.
> * [Rasher's Rockbox related stuff - Fonts - misc](http://rasher.dk/rockbox/fonts/misc/) has all sizes of fixed-misc available as images and downloads in a .fnt format.

* [GNU Free Font's](https://www.gnu.org/software/freefont/) Free Mono - Monospace font which is legible and relatively complete in terms of Unicode coverage.


**References - The difference between PPI and DPI**

* [PPI vs. DPI – The Difference Explained Simply](https://pixelcalculator.com/en/dpi-vs-ppi-difference.php)
> PPI: Pixels per Inch – The Digital World
>
> DPI: Dots per Inch – The Printed World

* [What is the difference between DPI (dots per inch) and PPI (pixels per inch)?](https://graphicdesign.stackexchange.com/questions/6080/what-is-the-difference-between-dpi-dots-per-inch-and-ppi-pixels-per-inch)


**References - Miscellaneous**

* [Setting up FreeBSD for Lenovo Thinkpad X220 (2011 year)](https://eugene-andrienko.com/it/2020/09/26/thinkpad-x220-freebsd.html)

* [Cannot change brightness on laptop (FreeBSD 13.1) (Thread Start date: Dec 15, 2022) -- FreeBSD Forums](https://forums.freebsd.org/threads/cannot-change-brightness-on-laptop-freebsd-13-1.87460/)

* [Brightness: lxqt-config-brightness and Gammy -- FreeBSD Forums](https://forums.freebsd.org/threads/brightness-lxqt-config-brightness-and-gammy.79960/)

* [XTerm introduction and TrueType fonts configuration](https://futurile.net/2016/06/14/xterm-setup-and-truetype-font-configuration/)

* [Vi-Mode Ubiquitous Cursor Indicator](http://micahelliott.com/posts/2015-07-20-vim-zsh-tmux-cursor.html)

* [Change font size in XTerm using keyboard](https://blog.rot13.org/2010/03/change-font-size-in-xterm-using-keyboard.html)

---

## Footnotes

[1] A *monospaced* font, also called a *fixed-pitch*, *fixed-width*, or *non-proportional* font, is a font whose letters and characters each occupy the same amount of *horizontal space*.
This contrasts with variable-width fonts, where the letters and spacings have different widths.
