---
layout: post
title: "How to Run Kroki on FreeBSD 13 with vm-bhyve and Debian GNU/Linux VM"  
date: 2022-02-24 20:47:13 -0700 
categories: freebsd docker vm virtualization howto diagram 
---


```
% sudo vm list
Password:
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    512M    -    No         Stopped
```

```
% sudo vm start debianvm1
```

```
% sudo vm console debianvm1
---- snip ----

Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login: dusko
Password:
```

```
% sudo \
 systemctl \
 list-units \
 --type=service \
 --state=active \
 | grep docker
  docker-registry.service    loaded active running the Docker toolset to 
    pack, ship, store, and deliver content
  docker.service      loaded active running Docker Application Container Engine
```

```
$ ls -lh /etc/systemd/system/docker.service.d/
total 4.0K
-rw-r--r-- 1 root root 78 Feb 14 20:35 override.conf
```

```
$ cat /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
```

```
$ ss -an | grep 2376
tcp   LISTEN 0      4096      *:2376         *:*
```

```
$ ip -4 address | grep -inet | grep scope
2:  inet 127.0.0.1/8 scope host lo
5:  inet 192.168.8.19/24 brd 192.168.8.255 scope global enp0s5
7:  inet 192.168.8.18/24 brd 192.168.8.255 scope global secondary dynamic enp0s5
10: inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```

```
$ ss -an | grep 9000
```

```
$ sudo \
 docker run -d -p 9000:9000 -v \
 /var/run/docker.sock:/var/run/docker.sock -v \
 portainer_data:/data portainer/portainer
3d6162208f6ec0a79b1c1956c9958f5bcf4d1d1217572ce1e0bd5769001e1cb6
```

```
$ ss -an | grep 9000
tcp   LISTEN 0      4096      0.0.0.0:9000             0.0.0.0:*
tcp   LISTEN 0      4096         [::]:9000                [::]:*
```

To exit the console (to drop the connection), press ~ + Ctrl-D at 
the ```debianvm1 login: ``` prompt.


```
$ exit
logout

Debian GNU/Linux 11 debianvm1 ttyS0

debianvm1 login: ~
[EOT]
```


```
% ps $$
  PID TT  STAT    TIME COMMAND
24254  5  Ss   0:00.05 -csh (csh)

% printf %s\\n "$SHELL"
/bin/csh
```

```
% set DOCKER_HOST="192.168.8.19"
```

```
% printf %s\\n "$DOCKER_HOST"
192.168.8.19
```


```
% command -V docker
docker is /usr/local/bin/docker

% type docker
docker is /usr/local/bin/docker

% which docker
/usr/local/bin/docker

% whereis docker
docker: /usr/local/bin/docker
```


```
% docker -H "tcp://dusko@$DOCKER_HOST":2376 run hello-world
 
Hello from Docker!
This message shows that your installation appears to be working correctly.
 
To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash
---- snip ----
```

```
% docker -H "tcp://dusko@$DOCKER_HOST":2376 images
REPOSITORY           TAG      IMAGE ID      CREATED        SIZE
ubuntu               latest   54c9d81cbb44  4 weeks ago    72.8MB
hello-world          latest   feb5d9fea6a5  5 months ago   13.3kB
portainer/portainer  latest   580c0e4e98b0  11 months ago  79.1MB
```

```
% docker -H "tcp://dusko@$DOCKER_HOST":2376 \
 run -d --name kroki -p 8080:8000 yuzutech/kroki
```

Output:

```
Unable to find image 'yuzutech/kroki:latest' locally
latest: Pulling from yuzutech/kroki
---- snip ----

Status: Downloaded newer image for yuzutech/kroki:latest
8b79ce7a6de16fc14b6ecf60d973527b0ec6df10be3b9bc7fe3ee890825622b2
```

Confirm the availability of the new image:

```
% docker -H "tcp://dusko@$DOCKER_HOST":2376 images
REPOSITORY           TAG      IMAGE ID      CREATED        SIZE
ubuntu               latest   54c9d81cbb44  4 weeks ago    72.8MB
yuzutech/kroki       latest   e58ce143c394  2 months ago   528MB
hello-world          latest   feb5d9fea6a5  5 months ago   13.3kB
portainer/portainer  latest   580c0e4e98b0  11 months ago  79.1MB
```


```
% netstat -an | grep $DOCKER_HOST
tcp4     0    0 192.168.8.1.57607   192.168.8.19.2376   TIME_WAIT

% nc -z -v $DOCKER_HOST 8080
Connection to 192.168.8.19 8080 port [tcp/http-alt] succeeded!
```

```
% lynx --dump "$DOCKER_HOST":8080 | wc -l
    2525
```


With a Web browser open: 

```
http://192.168.8.19:8080/
```

To test, from a Web browser open:

```
http://192.168.8.19:8080/plantuml/svg/eNplj0FvwjAMhe_5FVZP40CgaNMuUGkcdttp3Kc0NS
Vq4lRxGNKm_fe1HULuuD37-bOfuXPUm2QChEjRnlIMCDmdUfHNSYY6xh42a9Fsegflk-yYlOLlcHK2I2
SGtX4WZm9sZ1o8uOzxxbuWAlIGj8cshs6M1jDuY2owyU2P8jAezdnn10j53X0hlBsZFW021Pq7HaVSNw
-KN-OogG8F8BAGqT8dXhZjxW4cyJEW6kcC-yHWFagHqW0MfaThhYmaVyE26P_x27qaDmXeruqqAMMw1h
-ZlRI4aF3dX7hOwm5XzfIKDctlNcshPT1tFa8JPYAj-Zf5F065sqM=
```

The above example obtained from ```https://kroki.io/```, 
under Examples section.

More examples available from:

```
https://kroki.io/examples.html
```


```
% command -v python

% command -v python3.8
/usr/local/bin/python3.8
```


This is an example from ```https://docs.kroki.io/kroki/setup/usage/```:

```
% vi hello.dot
```

```
% cat hello.dot
digraph G {
  Hello->World
}
```

```
% cat hello.dot | \
 python3.8 -c \
 "import sys; import base64; import zlib; \
 print(base64.urlsafe_b64encode(zlib.\
 compress(sys.stdin.read().\
 encode('utf-8'), 9)).\
 decode('ascii'))"
```

Output:

```
eNpLyUwvSizIUHBXqOZSUPBIzcnJ17ULzy_KSeGq5QIAjfEJJA==
```


Copy and paste it into the web browser. 

```
http://192.168.8.19:8080/graphviz/svg/eNpLyUwvSizIUHBXqOZSUPBIzcnJ17ULzy_KSeGq5Q
IAjfEJJA==
```

The result will be an image in SVG format.


```
% curl \
 http://192.168.8.19:8080/graphviz/svg \
 --data-raw \
 'digraph G {Hello->World}' > \
 hello.svg
```

```
% rsvg-convert hello.svg > hello.png
```

```
% xv hello.png
```

**References:**    
https://kroki.io/   
https://demo.kroki.io/   
https://kroki.io/examples.html   
https://docs.kroki.io/kroki/   
https://docs.kroki.io/kroki/setup/install/   
https://docs.kroki.io/kroki/setup/manual-install/   
https://docs.kroki.io/kroki/setup/configuration/   
https://github.com/yuzutech/kroki   
https://github.com/yuzutech/kroki/tree/main/server   
https://docs.kroki.io/kroki/setup/http-clients/   
https://docs.kroki.io/kroki/setup/kroki-cli/   
https://github.com/yuzutech/kroki/tree/main/server   
https://github.com/yuzutech/kroki/releases    

https://github.com/httpie   

