---
layout: post
title: "How to Configure X (X.Org, X11) for Multi-Head with Two Separate \
Screens aka Zaphod Method"
date: 2021-12-12 21:53:55 -0700 
categories: x11 unix howto dotfiles
---

**tl;dr:**    

Goal:  
Dual-output/single-GPU/two independent screens - a configuration called **Zaphod**.   

Use two outputs from a system with a single graphics card or a single 
on-board video (integrated graphics), with a dual screen configuration 
so that there are two completely separate (independent) ```:0.0``` 
and ```:0.1``` screens that have nothing to do with each other; that is,
the origin of each screen is (0,0).   

This is known as a **multi-head** setup (sometimes called **multiseat**,
or **multi-seat**, or **dual head**, or a **Zaphod** configuration).  


One of the reasons why:   
I don't want a single screen so that; for example, dialogs that are 
intended to be positioned in the centre of a display always display 
in the middle of span across monitors in a dual-monitor configuration.

To accomplish this, you need to:   
1. Use two ```Screen``` sections (in the **xorg.conf** file) referring 
   to the device Identifiers.  For example, you can call 
   them: ```Identifier "Screen0``` 
   and ```Identifier "Screen1"```
2. Two ```Device``` sections (in the **xorg.conf** file) with:   
Option "ZaphodHeads" "yourdevice"   
(yourdevice is given by xrandr(1) tool)   
Option "AccelMethod" "sna"   
(In my tests, AccelMethod wasn't needed when used 
 with ```modesetting```, while it was required when used 
 with ```intel``` driver.) 
3. (Only needed when used with graphics card drivers so you don't need 
   this step if you will use ```modesetting``` driver): Install the card's 
   driver (package names: xf86-video-*).  Most xf86-video-\* drivers 
   support Zaphod mode, which allows for a single device to produce 
   multiple X screens.  For example, for a graphics card with 
   an Intel chipset, you need to install the intel graphics 
   driver: ```pkg installxf86-video-intel```.   

