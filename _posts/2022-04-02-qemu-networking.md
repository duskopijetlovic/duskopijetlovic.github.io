---
layout: post
title: "QEMU Networking"
date: 2022-04-02 08:11:22 -0700 
categories: howto virtualization rs232serial cli terminal shell console sysadmin server hardware networking
---

---
Host OS: RHEL 8.5 - Shell: csh    
Guest OS: CentOS Linux 7.9 - Shell: bash   

---

*Assumptions:*

The host server was already configured for virtualization.  It had the 
following packages installed on it: 

```
ipxe-roms-qemu, libvirt-daemon-driver-qemu, qemu-guest-agent, qemu-img, 
qemu-kvm, qemu-kvm-block-curl, qemu-kvm-block-gluster, qemu-kvm-block-iscsi, 
qemu-kvm-block-rbd, qemu-kvm-block-ssh, qemu-kvm-common, qemu-kvm-core,
libvirt, virt-install, virt-manager, libguestfs-tools, libguestfs-gfs2, 
libguestfs-rescue, ibguestfs-rsync libguestfs-xfs,
virt-dib, virt-v2v, virt-p2v-maker, virt-viewer, virt-who, virt-top, virtio-win

minicom 
```

### About Bridge Switch, Bridge Mode of QEMU, Bridged Networking, TUN Connection, TAP Mode (TAP Device), NAT Mode

A **bridge** is a **network switch** but implemented in software.    

