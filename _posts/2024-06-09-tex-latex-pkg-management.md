---
layout: post
title: "TeX and LaTeX Package Management [WIP]"
date: 2024-06-09 20:15:14 -0700 
categories: tex latex
---

OS: FreeBSD 14      
Shell: csh

----

## Package Managers with TeX distributions

TeX Live:  TeX Live Manager (```tlmgr``` or ```tlshell```)    
MiKTeX:    MiKTeX package manager (```mpm```)    
MacTeX:    TeX Live Utility   

The **tlmgr** program is the successor of the ```texconfig(1)``` tool.
From the man page for *texconfig(1)*:

```
texconfig(1)                TeX Live                texconfig(1)
NAME
    texconfig - configures teTeX or TeX Live

    texconfig-sys - configures teTeX or TeX Live system-wide
DESCRIPTION
    texconfig allows one to configure and maintain TeX in an easy and
    convenient manner, offering a series of dialog boxes to the user.  The
    directory in which texconfig is found is also preferentially used to
    find subprograms.

    The tlmgr program has subsumed this function for TeX Live.  This
    program is still supported, but the tlmgr interface is much more
    actively developed and tested.
```


To list all packages
(a.k.a. to list all installed TeX/LaTeX packages, a.k.a. to list all availabled packages for installation): 

```
$ tlmgr info
```

With no argument, ```tlmgr info``` lists all packages available at the package repository, prefixing those already installed with "**i**".

To get more information about ```tlmgr info```:

```
$ tlmgr info --help
```

```
$ tlmgr info | wc -l
    7658

$ tlmgr info | grep -i palatino
i domitian: Drop-in replacement for Palatino
i mathpazo: Fonts to typeset mathematics to match Palatino
i palatino: URW 'Base 35' font pack for LaTeX
i pxfonts: Palatino-like fonts in support of mathematics
```


## Show General Configuration Information for TeX Live

Show general configuration information for TeX Live, including active configuration files, path settings, and more.
This is like running ```texconfig conf``` but works on all supported platforms.

The ```tlmgr conf``` gives all *kpathsea* variables.
It might feel that's better than using one ```kpathsea``` command (to get one variable) at a time.

<!---
https://talk.jekyllrb.com/t/code-block-is-improperly-handled-and-generates-liquid-syntax-error/7599/2

With Jekyll, Markdown files are fist processed by Liquid, and then Markdown, so Liquid syntax is interpreted, even within Markdown code-blocks.

To avoid the problem, the raw tag can be used to disable Liquid processing 161.

https://shopify.github.io/liquid/tags/template/#raw

raw
Temporarily disables tag processing. This is useful for generating certain content that uses conflicting syntax, such as Mustache or Handlebars.
-->

{% raw %}

