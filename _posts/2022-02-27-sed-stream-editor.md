---
layout: post
title: "sed - Stream Editor"
date: 2022-02-27 11:21:01 -0700 
categories: unix freebsd rhel linux howto oneliner sed cli terminal shell script
---

## Replacing Strings with sed(1) in csh on FreeBSD

### Replacing a Single String

OS: FreeBSD 13   
Shell: **csh** (**tcsh**)     


```
% freebsd-version
13.0-RELEASE-p7

% uname -m
amd64

% uname -p
amd64

% sysctl -d hw.machine_arch
hw.machine_arch: System architecture
 
% sysctl hw.machine_arch
hw.machine_arch: amd64

% ps $$
  PID TT  STAT    TIME COMMAND
93946  0  Ss   0:00.05 -csh (csh)
 
% printf %s\\n "$SHELL"
/bin/csh
```

---

```
% printf %s\\n "Line one/" "Line two/" "Line three/" "Line four/" > testfile.txt
```

```
% cat testfile.txt
Line one/
Line two/
Line three/
Line four/
```

Use ```sed(1)``` as ```grep(1)``` -- Search for a word "three" in 
a file (without changing the file content).  

```
% sed -n "/three/p" testfile.txt
Line three/
```

Print the line number(s) matching the search string.

```
% sed -n "/three/=" testfile.txt
3
```

Test replacing a string in a line in a file (without changing the file content) 
and with displaying the file. 

```
% sed -n "s/three/3/p" testfile.txt
Line 3/
```

Or:

```
% sed "/three/s/three/3/" testfile.txt
Line one/
Line two/
Line 3/
Line four/
```


Test replacing a string in a line of a file (without changing the file content) 
and with displaying only the new content of the line to be changed.  

```
% sed -n "/three/s/three/3/p" testfile.txt
Line 3/
```


Replace a string in a line of a file.  

```
% sed -i'.BAK' -e "/three/s/three/3/" testfile.txt
```

Or:

```
% sed -i.BAK -e "s/three/3/" testfile.txt
```

```
% diff --unified=0 testfile.txt.BAK testfile.txt
--- testfile.txt.BAK    2022-02-27 11:23:31.545997000 -0800
+++ testfile.txt        2022-02-27 11:23:39.753589000 -0800
@@ -3 +3 @@
-Line three/
+Line 3/
```

```
% cat testfile.txt
Line one/
Line two/
Line 3/
Line four/
```

```
% cp -i testfile.txt.BAK testfile.txt
overwrite testfile.txt? (y/n [n]) y
```


### Replacing Multiple Strings

Test replacing two strings (multiple strings), one of which is a special 
character (in this example, forward slash '/'), in a line of a file 
(without changing the file content) and with displaying only the new 
content of the line to be changed.  


```
% sed -n "/three/s/three\//3/p" testfile.txt
Line 3
```

```
% cat testfile.txt
Line one/
Line two/
Line three/
Line four/
```

Replace two strings (multiple strings), one of which is a special 
character (in this example, forward slash '/'), in a line of a file.   

```
% sed -i'.BAK' -e "/three/s/three\//3/" testfile.txt
```

```
% diff --unified=0 testfile.txt.BAK testfile.txt
--- testfile.txt.BAK    2022-02-27 11:24:10.790813000 -0800
+++ testfile.txt        2022-02-27 11:24:20.427687000 -0800
@@ -3 +3 @@
-Line three/
+Line 3
```

```
% cat testfile.txt
Line one/
Line two/
Line 3
Line four/
```


### Replacing Lines (Strings) with Special Characters

```
% head -1 input.pl
#!/usr/bin/perl
```

```
% sed -i .bkp 's/\#\!\/usr\/bin\/perl/\#\!\/usr\/bin\/env perl/' input.pl
```

```
% diff --unified=0 input.pl.bkp input.pl
--- input.pl.bkp        2022-02-27 12:53:28.352198000 -0700
+++ input.pl    2022-02-27 12:54:00.590181000 -0700
@@ -1 +1 @@
-#!/usr/bin/perl
+#!/usr/bin/env perl
```

