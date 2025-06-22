---
layout: page
title: "Fonts - Larger Monospaced in Terminal: Bitmap and Xft (TrueType) [WIP]"
---

# My Preference for Larger Traditional X Bitmap Monospaced Fonts in Terminals 

My current (as of Jun 15, 2025) traditional X11 bitmap monospaced font is **Gallant**. 

* Traditional X bitmap font: Gallant is likely designed in the X11 bitmap font format, which is a common format for bitmap fonts used in X Window System environment.
These fonts are typically fixed in size and are represented as pixel images for each character.
* Monospaced: As a monospaced font, Gallant ensures that each character occupies the same amount of horizontal space.
This uniformity is essential for programming, text editing, and terminal applications, where alignment of text is important.

## How To Use Gallant Font with Xterm

For example, to use the Gallant font with xterm and with a font size of 14 points, run this command:

```
% xterm -fa gallant -fs 14
```

----

From [https://github.com/MicahElliott/Orp-Font](https://github.com/MicahElliott/Orp-Font) (Retrieved on Jun 15, 2025):

> There are two major type systems in X: [Core and Xft](http://www.xfree86.org/current/fonts2.html).
> Core fonts are *bitmaps* and are recommended in a terminal.
> They come in the form of *BDFs* (and are *compressed* as *PCFs*).
> 
> *Xft* fonts are *antialiased* and you don't want these *unless* you're looking at *larger fonts*.
> You'll recognize them as *TTFs*.
> Actually, you can selectively turn off antialiasing of TTFs, but still doesn't solve the lack of bold/italic offerings.



```
------------
== 75 dpi ==
------------

-Adobe-Courier-Medium-R-Normal--14-140-75-75-M-90-ISO10646-1
-Adobe-Courier-Medium-R-Normal--18-180-75-75-M-110-ISO10646-1
-Adobe-Courier-Medium-R-Normal--24-240-75-75-M-150-ISO10646-1
-B&H-LucidaTypewriter-Medium-R-Normal-Sans-18-180-75-75-M-110-ISO10646-1
-B&H-LucidaTypewriter-Medium-R-Normal-Sans-19-190-75-75-M-110-ISO10646-1
-B&H-LucidaTypewriter-Medium-R-Normal-Sans-24-240-75-75-M-140-ISO10646-1

--------------
== 100 dpi ==
--------------

-Adobe-Courier-Medium-R-Normal--20-140-100-100-M-110-ISO10646-1
-Adobe-Courier-Medium-R-Normal--25-180-100-100-M-150-ISO10646-1
-Adobe-Courier-Medium-R-Normal--34-240-100-100-M-200-ISO10646-1
-B&H-LucidaTypewriter-Medium-R-Normal-Sans-20-140-100-100-M-120-ISO10646-1
-B&H-LucidaTypewriter-Medium-R-Normal-Sans-25-180-100-100-M-150-ISO10646-1
-B&H-LucidaTypewriter-Medium-R-Normal-Sans-26-190-100-100-M-159-ISO10646-1
-B&H-LucidaTypewriter-Medium-R-Normal-Sans-34-240-100-100-M-200-ISO10646-1

----------
== misc == 
----------

-Misc-Fixed-Medium-R-Normal--20-200-75-75-C-100-ISO10646-1
-Sony-Fixed-Medium-R-Normal--24-170-100-100-C-120-ISO8859-1
-Misc-Fixed-Medium-R-Normal-ja-18-120-100-100-C-180-ISO10646-1
-Misc-Fixed-Medium-R-Normal-ko-18-120-100-100-C-180-ISO10646-1
-Misc-Fixed-Medium-R-Normal--15-140-75-75-C-90-ISO10646-1
-Misc-Fixed-Medium-R-Normal--18-120-100-100-C-90-ISO10646-1
```


## How To Use These Fonts with Xterm

```
% xterm -fn "-Adobe-Courier-Medium-R-Normal--18-180-75-75-M-110-ISO10646-1"
```

----


# My Preference for Larger Xft (TrueType) Monospaced Fonts in Terminals 

## Getting a List of Fonts to Try

If you have fontconfig, here's how to determine which monospaced scalable fonts you have installed, ie those that are suitable for terminal use:

```
% fc-list :spacing=mono:scalable=true family | sort
```

## Monospaced Sans fonts vs. Monospaced Serif fonts

For terminal use, some people prefer monospaced sans fonts over monospaced serif fonts because for them serifs interfere with readability.

----

# Fonts

From [Guide to X11/Fonts](https://en.wikibooks.org/wiki/Guide_to_X11/Fonts#Core_versus_Xft_fonts) (Retrieved on Jun 15, 2025):

When your X11 clients draw text, they use *fonts*, which are drawings of standard characters, such as letters, numerals, and punctuation.
At minimum, a font is a *typeface* (also called *family*) such as *Bitstream Vera Sans, Luxi Mono, Nimbus Roman No9 L, or fixed*.
More specifically, a font includes a size or style, such as **Bitstream Vera Sans Bold Italic 10 point**.

Fonts also come in three categories called *serif* (like Nimbus Roman No9 L), *sans-serif* (like Bitstream Vera Sans), and *monospace* (like Luxi Mono or "fixed").

Fonts come in several font formats such as bitmap, TrueType, and PostScript.

TrueType fonts are *.ttf* files.
If the X11 server and client are at different computers, then you might have installed different fonts at each computer. 


# Core versus Xft fonts

X11 clients can draw texts in several different manners:

1. Use the *original core X11 protocol* to draw text.
With this approach, the X11 server loads and stores each character of a font. Thus, if the X11 server (with the screen and keyboard) and the X11 client (with your web browser or other window) are at different computers, then you must install fonts at the server. The server converts the characters into *bitmaps* and draws them *upright*, which means that you *cannot rotate them*.
Further, the server *never antialiases* the fonts.
2. Use the ***Xft** library* and *RENDER extension to draw text*.
With this approach, the X11 client loads and stores each character of a font.
You must install fonts at the client machine.
The client converts the characters into geometric shapes.
It decomposes the shapes into basic shapes such as triangles and trapezoids, then sends these to the server.
The server draws the shapes and *optionally provides antialiasing*, which *smooths the appearance of fonts*.
One *can also rotate these shapes*.
3. Use a *client-side library* such as *libart_lgpl or SDL_ttf to draw text*.
While libart_lgpl is a vector-graphics library, SDL_ttf is a library to draw text for programs that use the cross-platform Simple DirectMedia Layer. Typically, these libraries load the geometric shapes, then draw them into bitmaps, possibly antialiased and rotated, before sending them to the X11 server, as if the X11 server knew nothing about text. It is also possible for these libraries to do as Xft does and use RENDER.

The first X11 clients used the core X11 protocol to draw text, as that was the only choice.
However, several clients now use Xft.
Because *GTK+* and *Qt*, the *toolkits behind several applications including all GNOME and KDE applications*, switched to *Xft*, many programs on most desktops, including Konqueror, now use Xft.


**Also**:

[An Introduction to Xft - aka An Xft Tutorial - Keith Packard - XFree86 Core Team, SuSE Inc.](https://keithp.com/~keithp/render/Xft.tutorial) (Retrieved on Jun 15, 2025)

> This is a quick tutorial about the basics of Xft; a comparison to core X
routines is given along with some brief examples

# Configuring Xft with fontconfig

[https://en.wikibooks.org/wiki/Guide_to_X11/Fonts#Configuring_Xft_with_fontconfig](https://en.wikibooks.org/wiki/Guide_to_X11/Fonts#Configuring_Xft_with_fontconfig)


## Installing new fonts

[https://en.wikibooks.org/wiki/Guide_to_X11/Fonts#Installing_new_fonts](https://en.wikibooks.org/wiki/Guide_to_X11/Fonts#Installing_new_fonts)


**Also:**

## Installing fonts

From [Fonts in XFree86 : Installing fonts](https://www.xfree86.org/current/fonts2.html) (Retrieved on Jun 15, 2025)

This section explains how to configure both Xft and the core fonts system to access newly-installed fonts.

### Configuring Xft

Subsections:

* Installing fonts in Xft 
* Fine-tuning Xft  
* Configuring applications
* Troubleshooting 

### Configuring the core X11 fonts system

Subsections:

* Installing bitmap fonts
* Installing scalable fonts 
* Installing CID-keyed fonts 
* Setting the server's font path 
* Temporary modification of the font path
* Permanent modification of the font path 
* Troubleshooting 


**Also:**

### Adding a font to your system

From [Adding a font to your system](http://osr507doc.sco.com/en/GECG/X_Font_ProcAddFn.html) (Retrieved on Jun 15, 2025):

* Place the new font file or files in the directory in which you want to store them.
* (Optional) Run the bdftopcf utility, if desired, to convert BDF font files to PCF files:

```
bdftopcf font.bdf > font.pcf
```

* Run the mkfontdir command and indicate the font's directory location, if necessary:

```
mkfontdir font_location
```

* If you added fonts to a directory not in the current font path, add the new directory to the font search path:

```
xset fp+ font_location
```

* Reset the server's font database with the following command:

```
xset fp rehash
```


**Also:**

## Installing Orp-Font fonts from source

From [GitHub - MicahElliott/Orp-Font: Small bitmap pixel-perfect fonts in medium, bold, italic, book, with extended glyphs, for X11 (urxvt and xterm)](https://github.com/MicahElliott/Orp-Font) (Retrieved on Jun 15, 2025)

[https://github.com/MicahElliott/Orp-Font?tab=readme-ov-file#from-source](https://github.com/MicahElliott/Orp-Font?tab=readme-ov-file#from-source)

> If you just want to start using the provided Orp fonts without tweaking glyphs or moving things around, all you need to do is run:

```
% cd orp-font
% xset +fp $PWD/misc
```

> You should now be able to fire up an xterm (or better: urxvt) and see the new Orp you just "installed":

```
% xterm -fn '-misc-orp-medium-r-*--*-*-*-*-*-*-iso10646-1'
```

> Put the ``xset`` line (hard-code expanded ``$PWD``) into your ``~/.Xdefaults`` and you're now permanent!
>
> [ . . . ]
>
> I've taken my very favorite existing monospace font, [Pro Font](http://en.wikipedia.org/wiki/Pro_font), adapted an xterm friendly BDF for it, and enhanced some of its glyphs to be slightly more friendly.
> Plus, I’ve added a few other derivative fonts that make up the Orp family.
>
> [ . . . ]
>
> All you need to understand
>
> A *BDF file* is the 'source code' of your font.
> It is modifiable via a tool called ``gbdfed`` (Gtk BDF EDitor), which is pretty easy for any n00b to start whacking glyphs with.
 After you're happy with your BDF you run it through a bunch of tools that create an output *(gzipped) PCF file*.
> Finally you tell X to start using the font/directory.
> 
> There are two major type systems in X: [Core and Xft](https://www.xfree86.org/current/fonts2.html)
> Core fonts are "bitmaps" and are *what you want in a terminal*.
> They come in the form of *BDFs* (and are *compressed* as *PCFs*).
> Xft fonts are antialiased and you don't want these [in a terminal] *unless* you're looking at *larger fonts*.
> You'll recognize them as *TTFs*.
> Actually, you can selectively turn off antialiasing of TTFs, but still doesn't solve the lack of bold/italic offerings.
>
> [ . . . ]
>
>
> Figure out what your new font is actually called.

```
% xfontsel
```

> Make sure your new font shows up under 'fmly' and select it.
You can paste that crazy -*-my font-*-... string into your ``~/.Xdefaults-$(hostname)`` file.
> My preference:

```
*font:       -misc-orp-medium-r-*-*-12-*-75-75-*-60-iso10646-*
*boldFont:   -misc-orp-bold-r-*-*-*-*-*-*-*-*-iso10646-1
*italicFont: -misc-orp-*-i-*-*-*-*-*-*-*-*-iso10646-1
```

> You can see it and other fonts on the system with ``xlsfonts`` (and maybe ``fc-list``).

> 
> [ . . . ]
>

----

## References

* [Guide to X11/Fonts](https://en.wikibooks.org/wiki/Guide_to_X11/Fonts#Core_versus_Xft_fonts) (Retrieved on Jun 15, 2025)

* [A semi-brief history and overview of X fonts and font rendering technology - Posted on May 19, 2012](https://utcc.utoronto.ca/~cks/space/blog/unix/XFontTypes) (Retrieved on Jun 15, 2025)
  - [Comments on this page](https://utcc.utoronto.ca/~cks/space/blog/unix/XFontTypes?showcomments#comments):

> From 193.219.181.217 at 2016-02-11 06:11:37:
> While this is an old post, it's a useful introduction to fonts in X, and it would be nice to update it somewhat.
> In particular, Xft is only one of several font drawing libraries, and a somewhat limited one; most "larger" toolkits render through Pango instead, so they get fancier features like better RTL support, better font fallback, etc.
>
> By cks (author of the blog - Chris Siebenmann) at 2016-02-11 11:35:09:
> As far as I know, FreeType/XFT remains the dominant underlying font technology for things like Pango; this Pango documentation describes XFT as the default backend.
> Even Cairo appears to default to using FreeType/XFT as its normal font backend on Unix.
> As part of this it appears that Pango inherits the normal XFT font configuration methods, although I wouldn't be surprised if it overrides hinting instructions at least some of the time.

* [Fonts in XFree86 : Installing fonts](https://www.xfree86.org/current/fonts2.html) (Retrieved on Jun 15, 2025)

* [An Introduction to Xft - aka An Xft Tutorial - Keith Packard - XFree86 Core Team, SuSE Inc.](https://keithp.com/~keithp/render/Xft.tutorial) (Retrieved on Jun 15, 2025)

* [GitHub - MicahElliott/Orp-Font: Small bitmap pixel-perfect fonts in medium, bold, italic, book, with extended glyphs, for X11 (urxvt and xterm)](https://github.com/MicahElliott/Orp-Font) (Retrieved on Jun 15, 2025)

* [Adding a font to your system](http://osr507doc.sco.com/en/GECG/X_Font_ProcAddFn.html) (Retrieved on Jun 15, 2025)

* [Console Monospace Fonts Collections](https://github.com/NCBM/console-mono-fonts-collections) (Retrieved on Jun 15, 2025)

> This project gathers monospace fonts which are compatible with wide/full-size characters, typically CJK characters, in horizontal metrics as well.
> Technically CJK characters are perfectly double wider than latin letters etc. 

* [X Terminal TrueType Fonts](https://contented.qolc.net/articles/x-terminal-truetype-fonts/) (Retrieved on Jun 15, 2025)

* [X Terminal Program Comparison](https://contented.qolc.net/articles/x-terminal-program-comparison/) (Retrieved on Jun 15, 2025)
> As a result of eye problems, I started to investigate the visual features offered by different X terminal programs, such as support for TrueType fonts or vertical spacing adjustment.
> This article features a comparison table and some notes about what I have found so far. It may be of particular interest to the partially sighted or anyone who works long hours in terminal windows.

* [bitmap-fonts -- Monospaced bitmap fonts for X11, good for terminal use](https://github.com/Tecate/bitmap-fonts) (Retrieved on Jun 15, 2025)
> A collection of monospaced bitmap fonts for X11, good for terminal use.
> These fonts were not created by me, the authors are listed below.
> Some of these fonts may be out of date.
> If something doesn't work check the archives file and see if there is a readme included with the font, or take a look at the creators website listed below.
>
> This repo is an attempt to catalog all existing bdf/pcf fonts.

* [XTerm monospace font examples](https://bezoar.org/posts/2023/0214/font-screenshots/) (Retrieved on Jun 15, 2025)
> My eyesight sucks, so I use an XTerm with 80x40+0+0 geometry and large characters.
> 
> I tried quite a few fonts before settling on my favorites:
> * xft:Menlo-Regular:pixelsize=20:bold
> * xft:SFMono-Regular:pixelsize=19:bold
> * xft:Bitstream Vera Sans Mono:pixelsize=21:bold
> * xft:Cascadia:pixelsize=20:bold
> 
> Here are some screenshots of fonts I tested showing the first 33 lines of the SSH(1) manpage.
> 
> The xterm command used looks like this:
> 
> ```
> /usr/local/bin/xterm -geometry 80x34+0+0 -j -b 10 -sb -si -sk -cr blue \
>   -sl 4000 -bd black -bg white -fa xft:Cascadia:pixelsize=20:bold
> ```

* [x11 - Larger "xterm" fonts on HIDPI displays - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/219370/larger-xterm-fonts-on-hidpi-displays) (Retrieved on Jun 15, 2025)

* [Changing font in urxvt, what's available? - ArchLinux Wiki](https://bbs.archlinux.org/viewtopic.php?id=139831) (Retrieved on Jun 15, 2025)
>
> To figure out xft and fontconfig took me quite a bit of trial and error.
> ' man fc-list' is not very helpful, the docs in '/usr/share/doc/fontconfig/' are better.
> 'fc-list' lists more than just TTF and OTF fonts.
>
> ```
> $ fc-list : | sort   ## list all fonts and styles known to fontconfig
> $ fc-list -f "%{family}\n" :lang=ja    ## list all japanese font families
> $ fc-list -f "%{family} : %{file}\n" :spacing=100 | sort    ## list monospace fonts by family and file
> $ fc-list :style=Bold | sort    ## all bold fonts
> # fc-list -f "%{file} " | xargs pacman -Qqo | sort -u    ## list font packages installed by pacman
> ```
> 
> It was not an easy Google search to find examples when I first tried to learn how to use fc-list.
>
> [ . . . ]
>
> If you installed xorg-fonts-100dpi or xorg-fonts-75dpi or the artwiz-fonts you would have quite a few pcf fonts, such as Courier and Lucida Typewriter.
> Many show up when I list monospace fonts.
> fc-list is used to list and filter the fonts that fontconfig knows.
> If you want to know most of the options a particular font has, you use th '-v' option to fc-list.
> '-f' is used to format and filter the information that is in the output.
> 
> ```
> $ fc-list -f "%{file}\n" :spacing=100 | grep pcf  ## monospace pcf font files
> /usr/share/fonts/100dpi/lutBS19.pcf.gz
> /usr/share/fonts/artwiz-fonts/smoothansi.pcf
>     ...<cut>
> ```
>
> Try the difference between something like these two commands:
> 
> ```
> $ fc-list :family=LucidaTypewriter:style=Sans  ## then try...
> $ fc-list -v :family=LucidaTypewriter:style=Sans
> ```
>
> You should be able to figure out the different font properties by referencing the documentation.
> A font does not have to include all (any?) of the font properties given in the fontconfig docs.
>
> [ . . .]
>
> ``` 
> $ pacman -S xorg-xfontsel gtk2fontsel
> ``` 
>
> `xfontsel` shows you all the X11 fonts.
> `gtk2fontsel` shows you the xft fonts.
> You put those in Xdefaults like this:
>
> ```
> Rxvt*font:    -*-clean-medium-r-*--12-*-*-*-*-*-*-*
> Rxvt*font:    xft:Bitstream Vera Sans Mono-8
> ```
>
> (respectively)
>
> To me, this is the most sensible way to do it, because you can try out fonts without actually having to set them and spawn a new urxvt.
> 
> [ . . . ]
>
> `xfontsel` is exactly what I needed.
>
> Thanks again for the help everyone.

---

* [Font configuration - Arch Linux Wiki](https://wiki.archlinux.org/title/Font_configuration) (Retrieved on Jun 15, 2025)

* [Fixed (typeface) - aka misc-fixed -- Wikipedia](https://en.wikipedia.org/wiki/Fixed_(typeface)) (Retrieved on Jun 15, 2025)
> *misc-fixed* is a collection of *monospace bitmap fonts* that is *distributed with the X Window System*.
> It is a set of independent bitmap fonts which - apart from all being sans-serif fonts - cannot be described as belonging to a single font family.
> The misc-fixed fonts were the *first fonts available* for the X Window System.
> Their individual origin is not attributed, but it is likely that many of them were created in the early or mid 1980s as part of MIT's Project Athena, or at its industrial partner, DEC.
> The misc-fixed fonts are in the public domain.

* [List of monospaced typefaces - Wikipedia](https://en.wikipedia.org/wiki/List_of_monospaced_typefaces) (Retrieved on Jun 15, 2025)

* [Rasher's Rockbox related stuff - Fonts - misc](http://rasher.dk/rockbox/fonts/misc/) (Retrieved on Jun 15, 2025)
It has all sizes of *fixed-misc* available as images and downloads in a `.fnt` format.

* [Configuring fonts for xterm, urxvt, emacs and others - Super User](https://superuser.com/questions/263104/configuring-fonts-for-xterm-urxvt-emacs-and-others) (Retrieved on Jun 15, 2025)

* [Configure unreadable, tiny, small, ..., huge Xterm fonts - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/332316/configure-unreadable-tiny-small-huge-xterm-fonts) (Retrieved on Jun 15, 2025)

* [How Sub-Pixel Font-Rendering Works - Splitting the Pixel: When is a pixel not a pixel?](https://www.grc.com/ctwhat.htm) (Retrieved on Jun 15, 2025)


