---
layout: post
title: "Encodings, UTF-8 and Unicode Notes [DRAFT]"
date: 2024-08-12 14:23:13 -0700 
categories:  unicode utf8 x11 xorg xterm cli terminal shell howto sysadmin
             unix typography font html
---

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


## Conversions (Converting)

### Converting from Unicode/UTF to ISO:

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

* [uni.pl - Perl script from leahneukirchen (Leah Neukirchen) - List Unicode symbols matching pattern](https://leahneukirchen.org/dotfiles/bin/uni)


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


### Python

```
% python3 -c 'print(u"\u2620")' 
☠
```

```
% python3 -c 'print(u"\u2620")' | od -ac
0000000   e2  98  a0  nl                                                
           ☠  **  **  \n                                                
0000004
 
% python3 -c 'print(u"\u2620")' | od -ab
0000000   e2  98  a0  nl                                                
          342 230 240 012                                                
0000004
```

[Unicode HOWTO - Python Documentation](https://docs.python.org/3/howto/unicode.html)

```
% printf '\342\230\240'
☠% 
```

### `vim` 

```
vim: ga  # OR :as(cii)
```

----

## References
(Retrieved on Aug 12, 2024)

* [What is the difference between UTF-8 and Unicode?](https://web.archive.org/web/20150815071315/https://rrn.dk/the-difference-between-utf-8-and-unicode)
> **UTF-8 is an encoding - Unicode is a character set**.

* [Unicode Escape Formats](https://www.billposer.org/Software/ListOfRepresentations.html)

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

* [UTF-8 Sampler](https://kermitproject.org/utf8.html)

* [UTF-8 Tool](https://www.cogsci.ed.ac.uk/~richard/utf-8.html)

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

* [What are useful Perl one-liners for working with UTF-8? - UTF-8 and Unicode FAQ](https://www.cl.cam.ac.uk/~mgk25/unicode.html#perl)

* [Use of 'use utf8;' gives me 'Wide character in print'](https://stackoverflow.com/questions/15210532/use-of-use-utf8-gives-me-wide-character-in-print)

* [How to get rid of `Wide character in print at`?](https://stackoverflow.com/questions/47940662/how-to-get-rid-of-wide-character-in-print-at)

* [Perl Unicode Cookbook: The Standard Preamble](https://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html/)
> Apr 2, 2012 by Tom Christiansen
>
> Editor's note:
> Perl guru Tom Christiansen created and maintains a list of 44 recipes for working with Unicode in Perl 5.
> This is the first recipe in the series.

* [perlunicook - Cookbookish examples of handling Unicode in Perl](https://perldoc.perl.org/perlunicook)

* [Unicode HOWTO - Python Documentation](https://docs.python.org/3/howto/unicode.html)

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

* [utf8-validator: Reads and outputs an UTF-8 string by replacing invalid sequences and glyphs with the replacement glyph � (0xFFFD)](https://github.com/detomon/utf8-validator)

* [UTF-8 decoder capability and stress test](https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt)

* [Unicode programming, with examples](https://begriffs.com/posts/2019-05-23-unicode-icu.html)

* [Byte order mark (BOM) - Wikipedia](https://en.wikipedia.org/wiki/Byte_order_mark)

* [Endianness - Wikipedia](https://en.wikipedia.org/wiki/Endianness)
> In computing, endianness is the order in which bytes within a word of digital data are transmitted over a data communication medium or addressed (by rising addresses) in computer memory, counting only byte significance compared to earliness.
> Endianness is primarily expressed as big-endian (BE) or little-endian (LE), terms introduced by Danny Cohen into computer science for data ordering in an Internet Experiment Note published in 1980.

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
> For a description, consult chapter [6 Writing Systems and Punctuation](http://www.unicode.org/versions/latest/ch06.pdf) and block description [General Punctuation](http://www.unicode.org/charts/PDF/U2000.pdf) in the Unicode standard.
> This document also lists three characters that have no width and can thus be described as no-width spaces.
> 
> The third column of the following table shows the appearance of the space character, in the sense that the cell contains the words "foo" and "bar" in bordered boxes separated by that character.
> *It is possible that your browser does not present all the space characters properly*.
> This depends on the font used, on the browser, and on the fonts available in the system.

* [Unicode Character Recognition](https://shapecatcher.com/index.html)

* [SYMBL - Symbols, Emojis, Hieroglyphs, Scripts, Alphabets, and the entire Unicode](https://symbl.cc/)

* [The End-of-Line Story -- RFC Editor (2004)](https://www.rfc-editor.org/old/EOLstory.txt)

----

