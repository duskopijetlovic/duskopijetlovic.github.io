---
layout: post
title: "How to Connect to Xorg in Linux Guest from Bhyve"
date: 2022-03-09 19:13:27 -0700 
categories: howto bhyve virtualization xorg x11 freebsd 
---

OS: FreeBSD 13   
Shell:  csh  


```
$ sudo vm list
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    512M    -    No         Stopped
```

```
$ sudo vm start debianvm1
Starting debianvm1
  * found guest in /vm/debianvm1
  * booting...
```


```
$ sudo vm console debianvm1


  Booting `Debian GNU/Linux'

Loading Linux 5.10.0-13-amd64 ...
Loading initial ramdisk ...

---- snip ----
Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login: dusko
Password:
```

In Linux guest:

```
$ sudo apt install tigervnc-standalone-server
```

```
$ vncserver -depth 32 -geometry 1680x1200
```

Output:

```
You will require a password to access your desktops.

Password:
Verify:
Would you like to enter a view-only password (y/n)? n

New Xtigervnc server 'debianvm1.chem.ubc.ca:1 (dusko)' on port 5901 
  for display :1.
Use xtigervncviewer -SecurityTypes VncAuth -passwd /home/dusko/.vnc/passwd :1 
  to connect to the VNC server.
```

```
$ ss -tulpn | grep vnc
tcp   LISTEN 0  5  127.0.0.1:5901   0.0.0.0:*  users:(("Xtigervnc",pid=1441,fd=9))
tcp   LISTEN 0  5      [::1]:5901      [::]:*  users:(("Xtigervnc",pid=1441,fd=10))
```

```
$ ip -4 address | grep inet
  inet 127.0.0.1/8 scope host lo
  inet 123.12.23.43/24 brd 123.12.23.255 scope global dynamic noprefixroute enp0s5 
  inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```

```
$ exit
logout
Connection to 123.12.23.43 closed.
```


In the FreeBSD host:

Make sure that you have a VNC client. 
If not, install one. 
For example, you can install tigervnc-viewer. 


```
$ sudo pkg install tigervnc-viewer
```

Forward a local port to the port used by VNC server in bhyve guest VM. 
In this example:  
- Local port: as the first 1024 ports are restricted to the root user only, and this example is for a non-root user, you can use any port above 1024, e.g. 9876 
- VNC server port in bhyve guest VM: 5901
- Bhyve guest VM's IP address: 123.12.23.43


```
$ ssh dusko@123.12.23.43 -L 9876:127.0.0.1:5901
```

Launch a separate shell instance and from there start ```vncviewer```, 
specifying the port you forwarded.  

```
$ vncviewer 127.0.0.1:9876
```

---


Reference:   
[Bhyve - how to configure Xorg in Linux guest - FreeBSD Forums](https://forums.freebsd.org/threads/bhyve-how-to-configure-xorg-in-linux-guest.82231/)   
(Thread started on Sep 28, 2021)    
(Retrieved on Mar 9, 2022)   

---