```
% head -1 input.pl
#!/usr/bin/env perl
```


**TODO: Which Title?**

### Replacing a Line with Partially Matched Strings within a Line

### The Match Criteria Does Not Have to be the Whole Line

You don't have to match the whole line.

Here's an example of [TODO]???  

```
% grep -n path ~/.cshrc
19:set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin)
```


Match a line with ```set path``` at the **beginning** of the line:

```
% sed -n '/^set path/p' ~/.cshrc
set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin)
```


Match a line with ```bin)``` at the **end** of the line:

```
% sed -n '/bin)$/p' ~/.cshrc
set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin)
```

Match a line with ```set path``` at the *beginning* of the line **and** 
with ```bin)``` at the *end* of the same line:

```
% sed -n '/^set path.*bin)$/p' ~/.cshrc
set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin)
```

```
% sed \
 -i.bkp \
 's/^set path.*bin)$/set path = (\/sbin \/bin \/usr\/sbin \/usr\/bin \/usr\/local\/sbin \/usr\/local\/bin \$HOME\/bin \$HOME\/.local\/bin)/' ~/.cshrc
```

NOTE:   
The following characters had to be escaped: forward slash (/) 
and the currency symbol a.k.a. a dollar sign ($).   


```
% diff \
 --unified=0 \
 /home/dusko/.cshrc.bkp \
 /home/dusko/.cshrc
--- /home/dusko/.cshrc.bkp      2022-02-27 16:44:09.410150000 -0700
+++ /home/dusko/.cshrc  2022-02-27 16:44:21.162085000 -0700
@@ -19 +19 @@
-set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin)
+set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin $HOME/.local/bin)
```


**NOTE:**  

The above example is for illustration purposes -- Of course, you could've 
appended the string by matching the end of the line and replacing that 
match with the needed string additon:

```
% sed -i.bkp 's/bin)$/bin \$HOME\/.local\/bin)/' ~/.cshrc
```


### Less Complicated Example

*Task:*    
In /etc/hosts file, replace a line 
```192.168.80.104 node104 node104.mycluster.myorg``` with this line
```192.168.80.4 node104```


```
$ cp -i /etc/hosts /tmp/hosts.bak.2
```


```
$ grep -n 104 /etc/hosts
24:192.168.80.104 node104 node104.mycluster.myorg
```

```
$ sed -n '/node104.mycluster.myorg/p' /etc/hosts
192.168.80.104 node104 node104.mycluster.myorg
```

```
$ sed -n '/^192.168.80.104/p' /etc/hosts
192.168.80.104 node104 node104.mycluster.myorg
```

```
$ sed -n '/^192.168.80.104/=' /etc/hosts
24
```

Why is this not matching?:

```
$ sed -n '/node104\.mycluster\.myorg$/p' /etc/hosts
```

From the man page for cat(1) for the option ```-e```: 
> Display non-printing characters (see the -v option), and display 
> a dollar sign ('$') at the end of each line.


```
$ grep 'node104\.mycluster\.myorg' hosts | cat -e
192.168.80.104 node104 node104.mycluster.myorg $
```

Aha, there's an extra space at the end of the line so with a space 
character at the end of the line this is now matching:


```
$ sed -n '/node104\.mycluster\.node $/p' /etc/hosts
192.168.80.104 node104 node104.mycluster.myorg 
```

Or, you could've used a single dot or period (```.```) - the wildcard 
symbol in regular expressions (regex) for matching a single character.  

```
$ sed -n '/node104\.mycluster\.myorg.$/p' /etc/hosts
192.168.80.104 node104 node104.mycluster.myorg 
```

The actual replacement:

```
$ sudo \
sed -i.bkp \
's/^192.*node104.mycluster.myorg.$/192.168.80.4 node104/' \
/etc/hosts
```

