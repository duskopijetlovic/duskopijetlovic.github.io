---
layout: post
title: "New Storage Pool and Installing a New VM in Text Mode in KVM - HowTo [WIP]"
date: 2024-06-21 22:30:44 -0700 
categories: kvm qemu virtualization storage disk tutorial howto sysadmin 
---

**[TODO]** Transcribe my log 2024_06_21_1245   
**[TODO]** SELinux

----

*Assumptions:* 
* Your KVM server name: *yourkvmserver.com* 
* New VM name: *appserver1*

----

## Creating XML File Template

Log in to your hypervisor.

```
$ ssh dusko@yourkvmserver.com
```

```
$ sudo virsh list --all
 Id    Name                           State
----------------------------------------------------
 1     mail                           running
 2     www                            running
 3     groups                         running
 4     xenon                          running
 5     neon                           running
 6     webmailx                       running
 -     exceed                         shut off
 -     fbsdtest1                      shut off
 -     mailxtest                      shut off

$ sudo virsh pool-list --all
 Name                 State      Autostart
-------------------------------------------
 default              active     yes
 tmp                  active     yes

$ sudo virsh pool-info default
Name:           default
UUID:           a721f571-...
State:          running
Persistent:     yes
Autostart:      yes
Capacity:       4.55 TiB
Allocation:     1.68 TiB
Available:      2.87 TiB

$ sudo virsh pool-info tmp
Name:           tmp
UUID:           5a272ff5-...
State:          running
Persistent:     yes
Autostart:      yes
Capacity:       113.98 GiB
Allocation:     30.51 GiB
Available:      83.47 GiB
```

```
$ sudo virsh vol-list --pool default
 Name                 Path
------------------------------------------------------------------------------
 exceed.qcow2         /iscsisan/images/exceed.qcow2
 fbsdtest1.qcow2      /iscsisan/images/fbsdtest1.qcow2
 groups.qcow2         /iscsisan/images/groups.qcow2
 mail.qcow2           /iscsisan/images/mail.qcow2
 mailxtest.qcow2      /iscsisan/images/mailxtest.qcow2
 matlab.qcow2         /iscsisan/images/matlab.qcow2
 neon.qcow2           /iscsisan/images/neon.qcow2
 webmailx.qcow2       /iscsisan/images/webmailx.qcow2
 www.qcow2            /iscsisan/images/www.qcow2
 xenon.qcow2          /iscsisan/images/xenon.qcow2
```

```
$ ls -Alh /iscsisan/images/
total 724G
-rw-------. 1 qemu qemu  38G Jun 15 08:01 exceed.qcow2
-rw-r--r--. 1 root root 2.0G Dec  6  2019 fbsdtest1.qcow2
-rw-r--r--. 1 qemu qemu 123G Jun 21 12:48 groups.qcow2
-rw-r--r--. 1 qemu qemu  92G Jun 21 12:49 mail.qcow2
-rw-r--r--. 1 qemu qemu 117G Apr 20  2021 mailxtest.qcow2
-rw-------. 1 root root  25G Jan 28  2020 matlab.qcow2
-rw-r--r--. 1 qemu qemu  79G Jun 21 12:49 neon.qcow2
-rw-------. 1 qemu qemu  46G Jun 21 12:49 webmailx.qcow2
-rw-r--r--. 1 qemu qemu 123G Jun 21 12:49 www.qcow2
-rw-r--r--. 1 qemu qemu  82G Jun 21 12:31 xenon.qcow2

$ qemu-img info /iscsisan/images/groups.qcow2
image: /iscsisan/images/groups.qcow2
file format: qcow2
virtual size: 123G (131941395456 bytes)
disk size: 123G
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: true

$ sudo virsh vol-info /iscsisan/images/groups.qcow2 --pool default
Name:           groups.qcow2
Type:           file
Capacity:       122.88 GiB
Allocation:     122.90 GiB
```

```
$ sudo virsh vol-dumpxml /iscsisan/images/groups.qcow2 --pool default
<volume type='file'>
  <name>groups.qcow2</name>
  <key>/iscsisan/images/groups.qcow2</key>
  <source>
  </source>
  <capacity unit='bytes'>131941395456</capacity>
  <allocation unit='bytes'>131961782272</allocation>
  <physical unit='bytes'>131961782272</physical>
  <target>
    <path>/iscsisan/images/groups.qcow2</path>
    <format type='qcow2'/>
    <permissions>
      <mode>0644</mode>
      <owner>107</owner>
      <group>107</group>
      <label>system_u:object_r:svirt_image_t:s0:c65,c100</label>
    </permissions>
    <timestamps>
      <atime>1718999550.568884804</atime>
      <mtime>1718999545.766868089</mtime>
      <ctime>1718999545.766868089</ctime>
    </timestamps>
    <compat>1.1</compat>
    <features>
      <lazy_refcounts/>
    </features>
  </target>
</volume>
```

```
$ grep 107 /etc/passwd
qemu:x:107:107:qemu user:/:/sbin/nologin

$ grep 107 /etc/group
qemu:x:107:
```

```
$ vi ~/vol-template-for-appserver1.xml
```

```
$ cat ~/vol-template-for-appserver1.xml
<volume type='file'>
  <name>appserver1.qcow2</name>
  <key>/iscsisan/images/appserver1.qcow2</key>
  <source>
  </source>
  <capacity unit='G'>240</capacity>
  <target>
    <path>/iscsisan/images/appserver1.qcow2</path>
    <format type='qcow2'/>
    <permissions>
      <mode>0644</mode>
      <owner>107</owner>
      <group>107</group>
      <label>virt_image_t</label>
    </permissions>
  </target>
</volume>
```

```
$ sudo \
 virsh vol-create \
 --pool default \
 ~/vol-template-for-appserver1.xml
```

Output:

```
Vol appserver1.qcow2 created from /home/dusko/vol-template-for-appserver1.xml
```


```
$ sudo virsh vol-list --pool default
 Name                 Path
------------------------------------------------------------------------------
 appserver1.qcow2     /iscsisan/images/appserver1.qcow2
 exceed.qcow2         /iscsisan/images/exceed.qcow2
 fbsdtest1.qcow2      /iscsisan/images/fbsdtest1.qcow2
 groups.qcow2         /iscsisan/images/groups.qcow2
 mail.qcow2           /iscsisan/images/mail.qcow2
 mailxtest.qcow2      /iscsisan/images/mailxtest.qcow2
 matlab.qcow2         /iscsisan/images/matlab.qcow2
 neon.qcow2           /iscsisan/images/neon.qcow2
 webmailx.qcow2       /iscsisan/images/webmailx.qcow2
 www.qcow2            /iscsisan/images/www.qcow2
 xenon.qcow2          /iscsisan/images/xenon.qcow2

$ ls -lh /iscsisan/images/appserver1.qcow2
-rw-r--r--. 1 qemu qemu 196K Jun 21 13:44 /iscsisan/images/appserver1.qcow2

$ date
Fri Jun 21 13:44:30 PDT 2024

$ file /iscsisan/images/appserver1.qcow2
/iscsisan/images/appserver1.qcow2: QEMU QCOW Image (v2), 257698037760 bytes

$ qemu-img info /iscsisan/images/appserver1.qcow2
image: /iscsisan/images/appserver1.qcow2
file format: qcow2
virtual size: 240G (257698037760 bytes)
disk size: 196K
cluster_size: 65536
Format specific information:
    compat: 0.10

$ sudo virsh vol-info /iscsisan/images/appserver1.qcow2
Name:           appserver1.qcow2
Type:           file
Capacity:       240.00 GiB
Allocation:     196.00 KiB
```

