---
layout: post
title: "TeX and LaTeX Quick Start"
date: 2024-06-01 20:09:43 -0700 
categories: tex latex pdf x11 xorg tutorial howto sysadmin technicalwriting 
            documentation writing plaintext text editor utf8 unicode
            unix 
---

OS: FreeBSD 14   
X Window Manager: FVWM  
DVI Viewer: xdvi (```$ sudo pkg install tex-xdvik```)   
PDF Viewers: zathura, mupdf (```$ sudo pkg install zathura zathura-pdf-poppler zathura-ps mupdf```)  	

# Hello World in TeX

```
$ cat helloworld.tex
% Hello World in plain \TeX
Hello, World!
\bye
```


Running TeX on this file (for example, by typing ```tex helloworld.tex```) creates an output file called *helloworld.dvi*, representing the content of the page in a **d**e**v**ice **i**ndependent format (**DVI**).
A DVI file could then be either viewed on screen or converted to a suitable format for printing.

```
$ tex helloworld.tex
```


If your system doesn't have a program for viewing .dvi files, you can install 
**xdvi** program (DVI Previewer for the X Window System):

```
$ pkg search xdvi
tex-xdvik-22.87.06_3           DVI Previewer(kpathsearch) for X
```
 
```
$ sudo pkg install tex-xdvik
```

```
$ xdvi helloworld.dvi
```


To change the colour of the background and the colour of the text (foreground):

```
$ xdvi -bg white -fg black helloworld.dvi
```