```
$ diff \
--unified=0 \
/etc/hosts.bkp \
/etc/hosts
--- /etc/hosts.bkp      2022-02-27 14:19:22.572122073 -0700
+++ /etc/hosts  2022-02-27 14:27:20.128832801 -0700
@@ -24 +24 @@
-192.168.80.104 node104 node104 node104.mycluster.myorg
+192.168.80.4 node104
```

```
$ diff \
--unified=0 \
/tmp/hosts.bak.2 \
/etc/hosts
--- /tmp/hosts.bak.2    2022-02-27 14:04:40.098265137 -0700
+++ /etc/hosts  2022-02-27 14:27:20.128832801 -0700
@@ -24 +24 @@
-192.168.80.104 node104 node104.mycluster.myorg
+192.168.80.4 node104
```

### Insert or Append a Line with sed(1)


Example for the following system:  
OS: CentOS 5.2 (RHEL 5.2)   
Shell: bash   
User: root  

Task:  
Add the following line to the end of the # Run gettys in standard 
runlevels section of the /etc/inittab file. (This enables hardware flow 
control and enables users to log in through the SOL (Serial Over LAN) console.)

```7:2345:respawn:/sbin/agetty -h ttyS1 19200 vt102```

```
# wc -l inittab
53 inittab
```


```
# grep -n tty6 /etc/inittab
50:6:2345:respawn:/sbin/mingetty tty6

# sed -n '/tty6/p' /etc/inittab
6:2345:respawn:/sbin/mingetty tty6

# sed -n '/tty6/=' /etc/inittab
50
```

```
# sed -n 44,50p /etc/inittab
# Run gettys in standard runlevels
1:2345:respawn:/sbin/mingetty tty1
2:2345:respawn:/sbin/mingetty tty2
3:2345:respawn:/sbin/mingetty tty3
4:2345:respawn:/sbin/mingetty tty4
5:2345:respawn:/sbin/mingetty tty5
6:2345:respawn:/sbin/mingetty tty6
```


Find lines with ```tty6``` at the end.

```
# sed -n '/tty6$/p' /etc/inittab
6:2345:respawn:/sbin/mingetty tty6
```

Keep ```tty6``` at the end of that line and add a new line below it.

```
# sed \
 -i.bkp \
 's/tty6$/tty6\n7:2345:respawn:\/sbin\/agetty -h ttyS1 19200 vt102/' \
 /etc/inittab
```

```
# diff \
 --unified=0 \
 /etc/inittab.bkp \
 /etc/inittab
--- /etc/inittab.bkp    2008-06-14 14:46:34.000000000 -0700
+++ /etc/inittab        2022-02-27 18:39:42.000000000 -0700
@@ -50,0 +51 @@
+7:2345:respawn:/sbin/agetty -h ttyS1 19200 vt102
```


## Replacing Strings with sed(1) in Bash on Linux

### Replacing a Single String


OS: RHEL 6.8 64-bit   
Shell:  **bash**    


```
# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 6.8 (Santiago)

# arch
x86_64

# ps $$
  PID TTY      STAT   TIME COMMAND
11324 pts/0    Ss     0:00 -bash

# printf %s\\n "$SHELL"
/bin/bash
```

---

```
$ printf %s\\n "Line one/" "Line two/" "Line three/" "Line four/" > testfile.txt
```

```
$ cat testfile.txt 
Line one/
Line two/
Line three/
Line four/
```

 
Use ```sed(1)``` as ```grep(1)``` -- Search for a string "three" in 
a file (without changing the file content).  

```
$ sed -n "/three/p" testfile.txt 
Line three/
```

Test replacing a string in a line in a file (without changing the file content).  

```
$ sed -n "s/three/3/p" testfile.txt 
Line 3/
```

Replace a string in a line of a file.

```
$ sed -i'.BAK' -e "s/three/3/" testfile.txt 
```

```
$ diff \
 --unified=0 \
 testfile.txt.BAK \
 testfile.txt
--- testfile.txt.BAK    2022-02-27 20:01:16.699001452 -0700
+++ testfile.txt        2022-02-27 20:05:02.583942777 -0700
@@ -3 +3 @@
-Line three/
+Line 3/
```