```
$ sudo virsh vol-dumpxml /iscsisan/images/appserver1.qcow2 --pool default
<volume type='file'>
  <name>appserver1.qcow2</name>
  <key>/iscsisan/images/appserver1.qcow2</key>
  <source>
  </source>
  <capacity unit='bytes'>257698037760</capacity>
  <allocation unit='bytes'>200704</allocation>
  <physical unit='bytes'>200704</physical>
  <target>
    <path>/iscsisan/images/appserver1.qcow2</path>
    <format type='qcow2'/>
    <permissions>
      <mode>0644</mode>
      <owner>107</owner>
      <group>107</group>
      <label>system_u:object_r:unlabeled_t:s0</label>
    </permissions>
    <timestamps>
      <atime>1719002657.236714680</atime>
      <mtime>1719002657.232714666</mtime>
      <ctime>1719002657.235714676</ctime>
    </timestamps>
  </target>
</volume>
```

```
$ ls -Alh /iscsisan/
total 123G
drwxr-xr-x. 1 root  root    16 Sep  6  2020 abacuswebmo
drwxr-xr-x. 1 qemu  qemu   270 Jun 21 13:44 images
drwxrwxr-x. 1 dusko dusko  870 Dec  3  2019 neon
-rw-r--r--. 1 qemu  qemu  123G Jul 13  2019 www.qcow2
-rw-r--r--. 1 root  root  197K Jul 13  2019 www.qcow2.original.bak

$ ls -Alh /iscsisan/images/
total 724G
-rw-r--r--. 1 qemu qemu 196K Jun 21 13:44 appserver1.qcow2
-rw-------. 1 qemu qemu  38G Jun 15 08:01 exceed.qcow2
-rw-r--r--. 1 root root 2.0G Dec  6  2019 fbsdtest1.qcow2
-rw-r--r--. 1 qemu qemu 123G Jun 21 13:54 groups.qcow2
-rw-r--r--. 1 qemu qemu  92G Jun 21 13:54 mail.qcow2
-rw-r--r--. 1 qemu qemu 117G Apr 20  2021 mailxtest.qcow2
-rw-------. 1 root root  25G Jan 28  2020 matlab.qcow2
-rw-r--r--. 1 qemu qemu  79G Jun 21 13:54 neon.qcow2
-rw-------. 1 qemu qemu  46G Jun 21 13:54 webmailx.qcow2
-rw-r--r--. 1 qemu qemu 123G Jun 21 13:54 www.qcow2
-rw-r--r--. 1 qemu qemu  82G Jun 21 13:54 xenon.qcow2
```


Previously I copied RHEL 9.2 ISO DVD image to `/iscsisan/ISO/rhel-9.2-x86_64-dvd.iso`.


NOTE: For the following `virt-install` command: Instead of probably more common `--disk=<disk_size>`, in this case you will use `--disk vol=poolname/volname` option for specifying storage volume.

```
$ sudo \
 virt-install \
 --name appserver1 \
 --memory 8192 \
 --vcpus 4 \
 --disk vol=default/appserver1.qcow2 \
 --os-variant rhel9.2 \
 --graphics none \
 --location /iscsisan/ISO/rhel-9.2-x86_64-dvd.iso \
 --extra-args='console=ttyS0'

ERROR    Error validating install location: Distro 'rhel9.2' does not exist in our dictionary
```


For `virt-install`, it's not critical to use an *os-variant* config distro file.

The distro config file is used to lookup the optimized drivers to use primarily for disk and network.
You could just use the 'rhel8' distro type when installing 'rhel-9.2' and `virt-install` would work fine.
If you were to do that, it could mean that some defaults may be configured with suboptimal values; for example, if there have been changes in defaults between *rhel8* and *rhel9*.

The `virt-install` gets its OS information from the `osinfo-db`.