```
$ tlmgr conf
=========================== version information ==========================
tlmgr revision 66457 (2023-03-08 00:07:12 +0100)
tlmgr using installation: /usr/local/share/tlpkg
==================== executables found by searching PATH =================
PATH: /usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/home/dusko/bin:/home/dusko/.local/bin
dvipdfmx:  /usr/local/bin/dvipdfmx
dvips:     /usr/local/bin/dvips
fmtutil:   /usr/local/bin/fmtutil
kpsewhich: /usr/local/bin/kpsewhich
luatex:    /usr/local/bin/luatex
mktexpk:   /usr/local/bin/mktexpk
pdftex:    /usr/local/bin/pdftex
tex:       /usr/local/bin/tex
tlmgr:     /usr/local/bin/tlmgr
updmap:    /usr/local/bin/updmap
xetex:     /usr/local/bin/xetex
=========================== active config files ==========================
config.ps:        /usr/local/share/texmf-dist/dvips/config/config.ps
fmtutil.cnf:      /usr/local/share/texmf-config/web2c/fmtutil.cnf
mktex.cnf:        /usr/local/share/texmf-dist/web2c/mktex.cnf
pdftexconfig.tex: /usr/local/share/texmf-dist/tex/generic/tex-ini-files/pdftexconfig.tex
texmf.cnf:        /var/db/tlpkg/texmf.cnf
texmf.cnf:        /usr/local/share/texmf-dist/web2c/texmf.cnf
============================= font map files =============================
Missing argument in sprintf at /usr/local/bin/tlmgr line 6507.
kanjix.map:  pdftex.map:  /usr/local/share/texmf-dist/fonts/map/pdftex/updmap/pdftex.map
ps2pk.map:   /usr/local/share/texmf-dist/fonts/map/dvips/updmap/ps2pk.map
psfonts.map: /usr/local/share/texmf-dist/fonts/map/dvips/updmap/psfonts.map
=========================== kpathsea variables ===========================
ENCFONTS=.:{{}/home/dusko/.texlive2023/texmf-config,/home/dusko/.texlive2023/texmf-var,/home/dusko/texmf,!!/usr/local/share/texmf-local,!!/usr/local/share/texmf-config,!!/usr/local/share/texmf-var,!!/usr/local/share/texmf-dist}/fonts/enc//
SYSTEXMF=/usr/local/share/texmf-var:/usr/local/share/texmf-local:/usr/local/share/texmf-dist
TEXCONFIG={{}/home/dusko/.texlive2023/texmf-config,/home/dusko/.texlive2023/texmf-var,/home/dusko/texmf,!!/usr/local/share/texmf-local,!!/usr/local/share/texmf-config,!!/usr/local/share/texmf-var,!!/usr/local/share/texmf-dist}/dvips//
TEXFONTMAPS=.:{{}/home/dusko/.texlive2023/texmf-config,/home/dusko/.texlive2023/texmf-var,/home/dusko/texmf,!!/usr/local/share/texmf-local,!!/usr/local/share/texmf-config,!!/usr/local/share/texmf-var,!!/usr/local/share/texmf-dist}/fonts/map/{kpsewhich,pdftex,dvips,}//
TEXMF={{}/home/dusko/.texlive2023/texmf-config,/home/dusko/.texlive2023/texmf-var,/home/dusko/texmf,!!/usr/local/share/texmf-local,!!/usr/local/share/texmf-config,!!/usr/local/share/texmf-var,!!/usr/local/share/texmf-dist}
TEXMFCONFIG=/home/dusko/.texlive2023/texmf-config
TEXMFDBS={!!/usr/local/share/texmf-local,!!/usr/local/share/texmf-config,!!/usr/local/share/texmf-var,!!/usr/local/share/texmf-dist}
TEXMFDIST=/usr/local/share/texmf-dist
TEXMFHOME=/home/dusko/texmf
TEXMFLOCAL=/usr/local/share/texmf-local
TEXMFMAIN=/usr/local/share/texmf-dist
TEXMFSYSCONFIG=/usr/local/share/texmf-config
TEXMFSYSVAR=/usr/local/share/texmf-var
TEXMFVAR=/home/dusko/.texlive2023/texmf-var
TEXPSHEADERS=.:{{}/home/dusko/.texlive2023/texmf-config,/home/dusko/.texlive2023/texmf-var,/home/dusko/texmf,!!/usr/local/share/texmf-local,!!/usr/local/share/texmf-config,!!/usr/local/share/texmf-var,!!/usr/local/share/texmf-dist}/{dvips,fonts/{enc,type1,type42,type3}}//
VARTEXFONTS=/home/dusko/.texlive2023/texmf-var/fonts
WEB2C={{}/home/dusko/.texlive2023/texmf-config,/home/dusko/.texlive2023/texmf-var,/home/dusko/texmf,!!/usr/local/share/texmf-local,!!/usr/local/share/texmf-config,!!/usr/local/share/texmf-var,!!/usr/local/share/texmf-dist}/web2c
==== kpathsea variables from environment only (ok if no output here) ====
```

{% endraw %}


### Checking Package Status

For example, to check status of the package *tikz*:

```
$ kpsewhich tikz
```

Output:

```
/usr/local/share/texmf-dist/tex/plain/pgf/frontendlayer/tikz.tex
```

For more details on a specific package, use the tlmgr tool (TeX Live only):

```
$ tlmgr info <package_name>
```

For example:

```
$ tlmgr info palatino
package:     palatino
category:    Package
shortdesc:   URW 'Base 35' font pack for LaTeX
longdesc:    A set of fonts for use as "drop-in" replacements for Adobe's basic
set, comprising: Century Schoolbook (substituting for Adobe's New Century School
book); Dingbats (substituting for Adobe's Zapf Dingbats); Nimbus Mono L (substit
uting for Abobe's Courier); Nimbus Roman No9 L (substituting for Adobe's Times);
 Nimbus Sans L (substituting for Adobe's Helvetica); Standard Symbols L (substit
uting for Adobe's Symbol); URW Bookman; URW Chancery L Medium Italic (substituti
ng for Adobe's Zapf Chancery); URW Gothic L Book (substituting for Adobe's Avant
 Garde); and URW Palladio L (substituting for Adobe's Palatino).
installed:   Yes
revision:    61719
sizes:       run: 1553k
relocatable: Yes
cat-license: gpl
cat-topics:  font font-type1 font-collection
cat-related: tex-gyre
collection:  collection-fontsrecommended
```


```
$ kpsewhich --help
Usage: kpsewhich [OPTION]... [FILENAME]...

Standalone path lookup and expansion for the Kpathsea library.
The default is to look up each FILENAME in turn and report its
first match (if any) to standard output.

When looking up format (.fmt/.base/.mem) files, it is usually necessary
to also use -engine, or nothing will be returned; in particular,
-engine=/ will return matching format files for any engine.

-all                   output all matches, one per line (no effect with pk/gf).
[-no]-casefold-search  fall back to case-insensitive search if no exact match.
-cnf-line=STRING       parse STRING as a configuration file line.
-debug=NUM             set debugging flags.
-D, -dpi=NUM           use a base resolution of NUM; default 600.
-engine=STRING         set engine name to STRING.
-expand-braces=STRING  output variable and brace expansion of STRING.
-expand-path=STRING    output complete path expansion of STRING.
-expand-var=STRING     output variable expansion of STRING.
-format=NAME           use file type NAME (list shown by -help-formats).
-help                  display this message and exit.
-help-formats          display information about all supported file formats.
-interactive           ask for additional filenames to look up.
[-no]-mktex=FMT        disable/enable mktexFMT generation (FMT=pk/mf/tex/tfm).
-mode=STRING           set device name for $MAKETEX_MODE to STRING; no default.
-must-exist            search the disk as well as ls-R if necessary.
-path=STRING           search in the path STRING.
-progname=STRING       set program name to STRING.
-safe-in-name=STRING   check if STRING is ok to open for input.
-safe-out-name=STRING  check if STRING is ok to open for output.
-show-path=TYPE        output search path for file type TYPE
                         (list shown by -help-formats).
-subdir=STRING         only output matches whose directory ends with STRING.
-var-brace-value=STRING output brace-expanded value of variable $STRING.
-var-value=STRING       output variable-expanded value of variable $STRING.
-version               display version information number and exit.
 
Email bug reports to tex-k@tug.org.
Kpathsea home page: https://tug.org/kpathsea/
```

