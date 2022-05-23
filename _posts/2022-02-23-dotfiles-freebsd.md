---
layout: post
title: "Dotfiles"
date: 2022-02-23 19:14:33 -0700 
categories: dotfiles freebsd
---

```
% cat /etc/rc.conf
zfs_enable="YES"
dumpdev="AUTO"
powerd_enable="YES"
ifconfig_ue0="DHCP"
defaultrouter="192.168.1.254"
kld_list="i915kms"
hostname="fbsd1.home.arpa"
vm_enable="YES"
vm_dir="zfs:zroot/vm"
pf_enable="YES"
gateway_enable="YES"
dnsmasq_enable="YES"
```

```
% cat /etc/rc.conf.wireless
zfs_enable="YES"
dumpdev="AUTO"
powerd_enable="YES"
ifconfig_ue0="DHCP"
defaultrouter="192.168.1.254"
kld_list="i915kms"
hostname="fbsd1.home.arpa"
vm_enable="YES"
vm_dir="zfs:zroot/vm"
pf_enable="YES"
gateway_enable="YES"
dnsmasq_enable="YES"
wlans_iwm0="wlan0"
ifconfig_wlan0="wpa DHCP"
```


