---
layout: post
title: "HOWTO Change Themes and Colours in GTK Applications"
date: 2025-10-07 10:28:08 -0700 
categories: dotfiles wiki x11 xorg howto cli terminal shell
---

AKA: HOWTO Change Themes and Colours in Zim Desktop Wiki

----


OS: FreeBSD 14

```
% freebsd-version 
14.3-RELEASE-p1
```
 
Shell:

```
% ps $$
  PID TT  STAT    TIME COMMAND
43316  8  Ss   0:00.13 -csh (csh)
```

X11 Window Manager: 

```
% cat ~/.xinitrc
---- snip ----
exec fvwm3
```

----

```
% env GTK_DEBUG=interactive zim
```


In the  debugger, click  'Visual'  tab.

For 'GTK+ Theme' drop-down menu, change it from  'decay' to some other theme, e.g. Yaru-viridian.


GTK themes are in:

```
/usr/local/share/themes/
```

Example:

```
% cat /usr/local/share/themes/Yaru-viridian/index.theme
[Desktop Entry]
Name=Yaru-viridian
Type=X-GNOME-Metatheme
Comment=Ubuntu Yaru-viridian theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Yaru-viridian
MetacityTheme=Yaru
IconTheme=Yaru-viridian
CursorTheme=Yaru
CursorSize=24
X-Yaru-Dark=false
X-Yaru-Accent-Name=viridian
X-Yaru-Accent-Color=#03875B
```

```
% cat /usr/local/share/themes/Yaru-viridian/gtk-3.0/gtk.css
@import url("resource:///com/ubuntu/themes/Yaru-viridian/3.0/gtk.css");
```

```
% ls -Alh ~/.config/gtk-3.0/
total 9
-rw-r--r--  1 dusko wheel  226B Oct  7 21:02 gtk.css
-rw-r--r--  1 dusko wheel  467B Mar  5  2025 settings.ini
```

```
% grep theme ~/.config/gtk-3.0/settings.ini
gtk-cursor-theme-name=XCursor-Pro-Decay
gtk-cursor-theme-size=0
gtk-icon-theme-name=Papirus-Dark
gtk-theme-name=decay
```

```
% grep gtk-theme-name ~/.config/gtk-3.0/settings.ini
gtk-theme-name=decay
```


This worked (you can ignore warnings):

```
% env GTK_THEME=Yaru-viridian zim
```

---

# References

* [how to change theme in 0.73.2 #1284](https://github.com/zim-desktop-wiki/zim-desktop-wiki/issues/1284)


* [Option to Change background and font color #755](https://github.com/zim-desktop-wiki/zim-desktop-wiki/issues/755)

* [Option to Change background and font color #1802](https://github.com/zim-desktop-wiki/zim-desktop-wiki/discussions/1802)


----

