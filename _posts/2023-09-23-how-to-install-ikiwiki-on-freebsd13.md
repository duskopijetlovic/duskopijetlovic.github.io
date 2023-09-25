---
layout: post
title: "How to Install ikiwiki on FreeBSD 13"
date: 2023-09-23 10:04:23 +0000
categories: wiki freebsd howto webbrowser webdevelopment web tool
            markdown plaintext text tex latex pdf graph diagram writing
            technicalwriting documentation visualization staticsitegenerator
---

----

OS: FreeBSD 13.2, Shell: csh

----

```
% sudo pkg install ikiwiki
```

```
% pkg query '%Fp' ikiwiki | wc -l
     833
```

```
% pkg query '%Fp' ikiwiki | grep bin
/usr/local/bin/ikiwiki
/usr/local/bin/ikiwiki-calendar
/usr/local/bin/ikiwiki-comment
/usr/local/bin/ikiwiki-makerepo
/usr/local/bin/ikiwiki-transition
/usr/local/bin/ikiwiki-update-wikilist
/usr/local/sbin/ikiwiki-mass-rebuild
 
% pkg query '%Fp' ikiwiki | grep man
/usr/local/man/man1/ikiwiki-calendar.1.gz
/usr/local/man/man1/ikiwiki-comment.1.gz
/usr/local/man/man1/ikiwiki-makerepo.1.gz
/usr/local/man/man1/ikiwiki-transition.1.gz
/usr/local/man/man1/ikiwiki-update-wikilist.1.gz
/usr/local/man/man1/ikiwiki.1.gz
/usr/local/man/man8/ikiwiki-mass-rebuild.8.gz
 
% pkg query '%Fp' ikiwiki | grep examples | wc -l
      27
 
% pkg query '%Fp' ikiwiki | grep basewiki | wc -l
     212
 
% pkg query '%Fp' ikiwiki | grep templates | wc -l
      63
 
% pkg query '%Fp' ikiwiki | grep themes | wc -l
       9
```

```
% ikiwiki
usage: ikiwiki [options] source dest
       ikiwiki --setup my.setup [options]
```

```
% man -k ikiwiki
apropos: nothing appropriate

% sudo makewhatis

% man -k ikiwiki
ikiwiki(1) - a wiki compiler
ikiwiki-calendar(1) - create calendar archive pages
ikiwiki-comment(1) - posts a comment
ikiwiki-makerepo(1) - check an ikiwiki srcdir into revision control
ikiwiki-transition(1) - transition ikiwiki pages to new syntaxes, etc
ikiwiki-update-wikilist(1) - add or remove user from /usr/local/etc/ikiwiki/wikilist
ikiwiki-mass-rebuild(8) - rebuild all ikiwiki wikis on a system
```

```
% ls /usr/local/etc/ikiwiki/
auto-blog.setup         auto.setup              wikilist
auto-blog.setup.sample  auto.setup.sample       wikilist.sample
```

```
% diff \
 /usr/local/etc/ikiwiki/auto.setup.sample \
 /usr/local/etc/ikiwiki/auto.setup
 
% wc -l /usr/local/etc/ikiwiki/auto.setup.sample
      44 /usr/local/etc/ikiwiki/auto.setup.sample
```

```
% cat /usr/local/etc/ikiwiki/auto.setup.sample
#!/usr/local/bin/perl
# Ikiwiki setup automator.
#
# This setup file causes ikiwiki to create a wiki, check it into revision
# control, generate a setup file for the new wiki, and set everything up.
#
# Just run: ikiwiki --setup /usr/local/etc/ikiwiki/auto.setup
#
# By default, it asks a few questions, and confines itself to the user's home
# directory. You can edit it to change what it asks questions about, or to
# modify the values to use site-specific settings.

---- snip ----
```


```
% ls -alh ~/.ikiwiki
ls: /home/dusko/.ikiwiki: No such file or directory
```


