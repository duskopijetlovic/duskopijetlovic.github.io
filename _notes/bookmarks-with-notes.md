---
layout: page 
title: "Bookmarks with Notes"
---

## Backup

* [Performing backups the right way](https://whynothugo.nl/journal/2014/08/06/performing-backups-the-right-way/)

* [PSA: Backups](https://www.jwz.org/blog/2007/09/psa-backups/)
  - Also: [https://www.jwz.org/doc/backups.html](https://www.jwz.org/doc/backups.html)
> Dear Lazyweb, and also a certain you-know-who-you-are who should certainly know better by now, I am here to tell you about backups. It's very simple. 
>
> . . . 
>   
> ```
> $ sudo rsync -vax --delete --ignore-errors / /Volumes/Backup/
> ```
> 
> If your version of rsync supports the `--xattrs` and `--acls` options (it probably does), use those too. 
> 
> If you have a desktop computer, have this happen every morning at 5AM by creating a temporary text file containing this line:
> 
> ```
> 0 5 * * * rsync -vax --delete --ignore-errors / /Volumes/Backup/
> ```
> 
> and then doing sudo crontab -u root that-file
>
> . . . 
> 
> You have a computer. It came with a hard drive in it. Go buy two more drives of the same size or larger. If the drive in your computer is SATA2, get SATA2. If it's a 2.5" laptop drive, get two of those. Brand doesn't matter, but physical measurements and connectors should match. -- By: Jamie Zawinski, 2007.

* [crontab_backup_script](https://github.com/jloughry/crontab_backup_script)
> Inspired by http://www.jwz.org/blog/2007/09/psa-backups/ and extended to maintain off-line backups 
> 
> Inspired by [jwz's](http://www.jwz.org/blog/2007/09/psa-backups/) method for on-line backups and modified in light of the [CryptoLocker](http://en.wikipedia.org/wiki/CryptoLocker) malware to use off-line storage, this script runs nightly to synchronise `rsync` backups.
> 
> The method used to mount and unmount off-line storage is Mac OS X-specific, but this script backs up data residing on co-located servers, Windows machines, Macs, and web servers.
> 
> The `line_to_put_in_crontab` should be put in root's crontab.
> 
> The backup volumes are kept unmounted; they really should be kept physically unplugged and powered off in case CryptoLocker gets smart enough in future to try mounting disks before it goes hunting.

### ZFS Snapshots

* [sanoid - These are policy-driven snapshot management and replication tools which use OpenZFS for underlying next-gen storage. (Btrfs support plans are shelved unless and until btrfs becomes reliable)](https://github.com/jimsalterjrs/sanoid)

### Rsync Snapshots

* [linux-timemachine -- Rsync-based OSX-like time machine for Linux, MacOS and BSD for atomic and resumable local and remote backups](https://github.com/cytopia/linux-timemachine)
> Rsync-based OSX-like time machine for Linux, MacOS and BSD for atomic and resumable local and remote backups.
> 
> timemachine is a tiny and stable KISS (https://web.archive.org/web/20220411220714/https://en.wikipedia.org/wiki/KISS_principle) driven and POSIX (https://web.archive.org/web/20220411142007/https://en.wikipedia.org/wiki/POSIX) compliant script that mimics the behavior of OSX's timemachine. It uses rsync (https://web.archive.org/web/20220411142007/https://linux.die.net/man/1/rsync) to incrementally back up your data to a different directory, hard disk or remote server via SSH. All operations are incremental, atomic and automatically resumable.
> 
> By default it uses the rsync options: --recursive, --perms, --owner, --group, --times and --links. In case your target filesystem does not support any of those options or you cannot use them due to missing permission, you can explicitly disable them via --no-perms, --no-owner, --no-group, --no-times, and --copy-links. See FAQ (https://web.archive.org/web/20220411142007/https://github.com/cytopia/linux-timemachine#bulb-faq) for examples.
> 
> Motivation
> 
> The goal of this project is to have a cross-operating system and minimal as possible backup script that can be easily reviewed by anyone without great effort. Additionally it should provide one task only and do it well without the need of external requirements and only rely on default installed tools.
> 
> Retention
> 
> As described above this project is KISS driven and only tries to do one job: back up your data.
> 
> Retention is a delicate topic as you want to be sure that data is removed as intended. For this there are already well-established tools that do an excellent job and have proven themselves over time: tmpreaper (https://web.archive.org/web/20220411142007/http://manpages.ubuntu.com/manpages/precise/man8/tmpreaper.8.html) and tmpwatch (https://web.archive.org/web/20220411142007/https://linux.die.net/man/8/tmpwatch).
> 
> Reliability
> 
> The script is written and maintained with maximum care. In order to retain a reliable and stable backup solution, a lot of effort goes into a vast amount of integration and regression tests (https://web.archive.org/web/20220411142007/https://github.com/cytopia/linux-timemachine/actions). These tests not only give you measurable confidence, but also help new contributors to not accidentally introduce new or old bugs.
> 
> FAQ
> 
> Q: Should I add trailing directory slashes (/)?
> A: Trailing directory slashes only matter for the source directory and will not make a difference if added to the destination directory.

* [rsync-time-backup -- Time Machine style backup with rsync](https://github.com/laurent22/rsync-time-backup)
> This script offers Time Machine-style backup using rsync. It creates incremental backups of files and directories to the destination of your choice. The backups are structured in a way that makes it easy to recover any file at any point in time.

---

## Documentation

* [Dummy IP & MAC Addresses for Documentation & Sanitization](https://ittavern.com/dummy-ip-and-mac-addresses-for-documentation-and-sanitization/)

* [whitebophir - Online collaborative Whiteboard that is simple, free, easy to use and to deploy](https://github.com/lovasoa/whitebophir)

* [whitebophir - Free online collaborative whiteboard WBO](https://wbo.ophir.dev/)
> The public board is accessible to everyone. It is a happily disorganized mess where you can meet with anonymous strangers and draw together. Everything there is ephemeral.

---

## Visualization

* [Visual guide to SSH tunneling and port forwarding](https://ittavern.com/visual-guide-to-ssh-tunneling-and-port-forwarding/)

* [Visual guide to SSH tunneling and port forwarding - Discussion on Hacker News](https://news.ycombinator.com/item?id=41596818)

---

## Editor

### Vi

* [Wonderful vi](https://world.hey.com/dhh/wonderful-vi-a1d034d3)

---

## Writing

* [Lab Notebooks](https://sambleckley.com/writing/lab-notebooks.html)
> What wet-lab chemistry can teach software engineers

* [Note Taking, Writing and Life Organization Using Plain Text Files](http://www.markwk.com/plain-text-life.html)
> The Why: Advantages and Disadvantages of Plaintext Files
> 
> "Writing is thinking. To write well is to think clearly. That’s why it’s so hard." -- David McCullough
> 
> Writing is arguably the critical ingredient to how we think and learn.  If you can’t write about something coherently and intelligibly, then your thinking on that topic or subject is vague and incomplete.
> 
> Similarly, I'd argue writing is a key aspect to personal and professional organization too. Often through lists, note-taking, project management tools, or a process journal, we write out our plans, goals, intentions and other aspects that clarify what we want to accomplish.  Writing allows us to express vague feelings and turn them into intentions and goals.

---

## Postmaster

### SMTP

#### SMTP RFCs 

* RFC5322 (used to be RFC822)
[OpenSMTPD: We deliver ! by Eric Faurot - Presentation at AsiaBSDCon 2013](https://opensmtpd.org/presentations/asiabsdcon2013-smtpd/#slide-3)
> Exchange Internet messages:
> * as defined by RFC5322 (used to be 822)
> 
> [ . . . ]

* RFC 5321
[OpenSMTPD - Home page (retrieved on Sep 24, 2024)](https://opensmtpd.org/)
> OpenSMTPD is a free implementation of the server-side SMTP protocol as defined by RFC 5321 [ . . . ]

### Sendmail

* [The Architecture of Open Source Applications (Volume 1) - Sendmail - Eric Allman](https://aosabook.org/en/v1/sendmail.html)

* [Sendmail Made Easy - UUASC (UNIX Users Association of Southern California - LA) - April 3, 2003 - archived from the original on 2008-02-28](https://web.archive.org/web/20080228054830/http://www.ultimateevil.org/~jeff/uuasc-2003-04-03.html)
> Sendmail is configured by the `sendmail.cf` file, which is typically located in either `/etc` or `/etc/mail`.  This file contains literally over a thousand lines of configuration data which most people find intimidating.  After reading through this document, you should be able to wade through that file with enough understanding to tell what it is doing.
> 
> To configure *sendmail*, though, we do not actually edit the `sendmail.cf` file.  Normally you edit a file named `sendmail.mc`, which is used to *"compile"* the `sendmail.cf` file.  The `sendmail.mc` file is written in a language called `m4`, which was originally a pre-processor for Fortran (similar to cpp for C).
> 
> The following is an example of one of the m4 macro files I actually use for one of the mail servers I have configured.  This file contains some special changes for the *Cyrus IMAP* daemon, which I tweaked a bit to use *Procmail* in the mix as well.
> 
> [ . . . ]

---

## Productivity

* [arbtt - automatic, rule-based time tracker](http://arbtt.nomeata.de/#what)
> arbtt is a cross-platform, completely automatic time tracker.
> 
> There are lots of time-tracking programs out there that allow you to collect statistics about how you spend your time, which activities are your biggest time-wasters, and so on. However, most of them require explicit action on your part: you have to manually enter what activity or project you're working on, and that has several disadvantages:
> * You need to stop what you're doing to insert the meta-information, and that breaks your concentration;
> * If you are lazy or get annoyed and don't keep updating it, the statistics will be useless
> * You won't be able to catch a little thing like quickly answering an e-mail or looking for the weather report.

* [arbtt - source code on GitHub](https://github.com/nomeata/arbtt)

* [I'm tired of overwhelming productivity apps, so I created this simple system instead](https://www.xda-developers.com/im-tired-of-overwhelming-productivity-apps-so-i-created-this-simple-system-instead/)
> Key Takeaways
> * Use simple, efficient apps for productivity, like TickTick for tasks and Google Calendar for events.
> * Keep note-taking simple with Google Docs and Windows Notepad, and streamline your reading process with Feedly, Pocket, and Google Discover.
> * Focus on personal habits and discipline, not just the features of productivity apps, to achieve your goals.

* [Plaintext Productivity](https://plaintext-productivity.net/)

* [today.txt - If you do this and only this, today will be a good day](https://johnhenrymuller.com/today)

---

## Plain Text (plaintext, plain-text)

* [Plain Text - brajeshwar.com](https://brajeshwar.com/2022/plain-text/) [<sup>[1](#footnotes)</sup>]

* [today.txt - Includes a template for today.txt file in plain text](https://johnhenrymuller.com/today)
> If you do this and only this, today will be a good day.

* [A template to organise life in plain text files - inspired by today.txt template and then extended it a little bit](https://github.com/jukil/plain-text-life)

* [Plain Text Journaling System - The Overthinker](https://georgecoghill.wordpress.com/plain-text/)
> Includes a template for plain text daily journaling 

* [Journal.TXT - Single-Text File Journals - The Human Multi-Document Format for Writers](https://journaltxt.github.io/)
> Write your journal in a single-text file.

* [Markwhen - A markdown-like journal language for plainly writing logs, gantt charts, blogs, feeds, notes, journals, diaries, todos, timelines, calendars or anything that happens over time](https://markwhen.com/)
> Output:
> Calendar
> Timeline
> Oneview
> JSON

* [Write plain text files - Derek Sivers](https://sive.rs/plaintext)

* [A Plain Text Personal Organizer (One big text file)](https://danlucraft.com/blog/2008/04/plain-text-organizer/)

* [Achieve a text-only work-flow HOWTO](http://donlelek.github.io/2015-03-09-text-only-workflow/)

* [Plain Text Project](https://plaintextproject.online)

* [Plaintext Productivity](https://plaintext-productivity.net/)

* [Note Taking, Writing and Life Organization Using Plain Text Files](http://www.markwk.com/plain-text-life.html)
> Fallacy of the Collector
>
> As a self-tracker and documenting guy, I love collecting stuff and tracking different aspects of my life.  For example, automation tools like IFTTT and Zapier can make it seamless for me to pull in links, articles and clippings from tools like Todoist or Instapaper.  Evernote and most note-taking tools also make it a tad too easily to be used for miscellaneous collecting.  Once all of my notes were into plain text, I discovered how much of it was just collected stuff.
> 
> The key realization here is that your plain text files system should not just be another collection system.  In fact, collecting and aggregating should be a minor aspect of what these systems should do.  What our system should help us do is to learn, connect and create and to stay organized.

* [Calendar.txt - Keep your calendar in a plain text file](https://terokarvinen.com/2021/calendar-txt/)
> Calendar.txt is versionable, supports all operating systems and easily syncs. 
> 
> You're not going to need it before 2033, but here is the [short go program to generate calendar.txt templates](https://terokarvinen.com/2021/calendar-txt/calendartxt-generator-0.0.1.zip).

* [Plain text planning calendar](https://demeyere.com/text-calendar/)

* [A list of Online text to diagram tools](https://xosh.org/text-to-diagram/)

* [txt2tags - One source, multiple targets](https://txt2tags.org/)
> Txt2tags is a document generator.  It reads a text file with minimal markup such as **bold** and //italic// and converts it to many formats.

* [awesome-txt -- A collection of awesome .TXT Text tools, formats, services, tips & tricks and more](https://github.com/mundimark/awesome-txt)

---

## Tool Makers

* [solemnwarning (Daniel Collins) - Never stopping to think if I should](http://www.solemnwarning.net/)

* [Alberto Salvia Novella - Personal projects](https://gitlab.com/users/es20490446e/projects)

* [Omar Polo](http://dots.omarpolo.com/)

* [Omar Polo on GitHub](https://github.com/omar-polo/)

* [whynothugo](https://git.sr.ht/~whynothugo/)

---

## Websites

* [Matt Might](https://matt.might.net/articles/)

* [Jackson Chen - jacksonchen666](https://jacksonchen666.com/)

* [Jan-Piet Mens](https://jpmens.net/archive/)

---

## Dotfiles

* [whynothugo - dotfiles](https://git.sr.ht/~whynothugo/dotfiles/tree/main/item/home/.local/bin)

---

## Unicode

### Locally hosted

* [text.makeup](https://text.makeup/)

---

## Unix

* [Rosetta Stone for Unix - Map Commands to Other Versions of UNIX - aka The Ultimate Unix Cheat Sheet - aka A Sysadmin's Unixersal Translator - or - What do they call that in this world?](http://bhami.com/rosetta.html)

* [UNIX History (huge chart)](https://www.levenez.com/unix/)

* [Unix Text Processing (Hayden Books)](https://www.oreilly.com/openbook/utp/)
> Unix Text Processing, by Dale Dougherty and Tim O'Reilly, was published by Hayden Books in 1987, back when O'Reilly & Associates wrote technical documentation for hire. Hayden later took the book out of print, but Dale and Tim retained the copyright and have decided to make it available through our web site under Creative Commons' Attribution License. 

* [Sculpting text with regex, grep, sed, awk, emacs and vim](https://matt.might.net/articles/sculpting-text/)

---

## Sysadmin

* [Data Center Management and Best Practices](http://veggiechinese.net/data_center_management/sydes_yardley_datacenter_management.pdf)

---

## Shell

* [pure-sh-bible](https://github.com/dylanaraps/pure-sh-bible)
> A collection of pure POSIX sh alternatives to external processes. 

---

## Diagrams and Graphs

* [A list of Online text to diagram tools](https://xosh.org/text-to-diagram/)

---

## Minimalism

* [barsh - Use your terminal as a bar](https://github.com/dylanaraps/barsh) 
> 1. Modify script to display information.
> 2. Run script in terminal.
> 3. Get window manager to use terminal as bar.

* [Dylan Araps - scripts](https://github.com/dylanaraps/bin)

* [Startpage - Simple start page written in HTML/SCSS](https://github.com/dylanaraps/startpage)

---

## Inspiration

* [edstrom.dev - about](https://edstrom.dev/vbjmn/about)
>  Hello. On this homepage, I publish some of my notes.
> 
> Notes of what?
> 
> What not? They can include:
> study notes, taken while I learn;
> guides / tips;
> cheatsheets;
> observations;
> movie lists and other attempts to systematize;
> open questions / confusions.
>
> Most of all, it's not a blog.  Blogs (and social media) tend to peg each post to a point in time, so that they age like milk and not like wine.  That's the "stream" in [The Garden and the Stream](https://edstrom.dev/nbgks/the-garden-and-the-stream).  I always saw more sense in the "garden" a.k.a. evergreen/[long content](https://gwern.net/about#long-content), where you continually reuse, refine and extend your pages.
> 
> If there's any guiding principle, it's the notion of a slipbox as described by [Book: How to Take Smart Notes](https://edstrom.dev/tdzkq/book-how-to-take-smart-notes), though as of [2023-11-23 Thu] I think future-me wouldn't call this a good slipbox just yet.
> 
> It may make sense to realize the notes existed **before** the website, they're **not written for it**.  I was writing them anyway, for my own purposes. 

---

## Cool

* [A simple SVG clock (in JavaScript) - Russell Cottrell](https://www.russellcottrell.com/blog/simpleClock.htm)

* [A single-handed clock (in JavaScript) - Russell Cottrell](https://www.russellcottrell.com/blog/singleHand.htm)
> One hand is all you need!  The earliest clocks and watches, and some historic clocks still in use, only had one hand.
> 
> On a 24-hour dial with midnight at the bottom and noon at the top, the position of the hour hand is analogous to the apparent position of the sun. 

* [Clock Chimes - Russell Cottrell](https://www.russellcottrell.com/blog/ClockChimes.htm)
> Clock Chimes runs in the background to play quarter and hour chimes accurately.
> 
> It uses a web worker that runs in an operating system thread, independent of the browser.
> The chime sounds are synthesized, keeping the document size small.

---

## Footnotes

[1] From [Plain Text - brajeshwar.com](https://brajeshwar.com/2022/plain-text/#fn:plaintext):
> Plain Text is a loose term for data that represent only characters of readable material but not its graphical representation nor other objects.  It may also include a limited number of "whitespace" characters that affect simple arrangement of text, such as spaces, line breaks, or tabulation characters.  Plain text is different from formatted text, where style information is included; from structured text, where structural parts of the document such as paragraphs, sections, and the like are identified; and from binary files in which some portions must be interpreted as binary objects. 
