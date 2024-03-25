---
layout: post
title: "ANSI Escape Sequence - Terminals, Shells, Consoles"
date: 2024-02-18 18:34:23 -0700 
categories: ansi ascii cli terminal shell plaintext text ansi
            ascii cli terminal shell console plaintext text 
            it computing history sysadmin rs232serial console 
---

[Escape sequence - Terminal and Printers Handbook Glossary](https://vt100.net/docs/tp83/glossary.html):

```
Escape sequence
A special sequence of ASCII characters beginning with the escape character (ESC) used to send special text-formatting or editing commands to terminals. See also: [ASCII](https://vt100.net/docs/tp83/glossary.html#a09)
```

[Line discipline (LDISC) aka Terminal I/O](https://en.wikipedia.org/wiki/Line_discipline):

```
A line discipline (LDISC) is a layer in the terminal subsystem in some Unix-like systems. 

The terminal subsystem consists of three layers: 
    * the upper layer to provide the character device interface, 
    * the lower hardware driver to communicate with the hardware or pseudo terminal, 
    * the middle line discipline to implement behavior common to terminal devices. 
```


Some Unix-like systems use STREAMS to implement line disciplines:

[STREAMS - the native **framework** in Unix System V for implementing character device drivers, network protocols, and inter-process communication](https://en.wikipedia.org/wiki/STREAMS)


[XTerm Control Sequences - aka ctlseqs - XTerm by Thomas Dickey (invisible-island.net)](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html):

```
Definitions
-----------

Many controls use parameters, shown in italics.  If a control uses a
single parameter, only one parameter name is listed.  Some parameters
(along with separating ;  characters) may be optional.  Other characters
in the control are required.

C    A single (required) character.
Ps   A single (usually optional) numeric parameter, composed of one or
     more digits.
Pm   Any number of single numeric parameters, separated by ;  charac-
     ter(s).  Individual values for the parameters are listed with Ps .
Pt   A text parameter composed of printable characters.


Control Bytes, Characters, and Sequences
----------------------------------------

ECMA-48 (aka "ISO 6429") documents C1 (8-bit) and C0 (7-bit) codes.
Those are respectively codes 128 to 159 and 0 to 31.  ECMA-48 avoids
referring to these codes as characters, because that term is associated
with graphic characters.  Instead, it uses "bytes" and "codes", with
occasional lapses to "characters" where the meaning cannot be mistaken.

Controls (including the **escape code 27**) are processed once:

---- snip ----

C1 (8-Bit) Control Characters
-----------------------------

The xterm program recognizes both 8-bit and 7-bit control characters.

It generates 7-bit controls (by default) or 8-bit if S8C1T is enabled.

The following pairs of 7-bit and 8-bit control characters are equiva-
lent:

---- snip ----
ESC [
     Control Sequence Introducer (CSI  is 0x9b).
---- snip ----
ESC ]
     Operating System Command (OSC  is 0x9d).


---- snip ----


Non-VT100 Modes
---------------
Tektronix 4014 Mode
-------------------

Most of these sequences are standard Tektronix 4014 control sequences.
Graph mode supports the 12-bit addressing of the Tektronix 4014.  The
major features missing are the write-through and defocused modes.  This
document does not describe the commands used in the various Tektronix
plotting modes but does describe the commands to switch modes.

Some of the sequences are specific to xterm.  The Tektronix emulation
was added in X10R4 (1986).  The VT240, introduced two years earlier,
also supported Tektronix 4010/4014.  Unlike xterm, the VT240 documenta-
tion implies (there is an obvious error in section 6.9 "Entering and
Exiting 4010/4014 Mode") that exiting back to ANSI mode is done by
resetting private mode 3 8  (DECTEK) rather than ESC ETX .  A real Tek-
tronix 4014 would not respond to either.

BEL       Bell (Ctrl-G).
BS        Backspace (Ctrl-H).
TAB       Horizontal Tab (Ctrl-I).
LF        Line Feed or New Line (Ctrl-J).
VT        Cursor up (Ctrl-K).
FF        Form Feed or New Page (Ctrl-L).
CR        Carriage Return (Ctrl-M).
ESC ETX   Switch to VT100 Mode (ESC  Ctrl-C).
ESC ENQ   Return Terminal Status (ESC  Ctrl-E).
ESC FF    PAGE (Clear Screen) (ESC  Ctrl-L).
ESC SO    Begin 4015 APL mode (ESC  Ctrl-N).  This is ignored by xterm.
ESC SI    End 4015 APL mode (ESC  Ctrl-O).  This is ignored by xterm.
ESC ETB   COPY (Save Tektronix Codes to file COPYyyyy-mm-dd.hh:mm:ss).
            ETB  (end transmission block) is the same as Ctrl-W.
ESC CAN   Bypass Condition (ESC  Ctrl-X).
ESC SUB   GIN mode (ESC  Ctrl-Z).
ESC FS    Special Point Plot Mode (ESC  Ctrl-\).
ESC 8     Select Large Character Set.
ESC 9     Select #2 Character Set.
ESC :     Select #3 Character Set.
ESC ;     Select Small Character Set.


OSC Ps ; Pt BEL
          Set Text Parameters of VT window.
            Ps = 0  ⇒  Change Icon Name and Window Title to Pt.
            Ps = 1  ⇒  Change Icon Name to Pt.
            Ps = 2  ⇒  Change Window Title to Pt.
            Ps = 4 6  ⇒  Change Log File to Pt.  This is normally 
                         disabled by a compile-time option.
```


### Example: Change XTerm Window Title

Sequence is:  ```OSC Ps ; Pt BEL```

This works in **FreeBSD 12**  
(Shell: **tcsh**; TERM: **xterm-new**; TERMCAP set?: **Yes**; Window Manager: **Fvwm**)


NOTE:

From the man page for ```xterm(1)```:

```
Window and Icon Titles
    Some scripts use echo with options -e and -n to tell the shell to
    interpret the string “\e” as the escape character and to suppress a
    trailing newline on output.  Those are not portable, nor recommended.
    Instead, use printf (POSIX).

    For example, to set the window title to “Hello world!”, you could use
    one of these commands in a script:

        printf '\033]2;Hello world!\033\\'
        printf '\033]2;Hello world!\007'
        printf '\033]2;%s\033\\' "Hello world!"
        printf '\033]2;%s\007' "Hello world!"

    The printf command interprets the octal value “\033” for escape, and
    (since it was not given in the format) omits a trailing newline from
    the output.

    Some programs (such as screen(1)) set both window- and icon-titles at
    the same time, using a slightly different control sequence:

        printf '\033]0;Hello world!\033\\'
        printf '\033]0;Hello world!\007'
        printf '\033]0;%s\033\\' "Hello world!"
        printf '\033]0;%s\007' "Hello world!"

    The difference is the parameter “0” in each command.  Most window
    managers will honor either window title or icon title.  Some will make
    a distinction and allow you to set just the icon title.  You can tell
    xterm to ask for this with a different parameter in the control
    sequence:

        printf '\033]1;Hello world!\033\\'
        printf '\033]1;Hello world!\007'
        printf '\033]1;%s\033\\' "Hello world!"
        printf '\033]1;%s\007' "Hello world!"
```


* **OSC** (Operating System Command (OSC is 0x9d) is:  ```ESC ]```

To be used by ```printf(1)```, OSC is:

```
\033]
```

NOTE:   
ESC = ```033``` in ASCII (in *octal* - because ```printf(1)``` requires it in octal) 

NOTE:   
```printf(1)``` uses a backslash (```\```) for **octal** number representation.


* **Ps** (control for chaning change the window title) is:

```
2
```

* After OSC and Ps controls, the next parameter is the **separating semicolon character**:

```
;
```

* **Pt** (a text parameter composed of printable characters) is:

```
My Window Title
```

* **BEL** is: 

```
\007
``` 

NOTE:  
BEL = ```007``` in ASCII (in *octal* - because ```printf(1)``` requires it in octal) 

NOTE:   
```printf(1)``` uses a backslash (```\```) for **octal** number representation.


```
$ printf '\033]2;My Window Title\007'
```

* [ANSI escape sequences, how to enter escape character from keyboard? [closed]](https://stackoverflow.com/questions/17815836/ansi-escape-sequences-how-to-enter-escape-character-from-keyboard)


"Although using vt escape sequences (as above) is easy and supported by most if not all commonly-used unix terminal emulators, die-hards will insist that you learn to use the ```tput(1)``` command:"

```
printf "Here is a %sbold red%s word\n" "$(tput bold)""$(tput setf 4)" "$(tput sgr0)"
```

"IMHO, figuring out the magic tput symbols (see man 5 terminfo on a debian/ubuntu system) is not as easy as looking up the xterm control sequences (google the last three words), but YMMV".

In my tests, it partially worked in a bhyve VM running Debian GNU/Linux 11 (bullseye) in bash shell: it displayed 'bold' in bold but not 'red' in red colour.  


The following works in **FreeBSD 12** (Shell: **tcsh**; TERM: **xterm-new**; TERMCAP set?: **Yes**; Window Manager: **Fvwm**): 

* With ```bold``` for the capability name (**capname** - the short name used in the text of the terminal capability database): ```tput bold```, ```tput AF```, ```tput me```:

```
$ printf "Here is a \033[0;1mbold %sred %sword \n" `tput bold` `tput AF 1` `tput me`
Here is a bold red word 
```
 
Without zero in the escape sequence (```[;1m``` instead of ```[0;1m```):

```
$ printf "Here is a \033[;1mbold %sred %sword \n" `tput bold` `tput AF 1` `tput me`
Here is a bold red word 
```

With ```%s``` format character for string format in ```printf(1)``` utility (```%s\033[0;1m``` instead of ```\033[0;1m```):

```
$ printf "Here is a %s\033[0;1mbold %sred %sword\n" `tput bold` `tput me` `tput AF 1` `tput me`
Here is a bold red word
```

* With ```md``` for the capability name (**TCap code**) in the text of the terminal capability database: 

```
$ printf "Here is %sa %s\033[0;1mbold %sred %sword\n" `tput md ` `tput me` `tput AF 1` `tput me`
```

Without zero in the escape sequence (```[;1m``` instead of ```[0;1m```):

```
% printf "Here is %sa %s\033[;1mbold %sred %sword\n" `tput md ` `tput me` `tput AF 1` `tput me`
Here is a bold red word
```

Without ```%s``` format character for string format in ```printf(1)``` utility (```Here is a``` instead of ```Here is %sa```): 

```
$ printf "Here is a %s\033[;1mbold %sred %sword\n" `tput md ` `tput AF 1` `tput me`
Here is a bold red word
```

NOTE:   

```tput AF 0```: black, ```tput AF 1```: red, ```tput AF 2```: bright green, ```tput AF 3```: yellow, ```tput AF 4```: blue, ```tput AF 5```: magenta, ```tput AF 6```: cyan, ```tput AF 7```: white
 

From the man page for ```terminfo(5)``` terminal capability database on FreeBSD 12:


```
---- snip ----

Predefined Capabilities
     The following is a complete table of the capabilities included in a
     terminfo description block and available to terminfo-using code.
     In each line of the table,
  
     The variable is the name by which the programmer (at the terminfo
     level) accesses the capability.

     The capname is the short name used in the text of the database, and is
     used by a person updating the database.  Whenever possible, capnames
     are chosen to be the same as or similar to the ANSI X3.64-1979 standard
     (now superseded by ECMA-48, which uses identical or very similar
     names).  Semantics are also intended to match those of the
     specification.

     The termcap code is the old termcap capability name (some capabilities
     are new, and have names which termcap did not originate).
  
     Capability names have no hard length limit, but an informal limit of 5
     characters has been adopted to keep them short and to allow the tabs in
     the source file Caps to line up nicely.

---- snip ----

These are the string capabilities:

   Variable                   Cap-      TCap   Description
    String                    name      Code

---- snip ----

   set_a_foreground           setaf     AF     Set foreground
                                               color to #1, using
                                               ANSI escape

---- snip ----

   exit_attribute_mode        sgr0      me     turn off all
                                               attributes

---- snip ----

     Most color terminals are either “Tektronix-like” or “HP-like”:
  
     *   Tektronix-like terminals have a predefined set of N colors (where N
         is usually 8), and can set character-cell foreground and background
         characters independently, mixing them into N * N color-pairs.
  
     *   On HP-like terminals, the user must set each color pair up
         separately (foreground and background are not independently
         settable).  Up to M color-pairs may be set up from 2*M different
         colors.  ANSI-compatible terminals are Tektronix-like.
  
     Some basic color capabilities are independent of the color method.  The
     numeric capabilities colors and pairs specify the maximum numbers of
     colors and color-pairs that can be displayed simultaneously.  The op
     (original pair) string resets foreground and background colors to their
     default values for the terminal.  The oc string resets all colors or
     color-pairs to their default values for the terminal.  Some terminals
     (including many PC terminal emulators) erase screen areas with the
     current background color rather than the power-up default background;
     these should have the boolean capability bce.

     While the curses library works with color pairs (reflecting the
     inability of some devices to set foreground and background colors
     independently), there are separate capabilities for setting these
     features:
  
     *   To change the current foreground or background color on a
         Tektronix-type terminal, use setaf (set ANSI foreground) and setab
         (set ANSI background) or setf (set foreground) and setb (set
         background).  These take one parameter, the color number.

         The SVr4 documentation describes only setaf/setab; the XPG4 draft
         says that "If the terminal supports ANSI escape sequences to set
         background and foreground, they should be coded as setaf and setab,
         respectively.

     *   If the terminal supports other escape sequences to set background
         and foreground, they should be coded as setf and setb,
         respectively.  The vidputs and the refresh(3X) functions use the
         setaf and setab capabilities if they are defined.
  
     The setaf/setab and setf/setb capabilities take a single numeric
     argument each.  Argument values 0-7 of setaf/setab are portably defined
     as follows (the middle column is the symbolic #define available in the
     header for the curses or ncurses libraries).  The terminal hardware is
     free to map these as it likes, but the RGB values indicate normal
     locations in color space.
  
                  Color       #define       Value       RGB
                  black     COLOR_BLACK       0     0, 0, 0
                  red       COLOR_RED         1     max,0,0
                  green     COLOR_GREEN       2     0,max,0
                  yellow    COLOR_YELLOW      3     max,max,0
                  blue      COLOR_BLUE        4     0,0,max
                  magenta   COLOR_MAGENTA     5     max,0,max
                  cyan      COLOR_CYAN        6     0,max,max
                  white     COLOR_WHITE       7     max,max,max


---- snip ----

Highlighting, Underlining, and Visible Bells
     If your terminal has one or more kinds of display attributes, these can
     be represented in a number of different ways.  You should choose one
     display form as standout mode, representing a good, high contrast,
     easy-on-the-eyes, format for highlighting error messages and other
     attention getters.  (If you have a choice, reverse video plus half-
     bright is good, or reverse video alone.)  The sequences to enter and
     exit standout mode are given as smso and rmso, respectively.  If the
     code to change into or out of standout mode leaves one or even two
     blank spaces on the screen, as the TVI 912 and Teleray 1061 do, then
     xmc should be given to tell how many spaces are left.
  
     Codes to begin underlining and end underlining can be given as smul and
     rmul respectively.  If the terminal has a code to underline the current
     character and move the cursor one space to the right, such as the
     Microterm Mime, this can be given as uc.

     Other capabilities to enter various highlighting modes include blink
     (blinking) bold (bold or extra bright) dim (dim or half-bright) invis
     (blanking or invisible text) prot (protected) rev (reverse video) sgr0
     (turn off all attribute modes) smacs (enter alternate character set
     mode) and rmacs (exit alternate character set mode).  Turning on any of
     these modes singly may or may not turn off other modes.
  
     If there is a sequence to set arbitrary combinations of modes, this
     should be given as sgr (set attributes), taking 9 parameters.  Each
     parameter is either 0 or nonzero, as the corresponding attribute is on
     or off.  The 9 parameters are, in order: standout, underline, reverse,
     blink, dim, bold, blank, protect, alternate character set.  Not all
     modes need be supported by sgr, only those for which corresponding
     separate attribute commands exist.
  
     For example, the DEC vt220 supports most of the modes:
  
             tparm parameter      attribute        escape sequence
  
             none                 none             \E[0m
             p1                   standout         \E[0;1;7m
             p2                   underline        \E[0;4m
             p3                   reverse          \E[0;7m
             p4                   blink            \E[0;5m
             p5                   dim              not available
             p6                   bold             \E[0;1m
             p7                   invis            \E[0;8m
             p8                   protect          not used
             p9                   altcharset       ^O (off) ^N (on)

     We begin each escape sequence by turning off any existing modes, since
     there is no quick way to determine whether they are active.  Standout
     is set up to be the combination of reverse and bold.  The vt220
     terminal has a protect mode, though it is not commonly used in sgr
     because it protects characters on the screen from the host's erasures.
     The altcharset mode also is different in that it is either ^O or ^N,
     depending on whether it is off or on.  If all modes are turned on, the
     resulting sequence is \E[0;1;4;5;7;8m^N.

  
---- snip ----

```

On this system, FreeBSD 12 (Shell: tcsh; TERM: xterm-new; TERMCAP set?: Yes; Window Manager: Fvwm), changing foreground colour works with ```setaf```, that is ```AF```, so the **xterm** on this system is a **Tektronix-type terminal** (see above excerpt from the man page for ```terminfo(5)```).


From Perl Programmers Reference Guide: 

```
$ man Term::ANSIColor
```


[Standard ECMA-48 - Control functions for coded character sets (5th edition) - June 1991 - Reprinted June 1998 -- Ecma International](https://ecma-international.org/publications-and-standards/standards/ecma-48/):

"This Ecma Standard defines control functions and their coded representations for use in a 7-bit code, an extended 7-bit code, an 8-bit code or an extended 8-bit code, if such a code is structured in accordance with Standard [ECMA-35](https://ecma-international.org/publications-and-standards/standards/ecma-35/)."

[Standard ECMA-48 - Control functions for coded character sets (5th edition) - June 1991 - Reprinted June 1998 -- Ecma International - PDF](https://ecma-international.org/wp-content/uploads/ECMA-48_5th_edition_june_1991.pdf)   
ECMA-48, 1st edition, March 1976 (not available), No file available   
ECMA-48, 2nd edition, August 1979, [Download](https://ecma-international.org/wp-content/uploads/ECMA-48_2nd_edition_august_1979.pdf)   
ECMA-48, 3rd edition, March 1984, [Download](https://ecma-international.org/wp-content/uploads/ECMA-48_3rd_edition_march_1984.pdf)   
ECMA-48, 4th edition, December 1986, [Download](https://ecma-international.org/wp-content/uploads/ECMA-48_4th_edition_december_1986.pdf)   


* [Color standards for terminal emulators - Termstandard/Colors Repository -- Terminal Colors (Previously published and discussed at https://gist.github.com/XVilka/8346728)](https://github.com/termstandard/colors)

----

[How do I change the behavior of **clear** on CentOS7 such that it will NOT clear scrollback buffers on xterm?](https://superuser.com/questions/1094599/how-do-i-change-the-behavior-of-clear-on-centos7-such-that-it-will-not-clear)

"The place to look is in the *extended* capabilities, shown using the ```-x``` option of ```infocmp(1M)```, e.g.:

```
$ infocmp -1x | grep E3
```

would show

```
    E3=\E[3J,
```

I used the ```-1``` option to format the output as a single column." 


Further reading:

[Miscellaneous extensions](https://invisible-island.net/ncurses/terminfo.src.html#toc-_Miscellaneous_extensions_)

```
https://invisible-island.net/ncurses/

######## TERMINAL TYPE DESCRIPTIONS SOURCE FILE
#
# This version of terminfo.src is distributed with ncurses and is maintained
# by Thomas E. Dickey (TD).
---- snip ----
```

----


[Course material for Introduction to System Programming (Chapter 4) by Stewart Weiss - Hunter College of CUNY](http://compsci.hunter.cuny.edu/~sweiss/)

UNIX Lecture Notes - Chapter 4: Control of Disk and Terminal I/O - Prof. Stewart Weiss
[http://compsci.hunter.cuny.edu/~sweiss/course_materials/unix_lecture_notes/chapter_04.pdf](http://compsci.hunter.cuny.edu/~sweiss/course_materials/unix_lecture_notes/chapter_04.pdf)

Concepts Covered:   
*File structure table, open file table, file status flags, auto-appending, device files, terminal devices, device drivers, line discipline, termios structure, terminal settings, canonical mode, non-canonical modes, IOCTLs, fcntl, ttyname, isatty, ctermid, getlogin, gethostname, tcgetattr, tcsetattr, tcflush, tcdrain, ioctl.*

"The **control terminal** for a process is the terminal device from which keyboard-related signals may be generated.
For example, if the user presses a ```Ctrl-C``` or ```Ctrl-D``` on terminal ```/dev/pts/2```, all processes that have ```/dev/pts/2```  as their control terminal will receive this signal."

----

[Using printf with escape sequences? - StackExchange](https://unix.stackexchange.com/questions/513447/using-printf-with-escape-sequences) 

"Do you know that printf does not support hex backslash escapes? 
Your code is not portable as it relies on non-POSIX features."

---

[Where is the character escape sequence ```\033[\061m``` documented to mean bold?](https://unix.stackexchange.com/questions/402479/where-is-the-character-escape-sequence-033-061m-documented-to-mean-bold)


MY NOTES:

Convert octal to decimal:

```
$ printf %d\\n 061
49
```

```
Convert octal to hexadecimal:
$ printf %x\\n 061
31
```

----

[What protocol/standard is used by terminals?](https://unix.stackexchange.com/questions/5800/what-protocol-standard-is-used-by-terminals/5802)

ANSI Terminals

"**xterm**: A kind of amalgam of ANSI and the VT-whatever standards. Whenever you're using a GUI terminal emulator like ```xterm``` or one of its derivatives, you're usually also using the ```xterm``` terminal protocol, typically the more modern ```xterm-color``` or ```xterm-color256``` variants.

. . . 

A typical terminal emulator program is something of a mongrel, and doesn't emulate any single terminal model exactly. It might support 96% of all DEC VT escape sequences up through the VT320, yet also support extensions like ANSI color (a VT525 feature) and an arbitrary number of rows and columns. The 4% of codes it doesn't understand may not be missed if your programs don't need those features, even though you've told ```curses``` (or whatever) that you want programs using it to use the VT320 protocol. Such a program might advertise itself as VT320 compatible, then, even though, strictly speaking, it is not."


"AT&T promulgated [terminfo as a replacement for BSD's termcap database](https://en.wikipedia.org/wiki/Terminfo), and it was largely successful in replacing it, but there are still programs out there that still use the old termcap database. It is one of the many BSD vs. AT&T differences you can still find on modern systems.

My macOS box doesn't have ```/etc/termcap```, but it does have ```/usr/share/terminfo```, whereas a standard installation of **FreeBSD** is the opposite way around, even though these two OSes are often quite similar at the command line level.

Properly-written Unix programs don't emit these escape sequences directly. Instead, they use one of the libraries mentioned above, telling it to "move the cursor to position (1,1)" or whatever, and the *library* emits the necessary terminal control codes based on your TERM environment variable setting. This allows the program to work properly no matter what terminal type you run it on.

Old text terminals had a lot of strange features that didn't get a lot of use by programs, so many popular terminal emulator programs simply don't implement these features. Common omissions are support for sixel graphics and double-width/double-height text modes.

The maintainer of xterm wrote a program called vttest for testing VT terminal emulators such as xterm. You can run it against other terminal emulators to find out which features they do not support.
"

----

[Using colors with printf](https://stackoverflow.com/questions/5412761/using-colors-with-printf)  

```
$ printf '\033[1;34m%-6s\033[m' "This is blue text"
This is blue text$ 
```
 
```
$ printf '\033[1;33m%-6s\033[m' "This is yellow text"
This is yellow text$ 
 
$ printf '\033[1;31m%-6s\033[m' "This is red text"
This is red text$ 
```

----

[Pseudo terminal (Pseudoterminal) - Wikipedia](https://en.wikipedia.org/wiki/Pseudoterminal)

"**Variants**   
In the BSD PTY system, the slave device file, which generally has a name of the form ```/dev/tty[p-za-e][0-9a-f]```, supports all *system calls* applicable to *text terminal devices*.  Thus it supports *login sessions*.  *The master device file*, which generally has a name of the form ```/dev/pty[p-za-e][0-9a-f]```, is the endpoint for communication with the terminal emulator.  With this ```[p-za-e]``` naming scheme, there can be at most 256 tty pairs.  Also, finding the first free pty master can be racy unless a locking scheme is adopted.  For that reason, recent BSD operating systems, such as FreeBSD, implement Unix98 PTYs.

BSD PTYs have been rendered obsolete by [Unix98 - Single UNIX Specification](https://en.wikipedia.org/wiki/Single_UNIX_Specification) ptys whose naming system does not limit the number of pseudo-terminals and access to which occurs without danger of race conditions. ```/dev/ptmx``` is the 'pseudo-terminal master multiplexer'.  Opening it returns a file descriptor of a master node and causes an associated slave node ```/dev/pts/N``` to be created."

----

From ```man printf(1)```:

```
       Character escape sequences are in backslash notation as defined in the
       ANSI X3.159-1989 (“ANSI C89”), with extensions.  The characters and their
       meanings are as follows:
  
             \a      Write a <bell> character.
             \b      Write a <backspace> character.
             \c      Ignore remaining characters in this string.
             \f      Write a <form-feed> character.
             \n      Write a <new-line> character.
             \r      Write a <carriage return> character.
             \t      Write a <tab> character.
             \v      Write a <vertical tab> character.
             \´      Write a <single quote> character.
             \\      Write a backslash character.
             \num    Write a byte whose value is the 1-, 2-, or 3-digit octal
                     number num.  Multibyte characters can be constructed using
                     multiple \num sequences.
  
       Each format specification is introduced by the percent character (``%'').
       The remainder of the format specification includes, in the following
       order:
```

So:

```
$ printf %o\\n 65
101
 
$ printf '\101'
A$ 

$ printf '\101 \102 \103 \n'
A B C 


$ printf '\033[9mTest\n\033[\060m' | od -c
0000000  033   [   9   m   T   e   s   t  \n 033   [   0   m            
0000015

$ printf '\033[9mCrossed-out characters.\n\033[\060m'

$ printf '\033[1mBold. VT100\n\033[\060m'
 
$ printf '\033[2mFaint\n\033[\060m'
    
$ printf '\033[3mItalicized\n\033[\060m'

$ printf '\033[4mUnderlined. VT100\n\033[\060m'
 
$ printf '\033[5mBlink. VT100\n\033[\060m'

$ printf '\033[7mInverse\n\033[\060m'

$ printf '\033[8mInvisible (hidden)\n\033[\060m'
                  
$ printf '\033[9mCrossed-out characters.\n\033[\060m'
 
$ printf '\033[21mDoubly-underlined.\n\033[\060m'


$ printf '\033[31mRed foreground.\n\033[\060m'
Red foreground.
 
$ printf '\033[32mGreen foreground.\n\033[\060m'
Green foreground.
 
$ printf '\033[33mYellow foreground.\n\033[\060m'
Yellow foreground.
 
$ printf '\033[34mBlue foreground.\n\033[\060m'
Blue foreground.
 
$ printf '\033[35mMagenta foreground.\n\033[\060m'
Magenta foreground.
```

----


[ANSI Codes and Colorized Terminals](https://www.linux.org/threads/ansi-codes-and-colorized-terminals.11706/)

ANSI codes are embedded byte commands that are read by command-lines to output the text with special formatting or perform some task on the terminal output. The ANSI codes (or escape sequences) may appear as character codes rather than formatting codes. Terminals and terminal-emulators (such as Xterm) support many ANSI codes as well as some vendor-specific codes. Learning about ANSI may help terminal users to understand how it all works and allow developers to make better programs.

Control Characters (C0 and C1 Control Codes) are not the same as ANSI codes. Control characters are the commonly used CTRL+button combinations used in a terminal such as CTRL+C, CTRL+Z, CTRL+D, etc. In terminals, control characters may appear as "^C" (for "CTRL+C") in the terminal output. For instance, in a terminal, press CTRL+C and then users will see "^C" in the terminal. The CTRL button provides a way to input the ESC character.

NOTE: The “ESC character” is not the same as the “ESC key”.

ANSI codes begin with the ESC character which appears as a carat (^) in terminals. The ESC character is then followed by ASCII characters which specifically tell the terminal what to do or how to display text. The ASCII character after the ESC character may be in the ASCII range "@" to "_" (64-95 ASCII decimal). However, more possibilities are available when using the two-character escape such as the carat and bracket (^[) which is known as the Control Sequence Introducer (CSI). CSI codes use "@" to "~" (64-126 ASCII decimal) after the escape. In ASCII hexadecimal, the ESC character is 0x1B or 33 in octal.

NOTE: The carat character is not the ESC character. Terminals use the carat symbol to display or represent the ESC character.

In a terminal, to type the CSI, type "\e[". The "\e" acts as the ESC character and the "[" is the rest of the CSI. After typing the CSI, type the ASCII sequence needed to generate the desired output. For instance, in Xterm, typing "echo -e \\e[S" will scroll the screen/output up one line. To scroll up more lines, place a number before the "S" which will act as a parameter - "echo -e \\e[5S".



MY NOTE:
However in FreeBSD 12.x (tcsh shell, TERM = xterm-new, TERMCAP set?: Yes):

```
$ ps $$
  PID TT  STAT    TIME COMMAND
95398  5  Ss   0:01.19 -tcsh (tcsh)

$ printf %s\\n "$SHELL"
/bin/tcsh

$ printf %s\\n "$TERM"
xterm-new
 
$ echo -e \\e[S
-e \e[S

$ set | grep echo
echo_style      bsd
 
$ set echo_style = both

$ set | grep echo
echo_style      both
 
$ echo -e \\e[S
-e 

$ echo \\e[S
```

And, similarly:

```
$ echo \\e[H\e[2J

$ printf '\033[H\033[2J'
```

----

From 
[STREAMS - Wikipedia](https://en.wikipedia.org/wiki/STREAMS):

> In computer networking, **STREAMS** is the native framework in *Unix System V* for implementing *character device* drivers, network protocols, and *inter-process communication*.
> In this framework, a stream is a chain of *coroutines* that *pass messages* between a program and a device driver (or between a pair of programs). STREAMS originated in *Version 8 Research Unix*, as Streams (not capitalized). 
> 
> STREAMS's design is a modular architecture for implementing full-duplex *I/O* between kernel and device drivers.
> Its most frequent uses have been in developing terminal I/O (*line discipline*) and networking subsystems.
> In System V Release 4, the entire terminal interface was reimplemented using STREAMS.
> An important concept in STREAMS is the ability to push drivers - custom code modules which can modify the functionality of a network interface or other device - together to form a stack.
> Several of these drivers can be chained together in order. 
> 
> ...
> 
> The actual Streams modules live in *kernel space* on Unix, and are installed (pushed) and removed (popped) by the ioctl system call. 
> 
> ... 
> 
> To perform input/output on a stream, one either uses the ```read``` and ```write``` *system calls* as with regular *file descriptors*, or a set of STREAMS-specific functions to send control messages.
> 
> Ritchie admitted to regretting having to implement Streams in the kernel, rather than as processes, but felt compelled to do for reasons of efficiency.
> A later *Plan 9* implementation did implement modules as user-level processes.
>
> ...
> 
> ### Implementations
> 
> ...
> 
> FreeBSD has basic support for STREAMS-related system calls, as required by SVR4 binary compatibility layer.   

----

From
[vt100.net - Terminals and Printers Handbook 1983-84 -- Glossary -- Appendix A -- ASCII Codes](https://vt100.net/docs/tp83/appendixa.html):

"Both seven- and eight-bit ASCII codes are referenced here, as well as special graphics sets."

```
7-Bit ASCII Code

---- snip ----

Control Characters 
---- snip ----
Char  Octal  Binary
ESC     033  0011011
---- snip ----
```

----


```
Control Characters

+--------+-----------+-------+-------------------------------------+
| Name   | Character | Octal | Function                            |
|        | Mnemonic  | Code  |                                     |
| ---- snip ----     |       |                                     |
+--------------------+-------+-------------------------------------+
| Escape | ESC       | 033   | Processed as a sequence introducer. |
| ---- snip ----     |       |                                     |
+--------+-----------+-------+-------------------------------------+
```

----

From
[vt100.net - Letterprinter 100 Programming Reference Summary - Terminals and Printers Handbook 1983-84 -- Appendix G:](https://vt100.net/docs/tp83/appendixg.html)

```
Programmer Information
======================

Standard Character Set
----------------------

C0 Control Characters 
---------------------

+--------+----------+-------+-------------------------------------+
| Name   | Mnemonic | Octal | Function                            |
|        |          | Code  |                                     |
| ---- snip ----    |       |                                     |
+-------------------+-------+-------------------------------------+
| Escape | ESC      | 033   | Introduces an escape sequence.      |
|        |          |       | When executed in graphics mode      |
|        |          |       | causes the terminal to exit and     |
|        |          |       | start processing the sequence.      |
| ---- snip ----    |       |                                     |
+--------+----------+-------+-------------------------------------+

Graphics    Mode C0   Control Characters
----------------------------------------

+------------+----------+-------+---------------------------------------------+
| Name       | Mnemonic | Octal | Function                                    |
|            |          | Code  |                                             |
+------------+----------+-------+---------------------------------------------+
| Cancel     | CAN      | 030   |Immediately causes an exit from graphics mode|
+------------+----------+-------+---------------------------------------------+
| Substitute | SUB      | 032   |SUB is processed as a one column space       |
+------------+----------+-------+---------------------------------------------+
| Escape     | ESC      | 033   |Causes the terminal to exit graphics mode and|
|            |          |       |start processing the sequence                |
+------------+----------+-------+---------------------------------------------+

---- snip ----

Escape and Control Sequences
-----------------------------

Note: V2 microcode supports the use of 8-bit characters to replace certain 7-bit sequences.

8-Bit Character [*] Equivalents for 7-Bit Escape Sequences 
----------------------------------------------------------


+-----------------+---------------+-----------------------------+
| 7-Bit           | 8-Bit         | Function                    |
| Sequence        | Character [*] |                             |
|                 |               |                             | 
|  Octal          |       Octal   |                             |
+-----------------+---------------+-----------------------------+
|                 |               |                             |
| ---- snip ----  |               |                             |
|                 |               |                             |
| ESC [  033 133  =  CSI  233     | Control sequence introducer |
|                 |               |                             | 
| ---- snip ----  |               |                             |
+-----------------+---------------+-----------------------------+

[*] V.2. only
```

----

From  
*Using csh & tcsh*   
By: Paul DuBois  
Publisher: O'Reilly Media, Inc.  
Publication Date: **July 1, 1995**  
Print ISBN-13: 978-1-56592-132-0  

> Preface
> 
> A **shell** is a **command interpreter**.
> You type commands into a shell, and the shell passes them to the computer for execution.
> UNIX systems usually provide several shell choices.
> This handbook focuses on two of the shells: C shell (*csh*) and an enhanced C shell (*tcsh*).
> 
> C shell (*csh*), a popular command interpreter that has its origins in Berkeley UNIX, is particularly suited for interactive use.
> It offers many features, including an ability to recall and modify previous commands, a facility for creating command shortcuts, shorthand notation for pathnames to home directories, and job control.
> 
> *tcsh*, an enhanced version of *csh*, is almost entirely upward compatible with csh, so whatever you know about the C shell you can apply immediately to *tcsh*.
> But *tcsh* goes beyond *csh*, adding capabilities like a general purpose command line editor, spelling correction, and programmable command, file, and user name completion.
> 
> Shells other than *csh* and *tcsh* may be available on your system.
> The two most significant examples are the Bourne shell (*sh*) and the Korn shell (*ksh*).
> The Bourne shell is the oldest of the currently popular shells and is the most widely available.
> The Korn shell was developed at AT&T and is most prevalent on System V-based UNIX systems.
> Both shells are fully documented elsewhere, so we won't deal with them here.
> 
> ...
> 
> Another reason for emphasizing interactive use over scripting is that *csh* and *tcsh* **not good shells for writing scripts** (Appendix C, Other Sources of Information, references a document that describes why).
> *sh* or *perl* are better for writing scripts, so there is little reason to discuss doing so with *csh* or *tcsh*. 


> *Using csh & tcsh* - Chapter 5. Setting Up Your Terminal
> 
> Identifying Your Terminal Settings
> 
> *stty* displays your current terminal settings.
> Its options vary from system to system, but at least one of the following command lines should produce output identifying several important terminal control functions and the characters you type to perform them:
> 
```
% stty -a
% stty all
% stty everything
```
> 
> In the output, look for something like this:
> 
```
erase kill werase rprnt flush lnext susp intr quit stop  eof
^?    ^U   ^W     ^R    ^O    ^V    ^Z   ^C   ^\   ^S/^Q ^D
```
>
> Or like this:
> 
```
intr = ^c; quit = ^\; erase = ^?; kill = ^u; eof = ^d; start = ^q;
stop = ^s; susp = ^z; rprnt = ^r; flush = ^o; werase = ^w; lnext = ^v;
```
>
> The words ```erase```, ```kill```, etc., indicate **terminal control functions**.
> The ```^c``` sequences indicate the characters that perform the functions.
> For example, ```^u``` and ```^U``` represent ```CTRL-U```, and ```^?``` represents the DEL character.
> 
> ...
> 
> Footnote [6]: By **terminal**, I mean a **keyboard-display combination**.
> The display could be the screen of a real terminal, an *xterm* window running under X, or a screen managed by a terminal emulation program, running on a microcomputer.

---

From  
*Using csh & tcsh*   
By: Paul DuBois  
Publisher: O'Reilly Media, Inc.  
Publication Date: **July 1, 1995**  
Print ISBN-13: 978-1-56592-132-0  


> *Using csh & tcsh* - Chapter 5. What the Settings Mean
> 
> There are many special keys on your terminal; the most important are those that per form the ```erase```, ```kill```, ```werase```, ```rprnt```, ```lnext```, ```stop```, ```start```, ```intr```, ```susp```, and ```eof``` functions.
> 
> Line Editing Settings
> 
> The ```erase```, ```kill```, ```werase```, ```rprnt```, and ```lnext``` characters let you do simple *editing of the current command line*.
> (Some systems do not support ```werase``` or ```rprnt```.)
> If you use *tcsh*, you also have access to a *built-in general purpose editor*, described in Chapter 7, The tcsh Command-Line Editor.
>
> ...
> 
> 
> ```lnext```
> The ```lnext``` (literal-next) character lets you type characters into the command line that would otherwise be interpreted immediately.
> For instance, in *tcsh*, ```TAB``` triggers filename completion.
> To type a literal ```TAB``` into a command, type the ```lnext``` character first.
> The ```lnext``` character is usually ```CTRL-V```.

---

From  
*Using csh & tcsh*   
By: Paul DuBois  
Publisher: O'Reilly Media, Inc.  
Publication Date: **July 1, 1995**  
Print ISBN-13: 978-1-56592-132-0  


> *Using csh & tcsh* - Chapter 11. Quoting and Special Characters
> 
> This chapter describes how to quote special characters when you need to type them in a command line, as happens when a filename contains a space, ```&```, or ```*```.
> 
> Special Characters
> 
> The shell normally assigns special meanings to several characters (see Table 11-1).
> As you gain experience with the shell and learn these meanings, the fact that these characters are not interpreted literally tends to become a fact you take for granted.
> For example, after you know that ```&``` signifies background execution and begin to use it accordingly, the convention becomes second-nature -- part of your repertoire of shell-using skills.
> 
> However, this set of skills is incomplete unless you also know how to use special characters literally, because sometimes you need to turn off their special meanings.
> 
> ...
> 
> The Shell's Quote Characters
> 
> Four characters are used for quoting.
> They turn off (or "escape") special character meanings:
> * A backslash (```\```) turns off the special meaning of the following character.
> * Single quotes (```'```...```'```) turn off the special meaning of the characters between the quotes, except that ```!event``` still indicates history substitution.
> * Double quotes (```"```...```"```) turn off the special meaning of the characters between the quotes, except that ```!event```, ```$var```, and ``` `cmd` ``` still indicate history, variable, and command substitution.
> (You can think of double quotes as being "weaker" than single quotes because they turn off fewer special characters.)
> * The ```lnext``` ("literal next") character turns off the special meaning of the following character.
> (The ```lnext``` character is usually ```CTRL-V```.
> See *Chapter 5, Setting Up Your Terminal*, for more information.)
> [NOTE] This character can be used with special characters that are otherwise interpreted as soon as they are typed. For example, in *tcsh* a ```TAB``` triggers filename completion; therefore, you cannot type a literal TAB unless you precede it with ```CTRL-V```.
>
> ...
> 
> *Using csh & tcsh* - Chapter 11. Quoting and Special Characters
> 
> Quoting Oddities
> 
> The quoting rules have a few exceptions.
> You probably won't run into these often, but it's good to be aware of them:
> 
> ...
> 

----

From  
*Unix in a Nutshell, 4th Edition*  
By: Arnold Robbins  
Publisher: O'Reilly Media, Inc.  
Publication Date: **October 26, 2005**  

> Chapter 2. Unix Commands 
>
> ...
> 
> 2.2. Alphabetical Summary of Common Commands > stty
>
> This list describes the commands that are common to two or more of Solaris, GNU/Linux, and Mac OS X.
> It also includes many programs available from the Internet that may not come "out of the box" on all the systems.
> 
> On Solaris, many of the Free Software and Open Source programs described here may be found in ```/usr/sfw/bin``` or ```/opt/sfw/bin```.
> Interestingly, the Intel version of Solaris has more programs in ```/opt/sfw/bin``` than does the SPARC version.
> As mentioned earlier, on Solaris, we recommend placing ```/usr/xpg6/bin``` and ```/usr/xpg4/bin``` in your PATH before ```/usr/bin```.
>
> ...
> 
> Name
> 
> ```stty```
> 
> Synopsis
> 
> ```stty [options] [modes]```
>
> Set terminal I/O options for the current device. 
> Without options, ```stty``` reports the terminal settings, where a ```^``` indicates the **Control** key, and ```^'``` indicates a **null value**.
> Most modes can be switched using an optional preceding ```-``` (shown in brackets). 
> The corresponding description is also shown in brackets. 

----

From the man page for ```tcsh(1)``` on FreeBSD:  

```
sequence-lead-in (arrow prefix, meta prefix, ^X)
        Indicates that the following characters are part of a multi-key
        sequence.  Binding a command to a multi-key sequence really
        creates two bindings: the first character to sequence-lead-in
        and the whole sequence to the command.  All sequences beginning
        with a character bound to sequence-lead-in are effectively
        bound to undefined-key unless bound to another command.
```

From the man page for ```tcsh(1)``` on FreeBSD:  
> Control characters in key can be **literal** (they can be typed by preceding them with the editor command **quoted-insert**, normally bound to ```^V```) or written **caret-character style**, e.g., ```^A```.
> Delete is written ```^?``` (caret-question mark).  
> *key* and *command* can contain backslashed escape sequences (in the style of
System V echo(1)) as follows:

```
  \a      Bell
  \b      Backspace
  \e      Escape
  \f      Form feed
  \n      Newline
  \r      Carriage return
  \t      Horizontal tab
  \v      Vertical tab
  \nnn    The ASCII character corresponding to the octal
          number nnn

  `\' nullifies the special meaning of the following character,
  if it has any, notably `\' and `^'.
```

```
---- snip ----
REFERENCE
       The next sections of this manual describe all of the available Builtin
       commands, Special aliases and Special shell variables.

   Builtin commands

---- snip ----
       bindkey [-l|-d|-e|-v|-u] (+)
       bindkey [-a] [-b] [-k] [-r] [--] key (+)
       bindkey [-a] [-b] [-k] [-c|-s] [--] key command (+)
               Without options, the first form lists all bound keys and the
               editor command to which each is bound, the second form lists
               the editor command to which key is bound and the third form
               binds the editor command command to key.  Options include:
---- snip ----
             -b  key is interpreted as a control character written
                   ^character (e.g., `^A') or C-character (e.g., `C-A'), a
                   meta character written M-character (e.g., `M-A'), a
                   function key written F-string (e.g., `F-string'), or an
                   extended prefix key written X-character (e.g., `X-A').

```


From the man page for ```tcsh(1)``` on FreeBSD:  

> Control characters can be written either in C-style-escaped notation, or in stty-like ^-notation.
> 
> The C-style notation adds ```^[``` for **Escape**, ```_``` for a **normal space character**, and ```?``` for **Delete**.
> In addition, the ```^[``` escape character can be used to override the default interpretation of ```^[```, ```^```, ```:``` and ```=```.

----

From 
[POSIX terminal interface - Wikipedia](https://en.wikipedia.org/wiki/POSIX_terminal_interface)  
>
> History > [BSD: the advent of job control](https://en.wikipedia.org/wiki/POSIX_terminal_interface#BSD:_the_advent_of_job_control)
> 

See also:  
[Job control (Unix) - POSIX terminal interface - Wikipedia((https://en.wikipedia.org/wiki/POSIX_terminal_interface#Job_control)

> With the BSD Unices came *job control*, and a *new terminal driver* with extended capabilities.
> These extensions comprised additional (again programmatically modifiable) special characters:
> 
> * The "suspend" and "delayed suspend" characters (by default ```Control```+```Z``` and ```Control```+```Y``` -- ASCII ```SUB``` and ```EM```) caused the generation of a new *SIGTSTP* signal to processes in the terminal's controlling process group.
> * The "word erase", "literal next", and "reprint" characters (by default ```Control```+```W```, ```Control```+```V```, and ```Control```+```R``` -- ASCII ```ETB```, ```SYN```, and ```DC2```) performed additional line editing functions.
> "word erase" erased the last word at the end of the line editing buffer. "literal next" allowed any special character to be entered into the line editing buffer (a function available, somewhat inconveniently, in Seventh Edition Unix via the backslash character).
> "reprint" caused the line discipline to reprint the current contents of the line editing buffer on a new line (useful for when another, background, process had generated output that had intermingled with line editing).
> 
> The programmatic interface for querying and modifying all of these extra modes and control characters was still the ioctl() system call, which its creators (Leffler et al. 1989, p. 262) described as a "rather cluttered interface".
> All of the original Seventh Edition Unix functionality was retained, and the new functionality was added via additional ```ioctl()``` operation codes, resulting in a programmatic interface that had clearly grown, and that presented some duplication of functionality. 
> 

----

[An annotated history of some character codes - or - ASCII: American Standard Code for Information Infiltration - by Tom Jennings](https://www.sensitiveresearch.com/Archive/CharCodeHist/index.html)  
(Retrieved on Feb 18, 2024)   
Most recently revised 12 April 2023 (typos and mention stunt box), previously revised 05 February 2020, previously revised 20 April 2016   
Revision history:   
[https://www.sensitiveresearch.com/Archive/CharCodeHist/index.html#REVHIST](https://www.sensitiveresearch.com/Archive/CharCodeHist/index.html#REVHIST)


[ASCII-1963](https://www.sensitiveresearch.com/Archive/CharCodeHist/index.html#ASCII-1963)[^1] 


[American Standard Code for Information Interchange (ASCII) - WPS (World Power Systems):Projects:History of character codes: ASA standard X3.4-1963 (scanned and archived copy)](http://web.archive.org/web/20131104114603/http://www.wps.com/projects/codes/X3.4-1963/index.html)

(Original: *http://www.wps.com/projects/codes/X3.4-1963/index.html*)

[ASCII - ASA standard X3.4-1963 -- Page 5. Information Interchange: 1. Scope, 2. Standard Code, 3. Positional Order and Notation, 4. Legend](http://web.archive.org/web/20131104195533/http://www.wps.com/projects/codes/X3.4-1963/page5.JPG)

(Original: *http://www.wps.com/projects/codes/X3.4-1963/page5.JPG*)

![ASCII Standard Code Table](/assets/img/ascii-standard-code-table.jpg "ASCII Standard Code Table")

----

[ASCII - Wikipedia](https://en.wikipedia.org/wiki/ASCII)

> Overview
> 
> ASCII was developed in part from *telegraph code*.
> Its first commercial use was in the *Teletype Model 33* and the Teletype Model 35 as a seven-bit teleprinter code promoted by Bell data services.
> Work on the ASCII standard began in *May 1961*, with the first meeting of the American Standards Association's (*ASA*) (now the *American National Standards Institute* or *ANSI*) X3.2 subcommittee.
> The *first edition* of the standard was published in **1963**, underwent a major revision during *1967*, and experienced its most recent update during *1986*.
> Compared to earlier telegraph codes, the proposed Bell code and ASCII were both ordered for more convenient sorting (i.e., alphabetization) of lists and added features for devices other than teleprinters.
>
> The use of ASCII format for **Network Interchange** was described in 1969.
> That document was *formally elevated* to an *Internet Standard* in **2015**.
> 
> Originally based on the (modern) English alphabet, ASCII encodes 128 specified *characters* into *seven-bit integers* as shown by the ASCII chart in this article:    
> [RFC 4949 - Internet Security Glossary, Version 2 - Dr. Robert W. Shirey (August 2007)](https://datatracker.ietf.org/doc/html/rfc4949)   
> **Ninety-five** of the encoded characters are **printable**: these include the digits 0 to 9, lowercase letters a to z, uppercase letters A to Z, and punctuation symbols.
> In addition, the original ASCII specification included **33 non-printing control codes** which originated with *Teletype models*; most of these are now obsolete, (see note below 'From *Digital Electronics: Principles, Devices and Applications*') although a few are still commonly used, such as the *carriage return*, *line feed*, and *tab* codes.
> 
> For example, lowercase ```i``` would be represented in the ASCII encoding by *binary* 1101001 = *hexadecimal* 69 (i is the ninth letter) = *decimal* 105. 

----

From
*Digital Electronics: Principles, Devices and Applications*   
By: Anil K. Maini   
Published By: Wiley (John Wiley & Sons, Inc.)   
Publication Date: September 2007  

> Chapter 2. Binary Codes
>
> 2.4.1 ASCII code
> 
> The ASCII (American Standard Code for Information Interchange), pronounced 'ask-ee', is strictly a seven-bit code based on the English alphabet.
> ASCII codes are used to represent alphanumeric data in computers, communications equipment and other related devices.
> The code was first published as a *standard* in **1967**.
> It was subsequently updated and published as *ANSI X3.4-1968*, then as *ANSI X3.4-1977* and finally as *ANSI X3.4-1986*.
> Since it is a seven-bit code, it can at the most represent 128 characters.
> It currently defines 95 printable characters including 26 upper-case letters (A to Z), 26 lower-case letters (a to z), 10 numerals (0 to 9) and 33 special characters including mathematical symbols, punctuation marks and space character.
> In addition, it defines codes for 33 nonprinting, **mostly obsolete control characters** that affect how text is processed.
> With the exception of 'carriage return' and/or 'line feed', all other characters have been rendered obsolete by modern mark-up languages and communication protocols, the shift from text-based devices to graphical devices and the elimination of teleprinters, punch cards and paper tapes.
> An *eight-bit* version of the ASCII code, known as *US ASCII-8* or *ASCII-8*, has also been developed.
> The eight-bit version can represent a maximum of 256 characters.
> 
> 
> Table 2.6 lists the ASCII codes for all 128 characters.
> When the ASCII code was introduced, many computers dealt with eight-bit groups (or bytes) as the smallest unit of information.
> The eighth bit was commonly used as a parity bit for error detection on communication lines and other device-specific functions.
> Machines that did not use the parity bit typically set the eighth bit to '0'.
> 
> 
> Table 2.6 ASCII code
> 

![ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 1 of 4](/assets/img/asci-code-table-001.jpg "ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 1 of 4")

![ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 2 of 4](/assets/img/asci-code-table-002.jpg "ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 2 of 4")

![ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 3 of 4](/assets/img/asci-code-table-003.jpg "ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 3 of 4")

![ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 4 of 4](/assets/img/asci-code-table-004.jpg "ASCII Standard Code Table - From Digital Electronics: Principles, Devices and Applications - Part 4 of 4")

> Looking at the structural features of the code as reflected in Table 2.6, we can see that the digits 0 to 9 are represented with their binary values prefixed with 0011.
> That is, numerals 0 to 9 are represented by binary sequences from 0011 0000 to 0011 1001 respectively.
> Also, lower-case and upper-case letters differ in bit pattern by a single bit.
> While upper-case letters 'A' to 'O' are represented by 0100 0001 to 0100 1111, lower-case letters 'a' to 'o' are represented by 0110 0001 to 0110 1111.
> Similarly, while upper-case letters 'P' to 'Z' are represented by 0101 0000 to 0101 1010, lower-case letters 'p' to 'z' are represented by 0111 0000 to 0111 1010.

----

On FreeBSD, you can see the ASCII chart (ASCII table, aka ASCII character sets) by referring to the man page for ```ascii(7)```. 

```
$ man ascii

ASCII(7)           FreeBSD Miscellaneous Information Manual           ASCII(7)

NAME
     ascii – octal, hexadecimal, decimal and binary ASCII character sets

DESCRIPTION
     The octal set:

     000 NUL  001 SOH  002 STX  003 ETX  004 EOT  005 ENQ  006 ACK  007 BEL
     010 BS   011 HT   012 LF   013 VT   014 FF   015 CR   016 SO   017 SI
     020 DLE  021 DC1  022 DC2  023 DC3  024 DC4  025 NAK  026 SYN  027 ETB
     030 CAN  031 EM   032 SUB  033 ESC  034 FS   035 GS   036 RS   037 US
     040 SP   041  !   042  "   043  #   044  $   045  %   046  &   047  '
     050  (   051  )   052  *   053  +   054  ,   055  -   056  .   057  /
     060  0   061  1   062  2   063  3   064  4   065  5   066  6   067  7
     070  8   071  9   072  :   073  ;   074  <   075  =   076  >   077  ?
     100  @   101  A   102  B   103  C   104  D   105  E   106  F   107  G
     110  H   111  I   112  J   113  K   114  L   115  M   116  N   117  O
     120  P   121  Q   122  R   123  S   124  T   125  U   126  V   127  W
     130  X   131  Y   132  Z   133  [   134  \   135  ]   136  ^   137  _
     140  `   141  a   142  b   143  c   144  d   145  e   146  f   147  g
     150  h   151  i   152  j   153  k   154  l   155  m   156  n   157  o
     160  p   161  q   162  r   163  s   164  t   165  u   166  v   167  w

---- snip ----
```

----

From the man page for ```termios(4)``` on FreeBSD 13:

```
---- snip ----
The following special characters are extensions defined by this system
and are not a part of IEEE Std 1003.1 (“POSIX.1”) termios.

---- snip ----

  LNEXT   Special character on input and is recognized if the IEXTEN flag
          is set.  Receipt of this character causes the next character to
          be taken literally.

---- snip ----

Local Modes
  Values of the c_lflag field describe the control of various functions,
  and are composed of the following masks.

        ECHOKE      /* visual erase for line kill */
        ECHOE       /* visually erase chars */
        ECHO        /* enable echoing */
        ECHONL      /* echo NL even if ECHO is off */
        ECHOPRT     /* visual erase mode for hardcopy */
        ECHOCTL     /* echo control chars as ^(Char) */

---- snip ----

  If ECHOCTL is set, the system echoes control characters in a visible
  fashion using a **caret** followed by the **control character**.

---- snip ----

Special Control Characters
  The special control characters values are defined by the array c_cc.
  This table lists the array index, the corresponding special character,
  and the system default value.  For an accurate list of the system
  defaults, consult the header file <sys/ttydefaults.h>.

        Index Name    Special Character    Default Value
        VEOF          EOF                  ^D
        VEOL          EOL                  _POSIX_VDISABLE
        VEOL2         EOL2                 _POSIX_VDISABLE
        VERASE        ERASE                ^? ‘\177’
        VWERASE       WERASE               ^W
        VKILL         KILL                 ^U
        VREPRINT      REPRINT              ^R
        VINTR         INTR                 ^C
        VQUIT         QUIT                 ^\\ ‘\34’
        VSUSP         SUSP                 ^Z
        VDSUSP        DSUSP                ^Y
        VSTART        START                ^Q
        VSTOP         STOP                 ^S
        VLNEXT        LNEXT                ^V
        VDISCARD      DISCARD              ^O
        VMIN          ---                  1
        VTIME         ---                  0
        VSTATUS       STATUS               ^T

---- snip ----

  The initial values of the flags and control characters after open() is
  set according to the values in the header <sys/ttydefaults.h>.

SEE ALSO
     stty(1), tcgetsid(3), tcgetwinsize(3), tcsendbreak(3), tcsetattr(3),
     tcsetsid(3), tty(4), stack(9)
```


```
$ wc -l /usr/include/sys/ttydefaults.h
     112 /usr/include/sys/ttydefaults.h
``` 
 
```
$ cat /usr/include/sys/ttydefaults.h
/*-
 * SPDX-License-Identifier: BSD-3-Clause
 *
---- snip ----
 *
 *      @(#)ttydefaults.h       8.4 (Berkeley) 1/21/94
 */

/*
 * System wide defaults for terminal state.
 */
#ifndef _SYS_TTYDEFAULTS_H_
#define _SYS_TTYDEFAULTS_H_

/*
 * Defaults on "first" open.
 */
#define TTYDEF_IFLAG    (BRKINT | ICRNL | IMAXBEL | IXON | IXANY)
#define TTYDEF_OFLAG    (OPOST | ONLCR)
#define TTYDEF_LFLAG_NOECHO (ICANON | ISIG | IEXTEN)
#define TTYDEF_LFLAG_ECHO (TTYDEF_LFLAG_NOECHO \
        | ECHO | ECHOE | ECHOKE | ECHOCTL)
#define TTYDEF_LFLAG TTYDEF_LFLAG_ECHO
#define TTYDEF_CFLAG    (CREAD | CS8 | HUPCL)
#define TTYDEF_SPEED    (B9600)

/*
 * Control Character Defaults
 */
/*
 * XXX: A lot of code uses lowercase characters, but control-character
 * conversion is actually only valid when applied to uppercase
 * characters. We just treat lowercase characters as if they were
 * inserted as uppercase.
 */
#define CTRL(x) ((x) >= 'a' && (x) <= 'z' ? \
        ((x) - 'a' + 1) : (((x) - 'A' + 1) & 0x7f))
#define CEOF            CTRL('D')
#define CEOL            0xff            /* XXX avoid _POSIX_VDISABLE */
#define CERASE          CTRL('?')
#define CERASE2         CTRL('H')
#define CINTR           CTRL('C')
#define CSTATUS         CTRL('T')
#define CKILL           CTRL('U')
#define CMIN            1
#define CQUIT           CTRL('\\')
#define CSUSP           CTRL('Z')
#define CTIME           0
#define CDSUSP          CTRL('Y')
#define CSTART          CTRL('Q')
#define CSTOP           CTRL('S')
#define CLNEXT          CTRL('V')
#define CDISCARD        CTRL('O')
#define CWERASE         CTRL('W')
#define CREPRINT        CTRL('R')
#define CEOT            CEOF
/* compat */
#define CBRK            CEOL
#define CRPRNT          CREPRINT
#define CFLUSH          CDISCARD

/* PROTECTED INCLUSION ENDS HERE */
#endif /* !_SYS_TTYDEFAULTS_H_ */

/*
 * #define TTYDEFCHARS to include an array of default control characters.
 */
#ifdef TTYDEFCHARS

#include <sys/cdefs.h>
#include <sys/_termios.h>

static const cc_t ttydefchars[] = {
        CEOF, CEOL, CEOL, CERASE, CWERASE, CKILL, CREPRINT, CERASE2, CINTR,
        CQUIT, CSUSP, CDSUSP, CSTART, CSTOP, CLNEXT, CDISCARD, CMIN, CTIME,
        CSTATUS, _POSIX_VDISABLE
};
_Static_assert(sizeof(ttydefchars) / sizeof(cc_t) == NCCS,
    "Size of ttydefchars does not match NCCS");

#undef TTYDEFCHARS
#endif /* TTYDEFCHARS */
```


```
$ grep CTRL /usr/include/sys/ttydefaults.h | grep V
#define CLNEXT          CTRL('V')
```

----


From
[Things Every Hacker Once Knew - Eric S. Raymond (esr)](http://www.catb.org/esr/faqs/things-every-hacker-once-knew/):    
(Retrieved on Feb 18, 2024)  

> **36-bit machines and the persistence of octal**
>
> There's a power-of-two size hierarchy in memory units that we now think of as normal - 8 bit bytes, 16 or 32 or 64-bit words.
> But this did not become effectively universal until after 1983.
> There was an earlier tradition of designing computer architectures with 36-bit words.
> There was a time when 36-bit machines loomed large in hacker folklore and some of the basics about them were ubiquitous common knowledge, though cultural memory of this era began to fade in the early 1990s.
> Two of the best-known 36-bitters were the DEC PDP-10 and the Symbolics 3600 Lisp machine.
> The cancellation of the PDP-10 in '83 proved to be the death knell for this class of machine, though the 3600 fought a rear-guard action for a decade afterwards.
> 
> Hexadecimal is a natural way to represent raw memory contents on machines with the power-of-two size hierarchy.
> But octal (base-8) representations of machine words were common on 36-bit machines, related to the fact that a 36-bit word naturally divides into 12 3-bit fields naturally represented as octal.
> In fact, back then we generally assumed you could tell which of the 32- or 36-bit phyla a machine belonged in by whether you could see digits greater than 7 in a memory dump.
>
> It used also to be generally known that 36-bit architectures explained some unfortunate features of the C language.
> The original Unix machine, the PDP-7, featured 18-bit words corresponding to half-words on larger 36-bit computers.
> These were more naturally represented as six octal (3-bit) digits.
> 
> The immediate ancestor of C was an interpreted language written on the PDP-7 and named B.
> In it, a numeric literal beginning with 0 was interpreted as octal.
>
> The PDP-7's successor, and the first workhorse Unix machine was the PDP-11 (first shipped in 1970).
> It had 16-bit words - but, due to some unusual peculiarities of the instruction set, octal made more sense for its machine code as well.
> C, first implemented on the PDP-11, thus inherited the B octal syntax.
> And extended it: when an in-string backslash has a following digit, that was expected to lead an octal literal.
> 
> The Interdata 32, VAX, and other later Unix platforms didn't have those peculiarities; their opcodes expressed more naturally in hex.
> But C was never adjusted to prefer hex, and the surprising interpretation of leading 0 wasn't removed.
>
> Because many later languages (Java, Python, etc) copied C's low-level lexical rules for compatibility reasons, the relatively useless and sometimes dangerous octal syntax besets computing platforms for which three-bit opcode fields are wildly inappropriate, and may never be entirely eradicated [3].
> 
> The PDP-11 was so successful that architectures strongly influenced by it (notably, including Intel [4] and ARM microprocessors) eventually took over the world, killing off 36-bit machines.
> 
> The x86 instruction set actually kept the property that though descriptions of its opcodes commonly use hex, large parts of the instructiion set are best understood as three-bit fields and thus best expressed in octal.
> This is perhaps clearest in the encoding of the mov instruction.
> 
> [3]. Python 3, Perl 6, and Rust have at least gotten rid of the dangerous leading-0-for-octal syntax, but Go kept it.     
> [4]. Early Intel microprocessors weren't much like the PDP-11, but the 80286 and later converged with it in important ways.
>
> . . . 
> 
> **ASCII**
> 
> ASCII, the American Standard Code for Information Interchange, evolved in the early 1960s out of a family of character codes used on *teletypes*.
> 
> ASCII, unlike a lot of other early character encodings, is likely to live forever - because by design the low 127 code points of Unicode are ASCII.
> If you know what UTF-8 is (and you should) every ASCII file is correct UTF-8 as well.
> 
> The following table describes ASCII-1967, the version in use today.
> This is the 16x4 format given in most references.

```
Dec Hex    Dec Hex    Dec Hex  Dec Hex  Dec Hex  Dec Hex   Dec Hex   Dec Hex
  0 00 NUL  16 10 DLE  32 20    48 30 0  64 40 @  80 50 P   96 60 `  112 70 p
  1 01 SOH  17 11 DC1  33 21 !  49 31 1  65 41 A  81 51 Q   97 61 a  113 71 q
  2 02 STX  18 12 DC2  34 22 "  50 32 2  66 42 B  82 52 R   98 62 b  114 72 r
  3 03 ETX  19 13 DC3  35 23 #  51 33 3  67 43 C  83 53 S   99 63 c  115 73 s
  4 04 EOT  20 14 DC4  36 24 $  52 34 4  68 44 D  84 54 T  100 64 d  116 74 t
  5 05 ENQ  21 15 NAK  37 25 %  53 35 5  69 45 E  85 55 U  101 65 e  117 75 u
  6 06 ACK  22 16 SYN  38 26 &  54 36 6  70 46 F  86 56 V  102 66 f  118 76 v
  7 07 BEL  23 17 ETB  39 27 '  55 37 7  71 47 G  87 57 W  103 67 g  119 77 w
  8 08 BS   24 18 CAN  40 28 (  56 38 8  72 48 H  88 58 X  104 68 h  120 78 x
  9 09 HT   25 19 EM   41 29 )  57 39 9  73 49 I  89 59 Y  105 69 i  121 79 y
 10 0A LF   26 1A SUB  42 2A *  58 3A :  74 4A J  90 5A Z  106 6A j  122 7A z
 11 0B VT   27 1B ESC  43 2B +  59 3B ;  75 4B K  91 5B [  107 6B k  123 7B {
 12 0C FF   28 1C FS   44 2C ,  60 3C <  76 4C L  92 5C \  108 6C l  124 7C |
 13 0D CR   29 1D GS   45 2D -  61 3D =  77 4D M  93 5D ]  109 6D m  125 7D }
 14 0E SO   30 1E RS   46 2E .  62 3E >  78 4E N  94 5E ^  110 6E n  126 7E ~
 15 0F SI   31 1F US   47 2F /  63 3F ?  79 4F O  95 5F _  111 6F o  127 7F DEL
```


> However, this format - less used because the shape is inconvenient - probably does more to explain the encoding:

```
   0000000 NUL    0100000      1000000 @    1100000 `
   0000001 SOH    0100001 !    1000001 A    1100001 a
   0000010 STX    0100010 "    1000010 B    1100010 b
   0000011 ETX    0100011 #    1000011 C    1100011 c
   0000100 EOT    0100100 $    1000100 D    1100100 d
   0000101 ENQ    0100101 %    1000101 E    1100101 e
   0000110 ACK    0100110 &    1000110 F    1100110 f
   0000111 BEL    0100111 '    1000111 G    1100111 g
   0001000 BS     0101000 (    1001000 H    1101000 h
   0001001 HT     0101001 )    1001001 I    1101001 i
   0001010 LF     0101010 *    1001010 J    1101010 j
   0001011 VT     0101011 +    1001011 K    1101011 k
   0001100 FF     0101100 ,    1001100 L    1101100 l
   0001101 CR     0101101 -    1001101 M    1101101 m
   0001110 SO     0101110 .    1001110 N    1101110 n
   0001111 SI     0101111 /    1001111 O    1101111 o
   0010000 DLE    0110000 0    1010000 P    1110000 p
   0010001 DC1    0110001 1    1010001 Q    1110001 q
   0010010 DC2    0110010 2    1010010 R    1110010 r
   0010011 DC3    0110011 3    1010011 S    1110011 s
   0010100 DC4    0110100 4    1010100 T    1110100 t
   0010101 NAK    0110101 5    1010101 U    1110101 u
   0010110 SYN    0110110 6    1010110 V    1110110 v
   0010111 ETB    0110111 7    1010111 W    1110111 w
   0011000 CAN    0111000 8    1011000 X    1111000 x
   0011001 EM     0111001 9    1011001 Y    1111001 y
   0011010 SUB    0111010 :    1011010 Z    1111010 z
   0011011 ESC    0111011 ;    1011011 [    1111011 {
   0011100 FS     0111100 <    1011100 \    1111100 |
   0011101 GS     0111101 =    1011101 ]    1111101 }
   0011110 RS     0111110 >    1011110 ^    1111110 ~
   0011111 US     0111111 ?    1011111 _    1111111 DEL
```

> Using the second table, it's easier to understand a couple of things:
> 
> * The Control modifier on your keyboard basically clears the top three bits of whatever character you type, leaving the bottom five and mapping it to the 0..31 range.
> So, for example, Ctrl-SPACE, Ctrl-@, and Ctrl-` all mean the same thing: NUL.
> 
> * Very old keyboards used to do Shift just by toggling the 32 or 16 bit, depending on the key; this is why the relationship between small and capital letters in ASCII is so regular, and the relationship between numbers and symbols, and some pairs of symbols, is sort of regular if you squint at it.
> The ASR-33, which was an all-uppercase terminal, even let you generate some punctuation characters it didn’t have keys for by shifting the 16 bit; thus, for example, Shift-K (0x4B) became a [ (0x5B)
> 
> It used to be common knowledge that the *original 1963 ASCII* had been slightly different.
> It lacked tilde and vertical bar; 5E was an up-arrow rather than a caret, and 5F was a left arrow rather than underscore.
> Some early adopters (notably DEC) held to the 1963 version.
> 
> If you learned your chops after 1990 or so, the mysterious part of this is likely the control characters, code points 0-31.
> You probably know that C uses NUL as a string terminator.
> Others, notably LF = Line Feed and HT = Horizontal Tab, show up in plain text.
> But what about the rest?
> 
> Many of these are remnants from teletype protocols that have either been dead for a very long time or, if still live, are completely unknown in computing circles.
> A few had conventional meanings that were half-forgotten even before Internet times.
> A **very** few are still used in binary data protocols today.
> 
> Here's a tour of the meanings these had in older computing, or retain today. If you feel an urge to send me more, remember that the emphasis here is on what was common knowledge back in the day.
> If I don't know it now, we probably didn't generally know it then.
>
> . . . 
> 
> **SYN (Synchronous Idle) = Ctrl-V**
> 
>> Never to my knowledge used specially after teletypes, except in synchronous serial protocols never used on micros or minis.
>> Be careful not to confuse this with the SYN (synchronization) packet used in TCP/IP's SYN SYN-ACK initialization sequence.
>> In an *unrelated usage*, many Unix *tty* drivers use this (as ```Ctrl-V```) for the *literal-next* character (aka *lnext* character) that lets you quote following control characters such as ```Ctrl-C```.
> 
> ...
> 
> Change history
> 
> 1.0: 2017-01-26
>     Initial version.
>
> ...
> 
> 1.22: 2023-04-19 
    
----


From
[Things Every Hacker Once Knew (catb.org) - Hacker News dicussion](https://news.ycombinator.com/item?id=13498365):   
(Retrieved on Feb 18, 2024)   
 
> soneil on Jan 27, 2017 [-]
>
> I always thought it was a shame the *ASCII table* is rarely shown in *columns* (or *rows*) **of 32**, as it makes a lot of this quite obvious. e.g., [http://pastebin.com/cdaga5i1](http://pastebin.com/cdaga5i1)
>
> ```
>       00      01      10      11  
> 00000 NUL     Spc     @       `  
> 00001 SOH !   A       a 
> 00010 STX     "       B       b 
> 00011 ETX     #       C       c 
> 00100 EOT     $       D       d 
> 00101 ENQ     %       E       e 
> 00110 ACK     &       F       f 
> 00111 BEL     '       G       g 
> 01000 BS      (       H       h 
> 01001 TAB     )       I       i 
> 01010 LF      *       J       j 
> 01011 VT      +       K       k 
> 01100 FF      ,       L       l 
> 01101 CR      -       M       m 
> 01110 SO      .       N       n 
> 01111 SI      /       O       o 
> 10000 DLE     0       P       p 
> 10001 DC1     1       Q       q 
> 10010 DC2     2       R       r 
> 10011 DC3     3       S       s 
> 10100 DC4     4       T       t 
> 10101 NAK     5       U       u 
> 10110 SYN     6       V       v 
> 10111 ETB     7       W       w 
> 11000 CAN     8       X       x 
> 11001 EM      9       Y       y 
> 11010 SUB     :       Z       z 
> 11011 ESC     ;       [       { 
> 11100 FS      <       \       | 
> 11101 GS      =       ]       } 
> 11110 RS      >       ^       ~ 
> 11111 US      ?       _       DEL 
> ```
>
> It becomes immediately obvious why, e.g., ```^[``` becomes ```escape```.
> Or that the alphabet is just 40h + the ordinal position of the letter (or 60h for lower-case).
> Or that we shift between upper & lower-case with a single bit.
>
> esr's (Eric S. Raymond) rendering of the table - forcing it to fit hexadecimal as eight groups of 4 bits, rather than four groups of 5 bits, makes the relationship between ```^I``` and ```tab```, or ```^[``` and ```escape```, nearly invisible.
>
> It's like making the periodic table 16 elements wide because we're partial to hex, and then wondering why no-one can spot the relationships anymore. 
>
>
> [bogomipz - I am not following, can you explain why ^\[ becomes escape](https://news.ycombinator.com/item?id=13499895)
>
> "It becomes immediately obvious why, eg, ^\[ becomes escape.
> Or that the alphabet is just 40h + the ordinal position of the letter (or 60h for lower-case).
> Or that we shift between upper & lower-case with a single bit."
>
> Q: I am not following, can you explain why ```^[``` becomes ```escape```.
> Or that the alphabet is just 40h + the ordinal position?
> Can you elaborate?
> I feel like I am missing the elegance you are pointing out. 
>
> A: If you look at each byte as being 2 bits of 'group' and 5 bits of 'character';
>
> ```
>    00 11011 is Escape
>    10 11011 is [
> ```
>
> So when we do ```ctrl```+```[``` for ```escape``` (e.g., in old ANSI 'escape sequences', or in more recent discussions about the vim escape key on the 'touchbar' macbooks) - you're asking for the character ```11011``` (```[```) out of the control (```00```) set.
>
> Any time you see ```\n``` represented as ```^M```, it's the same thing - ```01101``` (M) in the control (```00```) set is ```Carriage Return```.
> 
>
> Excerpt from the above table
> 
> ```
>       00      01      10      11  
> ---- snip ---
> 01101 CR      -       M       m 
---- snip ---
> 11011 ESC     ;       [       { 
> ```
> Likewise, when you realise that the relationship between upper-case and lower-case is just the same character from sets 10 & 11, it becomes obvious that you can, e.g., translate upper case to lower case by just doing a bitwise or against ```64``` (```0100000```).
> 


MY NOTE:

Convert binary ```11011```  to decimal:
>
> ```
> +------------------------------+-----+-----+-----+-----+-----+
> | Number in binary             | 1   | 1   |  0  |  1  |  1  |
> +------------------------------+-----+-----+-----+-----+-----+
> | Positional values            |     |     |     |     |     |
> | (2 to the power of)          | 2^4 | 2^3 | 2^2 | 2^1 | 2^0 | 
> +------------------------------+-----+-----+-----+-----+-----+
> | Product - From the row above | 16  |  8  |  4  |  2  |  1  |
> +------------------------------+-----+-----+-----+-----+-----+
> | ON or OFF                    |     |     |     |     |     |
> |                              |     |     |     |     |     |
> | (Look in the first column )  | ON  | ON  | OFF | ON  | ON  |
> |  - From the first column:    |     |     |     |     |     |
> |      1 = ON                  |     |     |     |     |     |
> |      0 = OFF                 |     |     |     |     |     |
> +------------------------------+-----+-----+-----+-----+-----+
> ```
>
> ```16 + 8 + 0 + 2 + 1``` = ```27``` 
>
So, binary ```11011```  in decimal is ```27```.

Convert decimal ```27``` to octal:

```
% printf "%03o\n" 27
033
```

Explanation:    
"```%03```" - Column length for ```printf(1)``` is three digits, with zero-padding rather than blank-padding 

>
> ```
> ESC     033  00 11011
> ```
> 

----


From
[Things Every Hacker Once Knew - Lobsters (lobste.rs) discussion](https://lobste.rs/s/qph9hd/things_every_hacker_once_knew):   
(Retrieved on Feb 18, 2024)   

> A TTY-related fact that wasn't mentioned in the article:
> 
> To control text-formatting on an ANSI-compatible terminal (or emulator), you can send it terminal control sequences like ```\e[1m``` to enable bold or whatever.
> Paper-based terminals didn't have control-sequences like that, but people still figured out ways to do formatting.
> For example, if you printed a letter, then sent backspace (```Ctrl-H```, octet ```0x08```) and printed the same letter again, it would be printed with twice as much ink, making it look "bold".
> If you printed a letter, then sent backspace and an underscore, it would look underlined.
> 
> The original Unix typesetting software took full advantage of this trick.
> If you told it to output a document (say, a manpage) to your terminal (as opposed to the expensive typesetting machine in the corner), it would use the BS trick to approximate the intended formatting.
>
> This worked great, up until the invention of video display terminals, where the backspace trick just *replaced* the original text, instead of adding to it.
> So people wrote software to translate the backspace-trick into ANSI control codes, software like ```less(1)```.
> 
> If you run:
>
> ```
printf 'H\x08He\x08el\x08ll\x08lo\x08o w\x08_o\x08_r\x08_l\x08_d\x08_\n'
> ```
>
> ... in a modern terminal emulator, you'll probably get output like (see MY NOTE below):     
> 
> ```
> Hello _____
> ```
>
> ... because that's how glass TTYs work.
> However, if you pipe it through ```less(1)```:
> 
> ```
> printf 'H\x08He\x08el\x08ll\x08lo\x08o w\x08_o\x08_r\x08_l\x08_d\x08_\n' | less
> ```
>
> ... it will convert the backspace trick into formatting your terminal can understand.
> Unfortunately, I can't figure out how to represent it in Markdown, so you'll have to try it for yourself.
>


MY NOTE:   
In my test, it worked in *bash* but didn't work in *csh*.

----


From
[Synchronous Idle - Wikipedia - archive.org snapshot from Dec 13, 2023](https://web.archive.org/web/20231213162000/https://en.wikipedia.org/wiki/Synchronous_Idle):

> Synchronous Idle (SYN) is the ASCII control character 22 (0x16), represented as ```^V``` in *caret notation*.
> In *EBCDIC* the corresponding character is 50 (0x32).
> Synchronous Idle is used in *some synchronous serial communication systems* such as *Teletype* machines or IBM's *Binary Synchronous (Bisync)* protocol to provide a signal from which synchronous correction may be achieved between data terminal equipment.
> 
> Because there is no START, STOP, or PARITY bits present in synchronous serial communication, it is necessary to establish character framing through recognition of consecutive SYN characters - typically three - at which point character sync can be assumed to begin with the first bit of the SYN characters and every seven bits thereafter.
> 
> The SYN character has the bit pattern 00010110 (EBCDIC 00110010), which has the property that it is distinct from any *bit-wise rotation* of itself.
> This helps bit-alignment of sequences of synchronous idles. 
> 
> Unicode has a character U+2416 ␖ SYMBOL FOR SYNCHRONOUS IDLE for visual representation. 

----

From
[ASCII character #22. Char SYN - Synchronous Idle](https://www.asciihex.com/character/control/22/0x16/syn-synchronous-idle):

> **About SYN:**
> 
> ```
> Integer ASCII code:  22
> Binary code:  0001 0110
> Octal code:  26
> Hexadecimal code:  16
> Group:  control
> Seq:  ^V
> ```
> 
> Unicode symbol: ␖, int code: 9238 (html &#9238) hex code: 2416 (html &#x2416) 
>
> **Information**
> 
> It's not hard to guess, that Synchronous Idle is used in synchronous transmission systems in order to make a signal.
> From this signal a synchronous correction may be accomplished between data terminal equipment, especially in cases when no other character is being transmitted.
> 
> Synchronous Idle (SYN) is the ASCII control character 22 (0x16).
> In *caret notation* SYN is designated as ```^V```.
> The appropriate character in EBCDIC is 50 (0x32).
> The Synchronous Idle is perfectly suitable for use in some synchronous serial communication systems, for example *Teletype* machines or the *Binary Synchronous (Bisync) protocol*.
> The use of Synchronous Idle here makes a signal.
> From it one can accomplish a synchronous correction between data terminal equipment, especially when no additional character is being transmitted.
> 
> The SYN character possesses the following bit pattern: 00010110 (EBCDIC 00110010).
> It has one interesting feature: it is different from any *bit-wise rotation of itself*.
> This helps bit-alignment of synchronous idles sequences.
>

----

From the man page for ```lesskey(1)``` on FreeBSD 13:

```
LESSKEY(1)                  General Commands Manual                 LESSKEY(1)
  
NAME
       lesskey - customize key bindings for less
  
SYNOPSIS (deprecated)
       lesskey [-o output] [--] [input]
       lesskey [--output=output] [--] [input]
       lesskey -V
       lesskey --version

---- snip ----

DESCRIPTION
       A lesskey file specifies a set of key bindings and environment
       variables to be used by subsequent invocations of less.
  
FILE FORMAT
       The input file consists of one or more sections.  Each section starts
       with a line that identifies the type of section.
       Possible sections are:
  
         #command
                Customizes command key bindings.

---- snip ----

COMMAND SECTION
       The command section begins with the line
  
       #command
  
       If the command section is the first section in the file, this line may
       be omitted.  The command section consists of lines of the form:
  
            string <whitespace> action [extra-string] <newline>

---- snip ----

       The characters in the string may appear literally, or be prefixed by
       a caret to indicate a control key.  A backslash followed by one to
       three octal digits may be used to specify a character by its octal
       value.  A backslash followed by certain characters specifies input
       characters as follows:

           \b   BACKSPACE   (0x08)
           \e   ESCAPE      (0x1B)
           \n   NEWLINE     (0x0A)
           \r   RETURN      (0x0D)
           \t   TAB         (0x09)

---- snip ----
```

----

From
[Unprintable ASCII characters and TTYs](https://www.in-ulm.de/~mascheck/various/ascii-tty/):

> What happens when typing special "control sequences" like ```<ctrl-h>```, ```<ctrl-d>``` etc.?
>
> For convenience, "^X" means ```Ctrl-X``` in the following (ignoring the fact that you usually might use the lower case x).
> 
> About a possible origin of the "^"-notation (aka caret notation), see also an article in a.f.c, [62097@bbn.BBN.COM](http://groups.google.com/groups?as_umsgid=62097@bbn.BBN.COM)  
([local copy](https://www.in-ulm.de/~mascheck/various/ascii-tty/origin.html))

----

About a possible origin of the "^"-notation (aka caret notation), local copy:
[Re: Control characters - alt.folklore.computers - Jan 15, 1991](https://www.in-ulm.de/~mascheck/various/ascii-tty/origin.html)


About a possible origin of the "^"-notation (aka caret notation), see also an article in a.f.c, [62097@bbn.BBN.COM -- Control characters](https://groups.google.com/forum/#!msg/alt.folklore.computers/jnEqB1-DroQ/W7LEWqK7Vp8J)

[Subject: Re: Control characters](https://www.in-ulm.de/~mascheck/various/ascii-tty/origin.html)

----

From
[Why are special characters such as "carriage return" represented as "^M"?](https://superuser.com/questions/763879/why-are-special-characters-such-as-carriage-return-represented-as-m):
 
> I believe that what OP was actually asking about is called Caret Notation.
> 
> Caret notation is a notation for unprintable control characters in ASCII encoding.
> The notation consists of a caret (^) followed by a capital letter; this digraph stands for the ASCII code that has the numerical value equivalent to the letter's numerical value.
> For example the EOT character with a value of 4 is represented as ^D because D is the 4th letter in the alphabet.
> The NUL character with a value of 0 is represented as ^@ (@ is the ASCII character before A).
> The DEL character with the value 127 is usually represented as ^?, because the ASCII '?' is before '@' and -1 is the same as 127 if masked to 7 bits.
> An alternative formulation of the translation is that the printed character is found by inverting the 7th bit of the ASCII code

----

From the man page for ```less(1)``` on FreeBSD:

```
COMMANDS
         In the following descriptions, ^X means control-X.  ESC stands for the
         ESCAPE key; for example ESC-v means the two character sequence
         "ESCAPE", then "v".

---- snip ----

  LINE EDITING
         When entering command line at the bottom of the screen (for example, a
         filename for the :e command, or the pattern for a search command),
         certain keys can be used to manipulate the command line.  Most commands
         have an alternate form in [ brackets ] which can be used if a key does
         not exist on a particular keyboard.  (Note that the forms beginning
         with ESC do not work in some MS-DOS and Windows systems because ESC is
         the line erase character.)  Any of these special keys may be entered
         literally by preceding it with the "literal" character, either ^V or
         ^A.  A backslash itself may also be entered literally by entering two
         backslashes.
```

----


From the man page for ```curs_getch(3X)``` on FreeBSD:

```
         Note that some keys may be the same as commonly used control keys,
         e.g., KEY_ENTER versus control/M, KEY_BACKSPACE versus control/H.  Some
         curses implementations may differ according to whether they treat these
         control keys specially (and ignore the terminfo), or use the terminfo
         definitions.  Ncurses uses the terminfo definition.  If it says that
         KEY_ENTER is control/M, getch will return KEY_ENTER when you press
         control/M.
```

----

From
[FreeBSD.org - FreeBSD Manual Pages - 1. General Commands - Operating System: SunOS 5.10 -- stty(1) - set the options for a terminal](https://www.freebsd.org/cgi/man.cgi?query=stty&sektion=1&apropos=0&manpath=solaris):

```
The stty utility sets certain terminal I/O options for the device that
is the current standard input. Without arguments, stty reports the set-
tings of certain options.

In this report, if a character is preceded by a caret (^), then the
value of that option is the corresponding control character (for exam-
ple,  ^h is <CTRL-h>.  In this case, recall that <CTRL-h> is the same as
the <BACKSPACE> key).  The sequence ^@ means that an option has a null
value.

---- snip ----

Control Assignments
    control-character  c     Set control-character to c, where:

                             control-character

                                 is ctab, discard, dsusp, eof, eol, eol2,
                                 erase, intr, kill,  lnext,  quit, reprint,
                                 start, stop, susp, swtch, or werase  (ctab
                                 is used with -stappl, see termio(7I)).
                                 For information on swtch, see NOTES.

    c

    If c is a single character, the control
    character is set to that character.

    In the POSIX locale, if c is preceded by a
    caret (^) indicating an escape from the
    shell and is one of those listed in the ^c
    column of the following table, then its
    value used (in the  Value  column) is the
    corresponding control character (for exam-
    ple, ``^d''  is a <CTRL-d>). ``^?'' is in-
    terpreted as <DEL>  and  ``^-''  is inter-
    preted as undefined.

    +------------------+-------------------+------------------+
    |  ^c      Value   |  ^c      Value    |  ^c      Value   |
    | a, A     <SOH>   | l, L     <FF>     | w, W     <ETB>   |
    | b, B     <STX>   | m, M     <CR>     | x, X     <CAN>   |
    | c, C     <ETX>   | n, N     <SO>     | y, Y     <EM>    |
    | d, D     <EOT>   | o, O     <SI>     | z, Z     <SUB>   |
    | e, E     <ENQ>   | p, P     <DLE>    | [        <ESC>   |
    | f, F     <ACK>   | q, Q     <DC1>    | \        <FS>    |
    | g, G     <BEL>   | r, R     <DC2>    | ]        <GS>    |
    | h, H     <BS>    | s, S     <DC3>    | ^        <RS>    |
    | i, I     <HT>    | t, T     <DC4>    | _        <US>    |
    | j, J     <LF>    | u, U     <NAK>    | ?        <DEL>   |
    | k, K     <VT>    | v, V     <SYN>    |                  |
    +------------------+-------------------+------------------+
```

----


From
[FreeBSD.org - FreeBSD Manual Pages - Operating System: SunOS 5.10 -- termio(7I) - general terminal interface](https://www.freebsd.org/cgi/man.cgi?query=termio&sektion=7I&manpath=SunOS+5.10):


```
---- snip ----
Special Characters
    Certain characters have special functions on input.  These functions and
    their default character values are summarized as follows:

---- snip ----

       LNEXT         (Control-v  or ASCII SYN) causes the special meaning of
                     the next character to be ignored.  This works for all
                     the special characters mentioned above.  It allows char-
                     acters to be input that would otherwise be interpreted
                     by the system (for example KILL, QUIT).  The character
                     values for INTR, QUIT, ERASE, WERASE, KILL, REPRINT,
                     EOF, EOL, EOL2, SWTCH, SUSP, DSUSP, STOP, START, DIS-
                     CARD, and LNEXT may be changed to suit individual
                     tastes.  If the value of a special control character is
                     _POSIX_VDISABLE (0), the function of that special con-
                     trol character is disabled.  The ERASE, KILL, and EOF
                     characters may be escaped by a preceding backslash  (\)
                     character, in which case no special function is done.
                     Any of the special characters may be preceded by the
                     LNEXT  character, in which case no special function is
                     done.

---- snip ----

Terminal Parameters
    The parameters that control the behavior of devices and modules provid-
    ing the termios interface are specified by the termios structure de-
    fined by  termios.h.  Several  ioctl(2)  system calls that fetch or
    change these parameters use this structure that contains the following
    members:

           tcflag_t c_iflag;  /* input modes */
           tcflag_t  c_oflag; /* output modes */
           tcflag_t  c_cflag; /* control modes */
           tcflag_t  c_lflag; /* local modes */
           cc_t  c_cc[NCCS];  /* control chars */

    The special control characters are defined by the array c_cc.  The sym-
    bolic name NCCS is the size of the Control-character array and is also
    defined by  <termios.h>.  The relative positions, subscript names, and
    typical default values for each function are as follows:

    +--------------------+--------------------+-----------------------+
    | Relative Position  | Subscript Name     | Typical Default Value |
    +--------------------+--------------------+-----------------------+
    | 0                  | VINTR              | ETX                   |
    +--------------------+--------------------+-----------------------+
    | 1                  | VQUIT              | FS                    |
    +--------------------+--------------------+-----------------------+
    | 2                  | VERASE             | DEL                   |
    +--------------------+--------------------+-----------------------+
    | 3                  | VKILL              | NAK                   |
    +--------------------+--------------------+-----------------------+
    | 4                  | VEOF               | EOT                   |
    +--------------------+--------------------+-----------------------+
    | 5                  | VEOL               | NUL                   |
    +--------------------+--------------------+-----------------------+
    | 6                  | VEOL2              | NUL                   |
    +--------------------+--------------------+-----------------------+
    | 7                  | VWSTCH             | NUL                   |
    +--------------------+--------------------+-----------------------+
    | 8                  | VSTART             | NUL                   |
    +--------------------+--------------------+-----------------------+
    | 9                  | VSTOP              | DC3                   |
    +--------------------+--------------------+-----------------------+
    | 10                 | VSUSP              | SUB                   |
    +--------------------+--------------------+-----------------------+
    | 11                 | VDSUSP             | EM                    |
    +--------------------+--------------------+-----------------------+
    | 12                 | VREPRINT           | DC2                   |
    +--------------------+--------------------+-----------------------+
    | 13                 | VDISCARD           | SI                    |
    +--------------------+--------------------+-----------------------+
    | 14                 | VWERASE            | ETB                   |
    +--------------------+--------------------+-----------------------+
    | 15                 | VLNEXT             | SYN                   |
    +--------------------+--------------------+-----------------------+
    | 16-19              | Reserved           |                       |
    +--------------------+--------------------+-----------------------+
```

----

From
[Terminal usage of the shell - The basic notion of commands -- 4.4BSD Documents - FreeBSD Documents Archive - UNIX User's Supplementary Documents (USD) .4 Berkeley Software Distribution (BSD) - June, 1993 -- An Introduction to the C shell - William Joy (revised for 4.3BSD by Mark Seiden) - Computer Science Division, Department of Electrical Engineering and Computer Science - University of California, Berkeley](https://docs.freebsd.org/44doc/usd/04.csh/paper-1.html):

> Here and throughout this document, the notation "^x" is to be read "control-x" and represents the striking of the x key while the control key is held down.

----

From
[tty(4) [minix man page] - Linux and UNIX Man Pages - The UNIX and Linux Forums](https://www.unix.com/man-page/minix/4/tty/):

```
---- snip ----

Local Modes
    The c_lflag field contains the following single bit flags that
    control various functions:

    ECHO   Enable echoing of input characters.  Most input characters are
           echoed as they are.  Control characters are echoed as ^X where X is
           the letter used to say that the control character is CTRL-X.
           The CR, NL and TAB characters are echoed with their normal effect
           unless they are escaped by  LNEXT.
---- snip ----
```

----

From
[Control characters in ASCII and Unicode](https://www.aivosto.com/articles/control-characters.html):

> Tens of odd control characters appear in ASCII charts.
> The same characters have found their way to Unicode as well.
> CR, LF, ESC, CAN... what are all these codes for?
> Should I care about them?
> This is an in-depth look into control characters in ASCII and its descendants, including Unicode, ANSI and ISO standards.
>
> When ASCII first appeared in the 1960s, control characters were an essential part of the new character set.
> Since then, many new character sets and standards have been published.
> Computing is not the same either.
> What happened to the control characters?
> Are they still used and if yes, for what?
> 
> This article looks back at the history of character sets while keeping an eye on modern use.
> The information is based on a number of standards released by ANSI, ISO, ECMA and The Unicode Consortium, as well as industry practice.
> In many cases, the standards define one use for a character, but common practice is different.
> Some characters are used contrary to the standards.
> In addition, certain characters were originally defined in an ambiguous or loose way, which has resulted in confusion in their use.

>
> ...
> 
> **Character list**
> 
> **ASCII control characters (C0)**
> 
> The ASCII control characters work in 7-bit and 8-bit environments, as well as in Unicode.
> These controls originate from a set of related standards: ASCII, ISO 646 and ECMA-6, and also ISO 6429 and ECMA-48.
> All of these characters are available in Unicode, too.
> The actual C0 set consists of characters NUL through US (0–31).
> Two additional characters, SP and DEL, are a part of ASCII and the related standards as well.

(*) The 2-character mnemonics for the ASCII set are from ANSI X3.32, ISO 2047 and ECMA-17. So are also the graphic symbols. The symbols are outdated and rarely used. A couple of the symbols also have alternative forms.

```
Dec  Hex  Char       Description                                 Octal  Pos  *)
---- snip ---- 
22   $16  SYN (^V)   Synchronous Idle                            026    1/6  SY
                     TC9 Transmission control character 9  

                     Used as "time-fill" in synchronous transmission.
                     Sent during an idle condition to retain a signal when
                     there are no other characters to send. 

                     Note: SYN has been used by synchronous modems, which
                     have to send data constantly. — Beginning each
                     transmission with at least two SYN characters is a way
                     to achieve synchronization.  The receiving station will
                     possibly ignore SYN, since it doesn't belong to the actual
                     data content.
---- snip ---- 
```

----

From the man page for ```vi(1)``` on FreeBSD:

```
---- snip ----
  VI TEXT INPUT COMMANDS
---- snip ----
       ⟨literal next⟩
               Escape the next character from any special meaning.  
               The ⟨literal next⟩ character is usually ⟨control-V⟩.
---- snip ----
```

----

From the man page for ```readline(3)``` on FreeBSD:

```
NOTATION
       An Emacs-style notation is used to denote keystrokes.  Control keys are
       denoted by C-key, e.g., C-n means Control-N.  Similarly, meta keys are
       denoted by M-key, so M-x means Meta-X.  (On keyboards without a meta
       key, M-x means ESC x, i.e., press the Escape key then the x key.  This
       makes ESC the meta prefix.  The combination M-C-x means ESC-Control-x,
       or press the Escape key then hold the Control key while pressing the x
       key.)


     VI Mode bindings
  
               VI Insert Mode functions
  
               "C-D"  vi-eof-maybe
               "C-H"  backward-delete-char
               "C-I"  complete
               "C-J"  accept-line
               "C-M"  accept-line
               "C-R"  reverse-search-history
               "C-S"  forward-search-history
               "C-T"  transpose-chars
               "C-U"  unix-line-discard
               "C-V"  quoted-insert

               ---- snip ----
```

----

From
[Readline VI Editing Mode Cheat Sheet - Default Keyboard Shortcuts for Bash](https://catonmat.net/ftp/bash-vi-editing-mode-cheat-sheet.pdf):

```
---- snip ----
    Miscellaneous Commands
    ----------------------
Shortcut:     CTRL-v     
Description:  Insert a character literally (quoted insert)
---- snip ----

    Examples and Tips
    -----------------
* Use CTRL-v to insert character literally, for example, CTRL-v CTRL-r would
  insert CTRL-r in the command line.
* See man bash, man readline, and builtin bind command for modifying the
  default behavior.
```

----

From
[Readline Emacs Editing Mode Cheat Sheet - Default Keyboard Shortcuts for Bash](https://catonmat.net/ftp/readline-emacs-editing-mode-cheat-sheet.pdf):

```
---- snip ----
    Commands for Changing Text
    --------------------------
---- snip ----
Shortcut:       C-q or C-v    
Function Name:  quoted-insert 
Description:    Quoted insert
---- snip ----
```

----

From
[Midnight Commander - Fequently Asked Questions (FAQ)](https://midnight-commander.org/wiki/doc/faq):

> **2 Keyboard**
> 
> 2.1 What does documentation mean with the C-?, M-? and F? keys?
> 
> GNU Midnight Commander documentation uses emacs style names for keyboard keys.
> 
> C stands for the *Ctrl* key.
> For example, C-f means that you should hold down the Ctrl key and press the f key.
> 
> M stands for the *Meta* key.
> Your terminal might call it Alt or Compose instead of Meta.
> For example, M-f means that you should hold down the Meta/Alt/Compose key and press the f key.
> If your terminal doesn't have Meta, Alt or Compose or they don't work you can use Esc.
> For M-f press the Esc key and then press the f key.
> 
> Sometimes Ctrl and Alt are used instead of C and M for simplicity.
> Keep in mind that Alt can actually be Meta on some keyboards.
>
> F? stands for a function key.
> If your terminal doesn't have function keys or they don't work you can use Esc.
> For example, for F3 press the Esc key and then press the 3 key. 

----

On FreeBSD:

```
$ man -k editline
editline, el_deletestr, el_end, el_get, el_getc, el_gets, el_init, el_init_fd, el_insertstr, el_line, el_parse, el_push, el_reset, el_resize, el_set, el_source, el_wdeletestr, el_wget, el_wgetc, el_wgets, el_winsertstr, el_wline, el_wparse, el_wpush, el_wset, history_end, history_init, history_w, history_wend, history_winit, tok_end, tok_init, tok_line, tok_reset, tok_str, tok_wend, tok_winit, tok_wline, tok_wreset, tok_wstr, el_history, el_cursor, history(3) - line editor, history and tokenization functions
editrc(5) - configuration file for editline library
editline(7) - line editing user interface
```

```
$ man 3 editline
$ man 7 editline
```

More information: in the man page for ```editline(7)```.

----


On FreeBSD:   
NOTE for ```-a``` and ```-w``` options for ```man(1)```:
> ```-a```  Display all manual pages instead of just the first found for each
>           page argument.
> 
> ```-w```  Display the location of the manual page instead of the contents
            of the manual page.

```
$ man -a -w terminfo
/usr/share/man/man5/terminfo.5.gz
/usr/local/man/man5/terminfo.5.gz
```

```
$ ls -lh /usr/share/man/man5/terminfo.5.gz 
-r--r--r--  1 root  wheel    34K Jun 21  2018 /usr/share/man/man5/terminfo.5.gz
 
$ ls -lh /usr/local/man/man5/terminfo.5.gz
-rw-r--r--  1 root  wheel    35K Aug 22  2019 /usr/local/man/man5/terminfo.5.gz
 
$ diff /usr/share/man/man5/terminfo.5.gz /usr/local/man/man5/terminfo.5.gz 
Binary files /usr/share/man/man5/terminfo.5.gz and /usr/local/man/man5/terminfo.5.gz differ
 
$ man /usr/local/man/man5/terminfo.5.gz:
         A number of escape sequences are provided in the string valued
         capabilities for easy encoding of characters there:
  
         *   Both \E and \e map to an ESCAPE character,
         *   ^x maps to a control-x for any appropriate x, and
         *   the sequences
                 \n, \l, \r, \t, \b, \f, and \s
             produce
             newline, line-feed, return, tab, backspace, form-feed, and space,
             respectively.


         X/Open Curses does not say what "appropriate x" might be.  In practice,
         that is a printable ASCII graphic character.  The special case "^?" is
         interpreted as DEL (127).  In all other cases, the character value is
         AND'd with 0x1f, mapping to ASCII control codes in the range 0 through
         31.
  
         Other escapes include
         *   \^ for ^,
         *   \\ for \,
         *   \, for comma,
         *   \: for :,
         *   and \0 for null.
  
             \0 will produce \200, which does not terminate a string but behaves
             as a null character on most terminals, providing CS7 is specified.
             See stty(1).
```

----

```
$ man /usr/share/man/man5/terminfo.5.gz:
       A number of escape sequences are provided in the string-valued
       capabilities for easy encoding of control characters there.  

       \E maps to
       an ESC character, ^X maps to a control-X for any appropriate X, and the
       sequences \n \r \t \b \f map to linefeed, return, tab, backspace, and
       formfeed, respectively.  Finally, characters may be given as three octal
       digits after a \, and the characters ^ and \ may be given as \^ and \\.
       If it is necessary to place a : in a capability it must be escaped as \:
       or be encoded as \072.  If it is necessary to place a NUL character in a
       string capability it must be encoded as \200.  (The routines that deal
       with termcap use C strings and strip the high bits of the output very
       late, so that a \200 comes out as a \000 would.)
```

----

```
$ man -w -a termcap
/usr/share/man/man3/termcap.3.gz
/usr/share/man/man5/termcap.5.gz
```


```
$ man /usr/share/man/man3/termcap.3.gz 

curs_termcap(3X)                                              curs_termcap(3X)

NAME
       PC, UP, BC, ospeed, tgetent, tgetflag, tgetnum, tgetstr, tgoto, tputs -
       direct curses interface to the terminfo capability database

---- snip -----
```

----

```
$ man /usr/share/man/man5/termcap.5.gz:

TERMCAP(5)                FreeBSD File Formats Manual               TERMCAP(5)

NAME
     termcap – terminal capability data base

SYNOPSIS
     termcap

---- snip ----

     A number of escape sequences are provided in the string-valued
     capabilities for easy encoding of control characters there.  \E maps to
     an ESC character, ^X maps to a control-X for any appropriate X, and the
     sequences \n \r \t \b \f map to linefeed, return, tab, backspace, and
     formfeed, respectively.  Finally, characters may be given as three octal
     digits after a \, and the characters ^ and \ may be given as \^ and \\.
     If it is necessary to place a : in a capability it must be escaped as \:
     or be encoded as \072.  If it is necessary to place a NUL character in a
     string capability it must be encoded as \200.  (The routines that deal
     with termcap use C strings and strip the high bits of the output very
     late, so that a \200 comes out as a \000 would.)
```

----

```
man kbdmap(1)

BUGS
     The kbdmap and vidfont utilities work only on a **(virtual) console** 
     and not with X11.
```

----

````
man kbdmap(5)  
     ctrlname      One of the standard names for the ASCII control characters:
                   nul, soh, stx, etx, eot, enq, ack, bel, bs, ht, lf, vt, ff,
                   cr, so, si, dle, dc1, dc2, dc3, dc4, nak, syn, etb, can,
                   em, sub, esc, fs, gs, rs, us, sp, del.
```

----


From
[Read special keys in bash](https://unix.stackexchange.com/questions/294908/read-special-keys-in-bash/294935#294935):

> What you are missing is that most terminal descriptions (linux is in the minority here, owing to the pervasive use of hard-coded strings in .inputrc) use application mode for special keys.
> That makes cursor-keys as shown by ```tput``` and ```infocmp``` differ from what your (uninitialized) terminal sends.
> curses applications always initialize the terminal, and the terminal data base is used for that purpose.
> 
> ```dialog``` has its uses, but does not directly address this question.
> On the other hand, it is cumbersome (technically doable, rarely done) to provide a bash-only solution.
> Generally we use other languages to do this.
> 
> The problem with reading special keys is that they often are multiple bytes, including awkward characters such as ```escape``` and ```~```.
> You can do this with bash, but then you have to solve the problem of portably determining what special key this was.
> 
> ```dialog``` both handles input of special keys and takes over (temporarily) your display.
> If you really want a simple command-line program, that isn't ```dialog```.
> 
> Here is a simple program in C which reads a special key and prints it in printable (and portable) form:
>
> < ... >
>

----

```
man getcap(3)
      String capability values may contain any character.  Non-printable ASCII
      codes, new lines, and colons may be conveniently represented by the use
      of escape sequences:
  
       ^X        ('X' & 037)          control-X
       \b, \B    (ASCII 010)          backspace
       \t, \T    (ASCII 011)          tab
       \n, \N    (ASCII 012)          line feed (newline)
       \f, \F    (ASCII 014)          form feed
       \r, \R    (ASCII 015)          carriage return
       \e, \E    (ASCII 027)          escape
       \c, \C    (:)                  colon
       \\        (\)                  back slash
       \^        (^)                  caret
       \nnn      (ASCII octal nnn)
```

----


```
man terminfo(5)
         A number of escape sequences are provided in the string valued
         capabilities for easy encoding of characters there.  Both \E and \e map
         to an ESCAPE character, ^x maps to a control-x for any appropriate x,
         and the sequences \n \l \r \t \b \f \s give a newline, line-feed,
         return, tab, backspace, form-feed, and space.  


     Predefined Capabilities
         The following is a complete table of the capabilities included in a
         terminfo description block and available to terminfo-using code.  In
         each line of the table,
  
         The variable is the name by which the programmer (at the terminfo
         level) accesses the capability.
  
         The capname is the short name used in the text of the database, and is
         used by a person updating the database.  Whenever possible, capnames
         are chosen to be the same as or similar to the ANSI X3.64-1979 standard
         (now superseded by ECMA-48, which uses identical or very similar
         names).  Semantics are also intended to match those of the
         specification.
  
         The termcap code is the old termcap capability name (some capabilities
         are new, and have names which termcap did not originate).
  
         Capability names have no hard length limit, but an informal limit of 5
         characters has been adopted to keep them short and to allow the tabs in
         the source file Caps to line up nicely.
  
         Finally, the description field attempts to convey the semantics of the
         capability.  You may find some codes in the description field:
  
         (P)    indicates that padding may be specified
         #[1-9] in the description field indicates that the string is passed
                through tparm with parms as given (#i).
         (P*)   indicates that padding may vary in proportion to the number of
                lines affected
         (#i)   indicates the ith parameter.


         These are the boolean capabilities:
         ---- snip ----

         These are the numeric capabilities:
         ---- snip ----

         The following numeric capabilities are present in the SVr4.0 term
         structure, but are not yet documented in the man page.  They came in
         with SVr4's printer support.
         ---- snip ----

         These are the string capabilities:

                   Variable            Cap-     TCap   Description
                    String             name     Code
         ---- snip ----
           clear_all_tabs              tbc      ct     clear all tab stops (P)
         ---- snip ----
           clear_screen                clear    cl     clear screen and home
                                                       cursor (P*)
           clr_bol                     el1      cb     Clear to beginning of
                                                       line
           clr_eol                     el       ce     clear to end of line
                                                       (P)
           clr_eos                     ed       cd     clear to end of screen
                                                       (P*)
           column_address              hpa      ch     horizontal position
                                                       #1, absolute (P)
         ---- snip ----

           cursor_address              cup      cm     move to row #1 columns
                                                       #2
           cursor_down                 cud1     do     down one line
           cursor_home                 home     ho     home cursor (if no
                                                       cup)
         ---- snip ----
           enter_blink_mode            blink    mb     turn on blinking
           enter_bold_mode             bold     md     turn on bold (extra
                                                       bright) mode
           enter_ca_mode               smcup    ti     string to start
                                                       programs using cup
         ---- snip ----
           enter_shadow_mode           sshm     ZM     Enter shadow-print
                                                       mode
           enter_standout_mode         smso     so     begin standout mode
           enter_subscript_mode        ssubm    ZN     Enter subscript mode
           enter_superscript_mode      ssupm    ZO     Enter superscript mode
           enter_underline_mode        smul     us     begin underline mode
         ---- snip ----
           exit_attribute_mode         sgr0     me     turn off all
                                                       attributes
           exit_ca_mode                rmcup    te     strings to end
                                                       programs using cup
           exit_delete_mode            rmdc     ed     end delete mode
           exit_doublewide_mode        rwidm    ZQ     End double-wide mode
           exit_insert_mode            rmir     ei     exit insert mode
           exit_italics_mode           ritm     ZR     End italic mode
           exit_leftward_mode          rlm      ZS     End left-motion mode
           exit_micro_mode             rmicm    ZT     End micro-motion mode
           exit_shadow_mode            rshm     ZU     End shadow-print mode
           exit_standout_mode          rmso     se     exit standout mode
         ---- snip ----
           newline                     nel      nw     newline (behave like
                                                       cr followed by lf)
         ---- snip ----
           set_background              setb     Sb     Set background color #1
         ---- snip ----
           set_foreground              setf     Sf     Set foreground color #1
         ---- snip ----

         The following string capabilities are present in the SVr4.0 term
         structure, but were originally not documented in the man page.
  
  
                    Variable            Cap-       TCap   Description
                     String             name       Code

                    ---- snip ----
            set_a_background            setab      AB     Set background
                                                          color to #1, using
                                                          ANSI escape
            set_a_foreground            setaf      AF     Set foreground
                                                          color to #1, using
                                                          ANSI escape
                    ---- snip ----


          The XSI Curses standard added these hardcopy capabilities.  They were
          used in some post-4.1 versions of System V curses, e.g., Solaris 2.5
          and IRIX 6.x.  Except for YI, the ncurses termcap names for them are
          invented.  According to the XSI Curses standard, they have no termcap
          names.  If your compiled terminfo entries use these, they may not be
          binary-compatible with System V terminfo entries after SVr4.1; beware!
```

----

```
man user_caps(5)
             using a list of extended key names, ask tigetstr(3X) for their
             values, and
  
             given the list of values, ask key_defined(3X) for the key-code
             which would be returned for those keys by wgetch(3X).
```


----

```
man cat(1)
       -v      Display non-printing characters so they are visible.  Control
               characters print as ‘^X’ for control-X; the delete character
               (octal 0177) prints as ‘^?’.  Non-ASCII characters (with the high
               bit set) are printed as ‘M-’ (for meta) followed by the character
               for the low 7 bits.
```

----

From
[Control-V -- Wikipedia](https://en.wikipedia.org/wiki/Control-V):

> In computing, *Control-V* is a key stroke with a variety of uses including generation of a *control character* in *ASCII code*, also known as the *synchronous idle (SYN)* character.
> The key stroke is generated by pressing the V key while holding down the Ctrl key on a computer keyboard.
> For MacOS based systems, which lack a Ctrl key, the common replacement of the ⌘ Cmd key works. 

----

From
[Caret notation -- Wikipedia](https://en.wikipedia.org/wiki/Caret_notation):

> Caret notation (also known as ^-notation) is a notation for control characters in ASCII.
> The notation assigns ```^A``` to control-code ```1```, sequentially through the alphabet to ```^Z``` assigned to control-code ```26 (0x1A)```.
> For the control-codes outside of the range 1–26, the notation extends to the adjacent, non-alphabetic ASCII characters.
> 
> Often a control character can be typed on a keyboard by holding down the ```Ctrl``` and typing the character shown after the *caret*.
> The notation is often used to describe keyboard shortcuts even though the control character is not actually used (as in "type ```^X``` to cut the text"). 
> 
> The meaning or interpretation of, or response to the individual control-codes is not prescribed by the caret notation.  
> 
> **Description**
> 
> The notation consists of a *caret (^)* followed by a single character (usually a capital letter).
> The character has the ASCII code equal to the control code with the bit representing 0x40 reversed.
> A useful mnemonic, this has the effect of rendering the control codes ```1``` through ```26``` as ```^A``` through ``` ^Z```
>  Seven ASCII control characters map outside the upper-case alphabet: 0 (NUL) is ^@, 27 (ESC) is ^[, 28 is ^\, 29 is ^], 30 is ^^, 31 is ^_, and 127 (DEL) is ^?.
> 
> Examples are ```^M^J``` for the Windows CR, LF ```newline pair```, and describing the *ANSI escape sequence* to *clear the screen* as ```^[[3J```.
>
> Only the use of characters in the range of 63–95 ("?@ABC...XYZ[\]^_") is specifically allowed in the notation, but use of lower-case alphabetic characters entered at the keyboard is nearly always allowed - they are treated as equivalent to upper-case letters.
> When converting to a control character, except for '?', masking with 0x1F will produce the same result and also turn lower-case into the same control character as upper-case.
> 
> There is no corresponding version of the caret notation for control-codes with more than 7 bits such as the *C1 control characters* from 128-159 (0x80-0x9F). Some programs that produce caret notation show these as backslash and *octal* ("\200" through "\237").
> 

----


From
[Escape character - Wikipedia](https://en.wikipedia.org/wiki/Escape_character):

> In computing and telecommunication, an escape character is a character which invokes an alternative interpretation on subsequent characters in a character sequence.
> An escape character is a particular case of metacharacters.
> Generally, the judgment of whether something is an escape character or not depends on the context. 

----

From
[Esc key - Wikipedia](https://en.wikipedia.org/wiki/Esc_key):

> On computer keyboards, the Esc key (named Escape key in the international standard series ISO/IEC 9995) is a key used to generate the escape character (which can be represented as ASCII code 27 in decimal, Unicode U+001B, or Ctrl+[).
> The escape character, when sent from the keyboard to a computer, often is interpreted by software as "stop", and when sent from the computer to an external device (including many printers since the 1980s, computer terminals and Linux consoles, for example) marks the beginning of an escape sequence to specify operating modes or characteristics generally.
> 
> It is now generally placed at the top left corner of the keyboard, a convention dating at least to the original IBM PC keyboard, though the key itself originated decades earlier with teletypewriters. 
>

----

From
[ASCII - Wikipedia](https://en.wikipedia.org/wiki/ASCII):

> ASCII (/ˈæskiː/ ASS-kee), abbreviated from American Standard Code for Information Interchange, is a *character encoding* standard for *electronic communication*.
> ASCII codes represent text in computers, telecommunications equipment, and other devices. Most modern character-encoding schemes are based on ASCII, although they support many additional characters. 
>
> ...
> 
> **Character groups**
> 
> **Control characters**
> 
> ...
> 
> **Escape**
> 
> Many more of the control codes have been given meanings quite different from their original ones.
> The "escape" character (ESC, code 27), for example, was intended originally to allow sending other control characters as literals instead of invoking their meaning.
> This is the same meaning of "escape" encountered in URL encodings, *C language* strings, and other systems where certain characters have a reserved meaning.
> Over time this meaning has been co-opted and has eventually been changed.
> 
> In modern use, an ESC sent to the terminal usually indicates the start of a command sequence usually in the form of a so-called "ANSI escape code" - or -, more properly, a **"Control Sequence Introducer"** (**CSI**) from *ECMA-48 (1972)* and its successors, *beginning* with **ESC** *followed* by a **"[" (left-bracket)** character.
> An ESC sent from the terminal is most often used as an out-of-band character used to terminate an operation, as in the *TECO* and *vi text editors*.
> 
> In graphical user interface (GUI) and windowing systems, ESC generally causes an application to abort its current operation or to exit (terminate) altogether. 
> 
> ...
> 
> **Notes**
> 
> ...
> 
> Note c.  **Caret notation** (aka ^-notation) is often used to represent control characters on a terminal.
> On most text terminals, holding down the ```Ctrl``` key while typing the second character will type the *control character*.
> Sometimes the ```shift``` key is not needed, for instance ```^@``` may be typable with just ```Ctrl``` and ```2``` (notation: ```Ctrl+2```) or ```Ctrl``` and ```Space``` (notation: ```Ctrl+Space```).
> 

----

From
[ANSI escape code - Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code):

> ANSI escape sequences are a standard for in-band signaling to control the cursor location, color, and other options on video text terminals and terminal emulators.
> Certain sequences of bytes, most starting with Esc and '[', are embedded into the text, which the terminal looks for and interprets as commands, not as character codes. 
>
> **Escape sequences**
>
> Sequences have different lengths.
> All sequences start with ESC (27 / hex 0x1B / oct 033), followed by a second byte in the range 0x40–0x5F (ASCII @A–Z[\]^_).
>
> The standard says that in 8-bit environments these two-byte sequences can be merged into single C1 control code in the 0x80–0x9F range.
However, on modern devices those codes are often used for other purposes, such as parts of UTF-8 or for CP-1252 characters, so only the 2-byte sequence is typically used.


From 
[ANSI escape code - Wikipedia - archived on Feb 5, 2021](https://web.archive.org/web/20210205090809/https://en.wikipedia.org/wiki/ANSI_escape_code):  



> **Escape sequences**
> 
> Escape sequences vary in length.
> The general format for an ANSI-compliant escape sequence is defined by **ANSI X3.41** (equivalent to ECMA-35 or ISO/IEC 2022).
> The **ESC** (```27```, ```0x1B```, ```033```) is followed by zero or more intermediate "**I**" bytes between hex 0x20 and 0x2F inclusive, followed by a final "F" byte between 0x30 and 0x7E inclusive.
>
> Additionally, some control functions take additional parameter data following the ESC sequence itself, i.e. after the F byte of the ESC sequence.
> Specifically, the ESC sequence for **CSI** (*Control Sequence Introducer*) (```0x1B 0x5B```, or ```ESC [```) is itself followed by a sequence of parameter and intermediate bytes, followed by a final byte between 0x40 and 0x7E; the entire sequence including both the ESC sequence for *CSI* and the subsequent parameter and identifier bytes is dubbed a *"control sequence"* by *ECMA-48 (ANSI X3.64 / ISO 6429)*.
> Additionally, the ESC sequences for ```DCS```, ```SOS```, ```OSC```, ```PM``` and ```APC``` are followed by a variable-length sequence of parameter data terminated by ```ST```; this is known as a *"control string"*.
>
> ANSI X3.41 / ECMA-35 divides escape sequences into several broad categories:
>
> **Type Fe**
>> Escape sequences with no **I** bytes, and an **F** byte between 0x40 and 0x5F inclusive.
>> Delegated to the applicable *C1 control code* standard.
>> Accordingly, all escape sequences corresponding to C1 control codes from ANSI X3.64 / ECMA-48 follow this format.
>
> **Type Fs**
>> Escape sequences with no **I** bytes, and an **F** byte between 0x60 and 0x7E inclusive.
>> Used for control functions individually registered with the *ISO-IR* registry and, consequently, available even in contexts where a different C1 control code set is used.
>> Specifically, they correspond to single control functions approved by *ISO/IEC JTC 1/SC 2* and standardized by ISO or an ISO-recognised body.
>> Some of these are specified in ECMA-35 (ISO 2022 / ANSI X3.41), others in ECMA-48 (ISO 6429 / ANSI X3.64).
>> ECMA-48 refers to these as "independent control functions". 
>
> **Type Fp**
>> Escape sequences with no **I** bytes, and an **F** byte between 0x30 and 0x3F inclusive.
>> Set apart for private-use control functions.
>
> **Type nF**
>> Escape sequences with one or more **I** bytes.
>> They are further subcategorised by the low four bits of the first **I** byte, e.g. "type 2F" for sequences where the first **I** byte is ```0x22```, and by whether the **F** byte is in the private use range from 0x30 and 0x3F inclusive (e.g. "type 2Fp") or not (e.g. "type 2Ft").
>> They are mostly used for ANSI/ISO code-switching mechanisms such as those used by *ISO-2022-JP*, except for type *3F* sequences (those where the first intermediate byte is 0x23), which are used for individual control functions. 
>> Type *3Ft* sequences are reserved for additional ISO-IR registered individual control functions, while type *3Fp* sequences are available for private-use control functions.
> 
> The standard says that, in 8-bit environments, the control functions corresponding to type *Fe* escape sequences (those from the set of *C1 control codes*) can be represented as single bytes in the 0x80–0x9F range.
> However, on modern devices those codes are often used for other purposes, such as parts of *UTF-8* or for *CP-1252* characters, so only the 2-byte sequence is typically used.
> (In the case of UTF-8 and other Unicode encodings, C1 can be encoded as their Unicode codepoints [e.g. ```\xC2\x8E``` for ```U+008E```], but no space is saved this way.) 
> 
> Other C0 codes besides ESC - commonly BEL, BS, CR, LF, FF, TAB, VT, SO, and SI - produce similar or identical effects to some control sequences when output. 


**Some type Fe (C1 set element) ANSI escape sequences (not an exhaustive list)**

```
+-----------------+-------+------------+-------------------------------+
| Sequence | C1   | Short | Name       | Effect                        |
+----------+------+-------+------------+-------------------------------+
|                                                                      |
|                       ---- snip ----                                 |
|                                                                      |
| ESC [    | 0x9B | CSI   | Control    | Most of the useful sequences. |
|          |      |       | Sequence   |                               |
|          |      |       | Introducer |                               | 
+----------+------+-------+------------+-------------------------------+
```

>
> ...
> 
> **Control Sequence Introducer sequences - CSI sequences**
> 
> For *Control Sequence Introducer*, or *CSI* commands, the ```ESC [``` is *followed by* any number (including none) of **"parameter bytes"** in the range 0x30–0x3F (ASCII ```0–9:;<=>?```), then by any number of **"intermediate bytes"** in the range 0x20–0x2F (ASCII ```space``` and ```!"#$%&'()*+,-./```), then finally by a single **"final byte"** in the range 0x40–0x7E (ASCII ```@A–Z[\]^_`a–z{|}~```).
> 

----

From
[Escape sequence - Wikipedia](https://en.wikipedia.org/wiki/Escape_sequence):

> **Control sequences**
> 
> When directed this series of *characters* is used to change the *state* of *computers* and their attached *peripheral* devices, rather than to be displayed or printed as regular *data bytes* would be, these are also known as **control sequences**, reflecting their use in *device control*, beginning with the **Control Sequence Initiator** (or **Control Sequence Introducer**) - originally the **"escape character"** *ASCII code* - character ```27``` (decimal) - often written **"Esc"** on *keycaps*.
> 
> With the introduction of *ANSI terminals* most escape sequences began with the **two** characters **"ESC"** then **"["** or a specially-allocated **CSI** character with a code ```155``` (decimal).
>
> Not all control sequences used an escape character; for example:
> * modem control sequences used by *AT/Hayes-compatible modems*,
> * *Data General* terminal control sequences, but they often were still called escape sequences, and the very common use of "escaping" special characters in programming languages and command-line parameters today often use the "**backslash**" character to begin the sequence.
>
> Escape sequences in communications are commonly used when a computer and a peripheral have only a *single channel* through which to send information back and forth (so escape sequences are an example of *in-band signaling*).
> They were common when most *dumb terminals* used *ASCII* with 7 data bits for communication, and sometimes would be used to switch to a different character set for "foreign" or graphics characters that would otherwise been restricted by the 128 codes available in 7 data bits.
> Even relatively "dumb" terminals responded to some escape sequences, including the *original mechanical Teletype* printers (on which "*glass Teletypes*" or *VDUs* were based) responded to characters 27 and 31 to alternate between letters and figures modes. 

ASCII video data terminals
The VT52 terminal used simple digraph commands like escape-A: in isolation, "A" simply meant the letter "A", but as part of the escape sequence "escape-A", it had a different meaning. The VT52 also supported parameters: it was not a straightforward control language encoded as substitution.

The later VT100 terminal implemented the more sophisticated ANSI escape sequences standard (now ECMA-48) for functions such as controlling cursor movement, character set, and display enhancements. The Hewlett Packard HP 2640 series had perhaps the most elaborate escape sequences for block and character modes, programming keys and their soft labels, graphics vectors, and even saving data to tape or disk files. 

Use in Linux and Unix displays
The default text terminal, and text windows (such as using xterm) respond to ANSI escape sequences. 


----

From
[ANSI Escape Sequences - Christian Petersen - GitHub Gist](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797):
(Retrieved on Feb 18, 2024)   

> **ANSI Escape Sequences**
> 
> Standard escape codes are prefixed with ```Escape```:
> * Ctrl-Key: ```^[```
> * Octal: ```\033```
> * Unicode: ```\u001b```
> * Hexadecimal: ```\x1B```
> * Decimal: ```27```
>
> *Followed by* the *command*, sometimes delimited by opening square bracket (```[```), known as a **Control Sequence Introducer** (**CSI**), optionally followed by arguments and the command itself.
> 
> *Arguments* are *delimeted* by *semi colon* (```;```).
>
> For example:
> 
> ```
\x1b[1;31m  # Set style to bold, red foreground.
> ```
> 
> **Sequences**
>
> * **ESC** - sequence starting with **ESC** (```\x1B```)
> * **CSI** - Control Sequence Introducer: sequence starting with ```ESC [``` or **CSI** (```\x9B```)
> * **DCS** - Device Control String: sequence starting with ```ESC P``` or **DCS** (```\x90```)
> * **OSC** - Operating System Command: sequence starting with ```ESC ]``` or **OSC** (```\x9D```)
> 
> Any *whitespaces* between sequences and arguments should be *ignored*.
> They are present for *improved readability*.
>

----


From
[C0 and C1 control codes - Wikipedia - archived on Dec 10, 2021](https://web.archive.org/web/20211210075615/https://en.wikipedia.org/wiki/C0_and_C1_control_codes):    
The first column is named **Seq** (instead of Caret notation). 


From
[C0 and C1 control codes - Wikipedia - archived on Jan 11, 2022](https://web.archive.org/web/20220111021139/https://en.wikipedia.org/wiki/C0_and_C1_control_codes):    
The first column is named **Caret notation** (instead of **Seq**).

From
[C0 and C1 control codes - ESC (Escape) Character -- Wikipedia](https://en.wikipedia.org/wiki/C0_and_C1_control_codes#ESC):   
(Retrieved on Feb 18, 2024)   

> **C0 and C1 control codes**
>
> The **C0 and C1 control code** or **control character** sets define control codes for use in text by computer systems that use *ASCII* and derivatives of ASCII.
> The codes represent additional information about the text, such as the position of a cursor, an instruction to start a new line, or a message that the text has been received.
> 
> **C0** codes are the range ```00 - 1F``` (hexadecimal) and the default **C0** set was originally defined in *ISO 646* (*ASCII*).
> 
> **C1** codes are the range ```80 - 9F``` (hexadecimal) and the default **C1** set was originally defined in *ECMA-48* (harmonized later with *ISO 6429*).
> The *ISO/IEC 2022* system of specifying control and graphic characters allows other C0 and C1 sets to be available for specialized applications, but they are rarely used. 
>
> **C0 controls**
> 
> ASCII defined 32 control characters, plus a necessary extra character for the DEL character, ```7F``` (hexadecimal) or ```01111111``` (binary) (needed to punch out all the holes on a paper tape and erase it). 
> 
> ...
> 
> **ASCII control codes, originally defined in ANSI X3.4.**

```
+----------+-----+-----+----------------+--------+--------+-------------+---------------------------+
| Seq,     |     |     | Acronym        |        |        | C           | Description               |
| aka      | Dec | Hex | (Abbreviation) | Symbol | Name   | Programming |                           |
| Caret    |     |     |                |        |        | Language,   |                           |
| notation |     |     |                |        |        | aka         |                           |
|          |     |     |                |        |        | C escape    |                           |
+----------+-----+-----+----------------+--------+--------+-------------+---------------------------+
|                                                                                                   |
|                                     ---- snip ----                                                |
|                                                                                                   |
+----------+-----+-----+----------------+--------+--------+-------------+---------------------------+
| ^[       | 27  | 1B  | ESC            | ␛     | Escape | \e          | Alters the                |
|          |     |     |                |        |        | *[NOTE]     | the meaning of a          |
|          |     |     |                |        |        |             | limited number            |
|          |     |     |                |        |        |             | of following              |
|          |     |     |                |        |        |             | bytes.                    |
|          |     |     |                |        |        |             |                           |
|          |     |     |                |        |        |             | Nowadays this is          |
|          |     |     |                |        |        |             | almost always used        |
|          |     |     |                |        |        |             | to introduce an           |
|          |     |     |                |        |        |             | **ANSI escape sequence.** |
|                                                                                                   |
|                                                                                                   |
|                                     ---- snip ----                                                |
|                                                                                                   |
+----------+-----+-----+----------------+--------+--------+-------------+---------------------------+
```

```
*[NOTE]
For the C Programming Language:
The '\e' escape sequence is not part of ISO C and many other language specifications.
However, it is understood by several compilers, including GCC (GNU Compiler Collection).
```

>
> ...
>
> **C1 controls**
> 
> In 1973, *ECMA-35* and *ISO 2022* attempted to define a method so an 8-bit "extended ASCII" code could be converted to a corresponding 7-bit code, and vice versa.
> In a 7-bit environment, the Shift Out (SO) would change the meaning of the 96 bytes 0x20 through 0x7F (i.e. all but the C0 control codes), to be the characters that an 8-bit environment would print if it used the same code with the high bit set.
> This meant that the range 0x80 through 0x9F could not be printed in a 7-bit environment, thus it was decided that no alternative character set could use them, and that these codes should be additional control codes, which become known as the **C1 control codes**.
> To allow a 7-bit environment to use these new controls, the sequences ```ESC @``` through ```ESC _``` were to be considered equivalent.
> The later *ISO 8859* standards abandoned support for 7-bit codes, but preserved this range of control characters. 
> 
> The first C1 control code set to be registered for use with ISO 2022 was *DIN 31626*, a specialised set for bibliographic use which was registered in 1979.
> 
> The more common general-use *ISO/IEC 6429* set was registered in *1983*, although the *ECMA-48* specification upon which it was based had been first published in 1976 and *JIS X 0211* (formerly JIS C 6323).
> Symbolic names defined by *RFC 1345* and early drafts of ISO 10646, but not in ISO/IEC 6429 (PAD, HOP and SGC) are also used.
> 
> Except for SS2 and SS3 in *EUC-JP* text, and NEL in text transcoded from *EBCDIC*, the 8-bit forms of these codes were almost never used.
> ```CSI```, ```DCS``` and ```OSC``` are used to control *text terminals* and *terminal emulators*, but almost always by using their 7-bit escape code representations.
> Nowadays if these codes are encountered it is far more likely they are intended to be printing characters from that position of *Windows-1252* or *Mac OS Roman*.
>
> **ISO/IEC 6429 and RFC 1345 C1 control codes** 
 
```
+------+-----+-----+------+------------+-----------------------------------------------------------+
| ESC+ | Dec | Hex | Abbr | Name       | Description                                               |
+------+-----+-----+------+------------+-----------------------------------------------------------+
|                                                                                                  | 
|                                  ---- snip ----                                                  |
|                                                                                                  |
+------+-----+-----+------+------------+-----------------------------------------------------------+
| [    | 155 | 9B  | CSI  | Control    | Used to introduce control sequences that take parameters. |
|      |     |     |      | Sequence   | Used for **ANSI escape sequences**.                       |
|      |     |     |      | Introducer |                                                           |
+------+-----+-----+------+------------+-----------------------------------------------------------+
|                                                                                                  |
|                                  ---- snip ----                                                  |
|                                                                                                  |
+------+-----+-----+------+----------+--------+----------------------------------------------------+
```

----

From
[Appendix:Control characters - Wiktionary (The free dictionary)](https://en.wiktionary.org/wiki/Appendix:Control_characters):

> Besides alphabetic characters and symbols, *Unicode* also includes a variety of *control characters* with *no graphical representation*.
> While some of these are actually used to modify certain characters, others are largely disused remnants from older computing systems. 

> **C0 (ASCII and derivatives)**
> 
> C0 control codes are in the Unicode range ```U+0000``` - ```U+001F```, and were inherited from the *ASCII standard*.
> Often, these cannot be input directly because they fulfill specific low-level functions in the operating system. 

```
+-----+-----+-----+---------+--------+--------+----------------------------------------------------+
| Seq | Dec | Hex | Acronym | Name   | C      |  Description                                       |
+-----+-----+-----+---------+--------+--------+----------------------------------------------------+
|                                                                                                  |
|                                      ---- snip ----                                              |
|                                                                                                  |
+-----+-----+-----+---------+--------+--------+----------------------------------------------------+
| ^[  | 27  | 1B  | ESC     | Escape |        | The **Esc key** on the keyboard will               |
|     |     |     |         |        |        | cause this character to be sent on                 |
|     |     |     |         |        |        | most systems.  It can be used in                   |
|     |     |     |         |        |        | software user interfaces to exit from              |
|     |     |     |         |        |        | a screen, menu, or mode, or in                     |
|     |     |     |         |        |        | device-control protocols (e.g., printers           |
|     |     |     |         |        |        | and terminals) to signal that what                 |
|     |     |     |         |        |        | follows is a **special command sequence**          |
|     |     |     |         |        |        | rather than normal text.  In systems based         |
|     |     |     |         |        |        | on ISO/IEC 2022, even if another set of            |
|     |     |     |         |        |        | C0 control codes are used, this octet is           |
|     |     |     |         |        |        | required to always represent the escape character. |
+-----+-----+-----+---------+--------+--------+----------------------------------------------------+
|                                                                                                  |
|                                      ---- snip ----                                              |
|                                                                                                  |
+-----+-----+-----+---------+--------+--------+----------------------------------------------------+
```

----


From
[Metacharacter - Wikipedia](https://en.wikipedia.org/wiki/Metacharacter):

> A **metacharacter** is a character that has a special meaning to a computer program, such as a shell interpreter or a regular expression (regex) engine. 

----


From the man page for ```ssh(1)``` on FreeBSD: 

```
---- snip ----

The options are as follows:
  
---- snip ----

-e escape_char
        Sets the escape character for sessions with a pty (default: ‘~’).
        The escape character is only recognized at the beginning of a
        line.  The escape character followed by a dot (‘.’) closes the
        connection; followed by control-Z suspends the connection; and
        followed by itself sends the escape character once.  Setting the
        character to “none” disables any escapes and makes the session
        fully transparent.

---- snip ----

ESCAPE CHARACTERS

---- snip ----
~^Z     Background ssh.
```

----

On FreeBSD, refer to the following man pages:

```
curs_termcap(3X)
curses(3X)
curs_terminfo(3X)
curs_threads(3X)
ncurses(3X)
terminfo(5)
term_variables(3X)
```

```
$ locate curses.h | grep -w curses
/usr/include/curses.h
/usr/local/include/ncurses/curses.h
```

```
$ ls -lh /usr/include/curses.h
-r--r--r--  1 root  wheel 98K Apr  8  2021 /usr/include/curses.h

$ ls -lh /usr/local/include/ncurses/curses.h
-rw-r--r--  1 root  wheel 98K Oct  7 07:45 /usr/local/include/ncurses/curses.h

$ diff /usr/include/curses.h /usr/local/include/ncurses/curses.h | wc -l
     216
```

```
$ diff /usr/include/curses.h /usr/local/include/ncurses/curses.h | head
2c2
<  * Copyright 2018-2019,2020 Thomas E. Dickey                                *
---
>  * Copyright 2018-2020,2021 Thomas E. Dickey                                *
36c36
< /* $Id: curses.h.in,v 1.266 2020/02/08 10:51:53 tom Exp $ */
---
> /* $Id: curses.h.in,v 1.277 2021/09/24 16:07:37 tom Exp $ */
40a41,68
> /*
```

```
$ wc -l /usr/include/curses.h
    2113 /usr/include/curses.h
 
$ wc -l /usr/local/include/ncurses/curses.h
    2114 /usr/local/include/ncurses/curses.h
```

----


```
$ freebsd-version
12.0-RELEASE-p10
 
$ uname -a
FreeBSD freebsd3.my.domain 12.0-RELEASE-p10 FreeBSD 12.0-RELEASE-p10 GENERIC  amd64
 
$ ps $$
  PID TT  STAT    TIME COMMAND
53440  5  Ss   0:00.62 -tcsh (tcsh)
 
$ printf %s\\n "$SHELL"
/bin/tcsh
 
$ printf %s\\n "$TERM"
xterm-new
```
 
```
$ tset -s
Erase is backspace.
set noglob;
setenv TERM xterm-new;
setenv TERMCAP 'xterm-new:@7=\EOF:@8=\EOM:F1=\E[23~:F2=\E[24~:K2=\EOE:Km=\E[M:k1=\EOP:k2=\EOQ:k3=\EOR:k4=\EOS:k5=\E[15~:k6=\E[17~:k7=\E[18~:k8=\E[19~:k9=\E[20~:k;=\E[21~:kI=\E[2~:kN=\E[6~:kP=\E[5~:kd=\EOB:kh=\EOH:kl=\EOD:kr=\EOC:ku=\EOA:am:bs:km:mi:ms:ut:xn:AX:Co#8:co#80:kn#12:li#24:pa#64:AB=\E[4%dm:AF=\E[3%dm:AL=\E[%dL:DC=\E[%dP:DL=\E[%dM:DO=\E[%dB:LE=\E[%dD:RI=\E[%dC:UP=\E[%dA:ae=\E(B:al=\E[L:as=\E(0:bl=^G:cd=\E[J:ce=\E[K:cl=\E[H\E[2J:cm=\E[%i%d;%dH:cs=\E[%i%d;%dr:ct=\E[3g:dc=\E[P:dl=\E[M:ei=\E[4l:ho=\E[H:im=\E[4h:is=\E[\041p\E[?3;4l\E[4l\E>:kD=\E[3~:kb=^H:ke=\E[?1l\E>:ks=\E[?1h\E=:kB=\E[Z:le=^H:md=\E[1m:me=\E[m:ml=\El:mr=\E[7m:mu=\Em:nd=\E[C:op=\E[39;49m:rc=\E8:rs=\E[\041p\E[?3;4l\E[4l\E>:sc=\E7:se=\E[27m:sf=^J:so=\E[7m:sr=\EM:st=\EH:ue=\E[24m:up=\E[A:us=\E[4m:ve=\E[?12l\E[?25h:vi=\E[?25l:vs=\E[?12;25h:';
unset noglob;
 
$ stty
speed 38400 baud;
lflags: echoe echok echoke echoctl
iflags: -ixany -imaxbel -brkint
oflags: tab3
cflags: cs7 parenb
erase   
^H      
 
$ stty -a
speed 38400 baud; 34 rows; 144 columns;
lflags: icanon isig iexten echo echoe echok echoke -echonl echoctl
        -echoprt -altwerase -noflsh -tostop -flusho -pendin -nokerninfo
        -extproc
iflags: -istrip icrnl -inlcr -igncr ixon -ixoff -ixany -imaxbel -ignbrk
        -brkint -inpck -ignpar -parmrk
oflags: opost onlcr -ocrnl tab3 -onocr -onlret
cflags: cread cs7 parenb -parodd hupcl -clocal -cstopb -crtscts -dsrflow
        -dtrflow -mdmbuf
cchars: discard = ^O; dsusp = ^Y; eof = ^D; eol = <undef>;
        eol2 = <undef>; erase = ^H; erase2 = ^H; intr = ^C; kill = ^U;
        lnext = ^V; min = 1; quit = ^\; reprint = ^R; start = ^Q;
        status = ^T; stop = ^S; susp = ^Z; time = 0; werase = ^W;
 
$ stty -e
speed 38400 baud; 34 rows; 144 columns;
lflags: icanon isig iexten echo echoe echok echoke -echonl echoctl
        -echoprt -altwerase -noflsh -tostop -flusho -pendin -nokerninfo
        -extproc
iflags: -istrip icrnl -inlcr -igncr ixon -ixoff -ixany -imaxbel -ignbrk
        -brkint -inpck -ignpar -parmrk
oflags: opost onlcr -ocrnl tab3 -onocr -onlret
cflags: cread cs7 parenb -parodd hupcl -clocal -cstopb -crtscts -dsrflow
        -dtrflow -mdmbuf
discard dsusp   eof     eol     eol2    erase   erase2  intr    kill    
^O      ^Y      ^D      <undef> <undef> ^H      ^H      ^C      ^U      
lnext   min     quit    reprint start   status  stop    susp    time    
^V      1       ^\      ^R      ^Q      ^T      ^S      ^Z      0       
werase  
^W      
 
$ stty -g
gfmt1:cflag=5a00:iflag=300:lflag=5cf:oflag=7:discard=f:dsusp=19:eof=4:eol=ff:eol2=ff:erase=8:erase2=8:intr=3:kill=15:lnext=16:min=1:quit=1c:reprint=12:start=11:status=14:stop=13:susp=1a:time=0:werase=17:ispeed=38400:ospeed=38400
 
$ stty all
speed 38400 baud; 34 rows; 144 columns;
lflags: icanon isig iexten echo echoe echok echoke -echonl echoctl
        -echoprt -altwerase -noflsh -tostop -flusho -pendin -nokerninfo
        -extproc
iflags: -istrip icrnl -inlcr -igncr ixon -ixoff -ixany -imaxbel -ignbrk
        -brkint -inpck -ignpar -parmrk
oflags: opost onlcr -ocrnl tab3 -onocr -onlret
cflags: cread cs7 parenb -parodd hupcl -clocal -cstopb -crtscts -dsrflow
        -dtrflow -mdmbuf
discard dsusp   eof     eol     eol2    erase   erase2  intr    kill    
^O      ^Y      ^D      <undef> <undef> ^H      ^H      ^C      ^U      
lnext   min     quit    reprint start   status  stop    susp    time    
^V      1       ^\      ^R      ^Q      ^T      ^S      ^Z      0       
werase  
^W      
 
$ tty
/dev/pts/5
 
$ bindkey | wc -l
     155
 
$ bindkey | grep -i esc
 
$ bindkey | grep -i control
 
$ bindkey | grep -i ctrl
 
$ bindkey | grep '\[' | wc -l
      22
 
$ bindkey | grep '\[' 
"^["           ->  vi-cmd-mode
"^["           ->  sequence-lead-in
"["            ->  sequence-lead-in
"^[[A"         -> history-search-backward
"^[[B"         -> history-search-forward
"^[[C"         -> forward-char
"^[[D"         -> backward-char
"^[[H"         -> beginning-of-line
"^[[F"         -> end-of-line
"^[OA"         -> history-search-backward
"^[OB"         -> history-search-forward
"^[OC"         -> forward-char
"^[OD"         -> backward-char
"^[OH"         -> beginning-of-line
"^[OF"         -> end-of-line
"^[?"          -> run-help
"[A"           -> history-search-backward
"[B"           -> history-search-forward
"[C"           -> forward-char
"[D"           -> backward-char
"[H"           -> beginning-of-line
"[F"           -> end-of-line
 
$ bindkey | grep '\[' | grep 'sequence-lead-in'
"^["           ->  sequence-lead-in
"["            ->  sequence-lead-in
 
$ bindkey -l | wc -l
     246
 
$ bindkey -l 
backward-char
          Move back a character
backward-delete-char
          Delete the character behind cursor
backward-delete-word
          Cut from beginning of current word to cursor - saved in cut buffer
backward-kill-line
          Cut from beginning of line to cursor - save in cut buffer
backward-word
          Move to beginning of current word
beginning-of-line
          Move to beginning of line
capitalize-word
          Capitalize the characters from cursor to end of current word
change-case
          Vi change case of character under cursor and advance one character
change-till-end-of-line
          Vi change to end of line
clear-screen
          Clear screen leaving current line on top
complete-word
          Complete current word
complete-word-fwd
          Tab forward through files
complete-word-back
          Tab backward through files
complete-word-raw
          Complete current word ignoring programmable completions
copy-prev-word
          Copy current word to cursor
copy-region-as-kill
          Copy area between mark and cursor to cut buffer
dabbrev-expand
          Expand to preceding word for which this is a prefix
delete-char
          Delete character under cursor
delete-char-or-eof
          Delete character under cursor or signal end of file on an empty line
delete-char-or-list
          Delete character under cursor or list completions if at end of line
delete-char-or-list-or-eof
          Delete character under cursor, list completions or signal end of file
delete-word
          Cut from cursor to end of current word - save in cut buffer
digit
          Adds to argument if started or enters digit
digit-argument
          Digit that starts argument
down-history
          Move to next history line
downcase-word
          Lowercase the characters from cursor to end of current word
end-of-file
          Indicate end of file
end-of-line
          Move cursor to end of line
exchange-point-and-mark
          Exchange the cursor and mark
expand-glob
          Expand file name wildcards
expand-history
          Expand history escapes
expand-line
          Expand the history escapes in a line
expand-variables
          Expand variables
forward-char
          Move forward one character
forward-word
          Move forward to end of current word
gosmacs-transpose-chars
          Exchange the two characters before the cursor
history-search-backward
          Search in history backward for line beginning as current
history-search-forward
          Search in history forward for line beginning as current
insert-last-word
          Insert last item of previous command
i-search-fwd
          Incremental search forward
i-search-back
          Incremental search backward
keyboard-quit
          Clear line
kill-line
          Cut to end of line and save in cut buffer
kill-region
          Cut area between mark and cursor and save in cut buffer
kill-whole-line
          Cut the entire line and save in cut buffer
list-choices
          List choices for completion
list-choices-raw
          List choices for completion overriding programmable completion
list-glob
          List file name wildcard matches
list-or-eof
          List choices for completion or indicate end of file if empty line
load-average
          Display load average and current process status
magic-space
          Expand history escapes and insert a space
newline
          Execute command
newline-and-hold
          Execute command and keep current line
newline-and-down-history
          Execute command and move to next history line
normalize-path
          Expand pathnames, eliminating leading .'s and ..'s
normalize-command
          Expand commands to the resulting pathname or alias
overwrite-mode
          Switch from insert to overwrite mode or vice versa
prefix-meta
          Add 8th bit to next character typed
quoted-insert
          Add the next character typed to the line verbatim
redisplay
          Redisplay everything
run-fg-editor
          Restart stopped editor
run-help
          Look for help on current command
self-insert-command
          This character is added to the line
sequence-lead-in
          This character is the first in a character sequence
set-mark-command
          Set the mark at cursor
spell-word
          Correct the spelling of current word
spell-line
          Correct the spelling of entire line
stuff-char
          Send character to tty in cooked mode
toggle-literal-history
          Toggle between literal and lexical current history line
transpose-chars
          Exchange the character to the left of the cursor with the one under
transpose-gosling
          Exchange the two characters before the cursor
tty-dsusp
          Tty delayed suspend character
tty-flush-output
          Tty flush output character
tty-sigintr
          Tty interrupt character
tty-sigquit
          Tty quit character
tty-sigtsusp
          Tty suspend character
tty-start-output
          Tty allow output character
tty-stop-output
          Tty disallow output character
undefined-key
          Indicates unbound character
universal-argument
          Emacs universal argument (argument times 4)
up-history
          Move to previous history line
upcase-word
          Uppercase the characters from cursor to end of current word
vi-beginning-of-next-word
          Vi goto the beginning of next word
vi-add
          Vi enter insert mode after the cursor
vi-add-at-eol
          Vi enter insert mode at end of line
vi-chg-case
          Vi change case of character under cursor and advance one character
vi-chg-meta
          Vi change prefix command
vi-chg-to-eol
          Vi change to end of line
vi-cmd-mode
          Enter vi command mode (use alternative key bindings)
vi-cmd-mode-complete
          Vi command mode complete current word
vi-delprev
          Vi move to previous character (backspace)
vi-delmeta
          Vi delete prefix command
vi-endword
          Vi move to the end of the current space delimited word
vi-eword
          Vi move to the end of the current word
vi-char-back
          Vi move to the character specified backward
vi-char-fwd
          Vi move to the character specified forward
vi-charto-back
          Vi move up to the character specified backward
vi-charto-fwd
          Vi move up to the character specified forward
vi-insert
          Enter vi insert mode
vi-insert-at-bol
          Enter vi insert mode at beginning of line
vi-repeat-char-fwd
          Vi repeat current character search in the same search direction
vi-repeat-char-back
          Vi repeat current character search in the opposite search direction
vi-repeat-search-fwd
          Vi repeat current search in the same search direction
vi-repeat-search-back
          Vi repeat current search in the opposite search direction
vi-replace-char
          Vi replace character under the cursor with the next character typed
vi-replace-mode
          Vi replace mode
vi-search-back
          Vi search history backward
vi-search-fwd
          Vi search history forward
vi-substitute-char
          Vi replace character under the cursor and enter insert mode
vi-substitute-line
          Vi replace entire line
vi-word-back
          Vi move to the previous word
vi-word-fwd
          Vi move to the next word
vi-undo
          Vi undo last change
vi-zero
          Vi goto the beginning of line
which-command
          Perform which of current command
yank
          Paste cut buffer at cursor position
yank-pop
          Replace just-yanked text with yank from earlier kill
e_copy_to_clipboard
          (WIN32 only) Copy cut buffer to system clipboard
e_paste_from_clipboard
          (WIN32 only) Paste clipboard buffer at cursor position
e_dosify_next
          (WIN32 only) Convert each '/' in next word to '\\'
e_dosify_prev
          (WIN32 only) Convert each '/' in previous word to '\\'
e_page_up
          (WIN32 only) Page visible console window up
e_page_down
          (WIN32 only) Page visible console window down
 
$ bindkey -l | grep -A1 'sequence-lead-in'
sequence-lead-in
          This character is the first in a character sequence
 
$ bindkdy -a | wc -l
bindkdy: Command not found.
       0
 
$ bindkey -a | wc -l
     155
 
$ bindkey -a 
Standard key bindings
"^@"           ->  is undefined
"^A"           ->  beginning-of-line
"^B"           ->  backward-char
"^C"           ->  tty-sigintr
"^D"           ->  list-or-eof
"^E"           ->  end-of-line
"^F"           ->  forward-char
"^G"           ->  list-glob
"^H"           ->  backward-delete-char
"^I"           ->  complete-word
"^J"           ->  newline
"^K"           ->  kill-line
"^L"           ->  clear-screen
"^M"           ->  newline
"^N"           ->  down-history
"^O"           ->  tty-flush-output
"^P"           ->  up-history
"^Q"           ->  tty-start-output
"^R"           ->  redisplay
"^S"           ->  tty-stop-output
"^T"           ->  transpose-chars
"^U"           ->  backward-kill-line
"^V"           ->  quoted-insert
"^W"           ->  backward-delete-word
"^X"           ->  expand-line
"^Y"           ->  tty-dsusp
"^Z"           ->  tty-sigtsusp
"^["           ->  vi-cmd-mode
"^\"           ->  tty-sigquit
" "  to "~"    ->  self-insert-command
"^?"           ->  backward-delete-char
"B!" to "C?"   ->  self-insert-command
Alternative key bindings
"^@"           ->  is undefined
"^A"           ->  beginning-of-line
"^B"           ->  is undefined
"^C"           ->  tty-sigintr
"^D"           ->  list-choices
"^E"           ->  end-of-line
"^F"           ->  is undefined
"^G"           ->  list-glob
"^H"           ->  backward-char
"^I"           ->  vi-cmd-mode-complete
"^J"           ->  newline
"^K"           ->  kill-line
"^L"           ->  clear-screen
"^M"           ->  newline
"^N"           ->  down-history
"^O"           ->  tty-flush-output
"^P"           ->  up-history
"^Q"           ->  tty-start-output
"^R"           ->  redisplay
"^S"           ->  tty-stop-output
"^T"           ->  is undefined
"^U"           ->  backward-kill-line
"^V"           ->  is undefined
"^W"           ->  backward-delete-word
"^X"           ->  expand-line
"^["           ->  sequence-lead-in
"^\"           ->  tty-sigquit
" "            ->  forward-char
"!"            ->  expand-history
"$"            ->  end-of-line
"*"            ->  expand-glob
"+"            ->  down-history
","            ->  vi-repeat-char-back
"-"            ->  up-history
"."            ->  is undefined
"/"            ->  vi-search-fwd
"0"            ->  vi-zero
"1"  to "9"    ->  digit-argument
":"            ->  is undefined
";"            ->  vi-repeat-char-fwd
"?"            ->  vi-search-back
"@"            ->  is undefined
"A"            ->  vi-add-at-eol
"B"            ->  vi-word-back
"C"            ->  change-till-end-of-line
"D"            ->  kill-line
"E"            ->  vi-endword
"F"            ->  vi-char-back
"I"            ->  vi-insert-at-bol
"J"            ->  history-search-forward
"K"            ->  history-search-backward
"N"            ->  vi-repeat-search-back
"O"            ->  sequence-lead-in
"R"            ->  vi-replace-mode
"S"            ->  vi-substitute-line
"T"            ->  vi-charto-back
"U"            ->  is undefined
"V"            ->  expand-variables
"W"            ->  vi-word-fwd
"X"            ->  backward-delete-char
"["            ->  sequence-lead-in
"\^"           ->  beginning-of-line
"a"            ->  vi-add
"b"            ->  backward-word
"c"            ->  vi-chg-meta
"d"            ->  vi-delmeta
"e"            ->  vi-eword
"f"            ->  vi-char-fwd
"g"            ->  is undefined
"h"            ->  backward-char
"i"            ->  vi-insert
"j"            ->  down-history
"k"            ->  up-history
"l"            ->  forward-char
"m"            ->  is undefined
"n"            ->  vi-repeat-search-fwd
"r"            ->  vi-replace-char
"s"            ->  vi-substitute-char
"t"            ->  vi-charto-fwd
"u"            ->  vi-undo
"v"            ->  expand-variables
"w"            ->  vi-beginning-of-next-word
"x"            ->  delete-char-or-eof
"~"            ->  change-case
"^?"           ->  backward-delete-char
"B?"           ->  run-help
"C"           ->  sequence-lead-in
"C"           ->  sequence-lead-in
Multi-character bindings
"^[[A"         -> history-search-backward
"^[[B"         -> history-search-forward
"^[[C"         -> forward-char
"^[[D"         -> backward-char
"^[[H"         -> beginning-of-line
"^[[F"         -> end-of-line
"^[OA"         -> history-search-backward
"^[OB"         -> history-search-forward
"^[OC"         -> forward-char
"^[OD"         -> backward-char
"^[OH"         -> beginning-of-line
"^[OF"         -> end-of-line
"^[?"          -> run-help
"[A"           -> history-search-backward
"[B"           -> history-search-forward
"[C"           -> forward-char
"[D"           -> backward-char
"[H"           -> beginning-of-line
"[F"           -> end-of-line
"OA"           -> history-search-backward
"OB"           -> history-search-forward
"OC"           -> forward-char
"OD"           -> backward-char
"OH"           -> beginning-of-line
"OF"           -> end-of-line
Arrow key bindings
down           -> history-search-forward
up             -> history-search-backward
left           -> backward-char
right          -> forward-char
home           -> beginning-of-line
end            -> end-of-line
 
$ bindkey -a | grep -n 'sequence-lead-in'
60:"^["           ->  sequence-lead-in
87:"O"            ->  sequence-lead-in
95:"["            ->  sequence-lead-in
121:"Ï"           ->  sequence-lead-in
122:"Û"           ->  sequence-lead-in
``` 
 
 
```
$ printf '%d\n' '"^\'
94
 
$ printf '%d\n' '"^['
94
$ 
$ printf '%d\n' '\^['
printf: \^[: expected numeric value
0
 
$ printf '%d\n' 
0
 
$ printf '%d\n' 6
6
 
$ printf '%d\n' a
printf: a: expected numeric value
0
 
$ printf '%d\n' '\a'
printf: \a: expected numeric value
0
 
$ printf '%d\n' 'a'
printf: a: expected numeric value
0
 
$ printf '%s\n' "${red//$'\e'/\\E}"
Missing '}'.
 
$ tput xterm-clear clear | od -c
0000000  033   [   H 033   [   2   J                                    
0000007
 
$ tput xterm-clear clear | od -x
0000000      5b1b    1b48    325b    004a                                
0000007
 
$ tput xterm-clear clear | od -d
0000000     23323    6984   12891      74                                
0000007
 
$ tput xterm-clear clear | od 
0000000    055433  015510  031133  000112                                
0000007
 
$ tput xterm-clear clear | od -b
0000000   033 133 110 033 133 062 112                                    
0000007
 
$ tput xterm-clear clear | od -c
0000000  033   [   H 033   [   2   J                                    
0000007
 
$ tput xterm-clear clear | od -a
0000000  esc   [   H esc   [   2   J                                    
0000007
 
$ tput xterm-clear clear | od -t a
0000000  esc   [   H esc   [   2   J                                    
0000007
 
$ tput xterm-clear clear | od -v
0000000    055433  015510  031133  000112                                
0000007
 
$ tput xterm-clear clear | od -a
0000000  esc   [   H esc   [   2   J                                    
0000007
 
$ tput xterm-clear clear | od -a -v
0000000  esc   [   H esc   [   2   J                                    
0000007
 
$ tput xterm-clear clear | od 
0000000    055433  015510  031133  000112                                
0000007
 
$ tput xterm-clear clear | hexdump -c
0000000 033   [   H 033   [   2   J                                    
0000007
 
$ tput xterm-clear clear | hexdump -b
0000000 033 133 110 033 133 062 112                                    
0000007
 
$ tput xterm-clear clear | hexdump -C
00000000  1b 5b 48 1b 5b 32 4a                              |.[H.[2J|
00000007
 
$ tput xterm-clear clear | hexdump -o
0000000  055433  015510  031133  000112                                
0000007
 
$ tput xterm-clear clear | hexdump -v
0000000 5b1b 1b48 325b 004a                    
0000007
 
$ tput xterm-clear clear | hexdump -v -C
00000000  1b 5b 48 1b 5b 32 4a                              |.[H.[2J|
00000007
 
$ tput xterm-clear clear | hexdump -v -o
0000000  055433  015510  031133  000112                                
0000007
 
$ tput xterm-clear clear | hexdump -v -b
0000000 033 133 110 033 133 062 112                                    
0000007
 
$ tput xterm-clear clear | hexdump -v -x
0000000    5b1b    1b48    325b    004a                                
0000007
``` 


```
$ tset -S
Erase is backspace.
xterm-new xterm-new:@7=\EOF:@8=\EOM:F1=\E[23~:F2=\E[24~:K2=\EOE:Km=\E[M:k1=\EOP:k2=\EOQ:k3=\EOR:k4=\EOS:k5=\E[15~:k6=\E[17~:k7=\E[18~:k8=\E[19~:k9=\E[20~:k;=\E[21~:kI=\E[2~:kN=\E[6~:kP=\E[5~:kd=\EOB:kh=\EOH:kl=\EOD:kr=\EOC:ku=\EOA:am:bs:km:mi:ms:ut:xn:AX:Co#8:co#80:kn#12:li#24:pa#64:AB=\E[4%dm:AF=\E[3%dm:AL=\E[%dL:DC=\E[%dP:DL=\E[%dM:DO=\E[%dB:LE=\E[%dD:RI=\E[%dC:UP=\E[%dA:ae=\E(B:al=\E[L:as=\E(0:bl=^G:cd=\E[J:ce=\E[K:cl=\E[H\E[2J:cm=\E[%i%d;%dH:cs=\E[%i%d;%dr:ct=\E[3g:dc=\E[P:dl=\E[M:ei=\E[4l:ho=\E[H:im=\E[4h:is=\E[\041p\E[?3;4l\E[4l\E>:kD=\E[3~:kb=^H:ke=\E[?1l\E>:ks=\E[?1h\E=:kB=\E[Z:le=^H:md=\E[1m:me=\E[m:ml=\El:mr=\E[7m:mu=\Em:nd=\E[C:op=\E[39;49m:rc=\E8:rs=\E[\041p\E[?3;4l\E[4l\E>:sc=\E7:se=\E[27m:sf=^J:so=\E[7m:sr=\EM:st=\EH:ue=\E[24m:up=\E[A:us=\E[4m:ve=\E[?12l\E[?25h:vi=\E[?25l:vs=\E[?12;25h:$ 
 
$ tset -s
Erase is backspace.
set noglob;
setenv TERM xterm-new;
setenv TERMCAP 'xterm-new:@7=\EOF:@8=\EOM:F1=\E[23~:F2=\E[24~:K2=\EOE:Km=\E[M:k1=\EOP:k2=\EOQ:k3=\EOR:k4=\EOS:k5=\E[15~:k6=\E[17~:k7=\E[18~:k8=\E[19~:k9=\E[20~:k;=\E[21~:kI=\E[2~:kN=\E[6~:kP=\E[5~:kd=\EOB:kh=\EOH:kl=\EOD:kr=\EOC:ku=\EOA:am:bs:km:mi:ms:ut:xn:AX:Co#8:co#80:kn#12:li#24:pa#64:AB=\E[4%dm:AF=\E[3%dm:AL=\E[%dL:DC=\E[%dP:DL=\E[%dM:DO=\E[%dB:LE=\E[%dD:RI=\E[%dC:UP=\E[%dA:ae=\E(B:al=\E[L:as=\E(0:bl=^G:cd=\E[J:ce=\E[K:cl=\E[H\E[2J:cm=\E[%i%d;%dH:cs=\E[%i%d;%dr:ct=\E[3g:dc=\E[P:dl=\E[M:ei=\E[4l:ho=\E[H:im=\E[4h:is=\E[\041p\E[?3;4l\E[4l\E>:kD=\E[3~:kb=^H:ke=\E[?1l\E>:ks=\E[?1h\E=:kB=\E[Z:le=^H:md=\E[1m:me=\E[m:ml=\El:mr=\E[7m:mu=\Em:nd=\E[C:op=\E[39;49m:rc=\E8:rs=\E[\041p\E[?3;4l\E[4l\E>:sc=\E7:se=\E[27m:sf=^J:so=\E[7m:sr=\EM:st=\EH:ue=\E[24m:up=\E[A:us=\E[4m:ve=\E[?12l\E[?25h:vi=\E[?25l:vs=\E[?12;25h:';
unset noglob;
``` 

 
```
$ infocmp 
#     Reconstructed via infocmp from file: /usr/local/share/misc/terminfo.db
xterm-new|modern xterm terminal emulator,
      am, bce, km, mc5i, mir, msgr, npc, xenl,
      colors#8, cols#80, it#8, lines#24, pairs#64,
      acsc=``aaffggiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz{ { | | } }~~,
      bel=^G, blink=\E[5m, bold=\E[1m, cbt=\E[Z, civis=\E[?25l,
      clear=\E[H\E[2J, cnorm=\E[?12l\E[?25h, cr=\r,
      csr=\E[%i%p1%d;%p2%dr, cub=\E[%p1%dD, cub1=^H,
      cud=\E[%p1%dB, cud1=\n, cuf=\E[%p1%dC, cuf1=\E[C,
      cup=\E[%i%p1%d;%p2%dH, cuu=\E[%p1%dA, cuu1=\E[A,
      cvvis=\E[?12;25h, dch=\E[%p1%dP, dch1=\E[P, dim=\E[2m,
      dl=\E[%p1%dM, dl1=\E[M, ech=\E[%p1%dX, ed=\E[J, el=\E[K,
      el1=\E[1K, flash=\E[?5h$<100/>\E[?5l, home=\E[H,
      hpa=\E[%i%p1%dG, ht=^I, hts=\EH, ich=\E[%p1%d@,
      il=\E[%p1%dL, il1=\E[L, ind=\n, indn=\E[%p1%dS,
      invis=\E[8m, is2=\E[!p\E[?3;4l\E[4l\E>, kDC=\E[3;2~,
      kEND=\E[1;2F, kHOM=\E[1;2H, kIC=\E[2;2~, kLFT=\E[1;2D,
      kNXT=\E[6;2~, kPRV=\E[5;2~, kRIT=\E[1;2C, ka1=\EOw,
      ka3=\EOy, kb2=\EOu, kbs=^H, kc1=\EOq, kc3=\EOs, kcbt=\E[Z,
      kcub1=\EOD, kcud1=\EOB, kcuf1=\EOC, kcuu1=\EOA,
      kdch1=\E[3~, kend=\EOF, kent=\EOM, kf1=\EOP, kf10=\E[21~,
      kf11=\E[23~, kf12=\E[24~, kf13=\E[1;2P, kf14=\E[1;2Q,
      kf15=\E[1;2R, kf16=\E[1;2S, kf17=\E[15;2~, kf18=\E[17;2~,
      kf19=\E[18;2~, kf2=\EOQ, kf20=\E[19;2~, kf21=\E[20;2~,
      kf22=\E[21;2~, kf23=\E[23;2~, kf24=\E[24;2~,
      kf25=\E[1;5P, kf26=\E[1;5Q, kf27=\E[1;5R, kf28=\E[1;5S,
      kf29=\E[15;5~, kf3=\EOR, kf30=\E[17;5~, kf31=\E[18;5~,
      kf32=\E[19;5~, kf33=\E[20;5~, kf34=\E[21;5~,
      kf35=\E[23;5~, kf36=\E[24;5~, kf37=\E[1;6P, kf38=\E[1;6Q,
      kf39=\E[1;6R, kf4=\EOS, kf40=\E[1;6S, kf41=\E[15;6~,
      kf42=\E[17;6~, kf43=\E[18;6~, kf44=\E[19;6~,
      kf45=\E[20;6~, kf46=\E[21;6~, kf47=\E[23;6~,
      kf48=\E[24;6~, kf49=\E[1;3P, kf5=\E[15~, kf50=\E[1;3Q,
      kf51=\E[1;3R, kf52=\E[1;3S, kf53=\E[15;3~, kf54=\E[17;3~,
      kf55=\E[18;3~, kf56=\E[19;3~, kf57=\E[20;3~,
      kf58=\E[21;3~, kf59=\E[23;3~, kf6=\E[17~, kf60=\E[24;3~,
      kf61=\E[1;4P, kf62=\E[1;4Q, kf63=\E[1;4R, kf7=\E[18~,
      kf8=\E[19~, kf9=\E[20~, khome=\EOH, kich1=\E[2~,
      kind=\E[1;2B, kmous=\E[<, knp=\E[6~, kpp=\E[5~,
      kri=\E[1;2A, mc0=\E[i, mc4=\E[4i, mc5=\E[5i, meml=\El,
      memu=\Em, mgc=\E[?69l, op=\E[39;49m, rc=\E8,
      rep=%p1%c\E[%p2%{1}%-%db, rev=\E[7m, ri=\EM,
      rin=\E[%p1%dT, ritm=\E[23m, rmacs=\E(B, rmam=\E[?7l,
      rmcup=\E[?1049l\E[23;0;0t, rmir=\E[4l, rmkx=\E[?1l\E>,
      rmm=\E[?1034l, rmso=\E[27m, rmul=\E[24m, rs1=\Ec,
      rs2=\E[!p\E[?3;4l\E[4l\E>, sc=\E7, setab=\E[4%p1%dm,
      setaf=\E[3%p1%dm,
      setb=\E[4%?%p1%{1}%=%t4%e%p1%{3}%=%t6%e%p1%{4}%=%t1%e%p1%{6}%=%t3%e%p1%d%;m,
      setf=\E[3%?%p1%{1}%=%t4%e%p1%{3}%=%t6%e%p1%{4}%=%t1%e%p1%{6}%=%t3%e%p1%d%;m,
      sgr=%?%p9%t\E(0%e\E(B%;\E[0%?%p6%t;1%;%?%p5%t;2%;%?%p2%t;4%;%?%p1%p3%|%t;7%;%?%p4%t;5%;%?%p7%t;8%;m,
      sgr0=\E(B\E[m, sitm=\E[3m, smacs=\E(0, smam=\E[?7h,
      smcup=\E[?1049h\E[22;0;0t,
      smglr=\E[?69h\E[%i%p1%d;%p2%ds, smir=\E[4h,
      smkx=\E[?1h\E=, smm=\E[?1034h, smso=\E[7m, smul=\E[4m,
      tbc=\E[3g, u6=\E[%i%d;%dR, u7=\E[6n,
      u8=\E[?%[;0123456789]c, u9=\E[c, vpa=\E[%i%p1%dd,
```
 
``` 
$ infocmp -K
#     Reconstructed via infocmp from file: /usr/local/share/misc/terminfo.db
# (untranslatable capabilities removed to fit entry within 1023 bytes)
xterm-new|modern xterm terminal emulator:\
      :am:bs:km:mi:ms:xn:\
      :co#80:it#8:li#24:\
      :AL=\E[%dL:DC=\E[%dP:DL=\E[%dM:DO=\E[%dB:IC=\E[%d@:\
      :K1=\EOw:K2=\EOu:K3=\EOy:K4=\EOq:K5=\EOs:LE=\E[%dD:\
      :RI=\E[%dC:SF=\E[%dS:SR=\E[%dT:UP=\E[%dA:ae=\E(B:al=\E[L:\
      :as=\E(0:bl=^G:bt=\E[Z:cd=\E[J:ce=\E[K:cl=\E[H\E[2J:\
      :cm=\E[%i%d;%dH:cr=\r:cs=\E[%i%d;%dr:ct=\E[3g:dc=\E[P:\
      :dl=\E[M:do=\n:ec=\E[%dX:ei=\E[4l:ho=\E[H:im=\E[4h:\
      :is=\E[!p\E[?3;4l\E[4l\E>:k1=\EOP:k2=\EOQ:k3=\EOR:\
      :k4=\EOS:k5=\E[15~:k6=\E[17~:k7=\E[18~:k8=\E[19~:\
      :k9=\E[20~:kD=\E[3~:kI=\E[2~:kN=\E[6~:kP=\E[5~:kb=^H:\
      :kd=\EOB:ke=\E[?1l\E>:kh=\EOH:kl=\EOD:kr=\EOC:\
      :ks=\E[?1h\E=:ku=\EOA:le=^H:mb=\E[5m:md=\E[1m:me=\E[0m:\
      :mh=\E[2m:mm=\E[?1034h:mo=\E[?1034l:mr=\E[7m:nd=\E[C:\
      :rc=\E8:sc=\E7:se=\E[27m:sf=\n:so=\E[7m:sr=\EM:st=\EH:ta=^I:\
      :te=\E[?1049l\E[23;0;0t:ti=\E[?1049h\E[22;0;0t:\
      :ue=\E[24m:up=\E[A:us=\E[4m:vb=\E[?5h\E[?5l:\
      :ve=\E[?12l\E[?25h:vi=\E[?25l:vs=\E[?12;25h:
 
$ stty -e
speed 38400 baud; 34 rows; 144 columns;
lflags: icanon isig iexten echo echoe echok echoke -echonl echoctl
        -echoprt -altwerase -noflsh -tostop -flusho -pendin -nokerninfo
        -extproc
iflags: -istrip icrnl -inlcr -igncr ixon -ixoff -ixany -imaxbel -ignbrk
        -brkint -inpck -ignpar -parmrk
oflags: opost onlcr -ocrnl tab3 -onocr -onlret
cflags: cread cs7 parenb -parodd hupcl -clocal -cstopb -crtscts -dsrflow
        -dtrflow -mdmbuf
discard dsusp   eof     eol     eol2    erase   erase2  intr    kill    
^O      ^Y      ^D      <undef> <undef> ^H      ^H      ^C      ^U      
lnext   min     quit    reprint start   status  stop    susp    time    
^V      1       ^\      ^R      ^Q      ^T      ^S      ^Z      0       
werase  
^W      
```
 
----


From the man page for ```xterm(1)``` on FreeBSD:

```
---- snip ----

Special Keys
    Xterm, like any VT100-compatible terminal emulator, has two modes for
    the special keys (cursor-keys, numeric keypad, and certain function-
    keys):

    *   normal mode, which makes the special keys transmit “useful”
        sequences such as the control sequence for cursor-up when pressing
        the up-arrow, and
  
    *   application mode, which uses a different control sequence that
        cannot be mistaken for the “useful” sequences.

    The main difference between the two modes is that normal mode sequences
    start with CSI (escape [) and application mode sequences start with SS3
    (escape O).
  
    The terminal is initialized into one of these two modes (usually the
    normal mode), based on the terminal description (termcap or terminfo).
    The terminal description also has capabilities (strings) defined for
    the keypad mode used in curses applications.
  
    There is a problem in using the terminal description for applications
    that are not intended to be full-screen curses applications: the
    definitions of special keys are only correct for this keypad mode.  For
    example, some shells (unlike ksh(1), which appears to be hard-coded,
    not even using termcap) allow their users to customize key-bindings,
    assigning shell actions to special keys.

---- snip ----
```

From
[Xterm Control Sequences - Edward Moy, University of California, Berkeley - Revised by Stephen Gildea X Consortium (1994), Thomas Dickey XFree86 Project (1996-2005)](https://theory.uwinnipeg.ca/XFree86/htdocs/4.7.0/ctlseqs.html):   
(Retrieved on Feb 18, 2024)   

> **C1 (8-Bit) Control Characters**
>
> The *xterm* program recognizes both 8-bit and 7-bit control characters.
> It generates 7-bit controls (by default) or 8-bit if S8C1T is enabled.
> The following pairs of 7-bit and 8-bit control characters are equivalent:
>
> . . .  
> ```ESC [```   Control Sequence Introducer ( CSI is 0x9b)     
> . . .  
>

The whole list from that page is:
>
```ESC D``` Index (```IND``` is ```0x84```)   
```ESC E``` Next Line (```NEL``` is ```0x85```)   
```ESC H``` Tab Set (```HTS``` is ```0x88```)   
```ESC M``` Reverse Index (```RI``` is ```0x8d```)   
```ESC N``` Single Shift Select of G2 Character Set (```SS2``` is ```0x8e```): affects next character only   
```ESC O``` Single Shift Select of G3 Character Set (```SS3``` is ```0x8f```): affects next character only   
```ESC P``` Device Control String (```DCS``` is ```0x90```)   
```ESC V``` Start of Guarded Area (```SPA``` is ```0x96```)   
```ESC W``` End of Guarded Area (```EPA``` is ```0x97```)   
```ESC X``` Start of String (```SOS``` is ```0x98```)   
```ESC Z``` Return Terminal ID (```DECID``` is ```0x9a```). *Obsolete* form of ```CSI c``` (```DA```).   
```ESC [``` Control Sequence Introducer (```CSI``` is ```0x9b```)   
```ESC \``` String Terminator (```ST``` is ```0x9c```)   
```ESC ]``` Operating System Command (```OSC``` is ```0x9d```)   
```ESC ^``` Privacy Message (```PM``` is ```0x9e```)   
```ESC _``` Application Program Command (```APC``` is ```0x9f```)   
>
> These control characters are used in the vtXXX emulation.
>

----


From
[Red Hat Enterprise Linux 4: Debugging with gdb - Red Hat Customer Portal - Chapter 29. Command Line Editing - 29.1. Introduction to Line Editing - archive.org - snapshot from Sep 23, 2015](https://web.archive.org/web/20150923190005/https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Debugging_with_gdb/command-line-editing.html): 

> **Chapter 29. Command Line Editing**
> 
> This chapter describes the basic features of the gnu command line editing interface.
> 
> **29.1. Introduction to Line Editing**
> 
> The following paragraphs describe the notation used to represent keystrokes.
>
> The text **C-k** is read as 'Control-K' and describes the character produced when the [k] key is pressed while the Control key is depressed.
>
> The text **M-k** is read as 'Meta-K' and describes the character produced when the Meta key (if you have one) is depressed, and the [k] key is pressed.
> The Meta key is labeled [ALT] on many keyboards.
> On keyboards with two keys labeled [ALT] (usually to either side of the space bar), the [ALT] on the left side is generally set to work as a Meta key.
> The [ALT] key on the right may also be configured to work as a Meta key or may be configured as some other modifier, such as a Compose key for typing accented characters.
>
> If you do not have a Meta or [ALT] key, or another key working as a Meta key, the identical keystroke can be generated by typing [ESC] *first*, and then typing [k].
> Either process is known as *metafying* the [k] key.
>
> The text **M-C-k** is read as 'Meta-Control-k' and describes the character produced by *metafying* **C-k**.
>
> In addition, several keys have their own names.
> Specifically, [DEL], [ESC], [LFD], [SPC], [RET], and [TAB] all stand for themselves when seen in this text, or in an init file (refer to [Section 29.3 Readline Init File](https://web.archive.org/web/20150923192132/https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Debugging_with_gdb/readline-init-file.html)).
> If your keyboard lacks a [LFD] key, typing [C-j] will produce the desired character.
> The [RET] key may be labeled [Return] or [Enter] on some keyboards. 
> 

----


From
[Red Hat Enterprise Linux 4: Debugging with gdb - Red Hat Customer Portal - Chapter 29. Command Line Editing - Readline Init File - archive.org - snapshot from Sep 23, 2015](https://web.archive.org/web/20150923192132/https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Debugging_with_gdb/readline-init-file.html): 

> **29.3. Readline Init File**
>
> Although the Readline library comes with a set of **Emacs-like keybindings** installed by **default**, it is possible to use a different set of keybindings.
> Any user can customize programs that use Readline by putting commands in an *inputrc* file, conventionally in his home directory.
> The name of this file is taken from the value of the environment variable ```INPUTRC```.
> If that variable is unset, the default is ```~/.inputrc```.
>
> When a program which uses the Readline library starts up, the init file is read, and the key bindings are set.
>
> In addition, the ```C-x C-r``` command re-reads this init file, thus incorporating any changes that you might have made to it. 
> 
> **29.3.1. Readline Init File Syntax**
> 
> There are only a few basic constructs allowed in the Readline init file.
> Blank lines are ignored.
> Lines beginning with a ```#``` are comments.
> Lines beginning with a ```$``` indicate conditional constructs (refer to Section 29.3.2 Conditional Init Constructs).
> Other lines denote variable settings and key bindings. 
>
> **Variable Settings**
>
> You can modify the run-time behavior of Readline by altering the values of variables in Readline using the ```set``` command within the init file.
> The syntax is simple:
>
> ```
> set variable value
> ```
> Here, for example, is how to change from the default Emacs-like key binding to use **vi** line editing commands:
>
> ```
> set editing-mode vi
> ```
>
> Variable names and values, where appropriate, are recognized without regard to case.
> A great deal of run-time behavior is changeable with the following variables. 
>
> *bell-style*
>
>> Controls what happens when Readline wants to ring the terminal bell.
>> If set to ```none```, Readline never rings the bell.
>> If set to ```visible```, Readline uses a visible bell if one is available.
>> If set to ```audible``` (the default), Readline attempts to ring the terminal's bell.     
> . . .         
>        
> . . .    
>      
>       
> **Key Bindings**
>
> The syntax for controlling key bindings in the init file is simple.
> First you need to find the name of the command that you want to change.
> The following sections contain tables of the command name, the default keybinding, if any, and a short description of what the command does.
> 
> Once you know the name of the command, simply place on a line in the init file the name of the key you wish to bind the command to, a colon, and then the name of the command.
> The name of the key can be expressed in different ways, depending on what you find most comfortable.
> 
> In addition to command names, readline allows keys to be bound to a string that is inserted when the key is pressed (a ```macro```). 
>
> ```keyname: function-name or macro```
> 
> ```keyname``` is the name of a key spelled out in English.
> For example: 
>
> ```
> Control-u: universal-argument
> Meta-Rubout: backward-kill-word
> Control-o: "> output"
> ```
>
> In the above example, **C-u** is bound to the function ```universal-argument```, **M-DEL** is bound to the function ```backward-kill-word```, and **C-o** is bound to run the macro expressed on the right hand side (that is, to insert the text ```> output``` into the line).
> 
> A number of symbolic character names are recognized while processing this key binding syntax: DEL, ESC, ESCAPE, LFD, NEWLINE, RET, RETURN, RUBOUT, SPACE, SPC, and TAB. 
>
> ```"keyseq": function-name or macro```
> 
> ```keyseq``` differs from ```keyname``` above in that strings denoting an entire key sequence can be specified, by placing the key sequence in double quotes.
> Some gnu *Emacs* style key escapes can be used, as in the following example, but the special character names are not recognized. 
>
> ```
> "\C-u": universal-argument
> "\C-x\C-r": re-read-init-file
> "\e[11~": "Function Key 1"
> ```
>
> In the above example, **C-u** is again bound to the function ```universal-argument``` (just as it was in the first example), **C-x C-r** is bound to the function ```re-read-init-file```, and ```[ESC] [[] [1] [1] [~]``` is bound to insert the text ```Function Key 1```.
> 

> The following gnu Emacs style escape sequences are available when specifying key sequences:
>
> ```\C-```
>> control prefix
> 
> ```\M-```
>> meta prefix
>
> ---- snip ----
> 

----


From
[Red Hat Enterprise Linux 4: Debugging with gdb - Red Hat Customer Portal - Chapter 29. Command Line Editing - 29.4. Bindable Readline Commands - archive.org - snapshot from Sep 23, 2015](https://web.archive.org/web/20150923212859/https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Debugging_with_gdb/bindable-readline-commands.html): 

> **29.4. Bindable Readline Commands**
> 
> This section describes Readline commands that may be bound to key sequences.
> Command names without an accompanying key sequence are unbound by default.
> 
> In the following descriptions, *point* refers to the current cursor position, and *mark* refers to a cursor position saved by the ```set-mark``` command.
> The text between the point and mark is referred to as the *region*.
> 
> **29.4.1. Commands For Moving**
> 
> ---- snip ----
> 
> **29.4.2. Commands For Manipulating The History**
> 
> ---- snip ----
> 
> **29.4.3. Commands For Changing Text**
> 
> ---- snip ----
>
> ```quoted-insert (C-q or C-v)```
> 
> Add the next character typed to the line verbatim. 
> This is how to insert key sequences like **C-q**, for example. 
> 
> ---- snip ----
> 

----


From
[Readline vi Mode - Red Hat Enterprise Linux 4: Debugging with gdb - Red Hat Customer Portal - Chapter 29. Command Line Editing - 29.5. Readline vi Mode - archive.org - snapshot from Sep 23, 2015](https://web.archive.org/web/20150923174508/https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Debugging_with_gdb/readline-vi-mode.html): 

> **29.5. Readline vi Mode**
> 
> While the Readline library does not have a full set of **vi** editing functions, it does contain enough to allow simple editing of the line.
> The Readline **vi** mode behaves as specified in the posix *1003.2 standard*.
> 
> In order to switch interactively between **emacs** and **vi** editing modes, use the command ```M-C-j``` (bound to ```emacs-editing-mode``` when in **vi** mode and to ```vi-editing-mode``` in **emacs** mode).
> The Readline **default** is **emacs** mode.
> 
> When you enter a line in **vi** mode, you are already placed in 'insertion' mode, as if you had typed an ```i```.
> Pressing [ESC] switches you into 'command' mode, where you can edit the text of the line with the standard **vi** movement keys, move to previous history lines with ```k``` and subsequent lines with ```j```, and so forth. 
>

----


From
[GNU Readline - Wikipedia](https://en.wikipedia.org/wiki/GNU_Readline):  
(Retrieved on Feb 18, 2024)  

> GNU Readline is a *software library* that provides *in-line-editing* and *history* capabilities for *interactive programs* with a *command-line interface*, such as *Bash*. 
>
> It allows users to move the *text cursor*, search the *command history*, control a *kill ring* (a more flexible version of a copy/paste clipboard)
([Kill ring - Wikipedia -- Redirect page, which redirects to Cut, copy, and paste#Multiple clipboards](https://en.wikipedia.org/w/index.php?title=Kill_ring&redirect=no))
([Cut, copy, and paste - Wikipedia](https://en.wikipedia.org/wiki/Cut,_copy,_and_paste#Multiple_clipboards))
and use *tab completion* on a *text terminal*.
>
> As a *cross-platform library*, readline allows applications on various systems to exhibit identical line-editing behavior. 
>
> ...
> 
> **Editing modes**
>
> Readline supports both *Emacs* and *vi* editing modes, which determine how keyboard input is interpreted as editor commands.
> 
> **Emacs keyboard shortcuts**
> 
> Emacs editing mode *key bindings* are taken from the text editor *Emacs*.
> 
> On some systems, ```Esc``` must be used instead of ```Alt```, because the ```Alt``` shortcut conflicts with another shortcut.
> For example, pressing ```Alt```+```f``` in *Xfce's terminal emulator* window does not move the cursor forward one word, but activates "File" in the menu of the terminal window, unless that is disabled in the emulator's settings.
>
> --- snip ---
> 
> ```Ctrl```+```v```:  
>> If the next input is also a control sequence, type it literally   
>> (e. g. ```Ctrl```+```v``` ```Ctrl```+```h``` types "^H", a literal backspace.)  
>
> --- snip ---
>  

----


From
[Control key - Wikipedia](https://en.wikipedia.org/wiki/Control_key):  
(Retrieved on Feb 18, 2024)  

> **Notation**
> 
> There are several common notations for pressing the Control key in conjunction with another key.
> Each notation below means *press* and *hold* ```Ctrl``` *while pressing* the ```X``` key:
> 
> ```^X```         Traditional *caret notation*    
> ```C-x```        *Emacs* and *Vi* (*Vim*) notation   
> ```CTRL-X```     Old *Microsoft* notation  
> ```Ctrl+X```     Current Microsoft notation  
> ```Ctrl/X```     *OpenVMS* notation  
```⌃X```           *Classic Mac OS* and *macOS* notation, used in menus and *Sticky Keys* (similar to caret notation, but using ```U+2303``` ```⌃ UP ARROWHEAD``` instead of a *caret*)  
> ```Control–X```  Classic Mac OS and macOS notation, used in prose  
> ```CNTL/X```     *Cisco IOS* notation  
```|X```           Bar notation   
>
> **Table of examples**
> 
> Different application programs, user interfaces, and operating systems use the various control key combinations for different purposes.

{:class="table table-bordered"}
| Key combination | Microsoft Windows/KDE/GNOME | Unix (command line and programs using readline | Emacs (if different from Unix command line)
| :---            | :---   | :---        | :--- |
| --- snip --- | --snip-- | --snip-- | --snip-- |
| ```Ctrl```+```v```         | Paste | Literal insert | Page down |
| --- snip --- | --- snip --- | --- snip --- | --- snip --- |
| ```Ctrl```+```[``` | Decrease font size | Same as ```Esc``` or ```Alt``` | Same as ```Esc``` or ```Alt``` |
| --- snip --- | --- snip --- | --- snip --- | --- snip --- |

----


From
[Control character (aka Non-printable character) - Wikipedia -- archive.org - snapshot from Feb 25, 2021](https://web.archive.org/web/20210225163641/https://en.wikipedia.org/wiki/Control_character):

> "Non-printable character" redirects here.
> For characters in text applications, see Non-printing character in word processors.
> 
> Not to be confused with *Escape character*.
>
> In computing and telecommunication, a **control character** or **non-printing character (NPC)** is a *code point* (a number) in a *character set* that **does not represent a written symbol**.
> They are used as *in-band signaling* to cause effects other than the addition of a symbol to the text.
> All other characters are mainly *graphic characters*, also known as *printing characters* (or *printable characters*), except perhaps for "*space*" character (see ASCII printable characters).
>
> All entries in the *ASCII* table **below code 32** (technically the **C0 control code set**) are *of this kind*, including *CR* and *LF* used to separate lines of text.
> The code ```127``` (```DEL```) is also a control character.
> *Extended ASCII* sets defined by *ISO 8859* **added** the codes ```128``` through ```159``` as **control characters**, this was primarily done so that if the high bit was stripped it would not change a printing character to a *C0 control code*, but there have been some assignments here, in particular *NEL* (see the NOTE below).   
> This second set is called the **C1 set**.

> NOTE for NEL:   
> **Newline** (frequently called **line ending**, **end of line (EOL)**, **line feed**, or **line break**) is a *control character* or sequence of control characters in a *character encoding* specification (e.g. *ASCII* or *EBCDIC*) that is used to signify the end of a line of text and the start of a new one.
> Some text editors set this special character when pressing the ↵ ```Enter``` key.
> 
> When displaying (or printing) a text file, this control character causes the text editor to show the following characters in a new line. 
>
> These 65 control codes were carried over to *Unicode*.
> Unicode added more characters that could be considered controls, but it makes a *distinction* between these "Formatting characters" (such as the ```Zero-width non-joiner```), and the 65 Control characters.
> 
> The *Extended Binary Coded Decimal Interchange Code (EBCDIC)* character set contains 65 control codes, including all of the ASCII control codes as well as additional codes which are mostly used to control IBM peripherals. 

----

From 

[The man page for man console_codes(4) - The man-pages project - Online manual pages -- Linux Programmer's Manual](http://man7.org/linux/man-pages/man4/console_codes.4.html):    
(Retrieved on Feb 18, 2024)   

```
console_codes(4) - Linux manual page

console_codes(4)        Kernel Interfaces Manual        console_codes(4)

NAME
       console_codes - Linux console escape and control sequences

DESCRIPTION
       The Linux console implements a large subset of the VT102 and
       ECMA-48/ISO 6429/ANSI X3.64 terminal controls, plus certain
       private-mode sequences for changing the color palette, character-
       set mapping, and so on.  In the tabular descriptions below, the
       second column gives ECMA-48 or DEC mnemonics (the latter if
       prefixed with DEC) for the given function.  Sequences without a
       mnemonic are neither ECMA-48 nor VT102.

       After all the normal output processing has been done, and a
       stream of characters arrives at the console driver for actual
       printing, the first thing that happens is a translation from the
       code used for processing to the code used for printing.

       If the console is in **UTF-8 mode**, then the incoming bytes are
       first assembled into *16-bit Unicode codes*.  Otherwise, each byte
       is transformed according to the current mapping table (which
       translates it to a Unicode value).  See the *Character Sets*
       section below for discussion.

       In the normal case, the Unicode value is converted to a font
       index, and this is stored in video memory, so that the
       corresponding glyph (as found in video ROM) appears on the
       screen.  Note that the use of Unicode (and the design of the PC
       hardware) allows us to use 512 different glyphs simultaneously.

       If the current Unicode value is a **control character**, or we are
       currently processing an **escape sequence**, the value will treated
       **specially**.  Instead of being turned into a font index and rendered
       as a glyph, it may trigger cursor movement or other control functions.
       See the *Linux Console Controls* section below for discussion.

       It is generally not good practice to hard-wire terminal controls into
       programs.  Linux supports a *terminfo(5)* database of *terminal
       capabilities*.  Rather than emitting console escape sequences by hand,
       you will almost always want to use a terminfo-aware screen library or
       utility such as ncurses(3), tput(1), or reset(1).

Linux console controls
----------------------
    This section describes all the control characters and escape
    sequences that invoke special functions (i.e., anything other than
    writing a glyph at the current cursor location) on the Linux console.

    Control characters
    -------------------

    A character is a *control character* if (before transformation
    according to the mapping table) it has one of the following 14 codes:
    00 (NUL), 07 (BEL), 08 (BS), 09 (HT), 0a (LF), 0b (VT), 0c (FF), 0d (CR),
    0e(SO), 0f (SI), 18 (CAN), 1a (SUB), 1b (ESC), 7f (DEL).

    One can set a" "display control characters" mode (see below), and
    allow 07, 09, 0b, 18, 1a, 7f to be displayed as glyphs.
    On the other hand, in *UTF-8* mode all codes 00 - 1f are regarded as
    *control characters*, regardless of any "display control characters" mode.

    If we have a control character, it is acted upon immediately and then
    discarded (even in the middle of an escape sequence) and the escape
    sequence continues with the next character. 
    (However, ESC starts a new escape sequence, possibly aborting a previous
    unfinished one, and CAN and SUB abort any escape sequence.)

    The recognized **control characters** are BEL, BS, HT, LF, VT, FF, CR,
                                              SO, SI, CAN, SUB, ESC, DEL, CSI.  
    They do what one would expect:

    BEL (0x07, ^G)
           beeps;

    BS (0x08, ^H)
           backspaces one column (but not past the beginning of
           the line);

    HT (0x09, ^I)
           goes to the next tab stop or to the end of the line if
           there is no earlier tab stop;

    LF (0x0A, ^J)
    VT (0x0B, ^K)
    FF (0x0C, ^L)
           all give a linefeed,
           and if LF/NL (new-line mode) is set
           also a carriage return;

    CR (0x0D, ^M)
           gives a carriage return;

    SO (0x0E, ^N)
           activates the G1 character set;

    SI (0x0F, ^O)
           activates the G0 character set;

    CAN (0x18, ^X)
    SUB (0x1A, ^Z)
            interrupt escape sequences (abort escape sequences);

******** <<== My highliting 
    ESC (0x1B, ^[)
            starts an escape sequence;
******** <<== My highliting

    DEL (0x7F)
            is ignored;

******** <<== My highliting
    CSI (0x9B)
            is equivalent to ESC [.
******** <<== My highliting 

---- snip ----


    ECMA-48 CSI sequences (Control Sequence Introducer sequences) 
                          (a.k.a. Control Sequence Initiator sequences)
    -------------------------------------------------------------------
       CSI (or ESC [) is followed by a sequence of parameters, at most
       NPAR (16), that are decimal numbers separated by semicolons.

       An empty or absent parameter is taken to be 0.

       The sequence of parameters may be preceded by a single question mark.

       However, after CSI [ (or ESC [ [) a single character is read and
       this entire sequence is ignored.  (The idea is to ignore an
       echoed function key.)

---- snip ----

Character sets
--------------
       The kernel knows about 4 translations of bytes into console-
       screen symbols.  The four tables are: a) Latin1 -> PC, b) VT100
       graphics -> PC, c) PC -> PC, d) user-defined.

       There are two character sets, called G0 and G1, and one of them
       is the current character set.  (Initially G0.)  Typing ^N causes
       G1 to become current, ^O causes G0 to become current.

       These variables G0 and G1 point at a translation table, and can
       be changed by the user.  Initially they point at tables a) and
       b), respectively.  The sequences ESC ( B and ESC ( 0 and ESC ( U
       and ESC ( K cause G0 to point at translation table a), b), c),
       and d), respectively.  The sequences ESC ) B and ESC ) 0 and ESC
       ) U and ESC ) K cause G1 to point at translation table a), b),
       c), and d), respectively.

       The sequence ESC c causes a terminal reset, which is what you
       want if the screen is all garbled.  The oft-advised "echo ^V^O"
       will make only G0 current, but there is no guarantee that G0
       points at table a).  In some distributions there is a program
       reset(1) that just does "echo ^[c".  If your terminfo entry for
       the console is correct (and has an entry rs1=\Ec), then "tput
       reset" will also work.

       The user-defined mapping table can be set using mapscrn(8).  The
       result of the mapping is that if a symbol c is printed, the
       symbol s = map[c] is sent to the video memory.  The bitmap that
       corresponds to s is found in the character ROM, and can be
       changed using setfont(8).

---- snip ----

Comparisons with other terminals
--------------------------------
    Many different terminal types are described, like the Linux
    console, as being "VT100-compatible".  Here we discuss
    differences between the Linux console and the two most important
    others, the DEC VT102 and xterm(1).

    Control-character handling
    -------------------------- 

    The VT102 also recognized the following control characters:

    NUL (0x00)
           was ignored;

    ENQ (0x05)
           triggered an answerback message;

    DC1 (0x11, ^Q, XON)
           resumed transmission;

    DC3 (0x13, ^S, XOFF)
           caused VT100 to ignore (and stop transmitting) all codes
           except XOFF and XON.

    VT100-like DC1/DC3 processing may be enabled by the terminal driver.

    The xterm(1) program (in VT100 mode) recognizes the control
    characters BEL, BS, HT, LF, VT, FF, CR, SO, SI, ESC.

---- snip ----

BUGS 
       In Linux 2.0.23, CSI is broken, and NUL is not ignored inside
       escape sequences.

       Some older kernel versions (after Linux 2.0) interpret 8-bit
       control sequences.  These "C1 controls" use codes between 128 and
       159 to replace ESC [, ESC ] and similar two-byte control sequence
       initiators (CSI).  There are fragments of that in modern kernels
       (either overlooked or broken by changes to support UTF-8), but
       the implementation is incomplete and should be regarded as
       unreliable.

       Linux "private mode" sequences do not follow the rules in ECMA-48
       for private mode control sequences.  In particular, those ending
       with ] do not use a standard terminating character.  The OSC (set
       palette) sequence is a greater problem, since xterm(1) may
       interpret this as a control sequence which requires a string
       terminator (ST).  Unlike the setterm(1) sequences which will be
       ignored (since they are invalid control sequences), the palette
       sequence will make xterm(1) appear to hang (though pressing the
       return-key will fix that).  To accommodate applications which
       have been hardcoded to use Linux control sequences, set the
       xterm(1) resource brokenLinuxOSC to true.

       An older version of this document implied that Linux recognizes
       the ECMA-48 control sequence for invisible text.  It is ignored.
```

----


From
[Bash Reference Manual - GNU Operating System - Supported by the Free Software Foundation -- www.gnu.org](https://www.gnu.org/software/bash/manual/html_node/index.html):    
(Retrieved on Feb 18, 2024)   

> **Chapter 8. Command Line Editing**
> 
> **8.1 Introduction to Line Editing**

[8.1 Introduction to Line Editing](https://www.gnu.org/software/bash/manual/html_node/Introduction-and-Notation.html#Introduction-and-Notation)

> The following paragraphs describe the notation used to represent keystrokes.
>
> The text ```C-k``` is read as 'Control-K' and describes the character produced when the ```k``` key is pressed *while* the ```Control``` key is depressed.

> The text ```M-k``` is read as ```Meta-K``` and describes the character produced when the ```Meta``` key (if you have one) is depressed, and the ```k``` key is pressed.
> The ```Meta``` key is labeled ```ALT``` on many keyboards.
> On keyboards with two keys labeled ```ALT``` (usually to either side of the space bar), the ```ALT``` on the left side is generally set to work as a ```Meta``` key.
> The ```ALT``` key on the right may also be configured to work as a ```Meta``` key or may be configured as some other modifier, such as a Compose key for typing accented characters.
> 
> If you do not have a ```Meta``` or ```ALT``` key, or another key working as a ```Meta``` key, the identical keystroke can be generated by typing ```ESC``` *first*, and then typing ```k```.
> Either process is known as *metafying* the ```k``` key.
>
> The text ```M-C-k``` is read as Meta-Control-k' and describes the character produced by *metafying* ```C-k```.
>
> In addition, several keys have their own names.
> Specifically, ```DEL```, ```ESC```, ```LFD```, ```SPC```, ```RET```, and ```TAB``` all stand for themselves when seen in this text, or in an init file 
(see [Readline Init File](https://www.gnu.org/software/bash/manual/html_node/Readline-Init-File.html#Readline-Init-File)).
> If your keyboard lacks a ```LFD``` key, typing ```C-j``` will produce the desired character.
> The ```RET``` key may be labeled ```Return``` or ```Enter``` on some keyboards. 

----


From
[The difference between \e and ^\[](https://unix.stackexchange.com/questions/89812/the-difference-between-e-and):    
(Retrieved on Feb 18, 2024)   

> If you take a look at the [ANSI ASCII standard](https://en.wikipedia.org/wiki/ASCII), the lower part of the character set (the first 32) are reserved "**control characters**" (sometimes referred to as "**escape sequences**").
> These are things like the ```NUL``` character, ```Line Feed``` (LF), ```Carriage Return``` (CR), ```Tab```, ```Bell```, etc.
> The vast *majority* can be *emulated* by pressing the ```Ctrl``` key *in combination* with another key.
> 
> The 27th (decimal) or ```\033``` (octal) sequence, or ```0x1b``` (hexadecimal) sequence is the **Escape sequence**.
> They are all representations of the same *control sequence*.
> Different shells, languages and tools refer to this sequence in different ways.
> Its ```Ctrl``` sequence is ```Ctrl```-```[```, hence sometimes being represented as ```^[```, ```^``` being a short hand for ```Ctrl```.
> 
> You can enter *control character sequences* as a *raw* sequences on your *command line* by **proceeding them** with ```Ctrl```-```v```.
> ```Ctrl```-```v``` to most shells and programs *stops the interpretation of the following key sequence* and instead *inserts* in its **raw form**.
> If you do this with **either** the ```Escape``` key or ```Ctrl```-```v``` it will *display* on most shells as ```^[```.
> However, although this sequence will get interpreted, it will not cut and paste easily, and may get reduced to a non control character sequence when encountered by certain protocols or programs.
> 
> To get around this to make it easier to use, certain utilities represent the "raw" sequence either with ```\033``` (by octal reference), \x1b (hex reference) **or** by *special character reference* ```\e```.
> This is much the same in the way that ```\t``` is interpreted as a ```Tab``` - which by the way can also be input via ```Ctrl```-```i```, or ```\n``` as ```newline``` or the ```Enter``` key, which can also be input via ```Ctrl```-```m```.
>
> So when Gilles says
([https://unix.stackexchange.com/questions/89802/terminator-ctrl-tab-key-binding/89810#89810](https://unix.stackexchange.com/questions/89802/terminator-ctrl-tab-key-binding/89810#89810)):    
> 
> ```
> 27 = 033 = 0x1b = ^[ = \e
> ```
>
> He is saying decimal ASCII 27, octal 33, hex 1b, ```Ctrl```-```[``` and ```\e``` are all equal he means they all refer to the same thing (semantically).
>
> When Demizey says 
([https://unix.stackexchange.com/questions/67425/screenrc-find-out-the-keys-bound-by-bindkey#comment97272_67426)](https://unix.stackexchange.com/questions/67425/screenrc-find-out-the-keys-bound-by-bindkey#comment97272_67426)):   
> 
> ```^[``` is just a representation of ```ESCAPE``` and ```\e``` is interpreted as an actual ```ESCAPE``` character
> 
> He means semantically, but if you press ```Ctrl```-```v``` ```Ctrl```-```[``` this is exactly the same as ```\e```, the *raw* inserted sequence will most likely be treated the same way, but **this is not always guaranteed**, and so it recommended to use the programmatically **more portable** ```\e``` or ```0x1b``` or ```\033``` *depending* on the language/shell/utility being used.
>

----


From
[Terminator Ctrl-Tab key binding](https://unix.stackexchange.com/questions/89802/terminator-ctrl-tab-key-binding/89810#89810):   
(Retrieved on Feb 18, 2024)   

> Terminals **send characters** to applications, **not keys**.
> Keys are encoded as characters or character sequences; most function keys send a sequence beginning with the escape character (character ```27``` (decimal)  = ```033``` (octal) = ```0x1b``` (hexadecimal) = ```^[``` = ```\e```).
> 
> There is no standard escape sequence corresponding to the key combination Ctrl+Tab, so most terminals send the character ```9``` = ```^I``` = ```TAB``` = ```\t```, just like for a plain ```Tab```.

----


From
[What does a bash sequence '\033\[999D' mean and where is it explained?](https://unix.stackexchange.com/questions/116243/what-does-a-bash-sequence-033999d-mean-and-where-is-it-explained):   
(Retrieved on Feb 18, 2024)   

> As other people have pointed out, these control sequences are nothing to do with *bash* itself but rather the terminal device/emulator the text appears on.
> Once upon a time it was common for these sequences to be interpreted by a completely different piece of hardware.
> Originally, each one would respond to completely different sets of codes.
> To deal with this the ```termcap``` and ```terminfo``` libraries where used to write code compatible with multiple terminals.
> The ```tput``` command is an **interface** to the ```terminfo``` library (```termcap``` support can also be compiled in) and is a *more robust* way to create compatible sequences.

---


From
[How Unix erases things when you type a backspace while entering text](https://utcc.utoronto.ca/~cks/space/blog/unix/HowUnixBackspaces):   
(Retrieved on Feb 18, 2024)   

> Then we have the case when you quoted a control character while entering it, e.g. by typing ```Ctrl-V Ctrl-H```; this causes the kernel to print the ```Ctrl-H``` instead of acting on it, and it prints it as the two character sequence ```^H```.
>
> . . . 
> 
> (FreeBSD also handles backspacing a space specially, because you don't need to actually rub that out with a '\b \b' sequence; you can just print a plain ```\b```.
> Other kernels don't seem to bother with this optimization.
> The FreeBSD code for this is in ```sys/kern/tty_ttydisc.c``` in the ```ttydisc_rubchar``` function.)
>
> PS:  If you want to see the kernel's handling of backspace in action, you usually can't test it at your shell prompt, because you're almost certainly using a shell that supports command line editing and readline and so on.
> Command line editing requires taking over input processing from the kernel, and so such shells are handling everything themselves.
> My usual way to see what the kernel is doing is to run ```cat >/dev/null``` and then type away.
>
> . . .
> 
> **Comments on this page:** 
>
> By BryRob at 2017-02-05 04:23:39:
>> Hello Chris,
>>
>> Sorry for being an ignoramus, but could you please tell me what happens when you do the ```cat > /dev/null```?
>> I tried it on the terminal, and as far I've understood, it inputs to some file.
>> I'm pretty new to Linux and Unix in general. Thanks!
> 
> By carsten at 2017-02-05 18:51:34:   
>> Not sure this is correct - at the very least it's probably more complicated. You describe the special case of backspacing when the cursor is at the end of the line. Backspace also works in the middle of the line and it doesn't just overwrite the deleted character with a space - in this case is shifts the rest of the line to the left (at least in insert mode which seems to be default in most cases).
>
> By cks at 2017-02-05 19:50:49:    
>> carsten: Backspacing in the middle of the line isn't handled by the kernel.
>> Readline style line editing is handled in user space by the program involved, and it's a lot more complicated than kernel backspacing (and probably a lot more variable between various libraries for it).
>> The kernel only gets involved if the program does not take over line processing from it.
>
>> BryRob: ```cat``` with no arguments reads from standard input and writes to standard output, so running just ```cat >/dev/null``` causes ```cat``` to read from your terminal (the default standard input) and write to ```/dev/null``` (where we have directed standard output), effectively throwing away what we type to cat.
>> Without that ```>/dev/null``` bit, ```cat``` would still read from the terminal but then it would echo what you'd just typed back to you, which is distracting if you just want to see the kernel's line input handling in action.
>> 
>> (```cat``` is one of many programs that doesn't do any special readline processing when it's reading from a terminal.
>> You could get the same effect from lots of others, although many of them need various arguments to make them happy here.)
>
> By bob at 2017-02-06 12:48:54:
>> So from *bash* if I type ```Ctrl+h``` it acts the same as if I press the ```backspace``` key.
>>
>> From ```cat > /dev/null``` if I press ```Ctrl+h``` it prints a **^H** to the screen, just like if I typed ```Ctrl+v Ctrl+H``` from *bash*.
> If I press the actual ```backspace``` key, it deletes deletes both characters (^H).
>>
>> I guess I thought the ```backspace``` key and ```Ctrl+H``` weren't distinguishable.
>> And I'm not really seeing what the kernel is doing; I suppose I need a ```gdb``` setup with breakpoints for that?
>
> By cks at 2017-02-06 13:17:55:
>> If you run ```stty -a```, you'll probably find that the kernel's ```erase``` character is set to something other than ```Ctrl-H```.
> *Bash* (well, *readline*) does you the favour of interpreting ```Ctrl-H``` the same as your ```erase``` character, which is probably ```DEL``` (and that's probably what your ```backspace``` key is generating in your environment).
>> 
>> How the ```backspace``` key on your keyboard gets mapped to some key as cat and *Bash* see it can be very complicated, because there are a number of programs involved.
>> In X (aka X11 or Xorg or X Window System), the X server itself can be told to remap what key is generated, and then some terminal emulators can remap this key again.
>> For example, gnome-terminal has a 'Compatibility' tab with settings for what gets generated for the backspace and delete keys; by default I believe it's set so that backspace generates *ASCII* ```DEL```.

----


From
[Keyboard shortcut - Wikipedia](https://en.wikipedia.org/wiki/Keyboard_shortcut):   
(Retrieved on Feb 18, 2024)   

> **Notation**
> 
> The *simplest* keyboard shortcuts consist of only one key.
> For these, one generally just writes out the name of the key, as in the message "Press F1 for Help".
> The name of the key is sometimes **surrounded in brackets** or *similar characters*.
> For example: ```[F1]``` or ```<F1>```.
> The key name may also be set off using special formatting (bold, italic, all caps, etc.)
> 
> *Many* shortcuts require *two or more keys to be pressed together*.
> For these, the usual notation is to *list* the keys names *separated* by **plus** signs or **hyphens**.
> For example: "Ctrl+C", "Ctrl-C", or "```Ctrl```+```C```".
> The ```Ctrl``` key is sometimes indicated by a **caret** character (```^```).
> Thus ```Ctrl```-```C``` is sometimes written as ```^C```.
> At times, usually on *Unix* platforms, the case of the second character is significant - if the character would normally require pressing the *Shift key* to type, then the *Shift* key is part of the shortcut e.g. '```^C```' vs. '```^c```' or '```^%```' vs. '```^5```'.
> ```^%``` may also be written "```Ctrl```+```⇧ Shift```+```5```".
>
> Some keyboard shortcuts, including all shortcuts involving the ```Esc``` key, require keys (or sets of keys) to be pressed *individually*, *in sequence*.
> These shortcuts are sometimes written with the individual keys (or sets) *separated* by *commas* or *semicolons*.
> The *Emacs* text editor uses many such shortcuts, using a designated set of "prefix keys" such as ```Ctrl+C``` or ```Ctrl+X```.
> Default Emacs keybindings include ```Ctrl+X Ctrl+S``` to save a file or ```Ctrl+X Ctrl+B``` to view a list of open buffers.
> Emacs uses the letter ```C``` to denote the ```Ctrl``` key, the letter ```S``` to denote the ```Shift``` key, and the letter ```M``` to denote the ```Meta``` key (commonly mapped to the ```Alt``` key on modern keyboards.)
> Thus, in Emacs parlance, the above shortcuts would be written ```C-x C-s``` and ```C-x C-b```.
> A common backronym (a backronym is an acronym formed from an already existing word by expanding its letters into the words of a phrase) for Emacs is "Escape Meta Alt Ctrl Shift" (EMACS), poking fun at its use of many modifiers and extended shortcut sequences. 
> 
>
> **Notes and references**    
>
> . . . 
> 
> In the English language a "shortcut" may unintentionally suggest an incomplete or sloppy way of completing something.
> Consequently, some computer applications designed to be controlled mainly by the keyboard, such as Emacs, use the alternative term "key binding".
>

----


From
[How can I use shift- or control-modifiers? -- Ncurses - Frequently Asked Questions](https://invisible-island.net/ncurses/ncurses.faq.html#modified_keys):   
(Retrieved on Feb 18, 2024)   

> **How can I use shift- or control-modifiers?**
>
> The standard response is "curses doesn't do that".
>
> --- snip ---
>
> **How can I see what my keyboard sends?**
>
> All of the trouble-shooting for keyboard problems relies on you being able to see what the keys send.
> You can do this in more than one way:
>
> * Some implementations of the ```cat``` program have a ```-v``` option which tells it to show *non-printing* characters in visible form.
>> These include all BSD and Linux-based systems, as well as [AIX](https://www-01.ibm.com/support/knowledgecenter/ssw_aix_71/com.ibm.aix.cmds1/cat.htm), [HPUX](https://www.freebsd.org/cgi/man.cgi?query=cat&apropos=0&sektion=1&manpath=HP-UX+11.11&arch=default&format=html) and [Solaris](https://www.freebsd.org/cgi/man.cgi?query=cat&apropos=0&sektion=1&manpath=SunOS+5.10&arch=default&format=html).
>> 
>> While all of the extent Unix systems appear to have this feature, [POSIX](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/cat.html) does not document it.
>>
>> You would use it by typing
>>
>> ```cat -v```
>>
>> It has a few limitations:
>>   * it does not stop special characters such as ```control-C```,
>>   * the output format cannot be inverted to obtain the original inputs.
>
> * You can suppress the terminal driver's interpretation of the *first* byte in a given key by first pressing ```control-V``` (the **lnext** or *literal-next character*).
>>
>> In practice, this is "good enough" since most of the terminals you might want to use will only have a leading escape character in the special key strings.
>
> That makes it possible to see what your keyboard sends.
> There is a corresponding problem seeing what programs actually send to your terminal.
>
> * A few platforms have [vis](https://www.freebsd.org/cgi/man.cgi?query=vis&apropos=0&sektion=1&manpath=FreeBSD+11-current&arch=default&format=html), which first appeared in *4.4BSD*.
> There is a corresponding [unvis](https://www.freebsd.org/cgi/man.cgi?query=unvis&apropos=0&sektion=1&manpath=FreeBSD+11-current&arch=default&format=html) which can put the string back together (unlike ```cat -v```).
> You would use this by using ```script``` to capture all of the bytes sent to your terminal, e.g., in a file named ```typescript```.
> * But ```vis``` is not available everywhere (e.g., AIX and Solaris do not provide it, nor are you likely to find it with a Linux-based system).
>
>> At the [end of 1995](https://invisible-island.net/misc_tools/CHANGES.html#t19951215), I wrote a similar program named [unmap](https://invisible-island.net/misc_tools/index.html#item:unmap) based on a description of ```vis```, and likewise [map](https://invisible-island.net/misc_tools/index.html#item:map) (like ```unvis```) for completeness.

----


From
[Why does Ctrl + V not paste in Bash (Linux shell)?](https://superuser.com/questions/421463/why-does-ctrl-v-not-paste-in-bash-linux-shell/421468):   
(Retrieved on Feb 18, 2024)   

> ```Ctrl``` ```C``` almost everywhere in Unix was the ["interrupt" key](http://en.wikipedia.org/wiki/Control-C#In_command-line_environments), used to cancel the current program or operation.
> The ```Ctrl``` ```V```  key often meant "verbatim insert" - that is, insert the following character literally without performing any associated action.
> For example, a normal ```Esc``` switches to command mode in the *vi* editor, but ```Ctrl``` ```V``` ```Esc``` will insert the ```ESC``` character into the document.
>
> ...
> 
> [Comment by user Kaz](https://superuser.com/questions/421463/why-does-ctrl-v-not-paste-in-bash-linux-shell/421468#comment484056_421568)
> 
> Because the keys are essentially randomly ordered with respect to the ASCII standard, the program ROM includes several look-up tables that assist in the generation of the ASCII codes. ...
> Holding down the CONTROL key when another key is pressed causes another table look-up. 
> [VT100 series Technical Manual, 4.4.9.3, Digital]. – Kaz May 10 '12 at 2:40

----


From
[Control character - Wikipedia -- How control characters map to keyboards](https://en.wikipedia.org/wiki/Control_character#How_control_characters_map_to_keyboards):   
(Retrieved on Feb 18, 2024)   

> **How control characters map to keyboards**
> 
> ASCII-based keyboards have a key labelled "**Control**", "**Ctrl**", or (rarely) "**Cntl**" which is used much like a *shift* key, being pressed in combination with another letter or symbol key.
> In one implementation, the control key generates the code *64 places below the code for the (generally) uppercase letter it is pressed in combination with* (i.e., subtract ```64``` from ASCII code value in decimal of the (generally) uppercase letter).
> The other implementation is to take the ASCII code produced by the key and *bitwise AND* it with 31 (1F in hexadecimal), forcing bits 5 to 7 to zero.
> For example, pressing "**control**" and the letter "g" or "G" (code 107 in octal or 71 in base 10, which is 01000111 in binary, produces the code 7 (Bell, 7 in base 10, or 00000111 in binary).
> The NULL character (code 0) is represented by ```Ctrl-@```, "```@```" being the code immediately before "A" in the ASCII character set.
> For convenience, a lot of terminals accept ```Ctrl-Space``` as an *alias* for ```Ctrl-@```.
> In either case, this produces one of the 32 ASCII control codes between 0 and 31. 
> Neither approach works to produce the DEL character because of its special location in the table and its value (code 127 (in decimal)), but ```Ctrl-?``` is often used for this character, as subtracting ```64``` from a '```?```' gives ```-1```, which if masked to 7 bits is 127. 
> [ASCII Characters. Archived from the original on October 28, 2009. Retrieved 2010-10-08](https://web.archive.org/web/20091028135111/http://geocities.com/dtmcbride/tech/charsets/ascii.html)
>
> When the control key is held down, letter keys produce the same control characters regardless of the state of the *shift* or *caps lock* keys.
> In other words, it does not matter whether the key would have produced an upper-case or a lower-case letter.
> The interpretation of the control key with the space, graphics character, and digit keys (ASCII codes 32 to 63) vary between systems.
> Some will produce the same character code as if the control key were not held down.
> Other systems translate these keys into control characters when the control key is held down.
> The interpretation of the control key with non-ASCII ("foreign") keys also varies between systems.
>
> Control characters are often rendered into a printable form known as *caret notation* by printing a caret (```^```) and then the ASCII character that has a value of the control character plus 64.
> Control characters generated using letter keys are thus displayed with the upper-case form of the letter.
> For example, ```^G``` represents code ```7```, which is generated by pressing the ```G``` key when the control key is held down.
>
> Keyboards also typically have a few single keys which produce control character codes.
> For example, the key labelled "Backspace" typically produces code 8, "Tab" code 9, "Enter" or "Return" code 13 (though some keyboards might produce code 10 for "Enter").
> 
> Many keyboards include keys that do not correspond to any ASCII printable or control character, for example cursor control arrows and word processing functions.
> The associated keypresses are communicated to computer programs by one of four methods: appropriating otherwise unused control characters; using some encoding other than ASCII; using multi-character control sequences; or using an additional mechanism outside of generating characters.
> "Dumb" *computer terminals* typically use control sequences.
> Keyboards attached to stand-alone personal computers made in the 1980s typically use one (or both) of the first two methods.
> Modern computer keyboards generate *scancodes* that identify the specific physical keys that are pressed; computer software then determines how to handle the keys that are pressed, including any of the four methods described above. 

----


From
[Terminal codes (ANSI/VT100) introduction - archive.org snapshot from Jan 27, 2023](https://web.archive.org/web/20230127144947/https://wiki.bash-hackers.org/scripting/terminalcodes):   

> **Terminal codes (ANSI/VT100) introduction**
> 
> Terminal (control) codes are used to issue specific commands to your terminal.
> This can be related to switching colors or positioning the cursor, i.e. anything that can't be done by the application itself.
> 
> **General useful ASCII codes**
> 
> The **Ctrl-Key** representation is simply associating the *non-printable* characters from *ASCII* code 1 with the printable (letter) characters from ASCII code 65 ("A").
> ASCII code 1 would be ```^A``` (```Ctrl-A```), while ASCII code ```7``` (```BEL```) would be ```^G``` (```Ctrl-G```).
> This is a common representation (and input method) and historically comes from one of the **VT** series of terminals. 

----

From  
The Linux Programming Interface   
By Michael Kerrisk   
Published By: No Starch Press    
Publication Date: October 2010   

> **Chapter 62. Terminals**
> 
> Historically, users accessed a UNIX system using a terminal connected via a serial line (an RS-232 connection).
> Terminals were cathode ray tubes (CRTs) capable of displaying characters and, in some cases, primitive graphics.
> Typically, CRTs provided a monochrome display of 24 lines by 80 columns.
> By today's standards, these CRTs were small and expensive.
> In even earlier times, terminals were sometimes hard-copy teletype devices.
> Serial lines were also used to connect other devices, such as printers and modems, to a computer or to connect one computer to another.
>
> On early UNIX systems, the terminal lines connected to the system were represented by character devices with names of the form ```/dev/ttyn```.
> (On Linux, the ```/dev/ttyn``` devices are the virtual consoles on the system.)
> It is common to see the abbreviation ```tty``` (derived from *teletype*) as a shorthand for *terminal*.
> 
> . . . 
> 
> **62.4 Terminal Special Characters**
>
> . . .
> 
> The operation of each of the special characters is subject to the setting of various flags in the ```termios``` bit-mask fields (described in Section 62.5), as shown in the penultimate column of the table.
> 
> The final column indicates which of these characters are specified by SUSv3.
> Regardless of the SUSv3 specification, most of these characters are supported on all UNIX implementations.
>
> Table 62-1: Terminal special characters
> 
> ```
> +-----------+----------------+--------------+-----------------+-------------------------+-------+
> | Character | c_cc subscript | Description  | Default setting | Relevant bit-mask flags | SUSv3 |
> | ---- snip ----             |              |                 |                         |       | 
> | LNEXT     | VLNEXT         | Literal next | ^V              | ICANON, IEXTEN          |       |
> | ---- snip ----             |              |                 |                         |       | 
> ```
>
>
> The following paragraphs provide more detailed explanations of the terminal special characters.
> Note that if the terminal driver performs its special input interpretation on one of these characters, then - with the exception of CR, EOL, EOL2, and NL—the character is discarded (i.e., it is not passed to any reading process).
> 
> . . . 
> 
> **LNEXT**
> 
> LNEXT is the *literal next* character.
> In some circumstances, we may wish to treat one of the terminal special characters as though it were a normal character for input to a reading process.
> Typing the literal next character (usually **Control-V**) causes the next character to be treated literally, voiding any special interpretation of the character that the terminal driver would normally perform.
> Thus, we could enter the *2-character sequence* ```Control-V Control-C``` to supply a real *Control-C* character (ASCII 3) as input to the reading process.
> The LNEXT character itself is not passed to the reading process.
> This character is interpreted only in canonical mode with the ```IEXTEN``` (*extended input processing*) flag set (which is the default).
> 
> . . .
>
>
> **62.5 Terminal Flags**
> 
> Table 62-2 lists the settings controlled by each of the four flag fields of the termios structure.
> The constants listed in this table correspond to single bits, except those specifying the term *mask*, which are values spanning several bits; these may contain one of a range of values, shown in parentheses.
> The column labeled SUSv3 indicates whether the flag is specified in SUSv3.
> The *Default* column shows the default settings for a virtual console login.
>
> Many shells that provide command-line editing facilities perform their own manipulations of the flags listed in Table 62-2.
> This means that if we try using ```stty(1)``` to experiment with these settings, then the changes may not be effective when entering shell commands.
> To circumvent this behavior, we must disable command-line editing in the shell.
> For example, command-line editing can be disabled by specifying the command-line option ```--noediting``` when invoking *bash*.
>
> . . .
>
> The following paragraphs provide more details about some of the *termios* flags.
>
> . . .
> 
> **ECHO**
> 
> Setting the ```ECHO``` flag enables echoing of input characters.
> Disabling echoing is useful when reading passwords.
> Echoing is also disabled within the command mode of *vi*, where keyboard characters are interpreted as editing commands rather than text input.
> The ```ECHO``` flag is effective in both canonical and noncanonical modes.
>
> **ECHOCTL**
> 
> If ```ECHO``` is set, then enabling the ```ECHOCTL``` flag causes control characters other than tab, newline, START, and STOP to be echoed in the form ```^A``` (for ```Control-A```), and so on.
> If ```ECHOCTL``` is disabled, control characters are not echoed.
>
> The *control characters* are those with ASCII codes *less than 32*, plus the DEL character (127 decimal).
> A control character, **x**, is echoed using a caret (```^```) followed by the character resulting from the expression (```x ^ 64```).
> For all characters except ```DEL```, the effect of the ```XOR``` (```^```) operator in this expression is to add 64 to the value of the character.
> Thus, ```Control-A``` (ASCII ```1```) is echoed as *caret* plus ```A``` (ASCII 65).
> For ```DEL```, the expression has the effect of subtracting 64 from 127, yielding the value 63, the ASCII code for ```?```, so that ```DEL``` is echoed as ```^?```.
>
> **ECHOE**
>
> In canonical mode, setting the ```ECHOE``` flag causes ```ERASE``` to be performed *visually*, by outputting the sequence backspace-space-backspace to the terminal.
> If ```ECHOE``` is disabled, then the ```ERASE``` character is instead echoed (e.g., as ```^?```), but still performs its function of deleting a character.

----


From the manpage for ```stty(1)``` on FreeBSD:

```
  STTY(1)                 FreeBSD General Commands Manual                STTY(1)
  
  NAME
       stty – set the options for a terminal device interface
  
  SYNOPSIS
       stty [-a | -e | -g] [-f file] [arguments]
  
  DESCRIPTION
       The stty utility sets or reports on terminal characteristics for the
       device that is its standard input.  If no options or arguments are
       specified, it reports the settings of a subset of characteristics as well
       as additional ones if they differ from their default values.  Otherwise
       it modifies the terminal state according to the specified arguments.
       Some combinations of arguments are mutually exclusive on some terminal
       types.

---- snip ----

     Local Modes:
       Local mode flags (lflags) affect various and sundry characteristics of
       terminal processing.  Historically the term "local" pertained to new job
       control features implemented by Jim Kulp on a Pdp 11/70 at IIASA.  Later
       the driver ran on the first VAX at Evans Hall, UC Berkeley, where the job
       control details were greatly modified but the structure definitions and
       names remained essentially unchanged.  The second interpretation of the
       'l' in lflag is ``line discipline flag'' which corresponds to the c_lflag
       of the termios structure.
  
---- snip ----

       icanon (-icanon)
                   Enable (disable) canonical input (ERASE and KILL processing).
  
       iexten (-iexten)
                   Enable (disable) any implementation defined special control
                   characters not currently controlled by icanon, isig, or ixon.

---- snip ----
  
     Control Characters:
       control-character string
                   Set control-character to string.  If string is a single
                   character, the control character is set to that character.
                   If string is the two character sequence "^-" or the string
                   "undef" the control character is disabled (i.e., set to
                   {_POSIX_VDISABLE}.)
  
                   Recognized control-characters:
  
                         control-
                         character    Subscript    Description
                         _________    _________    _______________
                         eof          VEOF         EOF character
                         eol          VEOL         EOL character
                         eol2         VEOL2        EOL2 character
                         erase        VERASE       ERASE character
                         erase2       VERASE2      ERASE2 character
                         werase       VWERASE      WERASE character
                         intr         VINTR        INTR character
                         kill         VKILL        KILL character
                         quit         VQUIT        QUIT character
                         susp         VSUSP        SUSP character
                         start        VSTART       START character
                         stop         VSTOP        STOP character
                         dsusp        VDSUSP       DSUSP character
                         lnext        VLNEXT       LNEXT character
                         reprint      VREPRINT     REPRINT character
                         status       VSTATUS      STATUS character

---- snip ----

     Compatibility Modes:
       These modes remain for compatibility with the previous version of the
       stty command.

---- snip ----

       cbreak      If set, enables brkint, ixon, imaxbel, opost, isig, iexten,
                   and -icanon.  If unset, same as sane.

---- snip ----
```

----


From
[Where do I find a list of terminal key codes to remap shortcuts in bash?](https://unix.stackexchange.com/questions/76566/where-do-i-find-a-list-of-terminal-key-codes-to-remap-shortcuts-in-bash):    
(Retrieved on Feb 18, 2024)   

> Those are sequences of characters sent by your terminal when you press a given key.
> Nothing to do with bash or readline per se, but you'll want to know what sequence of characters a given key or key combination sends if you want to configure readline to do something upon a given key press.
> 
> When you press the ```A``` key, generally terminals send the ```a``` (```0x61```) character.
> If you press ```Ctrl-I``` or ```Tab```, then generally send the ```^I``` character also known as ```TAB``` or ```\t``` (```0x9```).
> Most of the function and navigation keys generally send a sequence of characters that starts with the ```^[``` (```control-[```), also known as ```ESC``` or ```\e``` (```0x1b``` (hexadecimal), ```033``` (octal)), but the exact sequence varies from terminal to terminal.
>
> The best way to find out what a key or key combination sends for your terminal, is run ```sed -n l``` and to type it followed by ```Enter``` on the keyboard.
> Then you'll see something like:
>
> ```
> $ sed -n l
> ^[[1;5A
> \033[1;5A$
> ```
> 
> The first line is caused by the local terminal ```echo``` done by the terminal device (it may not be reliable as terminal device settings would affect it).
> 
> The second line is output by ```sed```.
> The ```$``` is not to be included, it's only to show you where the end of the line is.
> 
> Above that means that ```Ctrl-Up``` (which I've pressed) send the 6 characters ```ESC```, ```[```, ```1```, ```;```, ```5``` and ```A``` (```0x1b``` ```0x5b``` ```0x31``` ```0x3b``` ```0x35``` ```0x41```)
> 
> The ```terminfo``` database records a number of sequences for a number of common keys for a number of terminals (based on ```$TERM``` value).
>
> For instance:
> 
> ```
> TERM=rxvt tput kdch1 | sed -n l
> ```
>
> Would tell you what escape sequence is send by ```rxvt``` (terminal emulator) upon pressing the ```Delete``` key.
>
> You can look up what key corresponds to a given sequence with your current terminal with ```infocmp``` (here assuming ```ncurses``` infocmp):
>
> ```
> $ infocmp -L1 | grep -F '=\E[Z'
>     back_tab=\E[Z,
>    key_btab=\E[Z,
> ```
>
> Key combinations like ```Ctrl-Up``` don't have corresponding entries in the ```terminfo``` database, so to find out what they send, either read the source or documentation for the corresponding terminal or try it out with the ```sed -n l``` method described above.
>
> . . . 
>

I also find doing something like: 

```
hexdump -v -e '/1 " 0x%02x "' -e '/1 "%03o "' -e '/1 "%_u\n"'
```

instead of sed -n l is nice.
It adds a lf (line feed) when used on keyboard input though (i.e. not pipe from tput). 


```
$ uname -v
FreeBSD 12.0-RELEASE-p10 GENERIC 
 
$ ps $$
  PID TT  STAT    TIME COMMAND
64763  6  Ss   0:01.11 -tcsh (tcsh)
 
$ printf %s\\n "$SHELL"
/bin/tcsh
 
$ printf %s\\n "$TERM"
xterm-new
```

The console (that is, non-X Window System) device is /dev/ttyv0:

```
$ sysctl -d kern.console
kern.console: Console device control

$ sysctl kern.console
kern.console: ttyv0,/ttyv0,
```

----


```
$ freebsd-version
12.0-RELEASE-p10
 
$ uname -a
FreeBSD freebsd3.my.domain 12.0-RELEASE-p10 FreeBSD 12.0-RELEASE-p10 GENERIC  amd64
 
$ ps $$
  PID TT  STAT    TIME COMMAND
68481  0  Ss   0:01.15 -tcsh (tcsh)
 
$ printf %s\\n "$SHELL"
/bin/tcsh
 
$ printf %s\\n "$TERM"
xterm-new
 
$ printf %s\\n "$TERMCAP"
xterm-new|modern xterm:@7=\EOF:@8=\EOM:F1=\E[23~:F2=\E[24~:K2=\EOE:Km=\E[M:k1=\EOP:k2=\EOQ:k3=\EOR:k4=\EOS:k5=\E[15~:k6=\E[17~:k7=\E[18~:k8=\E[19~:k9=\E[20~:k;=\E[21~:kI=\E[2~:kN=\E[6~:kP=\E[5~:kd=\EOB:kh=\EOH:kl=\EOD:kr=\EOC:ku=\EOA:am:bs:km:mi:ms:ut:xn:AX:Co#8:co#142:kn#12:li#38:pa#64:AB=\E[4%dm:AF=\E[3%dm:AL=\E[%dL:DC=\E[%dP:DL=\E[%dM:DO=\E[%dB:LE=\E[%dD:RI=\E[%dC:UP=\E[%dA:ae=\E(B:al=\E[L:as=\E(0:bl=^G:cd=\E[J:ce=\E[K:cl=\E[H\E[2J:cm=\E[%i%d;%dH:cs=\E[%i%d;%dr:ct=\E[3g:dc=\E[P:dl=\E[M:ei=\E[4l:ho=\E[H:im=\E[4h:is=\E[!p\E[?3;4l\E[4l\E>:kD=\E[3~:ke=\E[?1l\E>:ks=\E[?1h\E=:kB=\E[Z:le=^H:md=\E[1m:me=\E[m:ml=\El:mr=\E[7m:mu=\Em:nd=\E[C:op=\E[39;49m:rc=\E8:rs=\E[!p\E[?3;4l\E[4l\E>:sc=\E7:se=\E[27m:sf=^J:so=\E[7m:sr=\EM:st=\EH:ue=\E[24m:up=\E[A:us=\E[4m:ve=\E[?12l\E[?25h:vi=\E[?25l:vs=\E[?12;25h:kb=\010:
 
$ stty -a
speed 38400 baud; 34 rows; 144 columns;
lflags: icanon isig iexten echo echoe echok echoke -echonl echoctl
        -echoprt -altwerase -noflsh -tostop -flusho -pendin -nokerninfo
        -extproc
iflags: -istrip icrnl -inlcr -igncr ixon -ixoff -ixany -imaxbel -ignbrk
        -brkint -inpck -ignpar -parmrk
oflags: opost onlcr -ocrnl tab3 -onocr -onlret
cflags: cread cs7 parenb -parodd hupcl -clocal -cstopb -crtscts -dsrflow
        -dtrflow -mdmbuf
cchars: discard = ^O; dsusp = ^Y; eof = ^D; eol = <undef>;
        eol2 = <undef>; erase = ^H; erase2 = ^H; intr = ^C; kill = ^U;
        lnext = ^V; min = 1; quit = ^\; reprint = ^R; start = ^Q;
        status = ^T; stop = ^S; susp = ^Z; time = 0; werase = ^W;

$ locate ttydefaults
/usr/include/sys/ttydefaults.h
/usr/local/lib/perl5/site_perl/mach/5.30/sys/ttydefaults.ph
/usr/src/sys/sys/ttydefaults.h
 
$ ls -lh /usr/include/sys/ttydefaults.h 
-r--r--r--  1 root  wheel   4.0K Jan  4  2019 /usr/include/sys/ttydefaults.h
 
$ ls -lh /usr/src/sys/sys/ttydefaults.h 
-rw-r--r--  1 root  wheel   4.0K Feb  9  2019 /usr/src/sys/sys/ttydefaults.h
 
$ diff /usr/src/sys/sys/ttydefaults.h /usr/include/sys/ttydefaults.h 
 
$ file /usr/include/sys/ttydefaults.h
/usr/include/sys/ttydefaults.h: C source, ASCII text
 
$ wc -l /usr/include/sys/ttydefaults.h
     113 /usr/include/sys/ttydefaults.h
```

```
$ cat /usr/include/sys/ttydefaults.h
/*-
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright (c) 1982, 1986, 1993
 *      The Regents of the University of California.  All rights reserved.
 * (c) UNIX System Laboratories, Inc.
 * All or some portions of this file are derived from material licensed
 * to the University of California by American Telephone and Telegraph
 * Co. or Unix System Laboratories, Inc. and are reproduced herein with
 * the permission of UNIX System Laboratories, Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *      @(#)ttydefaults.h       8.4 (Berkeley) 1/21/94
 * $FreeBSD: releng/12.0/sys/sys/ttydefaults.h 326023 2017-11-20 19:43:44Z pfg $
 */

/*
 * System wide defaults for terminal state.
 */
#ifndef _SYS_TTYDEFAULTS_H_
#define _SYS_TTYDEFAULTS_H_

/*
 * Defaults on "first" open.
 */
#define TTYDEF_IFLAG    (BRKINT | ICRNL | IMAXBEL | IXON | IXANY)
#define TTYDEF_OFLAG    (OPOST | ONLCR)
#define TTYDEF_LFLAG_NOECHO (ICANON | ISIG | IEXTEN)
#define TTYDEF_LFLAG_ECHO (TTYDEF_LFLAG_NOECHO \
        | ECHO | ECHOE | ECHOKE | ECHOCTL)
#define TTYDEF_LFLAG TTYDEF_LFLAG_ECHO
#define TTYDEF_CFLAG    (CREAD | CS8 | HUPCL)
#define TTYDEF_SPEED    (B9600)

/*
 * Control Character Defaults
 */
/*
 * XXX: A lot of code uses lowercase characters, but control-character
 * conversion is actually only valid when applied to uppercase
 * characters. We just treat lowercase characters as if they were
 * inserted as uppercase.
 */
#define CTRL(x) ((x) >= 'a' && (x) <= 'z' ? \
        ((x) - 'a' + 1) : (((x) - 'A' + 1) & 0x7f))
#define CEOF            CTRL('D')
#define CEOL            0xff            /* XXX avoid _POSIX_VDISABLE */
#define CERASE          CTRL('?')
#define CERASE2         CTRL('H')
#define CINTR           CTRL('C')
#define CSTATUS         CTRL('T')
#define CKILL           CTRL('U')
#define CMIN            1
#define CQUIT           CTRL('\\')
#define CSUSP           CTRL('Z')
#define CTIME           0
#define CDSUSP          CTRL('Y')
#define CSTART          CTRL('Q')
#define CSTOP           CTRL('S')
#define CLNEXT          CTRL('V')
#define CDISCARD        CTRL('O')
#define CWERASE         CTRL('W')
#define CREPRINT        CTRL('R')
#define CEOT            CEOF
/* compat */
#define CBRK            CEOL
#define CRPRNT          CREPRINT
#define CFLUSH          CDISCARD

/* PROTECTED INCLUSION ENDS HERE */
#endif /* !_SYS_TTYDEFAULTS_H_ */

/*
 * #define TTYDEFCHARS to include an array of default control characters.
 */
#ifdef TTYDEFCHARS

#include <sys/cdefs.h>
#include <sys/_termios.h>

static const cc_t ttydefchars[] = {
        CEOF, CEOL, CEOL, CERASE, CWERASE, CKILL, CREPRINT, CERASE2, CINTR,
        CQUIT, CSUSP, CDSUSP, CSTART, CSTOP, CLNEXT, CDISCARD, CMIN, CTIME,
        CSTATUS, _POSIX_VDISABLE
};
_Static_assert(sizeof(ttydefchars) / sizeof(cc_t) == NCCS,
    "Size of ttydefchars does not match NCCS");

#undef TTYDEFCHARS
#endif /* TTYDEFCHARS */
```

----


## My Collection

```
$ sed -n l
```

```
$ hexdump -v -e '/1 " 0x%02x "' -e '/1 "%03o "' -e '/1 "%_u\n"' 
(It adds a lf when used on keyboard input though (i.e. not pipe from tput).) 
```

```
$ pkg info --regex showkey
showkey-1.7
```

```
$ tset -
xterm-new

$ infocmp -I -1 | grep -w ed
        ed=\E[J,
 
$  man terminfo

   The ed (string) capability in terminfo --> cd in termcap

$ infocmp -C -1 | grep -w cd
infocmp: xterm-new entry is 1123 bytes long
        :cd=\E[J:\

$ tput cd | od -c
0000000  033   [   J                                                    
0000003

$ tput clear
```

----


### Keywords

```
kill rings (buffers)
interrupt key
verbatim insert
key ID (KID)
C0 and C1 control codes
https://en.wikipedia.org/wiki/Keyboard_shortcut
control characters
caret notation
line discipline (LDISC) aka terminal I/O 
```

----


## References   
(Retrieved on Feb 18, 2024)   


* [xterm_control_sequences.py - XTerm Control Sequences from invisible-island.net as pythonic code, aka XTerm Control Sequences based on https://invisible-island.net/xterm/ctlseqs/ctlseqs.html](https://gist.github.com/nmichlo/5196879a6637ca42d5d0af22ee6848bf)

```
# ========================================================================= #
# XTerm Control Sequences from invisible-island.net as pythonic code.
# Basic control sequences are string variables.
#   - eg: ESC = '\033'
#         CSI = ESC + '['
# Control sequences that have args can be called to return a string.
#   - eg: sgr = CSI + Ps + 'm'
#         sgr(0) == '\033[0m' == sgr.RESET
# ========================================================================= #
```

* [Things Every Hacker Once Knew (catb.org) - Hacker News dicussion](https://news.ycombinator.com/item?id=13498365)

* [Things Every Hacker Once Knew - Lobsters (lobste.rs) discussion](https://lobste.rs/s/qph9hd/things_every_hacker_once_knew)

*     [*ASCII table* is rarely shown in *columns* (or *rows*) **of 32**](http://pastebin.com/cdaga5i1)

* [The difference between \e and ^\[](https://unix.stackexchange.com/questions/89812/the-difference-between-e-and)

* [bash - Understanding control characters in .inputrc - Super User](https://superuser.com/questions/269464/understanding-control-characters-in-inputrc)

* [Why does Ctrl + V not paste in Bash (Linux shell)? - Super User](https://superuser.com/questions/421463/why-does-ctrl-v-not-paste-in-bash-linux-shell/421468)

* [Terminator Ctrl-Tab key binding](https://unix.stackexchange.com/questions/89802/terminator-ctrl-tab-key-binding/89810#89810)

* [terminal - What are the keyboard shortcuts for the command-line? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/255707/what-are-the-keyboard-shortcuts-for-the-command-line)

* [bash - Can I rebind Ctrl-C to do the same as ESC in readline? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/562074/can-i-rebind-ctrl-c-to-do-the-same-as-esc-in-readline)

* [Terminal Colors - Termstandard/Colors Repository](https://github.com/termstandard/colors)

  Previously published and discussed at [https://gist.github.com/XVilka/8346728](https://gist.github.com/XVilka/8346728)

* [What are the keyboard shortcuts for the command-line?](https://unix.stackexchange.com/questions/255707/what-are-the-keyboard-shortcuts-for-the-command-line) 

* [UNIX Power Tools, Third Edition - Chapter 5.8 Terminal Escape Sequences](https://docstore.mik.ua/orelly/unix/upt/ch05_08.htm)

* [UNIX Power Tools, Third Edition - Chapter 30.14. Shell Command-Line Editing](https://docstore.mik.ua/orelly/unix3/upt/ch30_14.htm) 

* [Customizing Your Shell Environment - Learning Unix for Mac OS X, Second Edition by Brian Jepson, Dave Taylor](https://www.oreilly.com/library/view/learning-unix-for/0596004702/ch04s02.html)

* [Where do I find a list of terminal key codes to remap shortcuts in bash? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/76566/where-do-i-find-a-list-of-terminal-key-codes-to-remap-shortcuts-in-bash)

* [Read special keys in bash](https://unix.stackexchange.com/questions/294908/read-special-keys-in-bash/294935#294935)

* [How to display control characters differently in the shell](https://unix.stackexchange.com/questions/239808/how-to-display-control-characters-c-d-differently-in-the-shell)

  NOTE:    
  Control characters:  ```^C, ^D, ^[```   

* [mintty - Keyboard Layout - Keycodes.wiki -- Google Code Archive - archive.org snapshot from Dec 26, 2023](https://web.archive.org/web/20231226110016/http://code.google.com/archive/p/mintty/wikis/Keycodes.wiki)

* [Escape sequences (Escape character syntax) - IBM Documentation - z/OS](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.cbclx01/escape.htm)

* [RFC1345 - Character Mnemonics & Character Sets by Keld Simonsen - June 1992 -- IETF (Internet Engineering Task Force)](https://tools.ietf.org/html/rfc1345)

* *Linux and Unix Shell Programming*    
  By: David Tansley   
  Publisher: Addison-Wesley Professional/Pearson Business    
  Publication Date: December 27, 1999   
  Print ISBN-10: 0-201-67472-6   
  Print ISBN-13: 978-0-201-67472-9   

----


<!-- Footnotes -->

## Footnotes 

[^1]: By Tom Jennings: "Source X3.4-1963, AMERICAN STANDARD CODE FOR INFORMATION INTERCHANGE, American Standards Association (ASA), 17 June 1963. Available here as page images of a copy of the document obtained from ANSI. Unlike the very enlightened ECMA, ANSI charges for copies of their standards; I paid US$30.00 for eleven (11) poorly xeroxed sheets of paper containing the X3.4-1963 standard."

