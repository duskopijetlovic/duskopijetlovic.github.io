---
layout: post
title: "FreeBSD 15 ZFS, RHEL 10, Windows 11 Triple Boot [UEFI GPT]" 
date: 2026-05-30 13:12:33 -0700 
categories: zfs freebsd rhel linux windows boot howto cli terminal shell disk 
---

The three OSs for this configuration: FreeBSD 15, RHEL 10, Windows 11 Professional.

PC: Lenovo ThinkPad E14 Gen 6 laptop AMD model, Type (Machine Type or MT) 21M3 - customized

---

Configure FreeBSD and Windows dual-boot as explained in this post:

[FreeBSD ZFS and Windows 11 Dual Boot [UEFI GPT] [Manual Setup]]({% post_url 2025-02-25-uefi-gpt-zfs-manual-freebsd-win-dual-boot %})

Plug in a bootable USB flash drive with the RHEL 10.1 installer and boot from it.

```
GRUB version 2.12
  Install Red Hat Enterprise Linux 10.1

Langauge
  English

Keyboard
  English (Canada)

Installation Destination
  Corsair MP600 MICRO - nvme1n1 / 822.5 GiB free

Full disk summary and boot loader...
  Selected Disks and Boot Loader
    Corsair MP600 MICRO (Corsair_MP600_MICRO_AA4GB439003RGY_1)

Root Account
  - Enable Root Account
  - Root Pasword: ************
  - [X] Allow root SSH login with password

Time & Date
  Americas/Vancouver timezone  ## ** Autodeteced - I didn't need to change anything

Network & Host Name
  Connected: enp2s0            ## ** Autodeteced - I didn't need to change anything
  Host Name: rhel.home.arpa   ->  Clicked 'Apply'

Software Selection
  Changed from
    Server with GUI
  To
    Workstation
  Additional Software for Selected Environment
    Backup Client
    Headless Management
    Remote Desktop Clients
    Legacy UNIX Compatibility
    Console Internet Tools
    Container Management
    Development Tools
    Graphical Administration Tools
    Scientific Support
    Security Tools
    System Tools

User Creation
  - Full name: dusko
  - User name: dusko
  - [X] Add administrative privileges to this user account (wheel group membership)
  - [X] Require a password for this account

Begin Installation

------------------

Red Hat Enterprise Linux is now succefully installed and ready for you to use!

Go ahead and reboot your system to start using it!

(Use of this product is subject to the license agreement at /usr/share/redhat-license/EULA)

Clicked 'Reboot System'
```

After reboot:

```
GRUB version 2.12

Red Hat Enterprise Linux (6.12.0-124.8.1.el10_1.x86_64) 10.1 (Coughlan)
Red Hat Enterprise Linux (0-rescue-cf00eadc488c4103b67539f044a271ef) 10.1 (Coughlan)
Windows Boot Manager (on /dev/nvme1n1p1)
UEFI Firmware Settings
```

When you press **F12** for **Boot Menu**:

```
ThinkPad

Boot Menu

Red Hat Enterprise Linux 
FreeBSD
Windows Boot Manager
NVMe0: Corsair MP600 MICRO 
NVMe1: Samsung SSD 990 EVO Plus 2TB
PXE BOOT
```

Register for Red Hat Developer Subscription for Individuals at:

[Red Hat Developer Portal](https://developers.redhat.com/)


After registering for Red Hat Developer Subscription, register your system:

```
$ sudo subscription-manager register \
 --username <your_username> --password <your_password> --auto-attach
```

Update all packages - kernel, glibc, OpenSSL, systemd, everything - to the latest versions available in the RHEL repos.

```
$ sudo dnf upgrade
```

Is reboot required?
In this case, it was required:

```
$ sudo needs-restarting -r
Updating Subscription Management repositories.
Core libraries or services have been updated since boot-up:
  * glibc
  * kernel
  * kernel-core
  * linux-firmware
  * microcode_ctl
  * systemd

Reboot is required to fully utilize these updates.
More information: https://access.redhat.com/solutions/27943
```

To list the affected systemd services:

```
$ sudo needs-restarting -s
```

Restart the system.

```
$ sudo shutdown -r now
```

---

## References

* [How do I get the no-cost Red Hat Enterprise Linux Developer Subscription or renew it?](https://access.redhat.com/solutions/4078831)

* [Red Hat Developer Portal](https://developers.redhat.com/)

* [ Getting Started Guide - Get Started with Red Hat Enterprise Linux](https://developers.redhat.com/products/rhel/getting-started)
> Getting Started Guide covers downloading and installing Red Hat Enterprise Linux on a physical system or virtual machine (VM) using your choice of VirtualBox, VMware, Microsoft Hyper-V, or Linux KVM/Libvirt.
> 
> Beginner
>   * Learning paths - Cheat sheets - Articles & blogs - Interactive labs - Red Hat Customer Portal labs - Interactive demos
> 
> Intermediate
>   * Learning paths - Cheat sheets - E-books - Articles & blogs - Interactive labs - Red Hat Customer Portal labs - Interactive demos
> 
> Advanced
>   * Learning paths - Cheat sheets - Articles & blogs - Interactive labs - Red Hat Customer Portal labs

---

