---
layout: post
title: "Jails with ZFS on FreeBSD"
date: 2024-03-28 20:13:41 -0700 
categories: freebsd jail container vm virtualization zfs sysadmin  
---

In this example, the host operating system [^1] is *FreeBSD 13*, with the following FreeBSD kernel and userland versions
* the version and patch level of the installed kernel (```-k```): 13.2-RELEASE-p4,
* the version and patch level of the running kernel (```-r```): 13.2-RELEASE-p4, 
* the version and patch level of the installed userland (```-u```) (a.k.a. user environment)): 13.2-RELEASE-p4.

```
$ freebsd-version -kru
13.2-RELEASE-p4
13.2-RELEASE-p4
13.2-RELEASE-p4
```

---


## Create a New ZFS Dataset for Your First Jail

```
$ zfs list | grep -i jail
``` 
 
```
$ ls -Alh /jail
ls: /jail: No such file or directory
```
 
```
$ sudo zfs create -o mountpoint=/jail zroot/jail
``` 
 
```
$ ls -Alh /jail
total 0
``` 
 
```
$ ls -ld /jail
drwxr-xr-x  2 root  wheel  2 Mar 28 21:15 /jail
``` 
 
```
$ zfs list | grep -i jail
zroot/jail                                                     96K   244G       96K  /jail
```


I will name the jail *burgundy*.

 
```
$ sudo zfs create zroot/jail/burgundy
``` 
 
```
$ zfs list | grep -i jail
zroot/jail                                                    192K   244G       96K  /jail
zroot/jail/burgundy                                            96K   244G       96K  /jail/burgundy
```
 
```
$ df -hT | grep -i jail
zroot/jail                         zfs        244G     96K    244G     0%    /jail
zroot/jail/burgundy                zfs        244G     96K    244G     0%    /jail/burgundy
```


## Create or Modify jail.conf Configuration File

```
$ ls -ld /etc/jail*
drwxr-xr-x  2 root  wheel  2 Jul 27  2022 /etc/jail.conf.d

$ ls -Alh /etc/jail.conf.d/
total 0
``` 
 
```
$ sudo vi /etc/jail.conf
```
  
```
$ ls -lh /etc/jail.conf
-rw-r--r--  1 root  wheel   464B Mar 28 21:42 /etc/jail.conf
```
 
```
$ cat /etc/jail.conf
mount.devfs;                         # Mount devfs inside the jail
exec.start="sh /etc/rc";             # Start command
exec.stop="sh /etc/rc.shutdown";     # Stop command
path="/jail/${name}";                # Path to the jail
host.hostname="${name}.myhost.lan";  # Hostname

burgundy {
    interface="ue0";
    ip4.addr = "192.168.1.20";       # IP address of the jail 
    allow.raw_sockets = 1;           # To allow ping(8) and traceroute(8)
    allow.chflags = 1;   # Treat privileged users as privileged inside the jail
}

# Don't import any environment variables when connecting
# from the host system to the jail (except ${TERM})
exec.clean;
```
 

## Install FreeBSD in the Jail with bsdinstall(8)