```
% grep -r -n -i allow_symlinks_before_srcdir /usr/local/etc/ikiwiki/
```


To avoid error "symlink found in srcdir path (/home)" error, 
set ```allow_symlinks_before_srcdir``` to allow this.

```
% cp -i /usr/local/etc/ikiwiki/auto.setup ~/auto.setup
```

```
% vi ~/auto.setup
```

```
% diff --unified=0 /usr/local/etc/ikiwiki/auto.setup ~/auto.setup
--- /usr/local/etc/ikiwiki/auto.setup   2023-09-12 23:33:38.000000000 -0700
+++ /home/dusko/auto.setup      2023-09-24 00:20:16.367697000 -0700
@@ -43,0 +44 @@
+        allow_symlinks_before_srcdir => 1,
```

```
% ikiwiki --verbose --setup ~/auto.setup

What will the wiki be named? myikiwiki
Cannot create second readline interface, falling back to dumb.
What revision control system to use? git
Cannot create second readline interface, falling back to dumb.
Which user (wiki account, openid, or email) will be admin? dusko


Setting up myikiwiki ...
Importing /home/dusko/myikiwiki into git
---- snip ----

Initialized empty shared Git repository in /usr/home/dusko/myikiwiki.git/
---- snip ----

Directory /home/dusko/myikiwiki is now a clone of git repository /home/dusko/myikiwiki.git

refreshing wiki..
---- snip ----


Creating wiki admin dusko ...
Choose a password:
Confirm password:


generating wrappers..
rebuilding wiki..
---- snip ----

done
ikiwiki-update-wikilist: cannot write to /usr/local/etc/ikiwiki/wikilist
** Failed to add you to the system wikilist file.
** (Probably ikiwiki-update-wikilist is not SUID root.)
** Your wiki will not be automatically updated when ikiwiki is upgraded.


Successfully set up myikiwiki:
        url:         http://fbsd1.home/~dusko/myikiwiki
        srcdir:      ~/myikiwiki
        destdir:     ~/public_html/myikiwiki
        repository:  ~/myikiwiki.git
To modify settings, edit ~/myikiwiki.setup and then run:
        ikiwiki --setup ~/myikiwiki.setup
```

```
% ls -lh myikiwiki.setup
-rw-r--r--  1 dusko  dusko    14K Sep 23 10:21 myikiwiki.setup

% wc -l myikiwiki.setup
     428 myikiwiki.setup
```

```
% grep allow_symlinks_before_srcdir myikiwiki.setup
allow_symlinks_before_srcdir: 1
```

```
% ls -ld ~/public_html
drwxr-xr-x  3 dusko  dusko  3 Sep 23 10:21 /home/dusko/public_html
```

```
% ls -F ~/public_html/
myikiwiki/
```

```
% ls -fF ~/public_html/myikiwiki/
./              wikiicons/      local.css       shortcuts/      recentchanges/
../             templates/      smileys/        ikiwiki/        ikiwiki.cgi*
sandbox/        favicon.ico     index.html      style.css
```

```
% pkg search apache | wc -l
      78
```

```
% pkg search apache | grep -i web | grep -i server
apache24-2.4.57_1              Version 2.4.x of Apache web server
p5-Config-ApacheFormat-1.2_2   Parse a configuration file in the same syntax as the Apache web server
```

```
% sudo pkg install apache24
---- snip ----

Message from apache24-2.4.57_1:

--
To run apache www server from startup, add apache24_enable="yes"
in your /etc/rc.conf. Extra options can be found in startup script.
 
Your hostname must be resolvable using at least 1 mechanism in
/etc/nsswitch.conf typically DNS or /etc/hosts or apache might
have issues starting depending on the modules you are using.


- apache24 default build changed from static MPM to modular MPM
- more modules are now enabled per default in the port
- icons and error pages moved from WWWDIR to DATADIR

   If build with modular MPM and no MPM is activated in
   httpd.conf, then mpm_prefork will be activated as default
   MPM in etc/apache24/modules.d to keep compatibility with
   existing php/perl/python modules!

Please compare the existing httpd.conf with httpd.conf.sample
and merge missing modules/instructions into httpd.conf!
```

