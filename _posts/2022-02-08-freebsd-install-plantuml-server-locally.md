---
layout: post
title: "How To Install PlantUML and PlantUML Server Locally on FreeBSD" 
date: 2022-02-08 21:17:48 -0700
categories: freebsd graphviz graph visualization diagram 
---

Operating system:  FreeBSD 13.0

**Note:**
In code excerpts and examples, the long lines are folded and then
indented to make sure they fit the page.

https://plantuml.com/  

https://github.com/plantuml/   


### Run PlantUML Locally 

[*plantuml*](https://github.com/plantuml/plantuml)    
Generate diagrams from textual description

Requirements for running PlantUML locally:
- Java
- Graphviz

As of Feb 8, 2022, the latest version of PlantUML is 1.2022.1.   

PlantUML compiled Jar (Version 1.2022.1)

From [GitHub releases](https://github.com/plantuml/plantuml/releases/tag/v1.2022.1), you can download [plantuml.1.2022.1.jar](https://github.com/plantuml/plantuml/releases/download/v1.2022.1/plantuml-1.2022.1.jar). It includes GraphViz.   

```
$ fetch \
 https://github.com/plantuml/plantuml/releases/download/v1.2022.1/plantuml-1.2022.1.jar
```


Create a text file with PlantUML commands.

```
% cat sequenceDiagram.txt
@startuml
Alice -> Bob: test
@enduml
```

```
% java -jar plantuml-1.2022.1.jar sequenceDiagram.txt
```

This outputs the sequence diagram to a file called sequenceDiagram.png. 


```
% file sequenceDiagram.png
sequenceDiagram.png: PNG image data, 123 x 131, 8-bit/color RGB, non-interlaced
```

```
% xv sequenceDiagram.png
```


References:    
https://plantuml.com/starting
Local Installation notes [https://plantuml.com/en/faq-install](https://plantuml.com/en/faq-install)


### PlantUML PicoWeb Server

You can install PlantUML server and run it locally but you first need 
to install your own JEE web application server. 

If you don't want to install a full JEE application server, you may also 
choose to run PlantUML PicoWeb Server locally, as PlantUML developers 
have decided to integrate a tiny webserver inside ```plantuml.jar```. 

You just have to launch it with ```-picoweb``` option:

```
% java -jar plantuml-1.2022.1.jar -picoweb
webPort=8080
```

The server is now listening to http://localhost:8080.

Then; for example, for SVG service, in a Web browser, enter: 

http://localhost:8080/plantuml/svg/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000

or for TXT service, in a Web browser enter:

http://localhost:8080/plantuml/txt/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000


Reference:   
https://plantuml.com/en/picoweb


### Install and Run PlantUML Server Locally 

Requirements for PlantUML Server:  
- Maven (Apache Maven)   
- Jetty (Jetty web server)   


Install Maven.

```
% sudo pkg install maven
```

```
---- snip ----

New packages to be INSTALLED:
        java-zoneinfo: 2021.e
        maven: 3.8.4
        maven-wrapper: 1_2
        openjdk8: 8.312.07.1

Number of packages to be installed: 4

---- snip ---- 

=====
Message from openjdk8-8.312.07.1:

--
This OpenJDK implementation requires fdescfs(5) mounted on /dev/fd and
procfs(5) mounted on /proc.

If you have not done it yet, please do the following:

        mount -t fdescfs fdesc /dev/fd
        mount -t procfs proc /proc

To make it permanent, you need the following lines in /etc/fstab:

        fdesc   /dev/fd         fdescfs         rw      0       0
        proc    /proc           procfs          rw      0       0
---- snip ----
```


[TODO] cat /etc/fstab for java


Install jetty.

```
% sudo pkg install jetty9
```


```
---- snip ----
New packages to be INSTALLED:
        bash: 5.1.12
        jetty9: 9.4.29
---- snip ----

=====
Message from jetty9-9.4.29:

--
Jetty is now installed in /usr/local/jetty

From Jetty 9, the way to configure it has changed. You are **strongly**
advised to read the documentation found here:

http://www.eclipse.org/jetty/documentation/current/

Please pay particular attention to HOME and BASE documentation, i.e.,:

http://www.eclipse.org/jetty/documentation/current/startup-base-and-home.html

You may want to activate it in /etc/rc.conf:

    # echo jetty_enable="YES" >> /etc/rc.conf

A sample configuration file can be found here:

    /usr/local/etc/jetty/jetty.sample

Please modify it to suit your needs, paying particular attention
to the value of JETTY_HOME and JETTY_BASE.

Once you are happy with the configuration file, you can start Jetty:

    # service jetty start

Once Jetty is started, point your web browser to the default home page at
http://localhost:8080/.

A demo web app is installed for your convenience.

== ADVANCED USAGE ==

If you need to pass special options to Java/Jetty, please set the appropriate
variables in the configuration file, e.g.,

  # Increase memory limit of the Java virtual machine

  JAVA_OPTIONS="-Xms32m -Xmx256m"

  # Run Java with remote debugging turned on on port 8186

  JAVA_OPTIONS="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8186"

More configuration options are presented in the sample file.
```

TODO2 --- possibly here 


**NOTE:**   
For PlantUML Server, dont' start ```jetty``` service yet.  
It will be started with ```mvn jetty:run``` (see below steps).   


```
% mkdir ~/scratch
% cd ~/scratch
```

Download the latest version of PlantUML Server.

```
% fetch \
 https://codeload.github.com/plantuml/plantuml-server/zip/refs/heads/master
```

```
% ls -lh master
-rw-r--r--  1 dusko  dusko   139K Feb  8 23:49 master

% file master
master: Zip archive data, at least v1.0 to extract

% mv master plantuml-server.zip

% unzip plantuml-server.zip
```


```
% ls -ld plantuml-server*
drwxr-xr-x  7 dusko  dusko      18 Feb  8 23:50 plantuml-server-master
-rw-r--r--  1 dusko  dusko  142662 Feb  8 23:49 plantuml-server.zip

% mv plantuml-server-master plantuml-server

% ls -ld plantuml-server*
drwxr-xr-x  7 dusko  dusko      18 Feb  8 23:50 plantuml-server
-rw-r--r--  1 dusko  dusko  142662 Feb  8 23:49 plantuml-server.zip
```

```
% cd ~/scratch/plantuml-server
```

```
% pwd
/usr/home/dusko/scratch/plantuml-server
```

```
% mvn jetty:run
```

Then, in a Web browser, open:   
http://localhost:8080/plantuml  

To run it again:   

```
% cd ~/scratch/plantuml-server
% mvn jetty:run
```


References:    

PlantUML References:    
[PlantUML Server](https://plantuml.com/en/server)   
[PlantUML Server source code](https://github.com/plantuml/plantuml-server)    
[PlantUML Examples](https://github.com/mattjhayes/PlantUML-Examples/blob/master/docs/Diagram-Types/diagram-types.md)   
[PlantUML for the impatient](https://plantuml.com/starting)  
[Activity Diagram (legacy)](https://plantuml.com/activity-diagram-legacy)   
[Activity Diagram (new syntax)](https://plantuml.com/activity-diagram-beta)   
[PlantUML - Command line](https://plantuml.com/command-line)  
[PlantUML - Common commands: comment, zoom, title, footer and header, legend](https://plantuml.com/commons)  

[Drawing diagrams with PlantUML](https://www.linux-magazine.com/Issues/2020/235/PlantUML-Diagrams)   
(Linux Magazine Issue #235 - Jun 2020)  
(Retrieved on Feb 8, 2022)  

[Open Iconic, a free and open icon set](https://useiconic.com/open)  
(An open source icon set with 223 marks in SVG, webfont and raster formats)   
(Retrieved on Feb 8, 2022)  

[Other Uses for PlantUML](https://mattjhayes.com/2021/11/28/other-uses-for-plantuml/)   
(Retrieved on Feb 8, 2022)  

[Hyperlinks and tooltips](http://plantuml.com/link)    
[Creole](http://plantuml.com/creole): rich text, emoticons, unicode, icons  
[OpenIconic icons](http://plantuml.com/openiconic)  
[Sprite icons](http://plantuml.com/sprite)  
[AsciiMath mathematical expressions](http://plantuml.com/ascii-math)   