From the [Arch Wiki](https://wiki.archlinux.org/index.php/Network_bridge) (Retrieved on Apr 2, 2022):  

> A **bridge** is a piece of software used to **unite** two or 
> more **network segments**.
> 
> A bridge behaves like a virtual network **switch**, working 
> transparently (other machines do not need to know about its 
> existence).  Any real devices (e.g. `eth0`) and virtual devices
> (e.g. `tap0`) can be connected to it.
>
> [...]     
> When the bridge is fully set up, it can be **assigned an IP address**.

Or as per [Bridge - The Linux Foundation Wiki](https://wiki.linuxfoundation.org/networking/bridge) (Retrieved on Apr 2, 2022):  
> [...] a bridge connects two or more physical Ethernets together to 
> form one **bigger (logical) Ethernet**.

When you install `libvirt`, a **virtual bridge** (aka **virtual network 
switch**), the `virbr0`, is automatically created.  When you later 
create virtual machines, they connect to the `virbr0` bridge.

By default, the `virbr0` uses **NAT** mode and gets assigned an 
IP address 192.168.122.1.  Also, it can provide DHCP service for 
other virtual interfaces that connect to it.

From the [Arch Wiki](https://wiki.archlinux.org/title/Network_bridge): 
a bridge is a network switch but implemented in software.  Any real 
devices (e.g. `eth0`) and virtual devices (e.g. `tap0`) can be connected 
to it.  


From [NAT Networking - QEMU Documentation](https://wiki.qemu.org/Documentation/Networking/NAT) (Retrieved on Apr 2, 2022):  
> NAT   
> Configuring Network Address Translation (NAT) is a useful way to network 
> virtual machines in a desktop environment (particularly, when using 
> wireless networking).  A NAT network will allow your guests to fully 
> access the network, allow networking between your host and guests, but 
> **prevent the guests** from being directly **visible** on the physical network. 


*References:*  

[What's the function of `virbr0` and `virbr0-nic`?](https://unix.stackexchange.com/questions/523245/whats-the-function-of-virbr0-and-virbr0-nic)   
(Retrieved on Apr 2, 2022)   

[[libvirt-users] virtual networking - virbr0-nic interface](https://listman.redhat.com/archives/libvirt-users/2012-September/msg00038.html)   
(Retrieved on Apr 2, 2022)   

[What is virtual bridge with -nic in the end of name](https://unix.stackexchange.com/questions/378264/what-is-virtual-bridge-with-nic-in-the-end-of-name/444863#444863)   
(Retrieved on Apr 2, 2022)   


```
$ nmcli
eno1: connected to eno1
[...]
eno2: connected to eno2
[...]
virbr0: connected (externally) to virbr0
        "virbr0"
        bridge, 52:54:00:11:22:33, sw, mtu 1500
        inet4 192.168.122.1/24
        route4 192.168.122.0/24
eno3: disconnected
[...]
eno4: disconnected
[...]
lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

virbr0-nic: unmanaged
        "virbr0-nic"
        tun, 52:54:00:11:22:33, sw, mtu 1500

DNS configuration:
        servers: 208.67.222.222, 208.67.220.220  <-- Will list your DNS servers
        interface: eno1
```


```
$ nmcli device show virbr0
GENERAL.DEVICE:               virbr0
GENERAL.TYPE:                 bridge
[...]
GENERAL.STATE:                100 (connected (externally))
GENERAL.CONNECTION:           virbr0
[...]
IP4.ADDRESS[1]:               192.168.122.1/24
IP4.GATEWAY:                  --
IP4.ROUTE[1]:                 dst = 192.168.122.0/24, nh = 0.0.0.0, mt = 0
IP6.GATEWAY:                  --
```

The network **interface** `virbr0-nic` (virtual network interface) is not 
a bridge.  It is a regular Ethernet interface (although a virtual one, 
created with ip add type [veth](https://man7.org/linux/man-pages/man4/veth.4.html)).  It's there so that the bridge has at least one interface beneath it to 
use its MAC address from.  It doesn't pass real traffic since it's not 
really connected to any physical device.
The bridge would work without it but then it could change its MAC address 
as interfaces enter and exit the bridge, and when the MAC of the bridge 
changes, external switches may be confused, making the host lose network 
for some time.

According to `nmcli device show` and `ip -details link show` commands, 
the `virbr0-nic` virtual network interface is a **TUN** device:    

```
$ nmcli device show virbr0-nic
```

Output:

```
GENERAL.DEVICE:               virbr0-nic
GENERAL.TYPE:                 tun
GENERAL.HWADDR:               52:54:00:11:22:33
GENERAL.MTU:                  1500
GENERAL.STATE:                10 (unmanaged)
GENERAL.CONNECTION:           --
GENERAL.CON-PATH:             --
```

```
$ ip -details link show virbr0-nic | \
egrep -woi "tun|tap|bridge|bridge_slave|vlan_tunnel"
```

Output:

```
tun
tap
bridge_slave
vlan_tunnel
```


IP forwarding [¹](#footnotes) was already enabled on this server:

```
$ sudo /sbin/sysctl --all | grep 'net.ipv4.ip_forward'
net.ipv4.ip_forward = 1
net.ipv4.ip_forward_update_priority = 1
net.ipv4.ip_forward_use_pmtu = 0
```

Additional package that you need to install is `bridge-utils`.

```
$ sudo dnf install bridge-utils
```

It provides `brctl` tool. 

```
$ sudo dnf whatprovides /usr/sbin/brctl
[...]
bridge-utils-1.5-9.el7.x86_64 : Utilities for configuring the linux 
                              : ethernet bridge
[...]
```

```
$ command -V brctl; type brctl; which brctl; whereis brctl
brctl is /usr/sbin/brctl
brctl is /usr/sbin/brctl
/usr/sbin/brctl
brctl: /usr/sbin/brctl /usr/share/man/man8/brctl.8.gz
```

The `brctl(8)` tool is used for the Ethernet bridge administration. 
From its man page: 

```
[...]
DESCRIPTION
    brctl is used to set up, maintain, and inspect the ethernet bridge 
    configuration in the linux kernel.

    An ethernet bridge is a device commonly used to connect different  
    networks of ethernets together, so that these ethernets will appear 
    as one ethernet to the participants.

    Each of the ethernets being connected corresponds to one physical
    interface in the bridge.  These individual ethernets are bundled into
    one bigger ('logical') ethernet, this bigger ethernet corresponds to
    the bridge network interface.
```

Currently, this server has one bridge device (named virbr0) installed by 
the libvirt library so the output of `brctl show` and  `brctl show virbr0` 
is the same. 

```
$ brctl show 
bridge name     bridge id               STP enabled     interfaces
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```

```
$ brctl show virbr0
bridge name     bridge id               STP enabled     interfaces
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```

---

## QEMU Networking

Two parts:
* The front-end.  The virtual network device; e.g. a PCI network card
  (aka NIC - network interface controller) that the guest sees. 
* The network back-end on the host side; that is, the interface that QEMU uses 
  to exchange network packets with the outside (like other QEMU instances
  or other real hosts in your intranet or the internet). 

QEMU supports networking by emulating some popular network cards
(aka NICs - network interface controllers) and establishing virtual
LANs (VLAN). There are four ways that QEMU guests can be connected:  

- User mode (SLiRP) 
- Tap 
- Socket redirection
- VDE networking

References:    
* [QEMU's new -nic command line option](https://www.qemu.org/2018/05/31/nic-parameter/)
* [Networking - QEMU Documentation](https://wiki.qemu.org/Documentation/Networking)   
* [Networking - QEMU on wikibooks.org](https://en.wikibooks.org/wiki/QEMU/Networking)    

The difference between `-net`, `-netdev` and `-nic` options of the `qemu` command:
* the `-net` option can create either a front-end or a back-end (and also does other things)
* the `-netdev` can only create a back-end
* a single occurrence of `-nic` creates both a front-end and a back-end


### SLiRP (user networking) 

* Provides access to the host's network via NAT
* It doesn't support protocols other than TCP and UDP so e.g. ping and other ICMP utilities won't work from the guest 
* A virtual DHCP server on 10.0.2.2    
* A virtual DNS server on 10.0.2.3    
* Gateway: 10.0.2.3    
* An IP address starting from 10.0.2.15   
* NO tap0 on the host   
* ssh from the guest to the host   
* By default it acts as a firewall and does not permit any incoming traffic   


#### Starting a QEMU VM with SLiRP (User Networking) 

With the `-netdev` option:

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev user,id=network0 \
-device e1000,netdev=network0 \
-nographic
```

If you don't specify any network configuration options, then QEMU creates 
a SLiRP user network back-end and an appropriate virtual network device 
for the guest (e.g. an E1000 PCI card for most x86 PC guests):  

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-nographic
```

Alternatively, you can use the `-net` ([QEMU's new -nic command line option](https://www.qemu.org/2018/05/31/nic-parameter/)) instead of `-netdev` option:  

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-net nic \
-net user \
-nographic
```

### Tap

#### How To Create a Bridged Networking (Tun Device in Tap Mode) for QEMU with an IP Address Provided by libvirt's Bridge virbr0

References:   
[Helper Networking](https://wiki.qemu.org/Features/HelperNetworking)   

* Allows the guest to directly access the host's network
* ICMP utilities (e.g. ping) working
* 192.168.122.x (gw: 192.168.122.254)
* tap0 on the host
* IP address visible on the host's network -> ssh from the guest to the host

When you install the libvirt [²](#footnotes) package, a virtual network 
switch named `virbr0` is created.  

To allow unprivileged user access to the bridge from `qemu-bridge-helper`
tool, create or modify `/etc/qemu-kvm/bridge.conf` (in other Linux 
distributions, the location of this configuration file might be different, 
for example, /etc/qemu/bridge.conf). 

```
% printf %s\\n "allow virbr0" | sudo tee -a /etc/qemu-kvm/bridge.conf
```

NOTE:   
`qemu-bridge-helper` and `bridge.conf` are in the `qemu-kvm-common` package:

```
$ dnf repoquery --file /etc/qemu-kvm/bridge.conf 
[...]
qemu-kvm-common-15:2.12.0-63.module+el8+2833+c7d6d092.x86_64

$ dnf repoquery --file /usr/libexec/qemu-bridge-helper
[...]
qemu-kvm-common-15:2.12.0-63.module+el8+2833+c7d6d092.x86_64
```

Both examples below use the `-netdev` option for the back-end, together 
with `-device` for the front-end.  That combination configures a network 
connection where the emulated NIC is directly connected to a host network
back-end, without a hub in between (as opposed to a network connection 
created with the legacy `-net` option). 


#### Tap with virbr0 (Default Virtual Network Switch Created by the libvirt Library) - Method 1

Use `br=<bridge name>` in `-netdev` option.  

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev bridge,br=virbr0,id=hn0 \
-device virtio-net-pci,netdev=hn0,id=nic1 \
-nographic
```

#### Tap with virbr0 (Default Virtual Network Switch Created by the libvirt Library) - Method 2

In the `-netdev` option, for `tap` specify `helper` and point `--br` to 
the `virbr0` because by default the `qemu-bridge-helper` expects that the 
bridge name is `br0`.

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev tap,helper="/usr/libexec/qemu-bridge-helper --br=virbr0",id=hn0 \
-device virtio-net-pci,netdev=hn0,id=nic1 \
-nographic
```


#### How To Create a Bridged Networking (Tun Device in Tap Mode) for QEMU with an IP Address Visible on the Host's Network and via a Bridge Interface You Created

When you don't want to use the [default] bridge `virbr0` provided by the 
libvirt library, you need to configure the new bridge *before* running qemu. 

*Steps:*  
* Create a network bridge device and bind your default-route NIC to it. 
* Create a tap device attached to the bridge for QEMU to use.
  - Instead of setting it up manually, you can let QEMU to set up
    the necessary **tap** device using the `qemu-bridge-helper` tool
    (location on this host with the operating system RHEL 8.5:
     `/usr/libexec/qemu-bridge-helper`).  This example shows this, that is,
    it leaves the tap device creation and deletion to QEMU.  
  - To set up a bridge as a regular user, the `qemu-bridge-helper` tool 
    must be run as root so you have to add the setuid bit; that is, 
    permission (access) needs to be `(4755/-rwsr-xr-x)`.  On this system
    I didn't have to do it as the helper was already configured with the setuid.
* Configure the host's firewall to allow packets to move across the bridge.
  I didn't have to make changes for this item because IP forwarding
  [¹](#footnotes) was already enabled on this host. 
  

```
$ lsmod | grep ^bridge
bridge                192512  0

$ lsmod | grep ^tun
tun                    53248  1
```

```
$ ip tuntap list
virbr0-nic: tap persist
```

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```

NOTE:   
Network bridging doesn't work with Wi-Fi:    
[Configure Network Bridging - Red Hat Product Documentation (RHEL 7)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/ch-configure_network_bridging) (Retrieved on Apr 2, 2022):   
> Note that a bridge cannot be established over Wi-Fi networks operating 
> in Ad-Hoc or Infrastructure modes.  This is due to the IEEE 802.11 
> standard that specifies the use of 3-address frames in Wi-Fi for the 
> efficient use of airtime.


#### Create a New Bridge Connection 

Create a new bridge connection named br0.  

```
$ sudo nmcli connection add type bridge con-name br0 ifname br0
```

```
$ ifconfig | grep -w br0
br0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
```

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.000000000000       yes
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```

Add `eno1` network interface to the bridge `br0`.

```
$ sudo nmcli connection add type bridge-slave ifname eno1 master br0
```

```
$ nmcli -f bridge connection show br0
bridge.mac-address:                     --
bridge.stp:                             yes
bridge.priority:                        32768
bridge.forward-delay:                   15
bridge.hello-time:                      2
bridge.max-age:                         20
bridge.ageing-time:                     300
bridge.group-forward-mask:              0
bridge.multicast-snooping:              yes
bridge.vlan-filtering:                  no
bridge.vlan-default-pvid:               1
bridge.vlans:                           --
```


#### Convert Settings from NIC (Network Interface Controller) to Bridge Interface

Allocate a static IP address to the new br0 interface.  (If the DHCP server 
is available, it would provide IP addresses and other settings but since 
this is a server, I chose a set up with a static IP address.) 

In this example, network settings of the existing network interface 
`eno1` are converted to the `br0` bridge settings. 

```
$ nmcli connection show eno1 | grep 'ipv4.addresses'
ipv4.addresses:   123.12.23.148/24

$ nmcli connection show eno1 | grep gateway
ipv4.gateway:     123.12.23.254

$ nmcli connection show eno1 | grep 'ipv4.dns'
ipv4.dns:         208.67.222.222,208.67.220.220  <-- Will show your DNS servers

$ nmcli connection show eno1 | grep 'ipv4.method'
ipv4.method:                            manual
```

```
$ sudo nmcli connection modify br0 ipv4.addresses '123.12.23.148/24'
$ sudo nmcli connection modify br0 ipv4.gateway '123.12.23.254'
$ sudo nmcli connection modify br0 ipv4.dns '208.67.222.222,208.67.220.220'
$ sudo nmcli connection modify br0 ipv4.method manual
```

```
$ sudo nmcli connection up br0
```

Output:

```
Connection successfully activated (master waiting for slaves) 
(D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/28)
```

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.0894eff40004       yes             eno1
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```

```
$ nmcli connection show
NAME               UUID                                  TYPE      DEVICE 
eno1               4d928341-...........................  ethernet  eno1   
eno2               e94a2707-...........................  ethernet  eno2   
br0                07d25404-...........................  bridge    br0    
virbr0             3216d7f0-...........................  bridge    virbr0 
bridge-slave-eno1  02132481-...........................  ethernet  --     
[...]
```

```
$ ip address show br0
40: br0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue 
      state DOWN group default qlen 1000
      link/ether 5a:18:0d:a2:18:26 brd ff:ff:ff:ff:ff:ff
      inet 123.12.23.148/24 brd 123.12.23.255 scope global noprefixroute br0
      valid_lft forever preferred_lft forever
```

Remove the `eno1` network interface because now the `br0` bridge 
has a static IP address and the `eno1` will be in forwarding state. 

```
$ sudo nmcli connection delete eno1
```

Allow a regular user access to the new bridge `br0` from 
`qemu-bridge-helper`.  Add `allow br0` to `bridge.conf`. 


```
$ printf %s\\n "allow br0" | sudo tee -a /etc/qemu-kvm/bridge.conf
```


```
$ cat /etc/qemu-kvm/bridge.conf
allow virbr0
allow br0
```

NOTE:   
You don't need to create a tap device (a.k.a. a tap interface) manually 
because the `qemu-bridge-helper` tool (location on the host's OS, RHEL 8.5: 
`/usr/libexec/qemu-bridge-helper`) creates it automatically when you 
start a guest VM.  By default the helper assumes that the bridge name 
is `br0`.  Also, the name of a tap device that the helper automatically 
creates when the guest VM is started is `tap0`. 

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev bridge,br=br0,id=hn0 \
-device virtio-net-pci,netdev=hn0,id=nic1 \
-nographic
```

(NOTE:   You can skip `br=br0` because the `qemu-bridge-helper` tool assumes that the name of the bridge is `br0`.   Also, you can skip `id=nic1`.)    


Explanation for `-netdev` and `device` options:  

`-netdev bridge,br=br0,id=hn0`

Create a bridge network back-end (with id hn0) via bridge `br0`. 
This will connect to a tap interface tap0 device (aka tap0 interface), 
which will be automatically setup with the helper `qemu-bridge-helper`.  


`-device virtio-net-pci,netdev=hn0,id=nic1` 

Create a NIC (of a model `virtio-net-pci` and with id nic1) and connect 
to the `hn0` back-end created by the previous parameter.  

NOTE:  To list all devices, including network devices, 
run `/usr/libexec/qemu-kvm -device help`, which shows help on possible 
drivers and properties (in this case, since you'd be interested in network devices, you'd look under the section titled "Network devices").   

While the guest VM is running, start another shell on the host.
Run the following set of commands on the host system.  

```
$ ifconfig | egrep "^br|^virbr|^tap"
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
tap0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
```

```
$ ifconfig -a | egrep "^br|^virbr|^tap"
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
tap0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
virbr0-nic: flags=4098<BROADCAST,MULTICAST>  mtu 1500
```

```
$ nmcli connection | egrep -i "bridge|tun|tap|type"
NAME               UUID                                  TYPE      DEVICE 
br0                07d25404-5b85-4006-bdbc-272c63b9aaf0  bridge    br0    
virbr0             3216d7f0-124e-4c66-a6de-5b218d18377c  bridge    virbr0 
bridge-slave-eno1  02132481-584a-413d-97f5-46b161a4de9f  ethernet  eno1   
tap0               37ddcf4a-1105-4ab4-b076-0b62f87df4a8  tun       tap0   
```

```
$ nmcli connection show br0 | egrep -wi "type|mode|name|master|slave"
connection.type:                    bridge
connection.interface-name:          br0
connection.master:                  --
connection.slave-type:              --
ipv6.addr-gen-mode:                 stable-privacy
GENERAL.NAME:                       br0
GENERAL.MASTER-PATH:                --
```


```
$ nmcli connection show tap0 | egrep -wi "type|mode|name|master|slave"
connection.type:                    tun
connection.interface-name:          tap0
connection.master:                  br0
connection.slave-type:              bridge
bridge-port.hairpin-mode:           no
tun.mode:                           2 (tap)
GENERAL.NAME:                       tap0
GENERAL.MASTER-PATH:                /org/freedesktop/NetworkManager/Devices/34
```

```
$ nmcli device | egrep -i "bridge|tun|type"
DEVICE      TYPE      STATE                   CONNECTION        
br0         bridge    connected               br0               
virbr0      bridge    connected (externally)  virbr0            
eno1        ethernet  connected               bridge-slave-eno1 
tap0        tun       connected (externally)  tap0              
virbr0-nic  tun       unmanaged               --                
```

```
$ nmcli device show br0
GENERAL.DEVICE:         br0
GENERAL.TYPE:           bridge
GENERAL.HWADDR:         08:94:EF:F4:00:04
GENERAL.MTU:            1500
GENERAL.STATE:          100 (connected)
GENERAL.CONNECTION:     br0
GENERAL.CON-PATH:       /org/freedesktop/NetworkManager/ActiveConnection/28
IP4.ADDRESS[1]:         123.12.23.148/24 
IP4.GATEWAY:            123.12.23.254
IP4.ROUTE[1]:           dst = 123.12.23.0/24, nh = 0.0.0.0, mt = 426
IP4.ROUTE[2]:           dst = 0.0.0.0/0, nh = 123.12.23.254, mt = 426
IP4.DNS[1]:             208.67.222.222
IP4.DNS[2]:             208.67.220.220
IP6.ADDRESS[1]:         fe80::c929:3169:74dd:2429/64
IP6.GATEWAY:            fe80::a68c:dbff:fede:1301
IP6.ROUTE[1]:           dst = fe80::/64, nh = ::, mt = 426
IP6.ROUTE[2]:           dst = ::/0, nh = fe80::a68c:dbff:fede:1301, mt = 426
IP6.ROUTE[3]:           dst = ff00::/8, nh = ::, mt = 256, table=255
```

```
$ nmcli device show tap0
GENERAL.DEVICE:         tap0
GENERAL.TYPE:           tun
GENERAL.HWADDR:         FE:90:76:81:BE:CF
GENERAL.MTU:            1500
GENERAL.STATE:          100 (connected (externally))
GENERAL.CONNECTION:     tap0
GENERAL.CON-PATH:       /org/freedesktop/NetworkManager/ActiveConnection/30
```

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.0894eff40004       yes             eno1
                                                        tap0
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```


```
$ ip link show master br0
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br0 
    state UP mode DEFAULT group default qlen 1000
    link/ether 08:94:ef:f4:00:04 brd ff:ff:ff:ff:ff:ff
44: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel 
    master br0 state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether fe:90:76:81:be:cf brd ff:ff:ff:ff:ff:ff
```

```
$ bridge link show
[...]
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 
     state forwarding priority 32 cost 100 
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 hwmode VEPA 
[...]
44: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 
      state forwarding priority 32 cost 100 
```

```
$ nmcli device show br0 | grep -i type
GENERAL.TYPE:                           bridge

$ nmcli device show tap0 | grep -i type
GENERAL.TYPE:                           tun

$ nmcli device show eno1 | grep -i type
GENERAL.TYPE:                           ethernet
```


Return to the first shell, and in the guest VM, power off the system.

```
# poweroff
```


Back on the host system, after the VM is powered off:

```
$ ifconfig | egrep "^br|^virbr|^tap"
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
```

```
$ ifconfig -a | egrep "^br|^virbr|^tap"
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
virbr0-nic: flags=4098<BROADCAST,MULTICAST>  mtu 1500
```

```
$ nmcli connection | egrep -i "bridge|tun|tap|type"
NAME               UUID                                  TYPE      DEVICE 
br0                07d25404-5b85-4006-bdbc-272c63b9aaf0  bridge    br0    
virbr0             3216d7f0-124e-4c66-a6de-5b218d18377c  bridge    virbr0 
bridge-slave-eno1  02132481-584a-413d-97f5-46b161a4de9f  ethernet  eno1   
```

```
$ nmcli device | egrep -i "bridge|tun|tap|type"
DEVICE      TYPE      STATE                   CONNECTION        
br0         bridge    connected               br0               
virbr0      bridge    connected (externally)  virbr0            
eno1        ethernet  connected               bridge-slave-eno1 
virbr0-nic  tun       unmanaged               --                
```

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.0894eff40004       yes             eno1
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```

```
$ ip link show master br0
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br0 
    state UP mode DEFAULT group default qlen 1000
    link/ether 08:94:ef:f4:00:04 brd ff:ff:ff:ff:ff:ff
```

```
$ bridge link show
[...]
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 
     state forwarding priority 32 cost 100 
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 hwmode VEPA 
```


### How To Launch a QEMU Instance in Bridge Network with Two NICs in Two Separate Networks via TAP Network Connections - aka Configure Host TAP Network Backends/Host TAP Interfaces

#### Two Bridges - Method 1

Example:

Launch a QEMU instance with two NICs, each connected to a TAP device.
Use the default network script but instead of using the script's `virbr0` 
bridge, connect the both TAP devices to bridgess `br0` and `br1`,
respectively:  

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

When it starts the guest VM, QEMU automatically creates two **TUN**
connections (aka tun devices) of type **TAP**.  In this case QEMU names
these two devices tap0 and tap1.  You can obtain the details by starting
a separate shell (while the guest VM is running) and by using the 
following commands: 
`ip --details address show`, `ip --details link show`, 
`ip --details tuntap`, 
`nmcli connection`, `nmcli device`,
`nmcli device show`, and `brctl show`.   


#### Two Bridges - Method 2

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-netdev bridge,br=br0,id=hn0 \
-netdev bridge,br=br1,id=hn1 \
-device virtio-net-pci,netdev=hn0 \
-device virtio-net-pci,netdev=hn1 \
-nographic
```

### VDE Networking

From [Networking - QEMU Wiki - Documentation](https://wiki.qemu.org/Documentation/Networking) (Retrieved on Apr 2, 2022):   
> VDE
> 
> The VDE networking backend uses the [Virtual Distributed Ethernet](https://github.com/virtualsquare/vde-2) infrastructure to network guests. 
> Unless you specifically know that you want to use VDE, it is probably 
> not the right backend to use. 


### Redirecting Ports  

#### How to Get SSH Access to a Guest with Port Forwarding

* No tap0 on the guest.   
* IP address in the guest:  10.0.2.x  (gw: 10.0.2.254) 

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-m 4G \
-device e1000,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::5555-:22 \
-nographic
```

The first line creates a virtual e1000 network device, while the second 
line created one user typed backend, forwarding local port 5555 to guest 
port 22.  Then from the host:


```
$ ssh -p 5555 username@localhost
```

to have SSH access to guest after its network setup (if there are any 
firewalls in the guest or host, disable them or allow the needed ports).   

---

### How To Start a QEMU VM with Bridged Networking (with the Legacy -net Option, aka via Hub) 

*Task:*  Start a guest VM with the virtual network bridge `virbr0` 
(installed by the libvirt).

When QEMU starts (e.g. when you invoke it by starting a VM via QEMU), 
it runs the `qemu-bridge-helper` tool, which automatically creates 
a new tap device, which is effectively a virtual NIC (network interface
controller) with its own MAC address, and connects that device to the bridge.


*NOTE:*   
This example shows the use of the `-net` [³](#footnotes) legacy option.    

* Possible to ping from the guest VM
* The NIC is an e1000 by default on the PC target so if you want to emulate 
  an e1000 NIC in the guest you can skip `-model=e1000` in the `-net nic` option.
  As such, in the example below, you can use `-net nic` instead of `-net nic,model=e1000` 
* The emulated NIC and the host back-end are not *directly* connected.
  They are rather both connected to an emulated **hub** (called "vlan" in older versions of QEMU). 

```
$ /usr/libexec/qemu-kvm \
-drive format=raw,file=xcatmn.img \
-global ide-hd.physical_block_size=4096 \
-m 4G \
-net nic,model=e1000 \
-net bridge,br=virbr0 \
-nographic
```

```
  CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
  CentOS Linux (0-rescue-d01c41227ec248b983c9ea19758c73b0) 7 (Core)


  Use the ↑ and ↓ keys to change the selection.
```

Log in to the guest VM.

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

xcatmn login: root
Password:
```

Networking information in the guest VM: 

```
# ifconfig | grep -w inet
    inet 192.168.122.76  netmask 255.255.255.0  broadcast 192.168.122.255
    inet 127.0.0.1  netmask 255.0.0.0
```

```
# nmcli connection 
NAME  UUID                                  TYPE      DEVICE 
ens3  e5ec08b7-...........................  ethernet  ens3
```

```
# ip address show ens3 | grep -w inet
    inet 192.168.122.76/24 brd 192.168.122.255 scope global noprefixroute dynam3
```

```
# cat /etc/sysconfig/network-scripts/ifcfg-ens3
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="dhcp"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="no"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens3"
UUID="e5ec08b7-..........................."
DEVICE="ens3"
ONBOOT="yes"
DNS1="208.67.222.222"  <-- Will list your DNS1 server
DNS2="208.67.220.220"  <-- Will list your DNS2 server
```

```
# nmcli device show ens3 | grep DNS
IP4.DNS[1]:         192.168.122.1  
IP4.DNS[2]:         208.67.222.222    <-- Will show your DNS2 server
IP4.DNS[3]:         208.67.220.220    <-- Will show your DNS3 server
```

The kernel routing tables:

```
# netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.122.1   0.0.0.0         UG        0 0          0 ens3
192.168.122.0   0.0.0.0         255.255.255.0   U         0 0          0 ens3
```

Or:

```
# route -e
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
default         gateway         0.0.0.0         UG        0 0          0 ens3
192.168.122.0   0.0.0.0         255.255.255.0   U         0 0          0 ens3
```

Or with the new tool `ip(8)`, from the iproute2 package (a collection of 
userspace utilities for controlling and monitoring various aspects of 
networking in the Linux kernel): 

```
# ip route
default via 192.168.122.1 dev ens3 proto dhcp metric 100 
192.168.122.0/24 dev ens3 proto kernel scope link src 192.168.122.76 metric 100 
```

```
# cat /etc/resolv.conf 
# Generated by NetworkManager
search yourdomain.org
nameserver 192.168.122.1
nameserver 208.67.222.222   <-- Will list your nameserver1
nameserver 208.67.220.220   <-- Will list your nameserver2
```

#### virbr0-nic Ethernet Interface and tap0 Device are Created Automatically when Guest VM is Running 

While the guest VM is running, start another shell on the host.

On the host system, run the following commands, which show that 
the **tun** device named `tap0` (a.k.a. network interface of type 
**tun** - tun mode **tap** ) is created automatically (as a slave 
of the `virbr0` bridge) when the guest VM is powered on.   

```
$ ifconfig | egrep -i "virbr|tap"
tap0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
virbr0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
```

```
$ ifconfig -a | egrep -i "virbr|tap"
tap0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
virbr0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
virbr0-nic: flags=4098<BROADCAST,MULTICAST>  mtu 1500
```

```
$ nmcli connection | egrep -i "bridge|tun|tap|type"
NAME    UUID                                  TYPE      DEVICE
virbr0  3216d7f0-124e-4c66-a6de-5b218d18377c  bridge    virbr0
tap0    72e1da4b-5a73-40ec-9cce-c480078f3c68  tun       tap0
```

```
$ nmcli connection show virbr0 | egrep -wi "type|mode|name|master|slave"
connection.type:                    bridge
connection.interface-name:          virbr0
connection.master:                  --
connection.slave-type:              --
ipv6.addr-gen-mode:                 stable-privacy
GENERAL.NAME:                       virbr0
GENERAL.MASTER-PATH:                --
```

```
$ nmcli connection show tap0 | egrep -wi "type|mode|name|master|slave"
connection.type:                    tun
connection.interface-name:          tap0
connection.master:                  virbr0
connection.slave-type:              bridge
bridge-port.hairpin-mode:           no
tun.mode:                           2 (tap)
GENERAL.NAME:                       tap0
GENERAL.MASTER-PATH:                /org/freedesktop/NetworkManager/Devices/6
```

```
$ nmcli device | egrep -i "bridge|tun|type"
DEVICE      TYPE      STATE                   CONNECTION
virbr0      bridge    connected (externally)  virbr0
tap0        tun       connected (externally)  tap0
virbr0-nic  tun       unmanaged               --
```

```
$ nmcli device show virbr0
GENERAL.DEVICE:           virbr0
GENERAL.TYPE:             bridge
[...]
GENERAL.STATE:            100 (connected (externally))
GENERAL.CONNECTION:       virbr0
[...]
IP4.ADDRESS[1]:           192.168.122.1/24
IP4.GATEWAY:              --
IP4.ROUTE[1]:             dst = 192.168.122.0/24, nh = 0.0.0.0, mt = 0
[...]
```

```
$ nmcli device show virbr0-nic
GENERAL.DEVICE:           virbr0-nic
GENERAL.TYPE:             tun
[...]
GENERAL.STATE:            10 (unmanaged)
GENERAL.CONNECTION:       --
[...]
```

```
$ nmcli device show tap0
GENERAL.DEVICE:           tap0
GENERAL.TYPE:             tun
[...]
GENERAL.STATE:            100 (connected (externally))
GENERAL.CONNECTION:       tap0
[...]
```

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
virbr0          8000.525400a7c2ab       yes             tap0
                                                        virbr0-nic
```


#### Verification of Bridge Creation and Network Connection

Use the `ip` utility to display the link status of Ethernet devices that 
are ports of the bridge `virbr0`.

```
$ ip link show master virbr0
7: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master 
      virbr0 state DOWN mode DEFAULT group default qlen 1000
      link/ether 52:54:00:a7:c2:ab brd ff:ff:ff:ff:ff:ff
33: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master 
      virbr0 state UNKNOWN mode DEFAULT group default qlen 1000
      link/ether fe:0e:7b:05:f6:b1 brd ff:ff:ff:ff:ff:ff
```

You can also use the `bridge` utility to display the status of Ethernet 
devices that are ports of the `virbr0` bridge device.

```
$ bridge link show 
[...]
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 hwmode VEPA 
5: eno2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 hwmode VEPA 
7: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 master virbr0 state disabled 
     priority 32 cost 100 
33: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master virbr0 state 
     forwarding priority 32 cost 100
```

```
$ nmcli device show virbr0 | grep -i type
GENERAL.TYPE:                           bridge

$ nmcli device show virbr0-nic | grep -i type
GENERAL.TYPE:                           tun

$ nmcli device show tap0 | grep -i type
GENERAL.TYPE:                           tun
```

Back in the first shell, in the guest VM, power off the system.

```
# poweroff
```


#### virbr0-nic Network Interface and tap0 Device are Automatically Removed when Guest VM is Powered Down 

Back on the host system, after the VM is powered off, run the following 
set of commands.  They show that the the **tun** device named `tap0` 
(network interface of type **tun** - tun mode **tap** ) is automatically 
removed after the guest VM is powered off.  

```
$ ifconfig | egrep -i "virbr|tap"
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
```

```
$ ifconfig -a | egrep -i "virbr|tap"
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
virbr0-nic: flags=4098<BROADCAST,MULTICAST>  mtu 1500
```

```
$ nmcli connection | egrep -i "bridge|tun|tap|type"
NAME    UUID                                  TYPE      DEVICE
virbr0  3216d7f0-124e-4c66-a6de-5b218d18377c  bridge    virbr0
```

```
$ nmcli device | egrep -i "bridge|tun|tap|type"
DEVICE      TYPE      STATE                   CONNECTION
virbr0      bridge    connected (externally)  virbr0
virbr0-nic  tun       unmanaged               --
```

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
virbr0          8000.525400a7c2ab       yes             virbr0-nic
```

```
$ ip link show master virbr0
7: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 
      state DOWN mode DEFAULT group default qlen 1000
      link/ether 52:54:00:a7:c2:ab brd ff:ff:ff:ff:ff:ff
```

```
$ bridge link show
[...]
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 hwmode VEPA 
5: eno2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 hwmode VEPA 
7: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 master virbr0 state disabled 
      priority 32 cost 100 
```


---

## Appendix

This section shows how the guest VM used in the examples was created. 


### Create a Customized CentOS/RHEL DVD ISO for Installation in Text Mode via Serial Console 

Download CentOS 7.9 DVD ISO image and verify the SHA256 checksum 
of the ISO image file to ensure its integrity -- Verify that the SHA256 
checksum of the downloaded file matches that of the SHA256 checksum listed 
at the CentOS.org official download site. 

```
$ cd /tmp/

$ wget https://mirror.esecuredata.com/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Everything-2009.iso

$ wget https://mirror.esecuredata.com/centos/7.9.2009/isos/x86_64/sha256sum.txt

$ ls -lh sha256sum.txt
-rw-rw-r-- 1 dusko dusko 398 Nov  4  2020 sha256sum.txt

$ wc -l sha256sum.txt
4 sha256sum.txt

$ grep -n 'CentOS-7-x86_64-Everything-2009.iso' sha256sum.txt
1:689531cce9cf484378481ae762fae362791a9be078fda10e4f6977bf8fa71350  CentOS-7-x86_64-Everything-2009.iso

$ grep CentOS-7-x86_64-Everything-2009.iso sha256sum.txt > /tmp/sha256sum.txt.tmp

$ mv /tmp/sha256sum.txt.tmp /tmp/sha256sum.txt

$ cat /tmp/sha256sum.txt
689531cce9cf484378481ae762fae362791a9be078fda10e4f6977bf8fa71350  CentOS-7-x86_64-Everything-2009.iso

$ sha256sum --check sha256sum.txt
CentOS-7-x86_64-Everything-2009.iso: OK
```

Customize the DVD ISO image so that the installer redirects its text output 
to the serial console, specifically to the first serial device (ttyS0), 
with baud rate of 19200. (This is to meet the requirement of the system 
that this VM is going to replicate.)    

```
$ sudo mkdir -p /mnt/{dvd,customdvd}
```

```
$ sudo \
mount \
-t iso9660 \
/tmp/CentOS-7-x86_64-Everything-2009.iso \
/mnt/dvd/
mount: /mnt/dvd: WARNING: device write-protected, mounted read-only.
```

```
$ sudo rsync -a /mnt/dvd/ /mnt/customdvd/
```


```
$ ls -alh /mnt/customdvd/isolinux/
total 60M
drwxr-xr-x 2 root root  198 Oct 26  2020 .
drwxr-xr-x 8 root root  254 Oct 29  2020 ..
-r--r--r-- 1 root root 2.0K Nov  2  2020 boot.cat
-rw-r--r-- 1 root root   84 Oct 26  2020 boot.msg
-rw-r--r-- 1 root root  281 Oct 26  2020 grub.conf
-rw-r--r-- 1 root root  53M Oct 26  2020 initrd.img
-rw-r--r-- 1 root root  24K Oct 26  2020 isolinux.bin
-rw-r--r-- 1 root root 3.0K Oct 26  2020 isolinux.cfg
-rw-r--r-- 1 root root 187K Nov  5  2016 memtest
-rw-r--r-- 1 root root  186 Sep 30  2015 splash.png
-r--r--r-- 1 root root 2.2K Nov  2  2020 TRANS.TBL
-rw-r--r-- 1 root root 150K Oct 30  2018 vesamenu.c32
-rwxr-xr-x 1 root root 6.5M Oct 19  2020 vmlinuz
```

```
$ cat /mnt/customdvd/isolinux/boot.msg


splash.lss

 -  Press the 01<ENTER>07 key to begin the installation process.

```


Delete the line with 'splash.lss' from the 'boot.msg'.

```
$ sudo sed -i.bkp '/splash.lss/d' /mnt/customdvd/isolinux/boot.msg
```

```
$ diff \
--unified=0 \
/mnt/customdvd/isolinux/boot.msg.bkp \
/mnt/customdvd/isolinux/boot.msg
--- /mnt/customdvd/isolinux/boot.msg.bkp      2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/isolinux/boot.msg    2022-04-02 08:09:31.109458847 -0700
@@ -2 +1,0 @@
-splash.lss
```


```
$ cat /mnt/customdvd/isolinux/boot.msg



 -  Press the 01<ENTER>07 key to begin the installation process.

```


```
$ sudo rm -i /mnt/customdvd/isolinux/boot.msg.bkp
rm: remove regular file '/mnt/customdvd/isolinux/boot.msg.bkp'? y
```

Remove 'boot.cat'. It will be regenerated in a later step.

```
$ sudo rm -i /mnt/customdvd/isolinux/boot.cat
rm: remove regular file '/mnt/customdvd/isolinux/boot.cat'? y
```

Tell ISOLINUX to use a serial port as the console. "port" is a number
(0 = /dev/ttyS0 = COM1, etc.) or an I/O port address (e.g. 0x3F8)
([https://www.syslinux.org/old/faq.php](https://www.syslinux.org/old/faq.php),
[https://wiki.syslinux.org/wiki/index.php?title=SYSLINUX](https://wiki.syslinux.org/wiki/index.php?title=SYSLINUX)).

Here I want to use the port 0 so the `console` statement uses tty0 and ttyS0.  


```
$ sudo vi /mnt/customdvd/isolinux/isolinux.cfg
```


```
$ diff \
--unified=0 \
/mnt/dvd/isolinux/isolinux.cfg \
/mnt/customdvd/isolinux/isolinux.cfg
--- /mnt/dvd/isolinux/isolinux.cfg      2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/isolinux/isolinux.cfg        2022-04-02 08:12:12.604830661 -0700
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
$ ls -lh /mnt/customdvd/EFI/BOOT/
total 6.0M
-rwxr--r-- 1 root root 978K Jul 31  2020 BOOTIA32.EFI
-rwxr--r-- 1 root root 1.2M Jul 31  2020 BOOTX64.EFI
drwxr-xr-x 2 root root   42 Oct 26  2020 fonts
-rw-r--r-- 1 root root 1.3K Oct 26  2020 grub.cfg
-rwxr--r-- 1 root root 745K Jul 28  2020 grubia32.efi
-rwxr--r-- 1 root root 1.1M Jul 28  2020 grubx64.efi
-rwxr--r-- 1 root root 898K Jul 31  2020 mmia32.efi
-rwxr--r-- 1 root root 1.2M Jul 31  2020 mmx64.efi
-r--r--r-- 1 root root 1.8K Nov  2  2020 TRANS.TBL
```


```
$ sudo vi /mnt/customdvd/EFI/BOOT/grub.cfg
```

```
$ diff --unified=0 /mnt/dvd/EFI/BOOT/grub.cfg /mnt/customdvd/EFI/BOOT/grub.cfg
--- /mnt/dvd/EFI/BOOT/grub.cfg  2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/EFI/BOOT/grub.cfg    2022-04-02 08:23:17.334493194 -0700
@@ -16,0 +17,4 @@
+serial --unit=0 --speed=19200 --word=8 --parity=no --stop=1
+terminal_input serial console=tty0 console=ttyS0,19200
+terminal_output serial console=tty0 console=ttyS0,19200
+
```

```
$ cat /mnt/customdvd/EFI/BOOT/grub.cfg
set default="1"

function load_video {
  insmod efi_gop
  insmod efi_uga
  insmod video_bochs
  insmod video_cirrus
  insmod all_video
}

load_video
set gfxpayload=keep
insmod gzio
insmod part_gpt
insmod ext2

serial --unit=0 --speed=19200 --word=8 --parity=no --stop=1
terminal_input serial console=tty0 console=ttyS0,19200
terminal_output serial console=tty0 console=ttyS0,19200

set timeout=60
### END /etc/grub.d/00_header ###

search --no-floppy --set=root -l 'CentOS 7 x86_64'

### BEGIN /etc/grub.d/10_linux ###
menuentry 'Install CentOS 7' --class fedora --class gnu-linux --class gnu --class os {
        linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet
        initrdefi /images/pxeboot/initrd.img
}
menuentry 'Test this media & install CentOS 7' --class fedora --class gnu-linux --class gnu --class os {
        linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet
        initrdefi /images/pxeboot/initrd.img
}
submenu 'Troubleshooting -->' {
        menuentry 'Install CentOS 7 in basic graphics mode' --class fedora --class gnu-linux --class gnu --class os {
                linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet
                initrdefi /images/pxeboot/initrd.img
        }
        menuentry 'Rescue a CentOS system' --class fedora --class gnu-linux --class gnu --class os {
                linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet
                initrdefi /images/pxeboot/initrd.img
        }
}
```


```
$ isoinfo -d -i /tmp/CentOS-7-x86_64-Everything-2009.iso | grep "Volume id"
Volume id: CentOS 7 x86_64

$ isoinfo -d -i /tmp/CentOS-7-x86_64-Everything-2009.iso | grep Joliet
Joliet with UCS level 3 found

$ isoinfo -d -i /tmp/CentOS-7-x86_64-Everything-2009.iso | grep prepare
Data preparer id:

$ isoinfo -d -i /tmp/CentOS-7-x86_64-Everything-2009.iso | grep Torito
El Torito VD version 1 found, boot catalog is in sector 1430
```

```
$ blkid /tmp/CentOS-7-x86_64-Everything-2009.iso
/tmp/CentOS-7-x86_64-Everything-2009.iso: BLOCK_SIZE="2048" 
  UUID="2020-11-02-15-15-23-00" LABEL="CentOS 7 x86_64" TYPE="iso9660" 
  PTUUID="6b8b4567" PTTYPE="dos"
```

```
$ sudo \
mkisofs \
-o /tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso \
-b isolinux/isolinux.bin \
-J \
-R \
-l \
-c isolinux/boot.cat \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
-eltorito-alt-boot \
-e images/efiboot.img \
-no-emul-boot \
-graft-points \
-input-charset utf-8 \
-output-charset utf-8 \
-V "CentOS 7 x86_64" \
/mnt/customdvd
```

```
$ sudo chown dusko:dusko /tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso
```

```
$ blkid /tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso
/tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso: BLOCK_SIZE="2048" 
  UUID="2022-04-02-08-31-52-00" LABEL="CentOS 7 x86_64" TYPE="iso9660"
```

Implant an MD5 checksum in the ISO image.

```
$ implantisomd5 /tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso
```

Check an MD5 checksum implanted by `implantisomd5`.

```
$ checkisomd5 --verbose /tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso
[...]
The media check is complete, the result is: PASS.

It is OK to use this media.
```

Create a raw image of 60 GB in size. Using seek option creates 
a sparse file, which saves space.


```
$ dd if=/dev/null of=xcatmn.img bs=1M seek=61440
```

```
$ ls -lh xcatmn.img
-rw-rw-r-- 1 dusko dusko 60G Mar 2 08:36 xcatmn.img
```

```
$ command -V qemu-kvm; type qemu-kvm; which qemu-kvm; whereis qemu-kvm
/usr/bin/command: line 2: command: qemu-kvm: not found
/usr/bin/type: line 2: type: qemu-kvm: not found
qemu-kvm: Command not found.
qemu-kvm: /usr/lib64/qemu-kvm /etc/qemu-kvm /usr/libexec/qemu-kvm 
          /usr/share/qemu-kvm /usr/share/man/man1/qemu-kvm.1.gz
```

### Install CentOS Linux 7.9 on QEMU Guest VM Image 

Create a QEMU virtual machine with the following properties:
- for the VM's disk use the 60GB image created in the previous step   
- configure the disk with the physical sector size of 4096 bytes (4 K)
  (this is to meet the requirement of the system that this VM is going 
   to replicate)  
- 4 GB RAM 
- virtual machine booting on the first serial device (ttyS0)
- VM booting from the first CD-ROM/DVD drive

```
$ /usr/libexec/qemu-kvm \
-cdrom /tmp/CentOS-7-x86_64-Everything-CUSTOM-2009.iso \
-drive format=raw,file=xcatmn.img \
-global ide-hd.physical_block_size=4096 \
-m 4G \
-boot d \
-serial pty \
-nographic
```

This opens QEMU monitor (aka QEMU console): 

```
QEMU 4.2.0 monitor - type 'help' for more information
(qemu) char device redirected to /dev/pts/1 (label serial0)
(qemu)
```

Open a new shell and start `minicom` to connect to the installer, whose 
output is redirected to the first serial device (ttyS0) to /dev/pts/1. 
(Baud rate of 19200 was configured earlier in the `grub.cfg`, when you 
customized the installation DVD ISO image.)  

```
$ minicom --baudrate=19200 --ptty=/dev/pts/1
```


Install CentOS 7.9 Linux.

```
[  OK  ] Started Media check on /dev/sr0.
[  OK  ] Started Show Plymouth Boot Screen.
[  OK  ] Reached target Paths.
[...]
Starting installer, one moment...
anaconda 21.48.22.159-1 for CentOS 7 started.
 * installation log files are stored in /tmp during the installation
 * shell is available on TTY2
 * when reporting a bug add logs from /tmp as separate text/plain attachments
15:43:19 Not asking for VNC because we don't have a network
=============================================================================
=============================================================================
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

[anaconda] 1:main* 2:shell  3:log  4:storage-lo> Switch tab: Alt+Tab | Help: F1
```

```
2: Time settings > America/Vancouver timezone
NTP servers:
ntp1.serverinyourregion.org
ntp2.serverinyourregion.org

4: Software selection > Compute Node

5: Installation Destination
QEMU HARDDISK 60 GiB (sda) > Use All Space > LVM

7: Network configuration
Host name:  xcatmn.yourdomain.org

Wired (ens3)
Device configuration
DHCP
IPv6:  ignore
Nameservers:  208.67.222.222, 208.67.220.220  <<-- Use your nameservers 
[x] Connect automatically after reboot
[x] Apply configuration in installer

8: Root password

9: User creation
Create user
Fullname: dusko
Username: dusko
Use password
[X] Administrator
Groups: wheel
```


```
=============================================================================
=============================================================================
Installation
  
 1) [x] Language settings                 2) [x] Time settings
        (English (United States))                (America/Vancouver timezone)
 3) [x] Installation source               4) [x] Software selection
        (Local media)                            (Compute Node)
 5) [x] Installation Destination          6) [x] Kdump
        (Automatic partitioning                  (Kdump is enabled)
        selected)                         8) [x] Root password
 7) [x] Network configuration                    (Password is set.)
        (Wired (ens3) connected)
 9) [x] User creation
        (Administrator dusko will be
        created)

Please make your choice from above ['q' to quit | 'b' to begin installation |
'r' to refresh]:  b

=============================================================================
=============================================================================
Progress
Setting up the installation environment
.
Creating disklabel on /dev/sda
Creating xfs on /dev/sda1
Creating lvmpv on /dev/sda2
Creating swap on /dev/mapper/centos-swap
Creating xfs on /dev/mapper/centos-home
Creating xfs on /dev/mapper/centos-root
.
Running pre-installation scripts
.
Starting package installation process
Preparing transaction from installation source
Installing libgcc (1/483)
[...]
Installing iwl6000g2a-firmware (482/483)
Installing words (483/483)
Performing post-installation setup tasks
Installing boot loader
.
Performing post-installation setup tasks

Configuring installed system
Writing network configuration
Creating users
Configuring addons
Generating initramfs
Running post-installation scripts
.
    Use of this product is subject to the license agreement found at
      /usr/share/centos-release/EULA

     Installation complete.  Press return to quit
```

Press Ctr+b 2  

Power off the virtual machine.   

```
[anaconda root@localhost ~]# poweroff

[  OK  ] Started Show Plymouth Power Off Screen.
[  OK  ] Stopped Anaconda.
[  OK  ] Stopped target Anaconda System Services.
[...]
[  OK  ] Reached target Shutdown.
dracut Warning: Killing all remaining processes
Powering off.
[ 1909.085711] Power down.
```

Not shown here:  QEMU console (in the first shell) automatically exits.

---

#### Footnotes

[¹] IP Forwarding and libvirt Networking

> libvirt's default network configures an isolated bridge device to be
> used by guest domains.  This default bridge creates a private network
> for the virtual machines but does not connect that private network to
> your physical network.  The simplest way to complete that connection is
> to enable IP Forwarding in the kernel.  You can quickly enable IP
> Forwarding using sysctl:
>
>     # sysctl -w net.ipv4.ip_forward=1

[²] A library providing a simple virtualization API - a C toolkit to 
interact with the virtualization capabilities of Linux. It includes the 
libvrtd server exporting the virtualization support.

[³]  From [QEMU's new -nic command line option](https://www.qemu.org/2018/05/31/nic-parameter/):   
> The legacy -net option
> 
> QEMU's initial way of configuring the network for the guest was the `-net`
> option.  The emulated NIC hardware can be chosen with the
> `-net nic,model=xyz,...` parameter, and the host back-end with the
> `-net <backend>,...` parameter (e.g. `-net user` for the SLIRP back-end).
> However, the emulated NIC and the host back-end are *not directly connected*.
> They are rather both connected to an emulated **hub** (called "vlan" in older
> versions of QEMU).  Therefore, if you start QEMU with
> `-net nic,model=e1000 -net user -net nic,model=virtio -net tap` for example,
> you get a setup where all the front-ends and back-ends are connected
> together via a hub.   

---

**References:**

[What's the function of `virbr0` and `virbr0-nic`?](https://unix.stackexchange.com/questions/523245/whats-the-function-of-virbr0-and-virbr0-nic)   
(Retrieved on Apr 2, 2022)   

[[libvirt-users] virtual networking - virbr0-nic interface](https://listman.redhat.com/archives/libvirt-users/2012-September/msg00038.html)   
(Retrieved on Apr 2, 2022)   

[What is virtual bridge with -nic in the end of name](https://unix.stackexchange.com/questions/378264/what-is-virtual-bridge-with-nic-in-the-end-of-name/444863#444863)   
(Retrieved on Apr 2, 2022)   

[Bridged networking with qemu on Linux](https://code.lardcave.net/2019/07/20/1/)   
(Retrieved on Apr, 2022)   

[Network bridge - Arch Wiki](https://wiki.archlinux.org/title/Network_bridge)  
(Retrieved on Apr 2, 2022)   

[Bridge - The Linux Foundation Wiki](https://wiki.linuxfoundation.org/networking/bridge)   
(Retrieved on Apr 2, 2022)   

[Networking QEMU Virtual BSD Systems](http://bsdwiki.reedmedia.net/wiki/networking_qemu_virtual_bsd_systems.html)   
(Retrieved on Apr 2, 2022)   

[Configuring QEMU bridge helper after "access denied by acl file" error](https://blog.christophersmart.com/2016/08/31/configuring-qemu-bridge-helper-after-access-denied-by-acl-file-error/)    
(Retrieved on Apr 2, 2022)   

[Configuring Guest Networking - KVM](http://www.linux-kvm.org/page/Networking)   
(Retrieved on Apr 2, 2022)   
> Guest (VM) networking in kvm is the same as in qemu, so it is possible 
> to refer to other documentation about networking in qemu.  This page will 
> try to explain how to configure the most frequent types of networking needed. 

[QEMU's new -nic command line option](https://www.qemu.org/2018/05/31/nic-parameter/)    
(Retrieved on Apr 2, 2022)   

[CentOS 8 add network bridge (br0) with nmcli command](https://www.cyberciti.biz/faq/centos-8-add-network-bridge-br0-with-nmcli-command/)   
(Retrieved on Apr 2, 2022)   

[How to add network bridge with nmcli (NetworkManager) on Linux](https://www.cyberciti.biz/faq/how-to-add-network-bridge-with-nmcli-networkmanager-on-linux/)   
(Retrieved on Apr 2, 2022)   

[Qemu bridge/tap adaper - Red Hat Customer Portal](https://access.redhat.com/discussions/5996181)    
(Retrieved on Apr 2, 2022)   

[Virtual networking in bridged mode](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/configuring-virtual-machine-network-connections_configuring-and-managing-virtualization#virtual-networking-bridged-mode_types-of-virtual-machine-network-connections)    
(Retrieved on Apr 2, 2022)   

[Configuring a network bridge using nmcli commands](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/configuring-a-network-bridge_configuring-and-managing-networking#configuring-a-network-bridge-using-nmcli-commands_configuring-a-network-bridge)   
(Retrieved on Apr 2, 2022)   

[Setting up Qemu with a tap interface](https://gist.github.com/extremecoders-re/e8fd8a67a515fee0c873dcafc81d811c)    
(Retrieved on Apr 2, 2022)   

[[SOLVED] KVM/QEMU - Ethernet will not bridge](https://bbs.archlinux.org/viewtopic.php?id=261207)    
(Retrieved on Apr 2, 2022)   

[Howto do QEMU full virtualization with bridged networking](https://ahelpme.com/linux/howto-do-qemu-full-virtualization-with-bridged-networking/)    
(Retrieved on Apr 2, 2022)   

[Network emulation - QEMU Documentation](https://qemu.readthedocs.io/en/latest/system/devices/net.html)   
(Retrieved on Apr 2, 2022)   

[Setting up TUN/TAP networking for QEMU VM's (and bonus wireguard)](https://stty.io/2019/05/13/qemu-vm-wireguard-vpn-tun-tap-networking/)   
(Retrieved on Apr 2, 2022)   

[Configuring Guest Networking - KVM Documentation](https://www.linux-kvm.org/page/Networking)   
(Retrieved on Apr 2, 2022)   

---

