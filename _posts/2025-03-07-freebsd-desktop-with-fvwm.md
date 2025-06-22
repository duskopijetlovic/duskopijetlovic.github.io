---
layout: post
title: "Comfortable FreeBSD Desktop with FVWM3"
date: 2025-03-07 08:07:05 -0700 
categories: freebsd howto windowmanager wm x11 xorg dotfiles 
---

[TODO] - add excerpts from one of my several syndrizzle installs 
E.g.:

```
# pkg install sudo
```

```
% sudo pkg install npm
```


[TODO] in `/.fvwm/config`:

* Add splitting windows (1/3, 1/2, etc.) in Window operations menu
* Geometry window not showing -- My current fix (as of 2025-03-07): ```% pkill picom``` 
* Comments and references from the original `config` file, esp. from the top of the file

----

# Objective 

* Modern look and feel

* Comfortable:
  - a strong focus on keyboard bindings
  - several virtual desktops (I like to have nine desktops) 
  - some windows without titlebar
  - alt-tab window cycling 
  - multi-monitor layout

* For laptop: Dual-screen setup, aka dual-head configuration, Zaphod mode (allows for a single device to produce multiple X screens; that is, the mode with several displays for each "head" (output)), aka multi-display, aka primary and secondary display, aka external monitor, aka multiple monitors, aka dual monitors, aka configuring multiple X screens on one [graphics] card, set up a multi-head environnement, aka multi-head (multi-screen, multi-display or multi-monitor)

* Goodies:
  - Desktop screenshot
  - Window screenshot
  - Splitting windows
  - Changing keyboard layout (US, Serbian Latin, Serbian Cyrillic) with keyboard binding
  - X termination with **Ctrl+Alt+Bksp**, aka Terminating Xorg with Ctrl+Alt+Backspace, kill the X server with Ctrl+Alt+Backspace

NOTE 1: Previusly, in order to enable the **Ctrl+Alt+Backspace** sequence to kii the X server, you had to create a configuration snippet for setting the option **DontZapp** to **off**.
For example, ```/usr/local/etc/X11/xorg.conf.d/90-zap.conf``` containing: 

```
Section "ServerFlags"
    Option "DontZap" "off"
EndSection
```

However, you don't need to explicitly set *DonZap* to *off* anymore because it's the default since 2004. 


