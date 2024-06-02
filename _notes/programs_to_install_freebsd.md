---
layout: default    ## If you don't want to display the page as "plain"
title: "Programs to Install on a New Machine (FreeBSD) - DRAFT"
---

## Packages Available in FreeBSD 

```
texlive-base   TeX Live Typesetting System, base binaries
texlive-docs   TeX Live, documentation
texlive-texmf  TeX Live, macro packages and fonts
texlive-tlmgr  TeX Live, manager modules    [1] 
latex-mk       Collection of makefile and scripts for LaTeX documents
txt2tags       Convert simply formatted text into markup (e.g., LaTeX, HTML)
lyx            Document processor interfaced with LaTeX (nearly WYSIWYG)
setzer         LaTeX editor written in Python with Gtk

ipe            Extensible vector graphics editor with LaTeX support

rox-filer      Simple and easy to use graphical file manager
catseye-fm     Clear, fast, powerful file browser using gtk+2.0

kitty          Cross-platform, fast, featureful, GPU-based terminal emulator
```


## Manual Download or Manual Installations 

```
GraTeX         Visual graph creator for LaTeX (PGF & TikZ)    [2] 
```

```
$ fetch https://sourceforge.net/projects/gratex/files/GraTeX.jar
$ java -jar gratex.jar  
```


----

## Footnotes

[1] This package contains the files needed to get the TeX Live tools (notably ```tlmgr```) running: *perl* modules, *xz* binaries, plus (sometimes) *tar* and *wget*.
These files end up in the standalone install packages, and in the *tlcritical* repository.

[2] [GraTeX - SourceForge.net](https://sourceforge.net/projects/gratex/)    
> Java application for creating graphs, with a simple and intuitive interface. Obtaining LaTeX code for designed graph is a single-click operation.
Allows creating less and more complicated graphs for LaTeX documents without any knowledge about TikZ library.
> 
> The program lets you design and edit vertices, edges and labels to your liking thanks to a wide range of variants adequate to TikZ library.
> 
> GraTeX incorporates common editing mechanisms like saving/loading projects, undo-redo & copy-paste operations, and many other useful features.
> 
> The application has been developed by two students of University of Science and Technology in Krakow, Poland.
