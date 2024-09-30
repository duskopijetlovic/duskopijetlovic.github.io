---
layout: post
title: "Sendmail Notes [WIP]"
date: 2022-10-22 09:50:18 -0700 
categories: sendmail smtp mta mailserver cli terminal shell freebsd sysadmin reference 
---

## **[TODO]:**  SANITIZE! 

OSs:   
FreeBSD 13.1-RELEASE-p2 with sendmail 8.17.1, Shell: csh   
Red Hat Enterprise Linux Server release 6.8 (Santiago) with sendmail 8.14.4, Shell: bash   


Restart sendmail:

```
# kill -HUP `head -1 /var/run/sendmail.pid`
```

From [configure-sendmail-as-relay.md](https://gist.github.com/drmalex07/d63348dc9d26d1349309):

On the mail server:

```
$ printf "Subject: Hello\r\n\r\nI say hello"| sendmail -v -F 'Contact' someone@foo.com
```

## Test STARTTLS

Reference: Bat book, 4th edition   

Assumption: *sendmail* built with STARTTLS support.   


```
# sendmail -bs -Am
```

The `-bs` tells *sendmail* to speak SMTP on its standard input.  
The `-Am` tells *sendmail* to use its server configuration file
(not *submit.cf*), even though it is running in mail-submission mode. 

```
# sendmail -bs -Am
220 your.host.domain ESMTP mailer ready at Wed, 26 Oct 2022 19:02:10 -0700
ehlo your.host.domain
250-your.host.domain Hello root@localhost, pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-STARTTLS
250-DELIVERBY
250 HELP
quit
221 2.0.0 your.host.domain closing connection
```

Note the line `250-STARTTLS`


## Test SASL support in sendmail 

Reference: The Bat book, 4th edition - 5.1.2.1 Test SASL support in sendmail

The `-bs` tells *sendmail* to speak SMTP on its standard input.  
The `-Am` tells *sendmail* to use its server configuration file
(not *submit.cf*), even though it is running in mail-submission mode. 


```
# sendmail -bs -Am
220 test.host.domain ESMTP mailer ready at Wed, 26 Oct 2022 19:13:41 -0700
ehlo localhost
250-test.host.domain Hello root@localhost, pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-STARTTLS
250-DELIVERBY
250 HELP
quit
221 2.0.0 test.host.domain closing connection
```

Look for a line with `250-AUTH`.   
If it's missing, check the log file: 

```
# grep 'Oct 26 19:13:41' /var/log/maillog | grep 'allowed mech' 
Oct 26 19:13:41 test sendmail[14440]: AUTH: available mech=GSSAPI, allowed mech=LOGIN PLAIN
```


But:

```
# sendmail -bs -L sm-smmsp-queue -Ac
220 test.host.domain ESMTP Sendmail 8.14.4/8.14.4/Submit; Wed, 26 Oct 2022 19:59:22 -0700
ehlo localhost
250-test.host.domain Hello root@localhost, pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE
250-DSN
250-AUTH GSSAPI
250-DELIVERBY
250 HELP
quit
221 2.0.0 test.host.domain closing connection
```

```
# grep 'Oct 26 19:59:22' /var/log/maillog
```

```
# sendmail -bs -OLogLevel=13 -L sm-smmsp-queue -Ac
220 test.host.domain ESMTP Sendmail 8.14.4/8.14.4/Submit; Wed, 26 Oct 2022 19:59:59 -0700
ehlo localhost
250-test.host.domain Hello root@localhost, pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE
250-DSN
250-AUTH GSSAPI
250-DELIVERBY
250 HELP
quit
221 2.0.0 test.host.domain closing connection
```

```
# grep 'Oct 26 19:59:59' /var/log/maillog
Oct 26 19:59:59 test sm-smmsp-queue[23675]: NOQUEUE: connect from root@localhost
Oct 26 19:59:59 test sm-smmsp-queue[23675]: STARTTLS: ServerCertFile missing
Oct 26 19:59:59 test sm-smmsp-queue[23675]: AUTH: available mech=ANONYMOUS GSSAPI PLAIN LOGIN, allowed mech=EXTERNAL GSSAPI KERBEROS_V4 DIGEST-MD5 CRAM-MD5
Oct 26 19:59:59 test sm-smmsp-queue[23675]: 29R0xxvL023675: Milter: no active filter
```


## TO EXPAND

### 1

```
# cd /etc/mail

# make --dry-run
# make -n 
```


### Address Test Mode (`-bt`)

From the man page for *sendmail*:

```
-bt    Run in address test mode.  This mode reads addresses and shows
       the steps in parsing; it is used for debugging configuration
       tables.
```

From  
sendmail Cookbook - Craig Hunt   
2009 O'Reilly Media, Inc.   
1005 Gravenstein Highway North, Sebastopol, CA 95472   

> **1.9. Testing a New Configuration**    
> 
> **Problem**   
> 
> You need to test the sendmail configuration before it is deployed.
> 
> **Solution**  
> 
> Use the *sendmail* command-line options `-bt`, `-bv`, and `-v`.
> 
> **Discussion**  
> 
> At the end of Recipe 1.8, the newly created sendmail.cf is copied over
> the old configuration.  Do not copy a customized configuration into the
> */etc/mail* directory until it is thoroughly tested.  *sendmail* provides
> excellent test tools that are used extensively in this book.
> 
> The single most important tool for testing sendmail is sendmail itself.
> When started with the `-bt` command-line option, *sendmail* enters
> **test mode**.  While in test mode, *sendmail* accepts a variety of
> commands that examine the configuration, check settings, and observe how
> email addresses are processed by sendmail.  Table 1-2 lists the commands
> that are available in test mode.


Table 1-2. sendmail test mode commands

```
+--------------------+-------------------------------------------------------+
| Command            | Usage                                                 |
+--------------------+-------------------------------------------------------+
| <ruleset address>  | Process the address through the comma-separated lists |
|                    | of rulesets.                                          |
+--------------------+-------------------------------------------------------+
| =S <ruleset>       | Display the contents of the rulesets                  |
+--------------------+-------------------------------------------------------+
| =M                 | Display all of the mailer definitions.                |
+--------------------+-------------------------------------------------------+
| $ <v>              | Display the value of macro <v>.                       |
+--------------------+-------------------------------------------------------+
| $= <c>             | Display the value of class <c>.                       |  
+--------------------+-------------------------------------------------------+
| .D <vvalue>        | Set the macro <v> to <value>.                         |
+--------------------+-------------------------------------------------------+
| .C <cvalue>        | Add <value> to class <c>.                             |  
+--------------------+-------------------------------------------------------+
| -d <value>         | Set the debug value to <value>.                       | 
+--------------------+-------------------------------------------------------+
| /tryflags <flags>  | Set the flags used for address processing by /try     |
+--------------------+-------------------------------------------------------+
| /try <mailer> <ad- | Process the address for the <mailer>.                 |
| dress>             |                                                       |
+--------------------+-------------------------------------------------------+
| /parse <address>   | Return the mailer/host/user delivery triple for       |
|                    | the address.                                          |  
+--------------------+-------------------------------------------------------+
| /canon <hostname>  | Canonify <hostname>.                                  |
+--------------------+-------------------------------------------------------+
| /mx <hostname>     | Lookup the MX records for <hostname>.                 |
+--------------------+-------------------------------------------------------+
| /map <mapname>     | Look up <key> in the database identify by <mapname>.  |
+--------------------+-------------------------------------------------------+
| /quit              | Exit address test mode.                               |
+--------------------+-------------------------------------------------------+
```

---

sendmail Cookbook - Craig Hunt  
2009 O'Reilly Media, Inc.  
1005 Gravenstein Highway North, Sebastopol, CA 95472   

https://learning.oreilly.com/library/view/sendmail-cookbook/0596004710/ch03.html#sendmailckbk-CHP-3-SECT-1

```
# cat > special-test
               /parse tyler@science.foo.edu
               /parse sara@crab
               /parse craig
               CTRL-D
# sendmail -bt < special-test | grep '^mailer'
mailer relay, host smtp.wrotethebook.com, user tyler@science.foo.edu
mailer relay, host smtp.wrotethebook.com, user sara@crab.wrotethebook.com
mailer local, user craig
```


```
# sendmail -bv dusko -C/etc/mail/sendmail.cf
-C/etc/mail/sendmail.cf... User unknown
dusko... deliverable: mailer local, user dusko

# sendmail -bv dusko@some.domain -C/etc/mail/sendmail.cf
-C/etc/mail/sendmail.cf... User unknown
dusko@some.domain... deliverable: mailer local, user dusko

# sendmail -bv duskop@some.domain -C/etc/mail/sendmail.cf
-C/etc/mail/sendmail.cf... User unknown
duskop@some.domain ... deliverable: mailer esmtp, host mail.some.domain., user duskop@mail.some.comain

# sendmail -bv dusko_pijetlovic@yahoo.ca -C/etc/mail/sendmail.cf
-C/etc/mail/sendmail.cf... User unknown
dusko_pijetlovic@yahoo.ca... deliverable: mailer esmtp, host yahoo.ca., user dusko_pijetlovic@yahoo.ca
```


The content of the `relay-domains` file (in the following example it's empty):

```
# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> $=R
> /quit
```


```
# service sendmail status
sendmail (pid  538) is running...
sm-client (pid  547) is running...
```

```
# ps aux | grep -v grep | grep 538 
root       538  0.0  0.0  88884  3580 ?        Ss   Oct24   0:24 sendmail: accepting connections
```

```
# ps aux | grep -v grep | grep 547 
smmsp      547  0.0  0.0  78260  2116 ?        Ss   Oct24   0:00 sendmail: Queue runner@00:05:00 for /var/spool/clientmqueue
```

```
# cat /var/run/sendmail.pid 
538
/usr/sbin/sendmail -bd -q5m
```

```
# grep -r sendmail /etc/rc* | grep '\-bd'
/etc/rc.d/init.d/sendmail:    daemon /usr/sbin/sendmail $([ "x$DAEMON" = xyes ] && echo -bd) \

# grep -r sendmail /etc/init* | grep '\-bd'
/etc/init.d/sendmail:    daemon /usr/sbin/sendmail $([ "x$DAEMON" = xyes ] && echo -bd) \
```


```
# grep -r sendmail /etc/rc* | grep Ac
/etc/rc.d/init.d/sendmail:      daemon --check sm-client /usr/sbin/sendmail -L sm-msp-queue -Ac \

# grep -r sendmail /etc/init* | grep Ac
/etc/init.d/sendmail:   daemon --check sm-client /usr/sbin/sendmail -L sm-msp-queue -Ac \
```

> The `-bd` option line causes sendmail to run as a daemon and listen 
> for incoming mail on ports 25 and 587.  This first command creates the 
> sendmail daemon that reads the *sendmail.cf* configuration file and 
> runs in the traditional role of a mail transfer agent (MTA). 
> The second command starts sendmail as a mail submission program (MSP).
> The `-Ac` option on this command line directs sendmail to read the
> *submit.cf* configuration file.  The `-L` option tells this copy of 
> sendmail to use the name *sm-msp* when it logs messages.  Without the
> `-L` option, both copies of sendmail would log messages using the
> name *sendmail* making it difficult to determine which copy of sendmail
> logged the message.  The `-q5m` option directs a copy of sendmail to 
> process its mail queue every 5 minutes. 


#### Chapter Masquerading 

```
$ grep MASQUERADE_AS /etc/mail/freebsd.submit.mc
MASQUERADE_AS(`mydomain.to.masqueradeas')dnl
```

```
$ hostname
fbsd1.mydomain.to.masqueradeas
```

```
$ su
```

```
# sendmail -bt -Ac
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>

> $M
mydomain.to.masqueradeas
 
> $w
fbsd1
 
> $j
fbsd1.mydomain.to.masqueradeas

> /quit
```


```
# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>

> $M
Undefined

> $w
fbsd1
 
> $j
fbsd1.mydomain.to.masqueradeas

> /quit
``` 


```
# sendmail -bt -Ac
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
 
> /tryflags HS
> /try esmtp dusko
Trying header sender address dusko for mailer esmtp
canonify           input: dusko
Canonify2          input: dusko
Canonify2        returns: dusko
canonify         returns: dusko
1                  input: dusko
1                returns: dusko
HdrFromSMTP        input: dusko
PseudoToReal       input: dusko
PseudoToReal     returns: dusko
MasqSMTP           input: dusko
MasqSMTP         returns: dusko < @ *LOCAL* >
MasqHdr            input: dusko < @ *LOCAL* >
MasqHdr          returns: dusko < @ mydomain . to . masqueradeas . >
HdrFromSMTP      returns: dusko < @ mydomain . to . masqueradeas . >
final              input: dusko < @ mydomain . to . masqueradeas . >
final            returns: dusko @ mydomain . to . masqueradeas
Rcode = 0, addr = dusko@mydomain.to.masqueradeas
 
> /quit
```


```
# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
 
> /tryflags HS
> /try esmtp dusko
Trying header sender address dusko for mailer esmtp
canonify           input: dusko
Canonify2          input: dusko
Canonify2        returns: dusko
canonify         returns: dusko
1                  input: dusko
1                returns: dusko
HdrFromSMTP        input: dusko
PseudoToReal       input: dusko
PseudoToReal     returns: dusko
MasqSMTP           input: dusko
MasqSMTP         returns: dusko < @ *LOCAL* >
MasqHdr            input: dusko < @ *LOCAL* >
MasqHdr          returns: dusko < @ fbsd1 . mydomain . to . masqueradeas . >
HdrFromSMTP      returns: dusko < @ fbsd1 . mydomain . to . masqueradeas . >
final              input: dusko < @ fbsd1 . mydomain . to . masqueradeas . >
final            returns: dusko @ fbsd1 . mydomain . to . masqueradeas
Rcode = 0, addr = dusko@fbsd1.mydomain.to.masqueradeas
 
> /quit
```

The `$M` command shows `$M` macro (`MASQUERADE_AS`).   
The `$j` command shows the fully qualified name of this host.   
The `/tryflags` command tells sendmail to process the header sender (HS) address.   
The `/try` command tells sendmail to process *dusko* as the header sender 
address for the `esmtp` mailer.  Notice that *dusko* is an email address 
that does not contain a host part.  sendmail adds a hostname to the 
unqualified username, and, by default, it adds the hostname found in `$j`. 
The value returned by the `MasqHdr` ruleset shows this.


#### Dump a Class Macro with $=

The `$=` rule-testing command tells *sendmail* to print all the members for
a class.  The class name must immediately follow the `=` with no
intervening space.

```
# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
 
> $=w
localhost
fbsd1.your.local.domain
[127.0.0.1]
[123.45.67.8]
localhost.my.domain
[localhost.my.domain]

> $=m
your.local.domain

> $=M

> $={VirtHost}
 
> $=R

> $=N

> $=E
root

> /quit
```


ES = Envelope Sender

The `/tryflags ES` command configures sendmail to test header 
sender (HS) address processing:

```
# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
 
> /tryflags ES
> /try esmtp dusko@mydomain.to.masqueradeas
Trying envelope sender address dusko@mydomain.to.masqueradeas for mailer esmtp
canonify           input: dusko @ mydomain . to . masqueradeas
Canonify2          input: dusko < @ mydomain . to . masqueradeas >
Canonify2        returns: dusko < @ mydomain . to . masqueradeas . >
canonify         returns: dusko < @ mydomain . to . masqueradeas . >
1                  input: dusko < @ mydomain . to . masqueradeas . >
1                returns: dusko < @ mydomain . to . masqueradeas . >
EnvFromSMTP        input: dusko < @ mydomain . to . masqueradeas . >
PseudoToReal       input: dusko < @ mydomain . to . masqueradeas . >
PseudoToReal     returns: dusko < @ mydomain . to . masqueradeas . >
MasqSMTP           input: dusko < @ mydomain . to . masqueradeas . >
MasqSMTP         returns: dusko < @ mydomain . to . masqueradeas . >
MasqEnv            input: dusko < @ mydomain . to . masqueradeas . >
MasqHdr            input: dusko < @ mydomain . to . masqueradeas . >
MasqHdr          returns: dusko < @ mydomain . to . masqueradeas . >
MasqEnv          returns: dusko < @ mydomain . to . masqueradeas . >
EnvFromSMTP      returns: dusko < @ mydomain . to . masqueradeas . >
final              input: dusko < @ mydomain . to . masqueradeas . >
final            returns: dusko @ mydomain . to . masqueradeas . >
Rcode = 0, addr = dusko@mydomain.to.masqueradeas
 
> /quit
```


#### Chapter Controlling Spam 

```
# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>

> check_mail dusko@some.ext.domain
check_mail         input: dusko @ some . ext . domain
Basic_check_mail   input: dusko @ some . ext . domain
tls_client         input: $| MAIL
D                  input: < > < ? > < ! "TLS_Clt" > < >
D                returns: < ? > < > < ? > < ! "TLS_Clt" > < >
A                  input: < > < ? > < ! "TLS_Clt" > < >
A                returns: < > < ? > < ! "TLS_Clt" > < >
TLS_connection     input: $| < > < ? > < ! "TLS_Clt" > < >
TLS_connection   returns: OK
tls_client       returns: OK
CanonAddr          input: < dusko @ some . ext . domain >
canonify           input: < dusko @ some . ext . domain >
Canonify2          input: dusko < @ some . ext . domain >
Canonify2        returns: dusko < @ some . ext . domain . >
canonify         returns: dusko < @ some . ext . domain . >
Parse0             input: dusko < @ some . ext . domain . >
Parse0           returns: dusko < @ some . ext . domain . >
CanonAddr        returns: dusko < @ some . ext . domain . >
SearchList         input: < + From > $| < F : dusko @ some . ext . domain > < U : dusko @ > < D : some . ext . domain > < >
F                  input: < dusko @ some . ext . domain > < ? > < + From > < >
F                returns: < ? > < >
SearchList         input: < + From > $| < U : dusko @ > < D : some . ext . domain > < >
U                  input: < dusko @ > < ? > < + From > < >
U                returns: < ? > < >
SearchList         input: < + From > $| < D : some . ext . domain > < >
D                  input: < some . ext . domain > < ? > < + From > < >
D                  input: < ext . domain > < ? > < + From > < >
D                  input: < domain > < ? > < + From > < >
D                returns: < ? > < >
D                returns: < ? > < >
D                returns: < ? > < >
SearchList       returns: < ? >
SearchList       returns: < ? >
SearchList       returns: < ? >
Basic_check_mail returns: @ dusko < @ some . ext . domain >
check_mail       returns: @ dusko < @ some . ext . domain >

> check_relay dusko@some.external.domain
check_relay        input: dusko @ some . external . domain
check_relay      returns: dusko @ some . external . domain $| dusko @ some . external . domain

> .D{client_addr}192.168.111.68

> Basic_check_relay <>
Basic_check_rela   input: < >
Basic_check_rela returns: < >
 
> /quit
```


```
# sendmail -bt -Ac
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
 
> check_mail dusko@some.ext.domain
check_mail         input: dusko @ some . ext . domain
Basic_check_mail   input: dusko @ some . ext . domain
tls_client         input: $| MAIL
TLS_connection     input:
TLS_connection   returns:
tls_client       returns:
CanonAddr          input: < dusko @ some . ext . domain >
canonify           input: < dusko @ some . ext . domain >
Canonify2          input: dusko < @ some . ext . domain >
Canonify2        returns: dusko < @ some . ext . domain . >
canonify         returns: dusko < @ some . ext . domain . >
Parse0             input: dusko < @ some . ext . domain . >
Parse0           returns: dusko < @ some . ext . domain . >
CanonAddr        returns: dusko < @ some . ext . domain . >
Basic_check_mail returns: @ dusko < @ some . ext . domain >
check_mail       returns: @ dusko < @ some . ext . domain >
 
> check_relay dusko@some.ext.domain
check_relay        input: dusko @ some . ext . domain
check_relay      returns: dusko @ some . ext . domain $| dusko @ some . ext . domain

> .D{client_addr}192.168.111.68     

> Basic_check_relay <>
Basic_check_rela   input: < >
Basic_check_rela returns: < >
 
> /quit
```

```
# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
 
> Local_check_mail dusko
Local_check_mail   input: dusko
Local_check_mail returns: dusko
 
> Local_check_mail dusko@some.ext.domain
Local_check_mail   input: dusko @ some . ext . domain
Local_check_mail returns: dusko @ some . ext . domain
 
> Local_check_mail dusko_pijetlovic@yahoo.ca
Local_check_mail   input: dusko_pijetlovic @ yahoo . ca
Local_check_mail returns: dusko_pijetlovic @ yahoo . ca

> /quit
```


```
$ ps $$
  PID TT  STAT    TIME COMMAND
11825  2  Ss   0:00.09 -tcsh (tcsh)
 
$ printf %s\\n "$SHELL"
/bin/tcsh

$ su
Password:
# 

# command -v bash; type bash; whereis bash; which bash
/usr/local/bin/bash
bash is /usr/local/bin/bash
bash: /usr/local/bin/bash /usr/local/man/man1/bash.1.gz /usr/ports/shells/bash
/usr/local/bin/bash

# pkg info --regex bash
bash-5.2.2_1

# cat /etc/shells
# $FreeBSD$
#
# List of acceptable shells for chpass(1).
# Ftpd will not allow users to connect who are not using
# one of these shells.

/bin/sh
/bin/csh
/bin/tcsh
/usr/local/bin/bash
/usr/local/bin/rbash
/usr/local/libexec/git-core/git-shell
/usr/local/bin/ksh93

# bash
# 

# ps $$
  PID TT  STAT    TIME COMMAND
13555  2  S    0:00.01 bash
```

While in *bash*:
 
```
# echo -n "${EMAIL_CONTENT:6:-3}" | sendmail -Am -d60.5 -v dusko@some.ext.domain
map_lookup(dequote, dusko, %0=dusko) => NOT FOUND (0), ad=0
map_lookup(host, some.ext.domain, %0=some.ext.domain) => some.ext.domain. (0), ad=0
dusko@some.ext.domain... Connecting to esva.mail-relay.your.isp. via esmtp...
220 srv01.mail-relay.your.isp ESMTP
>>> EHLO fbsd1.home.arpa
250-srv01.mail-relay.your.isp 
250-8BITMIME
250-SIZE 52428800
250 STARTTLS
>>> STARTTLS
220 Go ahead with TLS
map_lookup(macro, {TLS_Name}, %0={TLS_Name}, %1=esva.mail-relay.your.isp) =>  (0), ad=0
>>> EHLO fbsd1.home.arpa
250-srv01.mail-relay.your.isp 
250-8BITMIME
250 SIZE 52428800
>>> MAIL From:<dusko@fbsd1.home.arpa>
250 sender <dusko@fbsd1.home.arpa> ok
map_lookup(macro, {TLS_Name}, %0={TLS_Name}, %1=esva.mail-relay.your.isp) =>  (0), ad=0
map_lookup(host, some.ext.domain, %0=some.ext.domain) => some.ext.domain. (0), ad=0
>>> RCPT To:<dusko@some.ext.domain>
250 recipient <dusko@some.ext.domain> ok
>>> DATA
354 go ahead
>>> .
250 ok:  Message 7580284 accepted
dusko@some.ext.domain... Sent (ok:  Message 7580284 accepted)
Closing connection to esva.mail-relay.your.isp.
>>> QUIT
221 srv01.mail-relay.your.isp
```


```
# echo -n "${EMAIL_CONTENT:6:-3}" | sendmail -Ac -d60.5 -v dusko@some.ext.domain
map_lookup(dequote, dusko, %0=dusko) => NOT FOUND (0), ad=0
map_lookup(host, some.ext.domain, %0=some.ext.domain) => some.ext.domain. (0), ad=0
dusko@some.ext.domain... Connecting to [127.0.0.1] port 1465 via smartrelay...
220 your.isp.net ESMTP mailer ready at Sat, 28 Jan 2023 21:15:03 -0800
>>> EHLO fbsd1.home.arpa
250-your.isp.net Hello fbsd1.home.arpa [123.45.67.89], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-AUTH LOGIN PLAIN
250-DELIVERBY
250 HELP
map_lookup(authinfo, AuthInfo:[127.0.0.1], %0=AuthInfo:[127.0.0.1]) => "U:smmsp" "I:dusko"  "P:YourSmartHostPwd" "M:LOGIN" (0), ad=0
>>> AUTH LOGIN
334 VXNlcm5hbWU6
>>> ABCab12=
334 UGFzc3dvcmQ6
>>> ABCdEF12gHIJkLMnoPQRSt==
235 2.0.0 OK Authenticated
>>> MAIL From:<dusko@fbsd1.home.arpa> AUTH=dusko@fbsd1.home.arpa
250 2.1.0 <dusko@fbsd1.home.arpa>... Sender ok
>>> RCPT To:<dusko@some.ext.domain>
250 2.1.5 <dusko@some.ext.domain>... Recipient ok
>>> DATA
354 Enter mail, end with "." on a line by itself
>>> .
250 2.0.0 30T5F3AO022530 Message accepted for delivery
dusko@some.ext.domain... Sent (30T5F3AO022530 Message accepted for delivery)
Closing connection to [127.0.0.1]
>>> QUIT
221 2.0.0 your.isp.net closing connection
```

Exit *bash*.

```
# exit
```

Exit *root*.

```
# exit
$ 
```

```
# find /etc -iname '*sasl*'
/etc/selinux/targeted/modules/active/modules/sasl.pp
/etc/sysconfig/saslauthd
/etc/rc.d/rc2.d/S65saslauthd
/etc/rc.d/rc1.d/K10saslauthd
/etc/rc.d/rc6.d/K10saslauthd
/etc/rc.d/rc4.d/S65saslauthd
/etc/rc.d/rc5.d/S65saslauthd
/etc/rc.d/rc3.d/S65saslauthd
/etc/rc.d/rc0.d/K10saslauthd
/etc/rc.d/init.d/saslauthd
/etc/sasl2

# ls -lh /etc/sasl2
total 4.0K
-rw-r--r-- 1 root root 49 Sep 25  2016 Sendmail.conf

# ls -lh /etc/sasl2/Sendmail.conf 
-rw-r--r-- 1 root root 49 Sep 25  2016 /etc/sasl2/Sendmail.conf

# cat /etc/sasl2/Sendmail.conf 
pwcheck_method:saslauthd
#mech_list: login plain
```

#### Chapter Authenticating with AUTH

Send mail to the remote host to test the AUTH credentials.  Call `sendmail` 
with the `-v` option in order to watch the protocol interactions. Here is a 
sample test:

```
# sendmail -Am -v -t
To: dusko@example.com
From: dusko@example.dom
Subject: Test

Please ignore.
```

Press *Ctrl-D*

In addition to the `-v` option, this test invokes sendmail with `-t` 
and `-Am`. `-t` tells sendmail to obtain the recipient address from any 
To:, CC:, and Bcc: lines in the message.  (In the example, you specified 
the recipient with a To: line in the message.)  The first five lines after 
the `sendmail` command is your test message, which is terminated by a 
Ctrl-D end-of-file mark.  The `-Am` option tells sendmail to run as an MTA, 
using the *sendmail.cf* configuration.  If this option is not specified, 
sendmail runs as a message submission program (MSP), uses the *submit.cf* 
configuration, and displays the interaction between the user's `sendmail` 
command and the local system.  Because you want to watch the MTA interaction 
between your system and a remote system, you need to use the `-Am` option.

Every line after the Ctrl-D is output from sendmail.  Output lines that 
start with `>>>` are SMTP commands coming from the sending system. 
Lines that start with a numeric response code come from the receiving system.


```
# grep AuthMechanisms /etc/mail/sendmail.cf
O AuthMechanisms=LOGIN PLAIN
```

```
# grep TrustAuthMech /etc/mail/sendmail.cf
C{TrustAuthMech}LOGIN PLAIN
R$* $| $={TrustAuthMech}        $# RELAY
```

```
# grep DaemonPortOptions /etc/mail/sendmail.cf
O DaemonPortOptions=Name=MTA, M=A
O DaemonPortOptions=Port=465, Name=MTASSL, M=s a
O DaemonPortOptions=Port=587, Name=MSA, M=a
O DaemonPortOptions=Addr=127.0.0.1, Port=10026
```

```
# grep -r Srv_Features /etc/mail/sendmail.cf
R$*             $: $>D <$&{client_name}> <?> <! "Srv_Features"> <>
R<?>$*          $: $>A <$&{client_addr}> <?> <! "Srv_Features"> <>
R<?>$*          $: <$(access "Srv_Features": $: ? $)>
```

## Chapter Securing the Mail Transport

```
# grep -r Try_TLS /etc/mail/sendmail.cf
R$*             $: $>D <$&{server_name}> <?> <! "Try_TLS"> <>
R<?>$*          $: $>A <$&{server_addr}> <?> <! "Try_TLS"> <>
R<?>$*          $: <$(access "Try_TLS": $: ? $)>
```


## Chapter Managing the Queue


```
# grep QueueDirectory /etc/mail/sendmail.cf
O QueueDirectory=/var/spool/mqueue
```

The `/mx` command returns the MX list sendmail will use to deliver to the 
specified recipient host:

```
# sendmail -bt 
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
 
> /mx sendmail.org
getmxrr(sendmail.org) returns 1 value(s):
        mc.sendmail.org.
 
> /mx yahoo.com
getmxrr(yahoo.com) returns 3 value(s):
        mta5.am0.yahoodns.net.
        mta7.am0.yahoodns.net.
        mta6.am0.yahoodns.net.

> /mx aol.com
getmxrr(aol.com) returns 1 value(s):
        mx-aol.mail.gm0.yahoodns.net.

> /mx gmail.com
getmxrr(gmail.com) returns 5 value(s):
        gmail-smtp-in.l.google.com.
        alt1.gmail-smtp-in.l.google.com.
        alt2.gmail-smtp-in.l.google.com.
        alt3.gmail-smtp-in.l.google.com.
        alt4.gmail-smtp-in.l.google.com.

> /mx some_domain.com 
getmxrr(duskopijetlovic.com) returns 2 value(s):
        aspmx1.somemx.com.
        aspmx2.somemx.com.

> /quit
```


## Chapter Securing sendmail


```
# grep '^M' /etc/mail/sendmail.cf | awk '{ print $1 $3 }'
Msmtp,F=mDFMuX,
Mesmtp,F=mDFMuXa,
Msmtp8,F=mDFMuX8,
Mdsmtp,F=mDFMuXa%,
Mrelay,F=mDFMuXa8,
Mlocal,F=lsDFMAw5:/|@qSPfhn9,
Mprog,F=lsDFMoqeu9,
Mprocmail,F=DFMSPhnu9,
```

```
# grep '^Mprog' /etc/mail/sendmail.cf
Mprog,          P=/usr/sbin/smrsh, F=lsDFMoqeu9, S=EnvFromL/HdrFromL, R=EnvToL/HdrToL, D=$z:/,

# strings /usr/sbin/smrsh | grep '^/'
/lib64/ld-linux-x86-64.so.2
/wTH
/w&H
/etc/smrsh
/bin:/usr/bin
/bin/sh
```

```
# grep '^DZ' /etc/mail/sendmail.cf
DZ8.14.4
```

```
# grep '^T' /etc/mail/sendmail.cf
Troot
Tdaemon
```


## Bat Book

Book:   
**sendmail**  
by Bryan Coastales with Eric Allman and Neil Rickert  
Copyright (c) 1993 O'Reilly & Associates, Inc.   
Printing history:  
November 1993: First Edition.   
February 1994: Minor corrections.  
September 1994: Minor corrections.    
ISBN: 1-56592-056-2   


**sendmail, Fourth Edition**  
by Bryan Coastales, George Jansen and Clauss Assman with Gregory Neil Shapiro
Copyright (c) 2008 Bryan Coastales, George Jansen and Clauss Assman  
Published by O'Reilly Media, Inc.   

Printing history:  
November 1993: First Edition.   
January 1997: Second Edition.  
December 2002: Third Editon.  
October 2007: Fourt Editon.  
ISBN-10: 0-596-51029-2   
ISBN-13: 978-0-596-51029-2   


### Chapter 3 The Roles of sendmail

Locations of other programs and files that `sendmail` uses: 

```
# grep -v \# /etc/mail/sendmail.cf | grep "/[^0-9].*/"
Fw/etc/mail/local-host-names
FR-o /etc/mail/relay-domains
Kaccess hash -T<TMPF> /etc/mail/access
Kaccess hash -o -T<TMPF> /etc/mail/access
Kmailertable hash -o /etc/mail/mailertable
Kvirtuser hash -o /etc/mail/virtusertable
O AliasFile=/etc/aliases
O HelpFile=/etc/mail/helpfile
O ForwardPath=$z/.forward.$w:$z/.forward
O QueueDirectory=/var/spool/mqueue
O CACertPath=/etc/mail/certs/alpha
O CACertFile=/etc/mail/certs/alpha/alphaintercert.crt
O ServerCertFile=/etc/mail/certs/alpha/my.domain.crt
O ServerKeyFile=/etc/mail/certs/alpha/my.domain.key
O ClientCertFile=/etc/mail/certs/alpha/my.domain.crt
O ClientKeyFile=/etc/mail/certs/alpha/my.domain.key
Ft-o /etc/mail/trusted-users
             T=DNS/RFC822/SMTP,
             T=DNS/RFC822/SMTP,
             T=DNS/RFC822/SMTP,
             T=DNS/RFC822/SMTP,
             T=DNS/RFC822/SMTP,
Mlocal,      P=/usr/bin/procmail, F=lsDFMAw5:/|@qSPfhn9, S=EnvFromL/HdrFromL, R=EnvToL/HdrToL,
             T=DNS/RFC822/X-Unix,
Mprog,       P=/usr/sbin/smrsh, F=lsDFMoqeu9, S=EnvFromL/HdrFromL, R=EnvToL/HdrToL, D=$z:/,
                T=X-Unix/X-Unix/X-Unix,
Mprocmail,   P=/usr/bin/procmail, F=DFMSPhnu9, S=EnvFromSMTP/HdrFromSMTP, R=EnvToSMTP/HdrFromSMTP,
             T=DNS/RFC822/X-Unix,
``` 

Lines beginning with an O character: a line as a configuration option.
The string following the O is the name of the option.

Lines beginning with an M character: a line defining a *delivery agent*,
a.k.a. *MDA* (*Mail Delivery Agent*). 
A delivery agent is a program that handles final local delivery to a 
user's mailbox (the `Mlocal`), handles delivery through a program 
(the `Mprog`), or `procmail(1)` program (the `Mprocmail`).
The *procmail* delivery agent allows additional processing for local or 
special delivery needs. 


### Network Forwarding

#### TCP/IP

The *sendmail* program has the *internal* ability to forward mail over 
only one kind of network, one that uses TCP/IP.  
Lines that instruct *sendmail* to do this have `[IPC]`
(may appear as `[TCP]`). 

```
# grep -v \# /etc/mail/sendmail.cf | grep '^M'
Msmtp,       P=[IPC], F=mDFMuX, S=EnvFromSMTP/HdrFromSMTP, R=EnvToSMTP, E=\r\n, L=990,
Mesmtp,      P=[IPC], F=mDFMuXa, S=EnvFromSMTP/HdrFromSMTP, R=EnvToSMTP, E=\r\n, L=990,
Msmtp8,      P=[IPC], F=mDFMuX8, S=EnvFromSMTP/HdrFromSMTP, R=EnvToSMTP, E=\r\n, L=990,
Mdsmtp,      P=[IPC], F=mDFMuXa%, S=EnvFromSMTP/HdrFromSMTP, R=EnvToSMTP, E=\r\n, L=990,
Mrelay,      P=[IPC], F=mDFMuXa8, S=EnvFromSMTP/HdrFromSMTP, R=MasqSMTP, E=\r\n, L=2040,
Mlocal,      P=/usr/bin/procmail, F=lsDFMAw5:/|@qSPfhn9, S=EnvFromL/HdrFromL, R=EnvToL/HdrToL,
Mprog,       P=/usr/sbin/smrsh, F=lsDFMoqeu9, S=EnvFromL/HdrFromL, R=EnvToL/HdrToL, D=$z:/,
Mprocmail,   P=/usr/bin/procmail, F=DFMSPhnu9, S=EnvFromSMTP/HdrFromSMTP, R=EnvToSMTP/HdrFromSMTP,
```

**Note:** The lines beginning with `Msmtp`, `Mesmtp`, `Msmtp8`, `Mpdsmtp`, 
`Mrelay` indicate the internal SMTP delivery agents.

The five SMTP delivery agents all use TCP to connect to other hosts.


### The sendmail Daemon


```
# grep -r sendmail /etc/rc*
/etc/rc.d/init.d/sendmail:# sendmail      This shell script takes care of starting and stopping
/etc/rc.d/init.d/sendmail:#               sendmail.
/etc/rc.d/init.d/sendmail:# processname: sendmail
/etc/rc.d/init.d/sendmail:# config: /etc/mail/sendmail.cf
/etc/rc.d/init.d/sendmail:# pidfile: /var/run/sendmail.pid
/etc/rc.d/init.d/sendmail:# Provides: sendmail MTA smtpdaemon
/etc/rc.d/init.d/sendmail:# Short-Description: start and stop sendmail
/etc/rc.d/init.d/sendmail:# Description: sendmail is a Mail Transport Agent (MTA)
/etc/rc.d/init.d/sendmail:# Source sendmail configureation.
/etc/rc.d/init.d/sendmail:if [ -f /etc/sysconfig/sendmail ]; then
/etc/rc.d/init.d/sendmail:    . /etc/sysconfig/sendmail
/etc/rc.d/init.d/sendmail:[ -x /usr/sbin/sendmail ] || exit 5
/etc/rc.d/init.d/sendmail:prog="sendmail"
/etc/rc.d/init.d/sendmail:    echo -n $"Package sendmail-cf is required to update configuration."
/etc/rc.d/init.d/sendmail:    daemon /usr/sbin/sendmail $([ "x$DAEMON" = xyes ] && echo -bd) \
/etc/rc.d/init.d/sendmail:    [ $RETVAL -eq 0 ] && touch /var/lock/subsys/sendmail
/etc/rc.d/init.d/sendmail:      daemon --check sm-client /usr/sbin/sendmail -L sm-msp-queue -Ac \
/etc/rc.d/init.d/sendmail:    killproc sendmail -HUP
/etc/rc.d/init.d/sendmail:    killproc sendmail
/etc/rc.d/init.d/sendmail:    [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/sendmail
/etc/rc.d/init.d/sendmail:status -p /var/run/sendmail.pid >/dev/null || status -p /var/run/sm-client.pid >/dev/null
/etc/rc.d/init.d/sendmail:      echo -n sendmail; status -p /var/run/sendmail.pid -l sendmail
```

```
# grep -r sendmail /etc/init.d/
/etc/init.d/sendmail:# sendmail      This shell script takes care of starting and stopping
/etc/init.d/sendmail:#               sendmail.
/etc/init.d/sendmail:# processname: sendmail
/etc/init.d/sendmail:# config: /etc/mail/sendmail.cf
/etc/init.d/sendmail:# pidfile: /var/run/sendmail.pid
/etc/init.d/sendmail:# Provides: sendmail MTA smtpdaemon
/etc/init.d/sendmail:# Short-Description: start and stop sendmail
/etc/init.d/sendmail:# Description: sendmail is a Mail Transport Agent (MTA)
/etc/init.d/sendmail:# Source sendmail configureation.
/etc/init.d/sendmail:if [ -f /etc/sysconfig/sendmail ]; then
/etc/init.d/sendmail:    . /etc/sysconfig/sendmail
/etc/init.d/sendmail:[ -x /usr/sbin/sendmail ] || exit 5
/etc/init.d/sendmail:prog="sendmail"
/etc/init.d/sendmail:   echo -n $"Package sendmail-cf is required to update configuration."
/etc/init.d/sendmail:    daemon /usr/sbin/sendmail $([ "x$DAEMON" = xyes ] && echo -bd) \
/etc/init.d/sendmail:    [ $RETVAL -eq 0 ] && touch /var/lock/subsys/sendmail
/etc/init.d/sendmail:   daemon --check sm-client /usr/sbin/sendmail -L sm-msp-queue -Ac \
/etc/init.d/sendmail:    killproc sendmail -HUP
/etc/init.d/sendmail:    killproc sendmail
/etc/init.d/sendmail:    [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/sendmail
/etc/init.d/sendmail:status -p /var/run/sendmail.pid >/dev/null || status -p /var/run/sm-client.pid >/dev/null
/etc/init.d/sendmail:   echo -n sendmail; status -p /var/run/sendmail.pid -l sendmail
```

### Bat Book (Fourth Edition): Chapter 16. Configuration File Overview 

> Chapter 16. Configuration File Overview
> 
> The *sendmail* configuration file (usually called *sendmail.cf*, but 
> for MSP submission, called *submit.cf*) provides all the central
> information that controls the sendmail program's behavior. 
> 
> [ . . . ]
> 
> The location of the *sendmail.cf* (and *submit.cf*) file is compiled
> into sendmail.  Beginning with V8.10, sendmail expects to find its
> configuration file in the */etc/mail* directory.
> 
> [ . . . ]
> 
> The configuration file is read and parsed by *sendmail* every time it
> starts up.  Because *sendmail* is run every time electronic mail is sent,
> its configuration file is designed to be easy for *sendmail* to parse
> rather than easy for humans to read.


> The listening daemon and the submission *msp sendmail* use two different
> configuration files (i.e., *sendmail.cf* and *submit.cf*).  Unless you
> specify a specific configuration file with `-C`, the `-Am` and `-Ac`
> switches determine which of the two configuration files is used.


From the `/usr/local/share/sendmail/cf/README` file:  

```
+----------------------------+
| MESSAGE SUBMISSION PROGRAM |
+----------------------------+
                                        
The purpose of the message submission program (MSP) is explained
in sendmail/SECURITY.  This section contains a list of caveats and
a few hints how for those who want to tweak the default configuration
for it (which is installed as submit.cf).

Notice: do not add options/features to submit.mc unless you are
absolutely sure you need them.  Options you may want to change
include:

- confTRUSTED_USERS, FEATURE(`use_ct_file'), and confCT_FILE for
  avoiding X-Authentication warnings.
- confTIME_ZONE to change it from the default `USE_TZ'.
- confDELIVERY_MODE is set to interactive in msp.m4 instead
  of the default background mode.
- FEATURE(stickyhost) and LOCAL_RELAY to send unqualified addresses
  to the LOCAL_RELAY instead of the default relay.
- confRAND_FILE if you use STARTTLS and sendmail is not compiled with
  the flag HASURANDOM.

[ . . . ]

Some things are not intended to work with the MSP.  These include
features that influence the delivery process (e.g., mailertable,
aliases), or those that are only important for a SMTP server (e.g.,
virtusertable, DaemonPortOptions, multiple queues).  Moreover,
relaxing certain restrictions (RestrictQueueRun, permissions on
queue directory) or adding features (e.g., enabling prog/file mailer)
can cause security problems.

Other things don't work well with the MSP and require tweaking or
workarounds.  For example, to allow for client authentication it
is not just sufficient to provide a client certificate and the
corresponding key, but it is also necessary to make the key group
(smmsp) readable and tell sendmail not to complain about that, i.e.,

        define(`confDONT_BLAME_SENDMAIL', `GroupReadableKeyFile')

If the MSP should actually use AUTH then the necessary data
should be placed in a map as explained in SMTP AUTHENTICATION:

FEATURE(`authinfo', `DATABASE_MAP_TYPE /etc/mail/msp-authinfo')

/etc/mail/msp-authinfo should contain an entry like:

        AuthInfo:127.0.0.1      "U:smmsp" "P:secret" "M:DIGEST-MD5"

The file and the map created by makemap should be owned by smmsp,
its group should be smmsp, and it should have mode 640.  The database
used by the MTA for AUTH must have a corresponding entry.
Additionally the MTA must trust this authentication data so the AUTH=
part will be relayed on to the next hop.  This can be achieved by
adding the following to your sendmail.mc file:

        LOCAL_RULESETS
        SLocal_trust_auth
        R$*     $: $&{auth_authen}
        Rsmmsp  $# OK

[ . . . ]

feature/msp.m4 defines almost all settings for the MSP.  Most of
those should not be changed at all.  Some of the features and options
can be overridden if really necessary.  It is a bit tricky to do
this, because it depends on the actual way the option is defined
in feature/msp.m4.  If it is directly defined (i.e., define()) then
the modified value must be defined after

        FEATURE(`msp')

If it is conditionally defined (i.e., ifdef()) then the desired
value must be defined before the FEATURE line in the .mc file.
To see how the options are defined read feature/msp.m4.
```

### Bat Book (Fourth Edition): Chapter 17. Configure sendmail.cf with m4 

> The MAILER definition must always be last in your *mc* configuration file.
> (Although it can and probably should be followed by rule set declarations,
> as for example, LOCAL_RULESET_0).  If you include MAILER definitions for
> procmail(1), maildrop(1), or uucp, those definitions must always follow
> the definition for `smtp`.  Any modification of a MAILER definition
> (as, for example, with LOCAL_MAILER_MAX) must precede that MAILER definition.


From **sendmail-source-tree/doc/op/op.txt**:    
(On FreeBSD 13.1: `/usr/local/share/doc/sendmail/op.txt`)    
(On Linux distributions: `/usr/share/doc/sendmail-X.XX.X` (e.g. `/usr/share/doc/sendmail-8.17.1`)


```
      m   This mailer can send to multiple users on the same
          host in one transaction.  When a $u macro occurs
          in the argv part of the mailer definition, that
          field will be repeated as necessary for all quali-
          fying users.  Removing this flag can defeat dupli-
          cate  suppression on a remote site as each recipi-
          ent is sent in a separate transaction.

      D*  This mailer wants a "Date:" header line.

      F*  This mailer wants a "From:" header line.
 
      u   Upper case should be preserved in user names for
          this mailer.  Standards require preservation of
          case in the local part of addresses, except for
          those address for which your system accepts  re-
          sponsibility.   RFC 2142 provides a long list of
          addresses which should be case insensitive.   If
          you use this flag, you may be violating RFC 2142.
          Note that postmaster is always treated as a case
          insensitive address regardless of this flag.

      X   This mailer wants to use the hidden dot algorithm
          as specified in RFC 821; basically, any line be-
          ginning with a  dot  will have an extra  dot
          prepended (to be stripped at the other end).  This
          insures that lines in the message containing a dot
          will not terminate the message prematurely.
 
      a   Run Extended SMTP  (ESMTP)  protocol (defined in
          RFCs 1869, 1652, and 1870).  This flag defaults on
          if the SMTP greeting message includes the word
          "ESMTP".

      k   Normally when sendmail connects to a host via
          SMTP, it checks to make sure that this isn't acci-
          dentally the same host name as might happen if
          sendmail is misconfigured or if a long-haul net-
          work interface is set in loopback mode.  This flag
          disables the loopback check.  It should only be
          used under very unusual circumstances.
```


## Essential System Administration, 3rd Edition

By Æleen Frisch    
O'Reilly Media, Inc.    
August 2002  


### Chapter 9.4. Configuring the Transport Agent (The whole chapter)

Also, about the `delay_checks` feature:  

The entries in the access database are used by three distinct sendmail 
message examination phases. [1] 

[1] To be more technically accurate, the entries are used by three 
different sendmail "rulesets": `check_relay`, `check_mail`, and `check_rcpt`.

Messages are checked first for allowed relaying (based on the client 
hostname and address), then for an allowed sender, and finally for an 
allowed recipient.  If a message is rejected in one phase, it cannot be 
restored later.  This means that the preceding syntax does not allow for 
certain kinds of exceptions to be defined.  For example, you cannot allow 
email to a specific user always to get through regardless of its origin 
because the local addresses checks are downstream from the message 
source checks.

However, you can use the `delay_checks` feature to reverse the order of 
the three test phases.  In this mode, recipient-level access controls 
have the highest precedence, rather than the lowest.


## The sendmail cf/README file and Documentation (doc Directory)

* Location of the *doc* directory on FreeBSD 13.1 is
`/usr/local/share/doc/sendmail`: 

```
$ ls /usr/local/share/doc/sendmail/
DEVTOOLS        MAIL.LOCAL      PGPKEYS         SECURITY        TRACEFLAGS
KNOWNBUGS       op.ps           README          SENDMAIL        TUNING
LICENSE         op.txt          RELEASE_NOTES   SMRSH
```

The *op* document is the *sendmail* "INSTALLATION AND OPERATION GUIDE".
That guide is supplied as a text file (*op.txt*) and as a PostScript
document (*op.ps*).  

* Location on FreeBSD 13.1 with *sendmail* 8.17.1:   
`/usr/local/share/sendmail/cf/README`  

* Location on RHEL Server release 6.8 (Santiago) 
with *sendmail* 8.14.4:   
`/usr/share/sendmail-cf/README`


On FreeBSD 13, the man page for `sendmail(8)` under SEE ALSO section lists *Sendmail Installation and Operation Guide, No. 8, SMM*.

```
$ man sendmail

. . . 

  SEE ALSO
         mail(1), syslog(3), aliases(5), mailaddr(7), mail.local(8), rc(8),
         rmail(8)
  
         DARPA Internet Request For Comments RFC819, RFC821, RFC822.  Sendmail
         Installation and Operation Guide, No. 8, SMM.
```

NOTE: *SMM* stands for UNIX *System Manager's Manual*.


* Sendmail Installation and Operation Guide - Eric Allman, Claus Assman, Gregory Neil Shapiro -- PostScript version - Location on FreeBSD 13.1:
`/usr/local/share/doc/sendmail/op.ps`

* Sendmail Installation and Operation Guide - Eric Allman, Claus Assmann, Gregory Neil Shapiro - Plain text version -- Location on FreeBSD 13.1:
`/usr/local/share/doc/sendmail/op.txt`


### The FEATURES Section - The require_rdns Feature

```
Available features are:

[ . . . ]

require_rdns    Reject mail from connecting SMTP clients without proper
                rDNS (reverse DNS), functional gethostbyaddr() resolution.
                Note: this feature will cause false positives, i.e., there
                are legitimate MTAs that do not have proper DNS entries.
                Rejecting mails from those MTAs is a local policy decision.

[ . . . ]

                EXCEPTIONS:

                Exceptions based on access entries are discussed below.
                Any IP address matched using $=R (the "relay-domains" file)
                is excepted from the rules.  Since we have explicitly
                allowed relaying for this host, based on IP address, we
                ignore the rDNS failure.

[ . . . ] 
                If `delay_checks' is in effect (recommended), then any
                sender who has authenticated is also excepted from the
                restrictions.  This happens because the rules produced by
                this FEATURE() will not be applied to authenticated senders
                (assuming `delay_checks').

                ACCESS MAP ENTRIES:

                Entries such as
                        Connect:1.2.3.4         OK
                        Connect:1.2             RELAY
                will whitelist IP address 1.2.3.4, so that the rDNS
                blocking does apply to that IP address

                Entries such as
                        Connect:1.2.3.4         REJECT
                will have the effect of forcing a temporary failure for
                that address to be treated as a permanent failure.
```


### The "Delay all checks" Section of the sendmail cf/README file


```
Delay all checks
----------------

By using FEATURE(`delay_checks') the rulesets check_mail and check_relay
will not be called when a client connects or issues a MAIL command,
respectively.  Instead, those rulesets will be called by the check_rcpt
ruleset; they will be skipped if a sender has been authenticated using
a "trusted" mechanism, i.e., one that is defined via TRUST_AUTH_MECH().
If check_mail returns an error then the RCPT TO command will be rejected
with that error.  If it returns some other result starting with $# then
check_relay will be skipped.  If the sender address (or a part of it) is
listed in the access map and it has a RHS of OK or RELAY, then check_relay
will be skipped.  This has an interesting side effect: if your domain is
my.domain and you have

        my.domain       RELAY

in the access map, then any e-mail with a sender address of
<user@my.domain> will not be rejected by check_relay even though
it would match the hostname or IP address.  This allows spammers
to get around DNS based blacklist by faking the sender address.  To
avoid this problem you have to use tagged entries:

        To:my.domain            RELAY
        Connect:my.domain       RELAY

if you need those entries at all (class {R} may take care of them).
```


### The CONNECTION CONTROL Section of the sendmail cf/README file
 
About the order of the `access_db`, `delay_checks`, `ratecontrol` 
and `conncontrol` features in the mc file; that is: 

`access_db`    
`delay_checks`   
`ratecontrol`   
`conncontrol`   


Excerpt from the cf/README file:

```
The features ratecontrol and conncontrol allow to establish connection
limits per client IP address or net.  These features can limit the
rate of connections (connections per time unit) or the number of
incoming SMTP connections, respectively.  If enabled, appropriate
rulesets are called at the end of check_relay, i.e., after DNS
blacklists and generic access_db operations.  The features require 
FEATURE(`access_db') to be listed earlier in the mc file.

Note: FEATURE(`delay_checks') delays those connection control checks
after a recipient address has been received, hence making these
connection control features less useful.  To run the checks as early
as possible, specify the parameter `nodelay', e.g.,

        FEATURE(`ratecontrol', `nodelay')

In that case, FEATURE(`delay_checks') has no effect on connection
control (and it must be specified earlier in the mc file).

An optional second argument `terminate' specifies whether the
rulesets should return the error code 421 which will cause
sendmail to terminate the session with that error if it is
returned from check_relay, i.e., not delayed as explained in
the previous paragraph.  Example:

        FEATURE(`ratecontrol', `nodelay', `terminate')
```


## Submission (Sendmail TLS SASL SMTP-AUTH Port 465 Port 587)

[Authentication succeeds, but sending still fails](https://serverfault.com/questions/880547/authentication-succeeds-but-sending-still-fails)


The locally-invoked sendmail on the mail server:

```
# sendmail -O LogLevel=14 -bs -Am
220 test.host.domain ESMTP mailer ready at Wed, 26 Oct 2022 20:03:40 -0700
HELO test.host.domain
250 test.host.domain Hello root@localhost, pleased to meet you
EHLO test.host.domain
250-test.host.domain Hello root@localhost, pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-STARTTLS
250-DELIVERBY
250 HELP
MAIL From:<dusko@test.host.domain>
250 2.1.0 <dusko@test.host.domain>... Sender ok
RCPT To:<dusko@host.domain.
250 2.1.5 <dusko@host.domain>... Recipient ok
DATA
354 Enter mail, end with "." on a line by itself
From: Dusko <dusko@foobar.com>
To: <dusko@host.domain> Dusko Pijetlovic
Subject: Test

Testing.
.
250 2.0.0 29S4ceAq025509 Message accepted for delivery
QUIT
221 2.0.0 test.host.domain closing connection
```


[Sendmail TLS SASL SMTP-AUTH](https://slackwiki.com/Sendmail_TLS_SASL_SMTP-AUTH)

The ```define(`confAUTH_OPTIONS', `A p y')dnl``` configures sendmail to:

* `A` is a workaround for broken MTAs that do not implement RFC 2554.
* The `p` option tells sendmail: "don't permit mechanisms susceptible to 
  simple passive attack (e.g., `LOGIN`, `PLAIN`), unless a security layer
  (think TLS tunnel) is active."
* The `y` option prohibits anonymous logins.

Take note that this will only allow LOGIN/PLAIN SMTP-AUTH after encryption
has been established in a TLS tunnel.  Allowing both TLS and non-TLS 
PLAIN/LOGIN SMTP-AUTH is left as an exercise to the reader. 


[How to configure sendmail for relaying mail over port 587 using authentication](https://access.redhat.com/solutions/60803)

What is: `sendmail -Am -v -t` 



[SMTP AUTH for sendmail 8.10: Realms and Examples](https://www.sendmail.org/~ca/email/authrealms.html)  
Last Update 2000-06-24  

**PLAIN**    
According to [RFC 2595](https://www.rfc-editor.org/rfc/rfc2595) the client must send: [[authorize-id]](https://www.sendmail.org/~ca/email/auth.html#userid) \0 [[authenticate-id]](https://www.sendmail.org/~ca/email/auth.html#authid) \0 password. [pwcheck_method](https://www.sendmail.org/~ca/email/authrealms.html#authpwcheck_method) has been set to [sasldb](https://www.sendmail.org/~ca/email/authrealms.html#PWCHECK_SASLDB) for the following example.

```
>>> AUTH PLAIN dGVzdAB0ZXN0QHdpei5leGFtcGxlLmNvbQB0RXN0NDI=
235 2.0.0 OK Authenticated
```

[Decoded:](https://www.sendmail.org/~ca/email/prgs/ed64.c)

```
test\000test@wiz.example.com\000tEst42
```

With [patch for lib/checkpw.c](https://www.sendmail.org/~ca/email/patches/cyrus-sasl-1.5.15-lib-checkpw.c.p1) or a [pwcheck_method](https://www.sendmail.org/~ca/email/authrealms.html#authpwcheck_method) that doesn't support realms:

```
>>> AUTH PLAIN dGVzdAB0ZXN0AHRFc3Q0Mg==
```

[Decoded:](https://www.sendmail.org/~ca/email/prgs/ed64.c)

```
test\000test\000tEst42
```

**LOGIN**   

[pwcheck_method](https://www.sendmail.org/~ca/email/authrealms.html#authpwcheck_method) has been set to [sasldb](https://www.sendmail.org/~ca/email/authrealms.html#PWCHECK_SASLDB) for the following example. 

```
>>> AUTH LOGIN
334 VXNlcm5hbWU6
>>> dGVzdEB3aXouZXhhbXBsZS5jb20=
334 UGFzc3dvcmQ6
>>> dEVzdDQy
235 2.0.0 OK Authenticated
```

[Decoded:](https://www.sendmail.org/~ca/email/prgs/ed64.c)

```
test
tEst42
```


[What is the difference between using `:plain` vs `:login` in active mailer smtp settings?](https://stackoverflow.com/questions/59464979/what-is-the-difference-between-using-plain-vs-login-in-active-mailer-smtp)

> Long story short as you are using TLS your credentials are safe as they 
> are being exchanged on an encrypted connection.
> 
> According to ActionMailer documentation [here](https://api.rubyonrails.org/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Configuration+options) irrespective of authentication `:plain` or `:login` the password is always `Base64` encoded.  The problem with Base64 encoding is that it can be easily decoded by anybody eavesdropping in on the SMTP communication. So both of these authentication mechanisms are really the same in terms of security.
> 
> However as you are using `TLS` the connection is encrypted and the Base64
> credentials are sent over this encrypted connection making it secure.
> If you were not using TLS then it would be better to use `:cram_md5` 
> instead of `:login` or `:plain` to secure the credentials.
> - - -
> This answer is correct but incomplete since OP also asked the difference
> between PLAIN and LOGIN. PLAIN sends both login and password in the 
> same Base64-encoded string, whereas LOGIN sends them separately. 




* [Simple Troubleshooting For SMTP Via Telnet And Openssl](https://wiki.zimbra.com/wiki/Simple_Troubleshooting_For_SMTP_Via_Telnet_And_Openssl)


## SASL

On the mail server:

```
# man -k sasl
pluginviewer         (8)  - list loadable SASL plugins and their properties
saslauthd            (8)  - sasl authentication server
saslauthd_selinux    (8)  - Security Enhanced Linux Policy for the saslauthd processes
sasldblistusers2     (8)  - list users in sasldb
saslpasswd2          (8)  - set a user's sasl password
testsaslauthd        (8)  - test utility for the SASL authentication server
```

List `auxprop` mechanisms and plugins:

```
# pluginviewer -a
Installed auxprop mechanisms are:
sasldb
List of auxprop plugins follows
Plugin "sasldb" ,       API version: 4
        supports store: yes
```


List server authentication (SASL) plugins:

```
# pluginviewer -s
Installed SASL (server side) mechanisms are:
ANONYMOUS GSSAPI PLAIN LOGIN EXTERNAL
List of server plugins follows
Plugin "anonymous" [loaded],    API version: 4
        SASL mechanism: ANONYMOUS, best SSF: 0, supports setpass: no
        security flags: NO_PLAINTEXT
        features: WANT_CLIENT_FIRST
Plugin "gssapiv2" [loaded],     API version: 4
        SASL mechanism: GSSAPI, best SSF: 56, supports setpass: no
        security flags: NO_ANONYMOUS|NO_PLAINTEXT|NO_ACTIVE|PASS_CREDENTIALS|MUTUAL_AUTH
        features: WANT_CLIENT_FIRST|PROXY_AUTHENTICATION
Plugin "plain" [loaded],        API version: 4
        SASL mechanism: PLAIN, best SSF: 0, supports setpass: no
        security flags: NO_ANONYMOUS
        features: WANT_CLIENT_FIRST|PROXY_AUTHENTICATION
Plugin "login" [loaded],        API version: 4
        SASL mechanism: LOGIN, best SSF: 0, supports setpass: no
        security flags: NO_ANONYMOUS
        features:
```

Similarly, list client authentication (SASL) plugins:

```
# pluginviewer -c
Installed SASL (client side) mechanisms are:
ANONYMOUS GSSAPI PLAIN LOGIN EXTERNAL
List of client plugins follows
[ . . . ]
```


The directory where the Cyrus SASL library package installed its plug-ins:

```
# ls -ld /usr/lib64/sasl2/
drwxr-xr-x. 2 root root 4096 May 17  2015 /usr/lib64/sasl2/
```

```
# ls -lh /usr/lib64/sasl2/
total 116K
lrwxrwxrwx 1 root root  22 May 17  2015 libanonymous.so -> libanonymous.so.2.0.23
lrwxrwxrwx 1 root root  22 May 17  2015 libanonymous.so.2 -> libanonymous.so.2.0.23
-rwxr-xr-x 1 root root 19K Feb 27  2015 libanonymous.so.2.0.23
lrwxrwxrwx 1 root root  21 May 17  2015 libgssapiv2.so -> libgssapiv2.so.2.0.23
lrwxrwxrwx 1 root root  21 May 17  2015 libgssapiv2.so.2 -> libgssapiv2.so.2.0.23
-rwxr-xr-x 1 root root 31K Feb 27  2015 libgssapiv2.so.2.0.23
lrwxrwxrwx 1 root root  18 May 17  2015 liblogin.so -> liblogin.so.2.0.23
lrwxrwxrwx 1 root root  18 May 17  2015 liblogin.so.2 -> liblogin.so.2.0.23
-rwxr-xr-x 1 root root 19K Feb 27  2015 liblogin.so.2.0.23
lrwxrwxrwx 1 root root  18 May 17  2015 libplain.so -> libplain.so.2.0.23
lrwxrwxrwx 1 root root  18 May 17  2015 libplain.so.2 -> libplain.so.2.0.23
-rwxr-xr-x 1 root root 19K Feb 27  2015 libplain.so.2.0.23
lrwxrwxrwx 1 root root  19 May 17  2015 libsasldb.so -> libsasldb.so.2.0.23
lrwxrwxrwx 1 root root  19 May 17  2015 libsasldb.so.2 -> libsasldb.so.2.0.23
-rwxr-xr-x 1 root root 23K Feb 27  2015 libsasldb.so.2.0.23
```

### Check and Test SASL Support in sendmail

There are two concepts to SASL and its use: authorization and authentication.

*Authorization* refers to a user's permission to perform certain actions.
One form of authorization, for example, might be to allow a user to relay
mail through your mail hub machine.  In general, authorization is 
associated with a user's identifier (`userid`), which may be the username
or something more complex.

*Authentication* refers to the validation of a user or machine's identity.
One form of authentication, for example, might be the recognition that 
a laptop is a company-owned machine. Authentication is communicated inside
credentials and is associated with a client's identifier (`authid`).

- - -

The `-bs` tells *sendmail* to speak SMTP on its standard input.
The `-Am` tells *sendmail* to use its server configuration file
(not *submit.cf*), even though it is running in mail-submission mode. 

Sendmail might not advertise it. 

```
# sendmail -bs -Am
220 test.host.domain ESMTP mailer ready at Wed, 26 Oct 2022 20:07:35 -0700
helo test.host.domain 
250 test.host.domain Hello root@localhost, pleased to meet you
ehlo test.host.domain 
250-test.host.domain Hello root@localhost, pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-STARTTLS
250-DELIVERBY
250 HELP
quit
221 2.0.0 test.host.domain closing connection
```

Here, the `AUTH` SMTP keyword doesn't appear. 

In that case, try increasing the log level, and checking the log file.


```
# sendmail -OLogLevel=14 -bs -Am
220 test.host.domain ESMTP mailer ready at Wed, 26 Oct 2022 20:08:32 -0700
ehlo test.host.domain 
250-test.host.domain Hello root@localhost, pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-STARTTLS
250-DELIVERBY
250 HELP
quit
221 2.0.0 test.host.domain closing connection
```

```
# grep 'Oct 26 20:08:32' /var/log/maillog 
Oct 26 20:08:32 test sendmail[30261]: STARTTLS=server, Diffie-Hellman init, key=1024 bit (1)
Oct 26 20:08:32 test sendmail[30261]: STARTTLS=server, init=1
Oct 26 20:08:32 test sendmail[30261]: AUTH: available mech=GSSAPI, allowed mech=LOGIN PLAIN
[ . . . ]
```

The log excerpt shows the `AUTH` SMTP keyword, indicating that this
site supports SASL authentication and two modes of authentication,
LOGIN and PLAIN. 

The *saslpasswd2* program is installed in the */usr/sbin* directory and 
is used to set up user accounts that exist only for email.

These user accounts and passwords are stored in the *sasldb* database.

```
# command -v saslpasswd2; type -a saslpasswd2; \
 whereis saslpasswd2; which saslpasswd2 
/usr/sbin/saslpasswd2
saslpasswd2 is /usr/sbin/saslpasswd2
saslpasswd2: /usr/sbin/saslpasswd2 /usr/share/man/man8/saslpasswd2.8.gz
/usr/sbin/saslpasswd2
```

The *sasldb* database provides the means to set up accounts for email 
that are separate from the user accounts that normally exist on your 
machine.  

If you wish to use only existing accounts, you need to install
*Sendmail.conf*.

At a minimum, one line should appear in that file and that line should 
indicate your preferred password verification method.

```
# cat /etc/sasl2/Sendmail.conf 
pwcheck_method:saslauthd
```

In this example, the password verification method is `saslauthd`, 
which means:  Connect to the *saslauthd(8)* program for all authentication.  

On this machine, that program is installed in */usr/sbin*.

**Note:** Instead of `saslauthd`, you could've used `pwcheck`; that is,
`pwcheck` is a synonym for `saslauthd`.  


```
# command -v saslauthd; type -a saslauthd; \
 whereis saslauthd; which saslauthd
/usr/sbin/saslauthd
saslauthd is /usr/sbin/saslauthd
saslauthd: /usr/sbin/saslauthd /usr/share/man/man8/saslauthd.8.gz
/usr/sbin/saslauthd
```

If you use it, the *saslauthd(8)* program must be started 
as a daemon automatically. 


### AUTH Mechanisms that Your Server Requires

```
# grep -r -i AUTH /etc/mail/ | grep -i mechanisms | grep -v \# 
/etc/mail/sendmail.cf:O AuthMechanisms=LOGIN PLAIN
/etc/mail/sendmail.mc:define(`confAUTH_MECHANISMS', `LOGIN PLAIN')dnl
```

This only defines the mechanisms that will be required if `AUTH` is 
required for inbound connections.  Whether or not connections must be 
authenticated is determined by the setting of the `DaemonOptions` option.

The class `$={TrustAuthMech}` contains a list of authentication
mechanisms that allow relaying.  It must contain a subset, or a
matching set of the list of all authentication mechanisms defined
with the `AuthMechanisms` option. For example, on this site:

```
# grep -r TrustAuthMech /etc/mail/
/etc/mail/sendmail.cf:C{TrustAuthMech}LOGIN PLAIN
/etc/mail/sendmail.cf:R$* $| $={TrustAuthMech}  $# RELAY
/etc/mail/submit.cf:R$* $| $={TrustAuthMech}    $# RELAY
```

```
# grep -r TRUST_AUTH_MECH /etc/mail/
/etc/mail/sendmail.mc:TRUST_AUTH_MECH(`LOGIN PLAIN')dnl
```

Here, *sendmail* will authenticate using LOGIN and PLAIN mechanism, and 
that authentication (if successful) will provide an authorization to relay.


### The AuthOptions Option 

The `AuthOptions` is used to specify how authentication should be handled
by your server (or client).  For example:

```
# grep -r AUTH_OPTIONS /etc/mail/
/etc/mail/sendmail.mc:define(`confAUTH_OPTIONS', `A p y')dnl
```

```
# grep -r AuthOptions /etc/mail/ | grep -v \#
/etc/mail/sendmail.cf:O AuthOptions=A p y
```

Each character sets a single tuning parameter.  If more than one
character is listed, each character must be separated from the next 
by a space.

The `A` character:  Use the `AUTH=` parameter from the `MAIL From:`
command only when authentication succeeds.  This character can be
specified as a workaround for broken mail transfer agents (MTAs) that
do not correctly implement RFC2554. (Client only)

The `p` character:  Don't permit mechanisms to be used if they are
susceptible to simple passive attack (that is, disallow use of PLAIN and
LOGIN), unless a security layer is already active (as, for example,
provided by STARTTLS). (Server only) 

The `y` character:  Don't permit the use of any mechanism that allows
anonymous login. (Server only)


### DaemonPortOptions 

The *sendmail* program can run in two connection modes: as a **daemon**, *accepting connections*; or as a **client**, *making connections*.
*Each mode* can connect to a **port** to do its work.
The options for the *client port* are set by the **`ClientPortOptions`** option.
The options for the *daemon* are set by the **`DaemonPortOptions`** option.

This `DaemonPortOptions` option is used to customize the daemon's SMTP service.
The form for this option is as follows:

```O DaemonPortOptions=pair,pair,pair```              <- configuration file (V8.7 and later)   
```-ODaemonPortOptions=pair,pair,pair```              <- command line (V8.7 and later)    
```define(`confDAEMON_OPTIONS',``pair,pair,pair'')``` <- mc configuration (V8.7 and later)   
```DAEMON_OPTIONS(``pair,pair,pair'')```              <- mc configuration (V8.11 and later)   
```OOpair,pair,pair```                                <- configuration file (deprecated)   
```-oOpair,pair,pair```                               <- command line (deprecated)   


The `DaemonPortOptions` option is set to a comma-separated list of pairs,
where each pair is of the form:

`key=value`

**Note:** When the argument to an m4 define command contains one or more 
commas, that argument should be enclosed in two single quotes.

As of V8.14.1, all keys are case-sensitive. **<sup>[[1]](#footnotes)</sup>**

That is, `Children` differs from `children`.  Prior to V8.7, an unknown 
key was silently ignored.


With V8.8 and later, an unknown key is still ignored but now causes the 
following error to be printed:

`DaemonPortOptions unknown parameter "key"`

Beginning with V8.10, you can declare multiple `DaemonPortOptions` options,
where each causes the single listening daemon to accept connections over
multiple sockets.

The list of some keys (DaemonPortOptions option keywords):

```
+--------+---------------------------+-------------------------------------------------+
| Key    |                           | Meaning                                         |
+--------+---------------------------+-------------------------------------------------+
| Addr   | DaemonPortOptions=Addr=   | The network to accept connection from           |
+--------+---------------------------+-------------------------------------------------+
| Name   | DaemonPortOptions=Name=   | User-definable name for the daemon              | 
+--------+---------------------------+-------------------------------------------------+
| Port   | DaemonPortOptions=Port=   | The port number on which sendmail should listen |
+--------+---------------------------+-------------------------------------------------+
| Modify | DaemonPortOptions=Modify= | Modify selected characteristics of the port     |
+--------+---------------------------+-------------------------------------------------+
```

Only the first character in each key is recognized so a succinct 
declaration such as the following can be used to change the port 
used by the daemon:

`O DaemonPortOptions=P=26,A=our-addr  # Only listen for local mail on nonstandard port 26`


### DaemonPortOptions=Modify=

Beginning with V8.10 *sendmail*, you can modify selected characteristics
of the port.  Modification is done by listing selected letters following
the `Modify=` (or `M=`).

Some `Modify=` port option letters are listed in the tabel below.

Note that the letters are case-sensitive.  Also note only `h`, `S`, and
`A` are valid for the `ClientPortOptions` option.


```
+--------+-----------------------------------------------------------------------------------+
| Letter | Meaning                                                                           |
+--------+-----------------------------------------------------------------------------------+
| a      | Require authentication with the AUTH ESMTP keyword before continuing with         | 
|        | the connection.  Do not use this setting on a public MTA that listens on port 25! |
+--------+-----------------------------------------------------------------------------------+
| s      | Use SMTP over SSL                                                                 | 
+--------+-----------------------------------------------------------------------------------+ 
| A      | Disable authentication - overrides the a modifier above.                          |
+--------+-----------------------------------------------------------------------------------+ 
| E      | Disallow use of the ETRN command as per RFC2476.                                  |
+--------+-----------------------------------------------------------------------------------+ 
```

The `DaemonPortOptions` option is not safe.  If specified from the command
line, it can cause sendmail to relinquish its special privileges.


```
# grep -r DaemonPortOptions /etc/mail/ 
/etc/mail/sendmail.cf:O DaemonPortOptions=Name=MTA, M=A
/etc/mail/sendmail.cf:O DaemonPortOptions=Port=465, Name=MTASSL, M=s a
/etc/mail/sendmail.cf:O DaemonPortOptions=Port=587, Name=MSA, M=a
/etc/mail/sendmail.cf:O DaemonPortOptions=Addr=127.0.0.1, Port=10026
/etc/mail/submit.cf:O DaemonPortOptions=Name=NoMTA, Addr=127.0.0.1, M=E
```


The `M=a` for the `DaemonPortOptions` option determines whether the 
connection must be authenticated for all connections, or whether only
a sender that tries to relay must be authenticated.  With a lowercase `a`,
that is `M=a`, *sendmail* requires connection authentication for all inbound
connections to the server.  To turn that off and only require the sender
to authenticate, use `M=A`. 

With the `M=A` setting, you can screen individual users for relaying
permission using rule sets.  If your server receives mail from the
Internet, you must use `M=A` instead of `M=a`.


### DaemonPortOptions=Name=

Because *sendmail* can listen on different ports simultaneously, and can 
bind to specific interfaces, it is desirable that each such instance be 
given a distinctive name.  When listening on port 25 for inbound mail,
*sendmail* is functioning as an MTA.  When listening on port 587 for
locally submitted mail, *sendmail* is functioning as an MSA.

This `DaemonPortOptions=Name=` is used to set the name that will be
reported with the `daemon=` syslog equate ([daemon=](#daemon-syslog-equate))
and that is placed into a `${daemon_name}` ([daemon_name macro](#daemon_name-macro))
or `${client_name}` ([client_name macro](#client_name-macro)).

Many errors in connections now produce error messages that include
the expression:

`daemon name`

to help clarify which port and role ran into a problem.

Instruct daemon not to listen on port 587 for local MSA:

```
# grep -B1 DAEMON_OPTIONS /etc/mail/sendmail.mc
FEATURE(`no_default_msa')dnl
DAEMON_OPTIONS(`Name=MTA, M=A')dnl
DAEMON_OPTIONS(`Port=465, Name=MTASSL, M=s a')dnl
DAEMON_OPTIONS(`Port=587, Name=MSA, M=a')dnl
DAEMON_OPTIONS(`Addr=127.0.0.1, Port=10026')dnl
```

### DaemonPortOptions=Port=

The `Port` key is used to specify the service port on which the daemon
should listen.  This is normally the port called `smtp`, as defined in
the */etc/services* file.  The value can be either a services string
(such as `smtp`) or a number (such as 25).  This key is useful inside
domains that are protected by a firewall.  By specifying a nonstandard
port, the firewall can communicate in a more secure manner with the
internal network while still accepting mail on the normal port from
the outside world:

```
O DaemonPortOptions=Port=26
```

If this pair is missing, the port defaults to `smtp`.

As of V8.10, *sendmail* also obeys RFC2476 and (by default) listens on
port 587 for the local submission of mail (unless turned off with the
`FEATURE(no_default_msa)`).



## SASL and Rule Sets


The SMTP `AUTH` extension, enabled by SASL, allows client machines to
relay mail through the authentication-checking server.  This mechanism is
especially useful for roaming users whose laptops seldom have a constant
IP number or hostname assigned.  A special rule set called `trust_auth`, 
found inside the *sendmail* configuration file, does the actual checking.
This rule set decides whether the client's authentication identifier
(`authid`) is trusted to act as (proxy for) the requested authorization
identity (`userid`).  It allows `authid` to act for `userid` if both are
recognized, and disallows that action if the authentication fails.

```
# grep -r trust_auth /etc/mail/ | grep -v \#
/etc/mail/sendmail.cf:SLocal_trust_auth
/etc/mail/sendmail.cf:Strust_auth
/etc/mail/sendmail.cf:R$* $| $*         $: $1 $| $>"Local_trust_auth" $2
/etc/mail/submit.cf:SLocal_trust_auth
/etc/mail/submit.cf:Strust_auth
/etc/mail/submit.cf:R$* $| $*           $: $1 $| $>"Local_trust_auth" $2
```

Another rule set, called `Local_trust_auth`, is available if you wish to
supplement the basic test provided by `trust_auth`.  The `Local_trust_auth`
rule set can return the `#error` delivery agent to disallow proxying, or it
can return OK to allow proxying.
   
Within the `Local_trust_auth` rule set you can use three *sendmail* macros
(in addition to the other normal sendmail macros). They are:

`{auth_authen}`: The client's authentication credentials as determined by
the authentication process.

`{auth_author}`: The authorization identity as set by issuance of the
`SMTP AUTH=` parameter.  This could be either a *username* or a
*user@host.domain* address.

`{auth_type}`: The mechanism used for authentication, such as LOGIN and PLAIN.

```
# grep -r auth_authen /etc/mail/ | grep -v \#
/etc/mail/sendmail.cf:O Milter.macros.envfrom=i, {auth_type}, {auth_authen}, {auth_ssf}, {auth_author}, {mail_mailer}, {mail_host}, {mail_addr}
/etc/mail/sendmail.cf:R$* $| $&{auth_authen}            $@ identical
/etc/mail/sendmail.cf:R$* $| <$&{auth_authen}>  $@ identical
/etc/mail/submit.cf:R$* $| $&{auth_authen}              $@ identical
/etc/mail/submit.cf:R$* $| <$&{auth_authen}>    $@ identical
```

```
# grep -r auth_author /etc/mail/ | grep -v \#
/etc/mail/sendmail.cf:O Milter.macros.envfrom=i, {auth_type}, {auth_authen}, {auth_ssf}, {auth_author}, {mail_mailer}, {mail_host}, {mail_addr}
```

```
# grep -r auth_type /etc/mail/ | grep -v \#
/etc/mail/sendmail.cf:O Milter.macros.envfrom=i, {auth_type}, {auth_authen}, {auth_ssf}, {auth_author}, {mail_mailer}, {mail_host}, {mail_addr}
/etc/mail/sendmail.cf:  $.$?{auth_type}(authenticated$?{auth_ssf} bits=${auth_ssf}$.)
/etc/mail/sendmail.cf:R$*                       $: $1 $| $>"Local_Relay_Auth" $&{auth_type}
/etc/mail/sendmail.cf:R$* $| $*         $: $1 $| $&{auth_type}
/etc/mail/sendmail.cf:R$*                       $: $&{auth_type} $| $1
/etc/mail/submit.cf:    $.$?{auth_type}(authenticated$?{auth_ssf} bits=${auth_ssf}$.)
/etc/mail/submit.cf:R$*                 $: $1 $| $>"Local_Relay_Auth" $&{auth_type}
/etc/mail/submit.cf:R$* $| $*           $: $1 $| $&{auth_type}
/etc/mail/submit.cf:R$*                 $: $&{auth_type} $| $1
```


## daemon Syslog Equate

**daemon=**

The name of the sender's daemon syslog equate   

When *sendmail* logs the sender of a message it includes a *syslog* equate
that shows the name of the daemon that handled the transaction.
Daemons are named with the `DaemonPortOptions` option's `Name` pair
(`DaemonPortOptions=Name=`). 

For example:

`O DaemonPortOptions=Name=MTA`

Whenever *sendmail* logs the sender of a message (with `from=`) and when
the message was handled by a daemon (not standard input), this `daemon=`
*syslog* equate will show the daemon's name.


## daemon_name Macro 

**${daemon_name}**

Listening daemon's name 

The `${daemon_name}` macro contains the value of the
`DaemonPortOptions=Name` option (`DaemonPortOptions=Name=`) whenever an
inbound connection is accepted.  The names assigned in the default
configuration file are MTA (for the daemon that listens on port 25) and
MSA (for the MSP daemon that listens on port 587).  

As distributed, this `${daemon_name}` macro is not used in the
configuration file.  It is, however, available to you for use in designing
your own particular rule sets.  Note that a `$&` prefix is necessary when
you reference this macro in rules (that is, use `$&{daemon_name}`,
not `${daemon_name}`).

`${daemon_name}` is transient.  If it is defined in the configuration file
or in the command line, that definition can be ignored by *sendmail*.


## client_name Macro

**${client_name}** 

The connecting host's canonical name. 

The `${client_name}` macro is assigned its value when a host connects to
the running daemon.  This macro holds as its value the canonical hostname
of that connecting host, which is the same as the hostname stored in the
`$_` macro.

The `${client_name}` macro is useful in the `Local_check_rcpt`
([Local_check_rcpt](#local_check_rcpt-and-check_rcpt-rule-sets)),
`Local_check_mail` ([Local_check_mail](#local_check_mail-and-check_mail-rule-sets)),
and `Local_check_relay` ([Local_check_relay and check_relay ](#local_check_relay-and-check_relay-rule-sets))
rule sets.

## Local_check_rcpt and check_rcpt Rule Sets

**Local_check_rcpt** and **check_rcpt**

The `Local_check_rcpt` rule set provides a hook into the `check_rcpt`
rule set, which is used to validate the recipient-sender address given in
the `RCPT To:` command in the SMTP dialog:

`RCPT To:<recipient@host.domain>`

The `check_rcpt` rule set is called immediately after the `RCPT To:`
command is read.  The workspace that is passed to `check_rcpt` is the
address following the colon.  The envelope-recipient address might or
might not be surrounded by angle brackets and might or might not have
other RFC2822 comments associated with it.

The `check_rcpt` rule set has default rules that do the following:

* Reject empty envelope-recipient addresses, such as `< >`, and those
  which have nothing following the `RCPT To:`.
* Ensure that the envelope-recipient address is either local, or one that
  is allowed to be relayed.
* If the *access* database ([The access Database](#the-access-database))
  is used, look up the envelope-recipient's host in that database and
  reject, accept, or defer the message based on the returned lookup value.
  If the `FEATURE(blacklist_recipients)` is declared, they also look up
  the envelope recipient in that database.


## Local_check_mail and check_mail Rule Sets

**Local_check_mail** and **check_mail**

The `Local_check_mail` rule set provides a hook into the `check_mail`
rule set, which is used to validate the envelope-sender address given in
the `MAIL From:` command of the SMTP dialog:

`MAIL From:<sender@host.domain>`	

The `check_mail` rule set is called immediately after the `MAIL From:`
command is read.  The workspace passed to `check_mail` is the address
following the colon in the `MAIL From:` command.  That envelope-sender
address might or might not be surrounded by angle braces.

If *sendmail*'s delivery mode is anything other than 
deferred (`-bd`) ([-bd Command-Line Switch](#-bd-command-line-switch)),
the `check_mail` rule set performs the following default actions:

* Calls the *tls_client* rule set to perform TLS verification, if needed
* Accepts all envelope-sender addresses of the form `< >`
* Makes certain that the host and domain part of the envelope-sender
  address exists
* If the *access* database is used, looks up the envelope-sender in that
  database and rejects, accepts, or defers the message based on the
  returned lookup value

The `Local_check_mail` rule set provides a hook into `check_mail` before
the preceding checks are made, and provides a place for you to insert your
own rules.


## Local_check_relay and check_relay Rule Sets

**Local_check_relay** and **check_relay**

Sendmail supports three mechanisms for screening incoming SMTP connections:

* the *libwrap.a* mechanism 
* the `check_relay` rule set 
* the *access* database mechanism

The `Local_check_relay` rule set provides a hook into the `check_relay`
rule set, which is used to screen incoming network connections and accept
or reject them based on the hostname, domain, or IP address.  It is called
just before the *libwrap.a* code and can be used even if that code was
omitted from your release of *sendmail*.  Note that the `check_relay` rule
set is not called if *sendmail* was run with the `-bs` command-line switch
([-bs Command-Line Switch](#-bs-command-line-switch)).


## -bd Command-Line Switch

**-bd**

Run as a daemon

The `-bd` command-line switch causes *sendmail* to become a daemon,
running in the background, listening for and handling incoming SMTP
connections. (In its classic invocation, `-bd` is usually combined
with a `-q1h`.)

To become a daemon, *sendmail* first performs a *fork(2)*.  The parent
then exits, and the child becomes the daemon by disconnecting itself from
its controlling terminal.  The `-bD` command-line switch can be used to
prevent the *fork(2)* and the detachment and allows the *sendmail*
program's behavior to be observed while it runs in daemon mode.

As a daemon, *sendmail* does a *listen(2)* on TCP port 25 by default for
incoming SMTP messages. (Beginning with V8.10, *sendmail* also listens on
port 587 for message submissions via MUAs.  This default behavior can be
turned off with the `FEATURE(no_default_msa)`.)  When another site connects
to the listening daemon, the daemon performs a *fork(2)*, and the child
handles receipt of the incoming mail message.


## -bs Command-Line Switch

**-bs**

Run SMTP on standard input 

The *-bs* command-line switch causes *sendmail* to run a single SMTP
session in the foreground over its standard input and output, and then exit.
The SMTP session is exactly like a network SMTP session.  Usually, one or
more messages are submitted to *sendmail* for delivery.

This mode is intended for use at sites that wish to run *sendmail* with
the *inetd(8)* daemon.  To implement this, place an entry such as the
following in your *inetd.conf(5)* file, and then restart *inetd(8)* by
killing it with a SIGHUP signal:

```
smtp   stream  tcp   nowait  root /usr/sbin/sendmail sendmail -bs
```

With this scheme it is important to either use *cron(3)* to run *sendmail*
periodically to process its queue:

```
0 * * * * /usr/sbin/sendmail -q
```

or run *sendmail* in the background to process the queue periodically by
specifying an interval to the `-q` command-line switch's interval:

```
/usr/sbin/sendmail -q1h
```

In general, the *inetd(8)* approach should be used only on lightly loaded
machines that receive few SMTP connections.

The `-bs` switch is also useful for MUAs that prefer to use SMTP rather
than a pipe to transfer a mail message to *sendmail*.
Depending on how it is configured, *mh(1)* can use this feature.


## -bt Command-Line Switch (with Debug Options)

```
# sendmail -bt -d21.12 -d60 -d38
[ . . . ]
```

The `-d21.12` debug switch is for tracing *sendmail* rules and rule sets.   
The `-d38` debug switch is for showing *sendmail* database map opens and failures.    
The `-d60` debug switch is for tracing *sendmail* database map lookups.    



## Sendmail Debug Lookups

 
```
$ sendmail -d60.5 -bt << END
 /tryflags E
 /try relay dusko@yourdomain.com
 END
```


```
-d60.5 - trace map lookups (including genericstable lookups)
-d21.12 - trace R lines processing, use it when genericstable is not
consulted at all

/tryflags flags:
hs - header sender (genericstable rewrites only it by default)
hr - header recipient
es - evelope sender ("MAIL FROM:" in SMTP session) 
```

```
$ sendmail -d21.12 -bt 
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> /tryflags hs
> /try esmtp dusko
```


[access map rule for eliminate dnsbl lookup](https://groups.google.com/g/comp.mail.sendmail/c/Muk7q_7qnUs/m/U4epocS9fEIJ)


```
$ echo 'A <16.19.2.333><default><+Connect><passthru>' | sendmail -d60.5 -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> A                  input: < 16 . 19 . 2 . 333 > < default > < + Connect > < passthru >
A                  input: < 16 . 19 . 2 > < default > < + Connect > < passthru >
A                  input: < 16 . 19 > < default > < + Connect > < passthru >
A                  input: < 16 > < default > < + Connect > < passthru >
A                returns: < default > < passthru >
A                returns: < default > < passthru >
A                returns: < default > < passthru >
A                returns: < default > < passthru >
> $ 
```


```
$ echo 'A <16.19.2.333><default><+Connect><passthru>' | sendmail -d60.5 -bt | tail -2 
A                returns: < default > < passthru >
> $ 
```


```
$ echo 'A <16.1.2.333><default><+Connect><passthru>' | sendmail -d60.5 -bt | tail -2 
A                returns: < default > < passthru >
> $ 
```


```
$ sendmail -d38.20 -v -oi <<END 
To: dusko@fbsd1.yourprovider.com
Subject: hello

Testing.
END
openmap()       dequote:dequote NULL: valid
Recipient names must be specified
closemaps: closing dequote (NULL)
```


```
$ sudo sendmail -d38.20 -Ac -v -i -t << END
To: dusko@yourprovider.com
Subject: Test

Testing.
END
openmap()       dequote:dequote NULL: valid
openmap()       host:host NULL: valid
getcanonname(yourprovider.com), trying dns
getcanonname(yourprovider.com), found, ad=0
dusko@yourprovider.com... Connecting to [127.0.0.1] port 1465 via smartrelay...
220 mailx.yourprovider.com ESMTP mailer ready at Wed, 7 Dec 2022 12:17:13 -0800
>>> EHLO fbsd1.yourisp.com
250-mailx.yourprovider.com Hello fbsd1.yourisp.com [123.45.67.89], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-AUTH LOGIN PLAIN
250-DELIVERBY
250 HELP
hash_map_open(authinfo, /etc/mail/authinfo, 0)
openmap()       hash:authinfo /etc/mail/authinfo: valid
db_map_lookup(authinfo, AuthInfo:[127.0.0.1])
>>> AUTH LOGIN
334 VXNlcm5hbWU6
>>> ZABcd12=
334 UGFzc3dvcmQ6
>>> TABcDE1fGHIjKLmnOPQ2rS==
235 2.0.0 OK Authenticated
>>> MAIL From:<dusko@fbsd1.yourisp.com> SIZE=46 AUTH=dusko@yourisp.com
250 2.1.0 <dusko@fbsd1.yourisp.com>... Sender ok
>>> RCPT To:<dusko@yourprovider.com>
250 2.1.5 <dusko@yourprovider.com>... Recipient ok
>>> DATA
354 Enter mail, end with "." on a line by itself
>>> .
250 2.0.0 2B7KHDhI015382 Message accepted for delivery
dusko@yourprovider.com... Sent (2B7KHDhI015382 Message accepted for delivery)
Closing connection to [127.0.0.1]
>>> QUIT
221 2.0.0 mailx.yourprovider.com closing connection
closemaps: closing authinfo (/etc/mail/authinfo)
db_map_close(authinfo, /etc/mail/authinfo, 1000121)
closemaps: closing host (NULL)
closemaps: closing dequote (NULL)
```


## no_default_msa FEATURE

**FEATURE(no_default_msa)** 

Disable automatic listening on MSA port 587


From V8.10, when *sendmail* starts up in *daemon* mode, it listens both on
the normal port 25 for incoming SMTP connections, and on port 587 for the
local submission of mail.  This later role is that of an MSA (documented
in RFC2476).


If you prefer to disable this service, you can do it with the FEATURE(no_default_msa):

```
FEATURE(`no_default_msa')
```

Since there is no way to directly change the settings of the MSA in your
*mc* configuration file, you can use the following trick if you need to
change, say, the `M=` equate from `M=E` to `M=Ea`:

```
FEATURE(`no_default_msa')
DAEMON_OPTIONS(`Port=587,Name=MSA,M=Ea')
```

Here, this feature prevents the automatic creation of an *mc* configuration
entry for an MSA.  You then insert your own declaration, with your new settings.

Be aware, however, that this feature also disables the listening daemon on
port 25.  If you use this feature, be certain to redeclare a port 25 daemon
if you need one:

```
FEATURE(`no_default_msa')
DAEMON_OPTIONS(`Port=587,Name=MSA,M=Ea')
DAEMON_OPTIONS(`Port=smtp, Name=MTA')
```


## STARTTLS

Encryption can improve the security of *sendmail*.  Ordinarily, mail is
sent between two machines in the clear.  That is, if you were to watch
the transmission of bytes over the network (with for example *tcpdump*
utility) you would see what is actually being sent or received.
This includes passwords, which are also sent in the clear. 

To reduce the likelihood that someone watching the network will find something that can harm you, you can encrypt the stream of data. Three forms of encryption are available:

* SSL   
SSL is a method for encrypting a single connection over which network
traffic can flow.   
One implementation of SSL is available from
[http://www.openssl.org/](http://www.openssl.org/).

* TLS    
Transport Layer Security, defined by RFC2246, is the successor to SSL that
provides further means of connection encryption.  It, too, is available from 
[http://www.openssl.org/](http://www.openssl.org/).

* SMTP `AUTH=`    
The DIGEST-MD5 and GSSAPI mechanisms, among others, for the `AUTH=` extension
to SMTP, also provide stream encryption.


### [TODO]:  STARTTLS and the access Database

Four prefixes in the *access* database are available for use with
STARTTLS connection encryption. 

`CERTISSUER:` and `CERTSUBJECT:` are for use with the `Local_Relay_Auth`
rule set.  `TLS_Srv:` and `TLS_Clt:` are for use with the `tls_server`
and `tls_client` rule sets.

```
# grep -n CERTISSUER /etc/mail/sendmail.cf
1774:R$+                        $: $(access CERTISSUER:$1 $)
```

```
# grep -n CERTSUBJECT /etc/mail/sendmail.cf
1777:R<@> $+                    $: <@> $(access CERTSUBJECT:$1 $)
```

```
# sed -n 1762,1779p /etc/mail/sendmail.cf
######################################################################
###  RelayTLS: allow relaying based on TLS authentication
###
###     Parameters:
###             none
######################################################################
SRelayTLS
# authenticated?
R$*                     $: <?> $&{verify}
R<?> OK                 $: OK           authenticated: continue
R<?> $*                 $@ NO           not authenticated
R$*                     $: $&{cert_issuer}
R$+                     $: $(access CERTISSUER:$1 $)
RRELAY                  $# RELAY
RSUBJECT                $: <@> $&{cert_subject}
R<@> $+                 $: <@> $(access CERTSUBJECT:$1 $)
R<@> RELAY              $# RELAY
R$*                     $: NO
```


### The access database with tls_server and tls_client

The `tls_server` rule set is called after the local *sendmail* issued
(or should have issued) the STARTTLS SMTP command. This rule set handles outbound connections.

The `tls_client` rule set is called at two possible points: just after the
connecting host's STARTTLS SMTP command is offered; and from the
`check_mail` rule set (which is called just after the connecting host
issues the `MAIL From:` command).  This `tls_client` rule set handles inbound connections.

Both rule sets are given the value of the `${verify}` *sendmail* macro in
their workspaces.  The `tls_client` rule set is given that value, followed
by a `$|` operator, and a literal string that is MAIL when `tls_client` is
called from the `check_mail` rule set, or STARTTLS otherwise.

If the *access* database is not used, the connection is allowed in all
cases, both inbound and outbound, unless the value in `${verify}` is
SOFTWARE, in which case the connection is not allowed.

If the *access* database is used, the `tls_server` rule set looks up the
hostname of the destination host in the *access* database using the
`TLS_Srv:` prefix.  For example, if the local *sendmail* connected to the
server *insecure.host.domain*, and if the negotiation for the TLS
connection was good, the following lookup is performed:

`TLS_Srv:insecure.host.domain`


The `tls_client` rule set looks up the hostname of the inbound connecting
host in the *access* database using the `TLS_Clt:` prefix.  For example,
if the local *sendmail* accepts a connection from *ssl.host.domain*, and
if the negotiation for TLS connection was good, the following lookup is performed:

`TLS_Clt:ssl.host.domain`


```
# grep -n TLS_Srv /etc/mail/sendmail.cf
1679:R$*                $: $1 $| $>D <$&{server_name}> <?> <! "TLS_Srv"> <>
1680:R$* $| <?>$*       $: $1 $| $>A <$&{server_addr}> <?> <! "TLS_Srv"> <>
1681:R$* $| <?>$*       $: $1 $| <$(access "TLS_Srv": $: ? $)>

# grep -n TLS_Clt /etc/mail/sendmail.cf
1450:SDelay_TLS_Clt
1457:SDelay_TLS_Clt2
1471:R$+ $| $#$*                $@ $>"Delay_TLS_Clt" $2
1664:R$* $| $*  $: $1 $| $>D <$&{client_name}> <?> <! "TLS_Clt"> <>
1665:R$* $| <?>$*       $: $1 $| $>A <$&{client_addr}> <?> <! "TLS_Clt"> <>
1666:R$* $| <?>$*       $: $1 $| <$(access "TLS_Clt": $: ? $)>
```


```
# grep -r -n TLS_Srv /etc/mail | grep -v 'sendmail.cf' 

# grep -r -n TLS_Clt /etc/mail | grep -v 'sendmail.cf' 
```


```
# sed -n 1450,1462p /etc/mail/sendmail.cf
SDelay_TLS_Clt
# authenticated?
R$*                     $: $1 $| $>"tls_client" $&{verify} $| MAIL
R$* $| $#$+             $#$2
R$* $| $*               $# $1
R$*                     $# $1

SDelay_TLS_Clt2
# authenticated?
R$*                     $: $1 $| $>"tls_client" $&{verify} $| MAIL
R$* $| $#$+             $#$2
R$* $| $*               $@ $1
R$*                     $@ $1
```

```
# sed -n 1655,1683p /etc/mail/sendmail.cf
######################################################################
###  tls_client: is connection with client "good" enough?
###     (done in server)
###
###     Parameters:
###             ${verify} $| (MAIL|STARTTLS)
######################################################################
Stls_client
R$*             $: $(macro {TLS_Name} $@ $&{client_name} $) $1
R$* $| $*       $: $1 $| $>D <$&{client_name}> <?> <! "TLS_Clt"> <>
R$* $| <?>$*    $: $1 $| $>A <$&{client_addr}> <?> <! "TLS_Clt"> <>
R$* $| <?>$*    $: $1 $| <$(access "TLS_Clt": $: ? $)>
R$* $| <$* <TMPF>>    $#error $@ 4.3.0 $: "451 Temporary system failure. Please try again later."
R$*             $@ $>"TLS_connection" $1

######################################################################
###  tls_server: is connection with server "good" enough?
###     (done in client)
###
###     Parameter:
###             ${verify}
######################################################################
Stls_server
R$*             $: $(macro {TLS_Name} $@ $&{server_name} $) $1
R$*             $: $1 $| $>D <$&{server_name}> <?> <! "TLS_Srv"> <>
R$* $| <?>$*    $: $1 $| $>A <$&{server_addr}> <?> <! "TLS_Srv"> <>
R$* $| <?>$*    $: $1 $| <$(access "TLS_Srv": $: ? $)>
R$* $| <$* <TMPF>>    $#error $@ 4.3.0 $: "451 Temporary system failure. Please try again later."
R$*             $@ $>"TLS_connection" $1
```

## The access Database

The *access* database provides a single, central database with rules to
accept, reject, and discard messages based on the sender name, address,
or IP address.  It is enabled with the `FEATURE(access_db)`.
(**Note:** Another feature, `FEATURE(blacklist_recipients)`, allows
 recipients to also be rejected.  Yet another, `FEATURE(delay_checks)`,
 allows even finer tuning based on the desire of individual recipients.)

For example, consider an access database with the following contents:

```
From:postmaster@spam.com   OK
From:spam.com              REJECT
```

Here, mail from *postmaster* at the site *spam.com* is accepted, whereas
mail from any other sender at that site is rejected.


## Sendmail Command-Line Arguments

```
% sendmail -i -v -d35.9,21.12 dusko
[ . . . ]
```

## References

[Email explained from first principles](https://explained-from-first-principles.com/email/)

[Sendmail overview diagram - Email flow](http://novosial.org/sendmail/index.html)

[Support for Running SMTP With TLS in Version 8.13 of sendmail](https://docs.oracle.com/cd/E19253-01/816-4555/fvbrb/index.html)
> Security Considerations Related to Running SMTP With TLS
> 
> As a standard mail protocol that defines mailers that run over the
> Internet, SMTP is not an end-to-end mechanism.  Because of this protocol
> limitation, TLS security through SMTP does not include mail user agents.
> Mail user agents act as an interface between users and a mail transfer
> agent (MTA) such as sendmail.
> 
> Also, mail might be routed through multiple servers.  For complete SMTP
> security the entire chain of SMTP connections must have TLS support.
>
> [ . . . ]
> 
> **Note -**    
> The implementation of TLS is based on the Secure Sockets Layer (SSL) protocol.
> 
> `STARTTLS` is the SMTP keyword that initiates a secure SMTP connection
> by using TLS.  This secure connection might be between two servers or
> between a server and a client.  A secure connection is defined as follows:
> * The source email address and the destination address are encrypted.
> * The content of the email message is encrypted.
> 
> When the client issues the `STARTTLS` command, the server responds with
> one of the following:
> * `220 Ready to start TLS`
> * `501 Syntax error (no parameters allowed)`
> * `454 TLS not available due to temporary reason`
> 
> The `220` response requires the client to start the TLS negotiation.
> The `501` response notes that the client incorrectly issued the `STARTTLS`
> command.  STARTTLS is issued with no parameters.  The `454` response
> necessitates that the client apply rule set values to determine whether
> to accept or maintain the connection.
> 
> Note that to maintain the Internet's SMTP infrastructure, publicly used
> servers must not require a TLS negotiation.  However, a server that is
> used privately might require the client to perform a TLS negotiation.
> In such instances, the server returns this response:
> 
> `530 Must issue a STARTTLS command first`
> 
> The `530` response instructs the client to issue the `STARTTLS` command
> to establish a connection.
> 
> The server or client can refuse a connection if the level of
> authentication and privacy is not satisfactory.  Alternately, because
> most SMTP connections are not secure, the server and client might
> maintain an unsecure connection.  Whether to maintain or refuse
> a connection is determined by the configuration of the server and the client.
> 
> Support for running SMTP with TLS is not enabled by default.  TLS is
> enabled when the SMTP client issues the STARTTLS command.  Before the
> SMTP client can issue this command, you must set up the certificates that
> enable *sendmail* to use TLS.  


[Secure mail server - IMAPS (Secure IMAP over SSL), SMTP AUTH plus either SMTP+STARTTLS (over Port 25) or SMTPS (over port 465)](https://bsd-box.net/~mikeg/blog/index.php?/archives/35-Lets-talk-about-sex.....html) -- or: [https://web.archive.org/web/20221030182616/https://bsd-box.net/~mikeg/blog/index.php?/archives/35-Lets-talk-about-sex.....html%2A](https://web.archive.org/web/20221030182616/https://bsd-box.net/~mikeg/blog/index.php?/archives/35-Lets-talk-about-sex.....html%2A)

[Secure SMTP AUTH over SSL/STARTTLS with Sendmail and Cyrus SASL, and secure IMAP server Howto](http://www.whoopis.com/howtos/sendmail-auth-howto.html)

[Observing SMTP](https://raysnotebook.info/computing/email-smtp.html)

[SSL versus TLS versus STARTTLS](http://novosial.org/openssl/tls-name/index.html)

[SSL, TLS, and STARTTLS](https://www.fastmail.help/hc/en-us/articles/360058753834-SSL-TLS-and-STARTTLS) 

[OpenSSL Command-Line HOWTO](https://www.madboa.com/geek/openssl/)

[What's the Difference Between Ports 465 and 587?](https://sendgrid.com/blog/whats-the-difference-between-ports-465-and-587/)

[What is StartTLS?](https://sendgrid.com/blog/what-is-starttls/) -- or: [https://sendgrid.com/blog/what-is-starttls/#:~:text=StartTLS%20is%20a%20protocol%20command,different%20command%20for%20encryption%2C%20STLS.](https://sendgrid.com/blog/what-is-starttls/#:~:text=StartTLS%20is%20a%20protocol%20command,different%20command%20for%20encryption%2C%20STLS.)

[The proposal for a standard to submit SMTP messages with encryption - Published in early 1997 - SMTPS - Port 465](https://lists.w3.org/Archives/Public/ietf-tls/1997JanMar/0079.html) 

[The IETF issued a one-time amendment to reinstate port 465 for message submission over TLS protocol - RFC 8314 - Use of TLS for Email Submission/Access - January 2018](https://tools.ietf.org/html/rfc8314#section-7.3)
> This is a one-time procedural exception to the rules in [RFC6335].
> This requires explicit IESG approval and does not set a precedent.
> Note: Since the purpose of this alternate usage assignment is to
> align with widespread existing practice and there is no known usage
> of UDP port 465 for Message Submission over TLS, IANA has not
> assigned an alternate usage of UDP port 465.
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
> during account setup.  If a new port is assigned for the submissions
> service, either (a) email software will continue with unregistered
> use of port 465 (leaving the port registry inaccurate relative to
> de facto practice and wasting a well-known port) or (b) confusion
> between the de facto and registered ports will cause harmful
> interoperability problems that will deter the use of TLS for Message
> Submission.  The authors of this document believe that both of these
> outcomes are less desirable than a "wart" in the registry documenting
> real-world usage of a port for two purposes.  Although STARTTLS on
> port 587 has been deployed, it has not replaced the deployed use of
> Implicit TLS submission on port 465.

[Issues with SSL/TLS and AUTH](https://qmail.jms1.net/tls-auth.shtml)

[Configuring Sendmail's STARTTLS (SSL) and Relaying](https://aput.net/~jheiss/sendmail/tlsandrelay.shtml)
> This page documents how to compile and configure Sendmail to support
> STARTTLS.  STARTTLS is the SMTP command to "Start Transport Layer
> Security"; or, in other words, to turn on SSL.
> 
> Using SSL with SMTP isn't terribly useful for protecting the contents
> of messages.  Email generally goes through multiple hops between the
> sender and the recipient and the sender has no way to ensure they every
> one of those hops will use SSL. 
> 
> However, it it very useful when authenticating senders.  You can either
> use SSL to protect a plain text login (SMTP AUTH), or use SSL
> certificates to do authentication directly.  SMTP authentication is
> useful for allowing remote users to relay mail through the external
> company mail server.  Claus Aßmann has some documentation but I found
> it a bit hard to follow so hopefully this is a little clearer. 


[Enable SMTPS service (SMTP over SSL, port 465)](https://docs.iredmail.org/enable.smtps.html)

[SMTP Service Extension for Secure SMTP over Transport Layer Security (TLS) - Explicit TLS (implemented with an extension called STARTTLS Command ) - RFC3207](https://www.rfc-editor.org/rfc/rfc3207) 
> A publicly-referenced SMTP server MUST NOT require use of the
> STARTTLS extension in order to deliver mail locally.  This rule
> prevents the STARTTLS extension from damaging the interoperability of
> the Internet's SMTP infrastructure.    
> A publicly-referenced SMTP server is an SMTP server which runs on 
> port 25 of an Internet host listed in the MX record (or A record if an
> MX record is not present) for the domain name on the right hand side of
> an Internet mail address.


[Configure Sendmail for SMTP over TLS](https://cromwell-intl.com/open-source/sendmail-ssl.html)

[SSL/TLS Background](https://cromwell-intl.com/cybersecurity/ssl-tls.html)

[How to fix Telnet SMTP 'must issue STARTTLS command first' error](https://devcoops.com/telnet-must-issue-starttls-command-first/)


[Testing SMTP AUTH connections](https://qmail.jms1.net/test-auth.shtml)

[FreeBSD - How to make changes to sendmail, FreeBSD styled](http://scratching.psybermonkey.net/2011/01/freebsd-how-to-make-changes-to-sendmail.html)

[Sendmail Guide and Sendmail Tips](https://www.akadia.com/services/sendmail_tips.html)

[Sendmail Survival Guide](https://www.akadia.com/download/documents/sendmail_survival.pdf)

[Setting Up Email: A Sendmail HOWTO](https://rimuhosting.com/support/settingupemail.jsp)

[How to setup an E-Mail Relay Host with Sendmail?](https://www.akadia.com/services/sendmail_relay.html)

[Outgoing Email - MTAs in Fedora](https://raysnotebook.info/computing/email-outgoing.html)

[Sendmail Tips and Tricks](http://www.harker.com/sendmail/index.html)

[Sendmail - ArchLinux Wiki](https://wiki.archlinux.org/title/sendmail)

[Simple Troubleshooting For SMTP Via Telnet And Openssl](https://wiki.zimbra.com/wiki/Simple_Troubleshooting_For_SMTP_Via_Telnet_And_Openssl)

[How to test SMTP servers using the command-line](https://halon.io/blog/how-to-test-smtp-servers-using-the-command-line)


[Tutorial - Testing Mail Protocols with SSL/TLS - Let's Encrypt](https://community.letsencrypt.org/t/tutorial-testing-mail-protocols-with-ssl-tls/43211/9)


[Installing and Configuring Sendmail](http://www.elandsys.com/resources/sendmail/)


[SMTP tidbits for the to-be postmaster](http://billauer.co.il/blog/2019/03/smtp-helo-ehlo-mail-from/)

[Virtual Dave - Wiki - sendmail section](https://wiki.xdroop.com/space/sendmail)

[Sendmail tips and debugging](http://www.linuxweblog.com/blog-tags/linux/sendmail)

[Sendmail client configuration](http://novosial.org/sendmail/client/index.html)


[Sample sendmail.mc configuration file](http://hiredavidbank.com/sendmail.mc)

[Practical Modern sendmail Configuration](http://hiredavidbank.com/prac-send.html)

[Defense In Depth: Anti-SPAM for sendmail Environments](http://hiredavidbank.com/AntiSPAM.html)

[Mail Relay Server Operations Guide [PDF]](http://hiredavidbank.com/DavidBank-TechnicalWritingSample.pdf)
> "An operations guide for a Linux-based mail relay server.  This is 
> a version of the original document, redacted to maintain the security of
> the original environment." 


[Switching to Ports-installed sendmail in FreeBSD](http://www.puresimplicity.net/~hemi/freebsd/ports-sendmail.html)

[FreeBSD sendmail Frequently Asked Questions](https://weldon.whipple.org/sendmail/freebsdsendmailfaqs.html)


[FreeBSD as a Secure Mail Server Using sendmail and imap-uw](http://www.puresimplicity.net/~hemi/freebsd/sendmail.html)

[Installing and Using procmail as the LDA for sendmail under FreeBSD](http://www.puresimplicity.net/~hemi/freebsd/procmail.html)

[Configure sendmail](https://gist.github.com/drmalex07/d63348dc9d26d1349309)

[SMTP Tests](https://rtcamp.com/tutorials/mail/server/testing/smtp/)

[Test SMTP with telnet or openssl](https://www.stevenrombauts.be/2018/12/test-smtp-with-telnet-or-openssl/)


[Debugging check_* in sendmail 8.8/8.9 and later](https://www.sendmail.org/~ca/email/chk-dbg.html)

- - - - 

* [A Secure Sendmail Based DMZ for the Corporate Email Environment](https://www.giac.org/paper/gsec/2496/secure-sendmail-based-dmz-corporate-email-environment/104359)

```
FEATURE(`delay_checks')dnl
The "delay_checks" feature is useful when used in combination with the "dnsbl"
feature for SPAM control.  Without enabling this feature, the log entry for the
rejected email will not contain the destination users mail address.  Having the
destination address is very useful when troubleshooting; typically the person
calling your organizations support center is the person whom cannot receive the
email.  This feature will put the destination users address into the reject log
message allowing you to search the log for it directly.  In the other case, the
external entity can be asked whom they were trying to send to.  Otherwise, you
are stuck looking for origin SMTP servers, not a straight forward as it might
seem.  For example, the sender works for company abc.com but is sending you
email from their home cable modem.
```

* [Demystifying Sendmail - Hal Pomeranz, Deer Run Associates](https://deer-run.com/users/hal/dns-sendmail/Demystifying-Sendmail.pdf)

```
In addition to the "access_db" declaration, however, you also want to add the
"delay_checks" feature.  Normally, the access DB and other anti-spam checks would
be consulted as soon as the remote server issues the "mail from:" command to set the
message sender.  The "delay_checks" feature tells Sendmail to wait until both the
sender and recipient addresses have been sent before deciding whether or not the message
is spam.  This is how you make sure that your "abuse@sysiphus.com" address
receives an unfiltered email stream while protecting all of your other users from spam.
```



* [Sendmail issues "530 Authentication required" error message when authinfo is supplied](https://unix.stackexchange.com/questions/230575/sendmail-issues-530-authentication-required-error-message-when-authinfo-is-sup):

> As root [on your mail server] send a test message with tracking
> map (authinfo) lookups

```
#!/bin/sh
# -d60.5 turn on traking map lookups
/usr/sbin/sendmail -d60.5 -v -i -fsender_email -- receiver_email  <<END
subject: test

test
END
```

* [sendmail allow authenticated sender with dnsbl](https://www.linuxquestions.org/questions/linux-server-73/sendmail-allow-authenticated-sender-with-dnsbl-698305/)

* [Sendmail DNSBL blocking authenticating users](https://www.linuxquestions.org/questions/linux-server-73/sendmail-dnsbl-blocking-authenticating-users-786503/)


* [Subject: Re: Logging of sendmail authenticated user](http://answers.google.com/answers/threadview?id=398644)

```
Sendmail.mc file approach:

Add the following definition to /etc/mail/sendmail.mc

define(`confLOG_LEVEL', `14')dnl

Rebuild /etc/mail/sendmail.cf

m4 sendmail.mc > sendmail.cf

Sendmail.cf file approach:

Change the following definition in /etc/mail/sendmail.cf

O LogLevel=14

After you have changed the logging level, restart the sendmail daemon.
 Syslog will now log any successful authentications to
/var/log/maillog.  Of interest to you are the following fields in each
authentication log entry:

authid= and relay=

authid will display the login that was used for the authentication,
and relay will display the remote IP address that was added as the
temporary relay.  If you don't recognize the relay, then it is most
likely the spammer entry.
```

* [Creating a multipart email and sending it in Linux](https://superuser.com/questions/286677/creating-a-multipart-email-and-sending-it-in-linux)

> Create a message of type multipart/alternative as documented in 
> [RFC 2046](https://www.rfc-editor.org/rfc/rfc2046#section-5.1.4):

```
From: Example Company <news@example.com>
To: Joe User <joe.u@example.net>
Date: Sat, 21 May 2011 17:40:11 +0300
Subject: Multipart message example
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary=asdfghjkl

--asdfghjkl
Content-Type: text/plain; charset=utf-8

Hello everyone!

--asdfghjkl
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<body>
<p>Hello everyone!</p>
</body>

--asdfghjkl--
```

> See [RFC 2046](https://www.rfc-editor.org/rfc/rfc2046) and 
> [RFC 5322](https://www.rfc-editor.org/rfc/rfc5322) for the exact syntax.


* [SSL versus TLS versus STARTTLS](http://novosial.org/openssl/tls-name/index.html)


> The following example shows how a SMTP client negotiates an encrypted 
> connection with STARTTLS.  First, the Mail Exchange (MX) for the domain 
> (example.org) must be looked up, then the smtp port on the MX at 
> smtp.example.org connected to.  Then the SMTP verbs EHLO and STARTTLS are 
> used to begin negotiating an encrypted dialog.

```
$ host -t mx example.org
example.org mail is handled by 10 smtp.example.org.

$ telnet smtp.example.org 25
Trying 192.0.2.1...
Connected to smtp.example.org.
Escape character is '^]'.
220 smtp.example.org ESMTP Sendmail 8.13.2/8.13.2
EHLO client.example.org
250-smtp.example.org Hello client.example.org [192.0.2.7], pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE 16180340
250-DSN
250-STARTTLS
250-DELIVERBY
250 HELP
STARTTLS
220 2.0.0 Ready to start TLS
...
```

> The [OpenSSL](https://www.openssl.org/) library ships with the `openssl` 
> utility, which has a `s_client` mode to test encrypted connections. 
> More recent versions of the `openssl` utility support STARTTLS for 
> protocols such as `smtp` and `pop3`.  The `openssl` invocations below 
> show how to connect via https to www.example.org and pop3 with STARTTLS 
> to mail.example.org.  Once connected, the protocol in question can then be used.

```
$ openssl s_client -connect www.example.org:443 -showcerts
...
GET / HTTP/1.0

HTTP/1.1 200 OK
...
$ openssl s_client -connect mail.example.org:110 -showcerts -starttls pop3
... 
+OK POP3 mail.example.org v2003.83 server ready
quit
+OK Sayonara
```


```
$ openssl s_client -verify 2 -quiet -connect mx.youremailprovider.com:465
---- snip ----
```


```
$ openssl s_client -verify 2 -quiet -connect mx.youremailprovider.com:465 2>/dev/null || exit 75
---- snip ----
```


* [Relaying with SMTP authentication](https://workaround.org/ispmail/stretch/relaying-smtp-authentication)

* [Linux Guide](https://dr0.ch/docs/linux-guide-10ed.pdf)

* [Sendmail - The Institute for Open Systems Technologies, Release 2.0, 22nd March 2004](http://www.ifost.org.au/Documents/sendmail.pdf)

* [SMART_HOST in FreeBSD12R default sendmail](https://ameblo-jp.translate.goog/ypsilondelta/entry-12628745736.html?_x_tr_sl=ja&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=sc)

* [Sendmail Presentation - NCTU CSCC/NYMCTU, Computer Network Management Course (2005 syllabus)](https://nasa.cs.nycu.edu.tw/nm/2005/slide/SendMail.pdf)

* [Sendmail Presentation - Computer Center CS NCTU/NYMCTU](https://people.cs.nctu.edu.tw/~chwong/course/netadm-2007/slide/07_SendMail.pdf)


## Bypass Filtering for Authenitcated Users

* [Suppress IP of authenticated senders in Sendmail](http://web.archive.org/web/20220930003249/https://fam.tuwien.ac.at/~schamane/_/oldblog/141118_suppress_ip_of_authenticated_senders_in_sendmail.html)

> So, in /etc/mail/sendmail.mc I added:

```
dnl # suppress IP of authenticated sender
define(`confRECEIVED_HEADER',`$?{auth_type}from auth (localhost [127.0.0.1]) $|_REC_HDR_$.
	_REC_BY_
	_REC_TLS_
	_REC_END_')
```

Note: The leading spaces are actually 1 TAB! 

From
[General Notes - Joel's Compendium of Total Knowledge](https://www.joelw.id.au/GeneralNotes):
> With sendmail, obscure Received: headers when relaying
> 
> I noticed that an email I had sent someone was marked as spam because 
> my dynamic IP address was on some blacklist.  I use my own authenticated 
> SMTP relay, so there's really no reason I'd want people to know my 
> IP address.  After some fiddling I came up with the following macro, 
> which you may add to your sendmail.mc:

```
define(`confRECEIVED_HEADER', `$?{auth_type}(from $j) by $j ($v/$Z)$|$?sfrom $s $.$?_($?s$|from $.$_)
$.$?{auth_type}(authenticated$?{auth_ssf} bits=${auth_ssf}$.)
$.by $j ($v/$Z)$?r with $r$. id $i$?{tls_version}
(version=${tls_version} cipher=${cipher} bits=${cipher_bits} verify=${verify})$.$?u
for $u; $|;
$.$b$.')dnl
```

> This looks horrible, but it's a fairly simple modification of the default rule.
> `sendmail.cf` uses `$?{variable} $| $.` as `if`, `else`, and `end if` operators respectively.
> So here, if `auth_type` is defined (which **only** occurs if an **authenticated user** is *relaying* through the server, which will only be *local users*), then show a simple "(from hostname) by hostname (8.14.3/8.14.3/Debian-9.2)", which is based on some other non-descript headers I managed to generate by invoking sendmail on the server from mutt.
> Otherwise, it proceeds with the default rule (`from $?sfrom $s ...`).


Also, the same page ([Suppress IP of authenticated senders in Sendmail](http://web.archive.org/web/20220930003249/https://fam.tuwien.ac.at/~schamane/_/oldblog/141118_suppress_ip_of_authenticated_senders_in_sendmail.html)) points to the following post as an inspiration:
[Removing Sender's IP Address From Email's Received: From Header](https://archive.ph/w7LRF)

> Anyway, what I did find was, for instance, [Removing Sender's IP Address From Email's Received: From Header](https://archive.ph/w7LRF).
> This page popped up frequently when I searched for how to suppress headers, and it seems to be one of very few indeed.
> It even addresses my main problem.
> The author's approach is totally valid, and s/he explains things well and gives pointers.
> However, I did not feel comfortable with completely removing the "from" part, and with redefining `confRECEIVED_HEADER` without honoring the defaults.
> I was also afraid that this might even break some other things (like our own spam filter rules).
>
> Another solution that I could find about 2 times goes 1 big step furhter:
> It suggested to remove the `HReceived` line(s) from `submit.cf` altogether.
> This does work, and it does make some sense for `submit.cf`, however, **only** if 2 *sendmail* daemons are used where 1 is running with the `submit.cf` and listens to *port 587*.
> But, my server is a Debian box with *only 1 daemon*, and I thought there should be no need for a 2nd. 
>
> `$?{auth_type}$|...$.`
>
> [Joel's Compendium of Total Knowledge](http://web.archive.org/web/20221102231352/https://joelw.id.au/GeneralNotes) (search for `Received:`) is the only page I found that suggests what I thought was reasonable, i.e. introduce an **if-then** `($?…$|…$.)` evaluating the *variable* `{auth_type}` to check whether the client has been *authenticated*:
>
> ```
> define(`confRECEIVED_HEADER', `$?{auth_type}...
> ```
>
> [ . . . ]
> 
>
> **Discussion**
> 
> Andreas Schamanek, 2014-11-18 22:46
> 
> By means of this approach we are suppressing an IP that might indeed be abused by the authenticated client.
> However, I don't think that this is of any concern.
> In such cases, the relaying mail server will be blacklisted anyway.
> I'll get notified, and I'll be able to stop the abuse.
> Besides, I have hourly and daily limits set for outgoing mail.


## With sendmail and spamass-milter, Don't Check Outgoing Messages

From
[General Notes - Joel's Compendium of Total Knowledge](https://www.joelw.id.au/GeneralNotes):
> Now that I've set up a secure mail relay, I can happily send mail from all manner of 3G and wireless connections.
> All of them are listed in RBLs, which makes me angry because SpamAssassin on my mail relay is marking my own messages as spam.
> Fortunately, Debian/Ubuntu's version of spamass-milter has a `-I` option that **skips checks for authenticated users**.
> This seems to work even with my dodgy hack above. 

----

[What is Sendmail? - Proofpoint](https://www.proofpoint.com/us/threat-reference/sendmail)

[Test and Use Sendmail from the Command Line - Sendmail Command Help and Examples](https://www.computerhope.com/unix/usendmai.htm)

----

## Documentation, README, FAQ, Help and Other Files Distributed with Sendmail On FreeBSD 13

```
$ diff /usr/src/contrib/sendmail/cf/README /usr/local/share/sendmail/cf/README | wc -l
     106
```

```
$ wc -l /usr/src/contrib/sendmail/src/README /usr/local/share/sendmail/cf/README 
    1869 /usr/src/contrib/sendmail/src/README
    4831 /usr/local/share/sendmail/cf/README
    6700 total
```

```
$ ls -lh /usr/src/contrib/sendmail/src/ | grep -v '\.c' | grep -v '\.h'
total 1332
-rw-r--r--  1 root  wheel   1.4K Oct 21 17:58 aliases
-rw-r--r--  1 root  wheel   3.1K Oct 21 17:58 aliases.5
-rw-r--r--  1 root  wheel   5.5K Oct 21 17:58 helpfile
-rw-r--r--  1 root  wheel   3.5K Oct 21 17:58 mailq.1
-rw-r--r--  1 root  wheel   347B Oct 21 17:58 Makefile
-rw-r--r--  1 root  wheel   4.4K Oct 21 17:58 Makefile.m4
-rw-r--r--  1 root  wheel   1.3K Oct 21 17:58 newaliases.1
-rw-r--r--  1 root  wheel    82K Oct 21 17:58 README
-rw-r--r--  1 root  wheel   7.5K Oct 21 17:58 SECURITY
-rw-r--r--  1 root  wheel    17K Oct 21 17:58 sendmail.8
-rw-r--r--  1 root  wheel   3.1K Oct 21 17:58 TRACEFLAGS
-rw-r--r--  1 root  wheel    10K Oct 21 17:58 TUNING
```


Possible mailers are listed in this directory:  
`/usr/local/share/sendmail/cf/mailer/`

  and (if you've obtained *sendmail* source):  

`/usr/src/contrib/sendmail/cf/mailer/`


Patches and 
some useful *sendmail* tools (e.g. `movemail.pl`, `qtool.pl`, 
`re-mqueue.pl`) are located here:   
`/usr/src/contrib/sendmail/contrib/`


```
$ cat /usr/src/contrib/sendmail/FAQ
The FAQ is no longer maintained with the sendmail release.  It is
available at http://www.sendmail.org/faq/ .

$Revision: 8.25 $, Last updated $Date: 2014-01-27 12:49:52 $
```

As of Oct 22, 2022, the Sendmail **FAQ** is at  
[https://www.proofpoint.com/us/sendmail/faq](https://www.proofpoint.com/us/sendmail/faq)   


On FreeBSD 13.1-RELEASE-p2, as of Oct 22, 2022, the package-provided
*sendmail* version is 8.17.1:

```
$ /usr/local/sbin/sendmail -d0.1 < /dev/null | head -1
Version 8.17.1
```

```
$ pkg search --regex ^sendmail-
sendmail-8.17.1_6              Reliable, highly configurable mail 
  transfer agent with utilities
sendmail-devel-8.17.1.22       Reliable, highly configurable mail
  transfer agent with utilities
```

  while *sendmail* shipped with FreeBSD 13 is V8.16.1:


```
$ /usr/libexec/sendmail/sendmail -d0.1 < /dev/null | head -1
Version 8.16.1
```

```
$ cat /usr/src/contrib/sendmail/FREEBSD-upgrade
$FreeBSD$

sendmail 8.16.1
        originals can be found at: ftp://ftp.sendmail.org/pub/sendmail/

For the import of sendmail, the following directories were renamed:

        sendmail -> src

Imported using the instructions at:

http://www.freebsd.org/doc/en_US.ISO8859-1/articles/committers-guide/subversion-primer.html

Then merged using:

% set FSVN=svn+ssh://repo.freebsd.org/base
% svn checkout $FSVN/head/contrib/sendmail head
% cd head
### Replace XXXXXX with import revision number in next command:
% svn merge -c rXXXXXX --accept=postpone '^/vendor/sendmail/dist' .
% svn resolve --accept working cf/cf/Build \
    cf/cf/generic-{bsd4.4,hpux{9,10},linux,mpeix,nextstep3.3,osf1,solaris,sunos4.1,ultrix4}.cf \
    devtools doc/op/op.ps editmap/editmap.0 mail.local/mail.local.0 mailstats/mailstats.0 \
    makemap/makemap.0 praliases/praliases.0 rmail/rmail.0 smrsh/smrsh.0 \
    src/{aliases,mailq,newaliases,sendmail}.0 vacation/vacation.0
% svn propset -R svn:keywords FreeBSD=%H .
% svn propdel svn:keywords libmilter/docs/*.jpg
% svn diff --no-diff-deleted --old=$FSVN/vendor/sendmail/dist --new=.
% svn status
% svn diff
% svn commit

After importing, bump the version of src/etc/sendmail/freebsd*mc
so mergemaster will merge /etc/mail/freebsd*cf by making a minor
change and committing.

To make local changes to sendmail, simply patch and commit to the head.
Never make local changes in the vendor area (/vendor/sendmail/).

All local changes should be submitted to the Sendmail Consortium
<sendmail@sendmail.org> for inclusion in the next vendor release.

The following files make up the sendmail build/install/runtime
infrastructure in FreeBSD:

        Makefile.inc1
        bin/Makefile
        bin/rmail/Makefile
        contrib/sendmail/
        etc/Makefile
        etc/defaults/make.conf (obsolete)
        etc/defaults/periodic.conf
        etc/defaults/rc.conf
        etc/mail/Makefile
        etc/mail/README
        etc/mail/access.sample
        etc/mail/aliases
        etc/mail/mailer.conf
        etc/mail/mailertable.sample
        etc/mail/virtusertable.sample
        etc/mtree/BSD.include.dist
        etc/mtree/BSD.sendmail.dist
        etc/mtree/BSD.usr.dist
        etc/mtree/BSD.var.dist
        etc/periodic/daily/440.status-mailq
        etc/periodic/daily/500.queuerun
        etc/rc
        etc/rc.sendmail
        etc/sendmail/Makefile
        etc/sendmail/freebsd.mc
        etc/sendmail/freebsd.submit.mc
        etc/sendmail/freefall.mc
        lib/Makefile
        lib/libmilter/Makefile
        lib/libsm/Makefile
        lib/libsmdb/Makefile
        lib/libsmutil/Makefile
        libexec/Makefile
        libexec/mail.local/Makefile
        libexec/smrsh/Makefile
        share/Makefile
        share/doc/smm/Makefile
        share/doc/smm/08.sendmailop/Makefile
        share/examples/etc/make.conf
        share/man/man5/make.conf.5
        share/man/man5/periodic.conf.5
        share/man/man5/rc.conf.5
        share/man/man7/hier.7
        share/man/man8/Makefile
        share/man/man8/rc.sendmail.8
        share/mk/bsd.libnames.mk
        share/sendmail/Makefile
        tools/build/mk/OptionalObsoleteFiles.inc
        usr.bin/Makefile
        usr.bin/vacation/Makefile
        usr.sbin/Makefile
        usr.sbin/editmap/Makefile
        usr.sbin/mailstats/Makefile
        usr.sbin/makemap/Makefile
        usr.sbin/praliases/Makefile
        usr.sbin/sendmail/Makefile
        usr.sbin/mailwrapper/Makefile

gshapiro@FreeBSD.org
15-July-2020
```

These files are located relative to `/usr/src/` directory; for example,
`libexec/smrsh/Makefile` is at `/usr/src/libexec/smrsh/Makefile`.


### Sendmail Related Manual Pages in FreeBSD 13

```
% man -k sendmail | wc -l
      11
``` 

``` 
% man -k sendmail
aliases(5) - aliases file for sendmail
aliases(5) - aliases file for sendmail
editmap(8) - query and edit single records in database maps for sendmail
editmap(8) - query and edit single records in database maps for sendmail
makemap(8) - create database maps for sendmail
makemap(8) - create database maps for sendmail
rc.sendmail(8) - sendmail 8 startup script
sendmail(8) - an electronic mail transport agent
sendmail, hoststat, purgestat(8) - an electronic mail transport agent
smrsh(8) - restricted shell for sendmail
smrsh(8) - restricted shell for sendmail
```

```
% manpath
/usr/share/man:/usr/local/share/man:/usr/local/man:/usr/share/openssl/man:/usr/local/lib/perl5/site_perl/man:/usr/local/lib/perl5/5.32/perl/man
```


## Sendmail Default Variables in /etc/defaults/rc.conf

```
% head -20 /etc/defaults/rc.conf
#!/bin/sh

# This is rc.conf - a file full of useful variables that you can set
# to change the default startup behavior of your system.  You should
# not edit this file!  Put any overrides into one of the ${rc_conf_files}
# instead and you will be able to update these defaults later without
# spamming your local configuration information.
#
# The ${rc_conf_files} files should only contain values which override
# values set in this file.  This eases the upgrade path when defaults
# are changed and new features are added.
#
# All arguments must be in double or single quotes.
#
# For a more detailed explanation of all the rc.conf variables, please
# refer to the rc.conf(5) manual page.
#
# $FreeBSD$

##############################################################
```

Also, from the man page for `rc.conf(5)`:

```
rc_conf_files
            (str) This option is used to specify a list of files that
            will override the settings in /etc/defaults/rc.conf.  The
            files will be read in the order in which they are specified
            and should include the full path to the file.  By default,
            the files specified are /etc/rc.conf and /etc/rc.conf.local
```


```
% grep -n sendmail /etc/defaults/rc.conf | wc -l
      16
 
% grep -n -i sendmail /etc/defaults/rc.conf | wc -l
      16
```

```
% grep sendmail /etc/defaults/rc.conf
mta_start_script="/etc/rc.sendmail"
# Settings for /etc/rc.sendmail and /etc/rc.d/sendmail:
sendmail_enable="NO"    # Run the sendmail inbound daemon (YES/NO).
sendmail_pidfile="/var/run/sendmail.pid"        # sendmail pid file
sendmail_procname="/usr/sbin/sendmail"          # sendmail process name
sendmail_flags="-L sm-mta -bd -q30m" # Flags to sendmail (as a server)
sendmail_cert_create="YES"      # Create a server certificate if none (YES/NO)
#sendmail_cert_cn="CN"          # CN of the generate certificate
sendmail_submit_enable="YES"    # Start a localhost-only MTA for mail submission
sendmail_submit_flags="-L sm-mta -bd -q30m -ODaemonPortOptions=Addr=localhost"
sendmail_outbound_enable="YES"  # Dequeue stuck mail (YES/NO).
sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
sendmail_msp_queue_enable="YES" # Dequeue stuck clientmqueue mail (YES/NO).
sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
                                # Flags for sendmail_msp_queue daemon.
sendmail_rebuild_aliases="NO"   # Run newaliases if necessary (YES/NO).
``` 

``` 
% grep sendmail /etc/defaults/rc.conf | grep flags
sendmail_flags="-L sm-mta -bd -q30m" # Flags to sendmail (as a server)
sendmail_submit_flags="-L sm-mta -bd -q30m -ODaemonPortOptions=Addr=localhost"
sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
```

```
% grep sendmail /etc/defaults/rc.conf | grep submit
sendmail_submit_enable="YES"    # Start a localhost-only MTA for mail submission
sendmail_submit_flags="-L sm-mta -bd -q30m -ODaemonPortOptions=Addr=localhost"
```

```
% grep sendmail /etc/defaults/rc.conf | grep msp
sendmail_msp_queue_enable="YES" # Dequeue stuck clientmqueue mail (YES/NO).
sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
                                # Flags for sendmail_msp_queue daemon.
```

```
% sudo grep -r -w sendmail_submit /etc/
/etc/rc.d/sendmail:     name="sendmail_submit"
```

```
% sudo grep -r sendmail_submit_flags /etc/
/etc/defaults/rc.conf:sendmail_submit_flags="-L sm-mta -bd -q30m -ODaemonPortOptions=Addr=localhost"
/etc/rc.sendmail:                       ${sendmail_program} ${sendmail_submit_flags}
```

```
% sudo grep -r -w sendmail_submit_enable /etc/
/etc/rc.d/sendmail:     sendmail_submit_enable="NO"
/etc/rc.d/sendmail:     sendmail_submit_enable="NO"
/etc/rc.d/sendmail:# If sendmail_submit_enable=yes, don't need outbound daemon
/etc/rc.d/sendmail:if checkyesno sendmail_submit_enable; then
/etc/rc.d/sendmail:if checkyesno sendmail_submit_enable; then
/etc/rc.d/sendmail:     rcvar="sendmail_submit_enable"
/etc/mail/README:can be disabled using the sendmail_submit_enable rc.conf option.  However,
/etc/mail/README:if both sendmail_enable and sendmail_submit_enable are set to "NO", you
/etc/defaults/rc.conf:sendmail_submit_enable="YES"      # Start a localhost-only MTA for mail submission
/etc/rc.sendmail:               case ${sendmail_submit_enable} in
/etc/rc.sendmail:               case ${sendmail_submit_enable} in
/etc/rc.sendmail:               case ${sendmail_submit_enable} in
```

```
% sudo grep -r -n mta_start_script /etc/
/etc/rc.d/othermta:15:if [ -n "${mta_start_script}" ]; then
/etc/rc.d/othermta:16:  [ "${mta_start_script}" != "/etc/rc.sendmail" ] && \
/etc/rc.d/othermta:17:      sh ${mta_start_script} "$1"
/etc/defaults/rc.conf:592:mta_start_script="/etc/rc.sendmail"
/etc/rc.sendmail:34:# MTAs.  It is only called by /etc/rc if the rc.conf mta_start_script is
```

```
% cat /etc/rc.d/othermta
#!/bin/sh
#
# $FreeBSD$
#

# PROVIDE: mail
# REQUIRE: LOGIN

# XXX - TEMPORARY SCRIPT UNTIL YOU WRITE YOUR OWN REPLACEMENT.
#
. /etc/rc.subr

load_rc_config

if [ -n "${mta_start_script}" ]; then
        [ "${mta_start_script}" != "/etc/rc.sendmail" ] && \
            sh ${mta_start_script} "$1"
fi
```

```
% ls -lh /etc/rc.sendmail
-rw-r--r--  1 root  wheel   5.6K Apr  8  2021 /etc/rc.sendmail
 
% file /etc/rc.sendmail
/etc/rc.sendmail: POSIX shell script, ASCII text executable
 
% wc -l /etc/rc.sendmail
     277 /etc/rc.sendmail
```


**NOTE:**   
The `/etc/rc.sendmail` startup script is used at **boot time**:   
"This script is used by `/etc/rc` at **boot time** to start *sendmail*."   

In addition, this script is used by **`/etc/mail/Makefile`**:  

"The script is also used by `/etc/mail/Makefile` to enable the
**start/stop/restart** targets." 

That is:

```
% cd /etc/mail
% sudo su
# make start    # (Or make stop, or make restart) 
```


```
% cat /etc/rc.sendmail
#!/bin/sh

#
# Copyright (c) 2002  Gregory Neil Shapiro.  All Rights Reserved.
# Copyright (c) 2000, 2002  The FreeBSD Project

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


```
% ls -lh /etc/rc.d/sendmail
-r-xr-xr-x  1 root  wheel   6.4K Apr  8  2021 /etc/rc.d/sendmail
 
% file /etc/rc.d/sendmail
/etc/rc.d/sendmail: POSIX shell script, ASCII text executable
 
% wc -l /etc/rc.d/sendmail
     229 /etc/rc.d/sendmail
```

```
% cat /etc/rc.d/sendmail
#!/bin/sh
#
# $FreeBSD$
#

# PROVIDE: mail
# REQUIRE: LOGIN FILESYSTEMS
#       we make mail start late, so that things like .forward's are not
#       processed until the system is fully operational
# KEYWORD: shutdown

# XXX - Get together with sendmail mantainer to figure out how to
#       better handle SENDMAIL_ENABLE and 3rd party MTAs.
#
. /etc/rc.subr

name="sendmail"
desc="Electronic mail transport agent"
rcvar="sendmail_enable"
required_files="/etc/mail/${name}.cf"
start_precmd="sendmail_precmd"

load_rc_config $name
command=${sendmail_program:-/usr/sbin/${name}}
pidfile=${sendmail_pidfile:-/var/run/${name}.pid}
procname=${sendmail_procname:-/usr/sbin/${name}}

CERTDIR=/etc/mail/certs

case ${sendmail_enable} in
[Nn][Oo][Nn][Ee])
        sendmail_enable="NO"
        sendmail_submit_enable="NO"
        sendmail_outbound_enable="NO"
        sendmail_msp_queue_enable="NO"
        ;;
esac

# If sendmail_enable=yes, don't need submit or outbound daemon
if checkyesno sendmail_enable; then
        sendmail_submit_enable="NO"
        sendmail_outbound_enable="NO"
fi

# If sendmail_submit_enable=yes, don't need outbound daemon
if checkyesno sendmail_submit_enable; then
        sendmail_outbound_enable="NO"
fi

[ . . . ]

required_files=

if checkyesno sendmail_submit_enable; then
        name="sendmail_submit"
        rcvar="sendmail_submit_enable"
        _rc_restart_done=false
        run_rc_command "$1"
fi

if checkyesno sendmail_outbound_enable; then
        name="sendmail_outbound"
        rcvar="sendmail_outbound_enable"
        _rc_restart_done=false
        run_rc_command "$1"
fi

name="sendmail_msp_queue"
rcvar="sendmail_msp_queue_enable"
pidfile="${sendmail_msp_queue_pidfile:-/var/spool/clientmqueue/sm-client.pid}"
required_files="/etc/mail/submit.cf"
_rc_restart_done=false
run_rc_command "$1"
```

```
% grep -n msp /etc/rc.d/sendmail
35:     sendmail_msp_queue_enable="NO"
224:name="sendmail_msp_queue"
225:rcvar="sendmail_msp_queue_enable"
226:pidfile="${sendmail_msp_queue_pidfile:-/var/spool/clientmqueue/sm-client.pid}"
```

```
% grep -n -i queue /etc/rc.d/sendmail
35:     sendmail_msp_queue_enable="NO"
224:name="sendmail_msp_queue"
225:rcvar="sendmail_msp_queue_enable"
226:pidfile="${sendmail_msp_queue_pidfile:-/var/spool/clientmqueue/sm-client.pid}"
```

```
% grep -n '\-L' /etc/rc.d/sendmail
```

```
% grep -n msp /etc/rc.sendmail 
55:sendmail_mspq_pidfile=${sendmail_mspq_pidfile:-/var/spool/clientmqueue/sm-client.pid}
152:start_mspq()
159:                    case ${sendmail_msp_queue_enable} in
162:                            ${sendmail_program} ${sendmail_msp_queue_flags}
170:stop_mspq()
179:                    case ${sendmail_msp_queue_enable} in
190:    if [ -r ${sendmail_mspq_pidfile} ]; then
192:            kill -TERM `head -1 ${sendmail_mspq_pidfile}`
194:            echo "$0: stop-mspq: ${sendmail_mspq_pidfile} not found"
198:restart_mspq()
207:                    case ${sendmail_msp_queue_enable} in
218:    if [ -r ${sendmail_mspq_pidfile} ]; then
220:            kill -HUP `head -1 ${sendmail_mspq_pidfile}`
222:            echo "$0: restart-mspq: ${sendmail_mspq_pidfile} not found"
232:    start_mspq
237:    stop_mspq
242:    restart_mspq
257:start-mspq)
258:    start_mspq
261:stop-mspq)
262:    stop_mspq
265:restart-mspq)
266:    restart_mspq
272:    echo "       `basename $0` {start-mspq|stop-mspq|restart-mspq}" >&2
```

```
% grep -n queue /etc/rc.sendmail 
55:sendmail_mspq_pidfile=${sendmail_mspq_pidfile:-/var/spool/clientmqueue/sm-client.pid}
159:                    case ${sendmail_msp_queue_enable} in
161:                            echo -n ' sendmail-clientmqueue'
162:                            ${sendmail_program} ${sendmail_msp_queue_flags}
172:    # Check to make sure we are configured to start an MSP queue runner
179:                    case ${sendmail_msp_queue_enable} in
191:            echo -n ' sendmail-clientmqueue'
200:    # Check to make sure we are configured to start an MSP queue runner
207:                    case ${sendmail_msp_queue_enable} in
219:            echo -n ' sendmail-clientmqueue'
```

```
% grep -n '\-L' /etc/rc.sendmail 
```

```
% sudo grep -r sendmail_outbound_enable /etc/
/etc/rc.d/sendmail:     sendmail_outbound_enable="NO"
/etc/rc.d/sendmail:     sendmail_outbound_enable="NO"
/etc/rc.d/sendmail:     sendmail_outbound_enable="NO"
/etc/rc.d/sendmail:if checkyesno sendmail_outbound_enable; then
/etc/rc.d/sendmail:     rcvar="sendmail_outbound_enable"
/etc/defaults/rc.conf:sendmail_outbound_enable="YES"    # Dequeue stuck mail (YES/NO).
/etc/rc.sendmail:                       case ${sendmail_outbound_enable} in
/etc/rc.sendmail:                       case ${sendmail_outbound_enable} in
/etc/rc.sendmail:                       case ${sendmail_outbound_enable} in
```

```
% sudo grep -n sendmail_outbound_enable /etc/defaults/rc.conf 
604:sendmail_outbound_enable="YES"      # Dequeue stuck mail (YES/NO).
```

```
% sudo grep -n sendmail_outbound /etc/defaults/rc.conf
604:sendmail_outbound_enable="YES"      # Dequeue stuck mail (YES/NO).
605:sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
```

```
% sudo grep -n sm /etc/defaults/rc.conf | grep queue
605:sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
607:sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
```

```
% sudo grep -n msp /etc/defaults/rc.conf 
606:sendmail_msp_queue_enable="YES"     # Dequeue stuck clientmqueue mail (YES/NO).
607:sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
608:                            # Flags for sendmail_msp_queue daemon.
``` 

``` 
% sed -n 605,610p /etc/defaults/rc.conf
sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
sendmail_msp_queue_enable="YES" # Dequeue stuck clientmqueue mail (YES/NO).
sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
                                # Flags for sendmail_msp_queue daemon.
sendmail_rebuild_aliases="NO"   # Run newaliases if necessary (YES/NO).
 
```

```
% grep -n '\-L' /etc/defaults/rc.conf
598:sendmail_flags="-L sm-mta -bd -q30m" # Flags to sendmail (as a server)
602:sendmail_submit_flags="-L sm-mta -bd -q30m -ODaemonPortOptions=Addr=localhost"
605:sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
607:sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
```

```
% grep -n -i msp /etc/defaults/rc.conf
606:sendmail_msp_queue_enable="YES"     # Dequeue stuck clientmqueue mail (YES/NO).
607:sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
608:                            # Flags for sendmail_msp_queue daemon.
```

## SECURITY File: MSP (Message Submission Program), submit.cf File 

On FreeBSD 13:

```
$ sed -n 11,172p /usr/src/contrib/sendmail/src/SECURITY 
This file gives some hints how to configure and run sendmail for
people who are very security conscious (you should be...).

Even though sendmail goes through great lengths to assure that it
can't be compromised even if the system it is running on is
incorrectly or insecurely configured, it can't work around everything.
This has been demonstrated by recent OS problems which have
subsequently been used to compromise the root account using sendmail
as a vector.  One way to minimize the possibility of such problems
is to install sendmail without set-user-ID root, which avoids local
exploits.  This configuration, which is the default starting with
8.12, is described in the first section of this security guide.


*****************************************************
** sendmail configuration without set-user-ID root **
*****************************************************

sendmail needs to run as root for several purposes:

- bind to port 25
- call the local delivery agent (LDA) as root (or other user) if the LDA
  isn't set-user-ID root (unless some other method of storing e-mail in
  local mailboxes is used).
- read .forward files
- write e-mail submitted via the command line to the queue directory.

Only the last item requires a set-user-ID/set-group-ID program to
avoid problems with a world-writable directory.  It is however
sufficient to have a set-group-ID program and a group-writable
queue directory.  The other requirements listed above can be
fulfilled by a sendmail daemon that is started by root.  Hence this
section explains how to use two sendmail configurations to accomplish
the goal to have a sendmail binary that is not set-user-ID root,
and hence is not open to system configuration/OS problems or at
least less problematic in presence of those.

The default configuration starting with sendmail 8.12 uses one
sendmail binary which acts differently based on operation mode and
supplied options.

sendmail must be a set-group-ID (default group: smmsp, recommended
gid: 25) program to allow for queueing mail in a group-writable
directory.  Two .cf files are required:  sendmail.cf for the daemon
and submit.cf for the submission program.  The following permissions
should be used:

-r-xr-sr-x      root   smmsp    ... /PATH/TO/sendmail
drwxrwx---      smmsp  smmsp    ... /var/spool/clientmqueue
drwx------      root   wheel    ... /var/spool/mqueue
-r--r--r--      root   wheel    ... /etc/mail/sendmail.cf
-r--r--r--      root   wheel    ... /etc/mail/submit.cf

[Notice: On some OS "wheel" is not used but "bin" or "root" instead,
however, this is not important here.]

That is, the owner of sendmail is root, the group is smmsp, and
the binary is set-group-ID.  The client mail queue is owned by
smmsp with group smmsp and is group writable.  The client mail
queue directory must be writable by smmsp, but it must not be
accessible for others. That is, do not use world read or execute
permissions.  In submit.cf the option UseMSP must be set, and
QueueFileMode must be set to 0660.  submit.cf is available in
cf/cf/, which has been built from cf/cf/submit.mc.  The file can
be used as-is, if you want to add more options, use cf/cf/submit.mc
as starting point and read cf/README:  MESSAGE SUBMISSION PROGRAM
carefully.

The .cf file is chosen based on the operation mode.  For -bm (default),
-bs, and -t it is submit.cf (if it exists) for all others it is
sendmail.cf.  This selection can be changed by -Ac or -Am (alternative
.cf file: client or mta).

The daemon must be started by root as usual, e.g.,

/PATH/TO/sendmail -L sm-mta -bd -q1h

(replace /PATH/TO with the right path for your OS, e.g.,
/usr/sbin or /usr/lib).

Notice: if you run sendmail from inetd (which in general is not a
good idea), you must specify -Am in addition to -bs.

Mail will end up in the client queue if the daemon doesn't accept
connections or if an address is temporarily not resolvable.  The
latter problem can be minimized by using

        FEATURE(`nocanonify', `canonify_hosts')
        define(`confDIRECT_SUBMISSION_MODIFIERS', `C')

which, however, may have undesired side effects.  See cf/README for
a discussion.  In general it is necessary to clean the queue either
via a cronjob or by running a daemon, e.g.,

/PATH/TO/sendmail -L sm-msp-queue -Ac -q30m

If the option UseMSP is not set, sendmail will complain during
queue runs about bogus file permission.  If you want a queue runner
for the client queue, you probably have to change OS specific
scripts to accomplish this (check the man pages of your OS for more
information.)  You can start this program as root, it will change
its user id to RunAsUser (smmsp by default, recommended uid: 25).
This way smmsp does not need a valid shell.

Summary
-------

This is a brief summary how the two configuration files are used:

sendmail.cf     For the MTA (mail transmission agent)
        The MTA is started by root as daemon:

                /PATH/TO/sendmail -L sm-mta -bd -q1h

        it accepts SMTP connections (on ports 25 and 587 by default);
        it runs the main queue (/var/spool/mqueue by default).

submit.cf       For the MSP (mail submission program)
        The MSP is used to submit e-mails, hence it is invoked
        by programs (and maybe users); it does not run as SMTP
        daemon; it uses /var/spool/clientmqueue by default; it
        can be started to run that queue periodically:

                /PATH/TO/sendmail -L sm-msp-queue -Ac -q30m


Hints and Troubleshooting
-------------------------

RunAsUser: FEATURE(`msp') sets the option RunAsUser to smmsp.
This user must have the group smmsp, i.e., the same group as the
clientmqueue directory.  If you specify a user whose primary group
is not the same as that of the clientmqueue directory, then you
should explicitly set the group, e.g.,

        FEATURE(`msp')
        define(`confRUN_AS_USER', `mailmsp:smmsp')

STARTTLS: If sendmail is compiled with STARTTLS support on a platform
that does not have HASURANDOMDEV defined, you either need to specify
the RandFile option (as for the MTA), or you have to turn off
STARTTLS in the MSP, e.g.,

        DAEMON_OPTIONS(`Name=NoMTA, Addr=127.0.0.1, M=S')
        FEATURE(`msp')
        CLIENT_OPTIONS(`Family=inet, Address=0.0.0.0, M=S')

The first option is used to turn off STARTTLS when the MSP is
invoked with -bs as some MUAs do.


What doesn't work anymore
-------------------------

Normal users can't use mailq anymore to see the MTA mail queue.
There are several ways around it, e.g., changing QueueFileMode
or giving users access via a program like sudo.

sendmail -bv may give misleading output for normal users since it
may not be able to access certain files, e.g., .forward files of
other users.
```

```
$ ls /usr/local/share/sendmail/cf/cf/submit*
/usr/local/share/sendmail/cf/cf/submit.cf
/usr/local/share/sendmail/cf/cf/submit.mc
```

### Good Information about the submit.cf (submit.mc) 

```
$ wc -l /usr/local/share/sendmail/cf/feature/msp.m4
      78 /usr/local/share/sendmail/cf/feature/msp.m4
```

```
$ cat /usr/local/share/sendmail/cf/feature/msp.m4
divert(-1)
#
# Copyright (c) 2000-2002, 2004 Proofpoint, Inc. and its suppliers.
#       All rights reserved.
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the sendmail distribution.
#
#

divert(0)dnl
VERSIONID(`$Id: msp.m4,v 1.34 2013-11-22 20:51:11 ca Exp $')
divert(-1)
undefine(`ALIAS_FILE')
define(`confDELIVERY_MODE', `i')
define(`confUSE_MSP', `True')
define(`confFORWARD_PATH', `')
define(`confPRIVACY_FLAGS', `goaway,noetrn,restrictqrun')
define(`confDONT_PROBE_INTERFACES', `True')
dnl ---------------------------------------------
dnl run as this user (even if called by root)
ifdef(`confRUN_AS_USER',,`define(`confRUN_AS_USER', `smmsp')')
ifdef(`confTRUSTED_USER',,`define(`confTRUSTED_USER',
`ifelse(index(confRUN_AS_USER,`:'), -1, `confRUN_AS_USER',
`substr(confRUN_AS_USER,0,index(confRUN_AS_USER,`:'))')')')
dnl ---------------------------------------------
dnl This queue directory must have the same group
dnl as sendmail and it must be group-writable.
dnl notice: do not test for QUEUE_DIR, it is set in some ostype/*.m4 files
ifdef(`MSP_QUEUE_DIR',
`define(`QUEUE_DIR', `MSP_QUEUE_DIR')',
`define(`QUEUE_DIR', `/var/spool/clientmqueue')')
define(`_MTA_HOST_', ifelse(defn(`_ARG_'), `', `[localhost]', `_ARG_'))
define(`_MSP_FQHN_',`dnl used to qualify addresses
ifdef(`MASQUERADE_NAME', ifdef(`_MASQUERADE_ENVELOPE_', `$M', `$j'), `$j')')
ifelse(_ARG2_, `MSA', `define(`RELAY_MAILER_ARGS', `TCP $h 587')')
dnl ---------------------------------------------
ifdef(`confPID_FILE', `dnl',
`define(`confPID_FILE', QUEUE_DIR`/sm-client.pid')')
define(`confQUEUE_FILE_MODE', `0660')dnl
ifdef(`STATUS_FILE',
`define(`_F_',
`define(`_b_', index(STATUS_FILE, `sendmail.st'))ifelse(_b_, `-1', `STATUS_FILE', `substr(STATUS_FILE, 0, _b_)sm-client.st')')
define(`STATUS_FILE', _F_)
undefine(`_b_') undefine(`_F_')',
`define(`STATUS_FILE', QUEUE_DIR`/sm-client.st')')
FEATURE(`no_default_msa')dnl
ifelse(defn(`_DPO_'), `',
`DAEMON_OPTIONS(`Name=NoMTA, Addr=127.0.0.1, M=E')dnl')
define(`_DEF_LOCAL_MAILER_FLAGS', `')dnl
define(`_DEF_LOCAL_SHELL_FLAGS', `')dnl
define(`LOCAL_MAILER_PATH', `[IPC]')dnl
define(`LOCAL_MAILER_FLAGS', `lmDFMuXkw5')dnl
define(`LOCAL_MAILER_ARGS', `TCP $h')dnl
define(`LOCAL_MAILER_DSN_DIAGNOSTIC_CODE', `SMTP')dnl
define(`LOCAL_SHELL_PATH', `[IPC]')dnl
define(`LOCAL_SHELL_FLAGS', `lmDFMuXk5')dnl
define(`LOCAL_SHELL_ARGS', `TCP $h')dnl
MODIFY_MAILER_FLAGS(`SMTP', `+k5')dnl
MODIFY_MAILER_FLAGS(`ESMTP', `+k5')dnl
MODIFY_MAILER_FLAGS(`DSMTP', `+k5')dnl
MODIFY_MAILER_FLAGS(`SMTP8', `+k5')dnl
MODIFY_MAILER_FLAGS(`RELAY', `+k')dnl
MAILER(`local')dnl
MAILER(`smtp')dnl

LOCAL_CONFIG
D{MTAHost}_MTA_HOST_

LOCAL_RULESETS
SLocal_localaddr
R$+                     $: $>ParseRecipient $1
R$* < @ $+ > $*         $#relay $@ ${MTAHost} $: $1 < @ $2 > $3
ifdef(`_USE_DECNET_SYNTAX_',
`# DECnet
R$+ :: $+               $#relay $@ ${MTAHost} $: $1 :: $2', `dnl')
R$*                     $#relay $@ ${MTAHost} $: $1 < @ _MSP_FQHN_ >
```

An example:

[Force sendmail to connect to itself - Sendmail newsgroup](https://groups.google.com/g/comp.mail.sendmail/c/vKQ1dm3Od5Q/m/oJxSQikeBQAJ)


### submit.cf - Flow

[sendmail.cf and submit.cf File - IBM Documentation - AIX Sendmail](https://www.ibm.com/docs/en/aix/7.2?topic=files-sendmailcf-submitcf-file):

> The **sendmail** command uses the `submit.cf` configuration file
> **by default**. The `sendmail.cf` file exists for compatibility with
> earlier versions of the **sendmail** command.  The following information
> is valid for both `sendmail.cf` and `submit.cf` configuration files.



[Creating the Message Submission Program file submit.cf - NOTE that this is for z/OS:](https://www.ibm.com/docs/en/zos/2.1.0?topic=sendmail-creating-message-submission-program-file-submitcf): 

> *Sendmail* needs to run as root for several reasons.  The Message
> Submission Program (MSP) configuration file `submit.cf` eliminates the
> need for *sendmail* to run as root to write email that is **submitted from
> the command line** to the **queue directory**.
> 
> MSP requires a set-user-ID/set-group-ID program to avoid problems with
> a world-writable directory.  It is, however, sufficient to have a
> set-group-ID program and a group-writable queue directory.  This can be
> fulfilled by a *sendmail* daemon that is started by root.  This topic
> explains how to use two *sendmail* configurations to accomplish the goal
> of having a *sendmail* binary file that is not set-user-ID root, and thus
> is less problematic in the presence of system configuration and OS problems.
> 
> The default configuration, starting with sendmail 8.12, uses one
> *sendmail* binary file that acts **differently** based on
> **operation mode** and **supplied options**.  When running in a program
> control environment, two binary files are used, `/usr/sbin/sendmail` and
`/bin/sendmail`.
> 
> [ . . . ]
>  
> **Sendmail** must be a set-group-ID (default group: smmspgrp, recommended
> gid: 25) program to allow for queueing mail in a group-writable directory.
> Two `.cf` files are required, `sendmail.cf` for the **daemon** and
> `submit.cf` for the **submission program**. 
> 
> [ . . . ]    
> 
> That is, the owner of *sendmail* is root, the group is smmspgrp, and the
> binary file is set-group-ID.  The client mail queue is owned by smmsp
> with group smmspgrp and is group writable.  The client mail queue
> directory must be writable by smmspgrp, but it must not be accessible
> for others.  That is, do not use world read or execute permissions.
> In `submit.cf`, the option `UseMSP` must be set, and `QueueFileMode`
> must be set to 0660.
> 
> [ . . . ] 
> 
> Some features are not intended to work with the MSP.  These include
> features that influence the delivery process (for example, mailertable,
> aliases), or those that are important only for an SMTP server (for
> example, virtusertable, DaemonPortOptions, multiple queues).  Moreover,
> relaxing certain restrictions (RestrictQueueRun, permissions on queue
> directory) or adding features (for example, enabling prog/file mailer)
> can cause security problems.
> 
> Other things do not work well with the MSP and require tweaking or
> workarounds.  For example, to allow for client authentication, it is not
> sufficient to just provide a client certificate and the corresponding
> key, but it is also necessary to make the key group (smmsp) readable and
> tell sendmail not to complain about it as follows:
> 
> ```
> define(`confDONT_BLAME_SENDMAIL', `GroupReadableKeyFile')
> ```
> 
> When **FEATURE(`msp')** is coded, the *sendmail* **client** will send
> **all mail to the local mail server**.   
> **If** using the *sendmail* server as the **local mail server**, review
> the **RELAY_DOMAIN()** for the *sendmail* **server**.  If needed, the
> *sendmail* **client** can be configured to send mail to a different
> server with this feature.
>
> 
> The `feature/msp.m4` (on FreeBSD 13, in:
> `/usr/local/share/sendmail/cf/feature/msp.m4`) defines almost all
> settings for the MSP.  Most of these should not be changed at all.
> Some of the features and options can be overridden if really necessary.
> It is a bit tricky to do this, because it depends on the actual way the
> option is defined in `feature/msp.m4`.  If it is directly defined [that
> is, with define()], the modified value must be defined after the following
> line:
> 
> ```
> FEATURE(`msp')
> ```
> 
> If it is conditionally defined [that is, with ifdef()], the wanted value
> must be defined before the FEATURE line in the `.mc` file.  To see how
> the options are defined, read `feature/msp.m4`.
> 
> The `.cf` file (`sendmail.cf` **or** `submit.cf`) is **chosen** based on the
> **operation mode**.  For `-bm` (**default**), `-bs`, and `-t`, it is
> `submit.cf`, if it exists.  For **all others**, it is `sendmail.cf`.
> This selection **can be changed** by `-Ac` (to use `submit.cf`) **or**
> `-Am` (to use `sendmail.cf`).
> 
> The *daemon* **must** be started by **root** as usual, for example:
> 
> ```
> /usr/sbin/sendmail -L sm-mta -bd -q1h
> ```


[Make /usr/lib/sendmail deliver local mail locally (submit.cf vs sendmail.cf)](https://serverfault.com/questions/266326/make-usr-lib-sendmail-deliver-local-mail-locally-submit-cf-vs-sendmail-cf):

> You can start sendmail with the `-Am` switch and not use `submit.cf` at all.
> Or you can have a *sendmail* daemon listen in some other port and then
> tweak `submit.cf` to deliver there instead of port 25.


### The `/etc/rc.sendmail` - Flow


```
$ grep sendmail /etc/defaults/rc.conf
mta_start_script="/etc/rc.sendmail"
# Settings for /etc/rc.sendmail and /etc/rc.d/sendmail:
sendmail_enable="NO"    # Run the sendmail inbound daemon (YES/NO).
sendmail_pidfile="/var/run/sendmail.pid"        # sendmail pid file
sendmail_procname="/usr/sbin/sendmail"          # sendmail process name
sendmail_flags="-L sm-mta -bd -q30m" # Flags to sendmail (as a server)
sendmail_cert_create="YES"      # Create a server certificate if none (YES/NO)
#sendmail_cert_cn="CN"          # CN of the generate certificate
sendmail_submit_enable="YES"    # Start a localhost-only MTA for mail submission
sendmail_submit_flags="-L sm-mta -bd -q30m -ODaemonPortOptions=Addr=localhost"
sendmail_outbound_enable="YES"  # Dequeue stuck mail (YES/NO).
sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
sendmail_msp_queue_enable="YES" # Dequeue stuck clientmqueue mail (YES/NO).
sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
                                # Flags for sendmail_msp_queue daemon.
sendmail_rebuild_aliases="NO"   # Run newaliases if necessary (YES/NO).
```

```
# The sendmail binary
sendmail_program=${sendmail_program:-/usr/sbin/sendmail}
```

```
$ /usr/sbin/sendmail -bt -d0 < /dev/null 
Version 8.17.1
 Compiled with: DANE DNSMAP IPV6_FULL LOG MAP_REGEX MATCHGECOS MILTER
                MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6 NETUNIX NEWDB NIS
                PICKY_HELO_CHECK PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS
                TLS_EC TLS_VRFY_PER_CTX USERDB XDEBUG
[ . . . ]
```

```
# The pid is used to stop and restart the running daemon(s).
sendmail_pidfile=${sendmail_pidfile:-/var/run/sendmail.pid}
sendmail_mspq_pidfile=${sendmail_mspq_pidfile:-/var/spool/clientmqueue/sm-client.pid}
```

```
$ sudo service sendmail status
Password:
sendmail is running as pid 45131.
sendmail_msp_queue is running as pid 45134.
``` 

``` 
$ sudo cat /var/run/sendmail.pid
45131
/usr/sbin/sendmail -L sm-mta -bd -q30m
```

```
$ sudo cat /var/spool/clientmqueue/sm-client.pid
45134
/usr/sbin/sendmail -L sm-msp-queue -Ac -q30m
```

```
start_mta()
{
  case ${sendmail_enable} in
    [Yy][Ee][Ss])
      echo -n ' sendmail'
        ${sendmail_program} ${sendmail_flags}

[ . . . ] 
  case ${sendmail_outbound_enable} in
    [Yy][Ee][Ss])
      echo -n ' sendmail-outbound'

[ . . . ]
```

```
$ grep sendmail_flags /etc/defaults/rc.conf
sendmail_flags="-L sm-mta -bd -q30m" # Flags to sendmail (as a server)
```

```
$ grep sendmail_outbound_flags /etc/defaults/rc.conf
sendmail_outbound_flags="-L sm-queue -q30m" # Flags to sendmail (outbound only)
```

results in:

`echo -n ' sendmail' /usr/sbin/sendmail -L sm-mta -bd -q30m`

`echo -n ' sendmail-outbound' /usr/sbin/sendmail -L sm-queue -q30m`


```
start_mspq()

  case ${sendmail_enable} in
    [Nn][Oo][Nn][Ee])
      ;;
  *)
    if [ -r /etc/mail/submit.cf ]; then
      case ${sendmail_msp_queue_enable} in
        [Yy][Ee][Ss])
          echo -n ' sendmail-clientmqueue'
            ${sendmail_program} ${sendmail_msp_queue_flags}
            ;;
        esac
    fi
    ;;
  esac
}
```

```
$ grep sendmail_msp_queue_flags /etc/defaults/rc.conf
sendmail_msp_queue_flags="-L sm-msp-queue -Ac -q30m"
```

results in:

`echo -n ' sendmail' /usr/sbin/sendmail -L sm-msp-queue -Ac -q30m`


```
# If no argument is given, assume we are being called at boot time.
_action=${1:-start}

case ${_action} in
start)
        start_mta
        start_mspq
        ;;

[ . . . ]
```

```
  echo "usage: `basename $0` {start|stop|restart}" >&2
  echo "       `basename $0` {start-mta|stop-mta|restart-mta}" >&2
  echo "       `basename $0` {start-mspq|stop-mspq|restart-mspq}" >&2
```

```
$ ls -lh /etc/rc.sendmail
-rw-r--r--  1 root  wheel   5.6K Aug 17  2021 /etc/rc.sendmail
 
$ /etc/rc.sendmail
/etc/rc.sendmail: Permission denied.
 
$ sudo /etc/rc.sendmail
sudo: /etc/rc.sendmail: command not found
```

```
$ sudo sh /etc/rc.sendmail
 sendmail sendmail-clientmqueue$ 
```

```
$ sudo sh /etc/rc.sendmail status
usage: rc.sendmail {start|stop|restart}
       rc.sendmail {start-mta|stop-mta|restart-mta}
       rc.sendmail {start-mspq|stop-mspq|restart-mspq}
```

```
$ sudo service sendmail stop
```

```
$ ps aux | grep -v grep | grep sendmail
```

```
$ sudo service sendmail start
Starting sendmail.
Starting sendmail_msp_queue.
``` 

```
$ ps aux | grep -v grep | grep sendmail
root      495   0.0  0.0    18976    8264  -  Ss   11:41        0:00.00 sendmail: accepting connections (sendmail)
smmsp     499   0.0  0.0    18316    7276  -  Is   11:41        0:00.00 sendmail: Queue runner@00:30:00 for /var/spool/clientmqueue (sendmail)
``` 

``` 
$ date
Thu 24 Nov 2022 11:41:33 PST
```

```
$ ls -lh /var/run/sendmail.pid 
-rw-------  1 root  wheel    43B Nov 24 11:41 /var/run/sendmail.pid
``` 
 
```
$ sudo cat /var/run/sendmail.pid
495
/usr/sbin/sendmail -L sm-mta -bd -q30m
```


```
$ sudo ls -lh /var/spool/clientmqueue/sm-client.pid
-rw-------  1 smmsp  smmsp    49B Nov 24 11:41 /var/spool/clientmqueue/sm-client.pid
``` 

```
$ sudo cat /var/spool/clientmqueue/sm-client.pid
499
/usr/sbin/sendmail -L sm-msp-queue -Ac -q30m
```

```
$ tail /var/log/maillog
[ . . . ]
Nov 24 11:41:28 fbsd1 sm-mta[495]: starting daemon (8.17.1): SMTP+queueing@00:30:00
[ . . . ]
Nov 24 11:41:28 fbsd1 sm-mta[495]: STARTTLS=server, init=1
Nov 24 11:41:28 fbsd1 sm-mta[495]: started as: /usr/sbin/sendmail -L sm-mta -bd -q30m
Nov 24 11:41:28 fbsd1 sm-msp-queue[499]: starting daemon (8.17.1): queueing@00:30:00
Nov 24 11:41:28 fbsd1 sm-msp-queue[499]: started as: /usr/sbin/sendmail -L sm-msp-queue -Ac -q30m
```

```
$ sudo service sendmail stop
```

```
$ date
Thu 24 Nov 2022 12:07:11 PST
```

```
$ tail /var/log/maillog
[ . . . ]
Nov 24 12:07:02 fbsd1 sm-mta[495]: NOQUEUE: stopping daemon, reason=signal
Nov 24 12:07:02 fbsd1 sm-msp-queue[499]: 2AOJfSZ7000498: stopping daemon, reason=signal
```


### The `/etc/rc.d/sendmail` - Flow

```
$ ls -lh /etc/rc.d/sendmail
-r-xr-xr-x  1 root  wheel   6.4K Aug 17  2021 /etc/rc.d/sendmail
```
 
```
$ /etc/rc.d/sendmail
Usage: /etc/rc.d/sendmail [fast|force|one|quiet](start|stop|restart|rcvar|enable|disable|delete|enabled|describe|extracommands|status|poll)
```
 
```
$ /etc/rc.d/sendmail status
sendmail is not running.
sendmail_msp_queue is not running.
```

```
$ /etc/rc.d/sendmail describe
Electronic mail transport agent
Electronic mail transport agent
```

```
$ /etc/rc.d/sendmail start
Starting sendmail.
limits: setrlimit datasize: Operation not permitted
/etc/rc.d/sendmail: WARNING: failed to start sendmail
Starting sendmail_msp_queue.
limits: setrlimit datasize: Operation not permitted
/etc/rc.d/sendmail: WARNING: failed to start sendmail_msp_queue
```

```
$ sudo /etc/rc.d/sendmail start
Password:
Starting sendmail.
Starting sendmail_msp_queue.
```

```
$ sudo /etc/rc.d/sendmail status
sendmail is running as pid 3527.
sendmail_msp_queue is running as pid 3531.
```

```
$ date
Thu 24 Nov 2022 12:36:18 PST
``` 

``` 
$ ps aux | grep -v grep | grep sendmail
root     3527   0.0  0.0    18976    8268  -  Ss   12:36        0:00.00 sendmail: accepting connections (sendmail)
smmsp    3531   0.0  0.0    18316    7284  -  Is   12:36        0:00.00 sendmail: Queue runner@00:30:00 for /var/spool/clientmqueue (sendmail)
```

```
$ ls -lh /var/run/sendmail.pid
-rw-------  1 root  wheel    44B Nov 24 12:36 /var/run/sendmail.pid
``` 

``` 
$ sudo cat /var/run/sendmail.pid
3527
/usr/sbin/sendmail -L sm-mta -bd -q30m
```

```
$ sudo ls -lh /var/spool/clientmqueue/sm-client.pid
-rw-------  1 smmsp  smmsp    50B Nov 24 12:36 /var/spool/clientmqueue/sm-client.pid
```

```
$ sudo cat /var/spool/clientmqueue/sm-client.pid
3531
/usr/sbin/sendmail -L sm-msp-queue -Ac -q30m
```


### Trace the Flow with `dtrace(1)`

```
$ command -v dtrace ; type dtrace ; which dtrace ; whereis dtrace
/usr/sbin/dtrace
dtrace is /usr/sbin/dtrace
/usr/sbin/dtrace
dtrace: /usr/sbin/dtrace /usr/share/man/man1/dtrace.1.gz
```

```
$ pkg info --regex dtrace
```

```
$ pkg search --regex ^dtrace
dtrace-toolkit-1.0_7           Collection of useful scripts for DTrace
```

```
$ sudo pkg install dtrace-toolkit  
[ . . . ]
=====
Message from dtrace-toolkit-1.0_7:

--
Many of the DTraceToolkit scripts do not work on FreeBSD at the moment,
usually because:
- They are using Solaris-specific features
- They use probes which are not supported yet on FreeBSD

Some popular scripts are installed at:

    /usr/local/bin

The rest of the scripts and other toolkit files can be found in:

    /usr/local/share/dtrace-toolkit

To view the manual pages in the "1m" manual section,
the section has to be specified explicitly, e.g.:

    man -s 1m fddist
```

```
$ find /usr/local/bin/ -name '*dtrace*'
``` 

``` 
$ find /usr/local/bin/ -lname '*dtrace*'
/usr/local/bin/opensnoop
/usr/local/bin/dtruss
/usr/local/bin/hotkernel
/usr/local/bin/procsystime
/usr/local/bin/shellsnoop
```

```
$ stat -f "%N: %HT%SY" /usr/local/bin/* | grep dtrace
/usr/local/bin/dtruss: Symbolic Link -> ../share/dtrace-toolkit/dtruss
/usr/local/bin/hotkernel: Symbolic Link -> ../share/dtrace-toolkit/hotkernel
/usr/local/bin/opensnoop: Symbolic Link -> ../share/dtrace-toolkit/opensnoop
/usr/local/bin/procsystime: Symbolic Link -> ../share/dtrace-toolkit/procsystime
/usr/local/bin/shellsnoop: Symbolic Link -> ../share/dtrace-toolkit/Apps/shellsnoop
```

```
$ ls -F /usr/local/share/dtrace-toolkit/
Apps/           errinfo*        iosnoop*        Notes/          rwtop*
Bin/            Examples/       iotop*          opensnoop*      Shell/
CDDL@           execsnoop*      Java/           Perl/           Snippits/
Code/           FS/             JavaScript/     Php/            statsnoop*
Cpu/            Guide           Kernel/         Proc/           System/
dexplorer*      hotkernel*      Locks/          procsystime*    Tcl/
Disk/           hotuser*        Man/            Python/         User/
Docs/           Include/        Mem/            README.md       Version
dtruss*         install*        Misc/           Ruby/           Zones/
dvmstat*        iopattern*      Net/            rwsnoop*
```

```
$ sudo /usr/local/share/dtrace-toolkit/FS/vfssnoop.d > /tmp/vfssnoopout.txt
```


**NOTE:**  
Instead of the `vfssnoop.d` script, you could use this command with similar effect:

`# dtrace -n 'syscall::open*:entry { printf("%s %s", execname, copyinstr(arg0)); }'`	


From another shell instance:

```
$ printf %s\\n "Testing." | mail -v -s "Test" dusko
dusko... Connecting to [127.0.0.1] via relay...
220 fbsd1.home.arpa ESMTP Sendmail 8.17.1/8.17.1; Thu, 24 Nov 2022 20:27:30 -0800 (PST)
>>> EHLO fbsd1.home.arpa
250-fbsd1.home.arpa Hello localhost [127.0.0.1], pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-8BITMIME
250-SIZE
250-DSN
250-STARTTLS
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
>>> MAIL From:<dusko@fbsd1.home.arpa> SIZE=34
250 2.1.0 <dusko@fbsd1.home.arpa>... Sender ok
>>> RCPT To:<dusko@fbsd1.home.arpa>
>>> DATA
250 2.1.5 <dusko@fbsd1.home.arpa>... Recipient ok
354 Enter mail, end with "." on a line by itself
>>> .
250 2.0.0 2AP4RUKS027991 Message accepted for delivery
dusko... Sent (2AP4RUKS027991 Message accepted for delivery)
Closing connection to [127.0.0.1]
>>> QUIT
221 2.0.0 fbsd1.home.arpa closing connection
```

Use the **Ctrl+C** key combination to stop the process.

```
$ sudo /usr/local/share/dtrace-toolkit/FS/vfssnoop.d > /tmp/vfssnoopout.txt
^C
```

FORMAT:

```
TIMESTAMP           UID    PID PROCESS          CALL             SIZE PATH/FILE
```

**NOTE:** Removed **TIMESTAMP** column.
 
```
 UID    PID PROCESS       CALL             SIZE PATH/FILE

1001  27989 tcsh          vop_open         - /usr/bin/mail
1001  27989 mail          vop_close        - /usr/bin/mail

1001  27989 mail          vop_open         - /etc/mail.rc
1001  27989 mail          vop_read        4K /etc/mail.rc
1001  27989 mail          vop_close        - /etc/mail.rc

1001  27989 mail          vop_open         - /usr/home/dusko/.mailrc
1001  27989 mail          vop_open         - /usr/home/dusko/.mail_aliases
1001  27989 mail          vop_read        4K /usr/home/dusko/.mail_aliases
1001  27989 mail          vop_close        - /usr/home/dusko/.mail_aliases
1001  27989 mail          vop_close        - /usr/home/dusko/.mailrc

1001  27989 mail          vop_create       - /tmp/mail.RsH2UdGjzkoo
1001  27989 mail          vop_open         - /tmp/<unknown>
1001  27989 mail          vop_getattr      - /tmp/mail.RsH2UdGjzkoo
1001  27989 mail          vop_remove       - /tmp/mail.RsH2UdGjzkoo

1001  27989 mail          vop_create       - /tmp/mail.RstbRvvCU6oB
1001  27989 mail          vop_open         - /tmp/<unknown>
1001  27989 mail          vop_open         - /tmp/mail.RstbRvvCU6oB
1001  27989 mail          vop_remove       - /tmp/mail.RstbRvvCU6oB

1001  27990 mail          vop_open         - /usr/sbin/mailwrapper
1001  27990 mailwrapper   vop_close        - /usr/sbin/mailwrapper

1001  27990 mailwrapper   vop_open         - /usr/local/etc/mail/mailer.conf

1001  27990 mailwrapper   vop_open         - /usr/local/sbin/sendmail
1001  27990 sendmail      vop_close        - /usr/local/sbin/sendmail

1001  27990 sendmail      vop_open         - /etc/libmap.conf
1001  27990 sendmail      vop_getattr      - /etc/libmap.conf
1001  27990 sendmail      vop_read       47B /etc/libmap.conf
1001  27990 sendmail      vop_close        - /etc/libmap.conf

1001  27990 sendmail      vop_open         - /usr/local/etc/libmap.d
[...]
1001  27990 sendmail      vop_close        - /usr/local/etc/libmap.d

1001  27990 sendmail      vop_open         - /usr/local/etc/libmap.d/mesa.conf
[...]
1001  27990 sendmail      vop_close        - /usr/local/etc/libmap.d/mesa.conf

1001  27990 sendmail      vop_open         - /var/run/ld-elf.so.hints
[...]
1001  27990 sendmail      vop_close        - /var/run/ld-elf.so.hints

1001  27990 sendmail      vop_open         - /usr/lib/libwrap.so.6
[...]
1001  27990 sendmail      vop_close        - /usr/lib/libwrap.so.6

1001  27990 sendmail      vop_open         - /usr/local/lib/libsasl2.so.3.0.0
[...]
1001  27990 sendmail      vop_close        - /usr/local/lib/libsasl2.so.3.0.0

1001  27990 sendmail      vop_open         - /usr/lib/libblacklist.so.0
[...]
1001  27990 sendmail      vop_close        - /usr/lib/libblacklist.so.0

1001  27990 sendmail      vop_open         - /usr/lib/libssl.so.111
[...]
1001  27990 sendmail      vop_close        - /usr/lib/libssl.so.111

1001  27990 sendmail      vop_open         - /lib/libcrypto.so.111
[...]
1001  27990 sendmail      vop_close        - /lib/libcrypto.so.111

1001  27990 sendmail      vop_open         - /lib/libutil.so.9
[...] 
1001  27990 sendmail      vop_close        - /lib/libutil.so.9

1001  27990 sendmail      vop_open         - /lib/libc.so.7
[...]
1001  27990 sendmail      vop_close        - /lib/libc.so.7

1001  27990 sendmail      vop_open         - /usr/lib/libdl.so.1
[...]
1001  27990 sendmail      vop_close        - /usr/lib/libdl.so.1

1001  27990 sendmail      vop_open         - /lib/libthr.so.3
[...]
1001  27990 sendmail      vop_close        - /lib/libthr.so.3

1001  27990 sendmail      vop_getattr      - /tmp/<unknown>
1001  27990 sendmail      vop_getattr      - /dev/<unknown>

1001  27990 sendmail      vop_open         - /etc/nsswitch.conf
[...]

1001  27990 sendmail      vop_open         - /etc/pwd.db
[...]
1001  27990 sendmail      vop_close        - /etc/pwd.db

1001  27990 sendmail      vop_open         - /etc/resolv.conf
[...]
1001  27990 sendmail      vop_close        - /etc/resolv.conf

1001  27990 sendmail      vop_open         - /etc/hosts
[...]
1001  27990 sendmail      vop_close        - /etc/hosts

                                           - /etc/localtime 
                                           - /usr/share/zoneinfo/posixrules
                                           - /usr/share/zoneinfo/UTC

1001  27990 sendmail      vop_open         - /etc/mail/submit.cf

1001  27990 sendmail      vop_open         - /etc/pwd.db
[...]
1001  27990 sendmail      vop_close        - /etc/pwd.db

1001  27990 sendmail      vop_read       41K /etc/mail/submit.cf
1001  27990 sendmail      vop_close        - /etc/mail/submit.cf

1001  27990 sendmail      vop_getattr      - /var/spool/clientmqueue

1001  27990 sendmail      vop_close        - /lib/libcrypto.so.111

   0    974 syslogd       vop_write      97B /var/log/debug.log

1001  27990 sendmail      vop_read      260B /etc/pwd.db
[...]
1001  27990 sendmail      vop_close        - /etc/pwd.db

1001  27990 sendmail      vop_create       - /var/spool/clientmqueue/df2AP4RU3I027990

1001  27990 sendmail      vop_create       - /var/spool/clientmqueue/qf2AP4RU3I027990

1001  27990 sendmail      vop_open         - /etc/services
[...]
1001  27990 sendmail      vop_close        - /etc/services

1001  27990 sendmail      vop_open         - /etc/hosts
[...]
1001  27990 sendmail      vop_open         - /etc/hosts

0       974 syslogd       vop_write      90B /var/log/maillog

0     27991 sendmail      vop_getattr      - /etc/resolv.conf

0     27991 sendmail      vop_open         - /etc/hosts
0     27991 sendmail      vop_read        4K /etc/hosts
[...]
0     27991 sendmail      vop_close        - /etc/hosts

0     27991 sendmail      vop_open         - /etc/services
[...]
0     27991 sendmail      vop_close        - /etc/services

0       974 syslogd       vop_write      81B /var/log/maillog

0     27991 sendmail      vop_open         - /etc/hosts.allow
[...]
0     27991 sendmail      vop_close        - /etc/hosts.allow

0       974 syslogd       vop_write      78B /var/log/maillog
[...]
[...]

1001  27990 sendmail      vop_open         - /etc/ssl/openssl.cnf
[...]
1001  27990 sendmail      vop_close        - /etc/ssl/openssl.cnf

1001  27990 sendmail      vop_open         - /usr/lib/libssl.so.111
1001  27990 sendmail      vop_getattr      - /usr/lib/libssl.so.111
1001  27990 sendmail      vop_close        - /usr/lib/libssl.so.111

   0    974 syslogd       vop_write      63B /var/log/maillog

   0    974 syslogd       vop_write      97B /var/log/debug.log

   0  27991 sendmail      vop_open         - /var/log/sendmail.st
[...]
   0  27991 sendmail      vop_close        - /var/log/sendmail.st

   0  27991 sendmail      vop_open         - /etc/spwd.db
[...]
   0  27991 sendmail      vop_close        - /etc/spwd.db

   0    974 syslogd       vop_write     106B /var/log/maillog
[...]
[...]

   0  27991 sendmail      vop_open         - /etc/mail/aliases.db
[...]
[...]

   0  27991 sendmail      vop_open         - /etc/spwd.db
[...]
   0  27991 sendmail      vop_close        - /etc/spwd.db

   0  27991 sendmail      vop_open         - /etc/shells
[...]
   0  27991 sendmail      vop_close        - /etc/shells

   0    974 syslogd       vop_write     109B /var/log/maillog
[...]
[...]

1001  27990 sendmail      vop_read        4K /var/spool/clientmqueue/df2AP4RU3I027990

   0    974 syslogd       vop_write      75B /var/log/maillog
[...]
[...]

   0  27991 sendmail      vop_create       - /var/spool/mqueue/df2AP4RUKS027991
[...]
   0  27991 sendmail      vop_close        - /var/spool/mqueue/df2AP4RUKS027991

   0  27991 sendmail      vop_create       - /var/spool/mqueue/qf2AP4RUKS027991

   0  27991 sendmail      vop_close        - /etc/mail/aliases.db

1001  27990 sendmail      vop_close        - /var/spool/clientmqueue/sm-client.st

1001  27990 sendmail      vop_close        - /var/spool/clientmqueue/df2AP4RU3I027990
1001  27990 sendmail      vop_remove       - /var/spool/clientmqueue/df2AP4RU3I027990

1001  27990 sendmail      vop_remove       - /var/spool/clientmqueue/qf2AP4RU3I027990

   0    974 syslogd       vop_write      73B /var/log/maillog

   0  27991 sendmail      vop_open         - /var/spool/mqueue/qf2AP4RUKS027991

   0  27992 sendmail      vop_open         - /var/spool/mqueue/qf2AP4RUKS027991

   0  27991 sendmail      vop_open         - /var/log/sendmail.st
[...]
   0  27991 sendmail      vop_close        - /var/log/sendmail.st

   0  27992 sendmail      vop_open         - /etc/spwd.db
[...]
   0  27992 sendmail      vop_close        - /etc/spwd.db

   0  27992 sendmail      vop_read      260B /etc/mail/aliases.db
[...]
   0  27992 sendmail      vop_read       32K /etc/mail/aliases.db

   0  27992 sendmail      vop_open         - /etc/spwd.db
[...]
   0  27992 sendmail      vop_close        - /etc/spwd.db

   0  27992 sendmail      vop_open         - /etc/shells
[...]
   0  27992 sendmail      vop_close        - /etc/shells

   0  27992 sendmail      vop_open         - /etc/group
[...]
   0  27992 sendmail      vop_close        - /etc/group

 1001 27992 sendmail      vop_getattr      - /usr/home/dusko

   0  27992 sendmail      vop_open         - /etc/group
[...]
   0  27992 sendmail      vop_close        - /etc/group

   0  27992 sendmail      vop_read        4K /var/spool/mqueue/qf2AP4RUKS027991

   0  27992 sendmail      vop_open         - /var/spool/mqueue/df2AP4RUKS027991

   0  27992 sendmail      vop_create       - /var/spool/mqueue/tf2AP4RUKS027991

   0  27993 sendmail      vop_getattr      - /usr/local/libexec/mail.local
   0  27993 sendmail      vop_open         - /usr/local/libexec/mail.local

   0  27993 sendmail      vop_open         - /libexec/ld-elf.so.1

   0  27993 mail.local    vop_close        - /usr/local/libexec/mail.local

   0  27993 mail.local    vop_open         - /etc/libmap.conf
[...]
   0  27993 mail.local    vop_close        - /etc/libmap.conf

   0  27993 mail.local    vop_open         - /usr/local/etc/libmap.d/mesa.conf
[...]
   0  27993 mail.local    vop_close        - /usr/local/etc/libmap.d/mesa.conf

   0  27993 mail.local    vop_open         - /var/run/ld-elf.so.hints
[...]
   0  27993 mail.local    vop_close        - /var/run/ld-elf.so.hints

   0  27993 mail.local    vop_open         - /lib/libutil.so.9
[...]
   0  27993 mail.local    vop_close        - /var/run/ld-elf.so.hints

   0  27993 mail.local    vop_open         - /lib/libutil.so.9
[...]
   0  27993 mail.local    vop_close        - /lib/libutil.so.9

   0  27993 mail.local    vop_open         - /lib/libc.so.7
[...]
   0  27993 mail.local    vop_close        - /lib/libc.so.7

   0  27993 mail.local    vop_open         - /etc/nsswitch.conf
[...]
   0  27993 mail.local    vop_close        - /etc/nsswitch.conf

   0  27993 mail.local    vop_open         - /etc/services
[...]
   0  27993 mail.local    vop_close        - /etc/services

   0  27993 mail.local    vop_open         - /etc/resolv.conf
[...]
   0  27993 mail.local    vop_close        - /etc/resolv.conf

   0  27993 mail.local    vop_open         - /etc/hosts
[...]
   0  27993 mail.local    vop_close        - /etc/hosts

   0  27993 mail.local    vop_open         - /etc/spwd.db
[...]
   0  27993 mail.local    vop_close        - /etc/spwd.db

   0  27993 mail.local    vop_create       - /tmp/local.0p2YZe
[...]
   0  27993 mail.local    vop_remove       - /tmp/local.0p2YZe

   0  27993 mail.local    vop_open         - /etc/localtime
[...]
[...]

   0  27992 sendmail      vop_getattr      - /var/spool/mqueue/df2AP4RUKS027991
   0  27993 mail.local    vop_close        - /var/spool/mqueue/df2AP4RUKS027991

   0  27992 sendmail      vop_read        4K /var/spool/mqueue/df2AP4RUKS027991

   0  27993 mail.local    vop_read       40K /usr/share/zoneinfo/posixrules
[...]
   0  27993 mail.local    vop_close        - /usr/share/zoneinfo/posixrules

   0  27993 mail.local    vop_open         - /etc/spwd.db
[...]
   0  27993 mail.local    vop_close        - /etc/spwd.db

   0  27993 mail.local    vop_create       - /var/mail/dusko.lock

1001  27993 mail.local    vop_open         - /var/mail/dusko
[...]
1001  27993 mail.local    vop_write     761B /var/mail/dusko
[...]
1001  27993 mail.local    vop_close        - /var/mail/dusko

   0  27992 sendmail      vop_open         - /var/log/sendmail.st
[...]
   0  27992 sendmail      vop_close        - /var/log/sendmail.st

   0  27992 sendmail      vop_close        - /var/spool/mqueue/df2AP4RUKS027991
   0  27992 sendmail      vop_remove       - /var/spool/mqueue/df2AP4RUKS027991

   0  27992 sendmail      vop_remove       - /var/spool/mqueue/qf2AP4RUKS027991

   0  27992 sendmail      vop_close        - /<unknown>

   0    974 syslogd       vop_write      84B /var/log/
   0  27992 sendmail      vop_inactive     - /maillog
   0  27992 sendmail      vop_close        - /etc/mail/aliases.db
   0  27992 sendmail      vop_close        - /dev/<unknown>
   0  27992 sendmail      vop_close        - /dev/<unknown>
```

---

From   
[dtrace - Display the names of commands that invoke the open() system call and the name of the file being opened](https://docs.oracle.com/cd/E37670_01/E37355/html/ol_examples_dtrace.html)

```
# dtrace -q -n 'syscall::open:entry { printf("%-16s %-16s\n",execname,copyinstr(arg0)); }'
```

---

### Trace the Flow with `dtrace(1)` Script


```
# cat ip-tcp-udp-probes.d 
#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=10Hz

dtrace:::BEGIN
{
    printf(" %30s %-6s %30s %-6s %-6s %s\n\n", "SADDR", "SPORT", "DADDR", "DPORT", "BYTES", "FLAGS");
}

tcp:::receive,
tcp:::send

{
    printf(" %30s %-6u %30s %-6u %-6u (%s%s%s%s%s%s\b)\n",
        args[2]->ip_saddr, args[4]->tcp_sport,
        args[2]->ip_daddr, args[4]->tcp_dport,
        args[2]->ip_plength - args[4]->tcp_offset,
        (args[4]->tcp_flags & TH_FIN) ? "FIN|" : "",
        (args[4]->tcp_flags & TH_SYN) ? "SYN|" : "",
        (args[4]->tcp_flags & TH_RST) ? "RST|" : "",
        (args[4]->tcp_flags & TH_PUSH) ? "PSH|" : "",
        (args[4]->tcp_flags & TH_ACK) ? "ACK|" : "",
        (args[4]->tcp_flags & TH_URG) ? "URG|" : "");
}
```

```
# chmod 0744 ip-tcp-udp-probes.d 
```

```
# ./ip-tcp-udp-probes.d > ipprobes.txt 
```

```
$ printf %s\\n "Hello" | mail -v -s "Test" dusko
```

Remove non-relevant lines from the **ipprobes.txt**.   

```
# cat ipprobes.txt
                          SADDR SPORT                           DADDR DPORT  BYTES  FLAGS

                      127.0.0.1 39446                       127.0.0.1 25     38     (SYN|)
                      127.0.0.1 39446                       127.0.0.1 25     38     (SYN|)
                      127.0.0.1 25                          127.0.0.1 39446  38     (SYN|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  38     (SYN|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     30     (ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     30     (ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  121    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  121    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     54     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     54     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  215    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  215    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     40     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     40     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  60     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  60     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     319    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     319    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  2677   (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  2677   (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     140    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     140    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  285    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  285    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     76     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     76     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  285    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  285    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     30     (ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     30     (ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  223    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  223    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     97     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     97     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  102    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  102    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     93     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     93     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  155    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  155    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     423    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     423    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  30     (ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  30     (ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     55     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     55     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  108    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  108    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     58     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     58     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  100    (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  100    (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     30     (FIN|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     30     (FIN|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  54     (PSH|ACK|)
                      127.0.0.1 25                          127.0.0.1 39446  54     (PSH|ACK|)
                      127.0.0.1 39446                       127.0.0.1 25     19     (RST|)
                      127.0.0.1 39446                       127.0.0.1 25     19     (RST|)
```

---

* Good `sendmail.cf` configuration file and good commands for 
debugging *sendmail*:    
[Sendmail Relay server no longer working. PLEASE HELP!](https://www.linuxquestions.org/questions/linux-server-73/sendmail-relay-server-no-longer-working-please-help-549437/)


[Sendmail Hacks - Things i need to do with sendmail at work that i keep forgetting](https://www.schmut.com/cheat-sheets/sendmail-hacks)

[Configuring sendmail for your UNIX desktop](https://managing.blue/2006/09/06/configuring-sendmail-for-your-unix-desktop/)

[On picking an MTA](https://managing.blue/2010/06/23/on-picking-an-mta/)

[Poor man's milter-ahead](https://managing.blue/2009/08/21/poor-mans-milter-ahead/) -- Mentions: [milter-ahead](http://www.snertsoft.com/sendmail/milter-ahead/)

[The Sendmail/Postfix log analyzer](https://sareport.darold.net/index.html)

[Introduction to Sendmail for Firewalls](http://www.ranum.com/security/computer_security/archives/sendmail-and-firewalls.pdf)

[Debugging sendmail problems](http://ibgwww.colorado.edu/~lessem/psyc5112/usail/mail/debugging/)

[Testing sendmail.cf - TCP/IP Network Administration, Third Edition](https://docstore.mik.ua/orelly/networking_2ndEd/tcp/ch10_08.htm)

[STARTTLS considered harmful](https://lwn.net/Articles/866481/)


## Testing Your Server for TLS Support

SMTP/S or SMTP over TLS uses TCP port 465, rather than SMTP's port 25. 


### Testing STARTTLS Support Within SMTP

This first test will very likely fail if you are trying to test your work
server from home.  Many Internet service providers block TCP/25 traffic 
from customers, because almost all of that would be spam sent from infected
Windows computers in peoples' homes and small businesses.

But within your organization, or on the server itself, you could try using
telnet to connect to TCP port 25 on the server.  Send over ehlo, the
"extended HELO", and see if Authentication and STARTTLS are announced.
Look for something like the following, where you type the following lines:
`helo my.host.domain`, `ehlo my.host.domain`, `quit`.  

This server supports STARTTLS (line: `250-STARTTLS`) but not AUTH over SMTP.  

From a workstation within your organization:

```
$ nc testmx.host.domain 25
220 testmx.host.domain ESMTP mailer ready at Sun, 30 Oct 2022 15:01:48 -0700
helo my.host.domain
250 testmx.host.domain ESMTP mailer ready at Sun, 30 Oct 2022 15:01:48 -0700
Hello my.host.domain [123.45.67.8], pleased to meet you
ehlo my.host.domain
250-testmx.host.domain Hello my.host.domain [123.45.67.8], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-STARTTLS
250-DELIVERBY
250 HELP
quit
221 2.0.0 testmx.host.domain closing connection
```

```
$ nc testmx.host.domain 25
220 testmx.host.domain ESMTP mailer ready at Sun, 30 Oct 2022 15:03:36 -0700
ehlo my.host.domain
250-testmx.host.domain Hello my.host.domain [123.45.67.8], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-STARTTLS
250-DELIVERBY
250 HELP
AUTH LOGIN
503 5.3.3 AUTH not available
AUTH PLAIN
503 5.3.3 AUTH not available
AUTH
503 5.3.3 AUTH not available

quit
221 2.0.0 testmx.host.domain closing connection
```


To start encrypting the connection first by using the STARTTLS command,
you can to use `openssl` command.  The `openssl` does the STARTTLS
handshake and you can to pick up the conversation from there (decrypted
automatically on the fly).

While still on a workstation within your organization, run the following
*openssl* command. 

**Note:** you type the following lines:   

`ehlo my.host.domain`,   
`MAIL From:<dusko@my.host.domain>`,    
`RCPT To:<dusko@testmx.host.domain>`,   
`data`,

and:

`From: Myname <dusko@my.host.domain>`   
`To: <dusko@testmx.host.domain> Firstname Lastname`    
`Subject: Testing SMTP over TLS on port 25`   
`Press <Enter> key (for newline)`   
`Testing.`    
`.`    

and:

`QUIT`


```
$ openssl s_client -starttls smtp -ign_eof -crlf -connect testmx.host.domain:25 
```

Output:

```
CONNECTED(00000003)
depth=2 C = BE, O = GlobalSign nv-sa, OU = Root CA, CN = GlobalSign Root CA
verify return:1
depth=1 C = BE, O = GlobalSign nv-sa, CN = AlphaSSL CA - SHA256 - G2
verify return:1
depth=0 CN = *.host.domain
verify return:1
---
Certificate chain
 0 s:CN = *.host.domain
   i:C = BE, O = GlobalSign nv-sa, CN = AlphaSSL CA - SHA256 - G2
 1 s:C = BE, O = GlobalSign nv-sa, CN = AlphaSSL CA - SHA256 - G2
   i:C = BE, O = GlobalSign nv-sa, OU = Root CA, CN = GlobalSign Root CA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIGOjCCBSKgAwIBAgIMMLyMRt1iOWV140T0MA0GCSqGSIb3DQEBCwUAMEwxCzAJ
[ . . . ]
YqHmWFAwYDjLKhyoU6w=
-----END CERTIFICATE-----
subject=CN = *.host.domain

issuer=C = BE, O = GlobalSign nv-sa, CN = AlphaSSL CA - SHA256 - G2

---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA
Server Temp Key: DH, 1024 bits
---
SSL handshake has read 3992 bytes and written 542 bytes
Verification: OK
---
New, TLSv1.2, Cipher is DHE-RSA-AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : DHE-RSA-AES256-GCM-SHA384
    Session-ID: E846518A07F0268F5A050119C0BE69CAA5D3FE6F2CE1027B5CA75AEF38BF4956
    Session-ID-ctx: 
    Master-Key: 769E3781160E13E[ . . . ]
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 1 (seconds)
    TLS session ticket:
    0000 - 7c ac ce 3e e4 ab d9 b1-fe 5f 1b c4 89 32 74 1d   |..>....._...2t.
    0010 - [ . . . ]
    0020 - [ . . . ]
    0030 - [ . . . ]
    0040 - [ . . . ]
    0050 - [ . . . ]
    0060 - [ . . . ]
    0070 - [ . . . ]
    0080 - [ . . . ]
    0090 - [ . . . ]
    00a0 - [ . . . ]
    00b0 - [ . . . ]

    Start Time: 1667166567
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
---
250 HELP
ehlo my.host.domain 
250-testmx.host.domain Hello my.host.domain [123.45.67.8], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-DELIVERBY
250 HELP
MAIL From:<dusko@my.host.domain>
250 2.1.0 <dusko@my.host.domain>... Sender ok
RCPT To:<dusko@testmx.host.domain> 
250 2.1.5 <dusko@testmx.host.domain>... Recipient ok 
data
354 Enter mail, end with "." on a line by itself
From: Myname <dusko@my.host.domain>
To: <dusko@testmx.host.domain> Firstname Lastname 
Subject: Testing SMTP over TLS on port 25

Testing.
.
250 2.0.0 29ULnMCa012594 Message accepted for delivery
QUIT
221 2.0.0 testmx.host.domain closing connection
closed
```


**Note:** In `From: ` and `To: ` fields, you can reverse the order of the
name and email address.  


Log into the mail server and check *sendmail* maillog:

```
# grep 29ULnMCa012594 /var/log/maillog 
Oct 30 17:00:48 testmx sendmail[30004]: 29ULnMCa012594: from=<dusko@my.host.domain>, size=110, class=0, nrcpts=1, msgid=<202210302359.29ULnMCa012594@testmx.host.domain>, proto=ESMTP, daemon=MTA, relay=my.host.domain [123.45.67.8]
Oct 30 17:00:49 testmx sendmail[30279]: 29ULnMCa012594: to=<dusko@testmx.host.domain>, delay=00:00:56, xdelay=00:00:01, mailer=local, pri=30490, dsn=2.0.0, stat=Sent
Oct 30 17:00:49 testmx sendmail[30279]: 29ULnMCa012594: done; delay=00:00:56, ntries=1
```

The envelope address (`MAIL From:`) check:

```
$ openssl s_client -starttls smtp -ign_eof -crlf -connect testmx.host.domain:25 
[ . . . ]
[ . . . ]
---
250 HELP
ehlo ehlo my.host.domain  
250-testmx.host.domain Hello my.host.domain [123.45.67.8], pleased to meet you
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-SIZE 52428800
250-DELIVERBY
250 HELP
MAIL From:<dusko@non.existing.domain>
250 2.1.0 <dusko@non.existing.domain>... Sender ok
RCPT To:<dusko@testmx.host.domain> 
553 5.1.8 <dusko@testmx.host.domain>... Domain of sender address dusko@non.existing.domain does not exist
QUIT
221 2.0.0 testmx.host.domain closing connection 
closed
```

#### Base64

```
$ perl -MMIME::Base64 -le 'print decode_base64("VXNlcm5hbWU6");'
Username:
 
$ perl -MMIME::Base64 -le 'print decode_base64("UGFzc3dvcmQ6");'
Password:
```

Username and password - For Auth PLAIN:

```
$ perl -MMIME::Base64 -le 'print encode_base64("\000myusername\000MyPassword");'
AG15dXNlcm5hbWUATXlQYXNzd29yZA==
```

```
$ perl -MMIME::Base64 -le 'print decode_base64("AG15dXNlcm5hbWUATXlQYXNzd29yZA==");'
myusernameMyPassword
```


Username and password - For Auth LOGIN:

```
$ perl -MMIME::Base64 -le 'print encode_base64("myusername");'
bXl1c2VybmFtZQ==

$ perl -MMIME::Base64 -le 'print encode_base64("MyPassword");'
TXlQYXNzd29yZA==
```

```
$ perl -MMIME::Base64 -le 'print decode_base64("bXl1c2VybmFtZQ==");'
myusername
 
$ perl -MMIME::Base64 -le 'print decode_base64("TXlQYXNzd29yZA==");'
MyPassword
```

## Testing

### Testing a Ruleset With Sendmail's Address Test Mode, sendmail -bt 

```
root@fbsd1:/etc/mail # sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
```

To see a complete list of debugging commands available, type ?

```
> ?
Help for test mode:
?                :this help message.
.Dmvalue         :define macro `m' to `value'.
.Ccvalue         :add `value' to class `c'.
=Sruleset        :dump the contents of the indicated ruleset.
=M               :display the known mailers.
-ddebug-spec     :equivalent to the command-line -d debug flag.
$m               :print the value of macro $m.
$=c              :print the contents of class $=c.
/mx host         :returns the MX records for `host'.
/parse address   :parse address, returning the value of crackaddr, and
                  the parsed address.
/try mailer addr :rewrite address into the form it will have when
                  presented to the indicated mailer.
/tryflags flags  :set flags used by parsing.  The flags can be `H' for
                  Header or `E' for Envelope, and `S' for Sender or `R'
                  for Recipient.  These can be combined, `HR' sets
                  flags for header recipients.
/canon hostname  :try to canonify hostname.
/map mapname key :look up `key' in the indicated `mapname'.
/quit            :quit address test mode.
rules addr       :run the indicated address through the named rules.
                  Rules can be a comma separated list of rules.
End of HELP info
```

**Reference:**

[Understanding Sendmail Address Rewriting Rules](http://www.harker.com/sendmail/rules-overview.html)


## Appendix

### Brief dtrace(1) and dwatch(1) Intro


### --->>>  USE THIS 1 OF 2!  <<<---


#### dtrace(1) - System Calls

```
# dtrace -n 'syscall::open*:entry { printf("%s %s", execname, copyinstr(arg0)); }'
```

From    
[FreeBSD Performance Observability - Learn what's happening in your FreeBSD system and alter the way the system behaves in real time](https://klarasystems.com/articles/freebsd-performance-observability/)

```
# dtrace -l | sed 1d | awk '{print $2}' | sort -u
```


Trace file opens with process and filename:

```
# dwatch -X open
[ . . . ]
```

Find the parent of a process calling a syscall

```
dwatch -R syscall::read:entry
[ . . . ] 
```

Trace TCP accepted connections by remote IP address:

```
# dwatch -X tcp-accept-established
INFO Sourcing tcp-accept-established profile [found in /usr/libexec/dwatch]
INFO Watching 'tcp:::accept-established' ...
2022 Nov 26 15:16:50 0.0 intr[12]: 127.0.0.1:25 <- 127.0.0.1:19231
^C
```


Trace TCP active opens by remote IP address:

```
# dwatch -X tcp-connect-established
INFO Sourcing tcp-connect-established profile [found in /usr/libexec/dwatch]
INFO Watching 'tcp:::connect-established' ...
2022 Nov 26 15:18:10 0.0 intr[12]: 127.0.0.1:13729 -> 127.0.0.1:25
^C
```

Trace TCP sent messages by remote IP address:

```
# dwatch -X tcp-send
[ . . . ]
```


Trace TCP received messages by remote IP address:

```
# dwatch -X tcp-receive
[ . . . ]
```


Trace TCP activity while given nc command runs: 

```
# dwatch -X tcp -- -c 'mail -v -s "Test" dusko'
[ . . . ]
```

# Trace VFS lookup events by path:

```
# dwatch -X vop_lookup
INFO Sourcing vop_lookup profile [found in /usr/libexec/dwatch]
INFO Watching 'vfs:vop:vop_lookup:entry' ...
2022 Nov 26 19:02:44 1001.1001 mail[70112]: /tmp/mail.RsW228Y8ZvvR
2022 Nov 26 19:02:44 1001.1001 mail[70112]: /tmp/mail.RsW228Y8ZvvR
2022 Nov 26 19:02:44 1001.1001 mail[70112]: /tmp/mail.RsW228Y8ZvvR
2022 Nov 26 19:02:44 1001.1001 mail[70112]: /tmp/mail.RsylzXOLZtiD
2022 Nov 26 19:02:44 1001.1001 mail[70112]: /tmp/mail.RsylzXOLZtiD
2022 Nov 26 19:02:44 1001.1001 mail[70112]: /tmp/mail.RsylzXOLZtiD
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/.
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/ 
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/.
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/.
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/qf
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/df
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/xf
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/.
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./xf2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/xf2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/.
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/.
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/.
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/df2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./qf2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/qf2AR32ig9070113
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /dev/crypto
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /dev/crypto
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/df2AR32ii1070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/qf2AR32ii1070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/xf2AR32ii1070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/xf2AR32ii2070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/df2AR32ii2070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/df2AR32ii2070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/df2AR32ii2070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/qf2AR32ii2070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/xf2AR32ii2070114
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/sm-client.st
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/sm-client.st
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./df2AR32ig9070113
2022 Nov 26 19:02:44 0.0 sendmail[70115]: /dev/null
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/df2AR32ig9070113
2022 Nov 26 19:02:44 0.0 sendmail[70115]: /dev/null
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./qf2AR32ig9070113
2022 Nov 26 19:02:44 0.0 sendmail[70115]: /dev/null
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/qf2AR32ig9070113
2022 Nov 26 19:02:44 0.0 sendmail[70115]: /dev/null
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/./xf2AR32ig9070113
2022 Nov 26 19:02:44 0.0 sendmail[70115]: /var/spool/mqueue/xf2AR32ii2070114
2022 Nov 26 19:02:44 1001.25 sendmail[70113]: /var/spool/clientmqueue/xf2AR32ig9070113
2022 Nov 26 19:02:44 0.0 sendmail[70115]: /var/spool/mqueue/qf2AR32ii2070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /dev/null
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /dev/null
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /dev/null
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /dev/null
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/df2AR32ii3070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/qf2AR32ii3070114
2022 Nov 26 19:02:44 0.0 sendmail[70114]: /var/spool/mqueue/xf2AR32ii3070114
2022 Nov 26 19:02:44 0.25 sendmail[70115]: /var/spool/mqueue/tf2AR32ii2070114
2022 Nov 26 19:02:44 0.25 sendmail[70115]: /var/spool/mqueue/tf2AR32ii2070114
2022 Nov 26 19:02:44 0.25 sendmail[70115]: /var/spool/mqueue/qf2AR32ii2070114
2022 Nov 26 19:02:44 0.0 mail.local[70116]: /tmp/local.HnQB1H
2022 Nov 26 19:02:44 0.0 mail.local[70116]: /tmp/local.HnQB1H
2022 Nov 26 19:02:44 0.0 mail.local[70116]: /var/mail/dusko.lock
2022 Nov 26 19:02:44 0.0 mail.local[70116]: /var/mail/dusko.lock
2022 Nov 26 19:02:44 0.25 sendmail[70115]: /var/spool/mqueue/df2AR32ii2070114
2022 Nov 26 19:02:44 0.25 sendmail[70115]: /var/spool/mqueue/qf2AR32ii2070114
2022 Nov 26 19:02:44 0.25 sendmail[70115]: /var/spool/mqueue/xf2AR32ii2070114
^C
```

Trace VFS create events by path:

``` 
# dwatch -X vop_create
INFO Sourcing vop_create profile [found in /usr/libexec/dwatch]
INFO Watching 'vfs:vop:vop_create:entry' ...
2022 Nov 26 19:09:14 1001.1001 mail[70625]: /tmp/mail.RshkOoUT6V9r
2022 Nov 26 19:09:14 1001.1001 mail[70625]: /tmp/mail.RsxKgOHLGsmf
2022 Nov 26 19:09:14 1001.25 sendmail[70626]: /var/spool/clientmqueue/df2AR39EnD070626
2022 Nov 26 19:09:14 1001.25 sendmail[70626]: /var/spool/clientmqueue/qf2AR39EnD070626
2022 Nov 26 19:09:14 0.0 sendmail[70627]: /var/spool/mqueue/df2AR39Elv070627
2022 Nov 26 19:09:14 0.0 sendmail[70627]: /var/spool/mqueue/qf2AR39Elv070627
2022 Nov 26 19:09:14 0.25 sendmail[70628]: /var/spool/mqueue/tf2AR39Elv070627
2022 Nov 26 19:09:14 0.0 mail.local[70629]: /tmp/local.5vsbk5
2022 Nov 26 19:09:14 0.0 mail.local[70629]: /var/mail/dusko.lock
^C
```


Trace VFS remove events by path:

```
# dwatch -X vop_remove
[ . . . ]
```

Trace VFS readdir events by path:

```
# dwatch -X vop_readdir
[ . . . ]
```

Trace VFS rename events by path and destination:

```
# dwatch -X vop_rename
INFO Sourcing vop_rename profile [found in /usr/libexec/dwatch]
INFO Watching 'vfs:vop:vop_rename:entry' ...
2022 Nov 26 19:19:39 0.25 sendmail[71356]: /var/spool/mqueue/tf2AR3Jd5P071355 -> /var/spool/mqueue/qf2AR3Jd5P071355
^C
```

Trace processes performing writes with small buffers but ignore dtrace executable:

```
# dwatch -X write -t 'execname != "dtrace" && this->nbytes < 10'
[ . . . ]
```


### --->>>  USE THIS 2 OF 2!  <<<---
 
From Systems Performance: Enterprise and the Cloud - By Brendan 
Gregg - Appendix D. DTrace One-Liners:

```
# dtrace -n 'syscall::open:entry { printf("%s %s", execname, copyinstr(arg0)); }'
[ . . . ]
```


Trace new processes with process name and arguments:
    
```
# dtrace -n 'proc:::exec-success { trace(curpsinfo->pr_psargs); }'
dtrace: description 'proc:::exec-success ' matched 1 probe
CPU     ID                    FUNCTION:NAME
  5  88556                none:exec-success   printf %s\n Testing.
  1  88556                none:exec-success   mail -v -s Test 6 dusko
  2  88556                none:exec-success   sendmail -i -v dusko
  2  88556                none:exec-success   sendmail -i -v dusko
  6  88556                none:exec-success   mail.local -l
^C
```


Trace new processes with arguments and time:

```
# dtrace -qn 'syscall::exec*:return { printf("%Y %s\n",walltimestamp,curpsinfo->pr_psargs); }'
[ . . . ]
```
    
Trace inbound TCP connections by remote address:
    
```
# dtrace -n 'tcp:::accept-established { trace(args[3]->tcps_raddr); }'
dtrace: description 'tcp:::accept-established ' matched 1 probe
CPU     ID                    FUNCTION:NAME
  4  88667          none:accept-established   127.0.0.1
^C
```


Trace files opened/created by process name:

```
# dtrace -n 'syscall::openat*:entry { printf("%s %s",execname,copyinstr(arg1)); }'
dtrace: description 'syscall::openat*:entry ' matched 2 probes
CPU     ID                    FUNCTION:NAME
  2  91306                     openat:entry mail /tmp/mail.RsdZQ34D6FcS
  2  91306                     openat:entry mail /tmp/mail.Rs0owR9iO4WP
  7  91306                     openat:entry sendmail /etc/mail/submit.cf
  7  91306                     openat:entry sendmail ./df2AQMK5BV055327
  7  91306                     openat:entry sendmail ./df2AQMK5BV055327
  7  91306                     openat:entry sendmail ./qf2AQMK5BV055327
  7  91306                     openat:entry sendmail /dev/crypto
  3  91306                     openat:entry sendmail /var/log/sendmail.st
  3  91306                     openat:entry sendmail ./df2AQMK5wg055328
  6  91306                     openat:entry sendmail ./df2AQMK5wg055328
  6  91306                     openat:entry sendmail ./qf2AQMK5wg055328
  7  91306                     openat:entry sendmail /var/spool/clientmqueue/sm-client.st
  3  91306                     openat:entry sendmail /dev/null
  3  91306                     openat:entry sendmail /dev/null
  3  91306                     openat:entry sendmail ./qf2AQMK5wg055328
  6  91306                     openat:entry sendmail /dev/null
  6  91306                     openat:entry sendmail /dev/null
  6  91306                     openat:entry sendmail /var/log/sendmail.st
  3  91306                     openat:entry sendmail ./df2AQMK5wg055328
  3  91306                     openat:entry sendmail ./tf2AQMK5wg055328
  3  91306                     openat:entry mail.local /tmp/local.iD5X5s
  3  91306                     openat:entry mail.local /var/mail/dusko.lock
  3  91306                     openat:entry mail.local /var/mail/dusko
  2  91306                     openat:entry sendmail /var/log/sendmail.st
^C
```

```
# dtrace -n 'syscall::open:entry { printf("At %Y %s file opened by PID %d UID %d using %s\n", walltimestamp, copyinstr(arg0), pid, uid, execname); }'
[ . . . ]
```

Trace inbound TCP connections by local address:

```
# dtrace -n 'tcp:::accept-established { trace(args[3]->tcps_laddr); }'
dtrace: description 'tcp:::accept-established ' matched 1 probe
CPU     ID                    FUNCTION:NAME
  0  88667          none:accept-established   127.0.0.1
^C
```


Trace inbound TCP connections by local port:

```
# dtrace -n 'tcp:::accept-established { trace(args[3]->tcps_lport); }'
dtrace: description 'tcp:::accept-established ' matched 1 probe
CPU     ID                    FUNCTION:NAME
  7  88667          none:accept-established     25
^C
```

Other DTrace One-Liners:
 
``` 
# dtrace -n 'tcp:::accept-refused { trace(args[4]->tcp_dport); }'
dtrace: description 'tcp:::accept-refused ' matched 1 probe
CPU     ID                    FUNCTION:NAME
  1  88668              none:accept-refused  40691
  6  88668              none:accept-refused     25
^C
``` 

```
# dtrace -n 'tcp:::accept-established { trace(args[3]->tcps_lport); }'
dtrace: description 'tcp:::accept-established ' matched 1 probe
CPU     ID                    FUNCTION:NAME
  7  88667          none:accept-established     25
^C
```


```
# dtrace -n 'tcp:::receive { trace(args[3]->tcps_lport); }'

# dtrace -n 'tcp:::receive { trace(args[3]->tcps_lport); }'

# dtrace -n 'tcp:::receive { trace(args[2]->ip_daddr); }'
```

```
# cat dtrace-ex1.d
syscall::open:entry
{
    printf("%s, %s\n", execname, copyinstr(arg0));
}
```

```
# dtrace -q -s dtrace-ex1.d 
printf, /etc/libmap.conf
[ . . . ]
mail, /etc/libmap.conf
mail, /usr/local/etc/libmap.d
mail, /usr/local/etc/libmap.d/mesa.conf
mail, /var/run/ld-elf.so.hints
mail, /lib/libc.so.7
mail, /usr/share/misc/mail.rc
mail, /usr/local/etc/mail.rc
mail, /etc/mail.rc
mail, /home/dusko/.mailrc
mail, /home/dusko/.mail_aliases
mail, /etc/localtime
mail, /usr/share/zoneinfo/posixrules
mail, /tmp/mail.Rs6miNZyD4Du
mailwrapper, /etc/libmap.conf
mailwrapper, /usr/local/etc/libmap.d
mailwrapper, /usr/local/etc/libmap.d/mesa.conf
mailwrapper, /var/run/ld-elf.so.hints
mailwrapper, /lib/libutil.so.9
mailwrapper, /lib/libc.so.7
mailwrapper, /usr/local/etc/mail/mailer.conf
sendmail, /etc/libmap.conf
sendmail, /usr/local/etc/libmap.d
sendmail, /usr/local/etc/libmap.d/mesa.conf
sendmail, /var/run/ld-elf.so.hints
sendmail, /lib/libwrap.so.6
sendmail, /usr/lib/libwrap.so.6
sendmail, /lib/libsasl2.so.3
sendmail, /usr/lib/libsasl2.so.3
sendmail, /usr/lib/compat/libsasl2.so.3
sendmail, /usr/local/lib/libsasl2.so.3
sendmail, /lib/libblacklist.so.0
sendmail, /usr/lib/libblacklist.so.0
sendmail, /lib/libssl.so.111
sendmail, /usr/lib/libssl.so.111
sendmail, /lib/libcrypto.so.111
sendmail, /lib/libutil.so.9
sendmail, /lib/libc.so.7
sendmail, /lib/libdl.so.1
sendmail, /usr/lib/libdl.so.1
sendmail, /lib/libthr.so.3
sendmail, /etc/nsswitch.conf
sendmail, /etc/pwd.db
sendmail, /etc/pwd.db
sendmail, /etc/resolv.conf
sendmail, /etc/hosts
sendmail, /etc/hosts
sendmail, /etc/localtime
sendmail, /usr/share/zoneinfo/posixrules
sendmail, /usr/share/zoneinfo/UTC
sendmail, /usr/share/zoneinfo/posixrules
sendmail, /etc/pwd.db
sendmail, /etc/pwd.db
sendmail, /lib/libcrypto.so.111
sendmail, /etc/pwd.db
sendmail, /etc/pwd.db
sendmail, /etc/services
sendmail, /etc/hosts
sendmail, /etc/hosts
sendmail, /etc/hosts
sendmail, /etc/hosts
sendmail, /etc/services
sendmail, /etc/hosts.allow
sendmail, /etc/ssl/openssl.cnf
sendmail, /usr/lib/libssl.so.111
sendmail, /etc/spwd.db
sendmail, /etc/mail/aliases.db
sendmail, /etc/spwd.db
sendmail, /etc/shells
sendmail, /etc/spwd.db
sendmail, /etc/mail/aliases.db
sendmail, /etc/spwd.db
sendmail, /etc/shells
sendmail, /etc/group
sendmail, /etc/group
sendmail, /etc/group
sendmail, /etc/group
mail.local, /etc/libmap.conf
mail.local, /usr/local/etc/libmap.d
mail.local, /usr/local/etc/libmap.d/mesa.conf
mail.local, /var/run/ld-elf.so.hints
mail.local, /lib/libutil.so.9
mail.local, /lib/libc.so.7
mail.local, /etc/nsswitch.conf
mail.local, /etc/services
mail.local, /etc/resolv.conf
mail.local, /etc/hosts
mail.local, /etc/spwd.db
mail.local, /etc/localtime
mail.local, /usr/share/zoneinfo/posixrules
mail.local, /etc/spwd.db
[ . . . ]
```

```
# cat dtrace-ex2.d
syscall::write:entry
{
        printf("%s", stringof(copyin(arg1, arg2)));
}
```

```
# dtrace -q -s dtrace-ex2.d > sendmailTRACE
^C#
```

```
# file sendmailTRACE
sendmailTRACE: data

# wc -l sendmailTRACE
     791 sendmailTRACE
```

```
# cat sendmailTRACE
  
Received: from fbsd1.home.arpa (localhost [127.0.0.1])
[ . . . ]
```

```
# strings sendmailTRACE | wc -l
     898
```

```
# strings sendmailTRACE
0.re\
|Testing.
Testing.
To: dusko
Subject: Test 01
[ . . . ]
1 sendmail[51179]: 2AO3Up92051179: SMTP outgoing connect on localhost
```

```
$ grep 2AO3Up92051179 /var/log/maillog
[ . . . ]
```

```
$ tail -21 ~/mbox
 
From dusko@fbsd1.home.arpa Wed Nov 23 19:30:52 2022
Return-Path: <dusko@fbsd1.home.arpa>
Received: from fbsd1.home.arpa (localhost [127.0.0.1])
        by fbsd1.home.arpa (8.17.1/8.17.1) with ESMTPS id 2AO3UpXe051180
        (version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NO)
        for <dusko@fbsd1.home.arpa>; Wed, 23 Nov 2022 19:30:51 -0800 (PST)
        (envelope-from dusko@fbsd1.home.arpa)
Received: (from dusko@localhost)
        by fbsd1.home.arpa (8.17.1/8.17.1/Submit) id 2AO3Up92051179
        for dusko; Wed, 23 Nov 2022 19:30:51 -0800 (PST)
        (envelope-from dusko)
Date: Wed, 23 Nov 2022 19:30:51 -0800 (PST)
From: dusko <dusko@fbsd1.home.arpa>
Message-Id: <202211240330.2AO3Up92051179@fbsd1.home.arpa>
To: dusko@fbsd1.home.arpa
Subject: Test 01
Status: RO

Testing.
```


#### dtrace(1) - Counts, Statistics and Such

```
# dtrace -n 'syscall:::entry { @[execname, probefunc] = count(); }'

# dtrace -n 'syscall::read:return /execname == "sshd"/ { @ = quantize(arg0); }'

# dtrace -n 'syscall::read:entry { self->ts = timestamp; } syscall::read:return /self->ts / \
 { @ = quantize(timestamp - self->ts); self->ts = 0; }'

# dtrace -n 'syscall::read:entry { self->vts = vtimestamp; } syscall::read:return /self->vts/ \
 { @["On-CPU us:"] = lquantize((vtimestamp - self->vts) / 1000, 0, 10000, 10); self->vts = 0; }'

# dtrace -n 'proc::: { @[probename] = count(); } tick-5s { exit(0); }'

# dtrace -x stackframes=100 -n 'profile-99 /arg0/ { @[stack()] = count(); }'

# dtrace -n 'sched:::off-cpu { @[stack(8)] = count(); }'

# dtrace -n 'tcp:::accept-established { @[args[3]->tcps_raddr] = count(); }'
```


**REFERENCES:** 

[DTraceOne-Liners - FreeBSD Wiki](https://wiki.freebsd.org/DTrace/One-Liners)


### Trace the Flow with `dtruss(1m)`

Examine all processes called "sendmail":

```
# dtruss -n sendmail
[ . . . ]
```

Run and examine the following command:

```
# dtruss 'printf %s\\n "Hello" | mail -v -s "Test" dusko'
[ . . . ]
```

```
# dtruss -a mail -v dusko
[ . . . ]
```

### Trace the Flow with `truss(1)`


```
# truss mail -v dusko
[ . . . ]
```


### Trace the Flow with `ktrace(1)`

```
# ktrace -i mail -v dusko
[ . . . ]
```

Then:

```
# kdump -f ktrace.out
```

```
# strings ktrace.out
```


## How do I see how sendmail will deliver a message?

Based on [How do I see how sendmail will deliver a message?](http://www.harker.com/sendmail/debug.deliver.html).

```
$ hostname
fbsd1.home.arpa
```

For a local mailbox:

```
$ sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> /parse dusko@fbsd1.home.arpa
Cracked address = $g
Parsing envelope recipient address
canonify           input: dusko @ fbsd1 . home . arpa
.
.   (output deleted)
.
final            returns: dusko
mailer local, user dusko
```

For an external (nonlocal) mailbox:

```
$ sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> /parse testuser1@yahoo.com 
Cracked address = $g
Parsing envelope recipient address
canonify           input: testuser1 @ yahoo . com
.
.   (output deleted)
.
final            returns: testuser1 @ yahoo . com
mailer esmtp, host yahoo.com., user testuser1@yahoo.com
```

The "mailer" is the delivery agent that will do the actual delivery.
You can find it in your `sendmail.cf` file by looking for the line starting
with "Mmailername", in this case "Mesmtp".  The *esmtp* delivery agent is
the same as *smtp* mailer (the *smtp* mailer includes support for sending
email to other hosts on the Internet) but also speaks ESMTP (Extended SMTP).
This is the preferred delivery agent for delivery over networks.  

The "host" is the host that *sendmail* will connect to, in this case
"yahoo.com".

The "user" is the actual recipient address that will be passed to the next
host for delivery, in this case "testuser1@yahoo.com". 


## The R Configuration Command

Rules are declared in the configuration file with the R configuration command. Like all configuration commands, the R rule configuration command must begin a line. The general form consists of an R command followed by three parts:

```
Rlhs    rhs   comment
    ↑       ↑
    tabs    tabs
```

The `lhs` stands for *lefthand* side and is most commonly expressed
as LHS.  The `rhs` stands for *righthand* side and is expressed as RHS.
The LHS and RHS are mandatory.  The third part (the `comment`) is optional.
The three parts must be separated from each other by one or more tab
characters (space characters will *not* work).

Space characters between the `R` and the LHS are optional.  If there is
a tab between the `R` and the LHS, *sendmail* prints and logs the
following error:

```
configfile: line number: R line: null LHS
```

Space characters can be used inside any of the three parts: the LHS, RHS,
or comment.  They are often used in those parts to make rules clearer and
easier to parse visually.

The tabs leading to the comment and the comment itself are optional and
can be omitted.  If the RHS is absent, *sendmail* prints the following
warning and ignores that `R` line:

`invalid rewrite line "bad rule here" (tab expected)`

This error is printed when the RHS is absent, even if there are tabs
following the LHS.  (This warning is usually the result of tabs being
converted to spaces when text is copied from one window to another in
a windowing system using cut and paste.)


## O -- Set Option

From *Sendmail Installation and Operation Guide, No. 8, SMM* (on FreeBSD 13, location: `/usr/local/share/doc/sendmail/op.ps` (PostScript version) `/usr/local/share/doc/sendmail/op.txt` (plain text version)):

> 5.7.  O -- Set Option
> 
> There are a number of global options that can be set from a configuration file.
> Options are represented by full words; some are also representable as single characters for back compatibility. 
> The syntax of this line is:
> ```
> O  option=value
> ```
>
> This sets option option to be value.
> Note that there must be a space between the letter `O` and the name of the option.
> An older version is:
> ```
> Oovalue
> ```
>
> where the option `o` is a single character.
> Depending on the option, value may be a string, an integer, a boolean (with legal values "t", "T", "f", or "F"; the default is TRUE), or a time interval.
> 
> . . . 
> 
> The options supported (with the old, one character names in brackets) are:
>
> . . . 
> 
> AliasFile=spec, spec, ...    
> [A]  Specify possible alias file(s).     
> . . . 
> 
> All options can be specified on the command line using the `-O` or `-o` flag, but most will cause *sendmail* to relinquish its  *set-user-ID*  permissions.
> 
> The options that will not cause this are SevenBitInput [7], EightBitMode [8], MinFreeBlocks [b], CheckpointInterval [C], DeliveryMode [d], ErrorMode [e], IgnoreDots [i], SendMimeErrors [j], LogLevel [L], MeToo [m], OldStyleHeaders [o], PrivacyOptions [p], SuperSafe [s], Verbose [v], Que
ueSortOrder, MinQueueAge, DefaultCharSet, DialDelay, NoRecipientAction, ColonOkInAddr, MaxQueueRunSize, SingleLineFromHeader, and AllowBogusHELO.
> 
> Actually, PrivacyOptions [p] given on the command line are added to those already specified in  the sendmail.cf  file, i.e., they can't be reset.
> 
> Also, M(define macro) when defining the r or s macros is also considered "safe".


## Comments

Comments provide you with the documentation necessary to maintain the
configuration file.  Because comments slow down *sendmail* by only
a negligible amount, and only at startup, it is better to overcomment
than to undercomment.

Blank lines and lines that begin with a `#` character are considered
comments and are ignored.  A blank line is one that contains no characters
at all (except for its terminating newline).  Indentation characters
(spaces and tabs) are invisible and can turn an apparently blank line into
an empty-looking line, which is not ignored:

```
# text            ← a comment
tabtext            ← a continuation line
            ← a blank line
tab            ← an "empty-looking line"
```

---

```
$ sed -n 4647,4672p /usr/local/share/sendmail/cf/README 

+--------------------------+
| FORMAT OF FILES AND MAPS |
+--------------------------+

Files that define classes, i.e., F{classname}, consist of lines
each of which contains a single element of the class.  For example,
/etc/mail/local-host-names may have the following content:

my.domain
another.domain

Maps must be created using makemap(8) , e.g.,

        makemap hash MAP < MAP

In general, a text file from which a map is created contains lines
of the form

key     value

where 'key' and 'value' are also called LHS and RHS, respectively.
By default, the delimiter between LHS and RHS is a non-empty sequence
of white space characters.
```

## V8 Comments

Beginning with V8 *sendmail*, all lines of configuration files of version
levels 3 and above can have optional trailing comments.  That is, all text
from the first `#` character to the end of the line is ignored.
Any whitespace (space or tab characters) leading up to the `#` is also ignored:

```
CWlocalhost mailhost  # This is a comment
                    ↑
                    from here to end of line ignored
```

To include a `#` character in a line under V8 *sendmail*, precede it with
a backslash:

```
DM16\#megs
```

Note that you do not need to escape the `#` in the `$#` operator.
The `$` has a higher precedence, and `$#` is interpreted correctly.


## Continuation Lines

A line that begins with either a tab or a space character is considered
a continuation of the preceding line.  Internally, such continuation lines
are joined to the preceding line, and the newline character of that
preceding line is retained.  Thus, for example:

```
DZzoos
       lions and bears
↑
line begins with a tab character
```

is internally joined by *sendmail* to form:

```
DZzoos\n       lions and bears
       ↑
       newline and tab retained
```

Both the newline (`\n`) and the tab are retained.  When such a joined line
is later used (as in a header), the joined line is split at the newline
and prints as two separate lines again.

## Pitfalls

* Avoid accidentally creating an empty-looking line (one that contains only
invisible space and tab characters) in the *sendmail.cf* file when you
really intend to create a blank line (one that contains only the newline
character).  The empty-looking line is joined by *sendmail* to the line
above it and is likely to cause mysterious problems that are difficult
to debug.  One way to find such lines is to run a command such as the
following, where there is a single space between the `^` and the dot:

```
$ grep '^ .*$' /etc/mail/sendmail.cf
```

* The listening daemon and the submission *msp sendmail* use two different
configuration files (i.e., *sendmail.cf* and *submit.cf*).  Unless you
specify a specific configuration file with `-C`, the `-Am` and `-Ac`
switches determine which of the two configuration files is used.


## Pitfalls

* The use of the `#` to place comments into a *.mc* file for eventual
transfer to your configuration file might not work as expected.  The `#` is
not special to the *m4* processor, so *m4* continues to process a line even
though that line is intended to be a comment.  So, instead of:

`# Here we define $m as our domain`

(which would see `define` as an *m4* keyword), use single quotes to
insulate all such comments from *m4* interpretation:

```
# `Here we define $m as our domain'
```

* Never blindly overwrite your *sendmail.cf* file with a new one.
Always compare the new version to the old first:

```
$ diff /etc/mail/sendmail.cf oursite.cf
19c19
< ##### built by you@oursite.com on Sat Nov  3  11:26:39 PDT 2007
---
> ##### built by you@oursite.com on Fri Dec 14 04:14:25 PDT 2007
```

Here, the only change was the date the files were built, but if you had
expected some other change, this would tell you the change had failed.

* Never edit your *sendmail.cf* file directly.  If you do, you will never
be able to generate a duplicate or update from your mc file.  This is an
especially serious problem when upgrading from one release of *sendmail*
to a newer release.  Should you make this mistake, reread the appropriate
sections in this book and the documentation supplied with the *sendmail*
source.

* Don't assume that UUCP support and UUCP relaying are turned off by default.
Always use `FEATURE(nouucp)` to disable UUCP unless you actually support UUCP:

```
FEATURE(`nouucp')               ← recommended through V8.9
FEATURE(`nouucp',`reject')      ← recommended with V8.10 and later
```

## Syntax

The `>` prompt expects rule sets and addresses to be specified like this:

`> ident,ident,ident ...   address`

Each `ident` is a rule set name or number.  When there is more than one
rule set, they must be separated from each other by commas (with no spaces
between them).

For numbered rule sets, the number must be in the range of 0 through the
highest number allowed.  A number that is too large causes *sendmail* to
print the following two errors:

```
bad rule set number (max max)
Undefined rule set number
```

A rule set whose number is below the maximum but was never defined will
act as though it was defined but lacks rules.

Named rule sets must exist in the symbol table. If the name specified was
never defined, the following error is printed:

`Undefined rule set ident` 


If any rule set number in the comma-separated list of rule sets is omitted
(e.g., `ident,,ident`), *sendmail* interprets the second comma as part of
the second identifier, thus producing this error:

`Undefined rule set ,identifier`

The `address` is everything following the first whitespace (space and tab
characters) to the end of the line.  If whitespace characters appear
anywhere in the list of rule sets, the rule sets to the right of the
whitespace are interpreted as part of the address.

We show named rule sets in our examples, even though numbered rule sets
will work just as well.  But by using named rule sets, the examples will
still work even if the corresponding numbers change in the future.


## The Configuration File

The configuration file contains all the information *sendmail* needs to do
its job.  Within it you provide information, such as file locations,
permissions, and modes of operation.

Rewriting rules and rule sets also appear in the configuration file.
They transform a mail address into another form that might be required for
delivery.  They are perhaps the single most confusing aspect of the
configuration file.  Because the configuration file is designed to be fast
for sendmail to read and parse, rules can look cryptic to humans:

```
R $+ @ $+		$: $1 < @ $2 >	focus on domain
R $+ < $+ @ $+ >	$1 $2 < @ $3 >	move gaze right
```

But what appears to be complex is really just succinct.  The `R` at the
beginning of each line, for example, labels a rewrite rule.  And the `$+`
expressions mean to match one or more parts of an address.  With experience,
such expressions (and indeed the configuration file as a whole) soon
become meaningful.

Fortunately, you don't need to learn the details of rule sets to configure
and install sendmail.  The *mc* form of configuration insulates you from
such details, and allows you to perform very complex tasks easily.

## Configuration Commands

The *sendmail.cf* configuration file is line-oriented.  
A configuration command, composed of a single letter, begins each line:

```
V10/Berkeley                       ← good
V10/Berkeley                       ← bad, does not begin a line
V10/Berkeley Fw/etc/mail/mxhosts   ← bad, two commands on one line
Fw/etc/mail/mxhosts                ← good
```

Each configuration command is followed by parameters that are specific
to it.  For example, the `V` command is followed by an ASCII representation
of an integer value, a slash, and a vendor name.  Whereas the `F` command
is followed by a letter (a `w` in the example), then the full pathname of
a file.  The complete list of configuration commands is shown in
Footnotes  **<sup>[[2]](#footnotes)</sup>**.

Some commands, such as `V`, should appear only once in your *sendmail.cf*
file.  Others, such as `R`, can appear often.

Blank lines and lines that begin with the `#` character are considered
comments and are ignored.  A line that begins with either a tab or a space
character is a continuation of the preceding line:

```
# a comment
V10
     /Berkeley  ← continuation of V line above
  ↑ tab
```

Note that anything other than a command, a blank line, a space, a tab,
or a `#` character causes an error.  If the *sendmail* program finds such
a character, it prints the following warning, ignores that line, and
continues to read the configuration file:

`/etc/mail/sendmail.cf: line 15: unknown configuration line "v9"`

Here, *sendmail* found a line in its *sendmail.cf* file that began with
the letter `v`.  Because a lowercase `v` is not a legal command, *sendmail*
printed a warning.  The line number in the warning is that of the line in
the *sendmail.cf* file that began with the illegal character.


## Rules

At the heart of the *sendmail.cf* file are sequences of rules that
rewrite (transform) mail addresses from one form to another.  This is
necessary chiefly because addresses must conform to many differing
standards.  The R command is used to define a rewriting rule:

`R$-	$@ $1 @ $R     user ->  user @ remote `

Mail addresses are compared to the rule on the left (`$-`).  If they match
that rule, they are rewritten on the basis of the rule on the right
(`$@ $1 @ $R`).  The text at the far right is a comment (that doesn't
require a leading `#`).

Use of multicharacter macros and `#` comments (V8 configuration files and
above) can make rules appear a bit less cryptic:

```
R$-				# If a plain username
	$@ $1 @ ${REMOTE}	#    append "@" remote host
```

## Rule sets

Because rewriting can require several steps, rules are organized into sets,
which can be thought of as subroutines.  The `S` command begins a rule set:

`S3`

This particular `S` command begins rule set 3.  Beginning with V8.7 *sendmail*,
rule sets can be given symbolic names as well as numbers:

`SHubset`

This particular `S` command begins a rule set named `Hubset`.  Named rule
sets are automatically assigned numbers by *sendmail*.

All the `R` commands (rules) that follow an `S` command belong to that
rule set.  A rule set ends when another `S` command appears to define
another rule set.


## Chapter 18. The R (Rules) Configuration Command

Rules are like little if-then or while-do clauses, existing inside rule
sets, that test a pattern against an address and change the address if the
two match.  The process of converting one form of an address into another
is called **rewriting**.  Most rewriting requires a sequence of many rules
because an individual rule is relatively limited in what it can do.
This need for many rules, combined with the *sendmail* program's need for
succinct expressions, can make sequences of rules dauntingly cryptic.


## The R Configuration Command

Rules are declared in the configuration file with the `R` configuration
command.  Like all configuration commands, the `R` rule configuration
command must begin a line.  The general form consists of an `R` command
followed by three parts:

```
Rlhs    rhs   comment
    ↑       ↑
    tabs    tabs
```

The `lhs` stands for **lefthand side** and is most commonly expressed
as **LHS**.  The `rhs` stands for **righthand side** and is expressed
as **RHS**.  The LHS and RHS are mandatory. The third part (the `comment`)
is optional.  The three parts must be separated from each other by one or
more **tab** characters (space characters will not work).

Space characters between the `R` and the LHS are optional.  If there is
a tab between the R and the LHS, *sendmail* prints and logs the following
error:

`configfile: line number: R line: null LHS`

Space characters can be used inside any of the three parts: the LHS, RHS,
or comment.  They are often used in those parts to make rules clearer and
easier to parse visually.

The tabs leading to the comment and the comment itself are optional and
can be omitted.  If the RHS is absent, *sendmail* prints the following
warning and ignores that `R` line:

`invalid rewrite line "bad rule here" (tab expected)`

This error is printed when the RHS is absent, even if there are tabs
following the LHS.  (This warning is usually the result of tabs being
converted to spaces when text is copied from one window to another in
a windowing system using cut and paste.)


## Macros in Rules

Each noncomment part of a rule is expanded as the configuration file
is read.  (Actually, the comment part is expanded too, but with no effect
other than a tiny expenditure of time.)  Thus, any references to defined
macros are replaced with the value that the macro has at that point in the
configuration file.  To illustrate, consider the following mini
configuration file (which is named *test.cf*):

```
V10
Stest
DAvalue1
R $A	$A.new
DAvalue2
R $A	$A.new
```

First, note that as of V8.10 *sendmail*, rules (the `R` lines) cannot exist
outside of rule sets (the `S` line).  If you omit a rule set declaration,
the following error will be printed and logged:

`configfile: line number: missing valid ruleset for "bad rule here"`

Second, note that beginning with V8.9, *sendmail* will complain if the
configuration file lacks a correct version number (the `V` line).
Had you omitted that line, *sendmail* would have printed and logged the
following warning:

```
Warning: .cf file is out of date: sendmail 8.12.6 supports version 10,
.cf file is version 0
```

The first `D` line assigns the value `value1` to the `$A` *sendmail* macro.
The second `D` line replaces the value assigned to `$A` in the first line
with the new value `value2`.  Thus, `$A` will have the value `value1` when
the first `R` line is expanded and `value2` when the second is expanded.
Prove this to yourself by running *sendmail* in `-bt` rule-testing mode to
test that file:

```
$ printf =Stest | sendmail -bt -Ctest.cf
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> Rvalue1               value1 . new 
Rvalue2                 value2 . new 
> $ 
```

Here, you used the `=S` command to show each rule after it has been read
and expanded.

Another property of macros is that an undefined macro expands to an empty
string.  Consider this rewrite of the previous *test.cf* file in which you
use a `$B` macro that was never defined:

```
V10
Stest
DAvalue1
R $A	$A.$B
DAvalue2
R $A	$A.$B
```

Run *sendmail* again, in rule-testing mode, to see the result:

```
$ printf =Stest | sendmail -bt -Ctest.cf
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> Rvalue1               value1 . 
Rvalue2                 value2 . 
> $ 
```

Beginning with V8.7, *sendmail* macros can be either single-character or
multicharacter.  Both forms are expanded when the configuration file is read:

```
D{YOURDOMAIN}us.edu
R ${YOURDOMAIN}    localhost.${YOURDOMAIN}
```

Multicharacter macros can be used in the LHS and in the RHS.
When the configuration file is read, the previous example is expanded
to look like this:

`R us . edu               localhost . us . edu`

It is critical to remember that macros are expanded when the
configuration file is read.  If you forget, you might discover that
your configuration file is not doing what you expect.

## Rules Are Treated Like Addresses

After each side (LHS and RHS) is expanded, each is then normalized just
as though it were an address.  A check is made for any **tabs** that might
have been introduced during expansion.  If any are found, everything from
the first tab to the end of the string is discarded.

Then, if the version of the configuration file you are running is less
than 9 (that is, if the version of *sendmail* you are running is less
than V8.10), RFC2822-style comments are removed.  An RFC2822 comment is
anything between and including an unquoted pair of parentheses:

```
DAroot@my.site (Operator)
R $A  <tab>RHS
   ↓
R root@my.site (Operator)  <tab>RHS        ← expanded
   ↓
R root@my.site  <tab>RHS      ← comment stripped prior to version 8 configs only
```

Finally, prior to V8.13 (as of V8.13, rules no longer need to balance),
a check was made for balanced quotation marks, and for right angle brackets
balanced by left (The `$>` operator isn't counted in checking balance.)
If any righthand character appeared without a corresponding lefthand
character, *sendmail* printed one of the following errors (where
*configfile* is the name of the configuration file that was being read,
*number* shows the line number in that file, and *expression* is the part
of the rule that was unbalanced) and attempted to make corrections:

```
configfile : line number: expression  ...Unbalanced '"'
configfile : line number: expression ...Unbalanced ''
```

Note that prior to V8.13, an unbalanced quotation mark was corrected by
appending a second quotation mark, and an unbalanced angle bracket was
corrected by removing it.  Consider the following *test.cf* confirmation file:

```
V8
Stest
R x      RHS"
R y      RHS>
```

If you ran pre-V8.13 *sendmail* in rule-testing mode on this file, the
following errors and rules would be printed:

```
$ printf =Stest | sendmail -bt -Ctest.cf
test.cf: line 3: RHS"... Unbalanced '"'
test.cf: line 4: RHS>... Unbalanced '>'
R x              RHS ""
R y              RHS
```

### As of V8.13, rules no longer need to balance

Prior to V8.13, special characters in rules were required to balance.
If they didn't, *sendmail* would issue a warning and try to make them balance:

```
SCheck_Subject
R ----> test <----         $#discard $: discard
```

### $-operators Are Tokens

As we progress into the details of rules, you will see that certain
characters become operators when prefixed with a `$` character.
Operators cause *sendmail* to perform actions, such as looking for
a match (`$*` is a wildcard operator) or replacing tokens with others by
position (`$1` is a replacement operator).

For tokenizing purposes, operators always divide one token from another,
just as the characters in the master list did.  For example:

`xxx$*zzz    becomes  →   xxx  $*  zzz`

### The Space Character Is Special

The space character is special for two reasons.  First, although the space
character is not in the master list, it *always* separates one token from
another:

`xxx zzz    becomes →  xxx  zzz`

Second, although the space character separates tokens, it is not itself
a token.  That is, in this example the seven characters on the left
(the fourth is the space in the middle) become two tokens of three
letters each, not three tokens.  Therefore, the space character can be
used inside the LHS or RHS of rules for improved clarity but does not
itself become a token or change the meaning of the rule.

### The Workspace

As was mentioned, rules exist to rewrite addresses.  We won't cover the
reasons this rewriting needs to be done just yet, but we will concentrate
on the general behavior of rewriting.

Before any rules are called to perform rewriting, a temporary buffer called
the "workspace" is created.  The address to be rewritten is then tokenized
and placed into that workspace.  The process of tokenizing addresses in the
workspace is exactly the same as the tokenizing of rules that you saw before:

`gw@wash.dc.gov    becomes  →   gw  @  wash  .  dc  . gov`

Here, the tokenizing characters defined by the `OperatorChars` option and
those defined internally by *sendmail* caused the address to be broken into
seven tokens.  The process of rewriting changes the tokens in the workspace:

```
                       ← workspace is "gw" "@" "wash" "." "dc" "." "gov"
R <lhs> <rhs>  R <lhs> <rhs>                ← rules rewrite the workspace
R <lhs> <rhs>                        ← workspace is "gw" "." "LOCAL"
```

Here, the workspace began with seven tokens.  The three hypothetical rules
recognized that this was a local address (in token form) and rewrote it so
that it became three tokens.


## The LHS

The LHS of any rule is compared to the current contents of the workspace
to determine whether the two match.  Table LHS Operators Table
**<sup>[[3]](#footnotes)</sup>** displays a variety of special operators
offered by *sendmail* that make comparisons easier and more versatile.


## The RHS

The purpose of the RHS in a rule is to rewrite the workspace.  To make this
rewriting more versatile, *sendmail* offers several special RHS operators.
The complete list is shown in Table RHS Operators Table
**<sup>[[4]](#footnotes)</sup>**.

---

## Debugging/Troubleshooting check_* in sendmail

From [Debugging check_* in sendmail 8.8/8.9 and later](https://www.sendmail.org/~ca/email/chk-dbg.h
tml) (By: Claus Aßmann - Last Update 2006-03-31)
(Retrieved on 2022-11-02)   

and

sendmail, 4th Edition (a.k.a. Bat Book), Published by O'Reilly Media, Inc.,
Publication Date: October 2007 (Chapter 7. How to Handle Spam, 
Subchapter "The Local_check_ Rule Sets" - Section "Local_check_relay and check_relay")

> After you have installed the new [check_* rules](https://www.sendmail.org/~ca/email/check.html)
or you
> use [sendmail 8.9 (and later) standard FEATUREs](https://www.sendmail.org/~ca/email/chk-89.html)
to avoid misuse of your system and spam from well-known
> sites, you need to test them.  Or you can blindly trust the guys who wrote
> them... (never do that, someone may have made a mistake!).

> First, you can use conventional debugging by testing the rewrite rules
> directly with `sendmail -bt`.  If you want to test those rulesets
> ([check_relay](https://www.sendmail.org/~ca/email/check.html#check_relay),
> [check_compat](https://www.sendmail.org/~ca/email/check.html#check_compat))
> which use the `$|` token, you should introduce the following ruleset first:

```
STranslate
R $* $$| $*	$: $1 $| $2	fake for -bt mode, remove for real version
```

NOTE:  There are two **tab** characters, one before  `$:` and the other
before `fake for -bt mode, remove for real version`.

This rule set changes a literal `$` and `|` into a `$|` operator so that
you can test rule sets such as `Local_check_relay` from rule-testing mode:

```
$ sudo su

# sendmail -bt
ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
Enter <ruleset> <address>
> Translate,Local_check_relay bogus.host.domain $| 123.45.67.89
Translate          input: bogus . host . domain $| 123 . 45 . 67 . 89
Translate        returns: bogus . host . domain $| 123 . 45 . 67 . 89
Local_check_rela   input: bogus . host . domain $| 123 . 45 . 67 . 89
Local_check_rela returns: bogus . host . domain $| 123 . 45 . 67 . 89
> 
> /quit
```

Also, see:


```
$ sed -n 2910,2950p /usr/local/share/sendmail/cf/README
Header Checks
-------------

You can also reject mail on the basis of the contents of headers.
This is done by adding a ruleset call to the 'H' header definition command
in sendmail.cf.  For example, this can be used to check the validity of
a Message-ID: header:

        LOCAL_CONFIG
        HMessage-Id: $>CheckMessageId

        LOCAL_RULESETS
        SCheckMessageId
        R< $+ @ $+ >            $@ OK
        R$*                     $#error $: 553 Header Error


The alternative format:

        HSubject: $>+CheckSubject

that is, $>+ instead of $>, gives the full Subject: header including
comments to the ruleset (comments in parentheses () are stripped
by default).

A default ruleset for headers which don't have a specific ruleset
defined for them can be given by:

        H*: $>CheckHdr

Notice:
1. All rules act on tokens as explained in doc/op/op.{me,ps,txt}.
That may cause problems with simple header checks due to the
tokenization.  It might be simpler to use a regex map and apply it
to $&{currHeader}.
2. There are no default rulesets coming with this distribution of
sendmail.  You can write your own, can search the WWW for examples,
or take a look at cf/cf/knecht.mc.
3. When using a default ruleset for headers, the name of the header
currently being checked can be found in the $&{hdr_name} macro.
```

---

## Footnotes

[1] If you depended on the old behavior where `Family` and `family` both
worked, rebuild *sendmail* with the *Build*-time macro `_FFR_DPO_CS` defined.
Note that beginning with V8.15, `Addr`, `Family`, `Listen`, `Modifier`,
`Name`, and `SendBufferSize` became case-insensitive, all the others
remained case-sensitive.

[2] The *sendmail.cf* file's configuration commands

```
+---------+------------------------------------------------------------+
| Command | Description                                                |
+---------+------------------------------------------------------------+
| C       | Define a class macro.                                      |
+---------+------------------------------------------------------------+
| D       | Define a macro.                                            |
+---------+------------------------------------------------------------+
| E       | Define an environment variable (beginning with V8.7).      |
+---------+------------------------------------------------------------+
| F       | Define a class macro from a file, pipe, or database map.   |
+---------+------------------------------------------------------------+
| H       | Define a header.                                           |
+---------+------------------------------------------------------------+
| K       | Declare a keyed database (beginning with V8.1).            |
+---------+------------------------------------------------------------+
| L       | Include extended load average support (contributed         |
|         | software, not covered).                                    |
+---------+------------------------------------------------------------+
| M       | Define a mail delivery agent.                              |
+---------+------------------------------------------------------------+
| O       | Define an option.                                          |
+---------+------------------------------------------------------------+
| P       | Define delivery priorities.                                | 
+---------+------------------------------------------------------------+
| Q       | Define a queue (beginning with V8.12).                     |
+---------+------------------------------------------------------------+
| R       | Define a rewriting rule.                                   |
+---------+------------------------------------------------------------+
| S       | Declare a rule-set start.                                  |
+---------+------------------------------------------------------------+
| T       | Declare trusted users (ignored in V8.1, restored in V8.7). | 
+---------+------------------------------------------------------------+
| V       | Define configuration file version (beginning with V8.1).   |
+---------+------------------------------------------------------------+
| X       | Define a mail filter (beginning with V8.12).               | 
+---------+------------------------------------------------------------+
```


[3]  LHS Operators Table 

```
+----------+-------------------------+---------------------------------------+
| Operator | §                       | Description or use                    |
+----------+-------------------------+---------------------------------------+
| $*       |                         | Match zero or more tokens.            |
+----------+-------------------------+---------------------------------------+
| $+       |                         | Match one or more tokens.             |
+----------+-------------------------+---------------------------------------+
| $-       |                         | Match exactly one token.              |
+----------+-------------------------+---------------------------------------+
| $@       |                         | Match exactly zero tokens (V8 only).  |
+----------+-------------------------+---------------------------------------+
| $=       | Matching Any in         | Match any tokens in                   |
|          | a Class: $=             | a class.  [a]                         |
+----------+-------------------------+---------------------------------------+
| $˜       | Matching Any Token Not  | Match any single token not            |
|          | in a Class: $~          | in a class.                           |
+----------+-------------------------+---------------------------------------+
| $#       |                         | Match a literal $#.                   |
+----------+-------------------------+---------------------------------------+
| $|       |                         | Match a literal $|.                   |
+----------+-------------------------+---------------------------------------+
| $&       | Use Value As Is with $& | Delay macro expansion until runtime.  |
+----------+-------------------------+---------------------------------------+
```

**[a]** Class matches either a single token or multiple tokens, depending on
        the version of *sendmail*. 


The first three operators in the LHS Operators Table are wildcard operators,
which can be used to match arbitrary sequences of tokens in the workspace. 
Consider the following rule, which employs the `$-` operator (match any
single token):

`R $-	fred.local`

Here, a match is found only if the workspace contains a single token
(such as tom).  If the workspace contains multiple tokens (such as
*tom@host*), the LHS does not match.  A match causes the workspace to be
rewritten by the RHS to become `fred.local`.  The rewritten workspace is
then compared again to the `$-`, but this time there is no match because
the workspace contains three tokens (`fred`, a dot [`.`], and `local`).
Because there is no match, the *current* workspace (`fred.local`) is
carried down to the next rule (if there is one).

The `$@` operator (introduced in V8 *sendmail*) matches an empty workspace.
Merely omitting the LHS won't work:

```
R<tab>RHS                ← won't work
R $@<tab>RHS                ← will work
```

If you merely omit the LHS in a mistaken attempt to match an empty LHS,
you will see the following error when sendmail starts up:

`configfile: line number: R line: null LHS`

Note that all comparisons of tokens in the LHS to tokens in the workspace
are done in a case-insensitive manner.  That is, `tom` in the LHS matches
`TOM`, `Tom`, and even `ToM` in the workspace.


[4]  RHS Operators Table 

```
+----------+-------------------------+---------------------------------------+
| RHS      | §                       | Description or use                    |
+----------+-------------------------+---------------------------------------+
| $ digit  | Copy by Position:       | Copy by position.                     | 
|          | $digit                  |                                       |
+----------+-------------------------+---------------------------------------+
| $:       | Rewrite Once Prefix: $: | Rewrite once (when used as a prefix), |
|          |                         | or specify the user in a delivery     |
|          |                         | agent "triple," or specify the        |
|          |                         | default value to return on a failed   |
|          |                         | database-map lookup.                  | 
+----------+-------------------------+---------------------------------------+
| $@       | Rewrite-and-Return      | Rewrite and return (when used as a    |
|          | Prefix: $@              | prefix), or specify the host in a     |
|          |                         | delivery-agent "triple," or specify   |
|          |                         | an argument to pass in a database-map |
|          |                         | lookup or action.                     | 
+----------+-------------------------+---------------------------------------+
| $> set   | Rewrite Through a Rule  | Rewrite through another rule set      |
|          | Set: $>set              | (such as a subroutine call that       |  
|          |                         | returns to the current position).     | 
+----------+-------------------------+---------------------------------------+
| $#       | Return a Selection: $#  | Specify a delivery agent or choose an |
|          |                         | action, such as to reject or discard  |
|          |                         | a recipient, sender, connection, or   |
|          |                         | message.                              |
+----------+-------------------------+---------------------------------------+
| $[ $]    | Canonicalize Hostname:  | Canonicalize the hostname.            | 
|          | $[ and $]               |                                       |
+----------+-------------------------+---------------------------------------+
| $( $)    | Use $( and $) in Rules  | Perform a lookup in an external       |
|          |                         | database, file, or network service,   |
|          |                         | or perform a change (such as          |
|          |                         | dequoting), or store a value into     |
|          |                         | a macro.                              |
+----------+-------------------------+---------------------------------------+
| $&       | Use Value As Is with $& | Delay conversion of a macro until     |
|          |                         | runtime.                              |
+----------+-------------------------+---------------------------------------+
```


[Using "env_sender $\| env_rcpt" check_compat rules in the check_rcpt ruleset](http://www.harker.com/sendmail/check_compat.in.check_rcpt.html)


[Auth to ISP - comp.mail.sendmail news group](https://groups.google.com/g/comp.mail.sendmail/c/1WfyI-e0nHU/m/xkdi2LcNjG4J)



