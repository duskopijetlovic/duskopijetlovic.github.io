---
layout: post
title: "Simple X11 Setup - Notes"
date: 2025-08-31 12:38:13 -0700 
categories: x11 xorg xterm config dotfiles howto font freebsd utf8 unicode unix 
            cli terminal shell tip 
---

# My Notes from [How to configure X11 in a simple way](https://eugene-andrienko.com/it/2025/07/24/x11-configuration-simple.html) by Eugene Andrienko
(Posted on 2025-07-24. Retrieved on 2025-08-31.)

# High DPI (HighDPI) Display 

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
 
% xdpyinfo | grep -B2 resolution
screen #0:
  dimensions:    1920x1200 pixels (294x184 millimeters)
  resolution:    166x166 dots per inch
```

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
    DisplaySize 301.50 188.50
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


**References - HiDPI and X11 (Xorg) Setup**

* [How to configure X11 in a simple way](https://eugene-andrienko.com/it/2025/07/24/x11-configuration-simple.html) by Eugene Andrienko
(Posted on 2025-07-24. Retrieved on 2025-08-31.)

* [HiDPI - ArchWiki](https://wiki.archlinux.org/title/HiDPI) 

* [HOWTO set DPI in Xorg - LinuxReviews](https://linuxreviews.org/HOWTO_set_DPI_in_Xorg)

* [Using X For A High Resolution Console On FreeBSD - By Warren Block (Last updated 2011-05-26)](https://web.archive.org/web/20241231155337/http://www.wonkity.com/~wblock/docs/pdf/hiresconsole.pdf)

* [Configure unreadable, tiny, small, ..., huge Xterm fonts](https://unix.stackexchange.com/questions/332316/configure-unreadable-tiny-small-huge-xterm-fonts)


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


**References - Larger xterm fonts on HiDPI displays**

* [Larger xterm fonts on HIDPI displays](https://unix.stackexchange.com/questions/219370/larger-xterm-fonts-on-hidpi-displays)

- PS8: vncdesk <https://github.com/feklee/vncdesk> is a good tool to use to scale up a single window:
-- [How to use Xfig on high DPI screen?](https://unix.stackexchange.com/questions/192493/how-to-use-xfig-on-high-dpi-screen#202277)

* [How to increase the default font size? - FreeBSD Forums](https://forums.freebsd.org/threads/how-to-increase-the-default-font-size.73261/)


https://graphicdesign.stackexchange.com/questions/5697/courier-new-like-font-with-unicode-support

https://superuser.com/questions/950794/per-application-window-scaling-in-xorg-for-high-dpi-display

https://lukas.zapletalovi.com/posts/2013/hidden-gems-of-xterm/

http://openlab.ring.gr.jp/efont/


**References - The difference between PPI and DPI**

* [PPI vs. DPI – The Difference Explained Simply](https://pixelcalculator.com/en/dpi-vs-ppi-difference.php)
> PPI: Pixels per Inch – The Digital World
>
> DPI: Dots per Inch – The Printed World

* [What is the difference between DPI (dots per inch) and PPI (pixels per inch)?](https://graphicdesign.stackexchange.com/questions/6080/what-is-the-difference-between-dpi-dots-per-inch-and-ppi-pixels-per-inch)

---


