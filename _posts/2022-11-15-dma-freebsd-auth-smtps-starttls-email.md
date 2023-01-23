---
layout: post
title: "Outgoing SMTP AUTH Mail with dma(8) from a FreeBSD System" 
date: 2022-11-15 09:31:24 -0700 
categories: sendmail smtp mta mailserver cli terminal shell freebsd sysadmin reference 
---

OSs:   
FreeBSD 13.1-RELEASE-p2, Shell: csh   

---

Set up a FreeBSD system to send mail from the command line.

Task: 
* Configure a CLI mail client to securely submit messages via SMTP over
TLS (Transport Layer Security) protocol.

---

SMTP use here is not MTA-to-MTA SMTP (Message Transfer Agent
[<sup>[1](#footnotes)</sup>] to Message Transfer Agent SMTP), which is
normally on port 25.  It's MUA-to-MSA (Mail User Agent
[<sup>[2](#footnotes)</sup>] to Mail Submission Agent) *submission* on
port 465. (The other secure submission method is STARTTLS on port 587;
connecting to the "cleartext" port and negotiating TLS using the STARTTLS
command). [<sup>[3](#footnotes)</sup>]

The RFC 6409 Memo [Message Submission for Mail - RFC6409 - IETF](https://www.rfc-editor.org/rfc/rfc6409) provides definitions of MTA (Message Transfer
Agent), MSA (Message Submission Agent), MUA (Message User Agent) and
SMTP (SMTP-MTA). [<sup>[4](#footnotes)</sup>]

--- 

In this example, my SMTP server (smart host) requires the following:
* SMTP authentication (SMTP AUTH), with mechanisms LOGIN or PLAIN
* **Implicit TLS** (or Enforced TLS) submission on port **465**.
The initial connection is started with a Transport Layer Security (TLS)
(default port 465); that is, the MTA listens on port 465 for message
submissions from MUAs. 


From [RFC8314 Memo - Cleartext Considered Obsolete: Use of Transport Layer Security (TLS) for Email Submission and Access - IETF](https://www.rfc-editor.org/rfc/rfc8314#section-3.3):
> **3.3.  Implicit TLS for SMTP Submission**
> 
> When a TCP connection is established for the "submissions" service
> (default port 465), a TLS handshake begins immediately.  Clients MUST
> implement the certificate validation mechanism described in
> [[RFC7817](https://www.rfc-editor.org/rfc/rfc7817)].  Once the TLS
> session is established, Message Submission protocol data
> [[RFC6409](https://www.rfc-editor.org/rfc/rfc6409)] is exchanged as TLS
> application data for the remainder of the TCP connection.
> (Note: The "submissions" service name is defined in
> [Section 7.3](https://www.rfc-editor.org/rfc/rfc8314#section-7.3) of this
> document and follows the usual convention that the name of a service
> layered on top of Implicit TLS consists of the name of the service as
> used without TLS, with an "s" appended.)

In other words, in order to allow relaying mail, the remote SMTP server
(smart host) requires clients to be authenticated first.  

The IETF issued a one-time [amendment](https://www.rfc-editor.org/rfc/rfc8314#section-7.3) to reinstate port 465 for message submission over TLS protocol.

---

## dma (DragonFly Mail Agent)

`dma(8)` is the DragonFly Mail Agent, and it is in base so you don't
need to install anything.

---

```
% command -v dma; type dma; which dma; whereis dma
dma: not found
dma: Command not found.
dma: /usr/libexec/dma /usr/share/man/man8/dma.8.gz
```

```
% file /usr/libexec/dma
/usr/libexec/dma: setgid ELF 64-bit LSB pie executable, x86-64, 
  version 1 (FreeBSD), dynamically linked, interpreter /libexec/ld-elf.so.1,
  for FreeBSD 13.1, FreeBSD-style, stripped
```

```
% grep sendmail_enable /etc/rc.conf
sendmail_enable="YES"
```

```
% sudo sed -i.bak -e 's/sendmail_enable="YES"/sendmail_enable="NONE"/' /etc/rc.conf
```

```
% grep sendmail_enable /etc/rc.conf                                
sendmail_enable="NONE"
```

```
% sudo vi /etc/dma/dma.conf
```

```
% sudo sed '/^[[:space:]]*$/d' /etc/dma/dma.conf | grep -v \^#
SMARTHOST your.isp.net
PORT 465
ALIASES /etc/aliases
SPOOLDIR /var/spool/dma
AUTHPATH /etc/dma/auth.conf
SECURETRANSFER
MASQUERADE domain.to.masquerade_as 
```

where `your.isp.net` is the FQDN of the SMTP server (your ISP/smart host).

From the man page for `dma(8)`:
> If `MASQUERADE` variable does not contain a @ sign, the string is
> interpreted as a host name.  For example, setting *MASQUERADE* to
> `john@` on host `hamlet` will send all mails as `john@hamlet`;
> setting it to `percolator` will send all mails as
> `username@percolator`.


```
% sudo chown root:mail /etc/dma/dma.conf
% sudo chown root:mail /etc/dma/auth.conf 
```

```
% sudo chmod 0640 /etc/dma/dma.conf
% sudo chmod 0640 /etc/dma/auth.conf
```

```
% sudo tee -a /etc/mail/mailer.conf <<EOF
sendmail        /usr/libexec/dma
send-mail       /usr/libexec/dma
mailq           /usr/libexec/dma
newaliases      /usr/libexec/dma
rmail           /usr/libexec/dma
EOF
```

```
% sudo tee -a /usr/local/etc/mail/mailer.conf <<EOF
sendmail        /usr/libexec/dma
send-mail       /usr/libexec/dma
mailq           /usr/libexec/dma
newaliases      /usr/libexec/dma
rmail           /usr/libexec/dma
EOF
```

Send a test email message to a local account:

```
% printf %s\\n "Testing." | mail -v -s "Test 1" dusko
``` 
 
```
% mail
Mail version 8.1 6/6/93.  Type ? for help.
"/var/mail/dusko": 1 message 1 new
>N  1 dusko@domain.to.masquerade_as    Tue Nov 15 18:34  13/378   "Test 1"
& 
Message 1:
From dusko@domain.to.masquerade_as Tue Nov 15 18:34:49 2022
To: dusko
Subject: Test 3
Date: Tue, 15 Nov 2022 18:34:49 -0800
From: <dusko@domain.to.masquerade_as>

Testing.
& q
Saved 1 message in mbox
```


Send a test email message to a non-local account:

```
% printf %s\\n "Testing." | mail -v -s "Test 2" dusko@example.com
```

```
Return-Path: <dusko@domain.to.masquerade_as>
Received: from fbsd1.home.arpa (external.domain.name [123.45.67.89])
	(authenticated bits=0)
	by smarthost.domain.name (8.14.4/8.14.4) with ESMTP id 1ABCdQe2345678
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <dusko@domain.to.masquerade_as>; Tue, 15 Nov 2022 18:35:26 -0800
Received: from dusko (uid 1001)
	(envelope-from dusko@domain.to.masquerade_as)
	id c7890
	by fbsd1.home.arpa (DragonFly Mail Agent v0.11+ on fbsd1.home.arpa);
	Tue, 15 Nov 2022 18:35:26 -0800
To: dusko@example.com
Subject: Test 2
Date: Tue, 15 Nov 2022 18:35:26 -0800
Message-Id: <12345a6b.c7890.123d45ef@fbsd1.home.arpa>
From: <dusko@domain.to.masquerade_as>

Testing.
```

---
 
**Reference:**    
[Simple solution for outgoing mail from a FreeBSD system](https://jpmens.net/2020/03/05/simple-solution-for-outgoing-mail-from-a-freebsd-system/)   

---

## Footnotes

[1] Also known as Mail Transfer Agent. 

[2] Also known as User Agent (UA).

Examples of MUAs (Mail User Agents): Thunderbird, Mutt, Pine/alpine,
Outlook, nail/malix. 

[3] *Sendmail* refers to these two modes as the MTA (mail transmission
    agent) and the MSP (mail submission program) -- From the
    `sendmail/SECURITY` document (on FreeBSD 13, located in:
    `/usr/local/share/doc/sendmail/SECURITY`):

```
Summary
-------

This is a brief summary how the two configuration files are used:

sendmail.cf  For the MTA (mail transmission agent)
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
```

[4] From 
[Message Submission for Mail - RFC6409 - IETF](https://www.rfc-editor.org/rfc/rfc6409): 

> **1.  Introduction**
> 
> SMTP [[SMTP-MTA](https://www.rfc-editor.org/rfc/rfc6409#ref-SMTP-MTA)
> [<sup>[5](#footnotes)</sup>]] was defined as a message *transfer* protocol,
> that is, a means to route (if needed) and deliver finished (complete)
> messages.
> 
> Message Transfer Agents (MTAs) are not supposed to alter the message
> text, except to add 'Received', 'Return-Path', and other header
> fields as required by
> [[SMTP-MTA](https://www.rfc-editor.org/rfc/rfc6409#ref-SMTP-MTA)
> [<sup>[5](#footnotes)</sup>]].
> 
> However, SMTP is now also widely used as a message *submission* protocol,
> that is, a means for Message User Agents (MUAs) to introduce new
> messages into the MTA routing network.  The process that accepts message
> submissions from MUAs is termed a "Message Submission Agent" (MSA).
> 
> In order to permit unconstrained communications, SMTP is not often
> authenticated during message relay.
> 
> Authentication and authorization of initial submissions have become
> increasingly important, driven by changes in security requirements
> and rising expectations that submission servers take responsibility
> for the message traffic they originate.
> 
> For example, due to the prevalence of machines that have worms,
> viruses, or other malicious software that generate large amounts of
> spam, many sites now prohibit outbound traffic on the standard SMTP
> port (port 25), funneling all mail submissions through submission
> servers.
>
> [ . . . ]
> 
> **2.  Document Information**   
> **2.1.  Definitions of Terms Used in This Memo**    
> 
> Message Submission Agent (MSA)
> 
> A process that conforms to this specification.  An MSA acts as a
> submission server to accept messages from MUAs, and it either
> delivers them or acts as an SMTP client to relay them to an MTA.
> 
> Message Transfer Agent (MTA)
> 
> A process that conforms to [SMTP-MTA].  An MTA acts as an SMTP server
> to accept messages from an MSA or another MTA, and it either delivers
> them or acts as an SMTP client to relay them to another MTA.
> 
> Message User Agent (MUA)
> 
> A process that acts (often on behalf of a user and with a user
> interface) to compose and submit new messages, and to process
> delivered messages.
> 
> For delivered messages, the receiving MUA may obtain and process the
> message according to local conventions or, in what is commonly
> referred to as a split-MUA model, Post Office Protocol [POP3] or IMAP
> [IMAP4] is used to access delivered messages, whereas the protocol
> defined here (or SMTP) is used to submit messages.

[5] [SMTP-MTA] Klensin, J., "Simple Mail Transfer Protocol",
    [RFC 5321](https://www.rfc-editor.org/rfc/rfc5321), October 2008.

---

