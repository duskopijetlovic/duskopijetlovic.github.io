---
layout: post
title: "Configure IP Addressing with NetworkManager (nmcli) in RHEL 8/CentOS 8" 
date: 2022-03-27 9:48:33 -0700
categories: rhel centos linux networking howto 
---

OS: RHEL 8   
Shell:  bash   

---


### Static Addressing

For example, create a new connection named 'eno1'.   
Specify a name for the connection profile (con-name), the interface the 
profile should be applied to (ifname), the IP address (ip4) and optionally, 
the gateway (gw4). The IP address must be specified with the network prefix. 
The connection profile name can match the interface name. 
The connection will be activated as soon as it is created.
```
$ sudo nmcli connection add \
con-name eno1 ifname eno1 type ethernet \
ip4 123.12.23.34/24 gw4 123.12.23.254
```

Set up DNS servers. For example, use recursive nameservers by OpenDNS, 
208.67.222.222, 208.67.220.220.

```
$ sudo nmcli connection modify eno1 \ 
ipv4.dns "208.67.222.222,208.67.220.220" 
```

NOTE:  Some other options that you can use for your DNS resolver:
* Cloudflare's public DNS server 1.1.1.1
* Google's DNS servers 4.4.8.8, 4.4.4.4, 8.8.8.8 
* In Canada, [CIRA Canada Shield](https://www.cira.ca/cybersecurity-services/canadian-shield): 
  - Private - DNS resolution only: 149.112.121.10, 149.112.122.10  
  - Protected - Malware and phishing protection: 149.112.121.20, 149.112.122.20
  - Family - Protected + blocking offensive content: 149.112.121.30, 149.112.122.30 

```
$ sudo nmcli connection modify eno1 ipv4.method manual
```

```
$ sudo nmcli connection reload
```

```
$ nmcli connection show
NAME  UUID               TYPE      DEVICE 
eno1  4d928341-........  ethernet  eno1   
[...]
```

Confirm the system is using NetworkManager.

```
$ sudo systemctl restart NetworkManager.service
```

```
$ sudo systemctl status NetworkManager.service
```

```
$ sudo nmcli networking connectivity check
full
```

