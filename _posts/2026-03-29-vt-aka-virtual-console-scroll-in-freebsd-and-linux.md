---
layout: post
title: "How to Scroll in VT (Virtual Terminal) on FreeBSD and Linux" 
date: 2026-03-29 16:39:59 -0700 
categories: rs232serial console terminal cli keyboard sysadmin freebsd unix 
---

AKA: Scrollback in VT (Virtual Terminal) (text console, the system console, tty)

---


## FreeBSD: Scrollback in VT - Scroll Lock Key

On FreeBSD, to scroll back in VT (virtual terminal), you need to press the **Scroll Lock** key, then scroll up and down with the **arrow keys**.
To scroll up or down a full screen at a time, use the **Page Up** and **Page Down** keys.


### If Keyboard doesn't have Scroll Lock Key

If your keyboard doesn't have a Scroll Lock key, it very likely uses a special function key sequence to access Scroll Lock.

On my wired split mechanical keyboard, Mistel Barocco MD770, you can activate Scroll Lock by pressing **Fn + [{** (the key to the right of 'P'). 


## Alternative - Remap Keys (Key Remapping)

[Changing your keyboard mapping - FreeBSD Diary](http://www.freebsddiary.org/kbdcontrol.php)

[Keyboard without Scroll Lock - freebsd-questions mailing list](https://lists.freebsd.org/pipermail/freebsd-questions/2007-September/158918.html)

[How can I scroll back the output in FreeBSD's console without Scroll Lock? - serverfault](https://serverfault.com/questions/420324/how-can-i-scroll-back-the-output-in-freebsds-console-without-scroll-lock)


## Linux: Software Scrollback was Removed in version 5.9 of the Kernel

On Linux, Scrollback via Shift+PageUp and Shift+PageDown is no longer supported on console terminals by kernels newer than version 5.9.

[vgacon (the VGA soft scrollback): remove software scrollback support - Linux kernel source tree](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=973c096f6a85e5b5f2a295126ba6928d9a6afd45)

[fbcon: remove soft scrollback code - Linux kernel source tree](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=50145474f6ef4a9c19205b173da6264a644c7489)


### Alternatives - Use a Terminal Multiplexer or less(1) or KMSCon 

* Use a terminal multiplexer; for example, `tmux(1)` or `screen(1)`.

* Use the `less(1)` program.

Of course, by the time you launch `tmux(1)`, `screen(1)` or `less(1)`, the message you need may have already scrolled out of view.

* [KMSCon](https://cgit.freedesktop.org/~dvdhrm/kmscon/plain/README) offers perhaps a better alternative by serving as a system console terminal emulator that captures all output from the start, avoiding this timing issue.

For more about KMSCon, see the References section below.

---

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

* [Linux 5.9 Dropping Soft Scrollback Support From FB + VGA Console Code](https://www.phoronix.com/news/Linux-5.9-Drops-Soft-Scrollback)

* [tty - How to scroll back in Linux virtual consoles (2022)? [duplicate] - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/714692/how-to-scroll-back-in-linux-virtual-consoles-2022)

* [Linux 5.9 Dropping Soft Scrollback Support From FB + VGA Console Code - Discussion includes KMSCon](https://www.phoronix.com/forums/forum/software/general-linux-open-source/1206921-linux-5-9-dropping-soft-scrollback-support-from-fb-vga-console-code#post1207225)

* [Linux Torvalds' announcement about removing soft scrollback support from FB + VGA console code - Sep 20 2020](https://lkml.iu.edu/hypermail/linux/kernel/2009.2/05870.html)

* [Linux console Shift + PgUp not working anymore - Unix and Linux Stack Exchange](https://unix.stackexchange.com/questions/325542/linux-console-shift-pgup-not-working-anymore)

* [The Latest Kernel Release - Page 173 - Console scrollback removed - Sep 19 2020](https://www.linuxquestions.org/questions/showthread.php?p=6167719)

* [KMSCon still has scrollback support - Hacker News - Dec 27 2022](https://news.ycombinator.com/item?id=34154035)

* [Scrollback on Linux TTY - Hacker News - Jun 14 2023 - Discussion includes KMSCon](https://news.ycombinator.com/item?id=36334329)

* [KMSCon – A Userspace System Console That Does Not Depend on Any Graphics Server (freedesktop.org) - Discussion on Hacker News](https://news.ycombinator.com/item?id=34153404)

* [kmscon - a system console for Linux - freedesktop.org](https://www.freedesktop.org/wiki/Software/kmscon/)

* [Kmscon - a simple terminal emulator based on linux kernel mode setting (KMS)](https://cgit.freedesktop.org/~dvdhrm/kmscon/plain/README)

---

