---
layout: post
title: "ASCII/Unicode Control Characters (^L in Terminal)"
date: 2025-09-21 10:28:08 -0700 
categories: ascii cli terminal xterm shell console rs232serial plaintext text 
            x11 xorg howto font typography utf8 unicode unix it computing
            history
---

AKA: NPC (Non-Printable Characters or Non-Printing Characters) 

---

Word cloud: ASCII Unicode UTF-8 CLI terminal xterm shell console RS232serial 
            "control characters" "ASCII control codes" "C0 control characters" 
            NPC "non-printable characters" "non-printing characters"
            locale teletype Unix "caret notation" "Control Pictures" 
            FF "Form Feed" "Page break" delimiter marker typography font history
            "insert ASCII control characters in text" "character escape sequences"
            "C-style escaped characters" "C escapes" dump "ASCII dump"
            less(1) xxd(1) hexdump(1) od(1) remind(1)

---

TLDR: The `remind(1)` program outputs the Form Feed (FF, ASCII `0x0C`, represented as `^L`) control character in its calendar displays.
Purpose of the FF character in `remind(1)` output is to facilitate pagination in terminal environments.
`^L` only becomes visible when the program in the pipeline decides to render it (`less`, `cat -v`, `od`, `hexdump`).

---

Tested on FreeBSD 14.3-RELEASE-p1 in xterm (version/patch number 400) with csh shell.

```
% freebsd-version 
14.3-RELEASE-p1
```

```
% ps $$
  PID TT  STAT    TIME COMMAND
70183  5  Ss   0:00.32 -csh (csh)

% printf %s\\n "$SHELL"
/bin/csh
```

```
% xterm -version
XTerm(400)

% printf %s\\n "$XTERM_VERSION"
XTerm(400)
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

---

# What is ^L in Output on Terminal?

For example, when I used [`remind(1)`](https://dianne.skoll.ca/projects/remind/) with `less(1)`, the ouptut had two **^L** characters; one in the line separating months, and the other at the end of output, after the last line of the last month displayed.

```
% remind -c2 /path/to/.reminders  | less
+----------------------------------------------------------------------------+
|                               September 2025                               |
+----------+----------+----------+----------+----------+----------+----------+
|  Sunday  |  Monday  | Tuesday  |Wednesday | Thursday |  Friday  | Saturday |
+----------+----------+----------+----------+----------+----------+----------+
---- snip ----
+----------+----------+----------+----------+----------+----------+----------+
|28        |29        |30        |          |          |          |          |
|          |          |          |          |          |          |          |
|          |          |          |          |          |          |          |
|          |          |          |          |          |          |          |
|          |          |          |          |          |          |          |
+----------+----------+----------+----------+----------+----------+----------+
^L+----------------------------------------------------------------------------+
|                                October 2025                                |
+----------+----------+----------+----------+----------+----------+----------+
|  Sunday  |  Monday  | Tuesday  |Wednesday | Thursday |  Friday  | Saturday |
+----------+----------+----------+----------+----------+----------+----------+
|          |          |          |1         |2         |3         |4         |
|          |          |          |          |          |          |          |
---- snip ---
+----------+----------+----------+----------+----------+----------+----------+
|26        |27        |28        |29        |30        |31        |          |
|          |          |          |          |          |          |          |
|          |          |          |          |          |          |          |
|          |          |          |          |          |          |          |
|          |          |          |          |          |          |          |
+----------+----------+----------+----------+----------+----------+----------+
^L
```

```
% remind -c2 /path/to/.reminders  | less --use-color
```

---

```
% remind -c2 /path/to/.reminders | less | tail -1 | xxd
00000000: 0c                                       .
```

Switch `xxd(1)` to bits (binary digits) dump, rather than hex dump: 

```
% remind -c2 /path/to/.reminders | less | tail -1 | xxd -b
00000000: 00001100                                               .
```

As per footnote [<sup>[1](#footnotes)</sup>], the first bit of **00001100** is **0** (zero), so this is a **1-byte** character. 

```
% remind -c2 /path/to/.reminders | less | tail -1 | xxd -s0 -l1
00000000: 0c                                       .
```

Since it's a 1-byte character, there's nothing in the next position.

```
% remind -c2 /path/to/.reminders | less | tail -1 | xxd -s1 -l1
```

Alternatively, you can use the ```-g bytes | -groupsize bytes``` [<sup>[2](#footnotes)</sup>] option of the `xxd(1)` tool, and separate the outupt in groups of 1-byte: 

```
% remind -c2 /path/to/.reminders | less | tail -1 | xxd -g1
00000000: 0c 

