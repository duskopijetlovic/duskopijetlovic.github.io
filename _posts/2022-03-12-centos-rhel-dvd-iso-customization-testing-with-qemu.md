---
layout: post
title: "Customize CentOS/RHEL DVD ISO for Installation in Text Mode via Serial Console and Test the Image with QEMU"
date: 2022-03-12 09:01:47 -0700 
categories: howto virtualization rs232serial cli terminal shell console sysadmin server hardware
---

OSs: RHEL 7, CentOS 7    
Shells:  csh, bash     

---

Specifically:  Customize CentOS/RHEL DVD ISO Image for Installation in Text 
Mode via Serial Console **on IBM BladeCenter HS21 Servers** and Test It with QEMU   

---

*Task:*      
Install CentOS Linux 7 in Text Mode on IBM BladeCenter HS21 blade servers 
(a.k.a blades) via serial console.

*Motivation:*   
Could not use IBM MM (Management Module) web interface's console 
for performing CentOS Linux installation because MM required a very old 
Java version, which proved complicated to setup.   

--- 

### Prepare the Server to Use Serial Console 

Server:  IBM BladeCenter HS21 (This blade is **BIOS-based** and does **not** 
support *EFI/UEFI*)


For SOL (Serial Over LAN) to work on this server, the following settings
of its BIOS need to be changed (the lines in bold had to be changed):

* Devices and I/O Ports:
   * **Serial Port A:** Auto-configure
   * **Serial Port B:** Auto-configure
* Remote Console Redirection:
   * **Remote Console Active:** Enabled 
   * **Remote Console COM Port:** COM 2
   * Remote Console Baud Rate: 19200
   * Remote Console Data Bits: 8 
   * Remote Console Parity: None
   * Remote Console Stop Bits: 1
   * Remote Console Text Emulation: ANSI 
   * **Remote Console After Boot:** Enabled 
   * **Remote Console Flow Control:** Hardware 

---

*(Optional)*   
Before the upgrade, the OS on the blades was CentOS Linux 5.2. 
If you wanted to enable CentOS 5.2 for redirecting output to the second 
serial device ttyS1 (COM2), you would need to change the following 
configuration files on that OS:
  * /etc/inittab
  * /etc/securetty
  * /boot/grub/grub.conf

Add the following line to the end of the 
```# Run gettys in standard runlevels``` section of the **/etc/inittab** file. 
This enables hardware flow control and enables users to log in through 
the SOL console.   

```
7:2345:respawn:/sbin/agetty -h ttyS1 19200 vt102
```

Add the following line at the bottom of the **/etc/securetty** file to 
enable a user to log in as the root user through the SOL console:

```
ttyS1
```


Complete the following steps to modify the **/boot/grub/grub.conf** file:

1. Comment out the ```splashimage=...``` line by adding a ```#``` at the 
beginning of this line.    
2. Add the following line before the first ```title=...``` line:
```# This will allow you to only Monitor the OS boot via SOL```    
3. Append the following text to the first ```title=...``` line:
```SOL Monitor```   
4. Append the following text to the ```kernel/...``` line of the 
first ```title=...``` section:  
```console=ttyS1,19200 console=tty1```    
5. Add the following lines between the two ```title=...``` sections:    

```
# This will allow you to Interact with the OS boot via SOL 
title Red Hat Linux (2.4.9-e.12smp) SOL Interactive
    root (hd0,0)
    kernel /vmlinuz-2.4.9-e.12smp ro root=/dev/hda6 console=tty1 
console=ttyS1,19200
    initrd /initrd-2.4.9-e.12smp.img
```

**Note:** The entry beginning with kernel ```/vmlinuz...``` is shown 
with a line break after ```console=tty1```. In your file, the entire 
entry must all be on one line.


Details:
[IBM BladeCenter - Serial Over LAN (SOL) Setup Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.advmgtmod.doc/kp1bd_pdf.pdf)    
Chapter 3. Operating system configuration > Linux configuration > 
Red Hat Enterprise Linux ES 2.1 configuration (including GRUB configuration)    
(Retrieved on Mar 12, 2022)   


---

Steps:  

* Download and test ISO
* Mount ISO and prep for edit
* Edit isolinux.cfg
* Create the new ISO
* Create a test QEMU image with console redirection to serial device on COM2 (ttyS1)
* Test the QEMU image 

**NOTE:**    
You need to construct a command line for calling QEMU because the 
raw QEMU doesn't have any VM management so your VM configuration is not
permanent. For the task explained on this page that's nice since you'll 
experiment with different VM configurations; for example, one serial 
device in the guest VM, two serial devices in the VM, no serial devices...

While your VM configuration is not remembered, changes you 
make in the guest VM do get saved in the VM image. In other words, after
you boot the guest in an image, log into the OS installed on it, and 
make changes in the guest OS' configuration files, they are saved. 
After restarting the guest on the same VM image, next time you log into 
the guest OS on it, your changes will be there. 

---

IBM BladeCenter HS21 does not support ```ipmitool```.   
**[TODO]:**  Check to see if it's possible to add IPMI support in/via BIOS. 

---

**NOTE:**    
When there are long lines in scripts, code and CLI output examples, 
they are folded and then indented to make sure they fit the page.
If there are exceptions, they are noted.  

---

### (Optional) Create a Test QEMU Image with a Text Console on the First Serial Device ttyS0 (COM1)


Note that this step is optional. It's here to show the setup of packages 
needed on the host OS, the use of QEMU as a test tool for performing the 
required task, and to demonstrate how to create a test virtual machine 
that redirects text output to serial console device. 

The host server used as a jump box already had the following 
packages installed.

```
ipxe-roms-qemu, libvirt-daemon-driver-qemu, qemu-guest-agent, qemu-img, 
qemu-kvm, qemu-kvm-block-curl, qemu-kvm-block-gluster, qemu-kvm-block-iscsi, 
qemu-kvm-block-rbd, qemu-kvm-block-ssh, qemu-kvm-common, qemu-kvm-core
```

Install additional packages. 

```
$ sudo dnf install libvirt
```

```
$ sudo dnf install virt-install virt-manager
```

```
$ sudo dnf install libguestfs-tools libguestfs-gfs2 libguestfs-rescue \
 libguestfs-rsync libguestfs-xfs
```

```
$ sudo dnf install virt-dib virt-v2v virt-p2v-maker virt-viewer virt-who \
 virt-top virtio-win
```

```
$ sudo dnf install minicom 
```

```
$ sudo dnf install isomd5sum
```


