---
layout: post
title: "Use SSH Public/Private RSA or DSA key (SSH Passwordless Operation)" 
date: 2021-10-02 20:53:02 -0700 
categories: ssh unix sysadmin 
---

Updated: Sep 25, 2024


**Note:**
In code excerpts and examples, the long lines are folded and then 
indented to make sure they fit the page.

Components of SSH Used:
- ssh-keygen(1) -- authentication key generation, management and conversion
- ssh-agent(1)  -- authentication agent

Local environment: bash shell, Red Hat Enterprise Linux 7.3 64-bit, 
user's home directory: /web.
```sh
$ ps $$
  PID TTY      STAT   TIME COMMAND
11123 pts/1    Ss     0:00 -bash

$ cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.3 (Maipo)

$ arch
x86_64

$ uname -a
Linux local.example 3.10.0-514.el7.x86_64 #1 SMP
  Wed Oct 19 11:24:13 EDT 2016 x86_64 x86_64 x86_64
  GNU/Linux

$ grep user1 /etc/passwd
user1:x:1000:48::/web:/bin/bash
```

Before setting up passwordless SSH, you are prompted for a password when 
logging in to the remote system:
```sh
$ ssh user1@remote.example
Password:
```

## Generating the Key Pair

The first step is to create your public- and 
private-key pair on your local machine.

The following command creates a 4,096-bit RSA key pair 
and prompts you for a passphrase (which you can leave blank).

```sh
$ ssh-keygen -t rsa -b 4096
```

Output (the key fingerprint obfuscated):
```sh
Generating public/private rsa key pair.
Enter file in which to save the key (/web/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /web/.ssh/id_rsa.
Your public key has been saved in /web/.ssh/id_rsa.pub.
The key fingerprint is:
ef:94:ab:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd user1@local.example
The key's randomart image is:
---- snip ----
```

You can place the public key file in any account on any remote machine 
running the SSH server (deamon), usually named _sshd_.  Your private key 
on the local machine allows you access to the remote machines.

To allow access to an account on a remote system, place the content of 
the public key file from the local system (~/.ssh/id_rsa.pub) in 
~/.ssh/authorized_keys file on the remote system.  The file contains one 
public key per line in its  ASCII representation.  If the file does not 
exist, simply make a copy of your public key file (from the local system).

If the account on the remote machine doesn't have ~/.ssh directory, 
create it by running the following on the remote machine:
```sh
$ mkdir -p ~/.ssh
$ chmod 0700 ~/.ssh
```

Run the following command on your local machine:
```sh
$ scp ~/.ssh/id_rsa.pub user1@remote.example:.ssh/authorized_keys
```

If you need to add a second key, append it to the file.

On the remote machine:
```sh
$ chmod 0600 ~/.ssh/authorized_keys
```

After you've set up passwordless SSH, logging in from the local machine 
to the remote system is direct, that is, without being prompted for 
the password:
```sh
$ ssh user1@remote.example

$ hostname
remote.example
```

**NOTE:** It is recommended that you create **separate** SSH key pairs for **each** *of the services* you are using because if a private key is compromised, only one service would be possibly affected and require SSH key change.

If you already have `id_rsa` key file, running `ssh-keygen` will overwrite that key (it will ask for confirmation before overwriting it).  Since `id_rsa` is the default name for RSA key type, you can have as many keys as you want with any names you want.  You can specify the output file name by adding `-f` option.  You can also specify the type and length of the key if you want.  

SSH keys for user authentication are usually stored in the user's .ssh directory under the home directory, that is, `~/.ssh` but in enterprise environments, the location is often different.  The default key file name depends on the algorithm, in the example above when using the default RSA algorithm it was `id_rsa`.  It could also be, for example, `id_dsa` or `id_ecdsa`.


**[TODO]**  Complete this section

ODAVDE

From the man page for `ssh-keygen(1)` on FreeBSD 14 with OpenSSH version OpenSSH_9.5p1 and [https://www.ssh.com/academy/ssh/keygen](https://www.ssh.com/academy/ssh/keygen).

OpenSSH supports the following key algorithms for authentication keys:
* rsa - the default key size for is 3072 bits; 4096 bits is better.  Choosing a different algorithm may be advisable.  It is quite possible the RSA algorithm will become practically breakable in the foreseeable future.  All SSH clients support this algorithm.
* ecdsa - a new Digital Signature Algorithm using elliptic curves.  This is probably a good algorithm for current applications.  Only three key sizes are supported: 256, 384, and 521 bits.  It's recommended to always use it with 521 bits.  Most SSH clients now support this algorithm.
* ed25519 - this is a new algorithm added in OpenSSH.  Support for it in clients is not yet universal.

References: [https://community.atlassian.com/t5/Bitbucket-questions/SSH-Keygen-invalidates-existing-SSH-keys/qaq-p/1289261](https://community.atlassian.com/t5/Bitbucket-questions/SSH-Keygen-invalidates-existing-SSH-keys/qaq-p/1289261), [https://www.ssh.com/academy/ssh/keygen](https://www.ssh.com/academy/ssh/keygen).

     
DOOVDE

---

## References
(Retrieved on Sep 25, 2024)

* [SSH Keygen, invalidates existing SSH keys?](https://community.atlassian.com/t5/Bitbucket-questions/SSH-Keygen-invalidates-existing-SSH-keys/qaq-p/1289261)

* [How to Use ssh-keygen to Generate a New SSH Key?](https://www.ssh.com/academy/ssh/keygen)

* [Using ssh-keygen and sharing for key-based authentication in Linux](https://www.redhat.com/sysadmin/configure-ssh-keygen)

---

