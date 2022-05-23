---
layout: post
title: "Setting Up GitHub Pages Website with Jekyll"
date: 2022-03-07 22:01:12 -0700 
categories: howto tutorial ruby git github  
---

OS: FreeBSD 13   
Shell:  csh  

Steps:
1. Install Ruby and Jekyll (including rubygem-bundler)
2. Create or Clone your GitHub Jekyll repository 
3. cd into the cloned repository
- Run your local Jekyll server:  
    ```bundle exec jekyll serve```
4. Open your local site in a Web browser:
     http://localhost:4000
5. To stop the local Jekyll server:  
     press **ctrl-c**

---

```
$ sudo pkg install ruby rubygem-jekyll rubygem-bundler
```

```
$ git clone https://github.com/duskopijetlovic/duskopijetlovic.github.io
```

```
$ cd ~/duskopijetlovic.github.io/
```

```
$ bundle exec jekyll serve
```

Open your local site in a Web browser:
     ```http://localhost:4000```

To stop the local Jekyll server:
     press **ctrl-c**

---

### Add Custom Domain in GitHub Pages

Add www.duskopijetlovic.com in the repo's Settings:    
Go to the project 'duskopijetlovic/duskopijetlovic.github.io':   
Pages > Custom domain:  www.duskopijetlovic.com    
Click 'Save'

Wait a couple of minutes for DNS check to complete.

---

### Pushing Updates to GitHub Pages

```
% cd ~/duskopijetlovic.github.io/
% git status
% git config --list
% git add .
% git commit -m "your commit messsage"
% git push
Username for 'https://github.com':
```

---

**References:**   

All references below retrieved on Mar 7, 2022.   

[Setting Up Github Pages site with Jekyll Tutorial](https://dev.to/azukacchi/setting-up-github-pages-site-with-jekyll-tutorial-1l60)   

[Setting Up Github Pages site with Jekyll Tutorial for Absolute Beginner](https://github.com/azukacchi/azukacchi.github.io)   

[Minimal tutorial on making a simple website with GitHub Pages](https://github.com/kbroman/simple_site)

[Simple site - Easy websites with GitHub Pages](https://kbroman.org/simple_site/)    

[You have already activated X, but your Gemfile requires Y](https://stackoverflow.com/questions/6317980/you-have-already-activated-x-but-your-gemfile-requires-y)    

[Jekyll-Bootstrap -- The quickest way to start and publish your Jekyll powered blog. 100% compatible with GitHub pages](https://github.com/plusjade/jekyll-bootstrap)

[Using Jekyll with Bundler](https://jekyllrb.com/tutorials/using-jekyll-with-bundler/)

[Jekyll Themes](https://jekyllrb.com/docs/themes/)

[Search for Jekyll Themes](https://rubygems.org/search?utf8=%E2%9C%93&query=jekyll-theme)

[Step by Step Tutorial](https://jekyllrb.com/docs/step-by-step/10-deployment/)

[Jekyll-Now -- Build a Jekyll blog in minutes, without touching the command line](https://github.com/barryclark/jekyll-now)   

[Markdown Style Guide - Jekyll Now](https://www.jekyllnow.com/Markdown-Style-Guide/)    

[GitHub Pages - Dependency versions](https://pages.github.com/versions/)

---