If your OS does not have a recent version of `osinfo-db`, you can manually download it from [libosinfo: The Operating System information database - Download page](https://libosinfo.org/download.html), [libosinfo: The Operating System information database - Download site](https://releases.pagure.org/libosinfo/), and import it.

```
$ wget https://releases.pagure.org/libosinfo/osinfo-db-20231215.tar.xz 
```

You could use `tar(1)` to check for `rhel9` configurations.

```
$ tar xf osinfo-db-20231215.tar.xz

$ ls osinfo-db-20231215/os/redhat.com/rhel-9*
osinfo-db-20231215/os/redhat.com/rhel-9-unknown.xml
osinfo-db-20231215/os/redhat.com/rhel-9.0.xml
osinfo-db-20231215/os/redhat.com/rhel-9.1.xml
osinfo-db-20231215/os/redhat.com/rhel-9.2.xml
osinfo-db-20231215/os/redhat.com/rhel-9.3.xml
osinfo-db-20231215/os/redhat.com/rhel-9.4.xml
```

After that, you could import it into your system by using the `osinfo-db-import` command: `osinfo-db-import -v osinfo-db-20231215.tar.xz`. The `-v` options displays all imported OSes. 

Since in this case you have the Red Hat Subscription Management (RHSM) (previously Red Hat Customer Portal or RedHat Network Systems Management (RHN) or just RHEL Subscription), download and install the RPM package for `osinfo-db` from Red Hat. 

However, I had problems with `subscription-manager` so I first had to fix that.
For how it was done, refer to the section below, *Troubleshooting RHEL Repos and subscription-manager*.

After that, see *Installing osinfo-db Package Manually* section further down.


## Troubleshooting RHEL Repos and subscription-manager

```
$ cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.6 (Maipo)
```

```
$ sudo yum list installed | wc -l
There was an error communicating with RHN.
Red Hat Satellite or RHN Classic support will be disabled.
Error communicating with server. The message was:
Unable to connect to the host and port specified
880
```

```
$ sudo yum list installed | grep osinfo
There was an error communicating with RHN.
Red Hat Satellite or RHN Classic support will be disabled.
Error communicating with server. The message was:
Unable to connect to the host and port specified
libosinfo.x86_64               1.1.0-3.el7         @rhel-x86_64-server-7
osinfo-db.noarch               20190319-2.el7      @rhel-x86_64-server-7
osinfo-db-tools.x86_64         1.1.0-1.el7         @rhel-x86_64-server-7

$ sudo yum update osinfo-db
Loaded plugins: langpacks, product-id, rhnplugin, search-disabled-repos,
              : subscription-manager
There was an error communicating with RHN.
Red Hat Satellite or RHN Classic support will be disabled.
Error communicating with server. The message was:
Unable to connect to the host and port specified
There are no enabled repos.
 Run "yum repolist all" to see the repos you have.
 To enable Red Hat Subscription Management repositories:
     subscription-manager repos --enable <repo>
 To enable custom repositories:
     yum-config-manager --enable <repo>
```

```
$ sudo yum list installed | grep -i katello
There was an error communicating with RHN.
Red Hat Satellite or RHN Classic support will be disabled.
Error communicating with server. The message was:
Unable to connect to the host and port specified

$ rpm -qa | wc -l
847

$ rpm -qa | grep -i katello
```

Some references pointing to issues with `subscription-manager` are also logged in `/var/log/messages`.
Here's some excerpts from `/var/log/messages`:

```
Jun 21 15:55:36 appserver1 systemd[1]: Starting dnf makecache...
Jun 21 15:55:37 appserver1 dnf[1738]: Updating Subscription Management repositories.
Jun 21 15:55:37 appserver1 dnf[1738]: Unable to read consumer identity
Jun 21 15:55:37 appserver1 dnf[1738]: This system is not registered with an entitlement server. You can use subscription-manager to register.
Jun 21 15:55:37 appserver1 dnf[1738]: Failed determining last makecache time.
Jun 21 15:55:37 appserver1 dnf[1738]: There are no enabled repositories in "/etc/yum.repos.d", "/etc/yum/repos.d", "/etc/distro.repos.d".
Jun 21 15:55:37 appserver1 systemd[1]: dnf-makecache.service: Deactivated successfully.
Jun 21 15:55:37 appserver1 systemd[1]: Finished dnf makecache.
Jun 21 16:25:36 appserver1 systemd[1]:
```

This `/var/log/messages` excerpt is from a different server, which was previously registered but in the meantime started experiencing problems with RHEL subscription:

```
... subscription-manager: Added subscription for 'Content Access' contract 'None'
... subscription-manager: Added subscription for product ' Content Access'
```

```
$ sudo \
 yum install --nogpgcheck \
 http://your.satelliteserver.com/pub/katello-ca-consumer-latest.noarch.rpm
```

```
$ sudo \
 subscription-manager register \
 --org=NameProvidedByYourOrg \
 --activationkey=YourActivationKey
```

Output:

```
WARNING

This system has already been registered with Red Hat using RHN Classic.

Your system is being registered again using Red Hat Subscription Management.
Red Hat recommends that customers only register once.

To learn how to unregister from either service please consult this
Knowledge Base Article:  https://access.redhat.com/kb/docs/DOC-45563

The system has been registered with ID: 9afd7f11-...
The registered system name is: kvmname2.yourdomain.com
Installed Product Current Status:
Product Name: Red Hat Enterprise Linux Server
Status:       Not Subscribed

Unable to find available subscriptions for all your installed products.
```

```
$ sudo subscription-manager identity
server type: RHN Classic and Red Hat Subscription Management
system identity: 9afd7f11-...
name: kvmname2.yourdomain.com
org name: Your Org Name
org ID: YourOrgName
environment name: Library/RHEL-7
```

```
$ sudo subscription-manager repos --list
+----------------------------------------------------------+
    Available Repositories in /etc/yum.repos.d/redhat.repo
+----------------------------------------------------------+
Repo ID:   jws-5-for-rhel-7-server-rpms
Repo Name: JBoss Web Server 5 (RHEL 7 Server) (RPMs)
Repo URL:  https://your.satelliteserver.com/pulp/content/OrgName/Library/RHEL-
           7/content/dist/rhel/server/7/7Server/$basearch/jws/5/os
Enabled:   0
. . . 

[ skipped 80 lines ]
. . . 

Repo ID:   rhel-7-server-satellite-client-6-rpms
Repo Name: Red Hat Satellite Client 6 (for RHEL 7 Server) (RPMs)
Repo URL:  https://your.satelliteserver.com/pulp/content/OrgName/Library/RHEL-
           7/content/dist/rhel/server/7/7Server/$basearch/sat-client/6/os
Enabled:   1

Repo ID:   rhel-7-server-satellite-capsule-6.6-rpms
Repo Name: Red Hat Satellite Capsule 6.6 (for RHEL 7 Server) (RPMs)
Repo URL:  https://your.satelliteserver.com/pulp/content/OrgName/Library/RHEL-
           7/content/dist/rhel/server/7/7Server/$basearch/sat-capsule/6.6/os
Enabled:   0

Repo ID:   rhel-7-server-rpms
Repo Name: Red Hat Enterprise Linux 7 Server (RPMs)
Repo URL:  https://your.satelliteserver.com/pulp/content/OrgName/Library/RHEL-
           7/content/dist/rhel/server/7/$releasever/$basearch/os
Enabled:   1
```

```
$ sudo subscription-manager identity
server type: RHN Classic and Red Hat Subscription Management
system identity: 9afd7f11-...
name: kvmname2.yourdomain.com
org name: Your Org Name
org ID: YourOrgName
environment name: Library/RHEL-7
```

```
$ sudo subscription-manager status
+-------------------------------------------+
   System Status Details
+-------------------------------------------+
Overall Status: Unknown
Content Access Mode is set to Organization/Environment Access. This host has access to content, regar
dless of subscription status.
```

```
$ sudo subscription-manager list
+-------------------------------------------+
    Installed Product Status
+-------------------------------------------+
Product Name:   Red Hat Enterprise Linux Server
Product ID:     69
Version:        7.9
Arch:           x86_64
Status:         Not Subscribed
Status Details:
Starts:
Ends:
```

```
$ sudo subscription-manager list --available
+-------------------------------------------+
    Available Subscriptions
+-------------------------------------------+
Subscription Name:   Red Hat Enterprise Linux Academic Site Subscription with
                     Satellite, Standard (Server, Desktop, Workstation, POWER,
                     HPC, Per FTE)
Provides:            Red Hat Beta
                     Red Hat Enterprise Linux for Power, big endian - Extended
                     Update Support
                     Red Hat Enterprise Linux for x86_64
. . . 
[ skipped 85 lines ]
. . . 
SKU:                 RH01157
Contract:            1.......
Pool ID:             0ee7b......
Provides Management: Yes
Available:           5000
Suggested:           1
Service Level:       Standard
Service Type:        L1-L3
Subscription Type:   Standard
Starts:              04/30/2024
Ends:                05/02/2025
System Type:         Physical

Subscription Name:   Red Hat Ansible Automation Platform (Academic Edition),
                     Standard (100 Managed Nodes)
Provides:            Red Hat Ansible Automation Platform
                     Red Hat Ansible Engine
                     Red Hat Single Sign-On
                     JBoss Enterprise Application Platform
                        . . . 
                  [ cut 12 lines ]
                        . . . 

Subscription Name:   Red Hat Enterprise Linux Academic Extended Life Cycle
                     Support (Unlimited Guests)
Provides:            Red Hat Enterprise Linux Server - Extended Life Cycle
                     Support
                        . . . 
                  [ cut 12 lines ]
                        . . . 

Subscription Name:   Red Hat JBoss Enterprise Application Platform ELS Program,
                     64-Core Standard
Provides:            Red Hat JBoss Data Grid
                     JBoss Enterprise Application Platform - ELS
                     Red Hat AMQ Interconnect
                     OpenJDK Java (for Middleware)
                        . . . 
                  [ cut 12 lines ]
                        . . . 

Subscription Name:   Red Hat JBoss Enterprise Application Platform, 64-Core
                     Standard
Provides:            Red Hat Beta
                     Red Hat Software Collections (for RHEL Server)
                     Red Hat Openshift Serverless
                     Red Hat Enterprise Linux for x86_64
                        . . . 
                     Red Hat CoreOS
                     Red Hat Ansible Engine
                        . . . 
                     Oracle Java (for RHEL Server)
                        . . . 
                     Red Hat Enterprise Linux Server
                        . . . 

Subscription Name:   Red Hat Directory Server (Replica)
Provides:            Red Hat Directory Server
                        . . . 

Subscription Name:   Red Hat Satellite Infrastructure Subscription
Provides:            Red Hat Beta
                     Red Hat Software Collections (for RHEL Server)
                     Red Hat Enterprise Linux for x86_64
                     Red Hat CodeReady Linux Builder for x86_64
                     Red Hat Ansible Engine
                     Red Hat Enterprise Linux Load Balancer (for RHEL Server)
                     Red Hat Discovery
                     Red Hat Satellite 5 Managed DB
                     Red Hat Satellite Capsule
                     Red Hat Enterprise Linux Server
                        . . . 

Subscription Name:   Red Hat Directory Server
Provides:            Red Hat Directory Server
                        . . . 
                  [ cut 12 lines ]
                        . . . 
```

```
$ sudo yum repolist all
Loaded plugins: langpacks, product-id, rhnplugin, search-disabled-repos,
              : subscription-manager
There was an error communicating with RHN.
Red Hat Satellite or RHN Classic support will be disabled.
Error communicating with server. The message was:
Unable to connect to the host and port specified
repo id                                           repo name      status
jws-3-for-rhel-7-server-rpms/7Server/x86_64       JBoss Web Serv disabled
jws-5-for-rhel-7-server-rpms/x86_64               JBoss Web Serv disabled
rhel-7-server-ansible-2-rpms/x86_64               Red Hat Ansibl disabled
rhel-7-server-ansible-2.8-rpms/x86_64             Red Hat Ansibl disabled
rhel-7-server-devtools-rpms/x86_64                Red Hat Develo disabled
rhel-7-server-dotnet-rpms/7Server/x86_64          dotNET on RHEL disabled
rhel-7-server-extras-rpms/x86_64                  Red Hat Enterp disabled
rhel-7-server-optional-rpms/7Server/x86_64        Red Hat Enterp disabled
rhel-7-server-rh-common-rpms/7Server/x86_64       Red Hat Enterp disabled
rhel-7-server-rhn-tools-rpms/7Server/x86_64       RHN Tools for  disabled
!rhel-7-server-rpms/7Server/x86_64                Red Hat Enterp enabled: 34,473
rhel-7-server-satellite-capsule-6.6-rpms/x86_64   Red Hat Satell disabled
!rhel-7-server-satellite-client-6-rpms/x86_64     Red Hat Satell enabled:     37
rhel-7-server-satellite-maintenance-6-rpms/x86_64 Red Hat Satell disabled
rhel-7-server-supplementary-rpms/7Server/x86_64   Red Hat Enterp disabled
rhel-server-rhscl-7-rpms/7Server/x86_64           Red Hat Softwa disabled
repolist: 34,510
```

```
$ sudo subscription-manager list --consumed
+-------------------------------------------+
   Consumed Subscriptions
+-------------------------------------------+
Subscription Name:   Red Hat Enterprise Linux Academic Site Subscription with
                     Satellite, Standard (Server, Desktop, Workstation, POWER,
                     HPC, Per FTE)
Provides:            Red Hat Enterprise Linux Atomic Host
                        . . .
                     Red Hat Enterprise Linux for x86_64
                        . . .
                     Red Hat Ansible Engine
                     Red Hat Enterprise Linux Desktop
                     Red Hat Enterprise Linux Server
                        . . .
                        . . .
SKU:                 RH01157
Contract:            1.......
Account:             6.....
Serial:              61........................
Pool ID:             0ee7b......
Provides Management: Yes
Active:              True
Quantity Used:       1
Service Level:       Standard
Service Type:        L1-L3
Status Details:      Subscription is current
Subscription Type:   Standard
Starts:              04/30/2024
Ends:                05/02/2025
System Type:         Physical
```


```
$ sudo yum -C repolist
Loaded plugins: langpacks, product-id, rhnplugin, search-disabled-repos,
              : subscription-manager
repo id                                       repo name                   status
!jws-3-x86_64-server-7-rpm                    Red Hat JBoss Web Server (v    476
!rhel-7-server-rpms/7Server/x86_64            Red Hat Enterprise Linux 7  34,473
!rhel-7-server-satellite-client-6-rpms/x86_64 Red Hat Satellite Client 6      37
!rhel-x86_64-server-7                         Red Hat Enterprise Linux Se 29,414
!rhel-x86_64-server-7-rhscl-1                 Red Hat Software Collection 12,735
!rhel-x86_64-server-extras-7                  RHEL Server Extras (v. 7 fo  1,303
!rhel-x86_64-server-optional-7                RHEL Server Optional (v. 7  21,413
!rhel-x86_64-server-supplementary-7           RHEL Server Supplementary (    376
!rhn-tools-rhel-x86_64-server-7               RHN Tools for RHEL Server (    139
repolist: 100,366
```

```
$ sudo subscription-manager config
[server]
   hostname = your.satelliteserver.com
   insecure = [0]
   no_proxy = []
   port = [443]
   prefix = /rhsm
   proxy_hostname = []
   proxy_password = []
   proxy_port = []
   proxy_user = []
   server_timeout = [180]
   ssl_verify_depth = [3]

[rhsm]
   auto_enable_yum_plugins = [1]
   baseurl = https://your.satelliteserver.com/pulp/content/
   ca_cert_dir = [/etc/rhsm/ca/]
   consumercertdir = [/etc/pki/consumer]
   entitlementcertdir = [/etc/pki/entitlement]
   full_refresh_on_yum = 1
   inotify = [1]
   manage_repos = [1]
   pluginconfdir = [/etc/rhsm/pluginconf.d]
   plugindir = [/usr/share/rhsm-plugins]
   productcertdir = [/etc/pki/product]
   repo_ca_cert = /etc/rhsm/ca/katello-server-ca.pem
   repomd_gpg_url = []
   report_package_profile = [1]

[rhsmcertd]
   autoattachinterval = [1440]
   certcheckinterval = [240]
   splay = [1]

[logging]
   default_log_level = [INFO]

[] - Default value in use
```

```
$ sudo yum update osinfo-db
. . . 

Updated:
  osinfo-db.noarch 0:20200529-1.el7

Complete!
```


The `osinfo-query os` command gives you a list of supported operating system variants.

```
$ osinfo-query os | wc -l
662

$ osinfo-query os | grep rhel | wc -l
73

$ osinfo-query os | grep rhel9 | wc -l
0
```

```
$ sudo \
 yum -y remove rhn-setup rhn-client-tools yum-rhn-plugin \
 rhnsd rhn-check rhnlib spacewalk-abrt spacewalk-oscap \
 osad 'rh-*-rhui-client' 'candlepin-cert-consumer-*'
```

```
$ sudo yum list installed | grep -i katello
katello-ca-consumer-your.satelliteserver.com.noarch

$ sudo subscription-manager remove --all
1 local certificate has been deleted.
1 subscription removed at the server.

$ sudo subscription-manager unregister
Unregistering from: your.satelliteserver.com:443/rhsm
System has been unregistered.

$ sudo subscription-manager clean
All local data removed
```

```
$ sudo \
 yum install --nogpgcheck \
 http://your.satelliteserver.com/pub/katello-ca-consumer-latest.noarch.rpm
```

```
$ sudo subscription-manager register --org=NameProvidedByYourOrg --activationkey=YourActivationKey
```

Output:

```
The system has been registered with ID: 8f326fad-...
The registered system name is: kvmname2.yourdomain.com

Installed Product Current Status:
Product Name: Red Hat Enterprise Linux Server
Status:       Not Subscribed

Unable to find available subscriptions for all your installed products.
```

```
$ sudo subscription-manager attach --auto
```


```
$ sudo yum clean all
Loaded plugins: langpacks, product-id, search-disabled-repos, subscription-
              : manager
Cleaning repos: rhel-7-server-rpms rhel-7-server-satellite-client-6-rpms
Other repos take up 945 M of disk space (use --verbose for details)
```

```
$ du -chs /var/cache/yum/
945M    /var/cache/yum/
945M    total

$ sudo du -chs /var/cache/yum/
945M    /var/cache/yum/
945M    total

$ sudo rm -rf /var/cache/yum/*

$ sudo du -chs /var/cache/yum/
0       /var/cache/yum/
0       total
```

``` 
$ sudo subscription-manager unregister
Unregistering from: your.satelliteserver.com:443/rhsm

System has been unregistered.

$ sudo subscription-manager clean
All local data removed
``` 

```
$ sudo yum remove 'katello-ca-consumer*'
```

```
$ sudo \
 yum install --nogpgcheck \
 http://your.satelliteserver.com/pub/katello-ca-consumer-latest.noarch.rpm
```

```
$ sudo subscription-manager register --org=NameProvidedByYourOrg --activationkey=YourActivationKey
```

Output:

```
The system has been registered with ID: a4bba9cb-...
The registered system name is: kvmname2.yourdomain.com
Installed Product Current Status:
Product Name: Red Hat Enterprise Linux Server
Status:       Not Subscribed

Unable to find available subscriptions for all your installed products.
```

```
$ sudo yum -y remove rhn-setup rhn-client-tools yum-rhn-plugin rhnsd \
 rhn-check rhnlib spacewalk-abrt spacewalk-oscap osad 'rh-*-rhui-client' \
 'candlepin-cert-consumer-*'
```

```
$ sudo subscription-manager repos --list
. . . 
Repo ID:   rhel-7-server-satellite-client-6-rpms
Repo Name: Red Hat Satellite Client 6 (for RHEL 7 Server) (RPMs)

Repo URL:  https://your.satelliteserver.com/pulp/content/OrgName/Library/RHEL-
           7/content/dist/rhel/server/7/7Server/$basearch/sat-client/6/os
Enabled:   1

Repo ID:   rhel-7-server-satellite-capsule-6.6-rpms
Repo Name: Red Hat Satellite Capsule 6.6 (for RHEL 7 Server) (RPMs)
Repo URL:  https://your.satelliteserver.com/pulp/content/OrgName/Library/RHEL-
           7/content/dist/rhel/server/7/7Server/$basearch/sat-capsule/6.6/os
Enabled:   0

Repo ID:   rhel-7-server-rpms
Repo Name: Red Hat Enterprise Linux 7 Server (RPMs)
Repo URL:  https://your.satelliteserver.com/pulp/content/OrgName/Library/RHEL-
           7/content/dist/rhel/server/7/$releasever/$basearch/os
Enabled:   1
. . . 
```


```
$ sudo yum repolist all
Loaded plugins: langpacks, product-id, search-disabled-repos, subscription-
              : manager
This system is registered with an entitlement server, but is not receiving updates. You can use subscription-manager to assign subscriptions.

repo id                                           repo name      status
jws-3-for-rhel-7-server-rpms/7Server/x86_64       JBoss Web Serv disabled
jws-5-for-rhel-7-server-rpms/x86_64               JBoss Web Serv disabled
rhel-7-server-ansible-2-rpms/x86_64               Red Hat Ansibl disabled
rhel-7-server-ansible-2.8-rpms/x86_64             Red Hat Ansibl disabled
rhel-7-server-devtools-rpms/x86_64                Red Hat Develo disabled
rhel-7-server-dotnet-rpms/7Server/x86_64          dotNET on RHEL disabled
rhel-7-server-extras-rpms/x86_64                  Red Hat Enterp disabled
rhel-7-server-optional-rpms/7Server/x86_64        Red Hat Enterp disabled
rhel-7-server-rh-common-rpms/7Server/x86_64       Red Hat Enterp disabled
rhel-7-server-rhn-tools-rpms/7Server/x86_64       RHN Tools for  disabled
!rhel-7-server-rpms/7Server/x86_64                Red Hat Enterp enabled: 34,473
rhel-7-server-satellite-capsule-6.6-rpms/x86_64   Red Hat Satell disabled
!rhel-7-server-satellite-client-6-rpms/x86_64     Red Hat Satell enabled:     37
rhel-7-server-satellite-maintenance-6-rpms/x86_64 Red Hat Satell disabled
rhel-7-server-supplementary-rpms/7Server/x86_64   Red Hat Enterp disabled
rhel-server-rhscl-7-rpms/7Server/x86_64           Red Hat Softwa disabled
repolist: 34,510
```

```
$ sudo subscription-manager repos --enable rhel-7-server-extras-rpms
Repository 'rhel-7-server-extras-rpms' is enabled for this system.

$ sudo subscription-manager repos --enable rhel-7-server-optional-rpms
Repository 'rhel-7-server-optional-rpms' is enabled for this system.

$ sudo subscription-manager repos --enable rhel-7-server-rh-common-rpms
Repository 'rhel-7-server-rh-common-rpms' is enabled for this system.

$ sudo subscription-manager repos --enable rhel-7-server-rhn-tools-rpms
Repository 'rhel-7-server-rhn-tools-rpms' is enabled for this system.

$ sudo subscription-manager repos --enable rhel-7-server-satellite-capsule-6.6-rpms
Repository 'rhel-7-server-satellite-capsule-6.6-rpms' is enabled for this system.

$ sudo subscription-manager repos --enable rhel-7-server-satellite-maintenance-6-rpms
Repository 'rhel-7-server-satellite-maintenance-6-rpms' is enabled for this system.

$ sudo subscription-manager repos --enable rhel-7-server-supplementary-rpms
Repository 'rhel-7-server-supplementary-rpms' is enabled for this system.

$ sudo subscription-manager repos --enable rhel-server-rhscl-7-rpms
Repository 'rhel-server-rhscl-7-rpms' is enabled for this system.
```

```
$ sudo yum repolist all
Loaded plugins: langpacks, product-id, search-disabled-repos, subscription-
              : manager
This system is registered with an entitlement server, but is not receiving updates. You can use subsc
ription-manager to assign subscriptions.
rhel-7-server-extras-rpms                                | 3.4 kB     00:00
rhel-7-server-optional-rpms                              | 3.2 kB     00:00
rhel-7-server-rh-common-rpms                             | 3.8 kB     00:00
rhel-7-server-rhn-tools-rpms                             | 3.8 kB     00:00
rhel-7-server-rpms                                       | 3.5 kB     00:00
rhel-7-server-satellite-capsule-6.6-rpms                 | 4.0 kB     00:00
rhel-7-server-satellite-client-6-rpms                    | 3.8 kB     00:00
rhel-7-server-satellite-maintenance-6-rpms               | 3.8 kB     00:00
rhel-7-server-supplementary-rpms                         | 3.4 kB     00:00
rhel-server-rhscl-7-rpms                                 | 3.5 kB     00:00
(1/3): rhel-server-rhscl-7-rpms/7Server/x86_64/group       |  124 B   00:00
(2/3): rhel-server-rhscl-7-rpms/7Server/x86_64/updateinfo  | 1.3 MB   00:00
(3/3): rhel-server-rhscl-7-rpms/7Server/x86_64/primary_db  | 6.6 MB   00:00
repo id                                            repo name     status
jws-3-for-rhel-7-server-rpms/7Server/x86_64        JBoss Web Ser disabled
jws-5-for-rhel-7-server-rpms/x86_64                JBoss Web Ser disabled
rhel-7-server-ansible-2-rpms/x86_64                Red Hat Ansib disabled
rhel-7-server-ansible-2.8-rpms/x86_64              Red Hat Ansib disabled
rhel-7-server-devtools-rpms/x86_64                 Red Hat Devel disabled
rhel-7-server-dotnet-rpms/7Server/x86_64           dotNET on RHE disabled
!rhel-7-server-extras-rpms/x86_64                  Red Hat Enter enabled:  1,482
!rhel-7-server-optional-rpms/7Server/x86_64        Red Hat Enter enabled: 24,420
!rhel-7-server-rh-common-rpms/7Server/x86_64       Red Hat Enter enabled:    243
!rhel-7-server-rhn-tools-rpms/7Server/x86_64       RHN Tools for enabled:    139
!rhel-7-server-rpms/7Server/x86_64                 Red Hat Enter enabled: 34,473
!rhel-7-server-satellite-capsule-6.6-rpms/x86_64   Red Hat Satel enabled:    231
!rhel-7-server-satellite-client-6-rpms/x86_64      Red Hat Satel enabled:     37
!rhel-7-server-satellite-maintenance-6-rpms/x86_64 Red Hat Satel enabled:     62
!rhel-7-server-supplementary-rpms/7Server/x86_64   Red Hat Enter enabled:    511
!rhel-server-rhscl-7-rpms/7Server/x86_64           Red Hat Softw enabled: 14,708
repolist: 76,306
```

```
$ sudo yum install katello-host-tools
```

```
$ sudo yum list installed | grep -i katello
katello-ca-consumer-your.satelliteserver.com.noarch
katello-host-tools.noarch 4.2.3-5.el7sat  @rhel-7-server-satellite-client-6-rpms
```

```
$ sudo yum update rpm
```

```
$ sudo yum list installed | grep -i osinfo
libosinfo.x86_64               1.1.0-3.el7         @rhel-x86_64-server-7
osinfo-db.noarch               20200529-1.el7      @rhel-7-server-rpms
osinfo-db-tools.x86_64         1.1.0-1.el7         @rhel-x86_64-server-7
```

### Installing osinfo-db Package Manually

Separately download RPM for the latest version of `osinfo-db` package from the Red Hat Subscription Management (RHSM) (previously Red Hat Customer Portal or RedHat Network Systems Management (RHN) or just RHEL Subscription).

After you log in to the RHSM, navigate to [Downloads](https://access.redhat.com/downloads/) > Software Components > RPM Package Search.
Search for: *osinfo-db*.
Choose Version of the package from its drop-down.
Click on the 'Download Now' link .
(Package name in this case was `osinfo-db-20231215-1.el8.noarch.rpm`).

```
$ sudo yum install /home/dusko/osinfo-db-20231215-1.el8.noarch.rpm
```

```
$ osinfo-query os | wc -l
844

$ osinfo-query os | grep rhel9 | wc -l
6

$ osinfo-query os | grep rhel9
rhel9-unknown | Red Hat Enterprise Linux 9 Unknown | 9-unknown | http://redhat.com/rhel/9-unknown
rhel9.0       | Red Hat Enterprise Linux 9.0       | 9.0       | http://redhat.com/rhel/9.0
rhel9.1       | Red Hat Enterprise Linux 9.1       | 9.1       | http://redhat.com/rhel/9.1
rhel9.2       | Red Hat Enterprise Linux 9.2       | 9.2       | http://redhat.com/rhel/9.2
rhel9.3       | Red Hat Enterprise Linux 9.3       | 9.3       | http://redhat.com/rhel/9.3
rhel9.4       | Red Hat Enterprise Linux 9.4       | 9.4       | http://redhat.com/rhel/9.4
```


## Install a Guest VM with `virt-install`

```
$ sudo \
 virt-install \
 --name appserver1 \
 --memory 8192 \
 --vcpus 4 \
 --disk vol=default/appserver1.qcow2 \
 --os-variant rhel9.2 \
 --graphics none \
 --location /iscsisan/ISO/rhel-9.2-x86_64-dvd.iso \
 --extra-args='console=ttyS0'
```

Output:

```
Starting install...
Retrieving file .treeinfo...                                | 1.5 kB  00:00
Retrieving file vmlinuz...                                  |  12 MB  00:00
Retrieving file initrd.img...                               |  96 MB  00:00

Connected to domain appserver1

Escape character is ^]

[    0.000000] Linux version 5.14.0-284.11.1.el9_2.x86_64
  (mockbuild@x86-vm-09.build.eng.bos.redhat.com)
  (gcc (GCC) 11.3.1 20221121 (Red Hat 11.3.1-4), 
  GNU ld version 2.35.2-37.el9) #1 SMP PREEMPT_DYNAMIC
  Wed Apr 12 10:45:03 EDT 2023

[    0.000000] The list of certified hardware and cloud instances for 
  Red Hat Enterprise Linux 9 can be viewed at the Red Hat Ecosystem Catalog,
  https://catalog.redhat.com.

[    0.000000] Command line: console=ttyS0

[    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
                           . . . 
                           . . . 
[    5.792583] systemd[1]: Detected virtualization kvm.
[    5.793158] systemd[1]: Detected architecture x86-64.
[    5.793755] systemd[1]: Running in initrd.

Welcome to Red Hat Enterprise Linux 9.2 (Plow) dracut-057-21.git20230214.el9 (Initramfs)!

[    5.797627] systemd[1]: No hostname configured, using default hostname.
[    5.799878] systemd[1]: Hostname set to <localhost>.
                           . . . 
[    8.140652] RPC: Registered udp transport module.
[    8.141201] RPC: Registered tcp transport module.
[    8.141750] RPC: Registered tcp NFSv4.1 backchannel transport module.

[  OK  ] Finished dracut pre-udev hook.
         Starting Rule-based Manage…for Device Events and Files...
[  OK  ] Started Rule-based Manager for Device Events and Files.
         Starting dracut pre-trigger hook...
[  OK  ] Finished dracut pre-trigger hook.
         Starting Coldplug All udev Devices...

Starting installer, one moment...
anaconda 34.25.2.10-1.el9_2 for Red Hat Enterprise Linux 9.2 started.

 * installation log files are stored in /tmp during the installation
 * shell is available on TTY2
 * if the graphical installation interface fails to start, try again with the
   inst.text bootoption to start text installation
 * when reporting a bug add logs from /tmp as separate text/plain attachments

===============================================================================
===============================================================================

Text mode provides a limited set of installation options. It does not offer
custom partitioning for full control over the disk layout. Would you like to use
VNC mode instead?

1) Start VNC
2) Use text mode

Please make a selection from the above ['c' to continue, 'q' to quit, 'r' to
refresh]:

      


[anaconda]1:main* 2:shell  3:log  4:storage-log >Switch tab: Alt+Tab | Help: F1
```

Press '2'.

```
Please make a selection from the above ['c' to continue, 'q' to quit, 'r' to
refresh]: 2

================================================================================
================================================================================

Installation

1) [x] Language settings                 2) [x] Time settings
       (English (United States))                (America/New_York timezone)
3) [!] Installation source               4) [!] Software selection
       (Processing...)                          (Processing...)
5) [!] Installation Destination          6) [x] Kdump
       (Processing...)                          (Kdump is enabled)
7) [x] Network configuration             8) [!] Root password
       (Connected: ens3)                        (Root account is disabled)
9) [!] User creation
       (No user will be created)

Please make a selection from the above ['b' to begin installation, 'q' to quit,
'r' to refresh]:
[anaconda]1:main* 2:shell  3:log  4:storage-log >Switch tab: Alt+Tab | Help: F1

    2 [x] Time settings

================================================================================
================================================================================

Time settings

Timezone: America/New_York

NTP servers:
ntp1.yourdomain.com (status: working)
ntp2.yourdomain.com (status: working)
[ . . . ]

1) Change timezone
2) Configure NTP servers

Please make a selection from the above ['c' to continue, 'q' to quit, 'r' to
refresh]:
```

Change timezone to *America/Vancouver*.

Add two NTP servers (`ntp1.yourdomain.com`, `ntp2.yourdomain.com`).


```
Time settings

Timezone: America/Vancouver

NTP servers:
ntp1.yourdomain.com (status: working)
ntp2.yourdomain.com status: working)
[ . . . ]

1) Change timezone
2) Configure NTP servers
```


Change 5) Installation Destination.

```
5) [!] Installation Destination
   (Automatic partitioning selected)

Partitioning Options
1) [ ] Replace Existing Linux system(s)
2) [x] Use All Space
3) [ ] Use Free Space
4) [ ] Manually assign mount points

Installation requires partitioning of your hard drive. Select what space
to use for the install target or manually assign mount points.

Partition Scheme Options
1) [ ] Standard Partition
2) [x] LVM
3) [ ] LVM Thin Provisioning
```


Change 7) Network configuration.

