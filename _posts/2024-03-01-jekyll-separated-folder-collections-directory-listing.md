---
layout: post
title: "How to Add and Use a Separate Directory in Jekyll or How to Loop through and Render Collections in Jekyll"
date: 2024-03-01 19:41:32 -0700 
categories: howto webdevelopment ruby programming coding  
---

a.k.a. "How to iterate through pages in directory listing in Jekyll"   
a.k.a. "How to provide directory listing in Jekyll"  
a.k.a. "How to render pages from Jekyll collections"   
a.k.a. "How to render files from Jekyll collections"   
a.k.a. "How to create subdirectories from the root directory in Jekyll"   
a.k.a. "Loop through a directory in jekyll"   


Documents (the items in a collection) live in a directory in the root of the site named _*collection_name*.
Note the underscore (```_```) in the name of the directory[^1].
In this example, the new collection will be named *notes* so the directory name for this collection will be ```_notes```.


Choose **Method 1** or **Method 2**.


## Method 1: New Directory Coupled with a Complement Directory

Q: Why do you need an additional directory; that is, why do you need one directory (in this example named ```_notes```) and the other without a preceding underscore (in this example named```notes```)?    
A: In addition to the underscored directory, you need the complement directory so that directory listing showing all pages from the the collection directory doesn't display a link to the **Index** file itself.
(Also see the NOTE under *Create Index File for New Directory* heading further below.) 


### Add a New Collection to the _config.yml Configuration File

First, backup your ```_config.yml``` configuration file.
In the root directory of your Jekyll project:

```
$ cp -i _config.yml _config.yml.ORIG
```

In ```_config.yml```, under ```collections:``` add:

```
notes:
  permalink: /notes/:path
  output: true
```

NOTE:  
In my tests, it also worked with the ```permalink``` line commented out.


To create a link to the new directory, you need to make an additional modification in the ```_config.yml``` file.
Under ```urls:``` section in the ```_config.yml``` add:

```
- text: Notes
  url: /notes/index.html
```

Comparing the ```_config.yml``` configuration file before and after the changes:

```
$ diff _config.yml.ORIG _config.yml
38a39,41
>   notes:
>     permalink: /notes/:path
>     output: true
58a62,63
>     - text: Notes
>       url: /notes/index.html
```


The ```collections:``` section now looks like this:

```
$ sed -n 35,42p _config.yml
collections:
  project:
    output: true
    permalink: /project/:path/
  notes:
    permalink: /notes/:path
    output: true

```


The ```urls:``` section is now:

```
$ sed -n 59,68p _config.yml
urls:
    - text: About
      url: /about/
    - text: Notes
      url: /notes/index.html
    - text: XML Feed
      url: /feed.xml
    - text: Categories 
      url: /category/categories

```


Image: URLs (URIs) before adding a new link to Jekyll's Navigation section

