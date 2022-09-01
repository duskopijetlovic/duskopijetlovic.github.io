---
layout: post
title: "How To Run diagrams.net (aka draw.io or drawio) Locally with Docker on FreeBSD 13 with vm-bhyve and Debian GNU/Linux" 
date: 2022-08-28 11:27:04 -0700 
categories: howto diagram java graph graphviz plaintext text tex latex visualization sysadmin documentation
---

Host OS: FreeBSD 13, Shell: csh    
Guest OS: Debian GNU/Linux, Shell: bash   

---

Prerequsites:   

In Debian GNU/Linux VM guest (running inside bhyve):
* Docker installed
* `docker.service` running
* `containerd.service` running

You can follow instructions outlined here:   

[How to Run Kroki on FreeBSD 13 with vm-bhyve and Debian GNU/Linux VM]({% post_url 2022-02-24-freebsd-docker-linux-kroki-diagrams %})

---

```
% sudo vm list
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    2048M   -    No         Stopped 
``` 
 
```
% sudo vm start debianvm1
```

```
% sudo vm console debianvm1
---- snip ----

debianvm1 login: dusko
Password:
```

```
$ sudo \
docker run -d -p 9000:9000 -v \
/var/run/docker.sock:/var/run/docker.sock -v \
portainer_data:/data portainer/portainer
```

```
$ ss -an | grep 9000
tcp   LISTEN 0      4096    0.0.0.0:9000             0.0.0.0:*
tcp   LISTEN 0      4096    [::]:9000                [::]:*
```

```
$ sudo \
docker \
run -it --rm --name="draw" \
-p 8080:8080 -p 8443:8443 \
jgraph/drawio
```

IP address of the guest VM (GNU/Linux Debian) is `192.168.8.18`.
The network interface name assigned by the OS is `enp0s5`, and 
when you run the following inside the guest, you get its IP address:

```
$ ip address show dev enp0s5 | grep -w inet 
    inet 192.168.8.18/24 brd 192.168.8.255 scope global dynamic enp0s5
```

Use a Web browser on the FreeBSD host and open `http://192.168.8.18:8080/` 
or `https://192.168.8.18:8443/`.   

---

**References:**    

[drawio](https://jgraph.github.io/drawio/)
(Source to app.diagrams.net, [www.diagrams.net](https://www.diagrams.net/)) 
(Retrieved on Aug 28, 2022):   
> draw.io, this project, is a configurable diagramming/whiteboarding 
> visualization application. draw.io is owned and developed by JGraph Ltd, 
> a UK based software company.
> 
> As well as running this project, we run a production-grade deployment 
> of the diagramming interface at https://app.diagrams.net.
>
> **Scope of the Project**
> 
> draw.io is a diagramming or whiteboarding application, depending on 
> which theme is selected.  It is not an SVG editing app, the SVG export 
> is designed only for embedding in web pages, not for further editing 
> in other tools.
> 
> The application is designed to be used largely as-is.  It's possible to 
> alter the major parts of the interface, but if you're looking for an 
> editor with very specific editing features, the project is likely not 
> a good base to use.
> 
> That is to say, if you wanted to create/deploy a whiteboard or 
> diagramming application where the functionality in the main canvas is 
> as this project provides, it more likely to be a good base to use. 
> The default libraries, the menus, the toolbar, the default colours, 
> the storage location, these can all be changed.
>
> **Running**
> 
> One way to run diagrams.net is to fork this project, [publish the master 
> branch to GitHub pages](https://help.github.com/categories/github-pages-basics/) and the [pages sites](https://jgraph.github.io/drawio/src/main/webapp/index.html) will have the full editor 
> functionality (sans the integrations).
> 
> Another way is to use [the recommended Docker project](https://github.com/jgraph/docker-drawio) or to download [draw.io Desktop](https://get.diagrams.net/).
> 
> The full packaged .war of the client and servlets is built when the 
> project is tagged and available on the [releases page](https://github.com/jgraph/draw.io/releases).    
