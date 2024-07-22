---
layout: post
title: "Install RHEL 9 (Red Hat Enterprise Linux 9) VM on KVM in Text Mode Over Serial Console [DRAFT]"
date: 2024-01-16 17:09:52 -0700 
categories: howto
---


[TODO:] Add creation of volume as QCOW2 image from an XML template



```
$ ssh dusko@kvmhost1.chem.ubc.ca
```

```
$ sudo virsh pool-list --all
 Name                 State      Autostart
-------------------------------------------
 default              active     yes
 dirpool              inactive   yes
 dwu                  active     yes
 images               active     yes
 iscsiadd02           active     yes
 isos                 inactive   yes
 PoolNappIt1          active     yes
 tmp                  active     yes

$ sudo virsh vol-list --pool iscsiadd02
 Name                 Path
------------------------------------------------------------------------------
 epidote.qcow2        /iscsiadd02/epidote.qcow2
 images               /iscsiadd02/images
 ofc2.qcow2           /iscsiadd02/ofc2.qcow2
 stores.qcow2         /iscsiadd02/stores.qcow2
```

```
$ sudo virsh vol-info epidote.qcow2 --pool iscsiadd02
Name:           epidote.qcow2
Type:           file
Capacity:       360.00 GiB
Allocation:     200.00 KiB

```

```
$ ls -lh /iscsiadd02/epidote.qcow2
-rw-r--r--. 1 root root 198K Jan  8 16:08 /iscsiadd02/epidote.qcow2

$ file /iscsiadd02/epidote.qcow2
/iscsiadd02/epidote.qcow2: QEMU QCOW Image (v2), 386547056640 bytes
```

```
$ qemu-img info /iscsiadd02/epidote.qcow2
image: /iscsiadd02/epidote.qcow2
file format: qcow2
virtual size: 360G (386547056640 bytes)
disk size: 200K
cluster_size: 65536
Format specific information:
    compat: 0.10
```


```
$ sudo virsh vol-dumpxml epidote.qcow2 --pool iscsiadd02
<volume type='file'>
  <name>epidote.qcow2</name>
  <key>/iscsiadd02/epidote.qcow2</key>
  <source>
  </source>
  <capacity unit='bytes'>386547056640</capacity>
  <allocation unit='bytes'>204800</allocation>
  <physical unit='bytes'>202752</physical>
  <target>
    <path>/iscsiadd02/epidote.qcow2</path>
    <format type='qcow2'/>
    <permissions>
      <mode>0644</mode>
      <owner>0</owner>
      <group>0</group>
      <label>system_u:object_r:default_t:s0</label>
    </permissions>
    <timestamps>
      <atime>1705292977.548377238</atime>
      <mtime>1704758917.021316115</mtime>
      <ctime>1705194419.415541519</ctime>
    </timestamps>
  </target>
</volume>
```

```
$ ls -lh /iscsiadd02/epidote.qcow2
-rw-r--r--. 1 root root 198K Jan  8 16:08 /iscsiadd02/epidote.qcow2
```

```
$ ls -Alh /iscsiadd02/
total 2.3T
-rw-r--r--. 1 root root 198K Jan  8 16:08 epidote.qcow2
drwxr-xr-x. 1 root root   46 Jan 13 14:40 images
-rw-r--r--. 1 qemu qemu 2.2T Jan 15 17:39 ofc2.qcow2
-rw-r--r--. 1 qemu qemu 126G Jan 15 17:38 stores.qcow2

$ ls -Alh /iscsiadd02/images/
total 9.0G
-rw-r--r--. 1 qemu qemu 9.0G Jan 13 14:40 rhel-9.2-x86_64-dvd.iso

$ sudo chown qemu:qemu /iscsiadd02/epidote.qcow2
```

```
$ ls -lh /iscsiadd02/epidote.qcow2
-rw-r--r--. 1 qemu qemu 198K Jan  8 16:08 /iscsiadd02/epidote.qcow2
```