CentOS Mirror ([http://mirror.centos.org/](http://mirror.centos.org/))
contains a directory tree with current CentOS Linux and Stream releases 
(as of Mar 12, 2022: CentOS 7 and CentOS 8-stream).  The last CentOS 
release before switching to CentOS Stream was CentOS 7.9: 
[http://mirror.centos.org/centos-7/7.9.2009/](http://mirror.centos.org/centos-7/7.9.2009/).  In order to conserve the limited bandwidth 
available, ISO images on CentOS.org are not downloadable from 
mirror.centos.org.  The following page lists mirrors in your region that 
have the ISO images available: [http://isoredirect.centos.org/centos/7.9.2009/isos/x86_64/](http://isoredirect.centos.org/centos/7.9.2009/isos/x86_64/).  

Download and verify the CentOS DVD ISO installation image. I decided to use minimal install, CentOS-7-x86_64-Minimal-2009.iso.  (Other options were: CentOS-7-x86_64-DVD-2009.iso, CentOS-7-x86_64-Everything-2009.iso, CentOS-7-x86_64-NetInstall-2009.iso.)  For my region, download location was on mirror.esecuredata.com.  

```
$ wget https://mirror.esecuredata.com/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso
$ wget https://mirror.esecuredata.com/centos/7.9.2009/isos/x86_64/sha256sum.txt
```

```
$ sha256sum CentOS-7-x86_64-Minimal-2009.iso
07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a  CentOS-7-x86_6
4-Minimal-2009.iso

$ grep 'CentOS-7-x86_64-Minimal-2009.iso' sha256sum.txt
07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a  CentOS-7-x86_6
4-Minimal-2009.iso
```

```
$ sudo mkdir -p /mnt/{dvd,customdvd}
```

```
$ ls -lh /mnt/
total 0
drwxr-xr-x 2 root root 6 Apr 16 19:57 customdvd
drwxr-xr-x 2 root root 6 Apr 16 19:57 dvd
```

Mount the DVD ISO image. 

```
$ sudo \
 mount \ 
 -t iso9660 \
 /home/dusko/CentOS-7-x86_64-Minimal-2009.iso \ 
 /mnt/dvd/
```


Copy the content of the DVD to a separate directory. 

```
$ sudo rsync -a /mnt/dvd/ /mnt/customdvd
```

```
$ ls -alh /mnt/customdvd/
total 84K
drwxr-xr-x  8 root root  254 Nov  3  2020 .
drwxr-xr-x. 4 root root   34 Apr 17 18:39 ..
-rw-r--r--  1 root root   14 Oct 29  2020 CentOS_BuildTag
-rw-r--r--  1 root root   29 Oct 26  2020 .discinfo
drwxr-xr-x  3 root root   35 Oct 26  2020 EFI
-rw-rw-r--  1 root root  227 Aug 30  2017 EULA
-rw-rw-r--  1 root root  18K Dec  9  2015 GPL
drwxr-xr-x  3 root root   57 Oct 26  2020 images
drwxr-xr-x  2 root root  182 Apr 17 18:47 isolinux
drwxr-xr-x  2 root root   43 Oct 26  2020 LiveOS
drwxr-xr-x  2 root root  28K Nov  3  2020 Packages
drwxr-xr-x  2 root root 4.0K Nov  3  2020 repodata
-rw-rw-r--  1 root root 1.7K Dec  9  2015 RPM-GPG-KEY-CentOS-7
-rw-rw-r--  1 root root 1.7K Dec  9  2015 RPM-GPG-KEY-CentOS-Testing-7
-r--r--r--  1 root root 2.9K Nov  3  2020 TRANS.TBL
-rw-r--r--  1 root root  354 Oct 26  2020 .treeinfo
```

```
$ cat /mnt/customdvd/.discinfo 
1603728831.612616
7.9
x86_64
```

```
$ cat /mnt/customdvd/.treeinfo 
[general]
name = CentOS-7
family = CentOS
timestamp = 1603729576.26
variant = 
version = 7
packagedir = 
arch = x86_64

[stage2]
mainimage = LiveOS/squashfs.img

[images-x86_64]
kernel = images/pxeboot/vmlinuz
initrd = images/pxeboot/initrd.img
boot.iso = images/boot.iso

[images-xen]
kernel = images/pxeboot/vmlinuz
initrd = images/pxeboot/initrd.img
```

```
$ ls -lh /mnt/customdvd/isolinux/
total 60M
-r--r--r-- 1 root root 2.0K Nov  3  2020 boot.cat
-rw-r--r-- 2 root root   84 Oct 26  2020 boot.msg
-rw-r--r-- 2 root root  281 Oct 26  2020 grub.conf
-rw-r--r-- 4 root root  53M Oct 26  2020 initrd.img
-rw-r--r-- 2 root root  24K Nov  3  2020 isolinux.bin
-rw-r--r-- 2 root root 3.0K Oct 26  2020 isolinux.cfg
-rw-r--r-- 3 root root 187K Nov  5  2016 memtest
-rw-r--r-- 5 root root  186 Sep 30  2015 splash.png
-r--r--r-- 1 root root 2.2K Nov  3  2020 TRANS.TBL
-rw-r--r-- 3 root root 150K Oct 30  2018 vesamenu.c32
-rwxr-xr-x 4 root root 6.5M Oct 19  2020 vmlinuz
```

Customize the DVD ISO so that the installer redirects its text 
output to the serial console. 

```
$ cd /mnt/customdvd/isolinux/
```

Remove 'boot.cat'. It will be regenerated in a later step.

```
$ sudo rm -i boot.cat
rm: remove regular file 'boot.cat'? y
```

```
$ wc -l boot.msg
5 boot.msg
```

Delete the line with 'splash.lss' from the 'boot.msg'.

```
$ cat boot.msg

 
splash.lss

 -  Press the 01<ENTER>07 key to begin the installation process.

```

```
$ grep -n 'splash\.lss' boot.msg
2:splash.lss
```

```
$ sudo sed -i.bkp '/splash\.lss/d' boot.msg
```

```
$ diff boot.msg.bkp boot.msg
2d1
< splash.lss
```

```
$ diff \
 --unified=0 \
 /mnt/dvd/isolinux/boot.msg \
 /mnt/customdvd/isolinux/boot.msg
--- /mnt/dvd/isolinux/boot.msg  2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/isolinux/boot.msg    2022-03-12 21:11:33.140839189 -0700
@@ -2 +1,0 @@
-splash.lss
```

```
$ sudo rm -i boot.msg.bkp
rm: remove regular file 'boot.msg.bkp'? y
```

```
$ sudo vi isolinux.cfg
```

Tell ISOLINUX to use a serial port as the console. 
"port" is a number (0 = /dev/ttyS0 = COM1, etc.) or an I/O port address (e.g. 0x3F8) ([https://www.syslinux.org/old/faq.php](https://www.syslinux.org/old/faq.php), [https://wiki.syslinux.org/wiki/index.php?title=SYSLINUX](https://wiki.syslinux.org/wiki/index.php?title=SYSLINUX)).

Here I want to use the port 0 so the ```console``` statement uses 
tty0 and ttyS0. 

```
$ diff \
 --unified=0 \
 /mnt/dvd/isolinux/isolinux.cfg \
 /mnt/customdvd/isolinux/isolinux.cfg
--- /mnt/dvd/isolinux/isolinux.cfg      2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/isolinux/isolinux.cfg        2022-03-12 22:39:15.690733667 -0700
@@ -64 +64 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet console=tty0 console=ttyS0
@@ -70 +70 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet console=tty0 console=ttyS0
@@ -86 +86 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet console=tty0 console=ttyS0
@@ -96 +96 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet console=tty0 console=ttyS0
```


No need to make EFI changes because in this case the guest system you are 
planning to simulate is is BIOS-based, not EFI/UEFI.  

Just as a reference, here's the content of the EFI directory:

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
-r--r--r-- 1 root root 1.8K Nov  3  2020 TRANS.TBL
```

#### Create a New Bootable Installation DVD ISO Image  

For the CentOS 7 Installation DVD, the label must stay the same.

Use the ```isoinfo``` command to find out the label of the CentOS DVD 
(an extension named "Volume id"). You can use the same command to find 
out other extensions too; for example, information about Rock Ridge, 
Joliet extensions and Eltorito boot information if present.


```
$ isoinfo -d -i \
 ~/CentOS-7-x86_64-Minimal-2009.iso | wc -l
29
```

```
$ isoinfo -d -i \
 ~/CentOS-7-x86_64-Minimal-2009.iso | grep "Volume id" 
Volume id: CentOS 7 x86_64

$ isoinfo -d -i \
 ~/CentOS-7-x86_64-Minimal-2009.iso | grep Joliet
Joliet with UCS level 3 found

$ isoinfo -d -i \
 ~/CentOS-7-x86_64-Minimal-2009.iso | grep prepare
Data preparer id:

$ isoinfo -d -i \
~/CentOS-7-x86_64-Minimal-2009.iso | grep Torito
El Torito VD version 1 found, boot catalog is in sector 606
```

Alternatively, ```blkid(8)``` also shows the label:

```
$ blkid ~/CentOS-7-x86_64-Minimal-2009.iso
/home/dusko/CentOS-7-x86_64-Minimal-2009.iso: BLOCK_SIZE="2048" 
  UUID="2020-11-03-14-55-29-00" LABEL="CentOS 7 x86_64" TYPE="iso9660" 
  PTUUID="6acc9bba" PTTYPE="dos"
```


Recreate the DVD ISO image with the customized settings. 

```
$ sudo \
 mkisofs \
 -o /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso \
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
$ sudo chown dusko:dusko /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso
```


Implant an MD5 checksum in the ISO image.  

```
$ implantisomd5 /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso
```

For systems that suport EFI/UEFI, the next step would be to run 
the ```isohybrid``` command to make the installation ISO image 
EFI/UEFI-bootable. (In this case, do **not** run the isohybrid command 
below because this server supports only BIOS.)   


Similarly, if you wanted to create a bootable USB drive (USB flash drive), 
you would also need to run the ```isohybrid``` command.  

```
$ isohybrid --uefi \
 /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso
```


Check an MD5 checksum implanted by ```implantisomd5```.

```
$ checkisomd5 \
 --verbose \
 /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso
---- snip ----
Checking: 100.0%

The media check is complete, the result is: PASS.
```

```
$ cd

$ pwd
/home/dusko
```

Create an image file for the guest virtual machine. 

```
$ truncate --size=291999055872 abnodevm.img
```

The created image's format is raw.  

```
$ qemu-img info abnodevm.img
image: abnodevm.img
file format: raw
virtual size: 272 GiB (291999055872 bytes)
disk size: 512 B
```

Optionally, you can convert the raw image to qcow2 format. 
(Shown here as a reference. **Don't** do it now.)  

```
$ qemu-img \ 
 convert \ 
 -f raw \
 -O qcow2 \
 abnodevm.img \
 abnodevm.qcow2
```

```
$ qemu-img info abnodevm.qcow2
image: abnodevm.qcow2
file format: qcow2
virtual size: 272 GiB (291999055872 bytes)
disk size: 16.5 KiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
```

Some useful options for QEMU's virtual console:  

```
$ /usr/libexec/qemu-kvm -h

---- snip ----

During emulation, the following keys are useful:
ctrl-alt-f      toggle full screen
ctrl-alt-n      switch to virtual console 'n'
ctrl-alt        toggle mouse and keyboard grab

When using -nographic, press 'ctrl-a h' to get some help.

See <https://qemu.org/contribute/report-a-bug> for how to report bugs.
More information on the QEMU project at <https://qemu.org>.

WARNING: 
Direct use of qemu-kvm from the command line is not supported by Red Hat.

WARNING: Use libvirt as the stable management interface.
```

Install CentOS 7.9 on the virtual machine image by using the customized 
CentOS installation DVD image (in text mode, with output via serial 
console - in this example it's the first serial device, ttyS0).  

```
$ /usr/libexec/qemu-kvm \
 -cdrom /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso \
 -hda abnodevm.qcow2 \
 -m 2G \
 -boot d \
 -enable-kvm \
 -nographic
```

Start the OS install and finish installing CentOS Linux 7.9.    

---

After installation:   

When you want to just boot from the image file without the installation 
ISO file (after you have finished installing and now you always want to 
boot the installed system), you can just remove the ```-cdrom``` option:

```
$ /usr/libexec/qemu-kvm \
 -hda abnodevm.qcow2 \
 -m 2G \
 -enable-kvm \
 -nographic
```

Alternatively, you can enable ssh port forwarding (with '-net user', 
'-net nic') when starting the guest VM so this works too:

```
$ /usr/libexec/qemu-kvm \
 -cdrom /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso \
 -hda abnodevm.qcow2 \
 -m 2G \
 -boot d \
 -enable-kvm \
 -net user,hostfwd=tcp::10022-:22 \
 -net nic \
 -nographic
```

---

### Create a QEMU Image with Serial Text Console on ttyS1 (COM2) 

**Why redirection to ttyS1 (COM2)?:**  The serial console on 
**COM2** (**ttyS1** in Unix) is required by IBM **MM** (Management Module) 
**CLI** on IBM BladeCenter HS21 Blade Servers.     

*Details:*    
Out-of-band (OOB) management interface (1) (2) on IBM BladeCenter server 
architecture is called **MM** (Management Module). 
On this particular generation of BladeCenter servers, in order 
for the MM to be able to support SOL (Serial Over LAN) you have to 
redirect the serial console to **COM2** (**ttyS1** in Unix).  

(1): Sometimes called lights-out management (LOM).   
(2): IBM MM (Management Module) interacts with a hardware module 
(a remote management card) often called BMC (Baseboard Management 
Controller) installed inside the IBM BladeCenter server chassis
(that houses multiple blades). The BMC is configured with the 
network interface controller (NIC) to use the Remote Management 
Control Protocol (RMCP), a.k.a. IPMI (Intelligent Platform Management 
Interface).   

Download the CentOS 7 DVD ISO image.  

```
$ wget https://mirror.esecuredata.com/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso
```

```
$ file CentOS-7-x86_64-DVD-2009.iso
CentOS-7-x86_64-DVD-2009.iso: ISO 9660 CD-ROM filesystem data 
  (DOS/MBR boot sector) 'CentOS 7 x86_64' (bootable)
```

```
$ wget https://mirror.esecuredata.com/centos/7.9.2009/isos/x86_64/sha256sum.txt
```

Usually I fold and then indent long lines when showing them in scripts, 
code and CLI outputs.  In this case (for ```sha256sum --check```), 
I'm making an exception.  

```
$ wc -l sha256sum.txt
4 sha256sum.txt

$ grep 'CentOS-7-x86_64-DVD-2009.iso' sha256sum.txt
e33d7b1ea7a9e2f38c8f693215dd85254c3a4fe446f93f563279715b68d07987  CentOS-7-x86_64-DVD-2009.iso

$ grep 'CentOS-7-x86_64-DVD-2009.iso' sha256sum.txt > /tmp/sha256sum.txt

$ mv /tmp/sha256sum.txt ~/sha256sum.txt

$ cat sha256sum.txt
e33d7b1ea7a9e2f38c8f693215dd85254c3a4fe446f93f563279715b68d07987  CentOS-7-x86_64-DVD-2009.iso

$ sha256sum --check sha256sum.txt
CentOS-7-x86_64-DVD-2009.iso: OK
```

```
$ sudo mkdir -p /mnt/{dvd,customdvd}
```

```
$ sudo \
 mount \
 -t iso9660 \
 ~/CentOS-7-x86_64-DVD-2009.iso \
 /mnt/dvd/
mount: /mnt/dvd: WARNING: device write-protected, mounted read-only.
```

```
$ sudo rsync -a /mnt/dvd/ /mnt/customdvd
```

```
$ du -chs /mnt/dvd/ /mnt/customdvd/
4.5G    /mnt/dvd/
4.5G    /mnt/customdvd
8.9G    total
```

```
$ ls -alh /mnt/customdvd/isolinux/
total 60M
drwxr-xr-x 2 root root  198 Nov  2  2020 .
drwxr-xr-x 8 root root  254 Nov  3  2020 ..
-r--r--r-- 1 root root 2.0K Nov  3  2020 boot.cat
-rw-r--r-- 1 root root   84 Oct 26  2020 boot.msg
-rw-r--r-- 1 root root  281 Oct 26  2020 grub.conf
-rw-r--r-- 1 root root  53M Oct 26  2020 initrd.img
-rw-r--r-- 1 root root  24K Nov  3  2020 isolinux.bin
-rw-r--r-- 1 root root 3.0K Oct 26  2020 isolinux.cfg
-rw-r--r-- 1 root root 187K Nov  5  2016 memtest
-rw-r--r-- 1 root root  186 Sep 30  2015 splash.png
-r--r--r-- 1 root root 2.2K Nov  3  2020 TRANS.TBL
-rw-r--r-- 1 root root 150K Oct 30  2018 vesamenu.c32
-rwxr-xr-x 1 root root 6.5M Oct 19  2020 vmlinuz
```


Delete the line with 'splash.lss' from the 'boot.msg'.

```
$ wc -l /mnt/customdvd/isolinux/boot.msg 
5 /mnt/customdvd/isolinux/boot.msg
```

```
$ cat /mnt/customdvd/isolinux/boot.msg

 
splash.lss

 -  Press the 01<ENTER>07 key to begin the installation process.

```

```
$ sudo sed -i.bkp '/splash.lss/d' /mnt/customdvd/isolinux/boot.msg 
```

```
$ diff \
 --unified=0 \
 /mnt/dvd/isolinux/boot.msg \
 /mnt/customdvd/isolinux/boot.msg
--- /mnt/dvd/isolinux/boot.msg  2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/isolinux/boot.msg    2022-03-12 22:45:03.473419287 -0700
@@ -2 +1,0 @@
-splash.lss
```

```
$ wc -l /mnt/customdvd/isolinux/boot.msg
4 /mnt/customdvd/isolinux/boot.msg
```

```
$ cat /mnt/customdvd/isolinux/boot.msg

 

 -  Press the 01<ENTER>07 key to begin the installation process.

```

```
$ sudo rm -i /mnt/customdvd/isolinux/boot.msg.bkp
rm: remove regular file '/mnt/customdvd/isolinux/boot.msg.bkp'? y
```

Remove *boot.cat*. You'll regenerate it in later steps. 

```
$ sudo rm -i /mnt/customdvd/isolinux/boot.cat
rm: remove regular file '/mnt/customdvd/isolinux/boot.cat'? y
```


```
$ sudo vi /mnt/customdvd/isolinux/isolinux.cfg 
```

Usually I fold and then indent long lines when showing them in scripts, 
code and CLI outputs. In this case, I'm making an exception.

```
$ diff \
 --unified=0 \
 /mnt/dvd/isolinux/isolinux.cfg \
 /mnt/customdvd/isolinux/isolinux.cfg
--- /mnt/dvd/isolinux/isolinux.cfg      2020-10-26 09:25:28.000000000 -0700
+++ /mnt/customdvd/isolinux/isolinux.cfg     2022-03-12 22:46:18.607074016 -0700
@@ -64 +64 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet console=tty1 console=ttyS1,19200
@@ -70 +70 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet console=tty1 console=ttyS1,19200
@@ -86 +86 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet console=tty1 console=ttyS1,19200
@@ -96 +96 @@
-  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet
+  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet console=tty1 console=ttyS1,19200
```

As noted in the [previous step](#create-a-new-bootable-installation-dvd-iso-image), for the CentOS 7 Installation DVD the label must stay the same. 

```
$ isoinfo -d -i ~/CentOS-7-x86_64-DVD-2009.iso | wc -l
29

$ isoinfo -d -i ~/CentOS-7-x86_64-DVD-2009.iso | grep "Volume id"
Volume id: CentOS 7 x86_64

$ isoinfo -d -i ~/CentOS-7-x86_64-DVD-2009.iso | grep Joliet
Joliet with UCS level 3 found

$ isoinfo -d -i ~/CentOS-7-x86_64-DVD-2009.iso | grep Rock
Rock Ridge signatures version 1 found

$ isoinfo -d -i ~/CentOS-7-x86_64-DVD-2009.iso | grep preparer
Data preparer id:

$ isoinfo -d -i ~/CentOS-7-x86_64-DVD-2009.iso | grep Torito
El Torito VD version 1 found, boot catalog is in sector 606
```

Alternatively, ```blkid(8)``` also shows the label: 

```
$ blkid ~/CentOS-7-x86_64-DVD-2009.iso
/home/dusko/CentOS-7-x86_64-DVD-2009.iso: BLOCK_SIZE="2048" 
  UUID="2020-11-04-11-36-43-00" LABEL="CentOS 7 x86_64" TYPE="iso9660" 
  PTUUID="6b8b4567" PTTYPE="dos"
```

Generate an ISO image of the customized DVD.

```
$ sudo \
 mkisofs \
 -o /tmp/CentOS-7-x86_64-DVD-2009-CUSTOM.iso \
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
$ sudo chown dusko:dusko /tmp/CentOS-7-x86_64-DVD-2009-CUSTOM.iso
```

```
$ implantisomd5 /tmp/CentOS-7-x86_64-DVD-2009-CUSTOM.iso
```

```
$ checkisomd5 --verbose /tmp/CentOS-7-x86_64-DVD-2009-CUSTOM.iso
---- snip ----
The media check is complete, the result is: PASS.
It is OK to use this media.
```

Create a raw image of 20 GB in size. Using **seek** option creates 
a sparse file, which saves space.


```
$ dd if=/dev/null of=ttyS1disk4k.img bs=1M seek=20480
```

```
$ ls -lh ttyS1disk4k.img
-rw-rw-r-- 1 dusko dusko 20G Mar 12 22:47 ttyS1disk4k.img
```

The image doesn't have a filesystem yet:

```
$ blkid ttyS1disk4k.img
```

NOTE    
For serial on QEMU:   
> You should use pseudo-terminals (-serial pty) instead of connecting to 
> "real" char-devices (-chardev tty,...).
> 
> qemu displays the pty /dev/pts/xx which it actually uses.  You can now 
> use this pty as a normal serial port from your host.
> 
> You can repeat this option to get more ptys connected to /dev/ttyS[0-*] 
> on the guest (if you use '-serial stdio', it is /dev/ttyS0 on the guest, 
> the first pty is then /dev/ttyS1). <--- Using '-serial stdio' and then
> another '-serial pty' did **not** work in my tests. 
> When I used ```-serial stdio -serial pty```, 
> qemu complained with this error:
> 
> qemu-kvm: -serial stdio: cannot use stdio by multiple character devices  
> qemu-kvm: -serial stdio: could not connect serial device to character 
>                          backend 'stdio'

Reference:   
[ttyO ports do not have the good port address on QEMU 1.4.0 running image for beagleboard-xm](https://alpha.frasesdemoda.com/categories-topics-unix.stackexchange.com/questions/78511/ttyo-ports-do-not-have-the-good-port-address-on-qemu-1-4-0-running-image-for-bea)       
(Retrieved on Mar 12, 2022)    


Next step:  install the OS. 

Explanation for options in the next command:   

The '-drive format=raw,file=\<image_filename\>' is for a raw image.  
(With -hda \<image_filename\>, qemu reports the warning below.)
> Image format was not specified for 'image_filename' and probing
> guessed raw.  Automatically detecting the format is dangerous for
> raw images, write operations on block 0 will be restricted.
> Specify the 'raw' format explicitly to remove the restrictions.

The '-global ide-hd.physical_block_size=4096' is to set disk 
block size to 4K, which is the block size on compute nodes (on the 
machine for which you are preparing and doing this test). 

Specifying the '-serial pty 'option **twice** is needed because the 
first one is for ttyS0 (COM1) and the second one is for ttyS1 (COM2). 
Similar to the block size, the second serial device (ttyS1) is required 
by the server for which this test is performed.    

From the man page for ```qemu-kvm```:    
>
> -nographic   
> Normally, if QEMU is compiled with graphical window support, it
> displays output such as guest graphics, guest console, and the
> QEMU monitor in a window. With this option, you can totally
> disable graphical output so that QEMU is a simple command line
> application. The emulated serial port is redirected on the console
> and muxed with the monitor (unless redirected elsewhere
> explicitly). Therefore, you can still use QEMU to debug a Linux
> kernel with a serial console. 
>     
> Use C-a h for help on switching between the console and monitor.

'-cdrom': Use file as CD-ROM image.   
'-m 2G':  Set guest startup RAM size to 2 gigabytes.  
'-b d':   Boot from CD-ROM.    


Note that default block size that the ```mkfs.xfs``` uses is 4096 bytes (4k).  

**[TODO]**   
Would there be any (major) differences if instead of leaving it to the OS 
installer to create it, you created the filesystem first, with, 
for example: ```mkfs.xfs /<image_name/>```, in this case: 
```mkfs.xfs ttyS1disk4k.img```?


```
$ /usr/libexec/qemu-kvm \
 -cdrom /tmp/CentOS-7-x86_64-DVD-2009-CUSTOM.iso \ 
 -drive format=raw,file=ttyS1disk4k.img \
 -global ide-hd.physical_block_size=4096 \
 -m 2G \
 -boot d \
 -enable-kvm \ 
 -serial pty \
 -serial pty \
 -nographic
```

Output:

```
QEMU 4.2.0 monitor - type 'help' for more information
(qemu) char device redirected to /dev/pts/2 (label serial0)
char device redirected to /dev/pts/3 (label serial1)

(qemu)  
```

From the QEMU Monitor's output above, note where qemu
redirected two char devices. In this case: 
```/dev/pts/2``` and  ```/dev/pts/3```. 

NOTE:   
To get help in the QEMU prompt (QEMU monitor), press  Ctrl-a h:

```
C-a h    print this help
C-a x    exit emulator
C-a s    save disk data back to file (if -snapshot)
C-a t    toggle console timestamps
C-a b    send break (magic sysrq)
C-a c    switch between console and monitor
C-a C-a  sends C-a
```

Open two new shell instances, and start minicom in both of them.

**Why two shell and minicom instances?**   
A:  To be sure you will not miss them:
- Virtual Terminal (VT) login prompts, i.e. those on your VGA screen 
as exposed in ```/dev/tty1``` (and similar devices). 
- Serial port terminal (including ```/dev/ttyS0```, ```/dev/ttyS1```)

> **tty1** gets special treatment: if you boot into graphical mode, the 
> display manager takes possession of this VT.  If you boot into multi-user 
> (text) mode, a getty is started on it.   
>
> 
> By default systemd will instantiate one serial-getty@.service on the 
> main kernel console, if it is not a virtual terminal.  The kernel console 
> is where the kernel outputs its own log messages and is usually configured 
> on the kernel command line in the boot loader via an argument such as 
> ```console=ttyS0```.  This logic ensures that when the user asks the kernel 
> to redirect its output onto a certain serial terminal, he will automatically 
> also get a login prompt on it as the boot completes.

Reference:   
[systemd for Administrators, Part XVI](http://0pointer.de/blog/projects/serial-console.html)   
(Retrieved on Mar 12, 2022)    


In the first new shell, start the first minicom.

```
$ minicom --baudrate=19200 --ptty=/dev/pts/2
```

The first serial connection (```/dev/pts/2```) is the kernel console.
As per quote above:   
> By default systemd will instantiate one serial-getty@.service on the 
> main kernel console, if it is not a virtual terminal.  The kernel console 
> is where the kernel outputs its own log messages and is usually configured 
> on the kernel command line in the boot loader via an argument such as 
> ```console=ttyS0```.  This logic ensures that when the user asks the kernel 
> to redirect its output onto a certain serial terminal, he will automatically 
> also get a login prompt on it as the boot completes.

For now (before making changes in the grub configuration), if you are
fast enough, you might briefly see CentOS Installer boot menu in the first 
serial console (/dev/pts/2):

```
   CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
   CentOS Linux (0-rescue-5003bb903e814f84ad84b479956f01d0) 7 (Core)




   Use the ^ and v keys to change the selection.
Press 'e' to edit the selected item, or 'c' for a command prompt.
```

However, in this example you are more interested in the second serial 
console connections (```/dev/pts/3```) because the CentOS 7 Linux 
Installer output will be displayed in there -- In the second new shell, 
start the second minicom. 

```
$ minicom --baudrate=19200 --ptty=/dev/pts/3
```

```
Welcome to minicom 2.7.1

OPTIONS: I18n
Compiled on Aug 13 2018, 16:41:28.
Port /dev/ttyS1

Press CTRL-A Z for help on special keys
```


At the bottom of minicom's screen:

```
CTRL-A Z for help | 19200 8N1 | NOR | Minicom 2.7.1 | VT102 | Offline | ttyS1
```

**NOTE:**   
You might need to press  Enter  to  refresh the screen in minicom.   


Start the OS install and finish installing CentOS.    

At the end of installation, the CentOS installer, Anaconda, 
displays the following:

```
[...]
      Installation complete.  Press return to quit

[anaconda] 1:main* 2:shell  3:log  4:storage-lo> Switch tab: Alt+Tab | Help: F1
```

Anaconda uses the **tmux** terminal multiplexer to display and control 
several windows you can use in addition to the main interface.

When you choose text mode installation, you start in virtual console 1 (tmux). 
The console running tmux has 5 available windows.  

**NOTE:** The keyboard shortcuts are two-part: first press Ctrl+b, then 
release both keys, and press the number key for the window you want to use.

Press Ctrl+b 2 to switch to interactive shell prompt with root 
privileges:  

```
[anaconda root@localhost ~]# 
```

Power off the system. 

```
[anaconda root@localhost ~]# poweroff
```

Start the virtual machine.

```
$ /usr/libexec/qemu-kvm \
 -drive format=raw,file=ttyS1disk4k.img \
 -global ide-hd.physical_block_size=4096 \
 -m 2G \
 -enable-kvm \
 -serial pty \
 -serial pty \
 -nographic
```

Log in to the guest virtual machine. 

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

guestvm login: root
Password:
```

You now have the anaconda kickstart configuration file, which you can use 
as a sample or a reference.

Usually I fold and then indent long lines when showing them in scripts, 
code and CLI outputs. In this case, I'm making an exception (for lines 
starting with 'network  --bootproto' and with 'user --groups=wheel').  

```
# cat /root/anaconda-ks.cfg                                   
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use text mode install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts=''
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=ens3 --gateway=192.168.80.56 --ip=192.168.80.3 --nameserver=192.168.80.200,192.168.80.210 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=guestvm

# Root password
rootpw --iscrypted $6$SYPpA<string_of_random_characters>
# System services
services --enabled="chronyd"
# Do not configure the X Window System
skipx
# System timezone
timezone America/Vancouver --isUtc
user --groups=wheel --name=dusko --password=$6$FgrE<string_of_random_characters> --iscrypted --gecos="dusko"
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=sda

%packages
@base
@core
@scientific
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
```

Some other configurations in the guest virtual machine: 

```
# cat /etc/fstab 

#
# /etc/fstab
# Created by anaconda on Sun Mar 12 05:48:28 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs   defaults    0 0
UUID=d6acae6c-9e23-4721-9180-722091f019d7 /boot xfs   defaults    0 0
/dev/mapper/centos-swap swap                    swap  defaults    0 0
```

```
# df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
devtmpfs                devtmpfs  908M     0  908M   0% /dev
tmpfs                   tmpfs     919M     0  919M   0% /dev/shm
tmpfs                   tmpfs     919M  8.5M  911M   1% /run
tmpfs                   tmpfs     919M     0  919M   0% /sys/fs/cgroup
/dev/mapper/centos-root xfs        17G  1.5G   16G   9% /
/dev/sda1               xfs      1014M  153M  862M  16% /boot
tmpfs                   tmpfs     184M     0  184M   0% /run/user/0
```

Confirm that both serial devices, COM1 (in *nix: ttyS0) 
and COM2 (in *nix: ttyS1), are created in the guest VM:

```
# dmesg | grep tty 
[  0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.10.0-1160.el7.x86_64 root=/d8
[  0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.10.0-1160.el7.x86_64 8
[  0.000000] console [ttyS1] enabled
[  0.808863] 00:04: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[  0.832473] 00:05: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
```


Next step is to set up serial terminal in the guest OS.   


#### Set Up a Serial Terminal and Console (in CentOS 7/RHEL 7)  

As per Red Hat (https://access.redhat.com/articles/7212):   
> It is sometimes helpful to have a serial console for debugging purposes 
> and a serial terminal for headless operation.  A serial console will 
> send all console output to the serial port.  A serial terminal, if 
> properly configured, also lets you log on to the system via the serial 
> port as a remote terminal.  You can set up both or just one.  
> 
> 
> ##### About Serial Console Kernel Option Configuration  
> 
> First, to get the kernel to output all console messages to the serial 
> port you need to pass the **console=ttyS0** parameter to the kernel at 
> boot time.  This is usually done via the bootloader; we'll be using 
> GRUB in our examples.  
> 
> **Note:**  The **primary** console for system output will be the 
> **last** console listed in the kernel parameters. For example: 
> ```console=tty0 console=ttyS0,115200``` 
> In this example, the serial console is the primary and the VGA console 
> tty0 is the secondary display.  This means messages from init scripts, 
> boot messages and critical warnings will go to the serial console since 
> it is the primary console,  If init script messages don't need to be 
> seen on the serial console, it should be made the secondary by swapping 
> the order of the console parameters:
> ```console=ttyS0,115200 console=tty0```  

Continuing with the setup of the guest virtual machine: you need to 
configure the system to send the console output to the serial port 
**ttyS1** at a baud rate of 19200, as well as to send the output to the 
regular console or "screen" **tty1**.    

```
# cp -i /etc/default/grub /tmp/grub.original.bkp 
```

```
# vi /etc/default/grub
```

```
# diff \
 --unified=0 \
 /tmp/grub.original.bkp \
 /etc/default/grub
--- /tmp/grub.original.bkp      2022-03-12 22:46:58.157447335 -0700
+++ /etc/default/grub   2022-03-12 22:48:01.959447335 -0700
@@ -5,3 +5,4 @@ 
-GRUB_TERMINAL="serial console"
-GRUB_SERIAL_COMMAND="serial --unit=1 --speed=19200"
-GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap console=ttyS1,19200"
+GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS1,19200"                  
+GRUB_TERMINAL="console serial"    
+GRUB_SERIAL_COMMAND="serial --speed=19200 --unit=1 --word=8 --parity=no --stop=1"
+GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap console=tty1 console=ttyS1,19200"
```

The system that this test guest VM image is for is a BIOS-based server 
so the ```grub2-mkconfig``` command to update GRUB2 is BIOS-specific:  

```
# grub2-mkconfig -o /boot/grub2/grub.cfg
```

(On UEFI-based machines it would be: 
```grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg```)


**NOTE:**   
The **main kernel console** is the one listed **first** in 
```/sys/class/tty/console/active```, which is the *last* one 
listed on the *kernel command line*.

```
# cat /sys/class/tty/console/active
ttyS1
```

(After reboot, the GRUB2 changes will take effect and  
```/sys/class/tty/console/active``` will show: ```tty1 ttyS1```)    

Configure a serial getty with the needed parameters so that it starts on boot.

```
# cp -i \
 /usr/lib/systemd/system/serial-getty@.service \
 /etc/systemd/system/serial-getty@ttyS1.service
```

```
# vi /etc/systemd/system/serial-getty@ttyS1.service
```

```
# diff \
 --unified=0 \
 /usr/lib/systemd/system/serial-getty@.service \
 /etc/systemd/system/serial-getty@ttyS1.service
--- /usr/lib/systemd/system/serial-getty@.service    2020-10-01 10:08:50.0000
+++ /etc/systemd/system/serial-getty@ttyS1.service   2022-03-12 22:36:36.5400
@@ -23 +23 @@
-ExecStart=-/sbin/agetty --keep-baud 115200,38400,9600 %I $TERM
+ExecStart=-/sbin/agetty --keep-baud 115200,38400,19200,9600 %I $TERM
```

Create a symlink.

```
# ln -s \
 /etc/systemd/system/serial-getty@ttyS1.service \
 /etc/systemd/system/getty.target.wants/
```

Reload the daemon and start the service. 

```
# systemctl daemon-reload
# systemctl enable serial-getty@ttyS1.service
# systemctl start serial-getty@ttyS1.service
```

This creates a unit file that is specific to serial port ttyS1 so that 
you can make specific changes to this port and this port only.


Restart the guest virtual machine. 

```
# reboot
```

If you keep shells with **minicom** connections running, the CentOS 
boot menu now appears in both shells: the one with minicom connected
to output of QEMU char device redirected to the first serial 
device /dev/pts/2 (```minicom --baudrate=19200 --ptty=/dev/pts/2```):


```
   CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
   CentOS Linux (0-rescue-b8fcd7b7f02249dc9e6a3d2a443a3b92) 7 (Core)


   Use the ^ and v keys to change the selection.
   Press 'e' to edit the selected item, or 'c' for a command prompt.
The selected entry will be started automatically in 4s.
```

and the other shell with 
minicom connected to output of QEMU char device redirected to the second 
serial device /dev/pts/3 (```minicom --baudrate=19200 --ptty=/dev/pts/3```): 

```
   CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
   CentOS Linux (0-rescue-b8fcd7b7f02249dc9e6a3d2a443a3b92) 7 (Core)


   Use the ^ and v keys to change the selection.
   Press 'e' to edit the selected item, or 'c' for a command prompt.
The selected entry will be started automatically in 4s.
```

After the selected boot menu entry starts, output is displayed only 
in the second separate shell (in this example: ```minicom --baudrate=19200 --ptty=/dev/pts/3```):

Log in to the guest virtual machine.

```
CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

guestvm login: root 
```

Confirm that the serial getty service has been started 
and that it's running.  

```
# systemctl is-enabled serial-getty@ttyS1.service
enabled
```

```
# systemctl is-active serial-getty@ttyS1.service
active
```

```
# cat /sys/class/tty/console/active                          
tty1 ttyS1
```

When you are done with exploring the guest VM, power it off. 

```
# poweroff
```


After you have finished installing and setting up the OS in the guest, 
use the following to start the guest VM again:

```
$ /usr/libexec/qemu-kvm \
 -drive format=raw,file=ttyS1disk4k.img \
 -global ide-hd.physical_block_size=4096 \
 -m 2G \
 -enable-kvm \
 -serial pty \
 -serial pty \
 -nographic
```

Output (which shows the QEMU monitor): 

```
QEMU 4.2.0 monitor - type 'help' for more information
(qemu) char device redirected to /dev/pts/2 (label serial0)
char device redirected to /dev/pts/3 (label serial1)

(qemu)
```

Then, from a separate shell instance, start ```minicom``` and connect 
to the serial console that was configured for console redirection.
In this case it's the second serial device, ttyS1, redirected by qemu 
and reported by the QEMU monitor as ```/dev/pts/3```. 

```
$ minicom --baudrate=19200 --ptty=/dev/pts/3
```

The above command for starting the guest VM can be simplified a bit 
(no need for '-global ide-hd.physical_block_size=4096'), 
as the filesystem has already been configured with block size of 4K). 
Also, the '-serial null' disables COM1 (ttyS0), redirects console to 
serial on COM2 (ttyS1):

```
$ /usr/libexec/qemu-kvm \ 
 -drive format=raw,file=ttyS1disk4k.img \
 -m 2G \
 -serial null \
 -serial pty \
 -nographic

QEMU 4.2.0 monitor - type 'help' for more information
(qemu) char device redirected to /dev/pts/0 (label serial1)
```

Then, connect to the serial console reported by qemu as serial1, 
in this case reported by the QEMU monitor as ```/dev/pts/0```. 

```
$ minicom --baudrate=19200 --ptty=/dev/pts/0
```

---

Yet another version of a qemu command for starting a QEMU VM image 
containing an OS configured to redirect output to second serial text 
console on **ttyS1 (COM2)** -> Use *'-serial null'* to disable 
COM1 (ttyS0) and the QEMU monitor, and combine that with *'mon:stdio'* to 
redirect output on COM2 (ttyS1) to the QEMU monitor (a.k.a. QEMU console): 

```
$ /usr/libexec/qemu-kvm \
 -drive format=raw,file=ttyS1disk4k.img \
 -m 2G \
 -serial null \
 -serial mon:stdio \
 -nographic
```

```
  CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
  CentOS Linux (0-rescue-5003bb903e814f84ad84b479956f01d0) 7 (Core)



  Use the ^ and v keys to change the selection.
Press 'e' to edit the selected item, or 'c' for a command prompt.   

---- snip ----

CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64

guestvm login: 
```

---

### APPENDIX

#### Connect Serial Output To a TCP Port in QEMU Backend 

From:   [https://stackoverflow.com/questions/66214257/qemu-connecting-to-specific-guest-uart-device](https://stackoverflow.com/questions/66214257/qemu-connecting-to-specific-guest-uart-device)    

> If you pass multiple -serial options to QEMU they will be interpreted 
> as defining what you want to do for UARTs 0, 1, 2, etc. 
> So for example "-serial stdio -serial tcp::4444,server" will send 
> UART 0 to your terminal and connect UART 1 to a TCP server on port 
> 4444, which you can then connect to with netcat or similar utility.

Here's an example of starting QEMU with an image of an OS whose serial 
console is redirected to TCP port 4321:

```
$ /usr/libexec/qemu-kvm \
 -drive format=raw,file=ttyS1disk4k.img \
 -m 2G \
 -serial pty \
 -serial tcp::4321,server \
 -nographic

QEMU 4.2.0 monitor - type 'help' for more information
(qemu) char device redirected to /dev/pts/0 (label serial0)
qemu-kvm: -serial tcp::4321,server: info: QEMU waiting for connection on: 
  disconnected:tcp:0.0.0.0:4321,server
```

Then, to connect with telnet:

```
$ telnet 127.0.0.1 4321
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.

guestvm login: root
Password: WillBeInClearText
```

Or, to connect with nc (netcat):


```
$ nc 127.0.0.1 4321

CentOS Linux 7 (Core)
Kernel 3.10.0-1160.el7.x86_64 on an x86_64


guestvm login: root
root
Password: WillBeInClearText
```


#### How to Get SSH Access to a QEMU Guest

Install CentOS 7 Linux VM in QEMU:


```
$ /usr/libexec/qemu-kvm \
 -cdrom /tmp/CentOS-7-x86_64-Minimal-2009-CUSTOM.iso \
 -hda abnodevm.qcow2 \
 -m 2G \
 -boot d \
 -enable-kvm \
 -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22 \
 -nographic
```

**NOTE:**   
This worked when I configured DHCP in the guest VM.   

Start the VM.

```
$ /usr/libexec/qemu-kvm \
 -hda abnodevm.qcow2 \
 -m 2G \
 -enable-kvm \
 -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22 \
 -nographic
```

From another shell instance in the host, connect to the guest VM.  

```
$ ssh localhost -p 5555
```

---

#### Word Soup

> CentOS 7/RHEL 7 installation through serial console, CentOS Installation 
> without VGA Console, How to remote install CentOS/RHEL 7 using a rescue 
> image like GRML, Remote Installation of the FreeBSD Operating System 
> Without a Remote Console, SOL (Serial Over LAN), 
> ipmitool - (IP Management Interface) tool, BMC - a.k.a an IPMI controller    
> 
> IBM MM (Management Module), remote management, 
> KVM (Keyboard - Video - Mouse), Virtualization, QEMU emulator, 
> KVM (Kernel-based Virtual Machine) 
> 
> qemu> prompt
> 
> SYSLINUX / ISOLINUX / PXELINUX, boot, GRUB (Legacy GRUB), GRUB 2 
> iPXE
> Kickstart
> dd
> guestfish
> 
> xCAT
> 
> bootloader chainloading
> headless VNC
> Ultimate Deployment Applicance
> 
> dmesg
> tty tty0 ttyS0 tty1 ttyS1 
> 

---

**REFERENCES:**  

[Using a Serial Console with Linux, GRUB, SysLinux + Understanding Serial Configuration](https://www.privex.io/articles/using-serial-sol-config/)   
(Retrieved on Mar 12, 2022)   

[How to remote install CentOS/RHEL 7 using a rescue image like GRML?](https://unix.stackexchange.com/questions/164289/how-to-remote-install-centos-rhel-7-using-a-rescue-image-like-grml)  
(Retrieved on Mar 12, 2022)  

[Out-of-band management](https://en.wikipedia.org/wiki/Out-of-band_management)    
(Retrieved on Mar 12, 2022)   

[IBM BladeCenter](https://en.wikipedia.org/wiki/IBM_BladeCenter)     
(Retrieved on Mar 12, 2022)    

[IBM Remote Supervisor Adapter or Integrated Management Module (IMM; IBM's out-of-band management implementation)](https://en.wikipedia.org/wiki/IBM_Remote_Supervisor_Adapter)     
(Retrieved on Mar 12, 2022)   

[Baseboard Management Controller, a microcontroller on computer motherboards](https://en.wikipedia.org/wiki/Baseboard_Management_Controller)   
(Retrieved on Mar 12, 2022)   

[Intelligent Platform Management Interface (IPMI)](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface)    
(Retrieved on Mar 12, 2022)   

**My comment:** HP iLO would be easier but I'm restricted by my environment 
with (a legacy) IBM MM (Management Module). For example, the website in 
the link below shows that with the version of iLO from that website it's 
possible to mount CD-ROM to http; iLO shows which serial port is active 
(COM1, COM2,...), etc.   
[HP ILO VSP: CentOS 7/RHEL 7 Installation through Serial Console](http://stivesso.blogspot.com/2015/09/hp-ilo-vsp-centos-7rhel-7installation.html)   
(Retrieved on Mar 12, 2022)   

[CentOS Mirror - PXE Installer BOOT Images - initrd.img and vmlinuz](http://mirror.centos.org/centos/7.9.2009/os/x86_64/images/pxeboot/)   
(Retrieved on Mar 12, 2022)   

[QEMU and serial ports on the guest OS](https://serverfault.com/questions/872238/qemu-and-serial-ports-on-the-guest-os)   
(Retrieved on Mar 12, 2022)   

[QEMU doesn't create a second serial port (Ubuntu x86-64 guest and host)](https://stackoverflow.com/questions/52801787/qemu-doesnt-create-a-second-serial-port-ubuntu-x86-64-guest-and-host)    
(Retrieved on Mar 12, 2022)   

[ttyO ports do not have the good port address on QEMU 1.4.0 running image for beagleboard-xm](https://unix.stackexchange.com/questions/78511/ttyo-ports-do-not-have-the-good-port-address-on-qemu-1-4-0-running-image-for-bea)  
(Retrieved on Mar 12, 2022)   
> The problem is on the host side:
> 
> You should use Pseudo-terminals (-serial pty) instead of 
> connecting to "real" char-devices (-chardev tty,...).
> 
> qemu displays the pty /dev/pts/xx which it actually uses. You can now use 
> this pty as a normal serial port from your host.
> 
> You can repeat this option to get more ptys connected to /dev/ttyS[0-*] on 
> the guest (if you use -serial stdio, it is /dev/ttyS0 on the guest, the 
> first pty is then /dev/ttyS1).


[CentOS Installation without VGA Console](http://wandin.net/dotclear/index.php?post/2010/03/16/CentOS-Installation-without-VGA-Console)   
(Retrieved on Mar 12, 2022)   

[IBM BladeCenter - Serial Over LAN (SOL) Setup Guide](https://bladecenter.lenovofiles.com/help/topic/com.lenovo.bladecenter.advmgtmod.doc/kp1bd_pdf.pdf)   
(Retrieved on Mar 12, 2022)   

[Connecting QEMU/KVM virtual machines via serial port](https://bauermann.wordpress.com/2013/09/04/connecting-qemukvm-virtual-machines-via-serial-port/)   
(Retrieved on Mar 12, 2022)   

[Headless VNC Install Disk](https://wiki.centos.org/TipsAndTricks/VncHeadlessInstall)   
(Retrieved on Mar 12, 2022)   

[centos_bstick.sh](https://gist.github.com/vkanevska/fd624f708cde7d7c172a576b10bc6966)  
(Retrieved on Mar 12, 2022)   

[QEMU - Wikipedia](https://en.wikipedia.org/wiki/QEMU)  
(Retrieved on Mar 12, 2022)   

[How to run qemu with -nographic and -monitor but still be able to send Ctrl+C to the guest and quit with Ctrl+A X?](https://stackoverflow.com/questions/49716931/how-to-run-qemu-with-nographic-and-monitor-but-still-be-able-to-send-ctrlc-to)   
(Retrieved on Mar 12, 2022)    

[How to pass Ctrl-C to the guest when running qemu with -nographic?](https://unix.stackexchange.com/questions/167165/how-to-pass-ctrl-c-to-the-guest-when-running-qemu-with-nographic/436321#436321)   
(Retrieved on Mar 12, 2022)    

[Installation Guide - Installing Using Anaconda - Consoles and Logging During the Installation -- CentOS Documentation](https://docs.centos.org/en-US/centos/install-guide/Consoles_Logs_During_Install_x86/)    
(Retrieved on Mar 12, 2022)    

[Red Hat Product Documentation - Red Hat Enterprise Linux - 7 - Installation Guide - Consoles and Logging During the Installation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-consoles-logs-during-installation-x86)    
(Retrieved on Mar 12, 2022)    

[Making a QEMU disk image bootable with GRUB](https://web.archive.org/web/20171014140837/http://nairobi-embedded.org/making_a_qemu_disk_image_bootable_with_grub.html)   
(Retrieved on Mar 12, 2022)     

[CentOS7 – Serial Console And Flow Control](https://centosfaq.org/centos/centos7-serial-console-and-flow-control/)   
(Retrieved on Mar 12, 2022)     

[QEMU serial console](https://www.uni-koeln.de/~pbogusze/posts/QEMU_serial_console.html)   
(Retrieved on Mar 12, 2022)     

[Creating a CentOS text-only CD / DVD](http://hintshop.ludvig.co.nz/show/centos-text-cd/)   
(Retrieved on Mar 12, 2022)     

[Make a custom CentOS-7 or RHEL-7 CD With kicktart File](https://www.facebook.com/notes/linux-only/make-a-custom-centos-7-or-rhel-7-cd-with-kicktart-file/1142994982390559)   
(Retrieved on Mar 12, 2022)     

[During install of custom RHEL 6 ISO, mediacheck errors with "Unable to find the checksum in the image. This probably means the disc was created without adding the checksum."](https://access.redhat.com/solutions/655603)    
(Retrieved on Mar 12, 2022)     

[Working with ISO Images Red Hat Enterprise Linux 7 | Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/anaconda_customization_guide/sect-iso-images)   
(Retrieved on Mar 12, 2022)     

[How to get SSH access to a guest - Network HOWTOs - QEMU Documentation - Networking](https://wiki.qemu.org/Documentation/Networking#How_to_get_SSH_access_to_a_guest)   
(Retrieved on Mar 12, 2022)     

[Archived | Using QEMU for cross-platform development](https://developer.ibm.com/tutorials/l-qemu-development/)   
(Retrieved on Mar 12, 2022)     

[#osdev - Operating System Development - IRC](https://libera.irclog.whitequark.org/osdev/2021-07-14)   
(Retrieved on Mar 12, 2022)     

[How does one set up a serial terminal and/or console in Red Hat Enterprise Linux?](https://access.redhat.com/articles/7212)   
(Retrieved on Mar 12, 2022)     

[systemd for Administrators, Part XVI](http://0pointer.de/blog/projects/serial-console.html)   
(Retrieved on Mar 12, 2022)     

[Sample Kickstart Configuration file](https://peterpap.net/index.php/Sample_Kickstart_Configuration_file)   
(Retrieved on Mar 12, 2022)     

---

