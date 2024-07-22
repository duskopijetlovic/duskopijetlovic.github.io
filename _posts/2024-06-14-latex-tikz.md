---
layout: post
title: "Graphics in LaTeX with TikZ [DRAFT]"
date: 2024-06-14 22:17:44 -0700 
categories: tex latex graphics diagram graph pdf 
            documentation  writing technicalwriting svg vector image png design 
            reference tutorial howto 
---

## What is TikZ?

The inventor of TikZ, Till Tantau, created the name as a recursive acronym in German.
TikZ stands for TikZ ist kein Zeichenprogramm, which translates to TikZ is not a drawing program.

The origin of TikZ is called PGF, which stands for Portable Graphics Format and is a set of graphics *macros* that can be used with pdfLaTeX and the classic DVI/PostScript-based LaTeX.
Today, TikZ is used as the frontend for PGF as the backend.

TikZ is a set of TeX commands for drawing graphics.
Just like LaTeX is code that describes a document, TikZ is code that describes graphics and looks like LaTeX code.
With TikZ, you write ```\draw [blue] circle (1cm);``` to get a blue circle with a 1 cm radius in your PDF document.


First, you need to  load the *tikz* package in the preamble of your LaTeX document:

```
\usepackage{tikz}
```

TikZ provides additional features with separate libraries.
Here, you load the *quotes* library for adding annotations with an easy quoting syntax that you will use in the drawing:

```
\usetikzlibrary{quotes}
```

Use a *tikzpicture* environment for the *drawing*.

```
\begin{tikzpicture}
```

----

## Working with Coordinates

When you want TikZ to place a line, a circle, or any other element on the drawing, you need to tell it where to put it.
For this, you use coordinates.

### Cartesian Coordinates

In the two dimensions of your drawing, you consider an x axis in the horizontal direction going from left to right and a y axis in the vertical order going from bottom to top.
Then, you define a point by its distance to each axis. 

A point **(0,0)** is called the **origin**.

### Polar Coordinates

Let's consider the same plane as you had with Cartesian coordinates.
Just now, you define a point by its distance to the origin and the angle to the x axis.

The syntax is **(angle:distance)**.
TikZ uses a colon to distinguish it from Cartesian coordinates in polar coordinate syntax. 
For example, a point **(60:2)**: a distance of **2** from the origin **(0:0)** with an angle of **60 degrees** to the *x* axis.
Similarly, **(20:2)** also has a distance of **2** to the origin and an angle of **20 degrees** to the *x* axis, and **(180:3)** has a distance of **3** and an angle of **180 degrees**.


### Three-Dimensional coordinates

**[TODO]**


### Using Relative Coordinates

When you use **\draw** with a sequence of coordinates, you can state the relative position to the first coordinate by adding a **+** sign.
So, **+(4,2)** means the new coordinate is **plus 4** in the *x* direction and **plus 2** in the *y* direction.
Note that with +, it is always relative to the first coordinate in this path section.

That's not so handy - always looking back to the first coordinate.
TikZ offers another syntax with **double plus signs**.
For example, **++(1,2)** means **plus one** in the *x* direction and **plus 2** in the *y* direction but from the previous point.
That means you can move step by step.

----

## Using Units

From
*Chapger 2: Creating the First TikZ Images - LaTeX Graphics with TikZ by Stefan Kottwitz, Published by Packt Publishing*: 
> You may already have wondered what a coordinate (1,2) or a radius of 2 can mean in a document regarding the size of the PDF.
> Mathematically, in a coordinate system, it's clear but in a document, you need actual width, height, and lengths.
> 
> So, by default, 1 means *1 cm*.
> You can use any LaTeX dimension, so you can also write **(8mm,20pt)** as a coordinate or **(60:1in)** for 60 degrees with a 1-inch distance.
>
> You can change the default unit lengths of 1 cm to anything else you like.
> If you write ```\begin{tikzpicture}[x=3cm,y=2cm]```, you get x = 1 as 3 cm, and y = 1 will be 2 cm.
> So, **(2,2)** would mean the point, **(6cm,4cm)**.
> It's an easy way of changing the dimensions of a complete TikZ drawing.
> For example, change x and y to be twice as big in the **tikzpicture** options to *double a picture in size*.

----

## Commands in the tikzpicture environment

### \draw

```\draw``` produces a *path* with coordinates and picture elements in between until you end it with a semicolon (```;```).
You can sketch it like the following:

```
\draw[<style>] <coordinate> <picture element> <coordinate> ... ;
```

To draw a *circle*, with a radius of 0.5 cm at the default origin; that is (0,0): 

```
\draw circle (0.5);
```

To draw a line from (-0.5,0) to (0.5,0) in Cartesian coordinates, with the label 'Test':

```
\draw (-0.5,0) to ["Test"] (0.5,0);
```

To draw a thin, dotted *grid* from the coordinate (-3,-3) to the coordinate (3,3):