```
% hostname
fbsd1.home.arpa
```

```
% grep hostname /etc/rc.conf
hostname="fbsd1.home.arpa"
```

```
% pkg query '%Fp' apache24 | wc -l
    1649
```

```
% pkg query '%Fp' apache24 | grep -w bin
/usr/local/bin/ab
/usr/local/bin/htdbm
/usr/local/bin/htdigest
/usr/local/bin/htpasswd
/usr/local/bin/httxt2dbm
/usr/local/bin/logresolve
/usr/local/www/apache24/cgi-bin/printenv
/usr/local/www/apache24/cgi-bin/test-cgi
```

```
% pkg query '%Fp' apache24 | grep -w sbin 
/usr/local/sbin/apachectl
/usr/local/sbin/apxs
/usr/local/sbin/check_forensic
/usr/local/sbin/checkgid
/usr/local/sbin/dbmmanage
/usr/local/sbin/envvars
/usr/local/sbin/fcgistarter
/usr/local/sbin/htcacheclean
/usr/local/sbin/httpd
/usr/local/sbin/rotatelogs
/usr/local/sbin/split-logfile
```

```
% pkg query '%Fp' apache24 | grep -w conf 
/usr/local/etc/apache24/Includes/no-accf.conf
/usr/local/etc/apache24/extra/httpd-autoindex.conf.sample
/usr/local/etc/apache24/extra/httpd-dav.conf.sample
/usr/local/etc/apache24/extra/httpd-default.conf.sample
/usr/local/etc/apache24/extra/httpd-info.conf.sample
/usr/local/etc/apache24/extra/httpd-languages.conf.sample
/usr/local/etc/apache24/extra/httpd-manual.conf.sample
/usr/local/etc/apache24/extra/httpd-mpm.conf.sample
/usr/local/etc/apache24/extra/httpd-multilang-errordoc.conf.sample
/usr/local/etc/apache24/extra/httpd-ssl.conf.sample
/usr/local/etc/apache24/extra/httpd-userdir.conf.sample
/usr/local/etc/apache24/extra/httpd-vhosts.conf.sample
/usr/local/etc/apache24/extra/proxy-html.conf.sample
/usr/local/etc/apache24/httpd.conf.sample
```

```
% pkg query '%Fp' apache24 | grep libexec | wc -l
     113
 
% pkg query '%Fp' apache24 | grep '\.so' | wc -l
     112
 
% pkg query '%Fp' apache24 | grep libexec | grep -v '\.so'
/usr/local/libexec/apache24/httpd.exp
```

```
% pkg query '%Fp' apache24 | grep libexec 
/usr/local/libexec/apache24/httpd.exp
/usr/local/libexec/apache24/mod_access_compat.so
/usr/local/libexec/apache24/mod_actions.so
---- snip ----
```

```
% pkg query '%Fp' apache24 | grep libexec | grep cgi | wc -l
       5
 
% pkg query '%Fp' apache24 | grep libexec | grep cgi
/usr/local/libexec/apache24/mod_authnz_fcgi.so
/usr/local/libexec/apache24/mod_cgi.so
/usr/local/libexec/apache24/mod_cgid.so
/usr/local/libexec/apache24/mod_proxy_fcgi.so
/usr/local/libexec/apache24/mod_proxy_scgi.so
```


