---
layout: page
title: "Add TOC (Table of Contents) in Jekyll [WIP]"
---

### Update `Gemfile`

```
$ cd /path/to/your/jekyll project
$ bundle install
$ bundle exec jekyll serve
```

Add the following line to `Gemfile`:

```
gem 'jekyll-toc'
```

### Modify `_config.yml`

If your `_config.yml` file already has `plugins:` section, add a line for `jekyll-toc` plugin to that section.

```
plugins:
  - some-other-plugin-1-here
  - some-other-plugin-2-here
  - some-other-plugin-3-here
  - jekyll-toc
```

If it doesn't have it, add the `plugins:` section, with the line for the `jekyll-toc` plugin.

```
plugins:
  - jekyll-toc
```

While you are in the `_config.yml` file, add the following *toc* section immediately after the `plugins:` section.

```
toc:
  min_level: 1
  max_level: 5
  list_class: toc
  list_class: toc__list
  sublist_class: toc__sublist
```

Save and exit the `_config.yml` file. 

With the edits above, the config file now looks similar to this:

```
$ cat _config.yml
---- snip ----

plugins:
  - jekyll-toc

toc:
  min_level: 1
# max_level: 3
  list_class: toc
  list_class: toc__list
  sublist_class: toc__sublist
```

### Run `bundle install`

To add the necessary dependencies to the project, run:

```
$ bundle install
```

### Add your CSS customization

If there is no `assets` directory in your *jekyll* project, create it with `css` sub-directory.

```
$ mkdir -p assets/css
```

In the `css` directory, create a CSS file with a name you like.

```
$ cat assets/css/tocstyle.css
.toc__list:before {
 content: "Table Of Contents";
 font-weight: bold;
 font-size: 1.5rem;
}

.toc__list {
 border: 2px solid #eee;
 border-radius: 4px;
 line-height: 1.8rem;
 padding: 1rem 1.5rem;
 font-weight: 600;
}

.toc__sublist li {
 padding-left: 1.25rem;
}

.toc-h2:first-child {
 margin-top: 1rem;
}

#toc a {
 color: #BE185D;
 text-decoration: underline;
}

#toc a:hover {
 color: #9D174D;
}
```

### Modify an HTML File in `_layouts` Directory 

Add the *liquid tag* for TOC to the place where you want the Table of Contents to appear.

{% raw %}

```
{% if page.toc %}
  {% toc %}
{% endif %}
```

{% endraw %}

Let's say there are three HTML files in the `_layouts` directory.

```
$ ls _layouts/
default.html    page.html       post.html
```

Also, for example, the `post.html` is: 

{% raw %}

```
$ cat _layouts/post.html 
---
layout: default
---

<h1>{{ page.title }}</h1>
<p style="font-size:90%;">Posted on <time datetime="{{ page.date | date_to_xmlschema }}">{{ page.date | date: "%B %-d, %Y" }}</time></p>

{{ content }}
```

{% endraw %}

After adding the section for TOC (Table of Contents), the same HTML file is: 

{% raw %}

```
$ cat _layouts/post.html
---
layout: default
---

<h1>{{ page.title }}</h1>
<p style="font-size:90%;">Posted on <time datetime="{{ page.date | date_to_xmlschema }}">{{ page.date | date: "%B %-d, %Y" }}</time></p>

{% if page.toc %}
  <b>Table of Contents:</b>
  {% toc %}
{% endif %}

{{ content }}
```

{% endraw %}

### Add `toc: true` to your Post

To tell the TOC plugin which posts you want to display a table of contents in, you need to include this line in the *front matter* of that post:

{% raw %}

```
toc: true
```

{% endraw %}

As an example, if your post file name is `2024-10-24-testing-toc.md`:

```
$ cat _posts/2024-08-25-selection.md
---
layout: post
title: "Testing TOC (Table of Contents)"
date: 2024-10-24 20:42:43 -0700
toc: true
---

---- snip ----
```

Add some content to the post, including different heading levels.  

Note: The default heading range for the `jekyll-toc` plugin  is from `<h1>` to `<h6>`.

```
$ cat _posts/2024-10-24-testing-toc.md

---- snip ----

# h1 Heading
## h2 Heading
### h3 Heading
#### h4 Heading
##### h5 Heading
###### h6 Heading
```

```
$ bundle exec jekyll serve
```

----

## References

* [How To Add A Table Of Contents To Jekyll Blog Posts](https://heymichellemac.com/table-of-contents-jekyll)

* [jekyll-toc -- Jekyll plugin which generates a table of contents](https://github.com/toshimaru/jekyll-toc)

* [Quickstart - Jekyll static site generator](https://jekyllrb.com/docs/)

* [Minimal Mistakes theme for Jekyll - Side bar and TOC](https://talk.jekyllrb.com/t/minimal-mistakes-side-bar-and-toc/3491/4)

* [no-style-please -- A (nearly) no-CSS, fast, minimalist Jekyll theme](https://github.com/riggraz/no-style-please)

* [jackal - A very lightweight & responsive theme for Jekyll](https://github.com/clenemt/jackal)

----