![URLs (URIs) before adding a new link to Jekyll's Navigation section](/assets/img/navigation-jekyll-urls-before.png "URLs (URIs) before adding a new link to Jekyll's Navigation section")

An image showing URLs (URIs) after adding a new link to the Navigation is displayed after *Restart Jekyll Server* heading further below.  


### Create a New Directory and Its Complement Directory

In the root directory of your Jekyll project, create a new directory with a preceding underscore (```_```).

```
$ mkdir _notes
```

In addition, create another directory with the same name but this time without using the underscore symbol (```_```).


```
$ mkdir notes
```

### Add Markdown Files in New Directory

Add your Markdown files in the directory with the underscore (```_```).
For example, create four new Markdown files here. 

Example content of the ```_notes``` directory:

```
$ ls -h _notes/*
_notes/note1.md _notes/note2.md _notes/note3.md _notes/note4.md
```

Ensure that your Markdown files in the ```_notes``` directory have YAML front matter at the top.  For example, ```note1.md``` might look like this:

```
$ cat _notes/note1.md 
---
layout: default
title: "My Note 1"
---

First note.
```

### Create Index File for New Directory

Create ```index.md``` and save it in the directory without the underscore (```_```); that is, in the ```notes``` directory.

**NOTE:**   
If you place the **Index** file in the ```_notes``` instead of in the ```notes``` directory, the listing will also include a link to the ```index.html``` file itself.
Most likely, you don't want that.

Example content of the ```index.md``` file in the ```notes``` directory:

{% raw %}

```
$ cat notes/index.md 
---
title: My Notes
layout: default
---

# My Digital Notes

<ul>
  {% for note in site.notes %}
    <li>
       <h3>
          <a href="{{ note.url | relative_url }}">
             {{ note.title }}
          </a>
       </h3>
    </li>
  {% endfor %}
</ul>
```


An alternate ```index.md``` file:

```
$ cat notes/index.md 
---
title: My Notes
layout: default
---

# My Digital Notes

<ul>
{% for note in site.notes %}
  <li><a href="{{ site.baseurl }}{{ note.url }}">{{ note.title }}</a></li>
{% endfor %}
</ul>
```

{% endraw %}


### Restart Jekyll Server

Restart the server.
Since you've made changes in the ```_config.yml``` file, you need to restart the Jekyll server to ensure that it picks up the changes.
Navigate to the root of your Jekyll project directory and run:

```
$ bundle exec jekyll serve
```


Image: URLs (URIs) after adding a new link to Jekyll's Navigation section

![URLs (URIs) after adding a new link to Jekyll's Navigation section](/assets/img/navigation-jekyll-urls-after.png "URLs (URIs) after adding a new link to Jekyll's Navigation section")

----

## Method 2: Using collection_name.html as Index File


### Add a New Collection to the _config.yml Configuration File 

Refer to *Add a New Collection to the _config.yml Configuration File* section in *Method 1* above. 


### Create a New Directory

In the root directory of your Jekyll project, create a new directory with a preceding underscore (```_```).

```
$ mkdir _notes
```

### Add Markdown Files in New Directory

Refer to *Add Markdown Files in New Directory* section in *Method 1* above. 


### Create Index File for New Directory

In the root directory of your Jekyll project, create a file named *collection_name.html*.
In this example, the collection is named ```notes``` so the Index file is named ```notes.html```. 

{% raw %}

Example content of the Index file for a collection.

```
$ cat notes.html 
---
title: Index
layout: default
---

<h2>List of Notes</h2>
 
<ul>
{% for note in site.notes %}
  <li><a href="{{ site.baseurl }}{{ note.url }}">{{ note.title }}</a></li>
{% endfor %}
</ul>
```

{% endraw %}


### Restart Jekyll Server

Refer to *Restart Jekyll Server* section in *Method 1* above. 


----

<!-- Footnotes -->
 
[^1]: In Jekyll, directory and file names that begin with an underscore (```_```) are treated as special directories and files. The special directories are: _layouts: Contains layout files that define the structure of pages on your site, _includes: Contains reusable snippets of code that can be included in your layouts and pages, _posts: Contains blog posts written in Markdown or HTML format, _data: Contains YAML or JSON files that can be used to store data for use in your site, _sass: Contains Sass files (CSS preprocessor) that can be used to style your site, _plugins: Contains custom plugins written in Ruby that extend the functionality of Jekyll. Apart from those directories, Jekyll doesn't read directories that start with an underscore (and some other special characters) **unless** the directory has been configured as a **collection**.

----

## References
(Retrieved on Mar 1, 2024)

* [Jekyll website - Docs - Getting Started - Step by Step Tutorial - 9. Collections](https://jekyllrb.com/docs/step-by-step/09-collections/)

* [Jekyll Cheatsheet](http://www.marcelofossrj.com/cheatsheet/2019/02/17/jekyll-cheatsheet.html)

* [[SOLVED] Pages from collection list are not rendered - Jekyll Talk Community - Help](https://talk.jekyllrb.com/t/solved-pages-from-collection-list-are-not-render/1059)
  - Relevant post:  
[https://talk.jekyllrb.com/t/solved-pages-from-collection-list-are-not-render/1059/4](https://talk.jekyllrb.com/t/solved-pages-from-collection-list-are-not-render/1059/4)

* [index.md - How to list all collections -- Get name of each post in each category - Jekyll Talk Community - Help](https://talk.jekyllrb.com/t/get-name-of-each-post-in-each-category/5646/4)

* [Jekyll collection with subdirectories and own index.html](https://stackoverflow.com/questions/64557906/jekyll-collection-with-subdirectories-and-own-index-html)

* [URLs and links in Jekyll - How Jekyll uses URLs and how to link posts, pages, assets, and other resources together](https://mademistakes.com/mastering-jekyll/how-to-link/)

* [Help with collections (not calling pages) - Jekyll Talk Community - Help](https://talk.jekyllrb.com/t/help-with-collections-not-calling-pages/1671)

* [Introduction to Collections in Jekyll - DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials/jekyll-collections)

* [Starter for a static website or blog - built with Jekyll, a minimal theme and GitHub Pages](https://michaelcurrin.github.io/jekyll-blog-demo/)
* [jekyll-blog-demo code on GitHub](https://github.com/MichaelCurrin/jekyll-blog-demo)

----