```
% pkg query '%Fp' apache24 | grep -w man | wc -l
      16
 
% pkg query '%Fp' apache24 | grep -w man | grep -v '\-man' | wc -l
      13
 
% pkg query '%Fp' apache24 | grep -w man | grep -v '\-man' 
/usr/local/man/man1/ab.1.gz
/usr/local/man/man1/apxs.1.gz
/usr/local/man/man1/dbmmanage.1.gz
/usr/local/man/man1/htdbm.1.gz
/usr/local/man/man1/htdigest.1.gz
/usr/local/man/man1/htpasswd.1.gz
/usr/local/man/man1/httxt2dbm.1.gz
/usr/local/man/man1/logresolve.1.gz
/usr/local/man/man8/apachectl.8.gz
/usr/local/man/man8/fcgistarter.8.gz
/usr/local/man/man8/htcacheclean.8.gz
/usr/local/man/man8/httpd.8.gz
/usr/local/man/man8/rotatelogs.8.gz
```

```
% pkg query '%Fp' apache24 | grep -w doc | wc -l
    1147
 
% pkg query '%Fp' apache24 | grep -w doc | head -4
/usr/local/share/doc/apache24/BUILDING
/usr/local/share/doc/apache24/LICENSE
/usr/local/share/doc/apache24/NOTICE
/usr/local/share/doc/apache24/bind.html

% pkg query '%Fp' apache24 | grep -w doc | tail -4
/usr/local/share/doc/apache24/vhosts/name-based.html.ko.euc-kr
/usr/local/share/doc/apache24/vhosts/name-based.html.tr.utf8
/usr/local/www/apache24/icons/small/doc.gif
/usr/local/www/apache24/icons/small/doc.png
```

```
% pkg query '%Fp' apache24 | grep -w www | wc -l
     264

% pkg query '%Fp' apache24 | grep -w www 
/usr/local/www/apache24/cgi-bin/printenv
/usr/local/www/apache24/cgi-bin/test-cgi
/usr/local/www/apache24/error/HTTP_BAD_GATEWAY.html.var
/usr/local/www/apache24/error/HTTP_BAD_REQUEST.html.var
---- snip ----
/usr/local/www/apache24/error/README
/usr/local/www/apache24/error/contact.html.var
/usr/local/www/apache24/error/include/bottom.html
/usr/local/www/apache24/error/include/spacer.html
/usr/local/www/apache24/error/include/top.html
/usr/local/www/apache24/icons/README
/usr/local/www/apache24/icons/README.html
/usr/local/www/apache24/icons/a.gif

% pkg query '%Fp' apache24 | grep -w www | tail -4
/usr/local/www/apache24/icons/world1.png
/usr/local/www/apache24/icons/world2.gif
/usr/local/www/apache24/icons/world2.png
/usr/local/www/apache24/icons/xml.png
```

```
% service apache24 status
Cannot 'status' apache24. Set apache24_enable to YES in /etc/rc.conf or use 'one
status' instead of 'status'.
```

```
% service apache24 onestatus
apache24 is not running.
```

```
% sudo service apache24 onestart
Performing sanity check on apache24 configuration:
AH00557: httpd: apr_sockaddr_info_get() failed for fbsd1.home.arpa
AH00558: httpd: Could not reliably determine the server's fully qualified domain
 name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this
 message
Syntax OK
Starting apache24.
AH00557: httpd: apr_sockaddr_info_get() failed for fbsd1.home.arpa
AH00558: httpd: Could not reliably determine the server's fully qualified domain
 name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this
 message
```

```
% sudo service apache24 onestop
```

```
% service apache24 onestatus
apache24 is not running.
```

```
% ls -fF /usr/local/etc/apache24/
./                      httpd.conf              magic.sample
../                     httpd.conf.ORIG         mime.types
magic                   extra/                  httpd.conf.sample
modules.d/              mime.types.sample
Includes/               envvars.d/
```

```
% diff \
 /usr/local/etc/apache24/httpd.conf.sample \
 /usr/local/etc/apache24/httpd.conf
```

```
% sudo cp -i \
 /usr/local/etc/apache24/httpd.conf \
 /usr/local/etc/apache24/httpd.conf.ORIG
```

```
% sudo vi /usr/local/etc/apache24/httpd.conf
```

