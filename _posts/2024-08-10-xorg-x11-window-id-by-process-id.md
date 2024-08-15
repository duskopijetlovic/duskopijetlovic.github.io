---
layout: post
title: "How to Find an X11 Window ID (WID) by a Process ID (PID)"
date: 2024-08-10 22:29:12 -0700 
categories:  x11 xorg xterm cli terminal shell howto sysadmin unix 
---

aka How to Find an X11 (X, Xorg) Window ID (WID) and Switch to That Window

---

OS: *FreeBSD 14*

```
$ freebsd-version 
14.0-RELEASE-p6
```

Shell: *csh*

```
$ ps $$
  PID TT  STAT    TIME COMMAND
69641 19  Ss   0:00.95 -csh (csh)
```

```
$ printf %s\\n "$SHELL"
/bin/csh
```

----

# Method 1: Instal and Use `wmctrl(1)`

Tools: 
* `wmctrl(1)`
* (Optional) `xwininfo(1)`


Install *wmctrl* package.

```
$ sudo pkg install wmctrl
```

Comment of the *wmctrl* package.

```
$ pkg query %c wmctrl
Command line tool to interact with an EWMH/NetWM compatible X managers
```

Description of the *wmctrl* package.

```
$ pkg query '%e' wmctrl
The wmctrl program is a command line tool to interact with an
EWMH/NetWM compatible X Window Manager.

It provides command line access to almost all the features defined in
the EWMH specification. Using it, it's possible to, for example, obtain
information about the window manager, get a detailed list of desktops
and managed windows, switch and resize desktops, change number of
desktops, make windows full-screen, always-above or sticky, and
activate, close, move, resize, maximize and minimize them.
```


Show information about the window manager and about the environment:

```
$ wmctrl -m
Name: FVWM
Class: fvwm
PID: N/A
Window manager's "showing the desktop" mode: N/A
```


I'm looking for a window where `vi(1)` text editor opened a specific file.

```
$ ps auxw | grep -v grep | grep 'vi ed-notes'
dusko   94716   0.0  0.0    13908    3764 13  I+   10:58  0:00.01 vi ed-notes.md
```

```
$ ps auxw | grep -v grep | grep 'vi ed-notes' | cut -w -f2
94716
```

*Explanation* for the `-w` option for the `ps(1)` utility:

From the man page for `ps(1)` (on *FreeBSD 14*) for the `-w` option: 

```
  Use at least 132 columns to display information, instead of the
  default which is the window size if ps is associated with a
  terminal.  If the -w option is specified more than once, ps will
  use as many columns as necessary without regard for the window size.
```


TIP: With the `-e` option, `ps(1)` displays the environment as well.

