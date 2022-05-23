---
layout: post
title: "How to Run Kroki on FreeBSD 13 with Java"  
date: 2022-02-25 22:15:24 -0700 
categories: freebsd howto diagram java
---


As per [Kroki server readme](https://github.com/yuzutech/kroki/tree/main/server), 
under [Manual install](https://github.com/yuzutech/kroki/tree/main/server#manual-install), 
install the following dependencies:

```
$ sudo pkg install openjdk8 graphviz erd svgbob
```

As per [Install Kroki](https://docs.kroki.io/kroki/setup/install/):  

> Manual installation
> 
> You can also make a customized manual installation that suits your needs.
> 
> To do this, you will need to manually install the Kroki gateway server 
> as a standalone executable jar, install each diagram library that you 
> want to use, then run the gateway server jar file.
> 
> You are responsible for managing diagram library installations on your system.
> 
> Find how to make a manual installation on the [Manual installation](https://docs.kroki.io/kroki/setup/manual-install/) page.

```
$ mkdir -p ~/scratch/kroki-server
$ cd ~/scratch/kroki-server
```

```
$ pwd
/usr/home/dusko/scratch/kroki-server
```

You can download the latest standalone executable jar from the GitHub [releases page](https://github.com/yuzutech/kroki/releases). 


At the time of writing, [the latest version of Kroki is 0.16.0.](https://github.com/yuzutech/kroki/releases)    
(Retrieved on Feb 25, 2022)   



```
$ fetch \
 https://github.com/yuzutech/kroki/releases/download/v0.16.0/kroki-server-v0.16.0.jar
```

```
$ file kroki-server-v0.16.0.jar
kroki-server-v0.16.0.jar: Java archive data (JAR)
```

Start a web server:

```
$ java -jar kroki-server-v0.16.0.jar
```

The above command starts the web server on port 8000. 
You can change the port using an environment variable, or a Java system property named KROKI_PORT.


With a Web browser, open ```http://localhost:8000/```.

---


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

---

