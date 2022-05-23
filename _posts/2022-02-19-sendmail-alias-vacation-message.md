---
layout: post
title: "Sendmail Autoreply Vacation Messages (a.k.a. OOO) for an Alias"
date: 2022-02-19 18:41:01 -0700 
categories: sendmail mailserver email howto
---

a.k.a.: Auto respond from an alias 

Note:  OOO = Out Of Office


OS:  Red Hat Enterprise Linux Server release 6.8 (Santiago) 64-bit  
Sendmail version:  8.14.4

```
# sendmail -d0.1
Version 8.14.4
---- snip ----
```

On the mail server:

```
# grep dusko /etc/passwd
dusko:x:1001:1001:FName Lname:/home/dusko:/bin/csh
```

```
# sendmail -bv myalias
myalias... User unknown
```

```
# printf %s\\n "myalias: dusko" >> /etc/aliases
```

```
# grep dusko /etc/aliases
dusko: myalias
```

```
# ls -ld /home/dusko/
drwx------. 15 dusko mail 4096 Dec  7 11:27 /home/dusko/
```


```
# ls -lh /etc/aliases.db
-rw-r--r--. 1 root root 84K Feb 15 20:16 /etc/aliases.db

# date
Sat Feb 19 21:36:28 PST 2022

# newaliases
/etc/aliases: 572 aliases, longest 60 bytes, 25488 bytes total

# ls -lh /etc/aliases.db
-rw-r--r--. 1 root root 84K Feb 19 21:36 /etc/aliases.db
```


```
# sendmail -bv myalias
dusko... deliverable: mailer local, user dusko 
```


The vacation program automatically replies to incoming mail. 
The reply is contained in the file ```.vacation.msg``` in your home directory.  

The ```.vacation.msg``` file should include a header with at least 
a 'Subject:' line (it should not contain a 'To:' line and need not contain 
a 'From:' line since these are generated automatically).  If the string 
**$SUBJECT** appears in the .vacation.msg file, it is replaced with the 
subject of the original message when the reply is sent.

In summary, it should have a "Subject:" line, possibly along with other 
headers that you want, followed by a blank line, followed by the message body. 


```
# vi /home/dusko/.vacation.msg
```

```
# cat /home/dusko/.vacation.msg
Subject: Re: $SUBJECT
From: AliasFName AliasLName <myalias@yourdomainhere.com>

I have received your email and it will be replied to as soon as possible.

--dusko
```


```
# vi /home/dusko/.forward 
```

```
# cat /home/dusko/.forward 
\dusko, "|/usr/bin/vacation -a myalias dusko"
```


```
# vacation -j -a myalias -i dusko 
```

```
# chown dusko:mail /home/dusko/.vacation.msg
# chown dusko:mail /home/dusko/.forward
# chown dusko:mail /home/dusko/.vacation.db
```

A list of senders is kept in the file .vacation.db in your home directory.


```
# sendmail -bv myalias
"|/usr/bin/vacation -a myalias dusko"... deliverable: mailer prog, 
  user "|/usr/bin/vacation -a myalias dusko"
\dusko... deliverable: mailer local, user \dusko
```


```
# sendmail -bv myalias@yourdomainhere.com
"|/usr/bin/vacation -a myalias dusko"... deliverable: mailer prog, 
  user "|/usr/bin/vacation -a myalias dusko"
\dusko... deliverable: mailer local, user \dusko
```


```
# su - dusko
```


```
$ printf %s\\n "Testing." | mail -s "Test 1" myalias@yourdomainhere.com
$ printf %s\\n "Testing." | mail -s "Test 2" dusko@yourdomainhere.com
```


To stop vacation message, remove the ```.forward``` file and the response 
database file ```.vacation.db```.


```
rm -i ~/.forward 
rm -i ~/.vacation.db
```

