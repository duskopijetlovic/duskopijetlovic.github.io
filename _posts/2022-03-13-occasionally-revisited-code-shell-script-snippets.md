---
layout: post
title: "Occasionally Revisited Code and Shell Script Snippets"
date: 2022-03-13 10:12:32 -0700 
categories: unix shell script cli terminal perl sysadmin
---

### Which shell I'm in?

```
$ ps $$
    PID TTY      STAT   TIME COMMAND
2612401 pts/0    Ss     0:00 -csh
```

```
$ printf %s\\n "$SHELL"
/bin/csh
```
---

### How to Set an Environment Variable for Just One Command In csh/tcsh?

Use a subshell:   

```
# (setenv XCATBYPASS "Y"; tabdump site)
```

Reference:   

[How to set an environment variable for just one command in csh/tcsh](https://stackoverflow.com/questions/5946736/how-to-set-an-environment-variable-for-just-one-command-in-csh-tcsh)  
(Retrieved on Mar 13, 2022)   


### How to set an Environment Variable for Just One Command in csh/tcsh and Pass It To sudo


```
% sudo "XCATBYPASS=Y" csh -c 'printf %s\\n "$XCATBYPASS"'
Y
```

**NOTE:**  This also works if you replace ```csh``` with ```tcsh```, 
or with ```sh```, or with ```bash```. (Tested on FreeBSD 13.0 and RHEL 8.4.)  


Reference:   

[Pass environment variable to sudo](https://stackoverflow.com/questions/40624957/pass-environment-variable-to-sudo)   
(Retrieved on Mar 13, 2022)   

---

### Set the Window Title in xterm(1)

From the man page for xterm(1) (OS: FreeBSD 13):  

```
[...]
For example, to set the window title to "Hello world!", you could use
one of these commands in a script:

  printf '\033]2;Hello world!\033\' 
  printf '\033]2;Hello world!\007'
  printf '\033]2;%s\033\' "Hello world!" 
  printf '\033]2;%s\007' "Hello world!"

The printf command interprets the octal value "\033" for escape, and
(since it was not given in the format) omits a trailing newline from
the output.

Some programs (such as screen(1)) set both window- and icon-titles at
the same time, using a slightly different control sequence:

  printf '\033]0;Hello world!\033\'
  printf '\033]0;Hello world!\007'
  printf '\033]0;%s\033\' "Hello world!"
  printf '\033]0;%s\007' "Hello world!"

The difference is the parameter "0" in each command.  Most window
managers will honor either window title or icon title.  Some will make
a distinction and allow you to set just the icon title.  You can tell
xterm to ask for this with a different parameter in the control
sequence:

printf '\033]1;Hello world!\033\'      <- The most portable apporach, with the
printf '\033]1;Hello world!\007'       <- parameter "1" - asks if the WM allows
printf '\033]1;%s\033\' "Hello world!" <- WM allows setting only the icon title.
printf '\033]1;%s\007' "Hello world!"  <- (Four different ways to do it.)
```

NOTE:  
This can be useful even if you don't use some window 
decorations (e.g.: no titlebars) in your window manager.
For example, in my current setup with `twm(1)` where I enabled the `NoTitle` 
variable in the `~/.twmrc`, I still find it useful to sometimes set the 
window title for some xterm windows as that makes their title visible 
in TWM's Icon Manager and that way helps with identifying which server 
I'm working on.    


### xterm(1)

> Fonts should be fixed width and, if both normal and bold are specified, 
> should have the same size.  If only a normal font is specified, it will 
> be used for both normal and bold text (by doing overstriking).  
> The -e option, if given, must appear at the end of the command line, 
> otherwise the user's default shell will be started.  
> Options that start with a plus sign (+) restore the default.

---

### sed(1) 

OS: CentOS Linux 7, Shell: bash   

```
$ grep -n ttyS0 /etc/securetty
24:ttyS0

$ sed -n '/ttyS0/p' /etc/securetty
ttyS0

$ sed -n '/ttyS0/=' /etc/securetty
24
```

### Perl

OS: CentOS Linux 5, Shell: bash   

You need to prepend the currency symbol (a.k.a. dollar sign) with
a backslash (\\) in a [heredoc](https://en.wikipedia.org/wiki/Here_document).

```
$ cat << EOF >> perl1.pl
#!/usr/bin/env perl
use strict;
use Getopt::Long;
use File::Basename;

my \$arguments=join(',',@ARGV);

print "\$arguments\n";
EOF
```

```
# chmod 0744 perl1.pl
```

```
$ ./perl1.pl testArg1 testArg2
testArg1,testArg2
```

### How to Get Physical Block Size in Linux?

```
# blockdev --getbsz /dev/sda
4096
```

If filesystem is XFS (property: **bsize**):

```
# df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
devtmpfs                devtmpfs  908M     0  908M   0% /dev
tmpfs                   tmpfs     919M     0  919M   0% /dev/shm
tmpfs                   tmpfs     919M  8.5M  911M   1% /run
tmpfs                   tmpfs     919M     0  919M   0% /sys/fs/cgroup
/dev/mapper/centos-root xfs       3.5G  1.3G  2.3G  36% /
/dev/sda1               xfs      1014M  150M  865M  15% /boot
tmpfs                   tmpfs     184M     0  184M   0% /run/user/0
```

```
# xfs_info /dev/mapper/centos-root
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=229120 blks
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=916480, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

```
# xfs_info /dev/mapper/centos-root | grep bsize
data     =                       bsize=4096   blocks=916480, imaxpct=25
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
```

```
# xfs_info /boot | grep bsize
data     =                       bsize=4096   blocks=262144, imaxpct=25
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
```

### Running Commands on a Remote Machine with ssh(1)

```
$ ssh user@example.org "df -hT"
user@example.org's password: 
Filesystem    Type    Size  Used Avail Use% Mounted on
/dev/sda1     ext3    263G   26G  224G  11% /
tmpfs        tmpfs    7.9G     0  7.9G   0% /dev/shm
mgmt:/home     nfs    5.0T  1.7T  3.3T  34% /home
mgmt:/global   nfs    3.9T  636G  3.3T  16% /global
```

### Delete All Hidden Files with rm(1)  

```
$ ls -alh /mnt/customdvd/
total 8.0K
drwxr-xr-x  2 root root  40 Apr 23 15:54 .
drwxr-xr-x. 5 root root  50 Apr 22 16:17 ..
-rw-r--r--  1 root root  29 Oct 26  2020 .discinfo
-rw-r--r--  1 root root 354 Oct 26  2020 .treeinfo
 
$ ls -lh /mnt/customdvd/.[a-z0-9]*
-rw-r--r-- 1 root root  29 Oct 26  2020 /mnt/customdvd/.discinfo
-rw-r--r-- 1 root root 354 Oct 26  2020 /mnt/customdvd/.treeinfo

$ sudo rm -i /mnt/customdvd/.[a-z0-9]*
rm: remove regular file '/mnt/customdvd/.discinfo'? y
rm: remove regular file '/mnt/customdvd/.treeinfo'? y

$ ls -alh /mnt/customdvd/
total 0
drwxr-xr-x  2 root root  6 Apr 23 15:58 .
drwxr-xr-x. 5 root root 50 Apr 22 16:17 ..
```

---

### Jekyll Markdown Internal Links - aka Temporarily Disable Tag Processing

How can you link to internal content in Jekyll?   
A: You can post internal links by using the following:   

{% raw %}
```
[Some Link]{% post_url 2010-07-21-name-of-post %}
```
{% endraw %}


*Other options:*

{% raw %}
```
[Customize CentOS/RHEL DVD ISO for Installation in Text Mode via Serial Console and Test the Image with QEMU](http://localhost:4000/howto/virtualization/rs232serial/cli/terminal/shell/console/sysadmin/server/hardware/2022/03/12/centos-rhel-dvd-iso-customization-testing-with-qemu.html)
```
{% endraw %}

{% raw %}
```
[Customize CentOS/RHEL DVD ISO for Installation in Text Mode via Serial Console and Test the Image with QEMU](/howto/virtualization/rs232serial/cli/terminal/shell/console/sysadmin/server/hardware/2022/03/12/centos-rhel-dvd-iso-customization-testing-with-qemu.html)
```
{% endraw %}


**NOTE:**  How to actually display these code examples (with curly braces)?   
A:  Use raw and endraw tags (see below).   

[Jekyll Docs - Tags Filters](https://jekyllrb.com/docs/liquid/tags/):   
(Retrieved on Mar 13, 2022)   

> Jekyll processes all Liquid filters in code blocks
> 
> If you are using a language that contains curly braces, you will likely
> need to place {% raw %} {% raw %} {% endraw %}
> and {% raw %} {% endraw {% endraw %} {% raw %} %} {% endraw %}
> tags around your code. 
> 
> Since Jekyll 4.0, you can add `render_with_liquid: false` in your front 
> matter to disable Liquid entirely for a particular document.

[Liquid Documentation: Tags - Template](https://shopify.github.io/liquid/tags/template/):   
(Retrieved on Mar 13, 2022)   

> raw
> 
> Temporarily disables tag processing. This is useful for generating 
> certain content that uses conflicting syntax, such as 
> [Mustache](https://mustache.github.io/) or 
> [Handlebars](https://handlebarsjs.com/).  

-- References:    

[Jekyll Documentation - Linking to posts](https://jekyllrb.com/docs/liquid/tags/#linking-to-posts)   
(Retrieved on Mar 13, 2022)   

[Jekyll markdown internal links](https://stackoverflow.com/questions/4629675/jekyll-markdown-internal-links)    
(Retrieved on Mar 13, 2022)   

---

### How to Join Multiple PDF Pages into One PDF Document with Ghostscript

```
$ gs -q \
 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=merged.pdf \
 page01.pdf page02.pdf page03.pdf page04.pdf page05.pdf
```

---

