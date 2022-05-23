---
layout: post
title: "How To Create a Bootable FreeBSD ZFS Clone"
date: 2022-03-05 09:08:02 -0700 
categories: howto diagram graph graphviz plaintext text tex latex visualization documentation
---

OS: FreeBSD 13   
Shell:  csh  
Python version: 3.8.12  

---

**[TODO]**  Complete this page   

---

**Note:**   
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.  

---

Code for a mind map in [PlantUML](https://github.com/plantuml/plantuml/):

```
% cat zfsbootable.txt
@startmindmap

title Create a Bootable FreeBSD ZFS Machine Clone\n

' Based on
' https://ideashortcut.com/tutorial-convert-you-notes-into-a-wbs-and-gantt-charts-with-plantuml/
'   and
' https://forums.freebsd.org/threads/cloning-a-zfs-boot-disk-on-a-usb-drive.79687/
'   and
' https://github.com/mattjhayes/PlantUML-Examples/blob/master/docs/Diagram-Types/diagram-types.md

scale 0.85

skinparam ArrowColor DarkGrey

<style>
mindmapDiagram {
  node {
    Padding 15
    Margin 15
    BackGroundColor YellowGreen
    FontColor DarkSlateGrey
    LineColor White
    LineThickness 1.0
    MaximumWidth 320
  }
  rootNode {
    Padding 15
    Margin 15
    BackGroundColor YellowGreen
    FontColor DarkSlateGrey
    FontSize 18
    LineColor White
    LineThickness 1.0
  }
  leafNode {
    Padding 15
    Margin 15
    BackGroundColor LightGray
    FontColor DarkSlateGrey
    FontSize 15
    LineColor ForestGreen
    LineThickness 2.0
  }
  ' Styles to apply to tasks based on status:
  ' in progress (i)
  .i {
    BackgroundColor SkyBlue
  }
  ' completed (c)
  .c {
    BackgroundColor LightSlateGray
    FontStyle italic
    FontColor DarkGray
  }
  ' urgent (u)
  .u {
    BackgroundColor OrangeRed
    FontStyle bold
  }
  ' delegated (d)
  .d {
    BackgroundColor Gold
  }
}
</style>

' Legend colours need to be updated manually :-(
legend
|<back:LightGray><b>Not Started.</b></back>|
|<back:SkyBlue><b>In Progress.</b></back>|
|<back:LightSlateGrey><i>Completed     .</i></back>|
|<back:OrangeRed><b>Urgent        .</b></back>|
|<back:Gold><b>Delegated   .</b></back>|
|<back:YellowGreen><b>Branch        .</b></back>|
|<back:LightGray><b>[*] The same name as before not required but convenient, unless you have bootfs set in /boot/loader.conf.</b></back>|
|<back:LightGray><b>[**] If you are creating the same pool and the rest as subsets of that, you need to force the zfs receive in order to tell it to overwrite your existing pool.</b></back>|
|<back:LightGray><b>[***] On newer installs, this is zroot/ROOT/default or similar.</b></back>|
endlegend

* Full\nsystem\nrestore\nto a\nfresh\ndrive
** Root on ZFS install
** Cloning
** gpart(8)
** dd(1)
** Bare metal backup/restore
** ZFS snapshots
*** zfs send
**** on trusted: nc(1)
**** on untrusted: ssh(1)
*** zfs receive
*** beadm/bectl
**** Boot pool name: zroot
**** Boot BE parent\ndataset name: ROOT
**** Boot datasets:\nROOT/tmp,\nROOT/var/tmp,\nROOT/default
**** **/usr** and **/var** filesystems have\n**canmount** property set to **off**
***** /usr and /var are placed \non the / dataset the\nzroot/ROOT/default BE
** Full\nsystem\nrestore\nto a\nfresh\ndrive
*** Capture the root pool properties\n zpool get all rpool <<c>>
*** GPT layout <<i>>
**** Manually create GPT
*** Boot loader <<u>>
**** Write the boot loader
*** Sufficient size on destinaiton
*** Boot off the\nFreeBSD Live CD/USB
**** Get networking up\nand running
**** Create the new zpool [*]
**** zfs receive the backup [**]
**** Use zpool(1) to set bootfs\nproperty properly [***]
**** Reboot
**** Use gptzfsboot(8)\nto install bootcode
**** Reboot
@endmindmap
```


Send a POST request using [HTTPie](https://httpie.org/), [HTTP Clients - Kroki documentation](https://docs.kroki.io/kroki/setup/http-clients/) to generate the mind map image.      

```
% http \
 http://localhost:8000/ \
 diagram_type='plantuml' \
 output_format='png' \
 diagram_source='@zfsbootable.txt' \
 > zfsbootable.png
```

![Displaying a png image of a mind map created with PlantUML invoked via Kroki](/assets/img/zfsbootable.png "Displaying a png image of a mind map created with PlantUML invoked via Kroki")  


Alternatively, you can display the image in a web browser.  


```
% cat \
 zfsbootable.txt | \
 python3.8 -c \
 "import sys; import base64; import zlib; \
 print(base64.urlsafe_b64encode(zlib.\
 compress(sys.stdin.read().encode('utf-8'), 9)).decode('ascii'))"
```

Output:

```
eNq9V11v2zYUfdev4FtTobLaDl2zIDA6J01QIG2COEGxzXugRFriQpEaP5I6a__7zqVkx-mSod3DjNggLy_PPbxfZN74wF3olB
---- snip ----
```


Copy and paste the output to your web browser:

```
http://localhost:8000/plantuml/svg/eNq9V11v2zYUfdev4FtTobLaDl2zIDA6J01QIG2COEGxzXugRFriQpEaP5I6a_
---- snip ----
```


```
% cat bootable_os_zfs_activity_diagram.txt
@startuml
' Based on https://waddles.org/2009/11/17/replicating-zfs-root-disks/
' and
' https://github.com/mattjhayes/PlantUML-Examples/blob/master/docs/Diagram-Types/diagram-types.md

skinparam shadowing false

title Create a Bootable FreeBSD ZFS Clone\n- Activity Diagram -\n

start
:Verify status;
:Create recursive ZFS root pool (rpool) snapshot;
:Insert and label new disks;
:Create partition tables;
:Create new zpool;
:Replicate pool's dataset;
:Replicate remaining datasets;
:Set mountpoints;
:Set bootfs property;
:Export the new pool;
:Install boot blocks to both disks;

:Target System
Transfer disks and boot failsafe;

:Import zpool as rpool;
:Export the zpool;

:Boot to single user mode;
:Unconfigure the system;
:Reconfigure the system;
: Cleanup;

stop
@enduml
```

```
% http \ 
 http://localhost:8000/ \
 diagram_type='plantuml' \
 output_format='png' \
 diagram_source='@bootable_os_zfs_activity_diagram.txt' \
 > bootable_os_zfs_activity_diagram.png
```

![Displaying a png image of an activity diagram created with PlantUML invoked via Kroki](/assets/img/bootable_os_zfs_activity_diagram.png "Displaying a png image of an activity diagram created with PlantUML invoked via Kroki")  