You can install the base system by extracting ```base.txz``` set or by downloading from git and compiling from source but I will install the base system by using [bsdinstall(8)](https://man.freebsd.org/cgi/man.cgi?query=bsdinstall&sektion=8).

```
$ sudo bsdinstall jail /jail/burgundy


 FreeBSD Installer
 -----------------------------------------------------------------------------
 +----------------------------|Mirror Selection|-----------------------------+
 | Please select the site closest to you or "other" if                       | 
 | you'd like to specify a different choice.  Also note                      |
 | that not every site listed here carries more than the                     |
 | base distribution kits.  Only Primary sites are                           |
 | guaranteed to carry the full range of possible distributions.             |
 | Select a site that's close!                                               |
 |                                                                           |
 | +-----------------------------------------------------------------------+ |
 | |           ftp://ftp.freebsd.org      Main Site                        | |
 | |           ftp://ftp.freebsd.org      IPv6 Main Site                   | |

---- snip ---  
 
 +---------------------------------------------------------------------------+
 |                    [  OK  ]     [Other ]     [Cancel]                     |
 +---------------------------------------------------------------------------+
```
    

After selecting your site:

```
        +-------------------|Distribution Select|--------------------+
        | Choose optional system components to install:              |
        | +--------------------------------------------------------+ |
        | |[ ] lib32_dbg 32-bit compatibility libraries (Debugging)| |
        | |[X] lib32     32-bit compatibility libraries            | |
        | |[ ] ports     Ports tree                                | |
        | |[ ] src       System source tree                        | |
        | |[ ] tests     Test suite                                | |
        | +--------------------------------------------------------+ |
        |                          [  OK  ]                          |
        +------------------------------------------------------------+
```


```
                   +--------|Fetching Distribution|-------+
                   | base.txz             [     76%     ] |
                   | lib32.txz            [   Pending   ] |
                   |                                      |
                   | Fetching distribution files...       |
                   |                                      |
                   |  +-Overall Progress---------------+  |
                   |  |               58%              |  |
                   |  +--------------------------------+  |
                   +--------------------------------------+


                   +---------|Archive Extraction|---------+
                   | base.txz             [     90%     ] |
                   | lib32.txz            [   Pending   ] |
                   |                                      |
                   | Extracting distribution files...     |
                   |                                      |
                   |  +-Overall Progress---------------+  |
                   |  |               88%              |  |
                   |  +--------------------------------+  |
                   +--------------------------------------+


FreeBSD Installer
========================

Please select a password for the system management account (root):
Typed characters will not be visible.
Changing local password for root
New Password:
Retype New Password:


+---------------------------|System Configuration|---------------------------+
| Choose the services you would like to be started at boot:                  |
| +------------------------------------------------------------------------+ |
| |[ ] local_unbound      Local caching validating resolver                | |
| |[X] sshd               Secure shell daemon                              | |
| |[ ] moused             PS/2 mouse pointer on console                    | |
| |[ ] ntpd               Synchronize system and network time              | |
| |[ ] ntpd_sync_on_start Sync time on ntpd startup, even if offset is high| |
| |[ ] powerd             Adjust CPU frequency dynamically if supported    | |
| |[X] dumpdev            Enable kernel crash dumps to /var/crash          | |
| +------------------------------------------------------------------------+ |
+----------------------------------------------------------------------------+
|                                  [  OK  ]                                  |
+----------------------------------------------------------------------------+
```


I selected the following services:

```
+---------------------------|System Configuration|---------------------------+
| Choose the services you would like to be started at boot:                  |
| +------------------------------------------------------------------------+ |
| |[ ] local_unbound      Local caching validating resolver                | |
| |[X] sshd               Secure shell daemon                              | |
| |[ ] moused             PS/2 mouse pointer on console                    | |
| |[X] ntpd               Synchronize system and network time              | |
| |[X] ntpd_sync_on_start Sync time on ntpd startup, even if offset is high| |
| |[ ] powerd             Adjust CPU frequency dynamically if supported    | |
| |[X] dumpdev            Enable kernel crash dumps to /var/crash          | |
| +------------------------------------------------------------------------+ |
+----------------------------------------------------------------------------+
|                                  [  OK  ]                                  |
+----------------------------------------------------------------------------+
```

```
                       +------|Add User Accounts|-----+
                       | Would you like to add users  |
                       | to the installed system now? |
                       +------------------------------+
                       |     [ Yes  ]    [  No  ]     |
                       +------------------------------+
```


Selected  [ Yes ]  in  'Add User Accounts'. 

```
FreeBSD Installer
========================
Add Users

Username: dusko
Full name: dusko
Uid (Leave empty for default): 
Login group [dusko]: 
Login group is dusko. Invite dusko into other groups? []: wheel
Login class [default]: 
Shell (sh csh tcsh nologin) [sh]: tcsh
Home directory [/home/dusko]: 
Home directory permissions (Leave empty for default): 
Use password-based authentication? [yes]: yes
Use an empty password? (yes/no) [no]: no
Use a random password? (yes/no) [no]: no
Enter password: 
Enter password again: 
Lock out the account after creation? [no]: no
Username   : dusko
Password   : *****
Full Name  : dusko
Uid        : 1001
Class      : 
Groups     : dusko wheel
Home       : /home/dusko
Home Mode  : 
Shell      : /bin/tcsh
Locked     : no
OK? (yes/no): yes
adduser: INFO: Successfully added (dusko) to the user database.
Add another user? (yes/no): no

Goodbye!
```


## Update rc.conf Configuration File

You will need to add these configuration variables to ```rc.conf```:
* ```jail_enable="YES"```   
* Optionally: ```jail_list="burgundy"```    

Enable jails on boot, and optionally add the name of the jail to the list of jails to automatically start on boot. 

```
$ sudo cp -i /etc/rc.conf /etc/rc.conf.bak
```

```
$ sudo sysrc jail_enable="YES"
```
 
```
$ sudo sysrc jail_list="burgundy"
```


### Network Setup with Jail's IP Address under the Same Subnet as Host

In my home setup I use IP *aliases* against my primary network interface.
(You use an *alias* when you want to establish an additional network address for an interface.)

In production (for example, for host with only one public IP address), you can use NAT (also known as NATing) on the host.
For that setup, use instructions provided below under section titled [Network Setup with Jail IP Address in Private Subnet and NAT with pf](#network-setup-with-jail-ip-address-in-private-subnet-and-nat-with-pf).


List of all available interfaces on the host system:

```
$ ifconfig -l
em0 lo0 ue0 vm-public
```

Network interfaces that are currently down:

```
$ ifconfig -l -d
em0 vm-public
```

Network interfaces that are active:

```
$ ifconfig -l -u
lo0 ue0
```


If you want to exclude *loopback* interfaces from the list of network interfaces displayed with the ```-l``` option, set  *address_family* parameter of the ```ifconfig(8)``` utility to ```ether```. On this system, the name of the active network interface is ```ue0```:	

``` 
$ ifconfig -l -u ether
ue0
``` 


Using the [ifconfig(8)](https://man.freebsd.org/cgi/man.cgi?query=ifconfig&sektion=8) utility, display the configuration of interfaces that are up with the exception of loopback:

```
$ ifconfig -a -u -G lo
ue0: flags=...
---- snip ----
```


From the output, select the line with the IP address of the network interface.

```
$ ifconfig -a -u -G lo | grep inet
        inet 192.168.1.10 netmask 0xffffff00 broadcast 192.168.1.255
```


To display the IP address of the network interface in CIDR notation (also known as the *slash notation*, or CIDR format), use the ```-f``` flag, which controls the output format of ```ifconfig(8)```.


```
$ ifconfig -a -u -G lo -f inet:cidr | grep inet
        inet 192.168.1.10/24 broadcast 192.168.1.255
```


Show routing tables.

```
$ netstat -r
Routing tables

Internet:
Destination        Gateway            Flags     Netif Expire
---- snip ----
```

From the output, select the line with the default gateway [^2].

```
$ netstat -r | grep default
default            192.168.1.254      UGS         ue0
```


For this setup; that is, when you use the jail's IP address under the same subnet as the host, which is the same subnet as gateway, if the IP address of ```ue0``` network interface of the host is ```192.168.1.10``` with gateway ```192.168.1.254```, then the jail IP address should be in the range of ```192.168.1.x```.

You need to add an alias for your active network adapter (in this case, ```ue0```) to the ```rc.conf``` configuration file.
For example, to add an alias with an IP address ```192.168.1.20``` to the network interface named ```ue0```, use the following command to add an IP alias entry for this to the ```rc.conf``` configuration file.

```
$ sudo sysrc ifconfig_ue0_alias0="inet 192.168.1.20/32"
```

```
$ diff \
 --unified=0 \
 /etc/rc.conf.bak \
 /etc/rc.conf
--- /etc/rc.conf.bak    2024-03-28 21:45:06.863268000 -0700
+++ /etc/rc.conf        2024-03-28 22:42:32.278941000 -0700
@@ -19,0 +20,3 @@
+jail_enable="YES"
+jail_list="burgundy"
+ifconfig_ue0_alias0="inet 192.168.1.20/32"
```


NOTE:  
If you create another jail later on and you want to create a new IP alias for it (for example with an IP address ```192.168.1.21```), you'd add it by using the following command. 

```
$ sudo sysrc ifconfig_ue0_alias1="inet 192.168.1.21/32"
```


NOTE:   
Alternatively, you can use ```ifconfig_⟨interface⟩_aliases``` variable, which has the same functionality as ```ifconfig_⟨interface⟩_alias⟨n⟩``` and can have all of entries in a variable like the following: 

```
$ sudo sysrc ifconfig_ue0_aliases="\
 inet 192.168.1.22 netmask 0xffffffff \
 inet 192.168.1.23 netmask 0xffffffff \
 inet 192.168.1.24 netmask 0xffffffff"
```


The ```ifconfig_⟨interface⟩_alias⟨n⟩``` variable also supports CIDR notation.


From
["ping: sendto: Can't assign requested address" in Jail](https://forums.freebsd.org/threads/ping-sendto-cant-assign-requested-address-in-jail.2019/):

> To allow networking, first, interface must be specified in jail.conf.
> That interface must exist in host's ifconfig and has alias containing subnet of jail's IP address because value of ```ip4.addr=``` in ```jail.conf``` will be added to interface specified in ```interface=```.
> If subnet of *ip4.addr* doesn't exist in that interface, jail's IP won't be added.
> 
> The easiest setup is to use jail's IP under the same subnet as the host, which is the same subnet as gateway.
> I.e., if *em0* of the host use IP 192.168.0.5 with gateway 192.168.0.1, then jail IP should be in range of 192.168.0.x.
> 
> For host with only one public IP e.g., 61.x.x.x, you have to use a private subnet by adding a subnet to network interface as an alias, specify jail's IP under that subnet, then use ```pf(4)``` to NAT that subnet to public IP.


When you are ready to start using jails, start ```jail``` service.

```
$ sudo service jail start 
```

```
$ sudo service jail status
 JID             IP Address      Hostname                      Path
 burgundy        192.168.1.20    burgundy.myhost.lan           /jail/burgundy
```
 

Use [jls(8)](https://www.freebsd.org/cgi/man.cgi?query=jls&sektion=8) to list jails.

```
$ jls
   JID  IP Address      Hostname                      Path
     1  192.168.1.20    burgundy.myhost.lan           /jail/burgundy
```


The version and patch level of the installed *userland* in the jail: 

```
$ sudo freebsd-version -j burgundy
13.2-RELEASE
```


To enter the jail from host (a.k.a. log in to the jail) - a.k.a. Run the shell in the jail with [jexec(8)](https://man.freebsd.org/cgi/man.cgi?query=jexec&sektion=8).

```
$ sudo jexec burgundy /bin/sh
```

The ```bsdinstall(8)``` doesn't intall a kernel into the jail.

From
[Chapter 17. Jails and Containers - FreeBSD Handbook - FreeBSD Documentation Portal](https://docs.freebsd.org/en/books/handbook/jails/): 

> Jails do not have a kernel.   
> They run on the host's kernel.

```
# freebsd-version -k
freebsd-version: unable to locate kernel
```

The jail's running kernel version and patch level are inherited from the host so they are the same as the host's running kernel and patch level:

```
# freebsd-version -r
13.2-RELEASE-p4
```

The jail's userland version and patch level:

```
# freebsd-version -u
13.2-RELEASE
```


```
# uname -a
FreeBSD burgundy.myhost.lan 13.2-RELEASE-p4 FreeBSD 13.2-RELEASE-p4 GENERIC amd64
```


In this instance, the resolver, ```/etc/resolv.conf```, in the jail had to be fixed:  

```
# cat /etc/resolv.conf 
# Generated by resolvconf
search example.com 
nameserver 1.2.3.4
nameserver 1.2.3.5
nameserver 192.168.1.254
nameserver 75.153.1.2

# ping -c2 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: icmp_seq=0 ttl=60 time=6.474 ms
64 bytes from 8.8.8.8: icmp_seq=1 ttl=60 time=6.261 ms

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 6.261/6.368/6.474/0.107 ms
```

```
# resolvconf -I
```


Add the host's gateway (```192.168.1.254```) to the jail's [resolv.conf(5)](https://man.freebsd.org/cgi/man.cgi?query=resolv.conf&sektion=5).

```
# printf "nameserver 192.168.1.254" | resolvconf -a ue0
```

```
# cat /etc/resolv.conf
# Generated by resolvconf
nameserver 192.168.1.254
```

```
# resolvconf -u
```

```
# cat /etc/resolv.conf
# Generated by resolvconf
nameserver 192.168.1.254
```

```
# ping -c2 192.168.1.254
PING 192.168.1.254 (192.168.1.254): 56 data bytes
64 bytes from 192.168.1.254: icmp_seq=0 ttl=64 time=1.415 ms
64 bytes from 192.168.1.254: icmp_seq=1 ttl=64 time=1.683 ms

--- 192.168.1.254 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 1.415/1.549/1.683/0.134 ms

# ping -c2 freebsd.org
PING freebsd.org (96.47.72.84): 56 data bytes
64 bytes from 96.47.72.84: icmp_seq=0 ttl=53 time=78.208 ms
64 bytes from 96.47.72.84: icmp_seq=1 ttl=53 time=78.663 ms

--- freebsd.org ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 78.208/78.436/78.663/0.228 ms
```


Logout from the jail.

```
# exit
```


On the host, restart ```netif``` and ```routing``` services.

```
$ sudo service netif restart && sudo service routing restart
```


```
$ sudo service jail status
 JID             IP Address      Hostname                      Path
 burgundy        192.168.1.20    burgundy.myhost.lan           /jail/burgundy
```
 
```
$ jls
   JID  IP Address      Hostname                      Path
     1  192.168.1.20    burgundy.myhost.lan           /jail/burgundy
```


You can also log in to the jail with ```ssh(1)```. 
 
```
$ nc -z -v 192.168.1.20 22
Connection to 192.168.1.20 22 port [tcp/ssh] succeeded!
```
 
``` 
$ ssh dusko@192.168.1.20
The authenticity of host '192.168.1.20 (192.168.1.20)' can't be established.
ED25519 key fingerprint is SHA256:k7pm7Z......................................
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.20' (ED25519) to the list of known hosts.
(dusko@192.168.1.20) Password for dusko@burgundy.myhost.lan:
FreeBSD 13.2-RELEASE-p4 GENERIC

Welcome to FreeBSD!

---- snip ----

dusko@burgundy:~ % ifconfig 
em0: flags=8822<BROADCAST,SIMPLEX,MULTICAST> metric 0 mtu 1500
---- snip ----
        status: no carrier
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
---- snip ----
ue0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
---- snip ----
        inet 192.168.1.20 netmask 0xffffffff broadcast 192.168.1.20
        media: Ethernet autoselect (1000baseT <full-duplex>)
        status: active
vm-public: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
---- snip ----
```


Logout from the jail.

```
dusko@burgundy:~ % exit
logout
Connection to 192.168.1.20 closed.
```

----


### Network Setup with Jail IP Address in Private Subnet and NAT with pf

Assumptions: 

* This system has only one public IP address: ```61.2.3.4```.
* The host system already has the ```rc.conf``` file with jail-related configuraiton variables:

```
$ cat /etc/rc.conf

---- snip ----

jail_enable="YES"
jail_list="burgundy"
```

```
$ cat /etc/jail.conf
# STARTUP/LOGGING
exec.start="/bin/sh /etc/rc";             # Start command
exec.stop="/bin/sh /etc/rc.shutdown";     # Stop command
exec.consolelog = "/var/log/jail_console_${name}.log";

# PERMISSIONS
allow.raw_sockets = 1;           # To allow ping(8) and traceroute(8)
mount.devfs;                     # Mount devfs inside the jail
# Don't import any environment variables when connecting
# from the host system to the jail (except ${TERM})
exec.clean;

# HOSTNAME/PATH
path="/jail/${name}";                # Path to the jail
host.hostname="${name}.myhost.lan";  # Hostname

burgundy {
    # NETWORK
    interface="ue0";
    ip4.addr="172.16.0.11";            # IP address of the jail

    allow.chflags = 1;   # Treat privileged users as privileged inside the jail
}
```


In this setup, you have to use a private subnet by adding a subnet to the network interface as an alias, specify jail's IP address under that subnet, and then use [pf(4)](https://man.freebsd.org/cgi/man.cgi?query=pf&sektion=4) on the host to NAT to that subnet to the public IP address. 

Name of the active network interface is ```ue0```.


```
$ ifconfig -l 
ue0 lo0 vm-public tap0
 
$ ifconfig -l -d
vm-public tap0
 
$ ifconfig -l -u
ue0 lo0
 
$ ifconfig -l -u ether
ue0
```

```
$ ifconfig -a -u -G lo | grep inet
        inet 61.2.3.4 netmask 0xffffff00 broadcast 61.2.3.255 
```


Add a private network subnet as an alias against your active network adapter. 
For example, to add a subnet ```172.16.0.0/24``` to the network interface named ```ue0```, use the following command, which adds the subnet alias entry for this to the ```rc.conf``` configuration file.

```
$ sudo sysrc ifconfig_ue0_aliases="inet 172.16.0.0/24"
```


Next, add two configuration variables (```gateway_enable="YES"``` and ```pf_enable="YES"```) to the ```/etc/rc.conf``` configuration file. 

``` 
$ sudo sysrc gateway_enable="YES"
$ sudo sysrc pf_enable="YES"
```


```
$ cat /etc/rc.conf

---- snip ----

jail_enable="YES"
jail_list="burgundy"
gateway_enable="YES"
pf_enable="YES"
```


Load ```pf.ko``` module.
(Alternatively, you can restart your FreeBSD host.) 

```
$ sudo kldload pf
``` 


Create the ```pf.conf``` packet filter configuration file [^3].

```
$ sudo vi /etc/pf.conf
```
 

```
$ cat /etc/pf.conf
IP_PUB="61.2.3.4" 
NET_JAIL="172.16.0.0/24"
nat pass on ue0 from $NET_JAIL to any -> $IP_PUB
```


Start the ```pf``` service. 

```
$ sudo service pf start
```


To enter the jail from host (a.k.a. log in to the jail), run the usual [jexec(8)](https://man.freebsd.org/cgi/man.cgi?query=jexec&sektion=8) command:

```
$ sudo jexec burgundy /bin/sh
```

----


## References   
(Retrieved on Mar 28, 2024)   

[Chapter 17. Jails and Containers - FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/jails/) |
[Unadulterated Jails, the Simple Way](https://wiki.freebsd.org/VladimirKrstulja/Guides/Jails) |
[Jails - FreeBSD Wiki](https://wiki.freebsd.org/Jails) |
[Starting with FreeBSD jails](https://rubenerd.com/starting-with-freebsd-jails/) |
[Jails on FreeBSD are easy without ezjail](https://blog.frankleonhardt.com/2019/jails-on-freebsd-are-easy-without-ezjail/) |
[Using freebsd-update to upgrade jails](https://rubenerd.com/using-freebsd-update-to-upgrade-jails/) |
[ping: sendto: Can't assign requested address in Jail - FreeBSD Forums](https://forums.freebsd.org/threads/ping-sendto-cant-assign-requested-address-in-jail.2019/) |
[jupdate.sh - Jail update shell script by Felix J. Ogris - Run freebsd-update, portsnap, and portmaster on the host system and inside each running jail](https://ogris.de//howtos/jupdate.sh) |
[FreeBSD Experiment 1: Jails](https://www.benburwell.com/posts/freebsd-jails/) |
[Jails on FreeBSD](https://ogris.de//howtos/freebsd-jails.html) |
[Creating Comfy FreeBSD Jails Using Standard Tools - Posted on Jan 17, 2021](https://web.archive.org/web/20210125235815/https://kettunen.io/post/standard-freebsd-jails/) |
[Creating Comfy FreeBSD Jails Using Standard Tools - Discussion on Hacker News](https://news.ycombinator.com/item?id=25813800) |
[SysAdvent- Day 14 - FreeBSD Jails - Posted on Dec 14, 2010](https://sysadvent.blogspot.com/2010/12/day-14-freebsd-jails.html) |
[FreeBSD Jail Quick Setup with Networking](https://www.shaka.today/freebsd-jail-quick-setup-with-networking-2022/) |
[Networking FreeBSD Jails](https://blog.frankleonhardt.com/2020/networking-freebsd-jails/) |
[FreeBSD Jail with Single IP](http://kbeezie.com/freebsd-jail-single-ip/) |
[FreeBSD Jails And Networking](https://etherealwake.com/2021/08/freebsd-jail-networking/) |
[Re: chflags(7) in a hardening and security context, <https://forums.freebsd.org/posts/633105>](https://forums.freebsd.org/threads/my-freebsd-hardening-script.89523/page-2#post-633105) |
[Build yourself a little FreeBSD jail services box](https://rubenerd.com/build-yourself-a-freebsd-vpn-box/) |
[BSDInstall - FreeBSD Wiki](https://wiki.freebsd.org/BSDInstall)

FreeBSD Manual Pages - Manpages for:   
[jail.conf(5)](https://www.freebsd.org/cgi/man.cgi?query=jail.conf&sektion=5),
[bsdinstall(8)](https://man.freebsd.org/cgi/man.cgi?query=bsdinstall&sektion=8),
[jls(8)](https://www.freebsd.org/cgi/man.cgi?query=jls&sektion=8),
[jexec(8)](https://man.freebsd.org/cgi/man.cgi?query=jexec&sektion=8),
[rc(8)](https://man.freebsd.org/cgi/man.cgi?query=rc&sektion=8),
[service(8)](https://man.freebsd.org/cgi/man.cgi?query=service&sektion=8),
[ifconfig(8)](https://man.freebsd.org/cgi/man.cgi?query=ifconfig&sektion=8),
k[netstat(1)](https://man.freebsd.org/cgi/man.cgi?query=netstat&sektion=1),
[resolv.conf(5)](https://man.freebsd.org/cgi/man.cgi?query=resolv.conf&sektion=5),
[pf(4)](https://man.freebsd.org/cgi/man.cgi?query=pf&sektion=4),
[pf.conf(5)](https://man.freebsd.org/cgi/man.cgi?query=pf.conf&sektion=5)


----


## Footnotes

[^1]: When used with jails, a host is often called a "host system" or "host environment". 

[^2]: From the manpage for [netstat(1)](https://man.freebsd.org/cgi/man.cgi?query=netstat&sektion=1): "When netstat is invoked with the routing table option -r, it lists the available routes and their status.  Each route consists of a destination host or network, and a gateway to use in forwarding packets.  The flags field shows a collection of information about the route stored as binary choices.  The individual flags are discussed in more detail in the route(8) and route(4) manual pages.  The mapping between letters and flags is: 1 RTF_PROTO1 Protocol specific routing flag #1, 2 RTF_PROTO2 Protocol specific routing flag #2, 3 RTF_PROTO3 Protocol specific routing flag #3, B RTF_BLACKHOLE Just discard pkts (during updates), b RTF_BROADCAST The route represents a broadcast address, D RTF_DYNAMIC Created dynamically (by redirect), G RTF_GATEWAY Destination requires forwarding by intermediary, H RTF_HOST Host entry (net otherwise), L RTF_LLINFO Valid protocol to link address translation, M RTF_MODIFIED Modified dynamically (by redirect), R RTF_REJECT Host or net unreachable, S RTF_STATIC Manually added, U RTF_UP Route usable, X RTF_XRESOLVE External daemon translates proto to link address." Therefore, when letters in the **Flags** field are ```UGS```, it means: Route usable (```U``` for usable), Destination requires forwarding by intermediary (```G``` for gateway), Manually added (```S``` for static).

[^3]: From the manpage for [pf.conf(5)](https://man.freebsd.org/cgi/man.cgi?query=pf.conf&sektion=5): "FILES . . .  /etc/pf.conf  Default location of the ruleset file.  The file has to be created manually as it is not installed with a standard installation."

----