```
$ sudo virsh vol-dumpxml epidote.qcow2 --pool iscsiadd02
<volume type='file'>
  <name>epidote.qcow2</name>
  <key>/iscsiadd02/epidote.qcow2</key>
  <source>
  </source>
  <capacity unit='bytes'>386547056640</capacity>
  <allocation unit='bytes'>204800</allocation>
  <physical unit='bytes'>202752</physical>
  <target>
    <path>/iscsiadd02/epidote.qcow2</path>
    <format type='qcow2'/>
    <permissions>
      <mode>0644</mode>
      <owner>107</owner>
      <group>107</group>
      <label>system_u:object_r:default_t:s0</label>
    </permissions>
    <timestamps>
      <atime>1705292977.548377238</atime>
      <mtime>1704758917.021316115</mtime>
      <ctime>1705369306.611531762</ctime>
    </timestamps>
  </target>
</volume>
```

```
$ sudo virsh vol-dumpxml epidote.qcow2 --pool iscsiadd02 | grep mode
      <mode>0644</mode>
```

```
$ sudo virsh vol-dumpxml epidote.qcow2 --pool iscsiadd02 | grep owner 
      <owner>107</owner>

$ sudo virsh vol-dumpxml epidote.qcow2 --pool iscsiadd02 | grep group
      <group>107</group>
```

```
$ grep ^root /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

```
$ grep ^qemu /etc/passwd
qemu:x:107:107:qemu user:/:/sbin/nologin
```

Start serial QEMU RHEL 9.2 guest VM installation.

```
$ sudo \
 virt-install \
 --name epidote \
 --memory 8192 \
 --disk vol=iscsiadd02/epidote.qcow2 \
 --vcpus 4 \
 --os-variant rhel9.2 \
 --graphics none \
 --location /iscsiadd02/images/rhel-9.2-x86_64-dvd.iso \
 --extra-args 'console=ttyS0'
```


NOTE:
For pre-RHEL 9 guest VM, you could use an extra option: 

```
--console pty,target_type=serial \
```

and a different ```--extra-args``` parameter:

```
--extra-args 'console=ttyS0,115200n8 serial'
```


As of time of this writing, when you install RHEL 9 guest VM with ```virt-install(1)``` with ```--console pty,target_type=serial``` and ```--extra-args 'console=ttyS0,115200n8 serial'```, you will see this warning: 

```
'serial' is deprecated and has been removed.
To change the console use 'console=' instead.
```


Continuing with VM guest installation:

```
---- snip ----
---- snip ----

Starting installer, one moment...

anaconda 34.25.2.10-1.el9_2 for Red Hat Enterprise Linux 9.2 started.

 * installation log files are stored in /tmp during the installation
 * shell is available on TTY2
 * if the graphical installation interface fails to start, try again with the
   inst.text bootoption to start text installation
 * when reporting a bug add logs from /tmp as separate text/plain attachments

================================================================================
================================================================================

Text mode provides a limited set of installation options. It does not offer
custom partitioning for full control over the disk layout. Would you like to use
VNC mode instead?

1) Start VNC
2) Use text mode

Please make a selection from the above ['c' to continue, 'q' to quit, 'r' to
refresh]:
```

[TODO]  2024_01_16_1630_kvmhost1_epidote_vm_changed_hostname_to_epidote_chem_ubc_ca.txt


## RHEL subscription-manager -- Client Registration via Red Hat Satellite (RHS)

```
$ hostname
epidote.chem.ubc.ca
```

### Installing katello-ca-consumer


```
$ sudo \
 yum \
 install --nogpgcheck \
 http://satellite6.it.ubc.ca/pub/katello-ca-consumer-latest.noarch.rpm
```

### Registering the Client


Once katello-ca-consumer is installed, proceed with the registration:

```
$ sudo subscription-manager register --org=UBCITServices --activationkey=<ACTIVATION_KEY_NAME>
```

```
$ sudo yum -y remove rhn-setup rhn-client-tools \
 yum-rhn-plugin rhnsd rhn-check rhnlib spacewalk-abrt spacewalk-oscap \
 osad 'rh-*-rhui-client' 'candlepin-cert-consumer-*'
