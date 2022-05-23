---
layout: post
title: "Procmail Recipe for Vacation Auto-Reply Only to Senders from Certain Domains"
date: 2022-02-28 22:25:12 -0700 
categories: sendmail howto dotfiles 
---

---

Sendmail version:  8.14.4   
OS: Red Hat Enterprise Linux Server release 6.8 (Santiago) 64-bit    
Procmail version:  v3.22    
Shell:  bash

```
# cat /etc/redhat-release 
Red Hat Enterprise Linux Server release 6.8 (Santiago)
```

```
# procmail -v
procmail v3.22 2001/09/10
  Copyright (c) 1990-2001, Stephen R. van den Berg <srb@cuci.nl>
  Copyright (c) 1997-2001, Philip A. Guenther      <guenther@sendmail.com>

---- snip ----
Default rcfile:         $HOME/.procmailrc
---- snip ----
```

```
# arch
x86_64
```

```
# ps $$
  PID TTY      STAT   TIME COMMAND
16113 pts/0    Ss     0:00 -bash

# printf %s\\n "$SHELL"
/bin/bash
```

Print the version of sendmail and the options it was compiled with.
To exit, send EOF (End Of File) by pressing Ctrl + d.

```
# sendmail -d0.1
Version 8.14.4
 Compiled with: DNSMAP HESIOD HES_GETMAILHOST LDAPMAP LOG MAP_REGEX
                MATCHGECOS MILTER MIME7TO8 MIME8TO7 NAMED_BIND NETINET NETINET6
                NETUNIX NEWDB NIS PIPELINING SASLv2 SCANF SOCKETMAP STARTTLS
                TCPWRAPPERS USERDB USE_LDAP_INIT

============ SYSTEM IDENTITY (after readcf) ============
      (short domain name) $w = yourdomainname
  (canonical domain name) $j = yourdomainname.com
         (subdomain name) $m = 
              (node name) $k = yourdomainname.com
========================================================

Recipient names must be specified
```

```
# command -v procmail
/usr/bin/procmail
```

```
# man -k procmail
procmail          (1)  - autonomous mail processor
procmailex        (5)  - procmail rcfile examples
procmailrc        (5)  - procmail rcfile
procmailsc        (5)  - procmail weighted scoring technique
procmail_selinux  (8)  - Security Enhanced Linux Policy for procmail processes
```

Switch to your user account, navigate to the home directory and create the procmail **rcfile**.

```
$ cd
$ vi /home/dusko/.procmailrc
```

```
$ cat /home/dusko/.procmailrc
#  Initialize some variables

SHELL=/bin/sh
PATH=/usr/sbin:/usr/bin:/bin

#  For IMAPS, the Maildir *must* end with a trailing slash.
MAILDIR=/home/dusko/Maildir/

DEFAULT=$MAILDIR
LOGFILE=$HOME/procmail.log
LOG="--- Logging ${LOGFILE} for ${LOGNAME}, "
VERBOSE=yes
LOGABSTRACT=all

### ------------------------- ###
###                           ### 
###          Recipes          ### 
###                           ### 
### ------------------------- ###

# ----------------------------------------------------------------------
# Send all messages from Cron Daemon or logwatch 
# to the indicated directory (named .logwatch). 
# ----------------------------------------------------------------------
:0
* ^From:.*(Cron Daemon|logwatch@)
/home/dusko/Maildir/.logwatch/

# ----------------------------------------------------------------------
# Send all messages from Charlie Root to the indicated directory 
# (named .bsdperiodic). 
# ----------------------------------------------------------------------
:0
* ^From:.*Charlie Root
/home/dusko/Maildir/.bsdperiodic/

# ----------------------------------------------------------------------
# Send all emails from root to a directory named .logwatch.
# ----------------------------------------------------------------------
:0
* ^From:.*root
/home/dusko/Maildir/.logwatch/


# ----------------------------------------------------------------------
# Reply **only** to messages from tech.example.com domain, 
# OR from thedusko.com, OR from duskopijetlovic.com,
# OR from mail.example.com, OR example.com.
# 
#  W: Create a lock file, vacation.lock. This is to make sure that 
#     the lockfile is not removed until the pipe has finished.
#  h: Action line gets fed to the headers of the message.
#  c: Operate on a clone (copy) of the message. 
#
# - Check whether the message is addressed to dusko@tech.example.com. 
#     NOTE:  All capital letters in TO -> It is procmail's own 
#            special command/macro, which means: '(To|Cc|Bcc)'.
# - Do NOT reply to daemons (like bounces or mailing lists).
# - Avoid mail loops.   
# - Maintain a vacation database in the vacation.cache file.
# ----------------------------------------------------------------------
:0 Whc: $HOME/vacation.lock
# The next line works for the 'To: ' _OR_ 'Cc: ' field.
# as opposed to, for example:
#   * $^To:.*\<$\LOGNAME\>
# which only works for the 'To: ' field.
* ^TOdusko@tech.example.com
* !^FROM_DAEMON
* !^X-Loop: dusko@tech.example.com
* ^From:.+(@tech\.example\.com|@thedusko\.com|@duskopijetlovic\.com|@mail\.example\.com|@example\.com)
| /usr/bin/formail -rD 8192 $HOME/vacation.cache


# ----------------------------------------------------------------------
# Process this recipe if the name was not in the cache file.
#  e: Execute this recipe if the previous recipe's conditions 
#     were met but its action(s) couldn't be completed.
#  h: Action line gets fed to the headers of the message.
#  c: Operate on a clone (copy) of the message. 
# 
# - Create the email body via echo(1) commands, and pipe it to sendmail.
# - Sendmail's -oi options do note treat a line containing a sole 
#   period (.) as the end of input (rarely needed but traditionally 
#   included to be safe). 
# - Sendmail's -t option tells the program to determine the 
#   recepient(s) from the message headers. 
# ----------------------------------------------------------------------
:0 ehc
| (formail -rI"Precedence: Auto" \
-A"X-Loop: dusko@tech.example.com" ; \
echo "I received your mail."; \
echo "I'm away and will return on Tuesday, March 1."; \
echo "-- "; cat $HOME/.signature \
) | $SENDMAIL -oi -t
```

```
$ cat /home/computing/dusko/.signature 
- Dusko
```

**NOTE:**    
The capitalized **TO** is procmail's own regular expression matching 
```To:``` **or** ```Cc:``` or ```Bcc:``` email address fields.

---

#### Installation

1. Ensure that the ```.procmailrc``` rcfile is in your home directory.
(**!! Do not forget to remove ```~/.procmailrc``` after it's not needed anymore. !!**)   

2. Customize the script for your needs:  
- Replace dusko@tech.example.com with your email address.    
- Customize your away message in the section with echo commands.  
- (Optional): If you want, you can use your signature separately by 
placing it in a file (.signature in your home directory).  If you don't 
need it, don't use the last line with echo command (```echo "-- "; cat $HOME/.signature \```).  

3. If you would like to add more domains to which your vacation 
out-of-office would reply, just add more domains. 
For example, for @scooby.test, you would use the following lines 
for 'From:' field: ```* ^From:.+@.scooby\.test```

4. There is no special formatting for ```.signature``` file so you can 
just copy/paste your signature into it.


#### Uninstallation/Stopping Procmail Auto-Reply

1. Remove ```$HOME/.procmailrc``` rcfile.    

2. Empty or delete the cache file.    
(When the condition (sender is from @tech.example.com or from @example.com 
or from thedusko.com or from duskopijetlovic.com or from mail.example.com), 
the first recipe creates a cache file in $HOME/vacation.cache.)
