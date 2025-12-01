---
layout: post
title: "Simple X11 Setup - Notes"
date: 2025-08-31 12:38:13 -0700 
categories: x11 xorg xterm config dotfiles howto font freebsd utf8 unicode unix 
            cli terminal shell tip 
---

Word cloud: font, typography, kerning, bitmap, XLFD, monospaced, 
                  fixed, fixed-pitch, fixed-width, non-proportional, 
                  proportional, variable-pitch, glyph, XLFD, laptop,
                  14-inch screen, monitor, display, WUXGA (Wide Ultra XGA), 
                  High DPI (HighDPI or HiDPI), Very High Density (140+ PPI), 
                  FreeType, Xft, fontconfig, `.otf`, `.ttf`, `.ttc`, `.bdf`, 
                  Unicode, UTF-8,
                  xterm, terminal, shell, CLI

----

# My Notes from [How to configure X11 in a simple way](https://eugene-andrienko.com/it/2025/07/24/x11-configuration-simple.html) by Eugene Andrienko
(Posted on 2025-07-24. Retrieved on 2025-08-31.)

# My Primary Concerns 

* Display: 14-inch WUXGA (Wide Ultra XGA), 1920 by 1200 pixels
  - So, not strictly High DPI (HighDPI or HiDPI) display but still a Very High Density (140+ PPI) panel
