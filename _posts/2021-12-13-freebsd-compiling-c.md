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

