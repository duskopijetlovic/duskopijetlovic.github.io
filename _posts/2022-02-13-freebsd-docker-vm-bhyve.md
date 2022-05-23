---
layout: post
title: "How to Run Docker on FreeBSD 13 with vm-bhyve and Debian GNU/Linux VM"
date: 2022-02-13 08:22:41 -0700 
categories: freebsd bhyve docker virtualization
---

### Jails vs Docker

This post doesn't discuss jails vs Docker.  In general, if you need to 
segregate a set of processes with containers, you would use jails. 
If your requirements ask for Docker, continue reading.   


Host OS: FreeBSD 13.0 

```
$ sudo vm list
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    2048M   -    No         Stopped
```

```
$ sudo vm start debianvm1
```


```
$ sudo vm list
NAME       DATASTORE  LOADER  CPU  MEMORY  VNC  AUTOSTART  STATE
debianvm1  default    grub    1    512M    -    No         Running (29103)
```

```
$ sudo vm console debianvm1
Connected

debianvm1 login: dusko
Password:
```


```
$ sudo apt-get remove docker
$ sudo apt-get remove docker-engine
$ sudo apt-get remove docker.io
$ sudo apt-get remove containerd
$ sudo apt-get remove runc
```

```
$ sudo \
 apt-get install \
 ca-certificates \
 curl \
 gnupg \
 lsb-release
```

```
$ curl -fsSL https://download.docker.com/linux/debian/gpg \
 | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```
$ echo \
 "deb [arch=$(dpkg --print-architecture) \
 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
 https://download.docker.com/linux/debian \
 $(lsb_release -cs) stable" \
 | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
$ sudo apt-get update
```

```
$ sudo \
 apt-get install \
 docker-ce docker-ce-cli containerd.io
```

```
$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete
Digest: sha256:97a379f4f88575512824f3b352bc03cd75e239179eea0fecc38e597b2209f49a
Status: Downloaded newer image for hello-world:latest

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

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

```
$ sudo docker volume create portainer_data
```

```
$ sudo systemctl status docker.service
* docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset:enabled)
---- snip ----
   Main PID: 2512 (dockerd)
---- snip ----
```

```
$ sudo systemctl status containerd.service
* containerd.service - containerd container runtime
     Loaded: loaded (/lib/systemd/system/containerd.service; enabled; vendor preset: enabled)
---- snip ----
   Main PID: 2355 (containerd)
---- snip ----
```

```
$ ls -lh /etc/systemd/system/docker.service.d
ls: cannot access '/etc/systemd/system/docker.service.d': No such file or directory
```

```
$ sudo mkdir /etc/systemd/system/docker.service.d
```

```
$ sudo systemctl edit docker.service
```


This opens GNU nano text editor. 
Add the following three lines, save and exit.


```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
```

Confirm that the file override.conf has been created.

```
$ cat /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
```

```
$ sudo systemctl daemon-reload
```


```
$ sudo systemctl restart docker.service
$ sudo systemctl restart containerd
```


```
$ ss -an | grep 2376
tcp   LISTEN 0      4096         *:2376                   *
```

```
$ sudo ls -lh /var/lib/docker
total 44K
drwx--x--x  4 root root 4.0K Feb 13 20:16 buildkit
drwx--x---  4 root root 4.0K Feb 13 20:23 containers
drwx------  3 root root 4.0K Feb 13 20:16 image
drwxr-x---  3 root root 4.0K Feb 13 20:16 network
drwx--x--- 11 root root 4.0K Feb 13 20:39 overlay2
drwx------  4 root root 4.0K Feb 13 20:16 plugins
drwx------  2 root root 4.0K Feb 13 20:39 runtimes
drwx------  2 root root 4.0K Feb 13 20:16 swarm
drwx------  2 root root 4.0K Feb 13 20:39 tmp
drwx------  2 root root 4.0K Feb 13 20:16 trust
drwx-----x  3 root root 4.0K Feb 13 20:39 volumes
```

```
$ sudo \
 docker run -d -p 9000:9000 -v \
 /var/run/docker.sock:/var/run/docker.sock -v \
 portainer_data:/data portainer/portainer
```


```
$ ss -an | grep 9000
tcp   LISTEN 0      4096     0.0.0.0:9000         0.0.0.0:*
tcp   LISTEN 0      4096        [::]:9000            [::]:*
```