```
$ ps auxe -ww -p 94702
USER    PID %CPU %MEM    VSZ   RSS TT  STAT STARTED    TIME COMMAND
dusko 94702  0.0  0.1 115856 13660 v0  I    10:57   0:00.11 VENDOR=amd fvwm_editor=gvim LOGNAME=dusko LC_CTYPE=en_CA.UTF-8 LC_MESSAGES=en_CA.UTF-8 LANG=en_CA.UTF-8 PAGER=less OSTYPE=FreeBSD LC_TIME=en_CA.UTF-8 MACHTYPE=x86_64 MAIL=/var/mail/dusko GDK_USE_XFT=1 QT_XFT=1 TASKRC=/mnt/usbflashdrive/mydotfiles/.taskrc PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/home/dusko/bin:/home/dusko/.local/bin EDITOR=vi fvwm_img=/home/dusko/.fvwm/img/ HOST=fbsd1.home.arpa fvwm_theme_img=/home/dusko/.fvwm/deco/arctic GTK2_RC_FILES=/home/dusko/.gtkrc-2.0 fvwm_browser=/usr/local/bin/firefox fvwm_term=/usr/local/bin/xterm fvwm_file=rox DISPLAY=:0 fvwm_goright=3ddesk --view=goright --noautofun PWD=/home/dusko fvm_gnome_icon_theme=gnant GROUP=dusko HOSTDISPLAY=fbsd1.home.arpa:0 fvwm_theme=arctic TERM=xterm cset_wall_1=10 FVWM_MODULEDIR=/usr/local/libexec/fvwm/2.6.9 cset_wall_2=20 cset_wall_3=30 USER=dusko HOME=/home/dusko OOO_FORCE_DESKTOP=gnome cset_wall_4=40 fvwm_weather=um WINDOWPATH=9 fvwm_icon=/usr/local/share/icons/gnant SHELL=/bin/csh HOSTTYPE=FreeBSD MM_CHARSET=UTF-8 QT_QPA_PLATFORMTHEME=qt5ct fvwm_goleft=3ddesk --view=goleft --noautofun LC_ALL= CHEAT_CONFIG_PATH=/mnt/usbflashdrive/mydotfiles/cheat/conf.yml fvwm_calc=/usr/local/bin/xcalc FVWM_USERDIR=/home/dusko/.fvwm FVWM_DATADIR=/usr/local/share/fvwm fvwm_dock_x=730 fvwm_script=/home/dusko/.fvwm/script/ fvwm_wallpaper_dir=/home/dusko/.fvwm/img/wallpaper BLOCKSIZE=K SHLVL=1 fvwm_mail=/usr/local/bin/thunderbird /usr/local/bin/xterm
```


```
$ ps auxwwl -p 94716
USER    PID %CPU %MEM   VSZ  RSS TT  STAT STARTED    TIME COMMAND         UID  PPID C PRI NI MWCHAN
dusko 94716  0.0  0.0 13908 3368 13  I+   10:58   0:00.01 vi ed-notes.md 1001 94704 2  24  0 ttyin
```

*Explanation* for the `-l` option for the `ps(1)` utility:

From the man page for `ps(1)` (on *FreeBSD 14*) for the `-d` option: 

```
-l      Display information associated with the following keywords: uid, pid,
        ppid, cpu, pri, nice, vsz, rss, mwchan, state, tt, time, and command.
```

```
$ ps auxwwl -p 94716 | sed -n 2p
dusko 94716  0.0  0.0 13908 3368 13  I+   10:58   0:00.01 vi ed-notes.md 1001 94704 2  24  0 ttyin
```

So, the **PPID** (parent process ID) of the process ID (**PID**) 94716 is 94704. 

To display the PPID as the last column of the `ps(1)` output, you can use the `-o` option.

```
$ ps auxww -o ppid  -p 94716
USER    PID %CPU %MEM   VSZ  RSS TT  STAT STARTED    TIME COMMAND         PPID
dusko 94716  0.0  0.0 13908 3368 13  I+   10:58   0:00.01 vi ed-notes.md 94704
```

To obtain the value of the last field in the output, you can use `awk(1)`'s variable `$NF`. 

```
$ ps auxww -o ppid -p 94716 | awk '{print NF}'
12
13
```

```
$ ps auxww -o ppid -p 94716 | sed -n 1p | cut -w -f12
PPID
 
$ ps auxww -o ppid -p 94716 | sed -n 2p | cut -w -f13
94704
```


