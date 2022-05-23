---
layout: post
title: "How To List All Fonts That Contain a Particular UTF-8/Unicode Character" 
date: 2021-11-06 21:03:22 -0700 
categories: xterm font unicode utf-8 unix x11 fontconfig locale
---

**tl;dr:**   
- List all fonts that contain a particular character.  
- If your system doesn't have a font that contain that character: 
  find fonts that include the missing character.
- Render the character properly.   


> This page contains some uncommon Unicode characters.  
> If your web browser displays them as different unreadable symbols 
> (question marks, boxes, or other symbols), you most likely need to 
> install additional fonts that contain the missing characters.   

----

**Example 1:** List all fonts that include the Skull and Crossbones 
symbol (U+2620): 

Enter the following in your terminal emulator.  

```
% printf '%x' \'☠ | xargs -Ireplstr fc-list ":charset=replstr" 
```

**Example 2:** List all fonts that include the 
character 顠 (CJK Unified Ideograph-9860) (U+9860):

```
% printf '%x' \'顠 | xargs -Ireplstr fc-list ":charset=replstr" 
```

**Example 3:** For **NSM** (**Non-Spacing Mark**) characters, which are 
problematic [¹] to display on terminal emulators. For example, 
list all fonts that include the Combining Circumflex Accent (U+0302): 

a) Method 1

```
% printf  ̂ | xsel -i
% xsel -o > xselo
```

```
% printf "%x" \'`less xselo` | xargs -Ireplstr fc-list ":charset=replstr"
```

b) Method 2

```
% printf "%x" \'`printf  ̂ ` | xargs -Ireplstr fc-list ":charset=replstr" 
```