```
$ cat testfile.txt 
Line one/
Line two/
Line 3/
Line four/
```


```
$ cp -i testfile.txt.BAK testfile.txt
cp: overwrite `testfile.txt'? y
```


### Replacing Multipe Strings


Test replacing two strings (multiple strings), one of which is a special 
character (in this example, forward slash '/'), in a line of a file 
(without changing the file content) and with displaying only the new 
content of the line to be changed.  

```
$ sed -n "/three/s/three\//3/p" testfile.txt
Line 3
```


Replace two strings (multiple strings), one of which is a special 
character (in this example, forward slash '/'), in a line of a file.   

```
$ sed -i'.BAK' -e "/three/s/three\//3/" testfile.txt
```

```
$ diff \
 --unified=0 \
 testfile.txt.BAK \
 testfile.txt
--- testfile.txt.BAK    2022-02-27 20:43:44.959112954 -0700
+++ testfile.txt        2022-02-27 20:47:57.760371813 -0700
@@ -3 +3 @@
-Line three/
+Line 3
```

```
$ cat testfile.txt
Line one/
Line two/
Line 3
Line four/
```

---

### sed - Quoting and Special Characters in csh/tcsh Shell

On FreeBSD 13, with `csh` shell:

```
$ ps $$
 PID TT  STAT    TIME COMMAND
6578  4  Ss   0:00.22 -tcsh (tcsh)
 
$ printf %s\\n "$SHELL"
/bin/tcsh

$ diff /bin/csh /bin/tcsh
```


Let's say you need to change *sendmail* settings so that submitted mail is 
forwarded to the host *test.host.domain* for delivery, or for relaying
outward.  (In this example, it was needed to suppress MX lookups, which
is done by surrounding the hostname with square brackets.  Unless you
suppress it, the MSA will look up MX records for *test.host.domain*
and, if found, will deliver to the MX records found.) 

```
$ tail -1 /etc/mail/freebsd.submit.mc
FEATURE(`msp', `[127.0.0.1]')dnl
```

```
$ sudo sed -i.bkp -e 's/^FEATURE.*dnl$/FEATURE(`msp'"'"', `[test.host.domain]'"'"')dnl/' /etc/mail/freebsd.submit.mc
```

```
$ diff --unified=0 /etc/mail/freebsd.submit.mc.bkp /etc/mail/freebsd.submit.mc
--- /etc/mail/freebsd.submit.mc.bkp       2022-02-27 10:40:35.269642000 -0700
+++ /etc/mail/freebsd.submit.mc      2022-02-27 10:41:03.051256000 -0700
@@ -26 +26 @@
-FEATURE(`msp', `[127.0.0.1]')dnl
+FEATURE(`msp', `[test.host.domain]')dnl
```

Explanation:   
`s/^FEATURE.*dnl` - Find a line beginning with **FEATURE** and ending with **dnl**   
and replace it with this line:

```
FEATURE(`msp', `[test.host.domain]')dnl
```

In *csh*/*tcsh*, single and double quote marks quote each other:

```
$ echo '"'
"
 
$ echo "'"
'
```

```
$ echo "'" '"'
' "
```


So, quoting walk-through looks like this:

```
 To quote double quote marks: +   +                     +   +
                              |   |                     |   |
                              V   V                     V   V
's/^FEATURE.*dnl$/FEATURE(`msp'"'"', `[test.host.domain]'"'"')dnl/'
^                              ^  ^                      ^ ^      ^ 
|                              |  |                      | |      |
| To quote single quote marks: +  +                      + +      |
|                                                                 |
|                                                                 |
+-------  Everything is inside these single quoute marks  --------+
```


---

**References:**   
[use sed or awk command to replace a word with another word which is stored in variable](https://unix.stackexchange.com/questions/547274/use-sed-or-awk-command-to-replace-a-word-with-another-word-which-is-stored-in-va)   