NOTE: For continuing with going up the process tree, refer to *Footnote* 1 [<sup>[1](#footnotes)</sup>]. 


You are interested in displaying a part of the tree with the process that started the `vi(1)` text editor:

```
$ ps auxwd | grep -v grep | grep -B2 94716
dusko   94702   0.0  0.1     115856   11696 v0  I    10:57        0:00.11 |     |-- /usr/local/bin/xterm
dusko   94704   0.0  0.0     107160       8 13  IWs  -            0:00.00 |     | `-- -csh (csh)
dusko   94716   0.0  0.0      13908    3368 13  I+   10:58        0:00.01 |     |   `-- vi ed-notes.md
```

```
$ ps auxwd | grep -v grep | grep -B2 94716 | head -1 | cut -w -f2
94702
```

*Explanation* for the `-d` option for the `ps(1)` utility:

From the man page for `ps(1)` (on *FreeBSD 14*) for the `-d` option: 

```
  Arrange processes into descendancy order and prefix each command
  with indentation text showing sibling and parent/child
  relationships as a tree.
```

NOTE: The `-d` option is a non-standard FreeBSD extension; that is, it's specific to BSD (BSD syntax).

From the man page for `ps(1)` on *FreeBSD 14*:

```
STANDARDS
     For historical reasons, the ps utility under FreeBSD supports a different
     set of options from what is described by IEEE Std 1003.2 ("POSIX.2"), and
     what is supported on non-BSD operating systems.
```

For example, on Debian Linux, running `ps auxwd` generates this error: `error: unsupported option (BSD syntax)`.


The releavant part of the whole process tree:
* Terminal emulator (xterm), with PID 94702   
  * Child:  Shell (C shell, a.k.a. csh), with PID 94704
    * Child: Text editor (vi), with PID 94716   


From `wmctrl --help`:

```
  -l     List windows managed by the window manager.
  -p     Include PIDs in the window list. Very few X applications support this feature.
```

From the man page for `wmctrl(1)`:

```
  -p     Include PIDs in the window list printed by the -l action. Prints
         a PID of '0' if the application owning the window does not
         support it.`
```

```
$ wmctrl -lp | grep 94702
0x0500000c  8 94702  fbsd1.home.arpa xterm
```

```
$ wmctrl -lp | grep 94702 | cut -w -f1
0x0500000c
```


Remove the prefix *0x* because `xwininfo(1)` doesn't do *zero padding* [<sup>[2](#footnotes)</sup>]. 

```
$ wmctrl -lp | grep 94702 | cut -w -f1 | colrm 1 3
500000c
```

```
$ xwininfo -root -tree | grep -n 500000c
546:           0x500000c "xterm": ("xterm" "XTerm")  484x316+0+0  +301+886
```

```
$ xwininfo -root -tree | grep -A10 -B3 500000c
        9 children:
        0xa027aa (has no name): ()  484x316+1+1  +301+886
           1 child:
           0x500000c "xterm": ("xterm" "XTerm")  484x316+0+0  +301+886
              1 child:
              0x5000018 (has no name): ()  484x316+0+0  +301+886
        0xa027ab (has no name): ()  29x29+0+0  +300+885
        0xa027ad (has no name): ()  29x29+457+0  +757+885
        0xa027af (has no name): ()  29x29+0+289  +300+1174
        0xa027b1 (has no name): ()  29x29+457+289  +757+1174
        0xa027ac (has no name): ()  428x1+29+0  +329+885
        0xa027ae (has no name): ()  1x260+485+29  +785+914
        0xa027b0 (has no name): ()  428x1+29+317  +329+1202
        0xa027b2 (has no name): ()  1x260+0+29  +300+914
```


Back to previous `wmctrl(1)` command:

```
$ wmctrl -lp | grep 94702
0x0500000c  8 94702  fbsd1.home.arpa xterm
```

----

## Activate the Window with `wmctrl(1)` 

**Activate the window by switching to its desktop and by raising it.**

```
$ wmctrl -i -a 0x0500000c  
```

*Explanation:*  

From `wmctrl --help`:

```
  -a <WIN>  Activate the window by switching to its desktop and raising it.
  -i        Interpret <WIN> as a numerical window ID.
```


**Move the window to the current desktop and activate it.**

```
$ wmctrl -i -R 0x0500000c  
```

*Explanation:*  

From `wmctrl --help`:

```
-R <WIN>  Move the window to the current desktop and activate it.
```


**Move the window to the specified desktop.**

NOTE: To list all desktops managed by the window manager, use the `-d` option.

```
$ wmctrl -d
0  * DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  Main
1  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  Email
2  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  Editor
3  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  passxc
4  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  mutt
5  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  Desk 6
6  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  Desk 7
7  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  Desk 8
8  - DG: 2560x1440  VP: 0,0  WA: 0,0 2560x1440  net
```

For example, move the window to desktop 8:

```
$ wmctrl -t8 -i -r 0x0500000c  
```

Or:

```
$ wmctrl -i -t8 -r 0x0500000c  
```

*Explanation:*  

From `wmctrl --help`:

```
-r <WIN> -t <DESK>  Move the window to the specified desktop
```

----


# Method 2: Instal and Use `xdotool(1)`

Tools: 
* `xdotool(1)`

Comment of the *xdotool* package (queried from from remote repositories).

```
$ pkg rquery %c xdotool
Programmatically simulate keyboard input or mouse activity
```
 
Description of the *xdotool* package (queried from from remote repositories).

```
$ pkg rquery %e xdotool
Programatically (or manually) simulate keyboard input or mouse activity
using X11's XTEST extension.
```

Home page of the *xdotool* package (queried from from remote repositories).

```
$ pkg rquery %w xdotool
https://www.semicomplete.com/projects/xdotool/
```

Install *xdotool* package.

```
$ sudo pkg install xdotool
```

```
$ ps auxw | grep -v grep | grep 'vi testfile.md'
dusko    8352   0.0  0.0      13908    3476 13  S+   16:59        0:00.01 vi testfile.md
```

```
$ ps auxwd | grep -v grep | grep -B2 'vi testfile.md'
dusko    8328   0.0  0.1     109712   12200 v0  S    16:58        0:00.11 |     |-- /usr/local/bin/xterm
dusko    8330   0.0  0.6     107160   95008 13  Is   16:58        0:00.66 |     | `-- -csh (csh)
dusko    8352   0.0  0.0      13908    3476 13  I+   16:59        0:00.01 |     |   `-- vi testfile.md
```

```
$ ps auxwd | grep -v grep | grep -B2 'vi testfile.md' | head -1 | cut -w -f2
8328
```

```
$ xdotool search --all --pid 8328
83886092
```

Convert from decimal to hexadecimal. 

```
$ printf %s\\n "obase=16; ibase=10; 83886092" | bc
500000C
```

Or - with `printf(1)`:

```
$ printf %x\\n 83886092
500000c
```

```
$ printf %X\\n 83886092
500000C
```

## Activate the Window 

**Activate the window by switching to its desktop and by raising it.**

```
$ wmctrl -i -a 0x500000c
``` 

**NOTE:** `wmctrl(1)` doesn't care about *zero padding* so all of the following commands work.

```
$ wmctrl -t8 -i -a 0x0500000c
```

```
$ wmctrl -t8 -i -a 0x00500000c
```

```
$ wmctrl -t8 -i -a 0x0000500000c
```

```
$ wmctrl -t8 -i -a 0x000000000000000500000c
```


**Move the window to the current desktop and activate it.**

``` 
$ wmctrl -i -R 0x500000c
```


**Move the window to the specified desktop.**

For example, move the window to desktop 3:

```
$ wmctrl -t3 -i -r 0x500000c
```

----

## Tips

Tools:
* `xprop(1)`
* `xlsclients(1)`
* `xdotool(1)`

```
$ xprop -id 0x380000C _NET_WM_PID
_NET_WM_PID(CARDINAL) = 3870
```

```
$ xprop -id 0x380000C 
_NET_WM_STATE(ATOM) = _NET_WM_STATE_HIDDEN
WM_STATE(WM_STATE):
                window state: Iconic
                icon window: 0xa03b42
_NET_FRAME_EXTENTS(CARDINAL) = 1, 1, 1, 1
_KDE_NET_WM_FRAME_STRUT(CARDINAL) = 1, 1, 1, 1
_NET_WM_ALLOWED_ACTIONS(ATOM) = _NET_WM_ACTION_CHANGE_DESKTOP, _NET_WM_ACTION_CLOSE, _NET_WM_ACTION_FULLSCREEN, _NET_WM_ACTION_MAXIMIZE_HORZ, _NET_WM_ACTION_MAXIMIZE_VERT, _NET_WM_ACTION_MINIMIZE, _NET_WM_ACTION_MOVE, _NET_WM_ACTION_RESIZE, _NET_WM_ACTION_SHADE, _NET_WM_ACTION_STICK
_NET_WM_DESKTOP(CARDINAL) = 8
WM_PROTOCOLS(ATOM): protocols  WM_DELETE_WINDOW
_NET_WM_PID(CARDINAL) = 3870
WM_CLIENT_LEADER(WINDOW): window id # 0x380000c
WM_LOCALE_NAME(STRING) = "en_CA.UTF-8"
WM_CLASS(STRING) = "xterm", "XTerm"
WM_HINTS(WM_HINTS):
                Client accepts input or input focus: True
                Initial state is Normal State.
                window id # to use for icon: 0x3800019
WM_NORMAL_HINTS(WM_SIZE_HINTS):
                program specified size: 484 by 316
                program specified minimum size: 10 by 17
                program specified resize increment: 6 by 13
                program specified base size: 4 by 4
                window gravity: NorthWest
WM_CLIENT_MACHINE(STRING) = "fbsd1.home.arpa"
WM_COMMAND(STRING) = { "/usr/local/bin/xterm" }
WM_ICON_NAME(STRING) = "xterm"
WM_NAME(STRING) = "xterm"
```

```
$ xwininfo -id 0x00e0000c

xwininfo: Window id: 0xe0000c "xterm"

  Absolute upper-left X:  245
  Absolute upper-left Y:  1123
  Relative upper-left X:  0
  Relative upper-left Y:  0
  Width: 484
  Height: 316
  Depth: 24
  Visual: 0x21
  Visual Class: TrueColor
  Border width: 0
  Class: InputOutput
  Colormap: 0x20 (installed)
  Bit Gravity State: NorthWestGravity
  Window Gravity State: NorthWestGravity
  Backing Store State: NotUseful
  Save Under State: no
  Map State: IsViewable
  Override Redirect State: no
  Corners:  +245+1123  -1831+1123  -1831-1  +245-1
  -geometry 80x24+244-0
```

```
$ xlsclients -l | grep -n -i 0x380000C
25:Window 0x380000c:
```

```
$ xlsclients -l | sed -n 25,30p
Window 0x380000c:
  Machine:  fbsd1.home.arpa
  Name:  xterm
  Icon Name:  xterm
  Command:  /usr/local/bin/xterm
  Instance/Class:  xterm/XTerm
```

----

## Footnotes

[1] Continuing with going up the process tree.

The *PPID* of the *PID* 94704 is 94702.

```
$ ps auxww -o ppid -p 94704 | awk '{print NF}'
12
13
```

```
$ ps auxww -o ppid -p 94704 | sed -n 2p | cut -w -f13
94702
```



The *PPID* of the *PID* 94702 is 90450.

```
$ ps auxww -o ppid -p 94702 | awk '{print NF}'
12
12
```

```
$ ps auxww -o ppid -p 94702 | sed -n 1p | cut -w -f12
PPID
 
$ ps auxww -o ppid -p 94702 | sed -n 2p | cut -w -f12
90450
```


The *PPID* of the *PID* 90450 is 90425.

```
$ ps auxww -o ppid -p 90450 | awk '{ print NF }'
12
13
```

```
$ ps auxww -o ppid -p 90450 | sed -n 2p | cut -w -f13
90425
```


The *PPID* of the *PID* 90425 is 90424.

```
$ ps auxww -o ppid -p 90425 | sed -n 2p | awk '{ print NF }'
12
 
$ ps auxww -o ppid -p 90425 | sed -n 2p | cut -w -f12
90424
```


The *PPID* of the *PID* 90424 is **PID 1**.

```
$ ps auxww -o ppid -p 90424 | sed -n 2p | awk '{print NF}'
14
 
$ ps auxww -o ppid -p 90424 | sed -n 2p | cut -w -f14
1
```


[2] `wc(1)` also counts the newline (a.k.a. **NL**, or **nl**, or **line feed**, or **LF**, or **lf**).


```
$ wmctrl -lp | grep 72210 | cut -w -f1 | wc -c
      11

$ wmctrl -lp | grep 72210 | cut -w -f1 | wc -m
      11
```


With the following sed command, place every character on a new line.

Note *a blank line* (an empty line) at the end of the output.

```
$ wmctrl -lp | grep 94702 | cut -w -f1 | sed 's/\n$/H/' | sed 's/\(.\)/\1\n/g'
```

Output:

```
0
x
0
5
0
0
0
0
0
c

```


```
$ wmctrl -lp | grep 94702 | cut -w -f1 | sed 's/\n$/H/' | sed 's/\(.\)/\1\n/g' | wc -l
      11
```


```
$ wmctrl -lp | grep 94702 | cut -w -f1 | cat -vet
0x0500000c$
```

```
$ wmctrl -lp | grep 94702 | cut -w -f1 | vis -w
0x0500000c\012$ 
 
$ wmctrl -lp | grep 94702 | cut -w -f1 | vis -l
0x0500000c\$
```

Octal **012** is **LF** (line feed) in ASCII.

See `man 7 ascii`.


```
$ wmctrl -lp | grep 94702 | cut -w -f1 | od -ta
0000000    0   x   0   5   0   0   0   0   0   c  nl                    
0000013
 
$ wmctrl -lp | grep 94702 | cut -w -f1 | od -tc
0000000    0   x   0   5   0   0   0   0   0   c  \n                    
0000013
```

```
$ wmctrl -lp | grep 94702 | cut -w -f1 | awk '{ print length($0) }'
10
``` 

``` 
$ wmctrl -lp | grep 94702 | cut -w -f1 | awk '{ print length }'
10
```

Tools:
* `xxd(1)`
* `hexdump(1)`, `hd(1)`
* `od(1)`

----

## References
(Retrieved on Aug 5, 2024)

* [How to convert a X11 window ID to a process ID?](https://stackoverflow.com/questions/1131277/how-to-convert-a-x11-window-id-to-a-process-id?rq=1)

* [How to get an X11 Window from a Process ID?](https://stackoverflow.com/questions/151407/how-to-get-an-x11-window-from-a-process-id)

* [Is there a Linux command to determine the window IDs associated with a given process ID?](https://stackoverflow.com/questions/2250757/is-there-a-linux-command-to-determine-the-window-ids-associated-with-a-given-pro?rq=1)

* [wmctrl Command line tool to interact with an EWMH/NetWM compatible X managers -- FreshPort - The Place for Ports](https://www.freshports.org/x11/wmctrl)

* [wmctrl - a UNIX/Linux command line tool to interact with an EWMH/NetWM compatible X Window Manager](https://www.freedesktop.org/wiki/Software/wmctrl/)

* [wmctrl Examples - Archived from original on Sep 7, 2012](https://web.archive.org/web/20120907043247/http://spiralofhope.com/wmctrl-examples.html)

* [Why does the wc command count one more character than expected?](https://stackoverflow.com/questions/31584361/why-does-the-wc-command-count-one-more-character-than-expected)

* [Counting the characters of each line with wc](https://unix.stackexchange.com/questions/400650/counting-the-characters-of-each-line-with-wc)

* [Character count in Unix wc command](https://unix.stackexchange.com/questions/66360/character-count-in-unix-wc-command)

* [Placing every character on a new line](https://stackoverflow.com/questions/9899049/placing-every-character-on-a-new-line)

