---
layout: post
title: "How to Scroll in VT (Virtual Terminal)/Text Console in FreeBSD" 
date: 2026-03-29 16:39:59 -0700 
categories: rs232serial console terminal cli keyboard sysadmin freebsd unix 
---

AKA: Scrollback in VT (Virtual Terminal) (text console, the system console, tty)

---

## Scrollback in VT on FreeBSD

On FreeBSD, to scroll back in VT (virtual terminal), you need to press the **Scroll Lock** key, then scroll up and down with the **arrow keys**.
To scroll up or down a full screen at a time, use the **Page Up** and **Page Down** keys.


## If Keyboard doesn't have Scroll Lock Key

If your keyboard doesn't have a Scroll Lock key, it very likely uses a special function key sequence to access Scroll Lock.

On my wired split mechanical keyboard, Mistel Barocco MD770, you can activate Scroll Lock by pressing **Fn + [{** (the key to the right of 'P'). 


## Alternative 1 - Use a Terminal Multiplexer

Use a terminal multiplexer; for example, `tmux(1)` or `screen(1)`.


## Alternative 2 - Remap Keys (Key Remapping)

[Changing your keyboard mapping - FreeBSD Diary](http://www.freebsddiary.org/kbdcontrol.php)

[Keyboard without Scroll Lock - freebsd-questions mailing list](https://lists.freebsd.org/pipermail/freebsd-questions/2007-September/158918.html)

[How can I scroll back the output in FreeBSD's console without Scroll Lock? - serverfault](https://serverfault.com/questions/420324/how-can-i-scroll-back-the-output-in-freebsds-console-without-scroll-lock)


## References

* [vt(4) -- virtual terminal system video console driver -- FreeBSD Manual Pages](https://man.freebsd.org/cgi/man.cgi?vt)

> ```
> Scrolling Back
>   Output that has scrolled off the screen can be reviewed by pressing the
>   Scroll Lock key, then scrolling up and down with the arrow keys.
> 
>   The Page Up and Page Down keys scroll up or down a full screen at a time.
> 
>   The Home and End keys jump to the beginning or end of the scrollback buffer.
>  
>   When finished reviewing, press the Scroll Lock key again to return to 
>   normal use.  
> 
>   Some laptop keyboards lack a Scroll Lock key, and use a special function 
>   key sequence (such as Fn + K) to access Scroll Lock.
> ```

* [Scrolling Back without Scroll-Lock Key? - FreeBSD Forums](https://forums.freebsd.org/threads/scrolling-back-without-scroll-lock-key.42703/)


---