```

In this case, the OS is RHEL 9.
Activation key name for RHEL 9 OS is:  ```RHEL9``` 

Example for registering a Red Hat Enterprise Linux 9 system:

```
$ sudo \
 subscription-manager register \
 --org=UBCITServices \
 --activationkey=RHEL9

The system has been registered with ID: 0404e570-5090-4232-9568-9b99723e6efb
The registered system name is: epidote.chem.ubc.ca
```

```
$ sudo yum -y remove rhn-setup rhn-client-tools \
 yum-rhn-plugin rhnsd rhn-check rhnlib spacewalk-abrt spacewalk-oscap \
 osad 'rh-*-rhui-client' 'candlepin-cert-consumer-*'
```


### Host Tools

Ensure the **katello-host-tools** package is installed from the **Satellite Tools** repository on Satellite Server.
This package helps in reporting back to Satellite and informs of current patch levels and general state of your host.
Note, the repository is Satellite version dependent.
When Satellite is upgraded, the repository name will change to correspond with the new Satellite Server version.

```
$ sudo subscription-manager repos --enable satellite-tools-6.10-for-rhel-8-x86_64-rpms

$ sudo yum -y install katello-host-tools
```

```
$ sudo systemctl stop goferd.service
$ sudo systemctl disable goferd.service
$ sudo yum remove katello-agent
```


List the repo IDs of the currently subscribed repositories: 

```
$ sudo subscription-manager repos --list-enabled | grep ID | awk -F' ' '{ print $3 }'
rhel-9-for-x86_64-appstream-rpms
rhel-9-for-x86_64-baseos-rpms
```

List all installed packages.

```
$ sudo yum list installed | wc -l
947
```

---

From the man page for virsh(1):

```
NOTES
---- snip ----
       Several virsh commands take an optionally scaled integer; if no scale
       is provided, then the default is listed in the command (for historical
       reasons, some commands default to bytes, while other commands default
       to kibibytes).  The following case-insensitive suffixes can be used to
       select a specific scale:
         b, byte  byte      1
         KB       kilobyte  1,000
         k, KiB   kibibyte  1,024
         MB       megabyte  1,000,000
         M, MiB   mebibyte  1,048,576
         GB       gigabyte  1,000,000,000
         G, GiB   gibibyte  1,073,741,824
         TB       terabyte  1,000,000,000,000
         T, TiB   tebibyte  1,099,511,627,776
         PB       petabyte  1,000,000,000,000,000
         P, PiB   pebibyte  1,125,899,906,842,624
         EB       exabyte   1,000,000,000,000,000,000
         E, EiB   exbibyte  1,152,921,504,606,846,976
---- snip ----
```

---

## References

* [https://confluence.it.ubc.ca](https://confluence.it.ubc.ca)
> Welcome to the UBC IT Confluence site.
> Please login with your CWL, if you have not been issued one, please contact your supervisor.
> 
> Once logged in, if you require access to a specific space, [navigate to that space via the Space Directory](https://confluence.it.ubc.ca/spacedirectory/view.action).
> 
> Then, contact the Space Admins (found in the Space Overview section of the Space Tools located on the bottom left) to gain access to the desired space.
> 
> Thank-you, 
> 
> UBC IT

* [UBC IT Confluence - Log in](https://confluence.it.ubc.ca/login.action?os_destination=%2F)


IT Services - Systems [Public] > Services > Patch Management > Red Hat Satellite 6 (RHS6) > RHS6 - How To


    RHS6 - How To - Checking Client Repository Usage
    RHS6 - How To - Client Migration
    RHS6 - How To - Client Registration
    RHS6 - How To - Content Management for Organization Administrator
    RHS6 - How To - Installing the Latest katello-ca-consumer Package
    RHS6 - How To - Verifying Registration Status
---