* Fonts
  - Shell, terminal - **XTerm**
  - Proportional vs. monospace(d) vs. bitmap (pixel fonts) vs. fixed bitmap vs. TrueType (Xft) [<sup>[1](#footnotes)</sup>]
  - Unicode
* Brightness


## Laptop - Main Screen (Built-In Display)

# Very High Density (140+ PPI) DPI Display

aka: "Retina" display

How to setup X server to operate with a Very High Density (140+ PPI) display?

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

# Starting X (X Window System, X11)

```
% exec xinit  # OR: exec startx
```

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

## Fonts for Use with XTerm

In general, for `xterm(1)`, I prefer using bitmapped (old-style) fixed width fonts when I'm using an external monitor, while for a a laptop, I like better OpenType (OTF, new-style) and TrueType fonts (TTF, new-style).

From [Install TTF font on xterm (cygwin)](https://superuser.com/questions/920572/install-ttf-font-on-xterm-cygwin):
> TrueType fonts (TTF) with X are usually done using `fontconfig`.
> One of its features is that it looks by default in the **.fonts** directory under your **home** directory.
> You would use `fc-list` to list the fonts which are available, and use them with the `-fa` (family name) and `-fs` (font size) options of `xterm`. (while `xfd` has a corresponding `-fa` option, `xfontsel` does not).
> 
> `xset` on the other hand, looks for **bitmap** fonts which are referenced using the **XLFD** naming convention.
>You would use `xlsfonts` for listing those, and the `-fn` option of `xterm`.


### Fonts for Use with XTerm on This Laptop - Main Screen (Built-In Display)


In order of preference:


#### 0xProto - OpenType Font (OTF), TrueType Font (TTF) 

For this laptop, I prefer *0xProto* OpenType/TrueType font, so I start `xterm` with the `-fa` option (which corresponds to `xterm`'s *faceName* resource, and is used for selecting fonts from the *FreeType* library), and I also use the font size (`-fs` option) of *12*: 

```
% xterm -fa 0xProto -fs 12
```

To make it permanent, add the following two lines to your `~/.Xresources` file: 

```
XTerm*faceName: 0xProto
XTerm*faceSize: 12
```

Then, to re-read your Xresources file, and throw away your old resources, run:

```
% xrdb ~/.Xresources
```

#### X Core Fonts (Bitmapped, XLFD) for XTerm on This Laptop 

As mentioned before, for `xterm` on the laptop I prefer TrueType and OpenType (new-style) fonts.
However, when I sometimes choose to use bitmapped fonts (X core fonts, or old-style font), I like `-adobe-courier-medium-r-normal--24-240-75-75-m-150-iso10646-1`, so I start `xterm` with the `-fn` option.

```
% xterm -fn "-adobe-courier-medium-r-normal--24-240-75-75-m-150-iso10646-1"
```

To make it permanent, add the following line to your `~/.Xresources` file: 

```
XTerm*font: -adobe-courier-medium-r-normal--24-240-75-75-m-150-iso10646-1
```

Then, to re-read your Xresources file, and throw away your old resources, run:

```
% xrdb ~/.Xresources
```


Other X core (bitmapped, XLFD) fonts that look somewhat good on this laptop:

```
% xterm -fn "-b&h-lucidatypewriter-medium-r-normal-sans-34-240-100-100-m-200-iso10646-1"

% xterm -fn "-adobe-courier-medium-r-normal--34-240-100-100-m-200-iso10646-1"

% xterm -fn "-b&h-lucidatypewriter-medium-r-normal-sans-24-240-75-75-m-140-iso10646-1"

% xterm -fn "-b&h-lucidatypewriter-medium-r-normal-sans-26-190-100-100-m-159-iso10646-1"

% xterm -fn "-ibm-courier-medium-r-normal--0-0-0-0-m-0-iso10646-1"

% xterm -fn "-b&h-lucidatypewriter-medium-r-normal-sans-20-140-100-100-m-120-iso10646-1"

% xterm -fn "-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1"

% xterm -fn "-bitstream-terminal-medium-r-normal--18-140-100-100-c-110-iso8859-1"

% xterm -fa '' -fn "-sun-gallant-medium-r-normal--22-220-75-75-c-120-iso10646-1"
```

For the last font (Gallant Font), you have to install it from [https://github.com/NanoBillion/gallant](https://github.com/NanoBillion/gallant).


#### Searching for Bitmap Fonts (X Core Fonts, XLFD Fonts)

**XLFD**: 14 fields.
Field names are separated by dashes '-', and an XLFD font name starts with a dash '-'):

```
-fndry-fmly-wght-slant-swdth-adstyl-pxlsz-ptsz-resx-resy-spc-avgwdth-rgstry-encdng
```

For additional searches for an X core font (bitmapped, old-style font), I often use the following XLFD fields.

```
* wght (Weight): medium
* slant (Slant): r for roman (or upright)
* swdth (Nominal width): normal, condensed
* pxlsz (height, in pixels, of the type - Also called "body size")
* ptsz (height, in points, of the type)
* resx (horizontal screen resolution the font was designed for, in DPI 
* resy (vertical screen resolution the font was designed for, in DPI) 
* spc (the kind of spacing used by the font (its *escapement* class); either 'p' (a *proportional* font containing characters with varied spacing), 'm' (a *monospaced* font containing characters with constant spacing), or 'c' (a *character cell* font containing characters with constant spacing and constant height)
* avgwdth (average width of the characters used in the font, in 1/10th pixel units) 
```

```
% xlsfonts | wc -l
   23232
 
% xlsfonts -fn "*" | wc -l
   23232
```


For example, for the search below with the `xlsfonts(1)` program: `fmly` (family): *fixed*, `pxlsz` (body size in pixels): *18*. 

```
% xlsfonts -fn "*-fixed-*-*-*-*-18-*" | less 
```

This is good on an external monitor, but too small for this laptop:

```
% xterm -fn "-misc-fixed-medium-r-normal--18-120-100-100-c-90-iso10646-1"
```

Additional searches:

```
% xlsfonts -fn "*-fixed-*-*-*-*-24-*" | wc -l
% xlsfonts -fn "*-fixed-*-*-*-*-24-*" | less
```

```
% xlsfonts -fn "-*-*-medium-r-normal-*-24-*" | wc -l
% xlsfonts -fn "-*-*-medium-r-normal-*-24-*" | less 
```

The following search: spacing (11th field: *spc*): 'm' for *monospaced* - with *medium* weight (3rd field: *wgth*) and *upright* ('r' for *roman*) slant (4th field: *slant*).

```
% xlsfonts -fn "-*-*-*-r-normal-*-*-*-*-*-m-*" | wc -l
% xlsfonts -fn "-*-*-*-r-normal-*-*-*-*-*-m-*" | less 
```

The following search: spacing (11th field: *spc*): 'c' for *character cell* - with *medium* weight (3rd field: *wgth*) and *upright* ('r' for *roman*) slant (4th field: *slant*).

```
% xlsfonts -fn "-*-*-medium-r-normal-*-*-*-*-*-c-*" | wc -l
% xlsfonts -fn "-*-*-medium-r-normal-*-*-*-*-*-c-*" | less 
```

----

TODO - Clean this section

For use in X (X11, X Window System), there are two types of fonts:

* X core fonts (old-style bitmapped fixed width fonts and Type1 fonts)
* OpenType/TrueType (newer) fonts

There are two kinds of fonts in X11: server-side (drawn by the X server, shown in `xlsfonts(1)`) and client-side (drawn by the application, shown in `fc-list(1)`.


[https://man.freebsd.org/cgi/man.cgi?query=xterm&manpath=FreeBSD+10.2-RELEASE+and+Ports](https://man.freebsd.org/cgi/man.cgi?query=xterm&manpath=FreeBSD+10.2-RELEASE+and+Ports)
> However (even though `xfd` accepts a "-fa" option to denote *FreeType* fonts), `xfontsel` has *not* been similarly extended.
> 
> As a workaround, you may try:
>
> ```
> fc-list :scalable=true:spacing=mono: family
> ```
> 
> to find a list of scalable fixed-pitch fonts which may be  used
> for the faceName	resource value.

----

### XTerm's Default Font 

The default font for `xterm` is an alias *fixed*.

For more about finding out what it resolves to on your system, see [<sup>[2](#footnotes)</sup>].

In short (TLDR):

```
% xset -q | grep -A1 "Font Path"
Font Path:
  /usr/local/share/fonts/ ---- snip ----

% ls -1 /usr/local/share/fonts/misc/fonts.*
/usr/local/share/fonts/misc/fonts.alias
/usr/local/share/fonts/misc/fonts.dir
/usr/local/share/fonts/misc/fonts.scale
``` 


NOTE: With `xlsfonts(1)`:

```
% xlsfonts -l fixed
DIR  MIN  MAX EXIST DFLT PROP ASC DESC NAME
-->    0  255  some    0   23  11    2 -misc-fixed-medium-r-semicondensed--0-0-75-75-c-0-iso8859-1
-->    0  255  some    0   23  11    2 -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-->    0  255  some    0   23  11    2 -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-->    0  255  some    0   23  11    2 -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-koi8-r
```

Continuing - with exploring the `fonts.alias` and `fonts.dir` files. 

```
% grep ^fixed /usr/local/share/fonts/misc/fonts.alias 
fixed        -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
```

So, on my system, **fixed** alias resolves to `-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1`.


NOTE: Note that *fixed* is aliased specifically to the ISO 8859-1 version of the font, not to the Unicode version (which would be ISO 10646-1).

To find out that font's file:

```
% grep -- "-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1" /usr/local/share/fonts/misc/fonts.dir 
6x13-ISO8859-1.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
6x13-ISO8859-10.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-10
6x13-ISO8859-11.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-11
6x13-ISO8859-13.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-13
6x13-ISO8859-14.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-14
6x13-ISO8859-15.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-15
6x13-ISO8859-16.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-16

% ls /usr/local/share/fonts/misc/6x13-ISO8859-1.pcf.gz
/usr/local/share/fonts/misc/6x13-ISO8859-1.pcf.gz
```

So, on my system, **fixed** alias resolves to: 

```
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
```

and that font's file is:

```
/usr/local/share/fonts/misc/6x13-ISO8859-1.pcf.gz
```

----

### Unicode Support

If there is `iso10646-1` in XLFD font name: it supports Unicode. 

```
-misc-fixed-medium-o-semicondensed--13-120-75-75-c-60-iso10646-1
```

vs.

If there is `iso8859-1` in XLFD font name: it does not support Unicode.

```
-misc-fixed-medium-o-semicondensed--13-120-75-75-c-60-iso8859-1
```

----

## Laptop with an External Monitor - TODO

When I use an external monitor with the laptop.

On laptop:

```
% ./mirror_ext_monitor_xrandr.sh
```

```
% cat mirror_ext_monitor_xrandr.sh 
#!/bin/sh

# Based on 
#   <https://wiki.archlinux.org/title/Xrandr>

intern=eDP-1
extern=HDMI-1 

xrandr --output "$intern" --primary --auto --output "$extern" --same-as "$intern" --auto
```

----

### Fonts for Use with XTerm on an External Monitor


#### X Core (Bitmapped, Old-Style) Fonts 

In contrast to the laptop, with an external monitor, for `xterm` I prefer bitmapped fonts (X Core fonts, aka old-style fonts).

```
% xterm -fn "-b&h-lucidatypewriter-medium-r-normal-sans-14-140-75-75-m-90-iso106
46-1"

% xterm -fn "-misc-fixed-medium-r-normal--18-120-100-100-c-90-iso8859-1"

% xterm -fn "-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1"

% xterm -fn "-sun-gallant-medium-r-normal--22-220-75-75-c-120-iso10646-1"
# (You need to install it manually from:
# https://github.com/NanoBillion/gallant)
```

#### TrueType and OpenType (New-Style) Fonts

With *Fontconfig*.

Good but too big:

```
% xterm -fa 'Monospace' -fs 14
```
 
Not so good:

```
% xterm -fa 'Monospace' -fs 12
% xterm -fa 'Monospace' -fs 11
```

To list monospaced fonts (with using Fontconfig's `fc-list(1)`):
 
```
% fc-list | cut -f2 -d: | sort -u | grep -i Mono 
```

----


---

TODO: 

[The Unicode HOWTO: Display setup](https://linux.die.net/HOWTO/Unicode-HOWTO-2.html)

---

TODO:

* [Pleasant Fonts - FreeBSD Forums](https://forums.freebsd.org/threads/pleasant-fonts.84570/)

* [Fonts on Linux, Chapter One: Changing Default and Fallback Fonts with Fontconfig](https://dt.iki.fi/fontconfig-1)

* [How To Set Default Fonts and Font Aliases on Linux](https://jichu4n.com/posts/how-to-set-default-fonts-and-font-aliases-on-linux/)

* [UTF8 Playground](https://utf8-playground.netlify.app/)

* [UTF8 Playground - Source on GitHub](https://github.com/vishnuharidas/utf8-playground)

* [Font configuration](https://wiki.archlinux.org/title/Font_configuration#Replace_or_set_default_fonts)
> Although [Fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) is used often in modern Unix and Unix-like operating systems, some applications rely on the original method of font selection and display, the [X Logical Font Description](https://wiki.archlinux.org/title/X_Logical_Font_Description) (XLFD).

---

TODO:

```
% pkg search terminus-font
terminus-font-4.49.1_1   Terminus Font - a clean fixed width font

% pkg search --regex ^terminus
terminus-font-4.49.1_1   Terminus Font - a clean fixed width font
terminus-ttf-4.49.3      Terminus Font - a clean fixed width font (TTF version)
 
% pkg rquery %dn terminus-font
mkfontscale
fontconfig
```

```
% xterm -report-fonts > xterm-report-fonts

% awk '{print $1}' xterm-report-fonts | grep -n "^f[A-Z]"
2:fNorm:
29:fBold:
56:fWide:
83:fWBold:
111:fNorm:
138:fBold:
165:fWide:
192:fWBold:

% sed -n 2p /tmp/xterm-report-fonts 
        fNorm: fixed

% sed -n 29p /tmp/xterm-report-fonts
        fBold: fixed

% sed -n 56p /tmp/xterm-report-fonts
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1

% sed -n 83p /tmp/xterm-report-fonts
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1

% sed -n 111p /tmp/xterm-report-fonts
        fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1

% sed -n 138p /tmp/xterm-report-fonts
        fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1

% sed -n 165p /tmp/xterm-report-fonts
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1

% sed -n 192p /tmp/xterm-report-fonts
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
```

---

## References

**References - HiDPI, WUXGA, Very High Density (140+ PPI) X11 (Xorg) Setup**

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
>   The **modifiable** and **distributable** outline font which is based on Roman type and Mincho type. We are planning to distribute it in TrueType and CID Type-1 formats.
> The development started on November 29, 2000.
> Designers and testers are wanted.
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

* [XLFD (X Logical Font Description) Conventions](https://www.x.org/releases/X11R7.6/doc/xorg-docs/specs/XLFD/xlfd.html)

* [Fonts - The Linux Cookbook, Second Edition, by Michael Stutz](https://dsl.org/cookbook/cookbook_20.html)

* [How do you know the correct name to use for X11 fonts for XTerm*faceName or xterm -fa NAME?](https://superuser.com/questions/465142/how-do-you-know-the-correct-name-to-use-for-x11-fonts-for-xtermfacename-or-xter#comment2564250_1375786)

* [Fontconfig - A library for configuring and customizing font access](https://www.freedesktop.org/wiki/Software/fontconfig/)

* [The Unicode HOWTO: Display setup](https://linux.die.net/HOWTO/Unicode-HOWTO-2.html)

* [The Unicode HOWTO, Bruno Haible, haible@clisp.cons.org, v1.0, 23 January 2001](https://linux.die.net/HOWTO/Unicode-HOWTO.html)
> This document describes how to change your Linux system so it uses UTF-8 as text encoding.
> This is work in progress.
> Any tips, patches, pointers, URLs are very welcome.

* [Gallant Font](https://github.com/NanoBillion/gallant)
> The 12x22 raster font we love, used by Sun Microsystems SPARC stations. With a ton of Unicode glyphs! 

---

## Footnotes

[1] A *monospaced* font, also called a *fixed-pitch*, *fixed-width*, or *non-proportional* font, is a font whose letters and characters each occupy the same amount of *horizontal space*.
This contrasts with variable-width fonts, where the letters and spacings have different widths.

The ```font``` resource is a standard resource setting for the *X Toolkit*, which deals only with [XLFD (X Logical Font Description) Conventions](https://www.x.org/releases/X11R7.6/doc/xorg-docs/specs/XLFD/xlfd.html) bitmap, while ```faceName``` was added long after, in applications such as *xterm* to provide a way to specify **TrueType** fonts (actually whatever ```fontconfig``` supports, which *can* include *bitmap* fonts).

---
From [XLFD (X Logical Font Description) Conventions](https://www.x.org/releases/X11R7.6/doc/xorg-docs/specs/XLFD/xlfd.html): 

* Monospaced = fixed pitch
  - A font whose logical character widths are constant (that is, every glyph in the font has the same logical width).
* Proportional = variable pitch
  - A font whose logical character widths vary for each glyph.
* CharCell
  - A monospaced font that follows the standard typewriter character cell model (that is, the glyphs of the font can be modeled by X clients as "boxes" of the same width and height that are imaged side-by-side to form text strings or top-to-bottom to form text lines).
  By definition, all glyphs have the same logical character width, and no glyphs have "ink" outside of the character cell.
  There is no kerning.

---

* XLFD (bitmap): [xlsfonts](http://linux.die.net/man/1/xlsfonts), [xfontsel](https://linux.die.net/man/1/xfontsel), [xfd](https://linux.die.net/man/1/xfd)
* [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) (TrueType *and* it can support *bitmap* fonts too): [fc-list](http://linux.die.net/man/1/fc-list), [fc-match](https://linux.die.net/man/1/fc-match) 

* From [X Logical Font Description (XLFD) - Arch Wiki](https://wiki.archlinux.org/title/X_Logical_Font_Description):
> [X Logical Font Description (XLFD)](https://en.wikipedia.org/wiki/X_logical_font_description) is the *original* **core** X11 fonts system.
> It was designed for **bitmap** fonts, and support for **scalable** fonts (Type 1, TrueType, and OpenType/CFF) was added *later*.
* XLFD *does not support* anti‑aliasing and sub‑pixel rasterization.

---

From [Fonts in X11R6.8, Juliusz Chroboczek, jch@pps.jussieu.fr, 25 March 2004](https://www.x.org/archive/X11R6.8.0/doc/fonts.html), [Section 3. Fonts included with X11R6.8](https://www.x.org/archive/X11R6.8.0/doc/fonts3.html) 
> Fonts included with X11R6.8
>
> 3.1. Standard bitmap fonts
> 
> The Sample Implementation of X11 (SI) comes with a large number of bitmap fonts, including the `fixed' family, and bitmap versions of Courier, Times, Helvetica and some members of the Lucida family.
> In the SI, these fonts are provided in the **ISO 8859-1** encoding (ISO Latin Western-European).
> 
> In X11R6.8, a number of these fonts are provided in *Unicode-encoded* font files instead.
> At build time, these fonts are split into font files encoded according to legacy encodings, a process which allows us to provide the standard fonts in a number of regional encodings with no duplication of work.
> 
> For example, the font file
>
> ```
> /usr/X11R6/lib/X11/fonts/misc/6x13.bdf
> ```
>
> with XLFD
>
> ```
> -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
> ```
>
> is a Unicode-encoded version of the standard `fixed' font with added support for the Latin, Greek, Cyrillic, Georgian, Armenian, IPA and other scripts plus numerous technical symbols. 


[2] About XTerm's Default Font

## Default Font for XTerm

With default (`xterm` started with just `xterm`, that is, without using any of the `xterm` options): 

```
% xterm
```

In the new `xterm` window, run: 

```
% xtermcontrol --get-font
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
```

Confirm/check with `xterm(1)`:

```
% xterm -report-fonts | wc -l
     218

% xterm -report-fonts | grep -- "-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1"
     fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
     fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
```


As a contrast, next example shows `xterm` with a font selected from the FreeType library (new-style font), as opposed to a bitmap (old-style) font (which are specified with XLFD notation).

```
% xterm -fa mono -fs 12
```

In the new `xterm` window, run: 

```
% xtermcontrol --get-font
mono
```

Ask the `xprop(1)` utility, using its `-font` argument, to show the properties of the font named *fixed*.

```
% xprop -font fixed | grep -w FONT
FONT = -Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1
```

```
% xprop -font fixed
---- snip ----
FOUNDRY = Misc
FAMILY_NAME = Fixed
WEIGHT_NAME = Medium
SLANT = R
---- snip ----
PIXEL_SIZE = 13
POINT_SIZE = 120
RESOLUTION_X = 75
RESOLUTION_Y = 75
SPACING = C
AVERAGE_WIDTH = 60
CHARSET_REGISTRY = ISO8859
CHARSET_ENCODING = 1
---- snip ----
FONT = -Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1
---- snip ----
```

From the man page for `xterm(1)`:

```
   -fn font
           This option specifies the font to be used for displaying normal
           text.  The corresponding resource name is font.  The resource
           value default is fixed.
```


Note "The resource value (for the `-fn` option) default is **fixed**".

From:

```
% xprop -font fixed
---- snip ----
FONT = -Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1
```

Also:

```
% xterm -report-fonts | grep "f[A-Z]" | grep -i fixed | wc -l
       8
 
% xterm -report-fonts | grep "f[A-Z]" | wc -l
       8
 
% xterm -report-fonts | grep "f[A-Z]" | grep -i fixed | wc -l
       8
 
% xterm -report-fonts | grep "f[A-Z]" | grep -i fixed
       fNorm: fixed
       fBold: fixed
       fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
       fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
       fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
       fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
       fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
       fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
```

```
% xterm -report-fonts | grep "f[A-Z]" | grep -i fixed | grep -- "-13-120-" | wc -l
       6
 
% xterm -report-fonts | grep "f[A-Z]" | grep -i fixed | grep -- "-13-120-" 
       fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
       fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
       fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
       fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
       fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
       fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
```

With `xterm` use its `-xrm` option specifies a resource string to be used.

Here, use the `reportFonts` resource.

From the man page for `xterm(1)`:

```
   reportFonts (class ReportFonts)
           If true, xterm will print to the standard output a summary of
           each font's metrics (size, number of glyphs, etc.), as it loads
           them.  The default is “false”.
```


```
% xterm -xrm "*reportFonts: true" | wc -l
     218
```

```
% xterm -xrm "*reportFonts: true" | grep "f[A-Z]" | wc -l
       8
 
% xterm -xrm "*reportFonts: true" | grep "f[A-Z]" | grep -i fixed | wc -l
       8
 
% xterm -xrm "*reportFonts: true" | grep "f[A-Z]" | grep -i fixed 
        fNorm: fixed
        fBold: fixed
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
        fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
```

With `xterm`, explicitly load font *fixed* (which is actually an *alias* for the font that is loaded).

```
% xterm -xrm "*font:fixed"
```

Next, with `xterm`, load font *fixed* and use the resource string `reportFonts` to print to the standard output a summary of that font's metrics (size, number of glyphs, etc.), as `xterm` loads them.  

```
% xterm -xrm "*reportFonts: true" -xrm "*font:fixed" | wc -l
     218
 
% xterm -xrm "*reportFonts: true" -xrm "*font:fixed" | grep "f[A-Z]" | wc -l
       8
 
% xterm -xrm "*reportFonts: true" -xrm "*font:fixed" | grep "f[A-Z]" | grep -i fixed | wc -l
       8
 
% xterm -xrm "*reportFonts: true" -xrm "*font:fixed" | grep "f[A-Z]" | grep -i fixed 
        fNorm: fixed
        fBold: fixed
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
        fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
```


With the `-report-xres` option for `xterm`:

```
% xterm -report-xres | wc -l
     261
```

```
% xterm -report-xres | grep -E "font[[:space:]]"
font                    : fixed
```
 
```
% xterm -report-xres | grep -E "font[^[:alnum:]]"
font                    : fixed
```

```
% xterm -report-xres | grep -E "font[[:>:]]"
font                    : fixed
```

```
% xterm -report-xres
---- snip ----
font                    : fixed
font1                   : nil2
font2                   : 5x7
font3                   : 6x10
font4                   : 7x13
font5                   : 9x15
font6                   : 10x20
font7                   : -adobe-courier-medium-r-normal--24-240-75-75-m-150-iso10646-1
fontDoublesize          : true
fontWarnings            : 1
---- snip ----
utf8                    : default
utf8Fonts               : default
utf8Latin1              : false
---- snip ----
```

Use `xset(1)` to find the *Font Path*.

```
% xset -q | wc -l
      27

% xset -q | grep -A1 "Font Path"
Font Path:
  /usr/local/share/fonts/ . . . 
```

```
% ls -lh /usr/local/share/fonts/ | wc -l
      32
 
% ls -lh /usr/local/share/fonts/misc/ | wc -l
     413
 
% ls /usr/local/share/fonts/misc/fonts*
/usr/local/share/fonts/misc/fonts.alias /usr/local/share/fonts/misc/fonts.scale
/usr/local/share/fonts/misc/fonts.dir
```

```
% grep ^fixed /usr/local/share/fonts/misc/fonts.alias
fixed        -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
```

```
% grep -- "-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1" /usr/local/share/fonts/misc/fonts.dir 
6x13-ISO8859-1.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
6x13-ISO8859-10.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-10
6x13-ISO8859-11.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-11
6x13-ISO8859-13.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-13
6x13-ISO8859-14.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-14
6x13-ISO8859-15.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-15
6x13-ISO8859-16.pcf.gz -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-16
```

```
% ls /usr/local/share/fonts/misc/6x13-ISO8859-1.pcf.gz                      
/usr/local/share/fonts/misc/6x13-ISO8859-1.pcf.gz
```

```
% mkdir /tmp/6x13check
 
% cd /tmp/6x13check
 
% pwd
/tmp/6x13check
 
% cp -i /usr/local/share/fonts/misc/6x13-ISO8859-1.pcf.gz .
 
% gunzip 6x13-ISO8859-1.pcf.gz
 
% ls
6x13-ISO8859-1.pcf
 
% file 6x13-ISO8859-1.pcf 
6x13-ISO8859-1.pcf: X11 Portable Compiled Font data, bit: MSB, byte: MSB first
 
% wc -l 6x13-ISO8859-1.pcf
      10 6x13-ISO8859-1.pcf
 
% strings 6x13-ISO8859-1.pcf | wc -l
     191

% strings 6x13-ISO8859-1.pcf | grep -i "misc-fixed"
-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1
```

```
% xlsfonts | grep -i -- "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1" | wc -l
      15
 
% xlsfonts | grep -i -- "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1"
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-10
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-10
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-11
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-11
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-13
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-13
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-14
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-14
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-15
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-15
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-16
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-16
```

```
% xlsfonts -fn "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1" | wc -l
       6
 
% xlsfonts -fn "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1"
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
```

```
% xlsfonts -h
xlsfonts: unrecognized argument -h

usage:  xlsfonts [-options] [-fn pattern]
where options include:
    -l[l[l]]                 give long info about each font
---- snip ----
 
% xlsfonts -l -fn "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1" | wc -l
       7
 
% xlsfonts -ll -fn "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1" | wc -l
     228
 
% xlsfonts -lll -fn "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1" | wc -l
    1770
```

With `xfontsel(1)` application, to work with only a subset of the fonts, specify `-pattern` option followed by a partially or fully qualified font name; so `-pattern "*-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1*"` will select that subset of fonts which contain that string somewhere in their font name.

```
% xfontsel -pattern "*-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1*"
```

This returned "6  names match".

```
% xfd -fn "-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1" 
```

From the man page for `xfd(1)`: 

```
DESCRIPTION
       The xfd utility creates a window containing the name of the font being
       displayed, a row of command buttons, several lines of text for
       displaying character metrics, and a grid containing one glyph per cell.
```

In this case, `xfd(1)` created a window containing this name of the font displayed:

```
-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1
```

```
% xterm -fn "-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1" -report-fonts | grep "f[A-Z]"
        fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
        fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fNorm: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
        fBold: -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-1
        fWide: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
        fWBold: -Misc-Fixed-medium-R-*-*-13-120-75-75-C-120-ISO10646-1
```

## app-defaults

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

% grep "font:" /usr/local/lib/X11/app-defaults/XTerm
*SimpleMenu*menuLabel.font: -adobe-helvetica-bold-r-normal--*-120-*-*-*-*-iso8859-*
*VT100.utf8Fonts.font:  -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
 
% grep "font:" /usr/local/lib/X11/app-defaults/XTerm | grep fixed
*VT100.utf8Fonts.font:  -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
```

```
% grep -i font /usr/local/lib/X11/app-defaults/XTerm | grep -i default
*fontMenu*fontdefault*Label:    Default
! The default fixed font and font2-font6 are commonly aliased to iso106461 (Unicode)
!                                         fontdefault/SmeBSB
!                                         fontdefault/SmeBSB
! xterm can switch at runtime between bitmap (default) and TrueType fonts.
```

## appres

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

% appres XTerm xterm | grep "font:"
*SimpleMenu*menuLabel.font:     -adobe-helvetica-bold-r-normal--*-120-*-*-*-*-iso8859-*
*VT100.utf8Fonts.font:  -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1

% appres XTerm xterm | grep "font:" | grep fixed
*VT100.utf8Fonts.font:  -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
```


## find-xterm-fonts Perl script 

Using *find-xterm-fonts* Perl script from the maintainer of XTerm, Thomas E. Dickey: 

```
% fetch https://invisible-island.net/datafiles/release/misc-scripts.tar.gz

% tar xf misc-scripts.tar.gz
 
% ls
misc-scripts-20250722   misc-scripts.tar.gz

% cd misc-scripts-20250722/

% ls
CHANGES                         MANIFEST
check-manpage                   nm_cmp
classpath                       no-local
compare-terminfo                nodot
count-nroff                     noenv
diffstat2css                    nolocale
find-xterm-fonts                noterm
---- snip ----

% file find-xterm-fonts
find-xterm-fonts: Perl script text executable

% ./find-xterm-fonts
# opening /usr/local/lib/X11/app-defaults/XTerm
---- snip ----
        *VT100.utf8Fonts.font:  -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
---- snip ----
# opening /usr/local/lib/X11/app-defaults/UXTerm
        *VT100.font:    -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1
---- snip ----
# opening /usr/local/lib/X11/app-defaults/KOI8RXTerm
        *VT100.font:    -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-koi8-r
---- snip ---- 

Font-files used:
---- snip ----
        /usr/local/share/fonts/misc/6x13.pcf.gz
        -> UXTerm*VT100.font
        -> XTerm*VT100.utf8Fonts.font
---- snip ----

No font-files missing

Packages providing font-files:

font-adobe-75dpi-1.0.3_4
        /usr/local/share/fonts/75dpi/courR24.pcf.gz
        /usr/local/share/fonts/75dpi/helvB12-ISO8859-1.pcf.gz
font-misc-misc-1.1.2_4
        /usr/local/share/fonts/misc/10x20-ISO8859-1.pcf.gz
        /usr/local/share/fonts/misc/10x20-KOI8-R.pcf.gz
        /usr/local/share/fonts/misc/10x20.pcf.gz
        /usr/local/share/fonts/misc/5x7-ISO8859-1.pcf.gz
        /usr/local/share/fonts/misc/5x8-KOI8-R.pcf.gz
        /usr/local/share/fonts/misc/5x8.pcf.gz
        /usr/local/share/fonts/misc/6x10-ISO8859-1.pcf.gz
        /usr/local/share/fonts/misc/6x13-ISO8859-1.pcf.gz
        /usr/local/share/fonts/misc/6x13-KOI8-R.pcf.gz
        /usr/local/share/fonts/misc/6x13.pcf.gz
        /usr/local/share/fonts/misc/7x13-ISO8859-1.pcf.gz
        /usr/local/share/fonts/misc/7x14-KOI8-R.pcf.gz
        /usr/local/share/fonts/misc/7x14.pcf.gz
        /usr/local/share/fonts/misc/8x13-ISO8859-1.pcf.gz
        /usr/local/share/fonts/misc/8x13-KOI8-R.pcf.gz
        /usr/local/share/fonts/misc/8x13.pcf.gz
        /usr/local/share/fonts/misc/9x15-ISO8859-1.pcf.gz
        /usr/local/share/fonts/misc/9x18-KOI8-R.pcf.gz
        /usr/local/share/fonts/misc/9x18.pcf.gz
        /usr/local/share/fonts/misc/nil2.pcf.gz
```

----

# Appendix

## Useful Commands and Examples for Exploring Hardware

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

----

## Useful Tools for Using and Exploring Fonts


### X Tools for X Core Fonts - For XLFD (aka: Bitmapped fonts) - xlsfonts, xfontsel, xfd

**XLFD**: *X Logical Font Description*  (as opposed to *Fontconfig* and *FreeType* libraries). 

If on your FreeBSD system these three packages (`xfontsel`, `xlsfonts`, `xfd`) were not installed when you installed the `X` (`xorg`) metaport and other `X` (`xorg`) -related metaports and ports, you'll need to install them. 

To list `X` (`xorg`) and `X` (`xorg`) -related metaports and ports:

```
% pkg info | grep ^xorg-
xorg-7.7_3                   X.Org complete distribution metaport
xorg-apps-7.7_4              X.org apps meta-port
xorg-docs-1.7.3,1            X.org documentation files
xorg-drivers-7.7_7           X.org drivers meta-port
xorg-fonts-7.7_1             X.org fonts meta-port
xorg-fonts-100dpi-7.7        X.Org 100dpi bitmap fonts
xorg-fonts-75dpi-7.7         X.Org 75dpi bitmap fonts
xorg-fonts-cyrillic-7.7      X.Org Cyrillic bitmap fonts
xorg-fonts-miscbitmaps-7.7   X.Org miscellaneous bitmap fonts
xorg-fonts-truetype-7.7_1    X.Org TrueType fonts
xorg-fonts-type1-7.7         X.Org Type1 fonts
xorg-libraries-7.7_6         X.org libraries meta-port
xorg-server-21.1.18,1        X.Org X server and related programs
```

On my system they were not installed so I had to install them.


### xlsfonts

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
 -l[l[l]]             give long info about each font
 -m                   give character min and max bounds
 -C                   force columns
 -1                   force single column
 -u                   keep output unsorted
 -o                   use OpenFont/QueryFont instead of ListFonts
 -w width             maximum width for multiple columns
 -n columns           number of columns if multi column
 -display displayname X server to contact
 -d displayname       (alias for -display displayname)
 -v                   print program version
```


NOTE: `xlsfonts(1)` deals only with **XLFD** *14-part* names. 

Chapter *Fonts* of *The Linux Cookbook* (Second Edition, by Michael Stutz) has a table describing the meaning of each field of X font names in **XLFD** (*X Logical Font Description*): 

[X Fonts - The Linux Cookbook, Second Edition, by Michael Stutz](https://dsl.org/cookbook/cookbook_20.html#SEC313)

```
% xlsfonts | wc -l
   23232

% xlsfonts "*" | wc -l
   23232
```


When the searched font doesn't exist on the system:

```
% xlsfonts "mono"
xlsfonts: pattern "mono" unmatched
```

When there is a match for the given pattern:

```
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

It's *case insensitive*:

```
% xlsfonts -fn "*fixed*" | wc -l
    1014
 
% xlsfonts -fn "*Fixed*" | wc -l
    1014
 
% xlsfonts -fn "*FIXED*" | wc -l
    1014
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
```

When searched for the [Fixed (typeface) - aka **misc-fixed**](https://en.wikipedia.org/wiki/Fixed_(typeface)) fonts:

```
% xlsfonts -fn "*fixed*" | grep -i misc | wc -l
     970
 
% xlsfonts -fn "*fixed*" | grep -v misc | wc -l
      44
```

```
% xlsfonts -fn "*misc-fixed*" | wc -l
     970
```

```
% xlsfonts -fn "*misc-fixed*" | grep -i "\-Misc\-Fixed\-Medium\-R\-Normal\-\-7\-70\-75\-75\-C\-50\-ISO10646\-1"
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
 
% xlsfonts -fn "*misc-fixed*" | grep -n -i "\-Misc\-Fixed\-Medium\-R\-Normal\-\-7\-70\-75\-75\-C\-50\-ISO10646\-1"
758:-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
759:-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
```

Or:

```
% xlsfonts -fn "*misc-fixed*" | grep -i -- "-Misc-Fixed-Medium-R-Normal--7-70-75-75-C-50-ISO10646-1"
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1

% xlsfonts -fn "*misc-fixed*" | grep -n -i -- "-Misc-Fixed-Medium-R-Normal--7-70-75-75-C-50-ISO10646-1"
758:-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
759:-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
```

```
% xlsfonts -fn "*-Misc-Fixed-Medium-R-Normal--7-70-75-75-C-50-ISO10646-1*"
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
```

You don't have to use the `-fn` option:

```
% xlsfonts "*-Misc-Fixed-Medium-R-Normal--7-70-75-75-C-50-ISO10646-1*"
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
```

```
% xlsfonts "*misc-fixed*" | grep -n -i "\-Misc\-Fixed\-Medium\-R\-Normal\-\-7\-70\-75\-75\-C\-50\-ISO10646\-1"
758:-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
759:-misc-fixed-medium-r-normal--7-70-75-75-c-50-iso10646-1
```

### xfontsel

```
% pkg search --regex ^xfontsel
xfontsel-1.1.1    Point and click selection of X11 font names
```

```
$ pkg search --regex --full ^xfontsel | sed -n '/Description/,$p'
Description    :
This package contains xfontsel, an application which provides a simple way to
display fonts known to your X server.
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


NOTE: `xfontsel(1)` deals only with **XLFD** *14-part* names. 

To work with only a *subset* of the fonts, specify `-pattern` option followed by a partially or fully qualified font name; e.g., `-pattern "*medium*"` will select that subset of fonts which contain the string *medium* somewhere in their font name. 

When the searched font doesn't exist on the system:

```
$ xfontsel -fn nonexistingfont
Warning: Cannot convert string "nonexistingfont" to type FontStruct
```

```
$ xfontsel -fn mono
Warning: Cannot convert string "mono" to type FontStruct
```

```
% xfontsel -pattern 'mono' -print

#  The  xfontsel(1)  window displayed:
#    no names match
```

```
% xfontsel -pattern '*mono*' -print
        
#  On my system, the  xfontsel(1)  window displayed:
#    12 names match

#  After quitting xfontsel(1):
-*-b612 mono-*-*-*-*-*-*-*-*-*-*-*-*$ 
```


### xfd 

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

NOTE: In addition to `-fn` option (which specifies the *core X* server side font to be displayed), the `xfd(1)` utility *also supports* `-fa` option (which specifies an *Xft* font to be displayed).

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
% xfd -fn fixed
```

Loaded:

```
-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1
```

```
% xfontsel -print -fn "-Misc-Fixed-Medium-R-SemiCondensed--13-120-75-75-C-60-ISO8859-1"
```

Output:

```
-*-*-*-*-*-*-*-*-*-*-*-*-*-*% 
```

```
% xfontsel -print -fn fixed
```

Output:

```
-*-*-*-*-*-*-*-*-*-*-*-*-*-*% 
```


### Fontconfig Tools (fc-list, fc-match, fc-conflist) - For OpenType, TrueType Fonts

Print a list of all the configuration files processed by *Fontconfig*.

```
% fc-conflist 
```

The output is a '-' or '+' depending on whether the file is ignored or processed, a space, the file's path, a colon and space, and the description from the file or 'No description' if none is present.

The order of files looks like how *fontconfig* actually processes them except one containing `<include>` element.

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


To get detailed information about a font; for example, about 0xProto font:

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


### Additional Fontconfig Tools

```
% man fonts-conf
```

See also:

```
fc-cache(1) fc-list(1) fc-match(1) fc-pattern(1) fc-query(1) fc-scan(1) fc-cat(1)
```

---

## Glossary / Acronyms / Terms [TODO]

* (Often used interchangeably) X.Org Server - X - X11 - Xorg: X.Org Foundation implementation of the X Window System (X11) display server
  - So, X.Org Server (X): *implementation* of the *X Window System* (X11) *display server*
    - X Window System = X11
    - X11 = protocol, the core protocol
    - X.Org Server = X

References:

* [X Window System - Wikipedia](https://en.wikipedia.org/wiki/X_Window_System):
> X Window System (X11, or simply X) is a windowing system for bitmap displays, common on Unix-like operating systems.

* [Windowing system - Wikipedia](https://en.wikipedia.org/wiki/Windowing_system): 
> The X Window System was first released in 1984 and is historically the main windowing system for Unix and Unix-like operating systems.
> The **core protocol** has been at **version 11** since **1987**, hence it commonly being known as "X11".
> The current reference implementation of the X11 protocol is the X.Org Server, which provides the display server and some ancillary components. 
>
> [ . . . ]
> 
> The *main* component of any windowing system is usually called the *display server*, although alternative terms such as *window server* are also in use.

* [Xorg - Arch Wiki](https://wiki.archlinux.org/title/Xorg)
> [X.Org Server](https://en.wikipedia.org/wiki/X.Org_Server) - commonly referred to as simply **X** - is the [X.Org Foundation](https://en.wikipedia.org/wiki/X.Org_Foundation) implementation of the [X Window System](https://en.wikipedia.org/wiki/X_Window_System) (**X11**) display server, and it is the most popular display server among Linux users.
>
> For the alternative and successor, see [Wayland](https://wiki.archlinux.org/title/Wayland).

* XLFD = X Logical Font Description 

* Type 1, TrueType, OpenType/CFF = scalable fonts

----

# FAQ

## How do *misc-fixed* fonts look like?

Answer: On my FreeBSD 14 system:

```
% xfontsel -print
```

For `fndry` select `misc`.
For `fmly` select `fixed`.
Click 'quit'.

Output:

```
-misc-fixed-*-*-*-*-*-*-*-*-*-*-*-*%
```

```
% xlsfonts | wc -l
   23234

% xlsfonts "*-misc-fixed*" | wc -l
     970
```

On my system, there are 970 fonts in the *misc-fixed* collection of fonts.

Now, you can dig deeper, and start filtering out, until you find a font or a set of fonts that you like. 

```
% xlsfonts "*-misc-fixed*" | less

% xlsfonts "*-misc-fixed-medium-r-normal*" | wc -l
     454

% xlsfonts "*-misc-fixed-medium-r-normal*" | less

% xlsfonts "*-misc-fixed-medium-r-normal--20*" | wc -l
      34
 
% xlsfonts "*-misc-fixed-medium-r-normal--20*" | less
```

```
% xfontsel -pattern "-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1" 
```

Returned "6  names match".


Then with `xfd(1)`:

```
% xfd -fn "-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1"
```

Similarly:

```
% xfd -fn "*-misc-fixed-medium-r-normal--20-*"
```

will display:

```
-Misc-Fixed-Medium-R-Normal--20-200-75-75-C-100-ISO8859-1
```

and

```
% xfd -fn "-misc-fixed-medium-r-normal--*-*-*-*-*-*-iso10646-1"
```

will display:

```
-Misc-Fixed-Medium-R-Normal--20-200-75-75-C-100-ISO10646-1
```

```
% xterm -fn "-Misc-Fixed-Medium-R-Normal--20-200-75-75-C-100-ISO10646-1"
```

---

<!--
  -- TODO:
  -- 
  -- ChatGPT chat
  -- https://unix4lyfe.org/xterm/
  -- https://wiki.archlinux.org/title/Fonts
  -- https://www.jeffquast.com/post/terminal_wcwidth_solution/
  -- https://iamvishnu.com/posts/utf8-is-brilliant-design
  -- http://docsrv.sco.com/en/GECG/X_Font_ProcListXsrv.html 
  -- https://www.designmatrix.com/services/XResources_fonts.html
  -- http://docsrv.sco.com/en/GECG/X_Font_ProcListXsrv.html 
  -- https://stackoverflow.com/questions/17078247/linux-c-xft-how-to-use-it
  -- https://ia801601.us.archive.org/22/items/xwindowsystem03quermiss/xwindowsystem03quermiss.pdf 
  -- https://forums.freebsd.org/threads/pleasant-fonts.84570/
  -- https://askubuntu.com/questions/161652/how-to-change-the-default-font-size-of-xterm?rq=1
  -- https://unix.stackexchange.com/questions/675000/scaling-default-xterm-font-to-large 
  -- https://old.reddit.com/r/chrome/comments/6fbeh4/is_it_possible_to_use_bitmap_fonts_in_chrome/ 
  -- https://www.x.org/archive/X11R6.8.0/doc/fonts3.html
  -- [FAQ: Fonts - University of Utah - Mathematics Department](https://www.math.utah.edu/faq/fonts/fonts.html) 
  -- https://stackoverflow.com/questions/59889366/identify-xterm-fonts-being-used-and-corresponding-cygwin-package 
  -->

---

