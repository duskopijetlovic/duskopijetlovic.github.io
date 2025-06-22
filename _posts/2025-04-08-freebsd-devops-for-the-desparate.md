---
layout: post
title: "DevOps for the Desparate with FreeBSD"
date: 2025-04-08 20:13:06 -0700 
categories: devops freebsd sysadmin 
---

* Stop bhyve from loading
* On FreeBSD 14.x: Package *vagrant* not working - [Install Vagrant from source](https://developer.hashicorp.com/vagrant/docs/installation/source)
* `vagrant mutate bhyve` not working - use vagrant with *VirtualBox*
* [[Solved] Virtualbox-ose-6.1.5 fails to start any type of guest VM in 14.1 release](https://forums.freebsd.org/threads/virtualbox-ose-6-1-5-fails-to-start-any-type-of-guest-vm-in-14-1-release.95776/)

> added ```vboxdrv_load="YES"``` line to ```/boot/loader.conf```
>> Did you also load the module or rebooted the system?
It's not dynamic, the modules in ```/boot/loader.conf``` are only loaded when the system boots.

> the issue was vmm loading up as well due to the vm_dir line being in /etc/rc.conf
>> Right. [*sysutils/vm-bhyve*](https://www.freshports.org/sysutils/vm-bhyve) automatically loads it if it's enabled.
Unfortunately the two virtualization layers don't play nice with each other.