```
7) [x] Network configuration
       (Connected: ens3)

Network configuration

Wired (ens3) connected
 IPv4 Address: 1.2.3.4 Netmask: 255.255.255.0 Gateway: 1.2.3.254
 DNS: 1.1.1.1,8.8.8.8

Host Name:
  Current host name: dhcp-123.yourdomain.com

1) Set host name
2) Configure device ens3

1) Host Name:
   Host Name: appserver1.yourdomain.com

) Configure device ens3

Device configuration

1) IPv4 address or "dhcp" for DHCP
   dhcp
2) IPv4 netmask
3) IPv4 gateway
4) IPv6 address[/prefix] or "auto" for automatic, "dhcp" for DHCP,
        "ignore" to turn off
        auto
5) IPv6 default gateway
6) Nameservers (comma separated)
7) [x] Connect automatically after reboot
8) [ ] Apply configuration in installer
```

After changes:

```
Device configuration

1) IPv4 address or "dhcp" for DHCP
   1.2.3.4
2) IPv4 netmask
   255.255.255.0
3) IPv4 gateway
   1.2.3.254
4) IPv6 address[/prefix] or "auto" for automatic, "dhcp" for DHCP,
   "ignore" to turn off
   ignore
5) IPv6 default gateway
6) Nameservers (comma separated)
   1.1.1.1,8.8.8.8
7) [x] Connect automatically after reboot
8) [x] Apply configuration in installer

Please make a selection from the above ['c' to continue, 'q' to quit, 'r' to
refresh]:
```

