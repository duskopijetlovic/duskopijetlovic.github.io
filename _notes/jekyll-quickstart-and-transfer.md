---
layout: page
title: "Jekyll Quickstart [WIP]"
---

Gemfile -> `bundler exec jekyll serve`

No Gemfile -> `jekyll serve`

## Clone 

```
$ git clone https://github.com/huangyz0918/moving
```

If there's a `Gemfile`:

```
$ bundle install
```

```
$ bundle exec jekyll serve
```

If there are errors about missing gems/files; for example, if `jekyll` complains about *webrick*, similar to `cannot load such file -- webrick (LoadError)`, to add the missing file either:


```
$ bundle add webrick
```

This adds `webrick` to the end of `Gemfile`.

```
$ tail -1 Gemfile
gem "webrick", "~> 1.8"
```

## Troubleshooting


### Fixing Jekyll's dart-sass Dependency on FreeBSD and OpenBSD - aka An error occurred while installing sass-embedded and Bundler cannot continue

`An error occurred while installing sass-embedded (1.80.4), and Bundler cannot continue.`

**Fix:**

Add the following line to `Gemfile`:

``` 
gem 'jekyll-sass-converter', '~> 2.2'
``` 

NOTE: I didn't want to run `gem uninstall` on my FreeBSD 14.1-RELEASE-p5 system because it would uninstall its dependecies.

```
$ gem uninstall jekyll-sass-converter -v 1.5.2 --user-install

You have requested to uninstall the gem:
        jekyll-sass-converter-1.5.2

github-pages-215 depends on jekyll-sass-converter (= 1.5.2)
jekyll-3.10.0 depends on jekyll-sass-converter (~> 1.0)
jekyll-3.9.5 depends on jekyll-sass-converter (~> 1.0)
jekyll-3.9.0 depends on jekyll-sass-converter (~> 1.0)
jekyll-3.8.6 depends on jekyll-sass-converter (~> 1.0)
If you remove this gem, these dependencies will not be met.
Continue with Uninstall? [yN]  N
---- snip ----
```

#### Useful commands for this

```
$ gem help command

$ gem help list

$ gem list --local | grep -n "jekyll-sass-converter"
$ gem list --local --details | wc -l
$ gem list --local --details | grep -n "jekyll-sass-converter"
```

### Commands 

```
$ jekyll -v

$ bundle install
$ bundle list
$ bundle env
$ bundle help
```

---- 

## References

* [Fixing Jekyll's dart-sass Dependency on OpenBSD](https://btxx.org/posts/Fixing_Jekyll__39__s_dart-sass_Dependency_on_OpenBSD/)

* [Installing a gem on OpenBSD fails - feat: OpenBSD support #9493](https://github.com/jekyll/jekyll/issues/9493)

----