```
\draw[thin,dotted] (-3,-3) grid (3,3);
```

To draw a line with an *arrow tip*, from the coordinate (-3,0) to the coordinate (3,0):

```
\draw[->] (-3,0) -- (3,0);
```

Complete document example with TikZ test drawing:

```
cat tikz_example.tex
\documentclass{article}
\usepackage{tikz}
\usetikzlibrary{quotes}

\begin{document}
\begin{tikzpicture}
  \draw circle (0.5);
  \draw (-0.5,0) to ["Test"] (0.5,0);
\end{tikzpicture}
\end{document} 
```

Compile it to PDF.

```
$ latexmk -pdf tikz_example.tex
```

Open the PDF with a PDF viewer.

```
$ mupdf tikz_example.pdf 
```

----

## Drawing Geometric Shapes with TikZ

You start with ```\draw <coordinate>``` (that's the *current coordinate*) and continue with some of the following elements:

* Line: ```-- (x,y)``` draws a line from the current coordinate to (x,y).
* Rectangle: ```rectangle (x,y)``` draws a rectangle where one corner is the current coordinate, and the opposite corner is (x,y).
* Grid: Like rectangle but with lines in between as a grid.
* Circle: ```circle (r)``` is a short syntax: draw a circle with a radius of ```r```, at the default origin; that is, (0,0).
* Circle - the extended syntax is ```circle [radius=r]```, which draws a circle with the center at the current coordinate and a radius of ```r```.
* Ellipse: ```ellipse [x radius = rx, y radius = ry]``` draws an ellipse with a horizontal radius of rx and a vertical radius of ry. The short form is ```ellipse (rx and ry)```.
* Arc: ```arc[start angle=a, end angle=b, radius=r]``` gives a part of a circle with a radius of ```r``` at the *current coordinate*, starting from angles ```a``` to angles ```b```. The short command version is ```arc(a:b:r)```.
* Arc: ```arc[start angle=a, end angle=b, x radius=rx, y radius=ry]``` gives a part of an ellipse with an x radius of ```rx``` and a y radius of ```ry``` at the *current coordinate*, starting from angle ```a``` and going to angle ```b```. The short syntax would be ```arc(a:b:rx and ry)```.


## Drawing and Positioning Nodes with TikZ

In TikZ, a node is a piece of text that can have a specific shape.
By default, nodes have a *rectangular* shape but you can choose between many other shapes, such as circles, ellipses, polygons, stars, clouds, and many more.
Using shapes other than rectangles and circles requires loading the shapes library.
To use the *shapes* library (often also called shapes package), add this line to your TikZ document:

```
\usetikzlibrary{shapes}
```

The following are rules of thumb to note:
* The node text is in curly braces and is always required
* Coordinates are in parentheses
* Design options are in square brackets


When you want TikZ to also draw the *border*, add the draw option to the node:

```
\draw (4,2) node[draw] {Test Node};
```

You can choose a border colour, fill it with a color, and choose a text colour.
For example:

```
\draw (4,2) node[draw, color=red, fill=yellow, text=blue] {Test Node};
```

Since nodes are used often, there is the ```\node``` command for drawing them.

Consider the following command:

```
\draw (4,2) node [draw] {Test Node};
```

You could write the following instead.


A node with a border:

```
\node [draw] at (4,2) {Test Node};
```

A node without a border:

```
\node at (4,2) {Test Node};
```

You can give nodes names.
You use parentheses for this.

Create three nodes: a rectangle node (r), a circle node (c), and an ellipse node (e):

```
\node (r) at (0,1)   [draw, rectangle] {Node 1};
\node (c) at (1.5,0) [draw, circle]    {Node 2};
\node (e) at (3,1)   [draw, ellipse]   {Node 3};
```

You can use these names for later drawings.
For example, now you can add arrows from one node to another, using *compass directions*, such as north, south, east, west, and others:

```
\draw[->] (r.east)  -- (e.west);
\draw[->] (r.south) -- (c.north west);
\draw[->] (e.south) -- (c.north east);
```

These compass directions are called **anchors**.
That's because you can use them to anchor a node on a position.
For example, to put a red-filled circle at (4,2) and then add a rectangular node:

```
\draw[fill=red] (4,2) circle[radius=0.1];
\node at (4,2) [draw, rectangle] {Node with Red Anchor Example};
```

You can see that the rectangle node is placed in a way that its center is at the given coordinate of (4,2).
If you want to have (4,2) as the southwest corner, you can define this corner as the anchor of the node:

```
\draw[fill=red] (4,2) circle[radius=0.1];
\node at (4,2) [draw, rectangle, anchor=south west]{Node with SW Anchor};
```

## Using Shapes and Anchors with TikZ

While rectangle and circle node shapes are available by default, others require loading the *shapes* package.
To load the shapes package (strictly speaking it's a library, not a package), add this line to your LaTeX document:

```
\usetikzlibrary{shapes}
```

Some of the shapes from the shapes TikZ library:

circle
circle split
semicircle
circular sector
forbidden sign
dart
kite
isosceles triangle
diamond
regular polygon (5 sides)
regular polygon (6 sides)
regular polygon (8 sides)
trapezium
cloud
start
startbust
cylinder
signal
tape
magnetic tape
ellipse

rectangle:
```\node (r) at (0,2) [draw, rectangle] {Node 1};``` 

rectangle split: 
```
\node (r) at (0,2) [draw, rectangle split] {Node 1};
\node (r) at (0,2) [draw, rectangle split horizontal=true, rectangle split] {Node 1};
\node (r) at (0,2) [rectangle split horizontal=false, rectangle split parts=3, rectangle split, draw] {Node 1};
\node (r) at (0,2) [rectangle split, rectangle split parts=3, draw, rectangle split horizontal] {Node 1};
```

coordinate

A **coordinate** is a node with empty text and the coordinate shape, meaning it has *zero width and height* values.
It has the same anchor names as a default rectangle node but of course all anchors are equal here so you don't need to specify any anchor.

```
\coordinate (begin) at (2,0);
\coordinate (end)   at (4,2);
```

Or:

```
\node[shape=coordinate] (begin) at (2,0) {};
\node[shape=coordinate] (end) at (4,2) {};
```

Many shapes provide particular options, such as the number of puffs in a cloud, the number of parts in a split rectangle, aspect ratio, angles, and of course, the standard options for colour, filling, rotation, line width, and many more.

Once nodes and anchors are understood, it's often not much more complicated than selecting the desired shape, using the comprehensive manual to choose from the available design options for shapes, selecting colours, and then doing some fine-tuning on dimensions.

Apart from libraries, other packages use TikZ and build on it.
One is the *tikzpeople* package, which provides shapes of people.
It was originally intended to depict the usage of cryptographic protocols between parties.

To load the tikzpeople package, add the following line in the preamble of your LaTeX document.

```
\usepackage{tikzpeople}
```

----

## Hello World in TikZ

To place a simple piece of text on the coordinates x=4 and y=2:

```
\draw (4,2) node {Hello, World!};
```

The short form (a.k.a. with the ```\node``` command):

```
\node (4,2) {Hello, World!};
```

The complete LaTeX code for Hello World in TikZ:


```
$ cat hello.tex
\documentclass{article}
\usepackage{tikz}

\begin{document}
\begin{tikzpicture}
  \node (4,2) {Hello, World!};
\end{tikzpicture}
\end{document}
```


To compile it to PDF:


```
$ latexmk -pdf hello.tex
```

View it with a PDF viewer.

```
$ mupdf hello.pdf 
```

----

## Package standalone - Create a PDF Containing Only an Image

To create a PDF containing of only an image (or a graph or diagram), use the *standalone*  package.

[Package standalone on CTAN - Compile TeX pictures stand-alone or as part of a document](https://ctan.org/pkg/standalone)

To actually use a package in a document, you need to include it in the document by using the ```\documentclass``` LaTeX keyword:

```
\documentclass[tikz,border=10pt]{standalone}
```

The *standalone* class allows you to create documents that consist only of *a single drawing* and *cuts* the PDF document to *the actual content*.

Therefore, you don't have a letter or A4 page with just a tiny drawing, plus a lot of white space and margins.

With the ```border=10pt``` option you get a small margin of 10 pt around the picture. Having a small margin looks nicer in a PDF viewer.

Since the *standalone* class is designed for drawings, it provides a *tikz* option.
As you set that option, the class loads TikZ automatically so you **don't have to add** ```\usepackage{tikz}``` anymore.

An example with *tikz* package: a block diagram with arrows, labels and symbols from [My Favorite Tikz Things - Alfonso R. Reyes](https://github.com/f0nzie/tikz_favorites/blob/develop/src/elem-add_tikz_symbols_to_block_arr+symbol+diagram+command+style.tex):

```
$ fetch -o tikzdiagex.tex \ 
 "https://raw.githubusercontent.com/f0nzie/tikz_favorites/develop/src/elem-add_tikz_symbols_to_block_arr%2Bsymbol%2Bdiagram%2Bcommand%2Bstyle.tex" 
```

```
$ latexmk -lualatex tikzdiagex.tex
```

Here is the compiled PDF: [tikzdiagex.pdf]({{ site.url }}/assets/txt/tikzdiagex.pdf)

----

## References
(Retrieved on Jun 14, 2024)

* [Collection of favorite TikZ graphics](https://github.com/f0nzie/tikz_favorites) - or  [My Favorite Tikz Things - Alfonso R. Reyes](https://f0nzie.github.io/tikz_favorites/) 

* [standalone Package on CTAN - Compile TeX pictures stand-alone or as part of a document](https://ctan.org/pkg/standalone)
