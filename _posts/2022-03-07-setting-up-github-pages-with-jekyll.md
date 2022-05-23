---
layout: post
title: "Setting Up GitHub Pages Website with Jekyll"
date: 2022-03-07 22:01:12 -0700 
categories: howto tutorial ruby git github  
---

OS: FreeBSD 13   
Shell:  csh  

Steps:
1. INSTALL Ruby and Jekyll (including rubygem-bundler)
2. CREATE or CLONE your GitHub Jekyll repository 
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


If you want to start the repository from scratch.

1. Log in to your GitHub profile   
* Your repositories 
* Select the repository: Code > Clone > Download ZIP
* Select the repository: Settings > Danger Zone > Delete this repository
  * Confirm that you want to delete this repository

2. On your local machine
* Make the new project directory 
* Navigate to the project directory 

**[TODO]** Check THIS   

* Create a new Jekyll site in the current directory    
  `jekyll new`
* Install your theme, e.g. "Just-the-Docs" theme.
The default theme for new Jekyll site is "minima".    
  `gem install just-the-docs`
* Add it to your Jekyll site's Gemfile    
  `gem "just-the-docs"`
* Add Just the Docs theme to your Jekyll site's _config.yml
  `theme: "just-the-docs"`
* Run your local Jekyll server then open your local site on 
  web browser: http://localhost:4000    
  `bundle exec jekyll serve`  

3. Make changes to your pages    
   In this step, you can try adding some pages, customization, and test 
   them locally.  When you're changing the `_config.yml` file, the update 
   will not be applied unless you restart the server and run this line again:   
   `bundle exec jekyll serve`

4. After you've completed setting up your pages and your site is running 
   okay locally, proceed to the next step.

5. Push existing project to Github  
   Create a new repository on Github.  Type a name for your repository.
   If you're creating a user site, your repository **must** be named
   `<yourusername>.github.io`.  Do not add any files because you're going
   to push the files from local.

6. On your local machine:    
   Unless you're already working in the root of your project directory, 
   navigate to the root of your project directory.  Initialize git 
   repository in the current directory (must be the root directory).    
   `git init`   

**[TODO]**   Change this:   

Edit the Gemfile that Jekyll created.   
* Add "#" to the beginning of the line that starts with gem "jekyll" to 
  comment out this line.   
* Add the github-pages gem by editing the line starting with # gem "github-pages". Change this line to:    
    `gem "github-pages", "~> GITHUB-PAGES-VERSION", group: :jekyll_plugins`   
* Replace GITHUB-PAGES-VERSION with the latest supported version of the 
  github-pages gem.  Check the version here: [Dependency versions](https://pages.github.com/versions/)  
* Save and close the Gemfile  
* If you're using Jekyll theme other than the supported themes, edit 
  your `_config.yml` file.  For example, for "Just-the-Docs" theme, 
  change this line: theme: "just-the-docs to this:    
  `remote_theme: pmarsceill/just-the-docs`     
For another theme, check the theme documentation.

---

