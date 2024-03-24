---
layout: default    ## If you don't want to display the page as "plain"
title: "Fix for Wrong number of arguments in Jekyll" 
---

```
$ cd ~/duskopijetlovic.github.io
```

```
$ bundle exec jekyll serve
---- snip ----
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.

^C

---- snip ----
    hundres of lines
---- snip ----

/usr/home/dusko/duskopijetlovic.github.io/vendor/bundle/ruby/3.1/bin/jekyll: warning: Exception in finalizer #<Proc:0x00000009f1164fe0 /usr/home/dusko/duskopijetlovic.github.io/vendor/bundle/ruby/3.1/gems/rb-kqueue-0.2.7/lib/rb-kqueue/watcher/file.rb:45 (lambda)>
/usr/home/dusko/duskopijetlovic.github.io/vendor/bundle/ruby/3.1/gems/rb-kqueue-0.2.7/lib/rb-kqueue/watcher/file.rb:45:in `block in finalizer': wrong number of arguments (given 1, expected 0) (ArgumentError)
```


```
$ bundle update
---- snip ----
```

```
$ bundle clean
---- snip ----
```

---

## Reference:

[Wrong number of arguments (given 2, expected 1)](https://talk.jekyllrb.com/t/wrong-number-of-arguments-given-2-expected-1/5446/15)   
(Retrieved on Mar 24, 2024)  
