---
layout: post
title: "Testing Different Jekyll Themes" 
date: 2024-09-24 20:50:39 -0700 
categories: howto webbrowser networking sysadmin unix webdevelopment http html
            ruby tutorial
---

OS: FreeBSD 14   
Shell: tcsh   

---

## Requirements

* Ruby [<sup>[1](#footnotes)</sup>]
* RubyGems [<sup>[2](#footnotes)</sup>] 
* Bundler [<sup>[3](#footnotes)</sup>]
* Jekyll [<sup>[4](#footnotes)</sup>]

Install Ruby and RubyGems (also called *gems*) on your system by using your package manager. 

For example, to install Ruby and gems (RubyGems) on FreeBSD (as of time of this writing, Ruby version available for FreeBSD 14 was 3.2):

```
$ sudo pkg install ruby ruby32-gems
```

To install Bundler and Jekyll, you can use either your package manager or you can install them as Ruby gems.

For example, to install Bundler and Jekyll on FreeBSD with its package manager: 

```
$ sudo pkg install rubygem-jekyll rubygem-bundler
```

Alternatively, if you want to install Bundler and Jekyll as Ruby gems:

```
$ gem install bundler jekyll
```

---

## Set Gems Directory and Add It to the Shell Path 

Avoid installing RubyGems packages (called gems) as the root user.  Instead, set up a gem installation directory for your user account.  I use the standard FreeBSD shell *csh* so I need to add environment variables to `~/.cshrc` file to configure the gem installation path. [<sup>[5](#footnotes)</sup>]

---

## Jekyll Quick Start

```
% jekyll new my-awesome-site
% cd my-awesome-site
% bundle install
% bundle exec jekyll serve

# => Now browse to http://localhost:4000
```


NOTE: On FreeBSD 14, I encountered *NotImplementedError* when running `bundle install`: 

```
NotImplementedError: dart-sass for x86_64-freebsd14 not available at [. . .] 
```

To fix it, you need to hard-set the `jekyll-sass-converter` version in your `Gemfile`. [<sup>[6](#footnotes)</sup>]

Now that you have Jekyll running you can start testing different themes for it.  [<sup>[7](#footnotes)</sup>], [<sup>[8](#footnotes)</sup>]

---

## Example: whiteglass Theme

```
% git clone https://github.com/yous/whiteglass-template.git
```

```
% cd whiteglass-template
% bundle install
% bundle exec jekyll serve
```

Browse to *http://localhost:4000*.

If you encounter *NotImplementedError* when running `bundle install` (NotImplementedError: dart-sass for x86_64-freebsd14), fix it by hard-setting the `jekyll-sass-converter` version in your `Gemfile`. [<sup>[6](#footnotes)</sup>]

NOTE: On FreeBSD 14, I encountered `ERROR '/' not found` and/or `ERROR '/index.html'` when running `bundle exec jekyll serve`.  Fix it by setting the value of the `baseurl` to an empty string - `baseurl: ""` in your `_config.yml` file. [<sup>[9](#footnotes)</sup>]

Copy your Markdown files (`*.md`) to the `_posts` directory. 

## Example: lightspeed Theme

```
% git clone https://git.btxx.org/lightspeed
```

```
% cd lightspeed
% bundle install
% bundle exec jekyll serve
```

Copy your Markdown files (`*.md`) to the `_posts` directory.

Browse to *http://localhost:4000*.

---

## Footnotes

[1] Ruby is an object-oriented interpreted scripting language.
Ruby Programming Language - home page: [https://www.ruby-lang.org/en/](https://www.ruby-lang.org/en/)
>  A dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write. 

Install Ruby on your system by using your package manager.  For example, in FreeBSD `sudo pkg install ruby`

[2] Package management framework for the Ruby language.
An application or library is packaged into a **gem**, which is a single installation unit.  *RubyGems* entirely manages its own filesystem space, rather than installing files into the "usual" places.  This enables greater functionality and reliability.
RubyGems source code at GitHub: [RubyGems - Library packaging and distribution for Ruby](https://github.com/rubygems/rubygems)
> RubyGems is a package management framework for Ruby.
>
> A package (also known as a library) contains a set of functionality that can be invoked by a Ruby program, such as reading and parsing an XML file.  We call these packages "gems" and RubyGems is a tool to install, create, manage and load these packages in your Ruby environment.
> 
> RubyGems is also a client for [RubyGems.org](https://rubygems.org/), a public *repository* of Gems that allows you to publish a Gem that can be shared and used by other developers.  See our guide on publishing a Gem at [guides.rubygems.org](https://guides.rubygems.org/publishing/).

Install RubyGems on your system by using your package manager.  For example, in FreeBSD `sudo pkg install ruby<Version>-gems` so for Ruby version 3.2: `sudo pkg install ruby ruby32-gems`

[3] Bundler is a tool that manages gem dependencies for your Ruby applications.
Bundler home page: [Bundler: The best way to manage a Ruby application's gems](https://bundler.io/)

[4] From [Jekyll](http://jekyllrb.com/) home page:
> Jekyll - Simple, blog-aware, static site generator - Transform your plain text into static websites and blogs


[5] Here's how to add environment variables to `~/.cshrc` file on FreeBSD 14.

```
% ps $$
  PID TT  STAT    TIME COMMAND
34507 11  Ss   0:00.77 -csh (csh)

% printf %s\\n "$SHELL"
/bin/csh
```

```
% grep -n setenv ~/.cshrc
30:setenv       EDITOR  vi
---- snip ----
46:setenv CHEAT_CONFIG_PATH /mnt/usbflashdrive/mydotfiles/cheat/conf.yml
```

```
% sed -n "/CHEAT_CONFIG_PATH/p" ~/.cshrc
setenv CHEAT_CONFIG_PATH /mnt/usbflashdrive/mydotfiles/cheat/conf.yml

% sed -n "/CHEAT_CONFIG_PATH/=" ~/.cshrc
46
```

```
% sed -i".SEDBAK.1" '/CHEAT_CONFIG_PATH/a \\
 setenv GEM_HOME "$HOME\/gems" \\
 ' ~/.cshrc
```

```
% grep -n "set path" ~/.cshrc
25:set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin $HOME/.local/bin)

% grep -n 'bin)$' ~/.cshrc
25:set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin $HOME/.local/bin)
```


```
% sed -n '/bin)$/p' ~/.cshrc
set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin $HOME/.local/bin)

% sed -n '/bin)$/=' ~/.cshrc
25
```

```
% sed -i".SEDBAK.2" 's/bin)$/bin $HOME\/gems\/bin)/' ~/.cshrc
```

```
% mkdir -p "$HOME"/gems/bin
```

```
% source ~/.cshrc
```


```
% printf %s\\n "$GEM_HOME"
/home/dusko/gems

% printf %s\\n "$path"
/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin /home/dusko/bin /home/dusko/.local/bin /home/dusko/gems/bin
 
% printf %s\\n "$PATH"
/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/home/dusko/bin:/home/dusko/.local/bin:/home/dusko/gems/bin
```

[6] Fixing dart-sass Dependency on FreeBSD

Based on [Fixing Jekyll's dart-sass Dependency on OpenBSD](https://btxx.org/posts/Fixing_Jekyll__39__s_dart-sass_Dependency_on_OpenBSD/).

The error when running `bundle install` on FreeBSD 14 was presented as:

```
Installing sass-embedded 1.79.4 with native extensions
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

---- snip ----

rake aborted!
NotImplementedError: dart-sass for x86_64-freebsd14 not available at
https://github.com/sass/dart-sass/releases/tag/1.79.4 (NotImplementedError)
```

Fix:

```
% cp -i Gemfile Gemfile.ORIG
```

```
% wc -l Gemfile
      33 Gemfile
 
% tail -3 Gemfile
# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
```

```
% printf %s\\n >> Gemfile
% printf %s\\n\\n "# Customizations" >> Gemfile
% printf %s\\n "# Fixing dart-sass Dependency on FreeBSD" >> Gemfile
% printf %s\\n "gem 'jekyll-sass-converter', '~> 2.2'" >> Gemfile
```

```
% tail -1 Gemfile
gem 'jekyll-sass-converter', '~> 2.2'
```

[7] From [Jekyll themes - Made Mistakes (mademistakes) theme](https://mademistakes.com/work/jekyll-themes/)
> Below are the Jekyll themes and starters I've designed, developed, and released as open source.  Each theme contains the `_layouts`, `_includes`, Sass/CSS, JavaScript, and other sample files needed to build with Jekyll and host a static site or blog.
> 
> Getting started with each is roughly the same:
> 1. Install as a [Ruby gem](https://jekyllrb.com/docs/themes/#understanding-gem-based-themes), [remote theme](https://github.com/benbalter/jekyll-remote-theme), or fork the theme repository you'd like to use or modify.
> 2. [Install Bundler](https://bundler.io/) `gem install bundler` and run `bundle install` to install all dependencies (Jekyll, plugins, and so on).
3. Update Jekyll's `_config.yml` file, customize data files (found in the `_data` directory), and replace sample posts and pages with your own content.
> 
> For more specifics, consult each theme's documentation by visiting the setup guide links.


[8] [Understanding gem-based themes](https://jekyllrb.com/docs/themes/#understanding-gem-based-themes)
> When you [create a new Jekyll site](https://jekyllrb.com/docs/) (by running the `jekyll new <PATH>` command), Jekyll installs a site that uses a gem-based theme called [Minima](https://github.com/jekyll/minima).
> 
> With gem-based themes, some of the site's directories (such as the `assets`, `_data`, `_layouts`, `_includes`, and `_sass` directories) are stored in the theme's gem, hidden from your immediate view.  Yet all of the necessary directories will be read and processed during Jekyll's build process.
> 
> In the case of Minima, you see only the following files in your Jekyll site directory:
>
> ```
> .
> ├── Gemfile
> ├── Gemfile.lock
> ├── _config.yml
> ├── _posts
> │   └── 2016-12-04-welcome-to-jekyll.markdown
> ├── about.markdown
> └── index.markdown
> ```
>
> The `Gemfile` and `Gemfile.lock` files are used by Bundler to keep track of the required gems and gem versions you need to build your Jekyll site.
> 
> Gem-based themes make it easier for theme developers to make updates available to anyone who has the theme gem.  When there's an update, theme developers push the update to RubyGems.
> 
> If you have the theme gem, you can (if you desire) run `bundle update` to update all gems in your project.  Or you can run `bundle update <THEME>`, replacing `<THEME>` with the theme name, such as `minima`, to just update the theme gem.  Any new files or updates the theme developer has made (such as to stylesheets or includes) will be pulled into your project automatically.
> 
> The goal of gem-based themes is to allow you to get all the benefits of a robust, continually updated theme without having all the theme's files getting in your way and over-complicating what might be your primary focus: creating content.

[9] Based on [How to fix "error `/' not found" error about jekyll in localhost:4000 - Stack Overflow](https://stackoverflow.com/questions/56100280/how-to-fix-error-not-found-error-about-jekyll-in-localhost4000):

```
% grep -n whiteglass-template _config.yml
27:baseurl: "/whiteglass-template" # the subpath of your site, e.g. /blog

% sed -n '/whiteglass-template/p' _config.yml
baseurl: "/whiteglass-template" # the subpath of your site, e.g. /blog

% sed -n '/whiteglass-template/=' _config.yml
27
 
% sed -i".ORIG" 's/whiteglass-template//' _config.yml

% diff --unified=0 _config.yml.ORIG _config.yml
--- _config.yml.ORIG    2024-09-24 19:59:32.559332000 -0700
+++ _config.yml 2024-09-24 20:03:53.216647000 -0700
@@ -27 +27 @@
-baseurl: "/whiteglass-template" # the subpath of your site, e.g. /blog
+baseurl: "/" # the subpath of your site, e.g. /blog
```

---

## References
(Retrieved on Sep 24, 2024)

* [Jekyll on FreeBSD - Jekyll - Simple, blog-aware, static sites](https://jekyllrb.com/docs/installation/freebsd/)

* [Fixing Jekyll's dart-sass Dependency on OpenBSD](https://btxx.org/posts/Fixing_Jekyll__39__s_dart-sass_Dependency_on_OpenBSD/) 

* [How to fix "error `/' not found" error about jekyll in localhost:4000 - Stack Overflow](https://stackoverflow.com/questions/56100280/how-to-fix-error-not-found-error-about-jekyll-in-localhost4000)

* [Jekyll Themes - mademistakes theme](https://mademistakes.com/work/jekyll-themes/)

* [Template site for Jekyll whiteglass theme](https://github.com/yous/whiteglass-template)

* [Light Speed: Jekyll theme with a perfect Lighthouse score](https://git.btxx.org/lightspeed)

---