```
$ nc -n -z -v <guest_ip_address> 9000
(UNKNOWN) [guest_ip_address] 2376 (?) open 9000 (?) open
```


For example, if your guest VM's IP address is ```203.0.113.1```:

```
$ nc -n -z -v 203.0.113.1 9000
(UNKNOWN) [203.0.113.1] 9000 (?) open
```

```
$ nc -z -v 127.0.0.1 9000 
localhost [127.0.0.1] 9000 (?) open

$ nc -z -v localhost 9000 
localhost [127.0.0.1] 9000 (?) open
```

On the FreeBSD host, start a Web browser, navigate to port 9000 on the IP address of your guest VM.
For example, if your guest's IP address is ```203.0.113.1```, open:


```
http://203.0.113.1:9000/
```

That page is Portainer's login page. Since it's your first time using it, 
it will asks you to create admin user.


NOTE:  
If you want to use Portainer, you have to start the Portainer Server 
container again after every docker service restart (sudo systemctl restart docker):

```
$ sudo \
 docker run -d -p 9000:9000 -v \
 /var/run/docker.sock:/var/run/docker.sock -v \
 portainer_data:/data portainer/portainer
```


**CAUTION !!:**   
Exposing the docker socket (docker.sock) is a security risk. Giving an 
application access to it is equivalent to giving a unrestricted root 
access to your host. For more information see 
[OWASP: Do not expose the Docker daemon socket](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-1---do-not-expose-the-docker-daemon-socket-even-to-the-containers)


Logout from the guest VM.

```
$ exit
```

In the FreeBSD guest. 

```
$ sudo pkg install docker docker-compose
```

```
$ printf %s\\n "$DOCKER_HOST"
DOCKER_HOST: Undefined variable.
```

```
$ nc -z -v 203.0.113.1 2376
Connection to 203.0.113.1 2376 port [tcp/*] succeeded!
```

The shell is ```csh```. 

```
$ ps $$
  PID TT  STAT    TIME COMMAND
30033  7  Ss   0:00.02 -csh (csh)
```

```
$ set DOCKER_HOST="203.0.113.1:2376"
```

```
$ printf %s\\n "$DOCKER_HOST"
203.0.113.1:2376
```

```
$ docker -H "tcp://dusko@$DOCKER_HOST":2376 run hello-world
 
Hello from Docker!
This message shows that your installation appears to be working correctly.
---- snip ----
```


To show ```docker run``` usage:

```
$ docker -H tcp://dusko@203.0.113.1:2376 run --help

Usage:  docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

Run a command in a new container
---- snip ----
```

Docker run command to start an interactive bash shell session in an Ubuntu Docker image:

```
$ docker -H "tcp://dusko@$DOCKER_HOST":2376 run -it ubuntu bash

Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
08c01a0ec47e: Pull complete
Digest: sha256:669e010b58baf5beb2836b253c1fd5768333f0d1dbcb834f7c07a4dc93f474be
Status: Downloaded newer image for ubuntu:latest
root@9407014e2a92:/#
root@9407014e2a92:/#
```

```
root@9407014e2a92:/# hostname
9407014e2a92

root@9407014e2a92:/# uname -a
Linux 9407014e2a92 5.10.0-11-amd64 #1 SMP Debian 5.10.92-1 (2022-01-18) 
  x86_64 x86_64 x86_64 GNU/Linux
```

Logout from the bash shel.

```
root@9407014e2a92:/# exit
```

In the FreeBSD host, to show list of Docker images available: 

```
$ docker -H tcp://dusko@203.0.113.1:2376 images
REPOSITORY            TAG       IMAGE ID       CREATED        SIZE
ubuntu                latest    54c9d81cbb44   13 days ago    72.8MB
hello-world           latest    feb5d9fea6a5   4 months ago   13.3kB
portainer/portainer   latest    580c0e4e98b0   11 months ago  79.1MB
```

References:   

[How to run Docker on FreeBSD 12](https://www.gamsjager.nl/2019/01/11/How-to-run-Docker-on-FreeBSD-12/)   
[Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/debian/)    
[Docker Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)   
[How do I enable the remote API for dockerd](https://web.archive.org/web/20180615163619/https://success.docker.com/article/how-do-i-enable-the-remote-api-for-dockerd)    

