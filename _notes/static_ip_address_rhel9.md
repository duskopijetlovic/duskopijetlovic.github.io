---
layout: default
title: "Setting Up Static IP Address With nmcli on RHEL 9"
---

```
$ ifconfig
[ . . . ]
```

```
$ nmcli device
DEVICE  TYPE      STATE                   CONNECTION
ens3    ethernet  connected               ens3
lo      loopback  connected (externally)  lo
```


```
$ sudo nmcli connection modify ens3 ipv4.addresses 1.2.3.4/24
$ sudo nmcli connection modify ens3 ipv4.gateway 1.2.3.254
$ sudo nmcli connection modify ens3 ipv4.method manual
$ sudo nmcli connection modify ens3 ipv4.dns 1.1.1.1,1.0.0.1  
```

Explanation:

```
ipv4.adresses <your machine IP address>
ipv4.gateway <your gateway IP address>
ipv4.method manual/auto  (if DHCP, choose auto)
ipv4.dns <your DNS server IP addresses>
```

Restart Network Manager configuration. 

```
$ sudo nmcli connection down ens3 && sudo nmcli connection up ens3
Connection 'ens3' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/Acti
veConnection/2)
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnect
ion/3)
```

```
$ ifconfig
[ . . . ]
```

```
$ ip address show
[ . . . ]
```