As per
[installing - How to have local package override default package - TeX - LaTeX Stack Exchange](https://tex.stackexchange.com/questions/8357/how-to-have-local-package-override-default-package):

> By Alan Munn  Jan 6, 2011 at 16:39
> @Seamus: No, you do *not* need to run ```texhash``` for user additions ever.
> And you certainly wouldn't need to run it with ```sudo```.
> If that were true, the whole idea of user additions would be invalid, since it would prevent non-administrator accounts from ever managing their own local packages.
>
> By user2478  Jan 6, 2011 at 17:12
> TeX uses three variables for the directories: ```$TEXMF```, ```$TEXMFLOCAL``` and ```$TEXMFHOME```.
> For the first two, a directory list file ```ls -R``` is needed, which is created by ```mktexlsr``` or ```texhash```.
> The user directory dosn't use such a file.
> The *search order* for files is: *document dir* - ```TEXMFHOME``` - ```TEXMFLOCAL``` - ```TEXMF```.
> For MiKTeX you have other directories.
> And everything is predefined in ```texmf.cnf```.

```
$ tlmgr conf
---- snip ----
texmf.cnf:        /var/db/tlpkg/texmf.cnf
texmf.cnf:        /usr/local/share/texmf-dist/web2c/texmf.cnf
---- snip ----
```

These two files are the same:

```
$ diff /var/db/tlpkg/texmf.cnf /usr/local/share/texmf-dist/web2c/texmf.cnf
```


## Working with the Package Documentation

The LaTeX and its package installations contain documentation.

You can access it by using the ```texdoc```

```
$ texdoc <package_name>
```

For example:

```
$ texdoc palatino
```

On my system, LibreOffice opened */usr/local/share/texmf-dist/doc/latex/psnfss/psnfss2e.pdf* file.

----

## Filename Lookup

*kpathsea* - Its fundamental purpose is filename lookup.   
*kpathsea* is the manager of searches and file generation.   
*kpathsea* = Karl [Berry]'s Path Search    

[Karl Berry and Olaf Weber. kpathsea library, version 3.5.4, 2005](https://www.tug.org/teTeX/tetex-texmfdist/doc/programs/kpathsea.pdf)

This system is said to speed up searches for files done by all of the tools of the TeX world and to generate files on demand.
To generate files, **kpathsea** has three utilities at its disposal:

* ```mktextfm```, which generates a missing TFM file.
This utility is called by TeX when they cannot find a TFM file for a font used in the document.
* ```mktexmf```, which generates the METAFONT source file corresponding to the METAFONT used in the document if this font does not already exist.
* ```mktexpk```, which generates a bitmap font from the corresponding METAFONT source files.


As per [Finding and configuring my texmf tree - TeX - LaTeX Stack Exchange](https://tex.stackexchange.com/questions/449769/finding-and-configuring-my-texmf-tree)
> **Local additions** should **not** be put into the system texmf directory, i.e., ```/usr/local/share/texmf``` but instead should be put into your **home texmf** folder.
> This folder is not created automatically so you need to create it yourself.  

The location of your local *texmf* can be found by using the command:

```
$ kpsewhich -var-value TEXMFHOME
/home/dusko/texmf
```

On a Linux system, this will typically be ```~/texmf``` (```/home/<username>/texmf```).
You can create the folder yourself but it must conform to the **TeX Directory Structure** (**TDS**).


On FreeBSD 14.0:

```
$ ls -h /usr/local/bin/kps*
/usr/local/bin/kpseaccess       /usr/local/bin/kpsetool
/usr/local/bin/kpsepath         /usr/local/bin/kpsewhere
/usr/local/bin/kpsereadlink     /usr/local/bin/kpsewhich
/usr/local/bin/kpsestat         /usr/local/bin/kpsexpand
```

```
$ ls -h /usr/local/bin/tex*
/usr/local/bin/tex              /usr/local/bin/texhash
/usr/local/bin/tex2aspc         /usr/local/bin/texlinks
/usr/local/bin/tex2lyx          /usr/local/bin/texliveonfly
/usr/local/bin/tex4ebook        /usr/local/bin/texloganalyser
/usr/local/bin/tex4ht           /usr/local/bin/texlogfilter
/usr/local/bin/texaccents       /usr/local/bin/texlogsieve
/usr/local/bin/texconfig        /usr/local/bin/texlua
/usr/local/bin/texconfig-dialog /usr/local/bin/texluac
/usr/local/bin/texconfig-sys    /usr/local/bin/texluajit
/usr/local/bin/texcount         /usr/local/bin/texluajitc
/usr/local/bin/texdef           /usr/local/bin/texosquery
/usr/local/bin/texdiff          /usr/local/bin/texosquery-jre5
/usr/local/bin/texdirflatten    /usr/local/bin/texosquery-jre8
/usr/local/bin/texdoc           /usr/local/bin/texplate
/usr/local/bin/texdoctk         /usr/local/bin/text2pcap
/usr/local/bin/texfot           /usr/local/bin/textestvis
```


```
$ ls -h /usr/local/bin/latex*
/usr/local/bin/latex            /usr/local/bin/latexdiff-vc
/usr/local/bin/latex-git-log    /usr/local/bin/latexfileversion
/usr/local/bin/latex-papersize  /usr/local/bin/latexindent
/usr/local/bin/latex2man        /usr/local/bin/latexmk
/usr/local/bin/latex2nemeth     /usr/local/bin/latexpand
/usr/local/bin/latexdef         /usr/local/bin/latexrevise
/usr/local/bin/latexdiff
 
$ ls -h /usr/local/bin/lua*
/usr/local/bin/lua52            /usr/local/bin/luahbtex
/usr/local/bin/lua53            /usr/local/bin/luajittex
/usr/local/bin/lua54            /usr/local/bin/lualatex
/usr/local/bin/luac52           /usr/local/bin/lualollipop
/usr/local/bin/luac53           /usr/local/bin/luaotfload-tool
/usr/local/bin/luac54           /usr/local/bin/luatex
/usr/local/bin/luafindfont
```

----

## Installing Packages Manually

(aka Installing a package that doesn't come by default with LaTeX)  
(aka Installing a new style file that doesn't come by default with LaTeX)  
(aka How to have local package override default package)   
(aka When should I put things in the local texmf directory (folder)?)   
(aka Finding and configuring your texmf tree)   

From
[make-local-texmf -- Mac script to make a local texmf folder](https://github.com/amunn/make-local-texmf):
> Every TeX distribution expects to find personal additions (such as private style files or packages not part of the main distribution) in a local directory.
> The name of this directory is 'texmf' and it has a specific structure of sub-directories so that the TeX programs can find files correctly.
>
> Q: When should I put things in the local texmf folder?    
> A: Before putting anything into the local texmf folder, you should check that the relevant package isn't already part of TeXLive, and therefore included in the MacTeX distribution.
> The easiest way to do this is to use the TeXLive utility.
> This is especially true of packages on CTAN, most of which are included in TeXLive, and should already be available to you.
> 
> If you know that a package is not available as part of TeXLive, then you should put it into your local texmf folder.
>
> Q: What goes where?   
> A: The texmf folder contains a number of folders, and these folders themselves contain other folders.
>
> Also, the local texmf needs to follow the TeX Directory Structure (**TDS**); (you don't need to create all of these directories initially but you do need to put things in the right places when you add new stuff):
>
> ```
> *  bibtex directory    This is where bib files and bst files go
>    -  bst directory       Put bst files here
>    -  bib directory       Put bib files here
> *  tex directory       This is where new packages go
>    -  latex directory     Put latex packages here
>    -  plain directory     Put plain tex files here
>    -  xelatex directory   Put xelatex specific packages here
>    -  xetex  directory    Put plain xetex files here
>    -  context directory   Put context files here
>    -  generic directory   Put files that are usable with any TeX flavour here
> * doc directory
>   - put documentation files from packages installed in the tex directory here
> ```
>
> For example, you have the new package cool-new-package.
> If it's a LaTeX package, the package will come with (at least) a *.sty* file, and some documentation files (often a *.tex* and *.pdf* version).
> You would create a directory in ```~/texmf/tex/latex``` called cool-new-package and then put *cool-new-package.sty* there.
> You would also create a cool-new-package directory in ```~/texmf/doc``` and put the documentation files there.


From
[Finding and configuring my texmf tree - TeX - LaTeX Stack Exchange](https://tex.stackexchange.com/questions/449769/finding-and-configuring-my-texmf-tree):
> By David Carlisle - Sep 6, 2018 at 22:05    
> When you install the "system" TeX/LaTeX via sudo, the default TeX tree is not writable under a normal account but the default search path includes TEXMFHOME set to a texmf tree in your home directory (which does not need to exist) so if you make it and put just your updated files in there, then all standard files will be found in the existing system location but it will look in ~/texmf first and find any updated files there.
>
> By Alan Munn - Sep 6, 2018 at 22:05    
> You don't need to make all of the structure, just the stuff you need.
> So minimally you will probably need ```~/texmf/tex/latex``` for LaTeX packages and if you want documentation for a package to be found by texdoc it should be in ```~/texmf/doc```.
> 
> By Alan Munn - Sep 6, 2018 at 22:23   
> Local additions should not be put into the system ```texmf``` directory, i.e. ```/usr/local/share/texmf```,  but instead should be put into your home ```texmf``` directory.
> This directory is not created automatically so you need to create it yourself.

In other words, in a brand new installation, a local texmf directory is not created and you will need to create one if one doesn't exist.
It should be found first when LaTeX searches for packages.

----

## latexmk

To get usage information for latexmk:

```
$ latexmk -help
```

To compile a document and create a PDF from it:

```
$ latexmk -pdf file_name.tex
```

To compile a document with *lualatex*.
(a.k.a. Use *lualatex* for processing files to PDF.):

```
$ latexmk -lualatex file_name.tex
```

----