NOTE 2:
As per [Terminating Xorg with Ctrl+Alt+Backspace](https://wiki.archlinux.org/title/Xorg/Keyboard_configuration#Frequently_used_XKB_options)
> By default, the key combination ```Ctrl+Alt+Backspace``` is disabled.
You can enable it by passing ```terminate:ctrl_alt_bksp``` to ```XkbOptions```.
This can also be done by binding a key to ```Terminate_Server``` in ```xmodmap``` (which undoes any existing ```XkbOptions``` setting).
In order for either method to work, one also needs to have ```DontZap``` set to "off" in ```ServerFlags```: since 2004 [2] this is the default:  [xorg.conf(5x) manual page - Configuration File for Xorg](https://www.x.org/archive/X11R6.8.0/doc/xorg.conf.5.html)

```
---- Quote
Option "DontZap" "boolean"
    This disallows the use of the Ctrl+Alt+Backspace sequence. That sequence 
    is normally used to terminate the Xorg server. When this option is 
    enabled, that key sequence has no special meaning and is passed to clients. 
Default: off. 
---- End Quote
```

----

# X11 (X Window System) Setup with Two Separate Screens

Two methods:
* ```xrandr(1)```, or
* Xorg configuration files


NOTES:
* If you want true ZaphodHead (independent X screens), you must use Xorg configuration files. 
For more details, see my post [How to Configure X (X.Org, X11) for Multi-Head with Two Separate Screens aka Zaphod Method]({% post_url 2021-12-19-xorg-x11-multihead-two-separate-screens %}).
* If you are okay with a single X screen spanning both displays, ```xrandr(1)``` is a simpler and more flexible solution.
* While you cannot use it for Zaphod configuration, you can use ```xrandr(1)``` to mirror two screens. 


## Setting up Two Separate Screens - xrandr(1) Method

My configuration is with a Lenovo ThinkPad T14s Gen3 (Intel version) laptop (whose screen name is *eDP-1*) and an external 24-inch monitor, LG model 24BK550Y-B (whose screen name is *HDMI-1*).

I want to mirror two screens using ```xrandr(1)```.
Mirroring means that both displays show the same content, rather than extending the desktop across them.
This is useful for presentations or when you want the same output on both screens.


First, list the connected displays using ```xrandr(1)```:

```
% xrandr --query
```

Output:

```
% xrandr --query 
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 16384 x 16384
eDP-1 connected 1920x1080+0+0 (normal left inverted right x axis y axis) 301mm x 188mm
   1920x1200     60.00 +  59.95  
   1920x1080     59.93* 
---- snip ----
HDMI-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 480mm x 270mm
   1920x1080     60.00*+  50.00    59.94  
---- snip ---
DP-1 disconnected (normal left inverted right x axis y axis)
DP-2 disconnected (normal left inverted right x axis y axis)
DP-3 disconnected (normal left inverted right x axis y axis)
DP-4 disconnected (normal left inverted right x axis y axis)
```

### Identify the Common Resolution

To mirror two screens, both displays must use the same resolution. 
Check the supported resolutions for each display and choose a common resolution that both displays support.

In this case, the common resolution is **1920x1080**.

Since the displays have different native resolutions, you need to explicitly set the resolution for both displays.
I also want to set the external display, HDMI-1, as the the primary display while mirroring.


```
xrandr --output eDP-1 --mode 1920x1080 --same-as HDMI-1 --rotate normal --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal
```

Add that line to ```~/.xinitrc```. 

```
% tail -3 ~/.xinitrc 
exec xrandr --output eDP-1 --mode 1920x1080 --same-as HDMI-1 \
            --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 &
exec fvwm3 -v -o ~/.fvwm/fvwm3-output.log
```

NOTE: The native resolution for the Lenovo ThinkPad T14s Gen3 is *1920x1200*, while the native resolution for the LG 24BK550Y-B monitor is *1920x1080*.

NOTE:  The default FVWM3 log file location is ```~/.fvwm/fvwm3-output.log``` so you don't have to specify it; however, I like to explicitely note it because I don't want to remember its location later.

Restart **X** (X11 or X Window System).


### Reverting to Extended Mode

If you want to revert to an extended desktop (non-mirrored mode), use the following command.
It sets HDMI-1 as the primary display and positions eDP-1 to the right of HDMI-1.

```
% xrandr --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output eDP-1 --mode 1920x1080 --rotate normal
```

Add that line to ```~/.xinitrc```. 

```
% tail -3 ~/.xinitrc
exec xrandr --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 \
            --output eDP-1 --mode 1920x1080 --right-of HDMI-1 &
exec fvwm3 -v -o ~/.fvwm/fvwm3-output.log
```

Restart **X** (X11 or X Window System).

See also:

[FVWM3 setting up one desktop for three monitors - Configuration - FVWM Forums](https://fvwmforums.org/t/fvwm3-setting-up-one-desktop-for-three-monitors/4734/3)


## Setting up Two Separate Screens, aka Zaphod Configuration - Xorg Configuration Files Method

Instead of using ```xrandr(1)```, you can configure dual-head environment with Xorg configuration files.

```
% ls /usr/local/etc/X11/xorg.conf.d/
10-modesetting.conf     40-monitors.conf        70-modules.conf
20-card.conf            50-touchpad.conf        80-fonts.conf
30-layout.conf          60-keyboard.conf        90-nozap.conf
```

For the dual-screen environment, create these three files: ```20-card.conf```, ```30-layout.conf```, ```40-monitors.conf```.
Their contents are listed below.

```
% cat /usr/local/etc/X11/xorg.conf.d/20-card.conf 
Section "Device"
  Identifier "Intel0"
  Driver     "modesetting"
  Option     "DPMS"
  Screen     0
  #BusID      "PCI:0:2:0"
EndSection
 
Section "Device"
  Identifier "Intel1"
  Driver     "modesetting"
  Option     "DPMS"
  Screen     1
  #BusID      "PCI:0:2:0"
EndSection 
```

```
% cat /usr/local/etc/X11/xorg.conf.d/30-layout.conf 
Section "ServerLayout"
    Identifier     "DualHeadConf"
    Screen      0  "Screen0" 1920 0
    Screen      1  "Screen1"    0 0
EndSection
```

```
% cat /usr/local/etc/X11/xorg.conf.d/40-monitors.conf 
Section "Monitor"
    Identifier "eDP-1"
    Modeline "1920x1200x60.00"  154.00  1920 1968 2000 2080  1200 1203 1209 1235 +hsync -vsync
    Option "DPMS" "true"
EndSection

Section "Monitor"
    Identifier "HDMI-1"
    Modeline "1920x1080x60.00"  148.50  1920 2008 2052 2200  1080 1084 1089 1125 +hsync +vsync
    Option "DPMS" "true" 
EndSection

Section "Screen"
    Identifier "Screen0"
    Monitor "HDMI-1"
    DefaultDepth 24
    Device "Intel0"
    Option "ZaphodHeads" "HDMI-1"
    SubSection "Display"
        Depth       24
    EndSubSection
EndSection

Section "Screen"
    Identifier "Screen1"
    Monitor "eDP-1"
    DefaultDepth 24
    Device "Intel1"
    Option "ZaphodHeads" "eDP-1"
    SubSection "Display"
        Depth     24
    EndSubSection
EndSection
```

## Notes for the Two Methods of Zaphod Configuration Setup

* The ```20-card.conf``` and ```40-monitors.conf``` X configuration files are slightly different when used with the *Intel* driver instead of *modesetting*.
For more details, see my post [How to Configure X (X.Org, X11) for Multi-Head with Two Separate Screens aka Zaphod Method]({% post_url 2021-12-19-xorg-x11-multihead-two-separate-screens %}).
* With the ```xrandr(1)``` method (which is not true Zaphod configuration), both screens are visible and you can move between them. 

**NOTE 1:**
With the X configuration files method and with **FVWM** for window manager, the secondary screen (the laptop screen in my setup) was completely black and it only had a mouse pointer. 
Mouse operations and keyboard input didn't create or change anything. 
With that setup, I had to run a second session on the second screen:

In *csh*/*tcsh*:

```
% setenv DISPLAY :0.1; xterm
```

In *sh*:

```
$ DISPLAY=:0.1 xterm
```

However, I couldn't type in *xterm*'s window.
On the other hand, when I did the same with *kitty*, I was able to use it on the second screen (*:0.1*).


**NOTE 2:**
When I tried it with **TWM** for window manager, it worked; that is, I could move to the second screen, start *xterm* and other programs and use them indepedently (independently of the first screen).  

----

# Fonts

## Vermaden Fonts Collection

```
% fetch https://github.com/vermaden/scripts/raw/master/distfiles/fonts.tar.gz
% mkdir fonts-vermaden
% mv fonts.tar.gz fonts-vermaden/
% cd fonts-vermaden/
% tar xf fonts.tar.gz

% ls -ld ~/.fonts
ls: /home/dusko/.fonts: No such file or directory

% mv .fonts ~/
```

```
% fc-cache -f

% fc-list | wc -l
    1387
```


### Syndrizzle Fonts Collection

```
% git clone https://github.com/syndrizzle/hotfiles.git -b fvwm
% cd hotfiles
% cp usr/share/fonts/* ~/.fonts/

% fc-cache -f

% fc-list | wc -l
    1438
```

## Tips and Tricks


### [FVWM] About InfoStoreAdd Variable

From 
[FVWM on Ubuntu 21.04 - Section 2: Build your own fvwm3 .config](https://github.com/crb912/fvwm3-config):

Avoiding too many environment variables leads to a lot of "pollution" within FVWM's environment space, we should use `InfoStoreAdd`.

This [thread (FVWM Tips)](https://web.archive.org/web/20060926032424/http://fvwm.lair.be/viewtopic.php?t=1505) provides more information.  

By Thomas Adam

**SetEnv**

FVWM defines for you (which you yourself can change) the environment variable `FVWM_USERDIR` which by default points to `~/.fvwm` -- so you don't need to set "fvwm_home".
You should always rely on using "FVWM_USERDIR" where you need to reference a likely and *pre-defined* location for personal configuration files.

**InitFunction** versus StartFunction versus RestartFunction

You don't need to use *InitFunction*.

You don't need to use *RestartFunction*.

*StartFunction* is read by FVWM at *initialisation* and *reboots*.

**Exec exec** and the dreaded FvwmCommand versus PipeRead. 

*PipeRead* forces a shell, but more importantly one is then able to "echo" commands back to FVWM.
Not only does this synchronise things (especially if the PipeRead command exists within a function) but it means you don't have to worry about sending commands back indirectly via FvwmCommand.
FvwmCommand is only useful if you're calling some external script that doesn't rely on directly ending with FVWM (or where you don't want it to block with PipeRead). 

If you ever find yourself writing:

```
+ I Exec ...; FvwmCommand '....'	
```

you want PipeRead. 


I'm too good to use **ImagePath**.

It comes back to point 1, with SetEnv.

```
# Remove all those damn SetEnv commands
ImagePath $[FVWM_USERDIR]/.icons:+
```

All you need to do is this:

```
Style some_app Icon icon.png
```

And FVWM will know where to look by traversing the directories listed in the ImagePath.

Why do you need **DestroyFunc/Menu/etc.**?

> morbusg wrote:        
> One question which has bothered me pretty long:
> Could you be kind and explain why exactly does one need DestroyFunc/Menu/etc., ie. what are the consequences of not using them?
> If not doing any changes to them on the fly.	

Answer: 
They're useful in clearing any previous definitions for the named menu/function/etc.
Without them, AddTo{Func,Menu} are cumulative in that they'll define (if none exists) and then continually add to the definition of the menu or function they're defining.
In most circumstances this is fine, although imagine what happens when a file is read from within FVWM (during its lifetime) -- if a Destroy{Menu,Func} command did not exist, any subsequent AddTo{Func,Menu} commands would append to the definition, possibly tainting or giving incorrect results.

-- Thomas Adam


### Fixing "No sqlite available" when Starting albert  

The fix:

```
% sudo pkg install qt5-sqldrivers-sqlite2
% sudo pkg install qt6-base_sqldriver-sqlite
```

Start albert and activate some of its plugins:

```
% /usr/local/bin/albert
```

For example, some of my selected plugins were not installed, and I needed to instatl the following FreeBSD packages.

```
% sudo pkg install py311-latexcodec
% sudo pkg search py311-inflection
% sudo pkg search py311-pint
```

## Syndrizzle hotfiles Stuff

**TODO:** ADD LOG EXCERPTS


## NetBSD and the Quest for a Comfortable Desktop with FVWM3

[FVWM3 and the Quest for a Comfortable NetBSD Desktop - The F Virtual Window Manager](https://www.unitedbsd.com/d/442-fvwm3-and-the-quest-for-a-comfortable-netbsd-desktop)

"All scripts sending desktop notifications through libnotify naturally expect a *notify-daemon* to be running; author personally recommends *dunst* (requires *dbus*)." 


## My Customization of the Syndrizzle Project

* Reduced vertical space in the Window operations menu
* Using a different Conky configuration
* EWW - simplified the bar and reduced width from 98% to 50% of the screen width
* Added an item (xterm) to *jgmenu*


**[TODO]:** DOES THE FOLLOWING TITLE NEED TO BE CHANGED?

### Syndrizzle Hotfiles Installation

```
% sudo pkg install fvwm3
% sudo pkg install git npm picom xdg-user-dirs jgmenu thunar thunar-archive-plugin
% sudo pkg install xarchiver conky python3 py311-pip py311-Wand rust eww-x11
% sudo pkg install wmctrl-fork curl jq maim starship nitrogen pamixer hsetroot
% sudo pkg install xfce4-power-manager xfce4-settings mate-polkit
% sudo pkg install gtk2 gtk3 appmenu-gtk-module gtk-murrine-engine libappindicator 
% sudo pkg install noto-emoji jetbrains-mono kitty rofi fish zsh papirus-icon-theme
% sudo pkg install volman playerctl libwnck3 mpv tint2 pavucontrol albert redshift
% sudo pkg install albert redshift qt5ct mate-polkit yaru-gtk-themes yaru-icon-theme
```

```
% git clone https://github.com/decaycs/gtk3 decay-gtk3
% cd decay-gtk3/decay
% sudo npm install -g sass
% make && sudo make install
```

NOTE: These are just some of my changes.
Not all of my customizations are included here. 

* artwiz-fonts

```
% sudo pkg install artwiz-fonts
```

```
% cat << BSD | sudo tee -a /usr/local/etc/X11/xorg.conf.d/90-fonts.conf  
Section "Files"
    FontPath "/usr/local/share/fonts/artwiz-fonts"
EndSection
BSD
```

Alternatively, at the command line in the X session run:

```
% xset fp+ /usr/local/share/fonts/urwfonts
% xset fp rehash
```

* **glx-utils**



```
% sudo pkg install glx-utils
```

```
% glxgears
```

```
% glxinfo -B
---- snip ----
```

----

* **[TODO]**:  Add excerpts about modifying the *lock* shell script. 

Modified the *lock* shell script in the Syndrizzle project.

* XTerm without the title bar and window decorations.

Add this line to your `~/.fvwm/config` file:

```
Style xterm !Title, !Borders, !Handles, StaysOnTop
```

----


```
% cat /usr/local/etc/X11/xorg.conf.d/60-modules.conf 
Section "Module"
    Load "freetype"
EndSection
```

----

# Screenshot Shell Script

```
% sudo pkg install ImageMagick7 xdotool
```

----

# Summary

* Alt-Tab: window cycling
* Alt+Shift+T ("T" for teleport): Launch Pager
* Alt+Ctrl+r:  Restart FVWM

* Nine virtual desktops
* Pager

ROOT WINDOW
* Left mouse click anywhere in root window: launch Root Menu
* Right mouse click anywhere in root window: launch Window Operations menu 
* Middle mouse click anywhere in root window: launch Window List per Desktop menu

* Right Mod4 (Win or Super or Hyper): Invoke a Window List for the current Desktop

* Left mouse click on a minimized window: Bring the window back (un-minimize it) 


WINDOW 
* Right mouse click on title bar: Send To > choose a desktop number
* Alt+right arrow key = Increase window size horizontally (increase width)
* Alt+left arrow key = Decrease window size horizontally (decrease width)
* Alt+down arrow key = Increase window size vertically (increase height)
* Alt+up arrow key = Decrease window size vertically (decrease height)
* Alt+h: Move a window left
* Alt+j: Move a window down 
* Alt+k: Move a window up 
* Alt+l: Move a window right
* Alt+i: Identify

* Alt+F4:  Close a window
* Alt+d:  Destroy a window
* Alt+i:  Iconify (minimize) a window
* Alt+p:  Launch dmenu
* Alt+r:  Launch Rofi
* Alt+x:  Launch xterm 

* Alt+Left Mouse button drag and move: Move a window
* Alt+Right Mouse button drag and move: Resize a window
* Alt+Middle Mouse click: Raise a window that's behind another window  

* Mod4 (Win or Super or Hyper)+Enter: Launch kitty (terminal emulator)

* Mod4 (Win or Super or Hyper)+left arrow key: Snap a window left 
* Mod4 (Win or Super or Hyper)+right arrow key: Snap a window right 
* Mod4 (Win or Super or Hyper)+up arrow key: Snap a window into a half size of its original size 
* Mod4 (Win or Super or Hyper)+down arrow key: Snap a window into a quarter size of its original size
* Mod4 (Win or Super or Hyper)+n: Snap a window into a tiny size 

* Mod4 (Win or Super or Hyper)+b: Launch a web browser (firefox)
* Mod4 (Win or Super or Hyper)+k: Change keyboard layout (between US and Serbian layouts)
* Mod4 (Win or Super or Hyper)+t: Maximize a window


DESKTOPS
* Alt+1: Go (switch) to Desktop 1
* Alt+2: Go (switch) to Desktop 2
* Alt+3: Go (switch) to Desktop 3
* Alt+4: Go (switch) to Desktop 4
* Alt+5: Go (switch) to Desktop 5
* Alt+6: Go (switch) to Desktop 6
* Alt+7: Go (switch) to Desktop 7
* Alt+8: Go (switch) to Desktop 8
* Alt+9: Go (switch) to Desktop 9

PAGER
* Ctrl+Alt+up arrow key:  Cycle forward to the next desktop
* Ctrl+Alt+down arrow key:  Cycle backward to the previous desktop

----

## Tools

* ```setxkbmap(1)```

----

## References

[The Flawless FVWM](https://github.com/syndrizzle/hotfiles/tree/fvwm)
>
> 🏠 A collection of personal configuration files for various rices I have made.
> 
> About:  
> FVWM as the window manager.
> Decay as the color scheme.
> Kitty as the terminal emulator.
> Dunst (Fork) as the notification daemon.
> EWW as the widgets and the bottom panel.
> DockbarX as the dock.
> Picom as the compositor.
> Rofi as the application menu.
> Albert Launcher as the universal search.
> JGMenu as the desktop menu.
> SLiM as the desktop manager.
> i3lock as the lock screen.
> Some love as the essence!
>
> NOTE!!!
> This configuration was made for my PC, so things here might not work on your PC, in that case, please try if you can fix that up, or you can open an issue for help :).
> This was made for a screen having a resolution of 1920x1080 and, on a Laptop with 120 as the screen DPI (Dots Per Inch).

* [[FVWM] An essence of decay](https://old.reddit.com/r/unixporn/comments/wlscxa/fvwm_an_essence_of_decay/)

* [FreeBSD Desktop – Part 3 – X11 Window System -- By vermaden](https://vermaden.wordpress.com/2018/05/22/freebsd-desktop-part-3-x11-window-system/)

* [FreeBSD Desktop – Part 15 – Configuration – Fonts & Frameworks | 𝚟𝚎𝚛𝚖𝚊𝚍𝚎𝚗](https://vermaden.wordpress.com/2018/08/18/freebsd-desktop-part-15-configuration-fonts-frameworks/)

* [FVWM3 and the Quest for a Comfortable NetBSD Desktop - The F Virtual Window Manager](https://www.unitedbsd.com/d/442-fvwm3-and-the-quest-for-a-comfortable-netbsd-desktop)

* [Mixed Theme Package for FVWM](https://vakuumverpackt.de/fvwm/)

* [Mixed Theme Package for FVWM - Project on GitHub](https://github.com/vakuum/fvwm-mtp)

* [[FVWM] Tema i.redd.it - by user lauriset](https://old.reddit.com/r/unixporn/comments/1ifczsf/fvwm_tema/)

* [[FVWM] OpenBSD 6.6 : unixporn](https://www.reddit.com/r/unixporn/comments/gbjwwl/fvwm_openbsd_66/)

* [Wayland and Xorg -- how design differences make a fvwm-wayland version "impossible" (self.FVWM3)](https://old.reddit.com/r/FVWM3/comments/1iscdwl/wayland_and_xorg_how_design_differences_make_a/)

* [r/FVWM3](https://www.reddit.com/r/FVWM3/)

* [FVWM on Ubuntu 21.04 - Section 2: Build your own fvwm3 .config](https://github.com/crb912/fvwm3-config)

* [FVWM Beginner's Guide - A very detailed tutorial](https://zensites.net/fvwm/guide/index.html)

* [FVWM Configuration and Tweaking](https://circuitousroot.com/artifice/programming/useful/fvwm/configuration/index.html)

* [FVWM on Ubuntu 21.04](https://github.com/crb912/fvwm3-config)

* [FVWM: Using the keyboard instead of the mouse](https://www.fvwm.org/fvwm-ml/4890.html)
> You can use vi key bindings for menu navigation (j = down, k = up, h = left, l = right).

* [FvwmScript-DayDate -- Display the day and date in a window - Suitable to then be swallowed by FvwmButtons](https://www.galleyrack.com/images/artifice/programming/useful/fvwm/configuration/FvwmScript-DayDate)

* [Fvwm Window Manager - share configs, functions, all that jazz](https://forums.bunsenlabs.org/viewtopic.php?id=958)

* [Build Taskbar in FVWM3 - fvwm.org Wiki](https://www.fvwm.org/Wiki/Panels/FvwmTaskBar/)

----

* [FVWM Old School Linux Window Manager - Tom Hayden](http://tomhayden3.com/2014/05/03/fvwm/)

* [FVWM - wiki.archlinux.org](https://wiki.archlinux.org/title/FVWM)

* [Window Manager Project - FVWM - YouTube](https://www.youtube.com/watch?v=HHYXBdOgUrI)

* [FVWM configuration - Dev1Galaxy - The officially Devuan Forum](https://dev1galaxy.org/viewtopic.php?id=5742)

* ["Great FVWM configuration"](https://github.com/111LUX/GFVWM)

* [FVWM myExt collection - Arch Linux Forums](https://bbs.archlinux.org/viewtopic.php?id=261902)

* [FVWM myExtensions Collection - FVWM Themes](https://www.pling.com/p/1472903) 

* [FVWM myExtensions Collection - FVWM Forums](https://fvwmforums.org/t/fvwm3-myext-collection/3039)

* [Show us your screen - UnitedBSD](https://www.unitedbsd.com/d/452-show-us-your-screen)

* [GitHub - yshui/picom: A lightweight compositor for X11 with animation support](https://github.com/yshui/picom)

* [Picom prevents Conky from showing up on the desktop - Arch Linux Forums](https://bbs.archlinux.org/viewtopic.php?id=281941)

* [xorg - Lack of borders on xterm windows, Ubuntu 20.04 LTS - Ask Ubuntu](https://askubuntu.com/questions/1410161/lack-of-borders-on-xterm-windows-ubuntu-20-04-lts)

----

* [Inessential X Resources for Techno-Dweebs](https://web.mit.edu/sipb/doc/working/ixresources/xres.html)


* [xdg-ninja: A shell script which checks your $HOME for unwanted files and directories - Lobsters](https://lobste.rs/s/uaiivt/xdg_ninja_shell_script_which_checks_yourP

----

* [Switch monitors in xorg.conf in a dual screen setup](https://superuser.com/questions/1616104/switch-monitors-in-xorg-conf-in-a-dual-screen-setup)

* [Xorg/Multiple monitors - Gentoo Linux Wiki](https://wiki.gentoo.org/wiki/Xorg/Multiple_monitors)
> Important
> 
> Anything passing for a modern Xorg has autoconfiguration and [RandR](https://wiki.gentoo.org/wiki/Xrandr) extension which means that it should just work and any configuration can be done either via xrandr command line tool or a graphical tool provided by your desktop environment assuming you're using one.
> Nevertheless this article can prove useful for legacy or advanced use cases.

* [Multihead (Multi-head, multi-screen, multi-display or multi-monitor) - Arch Linux Wiki](https://wiki.archlinux.org/title/Multihead#RandR)

* [Dual Monitors with a single graphics card - Multiple X screens with ZaphodHeads - Gentoo Linux Wiki (archived from Apr 29, 2013)](https://web.archive.org/web/20130429073111/http://en.gentoo-wiki.com/wiki/X.Org/Dual_Monitors#Single_graphics_card.2C_Multiple_X_screens_with_ZaphodHeads)
> Motivation
> 
It is often desirable to have multiple X screens produced by a single VGA controller.
> Most xf86-video-* drivers support **Zaphod mode**, which allows for a single device to produce multiple X screens.
> With intel graphics integrated onto all Sandy Bridge and higher CPUs, this is especially important.
> 
> For instance, on a machine with an on-chip graphics controller, as well as a separated video card, this would allow for one display for each output.
> 
> This example will focus on Intel, though it should work with radeon and nouveau drivers that support it. 

* [A newbie discovers how to make dual monitors work in FreeBSD13](https://forums.freebsd.org/threads/a-newbie-discovers-how-to-make-dual-monitors-work-in-freebsd13.81484/)

* [Dual monitor, second screen blank (self.freebsd)](https://old.reddit.com/r/freebsd/comments/tqfwxd/dual_monitor_second_screen_blank/)

* [Multiple screens support in X server](https://askubuntu.com/questions/277097/multiple-screens-support-in-x-server)

----

* [FVWM3 setting up one desktop for three monitors - Configuration - FVWM Forums](https://fvwmforums.org/t/fvwm3-setting-up-one-desktop-for-three-monitors/4734/3)

----

* [The XKB Configuration Guide](https://www.x.org/releases/current/doc/xorg-docs/input/XKB-Config.html)

* [An Unreliable Guide to XKB Configuration - Doug Palmer](https://www.charvolant.org/doug/xkb/html/xkb.html)

----

