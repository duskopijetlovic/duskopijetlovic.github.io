---
layout: post
title: "Why Does My Program Display Some Characters as Square (Tofu)?" 
date: 2024-08-11 16:41:24 -0700 
categories:  unicode utf8 x11 xorg xterm cli terminal shell howto sysadmin unix 
             typography font webbrowser html
---

a.k.a. Why does my editor display some characters as square (tofu)?

----

## TL;DR 

Typically that means that the character is not recognized by the font; that is, the font does not include a glyph for that character.

The idiom: the font is missing a glyph.

(The no-break space sign forces clients to **not** break the line at this space, usually to improve readability.)

----

## Terminology

* Square, Square symbol, Tofu, Tofubake, Replacement glyph ( [The Unicode standard](http://unicode.org/glossary/#replacement_glyph) ), Glyph not available, Hexagana, Rectangle, Missing glyph square, Glyph replacement, Font fallback box glyph, Glyphlessness, Failure glyph
* トーフ, トーフ化け, 豆腐化け, 文字化け

More:  

[What do you call the phenomenon where a rectangle □ is shown because a font lacks a glyph?](https://english.stackexchange.com/questions/62524/what-do-you-call-the-phenomenon-where-a-rectangle-is-shown-because-a-font-lack)

[Where is "tofu" for "font fallback box glyph" coming from?](https://english.stackexchange.com/questions/296505/where-is-tofu-for-font-fallback-box-glyph-coming-from)

----

OS: *FreeBSD 14*

```
% freebsd-version 
14.0-RELEASE-p6
```

Shell: *csh*

```
% ps $$
  PID TT  STAT    TIME COMMAND
69641 19  Ss   0:00.95 -csh (csh)
```

```
% printf %s\\n "$SHELL"
/bin/csh
```

----

```
% fc-match 0xProto
0xProto-Regular.otf: "0xProto" "Regular"
```

```
% xterm -fa 0xProto -fs 12 -geometry 20x4+200+20 -bg black -fg white
```

```
% vi hello.txt
```

```
Hello, world!
~
~

```


![The 0xProto font displays NBSP as a square](/assets/img/nbsp-0xProto-font.jpg "The 0xProto font displays NBSP as a square")

*Figure:* The 0xProto font displays NBSP as a square.


```
% hexdump < hello.txt
0000000 6548 6c6c 2c6f a0c2 6f77 6c72 2164 000a
000000f
```

```
% hexdump -C < hello.txt
00000000  48 65 6c 6c 6f 2c c2 a0  77 6f 72 6c 64 21 0a     |Hello,..world!.|
0000000
```


```
% hd < hello.txt
00000000  48 65 6c 6c 6f 2c c2 a0  77 6f 72 6c 64 21 0a     |Hello,..world!.|
0000000f
```

```
% od -ac < hello.txt
0000000    H   e   l   l   o   ,  c2  a0   w   o   r   l   d   !  nl    
           H   e   l   l   o   ,      **   w   o   r   l   d   !  \n    
0000017
```


![The od(1) utility output: named characters and C-style escaped characters")](/assets/img/nbsp-od-ac-0xProto-font.jpg "The 0xProto font displays NBSP as a square - od(1) utility output: named characters and C-style escaped characters")

*Figure:* The `od(1)` utility output: named characters and C-style escaped characters.


From the man page for `od(1)` on FreeBSD 14:

```
-N length  Dump at most length bytes of input.
-H, -X     Output hexadecimal ints.  Equivalent to -t x4.
-h, -x     Output hexadecimal shorts.  Equivalent to -t x2.

Dump stdin skipping the first 13 bytes using named characters and dumping
no more than 5 bytes:

     $ echo "FreeBSD: The power to serve" | od -An -a -j 13 -N 5
                p   o   w   e   r
```


```
% od -N 8 -t a -c < hello.txt
0000000    H   e   l   l   o   ,  c2  a0                                
           H   e   l   l   o   ,      **                                
0000010
```


Dump the file skipping the first 6 bytes using named characters and dumping no more than 2 bytes:

```
% od -j 6 -N 2 -t a -c < hello.txt
0000006   c2  a0                                                        
              **                                                        
0000010
```


```
% od -j 6 -N 2 -t a -c -H < hello.txt
0000006   c2  a0                                                        
              **                                                        
                 0000a0c2                                                
0000010
```

```
% od -j 6 -N 2 -t a -c -h < hello.txt
0000006   c2  a0                                                        
              **                                                        
             a0c2                                                        
0000010
```


```
% od -j 6 -N 2 -ab < hello.txt
0000006   c2  a0                                                        
          302 240                                                        
0000010
```

```
% printf '\302\240' | od -a
0000000   c2  a0                                                        
0000002
```

```
% printf '\302\240' | od -c
0000000       **                                                        
0000002
```

```
% printf '\302\240' | od -ac
0000000   c2  a0                                                        
              **                                                        
0000002
```

```
% printf '\302\240' | iconv -t utf16
���% 
```


!["NBSP: iconv(1) utility output in UTF-16 codeset"](/assets/img/nbsp-printf-octal-iconv.jpg "NBSP: iconv(1) utility output in UTF-16 codeset")

*Figure:* The `iconv(1)` utility output in UTF-16 codeset.


```
$ printf '\302\240' | uchardet
UTF-8
```

```
$ printf '\302\240' | iconv -t utf16 | uchardet
UTF-16
```

```
$ printf '\302\240' | iconv -t utf16 | od -ac
0000000   fe  ff nul  a0                                                
         376 377  \0 240                                                
0000004
```

```
% printf '\302\240' | iconv -t utf16 | hexdump -C
00000000  fe ff 00 a0                                       |....|
00000004
```

So, Unicode number for NBSP (aka NBSP in Unicode) is:  **00A0** (or **U+00A0**). 


NOTE: To get the value in UTF-8:

```
% printf '\302\240' | iconv -t utf8 | hexdump -C
00000000  c2 a0                                             |..|
00000002
```


NOTE: Alternatively, to get the Unicode number, you can use `uniname` from the package `uniutils` on FreeBSD 14: 

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


### What is the Unicode Name Represented by Its Unicode Number

aka What is the Unicode symbol represented by a Unicode pattern?


Download Perl **uni** script from leahneukirchen (Leah Neukirchen).

```
% fetch https://leahneukirchen.org/dotfiles/bin/uni
```

```
% file uni 
uni: Perl script text executable
```

```
% ls -lh uni 
-rw-r--r--  1 dusko dusko  1.0K Nov 16  2020 uni
 
% chmod 0744 uni
 
% mv uni uni.pl

% ls -lh uni.pl 
-rwxr--r--  1 dusko dusko  1.0K Nov 16  2020 uni.pl
```

```
% head -1 uni.pl
#!/usr/bin/perl -CAO
 
% ls -lh /usr/bin/perl
ls: /usr/bin/perl: No such file or directory
```

```
% command -v perl ; type perl ; which perl ; whereis perl
/usr/local/bin/perl
perl is /usr/local/bin/perl
/usr/local/bin/perl
perl: /usr/local/bin/perl /usr/local/lib/perl5/5.36/perl/man/man1/perl.1.gz
```

```
% grep -n bin uni.pl 
1:#!/usr/bin/perl -CAO
 
% sed -n '/bin/p' uni.pl
#!/usr/bin/perl -CAO
 
% sed -n '/bin/=' uni.pl
1
```

```
% sed -i'.SEDBAK' 's/bin/local\/bin/' uni.pl
``` 

``` 
% diff --unified=0 uni.pl.SEDBAK uni.pl
--- uni.pl.SEDBAK       2024-08-11 16:20:42.079037000 -0700
+++ uni.pl      2024-08-11 16:21:00.908762000 -0700
@@ -1 +1 @@
-#!/usr/bin/perl -CAO
+#!/usr/local/bin/perl -CAO
``` 

```
% ./uni.pl 00A0                                                                
        00A0    NO-BREAK SPACE
```


### `uniutils`

Install **uniutils**.

```
% sudo pkg install uniutils
```

Description of the `uniutils` package and its home page.

```
% pkg query %c uniutils
Unicode Description Utilities

% pkg query %w uniutils
https://billposer.org/Software/unidesc.html
```

List all files for the `uniutils` packages.
There are eight binaries. 

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
% printf '\302\240' > chrname
```

```
% uniname chrname
No LINES variable in environment so unable to determine lines per page.
Using default of 24.
character  byte       UTF-32  encoded as   glyph   name
        0          0  0000A0  C2 A0                NO-BREAK SPACE
```

```
% uniname -r chrname
No LINES variable in environment so unable to determine lines per page.
Using default of 24.
character  byte       UTF-32  encoded as   glyph   range               name
        0          0  0000A0  C2 A0                Latin-1 Supplement  NO-BREAK SPACE
```

```
% ExplicateUTF8 chrname
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
% utf8lookup 0000A0
No LINES variable in environment so unable to determine lines per page.
Using default of 24.
UTF-32   name
0000A0  NO-BREAK SPACE
```
 
```
% utf8lookup 00A0
No LINES variable in environment so unable to determine lines per page.
Using default of 24.
UTF-32   name
0000A0  NO-BREAK SPACE
```

```
% unisurrogate 
Given a Unicode codepoint outside the BMP, report its surrogate decomposition
The codepoint may be given in raw hex or preceded by either U+ or 0x
Usage: unisurrogate [options] codepoint
       -h Print help information.
       -v Print version information.

Report bugs to: billposer@alum.mit.edu
```

```
% unisurrogate 0x00A0
The codepoint U+00a0 falls within plane 0.
```

----


### `xkbcli-how-to-type(1)`

```
% /usr/local/libexec/xkbcommon/xkbcli-how-to-type 0x00a0 | grep keysym | cut -w -f2
nobreakspace
```

For more, see Footnote 2. [<sup>[2](#footnotes)</sup>]

----

### `xxd(1)`

```
% xxd chrname
00000000: c2a0                                     ..
```
 
```
% xxd -p chrname
c2a0
```

----

### `vim(1)`

```
% vim chrname
```

Inside the file:

```
 
~
~
"chrname" [noeol] 1L, 2B
```

Print the ascii value of the character under the cursor in decimal, hexadecimal and octal. [<sup>[1](#footnotes)</sup>]

While in the file you've opened with `vim(1)`, move the cursor to the first character on the first line, and then press **ga**.

The status line changes to:

```
< > 160, Hex 00a0, Oct 240, Digr NS
```


Alternatively, instead of **ga**, enter the command:

```
:ascii
```

The status line updates to:

```
< > 160, Hex 00a0, Oct 240, Digr NS
```

----

### Perl

``` 
% perl -E 'my $x = "A\N{NO-BREAK SPACE}C"; $x =~ s/\x{00A0}/ /g; say $x' | hexdump -C
00000000  41 20 43 0a                                       |A C.|
00000004
```

```
% perl -E 'my $x = "\N{NO-BREAK SPACE}"; say $x' | hexdump -C
00000000  a0 0a                                             |..|
00000002
```

----

### Fontconfig `fc-` Commands


```
% fc-match 0xProto
0xProto-Regular.otf: "0xProto" "Regular"
```

```
% fc-match -v 0xProto | wc -l
      55
```

```
% fc-match -v 0xProto | grep file
        file: "/home/dusko/.fonts/0xProto-Regular.otf"(s)
```

```
% ls -lh /home/dusko/.fonts/0xProto-Regular.otf
-rw-r--r--  1 dusko dusko   37K Dec 17  2023 /home/dusko/.fonts/0xProto-Regular.otf
``` 

``` 
% file /home/dusko/.fonts/0xProto-Regular.otf
/home/dusko/.fonts/0xProto-Regular.otf: OpenType font data
```

```
% fc-query /home/dusko/.fonts/0xProto-Regular.otf | wc -l
      40
``` 

``` 
% fc-query --brief /home/dusko/.fonts/0xProto-Regular.otf | wc -l
      29
```

```
% xfd -fa 0xProto
```


With the `-start number` (first character to show) option.


First, you need to convert hex do decimal:

```
% printf %d\\n "0x00A0"
160
```

```
% xfd -fa 0xProto -start 160
```

From the man page for `xfd(1)`:

```  
Individual character metrics (index, width, bearings, ascent and
descent) can be displayed at the top of the window by clicking on the
desired character.
```

```
% xfd -fa 0xProto -start 160 -rows 1
```

Click on the first character (first box).

!["NBSP: xfd(1) utility with 0xProto font displayed"](/assets/img/nbsp-xfd-one-row-0xProto-font.jpg "NBSP: xfd(1) utility output with 0xProto font displayed")

*Figure:* The `xfd(1)` utility output with font *0xProto* displayed.

For the selected character, `xfd(1)` shows *no such character 0x0000a0 (0,160) (0,0240)*.


Convert from hex 0x0000a0 to decimal.

```
% printf %d\\n "0x0000a0"
160
``` 

Convert from hex 0x0000a0 to octal.

``` 
% printf %o\\n "0x0000a0"
240
```

Explanation:
* *no such character*: 0xProto font doesn't have a symbol for Unicode U+00A0 
* 0x0000a0: hexadecimal 
* (0,160): decimal
* (0,0240): octal

----

## Tools

* `hexdump(1)`, `hd(1)`
* `od(1)`
* `uchardet(1)`
* `iconv(1)`
* `uni` Perl script  (from https://leahneukirchen.org/dotfiles/bin/uni)
* `xxd(1)`
* `fc-match(1)`
* `fc-query(1)`
* `xfd(1)`

* `uni` [<sup>[3](#footnotes)</sup>]
* `ftfy` [<sup>[4](#footnotes)</sup>]

* [Unicode font utilities - Russell W. Cottrell](https://www.russellcottrell.com/greek/utilities/unicode_font_utilities.zip)
> Includes:
> * *The Unicode Range Viewer*
> Displays 16×16 blocks of Unicode characters, with both hex and decimal codes.
> You choose the Unicode range and the font, bold or italic.
> It is useful for finding characters and exploring the ranges and apperance of different fonts.
> It also works as a universal virtual keyboard; go to any code page and click a character to create text, then convert it to HTML or JavaScript code if desired.
> You can find a code block by entering a Unicode character, or selecting a block from the list.
> If you choose a font, only the characters in that font are displayed.
> 
> * *The Surrogate Pair Calculator etc.*
> Calculates the surrogate pairs for high-bit supplemental plane values, the scalar value for a surrogate pair, or both for a supplemental plane character.
> Also includes the algorithms and sample code for converting to and from surrogate pairs.
> 
> * *The Polytonic Greek Virtual Keyboard*
> Allows you to type Unicode Greek characters via the keyboard.
> Also converts text to either HTML or JavaScript code characters.
>
> * *The Greek Number Converter*
Converts numbers to the alphabetic Greek format.
> The only converter of its type that I know of.

```
% man -k unicode | wc -l
      51
 
% man -k unicode 
gencfu(1) - Generates Unicode Confusable data files
icuexportdata(1) - Writes text files with Unicode properties data from ICU.
luit(1) - Locale and ISO 2022 support for Unicode terminals
perlunicode(1) - Unicode support in Perl
perlunicook(1) - cookbookish examples of handling Unicode in Perl
perlunifaq(1) - Perl Unicode FAQ
perluniintro(1) - Perl Unicode introduction
perluniprops(1) - Index of Unicode Version 14.0.0 character properties in Perl
perlunitut(1) - Perl Unicode Tutorial
uxterm(1) - X terminal emulator for Unicode (UTF-8) environments
xkbcli-how-to-type, xkbcli how-to-type(1) - query how to type a given Unicode codepoint
charnames(3) - access to Unicode character names and named character sequences; also define character names
Encode::Unicode(3) - Various Unicode Transformation Formats

[ . . . ]

unicrud(6) - Bounces a random Unicode character on the screen.
```

On FreeBSD 14:

```
% locate charnames
/usr/local/lib/perl5/5.30/_charnames.pm.pkgsave
/usr/local/lib/perl5/5.30/charnames.pm.pkgsave
/usr/local/lib/perl5/5.30/perl/man/man3/charnames.3.gz.pkgsave
/usr/local/lib/perl5/5.36/_charnames.pm
/usr/local/lib/perl5/5.36/charnames.pm
/usr/local/lib/perl5/5.36/perl/man/man3/charnames.3.gz
 
% ls -lh /usr/local/lib/perl5/5.36/charnames.pm
-r--r--r--  1 root wheel   21K Feb 17 17:16 /usr/local/lib/perl5/5.36/charnames.pm
 
% ls -lh /usr/local/lib/perl5/5.36/_charnames.pm
-r--r--r--  1 root wheel   35K Feb 17 17:16 /usr/local/lib/perl5/5.36/_charnames.pm
 
% file /usr/local/lib/perl5/5.36/charnames.pm
/usr/local/lib/perl5/5.36/charnames.pm: Perl5 module source, Unicode text, UTF-8 text
 
% file /usr/local/lib/perl5/5.36/_charnames.pm
/usr/local/lib/perl5/5.36/_charnames.pm: Perl5 module source, ASCII text

% wc -l /usr/local/lib/perl5/5.36/charnames.pm
     510 /usr/local/lib/perl5/5.36/charnames.pm
 
% wc -l /usr/local/lib/perl5/5.36/_charnames.pm
     884 /usr/local/lib/perl5/5.36/_charnames.pm
 
% grep -i A0 /usr/local/lib/perl5/5.36/charnames.pm
 
% grep -i A0 /usr/local/lib/perl5/5.36/_charnames.pm
  my $nbsp = chr utf8::unicode_to_native(0xA0);
```

```
% command -v unicrud; type unicrud; which unicrud; whereis unicrud
unicrud: not found
unicrud: Command not found.
unicrud: /usr/local/share/man/man6/unicrud.6.gz
 
% locate unicrud
/usr/local/bin/xscreensaver-hacks/unicrud
/usr/local/share/man/man6/unicrud.6.gz
/usr/local/share/xscreensaver/config/unicrud.xml

% /usr/local/bin/xscreensaver-hacks/unicrud --help
Unicrud: from the XScreenSaver 6.08 distribution (10-Oct-2023)

        https://www.jwz.org/xscreensaver/

Options include: --root, --window, --mono, --install, --noinstall, 
                 --visual <arg>, --window-id <arg>, --fps, --no-fps, --pair, 
                 --spin, --no-spin, --wander, --no-wander, --speed <arg>, 
                 --block <arg>, --titles, --no-titles, --delay <arg>, 
                 --font <arg>.

% /usr/local/bin/xscreensaver-hacks/unicrud
```

----

## References
(Retrieved on Aug 11, 2024)

* [Display Problems? - Unicode.org](https://www.unicode.org/help/display_problems.html)
> **Lack of Font Support**
> 
> Most operating systems include fonts that provide extensive coverage of Unicode characters, and most applications know how to make use of the system fonts.
> There may be gaps, however.
> 
> When Unicode text is displayed but there is a lack of font support for some characters in the text, the typical symptom is appearance of special character-not-supported or **"tofu" glyphs**.
> (Font vendors often refer to such glyphs as ".notdef" glyphs.)
> Often, this will look like a white **square box** (like *a piece of tofu*), or a box containing a question mark or diagonals.
> Some applications generate a **fallback glyph** that shows the *code point for the character*.
> 
![Square box or "tofu" when Unicode text is displayed but there is a lack of font support for some characters in the text](/assets/img/notdef_glyphs.png "Square box or "tofu" when Unicode text is displayed but there is a lack of font support for some characters in the text")
> 
> Other symbols might also be used.
> Sometimes, there might *just be blank space*.
>
> When this occurs, the underlying issue is most likely to be one of the following:
> 
> * The product might not yet have been updated to support characters added in the most recent versions of the Unicode Standard.
> * An operating system might have font support, but an application running on that OS might have its own font selection or fallback logic that is not up to date with what’s available in the latest version of the OS.
> Due to limited storage (especially on mobile devices) or other such factors, a vendor might decide not to include font support for less-frequently-used characters.
> 
> If you encounter this issue and have access to a font that does support the characters in the text, you may be able to work around the issue if the application provides a way for you to indicate that the text should be displayed with that font. In apps that support text editing, there will usually be a way to select the font used to display the text. In some cases, the app might not accept the font you select; if that happens, contact the app vendor for help.
> 
> In apps that are not text editors, getting your custom font used might require tailoring of font fallback logic used by the app. That is not a commonly-available feature. Contact the vendor to see if that is possible, or to report the gap in font support in their app.
> 
> If this issue occurs with Web content, it is likely that the content author has assumed that an appropriate font can be supplied by the browser or by the host OS the browser is running on. A better approach is for the content to use CSS Web fonts to control what fonts are used to display the content. Contact the content author to suggest that option.

* [Where is "tofu" for "font fallback box glyph" coming from?](https://english.stackexchange.com/questions/296505/where-is-tofu-for-font-fallback-box-glyph-coming-from)
> **Tofu:**
> * Slang for the empty boxes shown in place of undisplayable code points in computer character encoding, a form of mojibake
> 
> **Mojibake** (文字化け?) (IPA: [mod͡ʑibake]; lit. "character transformation"):
> * from the Japanese 文字 (moji) "character" + 化け (bake, pronounced "bah-keh") "transform", is the garbled text that is the result of text being decoded using an unintended character encoding. The result is a systematic replacement of symbols with completely unrelated ones, often from a different writing system.
> 
> (Wikipedia)
> 
> Commented on Jun 8, 2016: "Tofu" (display of a .notdef glyph or equivalent) is *distinct* from "mojibake" (display of a completely inappropriate glyph). - user7318 
> 
> [Comment by Matthew Christian on Oct 10, 2016](https://english.stackexchange.com/questions/296505/where-is-tofu-for-font-fallback-box-glyph-coming-from/352613#352613):
> Displaying the hex codes of a glyphless character in a bordered or borderless rectangular space long predates the use of the slang "tofu". The technique originated in late 1990 with the OS/2 1-2-3/G team at Lotus Development Corporation while internationalizing the product for Japan. At that time it was referred to as "hexagana".

* [What do you call the phenomenon where a rectangle □ is shown because a font lacks a glyph?](https://english.stackexchange.com/questions/62524/what-do-you-call-the-phenomenon-where-a-rectangle-is-shown-because-a-font-lack)

* [Replacement glyph - The Unicode standard](http://unicode.org/glossary/#replacement_glyph)

* [Antisquare - Dynamically find the right font to avoid missing glyphs (aka glyphlessness, replacement glyph, missing glyph squares, tofu, tofubake, トーフ, トーフ化け, 豆腐化け, 文字化け) ](https://github.com/nicolas-raoul/Antisquare)

* [Why sometimes `&nbsp;` displays as a square? - Stack Overflow](https://stackoverflow.com/questions/31208925/why-sometimes-nbsp-displays-as-a-square)

* [Only squares instead of letters and numbers are displayed in my calculator and other apps in Ubuntu 18.04](https://askubuntu.com/questions/1103560/only-squares-instead-of-letters-and-numbers-are-displayed-in-my-calculator-and-o)

* [Fonts that display foreign characters as square boxes (reddit - self.typography)](https://old.reddit.com/r/typography/comments/94ptsn/fonts_that_display_foreign_characters_as_square/)
> Different fonts support different numbers of additional Unicode, so you can't really tell unless it's mentioned in the dev notes.
> There are a few good fonts that support many Unicode- in fact Google Noto was designed for this.
> "Noto" stands for No Tofu, which is the name for the little squares you mentioned.

* [Manual: Spaces - type.today](https://type.today/en/journal/spaces)
> Whitespace is the most invisible and, arguably, the most important of typographic elements.
> There are no less than ten whitespace characters in Latin and Cyrillic typography - and here's what they are, when to use them, and how to find them.

* [See the Unicode code point of the current character - Vi and Vim StackExchange](https://vi.stackexchange.com/questions/555/see-the-unicode-code-point-of-the-current-character/560#560)

```
Another way is to use ga or the :ascii command. From :help ga:

:as[cii]        or                                      ga :as :ascii
ga                      Print the ascii value of the character under the
                        cursor in decimal, hexadecimal and octal
```

* [Showing single space invisible character in vim](https://stackoverflow.com/questions/12814647/showing-single-space-invisible-character-in-vim)
> However, one should note that nbsp stands for non-breakable space (character **0xA0**).
> It's different from ordinary whitespaces (character **0x20**) and in most cases, we'll have to do `Ctrl-v x a 0` in *insert mode* to type it.

* [Non-breaking space -- Wikipedia](https://en.wikipedia.org/wiki/Non-breaking_space)
> In word processing and digital typesetting, a **non-breaking space**, also called **NBSP**, **required space**, **no-break space**, **non-breakable space**, **hard space**, or **fixed space** (in most typefaces, it is not of fixed width) is a *space* character that prevents an automatic line break at its position.
> In some formats, including HTML, it also prevents consecutive whitespace characters from collapsing into a single space.
> Non-breaking space characters with other widths also exist.  
>
> In HTML, the common non-breaking space, which is the same width as the ordinary space character, is encoded as `&nbsp;` or `&#160;`.
> In **Unicode**, it is encoded as **U+00A0**.

* [U+000A0 -- decodeunicode.org](https://decodeunicode.org/en/u+000A0)

* [No-Break Space (nbsp) -- Unicode Number U+00A0 -- SYMBL](https://symbl.cc/en/00A0/)
> **Symbol Meaning**
> 
> No-Break Space. Latin-1 Supplement.   
> 
> The symbol "No-Break Space" is included in the "Latin-1 punctuation and symbols" subblock of the "Latin-1 Supplement" block and was approved as part of Unicode version 1.1 in 1993.
> 
> Synonyms: nbsp
>
> **Technical Information**
> ```
> Unicode Name: No-Break Space
> Unicode Number: U+00A0 
> HTML Code: &#160; 
> CSS Code: \00A0 
> Entity &nbsp;
> Plane: 0: Basic Multilingual Plane
> Unicode Block: Latin-1 Supplement
> Unicode Subblock: Latin-1 punctuation and symbols
> Unicode Version: 1.1 (1993)
> Alt Code: Alt 255(English Keyboard Layout)
> ```
> 
> **Properties**
> ```
> Type of paired mirror bracket (bidi): None
> Composition Exclusion:                No
> Case change:                          00A0
> Simple case change:                   00A0
> Grapheme_Base:                        +
> Scripts:                              Common
> White_Space                           +
> ```
>
> **Encoding**
>
> ``` 
> Encoding  hex          dec (bytes)  dec         binary
> UTF-8     C2 A0        194 160      49824       11000010 10100000
> UTF-16BE  00 A0        0 160        160         00000000 10100000
> UTF-16LE  A0 00        160 0        40960       10100000 00000000
> UTF-32BE  00 00 00 A0  0 0 0 160    160         00000000 00000000 00000000 10100000
> UTF-32LE  A0 00 00 00  160 0 0 0    2684354560  10100000 00000000 00000000 00000000
> ``` 

* [Unicode Character 'NO-BREAK SPACE' (U+00A0) - FileFormat.Info - The Digital Rosetta Stone](https://www.fileformat.info/info/unicode/char/00a0/index.htm)

* [How to Convert Text to Unicode Codepoints](http://rishida.net/tools/conversion)

* [uni - Query the Unicode database from the commandline, with good support for emojis](https://github.com/arp242/uni/) -- How to install and use `uni` on FreeBSD 14. [<sup>[3](#footnotes)</sup>]

* [ftfy: fixes text for you](https://ftfy.readthedocs.io/) -- How to install `ftfy` on FreeBSD 14. [<sup>[4](#footnotes)</sup>]

* [Online Unicode Tools - by Browserling -- A collection of useful tools for working with Unicode](https://onlinetools.com/unicode)

* [Non-Breaking Spaces and UTF-8 Madness](https://www.bigmessowires.com/2021/10/14/non-breaking-spaces-and-utf-8-madness/)

* [When A Space Is Not A Space](https://www.bigmessowires.com/2021/06/01/when-a-space-is-not-a-space/)

* [Beware of the Unicode no-break space (0xC2 0xA0) -- Hacker News](https://news.ycombinator.com/item?id=27896856)

* [A Convenient Caboodle of Unicode Characters](https://somethingstrange.com/posts/a-convenient-caboodle-of-unicode-characters/)

* [U+00A0: NO-BREAK SPACE -- Charbase: A visual unicode database](https://charbase.com/00a0-unicode-no-break-space)

* [Why does vim/neovim show the zero width space as <200b>?](https://vi.stackexchange.com/questions/40272/why-does-vim-neovim-show-the-zero-width-space-as-200b)

* [List of Unicode characters](https://en.wikipedia.org/wiki/List_of_Unicode_characters)

* [non-breaking utf-8 0xc2a0 space and preg_replace strange behaviour](https://stackoverflow.com/questions/12837682/non-breaking-utf-8-0xc2a0-space-and-preg-replace-strange-behaviour)

* [Why some UTF-8 characters fall into some weird squares with four digits?](https://stackoverflow.com/questions/40336464/why-some-utf-8-characters-falls-into-some-weird-squares-with-four-digits)

```
It means your font doesn't have a symbol for U+80FD or U+591F (etc), so the square is a fallback that allows you to determine what the Unicode symbol was, even though the glyph cannot be displayed accurately.
```

* [Why are squares instead of whitespaces appearing in my HTML?](https://stackoverflow.com/questions/4682310/why-are-squares-instead-of-whitespaces-appearing-in-my-html)

```
It appears to be coming from your CSS font setting in body. If you inspect the element in Chrome and disable the style the issue goes away.

body {
   font-family: LiberationSansRegular;
}
```

* [Square symbols appearing instead of spaces - Stack Overflow](https://stackoverflow.com/questions/42257374/square-symbols-appearing-instead-of-spaces)

* [unicode - What does it mean when my text is displayed as boxes? - Stack Overflow](https://stackoverflow.com/questions/217228/what-does-it-mean-when-my-text-is-displayed-as-boxes)

```
Usually, that means that the Unicode character specified isn't available in that particular font. Try changing fonts to one of the multinational ones, it should go away.
```

* [What does it mean when my text is displayed as Question Marks?](https://stackoverflow.com/questions/217237/what-does-it-mean-when-my-text-is-displayed-as-question-marks)

* [Why do some characters show as squares in Chrome? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/36291/why-do-some-characters-show-as-squares-in-chrome)

* [squares instead of spaces and special characters](https://answers.microsoft.com/en-us/msoffice/forum/all/squares-instead-of-spaces-and-special-characters/50059571-9781-4e7b-b179-2070dd1c6595)

* [How can I best display a blank space character?](https://ux.stackexchange.com/questions/91255/how-can-i-best-display-a-blank-space-character)

* [What character can I use to represent the space bar?](https://ux.stackexchange.com/questions/55220/what-character-can-i-use-to-represent-the-space-bar)

* [Unicode spaces](https://www.jkorpela.fi/chars/spaces.html)

* [UTF-8 Tool -- Unicode character for Hex code point 00A0](https://www.cogsci.ed.ac.uk/~richard/utf-8.cgi?input=00A0&mode=hex)

* [Text inside files has squares with numbers in it](https://askubuntu.com/questions/47328/text-inside-files-has-squares-with-numbers-in-it)

* [How to fix these weird squares or missing unicode in arch linux?](https://old.reddit.com/r/linuxmasterrace/comments/10pxwv0/how_to_fix_these_weird_squares_or_missing_unicode/)

* [Program to check/look up UTF-8/Unicode characters in string on command line? - Super User](https://superuser.com/questions/581523/program-to-check-look-up-utf-8-unicode-characters-in-string-on-command-line)

* [How to fix UTF encoding for whitespaces?](https://stackoverflow.com/questions/13992934/how-to-fix-utf-encoding-for-whitespaces)

* [Safely removing Unicode zero-width spaces and other non-printing characters](https://www.perlmonks.org/?node_id=11109644)

* [Unicode Visualizer](https://unicode.link/)

----

## Footnotes

[1] From `:help ascii` or `:help ga` in `vim(1)`:

```
:as[cii]        or                                      *ga* *:as* *:ascii*
ga                      Print the ascii value of the character under the
                        cursor in decimal, hexadecimal and octal.
                        Mnemonic: Get Ascii value.

                        For example, when the cursor is on a 'R':
                                <R>  82,  Hex 52,  Octal 122  
                        When the character is a non-standard ASCII character,
                        but printable according to the 'isprint' option, the
                        non-printable version is also given.

                        When the character is larger than 127, the <M-x> form
                        is also printed.  For example:
                                <~A>  <M-^A>  129,  Hex 81,  Octal 201  
                                <p>  <|~>  <M-~>  254,  Hex fe,  Octal 376  
                        (where <p> is a special character)

                        The <Nul> character in a file is stored internally as
                        <NL>, but it will be shown as:
                                <^@>  0,  Hex 00,  Octal 000  

                        If the character has composing characters these are
                        also shown.  The value of 'maxcombine' doesn't matter.

                        If the character can be inserted as a digraph, also
                        output the two characters that can be used to create
                        the character:
                            <ö> 246, Hex 00f6, Oct 366, Digr o:
                        This shows you can type CTRL-K o : to insert ö.
```

[2] About `xkbcli-how-to-type(1)` on FreeBSD 14:

```
% command -v xkbcli-how-to-type
 
% type xkbcli-how-to-type
xkbcli-how-to-type: not found
 
% which xkbcli-how-to-type
xkbcli-how-to-type: Command not found.
 
% whereis xkbcli-how-to-type
xkbcli-how-to-type: /usr/local/share/man/man1/xkbcli-how-to-type.1.gz
 
% locate xkbcli-how-to-type
/usr/local/libexec/xkbcommon/xkbcli-how-to-type
/usr/local/share/man/man1/xkbcli-how-to-type.1.gz
```

[3] How to install and use `uni` on FreeBSD 14

```
% pkg search --regex ^uni-
uni-2.7.0_2                    Query the Unicode database from the commandline

% sudo pkg install uni
```

```
% uni search nbsp
             Dec    UTF8       HTML      Name
'␣'  U+FEFF  65279  ef bb bf   &#xfeff;  ZERO WIDTH NO-BREAK SPACE [BYTE ORDER MARK, BOM, ZWNBSP]

% uni search space | wc -l
      93

% uni search space | grep -i break | wc -l
       3

% uni search space | grep -i break
' '  U+00A0  160    c2 a0      &nbsp;    NO-BREAK SPACE
' '  U+202F  8239   e2 80 af   &#x202f;  NARROW NO-BREAK SPACE
'␣'  U+FEFF  65279  ef bb bf   &#xfeff;  ZERO WIDTH NO-BREAK SPACE [BYTE ORDER MARK, BOM, ZWNBSP]

% uni search "NO-BREAK SPACE"
             Dec    UTF8       HTML      Name
' '  U+00A0  160    c2 a0      &nbsp;    NO-BREAK SPACE
' '  U+202F  8239   e2 80 af   &#x202f;  NARROW NO-BREAK SPACE
'␣'  U+FEFF  65279  ef bb bf   &#xfeff;  ZERO WIDTH NO-BREAK SPACE [BYTE ORDER MARK, BOM, ZWNBSP]
```

```
% uni print 0x00a0
             Dec    UTF8        HTML       Name
' '  U+00A0  160    c2 a0       &nbsp;     NO-BREAK SPACE
```


[4] How to install `ftfy` on FreeBSD 14

```
$ pkg search ftfy
py311-ftfy-6.2.0               Fix some problems with Unicode text after the fact

$ sudo pkg install py311-ftfy

$ pkg query %Fp py311-ftfy
/usr/local/bin/ftfy
/usr/local/bin/ftfy-3.11
[ . . . ]
```

----

