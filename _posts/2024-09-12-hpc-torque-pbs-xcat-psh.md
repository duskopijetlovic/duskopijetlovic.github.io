---
layout: post
title: "HPC with TORQUE/PBS, xCAT, Gaussian and WebMO" 
date: 2024-09-12 20:32:08 -0700 
categories: hpc server hardware sysadmin automation configmanagement howto vm virtualization qemu kvm cli terminal shell linux unix networking
---

Updated: 2022-09-12

Initial post date: 2022-03-20

High Performance Computing (HPC) with *TORQUE* (Terascale Open-source *Resource* and QUEue *Manager*), PBS (Portable Batch System) *scheduling software*, xCAT (Extreme Cloud *Administration Toolkit*), using *Gaussian* software package via *WebMO*.

----

**[TODO]**  Add  merging  `/etc/passwd`, `/etc/shadow`,
                          `/etc/group`, and `/etc/gshadow`.   
---- 

*About xCAT*    

xCAT is a collection of mostly script based tools to build, configure, 
administer, and maintain computing clusters.

From [xCAT.org](http://xcat.org/index.html#quickstart):
> xCAT is an open-source tool for automating deployment, scaling, and 
> management of bare metal servers and virtual machines developed by IBM.
>
> xCAT is an official IBM High Performance Computing (HPC) cluster
> management tool.

---

*Scenario:*    

* New server hardware, Lenovo ThinkSystem SR530 - 7X08 (1U rack server),
  has just been installed in the existing cluster environment.   
* The existing cluster consists of 28 CNs (compute nodes). 
* The cluster is on a private Ethernet network.  The address space is 
non-routable (unroutable) so the compute nodes are "hidden" from 
a routable network, allowing you to separate your cluster logically 
from a public network.

*About the cluster environment in this scenario:*    
- All of the nodes use the same hardware and the same operating system.  

---

*Tasks:*  

On the new Lenovo server:   
* Create a guest VM to be used as the new MN (master node or management node)
  * On the guest VM (that is, the new MN): 
    * Install the latest xCAT version
    * Show examples of managing IBM Blade Center 
    * Show examples of related xCAT tables for the configuration
    * Remotely upgrade the OS on all CNs (computing nodes) 

---

*Where:* 

Computer cluster = a set of computers that work together so they can be 
viewed as a single system.  Computer clusters have each node (computer
used as a server) set to perform the same task. 

MN   = Master Node (`abacus.mydomain.com`) or Head Node (HN), aka Management Node or Controller Node - runs `pbs_server` daemon     
HN   = Head Node, see MN (Master Node)   
SN (IN) = Submit Node (Interactive) - client commands, e.g. `qsub` and `qhold`  
CN   = Compute Node (Execution Host) - Compute nodes run `pbs_mom` daemon  
xCAT = Extreme Cluster Administration Toolkit   
HPC  = High Performance Computing   
BMC  = Baseboard Management Controller    
IMM  = Integrated Management Module - aka as only MM (Management Module)   
AMM  = Advanced Management Module   
IPMI = Intelligent Platform Management Interface   
SNMP = Simple Network Management Protocol   
BC   = BladeCenter (IBM BladeCenter line of servers)    
SoL (also SOL) = Serial over LAN  
RM   = Resource Manager (also called a Job Scheduler or a Batch System)    
PBS  = Portable Batch System (scheduling software)   
MOM (also MoM) = Machine Oriented Miniserver    
MPI  = Message Passing Interface    
WebMO Basic = A web-based interface to computational chemistry packages   
WebMO Pro = An add-on to WebMO that provides additional calculations, visualization, and job management    
WebMO Enterprise = Extends WebMO Pro with nhancements for large numbers of users or computer clusters     
Fast Ethernet = 100 Mbps    
Gigabit Ethernet (GbE or 1 GigE) = 1,000 Mbps (1 Gbps; that is Gigabit per second)    

F1 Setup = IBM BladeCenter BIOS Setup (a.k.a. System/UEFI F1
Setup) - For example:
[BladeCenter HS21 Installation and User's Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.hs21.doc/hs21_install_ug.pdf), page 39 (Retrieved on Mar 20, 2022): "Using the Configuration/Setup Utility program":     
> When the Configuration/Setup utility message appears, press F1.  [...]   

---

*Operating systems and shells:*   
* MN: RHEL 8.5  (Red Hat Enterprise Linux release 8.5 (Ootpa)), Shell: tcsh 
* CNs: Upgrading from CentOS 5.2 to CentOS Linux 7.9, Shell: bash 

---

**Note:**   
In the following examples, IP addresses of network interfaces 
connected to the public network/Internet are from network subnet
`123.12.23.0`.  Replace those IP addresses with IP addresses of 
external interfaces in your environment.  Similarly, replace 
`123.12.23.254` with the broadcast address for external network 
interfaces in your environment.  

---

*Configuration:*  

Here is the hardware configuration in the environment:
* 2 x IBM BladeCenter H Chassis
  * Each chassis has 14 x IBM HS21 Blade Servers (Blades) - total
    of 28 compute nodes 
  * Each chassis has the IBM BladeCenter Advanced Management Module (AMM)
* 1 x IBM x3550 xServer (`xmgmt.mydomain.com`, old MN, kept temporary)   


* Newly installed server hardware: [Lenovo ThinkSystem SR530 - Type (Model) 7X08 - Product Home Page](https://datacentersupport.lenovo.com/de/en/products/servers/thinksystem/sr530/7x08)  

Here is the network configuration in the environment:
- eno1: Public-facing NIC.  External network (aka public VLAN): `123.12.23.x` 
- eno2: Cluster-facing NIC.  Internal network (aka xCAT VLAN):  `192.168.80.x`
- Management VLAN: `192.168.80.x` (BC MM, BC AMM, BC LAN switches)

--- 

## Content:  

* Create a QEMU VM Guest
* Configure the Guest with Two NICs in Two Separate Networks Connected 
to Two Bridges on Host
* Prepare the Management Node (MN)   
* Install and Configure xCAT (on the MN)  
* Stage 1: Add Your First Node and Control It with Out-Of-Band BMC Interface
* Stage 2: Add Your Second Node and Configure It for SOL (Serial Over LAN) 
Operation (aka Text Mode Console)
* Stage 3: Prepare Postscripts and Postbootscripts
* Tests
  * Submit a Test Job to a Specific Node (Compute Node)
* Setup NFS Server on the Head Node (HN) Running CentOS 8/RHEL 8
  * Configure Firewall Rules for NFS Server on CentOS 8/RHEL 8
  * Set Up NFS Client on Compute Nodes

---

## Create a QEMU VM Guest

This VM will be the xCAT MN (management node).   

* **Create QEMU VM guest on the new Lenovo server hardware**   
    (This VM will be the new **MN**)    
  **Note:**  I previously installed RHEL 8.5 on the new Lenovo server  
* **Install the most recent CentOS Linux version on the QEMU VM guest**  
    (At the time of this writing:  CentOS 7.9 Linux)    
  * Download and use CentOS DVD ISO image with everything   
    (file name: CentOS-7-x86_64-Everything-2009.iso)
  * Install CentOS 7.9 Linux in **text mode**

In order to conserve the limited bandwidth available, ISO images are not 
downloadable from mirror.centos.org.  To find a mirror closest to you in 
your region, visit the CentOS Project's website, 
[https://centos.org/](https://centos.org/).  Navigate to
Download > CentOS LInux > 7-2009 > x86_64.  For my region, the first listed 
mirror wtth the ISO images available was:  
http://mirror.esecuredata.com/centos/7.9.2009/isos/x86_64/.   


Follow these instructions: 
[Customize CentOS/RHEL DVD ISO for Installation in Text Mode via Serial Console and Test the Image with QEMU]({% post_url 2022-03-12-centos-rhel-dvd-iso-customization-testing-with-qemu %}).  

Changes that you need to make in `isolinux.cfg` and `grub.cfg` are shown below.

```
$ diff \
--unified=0 \
/mnt/dvd/isolinux/isolinux.cfg \
/mnt/customdvd/isolinux/isolinux.cfg
--- /mnt/dvd/isolinux/isolinux.cfg      2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/isolinux/isolinux.cfg        2022-03-20 08:59:36.911058507 -0700
@@ -64 +64 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet console=tty0 console=ttyS0,19200
@@ -70 +70 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet console=tty0 console=ttyS0,19200
@@ -86 +86 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet console=tty0 console=ttyS0,19200
@@ -96 +96 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet console=tty0 console=ttyS0,19200
```

```
$ diff \
--unified=0 \
/mnt/dvd/EFI/BOOT/grub.cfg \
/mnt/customdvd/EFI/BOOT/grub.cfg
--- /mnt/dvd/EFI/BOOT/grub.cfg  2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/EFI/BOOT/grub.cfg    2022-03-20 09:05:58.348907158 -0700
@@ -16,0 +17,4 @@
+serial --unit=0 --speed=19200 --word=8 --parity=no --stop=1
+terminal_input serial console=tty0 console=ttyS0,19200
+terminal_output serial console=tty0 console=ttyS0,19200
+
```

Continue following the instructions on the same page
([Customize CentOS/RHEL DVD ISO for Installation in Text Mode via Serial Console and Test the Image with QEMU]({% post_url 2022-03-12-centos-rhel-dvd-iso-customization-testing-with-qemu %})) up to the point of creating a raw image.
Then, instead of creating an image with `truncate` of 272 GB in size
(as in instructions on that page), create a raw image of 80 GB in size. 
Using seek option creates a sparse file, which saves space.

```
$ dd if=/dev/null of=xcatmn.img bs=1M seek=81920
```

Start CentOS 7.9 Linux installation with this command:

```
$ /usr/libexec/qemu-kvm \
-cdrom /tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso \
-drive format=raw,file=xcatmn.img \
-global ide-hd.physical_block_size=4096 \
-m 4G \
-boot d \
-enable-kvm \
-serial pty \
-nographic
```

Output:

```
QEMU 4.2.0 monitor - type 'help' for more information
(qemu) char device redirected to /dev/pts/2 (label serial0)
```

From QEMU monitor's output above, note where qemu redirected char
device.  In this case: `/dev/pts/2`.   

Open another shell instance, start `minicom` and connect to the first 
serial device where QEMU redirected char device (`/dev/pts/2`).   

```
$ minicom --baudrate=19200 --ptty=/dev/pts/2
```

Install CentOS Linux 7.9.

```
==========================================================================
==========================================================================
Installation

 1) [x] Language settings                 2) [!] Time settings
        (English (United States))                (Timezone is not set.)
 3) [!] Installation source               4) [!] Software selection
        (Processing...)                          (Processing...)
 5) [!] Installation Destination          6) [x] Kdump
        (No disks selected)                      (Kdump is enabled)
 7) [ ] Network configuration             8) [!] Root password
        (Not connected)                          (Password is not set.)
 9) [!] User creation
        (No user will be created)
  Please make your choice from above ['q' to quit | 'b' to begin installation |
  'r' to refresh]: 
```

```
2) Time settings > Set timezone > America > Vancouver  <-- Use your timezone
2) Time settings > Configure NTP servers > 
     Add NTP server > ntp1.serverinyourregion.org
     Add NTP server > ntp2.serverinyourregion.org   
4) Software selection > 3) Infrastructure Server
5) Installation Destination > QEMU HARDDISK: 80 GiB (sda) > Use All Space > LVM
7) Network configuration > 
     Set host name > xcatmn.mydomain.com
     Configure device ens3 >
        IPv4 address or "dhcp" for DHCP > dhcp
     IPv6 address > ignore
     Nameservers > 208.67.222.222,208.67.220.220  <-- Will list your nameservers
     Connect automatically after reboot
     Apply configuration in installer
8) Root password > 
     Password: 
     Password (confirm): 
9) User creation > 
     Create user > 
     Fullname >                                   <-- Enter your name 
     Username >                                   <-- Enter your username 
     Use password >
     Password >
       Password:
       Password (confirm):
     [X] Administrator > Groups wheel
```

```
==========================================================================
==========================================================================
Installation

 1) [x] Language settings                 2) [x] Time settings
        (English (United States))                (America/Vancouver timezone)
 3) [x] Installation source               4) [x] Software selection
        (Local media)                            (Infrastructure Server)
 5) [x] Installation Destination          6) [x] Kdump
        (Automatic partitioning                  (Kdump is enabled)
        selected)                         8) [x] Root password
 7) [x] Network configuration                    (Password is set.)
        (Wired (ens3) connected)
 9) [x] User creation
        (Administrator dusko will be
        created)
  Please make your choice from above ['q' to quit | 'b' to begin installation |
  'r' to refresh]: b
```

```
Progress
Setting up the installation environment
[...]
Installing libgcc (1/483)
Installing grub2-common (2/483)
Installing centos-release (3/483)
Installing setup (4/483)
Installing filesystem (5/483)
[...]

   Installation complete.  Press return to quit
```

In the CentOS 7.9 Linux installer, to switch to an interactive shell 
prompt with root privileges, press `Ctrl+b` `2` (two characters: 
ctrl-b, and '2').  

```
[anaconda root@localhost ~]#
```

Power off the VM.

```
[anaconda root@localhost ~]# poweroff
```


** **TIP:** **  If you cannot exit `minicom` with CTRL-X, first press Esc
                and then CTRL-X.   


To test and to confirm that the installed CentOS Linux 
really uses the first serial device ttyS0 (COM1) for a console,
start the QEMU guest VM by specifying the `-serial pty` option. 

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-enable-kvm \
-serial pty \
-nographic
```

Output:

```
QEMU 4.2.0 monitor - type 'help' for more information
(qemu) char device redirected to /dev/pts/2 (label serial0)
```

Open another shell instance, start `minicom` and connect to the first 
serial device where QEMU redirected char device, in this case, /dev/pts/2.

```
$ minicom --baudrate=19200 --ptty=/dev/pts/2
```

Can you see early boot messages/kernel log messages? If yes, that confirms
that the installed CentOS Linux uses the first serial device ttyS0 (COM1)
for a console. 

Log in to the guest virtual machine.

```
[...]
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

xcatmn login: root
Password:
```

At this point (in addition to the virtual loopback adapter
`lo0` [²](#footnotes) [³](#footnotes)), the guest VM has one Ethernet 
adapter, a.k.a. NIC (network interface controller or network interface 
card).  The name of that NIC that the OS (CentOS Linux) gave it to in 
this case is `ens3`. 

```
# nmcli device status
DEVICE  TYPE      STATE      CONNECTION
ens3    ethernet  connected  ens3
lo      loopback  unmanaged  --
```

```
# nmcli connection show
NAME  UUID                                  TYPE      DEVICE
ens3  0bb2148d-...........................  ethernet  ens3
```

Here, the guest is connected to the host via SLiRP (user networking), 
where the assigned IP address starts from `10.0.2.15`.

```
# ip -4 address show | grep inet
inet 127.0.0.1/8 scope host lo
inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic ens3
```

Show table routes (display the kernel routing tables):

```
# ip route
default via 10.0.2.2 dev ens3 proto dhcp metric 100 
10.0.2.0/24 dev ens3 proto kernel scope link src 10.0.2.15 metric 100 
```

Alternatively, you can display the routing tables with the legacy
`netstat(8)` tool:

```
# netstat -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
default         gateway         0.0.0.0         UG        0 0          0 ens3
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 ens3
```

Power off the guest VM.

```
# poweroff
```

---

## Configure the QEMU Guest VM with Two NICs in Two Separate Networks Connected to Two Bridges on Host 

Start the guest VM. 
This time don't use the serial device for console; rather, use only the 
`-nographic` option.   

The host is connected to a public network `123.12.23.x` (the network
contains a DHCP server).  The guest VM is connected to that network via
the first bridge `br0` and obtains a dynamic IP address.   

The host is also connected to another, private, cluster-facing
network, `192.168.80.x`.  The guest VM is connected to that
network via the second bridge `br1`.   


```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br0",id=hn0 \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br1",id=hn1 \
-device virtio-net-pci,netdev=hn0 \
-device virtio-net-pci,netdev=hn1 \
-nographic
```

Log into the guest OS.   

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

xcatmn login: root
Password: 
```

```
# nmcli device status
DEVICE  TYPE      STATE                                  CONNECTION         
eth0    ethernet  connected                              Wired connection 1 
eth1    ethernet  connecting (getting IP configuration)  Wired connection 2 
lo      loopback  unmanaged                              --                 
```

```
# nmcli connection show 
NAME                UUID                                  TYPE      DEVICE 
Wired connection 2  7ef26cf9-...........................  ethernet  eth1   
Wired connection 1  a9f5c51d-...........................  ethernet  eth0   
ens3                687a79e8-...........................  ethernet  --     
```

```
# ip -4 address show | grep inet
inet 127.0.0.1/8 scope host lo
inet 123.12.23.235/24 brd 123.12.23.255 scope global noprefixroute dynamic eth0
```

```
# ip route
default via 123.12.23.254 dev eth0 proto dhcp metric 100
123.12.23.0/24 dev eth0 proto kernel scope link src 123.12.23.235 metric 100
```

```
# netstat -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
default         gateway         0.0.0.0         UG        0 0          0 eth0
123.12.23.0     0.0.0.0         255.255.255.0   U         0 0          0 eth0
```

The name given by the OS (CentOS Linux) to the network interface 
controller/network interface card (NIC) connected to the **internal** 
(private/cluster-facing/xCAT, `192.168.80.x`) network is  `eth1`.    

Set the IP address of that NIC to **static** and assign it an IP address
from within `192.168.80.x` network.    

```
# nmcli connection show 'Wired connection 2' | grep 'ipv4.method'
ipv4.method:                            auto
```

```
# nmcli \
connection modify 'Wired connection 2' \
ip4 192.168.80.220/24 \
ipv4.method manual
```

The name given by the OS (CentOS Linux) to the network interface 
controller/network interface card (NIC) connected to the **public** 
(external/internet-facing, `123.12.23.x`) network is  `eth0`.    

Set the IP address of that NIC to **static**.

```
# nmcli connection show 'Wired connection 1' | grep 'ipv4.method'
ipv4.method:                            auto
```

**Note:**  
In the next command, replace IP addresses in `nmcli` connection's
properties `ip4`, `gw4` and `ipv4.dns` with IP addresses for those
properties in your environment. 

```
# nmcli \
connection modify 'Wired connection 1' \
ip4 123.12.23.235/24 gw4 123.12.23.254 \ 
ipv4.dns '208.67.222.222,208.67.220.220' \   <-- Use your DNS servers
ipv4.method manual
```

```
# nmcli \
connection modify 'Wired connection 1' \
connection.id eth0
```

```
# nmcli \
connection modify 'Wired connection 2' \
connection.id eth1
```


Restart NetworkManager service.

```
# systemctl restart NetworkManager.service 
```

If that doesn't refresh routing, use `nmcli(1)` to restart networking.
The `networking off` and `networking on` disables and then enables
networking control by NetworkManager.  All interfaces managed by
NetworkManager are deactivated when networking is disabled.

```
# nmcli networking off
# nmcli networking on
```

Check network connectivity state. The `check` argument tells
NetworkManager to re-check the connectivity. 

```
# nmcli networking connectivity check
full
```


```
# ip route
default via 123.12.23.254 dev eth0 proto static metric 100
123.12.23.0/24 dev eth0 proto kernel scope link src 123.12.23.235 metric 100
192.168.80.0/24 dev eth1 proto kernel scope link src 192.168.80.220 metric 101
```

```
# nmcli device status
DEVICE  TYPE      STATE      CONNECTION 
eth0    ethernet  connected  eth0       
eth1    ethernet  connected  eth1       
lo      loopback  unmanaged  --         
```

```
# nmcli connection show
NAME  UUID                                  TYPE      DEVICE 
eth0  a9f5c51d-...........................  ethernet  eth0   
eth1  7ef26cf9-...........................  ethernet  eth1   
ens3  687a79e8-...........................  ethernet  --     
```

Test connection to a public host.

```
# ping -c2 freebsd.org
PING freebsd.org (96.47.72.84) 56(84) bytes of data.
64 bytes from wfe0.nyi.freebsd.org (96.47.72.84): icmp_seq=1 ttl=50 time=76.1 ms
64 bytes from wfe0.nyi.freebsd.org (96.47.72.84): icmp_seq=2 ttl=50 time=76.1 ms
[...]
```

Test internal network connection.   

```
# ping -c2 192.168.80.210
PING 192.168.80.210 (192.168.80.210) 56(84) bytes of data.
64 bytes from 192.168.80.210: icmp_seq=1 ttl=64 time=0.477 ms
64 bytes from 192.168.80.210: icmp_seq=2 ttl=64 time=0.303 ms
[...]
```

Install `dnf(8)`. (From its man page:  DNF  is  the  next upcoming major 
version of YUM, a package manager for RPM-based Linux distributions.
It roughly maintains CLI compatibility with YUM and defines a strict API
for extensions and plugins.)


```
# yum install dnf dnf-data dnf-plugins-core
```

**Note:**    
In case of a bit older IBM blade servers, instead of **AMM**
(Advanced Management Module), chassis for older IBM blade servers
would have **MM** (Management Module).  In that case you would need
`telnet` to access the **MM** and you would need to install it:   

```
# dnf install telnet
```


## Prepare the Management Node (MN)

**[TODO]**  After the real cluster setup is finished,
change references to `xmgmt` (with IP address `192.168.80.200`) 
to the new(ly) installed server (with IP address `192.168.80.210`):

The cluster was partially upgraded in summer of 2021, and here's the list 
of those upgrades: 

* The WebMO server hardware was replaced.  It was an IBM blade server (HS20)
in a separate IBM chassis.   
The new server hardware is Lenovo ThinkSystem
SR530 - Type (Model) 7X08, with hostname `abacus.mydomain.com`, while the
"internal" hostname (for PBS software, TORQUE Resource Manager) is `mgmt`,
and the IP address on the cluster-facing network is `192.168.80.210`.   
  * This server has multiple roles: 
    * webserver (for running WebMO)
    * storage server, with a shared directory across the nodes (via NFS)
    * host for the majority of MN software (everything except DHCP server)  
      * **Note:** will move DHCP server to the new Lenove server later
* The OS on this server ("WebMO server") was updated from RHEL 5.2 to RHEL 8.4.   
* The storage server a.k.a. NFS server (named `xmgmtnfs.mydomain.com`) 
was moved from a separate legacy IBM SAN array to the new Lenovo server 
(Lenovo ThinkSystem SR530 - 7X08).  The new storage is a 6TB ZFS shared 
to CNs (compute nodes) via NFS.  The old hostname `xmgmtnfs.mydomain.com` 
was retired.   
* All PBS **managment** software and the both PBS management services
  (`pbs_server` and `pbs_sched`) were moved to the new server. 
  * The old xCAT (on the old MN, `xmgmt.mydomain.com`) was temporarily kept
    for managing BMC (two IBM chassis with 14 blades in each so 28 blades
    in total)  
  * The old MN (hostname: `xmgmt.mydomain.com`, IP address on the
    cluster-facing network: `192.168.80.200`) is kept and temporarily
    used as a DHCP server. 


### Configure DNS Settings  

**Note:** The hostname was set during the OS installation on the guest VM.  

```
# hostname
xcatmn.mydomain.com
```

```
# cat /etc/hostname 
xcatmn.mydomain.com
```

Update your `/etc/resolv.conf` with DNS settings and make sure that the 
node can visit `github` and `xcat` official website.

Configure any domain search strings and nameservers in 
the `/etc/resolv.conf` file.


```
# cat /etc/resolv.conf 
# Generated by NetworkManager
search xcatmn.mydomain mydomain.com 
nameserver 208.67.222.222   <-- Will show your DNS server 1
nameserver 208.67.220.220   <-- Will show your DNS server 2
```

Verify that your `/etc/hosts` file contains entries for all of your
management node interfaces.  Manually add any that are missing.

Add `xcatmn` into `/etc/hosts`.  

```
# printf %s\\n "192.168.80.220 xcatmn" >> /etc/hosts
```

```
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.80.220 xcatmn xcatmn.mydomain.com
```

Power off the guest virtual machine.

```
# poweroff
```


Start and run the guest VM in the background by using QEMU's
`-daemonize` option.    

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br0",id=hn0 \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br1",id=hn1 \
-device virtio-net-pci,netdev=hn0 \
-device virtio-net-pci,netdev=hn1 \
-daemonize
```

```
$ ps aux | grep -v grep | grep qemu
dusko     681555 94.6  2.1 4809628 678648 ?      Sl   15:39   0:21 /usr/libexec/qemu-kvm -drive format=raw,file=xcatmn.img -m 4G -netdev tap,helper=/usr/libexec/qemu-bridge-helper --br=br0,id=hn0 -netdev tap,helper=/usr/libexec/qemu-bridge-helper --br=br1,id=hn1 -device virtio-net-pci,netdev=hn0 -device virtio-net-pci,netdev=hn1 -daemonize
```

### Disable SELinux

```
# sed -i.bkp 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
```

```
# diff \
--unified=0 \
/etc/selinux/config.bkp \
/etc/selinux/config
--- /etc/selinux/config.bkp     2022-03-30 20:40:36.167508553 -0700
+++ /etc/selinux/config 2022-03-03 20:43:28.580246360 -0700
@@ -7 +7 @@
-SELINUX=enforcing
+SELINUX=disabled
```

A reboot is the most convenient way to make the disabling of SELinux 
take effect so if you want, you can now reboot and log in again.

## Install and Configure xCAT

Based on [xCAT Quick Start Guide](https://xcat-docs.readthedocs.io/en/latest/guides/get-started/quick_start.html) (retrieved on Mar 20, 2022) and then slightly modified.   


**Prerequisites and Assumptions**  

Assume there are two servers named `xcatmn.mydomain.com` and 
`abacus101.mydomain.com`.  The `xcatmn.mydomain.com` is going 
to be the MN (management node) [you can proably call it an 
"xCAT server" as well].  The `abacus101.mydomain.com` will 
be a compute node you will be provisioning.   


* They are in the same subnet `192.168.80.0`. 
* `abacus101.mydomain.com` is a CN (compute node), which is one of 14 blades in
   an IBM chassis.  The IBM chassis and the 14 included blades are managed
   by BMC, which the MN (`xcatmn.mydomain.com`) can access.
* `xcatmn.mydomain.com` has RHEL 8 installed, and uses an IP address `192.168.80.220`. 
* `xcatmn.mydomain.com` has access to internet.
* For the `abacus101.mydomain.com` compute node: BMC in the chassis that hosts this blade server, `abacus101.mydomain.com` (and other 13 blades running compute nodes on them), has an IP address `192.168.80.135`. 

* Prepare a full DVD for OS provision, and not a Live CD ISO.    
For this example, I use a **customized**
CentOS-7-x86_64-Everything-2009.iso DVD.
(See steps above.)

**BMC**  
MM1: 192.168.80.135   
MM2: empty   

**IBM BladeCenter Enclosure (Chassis)**   
Product Group: BladeCenter   
Type:  IBM BladeCenter E Type-8677  
Part no.: 39R8561   
FRU no.: 39R8563   
MM slots: 2   
Blade slots: 14   
I/O Module slots: 4   
Power Module slots: 4   
Blower slots: 2   

**14 blades** (14 blade servers)  
14 x IBM 8853-AC1 HS21 Bladeserver  
(Each blade is Machine Type: 8853, PID: 8853AC1)


**[TODO]**  After successul setup/test, add the info for the other chassis. 


All the following steps should be executed in `xcatmn.mydomain.com`.


```
# wget \
https://raw.githubusercontent.com/xcat2/xcat-core/master/xCAT-server/share/xcat/tools/go-xcat \
-O - > \
/tmp/go-xcat
```

```
# chmod +x /tmp/go-xcat
# /tmp/go-xcat install
```

Output:

```
[...]
If you are installing/updating xCAT-genesis-base separately, not as part
of installing/updating all of xCAT, run 'mknb <arch>' manually
[...]
Created symlink from /etc/systemd/system/multi-user.target.wants/xcatd.service
to /usr/lib/systemd/system/xcatd.service.

[...]
xCAT has been installed!
========================

If this is the very first time xCAT has been installed, run one of the
following commands to set the environment variables.

For sh:
    source /etc/profile.d/xcat.sh

For csh:
    source /etc/profile.d/xcat.csh
```

For choosing whether to run `For sh` or `For csh` command (script):   
The guest VM's shell is bash, which is intended to be compatible with the
original UNIX Bourne Shell (/bin/sh).    

```
# ps $$
  PID TTY      STAT   TIME COMMAND
 1532 pts/0    Ss     0:00 -bash

# printf %s\\n "$SHELL"
/bin/bash
```

So run the command `For sh`:

```
# source /etc/profile.d/xcat.sh
```

Verify xCAT installation.

```
# lsxcatd -a 
Version 2.16.3 (git commit d6c76ae5f66566409c3416c0836660e655632194, 
  built Wed Nov 10 09:58:20 EST 2021)
This is a Management Node
dbengine=SQLite
```

Check xCAT service status.

```
# systemctl status xcatd.service
```


xCAT creates the `site` table and the `networks` table automatically.

```
# tabdump site
[...]

# tabdump networks
[...]
```

Configure the system password for the **root** user on the
**compute nodes**.  For example, if you wanted to set the password
to `abc!!123(??)`:  

```
# chtab key=system passwd.username=root passwd.password='abc!!123(??)'
```

```
# tabdump passwd
#key,username,password,cryptmethod,authdomain,comments,disable
"system","root","abc!!123(??)",,,,
```

## Stage 1: Add Your First Node and Control It with Out-Of-Band BMC Interface

To get a list of data object types that are supported by xCAT:

```
# mkdef --help 
[...]
The following data object types are supported by xCAT:

auditlog boottarget eventlog firmware group kit kitcomponent kitrepo
monitoring network node notification osdistro osdistroupdate osimage
pdu policy rack route site taskstate zone zvmivp
[...]
```

To get a list of valid attribute names for each object type, use `mkdef`
with the `-h` option together with the `-t <object-types>` option.
For example, to get a list of valid attribute names for object type `node`:

```
# mkdef -h -t node
```

```
# mkdef -h -t node | grep ^ip
ip:    The IP address of the node. This is only used in makehosts.
The rest of xCAT uses system name resolution to resolve node names
to IP addresses.
```

```
# mkdef -h -t node | grep ^mac
mac:    The mac address or addresses for which xCAT will manage static
bindings for this node.    <-- a.k.a. MAC address of the node
[...]
```

```
# mkdef -h -t node | grep -w ^bmc
bmc:    The hostname of the BMC adapter.  <-- Or the BMC's IP address
```

To get the MAC address of the node with IP address 192.168.80.1:  

```
# ping -c2 192.168.80.1
```

```
# arp -a | grep '192.168.80.1'
? (192.168.80.1) at 00:11:22:33:44:55 [ether] on eth1
```

**Note:** If you don't have network connection with this node, you can
obtain its MAC address by logging in to the **AMM**/**MM** (**BMC**).
From Prerequisites (assumptions) above, you already know that
the BMC IP address is `192.168.80.135`.)


### Connecting to CLI on MM (AMM)   

```
# telnet 192.168.80.135
Trying 192.168.80.135...
Connected to 192.168.80.135.
Escape character is '^]'.

username: YOUR_BMC_USERID
password: YOUR_BMC_PASSWORD
```

The CLI command prompt is displayed:  

```
system>  
```


**[TODO]** Is it now **AMM** (advanced management module) because the BMC
was replaced on 2022-06-13?

You can now enter commands for the **AMM** (advanced management 
module)/**MM** (management module) [depending on whether your chassis 
uses **AMM** or **MM**].   

Display information on the first blade in the blade chassis.

**Note:**  Don't type **`system>`**   
It's a BMC CLI prompt, and it's shown here to indicate that you are 
using the AMM (or MM).   

```
system> info -T system:blade[1]
```

** **TIP:** **  You can shorten `-T system:blade[1]` to `-T blade[1]`: 

```
system> info -T blade[1]
[...]
MAC Address 1: 00:21:5E:2C:0E:D2
MAC Address 2: 00:21:5E:2C:0E:D4
MAC Address 3: Not Available
MAC Address 4: Not Available
[...]
```

Log off from the AMM CLI (or MM CLI).

```
system> exit
```

Back in the guest VM:  
(**Note:** This is optional; just to show where you can get information 
about node attributes.)  

List information about `bmcusername` and `bmcpassword` attributes for 
object type `node`.   


```
# mkdef -h -t node | grep ^bmcusername
bmcusername:    The BMC userid.  If not specified, the key=ipmi row
in the passwd table is used as the default.
```

```
# mkdef -h -t node | grep ^bmcpassword
bmcpassword:    The BMC password.  If not specified, the key=ipmi row
in the passwd table is used as the default.
```

You can use the `--template` option of the `lsdef(1)` command to display
the object definition templates shipped in xCAT.

To list all the object definition templates:

```
# lsdef --template 
```

Continuing with the setup:   
Create an xCAT data object definition for this node (name it `abacus101`).  
Explanation: `ip` = IP address of the node; `mac` = MAC address of
the node; `bmc` = IP address of the MM (BMC); `bmcusername` = username of
BMC (MM) account; `bmcpassword` = password for BMC (MM) user.   

```
# mkdef \
-t node abacus101 \
--template x86_64-template \
ip=192.168.80.1 \
mac=00:11:22:33:44:55 \
bmc=192.168.80.135 \
bmcusername=YOUR_BMC_USERID \
bmcpassword=YOUR_BMC_PASSWORD 
```

The domain of the xCAT node must be provided in an xCAT network definition
or the xCAT site definition.  Otherwise, two commands in the subsequent
steps for configuring DNS (`makehosts abacus101` and `makedns -n`) will
not work.

Currently, the domain is not defined in site table:

```
# tabdump site | grep domain
```

Add the `domain` key and value (in this example `mydomain.com)` to
the `site` table.  

```
# chtab key=domain site.value=mydomain.com
```

**Note:**   
Alternatively, instead of the `chtab(8)` command, you could use the
`chdef(1)` command to add the `domain` key (and value) to the `site` table:

```
# chdef -t site domain=mydomain.com
```


Update the `/etc/hosts` file with the `makehosts(8)` command to only 
replace the lines in the file that correspond to the node `abacus101`:

```
# makehosts abacus101
```

The node's IP address and hostname are added to `/etc/hosts`:

```
# tail -1 /etc/hosts
192.168.80.1 abacus101 abacus101.mydomain.com
```

Complete DNS setup by updating DNS records with the `makedns(8)` command.
(This also restarts `named` service.)


```
# makedns -n
```

```
# lsdef abacus101
Object name: abacus101
    arch=x86_64
    bmc=192.168.80.135
    bmcpassword=YOUR_BMC_USERID
    bmcusername=YOUR_BMC_PASSWORD
    cons=ipmi
    getmac=ipmi
    groups=all
    ip=192.168.80.1
    mac=00:11:22:33:44:55
    mgt=ipmi
    netboot=xnba
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
    serialport=0
    serialspeed=115200
    usercomment=the system X node definition
```

To get the list of data object types supported by xCAT:

```
# mkdef --help
```

Output:

```
[...]
The following data object types are supported by xCAT:
  auditlog boottarget eventlog firmware group kit kitcomponent kitrepo 
  monitoring network node notification osdistro osdistroupdate osimage 
  pdu policy rack route site taskstate zone zvmivp
```

To get a list of valid attribute names for each object type, use the
`mkdef(1)` command with the `-h` option together with the
`-t <object-types>` option.

For example, to get a list of valid attribute names for object type `node`: 

```
# mkdef -h -t node
```


### Fix for Blade - aka Touchup for Blade 

```
# mkdef -h -t node | grep -w ^mgt 
mgt:    The method to use to do general hardware management of the node.
This attribute is used as the default if power or getmac is not set.  
Valid values: openbmc, ipmi, blade, hmc, ivm, fsp, bpa, kvm, esx, rhevm.  
See the power attribute for more details.
```

```
# mkdef -h -t node | grep -w ^cons
cons:    The console method. If nodehm.serialport is set, this will default
to the nodehm.mgt setting, otherwise it defaults to unused.
Valid values: cyclades, mrv, or the values valid for the mgt attribute.

# mkdef -h -t node | grep -w ^serialport
serialport:    The serial port for this node, in the linux numbering style 
(0=COM1/ttyS0, 1=COM2/ttyS1).  For SOL on IBM blades, this is typically 1.
For rackmount IBM servers, this is typically 0.

# mkdef -h -t node | grep -w ^serialspeed
serialspeed:    The speed of the serial port for this node.  
For SOL this is typically 19200.

# mkdef -h -t node | grep -w ^power
power:    The method to use to control the power of the node. If not set,
the mgt attribute will be used.  Valid values: ipmi, blade, hmc, ivm, fsp,
kvm, esx, rhevm.  If "ipmi", xCAT will search for this node in the ipmi
table for more info.  If "blade", xCAT will search for this node in the
mp table.  If "hmc", "ivm", or "fsp", xCAT will search for this node in
the ppc table.
```

As this is a blade server, you need to change the following attributes
for the node object `abacus101`:  
`mgmt`, `getmac` and `cons`.   

In addition, this particular blade model, IBM **HS21**, does **not**
support **IPMI**:   

Per 
[[Ipmitool-devel] IBM gear](https://ipmitool-devel.narkive.com/gWukmQ01/ibm-gear) (Retrieved on Mar 20, 2022):    

> Unfortunately, the IBM Bladecenter does not expose IPMI over LAN. This
> comes from effort to maintain backwards compatibility with the days before
> IPMI existed and trying to make the POWER and x86 systems all act the same
> when in a chassis. Implementing remote management for CLI/scripting use
> can be done either by:   
> - Scripting the CLI (not bad if you set up ssh keys). [...]   
> - Using SNMP.     
> - Using some higher level software that knows how to speak IPMI and IBM
> Blade (requires extra setup).  For example with xCAT:
> 
> Power state of a KVM guest:
> 
> ```
> # rpower vmgt state
> vmgt: on
> ```
> 
> Power state of a blade:
> 
> ```
> # rpower h01 state
> h01: on
> ```

Also see:  
[Re: [Ipmitool-devel] 'ipmitool sol info' yields 'Invalid command'](https://www.mail-archive.com/ipmitool-devel@lists.sourceforge.net/msg00951.html) (Retrieved on Mar 20, 2022):   
> While the blades do communicate with the management module in a blade
> chassis using IPMI, they don't support doing SOL the way other platforms
> do.  Instead, to access the serial console you need to telnet to the
>  management module (MM or AMM), log in and then issue this command:

and  

[Re: [xcat-user] HS21 blade BMC](https://sourceforge.net/p/xcat/mailman/message/24363746/) (Retrieved on Mar 20, 2022):   
> The BMC IP address on all shipped IBM Blades to date is not useful for
> what you'd expect. The IPMI aspect of the service processor terminates
> within the chassis and the AMM will aggressively change the IP
> configuration of the BMCs via the dedicated management bus. For IBM
> BladeCenter, IPMI is only accessible via in-band methods. All
> out-of-band management is done either via SMASH CLP, SNMP (xCAT uses
> SNMP to implement IBM blade support), a BladeCenter CLI via telnet or
> SSH, a web interface, or IBM proprietary protocols that IBM Director uses.

and  


[IBM BladeCenter H and IPMI](https://communities.vmware.com/t5/vMotion-Resource-Management/IBM-BladeCenter-H-and-IPMI/td-p/278986)
(Retrieved on Mar 20, 2022):   
> Instructions in this section do not apply to IBM BladeCenters.
> IBM BladeCenter do not have IPMI remote access to the BMC on a Blade
> (the BMC IP address is not available outside of the BladeCenter).   


Continuing with the setup:   
Instead of IPMI, for remote control of this type of blade I use the
serial port so these two attributes need to be changed as well:
`serialport` and `serialspeed`.  

```
# lsdef -t node -o abacus101 -i cons,mgt,getmac,serialport,serialspeed
Object name: abacus101
    cons=ipmi
    getmac=ipmi
    mgt=ipmi
    serialport=0
    serialspeed=115200
```

Change xCAT data object definition for this node with the specified values
for attributes `cons`, `getmac`, `mgt`, `serialport` and `serialspeed`: 

```
# chdef \
-t node \
-o abacus101 \
cons=blade mgt=blade getmac=blade serialport=1 serialspeed=19200
```

```
# lsdef -t node -o abacus101 -i cons,mgt,getmac,serialport,serialspeed
Object name: abacus101
    cons=blade
    getmac=blade
    mgt=blade
    serialport=1
    serialspeed=19200
```

```
# lsdef abacus101
Object name: abacus101
    arch=x86_64
    cons=blade
    getmac=blade
    groups=all
    ip=192.168.80.1
    mac=00:11:22:33:44:55
    mgt=blade
    netboot=xnba
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
    serialport=1
    serialspeed=19200
    usercomment=the system X node definition
```


Check `abacus101` hardware control.   
`abacus101` power management:

```
# rpower abacus101 state
no mpa defined for node abacus101
```

### The mpa Table   

This table is where you put the information for a BladeCenter management
module (**MM**).      

```
# man mpa
NAME
       mpa - a table in the xCAT database.

SYNOPSIS
       mpa Attributes:  mpa, username, password, displayname, slots, urlpath,
       comments, disable

DESCRIPTION
       Contains info about each Management Module and how to access it.
[...]
```

```
# man mp
NAME
       mp - a table in the xCAT database.

SYNOPSIS
       mp Attributes:  node, mpa, id, nodetype, comments, disable

DESCRIPTION
       Contains the hardware control info specific to blades.  This table also
       refers to the mpa table, which contains info about each Management
       Module.
[...]
```

Add username and password for **MM** (**BMC**) to the `mpa` table.   
(This is the MM from `bmcusername` and `bmcpassword` in the above
`lsdef abacus101 [...]` command.  The `mpa` attribute in the command
below is that MM's hostname, which in this case is: `xbcmm1n`.)   

```
# chtab \
mpa=xbcmm1n \
mpa.username=YOUR_BMC_USERID \
mpa.password=YOUR_BMC_PASSWORD
```

```
# tabdump mpa 
#mpa,username,password,displayname,slots,urlpath,comments,disable
"xbcmm1n","YOUR_BMC_USERID","YOUR_BMC_PASSW0RD",,,,,
```

Add the BMC (MM) node to the `mp` table.
As the `mp` table refers to the `mpa` table, add the attribute `mpa` to
the table `mp`.  

```
# chtab \
node=xbcmm1n \
mp.mpa=xbcmm1n \
```

Similarly, add attributes of the newly added node (`abacus101`) to the
`mp` table: add the node's name (`node=abacus101`) and `id` (it's best to make
this number the same as the node name so in this case it's `1`).

```
# chtab \
node=abacus101 \
mp.mpa=xbcmm1n \
mp.id=1
```

```
# tabdump mp
#node,mpa,id,nodetype,comments,disable
"xbcmm1n","xbcmm1n",,,,
"abacus101","xbcmm1n","1",,,
```

The `mpa` attribute is now defined for node `abacus101`:

```
# lsdef abacus101 | grep mpa
    mpa=xbcmm1n
```


**Note:**   
Alternatively, you can display only attributes you are interested in by
using the `-i comma-separated-attr-list` option:

```
# lsdef abacus101 -i mpa
Object name: abacus101
    mpa=xbcmm1n
```

```
# lsdef abacus101
Object name: abacus101
    arch=x86_64
    cons=blade
    getmac=blade
    groups=all
    id=14
    ip=192.168.80.14
    mac=00:21:5E:2C:0A:AC
    mgt=blade
    mpa=xbcmm1n
    netboot=xnba
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
    serialport=1
    serialspeed=19200
    usercomment=the system X node definition
```

```
# tabdump passwd
#key,username,password,cryptmethod,authdomain,comments,disable
"system","root","abc!!123(??)",,,,
```

Add username and password for **MM** (**BMC**) to the `passwd` table.

```
# chtab \
key=blade \
passwd.username=YOUR_BMC_USERID \
passwd.password=YOUR_BMC_PASSWORD
```

```
# tabdump passwd
#key,username,password,cryptmethod,authdomain,comments,disable
"system","root","abc!!123(??)",,,,
"blade","YOUR_BMC_USERID","YOUR_BMC_PASSWORD",,,,
```

Verify that your `/etc/hosts` file contains entries for all of your
management node interfaces.  Manually add any that are missing.

Add **MM** (**BMC**) hostname (`xbcmm1n`) and its IP address
to `/etc/hosts` file.  

```
# printf %s\\n "192.168.80.135 xbcmm1n" >> /etc/hosts
```


Check `abacus101` hardware control.   
`abacus101` power management:


If there's an "Unsupported security level" error like the one shown below,
you need to add the MM (BMC) to xCAT database and to register it.

```
# rpower abacus101 state
abacus101: [xcatmn]: Error: Unsupported security level
```


To fix it, first check whether you can communicate with the MM (BMC):

```
# rspconfig xbcmm1n snmpdest
Error: Invalid nodes and/or groups in noderange: xbcmm1n
```

This particular MM (BMC) has not been added to xCAT database.
For now, xCAT has only one node:    

```
# nodels
abacus101
```

```
# lsdef xbcmm1n
Error: [xcatmn]: Could not find an object named 'xbcmm1n' of type 'node'.
No object definitions have been found
```

Discover all networked services information **within the cluster subnet**
(connected via the `eth1` network adapter with IP address `192.168.80.220`)
and write output to xCAT database:

```
# ip -4 address show eth1 | grep inet
    inet 192.168.80.220/24 brd 192.168.80.255 scope global noprefixroute eth1
```

```
# lsslp -i 192.168.80.220 -w
```

```
# nodels
Server--SNYK123456E1AB
abacus101
xbcmm1n
```

```
# lsdef xbcmm1n
Object name: xbcmm1n
    groups=mm,all
    id=0
    mgt=blade
    mpa=xbcmm1n
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
```

If a request for `snmpdest` from the MM (BMC) is empty as shown here:

```
# rspconfig xbcmm1n snmpdest
xbcmm1n: SP SNMP Destination 1: 
```

enable `snmpcfg` and `sshcfg`:

```
# rspconfig xbcmm1n snmpcfg=enable sshcfg=enable
xbcmm1n: SNMP enable: OK
xbcmm1n: SSH enable: OK
```

After that, request for `snmpdest` gets answered:

```
# rspconfig xbcmm1n snmpdest
xbcmm1n: SP SNMP Destination 1: 0.0.0.0
```

```
# rspconfig xbcmm1n snmpcfg
xbcmm1n: SNMP: enabled
```

```
# rspconfig xbcmm1n sshcfg 
xbcmm1n: SSH: enabled
```

While you are here, rename the **MM** (**BMC**) Server–SNYK123456E1AB 
(BMC on the other chassis) node to xbcmm2:

```
# chdef \
-t node \
-o Server--SNYK123456E1AB \
-n xbcmm2
```

Add username and password for **MM** (**BMC**) to the `mpa` table.

```
# chtab \
mpa=xbcmm2 \
mpa.username=YOUR_BMC_USERNAME \
mpa.password=YOUR_BMC_PASSWORD
```

For the same **MM** (**BMC**) node `xbcmm2`, change the `mpa` attribute in
the `mp` table (set it to be the same as the node name, that is `xbcmm2`).

```
# chtab
node=xbcmm2 \
mp.mpa=xbcmm2
```

Verify that your `/etc/hosts` file contains entries for all of your
management node interfaces.  Manually add any that are missing.

```
# printf %s\\n "192.168.80.127 xbcmm2" >> /etc/hosts
```


Back to continuing the node `abacus101` provisioning:

Hardware control check for power management for node `abacus101`
works now:

```
# rpower abacus101 state
abacus101: on
```

`abacus101` firmware information:

```
# rinv abacus101 all
abacus101: Machine Type/Model: 8853AC1
abacus101: Serial Number: KQCCXBT
abacus101: MAC Address 1: 00:21:5E:2C:0E:D2
abacus101: MAC Address 2: 00:21:5E:2C:0E:D4
abacus101: Management Module firmware: 36 (BPET36M 07-02-08)
```


### Provision a Node and Manage It with Parallel Shell

#### Configure DHCP

In order to PXE boot, you need a DHCP server to hand out IP addresses
and direct the booting system to the TFTP server where it can download
the network boot files.

Which networks `dhcpd` (dhcp daemon) should listen on can be controlled
by the `dhcpinterfaces` attribute in the `site(5)` table.
Add this attribute and set it to listen to only the
internal/private/cluster-facing network, which is connected to the `eth1` NIC.


```
# tabdump site | grep dhcp
"dhcplease","43200",,
```


Add the `dhcpinterfaces` attribute to the `site` table. 

```
# chtab key=dhcpinterfaces site.value=eth1
```

```
# tabdump site | grep dhcp
"dhcplease","43200",,
"dhcpinterfaces","eth1",,
```

A new dhcp configuration file is created by the `makedhcp(8)` command.
It requires that the `networks(5)` table is filled out properly.
Check the `networks(5)` table:

```
# tabdump networks
#netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,mtu,comments,disable
"123_12_23_0-255_255_255_0","123.12.23.0","255.255.255.0","eth0","123.12.23.254",,"<xcatmaster>",,,,,,,,,,,"1500",,
"192_168_80_0-255_255_255_0","192.168.80.0","255.255.255.0","eth1","<xcatmaster>",,"<xcatmaster>",,,,,,,,,,,"1500",,
```

While you are here, change the name of the cluster's network:

```
# chtab \
net=192.168.80.0 \
networks.netname=abacusnet
```

Note that before running the next command (`makedhcp -n`), 
the `dhcpd` (dhcp daemon) service is not running:

```
# systemctl is-active dhcpd.service
inactive
```

Create a new dhcp configuration file with a network statement for each
network the dhcp daemon should listen on.   
The `makedhcp(8)` command will automatically restart the `dhcpd` 
(dhcp daemon) after this operation.    
The `-n` option of the `makedhcp(8)` command replaces any existing 
configuration file, making a backup of it first.   

```
# makedhcp -n
```

Output:

```
Renamed existing dhcp configuration file to  /etc/dhcp/dhcpd.conf.xcatbak

Warning: [xcatmn]: No dynamic range specified for 192.168.80.0. 
If hardware discovery is being used, a dynamic range is required.
```

As I'm not using hardware discovery, I don't need to specify the `dynamicrange`
attribute in the `networks` table so I don't have to address the warning above. 


```
# ls -lhrt /etc/dhcp/dhcpd.conf*
-rw-r--r-- 1 root root  117 Oct  1  2020 /etc/dhcp/dhcpd.conf.xcatbak
-rw------- 1 root root 5.4K Mar 20 19:50 /etc/dhcp/dhcpd.conf
```

```
# grep range /etc/dhcp/dhcpd.conf
```

```
# grep -n subnet /etc/dhcp/dhcpd.conf
35:  subnet 192.168.80.0 netmask 255.255.255.0 {
78:  } # 192.168.80.0/255.255.255.0 subnet_end
```

```
# systemctl is-active dhcpd.service
active
```

Continuing with the setup, next two `makedhcp(8)` requirements have
already beeen met; see above. 

* Get the node IP addresses and MACs defined in the xCAT database.
  * Already done:

```
# lsdef abacus101 | grep -w ip
    ip=192.168.80.1
```

```
# tabdump mac
#node,interface,mac,comments,disable
"abacus101",,"00:11:22:33:44:55",,
```

* Get the hostnames and IP addresses pushed to `/etc/hosts` and do DNS.
  - Already done with:  `makehosts(8)` and with `makedns(8)`.

Run `makedhcp(8)` with a `noderange` option.  This injects configuration data
pertinent to the specified nodes into `dhcpd`.  The configuration information
takes effect immediately without a restart of DHCP.

So far, I've configured one compute node:

```
# nodels
[...]       <-- The rest of the nodes are MM nodes (not CNs)
abacus101
```

For now, add only one node to the DHCP server configuration.
The `dhcpd` (dhcp daemon) does not have to be restarted after this.

```
# makedhcp abacus101
```

Query the node entries from the DHCP server configuration to confirm that
only one node is configured for now:

```
# makedhcp -q abacus101
abacus101: ip-address = 192.168.80.1, hardware-address = 00:11:22:33:44:55 

# makedhcp -q all 
abacus101: ip-address = 192.168.80.1, hardware-address = 00:11:22:33:44:55 
```

Copy the customized CentOS Linux 7.9 DVD ISO to the xCAT server:

```
# scp dusko@192.168.80.210:/tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso .
```

Copy the CentOS 7.9 Linux DVD ISO to the xCAT `/install` directory.

```
# copycds CentOS-7-x86_64-Everything-CUSTOM-2009.iso
```

After `copycds(8)`, the corresponding basic `osimage` will be generated
automatically.  Then you can list the new osimage name here.  You can refer
to xCAT documentation on how to customize the package list or postscript
for target compute nodes. For now just use the default one:

```
# lsdef -t osimage
```

Output:

```
centos7.9-x86_64-install-compute  (osimage)
centos7.9-x86_64-netboot-compute  (osimage)
centos7.9-x86_64-statelite-compute  (osimage)
```


Use `xcatprobe` to precheck whether the xCAT **MN** (**management node**)
is ready for OS provision (`-i` option: install NIC, specifying the network
interface name of provision network on MN (management node).  `-w` option:
show each line completely; by default long lines are truncated):   

```
# xcatprobe -w xcatmn -i eth1
[mn]: Checking all xCAT daemons are running...                          [ OK ]
[mn]: Checking xcatd can receive command request...                     [ OK ]
[mn]: Checking 'site' table is configured...                            [ OK ]
[mn]: Checking provision network is configured...                       [ OK ]
[mn]: Checking 'passwd' table is configured...                          [ OK ]
[mn]: Checking important directories(installdir,tftpdir) are configured [ OK ]
[mn]: Checking SELinux is disabled...                                   [ OK ]
[mn]: Checking HTTP service is configured...                            [ OK ]
[mn]: Checking TFTP service is configured...                            [ OK ]
[mn]: Checking DNS service is configured...                             [WARN]
[mn]: DNS nameserver can not be reached
[mn]: Checking DHCP service is configured...                            [ OK ]
[mn]: Checking NTP service is configured...                             [ OK ]
[mn]: Checking rsyslog service is configured...                         [ OK ]
[mn]: Checking firewall is disabled...                                  [ OK ]
[mn]: Checking minimum disk space for xCAT ['/var' needs 1GB;'/install'
        needs 10GB;'/tmp' needs 1GB]...                                 [ OK ]
[mn]: Checking Linux ulimits configuration...                           [ OK ]
[mn]: Checking network kernel parameter configuration...                [ OK ]
[mn]: Checking xCAT daemon attributes configuration...                  [ OK ]
[mn]: Checking xCAT log is stored in /var/log/xcat/cluster.log...       [ OK ]
[mn]: Checking xCAT management node IP: <192.168.80.220> is configured
        to static...                                                    [ OK ]
[mn]: Checking dhcpd.leases file is less than 100M...                   [ OK ]
[mn]: Checking DB packages installation...                              [ OK ]
=================================== SUMMARY ==================================
[MN]: Checking on MN...                                                 [ OK ]
    Checking DNS service is configured...                               [WARN]
        DNS nameserver can not be reached
```

**NOTE:** Don't worry about DNS warning.  That warning is expected
          because the DNS nameserver for the cluster is within 
	  private network 192.168.80.0/24. 
	  
**Note:** To get usage information of xcatprobe: `xcatprobe -h`.   
To list all valid sub commands for `xcatprobe`, run: `xcatprobe -l`.


### Perform the Diskful OS Deployment (Scripted Install, Clone)
### a.k.a Build Nodes

Begin OS provision on the node `abacus101` with the specified `osimage`.
Earlier, from the output of `lsdef -t osimage`, one of the images was
`centos7.9-x86_64-install-compute`.

```
# lsdef -t osimage centos7.9-x86_64-install-compute
Object name: centos7.9-x86_64-install-compute
    imagetype=linux
    osarch=x86_64
    osdistroname=centos7.9-x86_64
    osname=Linux
    osvers=centos7.9
    otherpkgdir=/install/post/otherpkgs/centos7.9/x86_64
    pkgdir=/install/centos7.9/x86_64
    pkglist=/opt/xcat/share/xcat/install/centos/compute.centos7.pkglist
    profile=compute
    provmethod=install
    template=/opt/xcat/share/xcat/install/centos/compute.centos7.tmpl
```

**Note:**  Before starting `rinstall(8)`, make sure that the node's boot
order is configured so that the first boot device is **network**
(or **PXE network**).  As the HS21 blade server is BIOS-based 
(not UEFI-based), check the BIOS settings, and if needed, adjust the 
settings as needed. [⁶](#footnotes) 

**Note:**   
Alternatively, you can use xCAT's `rbootseq(1)`, which permanently sets
the order of boot devices for BMC-based servers, or `rsetboot(1)` command,
which sets the boot device to be used for BMC-based servers for the next
boot only.   

However, note that on IBM BladeCenter (which is the case here), you only
have `rbootseq` and not `rsetboot`:

[Re: [xcat-user] Problem with rsetboot: unable to identify plugin](https://www.mail-archive.com/xcat-user@lists.sourceforge.net/msg05290.html)
(Retrieved on Mar 20, 2022):   

> On BladeCenter, you have `rbootseq`.  I know, a bit peculiar, but the AMM
> supports boot sequence control rather than next one time boot device
> [which is controlled by `rsetboot`].  


```
# rbootseq abacus101 list
abacus101: net,cdrom,hd0,none
```


If it's not configured to boot from the Ethernet (net) device, you can change it with the `rbootseq(1)` command: `rbootseq abacus101 net,hd0,none,none`


```
# rpower abacus101 bmcstate
abacus101: on
```

```
# chtab \
node=abacus101 \
nodehm.consoleenabled=1
```

The MM (Management Module), a.k.a. BMC (Baseboard Management 
Controller), hosting this compute node (`abacus101`) is named `xbcmm1n`.
Its vitals and network settings are: 

```
# rvitals xbcmm1n all 
[...]
```

```
# rspconfig xbcmm1n network
xbcmm1n: MM IP: 192.168.80.135
xbcmm1n: MM Hostname: xbcmm1n
xbcmm1n: Gateway: 0.0.0.0
xbcmm1n: Subnet Mask: 255.255.255.0
```


If needed, change the `forwarders` attribute in the `site` table.   

From the manual page for `site(5)` table:   
> `forwarders`:   
> The DNS servers at your site that can provide names **outside** of
> the **cluster**.  The makedns command will configure the DNS on the
> management node to forward requests it does not know to these servers.
> Note that the DNS servers on the service nodes will ignore this value
> and always be configured to forward to the management node.
>
> `nameservers`:   
> A comma delimited list of DNS servers that each node in the cluster should
> use. This value will end up in the nameserver settings of the
> `/etc/resolv.conf` **on each node**. It is common (but not required) to set
> this attribute value to the IP address of the xCAT management node, if
> you have set up the DNS on the management node by running makedns.
> In a hierarchical cluster, you can also set this attribute to
> "**\<xcatmaster**\>" to mean the DNS server for each node should be the
> node that is managing it (either its service node or the management
> node).


Also, from the man page for `networks(5)`:
> `gateway`  The network gateway. It can be set to an ip address or the
> keyword **\<xcatmaster**\>.  The keyword \<xcatmaster\> indicates the
> **cluster-facing** ip address configured on this management node or
> service node.  Leaving this field blank means that there is no gateway
> for this network.


```
# tabdump site | grep forwarders 
"forwarders","208.67.222.222,208.67.220.220",,  <- Should list your DNS servers
```

If it hasn't been correctly set up, you can update the `forwarders`
attribute now with the following command. 

```
# chtab key=forwarders site.value=208.67.222.222,208.67.220.220
```

```
# tabdump site | grep forwarders
"forwarders","208.67.222.222,208.67.220.220" 
```

```
# tabdump site | grep nameservers
"nameservers","192.168.80.220",,
```

If it hasn't been correctly set up, you can now update the `nameservers`
attribute with the following command.   

```
# chtab key=nameservers site.value=192.168.80.220
```

```
# tabdump site | grep nameservers
"nameservers","192.168.80.220",,
```


**[TODO]**  Does the trio `makedhcp -n`, `makehosts`, `makedns -n`
            need to be run here?

```
# makedhcp -n
```

```
# makehosts 
```

```
# makedns -n
```


```
# makegocons -D abacus101
[...]
Starting goconserver service ...
abacus101: Created
```

After the node is registered for an instance of the console (serial console)
session with the command `makegocons -D abacus101` above,
the `consoleenabled` attribute has been added and set to `1` for the node
(in this case, node named `abacus101`): 

```
# lsdef abacus101 | grep cons
    cons=blade
    consoleenabled=1
```


```
# systemctl is-active goconserver.service 
active
```

```
# systemctl status goconserver.service 
  goconserver.service - goconserver console daemon
   Loaded: loaded (/usr/lib/systemd/system/goconserver.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2022-03-20 15:42:08 PDT; 1min ago
     Docs: https://github.com/xcat2/goconserver
 Main PID: 12517 (goconserver)
   CGroup: /system.slice/goconserver.service
           |-12517 /usr/bin/goconserver
           +-1253 ssh -t YOUR_BMC_USERNAME@xbcmm1n console -o -T blade[1]

Mar 20 15:42:08 xcatmn.mydomain.com systemd[1]: Started goconserver console daemon.
```

```
# makegocons -q abacus101
NODE                             SERVER                           STATE
abacus101                        xcatmn.mydomain.com              connected
```

Connect to the newly provisioned node (compute node):   

**NOTE:**  For the `rcons` to work, the node's BIOS must be configured 
for SOL (Serial Over LAN), a.k.a. Text Mode Console. <sup>[10](#footnotes)</sup>

```
# rcons abacus101
[Enter `^Ec?' for help]
goconserver(2022-03-20T20:44:12-07:00): Hello 192.168.80.220:32998,
  welcome to the session of abacus101

CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

abacus101 login: root
Password: 
[root@abacus101 ~]# 
```

Log off from the compute node.

```
# exit
```

The OS login banner appears. 

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

abacus101 login: 
```

**NOTE:**    
**To exit the console session, enter: `Ctrl-e` `c` `.`
(3 characters: Ctrl-e, 'c' and '.')**

```
[Disconnected]
```

Display the OS and network interface status (On or Off status) for compute
nodes which are managed by the current xCAT **MN** (**Management Node**):

```
# xcatstat
# Hostname:Status:Network-Interfaces:
abacus101:1:enp4s0-1:enp6s0-2 :
xbcmm1n:1:127 :
xbcmm2:1:127 :
```


Start the diskful OS deployment: 

```
# rinstall abacus101 osimage=centos7.9-x86_64-install-compute
```

**Note:**  The `rinstall` command works even though it raises this error: 

```
# rinstall abacus101 osimage=centos7.9-x86_64-install-compute
Provision node(s): abacus101
Error: [xcatmn]: rinstall plugin bug, pid 18475, process description:
  'xcatd SSL: rinstall to abacus101 for root@localhost: rinstall instance'
  with error 'Died at /opt/xcat/sbin/xcatd line 2104.'
  while trying to fulfill request for the following nodes: abacus101
```

This error is raised because this node is a ***blade*** node, while
`rinstall` command is supposed to support only IPMI based node:

[Re: [xcat-user] Problem with rsetboot: unable to identify plugin](https://www.mail-archive.com/xcat-user@lists.sourceforge.net/msg05288.html)    
(Retrieved on Mar 20, 2022):    
> Your node is a *blade* node. `rinstall` command only supports ipmi based node.


You can monitor installation process:

```
# rcons abacus101
```

After 5-10 minutes verify that provision status is booted:

```
# lsdef abacus101 -i status
Object name: abacus101
    status=booted
```

Use `xdsh(1)` to check the node `abacus101` OS version and whether OS provision
was successful:


```
# xdsh abacus101 more /etc/*release
abacus101: ::::::::::::::
abacus101: /etc/centos-release
abacus101: ::::::::::::::
abacus101: CentOS Linux release 7.9.2009 (Core)
abacus101: ::::::::::::::
abacus101: /etc/os-release
abacus101: ::::::::::::::
abacus101: NAME="CentOS Linux"
abacus101: VERSION="7 (Core)"
[...]
```

**Note:**  If you get a 'Permission denied' error:  

```
# xdsh abacus101 'cat /etc/redhat-release'
[xcatmn]: abacus101: Permission denied (publickey,gssapi-keyex,
gssapi-with-mic,password).
```

you can fix it by updating the security keys for this compute node:

```
# updatenode abacus101 -k
The ssh keys will be updated for 'root' on the node(s).
Password:
abacus101: Setup ssh keys has completed.
abacus101: =============updatenode starting====================
abacus101: /tmp/FlNrhJh5uy.dsh: line 62: /var/log/xcat/xcat.log: No such file or directory
abacus101: trying to download postscripts...
abacus101: /tmp/FlNrhJh5uy.dsh: line 62: /var/log/xcat/xcat.log: No such file or directory

^C
```

** **TIP:** **  If there are monitor probing errors in the console,
                showing approximately every ten seconds similar to 

```
drm:radeon_vga_detect [radeon]] *ERROR* VGA-1: probed a monitor
  but no|invalid EDID
```

you can remove them by adding `nomodeset` kernel boot line option as
explained in Footnotes at the bottom of this page <sup>[11](#footnotes)</sup>. 

See also:  

[Manual "nomodeset" Kernel Boot Line Option for Linux Booting](https://www.dell.com/support/kbdoc/en-ca/000123893/manual-nomodeset-kernel-boot-line-option-for-linux-booting)

[Radeon DVI errors filling logs](https://serverfault.com/questions/708400/radeon-dvi-errors-filling-logs)


Back to continuing with the setup:

Test ssh passwordless login to the node `abacus101`.

```
# ssh root@abacus101
Last login: Sun Mar 20 16:37:45 2022

# hostname
abacus101
```


Log off from the node (compute node).

```
# exit
logout
Connection to abacus101 closed.
```

---

## Stage 2: Add Your Second Node and Configure It for SOL (Serial Over LAN) Operation (aka Text Mode Console)

**Note:**    
You could continue with your first node `abacus101` and 
perform these steps on it but I want to show how to enable SOL 
(Serial Over LAN) operation (a.k.a. text mode console) on a compute 
node running CentOS Linux 5, and a different node is perfect for that 
since its OS hasn't been upgraded yet (it's still CentOS Linux 5.2).  

To prepare the IBM HS21 blade server for supporting serial console,
you need to:
* enable **SOL (Serial Over LAN)** [⁴](#footnotes) in the **BIOS**, and
* configure the **operating system** for SOL operation.  


**Assumptions:**
* Hostname of the node you are provisioning: `abacus102.mydomain.com` (IP address: `192.168.80.2`).   
* It's a blade server in a slot number 2 in an IBM chassis, holding (housing) a total of 14 blades (blade servers).   


### Configure IBM HS21 Blade BIOS for SOL (Serial Over LAN)   

The IBM BladeCenter HS21 blade is a **BIOS**-based server (it doesn't
support **UEFI**).  

This example shows how to use the IBM **Advanced Settings Utility (ASU)**
[⁵](#footnotes) tool to **remotely** modify basic input/output system
**(BIOS) CMOS** settings.  Specifically, for SOL (Serial Over LAN) to work on this server model, the following six settings need to be changed in the BIOS:
Serial Port A, Serial Port B, Remote Console Active, Remote
Console COM Port, Remote Console After Boot, Remote Console Flow Control.

**Note:**   
Alternatively, you can use xCAT's `rbootseq(1)`, which permanently sets
the order of boot devices for BMC-based servers, or `rsetboot(1)` command,
which sets the boot device to be used for BMC-based servers for the next
boot only.   


### Download and Install Advanced Settings Utility (ASU)   

Using your web browser, navigate from the [IBM home page](https://www.ibm.com/)
to the [Support page](https://www.ibm.com/support/home/?lnk=msu_usen)
and then to
(under section "Downloads, fixes & updates") [Fix Central](https://www.ibm.com/support/fixcentral).
Under "*Find product*", in the "*Product selector:*" box, type "HS21"
(without quotes) to access a list of product choices.  From the list of
choices, select **BladeCenter HS21**.  From the "*Product:*" drop-down,
select **8853**.

In the *Operating system*, select "All".  Click *Continue*.
Select the 64-bit version of IBM Advanced Settings Utility (ASU) for Linux
(name: ibm_utl_asu_asut79n-9.30_linux_x86-64_rpm). 

The downloaded file name is H29456300.iso.  Copy this file to the xCAT
server, `xcatmn.mydomain.com` (in this example, with the IP address
`123.12.23.235`).


```
$ scp H29456300.iso username@123.12.23.235:/tmp/
```

Log into the xCAT server. 

```
$ ssh username@123.12.23.235
```

Mount the ISO image. 

```
# mkdir /mnt/ASUISO
# mount -t iso9660 /tmp/H29456300.iso /mnt/ASUISO
```

```
# ls /mnt/ASUISO/
ibm_utl_asu_asut79n-9.30_anyos_i686.chg
ibm_utl_asu_asut79n-9.30_linux_x86-64.rpm
ibm_utl_asu_asut79n-9.30_linux_x86-64.txt
```

Create a directory for the ASU and copy all files from the
ASU ISO image to it. 

```
# mkdir /opt/asu
# cp -i /mnt/ASUISO/ibm_utl_asu_asut79n-* /opt/asu/
```

Unmount the ASU ISO image. 

```
# umount /mnt/ASUISO/
```

Copy the ASU RPM installation file to the node (this node's IP address
is `192.168.80.2`).   

```
# scp \
/opt/asu/ibm_utl_asu_asut79n-9.30_linux_x86-64.rpm \
root@192.168.80.2:/tmp/
```

Log into this node.

```
# ssh root@192.168.80.2
```


Install the ASU from the RPM package. 

```
# cd /tmp
# rpm -ivh ibm_utl_asu_asut79n-9.30_linux_x86-64.rpm
```

List all installed packages on the system and confirm that the ASU
is installed:

```
# rpm -qa | grep asu
ibm_utl_asu-9.30-asut79N
```

Find where the ASU's RPM installs the files:

```
# rpm -qpl ibm_utl_asu_asut79n-9.30_linux_x86-64.rpm
```

Output:

```
/opt/ibm/toolscenter/asu/asu64
/opt/ibm/toolscenter/asu/cdc_interface.sh
/opt/ibm/toolscenter/asu/lic_en.txt
/opt/ibm/toolscenter/asu/rdcli-x86_64/rdmount
/opt/ibm/toolscenter/asu/rdcli-x86_64/rdumount
/opt/ibm/toolscenter/asu/savestat.def
/opt/ibm/toolscenter/asu/template.xml
```

To get help for ASU:

```
# /opt/ibm/toolscenter/asu/asu64 --help
IBM Advanced Settings Utility version 9.30.79N
[...]
Usage: ./asu [apps] <cmds> [<cmd_mod> | <class>] [<options>] [<connect_opts>]

  Note: Full description of an app:     ./asu <app_name> --help
        Full description of a command:  ./asu <cmds> --help

[apps]
  savestat [app_cmd]   - Tool Kit Store System Install State
  immcfg [app_cmd]     - Configure IMM LAN over USB (IMM-based servers only)
  fodcfg [app_cmd]     - Configure Feature on Demand(FoD)
  cmmcfg [app_cmd]     - Configure the CMM
  immapp [app_cmd]     - Immapp Configuration

<cmds>:
   --license        encrypt       patchadd       replicate  showdefault
   batch            export        patchextract   resetrsa   showgroups
   createuuid       generate      patchlist      restore    showlocation
   comparedefault   help          patchremove    save       showvalues
   delete           import        rebootimm      set        version
   deletecert       loaddefault   rebootbmc      setenc     readraw
   dump             nodes         rebootrsa      show       writeraw

*** The ASU User's Guide provides detailed command description and operation.
```

Show names of variable classes on the system.

```
# /opt/ibm/toolscenter/asu/asu64 showgroups
bios
bmc
rsa
```

Show the possible values for the specified setting.

``` 
# /opt/ibm/toolscenter/asu/asu64 showvalues 
``` 

Show the default value for the specified setting.

```
# /opt/ibm/toolscenter/asu/asu64 showdefault
```

Show the current value for one or all settings.

```
# /opt/ibm/toolscenter/asu/asu64 show
```

```
Syntax:
    show [<setting>][<cmdmod>] [<options>] [<connect_opts>]
```


To prepare the IBM HS21 blade server to support serial console, you need
to enable SOL (Serial Over LAN) in BIOS.  That's done by changing values
of six BIOS settings (names of the six settings are listed at the beginning
of this section above). 

Change values for the six BIOS settings:

```
# /opt/ibm/toolscenter/asu/asu64 set CMOS_SerialA "Auto-configure"
# /opt/ibm/toolscenter/asu/asu64 set CMOS_SerialB "Auto-configure"
# /opt/ibm/toolscenter/asu/asu64 set CMOS_RemoteConsoleEnable Enabled
# /opt/ibm/toolscenter/asu/asu64 set CMOS_RemoteConsoleComPort "COM 2"
# /opt/ibm/toolscenter/asu/asu64 set CMOS_RemoteConsoleBootEnable Enabled
# /opt/ibm/toolscenter/asu/asu64 set CMOS_RemoteConsoleFlowCtrl Hardware 
```

Reference:  
[BladeCenter SOL (Serial over LAN) Setup Guide - IBM Corporation, Twelfth Edition (November 2009)](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.advmgtmod.doc/kp1bd_pdf.pdf) (retrieved on Mar 22, 2022):
Chapter 2. General configuration > Updating and configuring the blade server BIOS   


#### Configure RHEL-Based Linux Distribution for Serial Console (Text Console)


In this example the operating system on the node is CentOS
Linux **5.2** (64-bit).

To configure Linux for SOL operation, you must configure it to expose
the Linux initialization (booting) process.  This enables users to
log in to the Linux console using an SOL session and directs Linux output
to the serial console. 

**Note:** This procedure is based on a default installation of
**RHEL 5.2**
(Red Hat Enterprise Linux 5.2).  The file names, structures, and commands
might be different for other versions of RHEL-based Linux distributions.   


* Hardware flow control prevents character loss during communication over a
serial connection.  You must enable it when using a Linux operating system.
Add the following line to the end of the `# Run gettys in standard runlevels`
section of the `/etc/inittab` file.  This enables hardware flow control and
enables users to log in through the SOL console.
`7:2345:respawn:/sbin/agetty -h ttyS1 19200 vt102`

* Add the following line at the bottom of the `/etc/securetty` file to
enable a user to log in as the root user through the SOL console:   
`ttyS1`


#### GRUB Configuration

Complete the following steps to modify the `/boot/grub/grub.conf` file:

* Comment out the `splashimage=...` line by adding a `#` at the beginning of this line.

* Add the following line before the first `title ...` line:
`# This will allow you to only monitor the OS boot via SOL` 

* Add the following text to the end of first `title ...` line:    
`SOL Monitor`  

* Add the following text to the end of the `kernel /...` line of
the first `title ...` section:   
`console=ttyS1,19200 console=tty1` 

* Add the following lines after the frst `title ...` section:   

```
# This will allow you to interact with the OS boot via SOL
title CentOS (2.6.18-92.el5) SOL Interactive
    root (hd0,0)
    kernel /boot/vmlinuz-2.6.18-92.el5 ro root=LABEL=/ rhgb quiet console=tty1
console=ttyS1,19200
    initrd /boot/initrd-2.6.18-92.el5.img
```

**Note:**  The entry beginning with `kernel /boot/vmlinuz...` is shown with a line break
after `console=tty1`.  In your file, the entire entry must all be on one line.


Modified `/boot/grub/grub.conf` contents:

```
# grub.conf generated by anaconda
#
# Note that you do not have to rerun grub after making changes to this file
# NOTICE:  You do not have a /boot partition.  This means that
#          all kernel and initrd paths are relative to /, eg.
#          root (hd0,0)
#          kernel /boot/vmlinuz-version ro root=/dev/sda1
#          initrd /boot/initrd-version.img
#boot=/dev/sda
default=0
timeout=5
#splashimage=(hd0,0)/boot/grub/splash.xpm.gz
hiddenmenu
# This will allow you to only monitor the OS boot via SOL
title CentOS (2.6.18-92.el5) SOL Monitor
    root (hd0,0)
    kernel /boot/vmlinuz-2.6.18-92.el5 ro root=LABEL=/ rhgb quiet
console=ttyS1,19200 console=tty1
    initrd /boot/initrd-2.6.18-92.el5.img

# This will allow you to interact with the OS boot via SOL
title CentOS (2.6.18-92.el5) SOL Interactive
    root (hd0,0)
    kernel /boot/vmlinuz-2.6.18-92.el5 ro root=LABEL=/ rhgb quiet
console=tty1 console=ttyS1,19200
    initrd /boot/initrd-2.6.18-92.el5.img
```


**Note:**  The entries beginning with `kernel /boot/vmlinuz...` are shown
with a line break.  In the actual `grub.conf` file, the both entries are
actually on one line. 


You must reboot the Linux operating system after completing these
procedures for the changes to take effect and to enable SOL.
However, instead of doing it from the OS, I want to confirm that the SOL
setup worked by performing a test with establishing a SOL connection to
the command console of this blade server.  Steps listed below show how to
do that. 


Log on to the management module (**MM**) via the CLI (command line
interface) by following instructions listed
above (["Connecting to CLI on MM"](#connecting-to-cli-on-mm)).

Power cycle this blade server, blade 2 (which is in a blade chassis,
holding a total of 14 blades) to command console.    

The `-cycle` option: power off, then on.  The `-c` option: enter **console**
mode at power on (used on blades with `-on` or `-cycle`).  The `-T` option:
target (in this case blade number 2).  

```
system> power -cycle -c -T system:blade[2]
```

If you see output similar to the following, the SOL setup works:    

```
IPMI kcs interface initialized

                                             CP: 17RN50 200m/200e DDR1 BIOS


IBM BIOS - (c) Copyright IBM Corporation 2008                       CP: 28
Symmetric Multiprocessing System$
Intel(R) Xeon(R) CPU E5430 @ 2.66GHz$
2 Processor Packages Installed$

16384 MB Installed Memory


Press F1 for Configuration/Setup
Press F2 for Diagnostics
Press F12 for Boot Device Selection Menu


>> BIOS Version 1.15 <<

[...]

Press any key to enter the menu

Booting CentOS (2.6.18-92.el5) SOL Monitor in 1 seconds...

[...]

CentOS release 5.2 (Final)
Kernel 2.6.18-92.el5 on an x86_64

abacus102 login: root
```

**Note:**  If you loose communication over the serial connection,
you can re-establish it with the `console` command:
`console -T system:blade[2]`  


To **exit** the SOL session and to return to the CLI on the **MM**,
press Esc followed by an open parenthesis: 
`Esc (`  (two characters: `Esc` and `Shift-9` [on US keyboards])

To return to the OS, in the CLI prompt of the **MM**, type `exit`

Back in the OS:   

```
# ping -c2 192.168.80.2
```

To get the MAC address of the node with IP address 192.168.80.2:  

```
# arp -a | grep '192.168.80.2'
? (192.168.80.2) at 01:02:03:04:05:0e [ether] on eth1
```

**Note:** If you don't have network connection with this node, you can
obtain its MAC address by logging in to the **MM** (**BMC**).

Log on to the management module (**MM**) via the CLI (command line
interface) by following instructions listed
above (["Connecting to CLI on MM"](#connecting-to-cli-on-mm)).

In the BMC CLI prompt:

```
system> info -T blade[2]
[...]
MAC Address 1: 00:11:22:[...]
MAC Address 2: 00:11:22:[...]
MAC Address 3: Not Available
MAC Address 4: Not Available
[...]
```


Create an xCAT data object definition for this node 
(name the node `abacus102`).

**Note:**  I had to create this data object in two steps:
The attribute `bmc` must be specified but when I used `bmc` with
`mgt=blade`, the `mkdef` returned an error: *"Cannot set the attr='bmc'
attribute unless mgt value is ipmi or openbmc"* so in this first step
I skipped setting `bmc` attribute and then changed it in the next step.   

```
# mkdef \
-t node abacus102 \
id=2 \
--template x86_64-template \
ip=192.168.80.2 \
mac=01:02:03:04:05:0e \
bmc=192.168.80.135 \
mpa=xbcmm1n \
getmac=blade \
cons=blade \
serialport=1 \
serialspeed=19200
```

```
# chdef -t node -o abacus102 mgt=blade
```

```
# lsdef abacus102 
Object name: abacus102
    arch=x86_64
    cons=blade
    getmac=blade
    groups=all
    id=2
    ip=192.168.80.2
    mac=01:02:03:04:05:0e
    mgt=blade
    mpa=xbcmm1n
    netboot=xnba
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
    serialport=1
    serialspeed=19200
    usercomment=the system X node definition
```

```
# tabdump mpa
#mpa,username,password,displayname,slots,urlpath,comments,disable
"xbcmm1n","YOUR_BMC_USERID","YOUR_BMC_PASSW0RD",,,,,
```

```
# tabdump mp
#node,mpa,id,nodetype,comments,disable
"bcmgmt1","bcmgmt1","0",,,
"bcmgmt2","bcmgmt2","0",,,
[...]
"xbcmm1n","xbcmm1n",,,,
"abacus101","xbcmm1n","1",,,
"abacus102","xbcmm1n",,,,
```

Change `id` in `node=abacus102` row in the `mp` table setting with `id=2`:

```
# chtab \
node=abacus102 \
mp.id=2
```

```
# tabdump mp
#node,mpa,id,nodetype,comments,disable
"bcmgmt1","bcmgmt1","0",,,
"bcmgmt2","bcmgmt2","0",,,
[...]
"xbcmm1n","xbcmm1n",,,,
"abacus101","xbcmm1n","1",,,
"abacus102","xbcmm1n","2",,,
```


Check `abacus102` hardware control:

```
# rpower abacus102 state
abacus102: on
```

```
# rinv -V abacus102 all
20220320.21:48:23 (3057) rinv:start deal with SNMP session.
abacus102: Machine Type/Model: 8853AC1
abacus102: Serial Number: KQCCXBF
abacus102: MAC Address 1: 01:02:03:04:05:0e
abacus102: MAC Address 2: 01:02:03:04:05:0f
abacus102: Management Module firmware: 16 (BRET86S 10-12-09)
20220320.21:48:24 (3057) rinv:SNMP session completed.
```


Configure DNS.

```
# makehosts abacus102 
Warning: [xcatmn]: No domain can be determined for node 'abacus102'. 
  The domain of the xCAT node must be provided in an xCAT network
  definition or the xCAT site definition.
```

```
# makedns -n
Error: [xcatmn]: domain not defined in site table
```

To fix this error, add the `domain` attribute as explained further below.

The `tabdump` command displays the header and all the rows of the specified
table in CSV (comma separated values) format.  To show descriptions of the
tables, instead of the contents of the tables, use the option `-d`.
If a table name is also specified, descriptions of the columns
(attributes) of the table will be displayed.  Otherwise, a summary of each
table will be displayed.  


```
# tabdump -d
[...]
```


**Note:** The `site` table is specific and different from all the other tables.

```
# tabdump -d | grep -n site
115:site:  Global settings for the whole cluster.  This table is different from

# tabdump -d | sed -n 115,121p
site:  Global settings for the whole cluster.  This table is different from
the other tables in that each attribute is just named in the key column,
rather than having a separate column for each attribute. The following is
a list of attributes currently used by xCAT organized into categories.


statelite: The location on an NFS server where a nodes persistent files
are stored.  Any file marked persistent in t.
[...]
```

To show how `site` table is differently laid out, let's compare it to,
for example, table `passwd`:

```
# tabdump passwd
#key,username,password,cryptmethod,authdomain,comments,disable
"system","root","PASSWORDHERE",,,,
[...]
```

```
# tabdump site
#key,value,comments,disable
[...]
"master","192.168.80.220",,
[...]
```

This means that with all tables except the `site` table, you specifty attribute
by first giving the table name. For example, in case of the `passwd` table
(`passwd.username` or `passwd.password`):   

```
# chtab key=system passwd.username=root passwd.password='abc!!123(??)'
```

In contrast, for the `site` table, after the table name (that is, after
`site`), you always use `.value`:  

```
# chtab key=nameservers site.value=192.168.80.220
```

Back to fixing the error raised above (with `makehosts abacus102` and
`makedns -n`) where the warning was that the domain of the xCAT node 
must be provided in an xCAT network definition or the xCAT site definition.

Description of the `networks` table:

```
# tabdump -d | grep networks
networks:       Describes the networks in the cluster and info necessary to
set up nodes on that network.
```

Description of the `domain` attribute:

```
# tabdump -d site | grep -w domain 
 domain:  The DNS domain name used for the cluster.
```

Currently, the `site` table doesn't have the `domain` key:

```
# tabdump site | grep -i domain
```

To add the `domain` key and value (in this example `mydomain.com`) to the
`site` table:

```
# chtab key=domain site.value=mydomain.com
```

After this, both `makehosts` and `makedns` work:

```
# makehosts abacus102
```

```
# tail -1 /etc/hosts
192.168.80.2 abacus102 abacus102.mydomain.com
```

```
# makedns -n 
Handling xbcmm1n in /etc/hosts.
Handling abacus102 in /etc/hosts.
Handling localhost in /etc/hosts.
Handling localhost in /etc/hosts.
Handling xcatmn in /etc/hosts.
Getting reverse zones, this may take several minutes for a large cluster.
Completed getting reverse zones.
Updating zones.
Completed updating zones.
Restarting named
Restarting named complete
Updating DNS records, this may take several minutes for a large cluster.
Completed updating DNS records.
DNS setup is completed
```

Reference:  
[BladeCenter SOL (Serial over LAN) Setup Guide - IBM Corporation, Twelfth Edition (November 2009)](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.advmgtmod.doc/kp1bd_pdf.pdf) (retrieved on Mar 22, 2022):
Chapter 3. Operating system configuration > Linux configuration > Red Hat Enterprise Linux ES 2.1 configuration 

---

## Create a QEMU Image Snapshot Backup

Power off the guest VM.

Run the following commands on the host.

```
$ qemu-img info xcatmn.img
image: xcatmn.img
file format: raw
virtual size: 80 GiB (85899345920 bytes)
disk size: 21.6 GiB
```

List all snapshots in the image.

```
$ qemu-img snapshot -l xcatmn.img
```

So currently the image doesn't have any snapshots.  

Convert image format from raw to qcow2.

```
$ qemu-img \
convert \
-f raw \
-O qcow2 \
xcatmn.img \
xcatmn.qcow2
```

```
$ ls -lh xcatmn.img
-rw-rw-r-- 1 dusko dusko 80G Mar 20 20:03 xcatmn.img

$ ls -lh xcatmn.qcow2
-rw-r--r-- 1 dusko dusko 24G Mar 20 20:04 xcatmn.qcow2
```

Create the snapshot.

```
$ qemu-img snapshot -c xcat_configured_bkp xcatmn.qcow2
```

List all snapshots in the image.

```
$ qemu-img snapshot -l xcatmn.qcow2
Snapshot list:
ID        TAG                 VM SIZE                DATE       VM CLOCK
1         xcat_configured_bkp     0 B 2022-03-20 20:04:13   00:00:00.000
```

---

## Stage 3: Prepare Postscripts and Postbootscripts

For this installation, I wrote the following two custom scripts:

* `compute_custom_post`: post-**installation** script for all CNs
                         (compute nodes) 
* `abacus_custom_postboot`: post-**boot** script for `abacus` cluster's 
                            CNs (compute nodes)  

while `setupntp`, the next required post-**installation** script for all 
CNs (compute nodes) `setupntp`, was already preinstalled by xCAT.  


**Assumptions:**
* Hostname of the compute node that I'm using in this 
example: `abacus102.mydomain.com` (IP address: `192.168.80.2`). 
It's a blade server in a slot number 2 in an IBM chassis, 
holding (housing) a total of 14 blades (blade servers).   

Start the xCAT QEMU VM (`xcatmn.mydomain.com`, with 
IP address `192.168.80.220`).   

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br0",id=hn0 \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br1",id=hn1 \
-device virtio-net-pci,netdev=hn0 \
-device virtio-net-pci,netdev=hn1 \
-daemonize
```

Log into the QEMU virtual machine; that is, the xCAT MN (management node):

```
$ ssh root@192.168.80.220
```

The execution of post-installation and post-boot scripts is configured
with the xCAT postscripts table.  Post-installation and post-boot scripts,
including custom scripts, are placed in /install/postscripts.

```
# tabdump postscripts
#node,postscripts,postbootscripts,comments,disable
"xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,
"service","servicenode",,,
```

```
# xdsh abacus102 cat /etc/redhat-release
abacus102: CentOS Linux release 7.9.2009 (Core)
```


### Example Use Case:  PBS Scheduling Software with WebMO as Front-End

Scheduling software lets you run your cluster like a batch system,
allowing you to allocate cluster resources, such as CPU time and memory,
on a job-by-job basis.  Jobs are queued and run as resources become
available, subject to the priorities you establish.  Your users will be
able to add and remove jobs from the job queue as well as track the
progress of their jobs.  As the administrator, you will be able to
establish priorities and manage the queue. 

There are several freely available scheduling systems.   

**Note:**  This is an example of setting up **PBS** (**Portable Batch 
System**), specifically **TORQUE** (Terascale Open-source Resource 
and QUEue Manager),  

From *Distributed Computing with Python* by Francesco Pierfederici   
Packt Publishing, April 2016   

> The Portable Batch System (PBS) was developed for NASA in the beginning
> of the 90s.  It now exists in three variants:  OpenPBS, Torque, and
> PBS Pro.  These are all forks of the original codebase, and have a very
> similar look and feel from the user perspective.

Here, I look at **Torque** HPC Resource Manager.


### Torque Resource Manager

TORQUE v 2.3.6, thanks to [The Internet Archive](https://archive.org/):   
[https://web.archive.org/web/20090123185628/http://clusterresources.com/downloads/torque/torque-2.3.6.tar.gz](https://web.archive.org/web/20090123185628/http://clusterresources.com/downloads/torque/torque-2.3.6.tar.gz)

From the README for TORQUE v 2.3.6:

```
$ cat README.torque
#
# TORQUE 2.3.6 README (released Dec, 23 2008)
[...]

OVERVIEW --------------------

  TORQUE (Terascale Open-source Resource and QUEue manager) is an open source
project based on the original PBS* resource manager developed by NASA,
LLNL, and MRJ.  It possesses a large number of enhancements contributed by
organizations such as OSC, NCSA, TeraGrid, the U.S Dept of Energy, USC, 
and many, many others. [...] It may be utilized, modified, and distributed
subject to the constraints of the license located in the PBS_License.txt file. 
[...]
* TORQUE is not endorsed by nor affiliated with Altair.
```

The `pbs_mom(8)` command starts a pbs batch **Machine Oriented Mini-server**
(**MOM**) on a local host (on a compute node).  Typically, on systems with
traditional SysV init scripts, this command will be in a local boot file
such as /etc/rc.local.   


List the `torque` directory content on the storage server 
(IP address: `192.168.80.210`), which is configured with 
a shared directory across the nodes (via NFS). 
(This is the new server that replaced the old one in summer
of 2021. You can call it a "head node" as in addition to being 
the storage server, it's also hosting a front-end WebMO, running 
with Apache webserver.)  

```
# ssh -t dusko@192.168.80.210 ls -lh /opt/torque/
dusko@192.168.80.210's password:
total 4.0K
drwxr-xr-x 2 root root 4.0K May 16  2009 bin
drwxr-xr-x 2 root root   92 May 16  2009 include
drwxr-xr-x 2 root root  113 May 16  2009 lib
drwxr-xr-x 6 root root   54 May 16  2009 man
drwxr-xr-x 2 root root  147 May 16  2009 sbin
drwxr-xr-x 3 root root   19 May 16  2009 var
Connection to 192.168.80.210 closed.
```

While you are sill logged in the **MN** (**Management Node**),
`xcatmn.mydomain.com` (IP address: `192.168.80.220`), tar and 
copy the PBS `torque` directory from an existing **compute node** 
(for example, from a compute node with IP address `192.168.80.6`).  

```
# ssh -t root@192.168.80.6 ls -lh /opt/torque/
```

```
# ssh -t root@192.168.80.6 \
'cd /opt; tar czf torque.tar.gz torque; mv torque.tar.gz /tmp'
root@192.168.80.6's password: 
Connection to 192.168.80.6 closed.
```

Copy the content of the PBS `torque` directory from the compute node 
(using the already mentioned node at `192.168.80.6`) temporarily to 
the MN (management node). 


```
# scp root@192.168.80.6:/tmp/torque.tar.gz .
```

The tarred PBS `torque` directory on the compute node can be deleted:

```
# ssh -t root@192.168.80.6 rm -i /tmp/torque.tar.gz 
```

The PBS `torque` directory now can be copied to from the MN 
(management node) to the compute node that you are provisioning:

```
# scp torque.tar.gz root@192.168.80.2:/opt/
```

Log out from the MN (management node).

```
# exit
logout
Connection to 192.168.80.220 closed.
```


You are now back in the compute node that you are provisioning 
(named: `abacus102`).  If not, you can log into it with `ssh abacus102` 
since you've already configured it for passwordless ssh. 

```
# hostname
abacus102
```

```
# cd /opt
# tar xf torque.tar.gz
# rm -i torque.tar.gz
```

```
# ls -lh /opt/torque/
total 4.0K
drwxr-xr-x 2 root root 4.0K May 16  2009 bin
drwxr-xr-x 2 root root   92 May 16  2009 include
drwxr-xr-x 2 root root  113 May 16  2009 lib
drwxr-xr-x 6 root root   54 May 16  2009 man
drwxr-xr-x 2 root root  147 May 16  2009 sbin
drwxr-xr-x 3 root root   19 May 16  2009 var
```

Version of the TORQUE that I copied to the compute node is 2.3.6:

```
# grep ^version /opt/torque/bin/pbs-config
version="2.3.6"
```

Remove an old `mom.lock` file.

```
# rm -i /opt/torque/var/spool/mom_priv/mom.lock
```

### Convert Traditional SysV (System V) Init Script (aka SysVinit) for pbs_mom Service to systemd Unit File

At the beginning of the previous section above (titled *Torque Resource 
Manager*), I downloaded the source for TORQUE v 2.3.6.  I untarred the tar 
file and located the traditional SysV init script at `contrib/init.d/pbs_mom`. 

```
# diff --unified=0 pbs_mom.ORIG pbs_mom
--- pbs_mom.ORIG      2022-03-20 10:24:36.586238000 -0700
+++ pbs_mom    2022-03-20 10:24:59.884424000 -0700
@@ -12,2 +12,4 @@
-PBS_DAEMON=/usr/local/sbin/pbs_mom
-PBS_HOME=/var/spool/torque
+#PBS_DAEMON=/usr/local/sbin/pbs_mom
+#PBS_HOME=/var/spool/torque
+PBS_DAEMON=/opt/torque/sbin/pbs_mom
+PBS_HOME=/opt/torque/var/spool
```

```
# vi /etc/systemd/system/pbs_mom.service
```

```
# cat /etc/systemd/system/pbs_mom.service
[Unit]
Description=PBS Mom service

[Service]
ExecStart=/opt/torque/sbin/pbs_mom
Type=forking

[Install]
WantedBy=multi-user.target
```


```
# systemctl daemon-reload
```


Find out (confirm) the TORQUE server name.  In this example, it's `mgmt`.

```
# ls -lh /opt/torque/var/spool/server_name
-rw-r--r-- 1 root root 5 May 16  2009 /opt/torque/var/spool/server_name

# cat /opt/torque/var/spool/server_name
mgmt
```


**Note:**  This sample configuration includes
[WebMO](https://www.webmo.net/) as a front-end:   
> WebMO is a web-based interface to computational chemistry packages.


While still on the compute node `abacus102`, add
`IP_address canonical_hostname` pairs to the `/etc/hosts`
file [⁷](#footnotes) for the following hosts:
- `abacus102`: this compute node
- `mgmt`: MN (management node) 
- `abacus.mydomain.com`: the WebMO server


```
# printf %s\\n "192.168.80.2 abacus102" >> /etc/hosts
# printf %s\\n "192.168.80.210 mgmt" >> /etc/hosts
# printf %s\\n "192.168.80.100 abacus.mydomain.com" >> /etc/hosts
```

```
# systemctl is-enabled pbs_mom.service
disabled
```

```
# systemctl enable pbs_mom.service
Created symlink from /etc/systemd/system/multi-user.target.wants/pbs_mom.service to
  /etc/systemd/system/pbs_mom.service.
```

```
# systemctl is-enabled pbs_mom.service
enabled
```

```
# systemctl start pbs_mom.service
```

```
# systemctl is-active pbs_mom.service
active
```


### Submit a Test Job to a Specific Node

As the compute node `abacus102` has already been configured 
(with passwordless ssh), you can log into it:

```
[root@xcatmn ~]# ssh abacus102
Last login: Sun Mar 30 16:30:21 2022 from xcatmn.mydomain.com

[root@abacus102 ~]# 
```

On the compute node `abacus102`:  

```
# find /opt/torque/ -iname '*qstat*'
/opt/torque/bin/qstat
/opt/torque/man/man1/qstat.1
```

The manpage for qstat(1B) from the PBS software package (Torque):  

```
# man /opt/torque/man/man1/qstat.1 

qstat(1B)                   PBS                  qstat(1B)

NAME
       qstat - show status of pbs batch jobs

---- snip ----
```

Exit the compute node.

```
# exit
logout
Connection to abacus102 closed.
```

Log in to the head node (IP address: `192.168.80.210`), 
a.k.a. the webserver (for WebMO). 
**NOTE:**  This is **not** the xCAT MN (management node), 
`xcatmn.mydomain.com` (IP address: `192.168.80.220`).   

```
# ssh root@192.168.80.210
```

```
# command -v qstat; type -a qstat; whereis qstat; which qstat
/global/software/torque/x86_64/bin/qstat
qstat is /global/software/torque/x86_64/bin/qstat
qstat is /global/software/torque/x86_64/bin/qstat
qstat: /opt/torque/bin/qstat /global/software/torque/x86_64/bin/qstat /usr/share/man/man1p/qstat.1p.gz
/global/software/torque/x86_64/bin/qstat
```

**NOTE** the different manpage for the qstat(1P) from the POSIX 
Programmer's Manual than the one above (for qstat(1B) [from the PBS 
software package (Torque)]:

```
# man qstat

QSTAT(1P)                   POSIX Programmer's Manual   QSTAT(1P)

PROLOG
       This manual page is part of the POSIX Programmer's Manual. 
       The Linux implementation of this interface may differ (consult the 
       corresponding Linux manual page for details of Linux behavior), 
       or the interface may not be implemented on Linux.

NAME
       qstat - show status of batch jobs

---- snip ----
```


Without any options or arguments, `qstat` requests for status of all 
jobs (in all queues at the default server):   

```
# qstat 
Job id      Name         User  Time Use S Queue
----------- ------------ ----- -------- - -----
290398.mgmt WebMO_285069 webmo  2:17:56 R abacus 
[...]
```

While still at the head node (remember, this is **not** the xCAT 
MN `xcatmn.mydomain.com`), first use the `pbsnodes(8)`
<sup>[8](#footnotes)</sup> to check whether the node's state is `free`.  

```
# pbsnodes -l all abacus102
abacus102            offline
```

If the node is in OFFLINE state, the fix is to clear OFFLINE from the node:

```
# pbsnodes -c abacus102
```


If the node is in DOWN state, try fixing it by restarting `pbs_mom` 
service on the node -- remember that you need to run the `xdsh(1)` command from the xCAT MN (Management Node) so you first need to log into the xCAT MN:

```
# ssh root@192.168.80.220
```

In the xCAT MN (IP address: `192.168.80.220`), run `xdsh(1)` command to 
restart the `pbs_mom` service on the compute node `abacus102`:

```
# xdsh abacus102 systemctl restart pbs_mom.service
```

Exit the xCAT MN (Management Node).


```
# exit
```


Back on the head node (IP address: `192.168.80.210`), restart 
the `pbs_server` service.   

```
# systemctl restart pbs_server.service
```

Confirm that the status of the node is now `free`.

```
# pbsnodes -l all abacus102
abacus102            free
```


While still on the head node (IP address: `192.168.80.210`), create 
a test job (a.k.a. batch job) that will be submitted to run specifically 
on the compute node `abacus102`.   

```
# vi test_abacus102
```

```
# cat test_abacus102
#
#
#PBS -l nodes=1:abacus102
#
sleep 120
hostname
date
```

Submit a test job to compute node `abacus102`:

```
# qsub test_abacus102
290405.mgmt
```

You'll notice that the PBS Torque returned a job number, 
which is `290405.mgmt`. 

```
# qstat -a

mgmt: 
                                                       Req'd Req'd   Elap
Job ID      User Queue  Jobname         SessID NDS TSK Mem   Time  S Time
----------- ---- ------ --------------  ------ --- --- ----- ----- - ----
[...]
290405.mgmt root abacus test_abacus102  28382    1  --   --  120:0 R  --
```

Log into the compute node `abacus102` to confirm whether the submitted test
job is running on this node. 

```
$ ssh root@abacus102
```

```
# find /opt/torque/ -name '*290405*'
/opt/torque/var/spool/mom_priv/jobs/290405.mgmt.SC
/opt/torque/var/spool/mom_priv/jobs/290405.mgmt.TK
/opt/torque/var/spool/mom_priv/jobs/290405.mgmt.JB
/opt/torque/var/spool/aux/290405.mgmt
/opt/torque/var/spool/spool/290405.mgmt.OU
/opt/torque/var/spool/spool/290405.mgmt.ER
```

```
# cat /opt/torque/var/spool/mom_priv/jobs/290405.mgmt.SC
#
#
#PBS -l nodes=1:abacus102
#
sleep 120
hostname
date
```

```
# cat /opt/torque/var/spool/aux/290405.mgmt
abacus102
```

Log out from the compute node `abacus102`.   

```
# exit
logout
Connection to abacus102 closed.
```


Back on the head node:

```
# qstat 
Job id      Name           User Time Use S Queue
----------- -------------- ---- -------- - -----
[...]
290405.mgmt test_abacus102 root 00:00:00 R abacus
```

After 120 seconds:

```
# qstat 
Job id      Name           User Time Use S Queue
----------- -------------- ---- -------- - -----
[...]
```


### Setup NFS Server on the Head Node (HN) Running CentOS 8/RHEL 8 

**NOTE:**   
The following steps are performed on the head node `abacus.mydomain.com` (IP address:  `192.168.80.210`).   

**Note:**  The head node has been previously configured as an NFS server 
so the needed NFS server package (`nfs-utils`) is already installed:

```
$ sudo dnf list --installed | grep nfs-utils
nfs-utils.x86_64    1:2.3.3-46.el8    @rhel-8-for-x86_64-baseos-rpms
```

Verify the version of nfs protocol that is running.  The version is
indicated by the second column in the output below.

```
$ rpcinfo -p | grep nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
```

For additional configuration of the NFS server, you can find the
configuration files at `/etc/nfs.conf`, which is the NFS daemon config file
and the `/etc/nfsmount.conf`, which is the configuration file for the NFS mount.
In this example, these two files haven't been customized:  

```
$ grep -v \# /etc/nfs.conf
# /etc/nfs.conf
[general]
[exportfs]
[gssd]
use-gss-proxy=1
[lockd]
[mountd]
[nfsdcld]
[nfsdcltrack]
[nfsd]
[statd]
[sm-notify]
```

```
$ grep -v \# /etc/nfsmount.conf
[ NFSMount_Global_Options ]
```


The file system that is shared from the NFS server to NFS client systems:

```
$ showmount -e
Export list for mgmt:
/export   abacus214,abacus213, [...], abacus102,abacus101,mgmt
/global   abacus214,abacus213, [...], abacus102,abacus101,mgmt
/home     abacus214,abacus213, [...], abacus102,abacus101,mgmt
```

Directory ownership and permissions:

```
$ ls -ld /global
drwxr-xr-x 3 root root 3 Aug  3  2021 /global
[
$ ls -ld /home
drwxr-xr-x. 33 root root 34 Jun 21  2021 /home
```

All the compute nodes are allowed access to the NFS share:

```
$ cat /etc/exports
/home mgmt(rw,sync,no_root_squash) abacus101(rw,sync,no_root_squash) abacus102(rw,sync,no_root_squash) [...] abacus213(rw,sync,no_root_squash) abacus214(rw,sync,no_root_squash) 
/global mgmt(rw,sync,no_root_squash) abacus101(rw,sync,no_root_squash) abacus102(rw,sync,no_root_squash) [...] abacus213(rw,sync,no_root_squash) abacus214(rw,sync,no_root_squash)
```

Explanation:
* `rw`: Allow NFS clients read/write permissions to the NFS share.
* `sync`: Require the writing of the changes on the disk first before
          any other operation can be carried out.
* `no_root_squash`: Allow access to files inside directories to
                    which only root has access.   
   * From the man page for `exports(5)`: "Very  often, it is
     not desirable that the root user on a client machine is also treated
     as root when accessing files on the NFS server.  To this end, UID 0 is
     normally mapped to a different ID: the so-called anonymous or nobody UID.
     This mode of operation (called 'root squashing') is the default, and can
     be turned off with `no_root_squash`."  In other words, do *not* map
     requests from the root user on the client-side to an anonymous UID/GID.


### Configure the Firewall Rules for NFS Server on CentOS 8/RHEL 8

While still on the head node `abacus.mydomain.com` 
(IP address: `192.168.80.210`):  

```
$ sudo systemctl start firewalld.service
```

```
$ sudo systemctl is-active firewalld.service
active
```


```
$ sudo systemctl enable firewalld.service
```

```
$ sudo systemctl is-enabled firewalld.service
enabled
```

```
$ sudo firewall-cmd --permanent --add-service=nfs
$ sudo firewall-cmd --permanent --add-service=rpc-bind
$ sudo firewall-cmd --permanent --add-service=mountd
```


```
$ sudo grep -n PORT /opt/torque/include/pbs_ifl.h
[...]
392:#define PBS_BATCH_SERVICE_PORT  15001
[...]
398:#define PBS_BATCH_SERVICE_PORT_DIS 15001  /* new DIS port   */
[...]
404:#define PBS_MOM_SERVICE_PORT  15002
[...]
410:#define PBS_MANAGER_SERVICE_PORT 15003
[...]
416:#define PBS_SCHEDULER_SERVICE_PORT 15004
[...]
```

```
$ sudo firewall-cmd --list-ports
```

```
$ sudo firewall-cmd --permanent --add-port=15001-15004/tcp
```


```
$ sudo firewall-cmd --reload
```

```
$ sudo systemctl restart firewalld
```

```
$ sudo firewall-cmd --list-ports
15001-15004/tcp
```

```
$ sudo firewall-cmd --list-all
public (active)
  target: default
  [...] 
  interfaces: br0 br1 eno1 eno2
  [...] 
  services: cockpit dhcpv6-client http https mountd nfs rpc-bind ssh
  ports: 15001-15004/tcp
  [...] 
```


### Set Up NFS Client on Compute Node

Log in to the compute node `abacus102`.  

```
# ssh root@abacus102
```

```
# printf %s\\n "mgmt:/home    /home    nfs  defaults  1 2" >> /etc/fstab
# printf %s\\n "mgmt:/global  /global  nfs  defaults  1 2" >> /etc/fstab
```

```
# mkdir /global
```

```
# mount -a
```

```
# df -hT /home
Filesystem     Type  Size  Used Avail Use% Mounted on
mgmt:/home     nfs4  5.0T  1.8T  3.3T  36% /home

# df -hT /global
Filesystem     Type  Size  Used Avail Use% Mounted on
mgmt:/global   nfs4  3.9T  637G  3.3T  17% /global
```

```
# printf %s\\n Test > /home/testfile

# ls -lh /home/testfile
-rw-r--r-- 1 root root 5 Mar 20 19:59 /home/testfile

# cat /home/testfile
Test

# rm -i /home/testfile
rm: remove regular file ‘/home/testfile’? y

# ls -lh /home/testfile
ls: cannot access /home/testfile: No such file or directory
```

**[TODO]**: Complete this section

### Postscripts Setup

The following steps need to be run on the management node, 
`xcatmn.mydomain.com` (IP address: `192.168.80.220`).  

```
# mkdir /install/custom
```

```
# cd /install/custom/
```

Copy the content that your postscript will need. In this example, 
I prepared the torque directory on another compute node (`abacus106`, 
with the IP address: `192.168.80.6`) that I previously configured manually.

```
# scp root@192.168.80.6:/tmp/torque.tar.gz .
```

You don't need the tarred content on the other compute node so you can 
delete it from there:

```
# ssh -t root@192.168.80.6 rm -i /tmp/torque.tar.gz
```


Create the `synclist` file.

```
# cat /install/custom/install/centos/compute.centos7.x86_64.synclist
/install/custom/torque/* -> /opt/torque/

/install/custom/group_cn_common -> /etc/group
/install/custom/gshadow_cn_common -> /etc/gshadow
/install/custom/passwd_cn_common -> /etc/passwd
/install/custom/shadow_cn_common -> /etc/shadow
```

Confirm that the object `osimage` now has the attribute `synclists`.

```
# lsdef -t osimage -i synclists
Object name: centos7.9-x86_64-install-compute
    synclists=/install/custom/install/centos/compute.centos7.x86_64.synclist
Object name: centos7.9-x86_64-netboot-compute
    synclists=
Object name: centos7.9-x86_64-statelite-compute
    synclists=
```

Since it's included in the `osimage` object, the `syncfiles` has been addeed 
to the `postscripts` attribute of the compute node that you're configuring 
(`abacus102`):

```
# lsdef -t node -o abacus102 -i postscripts
Object name: abacus102
    postscripts=syslog,remoteshell,syncfiles
```

Create the `postscripts` file.

```
# cat /install/postscripts/compute_custom_post 
#!/bin/sh
#
# This is a postscript to configure compute nodes as NFS clients.
#
# This script is supposed to be located at
# /install/postscripts/compute_custom_post
#
# In order for it to be run after nodes are installed, compute_custom_post
# should be included in the postscripts field of the postscripts xCAT table.
# E.g.: nodegrpch compute postscripts.postscripts=compute_custom_post

MN_IP="192.168.80.210"
MN_HOST="mgmt"

cp /etc/fstab /etc/fstab.ORIG

printf %s\\n "$MN_IP $MN_HOST" >> /etc/hosts

mkdir /etc/xcat
mkdir /global
 
printf %s\\n "$MN_HOST:/home    /home    nfs  defaults  1 2" >> /etc/fstab
printf %s\\n "$MN_HOST:/global  /global  nfs  defaults  1 2" >> /etc/fstab

mount -a
```

```
# chmod 0755 /install/postscripts/compute_custom_post  
```

The next required postscripts script, `setupntp`, was already preinstalled 
by xCAT:  

```
# ls -lh /install/postscripts/setupntp
-rwxr-xr-x 1 root root 7.4K Nov 10  2021 /install/postscripts/setupntp

# wc -l /install/postscripts/setupntp
328 /install/postscripts/setupntp
```

```
# head /install/postscripts/setupntp
#!/bin/bash
#
# setupchrony - Set up chrony
#
# Copyright (C) 2018 International Business Machines
# Eclipse Public License, Version 1.0 (EPL-1.0)
#     <http://www.eclipse.org/legal/epl-v10.html>
#
# 2018-07-11 GONG Jie <gongjie@linux.vnet.ibm.com>
#     - Draft
```

Create the `postbootscripts` file.

```
# cat /install/postscripts/abacus_custom_postboot
#!/bin/sh
#
# This is a postbootscript to perform postboot configuration on the
# compute nodes.  ("postboot" means after the reboot that occurs after
# installation has completed)
#
# This script is supposed to be located at
# /install/postscripts/abacus_custom_postboot
#
# In order for it to be run after nodes are installed and rebooted,
# abacus_custom_postboot
# should be included in the postbootscripts field of the postscripts xCAT table.
# E.g.:  nodegrpch compute postscripts.postbootscripts=abacus_custom_postboot

PBS_MOM_SERVICE_LOC="/etc/systemd/system/pbs_mom.service"

printf %s\\n '[Unit]' > $PBS_MOM_SERVICE_LOC
printf %s\\n 'Description=PBS Mom service' >> $PBS_MOM_SERVICE_LOC
printf %s\\n >> $PBS_MOM_SERVICE_LOC
printf %s\\n '[Service]' >> $PBS_MOM_SERVICE_LOC
printf %s\\n 'ExecStart=/opt/torque/sbin/pbs_mom' >> $PBS_MOM_SERVICE_LOC
printf %s\\n 'Type=forking' >> $PBS_MOM_SERVICE_LOC
printf %s\\n >> $PBS_MOM_SERVICE_LOC
printf %s\\n '[Install]' >> $PBS_MOM_SERVICE_LOC
printf %s\\n 'WantedBy=multi-user.target' >> $PBS_MOM_SERVICE_LOC

systemctl daemon-reload
systemctl start pbs_mom.service
systemctl enable pbs_mom.service

rm /root/.ssh/id_rsa.pub
rm /root/.ssh/id_rsa

chmod 0600 /etc/ssh/ssh_host_ed25519_key
chmod 0600 /etc/ssh/ssh_host_ecdsa_key
chmod 0600 /etc/ssh/ssh_host_rsa_key
chmod 0600 /etc/ssh/ssh_host_dsa_key

systemctl restart sshd.service
```

```
# chmod 0755 /install/postscripts/abacus_custom_postboot
```

```
# lsdef abacus102 | grep provmethod
    provmethod=centos7.9-x86_64-install-compute

# lsdef abacus102 | grep -w -i os
    os=centos7.9

# nodels abacus102 nodetype | grep profile
abacus102: nodetype.profile: compute

# tabdump nodetype
#node,os,arch,profile,provmethod,supportedarchs,nodetype,comments,disable
---- snip ----
"abacus102","centos7.9","x86_64","compute","centos7.9-x86_64-install-compute",,,,
```

As of now, the `postscripts` attribute for the node `abacus102` has not 
been updated with the required scripts.  From the definition of the object 
type `node`, for the object `abacus102`, display the attribute postscripts. 
You'll notice that both `setupntp` and `compute_custom_post` have not been 
appended to the `postscripts` line:

```
# lsdef -t node -o abacus102 -i postscripts
Object name: abacus102
    postscripts=syslog,remoteshell,syncfiles
```

Similarly, when you ask for the `postbootscripts` attribute of the 
node `abacus102`, the `abacus_custom_postboot` script is missing from 
the `postbootscripts` line:

```
# lsdef -t node -o abacus102 -i postbootscripts
Object name: abacus102
    postbootscripts=otherpkgs
```

Upgrade the group `compute` with the required `postscripts` and 
`postbootscripts` script files:

```
# nodegrpch compute postscripts.postscripts=setupntp,compute_custom_post
# nodegrpch compute postscripts.postbootscripts=abacus_custom_postboot
```

Confirm that it’s been done:

```
# tabdump postscripts
#node,postscripts,postbootscripts,comments,disabl
---- snip ----
"compute","setupntp,compute_custom_post","abacus_custom_postboot",,
```

Also, you'll see that the compute node (`abacus102`) has not been added 
to the `postscripts` table:

```
# tabdump postscripts | grep abacus102
```

Add the required `postscripts` and `postbootscripts` script files to the 
node by updating it with the `chtab(8)` command.    

```
# chtab \
node=abacus102 \
postscripts.postscripts=setupntp,compute_custom_post \
postscripts.postbootscripts=abacus_custom_postboot
```


To confirm that the needed postscripts are now included with the node:

```
# lsdef abacus102 | grep postscripts 
    postscripts=syslog,remoteshell,syncfiles,setupntp,compute_custom_post
```

```
# lsdef abacus102 | grep postbootscripts
    postbootscripts=otherpkgs,abacus_custom_postboot
```

```
# tabdump postscripts
#node,postscripts,postbootscripts,comments,disable
---- snip ----
"abacus102","setupntp,compute_custom_post","abacus_custom_postboot",,
```

```
# tabdump postscripts | grep abacus102
"abacus102","setupntp,compute_custom_post","abacus_custom_postboot",,
```

Continuing with the setup, confirm that the node's profile is `compute` 
as that's the name of the whole group you modified earlier above.

```
# nodels abacus102 nodetype
abacus102: nodetype.arch: x86_64
abacus102: nodetype.node: abacus102
abacus102: nodetype.os: centos7.9
abacus102: nodetype.profile: compute
abacus102: nodetype.provmethod: centos7.9-x86_64-install-compute
abacus102: nodetype.supportedarchs: 
abacus102: nodetype.comments: 
abacus102: nodetype.nodetype: 
abacus102: nodetype.disable: 
```

```
# tabdump nodetype
#node,os,arch,profile,provmethod,supportedarchs,nodetype,comments,disable
---- snip ----
"abacus102","centos7.9","x86_64","compute","centos7.9-x86_64-install-compute",,,,
```

```
# lsdef -t node -o abacus102 -i postscripts
Object name: abacus102
    postscripts=syslog,remoteshell,syncfiles,setupntp,compute_custom_post
```

```
# lsdef -t node -o abacus102 -i postbootscripts
Object name: abacus102
    postbootscripts=otherpkgs,abacus_custom_postboot
```


Set `xcatdebugmode` in the `site` table to `2`.

```
# chdef -t site xcatdebugmode=2
```

Push `syncfiles` to the node:

```
# updatenode abacus102 -P syncfiles
```

```
# updatenode abacus102 -F -V
```

Log in to the compute node (`abacus102`):

**NOTE:**  For the `rcons` to work, the node's BIOS must be configured
for SOL (Serial Over LAN), a.k.a. Text Mode Console. <sup>[10](#footnotes)</sup>

```
# rcons abacus102
```

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

abacus102 login: root
Password:

[root@abacus102 ~]#
```

Run the following command (**note:** `192.168.80.220` is the IP address of the managment node (MN), `xcatmn.mydomain.com`, and `3001` is xCAT port).   

```
# USEOPENSSLFORXCAT=1 \
XCATSERVER=192.168.80.220:3001 \
/xcatpost/startsyncfiles.awk -v RCP=/usr/bin/rsync
```

Exit the compute node.

```
# exit
```

The CentOS Linux login banner appears.  

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

abacus102 login:
```

Press `Ctrl-e` `c` `.` (three characters: Ctrl-e, 'c' and '.') to disconnect 
from the node by closing the session with the `makegocons`.

Back in the management node, `xcatmn.mydomain.com`:

```
# xdcp abacus102 -F /install/custom/install/centos/compute.centos7.x86_64.synclist
```

Update the node `abacus102` but limit it to only run the scripts: 

```
# updatenode abacus102 -P
```

Check whether the run of the scripts worked.

Yeah, it worked for `synclist`; that is `compute.centos7.x86_64.synclist`:

```
# xdsh abacus102 ls -lh /opt/torque/ 
abacus102: total 4.0K
abacus102: drwxr-xr-x. 2 root root 4.0K May 16  2009 bin
abacus102: drwxr-xr-x. 2 root root   92 May 16  2009 include
abacus102: drwxr-xr-x. 2 root root  113 May 16  2009 lib
abacus102: drwxr-xr-x. 6 root root   54 May 16  2009 man
abacus102: drwxr-xr-x. 2 root root  147 May 16  2009 sbin
abacus102: drwxr-xr-x. 3 root root   19 May 16  2009 var

# xdsh abacus102 du -chs /opt/torque/ 
abacus102: 108M /opt/torque/
abacus102: 108M total
```

```
# xdsh abacus102 cat /etc/passwd 
---- snip ----
```

```
# xdsh abacus102 cat /etc/group
---- snip ----
```

It also worked for the `compute_custom_post` script run:

```
# xdsh abacus102 cat /etc/fstab
---- snip ----
abacus102: mgmt:/home    /home    nfs  defaults  1 2
abacus102: mgmt:/global  /global  nfs  defaults  1 2
```

```
# xdsh abacus102 df -hT 
abacus102: Filesystem              Type      Size  Used Avail Use% Mounted on
---- snip ---
abacus102: mgmt:/home              nfs4      5.0T  1.8T  3.3T  36% /home
abacus102: mgmt:/global            nfs4      3.9T  637G  3.3T  17% /global
```

```
# xdsh abacus102 cat /etc/hosts
---- snip ----
abacus102: 192.168.80.210 mgmt
```

The `setupntp` script run worked too:

```
# xdsh abacus102 systemctl is-active chronyd.service
abacus102: active
```

```
# xdsh abacus102 systemctl status chronyd.service
abacus102: * chronyd.service - NTP client/server
abacus102:    Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
abacus102:    Active: active (running) since Fri 2022-03-20 18:53:38 PDT; 2min ago
---- snip ----
```

Yep, the `abacus_custom_postboot` script run worked as well:

```
# xdsh abacus102 systemctl is-active pbs_mom.service
abacus102: active

# xdsh abacus102 systemctl status pbs_mom.service
abacus102: * pbs_mom.service - PBS Mom service
abacus102: Loaded: loaded (/etc/systemd/system/pbs_mom.service; enabled; vendor preset: disabled)
abacus102: Active: active (running) since Fri 2022-03-20 18:53:39 PDT; 2min ago
```

```
# xdsh abacus102 --verify ls -lh /
abacus102: total 28K
---- snip ----
```

**NOTE:**   
If the above `updatenode abacus102 -P` does not work, you can try fixing 
it by the following sequence of commands:

```
# updatenode abacus102 -P syncfiles
# updatenode abacus102 -P "confignetwork -s"
# updatenode abacus102 -P
# updatenode abacus102 -P -F -V
# updatenode abacus102 -P syncfiles -P "confignics -s"
# updatenode abacus102 -P syncfiles -F -V
# xdsh abacus102 shutdown -r now
```

*Explanation:*    
If you want to run all the customization scripts that have been designated 
for the `abacus102` node (in the `postscripts` and `postbootscripts` 
attributes), the `-P` option (i.e, the command: `updatenode abacus102 -P`) 
will not work after install.  Instead, after install use the `-F` option 
for file synchronization (including synchronization of the `postscripts` 
and `postbootscripts` attributes).

From the man page for the `updatenode(1)` command:

```
-F|--sync     Specifies that file synchronization should be performed on the
              nodes.  rsync/scp and ssh must be installed and configured on
              the nodes.
[...]
-P|--scripts  Specifies that postscripts and postbootscripts should be run on
              the nodes.  File sync with updatenode -P syncfiles is not
              supported.  The syncfiles postscript can only be run during
              install.  You should use updatenode -F instead.
```


## Provision a Node and Manage It with Parallel Shell - aka Create (Add) a New Compute Node (CN) in xCAT - FULL EXAMPLE

Assumptions:   
* You are configuring the new compute node on a blade server. 
* BMC (Baseboard Management Controller) in the blade chassis that hosts 
the blade server has already been configured so you can communicate with 
the BMC.  
* BMC's IP address:  `192.168.80.135`
* BMC's username:  `xadmin`
* The chassis holds 14 blade servers.
* You are configuring blade in bay number 9 (9th blade server). 


Log into the xCAT management node (xCAT MN).

```
$ ssh root@192.168.80.220
```

### Configure MM (Management Module) - a.k.a. BMC (Baseboard Management Controller)


Run the discovery on IP address of the xCAT MN (`192.168.80.220`) and list 
all discovered MM (Management Node) **service types**.   
 
```
# lsslp -s MM -i 192.168.80.220
---- snip ----
device  type-model  serial-number  side  ip-addresses    hostname
---- snip ----
mm      8852HC1     KQABCDE              192.168.80.135  Server--SNYK123456789A 
```

Rename the MM node to a more human-friendly name (`xbcmm1n`). 


```
# chdef \
-t node \
-o Server--SNYK123456789A \ 
-n xbcmm1n
```


Add the BMC (MM) node to the `mp` table.  

In other words, you are updating rows `username` and `password` 
in the table `mpa`.  From the `chtab(8)` command's usage:   
> `keycolname=keyvalue`   a column name-and-value pair that identifies the 
>                         rows in a table to be changed.
>   
> `tablename.colname=newvalue`    the new value for the specified row and 
>                                 column of the table.


```
# tabdump mpa
#mpa,username,password,displayname,slots,urlpath,comments,disable
---- snip ----
```

So, the `keycolname` is `mpa` with value being the name of the 
node that you'll give to this BMC (`xbcmm1n`), while the 
`tablename.colname=newvalue` are 
`mpa.username=xadmin` and `mpa.password=YOUR_BMC_PASSWORD`.  


After this explanation, run the actual command:

```
# chtab \
mpa=xbcmm1n \
mpa.username=xadmin \
mpa.password=YOUR_BMC_PASSWORD
```


As the `mp` table refers to the `mpa` table:

```
# tabdump mp
#node,mpa,id,nodetype,comments,disable
---- snip ----
```

add the attribute `mpa` to the table `mp`:

```
# chtab \
node=xbcmm1n \
mp.mpa=xbcmm1n
```


This MM (Management Module) node now includes the `node` and `mpa` attributes 
in the `mp` table:  

```
# tabdump mp
#node,mpa,id,nodetype,comments,disable
---- snip ----
"xbcmm1n","xbcmm1n",,,,
```


Add the attribute `id`. This is a MM (Management Module) and since 
it's customary to give value `0` (zero) to MMs, assign `0` to it:  

```
# chtab \
node=xbcmm1n \
mp.id=0
```


Add this MM (Management Module) node's IP address to `/etc/hosts` file.

```
# printf %s\\n "192.168.80.135 xbcmm1n" >> /etc/hosts
```

Check if you can communicate with the MM node.  For example, test whether 
the `rspconfig(1)` can run without errors:


```
# rspconfig xbcmm1n snmpdest
xbcmm1n: SP SNMP Destination 1: 192.168.11.2
```

**Note:**  It would've been good even if returned value was 
empty (without an IP address); at this point you just want to make 
sure there are no errors. 


Now you can setup new ssh keys (a.k.a. enable `snmp` and `ssh`) 
on this Management Module (named `xbcmm1n`):

```
# rspconfig xbcmm1n snmpcfg=enable sshcfg=enable
```

Output:

```
xbcmm1n: SNMP enable: OK
xbcmm1n: SSH enable: OK
```

You can now check remote hardware vitals for the MM node:

```
# rvitals xbcmm1n
---- snip ----
```

You can also check its hardware inventory:

```
# rinv xbcmm1n
---- snip ----
```


The passwordless ssh login to the MM node works:

```
# ssh xadmin@xbcmm1n
```

Output (with BMC CLI prompt indicated with `system>`):     


```
Static IP address:     192.168.80.135
---- snip ----
system>
```


### Provision New Node (Compute Node)

After you've setup the MM (Management Module) node, you are ready to 
start provisioning a new compute node.  

Find out the compute node's MAC address by logging in to the MM (AMM) and 
obtaining it from there: 

```
# ssh xadmin@192.168.80.135
```

**Note:**  Don't type **`system>`** .  It's a BMC CLI prompt and it's 
shown here to indicate that you are using the MM.   


```
system> info -T blade[9]
---- snip ----
MAC Address 1: 00:11:22:33:44:55 
MAC Address 2: 00:11:22:33:44:56
---- snip ----
```

Note down the `MAC Address 1`.   

Exit the BMC's CLI. 

```
system> exit
Connection to 192.168.80.135 closed.
```


Create an xCAT data object definition for this node (name it `abacus109`).  
Explanation: `ip` = IP address of the node; `mac` = MAC address of
the node; `bmc` = IP address of the MM/AMM (BMC); `bmcusername` = username of
BMC (MM) account; `bmcpassword` = password for BMC (MM) user, 
`-t` = object **t**ype, `--template` = name of the xCAT shipped object 
definition template or an existing object, from which the new object 
definition will be created.  


**Note:**  For the `mac` attribute, use the `MAC Address 1` you obtained above. 


```
# mkdef \
-t node \
abacus109 \
--template x86_64-template \
ip=192.168.80.9 \
mac=00:11:22:33:44:55 \
bmc=192.168.80.135 \
bmcusername=xadmin \
bmcpassword=yourBMCpassword
```


**"Fix for Blade"**   
Since it's on a blade server, you have to adjust this compute node's 
xCAT definition and make it blade-specific.  Also, while you are 
already making changes, modify serial port settings that this 
particular blade model (IBM HS21) requires for SOL (Serial Over LAN) 
to work; specfically, it asks it to be the second serial device 
(in Unix/BSD/Linux numbering style it starts with zero so the second 
device will be `1`) with serial speed of 19200: 

```
# chdef \
-t node \
-o abacus109 \
cons=blade mgt=blade getmac=blade serialport=1 serialspeed=19200
```


**Note:**  The domain of the xCAT node must be provided in an xCAT 
network definition or the xCAT site definition.  Otherwise, two commands 
in the subsequent steps for configuring DNS (`makehosts` and `makedns -n`) 
will not work.  In this example, an assumption is that you've alredy 
defined the `domain` attribute in the `site` table:    

```
# tabdump site | grep domain
"domain","mydomain.com",,
```

Continuing with the setup: 

```
# makehosts
```

This adds the compute node being created to `/etc/hosts`. Specifically, 
this line is added to the `/etc/hosts` file:   
`192.168.80.9 abacus109 abacus109.mydomain.com`   


Update DNS records with the `makedns(8)` command.  
(This also restarts `named` service.)

```
# makedns -n
```

```
# makedhcp abacus109
```

You can confirm that it worked by using the `-q` option:

```
# makedhcp -q abacus109
abacus109: ip-address = 192.168.80.9, hardware-address = 00:11:22:33:44:55
```

This updates `/etc/dhcp/dhcpd.conf` file with a line:  

```
#definition for host abacus109 aka host abacus109 can be found in the 
dhcpd.leases file (typically /var/lib/dhcpd/dhcpd.leases)`
```

and if you check the `/var/lib/dhcpd/dhcpd.leases` file, the compute 
node's  dhcp definition is there: 


```
# grep -n abacus109 /var/lib/dhcpd/dhcpd.leases
106:host abacus109 {
111:        supersede server.ddns-hostname = "abacus109";
112:        supersede host-name = "abacus109";
117:                                "http://${next-server}:80/tftpboot/xcat
/xnba/nodes/abacus109";
121:                                "http://${next-server}:80/tftpboot/xcat
/xnba/nodes/abacus109.uefi";
```


Add the new compute node to the `mp` table.   
(The `mpa` table has already been defined and linked to the 
 BMC (named *xbcmm1n*) in the `mp` table.) 


```
# chtab \
node=abacus109 \
mp.mpa=xbcmm1n \
mp.id=9
```

```
# lsdef -t osimage -i synclists
Object name: centos7.9-x86_64-install-compute
    synclists=/install/custom/install/centos/compute.centos7.x86_64.synclist
Object name: centos7.9-x86_64-netboot-compute
    synclists=
Object name: centos7.9-x86_64-statelite-compute
    synclists=
```


Explanation for options: `-t`: type, `-o`: object, `-i`: information/inquire.

```
# lsdef -t node -o abacus109 -i postscripts
Object name: abacus109
    postscripts=syslog,remoteshell,syncfiles
```

```
# lsdef abacus109 -i postscripts,postbootscripts
Object name: abacus109
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
```


So you need to add the necessary (for this particular configuration; 
that is, configuration of this example) scripts (both `postscripts` 
and `postbootscripts`) to the compute node that is being provisioned.
In other words, you are updating rows `postscripts` and `postbootscripts` 
in the table `postscripts`. From the `chtab(8)` command's usage:   
> `keycolname=keyvalue`   a column name-and-value pair that identifies the 
>                         rows in a table to be changed.
>   
> `tablename.colname=newvalue`    the new value for the specified row and 
>                                 column of the table.


```
# tabdump postscripts
#node,postscripts,postbootscripts,comments,disable
---- snip ----
```

So, the `keycolname` is `node` with value being the name of the 
node (`abacus109`), while the `tablename.colname=newvalue` are 
`postscripts.postscripts=setupntp,compute_custom_post` and 
`postscripts.postbootscripts=abacus_custom_postboot`. 


After this (long) explanation, run the actual command:   

```
# chtab \
node=abacus109 \
postscripts.postscripts=setupntp,compute_custom_post \
postscripts.postbootscripts=abacus_custom_postboot
```

Now the node includes all the needed scripts:

```
# lsdef abacus109 -i postscripts,postbootscripts
Object name: abacus109
    postbootscripts=otherpkgs,abacus_custom_postboot
    postscripts=syslog,remoteshell,syncfiles,setupntp,compute_custom_post
```

Check `abacus109` hardware control.  `abacus109` power management:

```
# rpower abacus109 state
abacus109: on
```

Similarly, you can check communication with the node with `rinv(1)`:

```
# rinv abacus109 all
abacus109: Machine Type/Model: 8853AC1
abacus109: Serial Number: ThisBlade'sSerialNumberHere
abacus109: MAC Address 1: 00:11:22:33:44:55 
abacus109: MAC Address 2: 00:11:22:33:44:56 
abacus109: Management Module firmware: 62 (BPET62C 06/23/2011)
```

The newly added compute node now appears in the nodes list:  

```
# nodels
---- snip ----
abacus109
---- snip ----
```


Check boot order on the node and whether it'sa configured to boot from 
the Ethernet (net) device. 

**Note:** On IBM BladeCenter (which is the case here), you only have
`rbootseq` and not `rsetboot`. 

[Re: [xcat-user] Problem with rsetboot: unable to identify plugin](https://www.mail-archive.com/xcat-user@lists.sourceforge.net/msg05290.html)
(Retrieved on Mar 20, 2022):   

> On BladeCenter, you [only] have `rbootseq`.  ... 

```
# rbootseq abacus109 list
abacus109: hd0,cdrom,none,none
```

In this case, the blade was not configured to boot from the Ethernet (net) 
device so you need to change it with the `rbootseq(1)` command: 

```
# rbootseq abacus109 net,hd0,cdrom,none
```

Confirm that the boot order has been changed: 

```
# rbootseq abacus109 list
abacus109: net,hd0,cdrom,none
```


Make sure that `goconserver.service` is running.  

```
# systemctl is-active goconserver.service
active
```

Register the node for an instance of the console (serial console) session: 

```
# makegocons -D abacus109
```

After the node is registered for an instance of the console session , 
the `consoleenabled` attribute has been added and set to `1` for the node:

```
# lsdef abacus109 | grep console
    consoleenabled=1
```

Ensure that the node's status is `connected` by querying its 
console connection state.

```
# makegocons -q abacus109
NODE                       SERVER                     STATE
abacus109                  xcatmn.mydomain.com        connected
```

Start provisioning the node. 

```
# xcatprobe osdeploy -n abacus109
```

Output:

```
# xcatprobe osdeploy -n abacus109
The install NIC in current server is eth1                             [INFO]
All nodes to be deployed are valid                                    [ OK ]
-------------------------------------------------------------
Start capturing every message during OS provision process....
-------------------------------------------------------------
```

Launch a separate shell session and in there (a.k.a. the second terminal), 
start installation process.  (The `nodeset(8)` command sets the boot 
state for a node or node range.)  

The `osimage=imagename` option (from the manual page for the `nodeset(8)` 
command):    
"Prepare server for installing a node using the specified os
image. The os image is defined in the `osimage` table and
`linuximage` table."    


```
# tabdump osimage
#imagename,groups,profile,imagetype,description,provmethod,rootfstype,osdistroname,osupdatename,cfmdir,osname,osvers,osarch,synclists,postscripts,postbootscripts,serverrole,isdeletable,kitcomponents,environvar,comments,disable
"centos7.9-x86_64-install-compute",,"compute","linux",,"install",,"centos7.9-x86_64",,,"Linux","centos7.9","x86_64","/install/custom/install/centos/compute.centos7.x86_64.synclist",,,,,,,,
"centos7.9-x86_64-netboot-compute",,"compute","linux",,"netboot",,"centos7.9-x86_64",,,"Linux","centos7.9","x86_64",,,,,,,,,
"centos7.9-x86_64-statelite-compute",,"compute","linux",,"statelite",,"centos7.9-x86_64",,,"Linux","centos7.9","x86_64",,,,,,,,,
```


```
# nodeset abacus109 osimage=centos7.9-x86_64-install-compute
```


### Fix for `rpower <nodename> boot`

Back in the second terminal, as per the message above, to reboot the 
compute node `abacus109` you would normally use this `rpower` 
command here: `rpower abacus109 boot`.   

However, at least in this setup, I've found it inconsistent because when 
running that command, the compute node would power off **but** would not 
power back on; that is, it wouldn't actually restart.  (Even though the 
man page for the `rpower(8)` command says for the `boot` option: 
"`boot`:  If off, then power on.  If on, then hard reset.  This option 
is **recommended** (*emphasis mine*) over `cycle` [option].

I had to add the following options to the `rpower(8)` command to make 
the installation work; that is, to turn the node off and then on. 
(Alternitavely, you could first manually turn the node off: 
`rpower abacus109 off`, and then on:  `rpower abacus109 on`.)    


Explanation for the options used in the `rpower(8)` command below
(from the manpage for the `rpower(8)` command):

* "`-r retrycount`
specify the number of retries that the monitoring process will
perform before declaring the failure. The default value is `3`.
Setting the `retrycount` to `0` means only monitoring the os
installation progress and will not re-initiate the installation if
the node status has not been changed to the expected value after
timeout.  This flag **must** (*emphasis mine*) be used with `-m` flag."
* "`-m table.column==expectedstatus -m table.column=~expectedstatus`
Use one or multiple `-m` flags to specify the node attributes and the
expected status for the node installation monitoring and automatic
retry mechanism.  The operators `==`, `!=`, `=~` and `!~` are valid. 
This flag **must** (*emphasis mine*) be used with `-t` flag."

  **Note:**  While `powering-on` is not listed as one of valid values 
  of the `status` (`nodelist.status`) in the manpage for `node(7)` 
  or `nodelist(5)`, in my tests it worked more reliable than using 
  `-m nodelist.status==booting` or `-m nodelist.status==installing`.
  <sup>[9](#footnotes)</sup> 

* "`-t timeout`
Specify the timeout, in minutes, to wait for the expectedstatus
specified by `-m` flag. This is a **required** (*emphasis mine*) flag if 
the `-m` flag is specified.  Power off, then on."   


In the second terminal, run the following command.
(**Note:**  You need to use the `==` (double equal sign), 
 a.k.a. *comparison operator* when testing for the expected status 
 with the `-m` option.) 

```
# rpower \
abacus109 \
boot \
-r 0 \
-m nodelist.status==powering-on \
-t 5
```


The first terminal updates with the following:

```
[abacus109] 19:37:29 Use command rpower to reboot node abacus109
```


And then in less than ten seconds, the first terminal displays another line:

```
[abacus109] 19:37:36 Node status is changed to powering-on
```


Launch yet another separate shell session and in there (let's call it 
the third terminal), check and monitor provisioning process. (**NOTE:** 
For the `rcons` to work, the node's BIOS must be configured  for 
SOL (Serial Over LAN), a.k.a. Text Mode Console. <sup>[10](#footnotes)</sup>)

```
# rcons abacus109
```


The output shows that the node is booting up:

```
[Enter `^Ec?' for help]
goconserver(2022-08-11T20:06:46-07:00): Hello 192.168.80.220:58102, 
welcome to the session of abacus109
>> BIOS Version 1.15 <<

Press F1 for Configuration/Setup
Press F2 for Diagnosticsbacus109
Press F12 for Boot Device Selection Menu

Broadcom NetXtreme II Ethernet Boot Agent v3.4.8
Copyright (C) 2000-2007 Broadcom Corporation
All rights reserved.

---- snip ----

Initializing../ 

---- snip ----
```


After 5-10 minutes, output in the third terminal shows that 
the OS installation is finishing.

```
Installing boot loader
.
Performing post-installation setup tasks
.

Configuring installed system
.
Writing network configuration
.
Creating users
.
Configuring addons
.
Generating initramfs
.
Running post-installation scripts

```


You can check the provision status in/from the second terminal:

```
# lsdef abacus109 -i status
Object name: abacus109
    status=installing
```


After post-installation scripts are done, the node will reboot (run this 
in the second terminal again): 

```
# lsdef abacus109 -i status
Object name: abacus109
    status=booting
```

Again in the second terminal after a couple of minutes:

```
# lsdef abacus109 -i status
Object name: abacus109
    status=failed
```

However, in the third terminal; it shows that the OS booted fine, and 
even logged in fine:

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

abacus109 login: root 
Password:

[root@abacus109 ~]#
```

Check the provision status in the first terminal, where the output is 
now long and most likely has been completed:   

```
---- snip ----
[abacus109] 20:24:39 INFO done
[abacus109] 20:24:39 INFO ready
[abacus109] 20:24:39 INFO done
[abacus109] 20:24:39 Node status is changed to failed
All nodes specified to monitor, have finished OS provision process    [ OK ]
======================  Summary  =====================
There is 1 node provision failures
abacus109 : stop at stage 'booting'                                   [FAIL]
   postscript end...: syncfiles return with 1
```

In this case, there was an issue with postscripts and that'll need to be fixed.


Also, `xdsh` check worked:


```
# xdsh abacus109 more /etc/*release
abacus109: ::::::::::::::
abacus109: /etc/centos-release
abacus109: ::::::::::::::
abacus109: CentOS Linux release 7.9.2009 (Core)
abacus109: ::::::::::::::
abacus109: /etc/os-release
abacus109: ::::::::::::::
abacus109: NAME="CentOS Linux"
abacus109: VERSION="7 (Core)"
abacus109: ID="centos"
abacus109: ID_LIKE="rhel fedora"
abacus109: VERSION_ID="7"
abacus109: PRETTY_NAME="CentOS Linux 7 (Core)"
---- snip ----
```


If there are remnants from a previous node setup, the host key has been 
changed and you'll receive a warning about it:

```
[xcatmn]: abacus109: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
abacus109: @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
abacus109: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
---- snip ---
abacus109: It is also possible that a host key has just been changed.
abacus109: The fingerprint for the ED25519 key sent by the remote host is
abacus109: SHA256:I04c7IX......
---- snip ---
abacus109: Add correct host key in /root/.ssh/known_hosts to get rid of this message.
abacus109: Offending ECDSA key in /root/.ssh/known_hosts:19
---- snip ----
```


To fix the warning about the host key, remove the line in question:

```
# sed -i.bkp '19d' /root/.ssh/known_hosts
```


The xdsh now works without the warning: 

```
# xdsh abacus109 more /etc/*release
abacus109: ::::::::::::::
abacus109: /etc/centos-release
abacus109: ::::::::::::::
abacus109: CentOS Linux release 7.9.2009 (Core)
---- snip ----
[xcatmn]: abacus109: Warning: Permanently added 'abacus109,192.168.80.9' (ED25519) to the list of known hosts.
```


If you want, you can remove backed up `known_hosts` file now:

```
# rm -i ~/.ssh/known_hosts.bkp
```


Check whether the run of the scripts worked.

Yeah, it worked for `synclist`; that is `compute.centos7.x86_64.synclist`:

```
# xdsh abacus109 ls -lh /opt/torque/ 
abacus109: total 4.0K
abacus109: drwxr-xr-x. 2 root root 4.0K May 16  2009 bin
abacus109: drwxr-xr-x. 2 root root   92 May 16  2009 include
abacus109: drwxr-xr-x. 2 root root  113 May 16  2009 lib
abacus109: drwxr-xr-x. 6 root root   54 May 16  2009 man
abacus109: drwxr-xr-x. 2 root root  147 May 16  2009 sbin
abacus109: drwxr-xr-x. 3 root root   19 May 16  2009 var

# xdsh abacus109 du -chs /opt/torque/ 
abacus109: 108M /opt/torque/
abacus109: 108M total
```

```
# xdsh abacus109 cat /etc/passwd 
---- snip ----
```

```
# xdsh abacus109 cat /etc/group
---- snip ----
```

It also worked for the `compute_custom_post` script run:

```
# xdsh abacus109 cat /etc/fstab
---- snip ----
abacus109: mgmt:/home    /home    nfs  defaults  1 2
abacus109: mgmt:/global  /global  nfs  defaults  1 2
```

```
# xdsh abacus109 df -hT 
abacus109: Filesystem              Type      Size  Used Avail Use% Mounted on
---- snip ---
abacus109: mgmt:/home              nfs4      5.0T  1.8T  3.3T  36% /home
abacus109: mgmt:/global            nfs4      3.9T  637G  3.3T  17% /global
```

```
# xdsh abacus109 cat /etc/hosts
---- snip ----
abacus109: 192.168.80.210 mgmt
```


The `setupntp` script run worked too:

```
# xdsh abacus109 systemctl is-active chronyd.service
abacus109: active
```

```
# xdsh abacus109 systemctl status chronyd.service
abacus109: * chronyd.service - NTP client/server
abacus109:    Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
abacus109:    Active: active (running) since Fri 2022-03-20 18:53:38 PDT; 2min ago
---- snip ----
```


Yep, the `abacus_custom_postboot` script run worked as well:

```
# xdsh abacus109 systemctl is-active pbs_mom.service
abacus109: active

# xdsh abacus109 systemctl status pbs_mom.service
abacus109: * pbs_mom.service - PBS Mom service
abacus109: Loaded: loaded (/etc/systemd/system/pbs_mom.service; enabled; vendor preset: disabled)
abacus109: Active: active (running) since Fri 2022-03-20 18:53:39 PDT; 2min ago
```

```
# xdsh abacus109 --verify ls -lh /
abacus109: total 28K
---- snip ----
```


The only thing left is to run a test job as explained above, under 
[Submit a Test Job to a Specific Node](#submit-a-test-job-to-a-specific-node).  

---

**[TODO]**  Temporary/currently: no systemd for pbs_server and pbs_sched so
for now starting them manually:   

```sudo /etc/rc.d/init.d/pbs_server start``` and    
```sudo /etc/rc.d/init.d/pbs_sched start```      

---


**[TODO]**  Migrate network restart with `at` to Appendix.

Restart networking and see if network interfaces are in the routing table.

If you are not logged in to the server directly via console; for example,
if you are logged in via ssh, use the `at(1)` utility, with the sequence 
of commands below.

**NOTE:**
To end input, generate the *end-of-file* (EOF) character [¹](#footnotes)
(aka *eof command*) by pressing **Ctrl D** (usually abbreviated `^D`)
on an empty line.
For additional details, refer to the man page for the current shell,
in this case **csh**/**tcsh**.   

```
$ sudo at now+3min
warning: commands will be executed using /bin/sh
at> sudo systemctl stop NetworkManager
at> sleep 5
at> sudo systemctl start NetworkManager
at> <EOT>
job 1 at Thu Mar 20 15:01:00 2022
```

You can check terminal line settings for EOF with the `stty(1)`:


```
$ stty --all | wc -l

$ stty --all | grep -i EOF
intr = ^C; quit = ^\; erase = ^H; kill = ^U; eof = ^D; eol = <undef>
```

Or:

```
$ stty --help | grep 'eof CHAR'
   eof CHAR      CHAR will send an end of file (terminate the input)
```

From the man page for stty(1):

```
[...]
Special characters:
[...]
    eof CHAR
           CHAR will send an end of file (terminate the input)
```

```
$ netstat -rn
Kernel IP routing table
Destination     Gateway        Genmask        Flags  MSS Window irtt Iface
0.0.0.0         123.12.23.254  0.0.0.0        UG       0 0         0 eno1
123.12.23.0     0.0.0.0        255.255.255.0  U        0 0         0 eno1
192.168.80.0    0.0.0.0        255.255.255.0  U        0 0         0 eno2
192.168.122.0   0.0.0.0        255.255.255.0  U        0 0         0 virbr0
```

---

---

**[TODO]**  Show this as an alternative setup - and move it to Appendix 

## Management Node Setup  

All the following steps should be executed on the server with the 
management node role. 


### Create Local CentOS Packages Repository 


```
$ sudo dnf clean metadata
```

```
$ sudo dnf update  
```

The CentOS 7 DVD ISO image has been transferred to /tmp when the content 
of the image was customized: 
[Customize CentOS/RHEL DVD ISO for Installation in Text Mode via Serial Console and Test the Image with QEMU]({% post_url 2022-03-12-centos-rhel-dvd-iso-customization-testing-with-qemu %}).   


**[TODO]**  Check if the link above will work on GitHub Pages   


```
$ sudo mkdir -p /install/isos/centos7
```

Place the ISO to the following directory:

```
$ sudo mv /tmp/CentOS-7-x86_64-DVD-2009-HS21.iso /install/isos/
```


```
$ sudo mkdir -p /mnt/dvd
```

Mount the ISO as follows.

```
$ sudo \
mount -o loop \
/install/isos/CentOS-7-x86_64-DVD-2009-HS21.iso \
/mnt/dvd/
```

```
$ df -hT | grep iso9660
/dev/loop0            iso9660   4.5G  4.5G     0 100% /mnt/dvd
```


```
$ sudo \
cp -a \
/mnt/dvd/* \
/install/isos/centos7
```


```
$ sudo umount /mnt/dvd
```

Create the CentOS repo file for the local repository. 

```
$ sudo vi /etc/yum.repos.d/centos7-local.repo
```

```
$ cat /etc/yum.repos.d/centos7-local.repo
[centos]
name=CentOS $releasever - $basearch
baseurl=file:///install/isos/centos7
enabled=1
gpgcheck=0
```

Confirm that the repo is enabled:

```
$ dnf repolist --all | grep centos
centos                CentOS 8 - x86_64    enabled
```

Install createrepo package.

This utility generates a common metadata repository from a directory 
of RPM packages. 

It defines the RPM-metadata (**repodata**) format and maintains one of 
the programs (**createrepo**) which create this format from existing RPMs 
and other sources.


Project's URI/URL: [http://createrepo.baseurl.org/](http://createrepo.baseurl.org/):   
(Retrieved on Mar 20, 2022)   

> The files break down as follows:
> 
> * repomd.xml this is the file that describes the other metadata files. 
>   It is like an index file to point to the other files. It contains 
>   timestamps and checksums for the other files. This lets a client 
>   download this one, small file and know if anything else has changed. 
>   This also means that cryptographically (ex: gpg) signing this one file 
>   can ensure repository integrity. 
> 
> * primary.xml.[gz] this file stores the primary metadata information. 
>   This includes information such as:
>   * name, epoch, version, release, architecture
>   * file size, file location, description, summary, format, 
>     checksums header byte-ranges, etc.
>   * dependencies, provides, conflicts, obsoletes, suggests, recommends
>   * file lists for the package for CERTAIN files - specifically files 
>     matching: /etc*, *bin/*, /usr/lib/sendmail [1] 
> * filelists.xml.[gz] this file stores the complete file and directory 
>   listings for the packages. The package is identified by: name, epoch, 
>   version, release, architecture and package checksum id.
> * other.xml.[gz] this file currently only stores the changelog data 
>   from packages. However, this file could be used for any other 
>   additional metadata that could be useful for clients.
> * groups.xml.[gz] this file is tentatively described. The intention is 
>   for a common package-groups specification as well. There is still 
>   some sections for this format that need to be fleshed out. 


```
$ sudo dnf install createrepo
```

```
$ sudo mkdir -p /install/centos7
```

The createrepo requires an argument which is the directory in which you 
would like to generate the repository data.  Since the packages directory 
will be in `/install/centos7`, run the following:   

```
$ sudo createrepo /install/centos7
Directory walk started
Directory walk done - 0 packages
Temporary output repo path: /install/centos7/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
```

```
$ ls -lh /install/centos7/repodata/
total 28K
-rw-r--r-- 1 root root 1.4K Mar 20 15:22 19699a08[...]87e3-primary.sqlite.bz2
-rw-r--r-- 1 root root  134 Mar 20 15:22 1cb61ea9[...]d7d8bcae-primary.xml.gz
-rw-r--r-- 1 root root  609 Mar 20 15:22 878c2f1d[...]b9-filelists.sqlite.bz2
-rw-r--r-- 1 root root  123 Mar 20 15:22 95a4415d[...]fb2a5f-filelists.xml.gz
-rw-r--r-- 1 root root  123 Mar 20 15:22 ef3e2069[...]9e070aaab6-other.xml.gz
-rw-r--r-- 1 root root  571 Mar 20 15:22 f660753f[...]78d966-other.sqlite.bz2
-rw-r--r-- 1 root root 3.0K Mar 20 15:22 repomd.xml
```

```
$ sudo dnf clean all
```

---

#### xCAT Backup   **[TODO]**  <-- Move it to Appendix

```
$ sudo mkdir /tmp/xcatsnapdirbkp
$ sudo /opt/xcat/sbin/xcatsnap -d /tmp/xcatsnapdirbkp
```

Also:

```
# mkdir /tmp/xCAT_Backup
# dumpxCATdb -a -p /tmp/xCAT_Backup
# restorexCATdb -p /tmp/xCAT_Backup
```

--- 

**[TODO]**   Change the title - and migrate it to Troubleshooting section
(after first creating the Troubleshooting section)   

### If You Encounter a Certificate Error   


```
$ lsxcatd -a
Unable to open socket connection to xcatd daemon on localhost:3001.
Verify that the xcatd daemon is running and that your SSL setup is correct.
Connection failure: SSL connect attempt failed error:0407008A:rsa 
  routines:RSA_padding_check_PKCS1_type_1:invalid padding 
  error:04067072:rsa routines:rsa_ossl_public_decrypt:padding check failed 
  error:0D0C5006:asn1 encoding routines:ASN1_item_verify:EVP 
  lib error:1416F086:SSL 
  routines:tls_process_server_certificate:certificate verify failed at 
  /opt/xcat/lib/perl/xCAT/Client.pm line 282.
```

Set the environment variable ```XCATBYPASS``` to ```Y``` and 
keep using it until you fix this certificate error. 

```
$ sudo "XCATBYPASS=Y" csh -c 'lsxcatd -a'
Version 2.16.3 (git commit d6c76ae5f66566409c3416c0836660e655632194, 
  built Wed Nov 10 09:58:20 EST 2021)
  This is a Management Node
dbengine=SQLite
```


```
$ sudo "XCATBYPASS=Y" csh -c 'tabdump site'
---- snip ----
```

---

### lsslp **[TODO]** Expand on `lsslp` and possibly put it in a separate section


The nodes which the user wants to discover.  

Use the lsslp command to discover **selected** networked services 
information within the same subnet.  The request is sent out all 
available network adapters. 

If the user specifies the noderange, lsslp will just return the nodes in 
the node range. 

Which means it will help to add the new nodes to the xCAT database 
without modifying the existed definitions. 

But the nodes' name specified in noderange should be defined in database 
in advance. 

---

## Appendix 

### Running QEMU Guest in the Background

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br0",id=hn0 \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=br1",id=hn1 \
-device virtio-net-pci,netdev=hn0 \
-device virtio-net-pci,netdev=hn1 \
-daemonize
```

**Note:**  `-nographic` cannot be used with `-daemonize`. 

Then, connect (log into) the guest OS:

```
$ ssh root@123.12.23.235
```

----

### PBS History

From
[OpenPBS Community Forum - PBS Default number of nodes and number of cpus](https://community.openpbs.org/t/pbs-default-number-of-nodes-and-number-of-cpus/834/4) 

Comment by user *scott* (Scott Suchyta) on Jan 4, 2018:
> So a little history for your knowledge.
> 
> PBS was originally developed for NASA under a contract project. Altair Engineering acquired the rights to all the PBS technology and intellectual property from Veridian in 2003. Altair Engineering currently owns and maintains the intellectual property associated with PBS, and also employs the original development team from NASA.
> 
> The following versions of PBS are currently available:
> * OpenPBS - original open source version released by MRJ in 1998 (not actively developed)
> * TORQUE - a fork of OpenPBS that is maintained by Adaptive Computing Enterprises, Inc. (formerly Cluster Resources, Inc.)
> * PBS Professional (PBS Pro) — the version of PBS offered by Altair Engineering that is dual licensed under an open source and a commercial license.
> 
> PBS Professional has a more modern language specification for job submission, which is called select/place. If using PBS Professional, I would suggest using queuejob hook to evaluate the user’s job submission and modify the select/place requirements to meet your combination check.

----

### How To Change Node Name with/from/in xCAT

Change node name from `cn14` to `abacus14`.   

```
# chdef \
-t node \
-o cn14 \
-n abacus14
```

```
# makehosts abacus14
# makedns -n
# makedhcp -n
# makehosts abacus14
# makehosts -n
# makedhcp abacus14
```

```
# makedhcp -q all 
abacus14: ip-address = 192.168.80.114, hardware-address = 00:21:5e:2c:0a:ac
cn13: ip-address = 192.168.80.113, hardware-address = 00:21:5e:2c:15:a4
```

---

### Troubleshooting Postscripts and Postbootscripts

The following steps need to be run on the management 
node, `xcatmn.mydomain.com`.  

Confirm that the object `osimage` has the attribute `synclists`.
(Options: `-t`: type, `-i`: information/inquire).   

```
# lsdef -t osimage -i synclists
Object name: centos7.9-x86_64-install-compute
    synclists=/install/custom/install/centos/compute.centos7.x86_64.synclist
Object name: centos7.9-x86_64-netboot-compute
    synclists=
Object name: centos7.9-x86_64-statelite-compute
    synclists=
```


Since it's included in the `osimage` object, the `syncfiles` has been 
addeed to the `postscripts` attribute of the compute node that you're 
configuring (`abacus109`).
(Options: `-t`: type, `-o`: object, `-i`: information/inquire).    

```
# lsdef -t node -o abacus109 -i postscripts
Object name: abacus109
    postscripts=syslog,remoteshell,syncfiles
```

```
# lsdef abacus109 | grep profile
    profile=compute
```

```
# lsdef abacus109 | grep provmethod 
    provmethod=centos7.9-x86_64-install-compute
```

```
# lsdef abacus109 | grep -w -i os 
    os=centos7.9
```

```
# nodels abacus109 nodetype | grep profile
abacus109: nodetype.profile: compute
```

```
# tabdump nodetype
#node,os,arch,profile,provmethod,supportedarchs,nodetype,comments,disable
---- snip ----
"abacus109","centos7.9","x86_64","compute","centos7.9-x86_64-install-compute",,,,
```


As of now, the `postscripts` attribute for the node `abacus109` has not 
been updated with the required scripts.  From the definition of the object 
type `node`, for the object `abacus109`, display the attribute `postscripts`. 
You'll notice that  both `setupntp` and `compute_custom_post` have not 
been appended to the `postscripts` line:  

```
# lsdef -t node -o abacus109 -i postscripts
Object name: abacus109
    postscripts=syslog,remoteshell,syncfiles
```

Similarly, when you ask for the `postbootscripts` attribute of the node 
`abacus109`, the `abacus_custom_postboot` script is missing from 
the `postbootscripts` line:

```
# lsdef -t node -o abacus109 -i postbootscripts
Object name: abacus109
    postbootscripts=otherpkgs
```

**NOTE:**  The following two `nodegrpch` commands do not need to be run 
if you've already setup `postscripts` and `postbootscripts` for the 
`compute` group. 

Upgrade the group `compute` with the required `postscripts` 
and `postbootscripts` script files:

```
# nodegrpch compute postscripts.postscripts=setupntp,compute_custom_post
# nodegrpch compute postscripts.postbootscripts=abacus_custom_postboot
```

Confirm that it's been done:

```
# tabdump postscripts
#node,postscripts,postbootscripts,comments,disabl
---- snip ----
"compute","setupntp,compute_custom_post","abacus_custom_postboot",,
```

Also, you'll see that the compute node (`abacus109`) has not been added 
to the `postscripts` table: 

```
# tabdump postscripts | grep abacus109
```

Update the node by adding the required `postscripts` and `postbootscripts` 
script files to it: 

```
# chtab \
node=abacus109 \
postscripts.postscripts=setupntp,compute_custom_post \
postscripts.postbootscripts=abacus_custom_postboot
```

To confirm that the needed postscripts are now included with the node:

```
# lsdef abacus109 | grep postscripts 
    postscripts=syslog,remoteshell,syncfiles,setupntp,compute_custom_post
```

```
# lsdef abacus109 | grep postbootscripts
    postbootscripts=otherpkgs,abacus_custom_postboot
```

```
# tabdump postscripts
#node,postscripts,postbootscripts,comments,disable
---- snip ----
"abacus109","setupntp,compute_custom_post","abacus_custom_postboot",,
```

```
# tabdump postscripts | grep abacus109
"abacus109","setupntp,compute_custom_post","abacus_custom_postboot",,
```

Continuing with the setup, confirm that the node's profile is `compute` 
as that's the name of the whole group you modified earlier above.

```
# nodels abacus109 nodetype
abacus109: nodetype.arch: x86_64
abacus109: nodetype.node: abacus109
abacus109: nodetype.os: centos7.9
abacus109: nodetype.profile: compute
abacus109: nodetype.provmethod: centos7.9-x86_64-install-compute
abacus109: nodetype.supportedarchs: 
abacus109: nodetype.comments: 
abacus109: nodetype.nodetype: 
abacus109: nodetype.disable: 
```

```
# tabdump nodetype
#node,os,arch,profile,provmethod,supportedarchs,nodetype,comments,disable
---- snip ----
"abacus109","centos7.9","x86_64","compute","centos7.9-x86_64-install-compute",,,,
```

```
# lsdef -t node -o abacus109 -i postscripts
Object name: abacus109
    postscripts=syslog,remoteshell,syncfiles,setupntp,compute_custom_post
```

```
# lsdef -t node -o abacus109 -i postbootscripts
Object name: abacus109
    postbootscripts=otherpkgs,abacus_custom_postboot
```

Set `xcatdebugmode` in the `site` table to `2`.


```
# chdef -t site xcatdebugmode=2
```

Push `syncfiles` to the node.

```
# updatenode abacus109 -P syncfiles
```

```
# updatenode abacus109 -F -V
```


Log in to the compute node (`abacus109`).  

**NOTE:**  For the `rcons` to work, the node's BIOS must be configured
for SOL (Serial Over LAN), a.k.a. Text Mode Console. <sup>[10](#footnotes)</sup>

```
# rcons abacus109
```

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

abacus109 login: root
Password:

[root@abacus109 ~]#
```

Run the following command:

```
# USEOPENSSLFORXCAT=1 \
XCATSERVER=192.168.80.220:3001 \
/xcatpost/startsyncfiles.awk -v RCP=/usr/bin/rsync
```

Exit the compute node.


```
# exit
```

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

abacus109 login:
```

Press `Ctrl-e` `c` `.` (three characters: Ctrl-e, 'c' and '.') to 
disconnect by closing the session with the `makegocons`.   


Back in the management node, `xcatmn.mydomain.com`:


```
# xdcp abacus109 -F /install/custom/install/centos/compute.centos7.x86_64.synclist
```

Update the node `abacus109` but limit it to only run the scripts.


```
# updatenode abacus109 -P
```

Check whether the run of the scripts worked.

Yeah, it worked for `synclist`; that is `compute.centos7.x86_64.synclist`:

```
# xdsh abacus109 ls -lh /opt/torque/ 
abacus109: total 4.0K
abacus109: drwxr-xr-x. 2 root root 4.0K May 16  2009 bin
abacus109: drwxr-xr-x. 2 root root   92 May 16  2009 include
abacus109: drwxr-xr-x. 2 root root  113 May 16  2009 lib
abacus109: drwxr-xr-x. 6 root root   54 May 16  2009 man
abacus109: drwxr-xr-x. 2 root root  147 May 16  2009 sbin
abacus109: drwxr-xr-x. 3 root root   19 May 16  2009 var

# xdsh abacus109 du -chs /opt/torque/ 
abacus109: 108M /opt/torque/
abacus109: 108M total
```

```
# xdsh abacus109 cat /etc/passwd 
---- snip ----
```

```
# xdsh abacus109 cat /etc/group
---- snip ----
```


It also worked for the `compute_custom_post` script run:

```
# xdsh abacus109 cat /etc/fstab
---- snip ----
abacus109: mgmt:/home    /home    nfs  defaults  1 2
abacus109: mgmt:/global  /global  nfs  defaults  1 2
```

```
# xdsh abacus109 df -hT 
abacus109: Filesystem              Type      Size  Used Avail Use% Mounted on
---- snip ---
abacus109: mgmt:/home              nfs4      5.0T  1.8T  3.3T  36% /home
abacus109: mgmt:/global            nfs4      3.9T  637G  3.3T  17% /global
```

```
# xdsh abacus109 cat /etc/hosts
---- snip ----
abacus109: 192.168.80.210 mgmt
```

The `setupntp` script run worked too:

```
# xdsh abacus109 systemctl is-active chronyd.service
abacus109: active
```

```
# xdsh abacus109 systemctl status chronyd.service
abacus109: * chronyd.service - NTP client/server
abacus109:    Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
abacus109:    Active: active (running) since Fri 2022-03-20 18:53:38 PDT; 2min ago
---- snip ----
```

Yep, the `abacus_custom_postboot` script run worked as well:

```
# xdsh abacus109 systemctl is-active pbs_mom.service 
abacus109: active

# xdsh abacus109 systemctl status pbs_mom.service 
abacus109: * pbs_mom.service - PBS Mom service
abacus109: Loaded: loaded (/etc/systemd/system/pbs_mom.service; enabled; vendor preset: disabled)
abacus109: Active: active (running) since Fri 2022-03-20 18:53:39 PDT; 2min ago
```

```
# xdsh abacus109 --verify ls -lh /
abacus109: total 28K
---- snip ----
```


**NOTE:**   
If the above `updatenode abacus109 -P` does not work, you can try fixing 
it by the following sequence of commands:

```
# updatenode abacus109 -P syncfiles
# updatenode abacus109 -P "confignetwork -s"
# updatenode abacus109 -P
# updatenode abacus109 -P -F -V
# updatenode abacus109 -P syncfiles -P "confignics -s"
# updatenode abacus109 -P syncfiles -F -V
# xdsh abacus109 shutdown -r now
```

*Explanation:*    
If you want to run all the customization scripts that have been designated for the `abacus109` node (in the `postscripts` and `postbootscripts` attributes), the `-P` option (i.e, the command: `updatenode abacus109 -P`) will not work after install.  Instead, after install use the `-F` option for file synchronization (including synchronization of the `postscripts` and `postbootscripts` attributes).

From the man page for the `updatenode(1)` command:

```
-F|--sync     Specifies that file synchronization should be performed on the
              nodes.  rsync/scp and ssh must be installed and configured on
              the nodes.
[...]
-P|--scripts  Specifies that postscripts and postbootscripts should be run on
              the nodes.  File sync with updatenode -P syncfiles is not
              supported.  The syncfiles postscript can only be run during
              install.  You should use updatenode -F instead.
```

---


### Useful/Typicall (First) Commands in the Guest VM with xCAT on It

```
# uptime
# hostname
# ifconfig
# ifconfig -1
# ip address show
# ip -d address show       (ip -d a s)
# ip link show
# ip neigh                 (ip neighbour, ip neighbor) 
# nmcli device status
# nmcli connection show
# netstat -rn
# netstat -r
# ip route
# cat /etc/resolv.conf
# cat /etc/hosts
# ping -c2 freebsd.org
# ping -c2 192.168.80.210   <-- forwarder (DNS server)
# ping -c2 192.168.80.220   <-- nameserver
# rpower cn14 state         <-- cn14 is a (compute) node
# rinv -V cn14 firm -all
# tabdump site
# tabdump networks
# tabdump mpa
# tabdump mp
# tabdump passwd
# tabdump postscripts
# tabdump prescripts
# tabdump ppc
# rpower cn13 state         <-- cn13 is a (compute) node

# nodels
# nodestat

# ipmitool-xcat

# rspconfig

# rbootseq

# rpower
# rvitals 
# rinv

# xdsh 
# psh

# tabdump ipmi
# tabdump hosts
# tabdump mac
# tabdump nodehm
# tabdump nodelist
# tabdump noderes
# tabdump nodetype
# tabdump linuximage
# tabdump chain
# tabdump discoverydata
# tabdump osdistro
# tabdump osimage
# tabdump policy

mkdef, chtab, lsdef

nodech 
nodeadd
nodegrpch
```

```
# lsslp
```

List nodes defined in database but can't be discovered:

```
# lsslp -I
```

`-I`    Give the warning message for the nodes in database which have no
        SLP responses.  Note that this flag can only be used after the
        database migration finished successfully.

```
# lsslp -z
# lsslp -x
# lsslp -w       <--  Writes output to xCAT database
# rscan cn13
# rscan -z cn13
# rscan -x cn13
# rscan -x cn13  <-- Writes output to xCAT database
# hwclock --show
# lsxcatd -a
# makehosts
# makedns
# makedhcp -n
# dumpxCATdb -a -p /tmp/xCAT_Backup
# restorexCATdb -p /tmp/xCAT_Backup
```


### The Fundamentals of Building an HPC Cluster

Adapted from [The Fundamentals of Building an HPC Cluster](https://www.admin-magazine.com/HPC/Articles/Building-an-HPC-Cluster) (retrieved on Mar 20, 2022):    

Architecture   
The cluster is on a **private Ethernet network**. 
The address space is **unroutable** so the compute nodes are "hidden" from 
a routable network, allowing you to separate your cluster logically from 
a public network.

To log in to the cluster from a public network you need to add a second 
network interface controller (NIC) to the managment node (master node). 
This NIC has a public IP address that allows you to log in to the cluster. 
Only the master node should have the public IP address because there is 
no reason for compute nodes to have two addresses. (You want them to 
be private.) 

Another key feature of a basic cluster architecture is a shared directory 
across the nodes.  Strictly speaking this isn't required but without it 
some MPI (message-passing interface) applications would not run. 
Therefore, it is a good idea simply to use a shared filesystem in 
the cluster.  **NFS** is the easiest to use because both server and 
client are in the kernel, and the distribution should have the tools 
for configuring and monitoring NFS.

Software Layers  
The first layer is the basic software you need and really nothing extra. 
The second layer adds some administrative tools to make it easier to 
operate the cluster, as well as tools to reduce problems when running 
parallel applications.  The third layer adds more sophisticated cluster 
tools and adds the concept of monitoring, so you can understand 
what's happening.

Layer 1: Software Configuration   
The first layer of software only contains the minimum software to run 
parallel applications.  Obviously, the first thing you need is an OS. 
Typical installation options are usually good enough. 
They install most everything you need.

The next thing you need is a set of MPI libraries such as 
[Open MPI](https://www.open-mpi.org/) or [MPICH](https://www.mpich.org/). 
These are the libraries you will use for creating parallel applications 
and running them on your cluster.  You can find details on how to build 
and install them on their respective websites.
**Note:**  This cluster configuration uses PBS (Portable Batch System) 
scheduling software in its [TORQUE (Terascale Open-source Resource and QUEue manager)](https://web.archive.org/web/20090123185628/http://clusterresources.com/downloads/torque/torque-2.3.6.tar.gz) variant, **without** interfacing with Message Passing MPI (Message Passing Interface) libraries -- As per 
[TORQUE Administrator Guide](https://docs.adaptivecomputing.com/torque/3-0-5/index.php), section 7.0 Interfacing with Message Passing and [7.1 MPI (Message Passing Interface) Support](https://docs.adaptivecomputing.com/torque/3-0-5/7.1mpi.php) "A message passing library is used by parallel jobs to 
**augment** (*emphasis mine*) communication between the tasks distributed across the cluster.  TORQUE can run with any message passing library and provides limited integration with some MPI libraries."    

The next, and actually last, piece of software you need is SSH. 
More specifically, you need to be able to SSH to and from each node 
without a password, allowing you to run the MPI applications easily. 
Make sure, however, that you set up SSH after you have NFS working 
across the cluster and each node has mounted the exported directory.

Layer 2: Architecture and Tools   
The next layer of software adds tools to help reduce cluster problems and 
make it easier to administer.  Using the basic software mentioned in the 
previous section, you can run parallel applications, but you might run 
into difficulties as you scale your system, including:   
> Running commands on each node (parallel shell)   
> Configuring identical nodes (package skew)   
> Keeping the same time on each node (NTP)   
> Running more than one job (job scheduler/resource manager)   

The last issue to address is the job scheduler (also called a resource 
manager).  This is a key element of HPC and can be used even for small 
clusters.  Roughly speaking, a job scheduler will run jobs (applications) 
on your behalf when the resources are available on the cluster so you 
don't have to sit around and wait for the cluster to be free before you 
run applications.  Rather, you can write a few lines of script and submit 
it to the job scheduler.  When the resources are available, it will run 
your job on your behalf.   

In the script, you specify the resources you need, such as the number of 
nodes or number of cores, and you give the job scheduler the command that 
runs your application, such as:  `mpirun -np 4 <executable>`   REPLACE w/TORQUE

Among the resource managers available, many are open source. 
Examples of resource managers include:

* [Torque](https://adaptivecomputing.com/cherry-services/torque-resource-manager/)
* [Slurm](https://slurm.schedmd.com/)
* [SGE](https://sourceforge.net/projects/gridengine/) – Son of Grid Engine
* [OGE](http://gridscheduler.sourceforge.net/) – Open Grid Engine

With these issues addressed, you now have a pretty reasonable cluster with some administrative tools. Although it’s not perfect, it’s most definitely workable. 

Layer 3: Deep Administration   
The third level of tools gets you deeper into HPC administration and begins 
to gather more information about the cluster so you can find problems 
before they happen.  The tools I will discuss briefly are:
* Cluster management tools
* Monitoring tools (how are the nodes doing)
* Environment Modules
* Multiple networks

A cluster management tool is really a toolkit to automate the configuration, 
launching, and management of compute nodes from the master node. 
In some cases, the toolkit will even install the master node for you. 
A number of open source cluster management tools are available, including:
* [xCAT](http://xcat.org/), also: [https://github.com/xcat2](https://github.com/xcat2), [https://sourceforge.net/p/xcat/wiki/Main_Page/](https://sourceforge.net/p/xcat/wiki/Main_Page/)
* [Warewulf](https://warewulf.lbl.gov/), also [https://github.com/warewulf/warewulf3](https://github.com/warewulf/warewulf3)
* [OSCAR](https://oscar-cluster.github.io/oscar/) - Open Source Cluster Application Resource, also [OSCAR on GitHub](https://github.com/oscar-cluster/oscar) 
* [oneSIS](http://onesis.org/)

The tools vary in their approach but they typically allow you to create 
compute nodes that are part of the cluster.  This can be done via images, 
in which a complete image is pushed to the compute node, or via packages, 
in which specific packages are installed on the compute nodes.

Many of the cluster management tools also include tools for monitoring 
the cluster.  Several monitoring tools are appropriate for HPC clusters 
but a universal tool is Ganglia.  Some of the cluster tools come 
pre-configured with Ganglia, and some don't, requiring 
an [installation](http://www.admin-magazine.com/HPC/Articles/Monitoring-HPC-Systems).
By default Ganglia comes with some pre-defined metrics but the tool is 
very flexible and allows you to write simple code to attain specific 
metrics from your nodes.

----

**[TODO]**  Review all footnotes, including the order and whether some
            footnotes are missing

### Footnotes

[1]  More specifically, when you press **Ctrl D**, the `at(1)` 
displays `<EOT>`, which stands for End Of Transmission:


```
$ man ascii
[...]
       The following table contains the 128 ASCII characters.

       C program '\X' escapes are noted.

       Oct   Dec   Hex   Char                        Oct   Dec   Hex   Char
       ────────────────────────────────────────────────────────────────────────
       000   0     00    NUL '\0' (null character)   100   64    40    @
       001   1     01    SOH (start of heading)      101   65    41    A
       002   2     02    STX (start of text)         102   66    42    B
       003   3     03    ETX (end of text)           103   67    43    C
       004   4     04    EOT (end of transmission)   104   68    44    D
[...]
```

[2] The loopback interface is a virtual interface that is always up and 
available after it has been configured.

Per Solaris(TM) Operating Environment Boot Camp by David Rhodes, 
Dominic Butler - Pearson Publishing -  September 2002:   
> All systems have a "loopback" interface, regardless of whether they are 
> connected to the network or not.  This is not a true network interface, 
> but acts as one to allow some network-aware programs (such as RPC) to be
> able to connect to both the remote and local host in the same way.
> 
> You don't need to be concerned with configuring it, as this is performed 
> by the operating system, but we do need to make certain that the local 
> host address remains in the host file.

[3] Per Networking Bible by
Barrie Sosinsky - John Wiley & Sons, Inc. - September 2009: 
> One important example of a logical network interface (also called 
> a virtual interface) is the loopback adapter.  The loopback adapter 
> is a software routine that emulates an internal NIC card that can accept
> system requests and reply to those requests.  The loopback adapter is 
> used to test whether network functions are operating correctly.
> 
> For IP version 4, the loopback adapter is found at `127.0.0.1`.


[4] SOL (Serial over LAN)   
[BladeCenter SOL (Serial over LAN) Setup Guide - IBM Corporation, Twelfth Edition (November 2009)](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.advmgtmod.doc/kp1bd_pdf.pdf) (Retrieved on Mar 22, 2022):    

> Chapter 1. Introduction   
>   
> Serial over LAN (SOL) provides a means to manage servers remotely by
> using a command-line interface (CLI) over a Telnet or Secure Shell (SSH)
> connection.  SOL is required to manage servers that do not have
> keyboard/video/mouse (KVM) support [...]    
>  
> [...]    
> 
> SOL (Serial Over LAN) provides console redirection for both BIOS and the
> blade server operating system.  The SOL feature redirects server
> serial-connection data over a LAN without the need for special cabling.
> The SOL connection enables blade servers to be managed from any remote
> location with network access. 


[5] IBM Advanced Settings Utility (ASU)    
[IBM Advanced Settings Utility (ASU)](https://www.ibm.com/support/pages/ibm-advanced-settings-utility-asu)
(Retrieved on Mar 20, 2022) 

and 

[IBM Advanced Settings Utility (ASU) Version 3.60 User's Guide](https://toolscenter.lenovofiles.com/help/topic/asu/asu_guide.pdf)
(Retrieved on Mar 20, 2022) 

> You can use the IBM Advanced Settings Utility (**ASU**) to modify
> firmware settings from the command line on multiple operating-system
> platforms.  You can perform the following tasks by using the utility:
> * Modify selected basic input/output system **(BIOS) CMOS** settings
    without the need to restart the system to access F1 settings.   
> * Modify selected **BMC** (Baseboard Management Controller) setup settings.   
> [...]  
> * Modify selected settings in **Integrated Management Module (IMM)**-based
>   servers for the **IMM** firmware and IBM System x Server Firmware. 
>   The IMM replaces the Remote Supervisor Adapter and **Baseboard Management
>   Controller (BMC)** functions on IMM-based servers.  IBM System x Server
>   Firmware is the IBM implementation of **Unified Extensible Firmware
>   Interface (UEFI)**.  The *UEFI* replaces the basic input/output system
>   *(BIOS)* and defines a standard interface between the operating system,
>   platform firmware, and external devices.    
>   [...]    


[6] Configure **Boot Order** in **BIOS** via the **ASU** Tool  

```
# /opt/ibm/toolscenter/asu/asu64 save BIOS.TXT --group all
```

```
# wc -l BIOS.TXT
88 BIOS.TXT
```

```
# grep -i boot BIOS.TXT
CMOS_AlternateBootDevice4=Hard Disk 0
CMOS_AlternateBootDevice3=CD ROM
CMOS_AlternateBootDevice2=Diskette Drive 0
CMOS_AlternateBootDevice1=Network
CMOS_PostBootFailRequired=Enabled
CMOS_PCIBootPriority=Planar SAS
CMOS_RemoteConsoleBootEnable=Enabled
BMC_PrimaryBootDevice1=HDD0
BMC_PrimaryBootDevice2=CD-ROM
```

```
# /opt/ibm/toolscenter/asu/asu64 showvalues --setlist \
BMC_PrimaryBootDevice1 \
BMC_PrimaryBootDevice2 \
BMC_PrimaryBootDevice3 \
BMC_PrimaryBootDevice4
```

Output:

```
BMC_PrimaryBootDevice1=Floppy Drive=iSCSI=iSCSI Critical=Network=HDD0=HDD1=HDD2=HDD3=CD-ROM
BMC_PrimaryBootDevice2=Floppy Drive=iSCSI=iSCSI Critical=Network=HDD0=HDD1=HDD2=HDD3=CD-ROM
BMC_PrimaryBootDevice3=Floppy Drive=iSCSI=iSCSI Critical=Network=HDD0=HDD1=HDD2=HDD3=CD-ROM
BMC_PrimaryBootDevice4=Floppy Drive=iSCSI=iSCSI Critical=Network=HDD0=HDD1=HDD2=HDD3=CD-ROM
```

```
# /opt/ibm/toolscenter/asu/asu64 set BMC_PrimaryBootDevice1 Network
# /opt/ibm/toolscenter/asu/asu64 set BMC_PrimaryBootDevice2 CD-ROM
# /opt/ibm/toolscenter/asu/asu64 set BMC_PrimaryBootDevice3 HDD0 
```

```
# /opt/ibm/toolscenter/asu/asu64 save BIOS_NEW.TXT --group all 
```

```
# wc -l BIOS_NEW.TXT
89 BIOS_NEW.TXT
```

```
# grep -i boot BIOS_NEW.TXT
CMOS_AlternateBootDevice4=Hard Disk 0
CMOS_AlternateBootDevice3=CD ROM
CMOS_AlternateBootDevice2=Diskette Drive 0
CMOS_AlternateBootDevice1=Network
CMOS_PostBootFailRequired=Enabled
CMOS_PCIBootPriority=Planar SAS
CMOS_RemoteConsoleBootEnable=Enabled
BMC_PrimaryBootDevice1=Network
BMC_PrimaryBootDevice2=CD-ROM
BMC_PrimaryBootDevice3=HDD0
```

[7] From the manual page for `hosts(5)` on RHEL 5.x:
> hosts - The static table lookup for host names    
> This file is a simple text file that associates IP addresses with
> hostnames, one line per IP address. For each host a single line should
> be present with the following information:
>    `IP_address canonical_hostname [aliases...]`    
> 
> Fields of the entry are separated by any number of blanks and/or tab
> characters.  Text from a "#" character until the end of the line is a
> comment, and is ignored.  Host names may contain only alphanumeric
> characters, minus signs ("-"), and periods (".").  They must begin with
> an alphabetic character and end with an alphanumeric character.
> Optional aliases provide for name changes, alternate spellings, shorter
> hostnames, or generic hostnames (for example, `localhost`).


[8] From the manual page for `pbsnodes(8)`:

```
DESCRIPTION

The pbsnodes command is used to mark nodes down, free or offline. 

It can also be used to list nodes and their state.

Node information is obtained by sending a request to the PBS job server.
Sets of nodes can be operated on at once by specifying a node property 
_prefixed_ by a _colon_.

Nodes do not exist in a single state, but actually have a set of states.

For example, a node can be simultaneously "busy" and "offline".

The "free" state is the absence of all other states and 
so is never combined with other states.
```

[9] From the manual page for `node(7)`:

```
The current status of this node.  This attribute will be set by
xCAT software.  Valid values: defined, booting, netbooting,
booted, discovering, configuring, installing, alive, standingby,
powering-off, unreachable. If blank, defined is assumed.

The possible status change sequences are:

For installation:
defined->[discovering]->[configuring]->[standingby]->installing->booting->[postbooting]->booted->[alive],

For diskless deployment:
defined->[discovering]->[configuring]->[standingby]->netbooting->[postbooting]->booted->[alive],

For booting:
[alive/unreachable]->booting->[postbooting]->booted->[alive],

For powering off: [alive]->powering-off->[unreachable],

For monitoring: alive->unreachable. 

Discovering and configuring are for x Series discovery process.
Alive and unreachable are set only when there is a monitoring
plug-in start monitor the node status for xCAT.

Note that the status values will not reflect the real node
status if you change the state of the node from outside
of xCAT (i.e. power off the node using HMC GUI).
```

However, when I used
`-m nodelist.status==booting` or `-m nodelist.status==installing` 
with `rpower boot`, the node would sometimes got stuck in powered off state, 
and the `rcons <nodename>` would display:

```
         DESTINATION BLADE IS IN POWER OFF STATE
```

As the output of the `xcatprobe osdeploy -n <nodename>` command in the first terminal; in this case, `xcatprobe osdeploy -n abacus109` (after `rpower abacus109 boot` in the second terminal) indicated

```
... Node status is changed to powering-on
```

search for *powering-on* returned:

```
# grep -r -n 'powering-on' /opt/xcat/
/opt/xcat/lib/perl/xCAT/GlobalDef.pm:52:$::STATUS_POWERING_ON  = "powering-on";
/opt/xcat/lib/perl/xCAT_plugin/openbmc.pm:49:$::POWER_STATE_POWERING_ON  = "powering-on";
/opt/xcat/probe/lib/perl/xCAT/GlobalDef.pm:52:$::STATUS_POWERING_ON  = "powering-on";
/opt/xcat/probe/subcmds/osdeploy:1209:                } elsif ($status eq "powering-on") {
```

For example, looking into `GlobalDef.pm` revealed even more valid values 
for `status` (`nodelist.status`).  One of them is `powering-on`:

```
# sed -n 43,63p /opt/xcat/lib/perl/xCAT/GlobalDef.pm
# valid values for nodelist.status columns or other status
$::STATUS_ACTIVE       = "alive";
$::STATUS_INACTIVE     = "unreachable";
$::STATUS_INSTALLING   = "installing";
$::STATUS_INSTALLED    = "installed";
$::STATUS_BOOTING      = "booting";
$::STATUS_POSTBOOTING  = "postbooting";
$::STATUS_NETBOOTING   = "netbooting";
$::STATUS_BOOTED       = "booted";
$::STATUS_POWERING_ON  = "powering-on";
$::STATUS_POWERING_OFF = "powering-off";
$::STATUS_DISCOVERING  = "discovering";
$::STATUS_DISCOVERED   = "discovered";
$::STATUS_CONFIGURING  = "configuring";
$::STATUS_CONFIGURED   = "configured";
$::STATUS_STANDING_BY  = "standingby";
$::STATUS_SHELL        = "shell";
$::STATUS_DEFINED      = "defined";
$::STATUS_UNKNOWN      = "unknown";
$::STATUS_FAILED       = "failed";
$::STATUS_BMCREADY     = "bmcready";
```

[10] In this example, the blade server is **IBM HS21**, whose BIOS needs 
to be setup with the following in order for SOL (Serial Over LAN) to work:

* Serial Port A: Auto-configure
* Serial Port B: Auto-configure
* Remote Console Active: Enabled
* Remote Console COM Port: COM 2
* Remote Console Active After Boot: Enabled
* Remote Console Flow Control: Hardware


[11] The `nomodeset` fix for the `no | invalid EDID` messages in the console:

For example, if the EDID issue is happening on a node named `abacus211`,
to fix it run the the following commands on the xCAT MN (Management Node), 
which in the examples on this page has an IP address `192.168.80.220`
(hostname `xcatmn.mydomain.com`).  (**Note:** The OS on the compute 
node `abacus214` is CentOS 7 so the grub version on it is grub2.) 

```
# scp root@abacus211:/etc/default/grub /tmp/grubabacus211.ORIG
```

```
# cp -i /tmp/grubabacus211.ORIG /tmp/grubabacus211.NEW
```

```
# grep -n CMDLINE /tmp/grubabacus211.NEW
7:GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=xcatvg/root console=ttyS1,19200"
```

```
# grep -n 'ttyS1,19200' /tmp/grubabacus211.NEW
7:GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=xcatvg/root console=ttyS1,19200"
```

```
# sed -n '/ttyS1,19200/p' /tmp/grubabacus211.NEW
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=xcatvg/root console=ttyS1,19200"
```

```
# sed -n '/ttyS1,19200/=' /tmp/grubabacus211.NEW
7
```

```
# sed -i.bkp 's/ttyS1,19200/ttyS1,19200 nomodeset/' /tmp/grubabacus211.NEW
```

```
# diff \
--unified=0 \
/tmp/grubabacus211.NEW.bkp \
/tmp/grubabacus211.NEW
--- /tmp/grubabacus211.NEW.bkp 2022-03-20 20:59:04.966346023 -0700
+++ /tmp/grubabacus211.NEW     2022-03-20 21:00:25.710970506 -0700
@@ -7 +7 @@
-GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=xcatvg/root console=ttyS1,19200"
+GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=xcatvg/root console=ttyS1,19200 nomodeset"
```

```
# xdsh abacus211 cp /etc/default/grub /tmp/grub.ORIG
```

```
# scp /tmp/grubabacus211.NEW root@abacus211:/etc/default/grub
```

```
# xdsh abacus211 cat /etc/default/grub
abacus211: GRUB_TIMEOUT=5
abacus211: GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
abacus211: GRUB_DEFAULT=saved
abacus211: GRUB_DISABLE_SUBMENU=true
abacus211: GRUB_TERMINAL="serial console"
abacus211: GRUB_SERIAL_COMMAND="serial --unit=1 --speed=19200"
abacus211: GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=xcatvg/root console=ttyS1,19200 nomodeset"
abacus211: GRUB_DISABLE_RECOVERY="true"
```

```
# xdsh abacus211 grub2-mkconfig -o /boot/grub2/grub.cfg
```

```
# xdsh abacus211 reboot
```

```
# rcons abacus211
```

---

**[TODO]**   Do I need to mention this method (order)?:

[Re: [xcat-user] Problem with rsetboot: unable to identify plugin](https://www.mail-archive.com/xcat-user@lists.sourceforge.net/msg05288.html):    

```
You should do the OS deployment by following three steps:
1. nodeset <node> osimage=<image name>
2. rbootseq <node> net,hd
3. rpower <node> boot
```

---

**[TODO]**  Probably add something about **Gaussian** (and **GaussView**).   

---

**[TODO]**  Should I go into IPMI via ASU (NOT tested yet)?:     

[Communicating via Command Mode with IBM HS22 IMM via AMM](https://serverfault.com/questions/60358/communicating-via-command-mode-with-ibm-hs22-imm-via-amm)  

---

**SUMMARY**


**[TODO]**  Should I sanitize this section, e.g.: MAC addresses? 


*Optional:*  Pre-Review:

```
# tabdump site
# lsdef -t site -l
# lsdef -t group -l
# lsdef -t osimage -l
# lsdef -t node -l
# rpower all stat
# nodestat all
# nodels all groups

# rinv all all
# rvitals all all

# monls -a
# lsvm all
```


```
# nodels
[...]               <-- The rest of the nodes are MM nodes (not CNs)
abacus102
abacus103
abacus105
xbcmm1n
```

```
# nodestat all
[...]               <-- The rest of the nodes are MM nodes (not CNs)
abacus102: noping
abacus103: pbs,sshd
abacus105: noping
xbcmm1n: sshd
```


**[TODO]**  Add `ping` when it works. 


```
# ping -c2 192.168.80.6
PING 192.168.80.6 (192.168.80.6) 56(84) bytes of data.
From 192.168.80.220 icmp_seq=1 Destination Host Unreachable
From 192.168.80.220 icmp_seq=2 Destination Host Unreachable

--- 192.168.80.6 ping statistics ---
2 packets transmitted, 0 received, +2 errors, 100% packet loss, time 999ms
pipe 2
```


**[TODO]**  TEST JOBS   - Clean and Complete


Run two test jobs, one from the CLI and the other one from WebMO.


  TEST JOB 1

```
# cat /home/webmo/qsub_test_abacus104
#
#
#PBS -l nodes=1:abacus104
#
sleep 120
hostname
date
```


```
# /global/software/torque/x86_64/bin/qsub /home/webmo/qsub_test_abacus104
```

**[NOTE]**    
If you receive a "Not enough nodes available", as shown here:

```
# /home/webmo/bin/qsort
JobID  Jobname              User  Status  Ncpus  C_Time  CPU%  hosts
==============================================================================
[...]
290585 WebMO_285222         webmo    R      1                  abacus-203
290591 qsub_test_abacus104  root     Q                         Not enough
                                                               nodes available
==============================================================================
```

check the node's state by using the `pbsnodes(8B)` command:


```
# /global/software/torque/x86_64/bin/pbsnodes -l all abacus104
abacus104            offline
```

If the node is in OFFLINE state, the fix is to clear OFFLINE from the node:  

```
# /global/software/torque/x86_64/bin/pbsnodes -c abacus104
```


If the node is in DOWN state, try fixing it by restarting `pbs_mom` service on the node:   


```
# xdsh abacus104 systemctl restart pbs_mom.service
```

**NOTE:**  If you are still not getting the `free` status for the compute 
           node, most likely you need to retart the `pbs_server` service 
	   on the head node; that is, on the head node:
           `systemctl restart pbs_server.service`.   


**Note:**   If no state is specified with the `-l` option in the `pbsnodes`
            command, it only lists nodes in the DOWN, OFFLINE, or UNKNOWN
	    states.  Specifying a state string acts as an output
            filter.   Valid  state  strings  are  "active",   "all",
            "busy", "down", "free", "offline", "unknown", and "up".


Most likely you'll need to delete the job 

```
# qdel 290591 
```

and re-submit it:

```
# /global/software/torque/x86_64/bin/qsub /home/webmo/qsub_test_abacus104
290592.mgmt
```



**[TODO]**:  Add the useful (currently, as of Jul 4, 2022, to be run from
             `abacus.mydomain.com`):   


```
# /opt/torque/sbin/momctl -f /etc/hosts -d 3

# /opt/torque/sbin/momctl -h abacus104 -d 3
```


Back on the MN (management node), `xcatmn.mydomain.com`:


```
# xdsh abacus104 find /opt/torque/ -name '*290592*'
abacus104: /opt/torque/var/spool/aux/290592.mgmt
abacus104: /opt/torque/var/spool/mom_priv/jobs/290592.mgmt.SC
abacus104: /opt/torque/var/spool/mom_priv/jobs/290592.mgmt.TK
abacus104: /opt/torque/var/spool/mom_priv/jobs/290592.mgmt.JB
abacus104: /opt/torque/var/spool/spool/290592.mgmt.OU
abacus104: /opt/torque/var/spool/spool/290592.mgmt.ER
```


```
# xdsh abacus104 cat /opt/torque/var/spool/aux/290592.mgmt
abacus104: abacus104
```

```
# xdsh abacus104 cat /opt/torque/var/spool/mom_priv/jobs/290592.mgmt.SC
abacus104: #
abacus104: #
abacus104: #PBS -l nodes=1:abacus104
abacus104: #
abacus104: sleep 120
abacus104: hostname
abacus104: date
```

Go back to the PBS server machine, `abacus.mydomain.com`.  


```
# /home/webmo/bin/qsort
JobID  Jobname              User  Status  Ncpus  C_Time  CPU%  hosts
=========================================================================
[...]
290585 WebMO_285222         webmo    R      1                  abacus-203
290592 qsub_test_abacus104  root     R      1    00:00    0%   abacus-104
=========================================================================
```


After 120 seconds:

```
# /home/webmo/bin/qsort
JobID  Jobname              User  Status  Ncpus  C_Time  CPU%  hosts
=========================================================================
[...]
290585 WebMO_285222         webmo    R      1                  abacus-203
=========================================================================
```


  TEST JOB 2 

Log into WebMO (via Canvas: All Courses > CHEM WEBMO > Student View > Abacus).

In WebMO Job Manager: New Job > Create New Job  

Create a simple job; for example, with seven connected C atoms.  

Specify a job execution node `abacus104`: select Advanced tab:  
`Nodes : PPN : Node Type`   `1: 1: abacus104`    

Submit the job.


Go back to the PBS server machine, `abacus.mydomain.com`.  

```
# /home/webmo/bin/qsort
JobID  Jobname              User  Status  Ncpus  C_Time  CPU%  hosts
=========================================================================
[...]
290585 WebMO_285222         webmo    R      1                  abacus-203
290593 WebMO_285228         webmo    R      1    00:00    0%   abacus-104
=========================================================================
```

On this cluster, this job completes in 5.3 seconds.

After six seconds:

```
# /home/webmo/bin/qsort
JobID  Jobname              User  Status  Ncpus  C_Time  CPU%  hosts
=========================================================================
[...]
290585 WebMO_285222         webmo    R      1                  abacus-203
=========================================================================
```

---

**[TODO]**

```
# man xcatprobe 
No manual entry for xcatprobe

# find /opt/xcat/ -iname '*xcatprobe*'
/opt/xcat/bin/xcatprobe
```

```
# xcatprobe -h
Usage:
xcatprobe -h
xcatprobe -l
xcatprobe [-V] <subcommand>  <attrbute_to_subcommand>

Options:
    -h : get usage information of xcatprobe
    -l : list all valid sub commands
    -V : print verbose information of xcatprobe
    -w : show each line completely. By default long lines are truncated.
```

```
# xcatprobe -l
Supported sub commands are:
detect_dhcpd     detect_dhcpd can be used to detect the dhcp server in a network
                 for a specific mac address. Before using this command, install
                 'tcpdump' command. The operating system supported are RedHat,
                 SLES and Ubuntu.
osdeploy         Probe operating system provision process. Supports two modes -
                 'Realtime monitor' and 'Replay history'.
nodecheck        Use this command to check node defintions in xCAT DB.
xcatmn           After xcat installation, use this command to check if xcat has
                 been installed correctly and is ready for use. Before using
                 this command, install 'tftp', 'nslookup' and 'wget' commands.
                 Supported platforms are RedHat, SLES and Ubuntu.
osimagecheck     Use this command to check osimage defintions in xCAT DB.
discovery        Probe for discovery process, including pre-check for required
                 configuration and realtime monitor of discovery process.
image            Use this command to check if specified diskless nodes have the
                 same images installed or if nodes are installed with the same
                 image as defined on the management node.
clusterstatus    Use this command to get node summary in the cluster.
switch_macmap    To retrieve MAC address mapping for the specified switch, or
                 all the switches defined in 'switches' table in xCAT db.
                 Currently, this command does not support hierarchy.
code_template    This isn't a probe tool, this is just a template for sub
                 command coding. Use it to develop sub command which need to
                 cover hierarchical cluster
```

```
# command -v tcpdump; type -a tcpdump; whereis tcpdump; which tcpdump
/usr/sbin/tcpdump
tcpdump is /usr/sbin/tcpdump
tcpdump: /usr/sbin/tcpdump /usr/share/man/man8/tcpdump.8.gz
/usr/sbin/tcpdump
```

```
# command -v tftp; type -a tftp; whereis tftp; which tftp 
/usr/bin/tftp
tftp is /usr/bin/tftp
tftp: /usr/bin/tftp /usr/share/man/man1/tftp.1.gz
/usr/bin/tftp
```

```
# command -v nslookup; type -a nslookup; whereis nslookup; which nslookup
/usr/bin/nslookup
nslookup is /usr/bin/nslookup
nslookup: /usr/bin/nslookup /usr/share/man/man1/nslookup.1.gz
/usr/bin/nslookup
```

```
# command -v wget; type -a wget; whereis wget; which wget 
/usr/bin/wget
wget is /usr/bin/wget
wget: /usr/bin/wget /usr/share/man/man1/wget.1.gz
/usr/bin/wget
```

```
# xcatprobe detect_dhcpd -h
[...]

# xcatprobe osdeploy -h
[...]

# xcatprobe nodecheck -h
[...]

# xcatprobe xcatmn -h
[...]

# xcatprobe osimagecheck -h
[...]

# xcatprobe discovery -h
[...]

# xcatprobe image -h
[...]

# xcatprobe clusterstatus -h
[...]

# xcatprobe switch_macmap -h
[...]

# xcatprobe code_template -h
[...]
```

---

**REFERENCES:**    

(Most of references retrieved on Mar 20, 2022.)    

* [xCAT Documentation: Docs > Admin Guide > Manage Clusters > x86_64](https://xcat-docs.readthedocs.io/en/latest/guides/admin-guides/manage_clusters/x86_64/index.html):     
> This section is not available at this time.  
> Refer to xCAT Documentation on SourceForge for information on System X servers":   
> [https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/)    

* [IBM BladeCenter HOWTO - xCAT Wiki on Sourceforge](https://sourceforge.net/p/xcat/wiki/IBM_Blade_Center_HowTo/)

* [Intelligent Clusters - Installation and Service Guide](https://download.lenovo.com/servers/mig/systems/support/system_x_pdf/installation_and_service_guide_15b_00wa645.pdf)  <-- Has information about hardware configuration, cabling and similar.

* [Connection failure: SSL connect attempt failed with unknown error error:14077410:SSL routines:SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure at /opt/xcat/lib/perl/xCAT/Client.pm line 281. #5797](https://github.com/xcat2/xcat-core/issues/5797)

* [IBM Blade Center HOWTO (incomplete)](https://sourceforge.net/p/xcat/wiki/IBM_Blade_Center_HowTo/)

* [XCAT Cluster with IBM BladeCenter](https://sourceforge.net/p/xcat/wiki/XCAT_Cluster_with_IBM_BladeCenter/)

* [XCAT BladeCenter Linux Cluster](https://sourceforge.net/p/xcat/wiki/XCAT_BladeCenter_Linux_Cluster/)

* [XCAT Dependency Packages (xcat-dep) - RPM Packages List (RHEL and SLES)](http://xcat.org/files/xcat/repos/yum/xcat-dep/)

* [A Brief Introduction to some commonly used xCAT tables - xCAT Tables Descriptions](https://sourceforge.net/p/xcat/wiki/Intro_to_xCAT_Tables/#xcat-tables-descriptions)

* [A Complete List of xCAT Tables and Their Descriptions (An overview of the xCAT database)](https://xcat-docs.readthedocs.io/en/latest/guides/admin-guides/references/man5/xcatdb.5.html)

* [xCAT Mini HOWTO (WIP)](http://sense.net/~egan/xcat/doc/xcat-mini-HOWTO.html)

* [xCAT HOWTO for Red Hat Linux](http://sense.net/~egan/xcat/doc/xcat-HOWTO.html)

* [xCAT susemgtnode-HOWTO for SuSE Linux](http://sense.net/~egan/xcat/doc/susemgtnode-HOWTO.html)

* [xCAT Stage1 HOWTO (WIP)](http://sense.net/~egan/xcat/doc/stage1-HOWTO.html)

* [xCAT Node Installation HOWTO (WIP)](http://sense.net/~egan/xcat/doc/nodeinstall-HOWTO.html)

* [The location of synclist file for updatenode and install process - xCAT Wiki on SourceForge](https://sourceforge.net/p/xcat/wiki/The_location_of_synclist_file_for_updatenode_and_install_process/)

* [IBM E server BladeCenter, Linux, and Open Source (IBM Redbooks)](https://www.redbooks.ibm.com/redbooks/pdfs/sg247034.pdf)

* [Installation and User's Guide - IBM BladeCenter HS21](https://www.ibm.com/support/pages/node/821662)

* [Advanced Settings Utility - Lenovo ToolCenter](https://toolscenter.lenovofiles.com/help/index.jsp?topic=%2Ftoolsctr%2Fasu_main.html)

* [IBM BladeCenter HS21 - Installation and User's Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.hs21.doc/hs21_install_ug.pdf)

* [IBM BladeCenter HS21 Documentation](https://bladecenter.lenovofiles.com/help/index.jsp?topic=%2Fcom.lenovo.bladecenter.hs21.doc%2Fbls_hs21_product_page.html&cp=0_6_2)

* [Troubleshooting the HS21 Blade Server - BladeCenter HS21 Problem Determination and Service Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.hs21.doc/hs21_pdguide.pdf)

* [IBM Management Module (MM) Documentation](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.mgtmod.doc/mgt_mod_product_page.html?cp=0_5_2)

* [IBM BladeCenter Management Module (MM) Installation Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.mgtmod.doc/d3sdems4.pdf)

* [IBM BladeCenter Management Module (MM) User's Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.mgtmod.doc/44R5370.pdf)

* [IBM BladeCenter Management Module (MM) Command-Line Interface (CLI) Reference Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.mgtmod.doc/44R5372.pdf)

* [BladeCenter SOL (Serial over LAN) Setup Guide - IBM Corporation, Twelfth Edition (November 2009)](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.advmgtmod.doc/kp1bd_pdf.pdf)

* [TORQUE (a.k.a. TORQUE Resource Manager)](https://en.wikipedia.org/wiki/TORQUE)

* [TORQUE Resource Manager - Adminstrator Guide 5.1.2 - November 2015 - Revised April 1, 2016](https://docs.adaptivecomputing.com/torque/5-1-2/torqueAdminGuide-5.1.2.pdf)

* [Torque Repository - GitHub](https://github.com/adaptivecomputing/torque)

* [OpenPBS Open Source Project](https://openpbs.org/)

* [OpenPBS Open Source - Source Code on GitHub - An HPC workload manager and job scheduler for desktops, clusters, and clouds](https://github.com/openpbs/openpbs)

* [PBS Professional released under an open source license - An Open Letter to the HPC Community - Bill Nitzberg, CTO, Altair - Mar 3, 2016](https://insidehpc.com/2016/05/an-open-letter-to-the-hpc-community/)
> We are joining the [OpenHPC project](http://openhpc.community/) with PBS Pro.

* [An Open Letter to the HPC Community - Archived in OpenPBS Wiki - Atlassian Confluence Wiki)](https://openpbs.atlassian.net/wiki/spaces/PBSPro/blog/2016/05/03/7274507/An+Open+Letter+to+the+HPC+Community)

* [PBS Professional 13.0 - Quick Start Guide - Archived from the original on Nov 14, 2015](https://web.archive.org/web/20151114032509/http://www.pbsworks.com/pdfs/PBSProQuickStartGuide13.0.pdf)

* [PBS Professional 13.0 Installation and Upgrade Guide - archived from the original on Apr 17 2016](https://web.archive.org/web/20160417152443/http://www.pbsworks.com/pdfs/PBSInstallGuide13.0.pdf)

* [PBS Professional 13.0 Reference Guide - archived from the original on Nov 20, 2015](https://web.archive.org/web/20151120150321/http://www.pbsworks.com/pdfs/PBSProRefGuide13.0.pdf)

* [OpenPBS - Contributors Portal aka Wiki - As of Sep 12, 2024 hosted in three Confluence Spaces: Developer Guide, OpenPBS, Project Documentation](https://pbspro.atlassian.net/wiki)

* [OpenPBS (Confluence Space)](https://openpbs.atlassian.net/wiki/spaces/PBSPro/overview)
> About PBS
> 
> PBS Professional software optimizes job scheduling and workload management in high-performance computing (HPC) environments – clusters, clouds, and supercomputers – improving system efficiency and people’s productivity. Built by HPC people for HPC people, PBS Pro™ is fast, scalable, secure, and resilient, and supports all modern infrastructure, middleware, and applications.

* [PBS Pro - Project Documentation](https://openpbs.atlassian.net/wiki/spaces/PD/overview) 

* [OpenHPC - Community building blocks for HPC systems](https://openhpc.community/)

* [Job scheduler - Batch queuing for HPC clusters (Job scheduler)](https://en.wikipedia.org/wiki/Job_scheduler)

* [Job queue](https://en.wikipedia.org/wiki/Job_queue)

* [Job queues (www.ibm.com - IBM Docs)](https://www.ibm.com/docs/en/i/7.1?topic=concepts-job-queues)

* [Converting traditional sysV init scripts to Red Hat Enterprise Linux 7 systemd unit files - RedHat Blog](https://www.redhat.com/en/blog/converting-traditional-sysv-init-scripts-red-hat-enterprise-linux-7-systemd-unit-files)

* [SysVinit - archlinux Wiki](https://wiki.archlinux.org/title/SysVinit)

* [WebMO](https://www.webmo.net/)

* [PolicyKit failing to start with error: polkit.service: main process exited, code=exited, status=1/FAILURE](https://access.redhat.com/solutions/1543343)

* [How to reset a broken TTY? - Super User](https://superuser.com/questions/640338/how-to-reset-a-broken-tty)

* [How to build a diskless Linux cluster?](https://web.mst.edu/~vojtat/pegasus/administration.htm)

* [Cluster Layout - Pegasus IV Computing Cluster](http://thomasvojta.com/pegasus/overview/layout.htm)

* [Serial jobs - Pegasus IV Computing Cluster](http://thomasvojta.com/pegasus/usage/serial_jobs.htm)
> Submitting a job
>
> You are not supposed to run your code on the cluster server, and you are not supposed to log into the compute nodes directly. So, how to use the cluster?
> 
> The answer is the resource manager (a.k.a. batch system) Torque. In short, to obtain computational resources (such as a certain number of CPUs), you send your request to Torque. Torque puts your request into a waiting queue, and as soon the requested resources are available somewhere in the Pegasus IV cluster, your computation starts.
> 
> There are two types of Torque jobs, interactive jobs and batch jobs. To submit a request for an interactive job, simply type:
> 
> `qsub -I`
> 
> and as soon as a machine is available you'll get interactive access to it. For you as a user, it will look as if you are directly logged into a cluster node.

* [Parallel Jobs - Pegasus IV Computing Cluster](http://thomasvojta.com/pegasus/
usage/parallel_jobs.htm)
> Submitting a parallel job
> 
> Similar to serial jobs, parallel jobs can be started interactively or submitte
d to the batch queue. To start a parallel job interactively, you can use `qsub -
I` but you need to specify how many processors you wish to use.

* [Computer cluster - Wikipedia](https://en.wikipedia.org/wiki/Computer_cluster)

* [Building a Linux cluster using PXE, DHCP, TFTP and NFS](https://kitson-consulting.co.uk/blog/building-linux-cluster-using-pxe-dhcp-tftp-and-nfs)
> By Pete Donnell, 2016-07-02
> 
> Building a small Linux cluster is a lot simpler than I thought it would be. That said, there are a number of snags and pitfalls along the way, and it's hard to find a comprehensive and up to date set of instructions online. There are also different approaches, either doing everything manually or using a system such as LTSP. This post describes my experiences setting up a cluster manually.
> 
> Warning: This is a long post! The steps are all relatively simple but there are a lot of them.

---

