---
layout: post
title: "Sendmail SMTP AUTH Running As a Client [HOWTO]"
date: 2022-11-12 06:50:18 -0700 
categories: sendmail smtp mta mailserver cli terminal shell freebsd sysadmin reference 
---

---

Also known as:   
Sendmail SMTP AUTH client with SSL-or-TLS over port 465
(submissions port) using Stunnel **[<sup>[ 1 ](#footnotes)</sup>]**   

---

### Word Cloud

<!-- Markdown extension for really small tiny text? -->
<!--   https://meta.stackexchange.com/questions/53800/markdown-extension-for-really-small-tiny-text -->

<sub><sup>
SMART_HOST, smart host, port 465, Implicit TLS submission on port 465,
TLS (Transport Layer Security), SSL (Secure Sockets Layer),
OpenSSL library, Base64,
SMTP (Simple Mail Transfer Protocol),  
SMTP AUTH, RFC2554 (ESMTP AUTH),
authentication, encryption, masquerading, relaying,
TCP, TCP/IP, networking, DNS, MX record, IANA (Internet Assigned Numbers
Authority),  
SASL (Simple Authentication and Security Layer), Cyrus SASL
library, sendmail, mailserver, postmaster, unix, CLI (command-line interface),
terminal, shell, csh, sh, FreeBSD, MTA (Mail Transfer Agent),  
MTA (Mail Transport Agent), MSP (Message Submission Program),
MSA (Mail Submission Agent), stunnel,    
SMTP/S [SMTPS (SMTP over SSL-or-TLS on port 465)], SMTPS client,
SMTPS (Simple Mail Transfer Protocol Secure)
</sup></sub>
**[<sup>[ 2 ](#footnotes)</sup>]**

---

OS:   
FreeBSD 13.1-RELEASE-p2 with *sendmail* 8.17.1, Shell: *csh*    

---

Setup requirements in this configuration: 
* Local *sendmail* server receives mails from local users or internal
  applications.
* After receiving the mail from local users or internal applications,
  this *sendmail* server:
  - relays the mail to your ISP (`your.isp.net`), if it's addressed
    to an external email address (sending a message to non local adresses);
  - relays the mail to local system, if it's addressed to a local user.
* The ISP's server accepts message submission on port 465 (Implicit TLS-or-SSL,
  aka Encrypted SMTP). **[<sup>[ 3 ](#footnotes)</sup>]**
  **[<sup>[ 4 ](#footnotes)</sup>]**

---

### Why This Approach Instead of Usual with SMART_HOST and RELAY_MAILER_ARGS? 

I tried this method and it worked but I couldn't make it work for local mail:

I configured *sendmail* with SMTPS (SMTP over SSL)/Implicit TLS submission
port 465 by using *stunnel* on my local machine (a local port; in my case,
`127.0.0.1:1465` to my smart host provider, `your.isp.net:465`) with
`SMART_HOST` and `RELAY_MAILER_ARGS` with `TCP $h 1465` in *submit.mc*
(*/etc/mail/freebsd.submit.mc* on FreeBSD) configuration file for MSP
(Mail Submission Program, which is a command-line *sendmail* that functions
as a Mail Submission Agent (MTA):

```
define(`SMART_HOST', `[127.0.0.1]')dnl
```

```
define(`RELAY_MAILER_ARGS', `TCP $h 465')dnl 
```

With *stunnel.conf*:

```
[smtps]
accept=127.0.0.1:1465
connect=your.isp.net:465
```

> The `A=` delivery agent equate is usually declared like `A=TCP $h`.
> The value in `$h` is the value returned by the `parse` rule set 0's `$@`
> operator and is usually the name of the host to which *sendmail* should connect. 
> During delivery the *sendmail* program expands this hostname into a possible
> list of MX records. (Unless (V8.8 and later) the `F=0` delivery agent flag
> is set (`F=0 (zero)`) or unless the hostname is surrounded by square brackets.)
> 
> The host (as `$h`) is usually the only argument given to `TCP` but `TCP`
> can accept two arguments, like this:
> 
> ```
> A=TCP hostlist port
> ```
> 
> The `port` is usually omitted and so defaults to 25.  However, a port number
> can be included to force *sendmail* to connect on a different port.


The *submit.mc* (*/etc/mail/freebsd.submit.mc*) also had:

```
LOCAL_RULE_0
R$* <@ $=w . $=m> $*    $#local $: $1      @my.local.domain

LOCAL_NET_CONFIG
R $* < @ $+ .$m. > $*   $#local $@ $2.$m $: $1 < @ $2.$m > $3
```

This configuration worked for nonlocal mail but it didn't work for local
delivery because messages for local users were relayed via smart host.
I made it work for local mail in this setup with masquerading but it was
making a round trip: local mail was delivered but to the smart host, which
is not ideal (e.g. no need for cron mails to go outside.)

**NOTE:**   
When I configured my workstation's  *sendmail* as a client to a different
smart host with STARTTLS port 587 (that is, with a different smart host
server that listens to port 587 for STARTTLS), it worked fine for both
local and nonlocal mail.

---

## TL;DR Version

For **detailed** instructions (**non tl;dr** version), refer to the
section further below [How To Setup Sendmail to Act As a Client with SMTP AUTH](#how-to-setup-sendmail-to-act-as-a-client-with-smtp-auth). 


The system-built *sendmail*:  `/usr/libexec/sendmail/sendmail`

The package-installed *sendmail*: `/usr/local/sbin/sendmail`

From the man page for `mailwrapper(8)`:
> The *mailwrapper* program is designed to replace */usr/sbin/sendmail* and to
> invoke an appropriate MTA (Mail Transfer Agent) based on configuration
> information placed in
> *${LOCALBASE}/etc/mail/mailer.conf* (LOCALBASE=*/usr/local*)
> **[<sup>[ 5 ](#footnotes)</sup>]** falling back on */etc/mail/mailer.conf*.
> This permits the administrator to configure which MTA is to be invoked on
> the system at run time.

```
$ cat /usr/local/etc/mail/mailer.conf
sendmail        /usr/local/sbin/sendmail
send-mail       /usr/local/sbin/sendmail
mailq           /usr/local/sbin/sendmail
newaliases      /usr/local/sbin/sendmail
hoststat        /usr/local/sbin/sendmail
purgestat       /usr/local/sbin/sendmail
```

```
$ cat /etc/mail/mailer.conf
sendmail        /usr/local/sbin/sendmail
send-mail       /usr/local/sbin/sendmail
mailq           /usr/local/sbin/sendmail
newaliases      /usr/local/sbin/sendmail
hoststat        /usr/local/sbin/sendmail
purgestat       /usr/local/sbin/sendmail
```


### Install Sendmail and Cyrus SASL Packages 

```
$ sudo pkg install cyrus-sasl cyrus-sasl-saslauthd`

$ printf %s\\n "pwcheck_method: saslauthd" | sudo tee /usr/local/lib/sasl2/Sendmail.conf

$ printf %s\\n 'saslauthd_enable="YES"' | sudo tee -a /etc/rc.conf

$ sudo pkg install sendmail

$ printf %s\\n 'SENDMAIL_CF_DIR=/usr/local/share/sendmail/cf' | sudo tee -a /etc/make.conf

$ printf %s\\n 'sendmail_enable="YES"' | sudo tee -a /etc/rc.conf
```


### Configure Sendmail Configuration Files - submit.cf and sendmail.cf

Modify  `/etc/mail/freebsd.submit.mc`.   
Changes:

```
define(`confLOG_LEVEL', `14')dnl

define(`SMART_HOST',`smartrelay:[127.0.0.1]')dnl
FEATURE(`authinfo',`hash /etc/mail/authinfo')dnl

dnl dnl MASQUERADE_AS(`domain.to.masquerade_as')dnl dnl
dnl dnl MASQUERADE_DOMAIN('fbsd1.home.arpa')dnl dnl
dnl # Uncomment the next line (with masquerade_envelope) if 
dnl # you want messages to be delivered to SMART_HOST. 
dnl dnl FEATURE(`masquerade_envelope')dnl
dnl dnl FEATURE(`masquerade_entire_domain')dnl dnl

dnl Disable SMTP AUTH on the loopback interface.
DAEMON_OPTIONS(`Name=NoMTA, Addr=127.0.0.1, M=EA')dnl

MAILER_DEFINITIONS
dnl 
dnl     LR0relayST (Local Rule 0 relay Single Token)
dnl For addresses with only a single token (e.g. a username):  dusko 
MLR0relayST,	P=[IPC], F=mDFMuXa8k, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
		T=DNS/RFC822/SMTP,
		A=TCP $h

dnl
dnl     LR0relayLH [Local Rule 0 relay Local (AND) Hostname]
dnl For addresses:  dusko@localhost, dusko@<hostname> (that is:  dusko@fbsd1.home.arpa)
MLR0relayLH,	P=[IPC], F=mDFMuXa8k, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
		T=DNS/RFC822/SMTP,
		A=TCP $h

dnl
dnl     smartrelay 
dnl For nonlocal (external) addresses; for example: dusko@some.external.domain
Msmartrelay,    P=[IPC], F=mDFMuXa8k, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
                T=DNS/RFC822/SMTP,
                A=TCP $h 1465

LOCAL_RULE_0
R$-	$#LR0relayST $@ $j $: $1 < @ $j. >
R$+ < @ $j. >	$#LR0relayLH $@ $j $: $1 < @ $j. >
```


**NOTE:**  In two lines below `LOCAL_RULE_0`,  
           there is a **tab** character before `#LR0relayST` and
           before `#LR0relayLH`.


Modify `/etc/mail/freebsd.mc`.   
Changes:

```
define(`confEBINDIR', `/usr/local/libexec')dnl
define(`UUCP_MAILER_PATH', `/usr/local/bin/uux')dnl

FEATURE(`nouucp',`reject')dnl

TRUST_AUTH_MECH(`DIGEST-MD5 CRAM-MD5 EXTERNAL GSSAPI LOGIN PLAIN')dnl
define(`confAUTH_MECHANISMS',`DIGEST-MD5 CRAM-MD5 EXTERNAL GSSAPI LOGIN PLAIN')dnl
define(`confDONT_BLAME_SENDMAIL',`GroupReadableSASLDBFile')dnl

LOCAL_RULESETS
SLocal_trust_auth
R$*     $: $&{auth_authen}
Rsmmsp  $# OK
```


**NOTE:**  In the two lines below `SLocal_trust_auth`, there is a **tab**
           character before `$:` and before `$#`.   


### Create the authinfo File for Storing AUTH Authentication Credentials

Create the `/etc/mail/authinfo` file (for storing AUTH authentication
credentials in a file separate from the *access* database).
  
You need to store the client's authentication credentials in that file
using the same `AuthInfo:` tag used in the *access* database, and you need
to make sure that the *authinfo* text file and database are not readable
by anyone except the **smmsp** user.

```
$ sudo vi /etc/mail/authinfo
$ sudo chown smmsp:smmsp /etc/mail/authinfo
$ sudo chmod 0640 /etc/mail/authinfo
```

```
$ sudo cat /etc/mail/authinfo
AuthInfo:[127.0.0.1] "U:smmsp" "I:dusko" "P:YourISPPassword" "M:LOGIN"
AuthInfo:127.0.0.1 "U:smmsp" "I:dusko" "P:YourISPPassword" "M:LOGIN"
```


### Install and Configure stunnel 

```
$ sudo pkg install stunnel
```

```
$ cat /usr/local/etc/stunnel/stunnel.conf
include = /usr/local/etc/stunnel/conf.d

[smarthost]
client = yes
accept = 127.0.0.1:1465 
connect = your.isp.net:465
```

```
$ printf %s\\n 'stunnel_enable="YES"' | sudo tee -a /etc/rc.conf

$ sudo service stunnel start
```

---
---


## How To Setup Sendmail to Act As a Client with SMTP AUTH 

**Sendmail** is the default MTA in FreeBSD base system (as of FreeBSD 13). 

FreeBSD 13 comes with *sendmail*; that is, in FreeBSD 13, *sendmail* is
in the base system (a.k.a. in the default setup of the base system).
That's why it's usually called the *system sendmail* (or the *system-built
sendmail*).  

--- 

**NOTE:**    
*dma(8)* (DragonFly Mail Agent) will **replace** *sendmail* as the
**default MTA** in **FreeBSD 14** **[<sup>[ 6 ](#footnotes)</sup>]**: 

[RELNOTES: document the switch from sendmail to dma](https://cgit.freebsd.org/src/commit/?id=4d184bd438)  (Author: Baptiste Daroussin <bapt at FreeBSD.org>  2022-11-07)

Related **[diff](https://cgit.freebsd.org/src/diff/?id=4d184bd438)**:   

```
diff --git a/RELNOTES b/RELNOTES
index 00d97ea54820..29db15f412dd 100644
--- a/RELNOTES
+++ b/RELNOTES
@@ -10,6 +10,9 @@ newline.  Entries should be separated by a newline.
 
 Changes to this file should not be MFCed.
 
+a67b925ff3e5:
+	The default mail transport agent is now dma(8) replacing sendmail.
+
 22893e584032:
 	L3 filtering on if_bridge will do surprising things which aren't
 	fail-safe, so net.link.bridge.pfil_member and
```

**mail: make The Dragonfly Mail Agent (dma) the default mta:**   
[FreeBSD source tree - mail: make The DragonFly Mail Agent (dma) the default mta.](https://cgit.freebsd.org/src/commit/?id=a67b925ff3e58b072a60b633e442ee1d33e47f7f) 

---


## SMTP AUTH Support - Sendmail in Base vs. Sendmail from Packages (Ports) in FreeBSD 13

Support for the SMTP extension AUTH, as defined by RFC2554 (ESMTP AUTH), 
was first included in *sendmail* beginning with V8.10.  

*Sendmail* provides SMTP AUTH via [Cyrus SASL (Simple Authentication and 
Security Layer) library](https://www.cyrusimap.org/sasl/). 
**[<sup>[ 7 ](#footnotes)</sup>]**


However, the system *sendmail* in FreeBSD 13 base doesn't support
SMTP AUTH; that is, it's not compiled and configured with the Cyrus SASL
library.

To add SMTP AUTH support to *sendmail* in FreeBSD 13, you can either: 
* re-compile the system *sendmail* with SASL support enabled, or
* install *sendmail* as a package since the package provided *sendmail*
  comes with SASL enabled by default

I chose to install *sendmail* from packages (instructions are further
down below). 


### Managing MTA (Mail Transfer Agent) in FreeBSD 13 with mailwrapper(8) 

FreeBSD 13 uses `mailwrapper(8)` program for managing MTA (Mail Transfer Agent)
software and invoking appropriate MTA based on configuration file.


From the man page for *mailwrapper*: 

```
The mailwrapper program is designed to replace /usr/sbin/sendmail and to
invoke an appropriate MTA based on configuration information placed in
${LOCALBASE}/etc/mail/mailer.conf falling back on /etc/mail/mailer.conf.

This permits the administrator to configure which MTA is to be invoked on
the system at run time.

[ . . . ]

FILES
Configuration for mailwrapper is kept in
${LOCALBASE}/etc/mail/mailer.conf or /etc/mail/mailer.conf.
/usr/sbin/sendmail is typically set up as a symbolic link to mailwrapper
which is not usually invoked on its own.
```

```
$ ls -lh /usr/sbin/sendmail
lrwxr-xr-x  1 root  wheel    11B Oct 31  2019 /usr/sbin/sendmail -> mailwrapper
```
 
```
$ file /usr/sbin/sendmail
/usr/sbin/sendmail: symbolic link to mailwrapper
```
 
```
$ file /usr/sbin/mailwrapper 
/usr/sbin/mailwrapper: ELF 64-bit LSB pie executable, x86-64, 
  version 1 (FreeBSD), dynamically linked, interpreter /libexec/ld-elf.so.1, 
  for FreeBSD 13.1, FreeBSD-style, stripped
```

```
$ command -v sendmail; type sendmail; which sendmail; whereis sendmail
/usr/sbin/sendmail
sendmail is /usr/sbin/sendmail
/usr/sbin/sendmail
sendmail: /usr/sbin/sendmail /usr/share/man/man8/sendmail.8.gz
```

The location of the system *sendmail* binary file shipped with FreeBSD 13
(provided in base) is `/usr/libexec/sendmail/sendmail`:

```
$ cat /usr/local/etc/mail/mailer.conf
# $FreeBSD$
#
# Execute the "real" sendmail program, named /usr/libexec/sendmail/sendmail
# 
# If dma(8) is installed, an example mailer.conf that uses dma(8) instead can
# can be found in /usr/share/examples/dma.
#
sendmail        /usr/libexec/sendmail/sendmail
mailq           /usr/libexec/sendmail/sendmail
newaliases      /usr/libexec/sendmail/sendmail
hoststat        /usr/libexec/sendmail/sendmail
purgestat       /usr/libexec/sendmail/sendmail
```

```
$ cat /etc/mail/mailer.conf
# $FreeBSD$
#
# Execute the "real" sendmail program, named /usr/libexec/sendmail/sendmail
#
# If dma(8) is installed, an example mailer.conf that uses dma(8) instead can
# can be found in /usr/share/examples/dma.
#
sendmail        /usr/libexec/sendmail/sendmail
mailq           /usr/libexec/sendmail/sendmail
newaliases      /usr/libexec/sendmail/sendmail
hoststat        /usr/libexec/sendmail/sendmail
purgestat       /usr/libexec/sendmail/sendmail
```


**NOTE:**   
From the man page for `mailwrapper(8)`:  
> The mailwrapper program is designed to replace `/usr/sbin/sendmail` and
> to invoke an appropriate MTA based on configuration information placed in
> `${LOCALBASE}/etc/mail/mailer.conf` (LOCALBASE=/usr/local)
> **[<sup>[ 5 ](#footnotes)</sup>]** falling back on `/etc/mail/mailer.conf`.
> This permits the administrator to configure which MTA is to be invoked
> on the system at run time.

An example `mailer.conf` that uses `dma(8)` instead of *sendmail*:

```
$ cat /usr/share/examples/dma/mailer.conf 
# $FreeBSD$

sendmail  /usr/libexec/dma
mailq     /usr/libexec/dma
```


### Install and Configure Cyrus SASL

Before installing it, check *sendmail* dependencies by using
the `pkq rquery` command.  [For details: `man pkg-rquery(8)`
(`pkg rquery` - query information from remote repositories)]:

```
$ pkg rquery '%dn' sendmail
cyrus-sasl-saslauthd
cyrus-sasl
```

The `-d0.1` (a.k.a. `-d0`) debugging switch tells *sendmail* to print 
information about its version.  The system-built *sendmail* version
(on FreeBSD 13) is V8.16.1:

```
$ /usr/libexec/sendmail/sendmail -d0 < /dev/null
Version 8.16.1
 Compiled with: DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PIPELINING SCANF STARTTLS TCPWRAPPERS TLS_EC TLS_VRFY_PER_CTX
                USERDB XDEBUG
 
============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================
      
Recipient names must be specified
```

The **base** *sendmail* in FreeBSD 13 is **not** compiled with the
**Cyrus SASL** library.

```
$ /usr/libexec/sendmail/sendmail -d0 < /dev/null | grep SASL
```

```
$ sendmail -d0 < /dev/null
Version 8.16.1
 Compiled with: DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PIPELINING SCANF STARTTLS TCPWRAPPERS TLS_EC TLS_VRFY_PER_CTX
                USERDB XDEBUG
 
============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================

Recipient names must be specified
```

On the other hand, the *sendmail* package (a.k.a. the packaged version
of *sendmail*) comes with **SASL** support (and it's also a slightly newer
version, V8.17.1 - versus V8.16.1 in FreeBSD 13 base). (As of Nov 12, 2022.) 

```
$ pkg search --regex ^sendmail
sendmail-8.17.1_5           Reliable, highly configurable mail transfer agent with utilities
sendmail-devel-8.17.1.20    Reliable, highly configurable mail transfer agent with utilities
```

```
$ pkg search --regex --full sendmail-8.17.1_5 | grep SASL
        SASL           : on
        SASLAUTHD      : on
```


Query the *sendmail* package and its SASL options.
[The `--query-modifier` option of the `pkg search` command displays
a list of the port options and their state (*on* or *off*) when the
package was built.]  

```
$ pkg search --query-modifier options sendmail-8.17.1_5 | grep SASL
        SASL           : on
        SASLAUTHD      : on
```

Make sure your hostname is set correctly in `/etc/rc.conf`.
This is what *sendmail* uses by default.

```
$ hostname
fbsd1.home.arpa
```

```
$ grep hostname /etc/rc.conf
hostname="fbsd1.home.arpa"
```

```
$ grep -v \# /etc/hosts
::1                     localhost localhost.my.domain
127.0.0.1               localhost localhost.my.domain
```


First, install *sendmail*'s dependencies, which are two Cyrus SASL packages:
*cyrus-sasl* (SASL itself) and *cyrus-sasl-saslauthd* (SASL authentication
server for Cyrus SASL).  (Refer to the beginning of this section, with  
the `pkg rquery` command listing *sendmail*'s dependencies.)

```
$ sudo pkg install cyrus-sasl cyrus-sasl-saslauthd
```

The *cyrus-sasl* port is compiled with a default `pwcheck_method` of `auxprop`. 

For directions on how to enable SMTP AUTH with the system *sendmail*, 
refer to Sendmail.README (`/usr/local/share/doc/cyrus-sasl2/Sendmail.README)`
included in *cyrus-sasl2* documentation: 

```
$ cat /usr/local/share/doc/cyrus-sasl2/Sendmail.README
How to enable SMTP AUTH with FreeBSD default Sendmail

1) Add the following to  /etc/make.conf:

    # Add SMTP AUTH support to Sendmail
    SENDMAIL_CFLAGS+=   -I/usr/local/include -DSASL=2
    SENDMAIL_LDFLAGS+=  -L/usr/local/lib
    SENDMAIL_LDADD+=    -lsasl2

2) Rebuild FreeBSD (make buildworld, ...)

3) Make sure that the pwcheck_method is correct in Sendmail.conf.

   Sendmail.conf (${PREFIX}/lib/sasl2/Sendmail.conf) is created by
   the cyrus-sasl2 ports during installation.  It may have
   pwcheck_method set to saslauthd by default.  Change this to what is
   appropriate for your site.

4) Add the following to your sendmail.mc file:

   dnl The group needs to be mail in order to read the sasldb2 file
   define(`confRUN_AS_USER',`root:mail')dnl

   TRUST_AUTH_MECH(`DIGEST-MD5 CRAM-MD5')dnl
   define(`confAUTH_MECHANISMS',`DIGEST-MD5 CRAM-MD5')dnl

   define(`confDONT_BLAME_SENDMAIL',`GroupReadableSASLDBFile')dnl

5) Add the following before FEATURE(msp) in your submit.mc file:

   DAEMON_OPTIONS(`Name=NoMTA, Addr=127.0.0.1, M=EA')dnl

   This disables SMTP AUTH on the loopback interface. Otherwise you may get
   the following error in the log:

        error: safesasl(/usr/local/etc/sasldb2) failed: Group readable file

   when sending mail locally (seen when using pine locally on same server).

 ----

   Additional AUTH Mechanisms are LOGIN, PLAIN, GSSAPI, and KERBEROS_V4.
   These can be added to TRUST_AUTH_MECH and confAUTH_MECHANISMS as a space
   seperated list.  You may want to restrict LOGIN, and PLAIN authentication
   methods for use with STARTTLS, as the password is not encrypted when
   passed to sendmail.

   LOGIN is required for Outlook Express users.  "My server requires
   authentication" needs to be checked in the accounts properties to 
   use SASL Authentication.

   PLAIN is required for Netscape Communicator users.  By default Netscape
   Communicator will use SASL Authentication when sendmail is compiled with
   SASL and will cause your users to enter their passwords each time they
   retreive their mail (NS 4.7).

   The DONT_BLAME_SENDMAIL option GroupReadableSASLDBFile is needed when you
   are using cyrus-imapd and sendmail on the same server that requires access
   to the sasldb2 database.

   SASLv2 support of Sendmail is starting with 8.12.4.
```


Since you'll install the *sendmail* package and will not use the
system *sendmail* (a.k.a. FreeBSD default *sendmail*), you can skip
step 1: adding SENDMAIL_CFLAGS, SENDMAIL_LDFLAGS, SENDMAIL_LDADD, and
step 2: Rebuild FreeBSD (make buildworld, ...); however, I performed the
step 1 and edited `/etc/make.conf` in case I decide to re-compile the
default *sendmail* later.  

```
$ printf %s\\n 'SENDMAIL_CFLAGS+=-I/usr/local/include -DSASL=2' | sudo tee -a /etc/make.conf
$ printf %s\\n 'SENDMAIL_LDFLAGS+=-L/usr/local/lib' | sudo tee -a /etc/make.conf
$ printf %s\\n 'SENDMAIL_LDADD+=-lsasl2' | sudo tee -a /etc/make.conf
```

```
$ cat /etc/make.conf
SENDMAIL_CFLAGS+=-I/usr/local/include -DSASL=2
SENDMAIL_LDFLAGS+=-L/usr/local/lib
SENDMAIL_LDADD+=-lsasl2
```


You need to tell *sendmail* what to do about secure authentication.

Since SASL can be used by different applications, you can create
a customized configuration file in the `/usr/local/lib/sasl2/` directory 
for every service that uses SASL.  The name of the file must be that of
the service with the *conf* extension so in this case it's a *Sendmail.conf*
file.

**NOTE:**   
The *Sendmail.conf* (*/usr/local/lib/sasl2/Sendmail.conf*) file is created
by the `cyrus-sasl2` ports during installation.  

At a minimum, one line should appear in that file and that line should
indicate your preferred password verification method.  Here, you need to
make sure that the `pwcheck_method` command in that file is set to
*saslauthd* daemon process (which is called from the Cyrus-SASL libraries,
and is a SASL authentication server for *cyrus-sasl2*).
This means that *sendmail* service will use SASL by connecting to the
`saslauthd(8)` deamon for all authentication (password verification).

Communication between *sendmail* and the `saslauthd` server takes place
over a UNIX-domain socket.  The `saslauthd` usually establishes the UNIX
domain socket in `/var/run/saslauthd/` and waits for authentication requests. 

```
$ sudo ls -lh /var/run/saslauthd/
total 3
srwxrwxrwx  1 root  mail     0B Nov 12 18:10 mux
-rw-------  1 root  mail     0B Nov 12 18:10 mux.accept
-rw-------  1 root  mail     5B Nov 12 18:10 saslauthd.pid
``` 

The default communications socket for *saslauthd* on FreeBSD 13 is
`/var/run/saslauthd/mux`:

``` 
$ sudo file /var/run/saslauthd/mux
/var/run/saslauthd/mux: socket
``` 

``` 
$ sudo cat /var/run/saslauthd/saslauthd.pid
1358
``` 

Here, *saslauthd* (from Cyrus SASL) uses the PAM framework to authenticate
credentials:
 
```
$ ps aux | grep -v grep | grep 1358
root    1358   0.0  0.0  18484  6120  -  Is 12Nov22    0:00.03 /usr/local/sbin/saslauthd -a pam
```


From the man page for `saslauthd(8)`: 

```
[ . . . ]

     Options
       Options named by lower-case letters configure the server itself.
       Upper-case options control the behavior of specific authentication
       mechanisms; their applicability to a particular authentication mechanism
       is described in the AUTHENTICATION MECHANISMS section.

       -a authmech
               Use authmech as the authentication mechanism. (See the
               AUTHENTICATION MECHANISMS section below.) This parameter is
               mandatory.

[ . . . ]

  AUTHENTICATION MECHANISMS
       saslauthd supports one or more "authentication mechanisms", dependent
       upon the facilities provided by the underlying operating system.  The
       mechanism is selected by the -a flag from the following list of choices:

[ . . . ]

       pam        (Linux, Solaris)
  
                  Authenticate using Pluggable Authentication Modules (PAM).
[ . . . ]
```

Refer to 
**[Authenticating with AUTH](#authenticating-with-auth)** section below
for additional information about AUTH protocol and SASL. 

```
$ printf %s\\n "pwcheck_method: saslauthd" | sudo tee /usr/local/lib/sasl2/Sendmail.conf
```

```
$ cat /usr/local/lib/sasl2/Sendmail.conf
pwcheck_method: saslauthd
```

To run *saslauthd* from startup, add `saslauthd_enable="YES"` in
your `/etc/rc.conf`.

```
$ printf %s\\n 'saslauthd_enable="YES"' | sudo tee -a /etc/rc.conf
```


From the [FreeBSD Handbook - 30.9. SMTP Authentication](https://docs.freebsd.org/en/books/handbook/mail/#SMTP-Auth):  

> This daemon serves as a broker for *sendmail* to authenticate against
> the FreeBSD `passwd(5)` database.  This saves the trouble of creating
> a new set of usernames and passwords for each user that needs to use SMTP
> authentication, and keeps the login and mail password the same.


### Install and Configure Sendmail from Packages (Ports) 

```
$ sudo pkg install sendmail
```

Output:

```
[ . . . ]

===> Creating groups.
Using existing group 'smmsp'.
===> Creating users
Using existing user 'smmsp'.
===> Creating homedir(s)
[2/2] Extracting sendmail-8.17.1_5: 100%
=====

[ . . . ]

Message from sendmail-8.17.1_5:

--
On install:
you should add in /etc/make.conf:
SENDMAIL_CF_DIR=        /usr/local/share/sendmail/cf
 
To deliver all local mail to your mailhub, edit the last line of submit.mc:
FEATURE(`msp','[mailhub.do.main]`)dnl

To update your configuration look at /usr/local/share/sendmail/cf/README.
---------------------------------------------------
To use the binaries supplied by the port you should add the following lines
to your sendmail.mc file before any mailer or feature definition:

define(`confEBINDIR', `/usr/local/libexec')dnl
define(`UUCP_MAILER_PATH', `/usr/local/bin/uux')dnl

---------------------------------------------------
To activate sendmail as your default mailer, run:
$ cd /usr/local/etc/mail && cp mailer.conf.sendmail mailer.conf

Your '/usr/local/etc/mail/mailer.conf' should look like this:
#
# Execute the "real" sendmail program, named /usr/libexec/sendmail/sendmail
#
sendmail        /usr/local/sbin/sendmail
send-mail       /usr/local/sbin/sendmail
mailq           /usr/local/sbin/sendmail
newaliases      /usr/local/sbin/sendmail
hoststat        /usr/local/sbin/sendmail
purgestat       /usr/local/sbin/sendmail

You may also need to update /etc/rc.conf.
```

```
$ printf %s\\n 'SENDMAIL_CF_DIR=/usr/local/share/sendmail/cf' | sudo tee -a /etc/make.conf
```

```
$ cat /etc/make.conf
SENDMAIL_CFLAGS+=-I/usr/local/include -DSASL=2
SENDMAIL_LDFLAGS+=-L/usr/local/lib
SENDMAIL_LDADD+=-lsasl2
SENDMAIL_CF_DIR=/usr/local/share/sendmail/cf
```


The package-installed *sendmail* includes SASL support: 

```
$ /usr/local/sbin/sendmail -bt -d0 < /dev/null | grep SASL
                PICKY_HELO_CHECK PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS
```

```
$ /usr/local/sbin/sendmail -bt -d0 < /dev/null 
Version 8.17.1
 Compiled with: DANE DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PICKY_HELO_CHECK PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS
                TLS_EC TLS_VRFY_PER_CTX USERDB XDEBUG

============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================

ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> $ 
$ 
```

To run *sendmail* from startup, add `sendmail_enable` to `YES` in
`/etc/rc.conf`.

```
$ printf %s\\n 'sendmail_enable="YES"' | sudo tee -a /etc/rc.conf
```

```
$ find /etc/rc* -iname '*sendmail*'
/etc/rc.d/sendmail
/etc/rc.sendmail
```

**NOTE:**   
The `/etc/rc.d/sendmail` file is the actual *sendmail* startup script.

The `/etc/rc.sendmail` file is specific to *sendmail*:

```
$ cat /etc/rc.sendmail
[ . . . ]
# This script is used by /etc/rc at boot time to start sendmail.  It
# is meant to be sendmail specific and not a generic script for all
# MTAs.  It is only called by /etc/rc if the rc.conf mta_start_script is
# set to /etc/rc.sendmail.  This provides the opportunity for other MTAs
# to provide their own startup script.

# The script is also used by /etc/mail/Makefile to enable the
# start/stop/restart targets.

# The source for the script can be found in src/etc/sendmail/rc.sendmail.
```


To display which `rc.conf(5)` variables (**rcvar**) are used to control
the startup of the *sendmail* service, use the `grep(1)` utility to search
the *sendmail* startup script (`/etc/rc.d/sendmail`) for lines  with **rcvar**.

```
$ grep 'rcvar=' /etc/rc.d/sendmail
rcvar="sendmail_enable"
        rcvar="sendmail_submit_enable"
        rcvar="sendmail_outbound_enable"
rcvar="sendmail_msp_queue_enable"
```

Yo don't need to add the other three *rcvar* variables
(`sendmail_submit_enable`, `sendmail_outbound_enable`,
`sendmail_msp_queue_enable`) to `/etc/rc.conf` because they are set 
to *YES* by default:  The `/etc/defaults/rc.conf` file contains
**default** *rcvar* variables for the default startup behaviour of
your system.  You need to put only your overrides into `/etc/rc.conf`.  

```
$ sudo grep sendmail_enable /etc/defaults/rc.conf
sendmail_enable="NO"    # Run the sendmail inbound daemon (YES/NO).
 
$ sudo grep sendmail_submit_enable /etc/defaults/rc.conf
sendmail_submit_enable="YES"    # Start a localhost-only MTA for mail submission
 
$ sudo grep sendmail_outbound_enable /etc/defaults/rc.conf
sendmail_outbound_enable="YES"  # Dequeue stuck mail (YES/NO).
 
$ sudo grep sendmail_msp_queue_enable /etc/defaults/rc.conf
sendmail_msp_queue_enable="YES" # Dequeue stuck clientmqueue mail (YES/NO).
```


```
$ ls -lh /usr/local/share/sendmail/
total 13
drwxr-xr-x  11 root  wheel    13B Nov 12 19:30 cf
-r--r--r--   1 root  wheel   5.9K Sep  5 15:35 helpfile
```

```
$ ls -lh /usr/local/share/sendmail/cf/
total 186
drwxr-xr-x  2 root  wheel    49B Nov 12 19:30 cf
drwxr-xr-x  2 root  wheel     8B Nov 12 19:30 domain
drwxr-xr-x  2 root  wheel    68B Nov 12 19:30 feature
drwxr-xr-x  2 root  wheel     4B Nov 12 19:30 hack
drwxr-xr-x  2 root  wheel     6B Nov 12 19:30 m4
drwxr-xr-x  2 root  wheel    14B Nov 12 19:30 mailer
drwxr-xr-x  2 root  wheel    58B Nov 12 19:30 ostype
-rw-r--r--  1 root  wheel   188K Jun  9  2021 README
-rw-r--r--  1 root  wheel   7.9K Apr  5  2021 sendmail.schema
drwxr-xr-x  2 root  wheel     3B Nov 12 19:30 sh
drwxr-xr-x  2 root  wheel     6B Nov 12 19:30 siteconfig
```

```
$ cd /etc/mail
```

```
$ sudo su
Password:
```

```
# pwd
/etc/mail
```

```
# head -64 /etc/mail/Makefile
#
# $FreeBSD$
#
# This Makefile provides an easy way to generate the configuration
# file and database maps for the sendmail(8) daemon.
#
# The user-driven targets are:
#
# all     - Build cf, maps and aliases
# cf      - Build the .cf file from .mc file
# maps    - Build the feature maps
# aliases - Build the sendmail aliases
# install - Install the .cf file as /etc/mail/sendmail.cf
#
# For acting on both the MTA daemon and MSP queue running daemon:
# start        - Start both the sendmail MTA daemon and MSP queue running
#                daemon with the flags defined in /etc/defaults/rc.conf or
#                /etc/rc.conf
# stop         - Stop both the sendmail MTA daemon and MSP queue running
#                daemon
# restart      - Restart both the sendmail MTA daemon and MSP queue running
#                daemon
#
# For acting on just the MTA daemon:
# start-mta    - Start the sendmail MTA daemon with the flags defined in
#                /etc/defaults/rc.conf or /etc/rc.conf
# stop-mta     - Stop the sendmail MTA daemon
# restart-mta  - Restart the sendmail MTA daemon
#
# For acting on just the MSP queue running daemon:
# start-mspq   - Start the sendmail MSP queue running daemon with the
#                flags defined in /etc/defaults/rc.conf or /etc/rc.conf
# stop-mspq    - Stop the sendmail MSP queue running daemon
# restart-mspq - Restart the sendmail MSP queue running daemon
#
# Calling `make' will generate the updated versions when either the
# aliases or one of the map files were changed.
#
# A `make install` is only necessary after modifying the .mc file. In
# this case one would normally also call `make restart' to allow the
# running sendmail to pick up the changes as well.
#
# ------------------------------------------------------------------------
# This Makefile uses `<HOSTNAME>.mc' as the default MTA .mc file.  This
# can be changed by defining SENDMAIL_MC in /etc/make.conf, e.g.:
#
#       SENDMAIL_MC=/etc/mail/myconfig.mc
#
# If '<HOSTNAME>.mc' does not exist, it is created using 'freebsd.mc'
# as a template.
#
# It also uses '<HOSTNAME>.submit.mc' as the default mail submission .mc
# file.  This can be changed by defining SENDMAIL_SUBMIT_MC in
# /etc/make.conf, e.g.:
#
#       SENDMAIL_SUBMIT_MC=/etc/mail/mysubmit.mc
#
# If '<HOSTNAME>.submit.mc' does not exist, it is created using
# 'freebsd.submit.mc' as a template.
# ------------------------------------------------------------------------
#
# The Makefile knows about the following maps:
# access, authinfo, bitdomain, domaintable, genericstable, mailertable,
# userdb, uucpdomain, virtusertable
```

```
# ls -lh /usr/local/etc/sasldb2.db 
-rw-r-----  1 cyrus  mail    16K Nov 12 18:56 /usr/local/etc/sasldb2.db
```

NOTE:   
Even though the `/usr/local/share/doc/cyrus-sasl2/Sendmail.README` says
that the group needs to be *mail* in order to read the sasldb2 file,
my tests worked without adding the following line in `sendmail.mc` file
(on FreeBSD: `/etc/mail/freebsd.mc` and `/etc/mail/<hostname>.mc`). 

```
define(`confRUN_AS_USER',`root:mail')dnl
```


### The Order Of mc Lines

From **sendmail**, 4th Edition (a.k.a. **"Bat Book"**)   
By Bryan Costales, Claus Assmann, George Jansen, Gregory Neil Shapiro  
(Published by: O'Reilly Media, Inc., Publication Date: October 2007):  

> Some *mc* lines must precede others.  This is necessary partly because
> *`m4(1)`* is a one-pass program, and partly because the order of items in
> the final *sendmail.cf* file is also critical.  The recommended order is:

```
VERSIONID( )
OSTYPE( )
DOMAIN( )
option definitions
FEATURE( )
macro definitions
MAILER( )
ruleset definitions
```

The general rules about the order of macro definition declarations
in *mc* files:

```
# sed -n 128,152p /usr/local/share/sendmail/cf/README

        MAILER(`local')
        MAILER(`smtp')

These describe the mailers used at the default CS site.  The local
mailer is always included automatically.  Beware: MAILER declarations
should only be followed by LOCAL_* sections.  The general rules are
that the order should be:

        VERSIONID
        OSTYPE
        DOMAIN
        FEATURE
        local macro definitions
        MAILER
        LOCAL_CONFIG
        LOCAL_RULE_*
        LOCAL_RULESETS

There are a few exceptions to this rule.  Local macro definitions which
influence a FEATURE() should be done before that feature.  For example,
a define(`PROCMAIL_MAILER_PATH', ...) should be done before
FEATURE(`local_procmail').

*******************************************************************
```

Also in:

```
# sed -n 128,152p /usr/share/sendmail/cf/README 
# sed -n 128,152p /usr/src/contrib/sendmail/cf/README
```

```
# cp -i /etc/mail/freebsd.mc /etc/mail/freebsd.mc.ORIG
```


### Edit **sendmail.mc** (**freebsd.mc** on FreeBSD) File 

Continuing with setup, modify `sendmail.mc` file
(on FreeBSD this file is: `/etc/mail/freebsd.mc`). 

```
# vi /etc/mail/freebsd.mc
```

Content of the `freebsd.mc` file after editing it:

```
$ grep -v ^dnl /etc/mail/freebsd.mc | grep -v \^#
divert(-1)


divert(0)
VERSIONID(`$FreeBSD$')
OSTYPE(freebsd6)
DOMAIN(generic)

define(`confLOG_LEVEL', `14')dnl

define(`confEBINDIR', `/usr/local/libexec')dnl
define(`UUCP_MAILER_PATH', `/usr/local/bin/uux')dnl

FEATURE(`nouucp',`reject')dnl

TRUST_AUTH_MECH(`DIGEST-MD5 CRAM-MD5 EXTERNAL GSSAPI LOGIN PLAIN')dnl
define(`confAUTH_MECHANISMS',`DIGEST-MD5 CRAM-MD5 EXTERNAL GSSAPI LOGIN PLAIN')dnl
define(`confDONT_BLAME_SENDMAIL',`GroupReadableSASLDBFile')dnl

FEATURE(access_db, `hash -o -T<TMPF> /etc/mail/access')
FEATURE(blocklist_recipients)
FEATURE(local_lmtp)

FEATURE(mailertable, `hash -o /etc/mail/mailertable')
FEATURE(virtusertable, `hash -o /etc/mail/virtusertable')

define(`CERT_DIR', `/etc/mail/certs')dnl
define(`confSERVER_CERT', `CERT_DIR/host.cert')dnl
define(`confSERVER_KEY', `CERT_DIR/host.key')dnl
define(`confCLIENT_CERT', `CERT_DIR/host.cert')dnl
define(`confCLIENT_KEY', `CERT_DIR/host.key')dnl
define(`confCACERT', `CERT_DIR/cacert.pem')dnl
define(`confCACERT_PATH', `CERT_DIR')dnl
define(`confDH_PARAMETERS', `CERT_DIR/dh.param')dnl

define(`confCW_FILE', `-o /etc/mail/local-host-names')

DAEMON_OPTIONS(`Name=IPv4, Family=inet')

define(`confBIND_OPTS', `WorkAroundBrokenAAAA')
define(`confNO_RCPT_ACTION', `add-to-undisclosed')
define(`confPRIVACY_FLAGS', `authwarnings,noexpn,novrfy')

MAILER(local)dnl
MAILER(smtp)dnl

LOCAL_RULESETS
SLocal_trust_auth
R$*     $: $&{auth_authen}
Rsmmsp  $# OK
```

**NOTE:** 
The LHS (lefthand side) in the two lines below `SLocal_trust_auth`
is separated from the RHS (righthand side) by one or more
**tab** characters (space characters will not work).  In this case, for
the first line below `SLocal_trust_auth`, `$*` ends the left-hand side;
`$:` starts the right-hand side so the TAB character is before `$:`;
that is:   
`R$*`[TAB]`$: $&{auth_authen}`

Similarly, in the second line, there is a TAB after `Rsmmsp`; that is:  
`Rsmmsp`[TAB]`$# OK`  


```
# touch /etc/mail/statistics
```

```
# ls -lh /etc/mail/statistics
-rw-r--r--  1 root  wheel     0B Nov 12 18:56 /etc/mail/statistics
```

```
# mkdir /etc/mail/host_status
``` 

``` 
# ls -ld /etc/mail/host_status
drwxr-xr-x  2 root  wheel  2 Nov 12 18:56 /etc/mail/host_status
``` 


```
# cp -i /etc/mail/freebsd.submit.mc /etc/mail/freebsd.submit.mc.ORIG
```


### Edit **submit.mc** (on FreeBSD: **freebsd.submit.mc**) File 

Modify the *submit.mc* file (on FreeBSD: `/etc/mail/freebsd.submit.mc`).

```
# vi /etc/mail/freebsd.submit.mc
```

```
# wc -l /etc/mail/freebsd.submit.mc
      46 /etc/mail/freebsd.submit.mc
```

Content of the **freebsd.submit.mc** file after editing it:

```
$ cat /etc/mail/freebsd.submit.mc
divert(-1)

#
#  This is the FreeBSD configuration for a set-group-ID sm-msp sendmail
#  that acts as a initial mail submission program.
#

divert(0)dnl

VERSIONID(`$FreeBSD$')
define(`confCF_VERSION', `Submit')dnl
define(`__OSTYPE__',`')dnl dirty hack to keep proto.m4 from complaining
define(`_USE_DECNET_SYNTAX_', `1')dnl support DECnet
define(`confTIME_ZONE', `USE_TZ')dnl
define(`confDONT_INIT_GROUPS', `True')dnl
define(`confBIND_OPTS', `WorkAroundBrokenAAAA')dnl

define(`confLOG_LEVEL', `14')dnl

define(`SMART_HOST',`smartrelay:[127.0.0.1]')dnl
FEATURE(`authinfo',`hash /etc/mail/authinfo')dnl

dnl dnl MASQUERADE_AS(`domain.to.masquerade_as')dnl dnl
dnl dnl MASQUERADE_DOMAIN('fbsd1.home.arpa')dnl dnl
dnl # Uncomment the next line (with masquerade_envelope) if 
dnl # you want messages to be delivered to SMART_HOST. 
dnl dnl FEATURE(`masquerade_envelope')dnl
dnl dnl FEATURE(`masquerade_entire_domain')dnl dnl

dnl Disable SMTP AUTH on the loopback interface.
DAEMON_OPTIONS(`Name=NoMTA, Addr=127.0.0.1, M=EA')dnl

FEATURE(`msp', `[127.0.0.1]')dnl

MAILER_DEFINITIONS
dnl 
dnl     LR0relayST (Local Rule 0 relay Single Token)
dnl For addresses with only a single token (e.g. a username):  dusko 
MLR0relayST,	P=[IPC], F=mDFMuXa8k, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
		T=DNS/RFC822/SMTP,
		A=TCP $h

dnl
dnl     LR0relayLH [Local Rule 0 relay Local (AND) Hostname]
dnl For addresses:  dusko@localhost, dusko@<hostname> (that is:  dusko@fbsd1.home.arpa)
MLR0relayLH,	P=[IPC], F=mDFMuXa8k, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
		T=DNS/RFC822/SMTP,
		A=TCP $h

dnl
dnl     smartrelay 
dnl For nonlocal (external) addresses; for example: dusko@some.external.domain
Msmartrelay,	P=[IPC], F=mDFMuXa8k, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
		T=DNS/RFC822/SMTP,
		A=TCP $h 1465

LOCAL_RULE_0
R$-	$#LR0relayST $@ $j $: $1 < @ $j. >
R$+ < @ $j. >	$#LR0relayLH $@ $j $: $1 < @ $j. >
```

**NOTE:**    
The LHS (lefthand side) in two lines below *LOCAL_RULE_0* is separated from
the RHS (righthand side) by a **tab** character (space characters will not
work).  In this case, in the first line under *LOCAL_RULE_0*, the `-` 
character (the minus sign) ends the LHS; `$#` starts the RHS; that is:   
`R$-` [TAB] `$#LR0relayST $@ $j $: $1 < @ $j. >`    
On the last line (second line under *LOCAL_RULE_0*), the `>` character
(the greater-than sign) ends the LHS, while `$#` starts the RHS; that is:    
`R$+ < @ $j. >` [TAB] `$#LR0relayLH $@ $j $: $1 < @ $j. >`

**NOTE:**    
In the MAILER_DEFINITIONS *mc* configuration macro definitions, you don't
have to use tabs between mailer names on the lefthand side (LHS) (in this
case, `LR0relayST`, `LR0relayLH` and `smartrelay`) and their definitions
(**delivery agent equates** **[<SUP>[ 10 ](#footnotes)</sup>]**) on the
righthand side (RHS).


### Three New Customized Delivery Agents (Mailers) - Explanation

```
define(`SMART_HOST',`smartrelay:[127.0.0.1]')dnl
```

To enable forwarding of all **nonlocal** mail to a **smart** gateway host,
you need to define `SMART_HOST`.

Here, Internet mail (nonlocal mail) will be forwarded to the host
`[127.0.0.1]` using the **smartrelay** delivery agent [the delivery agent
name is separated from the domain name by a colon (`:`)].
The square brackets (`[` and `]`) around `127.0.0.1` tell *sendmail* that
it is dealing with an **IP address**, rather than a hostname.  In other words, 
the **square brackets** around `127.0.0.1` **suppress** the lookup
of **MX records**.  During canonicalization of a hostname, when the
IP address between the square brackets corresponds to a known host,
the address and the square brackets are replaced with that host's canonical
name.    
In this case, canonical domain name for my localhost is *fbsd1.home.arpa*:

```
$ sendmail -d0 < /dev/null
[ . . . ]
  (canonical domain name) $j = fbsd1.home.arpa 
[ . . . ]
```

As a special case, the [default] delivery agent named *local* causes
slightly different behaviour in that it allows the name of the target user
to be listed without a host part:  *localhost local:dusko*; or
*fbsd1.home.arpa local:dusko*. 

For configuration in this article, the smart host is configured to use host
*127.0.0.1* (*localhost*) via the newly defined custom delivery
agent (named *smartrelay*).  I defined the *smartrelay* delivery agent
in the configuration file for the submission form of *sendmail*
(a.k.a. *msp sendmail*), `submit.mc`
(in FreeBSD, this file is: `/etc/mail/freebsd.submit.mc`)
to use port *1465* because I earlier chose that port number
in the *stunnel.conf* configuration file to be a conduit for tunneling
SSL to port *465* on the external smart host side.   
An excerpt from *stunnel.conf*:

```
accept = 127.0.0.1:1465 
connect = your.isp.net:465
```

**MSP** (mail submission program) is a command-line *sendmail* that
functions as a mail submission agent (**MSA**).


All mailer (a.k.a. deliver agent) definitions begin with the `M` operator.

All recipient addresses must resolve to a mailer (delivery agent)
in **rulest 0**.

In *sendmail*, a delivery agent is selected by the RHS of a *parse* rule
set 0 rule.  

In a setup in which the smart host is configured this way [to be
tunneled through the *localhost* with the *stunnel* to the actual
(external) smart host] I need to define two new, customized local delivery
agents for delivering local mail.  Otherwise, local mail would be 
forwarded by connecting to *[127.0.0.1]* via the default MSP `relay` delivery
agent, in which case authentication would fail because the client's
authentication credentials (configured earlier and stored in the
`/etc/mail/authinfo` file) are for the smart host; that is, they are not
authentication credentials for your localhost.


Also, I need to define an additional custom delivery agent
for the smart relay.  This delivery agent will use the port number
specified earlier for *stunnel* on the localhost side (in this case, port
*1465*) for tunneling mail to the smart relay side (which, in this case
requires authentication on port *465*).  


The three new delivery agents - summarized:  

*MLR0relayST*   
M = mailer definition   
Mailer name: **LR0relayST**   
Will be used when the address is a single token (such as *dusko*)  

*MLR0relayLH*   
M = mailer definition   
Mailer name: **LR0relayLH**   
Will be used when the address is the local hostname   
(*dusko@localhost*, or in this case: *dusko@fbsd1.home.arpa*)

*Msmartrelay*   
M = mailer definition    
Mailer name: **smartrelay**   
Will be used when the address is a nonlocal (external) addresses  
(for example: *dusko@some.external.domain*) 


Three new/customized mailers (a.k.a. delivery agents) are defined under
`MAILER_DEFINITIONS`.   
The `MAILER_DEFINITIONS` *m4* command is used for grouping delivery agent
definitions. 



### LOCAL_RULE_0 mc Macro - Explanation

**LOCAL_RULE_0** mc macro adds rules to `parse` rule set 0.   

I will use *LOCAL_RULE_0* to declare two new rules in the `parse` rule set 0.  

- The first rule detects a **single token** in the address (such as *dusko*)
  and calls the `LR0relayST` delivery agent.   
- The second rule detects a match with localhost
  (such as *localhost* or *local-hostname.some.domain*)
  and calls the `LR0relayLH` delivery agent. **Note:** This check is done
  against the local hostname after it went through the process of 
  canonicalization.   
  - In the flow of rules through the parse rule set 0, 
    canonicalization is done first.  In this case, the `canonify` ruleset
    returns `dusko < @ fbsd1 . home . arpa . >` for both inputs 
    `dusko@localhost` and `dusko@fbsd1.home.arpa`.   
    My workstation's hostname is *fbsd1.home.arpa*.  Its canonical domain
    name (`$j`) is *fbsd1.home.arpa*:  

```
$ sendmail -d0 < /dev/null
[ . . . ]
  (canonical domain name) $j = fbsd1.home.arpa
[ . . . ]
```


From [The Whole Scoop on the Configuration File - Claus Aßmann at sendmail.org](https://sendmail.org/~ca/email/doc8.12/op-sh-5.html) (Retrieved on Nov 11, 2022):

> R and S -- Rewriting Rules
> 
> The core of address parsing are the rewriting rules.  These are an ordered
> production system.  *Sendmail* scans through the set of rewriting rules
> looking for a match on the left hand side (LHS) of the rule.  When a rule
> matches, the address is replaced by the right hand side (RHS) of the rule. 

> The syntax of the R command: 
> 
> **R** *lhs* *rhs* *comments* 
> 
> The fields must be separated by at least one **tab character**;
> there may be embedded spaces in the fields.  The *lhs* is a pattern that
> is applied to the input.  If it matches, the input is rewritten to the *rhs*.
> The comments are ignored. 

> **The left hand side**
> 
> The left hand side of rewriting rules contains a pattern.  Normal words
> are simply matched directly.  Metasyntax is introduced using
> a **dollar sign**.  The metasymbols are:
> 
> **$\***	Match zero or more tokens  
> **$+**	Match one or more tokens  
> **$-**	Match exactly one token  
> **$=***x*	Match any phrase in class *x*   
> **$~***x*	Match any word not in class *x*   
> 
> If any of these match, they are assigned to the symbol **$** *n* for
> replacement on the right hand side, where *n* is the index in the LHS.
> For example, if the LHS: 
> 
> $-:$+  
> 
> is applied to the input:  
> 
> UCBARPA:eric
> 
> the rule will match, and the values passed to the RHS will be:   
> 
> $1 UCBARPA   
> $2 eric  
> 
> Additionally, the LHS can include **$@** to match **zero** tokens.
> This is not bound to a **$** *n* on the RHS, and is normally only used
> when it stands alone in order to match the **null input**.
>
> **The right hand side** 
> 
> When the left hand side of a rewriting rule matches, the input is deleted
> and replaced by the right hand side.  Tokens are copied directly from the
> RHS unless they begin with a dollar sign.  Metasymbols are:
> 
> **$***n*	Substitute indefinite token n from LHS  
> **$[***name***$]**	Canonicalize name   
> **$(***map key **$@***arguments **$:***default* **$)**   
> Generalized keyed mapping function   
> **$>***n*	"Call" ruleset *n*   
> **$#***mailer*	Resolve to *mailer*   
> **$@***host*	Specify *host*   
> **$:***user*	Specify *user*   
> 
> The **$** *n* syntax substitutes the corresponding value from a **$+**,
> **$-**, **$\***, **$=**, or **$~** match on the LHS.  It may be used
> anywhere.
> 
> A host name enclosed between **$[** and **$]** is looked up in the host
> database(s) and replaced by the canonical name.  For example, `$[ftp$]`
> might become `ftp.CS.Berkeley.EDU` and `$[[128.32.130.2]$]` would become
> `vangogh.CS.Berkeley.EDU`.  *Sendmail* recognizes its numeric IP address
> without calling the name server and replaces it with its canonical name.
> 
> The **$( ... $)** syntax is a more general form of lookup; it uses
> a named map instead of an implicit map.  If no lookup is found, the
> indicated *default* is inserted; if no default is specified and no
> lookup matches, the value is left unchanged.  The *arguments* are passed
> to the map for possible use.
> 
> The **$>** *n* syntax causes the remainder of the line to be substituted
> as usual and then passed as the argument to ruleset *n*.  The final value
> of ruleset n then becomes the substitution for this rule.  The **$>**
> syntax expands everything after the ruleset name to the end of the
> replacement string and then passes that as the initial input to the
> ruleset.  Recursive calls are allowed. For example,
> 
> $>0 $>3 $1
> 
> expands $1, passes that to ruleset 3, and then passes the result of
> ruleset 3 to ruleset 0.
> 
> The **$#** syntax should **only** be used in ruleset zero, a subroutine
> of ruleset zero, or rulesets that return decisions (e.g., `check_rcpt`).
> It causes evaluation of the ruleset to terminate immediately, and signals
> to *sendmail* that the address has completely resolved.  The complete
> syntax for ruleset 0 is:
>
> **$#***mailer* **$@***host* **$:***user*
> 
> This specifies the {mailer, host, user} 3-tuple necessary to direct
> the mailer.  If the mailer is local the host part may be omitted.
> The *mailer* must be a single word but the *host* and *user* may be
> multi-part.  If the *mailer* is the built-in IPC mailer, the *host* may
> be a colon-separated list of hosts that are searched in order for the
> first working address (exactly like MX records).  The *user* is later
> rewritten by the mailer-specific envelope rewriting set and assigned to
> the **$u** macro.  As a special case, if the mailer specified has the
> **F=@** flag specified and the first character of the **$:** value is `@`,
> the `@` is stripped off, and a flag is set in the address descriptor that
> causes sendmail to not do ruleset 5 processing.
> 
> Normally, a rule that matches is retried, that is, the rule loops until
> it fails.  A RHS may also be preceded by a **$@** or a **$:** to change
> this behaviour.  A **$@** prefix causes the ruleset to return with the
> remainder of the RHS as the value.  A **$:** prefix causes the rule to
> terminate immediately, but the ruleset to continue; this can be used to
> avoid continued application of a rule.  The prefix is stripped before continuing.
> 
> The **$@** and **$:** prefixes may precede a **$>** spec; for example: 
> 
> R$+ $: $>7 $1
> 
> matches anything, passes that to ruleset seven, and continues; the **$:**
> is necessary to avoid an infinite loop.
> 
> Substitution occurs in the order described, that is, parameters from the
> LHS are substituted, hostnames are canonicalized, `subroutines` are called,
> and finally **$#**, **$@**, and **$:** are processed.


### MAILER_DEFINITIONS m4 Command - Explanation

The **MAILER_DEFINITIONS** section introduces your new delivery agent definitions.  
This m4 command forces new delivery agent definitions to be grouped with
the other delivery agent definitions.


**MAILER_DEFINITIONS**    
Define new (custom) delivery agents (aka "mailers").   

In this case, under `MAILER_DEFINITIONS` macro, three new deliver agents are defined:
**MLR0relayST**, **MLR0relayLH** and **smartrelay**.


A close inspection of the fields in these two mailer (delivery agent)
entries shows the following:   

*MLR0relayST*, *MLR0relayLH* and *Msmartrelay*   
Define and name a mailer, here arbitrarily named *MLR0relayST*, *MLR0relayLH* and *Msmartrelay*.    

*P=[IPC]*   
The path to the program used for this mailer is `[IPC]`, which means delivery
of this mail is handled internally by *sendmail*.

*F=mDFMuXa8k*  
The *sendmail* flags for this mailer say that this mailer can send to
multiple recipients at once (`m`); that Date (`D`), From (`F`), and
Message-Id (`M`) headers are required; that uppercase should be preserved
in hostnames and usernames (`u`); that lines beginning with a dot have an
extra dot prepended (`X`); to run extended SMTP protocol (ESMTP) (`a`);
to force sending 8-bit data over SMTP even if the receiving server doesn't
support 8-bit MIME (`8`); and to don't check for loops in EHLO/HELO command (`k`). 

*S=EnvFromSMTP/HdrFromSMTP*    
The sender address in the mail *envelope* is processed through ruleset`EnvFromSMTP`,
and the sender address in the *message* is processed through ruleset `HdrFromSMTP`. 

*R=EnvToSMTP*   
All recipient addresses are processed through ruleset EnvToSMTP.

*E=\r\n*   
Lines are terminated with a carriage return and a line feed.

*L=2040*   
This mailer will handle lines up to 2040 bytes long.

*T=DNS/RFC822/SMTP*   
The MIME-type information for this mailer says that DNS is used for hostnames,
RFC 822 email addresses are used, and SMTP error codes are used.

*A=TCP $h*   
An internal *sendmail* process designed to deliver SMTP mail over a TCP connection.
The macro `$h` is expanded to provide the recipient host (`$h`) address.


All three custom delivery agents (*LR0relayST*, *LR0relayLH* and *smartrelay*)
have been copied from the **relay** delivery agent as defined and provided by
default in the `/etc/mail/submit.cf` file, and then modified. 
For my purposes, I've made only two modifications:  
* renaming delivery agent (to: *LR0relayST*, *LR0relayLH* and *smartrelay*), and 
* for the *Msmartrelay* delivery agent: added a port number **1465** as
  that's the port configured to be used by *stunnel*.  


The *relay* delivery agent as defined by default in the **sendmail.cf**
configuration file uses TCP to connect to other hosts.  It speaks ESMTP
and has the **F=mDFMuXa8** delivery agent flags set by default:

```
$ grep -A3 Mrelay /etc/mail/sendmail.cf
Mrelay,         P=[IPC], F=mDFMuXa8, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
                T=DNS/RFC822/SMTP,
                A=TCP $h
```

This delivery agent (the *relay* delivery agent) is chosen for forwarding
mail to the **SMART_HOST** (`SMART_HOST` mc macro). **[<sup>[ 8 ](#footnotes)</sup>]**


However, note that in the **submit.cf** configuration file, which is the
configuration file that *sendmail* uses for its **MSP** (mail submission program)
[(a command-line *sendmail* that functions as a mail submission agent (**MSA**)],
the **relay** delivery agent is defind sligthly differently.  (The only difference
is in **F=mDFMuXa8k** delivery agent flags.  These are the same delivery
agent flags that *relay* in *sendmail.cf* uses  but with the **F=k** delivery
agent flag added, which means "Don't check for loops in HELO/EHLO command".)

```
$ grep -A3 Mrelay /etc/mail/submit.cf
Mrelay,         P=[IPC], F=mDFMuXa8k, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
                T=DNS/RFC822/SMTP,
                A=TCP $h
```


**LOCAL_RULE_0**    
Add rules to parse rule set 0

Ruleset 0 is applied to recipient addresses by *sendmail* after Ruleset 3
**[<sup>[ 9 ](#footnotes)</sup>]**.
Ruleset 0 is expected to perform the delivery of the message to the recipient
so it must resolve to a triple that specifies each of the mailer, host,
and user.  The rules will be placed **before** any **smart host**
definition you may include so if you add rules that resolve addresses
appropriately, any address that matches a rule will **not** be handled by
the smart host.

The `LOCAL_RULE_0` macro marks the start of *sendmail.cf* code that is
added to **ruleset 0** (more commonly called the **parse** ruleset).
Specifically, the code that follows the `LOCAL_RULE_0` macro is added to
the `ParseLocal` ruleset, which is a hook into the *parse* ruleset where
**locally defined rules** are added.  The *parse* ruleset rewrites the delivery
address to a mail delivery triple.

The code that follows the `LOCAL_RULE_0` macro above is a rewrite rule.
The `R` command is used to define a rewriting rule: 
Mail addresses are compared to the rule on the left hand side (`$-` and `$+`)
(the `$j` macro holds the canonical domain name; which is in this case:
`fbsd1.home.arpa`).  If they match it, the rule rewrites those addresses
into a mail delivery triple where the mailer is *LR0relayLH*.  


After rebuilding the configuration with the new master configuration file,
running a `sendmail -bv` test (with the `-Ac` parameters so that the
**submit.cf** is used instead of **sendmail.cf**) shows: 

```
$ sudo sendmail -Ac -bv dusko
dusko... deliverable: mailer LR0relayST, host fbsd1.home.arpa,
  user dusko@fbsd1.home.arpa

$ sudo sendmail -Ac -bv dusko@localhost
dusko@localhost... deliverable: mailer LR0relayLH, host fbsd1.home.arpa,
  user dusko@fbsd1.home.arpa

$ sudo sendmail -Ac -bv dusko@fbsd1.home.arpa
dusko@fbsd1.home.arpa... deliverable: mailer LR0relayLH, host fbsd1.home.arpa,
  user dusko@fbsd1.home.arpa

$ sudo sendmail -Ac -bv dusko@some.external.domain
dusko@some.external.domain... deliverable: mailer smartrelay, host [127.0.0.1],
  user dusko@some.external.domain
```

**NOTE:**  Without defining the new, customized delivery agents
*LR0relayST* and *LR0relayLH*, delivery agent selected for local
delivery would have been the `relay` mailer supplied by default
by *sendmail*.  To check that you can run the following commands with
the default `submit.mc` (for FreeBSD: `freebsd.submit.mc`); that is,
without defining custom mailers (delivery agents):

```
$ sudo sendmail -Ac -bt 
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>

> ?
Help for test mode:
?                :this help message.
[ . . . ]
=M               :display the known mailers.
[ . . . ]

> =M 
[ . . .] 
mailer 8 (relay): P=[IPC] S=EnvFromSMTP/HdrFromSMTP R=MasqSMTP/MasqSMTP M=0 U=-1:-1 F=8DFMXakmu
  L=2040 E=\r\n T=DNS/RFC822/SMTP r=100 A=TCP $h
[ . . .] 
``` 

```
$ sudo sendmail -Ac -bv dusko
dusko... deliverable: mailer relay, host [127.0.0.1], user dusko@fbsd1.home.arpa

$ sudo sendmail -Ac -bv dusko@localhost
dusko@localhost... deliverable: mailer relay, host [127.0.0.1], user dusko@fbsd1.home.arpa

$ sudo sendmail -Ac -bv dusko@fbsd1.chem.ubc.ca
dusko@fbsd1.home.arpa... deliverable: mailer relay, host [127.0.0.1], user dusko@fbsd1.home.arpa

$ sudo sendmail -Ac -bv dusko@some.external.domain
dusko@some.external.domain... deliverable: mailer smartrelay, host [127.0.0.1],
  user dusko@some.external.domain
```


Continuing with the dissection of Ruleset 0 (a.k.a. *parse* ruleset): 

Run *sendmail* in address test mode by using the `-bt` parameters (and also
with the `-Ac` parameters so that the *submit.cf* is used instead of *sendmail.cf*). 

```
$ sendmail -bt -v -Ac
```


### Parse an Address with /parse

(Adapted and modified based on 
"The Bat Book" - sendmail, 4th Edition by Bryan Costales, Claus Assmann,
George Jansen, Gregory Neil Shapiro - Published by O'Reilly Media, Inc.,
October 2007 - Chapter 8. Test Rule Sets with -bt;
Section *Parse an Address with /parse*.) 


The `/parse` rule-testing command instructs *sendmail* to pass an address
through a predetermined sequence of rules to select a delivery agent and
to put the `$u` macro into its final form.  The `/parse` command is used
like this:

```
/parse address
```

Parse the indicated addresses (dusko, dusko@localhost, dusko@fbsd1.home.arpa,
dusko@some.external.domain) returning the parsed address and mailer
(a.k.a. delivery agent) that *sendmail* will use. 

```
> /parse dusko
Cracked address = $g
Parsing envelope recipient address
canonify          input: dusko
Canonify2         input: dusko
Canonify2       returns: dusko
canonify        returns: dusko
parse             input: dusko
Parse0            input: dusko
Parse0          returns: dusko
ParseLocal        input: dusko
ParseLocal      returns: $# LR0relayST $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
parse           returns: $# LR0relayST $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
2                 input: dusko < @ fbsd1 . home . arpa . >
2               returns: dusko < @ fbsd1 . home . arpa . >
MasqSMTP          input: dusko < @ fbsd1 . home . arpa . >
MasqSMTP        returns: dusko < @ fbsd1 . home . arpa . >
final             input: dusko < @ fbsd1 . home . arpa . >
final           returns: dusko @ fbsd1 . home . arpa
mailer LR0relayST, host fbsd1.home.arpa, user dusko@fbsd1.home.arpa
```


```
> /parse dusko@localhost (FirstN LastN)
Cracked address = $g (FirstN LastN)
Parsing envelope recipient address
canonify          input: dusko @ localhost
Canonify2         input: dusko < @ localhost >
Canonify2       returns: dusko < @ fbsd1 . home . arpa . >
canonify        returns: dusko < @ fbsd1 . home . arpa . >
parse             input: dusko < @ fbsd1 . home . arpa . >
Parse0            input: dusko < @ fbsd1 . home . arpa . >
Parse0          returns: dusko < @ fbsd1 . home . arpa . >
ParseLocal        input: dusko < @ fbsd1 . home . arpa . >
ParseLocal      returns: $# LR0relayLH $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
parse           returns: $# LR0relayLH $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
2                 input: dusko < @ fbsd1 . home . arpa . >
2               returns: dusko < @ fbsd1 . home . arpa . >
MasqSMTP          input: dusko < @ fbsd1 . home . arpa . >
MasqSMTP        returns: dusko < @ fbsd1 . home . arpa . >
final             input: dusko < @ fbsd1 . home . arpa . >
final           returns: dusko @ fbsd1 . home . arpa 
mailer LR0relayLH, host fbsd1.home.arpa, user dusko@fbsd1.home.arpa
```

The address *you@localhost* is first fed into *crackaddr*
[line *Cracked address = $g (FirstN LastN)*] to separate it from any
surrounding RFC822 comments such as "(FirstN LastN)".  If mail were
actually to be sent, the address would be stored in the `$g` macro before
being passed to rules.  That line uses `$g` as a placeholder to show where
the address was found.

The next line (*Parsing envelope recipient address*) shows that the address
will be treated as that of an *envelope recipient*.  The `/tryflags` command
sets whether it is treated as a *header* or *envelope* or as a *sender* or
*recipient* address.

The address is passed to the `canonify` rule set 3 because all addresses
are rewritten by the `canonify` rule set 3 first.  The job of the `canonify`
rule set 3 is to focus on (surround in angle brackets) the host part of the
address, which it does (line *Canonify2          input: dusko < @ localhost >*).
The `canonify` rule set 3, in this example, then passes the address to the
`Canonify2` rule set to see whether *localhost* is a synonym for the
local machine's name.  Since it is, the `Canonify2` rule set makes that
translation (*Canonify2        returns: dusko < @ fbsd1 . home . arpa . >*).

The output of the `canonify` rule set 3 is passed to the `parse` rule set 0,
whose job is to select a **delivery agent**
(line *parse             input: dusko < @ fbsd1 . home . arpa . >*).
Since *fbsd1.home.arpa* is the local machine, the `parse` rule set 0
(by way of other rule sets) selects the `LR0relayLH` customized (local)
delivery agent   
(line
*parse    returns: $# LR0relayLH $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >*).

That line shows that the `$:` part of the delivery agent **triple** will
eventually be tucked into `$u` for use by the delivery agent's `A=`
delivery agent equate.  Before that happens, that address needs to be
passed through its own set of specific rules.   It is given to rule set 2
because all recipient addresses are given to rule set 2   
(line  *2            input: dusko < @ fbsd1 . home . arpa . >*). 
It is then given to rule set `MasqSMTP` because the `R=` delivery agent
equate for the `LR0relayLH` customized local delivery agent specifies rule
set `MasqSMTP` for the envelope recipient
(line *MasqSMTP          input: dusko < @ fbsd1 . home . arpa . >*).
Finally, it is given to the `final` rule set 4 because all addresses are
lastly rewritten by the final rule set 4 (line 
*final           returns: dusko @ fbsd1 . home . arpa*). 
The last line of output shows that the customized local delivery agent
`LR0relayLH` was selected and that the value that would be put into `$u`
(were mail really being sent) would be `dusko@fbsd1.home.arpa`.  


Similarly, with the actual local host's hostname (*fbsd1.home.arpa*):

```
> /parse dusko@fbsd1.home.arpa
Cracked address = $g
Parsing envelope recipient address
canonify          input: dusko @ fbsd1 . home . arpa
Canonify2         input: dusko < @ fbsd1 . home . arpa >
Canonify2       returns: dusko < @ fbsd1 . home . arpa . >
canonify        returns: dusko < @ fbsd1 . home . arpa . >
parse             input: dusko < @ fbsd1 . home . arpa . >
Parse0            input: dusko < @ fbsd1 . home . arpa . >
Parse0          returns: dusko < @ fbsd1 . home . arpa . >
ParseLocal        input: dusko < @ fbsd1 . home . arpa . >
ParseLocal      returns: $# LR0relayLH $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
parse           returns: $# LR0relayLH $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
2                 input: dusko < @ fbsd1 . home . arpa . >
2               returns: dusko < @ fbsd1 . home . arpa . >
MasqSMTP          input: dusko < @ fbsd1 . home . arpa . >
MasqSMTP        returns: dusko < @ fbsd1 . home . arpa . >
final             input: dusko < @ fbsd1 . home . arpa . >
final           returns: dusko @ fbsd1 . home . arpa
mailer LR0relayLH, host fbsd1.home.arpa, user dusko@fbsd1.home.arpa
```

In this configuration (with three customized delivery agents *LR0relayLH*,
*LR0relayST* and *smartrelay*), when you `/parse` an address that is not local:

```
> /parse dusko@some.external.domain
Cracked address = $g
Parsing envelope recipient address
canonify           input: dusko @ some . external . domain
Canonify2          input: dusko < @ some . external . domain >
Canonify2        returns: dusko < @ some . external . domain . >
canonify         returns: dusko < @ some . external . domain . >
parse              input: dusko < @ some . external . domain . >
Parse0             input: dusko < @ some . external . domain . >
Parse0           returns: dusko < @ some . external . domain . >
ParseLocal         input: dusko < @ some . external . domain . >
ParseLocal       returns: dusko < @ some . external . domain . >
Parse1             input: dusko < @ some . external . domain . >
MailerToTriple     input: < smartrelay : [ 127 . 0 . 0 . 1 ] > dusko < @ some . external . domain . >
MailerToTriple   returns: $# smartrelay $@ [ 127 . 0 . 0 . 1 ] $: dusko < @ some . external . domain . >
Parse1           returns: $# smartrelay $@ [ 127 . 0 . 0 . 1 ] $: dusko < @ some . external . domain . >
parse            returns: $# smartrelay $@ [ 127 . 0 . 0 . 1 ] $: dusko < @ some . external . domain . >
2                  input: dusko < @ some . external . domain . >
2                returns: dusko < @ some . external . domain . >
MasqSMTP           input: dusko < @ some . external . domain . >
MasqSMTP         returns: dusko < @ some . external . domain . >
final              input: dusko < @ some . external . domain . >
final            returns: dusko @ some . external . domain 
mailer smartrelay, host [127.0.0.1], user dusko@some.external.domain
```


In this configuration (with three customized delivery agents *LR0relayLH*,
*LR0relayST* and *smartrelay*), when you run the indicated addresses
(dusko, dusko@localhost, dusko@fbsd1.home.arpa, dusko@some.external.address)
through the rule 0:

```
> 0 dusko
parse             input: dusko
Parse0            input: dusko
Parse0          returns: dusko
ParseLocal        input: dusko
ParseLocal      returns: $# LR0relayST $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
parse           returns: $# LR0relayST $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
``` 

``` 
> 0 dusko@localhost
parse              input: dusko @ localhost
Parse0             input: dusko @ localhost
Parse0           returns: dusko @ localhost
ParseLocal         input: dusko @ localhost
ParseLocal       returns: dusko @ localhost
Parse1             input: dusko @ localhost
Parse1           returns: $# local $: dusko @ localhost
parse            returns: $# local $: dusko @ localhost
```

```
> 0 dusko@fbsd1.home.arpa
parse              input: dusko @ fbsd1 . home . arpa
Parse0             input: dusko @ fbsd1 . home . arpa
Parse0           returns: dusko @ fbsd1 . home . arpa
ParseLocal         input: dusko @ fbsd1 . home . arpa
ParseLocal       returns: dusko @ fbsd1 . home . arpa
Parse1             input: dusko @ fbsd1 . home . arpa
Parse1           returns: $# local $: dusko @ fbsd1 . home . arpa
parse            returns: $# local $: dusko @ fbsd1 . home . arpa
```

```
> 0 dusko@some.external.address
parse              input: dusko @ some . external . domain
Parse0             input: dusko @ some . external . domain
Parse0           returns: dusko @ some . external . domain
ParseLocal         input: dusko @ some . external . domain
ParseLocal       returns: dusko @ some . external . domain
Parse1             input: dusko @ some . external . domain
Parse1           returns: $# local $: dusko @ some . external . domain
parse            returns: $# local $: dusko @ some . external . domain
```


Display the known mailers (by using the `=M` rule-testing command):

```
> =M
[ . . . ]
mailer 8 (relay): P=[IPC] S=EnvFromSMTP/HdrFromSMTP R=MasqSMTP/MasqSMTP M=0 U=-1:-1 F=8DFMXakmu L=2040 E=\r\n T=DNS/RFC822/SMTP r=100 A=TCP $h
mailer 9 (LR0relay): P=[IPC] S=EnvFromSMTP/HdrFromSMTP R=MasqSMTP/MasqSMTP M=0 U=-1:-1 F=8DFMXakmu L=2040 E=\r\n T=DNS/RFC822/SMTP r=100 A=TCP $h
mailer 10 (smartrelay): P=[IPC] S=EnvFromSMTP/HdrFromSMTP R=MasqSMTP/MasqSMTP M=0 U=-1:-1 F=8DFMXakmu L=2040 E=\r\n T=DNS/RFC822/SMTP r=100 A=TCP $h 1465
```

Dump the contents of the Ruleset 0.

```
> =S0
R$*             $: $> Parse0 $1 
R< @ >          $# local $: < @ > 
R$*             $: $> ParseLocal $1 
R$*             $: $> Parse1 $1 
```


Dump the contents of the rule Parse0.

```
> =SParse0
R< @ >          $@ < @ >
[ . . . ]
R$* $=O $* < @ *LOCAL* >                $@ $> Parse0 $> canonify $1 $2 $3 
R$* < @ *LOCAL* >               $: $1 
```

Dump the contents of the rule ParseLocal.

```
> =SParseLocal
R$-       $# LR0relayST $@ fbsd1 . home . arpa $: $1 < @ fbsd1 . home . arpa . > 
R$+ < @ fbsd1 . home . arpa . >       $# LR0relayLH $@ fbsd1 . home . arpa $: $1 < @ fbsd1 . home . arpa . >
```


Dump the contents of the rule Parse1.

```
> =SParse1
R$* < @ [ $+ ] > $*             $: $> ParseLocal $1 < @ [ $2 ] > $3 
R$* < @ [ $+ ] > $*             $: $1 < @ [ $2 ] : smartrelay : [ 127 . 0 . 0 . 1 ] > $3 
R$* < @ [ $+ ] : > $*           $# esmtp $@ [ $2 ] $: $1 < @ [ $2 ] > $3 
R$* < @ [ $+ ] : $- : $* > $*           $# $3 $@ $4 $: $1 < @ [ $2 ] > $5 
R$* < @ [ $+ ] : $+ > $*                $# esmtp $@ $3 $: $1 < @ [ $2 ] > $4 
R$=L < @ $=w . >                $# local $: @ $1 
R$+ < @ $=w . >                 $# local $: $1 
R$* < @ $* > $*                 $: $> MailerToTriple < smartrelay : [ 127 . 0 . 0 . 1 ] > $1 < @ $2 > $3 
R$* < @ $* > $*                 $# esmtp $@ $2 $: $1 < @ $2 > $3 
R$=L            $# local $: @ $1 
R$+             $# local $: $1 
```

Tests:

```
$ printf %s\\n "Testing." | mail -v -s "Test 1" dusko
dusko... Connecting to fbsd1.chem.ubc.ca. via LR0relayST...
[ . . . ]
```

```
$ printf %s\\n "Testing." | mail -v -s "Test 2" dusko@localhost
dusko@localhost... Connecting to fbsd1.chem.ubc.ca. via LR0relayLH...
[ . . . ]
```

```
$ printf %s\\n "Testing." | mail -v -s "Test 3" dusko@fbsd1.home.arpa
dusko@fbsd1.home.arpa... Connecting to fbsd1.home.arpa. via LR0relayLH...
[ . . . ]
```

```
$ printf %s\\n "Testing." | mail -v -s "Test 4" dusko@some.external.domain
dusko@some.external.domain... Connecting to [127.0.0.1] port 1465 via smartrelay...
[ . . . ]
```

Quit address test mode with the `/quit`.

```
> /quit
```

---

When you run `make`, if `your_machine_hostname.mc` file does not exist, 
it is created (using `freebsd.mc` file as a template).  Similarly, if 
`your_machine_hostname.submit.mc` file does not exist, it is created
using `freebsd.submit.mc` file as a template. 

More specifically, when you run `make`:
* the `freebsd.mc` file gets copied to `your_machine_hostname.mc` 
* the `m4` macro processor utility processes `your_machine_hostname.mc` 
  into `your_machine_hostname.cf`
* the `freebsd.submit.mc` file gets copied to `your_machine_hostname.submit.mc`
* the `m4` macro processor utility processes `your_machine_hostname.submit.mc`
  into `your_machine_hostname.submit.cf`


NOTE:  
`make install` will also install the `*.mc` files as `*.cf` files;
that is, it will install `your_machine_hostname.mc` as  
  **`sendmail.cf`**  
and   
`your_machine_hostname.submit.mc` as  
  **`submit.cf`**.   
[A `make install` is only necessary after modifying the *.mc* file(s).]


```
# make 
```

Output:

```
cp -f freebsd.mc fbsd1.home.arpa.mc
/usr/bin/m4 -D_CF_DIR_=/usr/local/share/sendmail/cf/   /usr/local/share/sendmail/cf/m4/cf.m4 fbsd1.home.arpa.mc > fbsd1.home.arpa.cf 

cp -f freebsd.submit.mc fbsd1.home.arpa.submit.mc
/usr/bin/m4 -D_CF_DIR_=/usr/local/share/sendmail/cf/   /usr/local/share/sendmail/cf/m4/cf.m4 fbsd1.home.arpa.submit.mc > fbsd1.home.arpa.submit.cf
```


Modify the `mailer.conf` file.  (Note that `mailer.conf`
is in two locations.  The mailwrapper(8) program first looks in
`/usr/local/etc/mail/mailer.conf` falling back on `/etc/mail/mailer.conf`.)

```
$ sudo cp -i /usr/local/etc/mail/mailer.conf /usr/local/etc/mail/mailer.conf.ORIG
```

```
$ cat /etc/mail/mailer.conf.ORIG 
# $FreeBSD$
#
# Execute the "real" sendmail program, named /usr/libexec/sendmail/sendmail
#
# If dma(8) is installed, an example mailer.conf that uses dma(8) instead can
# can be found in /usr/share/examples/dma.
#
sendmail        /usr/libexec/sendmail/sendmail
mailq           /usr/libexec/sendmail/sendmail
newaliases      /usr/libexec/sendmail/sendmail
hoststat        /usr/libexec/sendmail/sendmail
purgestat       /usr/libexec/sendmail/sendmail
```

```
$ sudo vi /usr/local/etc/mail/mailer.conf
```

```
$ cat /usr/local/etc/mail/mailer.conf
#
# Execute the "real" sendmail program, named /usr/local/sbin/sendmail
#
sendmail        /usr/local/sbin/sendmail
send-mail       /usr/local/sbin/sendmail
mailq           /usr/local/sbin/sendmail
newaliases      /usr/local/sbin/sendmail
hoststat        /usr/local/sbin/sendmail
purgestat       /usr/local/sbin/sendmail
```


```
$ sudo cp -i /etc/mail/mailer.conf /etc/mail/mailer.conf.ORIG
```

```
$ sudo cp -i /usr/local/etc/mail/mailer.conf /etc/mail/
```

```
$ cat /etc/mail/mailer.conf
#
# Execute the "real" sendmail program, named /usr/local/sbin/sendmail
#
sendmail        /usr/local/sbin/sendmail
send-mail       /usr/local/sbin/sendmail
mailq           /usr/local/sbin/sendmail
newaliases      /usr/local/sbin/sendmail
hoststat        /usr/local/sbin/sendmail
purgestat       /usr/local/sbin/sendmail
```


## Authenticating with AUTH

From **sendmail Cookbook** by Craig Hunt (Published by O'Reilly
Media, Inc., Publication Date: December 2003):

> Strong authentication uses cryptographic techniques to verify the
> identity of the **end points** in a network exchange.  For *sendmail*,
> strong authentication ensures that the connecting host and the receiving
> host are **who they claim to be**.  
>
> Authentication is not the same as encryption.  Encryption can be used to
> hide the content of a piece of mail or to hide the entire SMTP protocol
> exchange, including the mail.  (One technique for encrypting the SMTP
> exchange, and the mail it carries, is covered in Chapter 8. Securing the
> Mail Transport. **[<sup>[ 11 ](#footnotes)</sup>])**  Authentication does not
> hide the contents of mail; rather, it ensures that the mail comes from
> the correct source.   
> [ . . . ]    
> **The AUTH Protocol**  
> **AUTH** is an SMTP protocol extension. It is defined in RFC 2554,
> *SMTP Service Extension for Authentication*.  RFC 2554 outlines the
> negotiations that are used to select an authentication mechanism.
> **[<sup>[ 12 ](#footnotes)</sup>]**    
> [ . . . ]   
> The AUTH protocol relies on the **Simple Authentication and Security
> Layer (SASL)** for the actual authentication.  RFC 2222,
> *Simple Authentication and Security Layer (SASL)*, describes the SASL
> framework and defines how protocols negotiate an authentication method.   
> [ . . . ]   
> *sendmail* does not contain implementations of the various authentication
> techniques.  Instead, *sendmail* uses the techniques that are implemented
> and configured in SASL.  For this to work, Cyrus SASL must be installed
> and properly configured on the *sendmail* system.  

Refer to
**[AuthMechanisms Option](#authmechanisms-option)** section below for
more information about SASL (including a reference to an additional RFC:
RFC2554).  

> **Cyrus SASL**  
> Cyrus SASL is implemented as a library.  The SASL library standardizes
> the way in which applications interface with the authentication methods.
> Many Unix systems come with the SASL libraries preinstalled. 
> 
> If SASL is not installed on your system, check to see if it was delivered
> as part of your Unix software.  If it was, install the copy of SASL
> provided by your Unix vendor.  If it is not available from your vendor,
> go to [http://www.cyrusimap.org/sasl/](http://www.cyrusimap.org/sasl/)
> to download the latest version of SASL. 
> 
> After Cyrus SASL is installed, the specific authentication techniques
> must be configured before they can be used.  To understand SASL
> configuration, you must understand SASL terminology.
> **[<sup>[ 13 ](#footnotes)</sup>]**    
> 
> **The SASL Sendmail.conf file**   
> . . . Some authentication techniques (authentication mechanisms)
> available through SASL that can be used with *sendmail* require
> configuration through the *Sendmail.conf* SASL application file.
> **[<sup>[ 14 ](#footnotes)</sup>]**    

> **Passing Flags to SASL**
> 
> *sendmail* can be configured to request optional processing from SASL
> for the AUTH protocol.  The `confAUTH_OPTIONS` define can set several
> flags that affect the way that *sendmail* and SASL interact.
> **[<sup>[ 15 ](#footnotes)</sup>]**    

> **Authentication Macros and Rulesets**
> 
> *sendmail* uses the information provided by authentication and stores
> authentication data in several macros.  The authentication macros are:
> 
> *${auth_author}*  
> This macro holds the *sendmail* **authorization id**, which is the address
> assigned to the `AUTH=` parameter on the `MAIL From:` line.
> 
> *${auth_authen}*  
> This macro holds the *sendmail* **authentication id**, which is either the
> userid or the userid and the realm, written as *userid* @ *realm*.
> 
> *${auth_type}*  
> This macro holds the name of the authentication method used to
> authenticate the client.  For example, LOGIN would be a possible
> `${auth_type}` value.
> 
> *${auth_ssf}*   
> This macro holds the number of bits used for optional SASL encryption.
> If no SASL link encryption is used, this macro is unassigned.
 
> In addition to the authentication macros, the **hostname** *and*
> the **IP address** of the system at the other end of the mail transport
> connection are stored in macros, which can be useful information for
> authentication checks.  The following values are stored in the macros:
> 
> *${server_addr}*  
> The *IP address* of the **remote server**, as determined from the
> TCP connection.  This macro is used on the **client**.
>
> *${server_name}*   
> The *hostname* of the **remote server**, as determined from a hostname
> lookup of the `${server_addr}` value.  This macro is used on the
> **client**.
>
> *${client_addr}*  
> The *IP address* of the **client**, as determined from the TCP connection.
> This macro is used on the **server**.
> 
> *${client_name}*  
> The *hostname* of the **client**, as determined from a hostname lookup of
> the `${client_addr}` value.  This macro is used on the **server**.

> *sendmail* also provides *ruleset* **hooks** that simplify the process of
> adding authentication checks.  The primary hooks used with AUTH are:
> 
> *Local_check_mail*  
> This ruleset adds checks to the `check_mail` ruleset, which is used to
> process the **envelope sender address** from the `MAIL From:` line.
> The `check_mail` ruleset is **not** specific to AUTH, but the overlap
> between the `${auth_author}` value and the envelope sender address means
> that `Local_check_mail` is occasionally used for custom AUTH processing.
>
> *Local_check_rcpt*  
> This ruleset adds checks to the `check_rcpt` ruleset, which processes
> the **envelope recipient address** from the `RCPT To:` line.
> The `check_rcpt` ruleset is **not** specific to AUTH, but because it is
> used to authorize delivery to a recipient, `Local_check_rcpt` is
> occasionally used to modify it for AUTH processing.
>
> *Local_trust_auth*  
> This ruleset adds checks to the `trust_auth` ruleset, which is used by
> the server to determine whether the `AUTH=` parameter on the `MAIL From:`
> line should be trusted.  The `trust_auth` ruleset is specific to the AUTH
> protocol because the `AUTH=` parameter is only used when AUTH is running
> on the client.  Use `Local_trust_auth` to customize the processing of
> the `AUTH=` parameter.
>
> *Local_Relay_Auth*  
> This ruleset is called by the `Rcpt_ok` ruleset.  By default, *sendmail*
> grants relaying privileges to an authenticated client only if the client
> authenticated is using a mechanism listed in the `$={TrustAuthMech}` class.
> Use `Local_Relay_Auth` to modify the process of granting relaying
> privileges to **authenticated clients**.


## Storing AUTH Credentials in the authinfo File

From the *sendmail* **cf/README** (`/usr/local/share/sendmail/cf/README`),
under the section for **MSP** (Message Submission Program), which is a
command-line *sendmail* that functions as a mail submission agent (**MSA**):

```
[ . . . ]
+----------------------------+
| MESSAGE SUBMISSION PROGRAM |
+----------------------------+
[ . . . ]
If the MSP should actually use AUTH then the necessary data
should be placed in a map as explained in SMTP AUTHENTICATION:

FEATURE(`authinfo', `DATABASE_MAP_TYPE /etc/mail/msp-authinfo')

/etc/mail/msp-authinfo should contain an entry like:

        AuthInfo:127.0.0.1      "U:smmsp" "P:secret" "M:DIGEST-MD5"

The file and the map created by makemap should be owned by smmsp,
its group should be smmsp, and it should have mode 640.  

The database used by the MTA for AUTH must have a corresponding entry.

Additionally the MTA must trust this authentication data so the AUTH=
part will be relayed on to the next hop.  This can be achieved by
adding the following to your sendmail.mc file:

        LOCAL_RULESETS
        SLocal_trust_auth
        R$*     $: $&{auth_authen}
        Rsmmsp  $# OK
[ . . . ]
```


Create the */etc/mail/authinfo* file (for storing AUTH authentication
credentials in a file separate from the *access* database). 


**NOTE:**  In the two lines below `SLocal_trust_auth`
**[<sup>[ 16 ](#footnotes)</sup>]**, there is a **tab** character
before `$:` and before `$#`.   


You need to store the client's authentication credentials in that file
using the same `AuthInfo:` tag used in the *access* database, and you need
to make sure that the *authinfo* text file and database are not readable
by anyone except the *smmsp* user. 

```
$ sudo vi /etc/mail/authinfo
```

```
$ sudo chown smmsp:smmsp /etc/mail/authinfo
$ sudo chmod 0640 /etc/mail/authinfo
```

```
$ ls -lh /etc/mail/authinfo
-rw-r-----  1 smmsp  smmsp   142B Nov 12 19:57 /etc/mail/authinfo
```

```
$ grep '127.0.0.1' /etc/hosts
127.0.0.1               localhost localhost.my.domain
```

```
$ sudo cat /etc/mail/authinfo
AuthInfo:[127.0.0.1] "U:smmsp" "I:dusko" "P:YourISPPassword" "M:LOGIN"
AuthInfo:127.0.0.1 "U:smmsp" "I:dusko" "P:YourISPPassword" "M:LOGIN"
```

In my tests, when the letter `M` (the list of mechanisms, separated by
spaces) had both PLAIN and LOGIN mechanisms; that is `"M:PLAIN LOGIN"`
(or: `"M:LOGIN PLAIN"`), *sendmail* used only the PLAIN mechanism.
*Sendmail* used the LOGIN mechanism when the `M` letter had only `LOGIN`
(that is, `"M:LOGIN"`).


**NOTE:** This requires the use of the *authinfo* FEATURE to the
*sendmail* configuration, which you did above, when you modified
the `freebsd.submit.mc` file. 


**NOTE:** If the `make all` command generates an error `No such file or
directory` for `sendmail.cf`:

```
$ cd /etc/mail

$ sudo su
```

```
# make all
[ . . . ]
/usr/sbin/makemap hash authinfo.db < authinfo
makemap: /etc/mail/sendmail.cf: No such file or directory
*** Error code 66

Stop.
make: stopped in /etc/mail
```

fix it by creating an empty `sendmail.cf` file:

```
# touch /etc/mail/sendmail.cf
```

and then run `make all` again:

```
# make all
[ . . . ]
/usr/sbin/makemap hash authinfo.db < authinfo
chmod 0640 authinfo.db
```

```
# ls -lh /etc/mail/authinfo*
-rw-r-----  1 smmsp  smmsp   142B Nov 12 19:57 /etc/mail/authinfo
-rw-r-----  1 root   wheel   128K Nov 12 17:57 /etc/mail/authinfo.db
```

```
# chown smmsp:smmsp /etc/mail/authinfo.db 
# sudo chmod 0640 /etc/mail/authinfo.db
```

```
# ls -lh /etc/mail/authinfo*
-rw-r-----  1 smmsp  smmsp   142B Nov 12 19:57 /etc/mail/authinfo
-rw-r-----  1 smmsp  smmsp   128K Nov 12 19:57 /etc/mail/authinfo.db
```


**NOTE:**  When you need to re-create *sendmail* configuration files with 
these permissions for `authinfo.db`, you might encounter a `Permission
denied` error: 

```
# make all   (# or 'make install')
[ . . . ]
/usr/sbin/makemap hash authinfo.db < authinfo
makemap: error opening type hash map authinfo.db: Permission denied
*** Error code 73

Stop.
make: stopped in /etc/mail
```

To fix it, temporary change permissions for `authinfo.db`:

```
# chgrp wheel /etc/mail/authinfo.db
# chmod 0660 /etc/mail/authinfo.db
```

```
# ls -lh /etc/mail/authinfo.db
-rw-rw----  1 smmsp  wheel   128K Nov 12 19:14 /etc/mail/authinfo.db
``` 

``` 
# make all
/usr/sbin/makemap hash authinfo.db < authinfo
chmod 0640 authinfo.db
```

```
# ls -lh /etc/mail/authinfo.db
-rw-r-----  1 smmsp  wheel   128K Nov 12 19:14 /etc/mail/authinfo.db
``` 
 
After successfull `make run`, change the permissions back:

```
# chgrp smmsp /etc/mail/authinfo.db
```
 
```
# ls -lh /etc/mail/authinfo.db
-rw-r-----  1 smmsp  smmsp   128K Nov 12 19:14 /etc/mail/authinfo.db
```

and continue:

```
# make install
# make start
Starting: sendmail sendmail-clientmqueue.
```

```
# exit
exit
% 
```

```
$ sendmail -d0 < /dev/null
Version 8.17.1
 Compiled with: DANE DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PICKY_HELO_CHECK PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS
                TLS_EC TLS_VRFY_PER_CTX USERDB XDEBUG

============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================
 
Recipient names must be specified
```


```
$ sendmail -d0.1 -bv root 
Version 8.17.1
 Compiled with: DANE DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PICKY_HELO_CHECK PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS
                TLS_EC TLS_VRFY_PER_CTX USERDB XDEBUG

============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================

Notice: -bv may give misleading output for non-privileged user
root... deliverable: mailer local, user root
``` 

```
$ sudo /usr/libexec/sendmail/sendmail -d0.1 -bv root
Version 8.16.1
 Compiled with: DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PIPELINING SCANF STARTTLS TCPWRAPPERS TLS_EC TLS_VRFY_PER_CTX
                USERDB XDEBUG

============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================

root... deliverable: mailer local, user root
```

```
$ sudo /usr/sbin/sendmail -d0.1 -bv root
Version 8.17.1
 Compiled with: DANE DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PICKY_HELO_CHECK PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS
                TLS_EC TLS_VRFY_PER_CTX USERDB XDEBUG

============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================

root... deliverable: mailer local, user root
```


### Install and Configure stunnel

```
$ sudo pkg install stunnel
```

```
$ sudo cp -i /usr/local/etc/stunnel/stunnel.conf-sample /usr/local/etc/stunnel/stunnel.conf
```

```
$ sudo vi /usr/local/etc/stunnel/stunnel.conf
```

```
$ cat /usr/local/etc/stunnel/stunnel.conf
include = /usr/local/etc/stunnel/conf.d

[smarthost]
client = yes
accept = 127.0.0.1:1465 
connect = your.isp.net:465
```

where `your.isp.net` is the FQDN of the SMTP server (your ISP). 


Set `stunnel_enable` to `YES` in `/etc/rc.conf`:

```
$ printf %s\\n 'stunnel_enable="YES"' | sudo tee -a /etc/rc.conf
```

Start *stunnel* service. 

```
$ sudo service stunnel start
```

```
$ sudo service stunnel status
stunnel is running as pid 51293.
```


```
$ cd /etc/mail

$ sudo su
```

```
# rm -i /etc/mail/fbsd1.home.arpa.*
remove /etc/mail/fbsd1.home.arpa.cf? y
remove /etc/mail/fbsd1.home.arpa.mc? y
remove /etc/mail/fbsd1.home.arpa.submit.cf? y
remove /etc/mail/fbsd1.home.arpa.submit.mc? y
```

```
# rm -i /etc/mail/*.cf
remove /etc/mail/sendmail.cf? y
remove /etc/mail/submit.cf? y
```

Run `make all`, `make install` and `make restart` (or `make stop` and 
then `make restart`, depending on whether *sendmail* is currently running 
or not). 


```
# make all
# make install
# make restart
```

```
# service sendmail status
sendmail is running as pid 69385.
sendmail_msp_queue is running as pid 69388.
```

```
# ps aux | grep -v grep | grep sendmail
root    6938   0.0  0.0    18972    7228  -  Ss   19:14       0:00.01 sendmail: accepting connections (sendmail)
smmsp   6941   0.0  0.0    18312    6304  -  Is   19:14       0:00.00 sendmail: Queue runner@00:30:00 for /var/spool/clientmqueue (sendmail)
```

```
# tail /var/log/maillog
Nov 12 19:14:21 fbsd1 sm-mta[6938]: starting daemon (8.17.1): SMTP+queueing@00:30:00
[ . . . ]
Nov 12 19:14:21 fbsd1 sm-mta[6938]: STARTTLS=server, Diffie-Hellman init, key=2048 bit (I)
Nov 12 19:14:21 fbsd1 sm-mta[6938]: STARTTLS=server, init=1
Nov 12 19:14:21 fbsd1 sm-mta[6938]: started as: /usr/sbin/sendmail -L sm-mta -bd -q30m
Nov 12 19:14:21 fbsd1 sm-msp-queue[6941]: starting daemon (8.17.1): queueing@00:30:00
Nov 12 19:14:21 fbsd1 sm-msp-queue[6941]: started as: /usr/sbin/sendmail -L sm-msp-queue -Ac -q30m
```

If you now receive a `No local mailer defined` error when you run `make all`: 

```
# make all
/usr/sbin/makemap hash authinfo.db < authinfo
chmod 0640 authinfo.db
/usr/sbin/sendmail -bi -OAliasFile=/etc/mail/aliases
Warning: .cf file is out of date: sendmail 8.17.1 supports 
  version 10, .cf file is version 0
No local mailer defined
QueueDirectory (Q) option must be set
*** Error code 78

Stop.
make: stopped in /etc/mail
```

it's because *sendmail.cf* is still empty. 

```
# ls -lh sendmail.cf 
-rw-r--r--  1 root  wheel     0B Nov 12 19:10 sendmail.cf
``` 
 
To fix that, run `make install`:

``` 
# make install
install -m 444 fbsd1.home.arpa.cf /etc/mail/sendmail.cf
install -m 444 fbsd1.home.arpa.submit.cf /etc/mail/submit.cf
```


```
# ls -lh sendmail.cf
-r--r--r--  1 root  wheel    59K Nov 12 19:11 sendmail.cf
```


Now, the `make all` command runs fine: 

```
# make all
/usr/sbin/sendmail -bi -OAliasFile=/etc/mail/aliases
/etc/mail/aliases: 29 aliases, longest 10 bytes, 297 bytes total
chmod 0640 /etc/mail/aliases.db
```


Continue.  In this case, *sendmail* was not running so I used
`make start` (you might need to run `make restart` to first stop
*sendmail* if it's running on your system).

```
# make install
# make start
```

```
# service sendmail status
sendmail is running as pid 47902.
sendmail_msp_queue is running as pid 47905.
```

```
# exit
$ cd

$ pwd
/usr/home/dusko
```

```
$ sudo chown smmsp:smmsp /etc/mail/authinfo.db 
```

```
$ ls -lh /etc/mail/authinfo*
-rw-r-----  1 smmsp  smmsp    81B Nov 12 19:11 /etc/mail/authinfo
-rw-r-----  1 smmsp  smmsp   128K Nov 12 19:11 /etc/mail/authinfo.db
```


```
# service sendmail status
sendmail is running as pid 49494.
sendmail_msp_queue is running as pid 49497.
```


### Testing SMTP with telnet(1) (or nc(1) aka (netcat(1))

The Simple Mail Transfer Protocol (SMTP) governs mail flow.
SMTP conversation can be carried out by connecting to port 25 on
a mail server via `telnet(1)`. 

**NOTE:**   
Telnet is not secure as all communication in it happens in plain text
and all network traffic is unencrypted.  I decided it's fine to use it
for testing my *localhost* because it's in my trusted environment with
trusted network and applications.  


Below is a sample test SMTP session with `telnet(1)` to Port 25 from
my *localhost*.  


**NOTE:**   
In the examples, "**C:**" indicates what is said by the SMTP
client, "**T:**" is what you type (that is, in the following example,
you type the following three lines: `telnet localhost 25`, `ehlo localhost`, 
and `quit`), and "**S:**" indicates what is said by the SMTP server.

```
S: <waits for connection on TCP port 25>
C: <opens connection>   # with telnet
```

The second line shows the *telnet* command format using host *localhost*
and TCP port 25. 

```
S: <waits for connection on TCP port 25>

CT: telnet localhost 25
C: Trying 127.0.0.1...
C: Connected to localhost.
C: Escape character is '^]'.
S: 220 fbsd1.home.arpa ESMTP Sendmail 8.17.1/8.17.1; Sat, 12 Nov 2022 12:00:35 -0700 (PDT)
CT: ehlo localhost
S: 250-fbsd1.home.arpa Hello localhost [127.0.0.1], pleased to meet you
S: 250-ENHANCEDSTATUSCODES
S: 250-PIPELINING
S: 250-8BITMIME
S: 250-SIZE
S: 250-DSN
S: 250-ETRN
S: 250-AUTH DIGEST-MD5 CRAM-MD5
S: 250-STARTTLS
S: 250-DELIVERBY
S: 250 HELP
CT: quit
S: 221 2.0.0 fbsd1.home.arpa closing connection
C: Connection closed by foreign host.
``` 

From **Postfix** by Richard Blum
(Published By: Sams, Publication Date: May 2001):

> If the server is running an SMTP-based daemon, you should see a response
> similar to the one shown.  The first number is a 3-digit response code.
> You can use this code for troubleshooting purposes. 
> 
> Next, the hostname of the SMTP server and a description of the SMTP
> software package that the server is using are displayed
> (in this case, *Sendmail 8.17.1/8.17.1*). 
> 
> To close the *telnet* connection, type the word `quit` and press the
> Enter key.  The SMTP server sends you a closing message and ends the
> TCP connection.
> 
> SMTP accepts simple ASCII text commands and returns 3-digit reply codes
> with optional ASCII text messages.  SMTP is defined in the Request For
> Comment (RFC) document number 821 maintained by the Internet Engineering
> Task Force (IETF) published on August 21, 1982.  Several modifications
> and enhancements have been made to SMTP over the years, but the basic
> protocol commands still remain in use.

> #### Basic SMTP Client Commands
> 
> When a TCP session has been established and the SMTP server acknowledges
> the client by sending a welcome banner, it is the client's responsibility
> to control the connection and transmit data to the server.  The client
> accomplishes this by sending special commands to the server.  The server
> responds according to each command it receives.
>
> RFC 821 defines the basic client commands that an SMTP server should
> recognize and respond to.  Since then, there have been several extensions
> to SMTP that not all servers have implemented. 
>
> The basic format of an SMTP command is
> 
> ```
> command [parameters]
> ```
> 
> where `command` is a 4-character SMTP command, and `parameters` are
> optional qualifying data for the command.  For SMTP connections,
> the command names are **not** case sensitive.  Table at the end 
> of this page
> **[<sup>[ 18 ](#footnotes)</sup>]** lists basic SMTP commands. 


**NOTE:** You can use the `nc(1)` (*netcat*) utility instead of
the `telnet(1)` command (`nc localhost 25`).  For *localhost* testing,
I decided that *telnet* is fine. 


[RFC 3207](https://datatracker.ietf.org/doc/html/rfc3207) defines how SMTP
connections can make use of encryption.  Once a connection is established,
the client issues a STARTTLS command.  If the server accepts this, the client
and the server negotiate an encryption mechanism.  If the negotiation
succeeds, the data that subsequently passes between them is encrypted. 


**NOTE:** In this example, the AUTH line (`250-AUTH DIGEST-MD5 LOGIN PLAIN`)
now has `LOGIN PLAIN` when inquiring MSA (Mail Submission Agent) port 587
(while it didn't have LOGIN and PLAIN when testing via port 25).   
"**C:**" indicates what is said by the SMTP client, "**T:**" is what you
type (that is, in the following example, you type the following three lines:
`telnet localhost 587`, `ehlo localhost`, and `quit`), and "**S:**" indicates
what is said by the SMTP server.   

``` 
S: <waits for connection on TCP port 587>

CT: telnet localhost 587
C: Trying 127.0.0.1...
C: Connected to localhost.
C: Escape character is '^]'.
S: 220 fbsd1.home.arpa ESMTP Sendmail 8.17.1/8.17.1; Sat, 12 Nov 2022 12:00:46 -0700 (PDT)
CT: ehlo localhost
S: 250-fbsd1.home.arpa Hello localhost [127.0.0.1], pleased to meet you
S: 250-ENHANCEDSTATUSCODES
S: 250-PIPELINING
S: 250-8BITMIME
S: 250-SIZE
S: 250-DSN
S: 250-AUTH DIGEST-MD5 LOGIN PLAIN
S: 250-STARTTLS
S: 250-DELIVERBY
S: 250 HELP
CT: quit
S: 221 2.0.0 fbsd1.home.arpa closing connection
C: Connection closed by foreign host.
```


## Testing and Troubleshooting with sendmail Command-Line

Some of *sendmail* parameters (from the man page for `sendmail(8)`):

**-v**:  Verbose mode.  Alias expansions will be announced, etc.   
**-d***category.level...*: Set the debugging flag for category to *level*.
The *category* is either an integer or a name specifying the topic,
and *level* is an integer specifying the level of debugging output desired.
Higher levels generally mean more output.  More than one flag can be
specified by separating them with commas.  A list of numeric debugging
categories found in the *TRACEFLAGS* file in the *sendmail* source
distribution.  The option **-d0.1** prints the version of *sendmail* and
the options used during the compile.  Most other categories are only
useful with, and documented in, *sendmail*'s source code.

Location of the *TRACEFLAGS* file in FreeBSD 13:
`/usr/local/share/doc/sendmail/TRACEFLAGS` and 
`/usr/src/contrib/sendmail/src/TRACEFLAGS`.   


Send a test email message with *sendmail* command-line:

```
$ date | sendmail -v -d38.20 dusko@some.external.domain
```


Some of *sendmail* parameters (from the man page for `sendmail(8)`):

**-Ac**:  Use **submit.cf** even if the operation mode does not indicate
          an initial mail submission; via the **MSP** (mail submission program)
          [which is a command-line *sendmail* that functions as a mail submission agent (**MSA**)].

**-d38.20**:  Debug command-line switch for tracing many different map
              lookups and also for tracing general lookups in various
              kinds of databases. 

**-odi**:  Deliver in foreground.

Explanation for **-odi**: 

**-o**x *value* (from the man page for `sendmail(8)`):  Set option *x* to
the specified *value*.  This form uses single character names only.
The short names are not described in this manual page; see the Sendmail
Installation and Operation Guide (on FreeBSD 13:
*/usr/local/share/doc/sendmail/op.txt*, or
*/usr/local/share/doc/sendmail/op.ps*) for details.  


**Options**   
There are also many processing options that can be set.  Normally these
are only used by a system administrator.  Options may be set either on the
command line using the **-o** flag (for short names), the **-O** flag (for 
long names), or in the **configuration file**.  Some of the options are:

**DeliveryMode=***x*    
Set the delivery mode to *x*.  Delivery modes are
"**i**" for interactive (synchronous) delivery (a.k.a. delivery in
foreground), "**b**" for background (asynchronous) delivery, "**q**" for
queue only; i.e., actual delivery is done the next time the queue is run,
and "**d**" for deferred - the same as "**q**", except that database
lookups for maps which have set the **-D** option (default for the
host map) are avoided.

As an example, the **-odi** in *sendmail* source:

```
$ sed -n 284p /usr/src/contrib/sendmail/rmail/rmail.c
        args[i++] = "-odi";             /* Deliver in foreground. */
```

Similarly, the **-d38.20** debug command-line switch in *sendmail* source:

```
$ sed -n 5590p /usr/src/contrib/sendmail/src/map.c
                if (tTd(38,20))
```


Send a test email message with *sendmail* command-line:

```
$ date | sendmail -Ac -v -d38.20 -odi dusko@some.external.domain
```


Some of sendmail parameters (from the man page for sendmail(8)):

**-Am**:  Use **sendmail.cf** even if the operation mode indicates an
          initial mail submission. 

**-t:**  Read message for recipients. **To:**, **Cc:**, and **Bcc:** lines
         will be scanned for recipient addresses.  The **Bcc:** line is 
         deleted before transmission.


Send a test email message with *sendmail* command-line.
In the following example, type in the first seven lines (starting with
`sendmail -Ac -v -t` and ending with a single dot).

(The lines that begin with numbers and the lines that begin with `>>>`
 characters constitute a record of the SMTP conversation.  The other lines
 are *sendmail* on your local machine telling you what it is trying to do
 and what it has successfully done.)   

```
$ sendmail -Ac -v -t
To: Dusko P <dusko@some.external.domain>
From: DP <dusko@fbsd1.home.arpa>
Subject: Test with -Ac

Testing.
.
Dusko P <dusko@some.external.domain>... Connecting to [127.0.0.1] port 1465 via smartrelay...
220 mailx.some.external.domain ESMTP mailer ready at Sat, 12 Nov 2022 16:51:07 -0700
>>> EHLO fbsd1.home.arpa
250-test.domain Hello fqdn.yourisp.domain [123.45.6.7], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-AUTH LOGIN PLAIN
250-DELIVERBY
250 HELP
>>> AUTH LOGIN
334 VXNlcm5hbWU6
>>> ABCab12=
334 UGFzc3dvcmQ6
>>> ABCdEF12gHIJkLMnoPQRSt==
235 2.0.0 OK Authenticated
>>> MAIL From:<dusko@fbsd1.home.arpa> SIZE=110 AUTH=dusko@fbsd1.home.arpa
250 2.1.0 <dusko@fbsd1.home.arpa>... Sender ok
>>> RCPT To:<dusko@some.external.domain>
250 2.1.5 <dusko@some.external.domain>... Recipient ok
>>> DATA
354 Enter mail, end with "." on a line by itself
>>> .
250 2.0.0 2A2Np7PB018356 Message accepted for delivery
Dusko P <dusko@some.external.domain>... Sent (2A2Np7PB018356 Message accepted for delivery)
Closing connection to [127.0.0.1]
>>> QUIT
221 2.0.0 mailx.some.external.domain closing connection
```

**Note:**  
`VXNlcm5hbWU6` is 'Username:' encoded in base64, and `UGFzc3dvcmQ6` is
'Password:' encoded in base64.


```
$ perl -MMIME::Base64 -le 'print decode_base64("VXNlcm5hbWU6");'
Username:
``` 

``` 
$ perl -MMIME::Base64 -le 'print decode_base64("UGFzc3dvcmQ6");'
Password:
```

---


## Testing and Troubleshooting with the mail(1) Utility 

Send a test email message with the *mail* (aka *mail*, *Mail*, *mailx*)
utility:  

```
$ printf %s\\n "Testing." | mail -v -s "Test" dusko@some.external.domain
```

---


## Testing SMTP with openssl(1) Command Line Tool

From [Chapter 43 - Encrypted SMTP connections using TLS/SSL - Exim Internet Mailer](https://www.exim.org/exim-html-current/doc/html/spec_html/ch-encrypted_smtp_connections_using_tlsssl.html) (Retrieved on Nov 12, 2022):  

> As of [RFC 8314](https://www.rfc-editor.org/rfc/rfc8314), the common
> practice of using the historically allocated port 465 for "email submission
> but with TLS **immediately** upon connect **instead** of using STARTTLS" is
> officially recommended by the IETF, and recommended by them in preference
> to STARTTLS.  
> 
> The name originally assigned to the port was "ssmtp" or "smtps", but as
> clarity emerged over the dual roles of SMTP, for MX delivery and Email
> Submission, nomenclature has shifted. The modern name is now "submissions".


To test/connect TLS/SSL with `openssl(1)` to a mail server on port 465
(Implicit TLS submission), use its `s_client(1)` command (SSL/TLS client
program).  (Change *your.outgoing.mailserver* to the host name of your
mailserver.)

```
$ openssl s_client -connect your.outgoing.mailserver:465
```

You'll get a lot of output concerning the TLS (SSL) session and
certificates used, and the last line of that output will show
a confirmation (a 220 or 250 status code with a message).  For example:

```
220 your.outgoing.mailserver ESMTP mailer ready at Sat, 12 Nov 2022 19:31:55 -0800
```

**Initiate the conversation**

Now you need to identify yourself and initiate the SMTP conversation with
the `EHLO` command (Extended EHLO).  This command takes the fully-qualified
domain name of the SMTP client (or an IP address, if the SMTP client system
does not have a meaningful domain name; e.g., when its address is
dynamically allocated and no reverse mapping record is available).

```
EHLO fbsd1.home.arpa
```

The server returns a list of commands (keywords) available in Extended mode; that is,
in ESMTP (Extended SMTP):

```
250-your.outgoing.mailserver Hello fbsd1.home.arpa [123.45.67.89], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-AUTH LOGIN PLAIN
250-DELIVERBY
250 HELP
```

**Authenticate yourself**

The output to the `EHLO` ESMTP command above displayed a space separated
list of the names of supported SASL mechanisms.  In this case, the list of
advertised authentication mechanisms was `PLAIN` and `LOGIN`.   


**Authenticate yourself using PLAIN**

The PLAIN mechanism expects a base64 encoded string containing both
username and password, each prefixed with a `NULL` byte.  You can generate
this string using Perl and its 
[MIME::Base64](https://perldoc.perl.org/MIME::Base64) module.
(Change your *username* and *password* with your username and password.)

```
$ perl -MMIME::Base64 -e 'print encode_base64("\0username\0password");'
AHVzZXJuYW1lAHBhc3N3b3Jk
```

Submit this base64 encoded string to the `AUTH` command in your
*openssl* session:

```
AUTH PLAIN AHVzZXJuYW1lAHBhc3N3b3Jk
```

If the authorization is successful, the mail server will reply
with `235 2.0.0 OK`:

```
235 2.0.0 OK Authenticated
```


**Authenticate yourself using LOGIN**

The `LOGIN` mechanism also expects base64 encoded username and password
but separately.  You can generate this string using Perl and its
[MIME::Base64](https://perldoc.perl.org/MIME::Base64) module.  (Change your
*yourusername* and *yourpasswordhere* with your username and password.) 


```
$ perl -MMIME::Base64 -e 'print encode_base64("yourusername");'
eW91cnVzZXJuYW1l
 
$ perl -MMIME::Base64 -e 'print encode_base64("yourpasswordhere");'
eW91cnBhc3N3b3JkaGVyZQ==
```

Authenticate yourself with the SMTP server: 

```
AUTH LOGIN
```

The server replies with `334` (authentication challenge) code, followed by
a challenge string.  (`VXNlcm5hbWU6` is 'Username:' encoded in base64.)

```
334 VXNlcm5hbWU6
```

Enter your username:

```
eW91cnVzZXJuYW1l
```

Next, the mail server asks for the password.  (`UGFzc3dvcmQ6` is 'Password:'
encoded in base64.)

```
334 UGFzc3dvcmQ6
```

Enter your password:

```
eW91cnBhc3N3b3JkaGVyZQ==
```

If the authorization is successful, the mail server will reply with
`235 2.0.0 OK Authenticated`:

```
235 2.0.0 OK Authenticated
```


**Send an email**

There are three steps to SMTP mail transactions **[<sup>[ 20 ](#footnotes)</sup>]**:   
* the sender (`MAIL FROM:`)
* the recipient (`RCPT TO:`)
* the message body (`DATA`)

The first step in the procedure is the `MAIL` command.
You use the `MAIL FROM:` SMTP command to set the message sender
(the **envelope sender** address).   


**NOTE:**  According to
[RFC 821 - Simple Mail Transfer Protocol (SMTP)](https://datatracker.ietf.org/doc/html/rfc821)
  and
[RFC 2821 - Simple Mail Transfer Protocol (SMTP)](https://datatracker.ietf.org/doc/html/rfc2821), you need to surround the email address with `<>`; that is, 
with **angle brackets**.  Also, note that there is **no space (blank)
character** around the colon character (`:`). **[<sup>[ 20 ](#footnotes)</sup>]**

If the mail server accepts the email address, it will reply with `250 OK`:

```
MAIL FROM:<dusko@fbsd1.home.arpa>
250 2.1.0 <dusko@fbsd1.home.arpa>... Sender ok
```

Now you send the `RCPT TO:` (or `rcpt to:`, see the NOTE below) SMTP command
so the server knows who the email message is for.  In this case, I'm sending
the email to *dusko@yourdomain.example.net*.
(Change *dusko@yourdomain.example.net* with your test email address.)


**NOTE**:  When you connect with *openssl* (as opposed to, for example, 
with *nc* or *telnet*), make sure to type the `rcpt to` command in
**lowercase**.  Pressing `R` in the client session instructs *openssl* to
renegotiate the TLS connection. **[<sup>[ 21 ](#footnotes)</sup>]**

```
rcpt to:<dusko@yourdomain.example.net>
250 2.1.5 <dusko@yourdomain.example.net>... Recipient ok
```

If you were communicating with a destination mail server here, and the
account you specified in the `RCPT TO:` command was invalid, the mail
server would return an error code.  At this point, the mail server has
accepted the message and will attempt to deliver it.  


After the `MAIL` and `RCPT` commands, the `DATA` command initiates the
actual message transfer.  To enter it, type `DATA` and press Enter. 

```
DATA
```

The mail server responds with instructions to end your email message body
with an empty line containing a single dot (`.`) character. 

```
354 Enter mail, end with "." on a line by itself
```


You can add any additional headers to your email message in the body.

As per [RFC 2822 - Internet Message Format](https://datatracker.ietf.org/doc/html/rfc2822), the only required header fields are the origination date field (`Date:`)
and the originator address field(s) (`From:`).  To end the message,
type a period on a line by itself. 

```
From: Dusko P <dusko@fbsd1.home.arpa>
To: DP <dusko@yourdomain.example.net>
Date: Sat, 12 Nov 2022 20:12:43 -0800
Subject: Test message 1

Testing.
.
```

The server will respond with `250 2.0.0` followed by the queue ID. 

```
250 2.0.0 2BH22lp2011970 Message accepted for delivery
```

Type `QUIT` to close the session.

```
QUIT
```

The server responds with `DONE`. 

```
DONE
```

--- 

## Testing with Class w ($=w) - The Local Host

```
$ printf '$=w' | sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> [IPv6:fe80:0:0:0:0:0:0:1]
[IPv6:0:0:0:0:0:0:0:1]
localhost
fbsd1.home.arpa
[123.45.6.7]
localhost.my.domain
[localhost.my.domain]
> $ 
```

From **sendmail**, 4th Edition (a.k.a. **"Bat Book"**)   
By Bryan Costales, Claus Assmann, George Jansen, Gregory Neil Shapiro  
(Published by: O'Reilly Media, Inc., Publication Date: October 2007):  

**Delivering to Local Recipient**

> Typically, some early rules in the `parse` *rule set 0* are intended to
> detect addresses that should be delivered locally.  A rule that
> accomplishes that end might look like this:

```
R $+ <@ $w>          $#local $:$1                 local address
```

> Here, the `$w` *sendmail* macro is the name of the *local host*.
> Note that the RHS (righthand side) strips the focused host part from
> the username.

> At some sites, the local host can be known by any of several names.
> A rule to handle such hosts would begin with a class declaration that
> adds those names to the class `w` (such as in the first line here):

```
Cw font-server fax printer3
R $+ <@ $=w>        $#local $:$1                 local address
```

> The class `w` is special because it is the one to which *sendmail*
> automatically appends the alternative name of the local host.
> This class declaration line adds names that *sendmail* might not
> automatically detect.  Usually, such a declaration would be near the top
> of the configuration file rather than in the `parse` rule *set 0*, but
> technically it can appear anywhere in the file.  This rule looks to see
> whether an address contains any of the names in class `w`.  If it does,
> the `$=w` in the lefthand side (LHS) matches, and the RHS selects the
> local delivery agent. 

> On central mail-server machines, the `parse` *rule set 0* might also
> have to match from a list of hosts for which the central server is an
> MX recipient machine (`FEATURE(use_cw_file)`).

----

### Check whether Your sendmail Supports SASL (with -d0.10 Debugging Switch)

If you are running a precompiled *sendmail* binary, you can use
the `-d0.10` debugging command-line switch to determine whether
*SASL* support is defined (if it appears in the list, it is defined).

Also, it shows configuration files; that is, default conf files for
**MTA** (Mail Transport Agent), **MSP** (Mail Submission Program)
[which is a command-line *sendmail* that functions as a mail submission
agent (**MSA**)], and the *selected configuration file* (if, for example,
you've started *sendmail* with the `-C<file_name>` parameter to use an
alternate configuration file).

By default:   
configuration file for MSP is:  `/etc/mail/submit.cf`     
configuration file for MTA is:  `/etc/mail/sendmail.cf`   


The `-d0.10` debug switch causes *sendmail* to print all the operating
system-specific **definitions** that were used to **compile** your specific
version of *sendmail*. 

```
$ sendmail -bt -d0.10 < /dev/null 
Version 8.17.1
 Compiled with: DANE DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PICKY_HELO_CHECK PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS
                TLS_EC TLS_VRFY_PER_CTX USERDB XDEBUG
    OS Defines: BSD4_4_SOCKADDR HASFCHOWN HASFCHMOD HASFLOCK
                HASGETDTABLESIZE HASGETUSERSHELL HASINITGROUPS HASLSTAT HASNICE
                HASRANDOM HASRRESVPORT HASSETLOGIN HASSETREUID HASSETRLIMIT
                HASSETSID HASSETUSERCONTEXT HASSETVBUF HAS_ST_GEN HASSRANDOMDEV
                HASURANDOMDEV HASSTRERROR HASUNAME HASUNSETENV HASWAITPID
                HAVE_NANOSLEEP IDENTPROTO IP_SRCROUTE LOCK_ON_OPEN
                SAFENFSPATHCONF SFS_MOUNT USE_DOUBLE_FORK USESETEUID USESYSCTL
Kernel symbols: don't use _PATH_UNIX
     Conf file: /etc/mail/submit.cf (default for MSP)
     Conf file: /etc/mail/sendmail.cf (default for MTA)
      Pid file: /var/run/sendmail.pid (default)
Canonical name: fbsd1.home.arpa
 UUCP nodename: fbsd1.home.arpa
        a.k.a.: localhost.my.domain
        a.k.a.: fbsd1.home.arpa
        a.k.a.: [127.0.0.1]
        a.k.a.: [IPv6:0:0:0:0:0:0:0:1]
        a.k.a.: [IPv6:fe80:0:0:0:0:0:0:1]
        a.k.a.: [192.168.1.3]
        a.k.a.: [192.168.8.1]
        a.k.a.: [10.1.2.3]
     Conf file: /etc/mail/sendmail.cf (selected)
      Pid file: /var/run/sendmail.pid (selected)

============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = fbsd1
  (canonical domain name) $j = fbsd1.home.arpa
         (subdomain name) $m = home.arpa
              (node name) $k = fbsd1.home.arpa
========================================================

ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> $ 
```


## From **sendmail**, 4th Edition (a.k.a. **"Bat Book"**)   
By Bryan Costales, Claus Assmann, George Jansen, Gregory Neil Shapiro  
(Published by: O'Reilly Media, Inc., Publication Date: October 2007):  


## Authinfo and the access Database

Under V8.12, default client authentication information was moved out of
the *default-auth-info* text file and into the *access* database.  If you 
prefer a more secure database than the *access* database, you can declare
an alternative with the `authinfo` feature (`FEATURE(authinfo)`). For example:

```
FEATURE(`authinfo')
```

Here, instead of looking up client authentication information in the 
*access* database, *sendmail* will look in the */etc/mail/authinfo*
database.

Whether you store default client authentication information in the
*access* database or in the *authinfo* database, the syntax of entries
is the same.

The database entries are created from a text file that has keys down the
left column and matching values down the right.  The two columns are
separated by one or more tab or space characters.  One line in such
a source text file might look like this:

```
AuthInfo:address      "U:user"  "P=password" 
```

The left column of the database is composed of two parts. The first part
is mandatory, the literal expression `AuthInfo:`.  The second, configurable
part is an IPv4 address, an IPv6 address, or a canonical host or domain
name.  For example:

```
AuthInfo:123.45.67.89
Authinfo:IPv6:2002:c0a8:51d2::23f4
AuthInfo:host.domain.com
AuthInfo:domain.com
```

When *sendmail* connects to another host, and that other host offers to
authenticate, that connected-to host's IP address, hostname, and domain
are looked up in the database.

If the IP address, host, or domain is not found, the connection is allowed,
but *sendmail* will not attempt to authenticate it.  Otherwise, the
information in the matching right column is returned for *sendmail* to use.

The right column is composed of letter and value pairs, each pair quoted
and separated from the others by space characters:

```
AuthInfo:address      "U:user"  "P=password"
```

Letters are separated from their value with a colon or an equal-sign.
A colon means that the value is literal text.  An equal-sign means that
the value is Base64-encoded.

These letters and their meanings are shown in the table below.  

Right-column key letters for the default *authinfo* file:

```
+-------------+----------------------------------------------+ 
| Letter      | Description                                  |
+-------------+----------------------------------------------+ 
| U           | The user (authorization) identifier          |
+-------------+----------------------------------------------+ 
| I           | The authentication identifier                |
+-------------+----------------------------------------------+
| P           | The password                                 |
+-------------+----------------------------------------------+ 
| R           | The realm                                    |
+-------------+----------------------------------------------+ 
| M           | The list of mechanisms (separated by spaces) |
+-------------+----------------------------------------------+ 
```

Either the `U` or the `I`, or both, must exist or authentication will fail.
The `P` must always be present.  The `R` and `M` are optional.  All the
letters are case-insensitive-that is, `U` and `u` are the same.

The `U` lists the name of the user that *sendmail* will use to check
allowable permissions.  Generally, this could be `U:authuser` (but it
should never be `root`).

The `I` lists the name of the user allowed to set up the connection.
Generally, this could be `I:authuser` (but it should never be *root*).

The `P` value is the password.  If the `P` is followed by a colon (as `P:`),
the password is in plain text.  If the `P` is followed by an equal-sign
(`P=`), the password is Base64-encoded.  Generally, this should never be
*root*'s plain-text password.

The `R` lists the administrative realm for authentication.  In general,
this should be your DNS domain.  If no realm is specified (this item is
missing), *sendmail* will substitute the value of
the ([`$j` macro](#canonical-name-macro)) unless the `AuthRealm` option
is used to define a realm to use in place of the value of the `$j` macro.

The `M` lists the preferred mechanism for connection authentication. 
Multiple mechanisms can be listed, one separated from another with a space:

```
"M:DIGEST-MD5 CRAM-MD5"
```

If the `M` item is missing, *sendmail* uses the mechanisms listed in the
`AuthMechanisms` option ([AuthMechanisms](#authmechanisms-option)).

Missing required letters, unsupported letters, and letters that are missing
values have warnings logged at a LogLevel of 9, or above, like this:

```
AUTH=client, relay=server_name [server_addr], authinfo failed
```

Here, the `server_name` is the value of the `${server_name}` *sendmail*
macro.  The `server_addr` is the value of the `${server_addr}` *sendmail*
macro.  Both identify the connected-to host for which the connection failed.

All of this is implemented when you use the `authinfo` rule set.
As of V8.14, there is no way to add your own rules to this rule set.


### DefaultAuthInfo

When *sendmail* is compiled with SASL defined, authenticated connections 
can be supported.  When negotiating an authenticated connection, certain 
information is required, specifically and in this order:

* The *user id* is the identifier *sendmail* uses to check allowable
  permissions.  In general, this should never be *root*.
* The *authorization id* is the identifier of the user allowed to set up
  the connection.  In general, this should never be *root*.
* The *password* is the clear text password used to authorize the mail
  connection.  This should be a password dedicated to this use, *not* the
  plain text copy of the user's password.
* The *realm* is the administrative zone for authentication.  In general,
  this should be your DNS domain.  If no realm is specified (this item is
  blank), *sendmail* will substitute the value of
  the [`$j` macro](#canonical-name-macro) (a.k.a. canonical name macro). 
* The *mechanism* is the preferred mechanism for connection authentication.
  This should match one of the mechanisms listed in
  the [`AuthMechanisms` option](#authmechanisms-option).


## Canonical Name Macro

**$j**

Your official canonical name 

The `$j` macro is used to hold the fully qualified domain name of the 
local machine.  V8 *sendmail* automatically defines `$j` to be the fully
qualified canonical name of the local host.  However, you can still
redefine `$j` if necessary; for example, if *sendmail* cannot figure out
your fully qualified canonical name, or if your machine has multiple
network interfaces and *sendmail* chooses the name associated with the
wrong interface.

A fully qualified domain name is one that begins with the local hostname,
which is followed by a dot and all the components of the local domain.

The hostname part is the name of the local machine.  That name is defined
at boot time in ways that vary with the version of Unix you are using.

At many sites, the local hostname is already fully qualified.
To tell whether your site uses just the local hostname, run *sendmail*
with a `-d0.4` switch:

```
$ sendmail -d0 -bt < /dev/null 
[ . . . ]
  (canonical domain name) $j = fbsd1.home.arpa
```

One way to tell whether `$j` contains the correct value is to send mail
to yourself.  Examine the `Received:` headers.  The name of the local host
must be fully qualified where it appears in them:

```
Received: by some.domain   ...other text here
```

`$j` is also used in the `Message-ID:` header definition.

The `$j` macro must *never* be defined in the command line. 

In the rare event that you need to give `$j` a value, you can do so in
your *mc* configuration file like this:

```
dnl Here at your.domain we hardwire the domain.
define(`confDOMAIN_NAME', `your.domain')
```

## AuthMechanisms Option

The `AuthMechanisms` option is used to declare the types of authentication
you want to allow to be passed in the AUTH ESMTP extension (see 
[RFC2554](https://datatracker.ietf.org/doc/html/rfc2554)
and 
[RFC4954](https://datatracker.ietf.org/doc/html/rfc4954)).

You use this option by listing the mechanisms you wish to set as its value.

When there is more than one preferred mechanism, each is separated from
the others by space characters. For example:

```
define(`confAUTH_MECHANISMS', `CRAM-MD5 KERBEROS_V4')
```

Before the actual AUTH is generated, *sendmail* produces an intersection
of the mechanisms you want and those supported by the SASL software you
have installed.  Only those that are specified by this option and those
supported by your software are listed by the issued AUTH command:

```
250-AUTH CRAM-MD5
```

Here, you wanted both CRAM-MD5 and KERBEROS_V4 offered as mechanisms.
But if the SASL software installed on your machine, for example, supports
only CRAM-MD5 and DIGEST-MD5, the common or intersecting mechanism will be
CRAM-MD5, so that is all that will be advertised.

When more than one mechanism is listed, the other side will negotiate them
one at a time, until one succeeds.

The following mechanisms are the maximum set of those recognized by the
cyrus-sasl-1.5.16 distribution.  Not all will be compiled in, so not all
will be supported.
    
*ANONYMOUS*   
The ANONYMOUS mechanism allows anyone to use the service. Authentication
parallels that of the anonymous *ftp* login.

*CRAM-MD5*   
The CRAM-MD5 mechanism is the style of authentication used by POP servers
known as APOP.

*DIGEST-MD5*   
The DIGEST-MD5 mechanism is a stronger version of the CRAM-MD5 mechanism
that also supports encryption.

*GSSAPI*   
The GSSAPI mechanism implements an API for general security services that
also support encryption.  One example is support for Kerberos V5, which is
achieved using GSSAPI.

*KERBEROS_V4*  
The KERBEROS_V4 mechanism implements authentication based on MIT's Kerberos 4.

*PLAIN*  
The PLAIN mechanism can perform plain text password authentication (in a
single step) with either PAM, KERBEROS_V4, or */etc/passwd*
(or */etc/shadow*) authentication.

*LOGIN*  
The LOGIN mechanism is a two-step version of PLAIN.


The `AuthMechanisms` option is available only if *sendmail* is compiled
with SASL.


**NOTE:**   
The complete list of SASL mechanisms, and the RFC that describes each,
can be found at   

**Simple Authentication and Security Layer (SASL) Mechanisms - IANA
(Internet Assigned Numbers Authority)**   
[https://www.iana.org/assignments/sasl-mechanisms/sasl-mechanisms.xhtml](https://www.iana.org/assignments/sasl-mechanisms/sasl-mechanisms.xhtml)   

Similarly, the list of SASL mechanisms, SASL profiles and SASL APIs:    
**SASL mechanisms, SASL profiles, SASL APIs - Claus Aßmann at sendmail.org**  
(List composed by Alexey Melnikov.  Last updated: April 29, 2002.)     
[https://www.sendmail.org/~ca/email/mel/SASL_info.html](https://www.sendmail.org/~ca/email/mel/SASL_info.html) 


## Test `submit.cf` (`<hostname>.submit.mc`) with *sendmail* from CLI

```
$ hostname
fbsd1.home.arpa
```

In the following example, after you start *sendmail* with 
`sendmail -Ac -bt`, lines and commands that you type are:
`3,0 dusko@localhost`, `3,0 dusko@fbsd1.home.arpa`, `3,0 dusko@example.com`,
`3,0 dusko`, `3,0 root`, `/quit`.  	

**NOTE:**    
The `-Ac` parameter tells *sendmail* to use *submit.cf* configuration file;
that is, to oparate in **MSP** (Mail Submission Program) mode.
MSP is a command-line *sendmail* that functions as a Mail Submission Agent
(**MSA**).

The `-bt` parameter invokes *sendmail* in address test mode.
This mode reads addresses and shows the steps in parsing.

```
$ sendmail -Ac -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> 3,0 dusko@localhost       
canonify           input: dusko @ localhost
Canonify2          input: dusko < @ localhost >
Canonify2        returns: dusko < @ fbsd1 . home . arpa . >
canonify         returns: dusko < @ fbsd1 . home . arpa . >
parse              input: dusko < @ fbsd1 . home . arpa . >
Parse0             input: dusko < @ fbsd1 . home . arpa . >
Parse0           returns: dusko < @ fbsd1 . home . arpa . >
ParseLocal         input: dusko < @ fbsd1 . home . arpa . >
ParseLocal       returns: $# LR0relay $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
parse            returns: $# LR0relay $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
 
> 3,0 dusko@fbsd1.home.arpa
canonify           input: dusko @ fbsd1 . home . arpa
Canonify2          input: dusko < @ fbsd1 . home . arpa >
Canonify2        returns: dusko < @ fbsd1 . home . arpa . >
canonify         returns: dusko < @ fbsd1 . home . arpa . >
parse              input: dusko < @ fbsd1 . home . arpa . >
Parse0             input: dusko < @ fbsd1 . home . arpa . >
Parse0           returns: dusko < @ fbsd1 . home . arpa . >
ParseLocal         input: dusko < @ fbsd1 . home . arpa . >
ParseLocal       returns: $# LR0relay $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >
parse            returns: $# LR0relay $@ fbsd1 . home . arpa $: dusko < @ fbsd1 . home . arpa . >

> 3,0 dusko@example.com
canonify           input: dusko @ example . com
Canonify2          input: dusko < @ example . com >
Canonify2        returns: dusko < @ example . com . >
canonify         returns: dusko < @ example . com . >
parse              input: dusko < @ example . com . >
Parse0             input: dusko < @ example . com . >
Parse0           returns: dusko < @ example . com . >
ParseLocal         input: dusko < @ example . com . >
ParseLocal       returns: dusko < @ example . com . >
Parse1             input: dusko < @ example . com . >
MailerToTriple     input: < smartrelay : [ 127 . 0 . 0 . 1 ] > dusko < @ example . com . >
MailerToTriple   returns: $# smartrelay $@ [ 127 . 0 . 0 . 1 ] $: dusko < @ example . com . >
Parse1           returns: $# smartrelay $@ [ 127 . 0 . 0 . 1 ] $: dusko < @ example . com . >
parse            returns: $# smartrelay $@ [ 127 . 0 . 0 . 1 ] $: dusko < @ example . com . >
 
> 3,0 dusko
canonify           input: dusko
Canonify2          input: dusko
Canonify2        returns: dusko
canonify         returns: dusko
parse              input: dusko
Parse0             input: dusko
Parse0           returns: dusko
ParseLocal         input: dusko
ParseLocal       returns: dusko
Parse1             input: dusko
Parse1           returns: $# local $: dusko
parse            returns: $# local $: dusko

> 3,0 root
canonify           input: root
Canonify2          input: root
Canonify2        returns: root
canonify         returns: root
parse              input: root
Parse0             input: root
Parse0           returns: root
ParseLocal         input: root
ParseLocal       returns: root
Parse1             input: root
Parse1           returns: $# local $: root
parse            returns: $# local $: root
 
> /quit
```


## Steps When Recompiling Sendmail Configuration after Modifying Its Configuration Files


```
$ cd /etc/mail
$ sudo su
```

```
# make stop
Stopping: sendmail sendmail-clientmqueue.
``` 

``` 
# rm -i fbsd1.home.arpa.*
remove fbsd1.home.arpa.cf? y
remove fbsd1.home.arpa.mc? y
remove fbsd1.home.arpa.submit.cf? y
remove fbsd1.home.arpa.submit.mc? y
``` 

``` 
# rm -i *.cf
remove sendmail.cf? y
remove submit.cf? y
```

```
# make all
# make install 
# make start
```


## Debugging Sendmail - Sending Outgoing Test Message in Verbose/Debug Mode

`-d8.20`: Debugging Switch: Tracking DNS Queuries   
`-d60.5`: Debugging Switch: Tracking Maps (Databases) queries   
`-Ac:` Use `submit.cf` even if the operation mode does not indicate an
initial mail submission; that is, oparate in MSP (Mail Submission Program)
mode.  MSP is a command-line *sendmail* that functions as a Mail Submission
Agent (MSA).

From:   
[Debugging sendmail - dsn=5.0.0 - - Sendmail: Sending outgoing test message in verbose/debug mode](https://serverfault.com/questions/521032/debugging-sendmail-dsn-5-0-0/521614#521614)


You may add additional debug/tracking command line options:    
`-d8.20` - tracking DNS queuries    
`-d60.5` - tracking maps (databases) queries 

```
# sendmail -v -Ac -d60.5 dusko@your.isp.domain
# sendmail -v -Ac -d60.5 dusko
```

Equivalent to:

```
# sendmail -v -d60.5 -Csubmit.cf dusko@your.isp.domain
# sendmail -v -d60.5 -Csubmit.cf dusko
```


In the following example, after you start *sendmail* with 
`sendmail -v -Ac -d60.5 <username>`, the three lines you type are:

```
Subject: Test 1

.
```

```
# sendmail -v -Ac -d60.5 dusko
map_lookup(dequote, dusko, %0=dusko) => NOT FOUND (0), ad=0
map_lookup(dequote, dusko, %0=dusko) => NOT FOUND (0), ad=0
map_lookup(dequote, dusko, %0=dusko) => NOT FOUND (0), ad=0
Subject: Test 1

.
dusko... Connecting to [127.0.0.1] via relay...
220 fbsd1.home.arpa ESMTP mailer ready at Sat, 12 Nov 2022 16:53:07 -0800 (PST)
>>> EHLO fbsd1.home.arpa
250-fbsd1.home.arpa Hello localhost [127.0.0.1], pleased to meet you 
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-AUTH LOGIN PLAIN
250-DELIVERBY
250 HELP
>>> STARTTLS
220 2.0.0 Ready to start TLS
>>> EHLO fbsd1.home.arpa
250-fbsd1.home.arpa Hello localhost [127.0.0.1], pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE
250-DSN
250-DELIVERBY
250 HELP
>>> MAIL From:<dusko@fbsd1.home.arpa> SIZE=17
250 2.1.0 <dusko@fbsd1.home.arpa>... Sender ok
>>> RCPT To:<dusko@fbsd1.home.arpa>
>>> DATA
250 2.1.5 <dusko@fbsd1.home.arpa>... Recipient ok
354 Enter mail, end with "." on a line by itself
>>> .
250 2.0.0 2B71HsDo027909 Message accepted for delivery
dusko... Sent (2B71HsDo027909 Message accepted for delivery)
Closing connection to [127.0.0.1]
>>> QUIT
221 2.0.0 fbsd1.home.arpa closing connection
```


The lines that begin with numbers and the lines that begin with `>>>`
characters constitute a record of the SMTP conversation. 


Similarly, with the `-Am` parameter, which tells *sendmail* to use
`sendmail.cf` configuration file even if the operation mode indicates an
initial mail submission:

```
# sendmail -v -Am -d60.5 dusko@your.isp.domain
# sendmail -v -Am -d60.5 dusko
```

Equivalent to:

```
# sendmail -v -Csendmail.cf -d60.5 dusko@your.isp.domain
# sendmail -v -Csendmail.cf -d60.5 dusko
```

---


## References

(All references retrieved on Nov 12, 2022.)    


[RELNOTES: document the switch from sendmail to dma](https://cgit.freebsd.org/src/commit/?id=4d184bd438)  (Author: Baptiste Daroussin <bapt at FreeBSD.org>  2022-11-07)


[FreeBSD source tree - mail: make The DragonFly Mail Agent (dma) the default mta.](https://cgit.freebsd.org/src/commit/?id=a67b925ff3e58b072a60b633e442ee1d33e47f7f) 


[Creating a new *sendmail* mailer](https://web.archive.org/web/20150810193500/http://brandonhutchinson.com/Creating_a_new_sendmail_mailer.html)


[Sendmail: redirect all mail for development](https://william.shallum.net/notes/2010-07-24-sendmailredirectallmailfordevelopment/)


[Sendmail - The FreeBSD Forums](https://forums.freebsd.org/threads/sendmail.56661/)


[Solved - "Lazy" question about sendmail - The FreeBSD Forums](https://forums.freebsd.org/threads/lazy-question-about-sendmail.49321/)


[Modifying the FreeBSD base system sendmail - Posted on Mar 12, 2005](https://www.hydrus.org.uk/journal/base-sendmail.html)


[Setting method of submit.mc for non-resident sendmail under OP25B environment - Configuration of submit.mc Under Outbound Port 25 Blocking](https://www-ecs-shimane--u-ac-jp.translate.goog/~stamura/personal/network/op25b-sendmail.html?_x_tr_sch=http&_x_tr_sl=ja&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=sc)


[Configuring SMTP-AUTH proxy with resident sendmail](https://www-ecs-shimane--u-ac-jp.translate.goog/~stamura/personal/network/op25b-sendmail.html?_x_tr_sl=ja&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=sc&_x_tr_sch=http#smtp-auth-proxy)


[Chapter 43 - Encrypted SMTP connections using TLS/SSL - Exim Internet Mailer](https://www.exim.org/exim-html-current/doc/html/spec_html/ch-encrypted_smtp_connections_using_tlsssl.html)


[[Solved] DMA makes sense - The FreeBSD Forums](https://forums.freebsd.org/threads/dma-makes-sense.52219/)


[sendmail as relay client over port 465 with SSL - comp.mail.sendmail - *sendmail* news group](https://groups.google.com/g/comp.mail.sendmail/c/Gy6QBfMd3l4)


[Sendmail smtps support - comp.mail.sendmail - *sendmail* news group](https://groups.google.com/g/comp.mail.sendmail/c/hIqbWpw1ugc/m/uBg2v3kwAwAJ)


[Configure sendmail as a client for SMTPs - Fedora Project Wiki](https://fedoraproject.org/wiki/Configure_sendmail_as_a_client_for_SMTPs)


[Configuring Sendmail to Relay via an SSL tunnel - Relaying Sendmail and SSL (posted on Feb 28, 2014)](https://web.archive.org/web/20140228040212/http://www.dawoodfall.net/index.php/en/relaying-sendmail-a-ssl)


[Simple solution for outgoing mail from a FreeBSD system - with dma(8) - DragonFly Mail Agent](https://jpmens.net/2020/03/05/simple-solution-for-outgoing-mail-from-a-freebsd-system/)


[30.3. Sendmail Configuration Files - Chapter 30. Electronic Mail - FreeBSD Documentation Portal](https://docs.freebsd.org/en/books/handbook/mail/#sendmail)


[SMTP AUTH in sendmail 8.10 (Last Update 2006-04-15) (Claus Aßmann at sendmail.org)](https://www.sendmail.org/~ca/email/auth.html)


[30.9. SMTP Authentication - FreeBSD Handbook - FreeBSD Documentation Portal](https://docs.freebsd.org/en/books/handbook/mail/#SMTP-Auth)


[Chapter 12 - Sendmail Server -- Linux Home Server HOWTO](https://www.brennan.id.au/12-Sendmail_Server.html)


[Configure sendmail to forward root's email without DNS (posted on May 6, 2012)](https://blog.grem.de/sysadmin/Sendmail-SmartHost-Without-DNS-2012-05-06-22-00.html)


[Perl - MIME::Base64 Module (Encoding and decoding of base64 strings)](https://perldoc.perl.org/MIME::Base64)


[sendmail rewrite rules in separate file - Server Fault](https://serverfault.com/questions/343720/sendmail-rewrite-rules-in-separate-file)
> Rules using LOCAL_NET_CONFIG will always be inserted at the same place:   
> halfway through ruleset 0.  And they can't be wildly different from what
> was there before such that delivery no longer approximately matches the
> assumptions made by the existing "parse" functionality.  New rulesets
> (subroutines) from LOCAL_RULESETS will either be called only by your
> inserted rules, or be called directly by the *sendmail* program itself
> depending on specific (and possibly obscure) subroutine names and
> sendmail.mc FEATURE specifications.  And extensions to existing rulesets
> (subroutines) from LOCAL_RULESET can add new functionality, but probably
> cannot change existing functionality, as a match and "return" by an
> existing earlier rule will terminate execution of that ruleset before
> your additional rules are even reached.  Nevertheless, this may be
> adequate for what you want.
> 
> If you do this, use the `sendmail -bt -Ctrial_sendmail.cf_file -d21.15`  
> (`-d21.15` debug switch is for tracing *sendmail* rules and rule sets)
> test mechanism to make sure it's behaving the way you intend.
> Remember, your "style" should be to compose your new rules in such
> a way that they fit seamlessly into the existing ruleset framework
> (rather than making arbitrary changes with little consideration for the
> existing framework); it's rather like adding a new feature to existing
> code that was structured by somebody else.  The distributed rewrite
> rules are very good at handling not only mainline behavior but also edge
> cases (MX for individual hosts? Masquerade exceptions?  UUCP connectivity?
> aliases? etc.?); hopefully your added rules will be similarly comprehensive. 


---


## Footnotes

**[ 1 ]** Other possible AKAs:   

Sendmail as a relay client over port 465 with SSL-or-TLS  
Sendmail with SASL2, SMTP AUTH and TLS   
Sendmail with SASL2, SMTP AUTH and SSL  
Sendmail with SASL2, SMTP AUTH and SSL-or-TLS  
Using Stunnel to secure SMTP transport   
Implicit TLS on port 465 for SMTP Submission   
Sendmail with SSL (port 465)   
Sendmail with SSL-or-TLS (port 465)   
Sendmail's SMTP Authentication (SMTP AUTH)   
Setting up Sendmail with SSL-or-TLS and AUTH support in FreeBSD   
Setting up Sendmail with TLS and AUTH support in FreeBSD   
Getting Sendmail (as a client) to use AUTH LOGIN   
Sendmail TLS SASL SMTP-AUTH   
Sendmail SSL-or-TLS SASL SMTP-AUTH   
Secure SMTP AUTH over SSL with Sendmail and Cyrus SASL   
Secure SMTP AUTH over SSL-or-TLS with Sendmail and Cyrus SASL   
Authenticated SMTP with sendmail   
SMTP AUTH: Client Authentication   
Sendmail, SASL, and SSL-or-TLS   
Sendmail, SASL, and TLS   
Testing SMTP AUTH connections   
Sendmail TLS SASL SMTP-AUTH   
Sendmail SSL-or-TLS SASL SMTP-AUTH   


**[ 2 ]**  Technically, SMTPS doesn't exist.  According to
[RFC 5321](https://datatracker.ietf.org/doc/html/rfc5321#page-61),
the Protocol is either SMTP or ESMTP:

```
Protocol       = "ESMTP" / "SMTP" / Attdl-Protocol

   Attdl-Protocol = Atom
                  ; Additional standard names for protocols are
                  ; registered with the Internet Assigned Numbers
                  ; Authority (IANA) in the "mail parameters"
                  ; registry [9].  SMTP servers SHOULD NOT
                  ; use unregistered names.

----

   [9]   Newman, C., "ESMTP and LMTP Transmission Types Registration",
         RFC 3848 [https://datatracker.ietf.org/doc/html/rfc3848], July 2004.
```

[RFC 3848](https://datatracker.ietf.org/doc/html/rfc3848) specified
additional values:   
ESMTPA when ESMTP is used with successful user authentication, ESMTPS
when ESMTP is used with STARTTLS, and ESMTPSA when the session has been
secured with both STARTTLS and SMTP AUTH are successfully negotiated
(the combination of ESMTPS and ESMTPA): 

```
Abstract

   This registers seven new mail transmission types (ESMTPA, ESMTPS,
   ESMTPSA, LMTP, LMTPA, LMTPS, LMTPSA) for use in the "with" clause of
   a Received header in an Internet message.

[ . . . ]

1.  IANA Considerations

   As directed by SMTP [2], IANA maintains a registry [7] of "WITH
   protocol types" for use in the "with" clause of the Received header
   in an Internet message.  This registry presently includes SMTP [6],
   and ESMTP [2].  This specification updates the registry as follows:

   o  The new keyword "ESMTPA" indicates the use of ESMTP when the SMTP
      AUTH [3] extension is also used and authentication is successfully
      achieved.

   o  The new keyword "ESMTPS" indicates the use of ESMTP when STARTTLS
      [1] is also successfully negotiated to provide a strong transport
      encryption layer.

   o  The new keyword "ESMTPSA" indicates the use of ESMTP when both
      STARTTLS and SMTP AUTH are successfully negotiated (the
      combination of ESMTPS and ESMTPA).

----

   [1]  Hoffman, P., "SMTP Service Extension for Secure SMTP over
        Transport Layer Security", 
        RFC 3207 [https://datatracker.ietf.org/doc/html/rfc3207], February 2002.

   [2]  Klensin, J., Ed., "Simple Mail Transfer Protocol", 
        RFC 2821 [https://datatracker.ietf.org/doc/html/rfc2821], April 2001.

   [3]  Myers, J., "SMTP Service Extension for Authentication", 
        RFC 2554 [https://datatracker.ietf.org/doc/html/rfc2554], March 1999.

[ . . . ]  

   [6]  Postel, J., "Simple Mail Transfer Protocol", STD 10, 
        RFC 821 [https://datatracker.ietf.org/doc/html/rfc821], August 1982.

   [7]  <http://www.iana.org/assignments/mail-parameters>
```


**[ 3 ]** [3.3. Implicit TLS for SMTP Submission -  The RFC 8314](https://www.rfc-editor.org/rfc/rfc8314#section-3.3):

> 3.3.  Implicit TLS for SMTP Submission
>
> When a TCP connection is established for the "submissions" service
> (default port 465), a TLS handshake begins immediately.  Clients MUST
> implement the certificate validation mechanism described in
> [RFC7817].  Once the TLS session is established, Message Submission
> protocol data [RFC6409] is exchanged as TLS application data for the
> remainder of the TCP connection.  (Note: The "submissions" service
> name is defined in Section 7.3 of this document and follows the usual
> convention that the name of a service layered on top of Implicit TLS
> consists of the name of the service as used without TLS, with an "s"
> appended.)
>
> [ . . . ]
> 
> Note that the "submissions" port provides access to a Message
> Submission Agent (MSA) as defined in [RFC6409], so requirements and
> recommendations for MSAs in that document, including the requirement
> to implement SMTP AUTH [RFC4954] and the requirements of Email
> Submission Operations [RFC5068], also apply to the submissions port.


[7.3. Submissions Port Registration (Port 465) for message submission over TLS protocol – The RFC 8314 - January 2018](https://tools.ietf.org/html/rfc8314#section-7.3)

> 7.3.  Submissions Port Registration
>
> IANA has assigned an alternate usage of TCP port 465 in addition to
> the current assignment using the following template [RFC6335]:
>
> Service Name: submissions  
> Transport Protocol: TCP  
> Assignee: IESG \<iesg@ietf.org\>  
> Contact: IETF Chair \<chair@ietf.org\>  
> Description: Message Submission over TLS protocol  
> Reference: RFC 8314  
> Port Number: 465  
>
> [ . . . ]
>
> Historically, port 465 was briefly registered as the "smtps" port.
> This registration made no sense, as the SMTP transport MX
> infrastructure has no way to specify a port, so port 25 is always
> used.  As a result, the registration was revoked and was subsequently
> reassigned to a different service.  In hindsight, the "smtps"
> registration should have been renamed or reserved rather than
> revoked.  Unfortunately, some widely deployed mail software
> interpreted "smtps" as "submissions" [RFC6409] and used that port for
> email submission by default when an end user requested security
> during account setup.  


**[ 4 ]** The RFC 8314 was amended in 2018 to recommend the use of
          Implicit TLS over port 465:

[The IETF issued a one-time amendment to reinstate port 465 for message submission over TLS protocol - RFC 8314 - Use of TLS for Email Submission/Access - January 2018](https://www.rfc-editor.org/rfc/rfc8314#section-3):

> To encourage more widespread use of TLS and to also encourage greater
> consistency regarding how TLS is used, this specification now recommends
> the use of Implicit TLS for POP, IMAP, SMTP Submission, and all other
> protocols used between an MUA (Mail User Agent) and an MSP (Mail Service
> Provider).

Port 465 and 587 are both **valid** ports for a mail submission agent (MSA).
Port 465 requires negotiation of TLS/SSL at connection setup and port 587
uses STARTTLS if an MUA chooses to negotiate TLS.


**[ 5 ]** On FreeBSD 13, the `user.localbase` is set to `/usr/local` by default.

From the man page for `sysctl(8)` utility:

```
The string and integer information is summarized below.  For a detailed
description of these variable see sysctl(3).

The changeable column indicates whether a process with appropriate
privilege can change the value.  String and integer values can be set
using sysctl.
  
Name                           Type          Changeable
.
[ . . . ]
.
user.localbase                 string        no
```

```
$ man 3 sysctl
[ . . . ]
       USER_LOCALBASE
               Return the value of localbase that has been compiled into system
               utilities that need to have access to resources provided by a
               port or package.
```

```
$ sysctl -d user.localbase
user.localbase: Prefix used to install and locate add-on packages
```

```
$ sysctl user.localbase
user.localbase: /usr/local
```


**[ 6 ]**  FreeBSD src tree - FreeBSD src commits - RELNOTES: document the
switch from sendmail to dma (Posted on Nov 7, 2022)   

* [FreeBSD src tree - FreeBSD src commits - RELNOTES: document the switch from sendmail to dma](https://cgit.freebsd.org/src/commit/?id=4d184bd438)    
  (Posted on Nov 7, 2022)  

  - [FreeBSD src commits (@FreeBSD_src_git) on Twitter - bapt@ on . (4d184bd438): RELNOTES: document the switch from sendmail to dma](https://twitter.com/FreeBSD_src_git/status/1589587194003472384)  (Posted on Nov 7, 2022)

* [Time to remove sendmail from #FreeBSD base? - Baptiste Daroussin - Twitter](https://twitter.com/_bapt_/status/938688218215714817)  (Posted on Dec 7, 2017)    

  - [Sendmail deprecation ? - Baptiste Daroussin bapt at FreeBSD.org - Dec 6, 2017 - The freebsd-arch Mailing List Archives](https://lists.freebsd.org/pipermail/freebsd-arch/2017-December/018712.html)  

* [Did you know? FreeBSD includes the DragonFly Mail Agent (dma), a minimal MTA, in the base system. - Ed Maste (@ed_maste)](https://twitter.com/ed_maste/status/1487170942249930756)  (Posted on Jan 28, 2022)  
> Did you know? FreeBSD includes the DragonFly Mail Agent (dma), a minimal MTA,
> in the base system.  See the dma(1) and mailer.conf(5) man pages for
> configuration details.
> 
> [dma(8) - FreeBSD Manual Pages](https://www.freebsd.org/cgi/man.cgi?query=dma)


**[ 7 ]** From [SMTP AUTH in sendmail 8.10 - Claus Aßmann at sendmail.org](https://www.sendmail.org/~ca/email/auth.html) (Last Update 2006-04-15) (Retrieved on Nov 12, 2022):  

> **Terminology**
> 
> SASL defines two terms which are important in this context:
> *authorization identifier* and *authentication identifer*.
> 
> *authorization identifier* (**userid**)   
> The userid is the identifier an application uses to check whether
> operations are allowed (authorized).    
> *authentication identifer* (**authid**)   
> The authentication identifier is the identifier that is being used to
> authenticate the client.  That is, the authentication credentials of
> the client contain the authentication identifier.  This can be used
> for a proxy server to act as (proxy for) another user. 
>
> [ . . . ]
> 
> **Operation**
> 
> SMTP AUTH allows relaying for senders who have successfully
> **authenticated themselves**.  Per default, **relaying** is **allowed**
> for any user who **authenticated** via a trusted mechanism, i.e., one that
> is defined via   
> TRUST_AUTH_MECH(`list of mechanisms')   
> This is useful for roaming users and can replace POP-before-SMTP hacks if
> the MUA supports SMTP AUTH.
> 
> [ . . . ]
> 
> New macros for SMTP AUTH are `{auth_authen}`, `{auth_author}`, and
> `{auth_type}`, which hold the client's authentication credentials
> ([authid](https://www.sendmail.org/~ca/email/auth.html#authid)),
> the authorization identity
> ([userid](https://www.sendmail.org/~ca/email/auth.html#userid))
> (i.e., the `AUTH=` parameter of the `MAIL` command, if supplied),
> and the mechanism used for authentication. 


**[ 8 ]** In addition, the **relay** delivery agent is also chosen for
forwarding mail to LUSER_RELAY (`LUSER_RELAY` mc macro),
BITNET_RELAY (`$B` macro, deprecated), UUCP_RELAY (`UUCP_RELAY` mc macro),
DECNET_RELAY (`DECNET_RELAY` mc macro), FAX_RELAY (`FAX_RELAY` mc macro)
and MAIL_HUB (`MAIL_HUB` mc macro).


**[ 9 ]**
From *Linux Network Administrator's Guide*, Second Edition  
By Olaf Kirch, Terry Dawson;
Published By: O'Reilly Media, Inc., Publication Date: June 2000  
(Chapter 18. Sendmail > Interpreting and Writing Rewrite Rules > Ruleset Semantics):

> Each of the *sendmail* rulesets is called upon to perform
> a different task in mail processing. 
> 
> LOCAL_RULE_3
> 
> Ruleset 3 is responsible for converting an address in an arbitrary format
> into a common format that *sendmail* will then process.
> The expected output format is  
> `local-part` `@` `host-domain-spec`.
> 
> Ruleset 3 should place the hostname part of the converted address inside
> the `<` and `>` characters to make parsing by later rulesets easier.
> Ruleset 3 is applied before *sendmail* does any other processing of an
> email address so if you want *sendmail* to gateway mail from some system that
> uses some unusual address format, you should add a rule using the `LOCAL_RULE_3`
> macro to convert addresses into the common format.


**[ 10 ]** Delivery Agent Equates

```
+--------+----------------+-------------------------------+
| Equate | Field Name     | Meaning                       |
+--------+----------------+-------------------------------+
| /=     | /path          | Set a chroot directory        |
|        |                | (V8.10 and later)             |
+--------+----------------+-------------------------------+
| A=     | Argv           | Delivery agent's              |
|        |                | command-line arguments        |
+--------+----------------+-------------------------------+
| C=     | CharSet        | Default MIME character        |
|        |                | set (V8.7 and later)          |
+--------+----------------+-------------------------------+
| D=     | Directory      | Delivery agent working        |
|        |                | directory (V8.6 and later)    |
+--------+----------------+-------------------------------+
| E=     | EOL            | End-Of-Line string            |
+--------+----------------+-------------------------------+
| F=     | Flags          | Delivery agent flags          |
+--------+----------------+-------------------------------+
| L=     | LineLimit      | Maximum line length           |
|        |                | (V8.1 and later)              |
+--------+----------------+-------------------------------+
| M=     | MaxMsgSize     | Maximum message size          |
+--------+----------------+-------------------------------+
| m=     | maxMsgsPerConn | Max messages per connection   |
|        |                | (V8.10 and later)             |
+--------+----------------+-------------------------------+
| N=     | Niceness       | How to nice(2) the agent      |
|        |                | (V8.7 and later)              | 
+--------+----------------+-------------------------------+
| P=     | Path           | Path to the delivery agent    |
+--------+----------------+-------------------------------+
| Q=     | QueueGroup     | The name of the queue group   | 
|        |                | to use (V8.12 and later)      | 
+--------+----------------+-------------------------------+
| R=     | Recipient      | Recipient rewriting rule      | 
+--------+----------------+-------------------------------+
| r=     | recipients     | Maximum recipients per        | 
|        |                | envelope (V8.12 and later)    |
+--------+----------------+-------------------------------+
| S=     | Sender         | Sender rewriting rule set     | 
+--------+----------------+-------------------------------+
| T=     | Type           | Types for DSN diagnostics     | 
|        |                | (V8.7 and later)              |
+--------+----------------+-------------------------------+
| U=     | UID            | Run agent as user-id:group-id |
|        |                | (V8.7 and later)              | 
+--------+----------------+-------------------------------+
| W=     | Wait           | Timeout for a process wait    |
|        |                | (V8.10 and later)             |
+--------+----------------+-------------------------------+
```


**[ 11 ]** Sections of Chapter 8. Securing the Mail Transport
(from *sendmail Cookbook* by Craig Hunt - Published by O'Reilly
Media, Inc., Publication Date: December 2003):

8.1. Building a Private Certificate Authority  
8.2. Creating a Certificate Request  
8.3. Signing a Certificate Request  
8.4. Configuring sendmail for STARTTLS  
8.5. Relaying Based on the CA  
8.6. Relaying Based on the Certificate Subject  
8.7. Requiring Outbound Encryption  
8.8. Requiring Inbound Encryption   
8.9. Requiring a Verified Certificate  
8.10. Requiring TLS for a Recipient  
8.11. Refusing STARTTLS Service  
8.12. Selectively Advertising STARTTLS  
8.13. Requesting Client Certificates    


**[ 12 ]** The RFC describes three functions for the AUTH keyword:

> * `250-AUTH` is the response of the SMTP `EHLO` command.  The response
> advertises the supported authentication mechanisms.  The configuration
> that causes *sendmail* to list AUTH in the `EHLO` response and to accept
> incoming AUTH connections is covered in Recipe 7.1.  That configuration
> applies when *sendmail* runs as an **MTA**, and it is **only** applicable
> when *sendmail* is run with the **`-bd`** command-line option.
> * `AUTH` is the SMTP command used to request authentication and to select
> the authentication mechanism for the session.  The connecting host must
> select one of the mechanisms advertised by the receiving host, or the
> authentication attempt is rejected. *sendmail* will request AUTH
> authentication when it is configured as described in Recipe 7.2.
> A laptop or desktop that sends SMTP mail but does not accept inbound SMTP
> connections could be configured using only Recipe 7.2.  A system that
> accepts incoming AUTH connections and creates outgoing AUTH connections
> would combine the configurations from both Recipe 7.1 and Recipe 7.2.
> * `AUTH=` is a parameter used on the `MAIL From:` line to identify the
> authenticated source address.  The `AUTH=` parameter comes from the
> connecting host as part of the initial envelope sender address.
> If the receiving host trusts the `AUTH=` parameter, it propagates it on
> to the next mail relay.  Recipe 7.6 provides additional information about
> the `AUTH=` parameter.


**[ 13 ]** The Cyrus SASL documentation defines four special terms:

**userid**    
The username that determines the permissions granted to the client.
The client is given the permissions normally granted to the specified user.
*userid* is also called the ***authorization id***.

**authid**    
The account name used to authenticate the connection.
*authid* is also called the ***authentication id***.

**realm**  
A group of users, systems, and services that share a common authentication
environment.  All members of a given group use the same *realm* value.
It is **common** to use a **domain name** or **hostname** for the *realm* value.

**mechanism**   
Identifies the type of authentication used.  For example, DIGEST-MD5 is a
valid *mechanism* value.

The *userid* and *authid* values cause the most confusion.  To understand
how SASL uses these two values, think of an */etc/passwd* file with one
entry for *craig* and another for *kathy*.  In a normal login, when Kathy
logs in to the *kathy* account, she is granted the permissions given to
that account.  With SASL, it is possible to set *authid* to *kathy* and
*userid* to *craig*, which means that the *kathy* account password is
required for authentication, but the permissions granted to the user are
the permissions granted to the *craig* account.


**[ 14 ]** Three configuration commands can be used in the *Sendmail.conf* file.
They are:

*srvtab*   
The `srvtab` command points to the file that contains the Kerberos 4
service key.  The argument provided with this command is the full pathname
of the service key file.

*auto_transition*  
The `auto_transition` command causes SASL to automatically create
a *sasldb* entry for every user that authenticates using the **PLAIN**
authentication method.

*pwcheck_method*  
The `pwcheck_method` command defines the technique that SASL should use to
validate the clear text password received during **PLAIN** method
authentication.  The possible values for the `pwcheck_method` are:
- *passwd*   
Tells SASL to look up passwords in the */etc/passwd* file.  
- *shadow*   
Tells SASL to look up passwords on the */etc/shadow* file.  Because of the
file permissions associated with the */etc/shadow* file, the application
must be running as *root*.
- *pam*   
Tells SASL to use Pluggable Authentication Modules (PAM). PAM must,
of course, be properly configured to authenticate the password.
- *sasldb*   
Tells SASL that the passwords for the PLAIN authentication method are
stored in the *sasldb* file.  Normally, *sasldb* is only used for
DIGEST-MD5 and CRAM-MD5 authentication.
- *kerberos_v4*   
Tells SASL to authenticate clear text passwords through the Kerberos 4
server.  Kerberos 4 must be installed, configured, and running, and the
Kerberos 4 server must be configured to accept clear text passwords.
- *sia*   
Tells SASL to use Digital's Security Integration Architecture (SIA) to
validate passwords.
- *pwcheck*   
Tells SASL to pass the data to an external program for password checking.


**[ 15 ]** SASL Flags 

```
+------+---------------------------------------------------------------+
| Flag | Purpose                                                       |
+------+---------------------------------------------------------------+
| A    | Use the AUTH= parameter only when successfully authenticated. |
+------+---------------------------------------------------------------+
| a    | Request optional protection against active attacks during the |
|      | authentication exchange.                                      |
+------+---------------------------------------------------------------+
| c    | Require client credentials if the authentication mechanism    |
|      | supports them.                                                |
+------+---------------------------------------------------------------+
| d    | Reject authentication techniques that are susceptible to      |
|      | dictionary attacks.                                           |
+------+---------------------------------------------------------------+
| f    | Don't use the same static shared-secret for each session.     |
+------+---------------------------------------------------------------+
| p    | Reject authentication techniques that are susceptible to      |
|      | simple passive attacks.                                       |
+------+---------------------------------------------------------------+
| y    | Don't allow the ANONYMOUS authentication mechanism.           |
+------+---------------------------------------------------------------+
```

The `A` option controls when the `AUTH=` parameter is added to the envelope
sender information on the SMTP `Mail From:` command line.  


**[ 16 ]** `Local_trust_auth` rule set and `SLocal_trust_auth` hook

About the `SLocal_trust_auth` hook - based on directions from
*/usr/local/share/sendmail/cf/README*:

```
If the MSP should actually use AUTH then the necessary data
should be placed in a map as explained in SMTP AUTHENTICATION:

FEATURE(`authinfo', `DATABASE_MAP_TYPE /etc/mail/msp-authinfo')

/etc/mail/msp-authinfo should contain an entry like:

        AuthInfo:127.0.0.1      "U:smmsp" "P:secret" "M:DIGEST-MD5"

The file and the map created by makemap should be owned by smmsp,
its group should be smmsp, and it should have mode 640.

The database used by the MTA for AUTH must have a corresponding entry.

Additionally the MTA must trust this authentication data so the AUTH=
part will be relayed on to the next hop.  This can be achieved by
adding the following to your sendmail.mc file:

        LOCAL_RULESETS
        SLocal_trust_auth
        R$*	$: $&{auth_authen}
        Rsmmsp	$# OK
```


From **sendmail**, 4th Edition (a.k.a. **"Bat Book"**)   
By Bryan Costales, Claus Assmann, George Jansen, Gregory Neil Shapiro  
(Published by: O'Reilly Media, Inc., Publication Date: October 2007)  

**SASL and Rule Sets**

The SMTP `AUTH` extension, enabled by SASL, allows client machines to relay
mail through the authentication-checking server.  This mechanism is especially
useful for roaming users whose laptops seldom have a constant IP number or
hostname assigned.  A special rule set called `trust_auth`, found inside
the *sendmail* configuration file, does the actual checking.  This rule set
decides whether the client's authentication identifier (`authid`) is trusted
to act as (proxy for) the requested authorization identity (`userid`).
It allows `authid` to act for `userid` if both are recognized, and disallows
that action if the authentication fails.

Another rule set, called `Local_trust_auth`, is available if you wish to
supplement the basic test provided by `trust_auth`.  The `Local_trust_auth`
rule set can return the `#error` delivery agent to disallow proxying, or it
can return OK to allow proxying.

Within the `Local_trust_auth` rule set you can use three new *sendmail*
macros (in addition to the other normal *sendmail* macros). They are:

`{auth_authen}`    
The client's **authentication credentials** as determined by the
authentication process.

`{auth_author}`   
The **authorization identity** as set by issuance of the `SMTP AUTH=` parameter.
This could be either a *username* or a *user@host.domain* address.

`{auth_type}`   
The **mechanism** used for authentication, such as CRAM-MD5 and PLAIN.

These three macros can also be used in any of the relay-testing rule sets
to determine whether a particular user may relay.  To illustrate, consider
a rule set designed to allow senders with local accounts on the local
machine to relay only if authenticated:

```
LOCAL_RULESETS
SLocal_check_rcpt
R$*			$: $&{auth_type} $| $&{auth_authen}
RDIGEST-MD5 $| $+@$=w	$# OK
RCRAM-MD5 $| $+@$=w	$# OK
```

Here, the `Local_check_rcpt` rule set is called to validate the envelope
recipient.  The first rule (`R` line) replaces the workspace (the `$*` on
the left) with three values: the current value of the `${auth_type}` macro;
a `$|` literal; and the current value of the `${auth_authen}` macro.

If the authentication type is either `DIGEST-MD5` or `CRAM-MD5` and if the
domain is in the class `$=w` (is a local hostname or address), the envelope
sender is allowed to relay.  But if the `${auth_type}` macro's value is
empty (nothing was authenticated), or if the authentication was by an
untrusted mechanism, such as PLAIN, the envelope sender is not allowed to relay.


**Policy Rule Set Reference**

> Beginning with V8.8, *sendmail* calls special rule sets internally to
> determine its behavior.  Called the *policy rule sets*, they are used for
> such varied tasks as setting spam handling, setting policy, or validating
> the conditions when ETRN should be allowed, to list just a few.
> Table below shows the complete list of these policy rule sets.

*The policy rule sets table*

```
+--------------+-------------------+------------------------------------------------------+
| Rule set     | Hook              | Description                                          |
+--------------+-------------------+------------------------------------------------------+
| authinfo     | None              | Handle AuthInfo: lookups in the access database.     |
+--------------+-------------------+------------------------------------------------------+
| check_compat | See below         | Validate just before delivery.                       |
+--------------+-------------------+------------------------------------------------------+
| check_data   | None needed       | Check just after DATA.                               | 
+--------------+-------------------+------------------------------------------------------+
| check_eoh    | None needed       | Validate after headers are read.                     |
+--------------+-------------------+------------------------------------------------------+
| check_eom    | None needed       | Review message's size (V8.13 and later).             |
+--------------+-------------------+------------------------------------------------------+
| check_etrn   | None needed       | Allow or disallow ETRN.                              |
+--------------+-------------------+------------------------------------------------------+
| check_expn   | None needed       | Validate EXPN.                                       |
+--------------+-------------------+------------------------------------------------------+
| check_mail   | Local_check_mail  | Validate the envelope-sender address.                | 
+--------------+-------------------+------------------------------------------------------+
| check_rcpt   | Local_check_rcpt  | Validate the envelope-recipient address.             | 
+--------------+-------------------+------------------------------------------------------+
| check_relay  | Local_check_relay | Validate incoming network connections.               |
+--------------+-------------------+------------------------------------------------------+
| check_vrfy   | None needed       | Validate VRFY.                                       |
+--------------+-------------------+------------------------------------------------------+
| queuegroup   | See below         | Select a queue group.                                |
+--------------+-------------------+------------------------------------------------------+
| srv_features | None needed       | Tune server setting based on connection information. | 
+--------------+-------------------+------------------------------------------------------+
| tls_client   | LOCAL_TLS_CLIENT  | With the access database, validate inbound STARTTLS  |
|              |                   | or MAIL From: SMTP command.                          |
+--------------+-------------------+------------------------------------------------------+
| tls_rcpt     | LOCAL_TLS_RCPT    | Validate a server's credentials based on the         |
|              |                   | recipient address.                                   |
+--------------+-------------------+------------------------------------------------------+
| tls_server   | LOCAL_TLS_SERVER  | Possibly with the access database, validate the      |
|              |                   | inbound and outbound connections.                    |
+--------------+-------------------+------------------------------------------------------+
| trust_auth   | Local_trust_auth  | Validate that a client's authentication              |
|              |                   | identifier (authid) is trusted to act as (proxy for) |
|              |                   | the requested authorization identity (userid).       |
+--------------+-------------------+------------------------------------------------------+
| try_tls      | LOCAL_TRY_TLS     | Disable STARTTLS for selected outbound connected-to  |
|              |                   | hosts.                                               |
+--------------+-------------------+------------------------------------------------------+
| Hname:$      | n/a               | Reject, discard, or accept a message based on a      |
|              |                   | header's value.                                      |
+--------------+-------------------+------------------------------------------------------+
```

Note that some of these rule sets are omitted from your configuration file
by default.  For those, no hook is needed. You merely declare the rule set
in your *mc* file and give it appropriate rules:

```
LOCAL_RULESETS
Scheck_vrfy
... <your rules here>
```

Those with a `Local_` hook, as shown in the table, are declared
**by default** in your configuration file.  To use them yourself, you need
only declare them with the `Local_` hook indicated:

```
LOCAL_RULESETS
SLocal_check_rcpt
... <your rules here>
```

Those with a `LOCAL_` hook, as shown in the table, are **declared directly
with that hook**.  There in no need to precede the hook with `LOCAL_RULESETS`.
For example:

```
LOCAL_TRY_TLS
... <your rules here>
```

The two **exceptions** are the `check_compat` and `queuegroup` rule sets.
Each is automatically declared when you use the corresponding
`FEATURE(check_compat)` or `FEATURE(queuegroup)`, but not declared if you
don't use that feature.

All of these rule sets are handled in the same manner.  If the rule set
does not exist, the action is permitted.  If the rule set returns anything
other than a `#error` or a `#discard` delivery agent, the message, identity,
or action is accepted for that rule set (although it can still be rejected
or discarded by another rule set).  Otherwise, the `#error` delivery agent
causes the message, identity, or action to be rejected and the `#discard`
delivery agent causes the message to be accepted, then discarded. 


**${auth_authen} Macro**   

RFC2554 AUTH credentials, *sendmail* V8.10 and later.

A server offers authentication by presenting the AUTH keyword to the
connecting site, following that with the types of mechanisms supported:

```
250-host.domain Hello some.domain, pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE
250-DSN
250-ETRN
250-AUTH DIGEST-MD5 CRAM-MD5
250-DELIVERBY
250 HELP
```

Note the line `250-AUTH DIGEST-MD5 CRAM-MD5`

If the connecting site wishes to authenticate itself, it replies with an
AUTH command indicating the type of mechanism preferred:

```
AUTH X5                                                           ← client sends
504 Unrecognized authentication type.                             ← server replies
AUTH CRAM-MD5                                                     ← client sends
334  PENCeUxFREJoU0NnbmhNWitOMjNGNndAZWx3b29kLmlubm9zb2Z0LmNvbT4= ← server replies
ZnJlZCA5ZTk1YWVlMDljNDBhZjJiODRhMGMyYjNiYmFlNzg2ZQ=  =            ← client sends
235 Authentication successful.          
```

Here, the client first asks for X5 authentication, which the server rejects.
The client next asks for CRAM-MD5.  The server says it can support that by
replying with a 334 followed by a challenge string.  The client replies to
the challenge with an appropriate reply string, and the authentication is
successful (as shown in the last line).

If authentication is successful, this `${auth_authen}` macro is assigned
the authentication credentials that were approved as its value.  The form
of the credentials depends on the encryption used.  It could be a simple
username (such as *bob*) or a username at a realm (such as `bob@some.domain`).

The client can then offer a different user, rather than the envelope sender,
to authenticate on behalf of the envelope sender.  This is done by adding
an AUTH= parameter to the `MAIL From:` keyword:

```
MAIL From: <user@host.domain> AUTH=address
```

The *address* is assigned to the `{auth_author}` macro, and the `trust_auth`
rule set is called to make further policy decisions, with the AUTH= parameter
in its workspace.

The `${auth_authen}` macro is useful for adding your own rules to the
`Local_trust_auth` rule set.

`${auth_authen}` is transient.  If defined in the configuration file or in
the command line, that definition can be ignored by *sendmail*.  Note that
a `$&` prefix is necessary when you reference this macro in rules (that is,
use `$&{auth_authen}`, not `${auth_authen}`).

Note that, beginning with V8.13, the value to be stored into this macro is
first xtext encoded, then stored (Macro Xtext Translations
**[<sup>[ 17 ](#footnotes)</sup>]**). 


**${auth_author} Macro** 

RFC2554 `AUTH=` parameter, *sendmail* V8.10 and later.

As part of the RFC2554 authentication scheme, a client can ask whether
a user other than the envelope sender is allowed to authenticate on behalf
of the envelope sender.  This is done by adding an `AUTH=` parameter to the
`MAIL From:` keyword:

```
MAIL From: <user@host.domain> AUTH=address
```

This `${auth_author}` macro is assigned the *address* that followed the
`MAIL From:` AUTH= extension.

The `${auth_author}` macro is useful for adding your own rules to the
`Local_trust_auth` rule set.  
Note that a `$&` prefix is necessary when you reference this macro in rules
(that is, use `$&{auth_author}`, not `${auth_author}`).

Note that beginning with V8.13, the value to be stored into this
macro is first xtext-encoded, then stored (Macro Xtext Translations
**[<sup>[ 17 ](#footnotes)</sup>]**). 

`${auth_author}` is transient.  If defined in the configuration file or in
the command line, that definition can be ignored by *sendmail*.


**${auth_type} Macro**  

Authentication mechanism used, *sendmail* V8.10 and later.

A server offers authentication by presenting the AUTH keyword to
the connecting site, following that with the types of authentication
mechanisms supported:

```
250-host.domain Hello some.domain, pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE
250-DSN
250-ETRN
250-AUTH DIGEST-MD5 CRAM-MD5
250-DELIVERBY
250 HELP
```

Note the line `250-AUTH DIGEST-MD5 CRAM-MD5`

If the connecting site wishes to authenticate itself, it replies with
an AUTH command indicating the mechanism preferred:

```
AUTH CRAM-MD5                                 ← client sends
```

Once it is selected, that mechanism is placed into this `${auth_type}` macro.
If no mechanism is selected (none is offered, or none is accepted) or if the
act of authentication fails, `${auth_type}` becomes undefined (NULL).

If the authentication is accepted, the `Received:` header is updated to reflect that:

```
HReceived: $?sfrom $s $.$?_($?s$|from $.$_)
        $.$?{auth_type}(authenticated$?{auth_ssf} bits=${auth_ssf}$.)
        $.by $j ($v/$Z)$?r with $r$. id $i$?{tls_version}
        (version=${tls_version} cipher=${cipher} bits=${cipher_bits}
verify=${verify})$.$?u
        for $u; $|;
        $.$b
```

Here, if the connection were authenticated, the second line of the
`Received:` header would look like this:

```
(authenticated bits=bits)
(authenticated)                       ← if no encryption negotiated
```

The `${auth_type}` macro is useful for adding your own rules to
policy rule sets, such as to the `Local_trust_auth` rule set.
Note that a `$&` prefix is necessary when you reference this macro
in rules (that is, use `$&{auth_type}`, not `${auth_type}`).

`${auth_type}` is transient.  If defined in the configuration file or in
the command line, that definition can be ignored by *sendmail*.


**[ 17 ]** Macro Xtext Translations

Some macros are assigned values from text that is supplied by outside
connecting hosts.  Such text cannot necessarily be trusted in rule sets,
or as keys in database-map lookups.

To protect itself, *sendmail* modifies such text by translating whitespace
characters (spaces and tabs), nonprinting characters (such as newlines and
control characters), and the following list of special characters:

```
< > ( ) " +
```

*Translation* is the replacement of each special character with its
corresponding hexadecimal value (based on U.S. ASCII), where each new
hexadecimal value is prefixed with a **plus character**. (This is also
called *xtext* translation and is documented in RFC1891.)

```
(some text)        becomes  →   +28some+20text+29
```

Only six macros are subject to this encoding at this time.  They are listed
in the table below. 

*Macros subject to xtext encoding*

```
+-----------------+---------------------------------------------------------------+
| Macro           | Description                                                   |
+-----------------+---------------------------------------------------------------+
| ${auth_authen}  | RFC2554 AUTH credentials (xtext encoded with V8.13 and later) |
+-----------------+---------------------------------------------------------------+
| ${auth_author}  | RFC2554 AUTH= parameter (xtext encoded with V8.13 and later)  |
+-----------------+---------------------------------------------------------------+
| ${cert_issuer}  | Distinguished name of certificate signer                      |
+-----------------+---------------------------------------------------------------+
| ${cert_subject} | Distinguished name of certificate (owner)                     |
+-----------------+---------------------------------------------------------------+
| ${cn_issuer}    | Common name of certificate signer                             |
+-----------------+---------------------------------------------------------------+
| ${cn_subject}   | Common name of certificate                                    |
+-----------------+---------------------------------------------------------------+
```

---

**[ 18 ]** SMTP Basic Commands
(From *Postfix* by Richard Blum, 
Published By: Sams, Publication Date: May 2001):

```
+---------+----------------------------------------------------------------------+
| Command | Description                                                          |
+---------+----------------------------------------------------------------------+
| HELO    | Opening greeting from client                                         |
+---------+----------------------------------------------------------------------+
| MAIL    | Identifies sender of message                                         |
+---------+----------------------------------------------------------------------+
| RCPT    | Identifies recipient(s)                                              |
+---------+----------------------------------------------------------------------+
| DATA    | Identifies start of message                                          |
+---------+----------------------------------------------------------------------+
| SEND    | Sends message to terminal(s)                                         |
+---------+----------------------------------------------------------------------+
| SOML    | Send-or-Mail; sends message to mailbox or terminal of recipient(s)   |
+---------+----------------------------------------------------------------------+
| SAML    | Send-and-Mail; sends message to mailbox and terminal of recipient(s) |
+---------+----------------------------------------------------------------------+
| RSET    | Reset; aborts SMTP connection and discards information               |
+---------+----------------------------------------------------------------------+
| VRFY    | Verifies that username exists on server                              |
+---------+----------------------------------------------------------------------+
| EXPN    | Verifies that mailing list exists on server                          |
+---------+----------------------------------------------------------------------+
| HELP    | Requests list of commands                                            |
+---------+----------------------------------------------------------------------+
| NOOP    | No operation; only elicits an "OK" from server                       |
+---------+----------------------------------------------------------------------+
| QUIT    | Ends the SMTP session                                                |
+---------+----------------------------------------------------------------------+
| TURN    | Requests that the systems reverse their current SMTP roles           |
+---------+----------------------------------------------------------------------+
```

**HELO Command**

This is not a typo.  By definition, SMTP commands are four characters long,
thus the opening greeting by the client to the server is the `HELO` command.
The format for this command is

`HELO hostname`

The purpose of the HELO command is for the client to identify itself to
the SMTP server.  The client can identify itself as whatever it wants to
use in the text string.  Most SMTP servers use this command just as
a formality.  If they really need to know the identity of the client,
they try to use a reverse DNS lookup of the client's IP address to
determine the client's DNS name.  For security reasons, many SMTP servers
refuse to talk to hosts whose IP address does not resolve to a proper
DNS hostname.

By sending the `HELO` command, the client indicates that it wants to
initialize a new SMTP session with the server.  By responding to this
command, the server acknowledges the new connection and should be ready
to receive further commands from the client.

**NOTE:**  *About people clients versus host clients*    
In SMTP you must remember to differentiate between people and hosts.
When creating a new mail message, the email user is the client of his
local host.  Once the user sends his message, s/he is no longer the client
in the SMTP process.  His/her local host computer takes over the process of
mailing the message and now becomes the client as far as SMTP is concerned.
When the local host contacts the remote host to transfer the message
using SMTP, it is now acting as the client in the SMTP process.
The `HELO` command identifies the local hostname as the client, not the
actual sender of the message.  This terminology often gets confusing.


**MAIL Command**

The `MAIL` command initiates a mail session with the server after the
initial `HELO` command is sent.  It identifies from whom the message is
being sent. The format of the `MAIL` command is

`MAIL reverse-path`

The `reverse-path` argument not only identifies the sender, but it also
identifies how to reach the sender with a return message.  If the sender
were a user on the client computer that initiated the SMTP session,
the format for the `MAIL` command would look something like this:

`MAIL FROM:username@example.domain.net`

Notice how the `FROM` section denotes the proper email address for the
sender of the message, including the fully qualified hostname of the client
computer.  This information should appear in the text of the email message
in the `FROM` section.  If the email message has been routed through several
different systems between the original sender and the desired recipient,
each system adds its routing information to the `reverse-path` section.
This documents the path that the email message traversed to get to the server.

Often, mail from clients on private networks has to traverse several mail
relay points before getting to the Internet.  The `reverse-path` information
is often useful in troubleshooting email problems or in tracking down
senders who are purposely trying to hide their identity by bouncing their
email messages off of several unknowing SMTP servers.


**RCPT Command**

The `RCPT` command identifies the intended recipient of the message.
In order to deliver the same message to multiple recipients, each recipient
must be listed in a separate `RCPT` command line. The format of the `RCPT`
command is

`RCPT forward-path`

The `forward-path` argument defines where the email is ultimately destined.
This is usually a fully qualified email address but could be just a username
that is local to the SMTP server.  For example, the following RCPT command

`RCPT TO:haley`

would send the message to user `haley` on the local SMTP server that is
processing the message. 

The protocol also allows messages to be relayed; that is, sent to users on
computer systems other than the server currently handling the SMTP connection.

For example, sending the following `RCPT` command

`RCPT TO:riley@example.domain.net`

to the SMTP server on `shadrach.domain.net` would cause `shadrach.domain.net`
to make a decision.  Since the recipient is not local to `shadrach`, it must
decide what to do with the message.  `shadrach` could take three possible
actions with the message:

* `shadrach` could accept the message for later forwarding to the specified
destination and return an OK response to the client.  In this scenario,
`shadrach` would prepend its hostname to the message's `<reverse-path>`.
* `shadrach` could refuse to forward the message but could reply to the
client that it would not deliver the message.  The response could also verify
that the address of `example.domain.net` was a correct address for another
server.  Then the client could try to resend the message directly to
`example.domain.net`.    
* `shadrach` could refuse to forward the message and could reply to the
client that this operation (relaying) is not permitted from this server.
It would be up to the system administrator at the client to figure out
what happened and why.

In the early days of the Internet, it was common to run across computers
that used the first scenario and blindly forwarded email messages across
the world.  Unfortunately, that courteous behavior was exploited by email
*spammers*, people who do mass mailings across the Internet for either fun
or profit.  Spammers often use unsuspecting, unsecured SMTP servers that
blindly forward email messages in an attempt to disguise the origin of their
mail messages.  To combat this situation, most mail system administrators
have either completely turned off mail relaying or have at least limited
it to hosts within their domain.  Many ISPs allow their customers to relay
email from their mail server but restrict outside computers from that privilege.

In the case of multiple recipients, it is up to the client how to handle
situations in which some of the recipients are not allowed by the server.
Some clients abort the entire message and return an error to the sending
user.  Some continue sending the message to the recipients that are
acknowledged and list the recipients that aren't acknowledged in a return
message.


**DATA Command**

After the `MAIL` and `RCPT` commands are worked out, the `DATA` command
initiates the actual message transfer.  The format of the `DATA` command is

`DATA`

Anything that appears after the command is treated as part of the message
being transferred.  Usually the SMTP server adds a timestamp and
`return-path` information to the head of the message.  The client indicates
the end of the message by sending a line with just **a single period**.
The format for that line is

```
<CR><LF>.<CR><LF>
```

When the SMTP server receives this sequence, it knows that the message
transmission is done and should return a response code to the client
indicating whether the message has been accepted.

Technically there is no wrong way to send a message, although work has been
done to standardize a method (see the "Message Format"
**[<sup>[ 19 ](#footnotes)</sup>]** in Footnotes).  Any combination of
valid ASCII characters is transferred to the specified recipients.  


**RSET Command**

The `RSET` command is short for reset.  If the client somehow gets confused
by the responses from the server or thinks that the SMTP connection has
gotten out of sync, it can issue the `RSET` command to return the connection to the HELO command state. Of course, all MAIL, RCPT, and DATA information already entered is lost. Often this is used as a last-ditch effort when the client either has lost track of where it was in the command series or did not expect a particular response from the server.


**HELP Command**

The `HELP` command asks the server to return useful information to
the client.  `HELP` with no arguments returns a list of SMTP commands
that the SMTP server understands. 

```
$ telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 fbsd1.home.arpa ESMTP Sendmail 8.17.1/8.17.1; Sat, 12 Nov 2022 19:12:14 -0800 (PST)
HELP
214-2.0.0 This is sendmail version 8.17.1
214-2.0.0 Topics:
214-2.0.0       HELO    EHLO    MAIL    RCPT    DATA
214-2.0.0       RSET    NOOP    QUIT    HELP    VRFY
214-2.0.0       EXPN    VERB    ETRN    DSN     AUTH
214-2.0.0       STARTTLS
214-2.0.0 For more info use "HELP <topic>".
214-2.0.0 To report bugs in the implementation see
214-2.0.0       http://www.sendmail.org/email-addresses.html
214-2.0.0 For local information send email to Postmaster at your site.
214 2.0.0 End of HELP info
QUIT
221 2.0.0 fbsd1.home.arpa closing connection
Connection closed by foreign host.
```


**NOOP Command**

The `NOOP` command is short for *no operation*.  This command has no effect
on the SMTP server other than making it return a positive response code.
This is often a useful command to send to test connectivity without actually
starting the message transfer process.


**QUIT Command**

The `QUIT` command indicates that the client computer is finished with the
current SMTP session and wants to close the connection.  It is the
responsibility of the SMTP server to respond to this command and to initiate
the closing of the TCP connection.  If the server receives a `QUIT` command
in the middle of an email transaction, any data previously transferred will
be deleted and not sent to any recipients.


**Extended SMTP**   

Since SMTP invention in 1982, system administrators began to recognize
its limitations.  Work was done to try and improve the basic SMTP protocol
by keeping the original specifications and adding new features.

[RFC 1869, SMTP Service Extensions](https://datatracker.ietf.org/doc/html/rfc1869)
was published in 1995 and defined a method of extending the capabilities of SMTP.

Extended SMTP (ESMTP) replaces the original SMTP greeting (`HELO`) with
a new greeting command: `EHLO`.  When an ESMTP server receives this command,
it should realize that the client is capable of sending extended SMTP commands.

```
$ telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 fbsd1.home.arpa ESMTP Sendmail 8.17.1/8.17.1; Sat, 12 Nov 2022 19:28:44 -0800 (PST)
EHLO localhost
250-fbsd1.home.arpa Hello localhost [127.0.0.1], pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE
250-DSN
250-ETRN
250-AUTH DIGEST-MD5 CRAM-MD5 LOGIN PLAIN
250-STARTTLS
250-DELIVERBY
250 HELP
HELP DSN
214-2.0.0 MAIL From:<sender> [ RET={ FULL | HDRS} ] [ ENVID=<envid> ]
214-2.0.0 RCPT To:<recipient> [ NOTIFY={NEVER,SUCCESS,FAILURE,DELAY} ]
214-2.0.0                    [ ORCPT=<recipient> ]
214-2.0.0       SMTP Delivery Status Notifications.
214-2.0.0 Descriptions:
214-2.0.0       RET     Return either the full message or only headers.
214-2.0.0       ENVID   Sender's "envelope identifier" for tracking.
214-2.0.0       NOTIFY  When to send a DSN. Multiple options are OK, comma-
214-2.0.0               delimited. NEVER must appear by itself.
214-2.0.0       ORCPT   Original recipient.
214 2.0.0 End of HELP info
HELP ETRN
214-2.0.0 ETRN [ <hostname> | @<domain> | #<queuename> ]
214-2.0.0       Run the queue for the specified <hostname>, or
214-2.0.0       all hosts within a given <domain>, or a specially-named
214-2.0.0       <queuename> (implementation-specific).
214 2.0.0 End of HELP info
QUIT
221 2.0.0 fbsd1.home.arpa closing connection
Connection closed by foreign host.
```

Notice that the server indicates that some additional commands are
available now that it is in "extended" mode. One of the new groups
of commands is the Delivery Status Notification (DSN) options.
These options can be used on the `MAIL` and `RCPT` commands to indicate
the delivery status of a particular email message for the client.


**The ETRN Command**

The `ETRN` command allows an SMTP client to issue a request for the SMTP
server to initiate another SMTP connection with the client to transfer
messages back to it.  The `ETRN` command is a request to start another
SMTP session.  This way, the SMTP server can contact the client using the
normal DNS hostname resolution methods.  This does not rely on who the
client says it is.  If a malicious actor establishes an unauthorized SMTP
connection and issues an `ETRN` command, the SMTP server just starts a new
SMTP connection with the real client and sends any mail - no harm done.

The format for the ETRN command is

`ETRN name`

where `name` can be either an individual hostname or a domain name if you
are requesting mail for an entire domain.  The `ETRN` command is a valuable
tool for the mail administrator.  If you elect to have an ISP spool mail
for your email server, you might use this method to notify the ISP when
you are ready to receive your spooled mail.


**The AUTH Command**

Another extended SMTP command gaining popularity is the `AUTH` command,
which allows an SMTP client to identify itself to the SMTP server with
a username and password pair or other agreed-upon authentication technique.
Once the client is positively identified by the server, it may be allowed
to perform special functions, such as using the server as a mail relay,
which non-authenticated clients would not be allowed to do.

The Cyrus-SASL package is a popular software package that can be used to
provide SMTP `AUTH` command support for many MTA packages.
The mail administrator must maintain a separate username and password
database that allows authentication of remote SMTP clients.


**[ 19 ]** Message Format - Standard RFC 822 Header Fields

RFC 822 specifies splitting the message into two separate parts.
The first part is called the *header*.  Its job is to store information
about the message.  The second part is the *body* of the message.
The header consists of data fields that can be used whenever additional
information is needed in the message.  The header fields should appear
before the text body of the message and should be separated by
**one blank line**.  Header fields do not need to appear in any particular
order, and the message can have multiple occurrences of any header field
(though this is deprecated).  Below is how a basic RFC 822-compliant
message would look.

RFC 822-compliant email message 

```
RFC 822-compliant email message 
+-----------------------------+
| RFC 822 Header              |
| +-------------------------+ |
| | Received:               | |
| | Return-Path:            | |
| | Reply-To:               | |
| | From:                   | |
| | Date:                   | |
| | To:                     | |
| +-------------------------+ |
|                             |  
| Message Body                |
| +-------------------------+ |
| |                         | |
| |                         | |
| |                         | |
| |                         | |
| |                         | |
| |                         | |
| +-------------------------+ |
+-----------------------------+
```


From [RFC 822 - Standard for the Format of ARPA Internet Text Messages](https://datatracker.ietf.org/doc/html/rfc822#section-4):  

```
     4.  MESSAGE SPECIFICATION
     
     4.1.  SYNTAX
     
     Note:  Due to an artifact of the notational conventions, the syn-
            tax  indicates that, when present, some fields, must be in
            a particular order.  Header fields  are  NOT  required  to
            occur  in  any  particular  order, except that the message
            body must occur AFTER  the  headers.   It  is  recommended
            that,  if  present,  headers be sent in the order "Return-
            Path", "Received", "Date",  "From",  "Subject",  "Sender",
            "To", "cc", etc.
     
            This specification permits multiple  occurrences  of  most
            fields.   Except  as  noted,  their  interpretation is not
            specified here, and their use is discouraged.

[ . . . ]

     4.4.  ORIGINATOR FIELDS
     
          The standard allows only a subset of the combinations possi-
     ble  with the From, Sender, Reply-To, Resent-From, Resent-Sender,
     and Resent-Reply-To fields.  The limitation is intentional.
     
     4.4.1.  FROM / RESENT-FROM
     
        This field contains the identity of the person(s)  who  wished
        this  message to be sent.  The message-creation process should
        default this field  to  be  a  single,  authenticated  machine
        address,  indicating  the  AGENT  (person,  system or process)
        entering the message.  If this is not done, the "Sender" field
        MUST  be  present.  If the "From" field IS defaulted this way,
        the "Sender" field is  optional  and  is  redundant  with  the
        "From"  field.   In  all  cases, addresses in the "From" field
        must be machine-usable (addr-specs) and may not contain  named
        lists (groups).

     4.4.2.  SENDER / RESENT-SENDER
     
        This field contains the authenticated identity  of  the  AGENT
        (person,  system  or  process)  that sends the message.  It is
        intended for use when the sender is not the author of the mes-
        sage,  or  to  indicate  who among a group of authors actually
        sent the message.  If the contents of the "Sender" field would
        be  completely  redundant  with  the  "From"  field,  then the
        "Sender" field need not be present and its use is  discouraged
        (though  still legal).  In particular, the "Sender" field MUST
        be present if it is NOT the same as the "From" Field.

[ . . . ]

     4.5.  RECEIVER FIELDS
     
     4.5.1.  TO / RESENT-TO
     
        This field contains the identity of the primary recipients  of
        the message.

[ . . . ]

     4.6.  REFERENCE FIELDS
     
     4.6.1.  MESSAGE-ID / RESENT-MESSAGE-ID
     
             This field contains a unique identifier  (the  local-part
        address  unit)  which  refers to THIS version of THIS message.
        The uniqueness of the message identifier is guaranteed by  the
        host  which  generates  it.  This identifier is intended to be
        machine readable and not necessarily meaningful to humans.   A
        message  identifier pertains to exactly one instantiation of a
        particular message; subsequent revisions to the message should
        each receive new message identifiers. 

[ . . . ]

     4.6.3.  REFERENCES
     
             The contents of this field identify other  correspondence
        which  this message references.  Note that if message identif-
        iers are used, they must use the msg-id specification format.

[ . . . ]

     4.7.  OTHER FIELDS
     
     4.7.1.  SUBJECT
     
             This is intended to provide a summary,  or  indicate  the
        nature, of the message.
```


From [RFC 2822 - Internet Message Format](https://datatracker.ietf.org/doc/html/rfc2822): 

```
2.1.1. Line Length Limits

   There are two limits that this standard places on the number of
   characters in a line.  Each line of characters MUST be no more than
   998 characters, and SHOULD be no more than 78 characters, excluding
   the CRLF.

[ . . . ]

2.3. Body

   The body of a message is simply lines of US-ASCII characters.  The
   only two limitations on the body are as follows:

   - CR and LF MUST only occur together as CRLF; they MUST NOT appear
     independently in the body.

   - Lines of characters in the body MUST be limited to 998 characters,
     and SHOULD be limited to 78 characters, excluding the CRLF.
```


Required header fields: 

```
3.6. Field definitions

[ . . . ]

   The only required header fields are the origination date field and
   the originator address field(s).  All other header fields are
   syntactically optional.
```


**[ 20 ]** About the proper format of the `MAIL FROM:` SMTP command. 

From [RFC 821 - Simple Mail Transfer Protocol (SMTP)](https://datatracker.ietf.org/doc/html/rfc821#page-3):

```
Commands and replies are composed of characters from the ASCII
character set [1].  When the transport service provides an 8-bit byte
(octet) transmission channel, each 7-bit character is transmitted
right justified in an octet with the high order bit cleared to zero.

When specifying the general form of a command or reply, an argument
(or special symbol) will be denoted by a meta-linguistic variable (or
constant), for example, "<string>" or "<reverse-path>".  Here the
angle brackets indicate these are meta-linguistic variables.

----

REFERENCES

   [1]  ASCII

      ASCII, "USA Code for Information Interchange", United States of
      America Standards Institute, X3.4, 1968.  Also in:  Feinler, E.
      and J. Postel, eds., "ARPANET Protocol Handbook", NIC 7104, for
      the Defense Communications Agency by SRI International, Menlo
      Park, California, Revised January 1978.
```

```
However, some arguments use the angle brackets literally.  For
example, an actual reverse-path is enclosed in angle brackets, i.e.,
"<John.Smith@USC-ISI.ARPA>" is an instance of <reverse-path> (the
angle brackets are actually transmitted in the command or reply).
```

From [RFC 821 - Simple Mail Transfer Protocol (SMTP)](https://datatracker.ietf.org/doc/html/rfc821#section-3):

```
 3.1.  MAIL

      There are three steps to SMTP mail transactions.  The transaction
      is started with a MAIL command which gives the sender
      identification.  A series of one or more RCPT commands follows
      giving the receiver information.  Then a DATA command gives the
      mail data.  And finally, the end of mail data indicator confirms
      the transaction.

         The first step in the procedure is the MAIL command.  The
         <reverse-path> contains the source mailbox.

            MAIL <SP> FROM:<reverse-path> <CRLF>

         This command tells the SMTP-receiver that a new mail
         transaction is starting and to reset all its state tables and
         buffers, including any recipients or mail data.  It gives the
         reverse-path which can be used to report errors.  If accepted,
         the receiver-SMTP returns a 250 OK reply.

[ . . . ]

The second step in the procedure is the RCPT command.

            RCPT <SP> TO:<forward-path> <CRLF>

         This command gives a forward-path identifying one recipient.
         If accepted, the receiver-SMTP returns a 250 OK reply, and
         stores the forward-path.  If the recipient is unknown the
         receiver-SMTP returns a 550 Failure reply.  This second step of
         the procedure can be repeated any number of times.

[ . . . ]

The third step in the procedure is the DATA command.

            DATA <CRLF>

         If accepted, the receiver-SMTP returns a 354 Intermediate reply
         and considers all succeeding lines to be the message text.
         When the end of text is received and stored the SMTP-receiver
         sends a 250 OK reply.
```

From [RFC 2821 - Simple Mail Transfer Protocol (SMTP)](https://datatracker.ietf.org/doc/html/rfc2821#section-3.3):

```
3.3 Mail Transactions
[ . . . ]

   The first step in the procedure is the MAIL command.

      MAIL FROM:<reverse-path> [SP <mail-parameters> ] <CRLF>

[ . . . ]

   . . .                     The <reverse-path> portion of the first or
   only argument contains the source mailbox (between "<" and ">"
   brackets) . . . 
```


From [RFC 821 - Simple Mail Transfer Protocol (SMTP)](https://datatracker.ietf.org/doc/html/rfc821):

```
4.  THE SMTP SPECIFICATIONS

   4.1.  SMTP COMMANDS

      4.1.1.  COMMAND SEMANTICS

         The SMTP commands define the mail transfer or the mail system
         function requested by the user.  SMTP commands are character
         strings terminated by <CRLF>.  The command codes themselves are
         alphabetic characters terminated by <SP> if parameters follow
         and <CRLF> otherwise.  The syntax of mailboxes must conform to
         receiver site conventions.  The SMTP commands are discussed
         below.  The SMTP replies are discussed in the Section 4.2.

[ . . . ]

         The last command in a session must be the QUIT command.  The
         QUIT command can not be used at any other time in a session.


  4.1.2.  COMMAND SYNTAX

         The commands consist of a command code followed by an argument
         field.  Command codes are four alphabetic characters.  Upper
         and lower case alphabetic characters are to be treated
         identically.  Thus, any of the following may represent the mail
         command:

            MAIL    Mail    mail    MaIl    mAIl

         This also applies to any symbols representing parameter values,
         such as "TO" or "to" for the forward-path.  Command codes and
         the argument fields are separated by one or more spaces.
         However, within the reverse-path and forward-path arguments
         case is important.  In particular, in some hosts the user
         "smith" is different from the user "Smith".

         The argument field consists of a variable length character
         string ending with the character sequence <CRLF>.  The receiver
         is to take no action until this sequence is received.

[ . . . ]

         The syntax of the above argument fields (using BNF notation
         where applicable) is given below.  The "..." notation indicates
         that a field may be repeated one or more times.

[ . . . ]

            <CR> ::= the carriage return character (ASCII code 13)

            <LF> ::= the line feed character (ASCII code 10)

            <SP> ::= the space character (ASCII code 32)
```


**[ 21 ]** From the man page for `s_client(1)`:

```
  CONNECTED COMMANDS
         If a connection is established with an SSL server then any data
         received from the server is displayed and any key presses will be sent
         to the server. If end of file is reached then the connection will be
         closed down. When used interactively (which means neither -quiet nor
         -ign_eof have been given), then certain commands are also recognized
         which perform special operations. These commands are a letter which
         must appear at the start of a line. They are listed below.

[ . . . ]

         R   Renegotiate the SSL session (TLSv1.2 and below only).
```

---