```
% diff \
 --unified=0 \
 /usr/local/etc/apache24/httpd.conf.ORIG \
 /usr/local/etc/apache24/httpd.conf
--- /usr/local/etc/apache24/httpd.conf.ORIG     2023-09-23 10:31:23.936523000 -0700
+++ /usr/local/etc/apache24/httpd.conf  2023-09-23 10:36:44.163782000 -0700
@@ -166 +166 @@
-       #LoadModule cgid_module libexec/apache24/mod_cgid.so
+       LoadModule cgid_module libexec/apache24/mod_cgid.so
@@ -169 +169 @@
-       #LoadModule cgi_module libexec/apache24/mod_cgi.so
+       LoadModule cgi_module libexec/apache24/mod_cgi.so
@@ -179 +179 @@
-#LoadModule userdir_module libexec/apache24/mod_userdir.so
+LoadModule userdir_module libexec/apache24/mod_userdir.so
@@ -226,0 +227 @@
+ServerName fbsd1.home.arpa:80
@@ -376 +377 @@
-    #Scriptsock cgisock
+    Scriptsock cgisock
@@ -431 +432 @@
-    #AddHandler cgi-script .cgi
+    AddHandler cgi-script .cgi .pl
@@ -503 +504 @@
-#Include etc/apache24/extra/httpd-userdir.conf
+Include etc/apache24/extra/httpd-userdir.conf
```

```
% sudo cp -i \
 /usr/local/etc/apache24/extra/httpd-userdir.conf \
 /usr/local/etc/apache24/extra/httpd-userdir.conf.ORIG
```

```
% sudo vi /usr/local/etc/apache24/extra/httpd-userdir.conf
```

```
% diff \
 --unified=0 \
 /usr/local/etc/apache24/extra/httpd-userdir.conf.ORIG \
 /usr/local/etc/apache24/extra/httpd-userdir.conf
--- /usr/local/etc/apache24/extra/httpd-userdir.conf.ORIG       2023-09-23 10:38:15.502167000 -0700
+++ /usr/local/etc/apache24/extra/httpd-userdir.conf    2023-09-23 10:40:41.981299000 -0700
@@ -23,0 +24,8 @@
+
+<Directory "/home/dusko/public_html">
+    AllowOverride None
+    Options +ExecCGI
+    AddHandler cgi-script .cgi .pl
+    Require all granted
+</Directory>
```

```
% grep Required /usr/local/etc/apache24/extra/httpd-userdir.conf
# Required module: mod_authz_core, mod_authz_host, mod_userdir
```


Display a list of loaded static and shared modules.

```
% apachectl -M | wc -l
      28

Loaded Modules:
 core_module (static)
---- snip ----
```

```
% apachectl -M | grep authz_core
 authz_core_module (shared)
 
% apachectl -M | grep authz_host
 authz_host_module (shared)
 
% apachectl -M | grep userdir
 userdir_module (shared)
```

```
% apachectl -M | grep -i cgi
 cgi_module (shared)
```

```
% service apache24 onestatus
apache24 is not running.
```

```
% sudo service apache24 onestart
Performing sanity check on apache24 configuration:
Syntax OK
Starting apache24.
```

```
% service apache24 onestatus
apache24 is running as pid 46570.
```

With your Web browser:

```
http://localhost/~dusko/myikiwiki/
```


![Displaying an ikiwiki instance home page running with apache web server on local machine](/assets/img/myikiwiki.jpg "Displaying an ikiwiki instance home page running with apache web server on local machine")


## References

[ikiwiki](https://ikiwiki.info/)
> Ikiwiki is a wiki compiler.  It converts wiki pages into HTML pages
suitable for publishing on a website.  Ikiwiki stores pages and history
in a revision control system such as Subversion or Git.  There are many
other features, including support for blogging and podcasting, as well
as a large array of plugins.
>    
> Alternatively, think of ikiwiki as a particularly flexible static site
generator with some dynamic features.

---