Press 'c'.

```
4) [x] Software selection
       (Server with GUI)

Software selection

Base environment

1) [x] Server with GUI                  4) [ ] Workstation
2) [ ] Server                           5) [ ] Custom Operating System
3) [ ] Minimal Install                  6) [ ] Virtualization Host

Please make a selection from the above ['c' to continue, 'q' to quit, 'r' to
refresh]: 5
```


After changes:

```
Software selection

Additional software for selected environment

1) [x] Guest Agents                     9) [x] Headless Management
2) [x] Standard                         10) [x] Network Servers
3) [x] Legacy UNIX Compatibility        11) [ ] RPM Development Tools
4) [x] Console Internet Tools           12) [ ] Scientific Support
5) [x] Container Management             13) [x] Security Tools
6) [x] Development Tools                14) [ ] Smart Card Support
7) [ ] .NET Development                 15) [x] System Tools
8) [ ] Graphical Administration Tools

Please make a selection from the above ['c' to continue, 'q' to quit, 'r' to
refresh]: c
```

```
8) [!] Root password
       (Root account is disabled)

Root password

Please select new root password. You will have to type it twice.

Password:
Password (confirm):
```

```
9) [ ] User creation
   (No user will be created)

User creation

1) [x] Create user
2) Full name
   dusko
3) User name
   dusko
4) [x] Use password
5) Password
   Password set.
6) [x] Administrator
7) Groups
   wheel
```