On recent FreeBSD versions, including FreeBSD 13, you would typically install
[drm-kmod metaport](https://www.freshports.org/graphics/drm-kmod/), 
which enables the integrated graphics chip on Intel CPUs (Intel Integrated 
Graphics, aka HD Graphics).  With **drm-kmod**, X.Org autodetects the driver, 
and utilizes the [**modesetting** X.Org driver](https://www.x.org/wiki/ModeSetting/) 
and/or [glamor driver](https://www.freedesktop.org/wiki/Software/Glamor/).

It's recommened to use the **modesetting** driver but the use of specific 
chipset graphics drivers is not discouraged if it's needed.   

---- 

Operating system and hardware used:   

FreeBSD 13.0  
**csh** shell  
[**twm** - Tab Window Manager for the X Window System](https://www.x.org/releases/X11R7.6/doc/man/man1/twm.1.xhtml)  [¹](#footnotes)    
Laptop: [Lenovo ThinkPad X280 | Ultraportable 12.5" Business Laptop](https://www.lenovo.com/us/en/p/laptops/thinkpad/thinkpadx/thinkpad-x280/22tp2tx2800)    
External monitor: [LG 29'' Class 21:9 UltraWide FHD IPS Monitor with HDR10 (29'' Diagonal)](https://www.lg.com/us/monitors/lg-29WL500-B-led-monitor)      


```
% freebsd-version
13.0-RELEASE-p5

% ps $$
  PID TT  STAT    TIME COMMAND
19567  3  Ss   0:00.09 -tcsh (tcsh)

% uname -a
FreeBSD machine1.home.arpa 13.0-RELEASE-p4 FreeBSD 13.0-RELEASE-p4 
  #0: Tue Aug 24 07:33:27 UTC 2021     
  root@amd64-builder.daemonology.net:/usr/obj/usr/src/amd64.amd64/sys/GENERIC
  amd64
``` 

**Note:**   
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.


## Two Methods of Setting Up

**NOTE:**   
These methods have been tested on a laptop (notebook) with a dual-head 
**Intel** graphics card with two physical monitor connections.     
There might be other methods available for different configurations; 
for example, with a dual-head Nvidia graphics cards or AMD Radeon 
chipsets (package name in FreeBSD: xf86-video-amdgpu). 

Other possibilites include Xinerama or Xypher. [²](#footnotes)    


The two methods explained here are a static setup in ```xorg.conf``` with:   
1. **Intel** video driver - Xorg driver for Intel integrated graphics chipsets
2. **modesetting** - video driver for framebuffer device

Each of the two drivers has its own man page: 
```man modesetting```, ```man intel```.

**Note:**   
You can also set up dual head dynamically by using ```xrandr(1)``` tool; 
however, this tool doesn't provide support for **Zaphod** mode.  In other
words, with ```xrandr(1)``` you can quickly configure two monitors but 
the display is one screen, not two independent screens. 

xrandr(1) tool is a command line interface to RandR (Rotate and Resize) 
extension [³](#footnotes), and can be used to set outputs for a screen dynamically, 
without adding any specific settings in xorg.conf. 

Starting with RandR 1.2, you can set up dual head and add/remove 
a monitor without restarting X.

----

### Configuration with Xorg driver for Intel Integrated Graphics Chipsets - Method 1 of 2
 

On FreeBSD 13, the **xorg.conf** is located in the  
directory ```/usr/local/etc/X11/xorg.conf.d/```. [⁴](#footnotes)   

#### X11 Window System Configuration

From   
[FreeBSD Desktop – Part 3 – X11 Window System](https://vermaden.wordpress.com/tag/xdm/)    
(Posted on May 22, 2018)   
(Retrieved on Dec 12, 2021)   

> Historically you would create entire ```/etc/X11/xorg.conf``` file 
> which would include complete X11 Window System configuration. 
>  
> Recently to comply with FreeBSD ```hier(7)``` directory structure and 
> logic this can be also configured as ```/usr/local/etc/X11/xorg.conf``` 
> file and even more recently you can just configure these parts of X11 
> server that you need without touching other parts.  
>   
> This ‘individual’ configuration is done in 
> the ```/usr/local/etc/X11/xorg.conf.d``` directory with 
> individual files for each setting, like ```card.conf``` for 
> graphics card configuration.


```
% pciconf -lv | grep -A4 vga
vgapci0@pci0:0:2:0:     class=0x030000 rev=0x07 hdr=0x00 vendor=0x8086 device=0x
5917 subvendor=0x17aa subdevice=0x2256
    vendor     = 'Intel Corporation'
    device     = 'UHD Graphics 620'
    class      = display
    subclass   = VGA
```


On the Lenovo x280 laptop with an external monitor plugged in:  

```
% xrandr --listproviders
Providers: number : 1
Provider 0: id: 0x47 cap: 0xa, Sink Output, 
  Sink Offload crtcs: 3 outputs: 5 associated providers: 0 name:modesetting
```


Install the X.Org legacy driver for Intel integrated graphics 
chipsets (package name: xf86-video-intel).


```
% sudo pkg install xf86-video-intel
```

The content of the ```card.conf``` configuration file for graphics card 
configuration (in this example, I had created this file previously, 
customizing it for **modesetting** video driver).  Here's how it looked 
before changing it to include the X.Org legacy driver for Intel 
integrated graphics chipsets:
 
```
% cat /usr/local/etc/X11/xorg.conf.d/card.conf
Section "Device"
    Identifier "Card0"
    Driver "modesetting"
EndSection
```

**Note:**  
You can designate the graphics card to work with the Intel driver by 
using the following ```Device``` section (but it would still be 
a **single** extended display over two monitors):    

```
% cat /usr/local/etc/X11/xorg.conf.d/card.conf
Section "Device"
    Identifier "Card0"
    Driver     "intel"
    BusID      "PCI:0:2:0"
EndSection
```

The value for BusID line is obtained from the first line of the output  
of the command ```pciconf -lv | grep -A4 vga``` ran above. 


Modify the **card.conf** to include the X.Org Intel legacy driver and 
to configure **two** ```Identifer``` sections (with ```Option``` set 
to ```ZaphodHeads```).  

```
% sudo vi /usr/local/etc/X11/xorg.conf.d/card.conf
```

```
Section "Device"
  Identifier "Intel0"
  Driver     "intel"
  Option     "ZaphodHeads" "HDMI-2"
  Option     "AccelMethod" "sna"
  Option     "DPMS"
  Screen     0
  #BusID      "PCI:0:2:0"
EndSection
 
Section "Device"
  Identifier "Intel1"
  Driver     "intel"
  Option     "ZaphodHeads" "eDP-1"
  Option     "AccelMethod" "sna"
  Option     "DPMS"
  Screen     1
  #BusID      "PCI:0:2:0"
EndSection
```

The BusID line is optional.  

To obtain individual screen resolutions, use the randr(1) command.

On the Lenovo x280 laptop with the external monitor, 
LG 29'' 21:9 UltraWide FHD IPS Monitor plugged in:   


```
% xrandr
Screen 0: minimum 320 x 200, current 4480 x 1080, maximum 16384 x 16384
eDP-1 connected primary 1920x1080+0+0 
  (normal left inverted right x axis y axis) 276mm x 155mm
   1920x1080     60.05*+  60.01    59.97    59.96    59.93  
---- snip ----
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-1 disconnected (normal left inverted right x axis y axis)
DP-2 disconnected (normal left inverted right x axis y axis)
HDMI-2 connected 2560x1080+1920+0 
  (normal left inverted right x axis y axis) 798mm x 334mm
   2560x1080     59.98*+  74.99    50.00  
---- snip ----
```


The dimesions (geometry), a.k.a. ```x resolution``` (horizontal resolution) 
and ```y resolution``` (vertical resolution) values:   

for the built-in screen (on the output **eDP-1**): 1920x1080    
for the external monitor (on the output **HDMI-2**): 2560x1080    


```
        |--> X

        0               1920                     4480
- 0     +----------------+------------------------+
|       |                |                        |
|       |     eDP-1      |        HDMI-2          |
v       |   1920x1080    |       2560x1080        |
        |                |                        |
1080    +----------------+------------------------+

        |<- width=1920 ->|<-     width=2560     ->|
```


```
% xdpyinfo | grep -A1 '^screen'
screen #0:
  dimensions:    4480x1080 pixels (1185x285 millimeters)
```


Currently, two outputs form **a single display** (a.k.a. extended display) 
with the geometry (dimensions) of **4480x1080**; that is, 
**width = 4480** and **height = 1080**.  

The goal is to modify this setup and create a dual layout X.Org 
configuration file with two **independent** outputs.  


```
% sudo vi /usr/local/etc/X11/xorg.conf.d/layout.conf
```


```
% cat /usr/local/etc/X11/xorg.conf.d/layout.conf
Section "ServerLayout"
    Identifier     "DualHeadConf"
    Screen      0  "Screen0" 1920 0
    Screen      1  "Screen1"    0 0
EndSection
```

For the Intel driver kernel module to be loaded at startup in the boot process
you need to add this line in ```/etc/rc.conf```:

```
kld_list="i915kms"
```

**Note:**   
In previous FreeBSD releases, you would need to add a line ```kern.vty=vt```
to ```/boot/loader.conf``` but that's not needed anymore as this is the 
default in new FreeBSD releases.

Resource:   
[FreeBSD Handbook - Chapter 5. The X Window System -  5.4.3. Kernel Mode Setting (KMS)](https://docs.freebsd.org/en/books/handbook/x11/)    
(Retrieved on Dec 12, 2021)   

> When the computer switches from displaying the console to a higher 
> screen resolution for X, it must set the video output mode. 
> Recent versions of Xorg use a system inside the kernel to do these mode 
> changes more efficiently.  Older versions of FreeBSD use sc(4), which 
> is not aware of the KMS system.  The end result is that after closing X, 
> the system console is blank, even though it is still working. 
> The newer vt(4) console avoids this problem.
> 
> Add this line to /boot/loader.conf to enable vt(4):
> 
> ```
> kern.vty=vt
> ```

----

Find out ```Modeline``` values for the output **eDP-1** 
(the built-in laptop screen).

```
% grep -i modeline /var/log/Xorg.0.log | wc -l
      68
```

**Note:**   
Instead of obtaining ```Modeline``` values from Xorg log file, you can 
use ```cvt(1)``` (a utility for calculating VESA Coordinated Video 
Timing modes) or ```gtf(1)``` (a utility for calculating VESA GTF modes).   
See examples below; immediately after the section showing how to 
obtain ```Modeline``` values from the Xorg log file. 


```
% grep -n 'Printing probed modes for output eDP-1' /var/log/Xorg.0.log
179:[   106.950] (II) intel(0): Printing probed modes for output eDP-1
```

```
% sed -n 179,211p Xorg.0.log | wc -l
      33
```


Filtering out for the highest refresh rate, which for this output is 60 Hz: 

```
% sed -n 179,211p Xorg.0.log | grep x60 | wc -l
      10
```

```
% sed -n 179,211p Xorg.0.log | grep x60 | grep '1920x1080' | wc -l
       2
```

**Note:**   
The long lines are folded and then indented to make sure they fit the page.

```
% sed -n 179,211p Xorg.0.log | grep x60 | grep '1920x1080'
[   106.950] (II) intel(0): Modeline "1920x1080"x60.0  
  141.00  1920 1936 1952 2104  1080 1083 1097 1116 -hsync -vsync (67.0 kHz eP)
[   106.950] (II) intel(0): Modeline "1920x1080"x60.0  
  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync (67.2 kHz d)
```


Similarly, find out ```Modeline``` values for the output **HDMI-2**   
(the external 29'' LG monitor).  

```
% grep -n 'Printing probed modes for output HDMI-2' /var/log/Xorg.0.log
285:[   107.364] (II) intel(0): Printing probed modes for output HDMI-2
```

```
% sed -n 285,319p /var/log/Xorg.0.log | wc -l
      35
```


Filtering out for the highest refresh rate, which for this output is 75 Hz: 

```
% sed -n 285,319p /var/log/Xorg.0.log | grep x75 | wc -l
       7
```

```
% sed -n 285,319p /var/log/Xorg.0.log | grep x75 | grep '2560x1080' | wc -l
       1
```

```
% sed -n 285,319p /var/log/Xorg.0.log | grep x75 | grep '2560x1080'
[   107.364] (II) intel(0): Modeline "2560x1080"x75.0  
  228.25  2560 2608 2640 2720  1080 1083 1093 1119 +hsync -vsync (83.9 kHz e)
```

If you wanted to calculate ```Modeline``` values with ```cvt(1)``` 
(usage: ```cvt [-v|--verbose] [-r|--reduced] h-resolution v-resolution [refresh]```), 
where ```--verbose``` is "Warn verbosely when a given mode does not 
completely correspond with CVT standards", or with ```gtf(1)```
(usage: ```gtf x y refresh [-v|--verbose] [-f|--fbmode] [-x|--xorgmode]```), 
where ```--verbose``` is: "Enable verbose printouts  This shows a trace 
for each step of the computation".    
For both ```cvt(1)``` and ```gtf(1)```: 
```x``` : the desired horizontal resolution; 
```y``` : the desired vertical resolution; 
```refresh``` : the desired refresh rate.


```
% cvt --verbose 1920 1080 60
# 1920x1080 59.96 Hz (CVT 2.07M9) hsync: 67.16 kHz; pclk: 173.00 MHz
Modeline "1920x1080_60.00"  
  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
```

```
% cvt --verbose 2560 1080 75
Warning: Aspect Ratio is not CVT standard.
# 2560x1080 74.94 Hz (CVT) hsync: 84.68 kHz; pclk: 294.00 MHz
Modeline "2560x1080_75.00"  
  294.00  2560 2744 3016 3472  1080 1083 1093 1130 -hsync +vsync
```

```
% gtf 1920 1080 60 --verbose
 1: [H PIXELS RND]             :     1920.000000
 2: [V LINES RND]              :     1080.000000
 3: [V FIELD RATE RQD]         :       60.000000
 4: [TOP MARGIN (LINES)]       :        0.000000
 5: [BOT MARGIN (LINES)]       :        0.000000
 6: [INTERLACE]                :        0.000000
 7: [H PERIOD EST]             :       14.909035
 8: [V SYNC+BP]                :       37.000000
 9: [V BACK PORCH]             :       34.000000
10: [TOTAL V LINES]            :     1118.000000
11: [V FIELD RATE EST]         :       59.994118
12: [H PERIOD]                 :       14.907574
13: [V FIELD RATE]             :       59.999996
14: [V FRAME RATE]             :       59.999996
15: [LEFT MARGIN (PIXELS)]     :        0.000000
16: [RIGHT MARGIN (PIXELS)]    :        0.000000
17: [TOTAL ACTIVE PIXELS]      :     1920.000000
18: [IDEAL DUTY CYCLE]         :       25.527727
19: [H BLANK (PIXELS)]         :      656.000000
20: [TOTAL PIXELS]             :     2576.000000
21: [PIXEL FREQ]               :      172.798065
22: [H FREQ]                   :       67.079994
17: [H SYNC (PIXELS)]          :      208.000000
18: [H FRONT PORCH (PIXELS)]   :      120.000000
36: [V ODD FRONT PORCH(LINES)] :        1.000000

  # 1920x1080 @ 60.00 Hz (GTF) hsync: 67.08 kHz; pclk: 172.80 MHz
  Modeline "1920x1080_60.00"  
    172.80  1920 2040 2248 2576  1080 1081 1084 1118  -HSync +Vsync
```


```
% gtf 2560 1080 75 --verbose
 1: [H PIXELS RND]             :     2560.000000
 2: [V LINES RND]              :     1080.000000
 3: [V FIELD RATE RQD]         :       75.000000
 4: [TOP MARGIN (LINES)]       :        0.000000
 5: [BOT MARGIN (LINES)]       :        0.000000
 6: [INTERLACE]                :        0.000000
 7: [H PERIOD EST]             :       11.825470
 8: [V SYNC+BP]                :       47.000000
 9: [V BACK PORCH]             :       44.000000
10: [TOTAL V LINES]            :     1128.000000
11: [V FIELD RATE EST]         :       74.967407
12: [H PERIOD]                 :       11.820331
13: [V FIELD RATE]             :       75.000000
14: [V FRAME RATE]             :       75.000000
15: [LEFT MARGIN (PIXELS)]     :        0.000000
16: [RIGHT MARGIN (PIXELS)]    :        0.000000
17: [TOTAL ACTIVE PIXELS]      :     2560.000000
18: [IDEAL DUTY CYCLE]         :       26.453901
19: [H BLANK (PIXELS)]         :      928.000000
20: [TOTAL PIXELS]             :     3488.000000
21: [PIXEL FREQ]               :      295.084808
22: [H FREQ]                   :       84.600006
17: [H SYNC (PIXELS)]          :      280.000000
18: [H FRONT PORCH (PIXELS)]   :      184.000000
36: [V ODD FRONT PORCH(LINES)] :        1.000000

  # 2560x1080 @ 75.00 Hz (GTF) hsync: 84.60 kHz; pclk: 295.08 MHz
  Modeline "2560x1080_75.00"  
    295.08  2560 2744 3024 3488  1080 1081 1084 1128  -HSync +Vsync
```

Create ```Monitor``` sections and a ```Screen``` section.

```
% sudo vi /usr/local/etc/X11/xorg.conf.d/monitors.conf 
```

```
% cat /usr/local/etc/X11/xorg.conf.d/monitors.conf 
Section "Monitor"
    Identifier "eDP-1"
    Modeline "1920x1080x60.00"  141.00  1920 1936 1952 2104  1080 1083 1097 1116 -hsync -vsync
    Option "DPMS" "true"   # DPMS (Display Power Management Signaling)
EndSection

Section "Monitor"
    Identifier "HDMI-2"
    Modeline "2560x1080x75.00"  228.25  2560 2608 2640 2720  1080 1083 1093 1119 +hsync -vsync 
    Option "DPMS" "true"   # DPMS (Display Power Management Signaling)
EndSection

# A Screen section ties a device (video card) to a monitor at a specific 
# colour depth and set of display resolutions. 

Section "Screen"
    Identifier "Screen0"
    Monitor "HDMI-2"
    DefaultDepth 24
    Device "Intel0"
    SubSection "Display"
        Modes "2560x1080x75.00"
        Viewport   1920 0
        Depth       24
    EndSubSection
EndSection

Section "Screen"
    Identifier "Screen1"
    Monitor "eDP-1"
    DefaultDepth 24
    Device "Intel1"
    SubSection "Display"
        Modes "1920x1080x60.00"
        Viewport   0 0
        Depth     24
    EndSubSection
EndSection
```

The whole **xorg.conf** file:

```
% cat /usr/local/etc/X11/xorg.conf.d/card.conf; printf %s\\n; \
 cat /usr/local/etc/X11/xorg.conf.d/fonts.conf; printf %s\\n; \
 cat /usr/local/etc/X11/xorg.conf.d/keyboard.conf; printf %s\\n; \
 cat /usr/local/etc/X11/xorg.conf.d/layout.conf; printf %s\\n; \
 cat /usr/local/etc/X11/xorg.conf.d/modules.conf; printf %s\\n; \
 cat /usr/local/etc/X11/xorg.conf.d/monitors.conf
Section "Device"
  Identifier "Intel0"
  Driver     "intel"
  Option     "ZaphodHeads" "HDMI-2"
  Option     "AccelMethod" "sna"
  Option     "DPMS"
  Screen     0
  #BusID      "PCI:0:2:0"
EndSection
 
Section "Device"
  Identifier "Intel1"
  Driver     "intel"
  Option     "ZaphodHeads" "eDP-1"
  Option     "AccelMethod" "sna"
  Option     "DPMS"
  Screen     1
  #BusID      "PCI:0:2:0"
EndSection

Section "Files"
    FontPath "/usr/local/share/fonts/dejavu/"
EndSection

Section "InputClass"
    Identifier "All Keyboards"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "us, rs(latinunicode), rs"
    Option "XkbOptions" "ctrl:nocaps,grp:rctrl_toggle"
EndSection

Section "ServerLayout"
    Identifier     "DualHeadConf"
    Screen      0  "Screen0" 1920 0
    Screen      1  "Screen1"    0 0
EndSection

Section "Module"
    Load "freetype"
EndSection

Section "Monitor"
    Identifier "eDP-1"
    Modeline "1920x1080x60.00"  141.00  1920 1936 1952 2104  1080 1083 1097 1116 -hsync -vsync
    Option "DPMS" "true"   # DPMS (Display Power Management Signaling)
EndSection

Section "Monitor"
    Identifier "HDMI-2"
    Modeline "2560x1080x75.00"  228.25  2560 2608 2640 2720  1080 1083 1093 1119 +hsync -vsync
    Option "DPMS" "true"   # DPMS (Display Power Management Signaling)
EndSection

# A Screen section ties a device (video card) to a monitor at a specific
# colour depth and set of display resolutions.

Section "Screen"
    Identifier "Screen0"
    Monitor "HDMI-2"
    DefaultDepth 24
    Device "Intel0"
    SubSection "Display"
        Modes "2560x1080x75.00"
        Viewport    1920 0
        Depth       24
    EndSubSection
EndSection

Section "Screen"
    Identifier "Screen1"
    Monitor "eDP-1"
    DefaultDepth 24
    Device "Intel1"
    SubSection "Display"
        Modes "1920x1080x60.00"
        Viewport   0 0
        Depth     24
    EndSubSection
EndSection
```

Restart Xorg.  

```
% pkill Xorg
```

----

After restarting Xorg:

```
% xdpyinfo | grep -A1 '^screen'
screen #0:
  dimensions:    2560x1080 pixels (677x285 millimeters)
--
screen #1:
  dimensions:    1920x1080 pixels (508x285 millimeters)
```


On the external monitor (output: HDMI-2):

```
% xrandr --listproviders
Providers: number : 1
Provider 0: id: 0x43 cap: 0xb, Source Output, Sink Output, 
  Sink Offload crtcs: 2 outputs: 2 associated providers: 0 name:Intel
```

```
% xrandr
Screen 0: minimum 8 x 8, current 2560 x 1080, maximum 32767 x 32767
HDMI-2 connected primary 2560x1080+0+0 
 (normal left inverted right x axis y axis) 800mm x 340mm
   2560x1080x75.00  74.99*+
   2560x1080     59.98 +  74.99    50.00  
   3840x2160     30.00    25.00    24.00    29.97    23.98  
   2560x1440     59.95  
   1920x1080     74.99    60.00    50.00    59.94  
   1680x1050     59.88  
   1600x900      60.00  
   1280x1024     75.02    60.02  
   1280x800      59.91  
   1152x864      75.00    59.97  
   1280x720      60.00    50.00    59.94  
   1024x768      75.03    60.00  
   1024x576      59.97  
   832x624       74.55  
   800x600       75.00    60.32  
   720x576       50.00  
   720x480       60.00    59.94  
   640x480       75.00    60.00    59.94  
VIRTUAL1 disconnected (normal left inverted right x axis y axis)
```

On the laptop built-in screen (output: eDP-1):

```
% xrandr --listproviders
Providers: number : 1
Provider 0: id: 0xcc cap: 0xb, Source Output, Sink Output, 
  Sink Offload crtcs: 2 outputs: 2 associated providers: 0 name:Intel
```

```
% xrandr
Screen 1: minimum 8 x 8, current 1920 x 1080, maximum 32767 x 32767
eDP-1 connected primary 1920x1080+0+0
 (normal left inverted right x axis y axis) 280mm x 160mm
   1920x1080x60.00  60.05*+
   1920x1080     60.05 +  59.93  
   1680x1050     59.88  
   1400x1050     59.98  
   1600x900      60.00    59.95    59.82  
   1280x1024     60.02  
   1400x900      59.96    59.88  
   1280x960      60.00  
   1368x768      60.00    59.88    59.85  
   1280x800      59.81    59.91  
   1280x720      59.86    60.00    59.74  
   1024x768      60.00  
   1024x576      60.00    59.97    59.90    59.82  
   960x540       60.00    59.63    59.82  
   800x600       60.32    56.25  
   864x486       60.00    59.92    59.57  
   640x480       59.94  
   720x405       59.51    60.00    58.99  
   640x360       59.84    59.32    60.00  
VIRTUAL1 disconnected (normal left inverted right x axis y axis)
```

----

### Configuration with the modesetting Driver - Method 2 of 2

Use the same setup as with the configuration for the Intel video 
driver for X.Org, except for ```Device``` sections (in my setup, 
in **card.conf** file) and ```Monitor``` and ```Screen``` 
sections (in my setup, in **monitors.conf** file).   

Modify **card.conf** xorg configuration file. 

```
% sudo vi /usr/local/etc/X11/xorg.conf.d/card.conf
```

```
% cat /usr/local/etc/X11/xorg.conf.d/card.conf
Section "Device"
  Identifier "Card0"
  Driver     "modesetting"
  Option     "DPMS"
  Screen     0
  #BusID      "PCI:0:2:0"
EndSection

Section "Device"
  Identifier "Card1"
  Driver     "modesetting"
  Option     "DPMS"
  Screen     1
  #BusID      "PCI:0:2:0"
EndSection
```


Modify the **monitors.conf** xorg configuration file. 

```
% sudo vi /usr/local/etc/X11/xorg.conf.d/monitors.conf
```

```
% cat /usr/local/etc/X11/xorg.conf.d/monitors.conf
Section "Monitor"
    Identifier "eDP-1"
    Modeline "1920x1080x60.00"  141.00  1920 1936 1952 2104  1080 1083 1097 1116 -hsync -vsync
    Option "DPMS" "true"   # DPMS (Display Power Management Signaling)
EndSection

Section "Monitor"
    Identifier "HDMI-2"
    Modeline "2560x1080x75.00"  228.25  2560 2608 2640 2720  1080 1083 1093 1119 +hsync -vsync
    Option "DPMS" "true"   # DPMS (Display Power Management Signaling)
EndSection

# A Screen section ties a device (video card) to a monitor at a specific
# colour depth and set of display resolutions.

Section "Screen"
    Identifier "Screen0"
    Monitor "HDMI-2"
    DefaultDepth 24
    Device "Card0"
    Option      "ZaphodHeads" "HDMI-2"
    SubSection "Display"
        Depth       24
    EndSubSection
EndSection

Section "Screen"
    Identifier "Screen1"
    Monitor "eDP-1"
    DefaultDepth 24
    Device "Card1"
    Option      "ZaphodHeads" "eDP-1"
    SubSection "Display"
        Depth     24
    EndSubSection
EndSection
```

Restart Xorg (a.k.a. X, or X11, or X.Org).

```
% pkill Xorg
```

----

#### Footnotes

[¹] The default window manager supplied with X11 since the X11R4 release in 1989.

[²] Xephyr   
(<https://www.freedesktop.org/wiki/Software/Xephyr/>)   
> 
> Xephyr is a kdrive based X Server which targets a window on a host 
> X Server as its framebuffer.  Unlike Xnest it supports modern 
> X extensions ( even if host server doesn't ) such as Composite, Damage, 
> randr etc (no GLX support now).  It uses SHM Images and shadow 
> framebuffer updates to provide good performance. It also has a visual 
> debugging mode for observing screen updates.
> 
> Possible uses include:
>
> Xnest replacement - Window manager, Composite 'gadget', etc. development tool.   
> Toolkit debugging - rendundant toolkit paints can be observered easily 
> via the debugging mode.   
> X Server internals development - develop without the need for an extra 
> machine / display.   
> Multiterminal with Xephyr - configuration is a single computer which 
> supports multiple users at the same time.   
>
> More information   
> See the README  
> <https://cgit.freedesktop.org/xorg/xserver/tree/hw/kdrive/ephyr/README>    

[³] X Server Extensions  
The X11 can be enhanced by adding extensions to the X server. 

Examples of some of the extensions:    
DPMS: Displays Power Management Signalling. Enables the X server 
to reduce monitor power consumption when not in use.   

RANDR: Rotate and Resize.  Notifies clients when the display is resized 
to a new resolution or rotated (especially useful on laptops, tablets 
and LCDs on pivot mounts) and enables the hot-plugging of monitors. 

[⁴] Traditionally, the most important file for Xorg has been the 
**xorg.conf** configuration file.

Modern versions of Xorg do not create an **xorg.conf** file by default. 
In other words, using the ```X -configure``` is not recommended. 
Instead, on FreeBSD, various files ending in **\*.conf** reside in the 
```/usr/local/etc/X11/xorg.conf.d``` directory and are automatically 
loaded by X at boot, prior to reading any **xorg.conf**.  

Configuration files will also be searched for in a directory
reserved for system use.  This is to separate configuration files from
the vendor or 3rd party packages from those of local administration.
In FreeBSD, these files are found in the 
directory ```/usr/local/share/X11/xorg.conf.d```.

On my system used for this document:   

```
% ls -lh /usr/local/share/X11/xorg.conf.d
total 14
-rw-r--r--  1 root  wheel   1.3K Jul  4 00:26 10-quirks.conf
-rw-r--r--  1 root  wheel   152B Jul  4 00:26 20-evdev-kbd.conf
-rw-r--r--  1 root  wheel   1.4K Jul  4 00:59 40-libinput.conf
```

You should not change what is included for system use 
in ```/usr/local/share/X11/xorg.conf.d``` directory. 

It's recommended to include your customizations or to override system 
settings by creating *.conf files in 
```/usr/local/etc/X11/xorg.conf.d``` directory. 

**Note:**    
Names of these files are arbitrary and each file can contain one 
or more sections in the same format used by **xorg.conf**.  Extension of 
the files has to be '**.conf**'. 


Immediately after installing FreeBSD, I usually include the following 
two X configuration customizations:


Create a ```Module``` X configuration file to make sure that the freetype 
module is loaded.  This file has a line ```Load "freetype"``` inside 
the ```"Modules"``` section: 

```
$ cat /usr/local/etc/X11/xorg.conf.d/modules.conf 
Section "Module"
    Load "freetype"
EndSection
```

Create a keyboard layout customization file:  

```
% cat /usr/local/etc/X11/xorg.conf.d/keyboard.conf
Section "InputClass"
    Identifier "All Keyboards"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "us, rs(latinunicode), rs"
    Option "XkbOptions" "ctrl:nocaps,grp:rctrl_toggle"
EndSection
```

With this configuration 
file (```/usr/local/etc/X11/xorg.conf.d/keyboard.conf```),
pressing the right Ctrl keyboard key cycles betweeen Serbian (latin), 
Serbian (cyrillic) and English (US) keyboard layouts, 
and ```ctrl:nocaps``` to ignore the Caps Lock key.  

**Note:**   
Alternatively, you can set your keymap in your ```$HOME/.xinitrc```.
For example, you can add 
a line ```setxkbmap rs -model pc105``` 
to your ```.xinitrc``` file.


**Note:**  
You can still create the xorg.conf file and continue making custom 
configurations in ```/etc/X11/xorg.conf``` as has been 
traditionally done but the file is not created by default. 


From   
[5.4. Xorg Configuration - 5.4.1. Quick Start -- FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/x11/#x-config)  
(Retrieved on Dec 20, 2021)  

> 5.4.4.1. Directory
> 
> Xorg looks in several directories for configuration files. 
> ```/usr/local/etc/X11/``` is the recommended directory for these files 
> on FreeBSD.  Using this directory helps keep application files separate 
> from operating system files.
> 
> Storing configuration files in the legacy **/etc/X11/** still works. 
> However, this mixes application files with the base FreeBSD files and 
> is not recommended.
>  
> 5.4.4.2. Single or Multiple Files
> 
> It is easier to use multiple files that each configure a specific 
> setting than the traditional single **xorg.conf**.  These files are 
> stored in the **xorg.conf.d/** subdirectory of the main configuration 
> file directory.  The full path is typically
> ```/usr/local/etc/X11/xorg.conf.d/```.
> 
> The traditional single **xorg.conf** still works, but is neither 
> as clear nor as flexible as multiple files in the **xorg.conf.d/** 
> subdirectory.



----

#### References:

[Introduction to Multiple Monitors in X - freedesktop.org](https://nouveau.freedesktop.org/MultiMonitorDesktop.html)   

> . . . 
> ### Dual-head Graphics Cards
> 
> Then came dual-head graphics cards with two physical monitor connections 
> and things got complicated. It did not fit the one SCREEN, one card, 
> one monitor scheme, so drivers had to invent ways to circumvent 
> the X server architecture limitations.
> 
> One solution for a driver (DDX) is to create one SCREEN per head, 
> which is called **Zaphod mode** (after Zaphod Beeblebrox, from the 
> Hitchhiker's Guide to the Galaxy).  This has the drawbacks of multiple 
> SCREENs, but you get the DPI right.
> 
> Another solution is to pretend that there is only one monitor, and use 
> just one SCREEN, which is what the Nvidia TwinView mode does. 
> TwinView avoids the drawbacks of the *Xinerama* feature, but has 
> a completely non-standard way of configuring it. Plus, it is proprietary.
> 
> The third and the only proper way to deal with it is the RandR extension, 
> which is a relatively new invention. RandR exposes the dual-head card 
> as a single SCREEN, yet having a standard way of managing the multiple 
> monitors.  It avoids the Xinerama feature drawbacks, but uses 
> the Xinerama extension to provide applications information about the 
> physical monitor layout.  RandR configuration can be controlled on the 
> fly with the command xrandr, and it can be written to 
> the X configuration file.  The default configuration is cloned views, 
> i.e. all heads show the same image.


[Separate screens with xrandr](https://www.phoronix.com/forums/forum/linux-graphics-x-org-drivers/open-source-amd-linux/14280-separate-screens-with-xrandr/page4):   
> With RandR:   
> 
> This mode gives you two viewports over a single surface and the ability 
> to size and position independently. Benefit is configurability, 
> disadvantage is application support.  If you are using a RANDR 1.3 
> capable distribution, you can also set "--primary" to provide a hint to 
> gnome-panel et al. about which monitor is your "center of the universe".
> 
> Disadvantage here is that applications are mostly naive when it comes 
> to multi-monitor modes.  They may listen to the xinerama extension and 
> place things intelligently, they may not.  This goes right up and down 
> the stack.


[X.Org/Dual Monitors - Single graphics card, Multiple X screens with ZaphodHeads](https://web.archive.org/web/20130429073111/http://en.gentoo-wiki.com/wiki/X.Org/Dual_Monitors#Single_graphics_card.2C_Multiple_X_screens_with_ZaphodHeads):   
> . . . 
> ### Single graphics card, Multiple X screens with ZaphodHeads
> 
> In the previous example, a single PCI device was used to stretch 
> a screen onto two separate displays. This will demonstrate how to 
> use a single PCI device to provide two separate screens on two 
> separate displays.  This will, for instance, allow you to launch 
> one program on a given display with DISPLAY=:0.0, and on another 
> with DISPLAY=:0.1.
> 
> #### Motivation
> 
> It is often desirable to have multiple X screens produced by 
> a single VGA controller.  Most xf86-video-* drivers support 
> Zaphod mode, which allows for a single device to produce 
> multiple X screens.  With intel graphics integrated onto all 
> Sandy Bridge and higher CPUs, this is especially important.
> 
> For instance, on a machine with an on-chip graphics controller, 
> as well as a separated video card, this would allow for one 
> display for each output.
> 
> This example will focus on intel, though it should work with 
> radeon and nouveau drivers that support it.   . . .   


[Mailing List Archive: questions and sundry gripes about X11 multihead (it's a rant)](https://lists.archive.carbon60.com/gentoo/desktop/282286):   
(Posted on Dec 29, 2013)    
> After years of assuming I'd probably never set my system up with
> multiple monitors, I've decided to go ahead and do it. I've watched
> with some interest as various new schemes for doing it have
> emerged over the years (Xinerama , and now lately RandR), but
> I've always assumed that if nothing else, good old Zaphod mode
> would always be around, since it's built right into the way X11
> numbers $DISPLAY (0:0, 0:1, 0:2...etc.).
> It's been around so long, it's older than Linux itself.  
> . . . 
> 
> Anyway, Zaphod is what I want. I don't care that it won't let me
> drag windows between monitors. That's precisely the advantage
> of it. Many applications are written with such an assumption of
> a single display that it's best not to disappoint them.
> I don't want to worry about what a full screen game will think
> of my multihead setup. I don't want to see dialog windows
> (or anything else really) popping up, half on one monitor and
> half on another. I don't want to have to setup the arrangement
> of my desktop so that it's arranged to not look ridiculous at
> the point where the two monitors divide the screen. It's all
> just simpler if we have two screens that are completely
> separate, and the only magic object that's able to move
> between them is the mouse pointer.
> 
> I'm not complaining that we have RandR now. I think it's great.
> One of X11's greatest weaknesses has always been that before
> now, you couldn't really make any big configuration changes
> while the X server is running. Now, thanks to RandR, you can
> do almost anything with your desktop running and active,
> and you don't even need root access. You can't configure
> Zaphod type multihead that way, but that's fine -- you
> couldn't do that before either (nothing gained, nothing lost).
> But RandR lets you make almost any other desktop geometry
> change as a regular user without restarting X, and I think
> that's great.
>  
> RandR (and its predecessor, Xinerama) both assume though that
> if you're doing multihead, you want one big screen that spans
> multiple monitors. Nice if that's what you want, but as
> detailed above, there are good reasons why you might prefer
> otherwise.

Posted on Dec 29, 2013   
Permalink:   
<https://lists.archive.carbon60.com/gentoo/desktop/282080#282080>   

----

[Graphics FreeBSD Wiki](https://wiki.freebsd.org/Graphics) 

[How to Set Up Dual Head for Intel Graphics with RandR 1.2 - 01.org Intel Open Source](https://01.org/temp-linuxgraphics/documentation/how-set-dual-head-intel-graphics-randr-1.2)

[How to configure X for multi-head with two separate screens?](https://www.linuxquestions.org/questions/showthread.php?p=6167464)

[Separate screens - Multihead - ArchWiki](https://wiki.archlinux.org/title/Multihead#Separate_screens)

[Xorg: Independent Mode](https://unix.stackexchange.com/questions/365796/xorg-independent-mode)

[X.Org **legacy driver** for **Intel** integrated graphics chipsets -- x11-drivers/xf86-video-intel](https://www.freshports.org/x11-drivers/xf86-video-intel)

[Multiseat gaming with multi-pointer X](https://bbs.archlinux.org/viewtopic.php?id=105450)

[Switch monitors in xorg.conf in a dual screen setup](https://superuser.com/questions/1616104/switch-monitors-in-xorg-conf-in-a-dual-screen-setup)

[NYC*BUG dmesgd](https://dmesgd.nycbug.org/index.cgi)    
> Launched in 2004, dmesgd aims to provide a **user-submitted** repository of 
> searchable *BSD dmesgs.  The dmesg(8) command displays the system message 
> buffer's content, and during boot a copy is saved to /var/run/dmesg.boot. 
> 
> This buffer contains the operating system release, name and version, 
> a list of devices identified, plus a whole host of other useful information. 
> 
> We hope others find this resource useful and further contribute to its growth. 
> Contact us at [ admin at lists dot nycbug dot org ]. 

[Hardware for BSD](https://bsd-hardware.info/)   
> This is a project to anonymously collect hardware details of BSD-powered 
> computers over the world and help people to collaboratively debug 
> hardware related issues, check for BSD-compatibility and find drivers.
> 
> [Probe your computer](https://bsd-hardware.info/?view=howto) in order to 
> participate in the project and discover your hardware in details. 
> Share your probes with BSD developers to debug and fix problems with 
> your computer. Please read more 
> in [our blog](https://forum.linux-hardware.org/?cat=2).

