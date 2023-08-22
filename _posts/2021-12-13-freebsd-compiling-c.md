---
layout: post
title: "How to Compile C Programs in FreeBSD"  
date: 2021-12-13 18:23:42 -0700 
categories: c programming freebsd howto 
---

OS:     FreeBSD 13  
Shell:  csh


```
% freebsd-version
13.0-RELEASE-p5
 
% ps $$
 PID TT  STAT    TIME COMMAND
6287  2  Ss   0:00.09 -csh (csh)
 
% printf %s\\n "$SHELL"
/bin/csh
```


```
% fetch \
 https://master.dl.sourceforge.net/project/yest/yest/2.7.0.7/yest-2.7.0.7.tgz
```

```
% tar xf yest-2.7.0.7.tgz
```

```
% ls -lh
total 22
-rwxr-xr-x  1 dusko  dusko   2.1K Jul 27  2014 README-2.7.0.7
-rw-r--r--  1 dusko  dusko    50K Jul 27  2014 yest-2.7.0.7.c
-rwxr-xr-x  1 dusko  dusko   8.4K Jul 27  2014 yest-2.7.0.7.man1
-rw-r--r--  1 dusko  dusko    17K Jul 28  2014 yest-2.7.0.7.tgz
```

```
% cc yest-2.7.0.7.c
```

```
% ls -lhrt
total 59
-rwxr-xr-x  1 dusko  dusko   8.4K Jul 27  2014 yest-2.7.0.7.man1
-rwxr-xr-x  1 dusko  dusko   2.1K Jul 27  2014 README-2.7.0.7
-rw-r--r--  1 dusko  dusko    50K Jul 27  2014 yest-2.7.0.7.c
-rw-r--r--  1 dusko  dusko    17K Jul 28  2014 yest-2.7.0.7.tgz
-rwxr-xr-x  1 dusko  dusko    50K Dec 13 18:23 a.out
```

```
% ./a.out
13/12/2021
```

```
% rm -i a.out
remove a.out? y
```

```
% cc -o yest yest-2.7.0.7.c
```

```
% ls -lhrt
total 59
-rwxr-xr-x  1 dusko  dusko   8.4K Jul 27  2014 yest-2.7.0.7.man1
-rwxr-xr-x  1 dusko  dusko   2.1K Jul 27  2014 README-2.7.0.7
-rw-r--r--  1 dusko  dusko    50K Jul 27  2014 yest-2.7.0.7.c
-rw-r--r--  1 dusko  dusko    17K Jul 28  2014 yest-2.7.0.7.tgz
-rwxr-xr-x  1 dusko  dusko    50K Dec 13 18:24 yest
```

```
% ./yest -3h
13/12/2021-15:24
```


## Compiling X (aka X11, aka Xorg) Programs

```
$ fetch https://raw.githubusercontent.com/leahneukirchen/xlossage/e09a0750d735ce
6e173f33c7912fd6245bd055cd/xlossage.c
```

### First Try 

```
$ cc -O2 -Wall -o xlossage xlossage.c -lX11 -lXi -g
xlossage.c:35:10: fatal error: 'X11/Xlib.h' file not found
#include <X11/Xlib.h>
         ^~~~~~~~~~~~
1 error generated.
```

Is the X11 library really missing from the system?

```
$ pkg info --regex libX11
libX11-1.7.2,1
```

```
$ pkg info --regex --full libX11 | grep Name
Name           : libX11
 
$ pkg info --regex --full libX11 | grep Comment
Comment        : X11 library
```


No, so where are the libX11 files located?


```
$ pkg query "%Fp" libX11 | wc -l
    1038
```

```
$ pkg query "%Fp" libX11 
/usr/local/include/X11/ImUtil.h
/usr/local/include/X11/XKBlib.h
/usr/local/include/X11/Xcms.h
/usr/local/include/X11/Xlib-xcb.h
/usr/local/include/X11/Xlib.h
/usr/local/include/X11/XlibConf.h
---- snip ----
/usr/local/lib/X11/XErrorDB
/usr/local/lib/X11/Xcms.txt
/usr/local/lib/X11/locale/C/Compose
/usr/local/lib/X11/locale/C/XI18N_OBJS
/usr/local/lib/X11/locale/C/XLC_LOCALE
---- snip ----
```

### Second Try and The Fix

Added the location of the X11 library by using the ```-I``` option:  
"Add the specified directory to the search path for include files."

```
$ cc -O2 -Wall -I/usr/local/include -o xlossage xlossage.c -lX11 -lXi -g
ld: error: unable to find library -lX11
ld: error: unable to find library -lXi
cc: error: linker command failed with exit code 1 (use -v to see invocation)
```

```
$ pkg info --regex libXi
libXi-1.8,1
libXinerama-1.1.4_2,1
 
$ pkg info --regex libXi-
libXi-1.8,1
```

```
$ pkg info --regex --full libXi- | grep Name
Name           : libXi
 
$ pkg info --regex --full libXi- | grep Comment
Comment        : X Input extension library
```

Where are the libXi (X Input extension library) files located? 

```
$ pkg query "%Fp" libXi | wc -l
      84
```

```
$ pkg query "%Fp" libXi 
/usr/local/include/X11/extensions/XInput.h
/usr/local/include/X11/extensions/XInput2.h
/usr/local/lib/libXi.a
---- snip ----
```

Use the ```-L``` option to add directory to library search path.

```
$ cc -O2 -Wall -I/usr/local/include -L/usr/local/lib \
 -o xlossage xlossage.c -lX11 -lXi -g
```

```
$ file xlossage
xlossage: ELF 64-bit LSB executable, x86-64, version 1 (FreeBSD), dynamically li
nked, interpreter /libexec/ld-elf.so.1, for FreeBSD 13.1, FreeBSD-style, with de
bug_info, not stripped
```

```
$ ./xlossage
```


### Another Way

Another way would be to use the application's Makefile.

```
$ fetch https://raw.githubusercontent.com/leahneukirchen/xlossage/e09a0750d735ce
6e173f33c7912fd6245bd055cd/Makefile
```

```
$ cat Makefile
CFLAGS=-O2 -Wall -g `pkg-config --cflags x11 xi`
LDFLAGS=`pkg-config --libs x11 xi`

all: xlossage

clean:
        rm -f xlossage
```

Run ```make(1)```.

```
$ make
cc -O2 -Wall -g `pkg-config --cflags x11 xi` `pkg-config --libs x11 xi` xlossage
.c  -o xlossage
```


```
$ file xlossage
xlossage: ELF 64-bit LSB executable, x86-64, version 1 (FreeBSD), dynamically li
nked, interpreter /libexec/ld-elf.so.1, for FreeBSD 13.1, FreeBSD-style, with de
bug_info, not stripped
```

```
$ ./xlossage
```

If you want to remove the executable:

```
$ make clean
```

---

## References

[How do I link X11 (-lX11) on FreeBSD?](https://www.reddit.com/r/freebsd/comments/di8u14/how_do_i_link_x11_lx11_on_freebsd/)

[Installing the X11 developer library](https://www.reddit.com/r/freebsd/comments/60756a/installing_the_x11_developer_library/)