```
================================================================================
================================================================================

Installation

1) [x] Language settings                 2) [x] Time settings
       (English (United States))                (America/Vancouver timezone)
3) [x] Installation source               4) [x] Software selection
       (Local media)                            (Custom Operating System)
5) [x] Installation Destination          6) [x] Kdump
       (Automatic partitioning                  (Kdump is enabled)
       selected)
7) [x] Network configuration             8) [x] Root password
       (Connected: ens3)                        (Root password is set)
9) [x] User creation
       (Administrator dusko will be
       created)

Please make a selection from the above ['b' to begin installation, 'q' to quit,
'r' to refresh]:

[anaconda]1:main* 2:shell  3:log  4:storage-log >Switch tab: Alt+Tab | Help: F1
```

Press 'b'.


```
Please make a selection from the above ['b' to begin installation, 'q' to quit,
'r' to refresh]: b
================================================================================
================================================================================
```

Output:

```
Progress
.

Setting up the installation environment
Configuring storage
Creating disklabel on /dev/vda
Creating xfs on /dev/vda1
Creating lvmpv on /dev/vda2
Creating swap on /dev/mapper/rhel_dhcp--123-swap
Creating xfs on /dev/mapper/rhel_dhcp--123-home
Creating xfs on /dev/mapper/rhel_dhcp--123-root
...
Running pre-installation scripts
.
Running pre-installation tasks
....

Installing.

Starting package installation process
Downloading packages
Preparing transaction from installation source

Installing libgcc.x86_64 (1/944)
   . . . 
   . . . 
Verifying yajl.x86_64 (943/944)
Verifying zlib-devel.x86_64 (944/944)

.
Installing boot loader
..
Performing post-installation setup tasks
.
Configuring Red Hat subscription
....
Configuring installed system
..............
Writing network configuration
.
Creating users
.....
Configuring addons
.
Generating initramfs
....
Storing configuration files and kickstarts
.
Running post-installation scripts
.
Installation complete

Use of this product is subject to the license agreement found at:
/usr/share/redhat-release/EULA

Installation complete. Press ENTER to quit:
```


