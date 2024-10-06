---
layout: post
title: "Encodings, UTF-8 and Unicode Notes"
date: 2024-09-17 10:40:13 -0700 
categories:  unicode utf8 x11 xorg xterm cli terminal shell howto sysadmin
             unix perl python vi vim ascii plaintext text tex latex pdf
             typography font html design webbrowser webdevelopment awk regex
             programming coding development tool reference dotfiles tip howto
---

OS: *FreeBSD 14*

```
% freebsd-version 
14.0-RELEASE-p6
```

Shell: *tcsh* [<sup>[1](#footnotes)</sup>]

Locale:

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


NOTE: Similar to Wikipedia note for [Emoji article](https://en.wikipedia.org/wiki/Emoji), heed this note:

This page contains [Unicode emoticons or emojis](https://en.wikipedia.org/wiki/Emoji#In_Unicode). Without proper rendering support, you may see [question marks, boxes, or other symbols](https://en.wikipedia.org/wiki/Specials_(Unicode_block)#Replacement_character) instead of the intended characters. [<sup>[2](#footnotes)</sup>]


## Programs from `uniutils` Package 

```
% pkg query %Fp uniutils | wc -l
      31
 
% pkg query %Fp uniutils | grep bin
/usr/local/bin/ExplicateUTF8
/usr/local/bin/unidesc
/usr/local/bin/unifuzz
/usr/local/bin/unihist
/usr/local/bin/uniname
/usr/local/bin/unireverse
/usr/local/bin/unisurrogate
/usr/local/bin/utf8lookup
```

```
% printf '\302\240' | uniname
No LINES variable in environment so unable to determine lines per page.
Using default of 24.
character  byte       UTF-32   encoded as     glyph   name
        0          0  0000A0   C2 A0                  NO-BREAK SPACE
``` 

```
% printf '\302\240' | env LINES=0 uniname
character  byte       UTF-32   encoded as     glyph   name
        0          0  0000A0   C2 A0                  NO-BREAK SPACE

% printf '\302\240' | env LINES=1 uniname
        0          0  0000A0   C2 A0                  NO-BREAK SPACE
```

``` 
% printf '\302\240' | unidesc
       0               0        Latin-1 Supplement
```

```
% printf '\302\240' | ExplicateUTF8
The sequence 0xC2     0xA0     
             11000010 10100000 
is a valid UTF-8 character encoding equivalent to UTF32 0x000000A0.
The first byte tells us that there should be 1
continuation bytes since it begins with 2 contiguous 1s.
There are 1 following bytes and all are valid
continuation bytes since they all have high bits 10.
The first byte contributes its low 5 bits.
The remaining bytes each contribute their low 6 bits,
for a total of 11 bits: 00010 100000 
This is padded to 32 places with 21 zeros: 0000000000000000000000000000000000000000000000000000000010100000
                                           0   0   0   0   0   0   A   0
```

```
% env LINES=0 utf8lookup 0000A0
UTF-32   name
0000A0  NO-BREAK SPACE

% env LINES=1 utf8lookup 0000A0
0000A0  NO-BREAK SPACE
```

----

## Converting Multi-Byte Characters

## Example: Detect and Convert

Paste the character you want to analyze into a file.

**NOTE:**
Depending on fonts you have on your system and your Web browser setup, you might not see the glyph representing this character (which is an emoji) in some of the outputs below.

```
% cat /tmp/convchar
🤔
```

### Explain both UTF-8 (Hex UTF-8 Bytes) and Unicode (Unicode Hex Point)

#### With `ExplicateUTF8(1)`

```
% ExplicateUTF8 /tmp/convchar 
The sequence 0xF0     0x9F     0xA4     0x94     
             11110000 10011111 10100100 10010100 
is a valid UTF-8 character encoding equivalent to UTF32 0x0001F914.
The first byte tells us that there should be 3
continuation bytes since it begins with 4 contiguous 1s.
There are 3 following bytes and all are valid
continuation bytes since they all have high bits 10.
The first byte contributes its low 3 bits.
The remaining bytes each contribute their low 6 bits,
for a total of 21 bits: 000 011111 100100 010100 
This is padded to 32 places with 11 zeros: 0000000000000000000000000000000000000000000000011111100100010100
                                           0   0   0   1   F   9   1   4
```

This chacter in UTF-8: `F0 9F A4 94` 

This chacter in Unicode: `1F914`


From the above output of the `ExplicateUTF8(1)` tool:

```
... for a total of 21 bits: 000 011111 100100 010100"
```

The 21 bits: `000 011111 100100 010100`


Convert binary to hex.

```
% printf "obase=16; ibase=2; 000011111100100010100" | bc
1F914
```

Or, with padding:


```
% printf "obase=16; ibase=2; 0000000000000000000000000000000000000000000000011111100100010100" | bc
1F914
```


#### With `uniname(1)`

```
% env LINES=0 uniname /tmp/convchar
character  byte       UTF-32   encoded as     glyph   name
        0          0  01F914   F0 9F A4 94    🤔      Character in undefined range
        1          4  00000A   0A                     LINE FEED (LF)
```


### UTF-8 bytes as Latin-1 Characters Bytes

About Latin-1 characters bytes: 
From [UTF-8 Conversion Tool by Richard Tobin](https://www.cogsci.ed.ac.uk/~richard/utf-8.cgi):
> *UTF-8 bytes as Latin-1 characters* is what you typically see when you display a UTF-8 file with a terminal or editor that only knows about 8-bit characters.


WARNING: On my FreeBSD 14 system, `iconv(1)` in the base install considered LATIN1 and ISO-8859-15 encodings as the same, while `iconv(1)` installed as a package didn't. 
This mattered because using `iconv(1)` with ISO-8859-15 encoding resulted in an incorrect output.

For more details, see Footnote 3. [<sup>[3](#footnotes)</sup>]

```
% where where
where is a shell built-in

% which which
which: shell built-in command.

% where whereis
/usr/bin/whereis

% where which
which is a shell built-in
/usr/bin/which
```

```
% command -V iconv
iconv is /usr/bin/iconv

% type iconv
iconv is /usr/bin/iconv

% which iconv
/usr/bin/iconv
 
% whereis -a iconv
iconv: /usr/bin/iconv /usr/local/bin/iconv /usr/share/man/man1/iconv.1.gz /usr/local/share/man/man1/iconv.1.gz /usr/share/man/man3/iconv.3.gz /usr/local/share/man/man3/iconv.3.gz
 
% where iconv
/usr/bin/iconv
/usr/local/bin/iconv
```

With `iconv(1)` from base install:

```
% iconv -l | grep -w -i LATIN1 | grep -i ISO-8859-15
ISO-8859-1 CP819 CSISOLATIN1 IBM819 ISO-IR-100 ISO8859-1 ISO_8859-1 ISO_8859-1:1987 L1 LATIN1 CSISOLATIN6 ISO-8859-10 ISO-IR-157 ISO8859-10 ISO_8859-10 ISO_8859-10:1992 L6 LATIN6 ISO-8859-11 ISO-IR-166 ISO8859-11 ISO_8859-11 TIS-620 TIS.2533-1 TIS620 TIS620-0 TIS620.2529-1 TIS620.2533-0 ISO-8859-13 ISO-IR-179 ISO8859-13 ISO_8859-13 ISO_8859-13:1998 L7 LATIN7 ISO-8859-14 ISO-CELTIC ISO-IR-199 ISO8859-14 ISO_8859-14 ISO_8859-14:1998 L8 LATIN8 CP923 IBM923 ISO-8859-15 ISO-IR-203 ISO8859-15 ISO_8859-15 ISO_8859-15:1998 L9 LATIN9 ISO-8859-16 ISO-IR-226 ISO8859-16 ISO_8859-16 ISO_8859-16:2001 L10 LATIN10
```


With `iconv(1)` from packages:

``` 
% /usr/local/bin/iconv -l | grep -w -i LATIN1 | grep -i ISO-8859-15 
```

```
% /usr/local/bin/iconv -l | grep -w -i LATIN1
CP819 IBM819 ISO-8859-1 ISO-IR-100 ISO8859-1 ISO_8859-1 ISO_8859-1:1987 L1 LATIN1 CSISOLATIN1
RISCOS-LATIN1
```

Incorect:

```
% iconv -f iso-8859-15 -t UTF-8 /tmp/convchar | od -ac
0000000   c3  b0  c2  9f  e2  82  ac  c2  94  nl                        
           ð  ** 302 237   €  **  ** 302 224  \n                        
0000012
```

```
% iconv -f iso-8859-15 -t UTF-8 /tmp/convchar | od -ab
0000000   c3  b0  c2  9f  e2  82  ac  c2  94  nl                        
          303 260 302 237 342 202 254 302 224 012
0000012
```
 
```
% printf '\303\260'
ð% 
```
 
```
% printf '\342\202\254'
€% 
```


Corect:

```
% iconv -f LATIN1 /tmp/convchar | od -ac
0000000   c3  b0  c2  9f  c2  a4  c2  94  nl                            
           ð  ** 302 237   ¤  ** 302 224  \n                            
0000011
```

Or, with `iconv(1)` from packages:

```
% /usr/local/bin/iconv -f LATIN1 /tmp/convchar | od -ac
0000000   c3  b0  c2  9f  c2  a4  c2  94  nl                            
           ð  ** 302 237   ¤  ** 302 224  \n                            
0000011
```

```
% /usr/local/bin/iconv -f LATIN1 /tmp/convchar | od -ab
0000000   c3  b0  c2  9f  c2  a4  c2  94  nl                            
          303 260 302 237 302 244 302 224 012                            
0000011
```

```
% printf '\303\260'
ð% 
 
% printf '\303\260\302'
ð�% 
 
% printf '\302\244'
¤% 
 
% printf '\302\244\302'
¤�% 
```

 
UTF-8 bytes as Latin-1 characters bytes: `ð <9F> ¤ <94>` 


### Hex UTF-16 Surrogates

```
% unisurrogate 1F914
The surrogate representation of U+1F914 is U+D83E U+DD14
```

Also see:

[The Surrogate Pair Calculator etc. by  Russell W. Cottrell](https://www.russellcottrell.com/greek/utilities/SurrogatePairCalculator.htm)
> A surrogate pair is defined by the Unicode Standard as "a representation for a single abstract character that consists of a sequence of two 16-bit code units, where the first value of the pair is a high-surrogate code unit and the second value is a low-surrogate code unit."
> Since Unicode is a **21-bit standard**, surrogate pairs are needed by applications that use **UTF-16**, such as *JavaScript*, to display characters whose code points are *greater than 16-bit*.
> (**UTF-8**, the most popular *HTML* encoding, uses a more flexible method of representing high-bit characters and does **not** use surrogate pairs.)
>
> The algorithm for converting to and from surrogate pairs is not widely published on the internet.  (But the code here has been "borrowed" a time or two!)
> The official source is The Unicode Standard, Version 3.0 | Unicode 3.0.0 (not later versions), Section 3.7, Surrogates.


### Conversion to UTF-8 (Hex UTF-8 Bytes)

#### With `od(1)` 

```
% od -ac /tmp/convchar
0000000   f0  9f  a4  94  nl
          🤔  **  **  **  \n
0000005
```

NOTE: This is a muli-byte character, with byte count of **4**, starting with `f0`.

From the man page for `od(1)`:

```
Multi-byte characters are displayed in the area
corresponding to the first byte of the character.
The remaining bytes are shown as ‘**’.
```


In UTF-8 (Hex UTF-8 Bytes), this character is `F0 9F A4 94`.


#### With `xxd(1)`

```
% xxd < /tmp/convchar 
00000000: f09f a494 0a                             .....
```

The `xxd(1)` output's screen capture so the colours are visible:

![Unicode character name Thinking Face - Conversion to UTF-8 with xxd(1)](/assets/img/unicode-to-utf8-with-xxd.jpg "Unicode character name Thinking Face - Conversion to UTF-8 with xxd(1)")


### Conversion to Unicode (Unicode Hex Point)

OS and shell: FreeBSD 14, tcsh


#### With `iconv(1)` **and** `xxd(1)` 

```
% iconv -t utf-32 /tmp/convchar | xxd
00000000: 0000 feff 0001 f914 0000 000a            ............
``` 

In Unicode (Unicode Hex Point), this character is `01f914`; that is, `1f914`.


#### With `od(1)`, `printf(1)` and `uniname(1)`

```
% od -ab /tmp/convchar
0000000   f0  9f  a4  94  nl                                            
          360 237 244 224 012                                            
0000005
```

```
% printf '\360\237\244\224' | env LINES=0 uniname
character  byte     UTF-32   encoded as     glyph   name
        0        0  01F914   F0 9F A4 94    🤔      Character in undefined range
```


The `xxd(1)` output's screen capture so the colours are visible:

![Unicode character name Thinking Face - Conversion to UTF-8 with iconv(1) and xxd(1)](/assets/img/unicode-to-utf8-with-iconv-and-xxd.jpg "Unicode character name Thinking Face - Conversion to UTF-8 with iconv(1) and xxd(1)")


----

## With All-In-One Tool: UTF-8 Conversion Tool by Richard Tobin

[UTF-8 Conversion Tool -- Interpreting a Unicode character as Hex UTF-8 bytes for a character represented with: F0 9F A4 94](https://www.cogsci.ed.ac.uk/~richard/utf-8.cgi?input=F0+9F+A4+94&mode=bytes)

![Unicode character name Thinking Face - Conversions with UTF-8 Conversion Tool by Richard Tobin](/assets/img/unicode-21-bits.jpg "Unicode character name Thinking Face - Conversions with UTF-8 Conversion Tool by Richard Tobin")

----

## With All-In-One Tool: `uni` Tool by Martin Tournoij

[uni - Query the Unicode database from the commandline, with good support for emojis](https://github.com/arp242/uni)

Available as a package for FreeBSD:

[uni on FreshPorts](https://www.freshports.org/textproc/uni)

[uni on pkgs.org](https://freebsd.pkgs.org/14/freebsd-amd64/uni-2.7.0_3.pkg.html)

In addition, available as a WASM (WebAssembly) demo: [https://arp242.github.io/uni-wasm/](https://arp242.github.io/uni-wasm/)

uni WASM (WebAssembly) demo details: [Running Go CLI programs in the browser with WASM](https://www.arp242.net/wasm-cli.html)

Project home page: [https://github.com/arp242/uni](https://github.com/arp242/uni)


For `uni` help, see Footnote 4. [<sup>[4](#footnotes)</sup>]


```
% uni identify < /tmp/convchar
             Dec    UTF8        HTML       Name
'🤔' U+1F914 129300 f0 9f a4 94 &#x1f914;  THINKING FACE
``` 

```
% uni identify --format '%unicode %name' < /tmp/convchar
Unicode Name
8.0     THINKING FACE
```

Include all columns:

NOTE: Here, `json` field represents what *UTF-8 Conversion Tool by Richard Tobin* calls *UTF-8 bytes as Latin-1 Characters Bytes*.

```
% uni identify --format all < /tmp/convchar
             Width Cells Dec    Hex   Oct    Bin               UTF8        UTF16LE     UTF16BE     HTML      XML       JSON         Keysym Digraph Name          Plane                            Cat          Block                                Script Props Unicode Aliases Refs
'🤔' U+1F914 wide  2     129300 1f914 374424 11111100100010100 f0 9f a4 94 3e d8 14 dd d8 3e dd 14 &#x1f914; &#x1f914; \ud83e\udd14                THINKING FACE Supplementary Multilingual Plane Other_Symbol Supplemental Symbols and Pictographs Common       8.0
```

Output data as JSON:

```
% uni identify --as json --format all < /tmp/convchar
[{
        "aliases": "",
        "bin":     "11111100100010100",
        "block":   "Supplemental Symbols and Pictographs",
        "cat":     "Other_Symbol",
        "cells":   "2",
        "char":    "🤔",
        "cpoint":  "U+1F914",
        "dec":     "129300",
        "digraph": "",
        "hex":     "1f914",
        "html":    "&#x1f914;",
        "json":    "\\ud83e\\udd14",
        "keysym":  "",
        "name":    "THINKING FACE",
        "oct":     "374424",
        "plane":   "Supplementary Multilingual Plane",
        "props":   "",
        "refs":    "",
        "script":  "Common",
        "unicode": "8.0",
        "utf16be": "d8 3e dd 14",
        "utf16le": "3e d8 14 dd",
        "utf8":    "f0 9f a4 94",
        "width":   "wide",
        "xml":     "&#x1f914;"
}]
```

----

## With All-In-One Tool: `unicode` Tool by Radovan Garabík 

Project home page: [https://github.com/garabik/unicode](https://github.com/garabik/unicode)

> unicode, simple command line utility that displays properties for a given unicode character, or searches unicode database for a given name. 

```
% git clone https://github.com/garabik/unicode.git
```

```
% cd unicode/
```

```
% ls
changelog       MANIFEST.in     README          setup.py
COPYING         paracode        README-paracode unicode
debian          paracode.1      setup.cfg       unicode.1
```

```
% python3 setup.py --help
[ . . . ]
  setup.py build      will build the package underneath 'build/'
[ . . . ]
```

```
% python3 setup.py build
```

```
% ls -Alhrt | tail -1
drwxr-xr-x  3 dusko wheel    3B Aug 12 19:50 build
```

```
% ls -Alhrt build/
total 1
drwxr-xr-x  2 dusko wheel    4B Aug 12 19:50 scripts-3.9
 
% ls -Alhrt build/scripts-3.9/
total 25
-rwxr-xr-x  1 dusko wheel   40K Aug 12 19:50 unicode
-rwxr-xr-x  1 dusko wheel  7.0K Aug 12 19:50 paracode
```

```
% build/scripts-3.9/unicode --help
[ . . . ]
  --download            Try to dowload UnicodeData.txt
[ . . . ]
```

```
% build/scripts-3.9/unicode --download
Downloading UnicodeData.txt from http://www.unicode.org/Public/15.1.0/ucd/UnicodeData.txt
downloading.../home/dusko/.unicode/UnicodeData.txt.gz downloaded
```

```
% build/scripts-3.9/unicode 1F914
U+1F914 THINKING FACE
UTF-8: f0 9f a4 94 UTF-16BE: d83edd14 Decimal: &#129300; Octal: \0374424
🤔
Category: So (Symbol, Other); East Asian width: W (wide)
Bidi: ON (Other Neutrals)
```

NOTE: This tool also shows some additional information, like Decomposition:

```
% build/scripts-3.9/unicode 00c0
U+00C0 LATIN CAPITAL LETTER A WITH GRAVE
UTF-8: c3 80 UTF-16BE: 00c0 Decimal: &#192; Octal: \0300
À (à)
Lowercase: 00E0
Category: Lu (Letter, Uppercase); East Asian width: N (neutral)
Bidi: L (Left-to-Right)
Decomposition: 0041 0300
```

----


### What's the Name of the Unicode Character?


#### Straight from Unicode.org

```
% fetch http://unicode.org/Public/UNIDATA/UnicodeData.txt
UnicodeData.txt                                       1869 kB  690 kBps    02s
```

```
% grep -i 1F914 UnicodeData.txt
1F914;THINKING FACE;So;0;ON;;;;;N;;;;;
```

The name of this character is *Thinking Face*.


#### From UCD (Unicode Character Database) Package in FreeBSD

Available as a package on FreeBSD 14.


```
% sudo pkg install UCD
```

```
% pkg query %Fp UCD | wc -l
      81
```

```
% pkg query %Fp UCD
[ . . . ]
/usr/local/share/unicode/ucd/ReadMe.txt
[ . . . ]
/usr/local/share/unicode/ucd/UnicodeData.txt
[ . . . ]
```

```
% grep 1F914 /usr/local/share/unicode/ucd/UnicodeData.txt
1F914;THINKING FACE;So;0;ON;;;;;N;;;;;
```

```
% grep -r -n -i 1F914 /usr/local/share/unicode/ucd/
/usr/local/share/unicode/ucd/UnicodeData.txt:33380:1F914;THINKING FACE;So;0;ON;;;;;N;;;;;
/usr/local/share/unicode/ucd/extracted/DerivedName.txt:43179:1F914         ; THINKING FACE
/usr/local/share/unicode/ucd/NamesList.txt:53248:1F914  THINKING FACE
```

#### With the `uni` Tool

On FreeBSD 14 installed as `sudo pkg install uni`.

```
% uni print 1F914
             Dec    UTF8        HTML       Name
'🤔' U+1F914 129300 f0 9f a4 94 &#x1f914;  THINKING FACE
```

Confirm:

```
% uni search thinking face
             Dec    UTF8        HTML       Name
'🤔' U+1F914 129300 f0 9f a4 94 &#x1f914;  THINKING FACE
```

----

### Converting from Unicode/UTF to ISO

From [utf8  on grml - Converting Files - GrmlWiki](http://wiki.grml.org/doku.php?id=utf8):

**Converting files from Unicode / UTF to ISO:**

```
% iconv -c -f utf8 -t iso-8859-15 < utffile > isofile
```

and vice versa:

```
% iconv -f iso-8859-15 -t utf8 < isofile > utffile
```

----

## Unicode Escape Formats

From [Unicode Escape Formats](https://www.billposer.org/Software/ListOfRepresentations.html):
> The following are ASCII representations of Unicode characters known to be used in various contexts.
> In a few cases we also include unusual representations of integers since integers are sometimes converted to characters. 

----

## My Selection of Tools and References

### UNUM: Unicode/HTML/Numeric Character Code Converter

> Interconvert numbers, Unicode, and HTML/XHTML entities

Perl tool     

Author: John Walker (www.fourmilab.ch), founder of Autodesk, Inc. and co-author of AutoCAD  

Project home page: [https://www.fourmilab.ch/webtools/unum/](https://www.fourmilab.ch/webtools/unum/)

About UNUM - From author's [Unix Utilities](https://www.fourmilab.ch/nav/topics/unix.html) page:
> Web authors who use characters from other languages, mathematical symbols, fancy punctuation, and other typographic embellishment in their documents often find themselves juggling the Unicode book, an HTML entity reference, and a programmer's calculator to convert back and forth between the various representations. This stand-alone command line Perl program contains complete databases of Unicode characters and character blocks and HTML/XHTML named character references, and permits easy lookup and interconversion among all the formats, including octal, decimal, and hexadecimal numbers. The program works best on a recent version of Perl, such as v5.8.5 or later, but requires no Perl library modules. New version 3.4-14.0.0 (September 2021) updates to the Unicode 14.0.0 standard and the new scripts, characters, and emoji it adds. 

----

### `uni.pl`: List Unicode symbols matching pattern

Project home page:
[uni.pl - Perl script from leahneukirchen (Leah Neukirchen) - List Unicode symbols matching pattern](https://leahneukirchen.org/dotfiles/bin/uni)

----

###  Perl, `uni.pl`, `xxd`, `iconv`, `hexdump` (`hd`), `od`, `printf`

```
% ./uni.pl crossbones
☠       2620    SKULL AND CROSSBONES
🕱       1F571   BLACK SKULL AND CROSSBONES

% ./uni.pl 2620
☠       2620    SKULL AND CROSSBONES

% ./uni.pl 2620 | cut -w -f1
☠

% ./uni.pl 2620 | cut -w -f1 > skandcr.txt

% cat skandcr.txt
☠

% xxd < skandcr.txt 
00000000: e298 a00a                                ....
```

NOTE: `xxd(1)` displayed the first three dots at the in *red* colour, and the fourth dot in *yellow*.
Accordingly, it also displayed `e298 a0` in *red*, and `0a` in *yellow*.


```
% uchardet < skandcr.txt
UTF-8
```

```
% iconv -t utf8 < skandcr.txt
☠
 
% iconv -t utf8 skandcr.txt | od -ac 
0000000   e2  98  a0  nl
           ☠  **  **  \n
0000004
```

NOTE: So in UTF-8, the symbol (for skull and crossbones) *below* `e2` and `**` in the next two groups, that is, below `98` and below `a0` so this symbol consists of **3 bytes** (or 6 digits). 

In octal:
 
```
% iconv -t utf8 skandcr.txt | od -ab
0000000   e2  98  a0  nl
          342 230 240 012
0000004
```

Pick up the first **three** bytes:

```
% printf '\342\230\240'
☠% 
```

Reference:

[How do you echo a 4-digit Unicode character in Bash?](https://stackoverflow.com/questions/602912/how-do-you-echo-a-4-digit-unicode-character-in-bash)


```
% iconv -t utf16 skandcr.txt | xxd
00000000: feff 2620 000a                           ..& ..
```

NOTE: `xxd(1)` displayed the first dot in *red*, the second dot in *dark green*, the ampresend (&) in  light green, the next dot in *white*, the last dot in *yellow*.
Accordingly, it also displayed `fe` in *red*, `ff` in *dark green*, `2620` in *light green*, `00` in *white*, and `0a` in *yellow*.


NOTE: 
> In **UTF-16**, a **BOM** (`U+FEFF`) are the first bytes of a file or character stream to indicate the endianness (byte order) of all the 16-bit code units of the file for stream.
> If an attempt is made to read this stream with the wrong endianness, the bytes will be swapped, thus delivering the character U+FFFE, which is defined by Unicode as a "noncharacter" that should never appear in the text. 
> 
> * If the 16-bit units are represented in big-endian byte order ("UTF-16BE"), the BOM is the (hexadecimal) byte sequence FE FF
> * If the 16-bit units use little-endian order ("UTF-16LE"), the BOM is the (hexadecimal) byte sequence FF FE
> 
> For the IANA registered charsets UTF-16BE and UTF-16LE, a byte-order mark should not be used because the names of these character sets already determine the byte order. 
> 
> . . . 
> 
> **UTF-32**
> 
> Although a BOM could be used with UTF-32, this encoding is rarely used for transmission. Otherwise the same rules as for UTF-16 are applicable.
> 
> The BOM for little-endian UTF-32 is the same pattern as a little-endian UTF-16 BOM followed by a UTF-16 NUL character, an unusual example of the BOM being the same pattern in two different encodings. Programmers using the BOM to identify the encoding will have to decide whether UTF-32 or UTF-16 with a NUL first character is more likely. 

Source: 
[Wikipedia - Byte order mark (BOM)](https://en.wikipedia.org/wiki/Byte_order_mark)


```
% perl -CS -E 'say "\x{2620}"'
☠
```

* [Unicode font utilities - Russell W. Cottrell - unicode_font_utilities.zip](https://www.russellcottrell.com/greek/utilities/unicode_font_utilities.zip)
> The zip file includes four utilities: *The Unicode Range Viewer*, *The Surrogate Pair Calculator etc.*, *The Polytonic Greek Virtual Keyboard* and  *The Greek Number Converter*.

* [Unicode browser (Unicode table for you)](https://www.ftrain.com/unicode)
> Source code: It's all on one page (HTML/CSS/JavaScript) and under the GPL/MIT license.

NOTE: In my tests, *Unicode table for you* didn't work when I accessed it from ftrain.com; however, it worked when I saved that page locally as *.html* and then opened it with my Web browser, Mozilla Firefox.

* [Wakamai Fondue - What can my font do?](https://wakamaifondue.com/)
> Wakamai Fondue is a tool that answers the question "What can my font do?"
> 
> Drop a font on it, or click the circle to upload one, and Wakamai Fondue will tell you about the features in the font. It will also give you all the CSS needed to actually use these features in your web projects!
> 
> Everything is processed inside the browser - your font will not be sent to a server!
> 

* [Perl Unicode Cookbook: The Standard Preamble](https://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html/)
> Apr 2, 2012 by Tom Christiansen
>
> Editor's note:
> Perl guru Tom Christiansen created and maintains a list of 44 recipes for working with Unicode in Perl 5.
> This is the first recipe in the series.

----

```
% perl -E 'my $x = "\N{SKULL AND CROSSBONES}"; say $x' | xxd
Wide character in say at -e line 1.
00000000: e298 a00a                                ....
```

```
% perl -E 'my $x = "\N{SKULL AND CROSSBONES}"; say $x' | hexdump -C
Wide character in say at -e line 1.
00000000  e2 98 a0 0a                                       |....|
00000004
```

To avoid `Wide character in say` warning: 

```
% perl -E 'use open qw(:std :encoding(UTF-8)); my $x = "\N{SKULL AND CROSSBONES}"; say $x'
☠
```

Or:

```
% perl -E 'binmode(STDOUT, ":encoding(UTF-8)"); my $x = "\N{SKULL AND CROSSBONES}"; say $x'
☠
```

Or:

```
% perl -CS -E 'my $x = "\N{SKULL AND CROSSBONES}"; say $x'
☠
```

References:

[How to get rid of `Wide character in print at`?](https://stackoverflow.com/questions/47940662/how-to-get-rid-of-wide-character-in-print-at)
> The `use utf8` means Perl expects your source code to be UTF-8.
> 
> The `open` pragma can change the encoding of the standard filehandles:
>
> `use open qw( :std :encoding(UTF-8) );`
> 
> And, whatever is going to deal with your output needs to expect UTF-8 too.
> If you want to see it correctly in your terminal, then you need to set up that correctly (but that's nothing to do with Perl).

[Use of 'use utf8;' gives me 'Wide character in print'](https://stackoverflow.com/questions/15210532/use-of-use-utf8-gives-me-wide-character-in-print)
> You can use this
> 
> `perl -CS filename`
> 
> It will also terminates that error.
> 
> Reference (abridged):
> 
> ```
> The -C flag controls some of the Perl Unicode features.
> 
> As of 5.8.1, the -C can be followed either by a number or a list of option letters.
> The letters, their numeric values, and effects are as follows; listing the letters is equal to summing the numbers.
> 
>     I     1   STDIN is assumed to be in UTF-8
>     O     2   STDOUT will be in UTF-8
>     E     4   STDERR will be in UTF-8
>     S     7   I + O + E
> ```
>
> [ . . . ]
> 
> If you're not just running a one-liner, see here: 
> 
> [perlunicook - Cookbookish examples of handling Unicode in Perl - ℞ 15: Declare STD{IN,OUT,ERR} to be utf8](https://perldoc.perl.org/perlunicook#%E2%84%9E-15:-Declare-STD%7BIN,OUT,ERR%7D-to-be-utf8)

----

### Python

Paste the character you want to analyze between single quotes of Python's built-in [ord()](https://docs.python.org/3/library/functions.html#ord) function.

```
% python3
>>> 
>>> import unicodedata

>>> ord('🤔')
129300

>>> chr(129300)
'🤔'

>>> unicodedata.name('🤔')
'THINKING FACE'

>>> "\N{Thinking Face}"
'🤔'

>>> u=chr(129300)

>>> u.encode('utf-8')
b'\xf0\x9f\xa4\x94'

>>> hex(129300)
'0x1f914'
```

```
% python3 -c 'print(0x1f914)'
129300
 
% python3 -c 'print(chr(129300))'
🤔
```

[Unicode HOWTO - Python Documentation](https://docs.python.org/3/howto/unicode.html)

----

### `vim` 

```
vim: ga  # OR :as(cii)
```

----

### libgrapheme

Project home page:
[https://libs.suckless.org/libgrapheme/](https://libs.suckless.org/libgrapheme/)

```
$ git clone https://git.suckless.org/libgrapheme
```

```
$ cd libgrapheme
```

```
$ ./configure
```

```
$ sudo make install
```

```
$ vi example.c
```

```
$ cat example.c
#include <grapheme.h>
#include <stdint.h>
#include <stdio.h>

int
main(void)
{
        /* UTF-8 encoded input */
        char *s = "T\xC3\xABst \xF0\x9F\x91\xA8\xE2\x80\x8D\xF0"
                  "\x9F\x91\xA9\xE2\x80\x8D\xF0\x9F\x91\xA6 \xF0"
                  "\x9F\x87\xBA\xF0\x9F\x87\xB8 \xE0\xA4\xA8\xE0"
                  "\xA5\x80 \xE0\xAE\xA8\xE0\xAE\xBF!";
        size_t ret, len, off;

        printf("Input: \"%s\"\n", s);

        /* print each grapheme cluster with byte-length */
        printf("grapheme clusters in NUL-delimited input:\n");
        for (off = 0; s[off] != '\0'; off += ret) {
                ret = grapheme_next_character_break_utf8(s + off, SIZE_MAX);
                printf("%2zu bytes | %.*s\n", ret, (int)ret, s + off);
        }
        printf("\n");

        /* do the same, but this time string is length-delimited */
        len = 17;
        printf("grapheme clusters in input delimited to %zu bytes:\n", len);
        for (off = 0; off < len; off += ret) {
                ret = grapheme_next_character_break_utf8(s + off, len - off);
                printf("%2zu bytes | %.*s\n", ret, (int)ret, s + off);
        }

        return 0;
}
```

```
$ cc -o example example.c -lgrapheme
```


```
$ ./example
Input: "Tëst 👨👩👦 🇺🇸 न\u0940 ந\u0bbf!"
grapheme clusters in NUL-delimited input:
 1 bytes | T
 2 bytes | ë
 1 bytes | s
 1 bytes | t
 1 bytes |
18 bytes | 👨👩👦
 1 bytes |
 8 bytes | 🇺🇸
 1 bytes |
 6 bytes | न\u0940
 1 bytes |
 6 bytes | ந\u0bbf
 1 bytes | !

grapheme clusters in input delimited to 17 bytes:
 1 bytes | T
 2 bytes | ë
 1 bytes | s
 1 bytes | t
 1 bytes |
11 bytes | 👨👩
```

----

## References
(Retrieved on Sep 17, 2024)

* [What is the difference between UTF-8 and Unicode?](https://web.archive.org/web/20150815071315/https://rrn.dk/the-difference-between-utf-8-and-unicode)
> **UTF-8 is an encoding - Unicode is a character set**.

* [UTF-8 Encoding -- The official specification: RFC 3629](https://www.ietf.org/rfc/rfc3629.txt)

* [Rob Pike's story about the invention of UTF-8](https://www.cl.cam.ac.uk/~mgk25/ucs/utf-8-history.txt)

* [What are useful Perl one-liners for working with UTF-8? - UTF-8 and Unicode FAQ](https://www.cl.cam.ac.uk/~mgk25/unicode.html#perl)

* [Markus Kuhn's Unicode FAQ, a very comprehensive resource about Unicode support on Free Unix-like systems](https://www.cl.cam.ac.uk/~mgk25/unicode.html)

* [UTF-8 decoder capability and stress test](https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt)

* [uni - Query the Unicode database from the commandline, with good support for emojis](https://github.com/arp242/uni)

* [WASM (WebAssembly) demo for uni](https://arp242.github.io/uni-wasm/)

* [A nice list of Unicode tools](https://github.com/arp242/uni?tab=readme-ov-file#alternatives)

* [Web Browser Compatibility Test](https://reinhart1010.id/browser-test)
> This site is designed with modern web feature detection standards, that is, by not complaining you for not using Google Chrome. However, as a friendly reminder, we usually give warnings to users who use:
> 
>  . . . 
> 
>  [ long list ] 
> 
>  . . . 

* [Text Makeup - A little tool to decode and explore Unicode strings](https://text.makeup/)
> [Text makeup - About](https://text.makeup/about/)
>
> text.makeup is made by me, Marcin Wichary. [Contact me](https://aresluna.org/), or [file a bug / suggest an idea](https://github.com/mwichary/text-makeup/issues/new).
> 
> Manifesto
> 
> I kind of love Unicode. There are so many stories hidden within all the codepoints, and so much strange complexity.
> 
> I want this tool to be somewhere at the intersection of "useful" and "fun." You might want to just paste a string that's giving you trouble, but not just that. Hopefully, you will also want to click around, learn, explore. I want information, but I also want stories.
> 
> This is meant to be a site for *nerds*, but specifically not Unicode nerds. (Many sites for Unicode nerds, filled with technical info and jargon already exist!)
> 
> Proof of concept
> 
> This site is a proof of concept. Only some aspects and some specific examples work ([more information about coverage](https://text.makeup/about)). 
> 
> [ . . . ]
> 
> Privacy
> 
> All the string processing happens on the client. (Very slowly right now.)
> 
> Nods and acknowledgements
> 
> Thank you to Manuel Strehl for creating the site [Codepoints](https://codepoints.net/)!

* [Unicode.org - Emoji Test for Latest Unicode Version](https://unicode.org/Public/emoji/latest/)
> For documentation and usage, see https://www.unicode.org/reports/tr51

* [Unicode Emoji - Unicode® Technical Standard #51](https://www.unicode.org/reports/tr51/)
> **Summary**
> 
> This document defines the structure of Unicode emoji characters and sequences, and provides data to support that structure, such as which characters are considered to be emoji, which emoji should be displayed by default with a text style versus an emoji style, and which can be displayed with a variety of skin tones. It also provides design guidelines for improving the interoperability of emoji characters across platforms and implementations.
> 
> Starting with Version 11.0 of this specification, the repertoire of emoji characters is synchronized with the Unicode Standard, and has the same version numbering system.

* [Unicode.org - Emoji ZWJ Sequences Test for Latest Unicode Version](https://unicode.org/Public/emoji/latest/emoji-zwj-sequences.txt)

* [Unicode.org - Emoji Sequences Test for Latest Unicode Version](https://unicode.org/Public/emoji/latest/emoji-sequences.txt)

* [Unicode.org - Emoji Test for Unicode 16.0](https://unicode.org/Public/emoji/16.0/emoji-test.txt)

* [Unicode.org - Emoji Test for Unicode 15.1](https://unicode.org/Public/emoji/15.1/emoji-test.txt)

* [Fontconfig and emoji - Emoji and symbols - Arch Linux Wiki (ArchWiki)](https://wiki.archlinux.org/title/Fonts#Fontconfig_and_emoji)

* [Features of your font you had no idea about](https://sinja.io/blog/get-maximum-out-of-your-font)

* [Features of your font you had no idea about - Discussion on Hacker News: What you can get out of a high-quality font (sinja.io)](https://news.ycombinator.com/item?id=41502721)

* [Quick guide to web typography for developers (Typography is my passion)](https://sinja.io/blog/web-typography-quick-guide)

* [How to be absolutely, positively, double definitely sure your web font renders](https://pixelambacht.nl/2013/font-face-render-check/)

* [The Ultimate Unicode Explorer & Tools - fontspace.com](https://www.fontspace.com/unicode)
> Browse through Unicode with a twist: We'll show you all the fonts that are available for each character. 

* [Unicode Text Analyzer - fontspace.com](https://www.fontspace.com/unicode/analyzer)
> This tool allows you to inspect any text and see the real Unicode characters. You may find that there are invisible codepoints, or mis-represented characters (also known as confusables or homoglyphs).
> 
> It's really interesting with complex Emojis that appear as a single character, but are really made up of a combination of codepoints. Try it with some samples to see all the parts decomposed.

* [An extensive list of Unicode/UTF-8 resources and tools -- *GNU Coreutils - Multibyte/unicode support*](https://crashcourse.housegordon.org/coreutils-multibyte-support.html)
> Random notes and pointers regarding the on-going effort to add multibyte and unicode support in [GNU Coreutils](https://www.gnu.org/software/coreutils/).
> 
> If you're considering working on multibyte/unicode/utf8 support in GNU coreutils (or other packages) - reading these should bring you up to speed (and hopefully save some time, too).
> 
> NOTE: *multibyte*, *multibyte-sequences*, *unicode*, *utf-8* are sometimes used interchangeably throughout the document, but the intent is to support all multibyte locales, not just UTF8 encodings.

* [Converting a file from an 8-bit character set (for example ISO_8859-1) to UTF-8 without POSTing the file to a remote server](http://www.academiccomputerclub.se/~saasha/charconv/)
> In many cases, the most obvious way to solve such a problem is to save the file, open a terminal, move to the directory where the file resides (with cd …) and use iconv similarly to:
> 
> `iconv -f iso88591 -t utf8 fileToConvert.txt > convertedFile.txt`
> 
> Unfortunately, finding out how to start a terminal is not always easy in today's GUI's!
> 
> Here, you are given the opportunity to achieve such a conversion locally. Choose a character set (charset, encoding) in the list below and choose the file you wish to convert. The JavaScript program linked to by this page will try to make your browser convert the file to UTF-8. If the conversion succeeds, you will be given the opportunity to save the converted file.
> 
> You do not need any Internet connection to achieve this conversion. You can save this page locally together with (in the same directory than) the JavaScript program it is linked to and open it in a browser to achieve the conversions even without any Internet connection.
> 
> Previously: [http://www.acc.umu.se/~saasha/charconv/](http://www.acc.umu.se/~saasha/charconv/)

* [Hexadecimal to UTF-8 (in C)](https://cplusplus.com/forum/general/70592/)
> Are you trying to print U+00C5, Å? The proper way to do this is to use wide character I/O.
> 
> In C:
> 
> ```
> #include <wchar.h>
> #include <locale.h>
> int main()
> {
>     setlocale(LC_ALL, "");
>     wchar_t c = L'\u00c5'; // or = L'\xc5';
>     wprintf(L"%lc\n", c);
}
> ```

* [Xterm copy and paste](https://www.win.tue.nl/~aeb/linux/misc/xterm.html)
> ```
> % cat xtest
> #include <stdio.h>
> 
> char s[6] = { 0x61, 0xcc, 0x85, 0xcc, 0x8a, 0 };
> 
> int main() {
>     return puts(s);
> }
> ```

* [Unicode Normalization](https://www.win.tue.nl/~aeb/linux/uc/nfc_vs_nfd.html)
> Unicode Normalization
> 
> Equivalence of sequences of Unicode values
> 
> Often a character can be represented in Unicode by several code sequences. For example, the GREEK SMALL LETTER ALPHA WITH DASIA AND OXIA AND YPOGEGRAMMENI can be written as U+1F85 (ᾅ), or U+1F05 U+0345 (ᾅ), or U+1F81 U+0301 (ᾅ), ..., or U+03B1 U+0314 U+0301 U+0345 (ᾅ), where the start of the sequence gives the main symbol, and the following unicode values indicate combining diacritics. All such sequences representing the same character are called canonically equivalent.
> 
> To be more precise, the combining classes for the combining diacritics U+0314, U+0301, U+0345 in this example are 230, 230, 240, respectively. These classes tend to indicate the position of the diacritic (above, below, ...) and it is assumed that diacritics in different positions can be ordered arbitrarily, while the order of diacritics in the same position is significant. Thus, U+03B1 U+0314 U+0301 U+0345 and U+03B1 U+0314 U+0345 U+0301 and U+03B1 U+0345 U+0314 U+0301 are equivalent, but U+03B1 U+0314 U+0301 U+0345 and U+03B1 U+0301 U+0314 U+0345 are not. The latter is equivalent to U+1FB4 U+0314 (ᾴ̔). 

* [YayText - A text styling tool for Facebook, Twitter, etc.](https://yaytext.com/)
> Super cool Unicode text magic. Use s̶t̶r̶i̶k̶e̶t̶h̶r̶o̶u̶g̶h̶, 𝐛𝐨𝐥𝐝, 𝒊𝒕𝒂𝒍𝒊𝒄𝒔, and 🅜🅞🅡🅔 🄲🅁🄰🅉🅈 ʷlͤoͥoͬkͩing fonts on Facebook, Twitter, and everywhere else.

* [font-variant-numeric Demo - CSS: Cascading Style Sheets - MDN (Mozilla Developer Network)](https://developer.mozilla.org/en-US/docs/Web/CSS/font-variant-numeric)
> 
> The font-variant-numeric CSS property controls the usage of alternate glyphs for numbers, fractions, and ordinal markers.

* [Modern Font Stacks](https://modernfontstacks.com/)
> System font stack CSS organized by typeface classification for every modern operating system. The fastest fonts available. No downloading, no layout shifts, no flashes - just instant renders.

* [Modern Font Stacks - on GitHub](https://github.com/system-fonts/modern-font-stacks)

* [The struggle of using native emoji on the web](https://nolanlawson.com/2022/04/08/the-struggle-of-using-native-emoji-on-the-web/)

* [emoji-picker-element -- A lightweight emoji picker for the modern web](https://github.com/nolanlawson/emoji-picker-element/)

* [emoji-picker-element -- Demo](https://nolanlawson.github.io/emoji-picker-element/)

* [Codepoints - Find all Unicode characters from Hieroglyphs to Dingbats - by Manuel Strehl](https://codepoints.net/) 

* [Codepoints.net - About](https://codepoints.net/about) 
> Finding Characters
> 
> It's hard to find one certain character in over 149944 codepoints. This site aims to make it as easy as possible with the following search options:
> * Free search: Just press the "Search" tab above or use the form on the front page and type a query. In many cases the codepoint in question is in the result.
> * [Extended search](https://codepoints.net/search): You can configure on this page every Unicode property of the codepoint in question.
> * The [Find My Codepoint](https://codepoints.net/search#wizard) wizard: Answer a series of questions to get to your character.
> 
> If you happen to already have the character in question just paste it in the search box. It will bring you directly to its description page.

* [Character Identifier by L. David Baron -- Add-On (Extension) for Mozilla Firefox Web Browser](https://addons.mozilla.org/en-US/firefox/addon/character-identifier/)
> This extension adds a context menu item for selected text that provides more information (from the Unicode database) about the characters selected.
> 
> Project Homepage:
> [Homepage](https://dbaron.org/mozilla/char-identifier/)

* [Character Identifier on GitHub](https://github.com/dbaron/char-identifier)
> Character Identifier is a Web Extension that adds a browser context menu item for selected text that provides more information (from the Unicode database) about the characters selected. 

* [Unicodey - Unicode decoder (into code points)](https://unicodey.com/)
> Unicode.com is a bunch of tools for understanding and debugging Unicode strings, specifically the UTF-8 encoding]

* [Unicode table](https://stosberg.net/unicode/)

* [Unicode symbol - List of character and symbol blocks](http://www.unicode-symbol.com/)
> This site is dedicated to Unicode® symbols, characters and code points.
>
> The Unicode® standard 15.0 splits the character code points among more than 250 distinct blocks. The following table lists all these blocks in alphabetical order. You can click on one of these blocks to discover the corresponding characters.

* [ScriptSource](https://scriptsource.org/)
> Writing systems, computers and people
> 
> ScriptSource is a dynamic, collaborative reference to the writing systems of the world, with detailed information on scripts, characters, languages - and the remaining needs for supporting them in the computing realm. It is sponsored, developed and maintained by SIL International. It currently contains only a skeleton of information, and so depends on your participation in order to grow and assist others.

* [The UniSearcher - Brett Baugh](https://www.isthisthingon.org/unicode/)

* [The UniSearcher - Brief Description](https://www.isthisthingon.org/unicode/ex.html) 
> The Shift-JIS codes are all different from the Unicode numbers.
> "shi" is 0x30B7 in Unicode, but 0x8356 in Shift-JIS. (The "0x" before something just means "this is a hexadecimal number.")
> Fortunately, the Unicode Consortium provides standardized, parseable text files which tell how to convert a Shift-JIS code into Unicode, list the actual name of most every Unicode character, even definitions and pronunciations for them.
> It is from there that my little searcher thingy gets its information.
> The problem I was running up against was that any time I wanted to put something Japanese into a web page, I had to perform many steps for each character.
> The program I use to look up Kanji in ("JquickTrans") lets you copy a character from it to the clipboard, but it'll only do it as Shift-JIS.
> I don't want to put Shift-JIS into web pages, as I explained earlier.
> So I had to (in Windows) copy it to the clipboard, save it into a text file, and then (in Unix) do a hexdump on the file to get the Shift-JIS hexadecimal codes for that character (and since it's displayed in "little endian" order, I also have to then reverse the order the two bytes are in), then look in the Unicode-provided mapping file to find the Unicode codepoint for that Shift-JIS code, then convert that into base-10 decimal, and then put "&#" in front of it and ";" after it, and only then could I put it in a web page.
>Douglas Adams once said something about how he derived great pleasure from spending all day creating a computer program that would automate a task that takes him ten seconds to do by hand.
> I suppose I'm no different... and thus, the searcher was born. 
> 
> The application I created to do all this dirty work for me consists of three pieces: the actual search page, the mapping/descriptions data stored in MySQL, and a parser that creates this data set from the five Unicode-provided mapping files.
. This way, if Unicode updates one of their data files, all you have to do is delete your copy of it, run the parser, and you're up-to-date.
> The parser takes less than two minutes to run on my machine (yours too, probably).
> 
> The code charting page shows all 256 characters in the current block, whether they exist or not. Each block is color-coded so you can tell them apart.
> Ones that appear grey are undefined blocks.
> If you hover your mouse over any character, a little popup tooltip kinda thing will appear that lists everything there is to know about that character.
> Makes the pages huge (over 100K each), but oh well... it's too handy to not keep it even though it's kinda slow this way. 
> 
> . . . 
>
> "Wow," you say, "this is great!
> Where do I get one?"
> Well, simply [download this distribution of it](https://www.isthisthingon.org/unicode/unisearch-1.1.tgz), unpack it somewhere, and read the INSTALL file.
> It shouldn't take more than five minutes to install if you already have a working apache/php/mysql server set up.
* [The UniSearcher - Source Code Distribution](https://www.isthisthingon.org/unicode/unisearch-1.1.tgz)

* [Unicode Library on compart.com](https://compart.com/en/unicode/)

* [qprint - Tool to Encode and Decode Quoted-Printable Files](https://www.fourmilab.ch/webtools/qprint/)
> The MIME (Multipurpose Internet Mail Extensions) specification ([RFC 1521](https://www.fourmilab.ch/webtools/qprint/rfc1521.html) and successors) defines a mechanism for encoding text consisting primarily of printable ASCII characters, but which may contain characters (for example, accented letters in the ISO 8859 Latin-1 character set) which cannot be encoded as 7-bit ASCII or are non-printable characters which may confuse mail transfer agents.
> 
> **qprint** is a command line utility which encodes and decodes files in this format.
> It can be used within a pipeline as an encoding or decoding filter, and is most commonly used in this manner as part of an automated mail processing system.
> With appropriate options, qprint can encode pure binary files, but it's a poor choice since it may inflate the size of the file by as much as a factor of three.
> The base64 MIME encoding is a better choice for such data. 

* [Unicode Search - Xah](http://xahlee.info/comp/unicode_index.html)
> * To search by name, type a word. Try heart
> * Type two or more words to narrow down result. Try heart face
> * A word starting with minus sign remove those result. Try heart -card
> * To show a range of unicode, type the character ID, e.g. 9829 or U+1f60d
> * To find a char's name or ID, paste in the character or emoji, e.g. 😂 ☕.

* [jsescape - Text Escaping and Unescaping in JavaScript - By Satoru Takabayashi (http://0xcc.net/)](http://0xcc.net/jsescape/)
> Text Escaping and Unescaping in JavaScript
> 
> A collection of utilities for text escaping and unescaping in JavaScript. Try typing "abc" in the first form to see how it works. Any form can be edited. 
> 
> *Notes*
>
> * No data is sent to the server (i.e. everything is done in JavaScript).
> * Conversion from Unicode to other encodings such as Shift_JIS can be slow first time as it needs to initialize internal conversion tables.
> * Surrogate pairs in UTF-16 are supported. Try inserting \uD840\uDC0B in the second form.
> * Three-byte characters in EUC-JP are not supported.

* [go-ucd -- Go libraries and utilities for working with Unicode character data](https://github.com/cooperhewitt/go-ucd) 

* [Xah Unicode Blog - aka Unicode Fun](http://xahlee.info/comp/unicode_fun.html)

* [amp-what -- aka &what;](https://www.amp-what.com/)
> AmpWhat is the place to explore the characters and icons underlying your browser, computer and phone.
>
> These are known as Unicode. 
> 
> About AmpWhat
> 
> AmpWhat is a quick, interactive reference of thousands of HTML character entities and common Unicode characters, 8859-1 characters, quotation marks, punctuation marks, accented characters, symbols, mathematical symbols, and Greek letters, icons, and markup-significant & internationalization characters.
> 
> Sources & Acknowledgements
> 
> AmpWhat was originally birthed using some of Remy Sharp's excellent work. I imported documents such as hacker jargon, and added hundreds of my own annotations. (When users searched and got no results, I fixed it!) Now, much of this data is part of the Unicode reference, but AmpWhat still uses a combination of source data.
> 
> Main sources:
> * [Unicode.org, "Latest Unicode.org international character reference"](http://www.unicode.org/Public/UCD/latest/ucdxml/)
> * [Unicode.org, "CLDR Data"](http://www.unicode.org/Public/cldr/)
> * [Unicode.org, "Emoji Data" and "Emoji Sequences](https://unicode.org/Public/emoji/)
> * [W3, "HTML entities"](https://html.spec.whatwg.org/)
> * [W3, "Using character escapes in markup and CSS"](http://www.w3.org/International/questions/qa-escapes/)
> * [whatwg.org](https://html.spec.whatwg.org/)
> * [app-charuse](https://github.com/r12a/app-charuse)

* [Unicode Escape Formats](https://www.billposer.org/Software/ListOfRepresentations.html)

* [Grapheme Clusters and Terminal Emulators](https://mitchellh.com/writing/grapheme-clusters-in-terminals)
> Copy and paste "🧑‍🌾" in your terminal emulator.
> How many cells forward did your cursor move? Depending on your terminal emulator, it may have moved 2, 4, 5, or 6 cells.
> Yikes.

NOTE: Three pictures below show that pasting the farmer emoji in *xterm* terminal emulator with *csh* (C shell), *bash* (GNU Bourne-again shell) and *sh* (Bourne shell) shells on my FreeBSD 14 system moved cursor four cells forward.

![Unicode character name Farmer (emoji) - In FreeBSD, pasting it in xterm with csh shell moved cursor four cells forward](/assets/img/xterm-csh-unicode-farmer-emoji.png "Unicode character name Farmer (emoji) - In FreeBSD, pasting it in xterm with csh shell moved cursor four cells forward")

![Unicode character name Farmer (emoji) - In FreeBSD, pasting it in xterm with bash shell moved cursor four cells forward](/assets/img/xterm-bash-unicode-farmer-emoji.png "Unicode character name Farmer (emoji) - In FreeBSD, pasting it in xterm with bash shell moved cursor four cells forward")

![Unicode character name Farmer (emoji) - In FreeBSD, pasting it in xterm with sh (Bourne shell) moved cursor four cells forward](/assets/img/xterm-sh-unicode-farmer-emoji.png "Unicode character name Farmer (emoji) - In FreeBSD, pasting it in xterm with sh (Bourne shell) moved cursor four cells forward")

> This blog post describes why this happens and how terminal emulator and program authors can achieve consistent spacing for all characters.
> 
> . . . 
> 
> Traditionally, terminals simply read an input byte stream and mapped each individual byte to a cell in the grid.
> For example, the stream "1234" is 4 bytes, and programmers can very easily read a byte at a time and place it into the next cell, move the cursor right one, repeat.
> 
> Eventually, "wide characters" came along.
> Common wide characters are Asian characters such as 橋 or Emoji such as 😃.
> A function [`wcwidth`](https://www.man7.org/linux/man-pages/man3/wcwidth.3.html) was added to libc to return the width of a wide character in *cells*.
> Wide characters were given a width of "2" (usually).
> Therefore, if you type 橋 in a terminal emulator, the character will take up two grid cells and your cursor should jump forward by two cells.
> 
> And this is how most terminal emulators and terminal programs (shells, TUIs, etc.) are implemented today: they process input characters via `wcwidth` and move the cursor accordingly.
> And for a short period of time, this worked completely fine.
> But today, this is no longer adequate and results in many errors.
> 
> **Grapheme Clustering**
> 
> It turns out that a single 32-bit value is not adequate to represent every user-perceived character in the world. A "**user-perceived character**" is how the Unicode Standard defines a **grapheme**.
> 
> Let's consider the emoji "🧑‍🌾". The emoji should look [something like this](https://static.mitchellh.com/ghostty/mode-2027/farmer.png) in case your computer doesn't support it. I think every human would agree this is a single "user-perceived character" or grapheme. The Unicode Standard itself defines this as a single grapheme so regardless of your personal opinion, international standards say this is one grapheme.
> 
> For computers, its not so obvious. "🧑‍🌾" is **three** codepoints (U+1F9D1 🧑, U+200D, and U+1F33E 🌾), **three** 32-bit values when UTF-32 encoded, or 11 bytes when UTF-8 encoded (assuming 8-bits is a byte, which is a fairly safe assumption nowadays).
>
> . . .
> 
> What's with the zero-width character? The codepoint `U+200D` is known as a [Zero-Width Joiner (ZWJ)](https://en.wikipedia.org/wiki/Zero-width_joiner) and has a standards-defined width of zero. The ZWJ tells text processing systems to treat the codepoints around it as *joined* into a single character. That's why you can type both "🧑‍🌾" and "🧑🌾"; the only difference between these two quoted values is the farmer on the left has a zero-width joiner between the two emoji.
>
> . . . 
> 
> Grapheme clustering is the process that lets a program see **three** 32-bit values as a **single** user-perceived *character*. The algorithm for grapheme clustering is defined in [UAX #29, "Unicode Text Segmentation"](https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries).
>
> 

* [Libgrapheme: A simple freestanding C99 library for Unicode (suckless.org)](https://libs.suckless.org/libgrapheme/)
> Libgrapheme is an extremely simple freestanding C99 library providing utilities for properly handling strings according to the latest Unicode standard 15.0.0.
> It offers fully Unicode compliant:
> * *grapheme cluster* (i.e. user-perceived character) *segmentation*
> * *word segmentation*
> * *sentence segmentation*
> * detection of permissible *line break opportunities*
> * *case detection* (lower-, upper- and title-case)
> * *case conversion* (to lower-, upper- and title-case)
>
> on UTF-8 strings and codepoint arrays, which both can also be null-terminated.

* [Recommended Emoji ZWJ Sequences, Unicode v15.1](https://unicode.org/emoji/charts/emoji-zwj-sequences.html)
> The following are the recommended emoji zwj sequences, which use a `U+200D` ZERO WIDTH JOINER (ZWJ) to join the characters into a single glyph if available. When not available, the ZWJ characters are ignored and a fallback sequence of separate emoji is displayed. Thus an emoji zwj sequence should only be supported where the fallback sequence would also make sense to a viewer.

* [Emoji ZWJ Sequences: Three Letters, Many Possibilities](https://blog.emojipedia.org/emoji-zwj-sequences-three-letters-many-possibilities/)

* [Libgrapheme (suckless.org) - on Hacker News](https://news.ycombinator.com/item?id=33612039)

* [HarfBuzz (a font shaper)](https://harfbuzz.github.io/)
> Harfbuzz sees a stream of codepoints, detects the graphemes, and is able to then map those graphemes to individual glyphs in a font.

* [wcwidth.awk - An implementation of wcwidth / wcswidth in pure AWK](https://github.com/ericpruitt/wcwidth.awk)

* [Emoji: Setting the Tables](https://medium.com/making-faces-and-other-emoji/emoji-setting-the-tables-1107195e1386)

* [Emoji: Fonts, Technically](https://medium.com/making-faces-and-other-emoji/emoji-fonts-technically-40f3fdc0869e)

* [Twemoji - A simple library that provides standard Unicode emoji support across all platforms - Emoji for everyone](https://github.com/twitter/twemoji)

* [OpenMoji -  Open source emojis for designers, developers and everyone else](https://openmoji.org/)

* [Terminal Emulators Battle Royale - Unicode Edition!](https://www.jeffquast.com/post/ucs-detect-test-results/)

* [It's Not Wrong that "🤦🏼‍♂️".length == 7 -- String Lengths in Unicode](https://hsivonen.fi/string-length/)

* [String Lengths in Unicode - Discussion on Hacker News](https://news.ycombinator.com/item?id=20914184)

* [Emojipedia - All things emoji](https://emojipedia.org/)

* [Awesome Code Points](https://github.com/Codepoints/awesome-codepoints)
> This is a curated list of characters in Unicode, that have interesting (and maybe not widely known) features or are awesome in some other way.
> 
> . . . 
> 
> **Breaking and Gluing other characters**
> 
> * [U+00A0](https://codepoints.net/U+00A0) NO-BREAK SPACE - force adjacent characters to stick together. Well known as `&nbsp;` in HTML.
> * [U+00AD](https://codepoints.net/U+00AD) SOFT HYPHEN - (in HTML: `&shy;`) like ZERO WIDTH SPACE, but show a hyphen if (and only if) a break occurs. 
> * [U+200B](https://codepoints.net/U+200B) ZERO WIDTH SPACE - the inverse to U+00A0: create no space, but allow word breaking.
> * [U+200D](https://codepoints.net/U+200D) ZERO WIDTH JOINER - force adjacent characters to be joined together (e.g., arabic characters or supported emoji). Apple uses this to compose some emoji like different families.
> * [U+2060](https://codepoints.net/U+2060) WORD JOINER - the same as U+00A0, but completely invisible. Good for writing `@font-face` on Twitter.

* [Unicode - Character Code Tutorial - ISO 10646, UCS, and Unicode - ISO 10646, the standard](https://www.jkorpela.fi/chars.html#10646)
> **Unicode, the more practical definition of UCS**
> 
> Unicode is a [standard](http://www.unicode.org/unicode/standard/standard.html), by the [Unicode Consortium](https://home.unicode.org/), which defines a character repertoire and character code intended to be fully compatible with ISO 10646, and an encoding for it. ISO 10646 is more general (abstract) in nature, whereas Unicode "imposes additional constraints on implementations to ensure that they treat characters uniformly across platforms and applications", as they say in section [Unicode & ISO 10646](http://www.unicode.org/unicode/faq/unicode_iso.html) of the [Unicode FAQ](http://www.unicode.org/unicode/faq/).
> 
> Unicode was *originally* designed to be a *16-bit* code, but it was **extended** so that currently *code positions* are expressed as *integers* in the hexadecimal **range** **0..10FFFF** (*decimal* **0..1 114 111**).
> That space is *divided* into *16-bit* **"planes"**.
> Until recently, the use of Unicode has mostly been limited to *"Basic Multilingual Plane (BMP)"* consisting of the range *0..FFFF*.
> 
> The ISO 10646 and Unicode *character repertoire* can be regarded as a superset of most character repertoires in use.
> However, the *code positions* of characters vary from one character code to another.
> "Unicode" is the commonly used name
> 
> In practice, people usually talk about Unicode rather than ISO 10646, partly because we prefer names to numbers, partly because Unicode is more explicit about the *meanings* of characters, partly because detailed information about Unicode is available on the Web.

* [UTF-8 Conversion Tool by Richard Tobin (UTF-8 Tool)](https://www.cogsci.ed.ac.uk/~richard/utf-8.html)

* [UTF-8 Sampler](https://kermitproject.org/utf8.html)

* [uni.pl - Perl script from leahneukirchen (Leah Neukirchen) - List Unicode symbols matching pattern](https://leahneukirchen.org/dotfiles/bin/uni)

* [decodeunicode.org](https://decodeunicode.org/)
> Unicode 11.0.0 encodes exactly 137,374 typographical characters.
> 
> Here you can see them all - Even if you don't have the matching font on your computer.

* [Unicode Decode - Decode a Unicode String](https://unicodedecode.com/)
> **Normalization Form**
> 
> NFC? NFD? Know if your string is normalized and to which normalization forms: NFC, NFD NFKC and NFKD. 

* [How do you echo a 4-digit Unicode character in Bash?](https://stackoverflow.com/questions/602912/how-do-you-echo-a-4-digit-unicode-character-in-bash)

* [Tofu](https://unicodedecode.com/tofu)
> Not Just For Eating
> 
> Are you seeing tofu, that is, □ instead of 𐓇 or ൠ? Perhaps you just see "□ or □". They're different, we promise! Regardless of how your characters are being rendered, [Unicode Decode](https://unicodedecode.com/) helps you to uncover the underlying codepoints. Seeing tofu isn't making your life easier so consider checking out [Google's Noto Fonts](https://www.google.com/get/noto/), a comprehensive open source font collection before [Google kills it](https://killedbygoogle.com/).

* [gucharmap the GNOME Character Map, based on the Unicode Character Database](https://wiki.gnome.org/Apps/Gucharmap)

* [How do you echo a 4-digit Unicode character in Bash?](https://stackoverflow.com/questions/602912/how-do-you-echo-a-4-digit-unicode-character-in-bash)

* [Unicode Lookup - Convert special characters](https://unicodelookup.com/)
> Unicode Lookup is an online reference tool to lookup Unicode and HTML special characters, by name and number, and convert between their decimal, hexadecimal, and octal bases.

* [Unicode Character Code Charts - Find chart by hex code](https://unicode.org/charts/)

* [Unicode Chart](https://ian-albert.com/unicode_chart/)
> My fascination with writing sys­tems gave me the idea to create a poster containing every Unicode character.
> Unicode is a method for encoding characters, like ASCII, but it can represent virtually every writing system in the world, not just English.
> I estimated I could print the whole thing on about a 36"x36" poster.
> Well, my estimates were off.
> It turned out to be about 6 feet by 12 feet.
> Likewise, the process of creating the poster turned out to be much more involved than I imagined.

* [UniChar - Find and utilize Unicode symbols from any browser](https://unichar.app/web/)

* [UniView - By Richard Ishida](https://r12a.github.io/uniview/)

* [UniView Help & User Guide - By Richard Ishida](https://r12a.github.io/uniview/help.html)

* [UTF-8: Bits, Bytes, and Benefits](https://research.swtch.com/utf8)

* [Apps by Richard Ishida](https://r12a.github.io/applist)
> These apps are written in HTML and JavaScript, and use Web Standards to work on all major browsers, so you don't need to install anything.

* [Unicode browser (Unicode table for you)](https://www.ftrain.com/unicode)
> 
> The code for this toy is contained in this page, and is available under both the GPL and MIT licenses.
> View source and help yourself.
> 
> From [Panel/Unicode table for you](https://www.ftrain.com/unicode-table):
> 
> Here is a simple Unicode browser for people who like looking at characters; you can click on the number below each character to visit its Wikipedia page. 
>
> Source code:
> It's all on one page (HTML/CSS/JavaScript) and under the GPL/MIT license, so if you have any big ideas go to town.

* [Unicode Toys - Unicode Toys](https://qaz.wtf/u/)
> *Unicode Text Converter*
> Transliterate plain text (letters, sometimes numbers, sometimes punctuation) to obscure characters from Unicode.\
> The output is fully cut-n-pastable text.
> This is the toy most visitors here want.
> Ŧħɨs 𝔦𝔰 ᴛʜᴇ тоЎ ᵐᵒˢᵗ √ﾉ丂ﾉｲo尺丂 ђєгє ẅäṅẗ⨀
>
> *Unicode Text Transformations*
> Other, more specialized, ways to transform text.
> 
> *Unicode Text Grep*
> Grep unicode descriptive names and display matching characters.
> All descriptions are punctuation-free ASCII (low bit).
> All searches are case insensitive.
> 
> *Show Unicode Character*
> Enter a code or character and see the Unicode name.
> Use START-STOP to show a range.

* [Pragmatic Unicode - Ned Batchelder - Presentation at PyCon 2012](http://nedbatchelder.com/text/unipain.html)

* [The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!)](https://eev.ee/blog/2015/09/12/dark-corners-of-unicode/)

* [The Absolute Minimum Every Software Developer Must Know About Unicode in 2023 (Still No Excuses!)](https://tonsky.me/blog/unicode/)
> Twenty years ago, [Joel Spolsky wrote](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/):
>
> There Ain't No Such Thing As Plain Text.
>
> It does not make sense to have a string without knowing what encoding it uses. You can no longer stick your head in the sand and pretend that "plain" text is ASCII.
> 
> A lot has changed in 20 years. In 2003, the main question was: what encoding is this?
> 
> In 2023, it's no longer a question: with a 98% probability, it's UTF-8. Finally! We can stick our heads in the sand again!
> 
> [ . . . ]
>
> What's UTF-8 then?
> 
> UTF-8 is an **encoding**. Encoding is how we store code points in memory.
> 
> The simplest possible encoding for Unicode is **UTF-32**. It simply stores code points as 32-bit integers. So `U+1F4A9` becomes `00 01 F4 A9`, taking up four bytes. Any other code point in UTF-32 will also occupy four bytes. Since the highest defined code point is `U+10FFFF`, any code point is guaranteed to fit.
> 
> UTF-16 and UTF-8 are less straightforward, but the ultimate goal is the same: to take a code point and encode it as bytes.
> 
> Encoding is what you'll actually deal with as a programmer.
>
> How many bytes are in UTF-8?
> 
> UTF-8 is a **variable-length** encoding. A code point might be encoded as a sequence of *one* **to** *four* bytes.
>
> This is how it works:
> 
> ```
> +-----------------+----------+----------+----------+----------+
> | Code point      | Byte 1   | Byte 2   | Byte 3   | Byte 4   |
> +-----------------+----------+----------+----------+----------+
> | U+0000..007F    | 0xxxxxxx |          |          |          |
> | U+0080..07FF    | 110xxxxx | 10xxxxxx |          |          |
> | U+0800..FFFF    | 1110xxxx | 10xxxxxx | 10xxxxxx |          |
> | U+10000..10FFFF | 11110xxx | 10xxxxxx | 10xxxxxx | 10xxxxxx |
> +-----------------+----------+----------+----------+----------+
> ```
> 
> If you combine this with the Unicode table, youll see that English is encoded with 1 byte, Cyrillic, Latin European languages, Hebrew and Arabic need 2, and Chinese, Japanese, Korean, other Asian languages, and Emoji need 3 or 4.
> 
> [ . . . ]
> 
> And a couple of important consequences:
> 
> * You CAN'T determine the length of the string by counting bytes.
> * You CAN'T randomly jump into the middle of the string and start reading.
> * You CAN'T get a substring by cutting at arbitrary byte offsets. You might cut off part of the character.
> 
> Those who do will eventually meet this bad boy: �
> 
> What’s �?
> 
> `U+FFFD`, the Replacement Character, is simply another code point in the Unicode table. Apps and libraries can use it when they detect Unicode errors.
>
> If you cut half of the code point off, there’s not much left to do with the other half, except displaying an error. That's when � is used.
>
> [ . . . ]
> 
> An **Extended Grapheme Cluster** is a sequence of one or more Unicode code points that must be treated as a single, unbreakable character.
> 
> [ . . . ] 
> 
> Is Unicode hard only because of emojis?
> 
> Not really. Extended Grapheme Clusters are also used for alive, actively used languages. For example:
> 
> * ö (German) is a single character, but multiple code points (U+006F U+0308).
> * ą́ (Lithuanian) is U+00E1 U+0328.
> * 각 (Korean) is U+1100 U+1161 U+11A8.
> 
> So no, it's not just about emojis.
> 
> [ . . . ]
> 
> What's sad for us is that the rules defining grapheme clusters change every year as well. What is considered a sequence of two or three separate code points today might become a grapheme cluster tomorrow! There's no way to know! Or prepare!
> 
> Even worse, different versions of your own app might be running on different Unicode standards and report different string lengths!
> 
> But that's the reality we live in. You don't really have a choice here. You can't ignore Unicode or Unicode updates if you want to stay relevant and provide a decent user experience. So, buckle up, embrace, and update.
>
> [ . . . ]
> 
> **Before comparing strings or searching for a substring, normalize!**
>
> [ . . . ]
> 
> **Unicode is locale-dependent**


* [ICU-TC -- International Components for Unicode - Technical Committee](https://icu.unicode.org/)

* [The home of the ICU project source code (https://icu.unicode.org/)](https://github.com/unicode-org/icu/tree/main)

* [Character encodings for beginners - W3C](https://www.w3.org/International/questions/qa-what-is-encoding)

* [Use of 'use utf8;' gives me 'Wide character in print'](https://stackoverflow.com/questions/15210532/use-of-use-utf8-gives-me-wide-character-in-print)

* [How to get rid of `Wide character in print at`?](https://stackoverflow.com/questions/47940662/how-to-get-rid-of-wide-character-in-print-at)

* [Perl Unicode Cookbook: The Standard Preamble](https://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html/)
> Apr 2, 2012 by Tom Christiansen
>
> Editor's note:
> Perl guru Tom Christiansen created and maintains a list of 44 recipes for working with Unicode in Perl 5.
> This is the first recipe in the series.

* [perlunicook - Cookbookish examples of handling Unicode in Perl](https://perldoc.perl.org/perlunicook)

* [The Python Unicode Mess](https://changelog.complete.org/archives/9938-the-python-unicode-mess)

* [The Python Unicode Mess - Discussion on Hacker News](https://news.ycombinator.com/item?id=18154667)

* [I Can't Write My Name in Unicode - Discussion on Hacker News](https://news.ycombinator.com/item?id=9219162)

* [Python 3 Unicode HOWTO](https://docs.python.org/3/howto/unicode.html)

* [unicodedata - Unicode Database - Python documentation](https://docs.python.org/3/library/unicodedata.html)

* [Unicode font utilities - Russell W. Cottrell - unicode_font_utilities.zip](https://www.russellcottrell.com/greek/utilities/unicode_font_utilities.zip)
> The zip file includes four utilities:
> * [The Unicode Range Viewer](https://www.russellcottrell.com/greek/utilities/UnicodeRanges.htm)
> The Unicode Range Viewer displays 16x16 blocks of Unicode characters with their hex and decimal values.
> Navigate through the code charts by using the arrows, going to the code value of a character, or selecting a block.
> Optionally, enter the name of a font, without modifiers (such as Liberation Serif, without Regular, Bold, Italic, etc.).
> Only the characters in that font will be displayed.
> Click a character to enter it into the textarea below, like a virtual keyboard.
>
> * [The Surrogate Pair Calculator etc.](https://www.russellcottrell.com/greek/utilities/SurrogatePairCalculator.htm)
> A surrogate pair is defined by the Unicode Standard as "a representation for a single abstract character that consists of a sequence of two 16-bit code units, where the first value of the pair is a high-surrogate code unit and the second value is a low-surrogate code unit."
> Since **Unicode** is a **21-bit** standard, surrogate pairs are needed by applications that use **UTF-16**, such as **JavaScript**, to display characters whose code points are *greater than 16-bit*.
> (UTF-8, the most popular HTML encoding, uses a more flexible method of representing high-bit characters and does not use surrogate pairs.)
>
> * *The Polytonic Greek Virtual Keyboard*
> Allows you to type Unicode Greek characters via the keyboard.
> Also converts text to either HTML or JavaScript code characters.
>
> * *The Greek Number Converter*
> Converts numbers to the alphabetic Greek format.

* [Some technical information about Unicode on the web - Russell W. Cottrell](https://www.russellcottrell.com/greek/technical.htm)

* [Unicode Visualizer](https://unicode.link/)
> Unicode Visualizer is a website with information from the Unicode Character Database.
> It also offers a tool that lets you inspect strings and view the breakdown of their codepoints and graphemes.
> 
> The inspect page lets you paste in any string and learn what it has in it. It can help diagnose issues with encodings, Unicode handling in apps, text filter bypasses, and other Unicode-related tasks.

* [Inspect Page - Unicode Visualizer](https://unicode.link/inspect)

* [Unicode Visualization](https://wichmann.github.io/UnicodeVisualization/)

* [Antisquare - Dynamically find the right font to avoid missing glyphs (aka glyphlessness, replacement glyph, missing glyph squares, tofu, tofubake, トーフ, トーフ化け, 豆腐化け, 文字化け) ](https://github.com/nicolas-raoul/Antisquare)

* [Unicode character inspector - Enter raw text to inspect, or try a hex code or search by name](https://apps.timwhitlock.info/unicode/inspect)

* [Unicode Character Search - FileFormat.Info](https://www.fileformat.info/info/unicode/char/search.htm)

* [Unicode - fileformat.info](https://www.fileformat.info/info/unicode/)
> From Wikipedia:
> 
> Details of many Unicode characters, including the named, decimal and hexadecimal character reference, showing how it should look and for each, how it looks in one's browser.

* [utf8-validator: Reads and outputs an UTF-8 string by replacing invalid sequences and glyphs with the replacement glyph � (0xFFFD)](https://github.com/detomon/utf8-validator)

* [Unicode programming, with examples](https://begriffs.com/posts/2019-05-23-unicode-icu.html)

* [Byte order mark (BOM) - Wikipedia](https://en.wikipedia.org/wiki/Byte_order_mark)

* [Endianness - Wikipedia](https://en.wikipedia.org/wiki/Endianness)
> In computing, endianness is the order in which bytes within a word of digital data are transmitted over a data communication medium or addressed (by rising addresses) in computer memory, counting only byte significance compared to earliness.
> Endianness is primarily expressed as big-endian (BE) or little-endian (LE), terms introduced by Danny Cohen into computer science for data ordering in an Internet Experiment Note published in 1980.

* [A Programmer's Introduction to Unicode](https://www.reedbeta.com/blog/programmers-intro-to-unicode/)

* [Unicode in Five Minutes - archived from the original on Feb 19, 2015](https://web.archive.org/web/20150219015700/https://richardharr.is/unicode-in-five-minutes.html)

* [ All sorts of things you can get wrong in Unicode, and why - archived from the original on Feb 19, 2015](https://web.archive.org/web/20150219032207/http://richardharr.is/all-sorts-of-things-you-can-get-wrong-in-unicode-and-why.html)

* [Programming with Unicode](https://unicodebook.readthedocs.io/index.html)

* [utf8 on grml - GrmlWiki](http://wiki.grml.org/doku.php?id=utf8)

* [Unicode Font Guide For Free/Libre Open Source Operating Systems](http://www.unifont.org/fontguide/)

* [What every JavaScript developer should know about Unicode](https://dmitripavlutin.com/what-every-javascript-developer-should-know-about-unicode/)

* [Open-source Unicode typefaces](https://en.wikipedia.org/wiki/Open-source_Unicode_typefaces)
> There are Unicode typefaces which are open-source and designed to contain glyphs of all Unicode characters, or at least a broad selection of Unicode scripts. 
> [ . . . ]
> Unicode fonts in modern formats such as OpenType can in theory cover multiple languages by including multiple glyphs per character, though very few actually cover more than one language's forms of the unified Han characters.

* [Unicode spaces](https://www.jkorpela.fi/chars/spaces.html)
> This document lists the various space characters in [Unicode](https://www.jkorpela.fi/chars.html#10646).
> For a description, consult [Chapter 6 Writing Systems and Punctuation - The Unicode Standard Core Specification](http://www.unicode.org/versions/latest/ch06.pdf) and block description [General Punctuation](http://www.unicode.org/charts/PDF/U2000.pdf) in the Unicode standard.
> This document also lists three characters that have no width and can thus be described as no-width spaces.
> 
> The third column of the following table shows the appearance of the space character, in the sense that the cell contains the words "foo" and "bar" in bordered boxes separated by that character.
> *It is possible that your browser does not present all the space characters properly*.
> This depends on the font used, on the browser, and on the fonts available in the system.

* [What are Digraphs? - Digraphs in Firefox (as seen in Vim) - Manuel Strehl](https://manuel-strehl.de/digraphs_in_firefox)
> I really became addicted to Vim’s digraph feature. It's a simple but elegant way to input higher Unicode by entering combinations of ASCII characters. In insert mode, you press Ctrl-K followed by a mnemonic two-character sequence and Vim inserts the corresponding character from the digraphs table.
> 
> The Wikipedia has an article about different input methods on several OSes and programs. In my opinion, the digraphs are one of the most elegant.
> 
> All existing digraphs in Vim can be listed with the :digraphs command. With two minor exceptions this table corresponds to all the two-letter digraphs standardized in RFC 1345.

* [Unicode input](https://en.wikipedia.org/wiki/Unicode_input)
> In the Vim editor, in insert mode, the user first types `Ctrl`+`V` `u` (for codepoints **up to 4 hex digits long**; using `Ctrl`+`V` `Shift`+`U` for longer), then types in the hexadecimal number of the symbol or character desired, and it will be converted into the symbol. (On Microsoft Windows, `Ctrl`+`Q` may be required instead of `Ctrl`+`V`.)

* [LaTeX names mapped to Unicode entities - This file is a collection of information about how to map Unicode entities to LaTeX](https://www.w3.org/Math/characters/unicode.xml)
> This file is a collection of information about how to map Unicode entities to LaTeX, and various SGML/XML entity sets (ISO and MathML). A Unicode character may be mapped to several entities.
> 
> Designed by Sebastian Rahtz in conjunction with Barbara Beeton for the STIX project.

* [Shapecatcher - Online tool to find Unicode characters by drawing them - Unicode Character Recognition](https://shapecatcher.com/index.html) 

* [Unicode Converter - Decimal, text, URL, and unicode converter](https://www.branah.com/unicode-converter)
> From Wikipedia:
> 
> Conversion between copy-pasteable characters, Unicode notation, html, percent encodings and other formats, helpful when trying to enter or interpret characters.

* [Alan Wood's Unicode resources - Unicode and multilingual support in HTML, fonts, Web browsers and other applications](http://www.alanwood.net/unicode/index.html)
> From Wikipedia:
> 
> Comprehensive resource with character test pages for all Unicode ranges, as well as OS-specific Unicode support information and links to fonts and utilities.

* [On snot and fonts](https://luc.devroye.org/fonts.html)
> Type design, typography, typefaces and fonts: These pages were permanently clo
sed on May 6, 2022. An encyclopedic treatment of type design, typefaces and font
s. This site is also known as on snot and fonts. [Full length pages](https://luc
.devroye.org/fonts.html). [Index pages](https://luc.devroye.org/fonts-index.html
).
>
> [About](https://luc.devroye.org/about.html):
>
> The content
>
> These encyclopedic pages offer over 90,000 entries with information on type design, type designers, the history and choice of fonts and typefaces, the mathematics of type design, font software, and typographic matters in general. The subjects are cross-classified by country, language, tag, style, and category. Each item also has a dedicated subpage with additional images not shown on the main pages [click on pink dots like ⦿]. I started this work in 1993. I halted it on May 6, 2022, after a terrible bicycle accident. 

* [Graphemica - For people who ♥ letters, numbers and symbols - A great resource for finding Unicode for especially tricky special characters](https://graphemica.com/)

* [DenCode - Encoding & Decoding Online Tools](https://dencode.com/)
> DenCode is a web application for encoding and decoding values.
> e.g. HTML Escape / URL Encoding / Base64 / MD5 / SHA-1 / CRC32 / and many other String, Number, DateTime, Color, Cipher, Hash formats

* [DenCode - source code on GitHub](https://github.com/mozq/dencode-web) 

* [What Unicode character is this? (Enter character or string of characters to convert)](https://babelstone.co.uk/Unicode/whatisit.html)
> Supports all 154,998 named characters defined in [Unicode 16.0](https://www.unicode.org/versions/Unicode16.0.0/) (released September 2024). Pass through a string of Unicode characters in the URL with the "string" parameter, e.g. [https://www.babelstone.co.uk/​Unicode/​whatisit.html?​string=🤦Q☃á€香](https://www.babelstone.co.uk/​Unicode/​whatisit.html?​string=🤦Q☃á€香). See [here](https://babelstone.co.uk/Unicode/whatisit_doc.html) for additional documentation.

* [Documentation for What Unicode character is this?](https://babelstone.co.uk/Unicode/whatisit_doc.html) 

* [Unicode lookup - Unicode search tool - browse around and search for Unicode characters, see properties, transformations](https://unicode.scarfboy.com/)
> Character set up to date to Unicode 12. The tool as a whole is a new version, public in early stages. As I work on it, it will be missing features, occasionally its data, and sometimes give error

* [BabelMap Online (Unicode 16.0)](https://babelstone.co.uk/Unicode/babelmap.html)

* [Unicode Text Styler](https://babelstone.co.uk/Unicode/text.html)

* [Unicode 16.0 Slide Show](https://babelstone.co.uk/Unicode/unicode.html)
> 154,998 characters in 332 blocks covering 168 scripts.

* [BabelStone Unicode Fonts](https://www.babelstone.co.uk/Fonts/index.html)

* [A great set of UTF-8 test documents -- Every Unicode character/codepoint in files and a file generator](https://github.com/bits/UTF-8-Unicode-Test-Documents)
> **Every Unicode code point**
> 
> While building and testing code meant to properly handle arbitrary UTF-8 strings, you might want to make use of some test documents that include every possible Unicode codepoint. These would include control codes like NULL, EOT, XOFF, CANcel and the never-seen-used DC2, all of 7-bit US-ASCII and explode in volume to cover the deepest recesses of Unicode. Here are those documents.
> 
> You never know what garbage people, fuzzers or errors will throw at your system, so here you'll find the gamut of representable characters / code points to test with.

* [SYMBL - Symbols, Emojis, Hieroglyphs, Scripts, Alphabets, and the entire Unicode](https://symbl.cc/)

* [WAZU Japan's Gallery of Unicode Fonts](https://www.wazu.jp/index.html)
> **Background**
> 
> The Gallery of Unicode Fonts was created by David McCreedy and Mimi Weiss in March, 2004 as part of their [Four Essential Travel Phrases](http://www.travelphrases.info/) website.
> 
> In October, 2006 the site was ceded to WAZU JAPAN.
> 
> This Gallery displays samples of available Unicode fonts by writing system (roughly equivalent to Unicode ranges).
> These are primarily Windows fonts, although some may work on other platforms.
> 
> Without doubt [Alan Wood's Unicode Resources](http://www.alanwood.net/unicode/) is the single most useful website on using Unicode and the fonts that support it.
> 
> So why create another Unicode font website? So that when you're looking for a Windows Unicode font you can quickly and easily see what the font looks like.

* [Unicode kaomoji smileys emoticons emoji - Has weird right-to-left characters](https://gist.github.com/endolith/157796)

* [Lenny Face - All text faces copy and paste](https://lennyfacepapa.me/)
> What does the Lenny face mean?
> 
> Lenny Face ( ͡° ͜ʖ ͡°) is a text based emoji created with different types of Unicode code characters and text symbols. The Lenny Faces are often used to express the feeling, emotion, nature by using these emoticon faces. These types of Lenny Faces are usually used on social media networks like WhatsApp, Tumblr, Facebook, Twitter, Snapchat, Pinterest, Reddit, Instagram or other social media. It is popular by other names in different countries: "keyboard faces", "Deg Deg face",  "Kawaii face, "ASCII Faces" "Kaomoji" or "Le Lenny Face".

* [2000+ Lenny Faces ( ͡° ͜ʖ ͡°) Copy and Paste (⌐■_■)](https://www.fancytextpro.com/LennyFace)
> 2000+ Lenny Faces copy and paste from one place including, Shrugging Lenny ¯\_(ツ)_/¯ Angry (◣_◢) Excited ٩(^ᴗ^)۶ Glasses (⌐■_■) happy ( ͡° ͜ʖ ͡°) Lenny faces hundreds of more.

* [About Shrug emotiocn (Shruggie) - from text.makeup:](https://text.makeup/#%C2%AF%5C_(%E3%83%84)_%2F%C2%AF)
>
> Emoticon
> 
> Emoticon is a convention, invented in the 1980s, of representing human faces or emotions by a combination of punctuation characters. It's been largely supplanted by emoji today. Its Japanese equivalent is kaomoji. [Learn more on Wikipedia](https://en.wikipedia.org/wiki/Emoticon)
> 
> Shrug emoticon (shruggie)
> 
> One of the most popular emoticons. Uses a Japanese katakana character as the face. [Learn more on The Atlantic - archived from the original on Jul 29, 2020](https://archive.ph/FjktZ)
>
> Homoglyph (a.k.a. homograph)
> 
> There are other characters in Unicode that look similar or identical to this one. This can sometimes be used nefariously to [make people click on a wrong domain that looks like the one you expect](https://en.wikipedia.org/wiki/IDN_homograph_attack), to [fool a parser](https://passkwall.net/homoglyphs-and-bypassing-web-application-controls/) - and sometimes used creatively. [Learn more on Wikipedia](https://en.wikipedia.org/wiki/Homoglyph)

* [Skull Emoji - Skull and crossbones emoji](https://skull-emoji.com/)
> What does the skull emoji mean?
> 
> The skull emoji (💀) is typically used to represent death or danger. It is often used to indicate something is deadly serious or to express a dark or macabre sense of humor. The skull can also be used as a reminder of our own mortality and to reflect on the fragility of life. 
> 
> It's also commonly used as a way to express a sense of danger or risk. For example, someone might use the skull emoji when talking about a risky activity like skydiving.
> It's also used in Halloween context, to express the spooky atmosphere, to represent the death of a character or situation.
> 
> It's worth noting that the meaning of emojis can be interpreted differently based on the context and culture, so it's always good to clarify the context of the message if there is any confusion.
> 
> How to type skull emoji?
> 
> There are several ways to type the skull emoji, depending on the device you're using:
> * On most smartphones and computers, you can simply use your emoji keyboard to select the skull emoji. On an iPhone, for example, you can access the emoji keyboard by tapping the globe icon next to the space bar. On an Android device, you can access the emoji keyboard by tapping the smiley face icon in your keyboard.
> * You can also type the skull emoji by using its Unicode code point. The Unicode code point for the skull emoji is `U+1F480`. On some devices, you can type this code point by holding down the "Alt" key and typing "1F480" on the numeric keypad (while using the Unicode hexadecimal input method).
> * If your device does not support the above methods, you can copy and paste the skull emoji from a website that provides a list of emojis, such as Emojipedia. Simply copy the emoji from the website and paste it into your message or document.

* [Fancy Text generator and Font Generator](https://www.thefancytext.com/)
> Font generator (font maker) tools have drastically changed the method of presenting text most stylishly and appealingly just copy and paste fonts and bingo.

* [gucharmap (GNOME Unicode Character Map - Unicode/ISO10646 character map and font viewer)](https://wiki.gnome.org/Apps/Gucharmap)

* [KCharSelect - Character selector for KDE](https://docs.kde.org/stable5/en/kcharselect/kcharselect/index.html)
> KCharSelect is a tool to select special characters from all installed fonts and copy them in different format (Plain text, Unicode or HTML) into the clipboard.

* [Introduction to: Examples Of Unicode Usage For Business Applications](http://www.i18nguy.com/unicode/unicode-example-intro.html)

* [Unicode utilites - on Unicode.org](https://util.unicode.org/UnicodeJsps/index.jsp)

* [A valid character to represent an invalid character](https://www.johndcook.com/blog/2024/01/11/replacement-character/)
> You may have seen a web page with the symbol � scattered throughout the text, especially in older web pages. What is this symbol and why does it appear unexpected?
> 
> The symbol we're discussing is a bit of a paradox. It's the (valid) Unicode character to represent an invalid Unicode character. If you just read the first sentence of this post, without inspecting the code point values, you can't tell whether the symbol appears because I've made a mistake, or whether I've deliberately included the symbol.
> 
> The symbol in question is U+FFFD, named REPLACEMENT CHARACTER, a perfectly valid Unicode character. But unlike this post, you're most likely to see it when the author did not intend for you to see it. What's going on?
> 
> It all has to do with character encoding.

* [Why "a caret, euro, trademark" â€™ in a file?](https://www.johndcook.com/blog/2024/01/11/a-caret-euro-trademark/)
> Why might you see â€™ in the middle of an otherwise intelligible file? The reason is very similar to the reason you might see �, which I explained in the [previous post](https://www.johndcook.com/blog/2024/01/11/replacement-character/). You might want to read that post first if you’re not familiar with Unicode and character encodings.
> 
> It all has to do with an encoding error, probably. Not necessarily, since, for example, I deliberately put â€™ in the opening sentence. But assuming it is an error, it's likely an encoding error.
> 
> But it's the opposite of the � error. The � occurs when non- UTF-8 text has been declared (or implicitly interpreted as) Unicode. In particular, you can run into this error if text encoded in ISO 8859-1 is interpreted as as UTF-8.
> 
> The â€™ sequence is usually the opposite: UTF-8 encoded text is being interpreted as Windows-1252 (a.k.a. CP-1252) encoded text. In particular, a single quote (U+2019) encoded in UTF-8 has been interpreted as the Windows-1252 text â€™.

* [Fallback font - Wikipedia](https://en.wikipedia.org/wiki/Fallback_font)
> A fallback font is a reserve typeface containing symbols for as many Unicode characters as possible. When a display system encounters a character that is not part of the repertoire of any of the other available fonts, a symbol from a fallback font is used instead. Typically, a fallback font will contain symbols representative of the various types of Unicode characters.
>
> Systems that do not offer a fallback font typically display black or white rectangles, question marks, the Unicode Replacement Character (U+FFFD), or nothing at all, in place of missing characters. Placing one or more fallback fonts at the end of a list of preferred fonts ensures that there are no missing characters. 
* [Dark corners of Unicode](https://eev.ee/blog/2015/09/12/dark-corners-of-unicode/)

* [Font Falsehoods - Falsehoods programmers believe about fonts](https://github.com/RoelN/Font-Falsehoods)

* [A Spectre is Haunting Unicode](https://www.dampfkraft.com/ghost-characters.html)

* [Text Editing Hates You Too](https://lord.io/text-editing-hates-you-too/)

* [Text Rendering Hates You](https://faultlore.com/blah/text-hates-you/)

* [Bitten by Unicode aka Bitten by bad Unicode usage - Discussion on Hacker News](https://news.ycombinator.com/item?id=41485001)

* [Bitten by Unicode](https://pyatl.dev/2024/09/01/bitten-by-unicode/)

* [Unicode is Kind of Insane](http://www.benfrederickson.com/unicode-insanity/)

* [The End-of-Line Story -- RFC Editor (2004)](https://www.rfc-editor.org/old/EOLstory.txt)

----

## Footnotes

[1] `command -V` and `type` is POSIX-compatible, while in **tcsh**, you can use `which`. 

```
% ps $$
  PID TT  STAT    TIME COMMAND
27010 17  Ss   0:00.71 -csh (csh)

% printf %s\\n "$SHELL"
/bin/csh

% command -V csh; type csh; which csh; whereis -a csh; where csh
csh is /bin/csh
csh is /bin/csh
/bin/csh
csh: /bin/csh /usr/share/man/man1/csh.1.gz
/bin/csh

% command -V tcsh; type tcsh; which tcsh; whereis -a tcsh; where tcsh
tcsh is /bin/tcsh
tcsh is /bin/tcsh
/bin/tcsh
tcsh: /bin/tcsh /usr/share/man/man1/tcsh.1.gz
/bin/tcsh

% ls -lh /usr/share/man/man1/csh.1.gz /usr/share/man/man1/tcsh.1.gz
-r--r--r--  2 root wheel   65K Jul 27  2022 /usr/share/man/man1/csh.1.gz
-r--r--r--  2 root wheel   65K Jul 27  2022 /usr/share/man/man1/tcsh.1.gz
 
% diff /usr/share/man/man1/csh.1.gz /usr/share/man/man1/tcsh.1.gz

% ls -lh /bin/csh /bin/tcsh
-r-xr-xr-x  2 root wheel  432K Apr  8 13:31 /bin/csh
-r-xr-xr-x  2 root wheel  432K Apr  8 13:31 /bin/tcsh
 
% diff /bin/csh /bin/tcsh

% csh --version
tcsh 6.22.04 (Astron) 2021-04-26 (x86_64-amd-FreeBSD) options wide,nls,dl,al,kan,sm,rh,color,filec
 
% tcsh --version
tcsh 6.22.04 (Astron) 2021-04-26 (x86_64-amd-FreeBSD) options wide,nls,dl,al,kan,sm,rh,color,filec

% /bin/csh --version
tcsh 6.22.04 (Astron) 2021-04-26 (x86_64-amd-FreeBSD) options wide,nls,dl,al,kan,sm,rh,color,filec
 
% /bin/tcsh --version
tcsh 6.22.04 (Astron) 2021-04-26 (x86_64-amd-FreeBSD) options wide,nls,dl,al,kan,sm,rh,color,filec
```

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
 
% command -V builtins; type builtins; which builtins; whereis -a builtins; where builtins
builtins: not found
builtins: not found
builtins: shell built-in command.
builtins: /usr/share/man/man1/builtins.1.gz
builtins is a shell built-in
```

References

* [What is the unix command to find out what executable file corresponds to a given command?](https://superuser.com/questions/351889/what-is-the-unix-command-to-find-out-what-executable-file-corresponds-to-a-given)
> For the **T C Shell**, **tcsh**, the built-in is the `which` command - not to be confused with any external command by that name:
> 
> ```
% which ls
ls: aliased to ls-F
% which \ls
/bin/ls
> ```

* [Why not use "which"? What to use then?](https://unix.stackexchange.com/questions/85249/why-not-use-which-what-to-use-then)
> Comment by Stéphane Chazelas May 21, 2014:
>  yes, `csh` (and `which` is still a csh *script* on *most commercial Unices*) does read `~/.cshrc` when *non-interactive*.
> That's why you'll notice csh scripts usually start with `#!/bin/csh -f`.
> `which` does not because it *aims* to give you the aliases because it's meant as a tool for (interactive) users of csh.
> POSIX shells users have `command -v`.
> 
> . . . 
> 
> **History**
> 
> . . . 
> 
> The early Unix shells until the late 70s had no functions or aliases.
> Only the traditional looking up of executables in `$PATH`.
> `csh` introduced aliases around 1978 (though `csh` was first released in 2BSD, in May 1979), and also the processing of a `.cshrc `for users to customize the shell (every shell, as `csh`, reads `.cshrc` even when not interactive like in scripts).
> 
> . . . 
> 
> `csh` got a lot more popular than the Bourne shell as (though it had an awfully worse syntax than the Bourne shell) it was adding a lot of more convenient and nice features for interactive use.
> 
> In 3BSD (1980), a [which csh script](https://github.com/dspinellis/unix-history-repo/blob/BSD-3/usr/ucb/which) was added for the `csh` users to help identify an executable, and it's a hardly different script you can find as `which` on many *commercial Unices* nowadays (like Solaris, HP/UX, AIX or Tru64).
> 
> . . . 
> 
> Here you go: `which` came first for the most popular shell at the time (and `csh` was still popular until the mid-90s), which is the main reason why it got documented in books and is still widely used.
> 
> . . . 
> 
> A similar functionality was not added to the Bourne shell until 1984 in SVR2 with the `type` builtin command.
> The fact that it is **builtin** (as opposed to an **external script**) means that it can give you the right information (to some extent) as it has access to the internals of the shell.
>
> . . . 
>
> The `which` csh script meanwhile was removed from NetBSD (as it was builtin in tcsh and of not much use in other shells), and the functionality added to `whereis` (when invoked as `which`, `whereis` behaves like `which` except that it only looks up executables in `$PATH`.
> In OpenBSD and FreeBSD, `which` was also changed to one written in C that looks up commands in `$PATH` only.

* [How can I check if a program exists from a Bash script?](https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script)
> Answered by user lhunath on Mar 24, 2009 - Edited by user Daniel Kaplan on Sep 12, 2023:
>
> . . . 
> POSIX compatible:
>
> `command -v <the_command>`
> . . . 

----

[2] For example, on my FreeBSD 14 system, certain emojis were missing or not displaying correctly in Mozilla Firefox web browser. On the following sites some emojis, especially emoji ZWJ (ZERO WIDTH JOINER) sequences, were not displaying; that is, there were blank spaces in their places. 

* [https://emojis.wiki/](https://emojis.wiki/)
* [https://getemoji.com/](https://getemoji.com/)
* [https://emojipedia.org/](https://emojipedia.org/)
* [https://emojiterra.com/](https://emojiterra.com/)
* [https://openmoji.org/](https://openmoji.org/)
* [https://emojikitchen.com/](https://emojikitchen.com/)

I fixed it by uninstalling (deinstalling) Noto Fonts family for emoji (package name on FreeBSD: `noto-emoji`). 

```
$ sudo pkg remove noto-emoji
```

Others reported that they fixed it by: 

* copying `TwemojiMozilla.ttf` font file to `~/.fonts` directory (`cp -i /usr/local/lib/firefox/fonts/TwemojiMozilla.ttf ~/.fonts`) 
* preventing the Mozilla font interfering with their system emoji font, by going to `about:config` in Firefox and changing `gfx.font_rendering.opentype_svg.enabled` to `false` or doing the opposite of the previous step; that is, removing 
`/usr/local/lib/firefox/fonts/TwemojiMozilla.ttf` in FreeBSD (or `/usr/lib/firefox/fonts/TwemojiMozilla.ttf` in Linux)
* by ignoring Firefox's Twemoji font for emojis and using the system font for emojis - by going to `about:config` in Firefox and changing `font.name-list.emoji` from `Twemoji Mozilla` to `emoji`

References for this:

* [Emoji - openSUSE Wiki](https://en.opensuse.org/Emoji)
> Install colored emoji fonts
> 
> openSUSE provides the following colored emoji fonts:
> * Noto Color Emoji (noto-coloremoji-fonts), the default emoji font of most Android smart phones.
> * Emoji One (emojione-color-font), an open source emoji project with best Unicode coverage.
> Note: Emoji One is deprecated and was replaced by JoyPixels.
> * Twitter Emoji (twemoji-color-font), used by Twitter website and mobile applications.
> 
> You can install **one** of them. There is *no need to install multiple emoji fonts* and it *may cause problems*.
>
> . . . 
> 
> Firefox emoji font configuration
> 
> Firefox comes with **built-in** emoji font: **Twemoji Mozilla**. And it is used *by default*. To change it to your system emoji font, go to `about:config` page, search `font.name-list.emoji` and change it to the emoji font name your would like to use. 

* [Solved - Emoji not displayed or overlapping text - The FreeBSD Forums](https://forums.freebsd.org/threads/emoji-not-displayed-or-overlapping-text.84951/)
* [Emoji ZWJ Sequence](https://emojipedia.org/emoji-zwj-sequence)

* [Firefox Font Troubleshooting - ArchWiki (Arch Linux Wiki)](https://wiki.archlinux.org/title/Firefox#Font_troubleshooting)
> Firefox has a setting which determines how many replacements it will allow from Fontconfig. To allow it to use all your replacement rules, change `gfx.font_rendering.fontconfig.max_generic_substitutions` to `127` (the highest possible value).
> 
> Firefox ships with the *Twemoji Mozilla* font. To use the system emoji font, set `font.name-list.emoji` to `emoji` in `about:config`. Additionally, to prevent the Mozilla font interfering with your system emoji font, change `gfx.font_rendering.opentype_svg.enabled` to `false` or remove `/usr/lib/firefox/fonts/TwemojiMozilla.ttf`.
* [Twemoji Confs - Reddit (self.linux)](https://old.reddit.com/r/linux/comments/gs83sj/twemoji_confs/)
> Comment by es20490446e[S]: 
> 
> Probably fontconfig was never designed with emoji in mind, where a specific set of glyphs should take over any other used font in the system.
> So figuring out how to do that got too messy for humans.
> 
> . . . 
> 
> Comment by xtifr: Do need the Noto fonts, but those are included, and don't need any special configuration. Just run `apt install fonts-noto`.
>
> . . . 
> 
> Comment by WhyNotHugo: I did en up taking a different approach though; ignore non-emojis glyphs for Twemoji, and make it the first font to be used: 
> [Configure Twemoji to be globally used for emoji - Archived from the original on Jul 2, 2020](https://web.archive.org/web/20200702074415/https://github.com/WhyNotHugo/sysconfig/commit/f6ed896b983db03da0beffc0e92891dbca384e31#diff-8daa883c9aa70cb4d7a400fc85f298d8)

----

[3] On my FreeBSD 14 system, the `iconv -l` command produced different output with `iconv(1)` from base install versus `iconv(1)` from packages.

```
% iconv -l | wc -l
     216
 
% iconv -l | grep -i latin | wc -l
      12
 
% iconv -l | grep -i latin1 | wc -l
       2
```

From the man page for `iconv(1)` on FreeBSD 14:

```
-l    Lists available codeset names.  Note that not all combinations of
      from_name and to_name are valid.
```

```
% locate iconv | grep man | wc -l
      22

% locate iconv | grep man | grep man1 | wc -l
       3
 
% locate iconv | grep man | grep -v jail | grep -v external | grep man1 
/usr/local/lib/perl5/5.36/perl/man/man1/piconv.1.gz
/usr/local/share/man/man1/iconv.1.gz
/usr/share/man/man1/iconv.1.gz
```

```
% man iconv | grep -i list
     -l    Lists available codeset names.  Note that not all combinations of
 
% man /usr/share/man/man1/iconv.1.gz | head -1
ICONV(1)                FreeBSD General Commands Manual               ICONV(1)

% man /usr/share/man/man1/iconv.1.gz | grep -i list
     -l    Lists available codeset names.  Note that not all combinations of
 
% man /usr/local/share/man/man1/iconv.1.gz | head -1
ICONV(1)                   Linux Programmer's Manual                  ICONV(1)
```

```
% man /usr/local/share/man/man1/iconv.1.gz | grep -n -i list
19:       implementation, they are listed in the iconv_open(3) manual page.
69:       The iconv -l or iconv --list command lists the names of the supported
72:       whitespace, and alias names of an encoding are listed on the same line
88:              lists the supported encodings.
```

```
% man /usr/local/share/man/man1/iconv.1.gz | sed -n 69,72p
       The iconv -l or iconv --list command lists the names of the supported
       encodings, in a system dependent format. For the libiconv
       implementation, the names are printed in upper case, separated by
       whitespace, and alias names of an encoding are listed on the same line
```

```
% command -V iconv; type iconv; which iconv; whereis -a iconv
iconv is /usr/bin/iconv
iconv is /usr/bin/iconv
/usr/bin/iconv
iconv: /usr/bin/iconv /usr/local/bin/iconv /usr/share/man/man1/iconv.1.gz /usr/local/share/man/man1/iconv.1.gz /usr/share/man/man3/iconv.3.gz /usr/local/share/man/man3/iconv.3.gz
```

```
% locate iconv | grep bin 
/usr/bin/iconv
/usr/local/bin/iconv
/usr/local/bin/piconv
```

```
% diff /usr/bin/iconv /usr/local/bin/iconv
Binary files /usr/bin/iconv and /usr/local/bin/iconv differ
```

```
% /usr/bin/iconv -l | wc -l
     216
 
% /usr/local/bin/iconv -l | wc -l
     196
```


```
% pkg which /usr/bin/iconv
/usr/bin/iconv was not found in the database
 
% pkg which /usr/local/bin/iconv
/usr/local/bin/iconv was installed by package libiconv-1.17_1
``` 

``` 
% pkg query %Fp libiconv-1.17_1
/usr/local/bin/iconv
/usr/local/include/iconv.h
/usr/local/include/libcharset.h
/usr/local/include/localcharset.h
/usr/local/lib/libcharset.a
/usr/local/lib/libcharset.so
/usr/local/lib/libcharset.so.1
/usr/local/lib/libcharset.so.1.0.0
/usr/local/lib/libiconv.a
/usr/local/lib/libiconv.so
/usr/local/lib/libiconv.so.2
/usr/local/lib/libiconv.so.2.6.1
/usr/local/share/doc/libiconv/iconv.1.html
/usr/local/share/doc/libiconv/iconv.3.html
/usr/local/share/doc/libiconv/iconv_close.3.html
/usr/local/share/doc/libiconv/iconv_open.3.html
/usr/local/share/doc/libiconv/iconv_open_into.3.html
/usr/local/share/doc/libiconv/iconvctl.3.html
/usr/local/share/licenses/libiconv-1.17_1/GPLv3
/usr/local/share/licenses/libiconv-1.17_1/LICENSE
/usr/local/share/licenses/libiconv-1.17_1/catalog.mk
/usr/local/share/man/man1/iconv.1.gz
/usr/local/share/man/man3/iconv.3.gz
/usr/local/share/man/man3/iconv_close.3.gz
/usr/local/share/man/man3/iconv_open.3.gz
/usr/local/share/man/man3/iconv_open_into.3.gz
/usr/local/share/man/man3/iconvctl.3.gz
```

From the man page for `pkg-shlib` on FreeBSD 14:

```
pkg shlib – display which installed package provides a specfic shared
library, and the installed packages which require it
  
library is the filename of the library without any leading path, but
including the ABI version number.  Only exact matches are handled.
```

```
% pkg shlib libiconv
No packages provide libiconv.
No packages require libiconv.
 
% pkg shlib libiconv.so.2
libiconv.so.2 is provided by the following packages:
libiconv-1.17_1
libiconv.so.2 is linked to by the following packages:
p5-Locale-libintl-1.33
chromium-123.0.6312.58
glib-2.80.0,2
libdatrie-0.2.13_2
vlc-3.0.20_5,4
mutt-2.2.13
fontforge-20230101
groff-1.23.0_3
fvwm-2.6.9_3
rsync-3.2.7_1
 
% pkg shlib libiconv.so.2.6.1
No packages provide libiconv.so.2.6.1.
No packages require libiconv.so.2.6.1.
```

----

[4] For a brief help for `uni` tool:

```
% uni 
Usage: uni [command] [flags]

uni queries the unicode database. https://github.com/arp242/uni

Flags:
    -f, -format    Output format.
    -a, -as        How to print the results: list (default), json, or table.
    -c, -compact   More compact output.
    -r, -raw       Don't use graphical variants or add combining characters.
    -p, -pager     Output to $PAGER.
    -o, -or        Use "or" when searching instead of "and".

Commands:
    list           List Unicode data such as blocks, categories, etc.
    identify       Identify all the characters in the given strings.
    search         Search description for any of the words.
    print          Print characters by codepoint, category, or block.
    emoji          Search emojis.

Use "uni help" or "uni -h" for a more detailed help.
```

Use `uni help` or `uni -h` for a more detailed help.

----

