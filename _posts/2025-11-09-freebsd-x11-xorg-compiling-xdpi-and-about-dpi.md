---
layout: post
title: "Compiling and Building X11 Program on FreeBSD" 
date: 2025-11-09 12:52:34 -0700 
categories: x11 xorg xterm config dotfiles howto font freebsd utf8 unicode unix 
            cli terminal shell tip c programming tutorial howto
---

Alternate title: "Building and Using xdpi and qtdpi on FreeBSD - DPI and Pixel Density"

---

xdpi - Display DPI and Physical Dimensions from X11/XCB 

xdpi queries Xlib, XRandR, Xinerama, and XCB to reveal the actual pixel density and physical dimensions reported by your X server.
It's a tiny diagnostic tool that helps you understand why your display looks the way it does.

From the project's Github [Oblomov - xdpi: X11 DPI information retrieval](https://github.com/Oblomov/xdpi):
> xdpi - This is a small *C program* that retrieves *all information about DPI (dots per inch)* of the *available displays in X11*.
>
> [ . . . ]
>
> qtdpi - A simple program to illustrate how Qt 5.6 and higher handle DPI information depending on the application settings 

---

My environment: FreeBSD 14.3, Shell: csh, WM (window manager): FVWM3, No DE (Des
ktop Environment), Lenovo ThinkPad T14s Gen 3 (14", Intel) laptop - 14-inch WUXGA (Wide Ultra XGA), 1920 by 1200 pixels - So, not strictly High DPI (HighDPI or HiDPI) display but still a Very High Pixel Density (140+ PPI) panel.

---

# Xlib (aka libX11) - X Window System Protocol Client Library 

Xlib (also known as libX11) is an X Window System protocol client library written in the C programming language.
It contains functions for interacting with an X server.
These functions allow programmers to write programs without knowing the details of the X protocol. 

Applications usually don't use Xlib directly; rather, they employ other libraries that use Xlib functions to provide widget toolkits (to generate GUI applications): Xt (X Toolkit Intrinsics), Xaw (Athena widget set), Motif, FLTK, GTK, Qt (X11 version), Tk (an extension for the Tcl scripting language), SDL (Simple DirectMedia Layer), SFML (Simple and Fast Multimedia Library), which in turn use Xlib for interacting with the server [X server].

# How to Build xdpi 

### Step 1 - Get the source code

Clone the repository:

```
$ git clone https://github.com/Oblomov/xdpi/ 
$ cd xdpi
```

### Step 2 - Check prerequisites

FreeBSD installs X11 components under `/usr/local`.

Check that the required X11 development libraries are installed:

```
$ pkg info | egrep 'libX11 | libXrandr | libXinerama | libxcb | xcb-util | xcb-util-xrm | xorgproto'
```

If any are missing, install them:

```
$ sudo pkg install libX11 libXrandr libXinerama libxcb xcb-util xcb-util-xrm xorgproto
```

### Step 3 - Build (preferred and alternatives)

* Preferred (recommended) - `pkg-config` (simple, portable, correct).

This asks `pkg-config(8)` for the right include & link flags for your system:

```
$ cc -std=c99 xdpi.c `pkg-config --cflags --libs x11 xrandr xinerama xcb xcb-randr xcb-xinerama xcb-xrm` -lm -o xdpi
```

`pkg-config` returns the correct `-I` and `-L -l` pieces (on FreeBSD those will point to `/usr/local/include` and `/usr/local/lib`).


* Backup manual method (if `pkg-config` is unavailable)

```
$ cc -std=c99 -I/usr/local/include -L/usr/local/lib -D_THREAD_SAFE xdpi.c -lX11 -lXrandr -lXinerama -lxcb -lxcb-randr -lxcb-xinerama -lxcb-xrm -lm -o xdpi
```


NOTE:  How the manual compile line was derived? - aka - Why these flags?

These flags come directly from the libraries the program includes.

Looking at the source code (xdpi.c), you see includes like:

```
$ grep include xdpi.c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <X11/Xlib.h>
#include <X11/extensions/Xinerama.h>
#include <X11/extensions/Xrandr.h>
#include <xcb/xproto.h>
#include <xcb/xinerama.h>
#include <xcb/randr.h>
#include <xcb/xcb_xrm.h>
```

Rule of thumb - when analyzing a C/C++ source file and classifying headers (header names) as likely standard or non-standard based on the presence of a directory prefix:
* No directory, simple name -> probably standard C.
* Directory-prefixed name (X11/, xcb/, GL/) -> external library.

For external libraries, each header implies one library must be linked [2]:

NOTES:
* Header--library is not alwasy one-to-one: Including a header does not guarantee you need to link a library - some headers are purely inline macros or depend on other headers, but for `X11/XCB` extensions, you generally do need the corresponding library.
* Library dependencies cascade: For example, linking `-lXrandr` may implicitly require `-lX11` because `libXrandr` depends on it.
Similarly, linking `XCB` extensions often requires `-lxcb`.
* For portability, using `pkg-config` is preferred. For example:

```
$ cc myprog.c `pkg-config --cflags --libs x11 xrandr xinerama xcb xcb-randr xcb-xinerama xcb-xrm` -o myprog
```

Here's a table that provides the safest approach to explicitly list headers<->libraries<->FreeBSD package names, so that the user can manually supply `-I` and `-L` options and link `-l` libraries:

```
+----------------------------+-----------------+-----------------------+
| Header                     | Library         | FreeBSD Package       |
|----------------------------|-----------------|-----------------------|
| stdio.h, stdlib.h,         | -lm             | base system           |
| string.h, stdint.h, math.h |                 |                       |
| X11/Xlib.h                 | -lX11           | x11/libX11            |
| X11/extensions/Xinerama.h  | -lXinerama      | x11/libXinerama       |
| X11/extensions/Xrandr.h    | -lXrandr        | x11/libXrandr         |
| xcb/xcb.h / xcb/xproto.h   | -lxcb           | x11/libxcb            |
| xcb/randr.h                | -lxcb-randr     | x11/xcb-util-randr    |
| xcb/xinerama.h             | -lxcb-xinerama  | x11/xcb-util-xinerama |
| xcb/xrm.h                  | -lxcb-xrm       | x11/xcb-util-xrm      |
+----------------------------+-----------------+-----------------------+

Notes:
- Linking order matters: XCB extensions follow core X11/XCB.
- Include paths: -I/usr/local/include or -I/usr/local/include/X11
- Library paths: -L/usr/local/lib
- For math functions, always add -lm
```

FreeBSD stores X11 development headers in:

```
/usr/local/include
/usr/local/lib
```

So you add the following flags for `cc(1)` (`clang(1)`) [3]: 

```
-I/usr/local/include
-L/usr/local/lib
```

In summary, the logic behind the flags - aka Why these flags?

```
-I/usr/local/include -L/usr/local/lib: FreeBSD installs X headers/libs under /usr/local (not /usr).
-lX11 -lXrandr -lXinerama: link the Xlib and extensions used by the program.
-lxcb -lxcb-randr -lxcb-xinerama -lxcb-xrm: link the optional xcb support libraries.
-lm: math library (used by the program).
-std=c99: program is written for C99.
```


NOTE: Why wasn't <xcb/xproto.h> checked in the pkg or header checks?

Because:

`xcb/xproto.h` comes from the core libxcb package, not from one of the extension-specific packages.

On FreeBSD, installing `libxcb` always provides it.
The file lives at:

```
/usr/local/include/xcb/xproto.h
```

When you checked for:

```
libxcb xcb-util xcb-util-xrm
```

you implicitly covered the presence of the libxcb development headers, so the assumption was:

*if libxcb is installed, xproto.h is guaranteed.*

The check list was aimed at extension libraries that might or might not be installed (randr, xinerama, xcb-xrm).

Core XCB is "always included" and therefore not usually listed.

If you want a robust checklist, you can explicitly check for it.
It doesn't harm, and it makes the steps feel complete.

Something like:

```
$ pkg info | grep ^libxcb
libxcb-1.17.0                  The X protocol C-language Binding (XCB) library
```

or explicit headers:

```
$ test -f /usr/local/include/xcb/xproto.h && echo "xproto.h OK"
```

Why `pkg-config` didn't require anything special for it?

`pkg-config --cflags --libs xcb` automatically pulls in the correct include path for the core XCB headers.
It doesn't list the header names; it only provides the flags needed to find them.

So `xccb/xproto.h` was silently handled by the `xcb` package's metadata.

In short: 

* `<xcb/xproto.h>` is installed by the base `libxcb` package.
* That package was already included in your checks (`libxcb`).
* That's why it didn't get its own dedicated check line.
* If you prefer explicit completeness, add a quick header test or a pkg info libxcb.


Alternatively, a quick header check: 

```
$ ls /usr/local/include/X11/Xlib.h \
   /usr/local/include/X11/extensions/Xrandr.h \
   /usr/local/include/X11/extensions/Xinerama.h \
   /usr/local/include/xcb/randr.h \
   /usr/local/include/xcb/xinerama.h \
   /usr/local/include/xcb/xcb_xrm.h || echo "some headers missing"
```


* Makefile method (for automation or packaging)

The supplied Makefile is convenient.
On FreeBSD it may override your environment CPPFLAGS. 

It works after adding these two lines for appending pkg-config-derived flags to the Makefile:

```
CPPFLAGS += $(shell pkg-config --cflags x11 xrandr xinerama xcb xcb-randr xcb-xinerama xcb-xrm)

LDLIBS += $(shell pkg-config --libs x11 xrandr xinerama xcb xcb-randr xcb-xinerama xcb-xrm)
```


Then simply run:

```
$ make
```

### Step 4 - Install

For personal use:

```
$ install -m 755 xdpi ~/bin/
```

For system-wide use (as root):

```
$ install -m 755 xdpi /usr/local/bin/
```


### Step 5 - Run


```
$ xdpi
```

This reports DPI for each connected monitor and suggests per-monitor scaling ratios.


**What the output means**

`xdpi` reports the physical size, pixel resolution, and computed DPI for each connected display, using `Xlib`, `XRandR`, and `Xinerama`.
It helps determine correct DPI values and optional scaling ratios when working with mixed-DPI monitors.

Example useful lines:

```
eDP-1: ... 162x162 dpi - laptop screen DPI
HDMI-1: ... 94x94 dpi  - external monitor DPI
Xft.dpi: 94            - global Xft DPI visible to many GUI toolkits
```

### Step 6. Short summary 

* Preferred modern method: use `pkg-config` (cc ... `pkg-config --cflags --libs ...`) - simple, portable, correct.
* Backup manual method: add `-I/usr/local/include -L/usr/local/lib` and the `-l` flags manually.
* Makefile method: fine for automation; on FreeBSD you may need to append `pkg-config` flags or override CPPFLAGS/LDFLAGS as shown above.


# How to Build qtdpi 

```
$ command -V qmake; type qmake; which qmake; whereis -a qmake; where -a qmake
qmake: not found
qmake: not found
qmake: Command not found.
qmake: /usr/ports/devel/qmake
 
$ command -V qmake-qt5; type qmake-qt5; which qmake-qt5; whereis -a qmake-qt5; where -a qmake-qt5
qmake-qt5 is /usr/local/bin/qmake-qt5
qmake-qt5 is /usr/local/bin/qmake-qt5
/usr/local/bin/qmake-qt5
qmake-qt5: /usr/local/bin/qmake-qt5 /usr/ports/devel/qt5-qmake/work/stage/usr/local/bin/qmake-qt5
/usr/local/bin/qmake-qt5
 
$ command -V qmake6; type qmake6; which qmake6; whereis -a qmake6; where -a qmake6 
qmake6 is /usr/local/bin/qmake6
qmake6 is /usr/local/bin/qmake6
/usr/local/bin/qmake6
qmake6: /usr/local/bin/qmake6
/usr/local/bin/qmake6
```

```
$ cd xdpi/qt
```

```
$ ls -Alh
total 10
-rw-r--r--  1 dusko wheel   35B Nov  4 16:55 .gitignore
-rw-r--r--  1 dusko wheel  1.4K Nov  4 16:55 main.cpp
-rw-r--r--  1 dusko wheel  258B Nov  4 16:55 qtdpi.pro
``` 

```
$ qmake-qt5
Info: creating stash file /tmp/xdpi/qt/.qmake.stash
```
 
```
$ ls -Alhrt
total 23
-rw-r--r--  1 dusko wheel   35B Nov  4 16:55 .gitignore
-rw-r--r--  1 dusko wheel  1.4K Nov  4 16:55 main.cpp
-rw-r--r--  1 dusko wheel  258B Nov  4 16:55 qtdpi.pro
-rw-r--r--  1 dusko wheel  669B Nov 11 16:11 .qmake.stash
-rw-r--r--  1 dusko wheel   26K Nov 11 16:11 Makefile
```


```
$ make
clang++ -c -pipe -Wextra -g -std=c++11 -Wall -Wextra -pthread -fPIC -DQT_GUI_LIB -DQT_CORE_LIB -I. -I/usr/local/include/qt5 -I/usr/local/include/qt5/QtGui -I/usr/local/include/qt5/QtCore -I. -I/usr/local/include -I/usr/local/include -I/usr/local/lib/qt5/mkspecs/freebsd-clang -o main.o main.cpp
clang++ -pthread -Wl,-rpath,/usr/local/lib/qt5 -o qtdpi main.o   -L/usr/local/lib /usr/local/lib/qt5/libQt5Gui.so /usr/local/lib/qt5/libQt5Core.so -lGL
```

```
$ ls -Alhrt
total 708
-rw-r--r--  1 dusko wheel   35B Nov  4 16:55 .gitignore
-rw-r--r--  1 dusko wheel  1.4K Nov  4 16:55 main.cpp
-rw-r--r--  1 dusko wheel  258B Nov  4 16:55 qtdpi.pro
-rw-r--r--  1 dusko wheel  669B Nov 11 16:11 .qmake.stash
-rw-r--r--  1 dusko wheel   26K Nov 11 16:11 Makefile
-rw-r--r--  1 dusko wheel  1.0M Nov 11 16:12 main.o
-rwxr-xr-x  1 dusko wheel  606K Nov 11 16:12 qtdpi
 
$ file qtdpi
qtdpi: ELF 64-bit LSB executable, x86-64, version 1 (FreeBSD), dynamically linked, interpreter /libexec/ld-elf.so.1, for FreeBSD 14.3, FreeBSD-style, with debug_info, not stripped
``` 


With a single monitor (laptop only):

```
$ ./qtdpi
QT version: 0x50f11
Enable/Disable: 0/0
Global pixel ratio: 1
Screens: 1
        eDP-1 @ (0,0) size (1920, 1200):
                Physical DPI: 162.074
                 Logical DPI: 144
                 pixel ratio: 1
Enable/Disable: 0/1
Global pixel ratio: 1
Screens: 1
        eDP-1 @ (0,0) size (1920, 1200):
                Physical DPI: 162.074
                 Logical DPI: 144
                 pixel ratio: 1
Enable/Disable: 1/0
Global pixel ratio: 2
Screens: 1
        eDP-1 @ (0,0) size (960, 600):
                Physical DPI: 81.0369
                 Logical DPI: 96
                 pixel ratio: 2
Enable/Disable: 1/1
Global pixel ratio: 1
Screens: 1
        eDP-1 @ (0,0) size (1920, 1200):
                Physical DPI: 162.074
                 Logical DPI: 144
                 pixel ratio: 1
```

----

## Resources

* [GitHub - Oblomov/xdpi: X11 DPI information retrieval](https://github.com/Oblomov/xdpi)
> **X11 DPI information retrieval**
>
> This is a small C program that retrieves all information about DPI (dots per inch) of the available displays in X11.
> Information from both the core protocol and the XRANDR extension is presented. Xinerama information (which lacks physical dimensions, and is thus not directly useful to determine output DPI) is also presented.
> If an XSETTINGS daemon is found, the reported (scaled and raw) Xft/DPI value is presented.
>
> (Limitation: XSETTINGS is currently only shown for Xlib, not xcb.)
> 
> From the retrieved information, xdpi will also compute (and present) "proposed" per-monitor/per-output UI scaling factors, assuming a reference **96 DPI**.
> Each scaling factor is computed as a single-precision floating-point integer, and four values are shown:
> 
> * the floor (largest integer no larger than),
> * the value itself,
> * the rounded value (closest integer),
> * and the ceiling (smallest integer no smaller than).
> 
> For each monitor/output, both the native scaling factors (based on the reported DPI) and the prorated factors (which take into account the ratio of the core DPI to the primary output DPI) are shown.
>
> Finally, to improve the usefulness of xdpi as a debugging tool, we also show the content of the following known-relevant environment variables, if set:
> * CLUTTER_SCALE
> * GDK_SCALE
> * GDK_DPI_SCALE
> * QT_AUTO_SCREEN_SCALE_FACTOR
> * QT_SCALE_FACTOR
> * QT_SCREEN_SCALE_FACTORS
> * QT_DEVICE_PIXEL_RATIO
>
> **Qt**
> 
> A simple program to illustrate how Qt 5.6 and higher handle DPI information depending on the application settings `Qt::AA_EnableHighDpiScaling` and `Qt::AA_DisableHighDpiScaling` can be found in the `qt` directory.
> 
> Build it with
> 
> ```
> qmake && make
> ```
> 
> and then run it with
> 
> ```
> ./qtdpi
> ```
> 
> If your `qmake` by defaults builds against Qt4, run `qtmake -qt=5` before `make`.

* [Mixed DPI and the X Window System](https://wok.oblomov.eu/tecnologia/mixed-dp
i-x11/)
> I'm writing this article because I'm getting tired of repeating the same conce
pts every time someone makes misinformed statements about the (lack of) support
for mixed-DPI configurations in X11.
> It is my hope that anybody looking for information on the subject may be direc
ted here, to get the facts about the actual possibilities offered by the protoco
l, avoiding the biased misinformation available from other sources.

* (Simple:) [A Flawless i3wm experience on a HiDPI/Retina display](https://dougie.io/linux/hidpi-retina-i3wm/)

* (Very useful:) [x11 - How to scale the resolution/display of the desktop and/or applications? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/596887/how-to-scale-the-resolution-display-of-the-desktop-and-or-applications) <-- For Qt and GDK/Gnome environment variables

* [Linux High DPI Settings - Lobsters](https://lobste.rs/s/z98fqy/linux_high_dpi_settings)

* [Linux High DPI Settings](https://horstmann.com/unblog/2023-01-07/index.html)

* [How to set custom resolution using xrandr when the resolution is not available in 'Display Settings'](https://unix.stackexchange.com/questions/227876/how-to-set-custom-resolution-using-xrandr-when-the-resolution-is-not-available-i)

* [Configuring mixed DPI monitors with xrandr](https://blog.summercat.com/configuring-mixed-dpi-monitors-with-xrandr.html)
> I use xrandr to configure a dual monitor setup with a high DPI and low DPI monitor on Linux.
> I also use it to switch back and forth between a dual monitor and a single monitor setup.

* [Handling different DPI settings for different monitors - GitHub gist - xrandr-config.md](https://gist.github.com/rinaldo-rex/d3db55230959b11ad67dcf06eac74c0c)
> // Taken from: https://blog.summercat.com/configuring-mixed-dpi-monitors-with-xrandr.html

* [Improving Linux HiDPI Support For Gnome, KDE, Xfce, Cinnamon And Firefox](https://www.makeuseof.com/tag/linux-hidpi-support-for-gnome-kde-xfce-cinnamon-and-firefox/)

* [Using Archlinux on a Retina (HiDPI) MacBook Pro with Xmonad](https://web.archive.org/web/20140908015116/https://vincent.jousse.org/tech/archlinux-retina-hidpi-macbookpro-xmonad/)

* [High DPI Displays - Qt 5.15](https://doc.qt.io/archives/qt-5.15/highdpi.html)
> **High DPI Displays**
> 
> High DPI displays have increased pixel density, compared to standard DPI displays.
> 
> Pixel density is measured in Dots per Inch (DPI) or Pixels per Inch (PPI), and is determined by the number of display pixels and their size.
> Consequently, the number of pixels alone isn't enough to determine if a display falls into the high-DPI category.
> 
> A 4K monitor has a fixed number of pixels (~8M), however its DPI varies between 185 (23 inches) and 110 (40 inches).
> The former is around twice the standard 96 DPI desktop resolution; the latter barely exceeds this resolution.

* [High-DPI displays and Linux [LWN.net]](https://lwn.net/Articles/619784/)

* [Display DPI detector - find out DPI of your monitor](https://www.infobyip.com
/detectmonitordpi.php)

* [HOWTO set DPI in Xorg](https://linuxreviews.org/HOWTO_set_DPI_in_Xorg)

* [xorg - How does Linux's display work? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/596894/how-does-linuxs-display-work)

* [x11 - Is X DPI (dot per inch) setting just meant for text scaling? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/596765/is-x-dpi-dot-per-inch-setting-just-meant-for-text-scaling)

* [xrandr with XPS 13" (3840x2160) HiDPI and 30" (2560x1600) LowDPI](https://lists.freedesktop.org/archives/xorg/2018-July/059376.html)


* [new laptop with 2560x1660 resolution but programs are too small on arch. Adjusting the DPI isn't really changing applications like chrome/firefox, is there an equivalent to the windows scale?](https://old.reddit.com/r/archlinux/comments/mu6t1d/new_laptop_with_2560x1660_resolution_but_programs/)

* [multiple monitors - XRandR DPI on multihead linux - Super User](https://superuser.com/questions/522453/xrandr-dpi-on-multihead-linux)

* [How to find and change the screen DPI?](https://askubuntu.com/questions/197828/how-to-find-and-change-the-screen-dpi)

* [HiDPI - ArchWiki - wiki.archlinux.org](https://wiki.archlinux.org/title/HiDPI)

* [[Solved][xfce] What should be proper way to set correct DPI for laptop](https://bbs.archlinux.org/viewtopic.php?id=279099)

* [Xsettingsd - ArchWiki - wiki.archlinux.org](https://wiki.archlinux.org/title/Xsettingsd)

----

## Footnotes

[1] EDID (Extended Display Identification Data) is a small block of metadata stored inside your display (monitor, laptop panel, projector, etc.).
It's provided by the display hardware to the graphics card so that the operating system (Xorg, Wayland, Windows, macOS, etc.) knows:

* The display's native resolution
* The physical size (millimeters)
* Supported refresh rates
* Colour characteristics
* Vendor/model information
* Preferred timing modes

Xorg reads this data from the GPU/driver.

**Details**

* EDID is stored in the screen hardware.
* For laptop panels, it is inside the LCD panel's firmware (EEPROM).
* Xorg does not measure the screen.
Instead, it only reports what the EDID claims.


[2] The other includes:

```
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
```

are all part of the **C standard library** (`libc` on FreeBSD, `glibc` on Linux, etc.) and the **standard C headers**.
On FreeBSD (or any modern Unix-like OSs):

* They come with the **compiler and system C library**.
* You do **not** need to install anything extra from ports/packages to use them.
* They are automatically available when you invoke `cc` or `clang` (or any standard-compliant compiler).

In contrast:


```
#include <X11/Xlib.h>
#include <X11/extensions/Xinerama.h>
#include <X11/extensions/Xrandr.h>
#include <xcb/xproto.h>
#include <xcb/xinerama.h>
#include <xcb/randr.h>
#include <xcb/xcb_xrm.h>
```

* These do **not** come with the standard compiler.
* They are part of the **X11 and XCB development libraries**, which must be installed separately via ports/packages (like `libX11`, `libXrandr*, `libxcb`, etc.).

So the rule of thumb is:

* **Standard C headers** -> always included, no extra installation.
* **X11/other GUI or third-party libraries** -> may require installation of `-devel` or equivalent packages.

This is why the `pkg info | egrep ...` check only looks for `libX11`, `libXrandr`, `libxcb`, etc., and not the standard C headers.


[3] Why `/usr/bin/cc` and `/usr/bin/clang` look identical?

FreeBSD uses **Clang** as its system compiler - not GCC - and has done so for years.

To ensure build scripts work across Unix systems, FreeBSD provides:

* `/usr/bin/cc` (the traditional POSIX C compiler name)
* `/usr/bin/clang` (the actual compiler)

On FreeBSD, `cc` is just **Clang** with a *different name*.
It is *not* a symlink.  It is a *hardlink*

That's why the following listing shows:

```
$ ls -lh /usr/bin/cc
-r-xr-xr-x  6 root wheel  105M Jul 13 12:50 /usr/bin/cc

$ ls -lh /usr/bin/clang
-r-xr-xr-x  6 root wheel  105M Jul 13 12:50 /usr/bin/clang
```

And the size and timestamp match exactly.
The "6" before root is the **link count**: meaning that *six* filenames point to the same underlying file.

So

```
$ diff /usr/bin/cc /usr/bin/clang
```

shows nothing because they are literally the same executable.

In addition to the identical size and link count as clues for showing that they are *hardlinks*, here's the canonical way for confirming it:


```
$ ls -li /usr/bin/cc /usr/bin/clang
```

You'll see the same inode number.

Same inode -> same file.


Let's check:

```
$ ls -li /usr/bin/cc /usr/bin/clang
```

Output:

```
165166 -r-xr-xr-x  6 root wheel 110230808 Jul 13 12:50 /usr/bin/cc
165166 -r-xr-xr-x  6 root wheel 110230808 Jul 13 12:50 /usr/bin/clang
```

```
$ command -V cc; type cc; which cc; whereis -a cc; where -a cc
cc is /usr/bin/cc
cc is /usr/bin/cc
/usr/bin/cc
cc: /usr/bin/cc /usr/share/man/man1/cc.1.gz /usr/share/man/man4/cc.4.gz /usr/ports/devel/py-pyperscan/files/cc /usr/ports/lang/quilc/files/cc /usr/src/contrib/netbsd-tests/usr.bin/cc
/usr/bin/cc
```

```
$ command -V clang; type clang; which clang; whereis -a clang; where -a clang
clang is /usr/bin/clang
clang is /usr/bin/clang
/usr/bin/clang
clang: /usr/bin/clang /usr/share/man/man1/clang.1.gz /usr/src/usr.bin/clang /usr/ports/devel/llvm11/files/clang /usr/ports/emulators/wine-proton/files/clang /usr/src/contrib/llvm-project/clang /usr/src/contrib/llvm-project/clang/include/clang /usr/src/usr.bin/clang/clang
/usr/bin/clang
```


**Why FreeBSD does this?**

Portability.

Many build systems (e.g., ancient autoconf scripts) expect:

* cc = system C compiler
* gcc = GNU compiler, if available
* clang = Clang, if available

FreeBSD ensures that:

```
cc  -> clang
c++ -> clang++
```

This keeps the system consistent and avoids breaking thousands of build scripts.


**So which one should you use?**

For compiling `xdpi` or any **C program** on FreeBSD:


```
cc
```

is the canonical choice.

It points to Clang anyway, and that's what FreeBSD expects.

You can use `clang` explicitly if you want to, but it makes no difference.



**Why does FreeBSD use hardlinks instead of symlinks?**

Because:

* Hardlinks survive chroot environments more predictably.
* Some early-boot tools need a real binary, not a symlink.
* It makes the compiler available even in minimal environments.

It's a robust-choice tradition in BSD land.


**Summary**

* `cc` is Clang.
* `clang` is Clang.

They are two faces of the same compiler.

You can use either, and FreeBSD will happily treat them as the same being wearing different hats.

FreeBSD avoids shipping GCC for base, but still provides it in ports.

----
