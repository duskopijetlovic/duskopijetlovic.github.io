---
layout: page
title: "Jekyll Markdown Internal Links"
---

aka *Link to a heading on the same page* or *Link to sections on a page* or *Link to headings within the same document*.

----

In Jekyll, if you want to include a link to a heading on the same page, you can use this method:

```
. . . refer to section [On a Workstation or On a Server](#on-a-workstation-or-on-a-server) . . .  
```

**Explanation:**

Each heading gets an `id` reference based on the heading text.
For example, if in your markdown (`.md`) document you have a heading 

```
### On a Workstation or On a Server
```

when Jekyll converts the page into HTML, that heading becomes: [<sup>[1](#footnotes)</sup>]

```
<h3 id="on-a-workstation-or-on-a-server">On a Workstation or On a Server</h3>
```


So to link to it from within the same document: 


```
Refer to section [On a Workstation or On a Server](#on-a-workstation-or-on-a-server) 
```

If you prefer, you can assign it an explicit id:

```
### On a Workstation or On a Server]
{: #workstationorserver }
```

and link to it:

```
Refer to section [On a Workstation or On a Server](#workstationorserver) 
```

----

## References

[jekyll markdown internal links](https://stackoverflow.com/questions/4629675/jekyll-markdown-internal-links)

----

## Footnotes

[1] For example, inside my Jekyll project, if one of my Markdown files (in `_posts` directory) is named *2024-05-01-tls-ssl-testing.md*, go to root of your Jekyll project and search for the converted HTML file.
It will be in `_sites` directory:

```
$ find . -name '*.html' | grep testing | grep tls
./_site/2024/05/01/tls-ssl-testing/index.html
```

```
$ grep "On a Workstation or On a Server" ./_site/2024/05/01/tls-ssl-testing/index.html
<h3 id="on-a-workstation-or-on-a-server">On a Workstation or On a Server</h3>
```

----