% remind -c2 /path/to//.reminders | less | tail -1 | xxd -g1 -b
00000000: 00001100                                               .
```

Back to the first position (first byte): 

```
% remind -c2 /path/to/.reminders | less | tail -1 | xxd -s0 -l1 -b
00000000: 00001100                                               .
```

Continuing with the explanation:  

`00001100` starts with a `0`, so it's a single-byte ASCII character.

What do the remaining bits `00001100` represent?

The bits from that byte (excluding the leading bits) combine to form the binary sequence `1100`.

From the man page for `ascii(7)`, for **1100**:

```
     The binary set:

      00     01     10     11

     NUL     SP      @      `     00000
     ---- snip ----
      FF      ,      L      l     01100
     ---- snip ----
```

So, it's the line with:

```
      FF      ,      L      l     01100
```


Again, from the man page for `ascii(7)`:

```
    The full names of the control character set:

     NUL      NULl
     ---- snip ----
      FF      new page Form Feed
     ---- snip ----
```

It's the *Form Feed* character, abbreviated *FF*. 


---

Binary `1100` is *12* in decimal. [<sup>[3](#footnotes)</sup>] 


```
% printf "obase=10; ibase=2; 1100" | bc
12
```

From the man page for `ascii(7)`, for *12*:

```
     The decimal set:

       0 NUL    1 SOH    2 STX    3 ETX    4 EOT    5 ENQ    6 ACK    7 BEL
       8 BS     9 HT    10 LF    11 VT    12 FF    13 CR    14 SO    15 SI
```

So, `12` is **FF** (Form Feed).

---

By default, `xxd(1)` creates a hexadecimal dump (a hex dump):

```
% remind -c2 /path/to/.reminders | less | tail -1 | xxd -s0 -l1 
00000000: 0c  
```

From the man page for `ascii(7)`, for C (0c);

```
     The hexadecimal set:

     00 NUL   01 SOH   02 STX   03 ETX   04 EOT   05 ENQ   06 ACK   07 BEL
     08 BS    09 HT    0a LF    0b VT    0c FF    0d CR    0e SO    0f SI
```

So, `0c` is **FF** (Form Feed).

---

```
% remind -c2 /path/to/.reminders | less | tail -1 | cat -v
^L%
```

From the man page for `cat(1)`:

```
     -v      Display non-printing characters so they are visible.
             Control characters print as `^X' for control-X; the delete
             character (octal 0177) prints as `^?'. 
             Non-ASCII characters (with the high bit set) are printed as
             `M-' (for meta) followed by the character for the low 7 bits.
```

**QUESTION:** Why **L**?

ANSWER: From the man page for `ascii(7)`:
               
```
     The binary set:
               
      00     01     10     11
               
     NUL     SP      @      `     00000
     ---- snip ----
      FF      ,      L      l     01100
```


Also, from [Unicode lookup table source: *UnicodeData.txt*](https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt):

```
0000;<control>;Cc;0;BN;;;;;N;NULL;;;;
---- snip ----
000C;<control>;Cc;0;WS;;;;;N;FORM FEED (FF);;;;
---- snip ----
```


`Cc`: control character

`WS`: white space


From [Control character ("Non-printable character" redirects here) - Wikipedia](https://en.wikipedia.org/wiki/Control_character):
> 0x0C (form feed, FF, \f, ^L), to cause a printer to eject paper to the top of the next page, or a video terminal to clear the screen.

From [Page break - Wikipedia](https://en.wikipedia.org/wiki/Page_break): [<sup>[4](#footnotes)</sup>] 
> The form feed character is sometimes used in *plain text* files of *source code* as a *delimiter* for a *page break*, or as *marker* for *sections of code*.
> Some editors, in particular *emacs* and *vi*, have built-in commands to *page up/down* on the form feed character.
> This convention is predominantly used in Lisp code, and is also seen in C and Python source code.
> GNU Coding Standards require such form feeds in C.

---

From [Insert ASCII Control Characters in Text](https://web.archive.org/web/20130312024614/http://www.bo.infn.it/alice/alice-doc/mll-doc/linux/vi-ex/node15.html):
> It is possible to insert ASCII Control Characters while editing test with the insert, append, replace or substitute commands.
> Some Control Characters are inserted directly by typing <ctrl>x:
>
> ```
> <ctrl>G bell
> <ctrl>L form feed
> ```
>
> Be careful: <ctrl>x can operate directly as editor command (i.e. `<ctrl>[` operates **insert break**).
> 
> If we want to insert a *visible <esc><, we must use: `<ctrl>V` followed by `<esc>`.
> The full set of *vi* supported control characters is listed in the following table.
>
> [ . . . ]

---

In [UTF-8 Tool, select Hex code point](https://www.cogsci.ed.ac.uk/~richard/utf-8.cgi?input=000c&mode=hex)

or

[UTF-8 Tool, Hex UTF-8 bytes](https://www.cogsci.ed.ac.uk/~richard/utf-8.cgi?input=000c&mode=bytes)

Output:

```
Character: ^L (Invisible in web browser but appears when copy-paste in terminal)
Character name: FORM FEED (FF)
Hex code point: 000C
Decimal code point: 12
Hex UTF-8 bytes: 0C
Octal UTF-8 bytes: 14
UTF-8 bytes as Latin-1 characters bytes: <0C>
```

```
Notes:

1. Some browsers may not be able to display all Unicode characters; they may display blanks, boxes, or question marks for some characters. Installing more fonts may help.
2. Cutting and pasting does not work reliably in all browsers.
3. When cutting and pasting hex numbers from dump output on little-endian machines (eg x86), beware of byte order problems.
4. Hex numbers should not be prefixed with "0x", "U+", or anything else.
5. When entering a character in UTF-8 as multiple hex or octal bytes, the bytes should be separated by spaces.
6. "UTF-8 bytes as Latin-1 characters" is what you typically see when you display a UTF-8 file with a terminal or editor that only knows about 8-bit characters.
7. Spaces are ignored in the input of bytes as Latin-1 characters, to make it easier to cut-and-paste from dump output.
```

---

Additionally (having in mind that the Form Feed character is a non-printable character):

[Complete Character List for UTF-8](https://www.fileformat.info/info/charset/UTF-8/list.htm)

[Unicode Character 'FORM FEED (FF)' (U+000C)](https://www.fileformat.info/info/unicode/char/000c/index.htm)

[Fonts that support U+000C](https://www.fileformat.info/info/unicode/char/000c/fontsupport.htm)

[LastResort font](https://www.fileformat.info/info/unicode/font/lastresort/u000C.png)

[Unifont font](https://www.fileformat.info/info/unicode/font/unifont/u000C.png)


---

The `uconv(1)` also says that it's a *control* character. 
```
% remind -c2 /path/to/.reminders | less | tail -1 | uconv -x 'any-name'
\N{<control-000C>}% 
```

---

```
% remind -c2 /path/to/.reminders | less | tail -1 | hexdump
0000000 000c
0000001

% remind -c2 /path/to/.reminders | less | tail -1 | hexdump -c
0000000  \f
0000001

% remind -c2 /path/to/.reminders | less | tail -1 | hexdump -C
00000000  0c                                                |.|
00000001
```

From the man page for `hexdump(1)` - AKA **standard escape notation**:

```
     The single character escape sequences described in the C
     standard are supported:

           NUL                  \0
           <alert character>    \a
           <backspace>          \b
           <form-feed>          \f
           <newline>            \n
           <carriage return>    \r
           <tab>                \t
           <vertical tab>       \v
```


So, the line with `\f` is *form-feed*:

```
           <form-feed>          \f
```


## hexdump Format Strings

```
% hexdump -e ' [iterations]/[byte_count] "[format string]" '
```

From the man page for `hexdump(1)`: 

```
A format string contains any number of format units, separated by
whitespace.  A format unit contains up to three items: an iteration
count, a byte count, and a format.

The iteration count is an optional positive integer, which defaults to
one.  Each format is applied iteration count times.

The byte count is an optional positive integer.  If specified it defines
the number of bytes to be interpreted by each iteration of the format.

If an iteration count and/or a byte count is specified, a single slash
must be placed after the iteration count and/or before the byte count to
disambiguate them.  Any whitespace before or after the slash is ignored.

The format is required and must be surrounded by double quote (" ") marks.
It is interpreted as a fprintf-style format string (see fprintf(3)),
with the following exceptions:
---- snip ----
```

Continuing with the man page for `hexdump(1)`:
 
```
     The hexdump utility also supports the following additional conversion
     strings:

---- snip ----

     _u          Output US ASCII characters, with the exception that control
                 characters are displayed using the following, lower-case,
                 names.  Characters greater than 0xff, hexadecimal, are
                 displayed as hexadecimal strings.

                 000 NUL  001 SOH  002 STX  003 ETX  004 EOT  005 ENQ
                 006 ACK  007 BEL  008 BS   009 HT   00A LF   00B VT
                 00C FF   00D CR   00E SO   00F SI   010 DLE  011 DC1
                 012 DC2  013 DC3  014 DC4  015 NAK  016 SYN  017 ETB
                 018 CAN  019 EM   01A SUB  01B ESC  01C FS   01D GS
                 01E RS   01F US   07F DEL
```

So, the control character **FF** (form feed) is **0xC** in hexadecimal in ASCII:

```
                 00C FF   00D CR   00E SO   00F SI   010 DLE  011 DC1
```


```
% remind -c2 /path/to/.reminders | tail -1 | hexdump -e '"%_u"'
ff% 
 
% remind -c2 /path/to/.reminders | tail -1 | hexdump -e '"%_u\n"'
ff
```

The `_p` conversion string outputs characters in the default character set.
*Nonprinting characters* are displayed as a single **“.”**.

```
% remind -c2 /path/to/.reminders | tail -1 | hexdump -e '"%_p"'
.% 
```

The `_c` conversion string outputs characters in the default character set.
*Nonprinting characters* are displayed in three character, zero-padded octal, except for those representable by standard *escape notation* (see above), which are displayed as two character strings.

```
% remind -c2 /path/to/.reminders | tail -1 | hexdump -e '"%_c"'
\f% 
```

---


Output named characters:

```
% remind -c2 /path/to/.reminders | less | tail -1 | od -a
0000000   ff
0000001
```

Output C-style escaped characters:

```
% remind -c2 /path/to/.reminders | less | tail -1 | od -c
0000000   \f
0000001
```

Combine `-a` and `-c` options to display both named characters and C-style escaped characters:

```
% remind -c2 /path/to/.reminders | less | tail -1 | od -a -c
0000000   ff
          \f
0000001
```


From the man page for `od(1)`:

```
     -a         Output named characters.  Equivalent to -t a.
     -c         Output C-style escaped characters.  Equivalent to -t c.

     -t type    Specify the output format.  The type argument is a string
                containing one or more of the following kinds of type
                specifiers:

                a       Named characters (ASCII).  Control characters are
                        displayed using the following names:

                        000 NUL 001 SOH 002 STX 003 ETX 004 EOT 005 ENQ
                        006 ACK 007 BEL 008 BS  009 HT  00A NL  00B VT
                        00C FF  00D CR  00E SO  00F SI  010 DLE 011 DC1
                        012 DC2 013 DC3 014 DC4 015 NAK 016 SYN 017 ETB
                        018 CAN 019 EM  01A SUB 01B ESC 01C FS  01D GS
                        01E RS  01F US  020 SP  07F DEL

                c       Characters in the default character set.  Non-printing
                        characters are represented as 3-digit octal character
                        codes, except the following characters, which are
                        represented as C escapes:

                        NUL              \0
                        alert            \a
                        backspace        \b
                        newline          \n
                        carriage-return  \r
                        tab              \t
                        vertical tab     \v

                        Multi-byte characters are displayed in the area
                        corresponding to the first byte of the character.  The
                        remaining bytes are shown as ‘**’.

                [d|o|u|x][C|S|I|L|n]
                        Signed decimal (d), octal (o), unsigned decimal (u) or
                        hexadecimal (x).  Followed by an optional size
                        specifier, which may be either C (char), S (short), I
                        (int), L (long), or a byte count as a decimal integer.

                f[F|D|L|n]
                        Floating-point number.  Followed by an optional size
                        specifier, which may be either F (float), D (double)
                        or L (long double).
```


The line: 

```
                        00C FF  00D CR  00E SO  00F SI  010 DLE 011 DC1
```

indicates that `00C` is **FF** (Form Feed).


**Position**

Dump (ASCII dump) the first byte (`-j <skip>` option: skip \<skip\> bytes), that is, skip zero (0) bytes), using named characters and dumping no more than 1 byte:
 
```
% remind -c2 /path/to/.reminders | tail -1 | od -An -a -j 0 -N 1
          ff
```

Same as above but skip the first byte:

```
% remind -c2 /path/to/.reminders | tail -1 | od -An -a -j 1 -N 1
```

If you try to skip 2 bytes, which is end of input in this case:

```
% remind -c2 /path/to/.reminders | tail -1 | od -An -a -j 2 -N 1
od: cannot skip past end of input
```

---

From [Unicode control characters - Wikipedia](https://en.wikipedia.org/wiki/Unicode_control_characters):
>
> `U+000C FORM FEED (FF)` (denotes a page break in a plain text file)
>

---

From [C0 and C1 control codes](https://en.wikipedia.org/wiki/C0_and_C1_control_codes):
> The C0 and C1 control code or control character sets define control codes for use in text by computer systems that use ASCII and derivatives of ASCII.
> The codes represent additional information about the text, such as the position of a cursor, an instruction to start a new line, or a message that the text has been received. 
>
> [ . . . ]
> 
> **C0 controls**
>
> ASCII defines 32 control characters, plus the DEL character.
> This large number of codes was desirable at the time, as multi-byte controls would require implementation of a state machine in the terminal, which was very difficult with contemporary electronics and mechanical terminals.
> 
> Only a few codes have maintained their use: BEL, ESC, and the format effector (FEn) characters BS, TAB, LF, VT, **FF**, and CR. 
> 
> [ . . . ]
>
> Unicode provides Control Pictures that can replace C0 control characters to make them visible on screen.
> However, *caret notation* is used *more often*.
>
> From [ASCII control codes](https://en.wikipedia.org/wiki/ASCII#Control_characters), originally defined in [ANSI X3.4](https://en.wikipedia.org/wiki/ANSI_X3.4):
> 
> ``` 
> Caret notation: ^L
> Decimal:        12
> Hexadecimal:    0C 
> Abbreviations:  FE4,FF
> Name:           Form Feed
> C escape:       \f
> Description:    Move down to the top of the next page. 
> ``` 

* [Control Pictures - AKA Unicode Control Pictures](https://en.wikipedia.org/wiki/Control_Pictures)
> Control Pictures is a Unicode block containing characters for graphically representing the C0 control codes, and other control characters. Its block name in Unicode 1.0 was Pictures for Control Codes.

Control Picture for FF (Form Feed): ␌

---

## Caret Notation

From [Caret notation - Wikipedia](https://en.wikipedia.org/wiki/Caret_notation)
> Caret notation is a notation for control characters in ASCII.
> The notation assigns ^A to control-code 1, *sequentially* through the alphabet to ^Z assigned to control-code 26 (0x1A).
> For the control-codes outside of the range 1–26, the notation extends to the adjacent, non-alphabetic ASCII characters.
> 
> *Often* a control character can be *typed* on a keyboard by holding down the `Ctrl` and typing the character shown after the *caret*.
> The notation is often used to describe keyboard shortcuts even though the control character is not actually used (as in "type `^X` to cut the text").
> 
> The meaning or interpretation of, or response to the individual control-codes is *not* prescribed by the caret notation. 
> 
> [ . . . ]
>
> Description
> 
> The notation consists of a caret (^) followed by a single character (usually a capital letter). The character has the ASCII code equal to the control code with the bit representing 0x40 reversed.
> A useful *mnemonic*, this has the effect of rendering the control codes 1 through 26 as `^A` through `^Z`.
> Seven ASCII control characters map outside the upper-case alphabet: 0 (NUL) is ^@, 27 (ESC) is ^[, 28 (FS) is ^\, 29 (GS) is ^], 30 (RS) is ^^, 31 (US) is ^_, and 127 (DEL) is ^?. 
>
> [ . . . ]
> 
> There is no corresponding version of the caret notation for control-codes with more than 7 bits such as the C1 control characters from 128–159 (0x80–0x9F).
> Some programs that produce caret notation show these as backslash and octal ("\200" through "\237").
> 
> [ . . . ]
> 
> **See also**
> 
> [C0 and C1 control codes](https://en.wikipedia.org/wiki/C0_and_C1_control_codes), which shows the caret notation for all C0 control codes as well as DEL.


From the man page for `less(1)`:

```
DESCRIPTION
   Less is a program similar to more(1), but it has many more features.
   Less does not have to read the entire input file before starting, so
   with large input files it starts up faster than text editors like
   vi(1).  Less uses termcap (or terminfo on some systems), so it can run
   on a variety of terminals.  There is even limited support for hardcopy
   terminals.  (On a hardcopy terminal, lines which should be printed at
   the top of the screen are prefixed with a caret.)

---- snip ----

   -r or --raw-control-chars
          Causes "raw" control characters to be displayed.  The default is
          to display control characters using the caret notation; for
          example, a control-A (octal 001) is displayed as "^A" (with some
          exceptions as described under the -U option).  Warning: when the
          -r option is used, less cannot keep track of the actual
          appearance of the screen (since this depends on how the screen
          responds to each type of control character).  Thus, various
          display problems may result, such as long lines being split in
          the wrong place.

          USE OF THE -r OPTION IS NOT RECOMMENDED.

---- snip ----

   --intr=c
          Use the character c instead of ^X to interrupt a read when the
          "Waiting for data" message is displayed.  c must be an ASCII
          character; that is, one with a value between 1 and 127
          inclusive.  A caret followed by a single character can be used
          to specify a control character.
---- snip ----

       Control and binary characters are displayed in standout (reverse
       video).  Each such character is displayed in caret notation if possible
       (e.g. ^A for control-A).  Caret notation is used only if inverting the
       0100 bit results in a normal printable character.  Otherwise, the
       character is displayed as a hex number in angle brackets.  This format
       can be changed by setting the LESSBINFMT environment variable.

```

Extracted from above:

On a hardcopy terminal, lines which should be printed *at the top* of the screen are prefixed with a *caret*.

The *default* is to display *control characters* using the *caret notation*; for example, a control-A (octal 001) is displayed as "^A" (with some exceptions as described under the -U option).  

A *caret* followed by a single character can be used to specify a *control character*.

*Control* and binary characters are displayed in standout (reverse video).
Each such character is displayed in *caret notation* if possible (e.g. ^A for control-A).
*Caret notation* is used only if inverting the 0100 bit results in a normal printable character.  

And, from the man page for `lesskey(1)`:
> The characters in the string may appear literally, or be *prefixed* by a *caret* to indicate a *control key*. 

---

## Footnotes

[1] [**UTF-8 Encoding** -- UTF-8 Playground](https://utf8-playground.netlify.app/)
> **UTF-8 Encoding**
>
> UTF-8 is a **variable-width** character encoding designed to represent *every* character in the *Unicode* character set, encompassing characters from most of the world's writing systems.
> 
> It encodes characters using **one** to **four** bytes.
> The *first 128 characters* (U+0000 to U+007F) are encoded with a **single byte**, ensuring backward *compatibility* with **ASCII** (read my post on this↗), while *other* characters require *two*, *three*, or *four* bytes.
> 
> The *leading* bits of the *first* byte determine the *total number of bytes* in the character.
> These bits follow *one of four specific patterns*, which indicate how many *continuation* bytes follow.
>
> ``` 
>    0xxxxxxx: 1 byte
>        0xxxxxxx
>    110xxxxx: 2 bytes
>        110xxxxx 10xxxxxx
>    1110xxxx: 3 bytes
>        1110xxxx 10xxxxxx 10xxxxxx
>    11110xxx: 4 bytes
>        11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
> ``` 
>
> The *second, third, and fourth* bytes in a multi-byte sequence *always* start with **10**.
> This indicates that these bytes are continuation bytes, following the main byte.
> 
> The remaining bits in the main byte, along with the bits in the continuation bytes, are combined to form the character's code point.
> A code point serves as a unique identifier for a character in the Unicode character set.

[2] From the man page for `xxd(1)`:

```
   -g bytes | -groupsize bytes
         Separate the output of every <bytes> bytes (two hex characters
         or eight bit digits each) by a whitespace.  Specify -g 0 to
         suppress grouping.  <Bytes> defaults to 2 in normal mode, 4 in
         little-endian mode and 1 in bits mode.  Grouping does not apply
         to PostScript or include style.
```

[3] Rest assured that it's known how to convert binary to decimal:

```
0 x 2^0 = 0 x 1 = 0
0 x 2^1 = 0 x 2 = 0
1 x 2^2 = 1 x 4 = 4
1 x 2^3 = 1 x 8 = 8
```

```
4 + 8 = 12
```

[4] More about Page break/Form feed [Page break - Wikipedia](https://en.wikipedia.org/wiki/Page_break): [<sup>[4](#footnotes)</sup>] 
> A *page break* is a marker in an electronic document that tells the document interpreter the content which follows is part of a new page.
> A page break causes a **form feed** to be sent to the printer during *spooling* of the document to the printer.
> It is one of the elements that contributes to *pagination*.
>
> **Form feed**
> 
> Form feed is a *page-breaking* ASCII *control character*.
> It directs the printer to eject the current page and to continue printing at the top of another.
> It will often also cause a carriage return.
> The form feed character code is defined as **12** (**0xC** in hexadecimal), and may be represented as `Ctrl+L` or `^L`.
>
> In a related use, `Ctrl+L` can be pressed to clear the screen in Unix shells such as bash, or redraw the screen in TUI programs like vi/emacs.
> In the C programming language (and other languages derived from C), the form feed character is represented as `'\f'`.
> 
> Unicode also provides the character [U+21A1 ↡ DOWNWARDS TWO HEADED ARROW](https://www.unicode.org/charts/PDF/U2190.pdf) as a printable symbol for a form feed (not as the form feed itself).
> The form feed character is considered *whitespace* by the C character classification function `isspace()`. 
> 
> [ . . . ]
> 
> **Semantic use**
>
> The form feed character is sometimes used in *plain text* files of *source code* as a *delimiter* for a *page break*, or as *marker* for *sections of code*.
> Some editors, in particular *emacs* and *vi*, have built-in commands to *page up/down* on the form feed character.
> This convention is predominantly used in Lisp code, and is also seen in C and Python source code.
> GNU Coding Standards require such form feeds in C. [<sup>[5](#footnotes)</sup>] 

[5] [GNU Coding Standards - Use formfeed characters (control-L) to divide the program into pages at logical places](https://www.gnu.org/prep/standards/standards.html#index-control_002dL):
> Please use formfeed characters (`control-L`) to *divide* the program into *pages* at *logical places* (but not within a function).
> It does not matter just how long the pages are, since they do not have to fit on a printed page.
> The formfeeds should appear *alone on lines by themselves*. 

---

# References

* [Remind - a sophisticated calendar and alarm program](https://dianne.skoll.ca/projects/remind/)

* [UTF-8 is a Brilliant Design](https://iamvishnu.com/posts/utf8-is-brilliant-design)
(Posted on 2025-09-12. Retrieved on 2025-09-20.)
> The first time I learned about UTF-8 encoding, I was fascinated by how well-thought and brilliantly it was designed to represent millions of characters from different languages and scripts, and **still be backward compatible with ASCII**.
> 
> Basically UTF-8 uses 32 bits and the old ASCII uses 7 bits, but UTF-8 is designed in such a way that:
> * Every ASCII encoded file is a valid UTF-8 file.
> * Every UTF-8 encoded file that has only ASCII characters is a valid ASCII file.
>
> Designing a system that scales to millions of characters and still be compatible with the old systems that use just 128 characters is a brilliant design.

* [UTF-8 Playground](https://utf8-playground.netlify.app/)
> **UTF-8 Encoding**
>
> UTF-8 is a **variable-width** character encoding designed to represent *every* character in the *Unicode* character set, encompassing characters from most of the world's writing systems.
> 
> It encodes characters using **one** to **four** bytes.
> The *first 128 characters* (U+0000 to U+007F) are encoded with a **single byte**, ensuring backward *compatibility* with **ASCII** (read my post on this↗), while *other* characters require *two*, *three*, or *four* bytes.
> 
> The *leading* bits of the *first* byte determine the *total number of bytes* in the character.
> These bits follow *one of four specific patterns*, which indicate how many *continuation* bytes follow.
>
> ``` 
>    0xxxxxxx: 1 byte
>        0xxxxxxx
>    110xxxxx: 2 bytes
>        110xxxxx 10xxxxxx
>    1110xxxx: 3 bytes
>        1110xxxx 10xxxxxx 10xxxxxx
>    11110xxx: 4 bytes
>        11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
> ``` 
>
> The *second, third, and fourth* bytes in a multi-byte sequence *always* start with **10**.
> This indicates that these bytes are continuation bytes, following the main byte.
> 
> The remaining bits in the main byte, along with the bits in the continuation bytes, are combined to form the character's code point.
> A code point serves as a unique identifier for a character in the Unicode character set.

* [Complete Character List for UTF-8](https://www.fileformat.info/info/charset/UTF-8/list.htm)

* [Unicode Character 'FORM FEED (FF)' (U+000C)](https://www.fileformat.info/info/unicode/char/000c/index.htm)

* [Fonts that support U+000C](https://www.fileformat.info/info/unicode/char/000c/fontsupport.htm)

* [LastResort font - fileformat](https://www.fileformat.info/info/unicode/font/lastresort/u000C.png)

* [Unifont font - fileformat](https://www.fileformat.info/info/unicode/font/unifont/u000C.png)

* [Control character - Wikipedia](https://en.wikipedia.org/wiki/Control_character)

* [Page break - Wikipedia](https://en.wikipedia.org/wiki/Page_break)

* [C0 and C1 control codes](https://en.wikipedia.org/wiki/C0_and_C1_control_codes)

* [How to get the unicode characters for CTRL+B, CTRL+L, ALT+K, etc...?](https://stackoverflow.com/questions/20885941/how-to-get-the-unicode-characters-for-ctrlb-ctrll-altk-etc)

* [Four Column ASCII](https://garbagecollected.org/2017/01/31/four-column-ascii/)

* [I always thought it was a shame the ASCII table is rarely shown in columns (or rows) of 32](https://news.ycombinator.com/item?id=13499386)
> I always thought it was a shame the ascii table is rarely shown in columns (or rows) of 32, as it makes a lot of this quite obvious. e.g., [http://pastebin.com/cdaga5i1](http://pastebin.com/cdaga5i1)
> 
> It becomes immediately obvious why, e.g., `^[` becomes **escape**.
> Or that the alphabet is just `40h` **+** the *ordinal position of the letter* (or `60h` for *lower-case*).
> Or that we *shift* between *upper* & *lower*-case with a *single bit*.
> 
> esr's rendering of the table - forcing it to fit hexadecimal as eight groups of 4 bits, rather than four groups of 5 bits, makes the relationship between `^I` and *tab*, or `^[` and *escape*, nearly invisible.
> 
> It's like making the periodic table 16 elements wide because we're partial to hex, and then wondering why no-one can spot the relationships anymore.

* [UTF-8 Tool](https://www.cogsci.ed.ac.uk/~richard/utf-8.cgi)

* [Why “caffè” may not be “caffè”](https://journal.bsd.cafe/2025/09/01/why-caffe-may-not-be-caffe/)

* [Unicode encodings - Programming with Unicode book](https://unicodebook.readthedocs.io/unicode_encodings.html)

* [Insert ASCII Control Characters in Text](https://web.archive.org/web/20130312024614/http://www.bo.infn.it/alice/alice-doc/mll-doc/linux/vi-ex/node15.html)

* [ASCII control codes](https://en.wikipedia.org/wiki/ASCII#Control_characters)

* [Unicode lookup table source: UnicodeData.txt](https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt)

* [Transform Rule Tutorial - ICU Documentation (useful for uconv)](https://unicode-org.github.io/icu/userguide/transforms/general/rules.html)

* [Unicode - a brief introduction (advanced](https://exploringjs.com/js/book/ch_unicode.html)

* [Control keys and control characters](https://www.johndcook.com/blog/2019/09/28/control-characters/)
> Control-[
> 
> Some control characters correspond to characters other than letters.
> If you flip the second bit of the ASCII code for `[` you get the control character for **escape**.
* And in some software, such as *vi* or *Emacs*, `Control-[` has the *same effect* as the *escape key*.
>
> [ . . . ]
>
> [1] Control keys are often written with capital letters, like Control-H.
> This can be misleading if you think this means you have to also hold down the shift key as if you were typing a capital H.
> Control-h would be better notation.
> But the ASCII codes for control characters correspond to capital letters, so I use capital letters here.

* [How UTF-8 works](https://www.johndcook.com/blog/2019/09/09/how-utf-8-works/)

* [ASCII Table](https://www.asciitable.com/)

* [GNU coding standards stipulates formfeed in source code. Why? (gnu.org)](https://old.reddit.com/r/programming/comments/2eixhe/gnu_coding_standards_stipulates_formfeed_in/)

---

# Further Reading

* [Category:Control characters - Wikipedia](https://en.wikipedia.org/wiki/Category:Control_characters)
> 
> * [Subcategory (of the Category:Control characters) - Unicode special code points (6 P)](https://en.wikipedia.org/wiki/Category:Unicode_special_code_points) 
> *For formatting characters, see [Category:Unicode formatting code points](https://en.wikipedia.org/wiki/Category:Unicode_formatting_code_points).*
> 
> This category lists code points in Unicode that have a special meaning, as defined by Unicode.
> Sometimes these are called, incorrectly, "special characters", but not all are characters.
> Most clearly since some code points designated "\<not a character\>".
>
> (without links for Pages on Wikipedia):
> 
> * Byte order mark (BOM)
> * Combining character
> * Combining grapheme joiner
> * Unicode control characters
> * Figure space
> * Regional indicator symbol 
 
Pages in [Category: Control characters](https://en.wikipedia.org/wiki/Category:Control_characters)
> (without links for Pages on Wikipedia):
> 
> * Control character
> * Acknowledgement (data networks)
> * Arabic letter mark
> * ASA carriage control characters
> * ASCII control character
> * ASCII control characters
> * ASCII control code
> * ASCII control codes
> * Backspace
> * Bell character
> * Block check character
> * C0 and C1 control codes
> * Cancel character
> * Caret notation
> * Carriage return
> * Combining grapheme joiner
> * Delete character
> * Eight Ones
> * End-of-Text character
> * End-of-Transmission character
> * End-of-Transmission-Block character
> * Enquiry character
> * Escape character
> * Escape sequence
> * Escape sequences in C
> * Figure space
> * Form feed
> * Implicit directional marks
> * Left-to-right mark
> * Line feed
> * Line starve
> * Narrow no-break space
> * Newline
> * Non-breaking space
> * Null character
> * Page break (Form feed)
> * Right-to-left mark
> * Shift Out and Shift In characters
> * Soft hyphen
> * Space (punctuation)
> * Substitute character
> * Syriac Abbreviation Mark
> * Tab character
> * Tab key
> * Word joiner
> * XON/XOFF
> * Zero-width joiner (ZWJ)
> * Zero-width no-break space (ZWNBSP)
> * Zero-width non-joiner (ZWNJ)
> * Zero-width space (ZWSP)


* man `termios(4)`
>
> ```
> NAME
>      termios - general terminal line discipline
> [ . . . ]
> ```

---

