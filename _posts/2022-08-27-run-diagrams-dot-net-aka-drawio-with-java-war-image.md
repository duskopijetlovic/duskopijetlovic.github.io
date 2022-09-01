---
layout: post
title: "How To Run diagrams.net (aka draw.io or drawio) Locally with a war File on FreeBSD 13" 
date: 2022-08-27 10:34:06 -0700 
categories: howto diagram java graph graphviz plaintext text tex latex visualization sysadmin documentation
---

OS: FreeBSD 13   
Shell: csh    

---

From the draw.io project's 
[Readme](https://github.com/jgraph/drawio#readme) file:


> The full packaged .war of the client and servlets is built when the 
> project is tagged and available on the [releases page](https://github.com/jgraph/draw.io/releases).  

As of Aug 27, 2022, the latest draw.io version is 20.2.6.  

```
% mkdir drawio
% cd drawio
% fetch https://github.com/jgraph/drawio/releases/download/v20.2.6/draw.war
```

```
% file draw.war
draw.war: Zip archive data, at least v1.0 to extract, compression method=store
```

```
% unzip draw.war 
---- snip ----
```


```
% pwd
/usr/home/dusko/drawio
```

```
% ifconfig
---- snip ----
ue0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500 
  options=68009b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,VLAN_HWCSUM,
  LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
---- snip ----
        inet 192.168.1.9 netmask 0xffffff00 broadcast 192.168.1.255
```

For example, to run it with python3 `http.server` module on port `8081`:

```
% python3.9 -m http.server 8081
```

Use a Web browser and open `http://localhost:8081` or
`http://127.0.0.1:8081/` or `http://192.168.1.9:8081/`.  


Alternatively, on this system I could also run it with 
python 3.8. <sup>[1](#footnotes)</sup>


```
% python3.8 -m http.server 8081
```

**Note:**   If you use python2, to use `SimpleHTTPServer` module, 
you need to run this command: 

```
% python2 -m SimpleHTTPServer 8081
```

---

## Footnotes

[1] About Python versions on this system:

```
% pkg info --regex python 
python38-3.8.13_2
python39-3.9.13
```

```
% command -v python; type python; whereis python; which python
python: not found
python:
python: Command not found.
```

```
% command -v python3.8; type python3.8; whereis python3.8; which python3.8
/usr/local/bin/python3.8
python3.8 is /usr/local/bin/python3.8
python3.8: /usr/local/bin/python3.8 /usr/local/man/man1/python3.8.1.gz
/usr/local/bin/python3.8
```

```
% command -v python3.9; type python3.9; whereis python3.9; which python3.9
/usr/local/bin/python3.9
python3.9 is /usr/local/bin/python3.9
python3.9: /usr/local/bin/python3.9 /usr/local/man/man1/python3.9.1.gz
/usr/local/bin/python3.9
```

```
% ls -lh /usr/local/bin/python*
-r-xr-xr-x  1 root  wheel   5.1K Jul  3 05:11 /usr/local/bin/python3.8
-r-xr-xr-x  1 root  wheel   3.1K Jul  3 05:11 /usr/local/bin/python3.8-config
-r-xr-xr-x  1 root  wheel   5.1K Jul  2 18:17 /usr/local/bin/python3.9
-r-xr-xr-x  1 root  wheel   3.1K Jul  2 18:18 /usr/local/bin/python3.9-config
```

---

