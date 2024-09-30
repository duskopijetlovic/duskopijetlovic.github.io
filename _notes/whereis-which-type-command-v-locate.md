---
layout: page
title: "All Known Instances of Command and the Full Path of the Executable"
---

## FreeBSD 14 and C Shell (csh) 

```
% command -V ls
ls is /bin/ls
 
% type ls
ls is /bin/ls

% which ls
/bin/ls
 
% /usr/bin/which -a ls
/bin/ls

% whereis -a ls
ls: /bin/ls /usr/share/man/man1/ls.1.gz

% where ls
/bin/ls

% locate ls | grep -w bin | wc -l
      96

% locate ls | grep -w bin
/bin/ls
[ . . . ]
```

----

## RHEL (Red Hat Enterprise Linux) 8.5 and C Shell (csh)

```
$ command -V pbsnodes 
pbsnodes is /global/software/torque/x86_64/bin/pbsnodes

$ type -a pbsnodes
pbsnodes is /global/software/torque/x86_64/bin/pbsnodes
pbsnodes is /global/software/torque/x86_64/bin/pbsnodes

$ which pbsnodes
/global/software/torque/x86_64/bin/pbsnodes

$ /usr/bin/which -a pbsnodes
/global/software/torque/x86_64/bin/pbsnodes
/global/software/torque/x86_64/bin/pbsnodes

$ whereis pbsnodes
pbsnodes: /opt/torque/bin/pbsnodes /global/software/torque/x86_64/bin/pbsnodes

$ where pbsnodes
/global/software/torque/x86_64/bin/pbsnodes
/global/software/torque/x86_64/bin/pbsnodes

$ locate pbsnodes | grep bin
/global/software/torque/x86_64/bin/pbsnodes
/global/software/torque32/x86/bin/pbsnodes
/global/software/torque_tmp/x86_64/bin/pbsnodes
/global/software/torque_tmp/x86_64/bin/pbsnodestat
/global/software/torque_tmp/x86_64/bin/xpbsnodes
/opt/torque/bin/pbsnodes
```

----

## RHEL (Red Hat Enterprise Linux) 8.3 and Bash Shell (bash)


```
# command -V rsync; type -a rsync; which -a rsync; /usr/bin/which -a rsync; whereis rsync 
rsync is /usr/bin/rsync
rsync is /usr/bin/rsync
/usr/bin/rsync
/usr/bin/rsync
rsync: /usr/bin/rsync /usr/share/man/man1/rsync.1.gz
```

----