Note:  
Quotes around ```less``` and ```printf``` above are the backtick 
character or the backquote (`), named "Grave Accent" in Unicode (U+0060).

[¹] 
For example, the Combining Circumflex Accent (U+0302) is at first visible 
in xterm when displayed with ```xsel -o | less```:

```
% printf  ̂ | xsel -i

% xsel -o | less
 ̂
```

However, after scrolling off the screen/screenful in xterm, the character 
(on the last line) disappears, appearing again if you select the last line 
with the mouse but even then when you copy that line, the character 
(Combining Circumflex Accent (U+0302)) is missing when pasted into other document.


Why is this? (a.k.a.: So, how to display non-spacing marks?)

A: To display a non-spacing mark by itself, apply it to a space.


Reference:  
From 
Unicode Demystified
(published by Addison-Wesley Professional, 
publication date: September 2002):

**Non-spacing mark**   
A combining character that takes up no space along the baseline. 
Non-spacing marks usually are drawn above or below the base character 
or overlay it.

A non-spacing mark always combines with the character that **precedes** it. 
If the backing store contains the character codes

```
U+006F LATIN SMALL LETTER O
U+0302 COMBINING CIRCUMFLEX ACCENT 
U+006F LATIN SMALL LETTER O
```

they represent the sequence

```
öo
```

and not the sequence

```
oö
```


**Example 4:** 
To show a non-spacing mark appearing by itself, apply it to a space. 
Unicode provides spacing versions of some non-spacing marks, generally 
for backward compatibility with some legacy encoding. Nevertheless, you 
can get any non-spacing mark to appear alone by preceding it with a space. 
In other words, U+0020 SPACE followed by U+0302 COMBINING CIRCUMFLEX ACCENT 
gives you a spacing (i.e., non-combining) circumflex accent. 


```
% ./uni.pl 0302
 ̂       0302    COMBINING CIRCUMFLEX ACCENT
```

```
% ./uni.pl 0303 | cut -f1 | xxd -p
cc830a
```

```
% printf %d 0x0a
10% 
 
% printf %o 0x0a
12% 
```

Ignore '0a' - it's ASCII hexadecimal 0a (decimal 10, octal 12).
ASCII 10 is the Line Feed character (LF).

```
% ./uni.pl 0303 | cut -f1 | xxd -p -l2
cc83
```


```
% printf %o 0xcc
314% 

% printf %o 0x83
203% 
```

Without a space, the Combining Circumflex Accent character (U+0302) is not displayed. 

```
% printf '\314\203'
```

The U+0020 SPACE (040 in octal) followed by U+0302 COMBINING CIRCUMFLEX ACCENT  
(UTF-8: 0xCC 0x83, 314 203 in octal) gives you a spacing (i.e., non-combining) 
circumflex accent. 


```
% printf '\040\314\203'
 ̃% 
```

```
% printf '%x' \'`printf '\40\314\203'` | xargs -Ireplstr fc-list ":charset=replstr" | wc -l
     632
```


```
% printf '%x' \'ç | xargs -Ireplstr fc-list ":charset=replstr" | wc -l
    1915
 
% printf '%x' \'ç | xargs -Ireplstr fc-list ":charset=replstr" | grep -i arvo
/home/dusko/.fonts/arvo.ttf: Arvo:style=Regular
/home/dusko/.fonts/arvo-bold-italic.ttf: Arvo:style=Bold Italic
/home/dusko/.fonts/arvo-bold.ttf: Arvo:style=Bold
/home/dusko/.fonts/arvo-italic.ttf: Arvo:style=Italic

% printf '%x' \'ç
e7%
```


```xfd(1)``` displays all the characters in an X font.  

To specify a point size, add the size before the column (:) as shown below 
for a sample for a font size of 18:

```
% xfd -fa "IBM Plex Mono-18:style=Regular"
```

```
% xfd -start <decimal_value> -fa <font_name>
```


```
% ./uni.pl ç
ç       00E7    LATIN SMALL LETTER C WITH CEDILLA

% ./uni.pl ç | cut -f1 | xxd -p
c3a70a
```

Note:  
```0x0a``` in hex is 10 in decimal.   
ASCII 10 is the Line Feed character (LF).

```
% printf %d\\n 0x0a
10

% man ascii | grep -i 0a
   08 BS   09 HT   0a LF   0b VT   0c FF   0d CR   0e SO   0f SI
```

Don't take the LF into account (which is the third octet).
In other words, make a hexdump of the first two octets:

```
% ./uni.pl ç | cut -f1 | xxd -p -l 2
c3a7
```


Since POSIX-compatible way of printing ??? is to use octal, 
convert from hexadecimal to octal.

```
% printf %o 0xc3
303% 
 
% printf %o 0xa7
247% 
```

Print the character by using printf and its octal notation.

```
% printf '\303\247'
ç% 
```

The **uni.pl** Perl script identified Unicode code point of the 
character as ```U+00E7``` (see above).  As ```xfd(1)``` uses decimal 
for its ```-start``` option, convert it to decimal.

```
% printf %d 0xE7
231%
```

```
% xfd -fa "Arvo:style=Regular"

% xfd -start 231 -fa "Arvo:style=Regular"
```

---- 


For **non tl;dr**, continue reading. 

----

**Note:**
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.

Local **environment**:  
FreeBSD 13.0-RELEASE-p3, terminal emulator: xterm(1),
csh (tcsh) shell, user's home directory: /home/dusko.

```tcsh``` is linked to ```csh``` in FreeBSD. It doesn't matter which 
one you type, you will still use the tcsh shell.


```
% freebsd-version
13.0-RELEASE-p3

% uname -a
FreeBSD fbsdx280.my.domain 13.0-RELEASE-p3 FreeBSD 13.0-RELEASE-p3 #0: 
  Tue Jun 29 19:46:20 UTC 2021 
  root@amd64-builder.daemonology.net:/usr/obj/usr/src/amd64.amd64/sys/GENERIC
  amd64

% ps $$
  PID TT  STAT    TIME COMMAND
98359  4  Ss   0:00.02 -tcsh (tcsh)

% xterm -version
XTerm(368)

% grep dusko /etc/passwd 
dusko:*:1001:1001:dusko:/home/dusko:/bin/tcsh

% cd 
 
% pwd
/usr/home/dusko
 
% ls -ld /home
lrwxr-xr-x  1 root  wheel  8 Mar 16  2019 /home -> usr/home
```

```
% locale
LANG=en_CA.UTF-8
LC_CTYPE="en_CA.UTF-8"
LC_COLLATE="en_CA.UTF-8"
LC_TIME="en_CA.UTF-8"
LC_NUMERIC="en_CA.UTF-8"
LC_MONETARY="en_CA.UTF-8"
LC_MESSAGES="en_CA.UTF-8"
LC_ALL=
```

The default ```tcsh``` prompt displays ```%``` when you're logged in as 
a regular user and ```hostname#``` when you're logged in as the superuser. 


```
% setxkbmap -print
xkb_keymap {
        xkb_keycodes  { include "evdev+aliases(qwerty)" };
        xkb_types     { include "complete"      };
        xkb_compat    { include "complete"      };
        xkb_symbols   { include "pc+us+rs(latinunicode):2+rs:3+inet(evdev)+group(rctrl_toggle)" };
        xkb_geometry  { include "pc(pc105)"     };
};
```

```
% stty -a
speed 38400 baud; 20 rows; 80 columns;
lflags: icanon isig iexten echo echoe echok echoke -echonl echoctl
        -echoprt -altwerase -noflsh -tostop -flusho -pendin -nokerninfo
        -extproc
iflags: -istrip icrnl -inlcr -igncr ixon -ixoff ixany imaxbel -ignbrk
        brkint -inpck -ignpar -parmrk
oflags: opost onlcr -ocrnl tab0 -onocr -onlret
cflags: cread cs8 -parenb -parodd hupcl -clocal -cstopb -crtscts -dsrflow
        -dtrflow -mdmbuf rtsdtr
cchars: discard = ^O; dsusp = ^Y; eof = ^D; eol = <undef>;
        eol2 = <undef>; erase = ^H; erase2 = ^H; intr = ^C; kill = ^U;
        lnext = ^V; min = 1; quit = ^\; reprint = ^R; start = ^Q;
        status = ^T; stop = ^S; susp = ^Z; time = 0; werase = ^W;
```

```
% tty
/dev/pts/5
```


**TIP**   
For maximum **portability**, to print (display) a character's encoded value, 
use printf utility with a backslash (\\) followed by 1, 2 or 3 octal digits 
because every POSIX-compliant printf can handle **octal** values. For example, 
to print the capital letter A (ASCII decimal 65, hex 0x41, octal 101):

```
% man ascii

% printf %x\\n 65
41
 
% printf %o\\n 65
101
```

```
% printf '\101'
A% 
```

Reference:  
The printf utility - The Open Group Base Specifications Issue 7, 2018 edition:   
<https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html>

----

### Useful Tools

iconv(1)   
uconv(1)   
od(1)  
hexdump(1)   
xxd(1)  
fc-list(1)   
fc-match(1)   
fc-query(1)   
xfd(1)   
pango-view(1)  
xsel(1)    
xkeycaps(1)   
luit(1)   

Perl  Unicode::Normalize --> <http://www.inference.org.uk/dasher/download/scripts/unicodesteps>

uni.pl Perl script - List Unicode symbols matching PATTERN   
<https://leahneukirchen.org/dotfiles/bin/uni>

gucharmap - a Unicode/ISO10646 character map and font viewer.   
It uses GTK+ 2, and supports anti-aliased, scalable fonts.  
WWW: <https://wiki.gnome.org/Gucharmap>   
<https://wiki.gnome.org/Apps/Gucharmap>

```
% gucharmap
% gucharmap U+00E7
```

----

From   
[Do modern terminals generally render all utf-8 characters correctly?](https://stackoverflow.com/questions/32928589/do-modern-terminals-generally-render-all-utf-8-characters-correctly)

> No, you should not assume that. Even in a modern system, the set of 
> fonts installed, the font used by the terminal application, and 
> environment variables such as LANG, LC_*, etc. may influence whether 
> certain characters can be displayed correctly on the terminal or not.
>   
> You might be able to make reasonable guesses based on the value of the 
> TERM, LANG, and LC_* environment variables as to what is supported, 
> but it's still going to be a guess. I'd suggest either not relying on it 
> at all or providing some means of enabling/disabling the use (via an 
> environment variable and/or via commandline flags to the application).

----

##### The Unicode Consortium. UnicodeData File - Unicode.org UnicodeData.txt

The UnicodeData.txt file contains most of the Unicode Character Database (UCD).
It's maintained as a simple semicolon-delimited ASCII text file. 
Each record in the database (that is, the information about each character) 
is separated from the next by a newline (Line Feed on Unix) -> (ASCII LF, 
hex 0x0A), and each field in a record (that is, each property of a single 
character) is separated from the next by a semicolon.

You can obtain the UnicodeData.txt from unicode.org (Retrieved on Nov 12, 2021):

*Note:*     
UnicodeData.txt is also available via http(s) at:    
<https://unicode.org/Public/UNIDATA/UnicodeData.txt>

```
% ftp -a ftp://ftp.unicode.org/Public/
```

```
ftp> dir
229 Entering Extended Passive Mode (|||28013|)
150 Opening ASCII mode data connection for file list
dr-xr-xr-x   5 ftp      ftp          4096 Jun 19  2017 10.0.0
drwxr-xr-x   5 ftp      ftp          4096 Apr 13  2020 11.0.0
---- snip ----
drwxr-xr-x   5 ftp      ftp          4096 Apr 13  2020 13.0.0
drwxr-xr-x   5 ftp      ftp          4096 Sep 14 00:08 14.0.0
---- snip ----  
-r--r--r--   1 ftp      ftp           344 Feb 21  2014 ReadMe.txt
---- snip ----
drwxr-xr-x  23 ftp      ftp          4096 Sep 14 18:16 UCA
drwxr-xr-x   2 ftp      ftp          4096 Sep 14 16:12 UCD
lrwxrwxrwx   1 ftp      ftp            10 Sep 14 16:02 UNIDATA -> /UNIDATA/14.0.0/ucd
---- snip ----
226 Transfer complete
ftp> 

ftp> page ReadMe.txt
This public directory contains data files for various versions
of the Unicode Standard, as well as data tables for specific
technical standards, mapping tables, and sample code.

For further information about data files please see:

Unicode Character Database
        http://www.unicode.org/ucd/

Terms of Use
        http://www.unicode.org/copyright.html

ftp> dir UCD
229 Entering Extended Passive Mode (|||40366|)
150 Opening ASCII mode data connection for file list
lrwxrwxrwx   1 ftp      ftp            10 Sep 14 16:12 latest -> /14.0.0
226 Transfer complete
 
ftp> dir 14.0.0
229 Entering Extended Passive Mode (|||16769|)
150 Opening ASCII mode data connection for file list
drwxr-xr-x   3 ftp      ftp          4096 Sep 27 13:11 charts
-rw-r--r--   1 ftp      ftp           635 May 25 19:05 README.html
-rw-r--r--   1 ftp      ftp          1060 Sep 10 16:29 ReadMe.txt
drwxr-xr-x   5 ftp      ftp          4096 Sep 14 16:03 ucd
drwxr-xr-x   2 ftp      ftp          4096 May 15  2021 ucdxml
226 Transfer complete

ftp> page 14.0.0/ReadMe.txt
# Unicode Character Database
# Date: 2021-09-10, 17:20:00 GMT [KW]
# © 2021 Unicode®, Inc.
# Unicode and the Unicode Logo are registered trademarks of Unicode, Inc. 
#   in the U.S. and other countries.
# For terms of use, see https://www.unicode.org/terms_of_use.html
#
# For documentation, see the following:
# ucd/NamesList.html
# UAX #38, "Unicode Han Database (Unihan)"
# UAX #42, "Unicode Character Database in XML"
# UAX #44, "Unicode Character Database"
# UTS #51, "Unicode Emoji"
#
# The UAXes and UTS #51 can be accessed at 
#   https://www.unicode.org/versions/Unicode14.0.0/

This directory contains the final data files
for Version 14.0.0 of the Unicode Standard.

The "ucd" subdirectory contains the Unicode
Character Database data files.

The "charts" subdirectory contains an archival set of
pdf code charts corresponding exactly to Version 14.0.0.

The "ucdxml" subdirectory contains the XML version of
the Unicode Character Database.

Zipped versions of UCD data files for Version 14.0.0 are
posted in:

https://www.unicode.org/Public/zipped/14.0.0/
 
ftp> cd 14.0.0
250 CWD command successful

ftp> dir
229 Entering Extended Passive Mode (|||59590|)

150 Opening ASCII mode data connection for file list
drwxr-xr-x   3 ftp      ftp          4096 Sep 27 13:11 charts
-rw-r--r--   1 ftp      ftp           635 May 25 19:05 README.html
-rw-r--r--   1 ftp      ftp          1060 Sep 10 16:29 ReadMe.txt
drwxr-xr-x   5 ftp      ftp          4096 Sep 14 16:03 ucd
drwxr-xr-x   2 ftp      ftp          4096 May 15  2021 ucdxml
226 Transfer complete

ftp> cd ucd
250 CWD command successful

ftp> dir
229 Entering Extended Passive Mode (|||39925|)

150 Opening ASCII mode data connection for file list
-rw-r--r--   1 ftp      ftp         40528 May 21 16:47 ArabicShaping.txt
drwxr-xr-x   2 ftp      ftp          4096 Sep  8 22:58 auxiliary
---- snip ----
-rw-r--r--   1 ftp      ftp       1897793 Jul  6 17:31 UnicodeData.txt
---- snip ---- 
226 Transfer complete

ftp> pwd
Remote directory: /Public/14.0.0/ucd

ftp> get UnicodeData.txt
---- snip ----

ftp> quit
221 Goodbye.
```

**Note:**
The fields for the unicode.org file **UnicodeData.txt** are documented here 
(Retrieved on Nov 12, 2021):
<https://www.unicode.org/reports/tr44/tr44-28.html#UnicodeData.txt>

The record for the letter A with the fields labeled:

```
% grep ^0041 UnicodeData.txt
0041;LATIN CAPITAL LETTER A;Lu;0;L;;;;;N;;;;0061;
```

```
                              +---------- General category
                              | +-------- Combining class
 Code point value             | | +------ Bidirectional category
  |                           | | |+----- Decomposition
  |    Name                   | | ||+---- Decimal digit value
  |     |                     | | |||
  v     v                     v v vvv 
 0041;LATIN CAPITAL LETTER A;Lu;0;L;;;;;N;;;;0061;
                                     ^^ ^^^^  ^  ^ 
                                     || ||||  |  |
                      Digit value ---+| ||||  |  |
                    Numeric value ----+ ||||  |  |
                         Mirrored ------+|||  |  |
                 Unicode 1.0 name -------+||  |  |
              10646 comment field --------+|  |  |
                Uppercase mapping ---------+  |  |
                Lowercase mapping ------------+  |
                Titlecase mapping ---------------+
```

The Unicode code point value U+0041 has the name LATIN CAPITAL LETTER A. 
It has a general category of "uppercase letter" (abbreviated "Lu"); 
it's not a combining mark (its combining class is 0); it's a left-to-right 
character (abbreviated "L"); it's not a composite character 
(no decomposition); it's not a numeral or digit (the three digit-value 
fields are all empty); it doesn't mirror (abbreviated "N"); its name in 
Unicode 1.0 was the same as its current name (empty field); it maps to 
itself when being converted to uppercase or titlecase (empty fields); 
and it maps to U+0061 (LATIN SMALL LETTER A) when being converted to lowercase.

----

### Fontconfig / Xft 

Xft is the X Font library.
It uses [Fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/)
to select fonts and the X protocol for rendering them. 

Fontconfig is a library for configuring and customizing font access.

**Note:**
In *X11*, you can use *multiple font systems*. 

In practice, there are two font systems:
- The **X11 core** font system (part of the core protocol)
  - Toolkits that use the core X font protocol include Xt, Xaw, Xaw3d, 
    Motif clones, Tk and GTK+ 1 [²]

- The **Xft** font system (more recent than the core font system)
  - Toolkits that use Xft are Qt and GTK+ 2

Over time, Fontconfig/Xft is supposed to replace the core X font subsystem. 


[²] The GTK team releases new versions on a regular basis.
It went through a sequence of revisions, from GTK 1 to GTK+2 and then 
to GTK+ 3 and GTK 4.

As of November 2021, GTK 4 and GTK 3 are maintained, while GTK 2 is end-of-life.  
GTK+ 3 was released in 2011 and was a major departure from GTK+ 2, which was
a major departure from GTK+ 1.

The "plus" (+) was removed the GTK project name in 2019:

Project rename to "GTK"
<https://mail.gnome.org/archives/gtk-devel-list/2019-February/msg00000.html>

> tl;dr: GTK is GTK, not GTK+. The documentation has been updated, and the 
> pkg-config file for the future 4.0 major release is now called "gtk4" 


As this section is about Xft and Fontconfig, it doesn't include 
the use of X Window (X11/Xorg) font utilities like 
```xlsfonts(1)``` or ```xfontsel(1)```.

----

**Note:**
To list how many fonts Fontconfig is aware of you can use  
```fc-list``` or ```fc-match```.

```
% fc-list | wc -l
    1997
```

```
% fc-match --all | wc -l
    1997
```

**Note:**
To show the ruleset files information on the system, use ```fc-conflist(1)```:
```
% fc-conflist
```


Unicode code point for the Skull and Crossbones character is U+2620.

```
% printf '%x' \'☠
2620%
```

**TIP**

To find out the name of the Unicode code point, use ```uconv(1)``` utility:

```
% printf ☠ | uconv -f utf-8 -x any-name
\N{SKULL AND CROSSBONES}% 
```

List all fonts on the system that support the Skull and Crossbones character.

```
% printf '%x' \'☠ | xargs -Ireplstr fc-list ":charset=replstr" | wc -l
      66
```

Select a font that you would like to preview.

```
% printf '%x' \'☠ | xargs -Ireplstr fc-list ":charset=replstr"
---- snip ----
/usr/local/share/fonts/Monoid/Monoid-Regular.ttf: Monoid:style=Regular
---- snip ----
```


Another way to find out a font's location:

```
% printf '%x' \'☠ \
? | xargs -Ireplstr fc-list -f "%{file}\n" ":charset=replstr" \
? | wc -l
      66
```

If you'd like to list font names:

```
% printf '%x' \'☠ \
 | xargs -Ireplstr fc-list -f "%{fullname}\n" ":charset=replstr" \
 | wc -l
      66
```

```
% printf '%x' \'☠ \
 | xargs -Ireplstr fc-list -f "%{fullname}\n" ":charset=replstr"
---- snip ----
Monoid
---- snip ----
```


To make sure that the font name is actually the one you want, use
the ```fc-query``` utility to confirm the font's name and other
details; style (Regular, Bold, Italic, ...), PostScript name, 
weight, width, file location, foundry, if the font is scalable or not,
character set, languagues supported, ...

**Note:**
For 'Regular' style, the word 'Regular' is not added to the font name.
For example, for Monoid font family - Regular style, the font is 
named 'Monoid' (not 'Monoid Regular').

```
% fc-query /usr/local/share/fonts/Monoid/Monoid-Regular.ttf | wc -l
      40

% fc-query /usr/local/share/fonts/Monoid/Monoid-Regular.ttf | grep -w -i family
        family: "Monoid"(s)

% fc-query /usr/local/share/fonts/Monoid/Monoid-Regular.ttf | grep -w -i style
        style: "Regular"(s)

% fc-query /usr/local/share/fonts/Monoid/Monoid-Regular.ttf | grep -i name
        postscriptname: "Monoid-Regular"(s)
```

```
% fc-match --all | grep -i Monoid | wc -l
      24

% fc-match --all | grep -i Monoid | grep -i Regular | wc -l
       6
 
% fc-match --all | grep -i Monoid | grep -i Regular
Monoid-Regular-Tight.ttf: "Monoid Tight" "Regular"
Monoid-Regular-HalfTight.ttf: "Monoid HalfTight" "Regular"
Monoid-Regular-HalfLoose.ttf: "Monoid HalfLoose" "Regular"
Monoid-Regular.ttf: "Monoid" "Regular"
Monoid-Regular-Loose.ttf: "Monoid Loose" "Regular"
monoid-regular.ttf: "Monoid" "Regular"
```


```
% fc-match 'Monoid-Regular'
monoid-regular.ttf: "Monoid" "Regular"
```

To find more details about the selected font (in this example:
Monoid, style: Regular), use ```fc-list``` utility and its ```-v``` 
option for verbose output.

```
% fc-list -v 'Monoid:style=Regular' | wc -l
      84
 
% fc-list -v 'Monoid:style=Regular' 
---- snip ----
```

For example, to check if the selected font supports Serbian character set:

```
% fc-list -v 'Monoid:style=Regular' | grep -w sr | wc -l
       2

% fc-list -v 'Monoid:style=Regular' | grep -w sr
        lang: aa|af|av|ay|az-az|be|bg|bi|br|bs|ca|ce|ch|co|cs|da|de|el|en
	|eo|es|et|eu|fi|fj|fo|fr|fur|fy|gd|gl|gv|haw|ho|hr|hu|ia|id|ie|ik
	|io|is|it|ki|kl|kum|la|lb|lez|lt|lv|mg|mh|mk|mo|mt|nb|nds|nl|nn|no
	|nr|nso|ny|oc|om|os|pl|pt|rm|ro|ru|se|sel|sk|sl|sm|sma|smj|smn|so
	|sq|sr|ss|st|sv|sw|tk|tl|tn|to|tr|ts|uk|uz|vo|vot|wa|wen|wo|xh|yap
	|zu|an|crh|csb|fil|hsb|ht|jv|kj|ku-tr|kwm|lg|li|mn-mn|ms|na|ng|nv
	|pap-an|pap-aw|rn|rw|sc|sg|sn|su|ty|za(s)
        lang: aa|af|av|ay|az-az|be|bg|bi|br|bs|ca|ce|ch|co|cs|da|de|el|en
	|eo|es|et|eu|fi|fj|fo|fr|fur|fy|gd|gl|gv|haw|ho|hr|hu|ia|id|ie|ik
	|io|is|it|ki|kl|kum|la|lb|lez|lt|lv|mg|mh|mk|mo|mt|nb|nds|nl|nn|no
	|nr|nso|ny|oc|om|os|pl|pt|rm|ro|ru|se|sel|sk|sl|sm|sma|smj|smn|so
	|sq|sr|ss|st|sv|sw|tk|tl|tn|to|tr|ts|uk|uz|vo|vot|wa|wen|wo|xh|yap
	|zu|an|crh|csb|fil|hsb|ht|jv|kj|ku-tr|kwm|lg|li|mn-mn|ms|na|ng|nv
	|pap-an|pap-aw|rn|rw|sc|sg|sn|su|ty|za(s)
```


You can narrow it down to, for example, charset:

```
% fc-list -v 'Monoid:style=Regular' charset 
Pattern has 1 elts (size 16)
        charset: 
0000: 00000000 ffffffff ffffffff 7fffffff 00000000 ffffffff ffffffff ffffffff
0001: ffffffff ffffffff ffffffff ffffffff 00008200 00000010 00000000 00000c00
0002: 0fffffff 00800000 1a000000 00000000 00000000 18000000 00000000 00000000
0003: 00269ddf 000003c0 00000000 00000000 ffffd770 fffffffb 10007fff 00000000
0004: ffffffff ffffffff ffffffff 003c0003 00030000 0000c000 00000000 00000300
0020: 773f083f 26000047 00000000 00300000 00000000 06001000 00000000 00000000
0021: 00000000 00000000 00000000 00000000 003f0000 00000000 00000000 00000000
0022: 02060140 00000800 00000100 00000033 00000000 00000000 00000000 00000000
0025: 00000000 00000000 00000000 00000000 00000100 00000000 00000000 00000000
0026: 00000000 00000001 00000000 0000e000 00000000 00000000 00000000 00000000
0030: 00000000 00000000 00000000 00000000 00000000 00000000 00000010 00000000
00e0: 00000000 00000000 00000000 00000000 00000000 000f0007 00000000 00000000
(s)
```

**TIP**

To see the text (or a single character) in the font you selected
you can use ```pango-view(1)``` Pango text viewer
and its ```-t``` ("text to display") option:

```
% env DISPLAY=:0 pango-view --font="Monoid" -t ☠
```

Alternatively, with FC_DEBUG environment variable, pango-view(1) creates 
a lot of output (in this example, around 7000 lines). 

```
% env DISPLAY=:0 FC_DEBUG=4 pango-view --font="Monoid" -t ☠
```

Reference:   
Beyond Linux® From Scratch (System V Edition) - Version r11.0-241  
Chapter 24. X Window System Environment  
[Tuning Fontconfig](https://www.linuxfromscratch.org/blfs/view/svn/x/tuning-fontconfig.html)   


> ```env FC_DEBUG=4 pango-view --font=monospace -t xyz | grep family``` 
> 
> This requires Pango and ImageMagick - it will invoke display(1) to show 
> the text in a tiny window, and after closing it, the last line of the 
> output will show which font was chosen.  This is particularly useful 
> for **CJK** (China, Japan, Korea) languages, and you can also pass 
> a language, e.g. 
> ```PANGO_LANGUAGE=en;ja``` (English, then assume Japanese) or just
> zh-cn (or other variants - 'zh' on its own is not valid). 


Finally, to see all the characters in an X font, use ```xfd(1)``` utility.
For example, to see all the characters in Monoid font:

```
% xfd -fa "Monoid"
```

By default, the xfd(1) displays the selected font in **Regular** style and 
with pointsize **12**.  In the case of Monoid, xfd(1) would by default display
**Monoid-12:style=Regular**.


To start xterm with the selected font.

```
% xterm -fa Monoid
```

To start xterm with the selected font and to specify the pointsize of the font.

```
% xterm -fa Monoid -fs 14
```


**Note:**

Use the ```-fa <fontname>``` option to specify a Xft font to be displayed. 

To specifiy the core X server side font to be displayed, use the
```-fn <fontname>``` option.

For font names without white spaces, you don't have to use quotes around
the font name so in the case of this example the following also works:
```xfd -fa Monoid```.


For font names with more than one word, you need to enclose it in quotes. 

```
% printf %x \'`printf '\314\202'` \
 | xargs -Ireplstr fc-list ":charset=replstr" \
 | grep -i gentium

/usr/local/share/fonts/GentiumBasic/GenBkBasI.ttf: Gentium Book Basic:style=Italic
/usr/local/share/fonts/GentiumBasic/GenBasB.ttf: Gentium Basic:style=Bold
/usr/local/share/fonts/GentiumBasic/GenBkBasB.ttf: Gentium Book Basic:style=Bold
/usr/local/share/fonts/GentiumBasic/GenBkBasR.ttf: Gentium Book Basic:style=Regular
/usr/local/share/fonts/GentiumBasic/GenBasI.ttf: Gentium Basic:style=Italic
/usr/local/share/fonts/GentiumBasic/GenBasR.ttf: Gentium Basic:style=Regular
/usr/local/share/fonts/GentiumBasic/GenBkBasBI.ttf: Gentium Book Basic:style=Bold Italic
/usr/local/share/fonts/GentiumBasic/GenBasBI.ttf: Gentium Basic:style=Bold Italic
```

```
% xfd -fa "Gentium Book Basic:style=Italic"
```

As it displays the font in pointsize 12 by default, xfd(1) displays 
*Gentium Book Basic-12:style=Italic*.

To display the selected font in a different size, add the size at the end 
of the font name:

```
% xfd -fa "Gentium Book Basic-20:style=Bold"
```

To start xterm  with this font, style and pointsize:

```
% xterm -fa "Gentium Book Basic-20:style=Bold"
```


#### How to Find All Available Fontconfig Utilities

On FreeBSD, the Fontconfig utilities are in ```/usr/local/bin/``` directory:

```
% command -v fc-list
/usr/local/bin/fc-list
 
% command -V fc-list
fc-list is /usr/local/bin/fc-list
 
% type fc-list
fc-list is /usr/local/bin/fc-list

% which fc-list
/usr/local/bin/fc-list
 
% whereis fc-list
fc-list: /usr/local/bin/fc-list
 
% where fc-list
/usr/local/bin/fc-list
```

The following Fontconfig utilites are available on this system:

```
% ls -lh /usr/local/bin/fc*
-rwxr-xr-x  1 root  wheel    14K Jul  7 18:12 /usr/local/bin/fc-cache
-rwxr-xr-x  1 root  wheel    12K Jul  7 18:12 /usr/local/bin/fc-cat
-rwxr-xr-x  1 root  wheel   7.2K Jul  7 18:12 /usr/local/bin/fc-conflist
-rwxr-xr-x  1 root  wheel   9.3K Jul  7 18:12 /usr/local/bin/fc-list
-rwxr-xr-x  1 root  wheel    10K Jul  7 18:12 /usr/local/bin/fc-match
-rwxr-xr-x  1 root  wheel   8.8K Jul  7 18:12 /usr/local/bin/fc-pattern
-rwxr-xr-x  1 root  wheel   8.4K Jul  7 18:12 /usr/local/bin/fc-query
-rwxr-xr-x  1 root  wheel   9.3K Jul  7 18:12 /usr/local/bin/fc-scan
-rwxr-xr-x  1 root  wheel   9.7K Jul  7 18:12 /usr/local/bin/fc-validate
```


### UTFs (Unicode Transformation Formats)

From
<https://www.ibm.com/docs/en/db2-for-zos/12?topic=unicode-utfs>

> Each Unicode code point can be expressed in several different formats.  
> These formats are called Unicode Transformation Formats (UTFs).  
> For example, the letter M is the Unicode code point U+004D.  
> In UTF-8, this code point is represented as 0x4D. 
> In UTF-16, this code point can be represented as 0x004D.

```
% printf M | hexdump -C
00000000  4d                                                |M|
00000001
```

```
% printf M | od -t x1
0000000    4d                                                            
0000001
```

```
% printf M | od -t x2
0000000      004d                                                        
0000001
```


**Note:**
```0x004D``` is the UTF-16 big endian representation. 
The UTF-16 little endian representation is ```0x4D00```. 
For more information about endianness, see Endianness
<https://www.ibm.com/docs/en/db2-for-zos/12?topic=data-endianness>

```
% printf M | iconv -f ascii -t utf-16le | od -x
0000000      004d
0000002
 
% printf M | iconv -f ascii -t utf-16be | od -x
0000000      4d00
0000002
```

Also see
How iconv and od handle endianness? 
<https://unix.stackexchange.com/questions/599582/how-iconv-and-od-handle-endianness>

Also see
How do I find out the Default Encoding used by a computer?
<https://social.msdn.microsoft.com/Forums/vstudio/en-US/a84ae865-cb2e-49cb-bdb2-1e4d55456b02/how-do-i-find-out-the-default-encoding-used-by-a-computer>
> UTF-16 requires a **byte order mark (BOM)** to distinguish whether the text was 
> created on a Little Endian or a Big Endian machine.  
> **Intel** processors are **Little Endian** machines. 
> So Windows is a Little Endian system.
>
> With UTF-8 encoding, the issue of endianess doesn't arise, because it 
> will have been written one byte (8 bits) at a time. In particular, 
> ISO 646's 7 bit codes (like ASCII) are stored unchanged directly into 
> the UTF-8 file.  Thus a UTF-8 file containing only invariant ISO 646 
> bytes is indistinguishable from an "ASCII" file. However, to store 
> remaining 1,112,064 Unicode Code Points UTF-8 introduces a marker byte, 
> and then a further one, two, three or four bytes to encode the code point.


### Looking at File Content
To display the content of a file in some other format than its character 
(ASCII) format, you can use a number of different commands. 
Some of them are od (octal dump), hexdump, xxd and iconv.

#### od(1) and cat(1)
The ```od -bc``` displays a file in octal and character format. 
```
% printf M | od -bc 
0000000   115                                                            
           M                                                            
0000001
```

```
% printf M > testing

% file testing
testing: very short file (no magic)
 
% wc -l testing
       0 testing
 
% wc -c testing
       1 testing

% od -bc testing
0000000   115
           M
0000001
```

With the cat(1) utility:
```-b``` option: number the non-blank output lines, starting at 1;
```-e``` option: display non-printing characters, and display 
                 a dollar sign ('$') at the end of each line
```
% cat -b testing
     1  M% 

% cat -e testing
M% 
```

With the newline character, which ends the single line of text:
```
% printf "%s\n" M > testing

% file testing
testing: ASCII text
 
% wc -l testing
       1 testing
 
% wc -c testing
       2 testing

% od -bc testing
0000000   115 012
           M  \n
0000002
```

The \012 at the end is the newline character (012 in octal, 0x0A in hex, 10 in decimal).

With the cat(1) utility:
```-b``` option: number the non-blank output lines, starting at 1;
```-c``` option: display non-printing characters, and display 
                 a dollar sign ('$') at the end of each line
```
% cat -b testing 
     1  M
 
% cat -e testing
M$
```

For the next example, modify the test file to include two characters.

Now, when you view the same test file in hexadecimal (a.k.a. hex), you'll 
notice that od(1) swapped the characters in each two-letter set.
For example, instead of A=41, A is 4d and instead of M=4d, M is 41 so for 
"AM" two-letter set, instead of "414d", it shows as "4d41":
```
% printf A | od -bc
0000000   101                                                            
           A                                                            
0000001
 
% printf M | od -bc
0000000   115                                                            
           M                                                            
0000001

% printf AM > testing
 
% file testing
testing: ASCII text, with no line terminators

wc -l testing
       0 testing
 
% wc -c testing
       2 testing
 
% od -bc testing
0000000   101 115                                                        
           A   M                                                        
0000002

% cat -b testing
     1  AM% 
 
% cat -e testing
AM% 
```

```
% printf A | od -hc
0000000      0041
           A
0000001
 
% printf M | od -hc
0000000      004d
           M
0000001
```

```
% od -hc testing
0000000      4d41
           A   M
0000002
```

**Note:**
The ```od -h``` outputs hexadecimal shorts.  It's equivalent to ```-t x2``` 
(hexadecimal type with a byte count of 2):

Also note that ```-h``` and ```-x``` are interchangeable in od(1).

```
% od -x testing
0000000      4d41
0000002
```

```
% od -t x2 testing
0000000      4d41                                                        
0000002

% od -t x2 -c testing
0000000      4d41                                                        
           A   M                                                        
0000002
```

Adding ```-t x1``` to the od(1) command (x1 = byte count is 1) gets 
around the character swapping in two letter sets:

```
% od -t x1 testing
0000000    41  4d                                                        
0000002
```

It outputs one hexadecimal byte at a time.

It's equivalent to a hexadecimal type with a size specifier = char (C): 

```
% od -t xC testing
0000000    41  4d                                                        
0000002
```

From 
How iconv and od handle endianness?
<https://unix.stackexchange.com/questions/599582/how-iconv-and-od-handle-endianness> 
> The ```-t x1``` gives big endian because it splits words. 
> 
> The ```-x``` and ```-t x2``` give little-endian. 

The big-endian and little-endian refers to whether the data 
values are ordered with the most significant (big-endian) or least 
significant (little-endian) byte first.


#### hexdump(1)

**Note:**
In FreeBSD, ```hexdump``` and ```hd``` are the same binary: 
```
% command -v hexdump
/usr/bin/hexdump
 
% command -v hd
/usr/bin/hd
 
% ls -lh /usr/bin/hexdump 
-r-xr-xr-x  3 root  wheel    30K Jul 13 14:30 /usr/bin/hexdump

% ls -lh /usr/bin/hd
-r-xr-xr-x  3 root  wheel    30K Jul 13 14:30 /usr/bin/hd
 
% diff /usr/bin/hd /usr/bin/hexdump 
```

Use hexdump(1) to display the test file in hex, character and octal format.

```
% hexdump testing
0000000 4d41
0000002
 
% hexdump -c testing
0000000   A   M
0000002
 
% hexdump -b testing
0000000 101 115
0000002
```

To display it with big endianess, use ```-C``` option.
From the man page for hexdump(1):
```
-C      Canonical hex+ASCII display.  Display the input offset in
        hexadecimal, followed by sixteen space-separated, two column,
        hexadecimal bytes, followed by the same sixteen bytes in %_p
        format enclosed in ``|'' characters.

Calling the command hd implies this option.
```

```
% hexdump -C testing
00000000  41 4d                                             |AM|
00000002
```

```
% hd testing
00000000  41 4d                                             |AM|
00000002
```

An example with a bigger number of characters to make the output of 
the sixteen space-separated, two column hexadecimal bytes more noticable:

```
% printf 'AMAMAMAMAMAMAMAMAMAMAMAM' > testing
 
% cat testing
AMAMAMAMAMAMAMAMAMAMAMAM% 

% hexdump -C testing
00000000  41 4d 41 4d 41 4d 41 4d  41 4d 41 4d 41 4d 41 4d  |AMAMAMAMAMAMAMAM|
*
00000010
```

```
00000000  41 4d 41 4d 41 4d 41 4d  41 4d 41 4d 41 4d 41 4d  |AMAMAMAMAMAMAMAM|
              
          01 02 03 04 05 06 07 08  09 10 11 12 13 14 15 16 
          sixteen space separated bytes
```

#### xxd(1)

The xxd(1) command creates a hex dump or converts a hex dump to some other format. 
It displays a file in big-endian format by default.

```
% printf AM > testing
 
% xxd testing
00000000: 414d                                     AM
```

Output in postscript continuous hexdump style. 
Also known as plain hexdump style.

```
% xxd -p testing
414d
```

#### iconv(1)

The iconv(1) utility converts (translates) content from one character 
encoding to another. 

To see how many different encoding schemes are supported by your system,
use the ```--list``` option:

```
% iconv --list | wc -l
     216
```

The syntax of the iconv(1) is: 

```
iconv [-f from-encoding] [-t to-encoding] [inputfile]
```


```
% printf AM > testing
 
% cat testing
AM% 

% file testing
testing: ASCII text, with no line terminators

% iconv -f utf8 -t utf16 testing > testingutf16

% file testingutf16
testingutf16: Big-endian UTF-16 Unicode text, with no line terminators
```


The UTF-16 encoded file, testingutf16, is three times the size of the UTF-8 file. 
```
% ls -lh testing*
-rw-r--r--  1 dusko  dusko     2B Nov 10 23:19 testing
-rw-r--r--  1 dusko  dusko     6B Nov 10 23:19 testingutf16
```

In the UTF-16 encoded file, every other byte is "00". 
The data you are displaying is not making use of the extra byte.
Also, two bytes are added at the beginning of the file.
They are used to indicate the endianess of the UTF-16 format and are not 
treated as characters.

These two bytes are a BOM (Byte Order Mark). 

From
UTF-8, UTF-16, UTF-32 & BOM -- Byte Order Mark (BOM) - Unicode.org FAQ
<http://unicode.org/faq/utf_bom.html>

> For Encoding Form UTF-16, big-endian -- Bytes:  FE FF 
>  
> For Encoding Form UTF-16, little-endian -- Bytes:  FF FE 
>  
> For Encoding Form UTF-32, big-endian -- Bytes:  00 00 FE FF 
>  
> For Encoding Form UTF-32, little-endian -- Bytes:  FF FE 00 00 

```
% hexdump testingutf16
0000000 fffe 4100 4d00
0000006
 
% hexdump -C testingutf16
00000000  fe ff 00 41 00 4d                                 |...A.M|
00000006
```


Similarly, for a UTF-32 encoded file (big-endian), BOM bytes are: 00 00 FE FF. 
```
% printf AM > testing

% cat testing
AM% 

% cat -b testing
     1  AM% 

% cat -e testing
AM% 

% file testing
testing: ASCII text, with no line terminators

% iconv --list | grep -i UTF | wc -l
       8

% iconv --list | grep -i UTF | grep 32 | wc -l
       3

% iconv --list | grep -i UTF | grep 32
UTF-32-INTERNAL UCS-4-INTERNAL
UTF-32-SWAPPED UCS-4-SWAPPED
UTF-32 CSUCS4 ISO-10646-UCS-4 UCS-4 UCS-4BE UTF-32BE UTF32BE UCS-4LE 
       UTF-32LE UTF32LE

% iconv -t UTF-32 testing > testingutf32

% ls -lh testing*
-rw-r--r--  1 dusko  dusko     2B Nov 11 11:52 testing
-rw-r--r--  1 dusko  dusko     6B Nov 10 23:19 testingutf16
-rw-r--r--  1 dusko  dusko    12B Nov 11 11:54 testingutf32

% file testingutf32
testingutf32: Unicode text, UTF-32, big-endian

% od -bc testingutf32
0000000   000 000 376 377 000 000 000 101 000 000 000 115
          \0  \0 376 377  \0  \0  \0   A  \0  \0  \0   M 
0000014

% xxd testingutf32
00000000: 0000 feff 0000 0041 0000 004d            .......A...M

% hexdump testingutf32
0000000 0000 fffe 0000 4100 0000 4d00
000000c

% hexdump -C testingutf32
00000000  00 00 fe ff 00 00 00 41  00 00 00 4d              |.......A...M|
0000000c
```

From
UTF-8, UTF-16, UTF-32 & BOM -- Byte Order Mark (BOM) FAQ
<http://unicode.org/faq/utf_bom.html>
>
> Q: When a BOM is used, is it only in 16-bit Unicode text?
> 
> A: No, a BOM can be used as a signature no matter how the Unicode text 
> is transformed: UTF-16, UTF-8, or UTF-32. The exact bytes comprising 
> the BOM will be whatever the Unicode character U+FEFF is converted into 
> by that transformation format. In that form, the BOM serves to indicate 
> both that it is a Unicode file, and which of the formats it is in. 
> Examples:
```
+-------------+-----------------------+
| Bytes       | Encoding Form         |
+-------------+-----------------------+
| 00 00 FE FF | UTF-32, big-endian    |
| FF FE 00 00 | UTF-32, little-endian |
| FE FF       | UTF-16, big-endian    |
| FF FE       | UTF-16, little-endian |
| EF BB BF    | UTF-8                 | 
+-------------+-----------------------+
```

> Q: Can a UTF-8 data stream contain the BOM character (in UTF-8 form)? 
> If yes, then can I still assume the remaining UTF-8 bytes are in 
> big-endian order?
> 
> A: Yes, UTF-8 can contain a BOM. However, it makes no difference as to 
> the endianness of the byte stream. UTF-8 always has the same byte order.
> An initial BOM is *only* used as a signature - an indication that an 
> otherwise unmarked text file is in UTF-8. Note that some recipients of 
> UTF-8 encoded data do not expect a BOM. Where UTF-8 is used transparently
> in 8-bit environments, the use of a BOM will interfere with any protocol
> or file format that expects specific ASCII characters at the beginning, 
> such as the use of "#!" at the beginning of Unix shell scripts. 


### How to Find a Unicode Code Point of a Character? 
### Method 1: printf(1) oneliner

**Note:**
For finding a Unicode code point of a **composite Unicode character**, 
see the next section below 'Unicode Normalized Formats (NFC or NFKC)', 
a.k.a. 'Composite Unicode Characters', 
a.k.a. 'Unicode Equivalence'.

Use ```printf``` utility:

For example, for a 'check mark' ('checkmark') character:
```
% printf "%x\n" \'✓
2713
```

Use ```uconv(1)``` utility to display the name of 
the Unicode code points of the desired character:

```
% printf ✓ | uconv -f utf-8 -x any-name
\N{CHECK MARK}% 
```

```
% grep 2713 UnicodeData.txt
2713;CHECK MARK;So;0;ON;;;;;N;;;;;
```

So, the Unicode for the Check Mark (Checkmark) character is 2713. 

A Unicode Character 'CHECK MARK' (U+2713)
<https://www.fileformat.info/info/unicode/char/2713/fontsupport.htm>


### How to Find a Unicode Code Point of a Character?
### Method 2: printf(1) and xxd(1)/hexdump(1)/od(1)

Use ```uconv(1)``` utility to display the name of the Unicode code point 
of the desired character:

```
% printf ž | uconv -f utf-8 -x any-name
\N{LATIN SMALL LETTER Z WITH CARON}% 
```

```
% printf ž 
ž% 
 
% printf ž | xxd
00000000: c5be                                     ..

% printf ž | xxd -p
c5be
 
% printf ž | hexdump -C
00000000  c5 be                                             |..|
00000002

% printf ž | od -t x1
0000000    c5  be                                                        
0000002
```

This character (ž) in UTF-8 encoding: ```0xC5 0xBE```.

In octal:

```
% printf ž | od -bc
0000000   305 276
           ž  **
0000002
``` 

Another method of converting from hexadecimal to octal: with printf(1).

```
% printf "%o\n" 0xc5
305
 
% printf "%o\n" 0xbe
276
```

To confirm that the UTF-8 code is correct: convert in the opposite 
direction (with printf(1)); from the character's UTF-8 hexadecimal code to 
UTF-8 octal code, suitable for POSIX-portable printf use:

```
% printf '\305'
�% 

% printf '\305\276'
ž% 
 
% printf '\305\276' | xxd
00000000: c5be                                     ..
```


```
% printf ž > chrtoconv
 
% ls -lh chrtoconv
-rw-r--r--  1 dusko  dusko     2B Nov 12 16:16 chrtoconv
 
% file chrtoconv
chrtoconv: UTF-8 Unicode text, with no line terminators
 
% wc -l chrtoconv
       0 chrtoconv
 
% wc -c chrtoconv
       2 chrtoconv
 
% cat -t chrtoconv
ž% 
 
% cat -b chrtoconv
     1  ž% 
 
% cat -e chrtoconv
ž% 
 
% cat -v chrtoconv
ž% 
 
% xxd chrtoconv
00000000: c5be                                     ..
 
% iconv -l | wc -l
     216
 
% iconv -l | grep -i unicode | wc -l 
       2

% iconv -l | grep -i unicode 
UTF-16 UNICODE UTF16 CSUNICODE CSUNICODE11 ISO-10646-UCS-2 UCS-2 
  UCS-2BE UNICODE-1-1 UNICODEBIG UTF-16BE UTF16BE UCS-2LE UNICODELITTLE 
  UTF-16LE UTF16LE
UTF-7 CSUNICODE11UTF7 UNICODE-1-1-UTF-7 UTF7
 
% file chrtoconv
chrtoconv: UTF-8 Unicode text, with no line terminators
 
% iconv -l | grep -i utf8
UTF-8 UTF8
 
% iconv -l | grep -i 'utf-8'
UTF-8 UTF8
 
% file chrtoconv
chrtoconv: UTF-8 Unicode text, with no line terminators
 
% iconv -f UTF-8 -t UNICODE chrtoconv > chrunicode
 
% ls -lh chrunicode
-rw-r--r--  1 dusko  dusko     4B Nov 12 16:34 chrunicode
 
% file chrunicode
chrunicode: Big-endian UTF-16 Unicode text, with no line terminators
 
% wc -l chrunicode
       0 chrunicode
 
% wc -c chrunicode
       4 chrunicode
 
% cat -t chrunicode
M-~M-^?^A~% 
 
% cat -b chrunicode
     1  ��~% 
 
% cat -e chrunicode
M-~M-^?^A~% 
 
% cat -v chrunicode
M-~M-^?^A~% 
``` 

``` 
% xxd chrunicode
00000000: feff 017e                                ...~
 
% xxd -i chrunicode
unsigned char chrunicode[] = {
  0xfe, 0xff, 0x01, 0x7e
};
unsigned int chrunicode_len = 4;
 
% xxd -p chrunicode
feff017e

% hexdump -C chrunicode
00000000  fe ff 01 7e                                       |...~|
00000004
``` 

This character's (ž) Unicode code point: ```U+017E```.

``` 
% grep -i ^017e UnicodeData.txt 
017E;LATIN SMALL LETTER Z WITH CARON;Ll;0;L;007A 030C;;;;N;
  LATIN SMALL LETTER Z HACEK;;017D;;017D
 
% ./uni.pl 017e
ž       017E    LATIN SMALL LETTER Z WITH CARON
```

```
% grep ^017E UnicodeData.txt 
017E;LATIN SMALL LETTER Z WITH CARON;Ll;0;L;007A 030C;;;;N;
  LATIN SMALL LETTER Z HACEK;;017D;;017D
```

When you know the value of a Unicode code point (U+017E in this example),
you can use ```uconv(1)``` utility to print the name of a Unicode code point: 

```
% printf '\\u017e' | uconv -x 'hex-any; any-name'; printf \\n
\N{LATIN SMALL LETTER Z WITH CARON}
```

### How to Find a Unicode Code Point of a Character? 
### Method 3: fc-list(1) and xfd(1)

To list all the fonts on the system that include the character 
you are looking up, use ```fc-list``` as explained in tl;dr at 
the very top of the page (and in more detail under 
["Fontconfig / Xft" heading](#fontconfig--xft) on this page).

After that, launch ```xfd(1)``` with one of the fonts from the list.

In xfd(1), browse glyphs (characters), which are displayed in a grid 
contatining one glyph per cell.  Click on the desired character and its
metrics (index, width, bearings, ascent and descent ) will be displayed. 
The first item is the character's code.  
In this example (selected character: ž), 
xfd(1) displayed the following code: ```0x00017e```. 

```
% xfd -fa Monoid
```

```
% ./uni.pl 017e
ž       017E    LATIN SMALL LETTER Z WITH CARON
```

```
% printf '\\u017e' | uconv -x 'hex-any; any-name'; printf \\n
\N{LATIN SMALL LETTER Z WITH CARON}
```

### How to Find a Unicode Code Point - Normalized Formats (NFC or NFKC)

From  
ICU Documenation - Normalization (Retrieved on Nov 13, 2021)   
<https://unicode-org.github.io/icu/userguide/transforms/normalization/>

> Normalization is used to convert text to a unique, equivalent form. 
> Software can normalize equivalent strings to one particular sequence, 
> such as normalizing composite character sequences into pre-composed 
> characters.
> 
> Normalization allows for easier sorting and searching of text. The ICU 
> normalization APIs support the standard normalization forms which are 
> described in great detail in 
> [Unicode Technical Report #15 (Unicode Normalization Forms)](http://www.unicode.org/reports/tr15) and the Normalization, Sorting and Searching 
> sections of chapter 5 of the [Unicode Standard](http://www.unicode.org/versions/latest/). ICU also supports related, additional operations. Some of them are described in [Unicode Technical Note #5 (Canonical Equivalence in Applications)](http://www.unicode.org/notes/tn5/).

**TIP**    

Normalization is a complex topic.  
When in doubt, use the extremelly helpful ICU Normalization Browser:   

**ICU Demonstration - Normalization Browser**   
<https://icu4c-demos.unicode.org/icu-bin/nbrowser>

(ICU project maintains uconv(1) tool.)


Also useful page is Normalization Charts - Unicode.org   
<http://www.unicode.org/charts/normalization/>

----

From   
How to find UTF-8 reference of a composite unicode character   
<https://stackoverflow.com/questions/30733035/how-to-find-utf-8-reference-of-a-composite-unicode-character>
> UTF-8 is a **byte encoding** for a sequence of *individual*  
> **Unicode code points**.
> There is no single Unicode code point defined for **n̂**, not even when 
> a Unicode string is normalized in NFC or NFKC formats. 
> As you have noted, n̂ consists of code point 
> ```U+006E LATIN SMALL LETTER N``` followed by code point 
> ```U+0302 COMBINING CIRCUMFLEX ACCENT```.
> In UTF-8, ```U+006E``` is encoded as byte ```0x6E```, and ```U+0302``` 
> is encoded as bytes ```0xCC 0x82```.

First, find out the Unicode code point name of the character:

```
% printf n̂ | uconv -f utf-8 -x any-name
\N{LATIN SMALL LETTER N}\N{COMBINING CIRCUMFLEX ACCENT}% 
```

```
% printf n̂ | xxd
00000000: 6ecc 82                                  n..

% printf n̂ | hexdump 
0000000 cc6e 0082
0000003

% printf n̂ | hexdump -C
00000000  6e cc 82                                          |n..|
00000003
```

```
% printf n̂ | od -bc
0000000   156 314 202
           n    ̂  **
0000003

% printf '\156'
n% 
 
% printf '\156\314'
n�% 
 
% printf '\156\314\202'
n̂% 

% printf '\156\314\202 '
n̂ %
```

Convert octal 156 to hex (hexadecimal):
```
% printf %x\\n 0156
6e
```

```
% ./uni.pl 006e
n       006E    LATIN SMALL LETTER N
𓉜       1325C   EGYPTIAN HIEROGLYPH O006E
```

```
% grep ^006E UnicodeData.txt
006E;LATIN SMALL LETTER N;Ll;0;L;;;;;N;;;004E;;004E
```

So, the first Unicode code point is U+006E, which is a latin small letter n.

To get a representation of the next Unicode code point,
you have to add the newline character at the end (012 in octal):
```
% printf '\314'
�% 

% printf '\314\202'
 
% printf '\314\202\012'
^
```

```
% printf '\314\202\012' | od -bc
0000000   314 202 012
            ̂  **  \n
0000003
 
% printf '\314\202\012' | hexdump -C
00000000  cc 82 0a                                          |...|
00000003
```


To exclude the newline character (012 in octal, 0x0A in hex), 
use the ***-n*** option to interpret only two bytes of input:
```
% printf '\314\202\012' | hexdump -C -n2
00000000  cc 82                                             |..|
00000002
```

**How did you know that ```0xCC 0x82``` (in UTF-8) is ```U+0302``` in Unicode?**

a.k.a.

**How to Translate (Convert) a UTF-8 Encoding to a Unicode Code Point?**

It's a little bit convoluted.
(**NOTE:** Not failsafe)

I used the following:
- First saved the character I'm interested in to a file
- Used uni.pl Perl utility to identify the character's Unicode code point

```
% printf '\314\202\012' > chartocheck

% file chartocheck
chartocheck: UTF-8 Unicode text

% wc -l chartocheck
       1 chartocheck

% wc -c chartocheck
       3 chartocheck

% cat -b chartocheck
     1̂
% cat -e chartocheck
$

% cat -v chartocheck
 ̂  
```

```
% xxd chartocheck
00000000: cc82 0a                                  ...
 
% od -bc chartocheck
0000000   314 202 012
            ̂  **  \n
0000003
 
% hexdump -C chartocheck
00000000  cc 82 0a                                          |...|
00000003
```

```
% ./uni.pl `cat chartocheck`
 ̂       0302    COMBINING CIRCUMFLEX ACCENT
```

```
% grep ^0302 UnicodeData.txt 
0302;COMBINING CIRCUMFLEX ACCENT;Mn;230;NSM;;;;;N;NON-SPACING CIRCUMFLEX;;;;
```


**Recap**

*In Unicode*

So, the character (which is a composite Unicode character) **n̂**
in Unicode is represented with **two** Unicode code points:
code point ```U+006E LATIN SMALL LETTER N``` 
followed by code point 
```U+0302 COMBINING CIRCUMFLEX ACCENT```.

*In UTF-8*

The same character in UTF-8 is encoded as byte ```0x6E```
and Unicode ```U+0302``` code point (which is in UTF-8 encoded as two bytes)
```0xCC 0x82```.


### How to Find UTF-8 Encoding of a Character?
### (applies to Composite Unicode Characters too)

An example with a **composite Unicode character** ```n̂``` 
from the earlier section above 'Unicode Normalized Formats (NFC or NFKC). 

You can use a one-liner with xxd(1):

```
% printf n̂ | xxd -p
6ecc82
```

The character **n̂** encoded in UTF-8: ```0x6E 0xCC 0x82```.


Another utility you can use is ```hexdump(1)```.

For example, character "ỗ" - Name: Latin Small Letter O with Circumflex 
and Tilde:

```
% printf ỗ | hexdump -C
00000000  e1 bb 97                                          |...|
00000003
```

So, UTF-8 encoding for the character "ỗ" (Latin Small Letter O with 
Circumflex and Tilde) is:  
```0xE1 0xBB 0x97```


**Note:**

Character "ỗ" (Latin Small Letter O with Circumflex and Tilde) Unicode 
code point is 1ED7, usually written as (U+1ED7).
```
% printf "%x\n" \'ỗ
1ed7
```

```
% grep ^1ED7 UnicodeData.txt
1ED7;LATIN SMALL LETTER O WITH CIRCUMFLEX AND TILDE;Ll;0;L;00F4 0303;;;;N;;;1ED6;;1ED6
```

### How to Print a Character when Its Unicode Code Point is Known?
### Method 1: printf(1), xxd(1), iconv(1)

For example, the known Unicode code point value is ```U+00D6```. 


```
% printf "0 00D6" | xxd -r | iconv -f UNICODEBIG -t UTF-8
Ö% 
```

*Reference:*

Print unicode hex code which is part of basic latin as a symbol in Bash    
<https://stackoverflow.com/questions/12693970/print-unicode-hex-code-which-is-part-of-basic-latin-as-a-symbol-in-bash>


### How to Print a Character when Its Unicode Code Point is Known?
### Method 2: HTML, JavaScript, Web browser

Create an HTML file similar to the following:

```
% cat convert.html 
<script type="text/javascript">
  var message1 = "I \u2665 Unicode! \u263A \u00A9";
  var message2 = "The xʷməθkʷəy\u0313əm, Tsleil-Waututh and Skwxwú7mesh peoples"
  var message3 = "\u00D6";

  document.write(message1);
  // For output to the page, use "<br/>" instead of '\n'
  document.write("<br/>");
  document.write(message2);
  document.write("<br/>");
  document.write(message3);
</script>
```

Use your Web browser to open the file convert.html. 


### How to Print a Character when Its Unicode Code Point is Known?
### Method 3: Normalization Browser - International Components for Unicode (ICU)

Use the extremelly helpful ICU Normalization Browser:   

**Normalization Browser - International Components for Unicode (ICU)**  
<https://icu4c-demos.unicode.org/icu-bin/nbrowser>

Enter ```00D6``` and press 'Show Results'.


## Conversions - Summary with Examples 

### Print a Character Based on Its Unicode Code Point (a.k.a. Hex Code) 
```
% printf "0 00D6" | xxd -r | iconv -f UNICODEBIG -t UTF-8
Ö% 
```

```xxd(1)``` with the ```-r``` option converts hex text into bytes. 
It requires line numbers, which is why the leading 0 in the printf is. 
xxd(1) in this case outputs the two bytes indicated by c.

### Print the Unicode Name of a Character 

```
% printf Ö | uconv -f utf-8 -x any-name
\N{LATIN CAPITAL LETTER O WITH DIAERESIS}% 
```

Check/confirmation:

```
% grep -i 'latin capital letter o with diaeresis' UnicodeData.txt 
00D6;LATIN CAPITAL LETTER O WITH DIAERESIS;Lu;0;L;004F 0308;;;;N;
  LATIN CAPITAL LETTER O DIAERESIS;;;00F6;
022A;LATIN CAPITAL LETTER O WITH DIAERESIS AND MACRON;Lu;0;L;
  00D6 0304;;;;N;;;;022B;

% grep ^00D6 UnicodeData.txt
00D6;LATIN CAPITAL LETTER O WITH DIAERESIS;Lu;0;L;004F 0308;;;;N;
  LATIN CAPITAL LETTER O DIAERESIS;;;00F6;
```

### Find a UTF-8 Code of a Character

```
% printf Ö 
Ö% 

% printf Ö | xxd
00000000: c396                                     ..

% printf Ö | xxd -p
c396
```

UTF-8 code of this character: ```0XC3 0x96```.

### Display (Print) a Character Based on Its UTF-8 Code

For example, the UTF-8 code of the desired character is: ```0XC3 0x96```.

First, convert to **octal** as every POSIX-compliant printf can handle 
octal values.

```
% printf %o 0xc3
303%

% printf %o 0x96
226%
```

```
% printf '\303\226'
Ö%
```

### Translate/Convert betweeen a Character's UTF-8 Code to Unicode Code Point and Back
### (includes NFC and NFD Normalization)

**NFC** Normalization and **NFD** Normalization are **EQUIVALENT** (see below).

From  
[Unicode Normalization](https://www.win.tue.nl/~aeb/linux/uc/nfc_vs_nfd.html)

> Text encoding - NFC or NFD?
> 
> In any nontrivial project, it is a good idea to standardize the data 
> representation. Unfortunately, the Unicode Consortium provides us with 
> two standards, and we have to choose. Does one have advantages over the 
> other? This is the nfc-vs-nfd question.
> 
> **"There is no difference"**   
> . . .   
> **"Choose NFC if possible"**   
> . . .     
> **"NFD is far superior"**    
> . . .   
>  
> **Conversion**   
> The utility ```uconv``` will convert from/to NFC/NFD: 
> ```uconv -f utf8 -t utf8 -x nfc``` converts stdin to NFC, and 
> ```uconv -f utf8 -t utf8 -x nfd``` converts stdin to NFD.


From:  
[NFC or NFD - what is the difference?](https://stackoverflow.com/questions/26525354/nfc-or-nfd-what-is-the-difference)    

> The difference is whether the characters are composed (C) or decomposed (D).
>  
> Letters with "extra bits" like ä can be represented in different ways. 
> There is a Unicode code point specially created for a with two dots. 
> That is the composed form, NFC. On the other hand you could represent 
> it as the usual "a" followed by a combining character that adds the 
> two dots. That is the decomposed form, NFD.
>  
> The decomposed form takes more space, but the composed form makes some 
> operations harder, such as comparing strings while ignoring differences 
> in accents.


Method 1 - NFD Normalization with uconv(1):

```
% ./uni.pl 1EBF
ế       1EBF    LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUTE
 
% ./uni.pl 1EBF | cut -f1
ế
 
% printf `./uni.pl 1EBF | cut -f1`
ế% 
 
% printf `./uni.pl 1EBF | cut -f1` | uconv -f utf-8 -x any-name
\N{LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUTE}% 
 
% grep ^1EBF UnicodeData.txt 
1EBF;LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUTE;Ll;0;L;00EA 0301;;;;N;;;1EBE;;1EBE
 
% printf `./uni.pl 1EBF | cut -f1` | xxd -p
e1babf
 
% printf `./uni.pl 1EBF | cut -f1` | uconv -f utf-8 -t utf-8 -x any-nfd
ế% 
 
% printf `./uni.pl 1EBF | cut -f1` | uconv -f utf-8 -t utf-8 -x any-nfd | xxd
00000000: 65cc 82cc 81                             e....
 
% printf `./uni.pl 1EBF | cut -f1` | uconv -f utf-8 -t utf-8 -x any-nfd | xxd -p
65cc82cc81
 
% printf %o 0x65
145% 
 
% printf %o 0xcc
314% 
 
% printf %o 0x82
202% 
 
% printf %o 0xcc
314% 
 
% printf %o 0x81
201% 
 
% printf '\145'
e% 
 
% printf '\145\314'
e�% 
 
% printf '\145\314\202'
ê% 
 
% printf '\145\314\202\314'
ê�% 
 
% printf '\145\314\202\314\201'
ế% 
 
% printf '\314\202'
 
% printf '\040\314\202'
 ̂% 
 
% printf '\314\201'
 
% printf '\040\314\201'
 ́% 
 
% printf '\040\314\202' | uconv -f utf-8 -x any-name
\N{SPACE}\N{COMBINING CIRCUMFLEX ACCENT}% 
 
% printf '\040\314\201' | uconv -f utf-8 -x any-name
\N{SPACE}\N{COMBINING ACUTE ACCENT}% 
 
% grep -n -i "COMBINING CIRCUMFLEX ACCENT" UnicodeData.txt 
771:0302;COMBINING CIRCUMFLEX ACCENT;Mn;230;NSM;;;;;N;NON-SPACING CIRCUMFLEX;;;;
814:032D;COMBINING CIRCUMFLEX ACCENT BELOW;Mn;220;NSM;;;;;N;NON-SPACING CIRCUMFLEX BELOW;;;;
 
% grep -n -i "COMBINING ACUTE ACCENT" UnicodeData.txt
770:0301;COMBINING ACUTE ACCENT;Mn;230;NSM;;;;;N;NON-SPACING ACUTE;;;;
792:0317;COMBINING ACUTE ACCENT BELOW;Mn;220;NSM;;;;;N;NON-SPACING ACUTE BELOW;;;;
 
% grep -n -i "COMBINING CIRCUMFLEX ACCENT;" UnicodeData.txt
771:0302;COMBINING CIRCUMFLEX ACCENT;Mn;230;NSM;;;;;N;NON-SPACING CIRCUMFLEX;;;;
 
% grep -n -i "COMBINING ACUTE ACCENT;" UnicodeData.txt
770:0301;COMBINING ACUTE ACCENT;Mn;230;NSM;;;;;N;NON-SPACING ACUTE;;;;
```

This character is composed of the three-character sequence U+0065 (e) 
U+0302 (circumflex accent) U+0301 (acute accent). The combining classes 
for the two accents are both 230, thus U+1EBF is not equivalent to 
U+0065 U+0301 U+0302.

Reference:  
[Unicode equivalence - Wikipedia](https://en.wikipedia.org/wiki/Unicode_equivalence)


Method 2 - NFD Normalization with the uni.pl Perl script:

```
% printf '\040\314\202' > chartocheck
 
% file chartocheck
chartocheck: UTF-8 Unicode text, with no line terminators
 
% wc -l chartocheck
       0 chartocheck
 
% wc -c chartocheck
       3 chartocheck
```

NOTE:  
The character is there - squint and you'll see it next to the prompt (```%```). 

```
% cat -b chartocheck
     1   ̂% 

% cat -e chartocheck
 ̂% 
 
% cat -v chartocheck
 ̂% 
 
% xxd chartocheck
00000000: 20cc 82                                   ..
 
% od -bc chartocheck
0000000   040 314 202
                ̂  **
0000003
 
% hexdump -C chartocheck
00000000  20 cc 82                                          | ..|
00000003
 
% cut -f1 chartocheck
 ̂% 
 
% cut -f1 chartocheck | xxd
00000000: 20cc 82                                   ..
 
% cut -f1 chartocheck | xxd -p
20cc82
 
% cat chartocheck
 ̂% 
 
% ./uni.pl `cat chartocheck`
 ̂       0302    COMBINING CIRCUMFLEX ACCENT
```

Method 3 - NFC Normalization:


```
% printf `./uni.pl 1EBF | cut -f1` | uconv -f utf-8 -t utf-8 -x any-nfc | xxd
00000000: e1ba bf                                  ...
 
% printf `./uni.pl 1EBF | cut -f1` | uconv -f utf-8 -t utf-8 -x any-nfc | xxd -p
e1babf
 
% printf %o 0xe1
341% 
 
% printf %o 0xba
272% 
 
% printf %o 0xbf
277% 
 
% printf '\341'
�% 
 
% printf '\341\272'
�% 
 
% printf '\341\272\277'
ế% 
 
% printf '\341\272\277' | uconv -f utf-8 -x any-name
\N{LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUTE}% 

% grep -i "LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUTE" UnicodeData.txt 
1EBF;LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUTE;Ll;0;L;00EA 0301;;;;N;;;1EBE;;1EBE
```

### Find the Unicode Name Based On a Character's Unicode Code Point

For example, the Unicode code point of a character is ```U+00D6```.

```
% printf '\\u00D6' | uconv -x 'hex-any; any-name'
\N{LATIN CAPITAL LETTER O WITH DIAERESIS}% 
```

### Find the Unicode Code Point (Hex Code) of a Character

Assuming a little-endian (Intel) CPU [³] and that all code points in the 
input fit into 16-bits (not a safe assumption). 

[³] Change to UTF-16BE for big-endian machines. 

```
% printf Ö | iconv -t UTF-16LE | od -tx2 -An
             00d6
```

If some characters require more than 16-bit, a safer option is to use 32-bits for every code point:

```
% printf Ö | iconv -t UTF-16LE | od -tx4 -An
                 000000d6                                                
```


### Decompose (Normalize) a Composite Unicode Character

For example, the character you want to decompose is: ```Ö```.

```
% printf Ö | uconv -f utf-8 -t utf-8 -x any-nfd
Ö% 

% printf Ö | uconv -f utf-8 -t utf-8 -x any-nfd | xxd
00000000: 4fcc 88                                  O..

% printf Ö | uconv -f utf-8 -t utf-8 -x any-nfd | xxd -p
4fcc88
```

This character's UTF-8 code: ```0x4F 0xCC 0x88```.

To check/confirm, print the character based on its UTF-8 code:

```
% printf %o 0x4f
117% 

% printf %o 0xcc
314% 

% printf %o 0x88
210% 

% printf '\117\314\210'
Ö% 
```

Also, you can see from the Unicode database, UnicodeData.txt, that this 
character's Decomposition field (fifth field [⁴]) is not empty and that the 
character is composed of two characters.   

[⁴] As the Unicode database, UnicodeData.txt, is a database of characters 
listed by their Code Points, the first field (Code Point value) is not 
counted, that is, field count starts with the next field, Name. 

First, find the Unicode Name of the Character: 

```
% printf Ö | uconv -f utf-8 -x any-name
\N{LATIN CAPITAL LETTER O WITH DIAERESIS}% 
```

Find the character in the Unicode database, UnicodeData.txt.   
(Note: disregard the second character since its name has an additional 
'AND MACRON'.)

```
% grep -i 'LATIN CAPITAL LETTER O WITH DIAERESIS' UnicodeData.txt 
00D6;LATIN CAPITAL LETTER O WITH DIAERESIS;Lu;0;L;004F 0308;;;;N;
  LATIN CAPITAL LETTER O DIAERESIS;;;00F6;
022A;LATIN CAPITAL LETTER O WITH DIAERESIS AND MACRON;Lu;0;L;
  00D6 0304;;;;N;;;;022B;
```

The fifth field (Decomposition) specifies that the character is 
composed with two characters: ```U+004F``` and ```U+0308```.


```
% grep ^004F UnicodeData.txt
004F;LATIN CAPITAL LETTER O;Lu;0;L;;;;;N;;;;006F;

% grep ^0308 UnicodeData.txt 
0308;COMBINING DIAERESIS;Mn;230;NSM;;;;;N;NON-SPACING DIAERESIS;;;;
```

In other words, this character is composed of 
LATIN CAPITAL LETTER O and COMBINING DIAERESIS.


```
% printf Ö | uconv -f UTF-8 -t UTF-8 -x any-nfd | xxd
00000000: 4fcc 88                                  O..
```

```
% printf "0 004F" | xxd -r | iconv -f UNICODEBIG -t UTF-8
O% 
```

```
% printf "0 0308" | xxd -r | iconv -f UNICODEBIG -t UTF-8
```

This character cannot be displayed in a terminal emulator because it's 
from Unicode character class (category) "Mark, Nonspacing", 
signified by the **Mn** designation in the UnicodeData.txt database. 
(See the output of ```grep ^0308 UnicodeData.txt``` command above.)  

To display this character (and other similar characters; from other 
combining classes, 
in a terminal emulator, apply it 
to a space; that is, place the space character (U+0020 SPACE) first 
**followed by** the character itself (U+0308 COMBINING DIAERESIS).
That gives you a spacing (i.e., non-combining) combining diaeresis.

```
% printf "0 00200308" | xxd -r | iconv -f UNICODEBIG -t UTF-8
 ̈% 
```

NOTE:   
The character is there - squint and you'll see it next to the prompt (%).


NOTE:  
You can also display this character by placing 
(ASCII 0x0A LF, or ASCII 0x0B VT, or 0x0C FF)
after the character.


```
% printf "0 0308000A" | xxd -r | iconv -f UNICODEBIG -t UTF-8
 ̈
```

```
% printf "0 0308000B" | xxd -r | iconv -f UNICODEBIG -t UTF-8
 ̈
```

```
% printf "0 0308000C" | xxd -r | iconv -f UNICODEBIG -t UTF-8
 ̈
```

From  
XTerm Control Sequences  (<https://invisible-island.net/xterm/ctlseqs/ctlseqs.html>)  
under **VT100 Mode Single-character functions** 

- FF Form Feed or New Page (NP ).  (FF  is Ctrl-L).
  FF  is treated the same as LF .
- LF Line Feed or New Line (NL).  (LF  is Ctrl-J).
- VT Vertical Tab (VT  is Ctrl-K). This is treated the same as LF.


Also see:   
[Summary of ANSI standards for ASCII terminals Joe Smith, 18-May-84, With additions by Dennis German](https://www.real-world-systems.com/docs/ANSIcode.html)

Under section named   
**C0 set of 7-bit control characters (from ANSI X3.4-1977)**   

```
Oct Hex Control Name Description 
-- snip --
012 0A  J       LF   * Linefeed, move to same position on next line (see also NL)
013 0B  K       VT   * Vertical Tabulation, move to next predetermined line
014 0C  L       FF   * Form Feed, move to next form or page
-- snip --

* functions used in DEC VT series or LA series terminals 
```


#### Combining Class (Unicode) 

From   
Squeak/Smalltalk -- an open-source Smalltalk programming system Wiki:    
[Combining Class (Unicode)](https://wiki.squeak.org/squeak/6257)

Combining class: A numeric value in the range 0..254 given to each.
Unicode code point, formally defined as the property 
**Canonical_Combining_Class**.

- The combining class for each encoded character in the standard is 
specified in the file UnicodeData.txt in the Unicode Character Database. 
Any code point not listed in that data file defaults to 
\p{Canonical_Combining_Class = 0} (or \p{ccc = 0} for short).
- An *extracted* listing of combining classes, sorted by numeric value, 
is provided in the file **DerivedCombiningClass.txt** in the Unicode 
Character Database (UCD).
- *Only* **combining marks** have a combining class **other than zero**. 
**Almost all** combining marks with a **class other than zero** are 
*also* **nonspacing marks**, with *a few exceptions*. Also, *not all* 
*nonspacing marks* have a *non-zero combining class*. Thus, while the 
*correlation* between ^\p{ccc=0] and \p{gc=Mn} is close, it is *not exact*, 
and implementations should not depend on the two concepts being identical. 

**Unicode Character Database**    
This directory contains the final Unicode data files.   
(At the time of writing, Version 14.0.0 of the Unicode Standard.)  
(Date: 2021-09-10, 17:20:00 GMT [KW])   
<https://www.unicode.org/Public/UCD/latest/ucd/extracted/>

DerivedCombiningClass.txt   
A file in the Unicode Character Database that lists the characters in 
each of the combining classes.

<https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedCombiningClass.txt>

To find more about combining classes, and their detailed breakdown, refer to    
[Unicode Character Database - Standard Annex #44](https://www.unicode.org/reports/tr44/)  
Version: Unicode 14.0.0 - Date: 2021-08-30   
(Retrieved on Nov 27, 2021)  
under section explaning the UnicodeData.txt outlined at   
<https://www.unicode.org/reports/tr44/#UnicodeData.txt>   
<https://www.unicode.org/reports/tr44/#Canonical_Combining_Class>   
and broken down in a table under section    
[5.7.4 Canonical Combining Class Values](https://www.unicode.org/reports/tr44/#Canonical_Combining_Class_Values)  

This table (Table 15. Canonical_Combining_Class Values) 
lists the long symbolic aliases for Canonical_Combining_Class 
values, along with a brief description of each category. (The listing for 
fixed position classes, with long symbolic aliases of the form "Ccc10", 
and so forth, is abbreviated, as when those labels occur they are 
predictable in form, based on the numeric values.) 

In this example, the combining class with value **230** is for marks that 
are drawn **above** (the "Description" from the table 
"Canonical_Combining_Class Values" is "Distinct marks directly above").

*A quick breakdown of the combining classes:*   
0 Non-combining characters, or characters that surround or become part of the base character  
1 Marks that attach to the interior of their base characters, or overlay them  
7–199 Various marks with language- or script-specific joining behaviour  
200–216 Marks that attach to their base characters in various positions   
218–232 Marks that are drawn in a specific spot relative to their base 
characters but don't touch them    
233–234 Marks that appear above or below two base characters in a row   
240 The iota subscript used in ancient Greek   


**Note:**    
This character (U+0308) is unique in that it's a lead-trail; the only 
character that can be both leading and trailing:

From  
[Canonically Equivalent Shortest Form](https://icu.unicode.org/design/normalizing-to-shortest-form) 

> A character is lead-trail when it can be both leading and trailing. 
> There is only one such character, a non-starter.
> 
>    U+0308 ( ̈ ) COMBINING DIAERESIS   
> <https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%5Cu0308%5D&g=&i=>
>
> (It is the lead in the decomposition of 
> U+0344 ( ̈́ ) COMBINING GREEK DIALYTIKA TONOS)
>


In **NFC** form:

```
% printf Ö | uconv -f UTF-8 -t UTF-8 -x any-nfc | xxd
00000000: c396                                     ..
```

Check/confirmation:

```
% printf %o 0xc3
303% 
 
% printf %o 0x96
226% 
 
% printf '\303\226'
Ö% 
```


Straight with the uni.pl Perl script:

```
% ./uni.pl 00D6
Ö       00D6    LATIN CAPITAL LETTER O WITH DIAERESIS
```


As before, if in doubt, use

**ICU Demonstration - Normalization Browser**   
<https://icu4c-demos.unicode.org/icu-bin/nbrowser>

  or another useful tool:

**UniView**   
<https://r12a.github.io/uniview/>

UniView:  
"Look up and see characters (using graphics or fonts) and property 
information, view whole character blocks or custom ranges, select 
characters to paste into your document, paste in and discover unknown 
characters, search for characters, do hex/dec/ncr conversions, 
highlight character types, etc." 


### List All Possible Transliterations (in uconv/ICU)

```
% uconv -L | tr ' ' '\n' | grep -i any | sort -f
```

```
% uconv -L | tr ' ' '\n' | grep -i any | sort -f | wc -l
     155
```

```
% uconv -L | tr ' ' '\n' | grep -i any | sort -f 
---- snip ----
Any-Hex
Any-Hex/C
Any-Hex/Java
Any-Hex/Perl
Any-Hex/Unicode
---- snip ----
Any-sr_Latn/BGN
---- snip ----
Accents-Any
---- snip ----
Any-Name
Any-NFC
Any-NFD
Any-NFKC
Any-NFKD

```

Usage:

```
uconv -x 'hex-any ; any-hex
uconv -x 'hex-any ; any-hex/c'
uconv -x 'hex-any ; any-hex/java'
uconv -x 'hex-any ; any-hex/perl'
uconv -x 'hex-any ; any-hex/unicode'

uconv -x 'hex-any ; Any-sr_Latn/BGN'

uconv -x 'hex-any ; Accents-Any'

uconv -x 'hex-any ; Any-Name'
uconv -x 'hex-any ; Any-NFC'
uconv -x 'hex-any ; Any-NFD'
uconv -x 'hex-any ; Any-NFKC'
uconv -x 'hex-any ; Any-NFKD'
```


#### Remove Accents (Normalization, uconv/ICU)


```
% printf "Ö" | uconv -f utf-8 -t utf-8 -x "::NFD; [:Nonspacing Mark:] >; ::NFC;"
O%
```

### Simplify a String (Remove Diacritics[⁴]) - Normalization, uconv/ICU, Perl
### Extreme Example

From   
[Generic way to simplify string, remove diacritics](https://stackoverflow.com/questions/13542421/generic-way-to-simplify-string-remove-diacritics)


```
% echo "ë ö ø Я Ł ɲ æ å ñ 開 당" | uconv -f utf-8 -x any-name \
 | perl -wpne 's/ WITH [^}]+//g;' | uconv -f utf-8 -t utf-8 -x name-any \
 | uconv -f utf-8 -x any-latin -t iso-8859-1 -c \ 
 | uconv -f iso-8859-1 -t ascii -x latin-ascii -c
```

Output:

```
e o o A L n ae a n ki dang
```

Note 1: Я -> A because that is the correct behaviour. 

Note 2: This fails on inputs containing diacritics without letters, 
as in ´ (acute accent) and ¨ (umlaut/diaeresis).

[⁴] From Wikipedia (Retrieved on Nov 6, 2021):
<https://en.wikipedia.org/wiki/Diacritic>

> A diacritic (also diacritical mark, diacritical point, diacritical sign, 
> or accent) is a glyph added to a letter or to a basic glyph. 
> Some diacritics, such as the acute (◌́  ) and > grave (◌̀  ), are often 
> called accents. Diacritics may appear above or below a letter or in 
> some other position such as within the letter or between two letters.


SEE ALSO:  
**Diacritical Marks in Unicode (gregtatum.com)**  
<https://gregtatum.com/writing/2021/diacritical-marks/>


### Character to Value in a Shell

```printf``` utility uses the leading-quote syntax (```\'A```): 

From The Open Group Base Specifications Issue 7, 2018 edition
IEEE Std 1003.1-2017 (Revision of IEEE Std 1003.1-2008)
Copyright © 2001-2018 IEEE and The Open Group
<https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html>

> If the leading character is a single-quote or double-quote, the value 
> shall be the numeric value in the underlying codeset of the character
> following the single-quote or double-quote.


```sh
% man ascii
---- snip ---

ASCII(7)           FreeBSD Miscellaneous Information Manual           ASCII(7)

NAME
     ascii - octal, hexadecimal, decimal and binary ASCII character sets

DESCRIPTION
     The octal set:
     ---- snip ---- 
     100  @   101  A   102  B   103  C   104  D   105  E   106  F   107  G
     ---- snip ---- 

     The hexadecimal set:
     ---- snip ---- 
     40  @    41  A    42  B    43  C    44  D    45  E    46  F    47  G
     ---- snip ---- 

     The decimal set:
     ---- snip ---- 
      64  @    65  A    66  B    67  C    68  D    69  E    70  F    71  G
     ---- snip ---- 

     The binary set:

      00     01     10     11

     NUL     SP      @      `     00000
     SOH      !      A      a     00001
     ---- snip ---- 
```


Numeric value (in decimal) of the character 'A' in the 
ISO/IEC 646:1991 standard codeset:

```
% printf "%d\n" \'A
65
```

In hexadecimal:
```
% printf "%x\n" \'A
41
```

In octal:
```
% printf "%o\n" \'A
101
```

**Note:**
POSIX-portable way of printing a character based on the underlying 
codeset (ASCII, UTF-8, Unicode) is to use an octal value: 

```
% printf %b\\n '\'101
A
```

Example: the 'Skull and Crossbones' character.
Its Unicode code point is U+2620. 
```
% printf "%x\n" \'☠
2620
```

Unicode 2620 in UTF-8 is E2-98-A0.
```
% printf ☠ | hexdump -C
00000000  e2 98 a0                      |...|
00000003
```

In octal:
```
% printf ☠ | hexdump -b
0000000 342 230 240                                                    
0000003
```


```
% printf ("\xE2\x98\xA0")
Badly placed ()'s.

% printf "\xE2\x98\xA0"
xE2x98xA0%

% printf "%o\n" "0xE2"
342

% printf "%o\n" "0x98"
230

% printf "%o\n" "0xA0"
240

% printf '\342\230\240'
☠%

% printf '\342\230\240\n'
☠
```


#### OS and Shell Specifics - printf(1) and builtins

tcsh shell's ```builtins``` prints the names of all builtin commands:
```
% builtins
:          @          alias      alloc      bg         bindkey    break
breaksw    builtins   case       cd         chdir      complete   continue
default    dirs       echo       echotc     else       end        endif
endsw      eval       exec       exit       fg         filetest   foreach
glob       goto       hashstat   history    hup        if         jobs
kill       limit      log        login      logout     ls-F       nice
nohup      notify     onintr     popd       printenv   pushd      rehash
repeat     sched      set        setenv     settc      setty      shift
source     stop       suspend    switch     telltc     termname   time
umask      unalias    uncomplete unhash     unlimit    unset      unsetenv
wait       where      which      while      
```

```sh
% man tcsh
---- snip ----
REFERENCE
    The next sections of this manual describe all of the available Builtin
    commands, Special aliases and Special shell variables.

  Builtin commands
---- snip ----
     which command (+)
             Displays the command that will be executed by the shell after
             substitutions, path searching, etc.  The builtin command is
             just like which(1), but it correctly reports tcsh aliases and
             builtins and is 10 to 100 times faster.  See also the which-
             command editor command.
---- snip ----
```


```sh
% man 1 printf
---- snip ----
  Some shells may provide a builtin printf command which is similar or
  identical to this utility.  Consult the builtin(1) manual page.
---- snip ----
```

```
% man 1 builtin
---- snip ----
SYNOPSIS
  See the built-in command description in the appropriate shell 
  manual page.

DESCRIPTION
  Shell builtin commands are commands that can be executed within the
  running shell's process.  Note that, in the case of csh(1) builtin
  commands, the command is executed in a subshell if it occurs as any
  component of a pipeline except the last.

  If a command specified to the shell contains a slash ‘/’, the shell will
  not execute a builtin command, even if the last component of the
  specified command matches the name of a builtin command.  Thus, while
  specifying “echo” causes a builtin command to be executed under shells
  that support the echo builtin command, specifying “/bin/echo” or “./echo”
  does not.

  While some builtin commands may exist in more than one shell, their
  operation may be different under each shell which supports them.  Below
  is a table which lists shell builtin commands, the standard shells that
  support them and whether they exist as standalone utilities.
---- snip ----

    Command           External        csh(1)       sh(1)
---- snip ----
    printf            Yes             No           Yes
---- snip ----
```

**Note:**
tcsh is the standard FreeBSD shell .

printf is not a builtin in csh/tcsh shells. 
(It's built into Bash and ksh93 shells.)

In tcsh shell, printf is an external binary in /usr/bin/printf.

```sh
% which printf
/usr/bin/printf
```


###  Character to Value in/with Perl

```
% perl -e 'printf "%c\n", 65;'
A
```

```
% perl -e 'print chr(65), "\n"'
A
```


### Testing the Terminal Emulator

From  
[How to set up a clean UTF-8 environment in Linux](https://perlgeek.de/en/article/set-up-a-clean-utf8-environment)

To test if you terminal emulator works, copy and paste this line 
in your shell:
```perl
perl -Mcharnames=:full -CS -wle 'print "\N{EURO SIGN}"'
```

This should print a Euro sign € on the console. If it prints a single 
question mark instead, your fonts might not contain it. Try installing 
additional fonts. If multiple different (nonsensical) characters are shown, 
the wrong character encoding is configured.

On my system, output is
```sh
€
```
----

TODO1    

LANGUAGES

- sh; shells (sh, csh/tcsh, ksh93, bash, etc.(?) )  
<https://unix.stackexchange.com/questions/245013/get-the-display-width-of-a-string-of-characters>  

- awk   
<https://unix.stackexchange.com/questions/245013/get-the-display-width-of-a-string-of-characters>

[Eric Pruitt](https://www.codevat.com/) wrote an implementation of 
wcwidth() and wcswidth() in Awk available at 
[wcwidth.awk](https://github.com/ericpruitt/wcwidth.awk). 

It mainly provides 4 functions   


```wcscolumns(), wcstruncate(), wcwidth(), wcswidth()```

where ```wcscolumns()``` also tolerates non-printable characters.


```
% fetch \
https://raw.githubusercontent.com/ericpruitt/wcwidth.awk/master/wcwidth.awk
```

```
% ls -lh wcwidth.awk
-rw-r--r--  1 dusko  wheel    33K Dec  5 14:20 wcwidth.awk
 
% file wcwidth.awk
wcwidth.awk: awk script, UTF-8 Unicode text executable
 
% wc -l wcwidth.awk
     698 wcwidth.awk
```

**wcscolumns(string)**   

Determine the number of columns needed to display a string. 

**Arguments:**   
**string:** A string of any length. In AWK interpreters that are not 
multi-byte safe, this argument is interpreted as a UTF-8 encoded string.  
**Returns:** The number of columns needed to display the string. 
This value will always be greater than or equal to 0.

**Example:**  
```
% cat example1.awk
{
  printf "wcscolumns(\"%s\") → %s\n", $0, wcscolumns($0)
}
```

```
% printf "⌚" | awk -f wcwidth.awk -f example1.awk
wcscolumns("⌚") → 2
``` 

``` 
% printf "⏱" | awk -f wcwidth.awk -f example1.awk
wcscolumns("⏱") → 1
```


**wcwidth(character)**   
A reimplementation of the 
[POSIX function of the same name](http://pubs.opengroup.org/onlinepubs/9699919799/functions/wcwidth.html) 
to determine the number of columns needed to display a single character.

**Arguments:**   
**character:** A single character. In AWK interpreters that are not multi-byte 
safe, this argument may consist of multiple characters that together 
represent a single UTF-8 encoded code point.

**Returns:** The number of columns needed to display the character if it is 
printable and -1 if it is not. If the argument does not contain exactly 
one UTF-8 character, -1 is returned.


**Example:**  

```
% cat example2.awk
{
  printf "wcwidth(\"%s\") → %s\n", $0, wcwidth($0)
}
```

```
% printf "⌚\n⏱\n" | awk -f wcwidth.awk -f example2.awk
wcwidth("⌚") → 2
wcwidth("⏱") → 1
```


- Perl   
<https://www.perlmonks.org/?node_id=923932>   
<https://stackoverflow.com/questions/9428891/what-is-the-right-way-to-get-a-grapheme/9430419>   


uniquote(1) is part of Perl module Unicode::Tussle so you need to install the module first:

```
% sudo cpanm Unicode::Tussle
```

Note:  
Instead of installing the Unicode::Tussle module, you could just download the source code for uniquote(1): ```fetch https://fastapi.metacpan.org/source/BDFOY/Unicode-Tussle-1.111/script/uniquote```


```
% perl -CS -Mutf8 -MUnicode::Normalize -E 'say "crème brûlée"'
crème brûlée
```


```
% perl -v

This is perl 5, version 32, subversion 1 (v5.32.1) built for 
amd64-freebsd-thread-multi
```

```
% cat getgrapheme01.pl
#!/usr/bin/env perl
use warnings;
use 5.014;
use utf8;
binmode STDOUT, ':utf8';
use charnames qw(:full);

my $string = "\N{LATIN CAPITAL LETTER U}\N{COMBINING DIAERESIS}";

while ( $string =~ /(\X)/g ) {
        say $1;
}
```

```
% ./getgrapheme01.pl
Ü
```

```
% cat getgrapheme02.pl
#!/usr/bin/env perl

use warnings;
use 5.014;
binmode STDOUT, ':utf8';

use Unicode::Normalize;

my $string = "fu\N{COMBINING DIAERESIS}r";
$string = NFC($string);

while ( $string =~ /(\X)/g ) {
    say $1;
}
```

```
% ./getgrapheme02.pl
f
ü
r
```


Perl - width example 
(the number of columns the string occupies when displayed)
 

```
% perl -MText::CharWidth=mbswidth -le 'print mbswidth shift' "A"
1

% perl -MText::CharWidth=mbswidth -le 'print mbswidth shift' "⌚"
2
 
% perl -MText::CharWidth=mbswidth -le 'print mbswidth shift' "⏱"
1
% 
```

- C   


C - Example 1    
UTF-8 validator and wrapper around a small UTF-8 library.    
Based on Bjoern Hoehrmann's UTF-8 decoder function written in C, 
a DFA (Deterministic Finite Automaton) parser.  

```
% cd /tmp

% fetch https://github.com/howerj/utf8/archive/refs/heads/master.zip

% ls -lh master.zip
-rw-r--r--  1 dusko  wheel    13K Dec 16 16:59 master.zip

% unzip master.zip

% rm -i master.zip

% ls -ld utf8-master/
drwxr-xr-x  2 dusko  wheel  10 Dec 16 17:00 utf8-master/
```

```
% cd utf8-master/

% pwd
/tmp/utf8-master

% ls -alh
total 317
drwxr-xr-x   2 dusko  wheel    10B Dec 16 17:00 .
drwxrwxrwt  90 root   wheel   1.9K Dec 16 17:00 ..
-rw-r--r--   1 dusko  wheel    33B Dec  4  2020 .gitignore
-rw-r--r--   1 dusko  wheel   1.1K Dec  4  2020 LICENSE
-rw-r--r--   1 dusko  wheel   1.4K Dec  4  2020 main.c
-rw-r--r--   1 dusko  wheel   1.1K Dec  4  2020 makefile
-rw-r--r--   1 dusko  wheel   3.5K Dec  4  2020 readme.md
-rw-r--r--   1 dusko  wheel   7.4K Dec  4  2020 utf8.c
-rw-r--r--   1 dusko  wheel   1.0K Dec  4  2020 utf8.h
-rw-r--r--   1 dusko  wheel    22K Dec  4  2020 utf8.txt
```


```
% cat readme.md
% utf8(1) | UTF8 Validator

# NAME

UTF8 - UTF-8 validator and wrapped around a small UTF-8 library

# SYNOPSES

utf8 string

utf8 < file

# DESCRIPTION

        Author:     Richard James Howe / Bjoern Hoehrmann
        License:    MIT
        Repository: <https://github.com/howerj/utf8>
        Email:      howe.r.j.89@gmail.com
        Copyright:  2008-2009 Bjoern Hoehrmann
        Copyright:  2020      Richard James Howe

This UTF-8 validator/decoder library is based entirely
around the (excellent) code and description available at
<http://bjoern.hoehrmann.de/utf-8/decoder/dfa/>,

Modifications are released under the same license as the original. The
executable built is mainly just there to allow the library itself to be
tested. This is a very minimal set of UTF-8 utilities, not much is provided
but it should allow you to build upon it.

# USAGE
 
The test program can either check whether a string passed in as an argument
is valid UTF-8 or it can read from stdin(3) if no argument is given and do
the same, in both cases the number of code points, if any, that have been
decoded is printed out if and only if the entire input is valid.

---- snip ----

This is a very simple library meant to deal with UTF-8 data, and converting
strings to and from code-points. It does not deal with issues like Unicode
normalization, case conversion and a whole host of horrors that occur when
not using ASCII.
```

```
% cc \
 -std=c99 -Wall -Wextra -pedantic -O2 -DUTF8_VERSION="0x010000ul" \
 utf8.c utf8.h main.c
```


```
% ls -lhrt | tail -1
-rwxr-xr-x  1 dusko  wheel    20K Dec 16 17:01 a.out
```


```
% ./a.out "hello"
5
```

```
% printf %s "hello" > file

% ./a.out < file
5
```

```
% echo "hello" > file

% ./a.out < file
6
```


C - Example 2:  
<https://stackoverflow.com/questions/58185069/expected-encoding-of-wcwidth-argument>   

Note:  
See  
<https://pubs.opengroup.org/onlinepubs/9699919799/functions/V2_chap02.html#tag_15_02_01_02>  
"An XSI-conforming application shall ensure that the feature test macro _XOPEN_SOURCE is defined with the value 700 before inclusion of any header."


```
% cat wcwidth_c_example_1.c
#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <locale.h>
#include <wchar.h>

int main(void)
{
    setlocale(LC_CTYPE, "");

    wchar_t c1 = L'ｈ';
    wchar_t c2 = L'⌚';
    wchar_t c3 = L'⏱';

    printf("Fullwidth small letter h (U+FF48) - width: %d\n", wcwidth(c1));
    printf("Watch (U+231A) - width: %d\n", wcwidth(c2));
    printf("Stopwatch (U+23F1) - width: %d\n", wcwidth(c3));

    return 0;
}
```


```
% cc wcwidth_c_example_1.c
```

```
% ./a.out
Fullwidth small letter h (U+FF48) - width: 2
Watch (U+231A) - width: 2
Stopwatch (U+23F1) - width: 1
```

C - Example 3:  
<https://www.ibm.com/docs/en/i/7.1?topic=functions-wcwidth-determine-display-width-wide-character>  

```
% cat wcwidth_c_example_2.c
#include <stdio.h>
#include <wchar.h>

int main(void)
{
   wint_t wc1 = L'A';
   wint_t wc2 = L'⌚';
   wint_t wc3 = L'⏱';
   wchar_t *wcs = L"ABC";

   printf("wc1 has a width of: %d\n", wcwidth(wc1));
   printf("wc2 has a width of: %d\n", wcwidth(wc2));
   printf("wc3 has a width of: %d\n", wcwidth(wc3));
   printf("wcs has a width of: %d\n", wcswidth(wcs,3));
}
```

```
% cc wcwidth_c_example_2.c
```

Return Value  
The wcswidth() function either returns:   
- 0, if wcs points to a null wide character; or
- the number of printing positions occupied by the wide string pointed to 
by wcs; or
- -1, the wide string pointed to by wcs is not printable 

```
% ./a.out
wc1 has a width of: 1
wc2 has a width of: -1
wc3 has a width of: -1
wcs has a width of: 3
```


C - Example 4:  
<https://sites.ualberta.ca/dept/chemeng/AIX-43/share/man/info/C/a_doc_lib/libs/basetrf2/wcswidth.htm>


```
% cat wcwidth_c_example_3.c 
#include <locale.h>
#include <stdio.h>
#include <wchar.h>

int main(void)
{
   int     retval1, retval2, n;
   
   wchar_t *pwcsWatch = L"⌚";
   wchar_t *pwcsStopwatch = L"⏱";
   
   (void)setlocale(LC_ALL, "");
   
   /* Let pwcs point to a wide character null terminated 
   ** string. Let n be the number of wide characters whose
   ** display column width is to be determined.
   */
   retval1 = wcswidth(pwcsWatch, n);
   retval2 = wcswidth(pwcsStopwatch, n);

   if(retval1 == -1 || retval2 == -1){
           /* Error handling. Invalid wide character code 
           ** encountered in the wide character string pwcs.
           */
       printf("pwcs is not printable\n");
   }
   
   printf("pwcsWatch has a width of: %d\n", wcswidth(pwcsWatch,n));
   printf("pwcsStopwatch has a width of: %d\n", wcswidth(pwcsStopwatch,n));
}
```


```
% cc wcwidth_c_example_3.c
```

```
% ./a.out
pwcsWatch has a width of: 2
pwcsStopwatch has a width of: 1
```


Reference:  
<https://stackoverflow.com/questions/5117393/number-of-character-cells-used-by-string>


From  
utf8everywhere.org:   
[Counting coded characters or code points is important.](http://utf8everywhere.org/#myth.strlen)  

> The size of the string as it appears on the screen is unrelated to 
> the number of code points in the string. One has to communicate with 
> the rendering engine for this. Code points do not occupy one column 
> even in monospace fonts and terminals. POSIX takes this into account.


Also see:  
- Programming with wide characters - Linux.com   
<https://www.linux.com/news/programming-wide-characters/>  

- The Unicode HOWTO - 6. Making your programs Unicode aware
<https://tldp.org/HOWTO/Unicode-HOWTO-6.html>  
Bruno Haible - v1.0, Jan 23, 2001    


C - Example 5:  

<https://stackoverflow.com/questions/5117393/number-of-character-cells-used-by-string>   

```
% cat wcwidth_c_example_4.c 
#define _XOPEN_SOURCE
#include <wchar.h>
#include <stdio.h>
#include <locale.h>
#include <stdlib.h>

int measure(char *string) {
    // allocate enough memory to hold the wide string
    size_t needed = mbstowcs(NULL, string, 0) + 1;

    wchar_t *wcstring = malloc(needed * sizeof *wcstring);

    if (!wcstring) return -1;

    // change encodings
    if (mbstowcs(wcstring, string, needed) == (size_t)-1) return -2;

    // measure width
    int width = wcswidth(wcstring, needed);

    free(wcstring);
    return width;
}

int main(int argc, char **argv) {
    setlocale(LC_ALL, "");

    for (int i = 1; i < argc; i++) {
        printf("%s: %d\n", argv[i], measure(argv[i]));
    }
}
```


```
% cc wcwidth_c_example_4.c
```

```
% ./a.out hello 莊子 cＡb ⌚ ⏱
hello: 5
莊子: 4
cＡb: 4
⌚: 2
⏱: 1
```


```
% ~/uni.pl watch
⌚      231A    WATCH
⏱       23F1    STOPWATCH
𝍄       1D344   TETRAGRAM FOR WATCH
```

```
% ~/uni.pl watch | head -1 | cut -f1
⌚
``` 

```
% ./a.out `~/uni.pl watch | head -1 | cut -f1`
⌚: 2
```

```
% ~/uni.pl stopwatch
⏱       23F1    STOPWATCH
```

```
% ./a.out `~/uni.pl stopwatch | cut -f1`
⏱: 1
```

```
% ~/uni.pl watch | head -1 | cut -f1 | xxd -p
e28c9a0a

% ~/uni.pl stopwatch | cut -f1 | xxd -p
e28fb10a
```


```
% printf '%x\n' \'`~/uni.pl watch | head -1 | cut -f1`
231a
 
% printf '%x\n' \'`~/uni.pl stopwatch | cut -f1`
23f1
```

```
% printf '%x' \'`~/uni.pl watch | \ 
 head -1 | \
 cut -f1` | \ 
 xargs -Irplstr fc-list ":charset=rplstr" | \
 wc -l
      64
 
% printf '%x' \'`~/uni.pl stopwatch | \
 cut -f1` | \
 xargs -Irplstr fc-list ":charset=rplstr" | \
 wc -l
       7
```


```
% grep ^231A UnicodeData.txt
231A;WATCH;So;0;ON;;;;;N;;;;;
 
% grep ^23F1 UnicodeData.txt
23F1;STOPWATCH;So;0;ON;;;;;N;;;;;
```


The latest released version of the UCD (Unicode Character Database) 
is always accessible at:   
    <https://www.unicode.org/Public/UCD/latest/> 

As of Dec 3, 2021, the current version of Unicode is version 14.  

The UAXes and UTS #51 can be accessed at 
<https://www.unicode.org/versions/Unicode14.0.0/>

From that page, under '14.0.0 Unicode Standard Annexes' section, 
the link for *UAX #44, Unicode Character Database* is listed as   
<https://www.unicode.org/reports/tr44/tr44-28.html>

Unicode Character Database  
Unicode® Standard Annex #44  
Date: 2021-08-30  

> Because of the legacy format constraints for UnicodeData.txt, that file 
> contains no specific information about default values for properties. 
> The default values for fields in UnicodeData.txt are documented in 
> Table 4 below if they cannot be derived from the general rules about 
> default values for properties.
> 
> -- snip --   
> Table 4. Default Values for Properties
> 
> ``` 
> Property Name     Default Value(s)           Complex?
> -- snip --
> East_Asian_Width  Neutral (= N), Wide (= W)  Yes
> -- snip --
> ```

The Table 4 indicates that the *East_Asian_Width* property can be either  
Neutral (= **N**) or Wide (= **W**).   


```
% fetch https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt
```


```
% grep ^231A EastAsianWidth.txt
231A..231B;W     # So     [2] WATCH..HOURGLASS

% grep ^23F1 EastAsianWidth.txt
23F1..23F2;N     # So     [2] STOPWATCH..TIMER CLOCK
```

Therefore, the *watch* (U+231A) code point's East_Asian_Width property is 
**wide**, while the *stopwatch* (U+23F1) code point's East_Asian_Width 
property is **neutral**.  

That's why the code point's width for 'watch' symbol in xterm is **2**.  


C - Example 6    

```
% fetch https://raw.githubusercontent.com/notevenodd/wcswidth/master/wcswidth.c
```

```
% cc -O2 -Wall -o wcswidth wcswidth.c
```

```
% ./wcswidth TODO3 - WATCH 1 WIDTH
1
```

```
% ./wcswidth TODO4 - WATCH 2 WIDTH
2
```


- Python2  
<https://stackoverflow.com/questions/23873771/how-to-handle-combining-diacritical-marks-with-unicodeutils>   

- Python3   

```
% pkg search cwidth
py38-cwcwidth-0.1.4            Python bindings for wc(s)width
py38-wcwidth-0.1.8             Determine the printable width of the terminal
```

```
% sudo pkg install py38-cwcwidth
```

```
% python3.8
Python 3.8.10 (default, Jul  4 2021, 01:12:00)
[Clang 11.0.1 (git@github.com:llvm/llvm-project.git llvmorg-11.0.1-0-g43ff75f2c on freebsd13
Type "help", "copyright", "credits" or "license" for more information.
>>>
>>> import cwcwidth
>>>  
>>> cwcwidth.wcwidth("a")
1
>>>
>>>
>>> cwcwidth.wcswidth("コ")
2
>>>
>>>
>>> cwcwidth.wcswidth("⌚")
2
>>>
>>>
>>> quit()
```

<https://unix.stackexchange.com/questions/280843/xterm-doesnt-display-some-unicode-characters-properly>   

<https://stackoverflow.com/questions/2352018/cant-use-unichr-in-python-3-1>   


In Python 3, you just use chr (instead of unichr() in Python 2):

```
% cat prunichr.py
#!/usr/bin/env python3.8

for x in range(0x2620, 0x2938):
        print(chr(x))
``` 
 
```
% chmod 0744 prunichr.py
 
% ./prunichr.py
```

- Java

GB2312Unicode.java - GB2312 to Unicode Mapping  
<http://www.herongyang.com/GB2312/GB2312Unicode-Java-GB2312-Unicode-Mapping.html>

> If we compare GB2312 codes with Unicode codes of same Chinese characters, 
> we will not find any mathematical relations. So if someone wants to 
> convert a Chinese text file from the GB2312 encoding to a Unicode 
> encoding, he/she needs to use a big mapping table that covers all 
> 7445 GB2312 characters.
> 
> If we search the Internet, we probably can find copies of such mapping 
> table in different formats.
> 
> But if you have JDK (Java Development Kit) installed on your computer, 
> you can build a GB2312 to Unicode mapping table yourself with a simple 
> program.
> 
> Here is a Java program I wrote to build a GB2312 to Unicode mapping table, 
> GB2312Unicode.java. The output of the program includes 5 columns per 
> character:
> 
> - "Q.W." Column: The GB2312 Location Code of the character.
> - Second Column: The GB2312 Encoding of the character.
> - "GB" Column: The GB2312 Encoding in HEX value of the character.
> - "Uni." Column: The Unicode Code in HEX value of the character.
> - "UTF-8." Column: The UTF-8 Encoding in HEX value of the character.
>
> ```
> /* GB2312Unicode.java
> - Copyright (c) 2015, HerongYang.com, All Rights Reserved.
> */
> ---- snip ----
> 
> ```


Download the source code. Place it in a file; for example, called javaUnicodeGB2312.java.

```
% vi javaUnicodeGB2312.java
```

Create the Java class.

```
% javac javaUnicodeGB2312.java
```

```
% ls -lhrt
total 9
-rw-r--r--  1 dusko  wheel   3.9K Dec 16 18:47 javaUnicodeGB2312.java
-rw-r--r--  1 dusko  wheel   3.8K Dec 16 18:54 UnicodeGB2312.class
```

Run the Java program.

```
% java UnicodeGB2312
Number of GB characters wrote: 7445
```

```
% ls -lhrt
total 98
-rw-r--r--  1 dusko  wheel   3.9K Dec 16 18:47 javaUnicodeGB2312.java
-rw-r--r--  1 dusko  wheel   3.8K Dec 16 18:54 UnicodeGB2312.class
-rw-r--r--  1 dusko  wheel   108K Dec 16 18:54 unicode_gb2312.gb
```

```
% ls -lh unicode_gb2312.gb
-rw-r--r--  1 dusko  wheel   108K Dec 16 18:54 unicode_gb2312.gb

% file unicode_gb2312.gb
unicode_gb2312.gb: ISO-8859 text, with CRLF line terminators

% wc -l unicode_gb2312.gb
    1493 unicode_gb2312.gb
```

```
% cat unicode_gb2312.gb
<pre>
Uni. GB   ¡¡   Uni. GB   ¡¡   Uni. GB   ¡¡   Uni. GB   ¡¡   Uni. GB   ¡¡

00A4 A1E8 ¡è   00A7 A1EC ¡ì   00A8 A1A7 ¡§   00B0 A1E3 ¡ã   00B1 A1C0 ¡À
00B7 A1A4 ¡¤   00D7 A1C1 ¡Á   00E0 A8A4 ¨¤   00E1 A8A2 ¨¢   00E8 A8A8 ¨¨
00E9 A8A6 ¨¦   00EA A8BA ¨º   00EC A8AC ¨¬   00ED A8AA ¨ª   00F2 A8B0 ¨°
00F3 A8AE ¨®   00F7 A1C2 ¡Â   00F9 A8B4 ¨´   00FA A8B2 ¨²   00FC A8B9 ¨¹
0101 A8A1 ¨¡   0113 A8A5 ¨¥   011B A8A7 ¨§   012B A8A9 ¨©   014D A8AD ¨­
016B A8B1 ¨±   01CE A8A3 ¨£   01D0 A8AB ¨«   01D2 A8AF ¨¯   01D4 A8B3 ¨³
01D6 A8B5 ¨µ   01D8 A8B6 ¨¶   01DA A8B7 ¨·   01DC A8B8 ¨¸   02C7 A1A6 ¡¦
02C9 A1A5 ¡¥   0391 A6A1 ¦¡   0392 A6A2 ¦¢   0393 A6A3 ¦£   0394 A6A4 ¦¤
0395 A6A5 ¦¥   0396 A6A6 ¦¦   0397 A6A7 ¦§   0398 A6A8 ¦¨   0399 A6A9 ¦©
039A A6AA ¦ª   039B A6AB ¦«   039C A6AC ¦¬   039D A6AD ¦­   039E A6AE ¦®
039F A6AF ¦¯   03A0 A6B0 ¦°   03A1 A6B1 ¦±   03A3 A6B2 ¦²   03A4 A6B3 ¦³
03A5 A6B4 ¦´   03A6 A6B5 ¦µ   03A7 A6B6 ¦¶   03A8 A6B7 ¦·   03A9 A6B8 ¦¸
03B1 A6C1 ¦Á   03B2 A6C2 ¦Â   03B3 A6C3 ¦Ã   03B4 A6C4 ¦Ä   03B5 A6C5 ¦Å
---- snip ----
```


- Ruby   

----

TODO2   

Add:   
mime -- email messages  
imagemagick -> view with: xv, sxiv, feh, meh
fc-cache  
~/.fonts  
~/.config  
~/.xinitrc  
xterm: -report-charclass, -report-colors, -report-fonts, -report-icons,
       -report-xres   
Normalization  
Double-width Unicode characters in xterm   
uxterm   

Install PHP source code for the Unicode Searcher (a.k.a. The UniSearcher)   
<http://www.isthisthingon.org/unicode/unisearch-1.1.tgz>   


```
% pkg search yudit
yudit-3.0.7                    Multi-lingual Unicode text editor with TTF support
```

```
% pkg search ^lv 
lv-4.51.20200728               Powerful Multilingual File Viewer
lv-aspell-0.5.5.1_1,2          Aspell Latvian dictionary
lv-libreoffice-7.2.1.2         lv language pack for libreoffice
lv2-1.18.2                     Open standard for audio plugins (successor to LADSPA)
lv2file-0.84.31_1              Simple program that apples LV2 effects to audio files
lv2lint-0.14.0                 Check whether a given LV2 plugin is up to the specification
lv2proc-0.5.1_1                Simple command line effect processor using LV2 plugins
lvtk-2.0.0.r1.14               Wraps the LV2 C API and extensions into easy to use C++ classes
 
% pkg search mined
mined-2015.25                  Text mode editor with Unicode support
p5-LWP-UserAgent-Determined-1.07_1 Virtual browser that retries errors
```


```
% pkg info --regex --full vim-gtk3
---- snip ----

FreeBSD has the following Vim packages:
* vim: Console-only Vim (vim binary) with all runtime files
* vim-gtk3, -gtk2, -athena, -motif, -x11: Console Vim plus 
  a GUI (gvim binary)
* vim-tiny: Vim binary only, with no runtime files. Not useful for most 
  people; intended for minimal (ex. jail) installations

WWW: http://www.vim.org/
WWW: https://github.com/vim/vim
```

```
% xterm -class UXTerm
```


----

From  
From Bash to Z Shell: Conquering the Command Line   
Apress November 2004   
By Oliver Kiddle, Jerry Peek, Peter Stephenson   
Chapter 4 - the sidebar "The Terminal Driver"   

> The Terminal Driver
> 
> Why are there all these strange effects associated with terminals, 
> and why do we need the stty command to control them?
> 
> In the early days of Unix, shells had no editing capabilities of their own, 
> not even the basic ability to delete the previous character. 
> However, a program existed that read the characters typed by the user, 
> and sent them to the shell: the terminal driver. It gradually developed 
> a few simple editing features of its own, until it grew to include all 
> the features you can see from the output of ```stty -a```.
> 
> By default, the terminal driver accepts input a line at a time; this is 
> sometimes known as "canonical" input mode. For commands that don't know 
> about terminals, such as simple shells without their own editors, 
> the terminal driver usually runs in a mode sometimes known as "cooked." 
> (This is Unix humour; when not in "cooked" mode, the terminal is in "raw" 
> mode.) Here, all the special keys are used. This allows you some very 
> primitive editing on a line of input. For these simple editing features, 
> the command stty acts as a sort of bind or bindkey command.
> 
> For example, let's try cat, which simply copies input to output. 
> Type the following:
> 
> ```
> % cat
> this is a line<ctrl-u>
> ```
> 
> The line disappears; that's because of the kill stty setting. 
> If it didn't work, try setting the following first:
> 
> ```
> % stty kill '^u'
> ```
> 
> This is handled entirely by the terminal driver; neither the program 
> (cat) nor the shell knows anything about it. In "cooked" mode, the 
> terminal passes a complete line to the program when you press Return. 
> So cat never saw what you typed before the Ctrl-u.
> 
> Since not all programs want the terminal driver to handle their input, 
> the terminal has other modes. The shell itself uses "cbreak" mode 
> (not quite equivalent to "raw" mode), which means many of the characters 
> which are special in "cooked" mode are passed straight through to 
> the shell. Hence when you press Backspace in either bash or zsh, it's 
> the shell, not the terminal driver, that deals with it.


### Unicode Combining Diacritics in a Terminal

Reference:  
<https://forums.linuxmint.com/viewtopic.php?t=339238>

```
#include <stdio.h>
#include <locale.h>

int main(void)
{
  setlocale(LC_ALL, "en_CA.UTF-8");
  puts("\xc3\xab");   // e with diaeresis as one utf-8 char
  puts("e\xc2\xa8");  // e as one char, then combining diaeresis as utf-8 char
  puts("\xc2\xa8""e");// combining diaeresis as utf-8 char, then e as next char
    
  return 0;
}
```


Compile and test:  

```
% cc diacritics.c
 
% ls -lh a.out 
-rwxr-xr-x  1 dusko  wheel    15K Nov 27 13:18 a.out
 
% date
Sat 27 Nov 2021 13:18:36 PST
```

``` 
% ./a.out
ë
e¨
¨e
```

### Print Double Width Characters - Escape Characters with xterm 


```
% bash
$
$ command -v echo
echo

$ command -V echo
echo is a shell builtin

$ type -a echo
echo is a shell builtin
echo is /bin/echo

$ which echo
/bin/echo

$ whereis echo
echo: /bin/echo /usr/share/man/man1/echo.1.gz /usr/src/bin/echo

$ where echo
bash: where: command not found
```

Print double width characters, move cursor one position left and print an 'x'.

```
$ echo -e "你好\e[Dx"
你 x
```

Return back to csh:

```
$ exit
exit
% 
```


```
% command -v echo
echo
 
% command -V echo
echo is a shell builtin
 
% type echo
echo is a shell builtin
 
% type -a echo
echo is a shell builtin
-a: not found
 
% which echo
echo: shell built-in command.
 
% whereis echo
echo: /bin/echo /usr/share/man/man1/echo.1.gz /usr/src/bin/echo
 
% where echo
echo is a shell built-in
/bin/echo
```

```
% echo -e "你好\e[Dx"
-e 你好\e[Dx
```


From the man page for `xterm(1)`:
> The dump-html action can also be triggered using the
> Media Copy control sequence CSI 1 0 i, for example from a
> shell script with
>
>    ```printf '\033[10i'```


```
% printf "你好\033Dx"
你好
    x% 
```

To send the escape sequence from keyboard directly:   
The character ```^[``` is typed this way   
```Ctrl + v``` then ```Esc```


```
% printf "你好^[Dx"
你好
    x% 
```

```
% echo -n "你好^[Dx"
你好
    x%
```

```
% echo "你好^[Dx"
你好
    x
%
```


References:  
[cursor behavior for full/ambiguous width characters #9](https://github.com/selectel/pyte/issues/9)  

[Why I can't send escape sequences from keyboard, but can do it from another tty?](https://unix.stackexchange.com/questions/369845/why-i-cant-send-escape-sequences-from-keyboard-but-can-do-it-from-another-tty)  
Posted on Jun 7, 2017 - Updated on Sep 19, 2019 - Retrieved on Nov 6, 2021   


The man page for ```xterm(1)```:   

> ```
> echotc [-sv] arg ... (+)
>     Exercises the terminal capabilities (see termcap(5)) in args.
>     For example, 'echotc home' sends the cursor to the home
>     position, 'echotc cm 3 10' sends it to column 3 and row 10, and
>     'echotc ts 0; echo "This is a test."; echotc fs' prints "This
>     is a test."  in the status line.
> ```


## UNICHAR Function in Spreadsheets 

### UNICHAR Function in LibreOffice

LibreOffice Help  
<https://help.libreoffice.org/Calc/Text_Functions#UNICHAR>   

Converts a code number into a Unicode character or letter 

UNICHAR   
Converts a code number into a Unicode character or letter.  

*Syntax*  
UNICHAR(number)   

*Example*  
=UNICHAR(169) returns the Copyright character ©.  


### UNICHAR Function in Excel 

<https://exceljet.net/excel-functions/excel-unichar-function>   

----

### References:

- Unicode Utilities - Unicode.org: Character Properties
<https://util.unicode.org/UnicodeJsps/character.jsp>

- Unicode Utilities: Description and Index
<https://util.unicode.org/UnicodeJsps/> 

- UTF-8 encoding table and Unicode characters
<https://utf8-chartable.de/unicode-utf8-table.pl>

- UniView
<https://r12a.github.io/uniview/>

- Unicode code converter v10
<https://r12a.github.io/app-conversion/>

- Analyse string 
<https://r12a.github.io/app-analysestring/>

- Encoding converter (Unicode, UTF-8, hex, char, dec)
<https://r12a.github.io/app-encodings/>

- Information about a Unicode Code Point  
For example:  SNOWMAN WITHOUT SNOW, (U+26C4)  
<http://codepoints.net/U+26C4>

See also:   

- Fileformat.info   
<https://www.fileformat.info/info/unicode/char/26C4/index.htm>

- The Unicode Searcher (a.k.a. The UniSearcher)
<http://www.isthisthingon.org/unicode/index.phtml?glyph=26C4>   
<http://www.isthisthingon.org/unicode/index.php?page=02&subpage=6&glyph=026C4>

- All Unicoded Characters by Code Point  
<http://www.isthisthingon.org/unicode/allchars1.php>  

- Unicode website  
<https://unicode.org/cldr/utility/character.jsp?a=26C4>    
<https://util.unicode.org/UnicodeJsps/character.jsp?a=26C4>

- Wikipedia 
<https://en.wikipedia.org/wiki/%E2%9B%84>

- Graphemica
<https://graphemica.com/%E2%9B%84>

- ScriptSource
<https://scriptsource.org/cms/scripts/page.php?item_id=character_detail&key=U0026C4>

- Compart
<https://www.compart.com/en/unicode/U+26C4>

- Unicode-table
<https://unicode-table.com/en/search/?q=26C4>


- X11 fonts - a tutorial 
<https://twiserandom.com/unix/x11-fonts-a-tutorial/index.html>

- X.org Fonts General
<http://xpt.sourceforge.net/techdocs/nix/x/fonts/xf18-XorgFontsGeneral/single/>

- A semi-brief history and overview of X fonts and font rendering technology
<https://utcc.utoronto.ca/~cks/space/blog/unix/XFontTypes>

- Unicode Explained book By Jukka K. Korpela
<https://learning.oreilly.com/library/view/unicode-explained/059610121X/>

- Fontconfig - freedesktop.org 
<https://www.freedesktop.org/wiki/Software/fontconfig/>

- Xft - freedesktop.org 
<https://freedesktop.org/wiki/Software/Xft/>

- Character Encoder / Decoder Tool -- String Functions - Online String Manipulation Tools
<https://string-functions.com/encodedecode.aspx>
##### What Is a Code Page?
> Code page is another name for character encoding. It consists of a table 
> of values that describes the character set for a particular language.

##### What is Character Encoding?
> Character encoding is the process of encoding a collection of characters 
> according to an encoding system. This process normally pairs numbers with 
> characters to encode information that can be used by a computer.
> 
> Character encodings allow us to understand the encoding that is taking 
> place with computers. Due to there being a variety of character encodings, 
> errors can spring up when encoded with one character encoding and decoding 
> with another. The above tool can be used to simulate if any errors will 
> come up when encoding with any character encoding and decoding with another.

##### Types of Character Encodings
> There is a wide variety of encodings that can be used to encode or decode 
> a string of characters, including UTF-8, ASCII, and ISO 9959-1.
> 
> Examples of popular character encodings:
> - ASCII: American Standard Code for Information Exchange
> - ANSI: American National Standards Institute
> - Unicode (internal text codes used by operating systems)
> - UTF-8 (Unicode Transformation Format that uses 1 byte to represent characters)
> - UTF-16 (Unicode Transformation Format that uses 2 bytes to represent characters)
> - UTF-32 (Unicode Transformation Format that uses 4 bytes to represent characters)
> 
> While these are certainly popular encodings that are used, there are 
> times when strings of code are encoded with encodings that aren't as 
> widely used, such as x-IA5-Norgwegian or DOS-720. This can cause confusion 
> and possible errors, so it's important to understand how to reduce these 
> errors by simulating beforehand using String Functions'
> character encoding/decoding tool.

- Misconceptions about Unicode and UTF-8/16/32 - Daniel Miessler
<https://danielmiessler.com/blog/misconceptions-about-unicode-and-utf-81632/>
> The chart above reveals a misconception about Unicode: the “8” in “UTF-8” 
> doesn’t actually indicate how many bits a code point gets encoded into. 
> The final size of the encoded data is based on two things: a) the code 
> unit size, and b) the number of code units used. So the 8 in UTF-8 stands 
> for the code unit size, not the number of bits that will be used to 
> encode a code point.
> 
> As the chart indicates, UTF-8 can actually store a code point using 
> between one and four bytes. I find it helpful to think of the code unit 
> size as the “granularity level”, or the “building block size” you have 
> available to you. So with UTF-16 you can still only have four bytes 
> maximum, but your code unit size is 16 bits, so your minimum number of 
> bytes is two.

- Flexible and Economical UTF-8 Decoder
<http://bjoern.hoehrmann.de/utf-8/decoder/dfa/>

- Integer ASCII value to character in bash using printf
<https://stackoverflow.com/questions/890262/integer-ascii-value-to-character-in-bash-using-printf>

- Find the best font for rendering a [Unicode] code point
<https://unix.stackexchange.com/questions/162305/find-the-best-font-for-rendering-a-codepoint/393740#393740>

- U+2620 Skull and Crossbones
<https://codepoints.net/U+2620>

- Unicode Check Mark (U+2713) Font Support (U+2713)
<https://www.fileformat.info/info/unicode/char/2713/fontsupport.htm>

- Unicode Character "ỗ" (U+1ED7) - Name: Latin Small Letter O with Circumflex and Tilde
<https://www.compart.com/en/unicode/U+1ED7>

- Unicode Character "顠" (U+9860) - Name: CJK Unified Ideograph-9860
<https://www.compart.com/en/unicode/U+9860>

- Encoding Problem Table
<https://string-functions.com/encodingtable.aspx?encoding=65001&decoding=20127>  
> What happens if you encode a character with one encoding and then try to 
> decode with another? This is often the case when you have a mix of 
> operating systems and/or internationalization requirements.  Also, this 
> tends to be a problem with web frameworks where the code page can be set 
> in the http header or in the http head section.  Selecting the wrong 
> encoding (code page) may display some characters correctly but others 
> will be scrambled.  The first 256 characters in a mixed selection of 
> encodings are displayed below.  Encoding a text with Unicode (UTF-8) and 
> decoding with US-ASCII will sometimes produce strange characters. 
> Characters may display as a box denoting binary data, another character 
> or even several other characters.

- The Universal Coded Character Set (UCS, Unicode) 
<https://en.wikipedia.org/wiki/Universal_Coded_Character_Set>

- Squinting at ASCII on Linux 
<https://www.networkworld.com/article/3244135/squinting-at-ascii-on-linux.html>

- Multilingual form encoding - W3C Internationalization
<https://www.w3.org/International/questions/qa-forms-utf-8>

- Search for Unicode characters 
<https://unicode-search.net/>

- Unicode to Bytes Converter - World's Simplest Unicode Tool 
<https://onlineunicodetools.com/convert-unicode-to-bytes>

- The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!)
<https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/>

- Introduction to Unicode and UTF-8
<https://flaviocopes.com/unicode/>

- UTFs - IBM Db2 for z/OS Documentation
<https://www.ibm.com/docs/en/db2-for-zos/12?topic=unicode-utfs>

- Endianness - IBM Db2 for z/OS Documentation
<https://www.ibm.com/docs/en/db2-for-zos/12?topic=data-endianness>

- UTF-8, UTF-16, UTF-32 & BOM - Unicode.org FAQ
<http://unicode.org/faq/utf_bom.html>

- Forms of Unicode 
<https://icu-project.org/docs/papers/forms_of_unicode/>

- How to find UTF-8 reference of a composite unicode character - Stack Overflow
<https://stackoverflow.com/questions/30733035/how-to-find-utf-8-reference-of-a-composite-unicode-character#30733559>

- Normalization Browser - ICU (International Components for Unicode)  
<https://icu4c-demos.unicode.org/icu-bin/nbrowser>

- Canonically Equivalent Shortest Form
<https://icu.unicode.org/design/normalizing-to-shortest-form>

- Character Normalization in IETF Protocols
<https://datatracker.ietf.org/doc/html/draft-duerst-i18n-norm-04>

- Globalization Gotchas
<http://www.macchiato.com/unicode/globalization-gotchas>

- What is NFC?
<http://www.macchiato.com/unicode/nfc-faq>

- Some gotchas about Unicode that EVERY programmer should know 
<https://nukep.github.io/progblog/2015/02/26/some-gotchas-about-unicode-that-every-programmer-should-know.html#characters-that-appear-the-same-might-not-test-equal>

- Can we use base 16, and not 85, for ASCII charset representations?
<https://lists.freedesktop.org/archives/fontconfig/2013-September/004915.html>

- UTF-8 and Unicode FAQ for Unix/Linux
<https://www.cl.cam.ac.uk/~mgk25/unicode.html>

- In bash, how can I convert a Unicode Code Point [0-9A-F] into a printable character?
<https://unix.stackexchange.com/questions/12273/in-bash-how-can-i-convert-a-unicode-codepoint-0-9a-f-into-a-printable-charact>

- Unicode List of Control characters to paste as seen in Notepad++ re those funny characters
<http://metadataconsulting.blogspot.com/2019/06/Unicode-List-of-Control-characters-to-paste-as-seen-in-Notepad-re-those-funny-characters.html>