Alternatively, you can use **pdfTeX**, which is capable of generating typeset PDF output in place of DVI.
pdfTeX has other capabilities, most notably in the area of fine typographic detail (for example, its support for optimising line breaks), but its greatest impact to date has been in the area of PDF output. [<sup>[1](#footnotes)</sup>] [<sup>[2](#footnotes)</sup>]

NOTE:   
In FreeBSD, **pdftex** is installed by *tex-basic-engines* package. 

```
$ pdftex helloworld.tex
```

```
$ zathura helloworld.pdf
```


# Hello World in LaTeX

```
$ cat helloworld.tex
% Hello World! in LaTeX
\documentclass{minimal}
\begin{document}
  Hello, World!
\end{document}
```

```
$ pdflatex helloworld.tex
```

```
$ zathura helloworld.pdf
```


# What is TeX (also called Plain TeX)?

* Typesetting engine (typesetting system) [<sup>[3](#footnotes)</sup>]
* Typesetting language [<sup>[4](#footnotes)</sup>]
* Typesetting computer program [<sup>[5](#footnotes)</sup>]
* Plain TeX is the basic macro package [<sup>[6](#footnotes)</sup>]

----

# What is LaTeX? (Simplified) Answer: LaTeX = TeX + Macros

* A TeX macro package [<sup>[7](#footnotes)</sup>]
* A document processing system [<sup>[7](#footnotes)</sup>]
* A set of commands for interacting with the system at a higher level than the plain TeX [<sup>[8](#footnotes)</sup>]
* A macro system (built on top of TeX that aims to simplify its use and automate many common formatting tasks) [<sup>[9](#footnotes)</sup>]
* LaTeX uses the TeX formatter as its typesetting engine [<sup>[10](#footnotes)</sup>]

----

# The Levels of TeX 

From [LaTeX vs. MiKTeX: The levels of TeX - TUG (TeX User Group)](https://tug.org/levels.html): [<sup>[11](#footnotes)</sup>]

1. Distributions: MiKTeX, TeX Live, W32TeX, ... 
2. Front ends and editors: Emacs, vim, TeXworks, TeXShop, WinEdt, ...
3. Engines: TeX, pdfTeX, XeTeX, LuaTeX, ... 
4. Formats: LaTeX, plain TeX, OpTeX, ... 
5. Packages: geometry, lm, ... 

----

# The First LaTeX Document

Based on [first-latex-doc -- A document for absolute LaTeX beginners](https://www.ctan.org/pkg/first-latex-doc):

> The document leads a reader, who knows nothing about LaTeX, through the production of a two page document.
> 
> The user who has completed that first document, and wants to carry on, will find recommendations for tutorials. 

and

[first-latex-doc.pdf -- The PDF file of example first document with embedded explanation](http://mirrors.ctan.org/info/first-latex-doc/first-latex-doc.pdf)


See also:   
[A First Set of LaTeX Resources](https://www.ctan.org/tex-archive/info/latex-doc-ptr)

and 

[A Typical LaTeX Input File - From *Getting Started with LaTeX*, 2nd Edition, 1995 - David R. Wilkins](https://www.maths.tcd.ie/~dwilkins/LaTeXPrimer/TypicalInput.html)

----


# TeX/LaTeX Document Structure

Based on [LaTeX/Document Structure - Wikibooks](https://en.m.wikibooks.org/wiki/LaTeX/Document_Structure) and [Free edition of the book "TeX for the Impatient"](http://mirrors.ctan.org/info/impatient/book.pdf).

* Preamble
  * Document Classes
  * Packages
* Groups
* Environments
* The Document Environment
  * Top Matter (aka Front Matter)
  * Abstract
  * Sectioning (Sectioning Commands)
    * Section Numbering
    * Section Number Style
  * Ordinary Paragraphs
  * Table of Contents
    * Depth
* Book Structure
  * Page Order
* Special pages
  * Bibliography

----

## Preamble - aka The Setup (of the Document/Layout)

Every input file must contain the commands

```
\documentclass{...}

\begin{document}
...
\end{document}
```

The area between ```\documentclass{...}``` and ```\begin{document}``` is called the **preamble**.
It normally contains commands that affect the entire document.
Major or permanent modifications should go in a *.sty* file and be invoked with a ```\usepackage``` command. 

### Document Classes

When processing an input file, LaTeX needs to know which layout standard to use.
Layouts standards are contained within 'class files' which have *.cls* as their filename extension.

```
\documentclass[options]{class}
```

Here, the ```class``` parameter for the command ```\documentclass``` specifies the .cls file to use for the document.
It is recommended to put this declaration at the very beginning.
The LaTeX distribution provides additional classes for other layouts, including letters and slides.
It is also possible to create your own.

The ```options``` parameter customizes the behaviour of the document class.
The *options* have to be *separated by commas*.

Example: an input file for a LaTeX document could start with the line

```
\documentclass[11pt,twoside,a4paper]{article}
```

which instructs LaTeX to typeset the document as an article with a base font size of 11 points, and to produce a layout suitable for double sided printing on A4 paper. 

Here's [a comprehensive list of document classes](https://ctan.org/topic/class).


#### Code Snippets for Standard Classes

* [Article](https://texblog.org/code-snippets/standard-classes/#article)
* [Report](https://texblog.org/code-snippets/standard-classes/#report)
* [Book](https://texblog.org/code-snippets/standard-classes/#book)

----

### Packages 

While writing your document, you will probably find that there are some areas where basic LaTeX cannot solve your problem.
If you want to include graphics, coloured text or source code from a file into your document, you need to enhance the capabilities of LaTeX.
Such enhancements are called packages.
Some packages come with the LaTeX base distribution.
Others are provided separately. Modern TeX distributions come with a large number of packages pre-installed.
The command to use a package is pretty simple: ```\usepackage```:

The ```\usepackage``` command goes into the **preamble** of the document; that is, in the area between ```\documentclass{...}``` and ```\begin{document}```. 


```
\usepackage[options]{package}
```

You can pass *several options* to a package, each *separated by a comma*.

```
\usepackage[option1,option2,option3]{''package_name''}
```

#### Recommended Packages - References

From [The nag package warns you for incorrect LaTeX usage - howtotex.com -- Archived from the original on Aug 8, 2016](https://web.archive.org/web/20160808221527/http://www.howtotex.com/packages/the-nag-package-warns-you-for-incorrect-latex-usage/):

* [https://www.ctan.org/pkg/nag](https://www.ctan.org/pkg/nag)
* [https://www.ctan.org/pkg/l2tabu](https://www.ctan.org/pkg/l2tabu)

From [Nine essential LaTeX packages everyone should use - howtotex.com -- Archived from the original on Aug 15, 2016](https://web.archive.org/web/20160815072957/http://www.howtotex.com/packages/9-essential-latex-packages-everyone-should-use):

* [https://ctan.org/pkg/amsmath](https://ctan.org/pkg/amsmath)
* [https://ctan.org/pkg/geometry](https://ctan.org/pkg/geometry)
* [https://ctan.org/pkg/graphicx](https://ctan.org/pkg/graphicx)
* [https://ctan.org/pkg/nag](https://ctan.org/pkg/nag)
* [https://ctan.org/pkg/microtype](https://ctan.org/pkg/microtype)
* [https://ctan.org/pkg/siunitx](https://ctan.org/pkg/siunitx)
* [https://ctan.org/pkg/booktabs](https://ctan.org/pkg/booktabs)
* [https://ctan.org/pkg/cleveref](https://ctan.org/pkg/cleveref)
* [https://ctan.org/pkg/hyperref](https://ctan.org/pkg/hyperref)

Note on *hyperref* package: as a rule of thumb it should be loaded at the end of the preamble, after all the other packages.
A few exceptions exist, such as the *cleveref* package. 
*cleveref* should be loaded after hyperref.
More exceptions are listed in this post on TeX.SE: [Which packages should be loaded after hyperref instead of before?](https://tex.stackexchange.com/questions/1863/which-packages-should-be-loaded-after-hyperref-instead-of-before)

From [Four effortless LaTeX packages you should use](https://brushingupscience.com/2016/02/13/four-effortless-latex-packages-you-should-use/):

* [https://ctan.org/pkg/mathpazo](https://ctan.org/pkg/mathpazo)
* [https://ctan.org/pkg/microtype](https://ctan.org/pkg/microtype)
* [https://ctan.org/pkg/caption](https://ctan.org/pkg/caption)
* [https://ctan.org/pkg/sectsty](https://ctan.org/pkg/sectsty)

----

## Groups

From [Free edition of the book "TeX for the Impatient"](http://mirrors.ctan.org/info/impatient/book.pdf):
> A *group* consists of material enclosed in matching left and right braces (**{** and **}**).
> By placing a command within a group, you can limit its effects to the material within the group.
> For instance, the ```\bf``` command tells TeX to set something in **boldface** type.
> If you were to put ```\bf``` into your input file and do nothing else to counteract it, everything in your document following the ```\bf``` would be set in boldface.
> By enclosing ```\bf``` in a group, you limit its effect to the group.
> For example, if you type:
> 
> ```We have {\bf a few boldface words} in this sentence.```
>
> you'll get:
>
> We have **a few boldface words** in this sentence.

----

## Environments

Areas between ```\begin{...}``` and ```\end{...}``` pairs are called **environments**.  [<sup>[12](#footnotes)</sup>] [<sup>[13](#footnotes)</sup>] [<sup>[14](#footnotes)</sup>]

----

## The Document Environment 
## aka Actual Document (Body of the Text or Document Body)
 
After the preamble, the text of your document is enclosed between two commands which identify the beginning and end of the actual document:

```
\begin{document}
...
\end{document}
```

A useful side-effect of marking the end of the document text is that you can store comments or temporary text underneath the ```\end{document}``` in the knowledge that LaTeX will never try to typeset them:

```
\end{document}
...
```

### The Document Environment

#### Top Matter (aka Front Matter)

At the beginning of most documents there will be information about the document itself, such as the title and date, and also information about the authors, such as name, address, email etc.
All of this type of information within LaTeX is collectively referred to as *top matter* (aka *front matter*).
Although never explicitly specified (there is no *\topmatter* or *\frontmatter* command) you are likely to encounter the term within LaTeX documentation. 

A simple example:

```
\documentclass[11pt,a4paper]{report}

\begin{document}
\title{How to Structure a LaTeX Document}
\author{Andrew Roberts}
\date{December 2004}
\maketitle
\end{document}
```

You always finish the top matter (front matter) with the \maketitle command, which tells LaTeX that it's complete and it can typeset the title according to the information you have provided and the class (style) you are using.
If you omit ```\maketitle```, the title will not be typeset. 

Using this approach, you can only create a title with a fixed layout.
If you want to create your title freely, see the [Title Creation](https://en.m.wikibooks.org/wiki/LaTeX/Title_Creation). 


#### Abstract

As most research papers have an abstract, there are predefined commands for telling LaTeX which part of the content makes up the abstract.
This should appear in its logical order, therefore, after the top matter (front matter), but before the main sections of the body.
This command is available for the document classes article and report, but not book.

```
\documentclass{article}

\begin{document}

\begin{abstract}
Your abstract goes here...
...
\end{abstract}
...
\end{document}
```

By default, LaTeX will use the word "Abstract" as a title for your abstract.
If you want to change it into anything else, e.g. "Executive Summary", add the following line before you begin the abstract environment:

```
\renewcommand{\abstractname}{Executive Summary}
```

### Sectioning (Sectioning Commands)

Here are some of the sectioning commands. 

```
\chapter{Introduction}
This chapter's content...

\section{Structure}
This section's content...

\subsection{Top Matter}
This subsection's content...

\subsubsection{Article Information}
This subsubsection's content...
```

You do not need to specify section numbers; LaTeX performs automatic numbering of the sections.
Also, for sections, you do not need to use ```\begin``` and ```\end``` commands to indicate which content belongs to a given block.

If you want to use **sections without numbering them**, then add an **asterisk (*)** after the section command, but before the first curly brace, i.e. ```\section*{A Title Without Numbers}```.


LaTeX provides 7 levels of depth for defining sections (see table below).
Each section in this table is a subsection of the one above it. 

```
+---------------------------------+-------+-----------------------+
| Command                         | Level | Comment               |
+---------------------------------+-------+-----------------------+
| \part{"part"}                   |  -1   | not in letter         |
+---------------------------------+-------+-----------------------+
| \chapter{"chapter"}             |   0   | only book and report* | 
+---------------------------------+-------+-----------------------+
| \section{"section"}             |   1   | not in letter         |
+---------------------------------+-------+-----------------------+
| \subsection{"subsection"}       |   2   | not in letter         |
+---------------------------------+-------+-----------------------+
| \subsubsection{"subsubsection"} |   3   | not in letter         |
+---------------------------------+-------+-----------------------+
| \paragraph{"paragraph"}         |   4   | not in letter         |
+---------------------------------+-------+-----------------------+
| \subparagraph{"subparagraph"}   |   5   | not in letter         |
+---------------------------------+-------+-----------------------+

[*] You need \documentclass{book} or \documentclass{report}.
```

All the titles of the sections are added automatically to the table of contents (if you decide to insert one).
But if you make manual styling changes to your heading, for example a very long title, or some special line-breaks or unusual font-play, this would appear in the Table of Contents as well, which you almost certainly don't want.
LaTeX allows you to give an optional extra version of the heading text which only gets used in the Table of Contents and any running heads, if they are in effect.
This optional alternative heading goes in [square brackets] before the curly braces:

```
\section[Effect on staff turnover]{An analysis of the
effect of the revised recruitment policies on staff
turnover at divisional headquarters}
```

----


#### Ordinary Paragraphs

----

#### Table of Contents
##### Depth

----


# Sample LaTeX Documents

Based on [Getting started with TeX, LaTeX, and friends](https://tug.org/begin.html).

## Introductory LaTeX Document (small2e.tex)

> If you have TeX installed and just want to get started, you can peruse and process this [introductory LaTeX document (small2e)](https://mirror.ctan.org/macros/latex/base/small2e.tex).
> When you've mastered that, move on to this [more complex example (sample2e)](https://mirror.ctan.org/macros/latex/base/sample2e.tex).
>
> The basic procedure is to create plain text files in any editor or GUI front end (TeXworks, TeXShop, GNU Emacs, etc.), and then run ```pdflatex myfile.tex``` from a command line to get PDF output.
> Or run ```latex``` to get DVI output, instead of PDF. 

```
$ fetch https://mirror.ctan.org/macros/latex/base/small2e.tex
```

```
$ pdflatex small2e.tex 
```

```
$ mupdf small2e.pdf
```


## More Complex Introductory LaTeX Document (sample2e.tex)

```
$ fetch https://mirror.ctan.org/macros/latex/base/sample2e.tex
```

```
$ pdflatex sample2e.tex 
```

```
$ mupdf sample2e.pdf 
```

----

## Template from AMS-LaTeX Primer
## (aka Getting up and running with AMS-LaTeX)

From
[Getting up and running with AMS-LaTeX -- Philip S. Hirschhorn](http://mirror.ctan.org/info/amslatex/primer/amshelp.pdf)
> Abstract.
> 
> Together with the template file *template.tex*, these notes are an attempt to tell you enough about LaTeX and AMS-LaTeX so that you can get started without having to read the book.

You can download the *template.tex* from CTAN here: [https://mirrors.ctan.org/info/amslatex/primer/template.tex](https://mirrors.ctan.org/info/amslatex/primer/template.tex)

----

## MWE (Minimal Working Example) of a LaTeX Document

From [LaTeX for tabletop - a MWE (minimal working example) of a LaTeX document](https://vladar.bearblog.dev/latex-for-tabletop/) 

> **STY files**   
> It is quite useful to keep all of your custom formatting parameters and macros in a separate file.

You can download the *.tex* and *.sty* files for this example here:   
[example.tex]({{ site.url }}/assets/txt/example.tex)   
[example.sty]({{ site.url }}/assets/txt/example.sty)

----

## Minimal LaTeX File

Based on [The Not-So Short Guide to LaTeX2e - Or LaTeX2e in 139 minutes -- Tobias Oetiker, Hubert Partl, Irene Hyna, and Elisabeth Schlegl](https://mirrors.ctan.org/info/lshort/english/lshort.pdf)

```
\documentclass{article}
\begin{document}
A Minimal LaTeX File.
\end{document}
```

## Slightly More than Minimal LaTeX Input File

Based on [The Not-So Short Guide to LaTeX2e - Or LaTeX2e in 139 minutes](https://mirrors.ctan.org/info/lshort/english/lshort.pdf)

```
$ cat small.tex
\documentclass[a4paper,11pt]{article}

% define the title
\author{P.~Dusko}
\title{Minimalism}

\begin{document}

% generates the title
\maketitle

% insert the table of contents
\tableofcontents

\section{Section with Some Interesting Words}
Well, and here begins my lovely article.

\section{Good Bye Section}
\ldots{} and here it ends.

\end{document}
```


NOTE: When you have a TOC (Table Of Contents) in your document, you need to invoke  LaTeX **two times** so unless you are using [```latexmk(1)``` Perl script](https://www.cantab.net/users/johncollins/latexmk/index.html), or [*LaTeX-Mk* (*make*-based build system for LaTeX projects)](https://latex-mk.sourceforge.net/), or the ```make(1)``` program, you need to run the ```pdflatex(1)``` command (or  the```latex``` command, or the ```lualatex``` command) **two times** in order to get a correct table of contents. [<sup>[15](#footnotes)</sup>] [<sup>[16](#footnotes)</sup>] [<sup>[17](#footnotes)</sup>]

```
$ pdflatex small.tex
```

```
$ pdflatex small.tex
```

```
$ mupdf small.pdf
```

![Slightly more than minimal LaTeX file](/assets/img/latex-minimalism.png "Slightly more than minimal LaTeX file")

An image showing a slightly more than minimal LaTeX file

----

## One Page Document Template (One-Pager Boilerplate) 

```
$ cat latexonepage.tex 
\documentclass{article}

% Preamble - the area between \documentclass{...} and \begin{document}
\usepackage{lipsum}
\title{The quick brown fox jumps over the lazy dog}
\author{Name}
% Preamble - the area between \documentclass{...} and \begin{document}

% Document Body - the area between \begin{document} and \end{document}
\begin{document}

% Document title; Author's name; Date - From \title and \author
\maketitle  

The lipsum command automatically generates the specified number of paragraphs of text that is commonly used for examples.

\section{Text for the first section}
  \lipsum[1]
\subsection{Text for a subsection of the first section}
  Text for a subsection of the first section.
\subsection{Another subsection of the first section}
  Text for another subsection of the first section.

\section{The second section}
  Text for the second section.
\subsection{Title of the first subsection of the second section}
  Text for the second subsection.

\end{document}
% Document Body - the area between \begin{document} and \end{document}
```

```
$ pdflatex latexonepage.tex
```

If your run ends with a question mark, then you can type 'x' and press the 'Enter' key to get out.

```
$ zathura latexonepage.pdf
```

Note that **numbering** of the sections and subsections is done **automatically**.


## Optional: All-in-One Preamble

All-in-one preamble that takes care of LuaLaTeX and XeLaTeX (based on [The Not-So Short Guide to LaTeX2e (Version 6.4, Mar 9, 2021) - Figure 2.1: All in one preamble that takes care of LuaLaTeX and XeLaTeX, page 24](https://mirrors.ctan.org/info/lshort/english/lshort.pdf)):

```
\usepackage{iftex}
\ifXeTeX
  \usepackage{fontspec}
\else
  \usepackage{luatextra}
\fi
\defaultfontfeatures{Ligatures=TeX}
\usepackage{polyglossia}
```

You can download the `latexonepage.tex` file with the all-in-one preamble here: [latexonepage.tex]({{ site.url }}/assets/txt/latexonepage.tex)

```
$ lualatex latexonepage.tex
```

```
$ zathura latexonepage.pdf 
```

### Mini FAQ for One Page Document Template

* [How to get rid of page numbers](https://texfaq.org/FAQ-nopageno)
* [The quality of your LaTeX](https://texfaq.org/FAQ-latexqual)

----

## My Typical Minimal Document Template (Boilerplate) 

Based on [*Beginners' LaTeX* (now called the *Formatting Information* document) - CTAN](https://www.ctan.org/tex-archive/info/beginlatex/),
[LaTeX cheat sheet - Winston Chang](http://wch.github.io/latexsheet/latexsheet.pdf),
and on
[Formatting Information - https://latex.silmaril.ie/formattinginformation](https://latex.silmaril.ie/formattinginformation).

```
$ cat latex-template.tex
\documentclass[12pt]{article}

% vv-- Preamble - the area between \documentclass{...} and \begin{document}
\usepackage{fontspec,url}
\usepackage{fullpage}      % Use 1 inch margins
\setmainfont{XCharter}
\setcounter{secnumdepth}{0}
\pagenumbering{gobble}     % Preventing pages from being numbered
% ^^-- Preamble - the area between \documentclass{...} and \begin{document}

% vv-- Document Body - the area between \begin{document} and \end{document}
\begin{document}

\section{My \LaTeX\ Template}

This is a short example of a \LaTeX\ document I wrote on \today. 
It shows a few simple features of automated typesetting, including:
\begin{itemize}
  \item setting the font size to 12pt for the `article' class;
  \item using any font, not just the default;
  \item using the special formatting for URIs (URLs or web addresses);
  \item using the XCharter typeface;
  \item preventing sections from being numbered;
  \item preventing pages from being numbered;
  \item formatting a section heading;
  \item using the \textbf{ \LaTeX\ } logo;
  \item generating today's date;
  \item formatting this list of items;
  \item formatting a subsection heading;
  \item using opening and closing quotes;
  \item boxing, centering, italicizing, and putting text into bold type.
\end{itemize}

\subsection{More information}

This example was taken from the book `Formatting
Information', which you can read online at
\url{http://latex.silmaril.ie/formattinginformation/}
and use as a teach-yourself guide.

\bigskip

A table:
\begin{table}[!th]
\begin{tabular}{|l|c|r|}
\hline
  first & row & data \\
  second & row & data \\
\hline
\end{tabular}
\caption{This is the caption}
\label{ex:table}
\end{table}

The table is numbered \ref{ex:table}.

\begin{center}
  \fbox{\emph{Have a nice day!}}
\end{center}

\end{document}
% ^^-- Document Body - the area between \begin{document} and \end{document}
```


```
$ lualatex latex-template.tex
. . . 
LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.
```

```
$ lualatex latex-template.tex
```

```
$ zathura latex-template.pdf
```

![My typical minimal LaTeX template file](/assets/img/latex-template.png "My typical minimal LaTeX template file")

An image showing my typical minimal LaTeX template file


### Tips and Tricks

#### Supressing Page Numbering

Use ```\pagenumbering{gobble}``` in the preamble of your LaTeX document.


#### Unnumbered Headings 

To get an unnumbered heading which does not go into the TOC (Table of Contents), follow the command name with an asterisk (*) before the opening curly brace.

```\section*{Section Title}```

----

## Sample File with Some Interesting TeX and LaTeX Examples 

You can download the sample file here:   
[tex-latex-extras.tex]({{ site.url }}/assets/txt/tex-latex-extras.tex)  
[tex-latex-extras.pdf]({{ site.url }}/assets/txt/tex-latex-extras.pdf)  

```
$ lualatex tex-latex-extras.tex
. . . 
LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.
. . . 
```

```
$ lualatex tex-latex-extras.tex
```

```
$ zathura tex-latex-extras.pdf 
```

----

# Makefile

NOTE:
The second line (```pdflatex helloworld.tex```) starts with one *ASCII tab*, a.k.a. the *TAB character*.

From the man page for [*make(1)*](https://man.freebsd.org/cgi/man.cgi?query=make&sektion=1):
>  Each of the lines in this script *must* be preceded by a tab. 


```
$ cat makefile
helloworld.pdf: helloworld.tex
	pdflatex helloworld.tex
```

```
$ make
```

----

# Makefile Scripts with LaTeX-Mk

Author: Dan McMahill ([dmcmahill](https://github.com/dmcmahill))

**LaTeX-Mk**: Collection of makefile and scripts for LaTeX documents [<sup>[18](#footnotes)</sup>] [<sup>[19](#footnotes)</sup>]

```
$ sudo pkg install latex-mk
```

LaTeX-Mk homepage - SourceForge.net:
[https://latex-mk.sourceforge.net/](https://latex-mk.sourceforge.net/)    

LaTeX-Mk project - GitHub:
[https://github.com/dmcmahill/latex-mk](https://github.com/dmcmahill/latex-mk)

----

# Using latexmk to Generate PDF by pdflatex

Author: [John Collins](https://www.cantab.net/users/johncollins/index.html)

From [Using Latexmk](https://mg.readthedocs.io/latexmk.html) - aka What is LaTeXmk?:
> If you use cross-references, you often have to run LaTeX more than once, if you use BibTeX for your bibliography or if you want to have a glossary you even need to run external programs in-between.
> 
> To avoid all this hassle, you should simply use Latexmk!
> 
> Latexmk is a Perl script which you just have to run once and it does everything else for you ... completely automagically.
> 
> And the nice thing is: you probably have it already installed on your computer, because it is part of MacTeX and MikTeX and it is bundled with many Linux Distributions.


In FreeBSD, **latexmk** is installed by package **texlive-base**.

```
$ latexmk -pdflatex helloworld.tex
```

```
$ mupdf helloworld.pdf 
```

```
$ latexmk -C
```

----

# Using latexmk with LuaLaTeX for Processing Files to PDF 

```
$ latexmk -lualatex helloworld.tex
```

```
$ mupdf helloworld.pdf
```

```
$ latexmk -C
```

Latexmk homepage:
[https://www.cantab.net/users/johncollins/latexmk/index.html](https://www.cantab.net/users/johncollins/latexmk/index.html)

Latexmk is also available at [CTAN](https://ctan.org/) at [https://ctan.org/pkg/latexmk/](https://ctan.org/pkg/latexmk/), and is/will be in the TeXLive and MiKTeX distributions.

----

# Editors

* [LyX – The Document Processor](https://www.lyx.org/)

* [TeXmaker - Free cross-platform latex editor](https://www.xm1math.net/texmaker/)

* [TeXstudio (formerly TexMakerX) - an integrated writing environment for creating LaTeX documents -- an open-source fork (2009) of Texmaker that offers a different approach to configurability and features](https://www.texstudio.org/)

* [TeXstudio on SourceForge.net](http://texstudio.sourceforge.net/)

* [TeXstudio on GitHub](https://github.com/texstudio-org/texstudio)

* [TeXworks - Lowering the entry barrier to the TeX world - a simple TeX front-end program (working environment)](https://tug.org/texworks/)

* [Kile - an Integrated LaTeX Editing Environment](https://kile.sourceforge.io/)

* [LibreOffice - with iMath and TexMaths extensions can provide mathematical TeX typesetting](https://www.libreoffice.org/)


# Online Editors

* [Overleaf (previously ShareLaTeX) - a partial-WYSIWYG, online editor that provides a cloud-based solution to TeX with additional features in real-time collaborative editing](https://www.overleaf.com)

  NOTE 1: ShareLaTeX and Overleaf have been merged in to one Overleaf v2 and Overleaf v1 had retired on January 8th, 2019.

  NOTE 2: It's Open Source, so you can install it on your own server [https://github.com/overleaf/overleaf](https://github.com/overleaf/overleaf).

* [LaTeX previewer](http://www.tlhiv.org/ltxpreview/)

* [Papeeria - Online LaTeX editor -- LaTeX and Markdown online Collaborative, free and reliable](https://papeeria.com/)

* [LaTeXOnlineEditor (XO) -- Your browser-based writing & formatting program to create PDFs](https://latexonlineeditor.net/)



# Editors - References

* [Comparison of TeX editors - Wikipedia](https://en.wikipedia.org/wiki/Comparison_of_TeX_editors)

* [Category:TeX editors - Wikipedia](https://en.wikipedia.org/wiki/Category:TeX_editors)

* [Compiling documents online - TeX - LaTeX Stack Exchange](https://tex.stackexchange.com/questions/3/compiling-documents-online)

----

[Online LaTeX Compilers](https://texblog.net/latex-link-archive/online-compiler/)

----

# Fonts and Typefaces (Font Families) in Tex/LaTeX

LaTeX handles its fonts as combination of three parameters.
These individual switches can be used inside a group, or as an environment:

```
{\ttfamily This is typewriter text}
\begin{mdseries}
This text is set in medium weight.
\end{mdseries}
```

Here are the categories and possible values.   
**family** roman, sans serif, typewriter type: ```\rmfamily```, ```\sffamily```, ```\ttfamily```.   
**series** medium and bold: ```\mdseries```, ```\bfseries```.  
**shape** upright, italic, slanted, and small caps: ```\upshape```, ```\itshape```, ```\slshape```, ```\scshape```.  


## Font Size 

**size** tiny, scriptsize, footnotesize, small, normalsize, large, Large, LARGE, huge, HUGE: ```\tiny```, ```\scriptsize```, ```\footnotesize```, ```\small```, ```\normalsize```, ```\large```, ```\Large```, ```\LARGE```, ```\huge```, ```\HUGE```    


## LaTeX2e Fonts

From [LaTeX2e font selection. LaTeX Project Team, March 2024](http://mirrors.ctan.org/macros/latex/base/fntguide.pdf):
> 1.1 LaTeX2e fonts
> 
> The most important difference between LaTeX 2.09 and LaTeX2e is the way that
fonts are selected.
> In LaTeX 2.09, the Computer Modern fonts were built into the LaTeX format, and so customizing LaTeX to use other fonts was a major effort.
> 
> In LaTeX2e, very few fonts are built into the format, and there are commands to load new text and math fonts.
> Packages such as *times* or *latexsym* allow authors to access these fonts.
> This document describes how to write similar font-loading packages.
> 
> The LaTeX2e font selection system was first released as the 'New Font Selection Scheme' (NFSS) in 1989, and then in release 2 in 1993.
> LaTeX2e includes NFSS release 2 as standard.


## Font and Typefaces - References

[LaTeX and its fancy fonts](https://vladar.bearblog.dev/latex-and-its-fancy-fonts/)

[Fonts and TeX - TUG (TeX User Group)](https://tug.org/fonts/)

[The LaTeX Font Catalogue - TUG](https://tug.org/FontCatalogue/) 

[Comprehensive LATEX Symbols List, Scott Pakin](https://mirror.ctan.org/info/symbols/comprehensive/symbols-letter.pdf)

[The Comprehensive LaTeX Symbol List - Symbols accessible from LaTeX - CTAN](https://www.ctan.org/tex-archive/info/symbols/comprehensive)

[Palatino and Source Sans Pro, the only fonts a scientist needs](https://brushingupscience.com/2018/06/14/palatino-and-source-sans-pro-the-only-fonts-a-scientist-needs/)


NOTE: If you want to use the Palatino font, you also need to use the following two packages: *fontenc* (with option *T1*) and *textcomp* in the preamble of your LaTeX document.

```
\usepackage[T1]{fontenc}
\usepackage{textcomp}
\usepackage{palatino}
```
 
References:   

* [Using common PostScript fonts with LaTeX - PSNFSS - Walter Schmidt](https://texdoc.org/serve/palatino/0):
> 1 What is PSNFSS?
> 
> The PSNFSS collection includes a set of files that provide a complete working
setup of the LaTeX font selection scheme (NFSS2) for use with common PostScript
fonts.
> It covers the so-called 'Base 35' fonts (which are built into any Level 2 PostScript printing device and the Ghostscript interpreter) and a number of free fonts.
>
> . . . 
>
> 3 Special considerations
> 
> 3.1 Output font encoding
> 
> None of the packages listed in table 1 changes the output font encoding from its default setting OT1. It is, however, highly recommended to use the fonts with the extended T1 and TS1 (text symbols) encodings by means of the commands:
> 
> ```
> \usepackage[T1]{fontenc}
> \usepackage{textcomp}
> ```

* [Using fonts installed in local texlive (including Palatino) - TeX - LaTeX Stack Exchange](https://tex.stackexchange.com/questions/202767/using-fonts-installed-in-local-texlive)

----

# My Choice of Engine: LuaTeX (LuaLaTeX)

From [TeX - Wikipedia](https://en.wikipedia.org/wiki/TeX):
> ... LuaTeX, a **Unicode-aware** *extension* to TeX that includes a Lua runtime with extensive hooks into the underlying TeX routines and algorithms.

From [LuaTeX - Wikipedia](https://en.wikipedia.org/wiki/LuaTeX):
> When LuaTeX is used with the LaTeX format, it is sometimes called "LuaLaTeX".

On FreeBSD, the ```lualatex``` command is installed with package *tex-luatex*.
Similarly, the documentation for *LuaLaTeX* is also installed with package *tex-luatex* in directory: */usr/local/share/texmf-dist/doc/lualatex/lualatex-doc/*.
This directory contains a file *lualatex-doc.pdf*, which is titled *A guide to LuaLaTeX*. 

From *A guide to LuaLaTeX, Manuel Pégourié-Gonnard (mpg@elzevir.fr), May 5, 2013 -- 1.1 Just what is LuaLaTeX?*:
> LuaLaTeX is the LuaTeX engine with the LaTeX format.
> Well, this answer isn't very satisfying if you don't know what LuaTeX and LaTeX are.
> 
> As you probably know, LaTeX is the general framework in which documents begin with ```\documentclass```, packages are loaded with ```\usepackage```, fonts are selected in a clever way (so that you can switch to boldface while preserving italics), pages are build with complicated algorithms including support for headers, footers, footnotes, margin notes, floating material, etc.
> This mostly doesn't change with LuaLaTeX, but new and more powerful packages are available to make parts of the system work in a better way.
> 
> So, what's LuaTeX? Short version: the hottest TeX engine right now!
> Long version: It is the designated successor of pdfTeX and includes all of its core features: direct generation of PDF files with support for advanced PDF features and micro-typographic enhancements to TeX typographic algorithms.

----


# Repositories

[CTAN - The Comprehensive TeX Archive Network](https://www.ctan.org/)

[The LaTeX Font Catalogue](https://tug.org/FontCatalogue/) 

----

# Drawing in TeX and LaTeX

[GraTeX](https://sourceforge.net/projects/gratex/)

[LaTeXDraw - SourceForge.net](http://latexdraw.sourceforge.net/)

[LaTeXDraw - GitHub](https://github.com/latexdraw/latexdraw)

[TeXCAD](https://texcad.sourceforge.io/)

[jPicEdt - jPicEdt for LaTeX](https://jpicedt.sourceforge.net/)

[Using TikZ to Prepare Illustrations, by Jennifer Brown](https://www.ams.org/arc/resources/pdfs/tikz_tutorials_all-brown.pdf).
This is a series of tutorials to show how to use TikZ to create professional-quality mathematical diagrams, graphs, and illustrations

[TikZ and PGF - TeXample.net](https://texample.net/tikz/)

[KtikZ - a nice user interface for making pictures using TikZ](https://github.com/fhackenberger/ktikz)

[KtikZ Editor - Archived from the original on Sep 25 2023](https://web.archive.org/web/20230925033323/https://www.hackenberger.at/blog/ktikz-editor-for-the-tikz-language/)
> KtikZ is a small application helping you to create TikZ (from the LaTeX pgf package) diagrams for your publications.
> It requires qt4, libpoppler, LaTeX (pdflatex), the LaTeX preview-latex-style package and pgf itself.
> For the eps export functionality you also need the poppler-utils package.
> If you'd like to improve this little tool just clone it from [https://github.com/fhackenberger/ktikz](https://github.com/fhackenberger/ktikz) and send a pull request.

[Asymptote - The Vector Graphics Language](https://asymptote.sourceforge.io/)

[Inkscape - Vector graphics editor](https://inkscape.org/) 

----

# Tutorials

Andrew Roberts has a few well written [tutorials on his website](http://www.andy-roberts.net/misc/latex/).

[LaTeX tutorials - a primer](http://www.tug.org/twg/mactex/tutorials/ltxprimer-1.0.pdf) by the Indian TeX User Group (The TUG*India*). 

Creating a LaTeX Minimal (Minimum) Example - aka Minimal Working Example (MWE): [PDF](http://www.dickimaw-books.com/latex/minexample/minexample-a4.pdf),
[HTML](https://www.dickimaw-books.com/latex/minexample/html/)

[Getting up and running with AMS-LaTeX -- Philip S. Hirschhorn](http://mirror.ctan.org/info/amslatex/primer/amshelp.pdf)

[User's Guide for the amsmath Package - (AMS) American Mathematical Society, LaTeX Project](http://mirror.ctan.org/macros/latex/required/amsmath/amsldoc.pdf)

----

# Tools

[LaTeX.js.org - JavaScript LaTeX to HTML5 Translator](https://latex.js.org/)

[LaTeX.js.org - Playground](https://latex.js.org/playground.html) 

[TeXtidote - Spelling, grammar and style checking on LaTeX documents](https://sylvainhalle.github.io/textidote/)

[TexText -- Re-editable LaTeX and typst graphics for Inkscape](https://github.com/textext/textext)

[JabRef -- Open-source, cross-platform citation and reference management software](https://www.jabref.org/)

----

# TeX/LaTeX Resources

[Getting started with LaTeX - a collection of resources - texblog](https://texblog.org/2012/10/29/getting-started-with-latex-a-collection-of-resources/)

[TeX/LaTeX Resources - texblog](https://texblog.org/tex-resources/)

[TeX Resources on the Web - TeX Users Group (TUG)](https://tug.org/interest.html)

[LaTeX Editors/IDEs](https://tex.stackexchange.com/questions/339/latex-editors-ides)

[What are other good resources on-line for information about TeX, LaTeX and friends?](https://tex.stackexchange.com/questions/162/what-are-other-good-resources-on-line-for-information-about-tex-latex-and-frien)

----


# Footnotes

[1] [What is pdfTeX? - The TeX FAQ - The TeX Frequently Asked Question List](https://texfaq.org/FAQ-pdftex) 

> One can reasonably say that pdfTeX is (today) the main stream of TeX distributions: most LaTeX nowadays use pdfTeX whether they know it or not.
>
> pdfTeX is a development of TeX that is capable of generating typeset PDF output in place of DVI. pdfTeX has other capabilities, most notably in the area of fine typographic detail (for example, its support for optimising line breaks), but its greatest impact to date has been in the area of PDF output.

[2] From [pdfTeX - TUG (TeX Users Group)](https://tug.org/applications/pdftex/)
> pdfTeX is an extension of TeX which can produce PDF directly from TeX source, as well as original DVI files.
> pdfTeX incorporates the e-TeX extensions.
>
> pdfTeX also has a variety of other extensions, perhaps most notably for microtypography line breaking features.
> The microtype package provides a convenient interface for LaTeX.
>
> pdfTeX is released as part of TeX Live, and also included in all TeX distributions, notably MiKTeX. Current release: NEWS, manual, sources. 

[3] From [The TeX showcase](https://tug.org/texshowcase/):
> This is the TeX showcase, edited by Gerben Wierda.
> It contains extreme examples of what you can do with TeX, the typesetting engine from Donald Knuth, world famous mathematician, computer scientist and above all well known for TeX. 

[4] From [Getting started with TeX, LaTeX, and friends - TUG (TeX Users Group)](https://tug.org/begin.html):
> TeX is a typesetting language.
> Instead of visually formatting your text, you enter your manuscript text intertwined with TeX commands in a plain text file.
> You then run TeX to produce formatted output, such as a PDF file.
> Thus, in contrast to standard word processors, your document is a separate file that does not pretend to be a representation of the final typeset output, and so can be easily edited and manipulated. 

[5] [LaTeX (Guide to LaTeX) - Wikibooks](https://en.wikibooks.org/wiki/LaTeX)
> TeX is a typesetting computer program created by [Donald Knuth](https://en.wikipedia.org/wiki/Donald_Knuth), originally for his magnum opus, [The Art of Computer Programming](https://en.wikipedia.org/wiki/The_Art_of_Computer_Programming).
It takes a "plain" text file and converts it into a high-quality document for printing or on-screen viewing.
> LaTeX is a macro system built on top of TeX that aims to simplify its use and automate many common formatting tasks.
It is the de-facto standard for academic journals and books in several fields, such as mathematics and physics, and provides some of the best typography free software has to offer. 

[6] [Components of TeX - Joachim Schrod's technical article describing many of the relationships between supplementary components (files and programs) - An overview of the ingredients of the TeX system -- The Components of TEX, Joachim Schrod, March 1991](https://ctan.org/pkg/components)

[7] [What is LaTeX? - The TeX FAQ - The TeX Frequently Asked Question List](https://texfaq.org/FAQ-latex) 
> LaTeX is a TeX macro package, originally written by Leslie Lamport, that provides a document processing system.
> LaTeX allows markup to describe the structure of a document, so that the user need not think about presentation.
> By using document classes and add-on packages, the same document can be produced in a variety of different layouts.
> 
> Lamport says that LaTeX "represents a balance between functionality and ease of use".
> This shows itself as a continual conflict that leads to the need for such things as FAQs: LaTeX can meet most user requirements, but finding out how is often tricky.

[8] From [What are TeX and its friends? - CTAN (The Comprehensive TeX Archive Network)](https://www.ctan.org/tex)
> An important boost to that popularity came in 1985 with the introduction of LaTeX by Leslie Lamport.
> This is a set of commands that allows authors to interact with the system at a higher level than Knuth's original command set (called Plain TeX). 

[9] From [LaTeX - Wikibooks](https://en.wikibooks.org/wiki/LaTeX):
> LaTeX is a macro system built on top of TeX that aims to simplify its use and automate many common formatting tasks. 

[10] From [The Not-So Short Guide to LaTeX2e](https://ctan.org/pkg/lshort-english), [The document itself (A4 paper format) in PDF](https://mirrors.ctan.org/info/lshort/english/lshort.pdf)
> 1.1.2 LaTeX 
> 
> LaTeX enables authors to typeset and print their work at the highest typographical quality, using a predefined, professional layout. 
LATEX was originally written by Leslie Lamport.
> It uses the TeX formatter as its typesetting engine.
> These days LaTeX is maintained by the LaTeX Project.
> LaTeX is pronounced "Lay-tech" or "Lah-tech."
> If you refer to LaTeX in an ASCII environment, you type LaTeX.
> LaTeX 2ε is pronounced "Lay-tech two e" and typed LaTeX2e.

[11] From [LaTeX vs. MiKTeX: The levels of TeX - TUG (TeX User Group)](https://tug.org/levels.html):
> 1. Distributions: [MiKTeX](https://miktex.org/), [TeX Live](https://tug.org/texlive/), [W32TeX](https://www.w32tex.org/), ...
> These are the large, coherent collections of TeX-related software to be downloaded and installed.
> When someone says "I need to install TeX on my machine", they're usually looking for a distribution.
> 2. Front ends and editors: [Emacs](https://www.gnu.org/software/emacs/), [vim](https://www.vim.org/), [TeXworks](https://tug.org/texworks/), [TeXShop](o), TeXnicCenter, WinEdt, ... 
> These editors are what you use to create a document file.
> Some (e.g., TeXShop) are devoted specifically to TeX, others (e.g., Emacs) can be used to edit any sort of file.
> TeX documents are independent of any particular editor; the TeX typesetting program itself does not include an editor.
> 3. Engines: [TeX](https://ctan.org/pkg/tex), [pdfTeX](https://tug.org/applications/pdftex/index.html), [XeTeX](http://scripts.sil.org/xetex), [LuaTeX](https://www.luatex.org//), ...
> These are the executable binaries which implement different TeX variants. In short:
  >> pdfTeX implements direct PDF output, along with a variety of programming and other extensions.
  >> XeTeX does the above, and also supports Unicode natively, OpenType and TrueType fonts, access to system fonts, ... 
  >> LuaTeX does all the above, and provides access to many internals via the embedded Lua language. Thus it is by far the most programmable engine.
  >> [e][u]pTeX provide full support for Japanese typesetting. 
> There are other engines, but the above are by far the most commonly used nowadays.
> 4. Formats: [LaTeX](https://texfaq.org/FAQ-latex), [plain TeX](https://ctan.org/pkg/texbytopic), [OpTeX](https://ctan.org/pkg/optex), ... 
> These are the TeX-based languages in which one actually writes documents.
> When someone says "TeX is giving me a mysterious error", they usually mean a format.
> 5. Packages: [geometry](https://ctan.org/pkg/geometry), [lm](https://ctan.org/pkg/lm), ... 
> These are add-ons to the basic TeX system, developed independently, providing additional typesetting features, fonts, documentation, etc.
> A package might or might not work with any given format and/or engine; for example, many are designed specifically for LaTeX, but there are plenty of others, too.
> The CTAN sites provide access to the vast majority of packages in the TeX world; CTAN is generally the source used by the distributions. 

[12] Reference: [Learn LaTeX.org - Lesson 3 -- LaTeX document structure - What you've got](https://www.learnlatex.org/en/lesson-03#what-youve-got)

[13] Reference: [Five minute guide to LaTeX (PDF) - How To LaTeX (howtolatex.com) -- Archived from the original on May 5, 2016](https://web.archive.org/web/20160505212246/http://www.howtotex.com/download/FiveMinuteGuideToLaTeX.pdf)
> 1.1.2 Environments
> 
> Environments contain special content, such as math, figures, tables, etc.
> Environments start with ```\begin{}``` and end with ```\end{}```, where the **environment name** is between **{}**.
> 
> The ```document``` environment is most important: all content within this environment will be **printed**.

[14] Reference: [Formatting information - A beginner's introduction to typesetting with LaTeX](https://mirrors.ctan.org/info/beginlatex/beginlatex.pdf)
> This **\begin ... \end** pair of commands is an example of a common LaTeX structure called an ***environment***.
> Environments enclose text which is to be handled in a particular way.
> All environments start with ```\begin{...}``` and end with ```\end{...}``` (putting the name of the environment in the curly braces).

[15] The *TOC (Table Of Contents)* is an example of a **cross-reference**.
(Cross-references are references to anything that is numbered; for example, sections, figures, formulas, tables, and special segments of text.)  

Since they are not updated on the first LaTeX invocation, when you use cross-references in your document, you need to run LaTeX **two times** to get a correct table of contents.
**Sometimes** it might be necessary to compile the document a **third time**.
LaTeX will tell you when this is necessary **but** *pdflatex* will not tell you that.

LaTeX creates a table of contents by taking the section headings and page numbers from the last compile cycle of the document. 

To avoid running LaTeX multiple times, you can use tools like ```make``` or ```latexmk``` or **LaTeX-Mk**. (Refer to use of these three tools in sections about them in this document.)

From [LaTeX Basics - Wikibooks - 4.2 Ancillary files](https://en.wikibooks.org/wiki/LaTeX/Basics#Ancillary_files)
> The TeX compilers are single-pass processes.
> It means that there is no way for a compiler to *jump* around the document, which would be useful for the *table of contents* and *references*.
> Indeed the compiler cannot guess at which page a specific section is going to be printed, so when the table of contents is printed before the upcoming sections, it cannot set the page numbers.
> 
> To circumvent this issue, many LaTeX commands which need to *jump*, use **ancillary files** which usually have the same file name as the current document but a different extension.
> It stores temporary data into these files and use them for the next compilation.
> So to have an up-to-date table of contents, you need to compile the document twice.
> There is no need to re-compile if no section moved. 

[16] From the man page for ```latexmk(1)``` (on FreeBSD 14: */usr/local/share/texmf-dist/doc/support/latexmk*):
> A very annoying complication handled very reliably by *latexmk*, is that LaTeX is a multiple pass system.
> On each run, LaTeX reads in information generated on a previous run, for things like cross referencing and indexing.
> In the simplest cases, a second run of LaTeX suffices, and often the log file contains a message about the need for another pass.
> However, there is a wide variety of add-on macro packages to LaTeX, with a variety of behaviors.
> The result is to break simple-minded determinations of how many runs are needed and of which programs.
> *Latexmk* has a highly general and efficient solution to these issues.
> The solution involves retaining between runs information on the source files, and a symptom is that *latexmk* generates an extra file (with extension *.fdb_latexmk*, by default) that contains the source file information.
>
> . . . 
> 
> When *latexmk* is run, it examines properties of the source files, and if any have been changed since the last document generation, *latexmk* will run the various LaTeX processing programs as necessary.
> In particular, it will repeat the run of *latex* (or a related program) often enough to resolve all cross references; depending on the macro packages used.
> With some macro packages and document classes, four, or even more, runs may be needed.
> If necessary, *latexmk* will also run *bibtex*, *biber*, and/or *makeindex*.
> In addition, *latexmk* can be configured to generate other necessary files.
> For example, from an updated figure file it can automatically generate a file in encapsulated postscript or another suitable format for reading by LaTeX.

[17] From [TeX for the Impatient - a book (of around 350 pages) on TeX, Plain TeX and Eplain -- CTAN -- Chapter 2: Using TeX - Turning input into ink - Programs and files you need](https://ctan.org/pkg/impatient): 
> In order to produce a TeX document, you'll need to run the TeX program
and several related programs as well.
> You'll also need supporting files for TeX and possibly for these other programs.
> In this book we can tell you about TeX but we can't tell you about the other programs and the supporting files except in very general terms because they depend on your local TeX environment.
> The people who provide you with TeX should be able to supply you with what we call local information.
> The local information tells you how to start up TeX, how to use the related programs, and how to gain access to the supporting files.


[18] From [LaTeX-Mk homepage](https://latex-mk.sourceforge.net/):
> LaTeX-Mk is a complete system for simplifying the management of small to large sized LaTeX documents.
> LaTeX-Mk uses the standard *make* program for doing most of the work.
> Users simply create a makefile which many times is as simple as one line that specifies the document name and a single include line that loads all of the LaTeX-Mk rules.
> LaTeX-Mk has been used for many years on projects ranging in scale from a single page business letter to a published book. 

[19] From the *latex-mk* package description on FreeBSD 14 (```$ pkg rquery '%e' latex-mk```):
> LaTeX-Mk is a tool for managing small to large sized LaTeX projects.
> The typical LaTeX-Mk input file is simply a series of variable definitions in a Makefile for the project.
> After creating a simple Makefile the user can easily perform all required steps to do such tasks as: preview the document, print the document, or produce a PDF file.
> LaTeX-Mk will keep track of files that have changed and how to run the various programs that are needed to produce the output.

----

## Documents Collection

[TeX-nutshell - A short document about TeX principles -- https://ctan.org/pkg/tex-nutshell](https://ctan.org/pkg/tex-nutshell)   
[TeX-nutshell - A short document about TeX principles - The Document Itself](http://mirrors.ctan.org/info/tex-nutshell/tex-nutshell.pdf)  
[A Simplified Introduction to LaTeX - https://ctan.org/pkg/simplified-latex](https://ctan.org/pkg/simplified-latex)    
[A Simplified Introduction to LaTeX - The Document Itself](http://mirrors.ctan.org/info/simplified-latex/simplified-intro.pdf)   
[http://csweb.ucc.ie/~dongen/LAF/Basics.pdf](http://csweb.ucc.ie/~dongen/LAF/Basics.pdf)  
[http://csweb.ucc.ie/~dongen/LAF/Commands.pdf](http://csweb.ucc.ie/~dongen/LAF/Commands.pdf)   
[https://ctan.org/pkg/impatient](https://ctan.org/pkg/impatient)   
[http://mirrors.ctan.org/info/impatient/book.pdf](http://mirrors.ctan.org/info/impatient/book.pdf)   
[gentle – A Gentle Introduction to TeX](https://ctan.org/pkg/gentle)   
[gentle – A Gentle Introduction to TeX - The Document Itself](https://mirrors.ctan.org/info/gentle/gentle.pdf)    
[http://latex.silmaril.ie/veryshortguide/](http://latex.silmaril.ie/veryshortguide/)   
[http://latex.silmaril.ie/veryshortguide/veryshortguide.pdf](http://latex.silmaril.ie/veryshortguide/veryshortguide.pdf)   
[http://mirrors.ctan.org/info/latex-veryshortguide/veryshortguide.pdf](http://mirrors.ctan.org/info/latex-veryshortguide/veryshortguide.pdf)   
[http://mirrors.ctan.org/info/latex-veryshortguide/veryshortguide-A4-imposed.pdf](http://mirrors.ctan.org/info/latex-veryshortguide/veryshortguide-A4-imposed.pdf)   
[https://ctan.org/pkg/fntguide](https://ctan.org/pkg/fntguide)   
[https://tug.org/TUGboat/Articles/tb14-2/tb39rahtz-nfss.pdf](https://tug.org/TUGboat/Articles/tb14-2/tb39rahtz-nfss.pdf)   
[https://tug.org/pracjourn/2006-1/schmidt/schmidt.pdf](https://tug.org/pracjourn/2006-1/schmidt/schmidt.pdf)   
[https://ctan.org/pkg/latex-essential](https://ctan.org/pkg/latex-essential)   
[http://mirrors.ctan.org/info/latex-essential/ess2e.pdf](http://mirrors.ctan.org/info/latex-essential/ess2e.pdf)   
[https://ctan.org/pkg/fontsmpl](https://ctan.org/pkg/fontsmpl)   
[http://mirrors.ctan.org/macros/latex/required/tools/fontsmpl.pdf](http://mirrors.ctan.org/macros/latex/required/tools/fontsmpl.pdf)   
[https://www.ctan.org/tex-archive/info/fontsampler/](https://www.ctan.org/tex-archive/info/fontsampler/)   
[https://mirrors.ctan.org/info/fontsampler/sampler.pdf](https://mirrors.ctan.org/info/fontsampler/sampler.pdf)   

----

## References
(Retrieved on Jun 1, 2024)   

* ["Hello, World!" program - Wikipedia](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program)

* [TeX - Wikipedia - How it is run - A sample Hello world program in plain TeX](https://en.wikipedia.org/wiki/TeX#How_it_is_run)

* [Hello world in TeX](https://github.com/leachim6/hello-world/blob/main/t/TeX.tex)

* [Hello world in LaTeX](https://github.com/leachim6/hello-world/blob/main/l/LaTeX.tex)

* [The Hello World Collection](https://helloworldcollection.de/)

* [Hello world - Rosetta Code](https://rosettacode.org/wiki/Hello_world/Text)

* [GitHub – leachim6/hello-world: Hello world in every computer language](https://github.com/leachim6/hello-world)

* [Arbitrary LaTeX reference](https://latex.knobs-dials.com/)
> Many problems in LaTeX require some research so I started to record my findings.
> Some of this is overly simplified, never investigated past my own needs, some things are unverified, some quite possible wrong.
> Lately I haven't needed TeX much so I don't work on this page much - feel free to mail me any suggestions, corrections, and such.
> Please wait until the page is loaded; expansion will not work before it is.
> You can expand all sections when you want to search or print.

* [Unsung Heroes of IT / Part One: Brian Kernighan. TheUnsungHeroesOfIT.com. Archived from the original on Mar 26 2016](https://web.archive.org/web/20160326193543/http://theunsungheroesofit.com/helloworld/)

* [What are TeX and its friends? - CTAN (The Comprehensive TeX Archive Network)](https://www.ctan.org/tex)

* [LaTeX (Guide to LaTeX) - Wikibooks](https://en.wikibooks.org/wiki/LaTeX)

* [Getting started with TeX, LaTeX, and friends](https://tug.org/begin.html)

* [Starting out with TeX, LaTeX, and friends - CTAN](https://www.ctan.org/starter)

* [TeX in a Nutshell - Petr Olšák](http://petr.olsak.net/ftp/olsak/optex/tex-nutshell.pdf)

* [Beginner's LaTeX Guide](https://physics.nyu.edu/~physlab/Lab_Main/Latexguide.pdf)

* [The First LaTeX Document -- first-latex-doc – A document for absolute LaTeX beginners](https://www.ctan.org/pkg/first-latex-doc)

* [first-latex-doc.pdf -- The PDF file of example first document with embedded explanation](http://mirrors.ctan.org/info/first-latex-doc/first-latex-doc.pdf)

* [A Typical LaTeX Input File - From *Getting Started with LaTeX*, 2nd Edition, 1995 - David R. Wilkins](https://www.maths.tcd.ie/~dwilkins/LaTeXPrimer/TypicalInput.html)

* [A First Set of LaTeX Resources](https://www.ctan.org/tex-archive/info/latex-doc-ptr)

* [Five minute guide to LaTeX (in HTML) - How To LaTeX (howtolatex.com) -- Archived from the original on Aug 3, 2016](https://web.archive.org/web/20160803193128/http://www.howtotex.com/general/five-minute-guide-to-latex/)

* [Five minute guide to LaTeX (in PDF) - How To LaTeX (howtolatex.com) -- Archived from the original on May 5, 2016](https://web.archive.org/web/20160505212246/http://www.howtotex.com/download/FiveMinuteGuideToLaTeX.pdf)

* [LaTeX for tabletop - a MWE (minimal working example) of a LaTeX document](https://vladar.bearblog.dev/latex-for-tabletop/) 

* [CTAN (The Comprehensive TeX Archive Network)](https://www.ctan.org/)

* [What is pdfTeX? - The TeX FAQ - The TeX Frequently Asked Question List](https://texfaq.org/FAQ-pdftex)

* [Things with "TeX" in the name - The TeX FAQ - Frequently Asked Question List for TeX](https://texfaq.org/FAQ-texthings)

* [LaTeX Document Structure - Wikibooks](https://en.m.wikibooks.org/wiki/LaTeX/Document_Structure)

* [TeX - Wikipedia](https://en.wikipedia.org/wiki/TeX)

* [LuaTeX](https://www.luatex.org/)

* [LuaTeX - Wikipedia](https://en.wikipedia.org/wiki/LuaTeX)

* [LaTeX Cookbook](https://github.com/alexpovel/latex-cookbook)
> Download PDF: [https://github.com/alexpovel/latex-cookbook/releases/latest/download/cookbook.pdf](https://github.com/alexpovel/latex-cookbook/releases/latest/download/cookbook.pdf)
>
> This repo contains a LaTeX document, usable as a cookbook (different "recipes" to achieve various things in LaTeX) as well as as a template.
> The resulting PDF covers LaTeX-specific topics and instructions on compiling the LaTeX source.
> 
> A comprehensive LaTeX template with examples for theses, books and more, employing the 'latest and greatest' (UTF8, glossaries, fonts, ...).
> The PDF artifact is built using CI/CD, with a Python testing framework.
> 
> There is a by former coworkers of the author, at the research institute this template originated from as well.
> Active development is still happening there:
>
> [LaTeX template of the Institute of Engineering Thermodynamics (M21) for theses - Based on the Cookbook by Alex Povel](https://collaborating.tuhh.de/m21/public/theses/itt-latex-template)

* [Comprehensive list of LaTeX document classes](https://ctan.org/topic/class)

* [Latexmk homepage](https://www.cantab.net/users/johncollins/latexmk/index.html)

* [Latexmk at CTAN](https://ctan.org/pkg/latexmk/)

* [Using Latexmk](https://mg.readthedocs.io/latexmk.html)

* [LaTeX Intro Workshop - Introduction to LaTeX for writing papers in LaTeX](https://github.com/opieters/latex_intro/blob/master/latex-intro.pdf)

* [Manual page for style.Makefile(5) - FreeBSD Makefile file style guide - FreeBSD Manual Pages](https://man.freebsd.org/cgi/man.cgi?query=style.Makefile&sektion=5)

* [Manual page for make(1) - Maintain program dependencies - FreeBSD Manual Pages](https://man.freebsd.org/cgi/man.cgi?query=make&sektion=1)

* [Getting started with LaTeX – a collection of resources](http://texblog.org/2012/10/29/getting-started-with-latex-a-collection-of-resources/)

* [Creating a PDF document using pdflatex](http://theoval.cmp.uea.ac.uk/~nlct/latex/pdfdoc/pdfdoc/pdfdoc.html)

* [LaTeX-Mk homepage - SourceForge.net](https://latex-mk.sourceforge.net/)    

* [LaTeX-Mk project - GitHub](https://github.com/dmcmahill/latex-mk)

* [LaTeX for Chemists, Chefs, Managers and Paparazzi](http://texblog.org/2008/09/17/latex-for-chemists-chefs-managers-and-paparazzi/)

* [List of all LaTeX packages - All styles files available on CTAN](http://www-sop.inria.fr/miaou/latex/styles-eng.html) 

* [CTAN package directory - aka The CTAN archive - Comprehensive TeX Archive Network - The CTAN root directory](https://tug.ctan.org/) 

* [LaTeX Templates](http://www.latextemplates.com/)

* [TikZ and PGF - TeXample.net -- TikZ and PGF Examples -- TikZ Galleries](https://texample.net/tikz/)

* [Learn LaTeX - Learn LaTeX online for free in beginner friendly lessons](https://www.learnlatex.org/)

* [LaTeX cheat sheet - Winston Chang](http://wch.github.io/latexsheet/)

* [General LaTeX Cheat Sheet - latexsheet.pdf](http://mirror.ctan.org/info/latexcheat/latexcheat/latexsheet.pdf)

* [Andrew Roberts - tutorials on his website](http://www.andy-roberts.net/misc/latex/)

* [TeX for the Impatient - a book (of around 350 pages) on TeX, Plain TeX and Eplain -- CTAN](https://ctan.org/pkg/impatient)

* [The Computer Science of TeX and LaTeX; based on CS 594, fall 2004, University of Tennessee - Victor Eijkhout, Texas Advanced Computing Center, The University of Texas at Austin - 2012](https://bitbucket.org/VictorEijkhout/tex-latex-science-book/raw/2353026a66c47870f9d7a99e09e79a8af3f9fd20/TeXLaTeXcourse.pdf)

* [TeX by Topic, A TeXnician's Reference - Victor Eijkhout - Document Revision 1.5, 2019](https://github.com/VictorEijkhout/tex-by-topic/raw/main/TeXbyTopic.pdf)

* [Getting to Grips with LaTeX](https://www.andy-roberts.net/latex/)

* [LaTeX for authors, LaTeX Project Team](https://www.latex-project.org/help/documentation/usrguide.pdf)

----

* [Travels in TeX Land (by Dave Walden)](https://www.walden-family.com/texland/)

* [Macro memories, TUGboat, vol. 35 no. 1, 2014, pp. 99-110](https://www.walden-family.com/texland/tb109walden-preprint.pdf)

* [Travels in TeX Land: A Macro, Three Software Packages, and the Trouble with TeX (The PracTeX Journal, 2005)](https://tug.org/pracjourn/2005-3/walden-travels/)

* [Travels in TeX Land: LaTeX for Productivity in Book Writing (The PracTeX Journal, 2006)](https://tug.org/pracjourn/2006-2/walden/) 

* [Travels in TeX Land: Final Layout of a Book (The PracTeX Journal, 2006)](https://tug.org/pracjourn/2006-3/walden/) 

----

