---
layout: post
title: "How To Install Graphviz Visual Editor on FreeBSD in a Linux Guest in Bhyve"
date: 2022-02-07 20:53:31 -0700 
categories: freebsd bhyve virtualization graphviz graph visualization 
---

Operating system:  FreeBSD 13.0 

**Note:**   
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.


### Install Graphviz Visual Editor

App:   
[Graphviz Visual Editor](https://github.com/magjac/graphviz-visual-editor)   
About  
"A web application for interactive visual editing of Graphviz graphs described in the DOT language."  
[http://magjac.com/graphviz-visual-editor](http://magjac.com/graphviz-visual-editor)   
(Retrieved on Feb 8, 2022)  


```
% sudo vm list
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    512M    -    No         Stopped
```


```
% sudo vm start -f debianvm1
```

Log in to Debian GNU/Linux VM.

```
Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login: 
```

Install Git and npm.

```
$ sudo apt install git
$ sudo apt install npm
```

```
$ mkdir ~/scratch
$ cd ~/scratch
$ git clone https://github.com/magjac/graphviz-visual-editor
$ cd graphviz-visual-editor/
```

```
$ npm install
$ make
```

```
$ npm run start
```

```
---- snip ----

Compiled successfully!

You can now view graphviz-visual-editor in the browser.

  Local:            http://localhost:3000/
  On Your Network:  http://192.168.8.19:3000/

Note that the development build is not optimized.
To create a production build, use npm run build.
```

Use a Web browser - on either GNU/Linux Debian guest VM or FreeBSD host 
and open ```http://192.168.8.19:3000/```.

To run it again:

```
$ cd ~/scratch/graphviz-visual-editor
$ npm run start
```