Press ENTER.

```
[  OK  ] Stopped Anaconda.
[  OK  ] Stopped target Anaconda System Services.
[  OK  ] Stopped Hold until boot process finishes up.
[  OK  ] Stopped Terminate Plymouth Boot Screen.
         Stopping RHSM dbus service...
         Stopping System Logging Service..
                    . . .
                    . . .
[  OK  ] Stopped target Local File Systems.
         Unmounting /mnt/sysimage/boot...
         Unmounting /mnt/sysimage/dev/pts...
         Unmounting /mnt/sysimage/dev/shm...
         Unmounting /mnt/sysimage/home...
         Unmounting /mnt/sysimage/proc...
         Unmounting /mnt/sysimage/run...
         Unmounting /mnt/sysimage/sys/fs/selinux...
         Unmounting /mnt/sysimage/tmp...
         Unmounting /mnt/sysroot/boot...
         Unmounting /mnt/sysroot/dev/pts...
         Unmounting /mnt/sysroot/dev/shm...
         Unmounting /mnt/sysroot/home...
         Unmounting /mnt/sysroot/proc...
         Unmounting /mnt/sysroot/run...
         Unmounting /mnt/sysroot/sys/fs/selinux...


                               GRUB version 2.06


 +----------------------------------------------------------------------------+
 |*Red Hat Enterprise Linux (5.14.0-284.11.1.el9_2.x86_64) 9.2 (Plow)         |
 | Red Hat Enterprise Linux (0-rescue-8244f8f3856641feb9f0a82867653602) 9.2 (>|
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 +----------------------------------------------------------------------------+

      Use the ^ and v keys to select which entry is highlighted.
      Press enter to boot the selected OS, `e' to edit the commands
      before booting or `c' for a command-line.
   The highlighted entry will be executed automatically in 5s.


[  OK  ] Started Show Plymouth Boot Screen.
[  OK  ] Started Forward Password R…s to Plymouth Directory Watch.
[  OK  ] Reached target Path Units.

[    2.642454] virtio_blk virtio2: [vda] 503316480 512-byte logical blocks (258 GB/240 GiB)
[    2.647842]  vda: vda1 vda2
[    2.774706] virtio_net virtio0 ens3: renamed from eth0
[    2.791128] scsi host0: ata_piix
                    . . .
                    . . .
[    4.844931] systemd[1]: Detected virtualization kvm.
[    4.845507] systemd[1]: Detected architecture x86-64.


Welcome to Red Hat Enterprise Linux 9.2 (Plow)!


[    4.890879] systemd-rc-local-generator[584]: /etc/rc.d/rc.local is not marked executable, skipping
                    . . .
                    . . .
[  OK  ] Finished Permit User Sessions.
[  OK  ] Started Deferred execution scheduler.
[  OK  ] Started Command Scheduler.
         Starting Hold until boot process finishes up...
         Starting Terminate Plymouth Boot Screen...

Red Hat Enterprise Linux 9.2 (Plow)
Kernel 5.14.0-284.11.1.el9_2.x86_64 on an x86_64

Activate the web console with: systemctl enable --now cockpit.socket

appserver1 login:
```

----

## References
(Retrieved on Jun 21, 2024)

* [Installing Virtual Machines with virt-install, plus copy pastable distro install one-liners](https://raymii.org/s/articles/virt-install_introduction_and_copy_paste_distro_install_commands.html#toc_15)

* [distro 'rhel7.2' does not exist in our dictionary - StackOverflow](https://stackoverflow.com/questions/44277936/distro-rhel7-2-does-not-exist-in-our-dictionary)

----

