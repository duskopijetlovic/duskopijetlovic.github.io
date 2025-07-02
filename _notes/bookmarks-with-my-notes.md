---
layout: page 
title: "Bookmarks with My Notes"
---

## Backup

* [Performing backups the right way](https://whynothugo.nl/journal/2014/08/06/performing-backups-the-right-way/)

* [Rsync Backups and Snapshoting - Anthony Thyssen](https://antofthy.gitlab.io/info/usage/rsync_backup.txt)
> Rsync Backups and Snapshoting
>
> Making incremental backups (snapshots) with rsync
> 
> It's actually very easy to use rsync to create multiple snapshot of a backup.
>
> All you have to do is create a hard linked copy of the backup tree before
(or after) you run rsync.
> Each snapshot will have a hardlinked copy of the files, so each snapshot uses very little extra disk space.
> 
 Then when a file changes, rsync will unlink and recreate that files, while
leaving the old version of the changed file older hardlinked snapshots
untouched.
> 
> This means you can have many 'snapshots' of your backup (hours, days, etc) each with a copy of the files as they existed at the time the snapshot was made, with only the changed files using extra disk space.
> A very efficent of disk space for a snapshot system.
>
> However, be warned that file premissions, and ownership is shared via hardlinks, so if later updated changes some files owner or permission than ALL the copies of that linked file will also recieved the same change.
> This is the only cavat with a hardlinked snapshot system.

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
> Inspired by [http://www.jwz.org/blog/2007/09/psa-backups/](http://www.jwz.org/blog/2007/09/psa-backups/) and extended to maintain off-line backups. 
> 
> Inspired by [jwz's](http://www.jwz.org/blog/2007/09/psa-backups/) method for on-line backups and modified in light of the [CryptoLocker](http://en.wikipedia.org/wiki/CryptoLocker) malware to use off-line storage, this script runs nightly to synchronise `rsync` backups.
> 
> The method used to mount and unmount off-line storage is Mac OS X-specific, but this script backs up data residing on co-located servers, Windows machines, Macs, and web servers.
> 
> The `line_to_put_in_crontab` should be put in **root**'s crontab.
> 
> The backup volumes are kept unmounted; they really should be kept physically unplugged and powered off in case CryptoLocker gets smart enough in future to try mounting disks before it goes hunting.

* [GitHub - nickjeffrey/kvm_backup: Backup scripts for KVM virtual machines](https://github.com/nickjeffrey/kvm_backup)
> Simple shell scripts to perform backup of KVM virtual machines.
> Runs from cron on your KVM host(s).
> 
> Supported backup destinations include local disk path, remote NFS share, another remote KVM host.

* [Backing up FreeBSD and other Unix systems](https://bezoar.org/src/backups/)
> I have a 3-Tbyte server running FreeBSD-6.1 that handles versioned backups.
> I don't bother with encrypting the filenames or hashes because we control the box, and if I'm not at work, other admins might need to restore something quickly.
> 
> We have around 3.7 million files from 5 other servers backed up under two 1.5-Tbyte filesystems, /mir01 and /mir02.
> My setup looks like this: 
> 
> [ . . . ]


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

### ZFS Snapshots

* [sanoid - These are policy-driven snapshot management and replication tools which use OpenZFS for underlying next-gen storage. (Btrfs support plans are shelved unless and until btrfs becomes reliable)](https://github.com/jimsalterjrs/sanoid)

---

## ZFS

* [ZFS Cheatsheet - FreeBSD Foundation - Author: Benedict Reuschling](https://github.com/FreeBSDFoundation/blog/blob/main/openzfs-cheat-sheet/zfs_cheatsheet_en.pdf)

* [ZFS Cheatsheet - Author: Benedict Reuschling - TeX Source](https://github.com/FreeBSDFoundation/blog/blob/main/openzfs-cheat-sheet/zfs_cheatsheet_en.tex)

---

## Documentation

* [Documentation - Oatmeal](https://eli.li/docs)
> Documentation
>
> Here are some scattered thoughts on writing and maintaining documentation. My experience doing this is wholly confined to software development, but I think most of this advice is general enough to make sense in other domains, too.
>
> All text is hypertext.
>
> One thing well
> 
> I think good documentation picks a lane and runs there.
> It doesn't try to be everything for everyone all at once.
> 
> The lanes available:
> * **Tutorials**, learning-oriented (teaching someone to cook)
> * **How-to guides**, problem-oriented (a recipe for cooking a specific thing)
> * **Explanation**, understanding-oriented (historical overview of an ingredient’s cultural importance)
> * **Reference**, information-oriented (an encyclopedia article about an ingredient)
> 
> Each of these maps fairly well to an audience:
> * Tutorials are for folks who *are totally new to a thing*
> * How-to guides are a step up from tutorials and *help you learn idioms and best practices* of a space
> * Explanation is useful when needing to *convey the value of a thing*
> * Reference is generally *for experts who are cozy doing* the thing

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

### ed

* [ed Cheatsheet](https://sdf.org/?tutorials/ed)
> SDF Public Access UNIX System - Free Shell Account and Shell Access

### Vi

* [Wonderful vi](https://world.hey.com/dhh/wonderful-vi-a1d034d3)

---

## Writing

* [Lab Notebooks](https://sambleckley.com/writing/lab-notebooks.html)
> What wet-lab chemistry can teach software engineers

* [Paper](https://dynomight.net/paper/)
> Paper is good.
> Somehow, a blank page and a pen makes the universe open up before you.
> Why paper has this unique power is a mystery to me, but I think we should all stop trying to resist this reality and just accept it.
> 
> [ . . . ]
> 
> So let me offer a few observations about paper.
> These all seem quite obvious.
> But it took me years to find them, and they've led me to a non-traditional lifestyle, paper-wise.
> 
> Observation 1: The primary value of paper is to **facilitate thinking**.
> 
> Observation 2: If you don’t have a "system", you won't get much benefit from paper.
> 
> Observation 3: User experience matters.
> 
> Observation 4: **Categorization is hard**.
> 
> [ . . . ]
> 
> My current system, the first one I actually like, is this:
> 
> 1. Buy three-hole punched printer paper.
> 2. Write on it.
> 3. Everything goes into a single-three ringed notebook in chronological order, no exceptions.
> 4. When that notebook is full, take the paper out, put a sheet of brown cardstock on each end, and put brass fasteners through the holes.
> 5. That "book" then goes on a bookshelf, never to be looked at again.
> 

* [Note Taking, Writing and Life Organization Using Plain Text Files](http://www.markwk.com/plain-text-life.html)
> The Why: Advantages and Disadvantages of Plaintext Files
> 
> "Writing is thinking. To write well is to think clearly. That’s why it’s so hard." -- David McCullough
> 
> Writing is arguably the critical ingredient to how we think and learn.  If you can’t write about something coherently and intelligibly, then your thinking on that topic or subject is vague and incomplete.
> 
> Similarly, I'd argue writing is a key aspect to personal and professional organization too. Often through lists, note-taking, project management tools, or a process journal, we write out our plans, goals, intentions and other aspects that clarify what we want to accomplish.  Writing allows us to express vague feelings and turn them into intentions and goals.

* [Replace Your To-Do List With Interstitial Journaling To Increase Productivity](https://medium.com/better-humans/replace-your-to-do-list-with-interstitial-journaling-to-increase-productivity-4e43109d15ef)
> A new journaling tactic that immediately kills procrastination and boosts creative insights.

* [Get focused with interstitial journaling](https://jesperbylund.com/blog/get-focused-with-interstitial-journaling)

---

## Digital Gardens - Personal Wikis - Knowledge Bases 

* [Felix at Home - Felix Pleşoianu](https://felix.plesoianu.ro/) 
> I'm just a lonely orange cat watching the moon from the windowsill on a starry night.
> I'm not a social media profile, or an end-point where you can push replies. I'm a person.
> Talk to me.
> 
> [ . . . ]
> 
> Personal
>
> * [journal](https://felix.plesoianu.ro/journal.html): occasional short thoughts
> * [wiki](https://felix.plesoianu.ro/wiki.html): notes that don't fit anywhere else 
> 
> * blog archive: [https://felix.plesoianu.ro/blog/index.html](https://felix.plesoianu.ro/blog/index.html)
> 
> [ . . . ]
>
> * [web directory](https://felix.plesoianu.ro/links/index.html): hundreds of links in context 
> Bounty of bookmarks
> 
> This is my personal web directory; a way to do something with my browser bookmarks instead of hoarding them.
> There are two parts. 
> Around eight hundred are divided between the categories below as of February 2025.
> More were moved to The Web Curator:
>
> * [The Web Curator - Blogrolls, linklogs and directories (in FeatherWiki) - Felix Pleşoianu](https://felix.plesoianu.ro/links/directory.html)
> About
> 
> This is my personal link directory; a way to do something with my browser bookmarks instead of hoarding them.
> Over nine hundred are divided between the categories in the sidebar as of late November 2023.
> The hard part was recalling why I wanted to keep some of them.
> 
> Specifically, this is an experimental mirror of the [initial static website](https://felix.plesoianu.ro/links/) with more pages and better organization, but ideally it should become its own thing someday.
>
> Motivation
> 
> The web is huge.
> Each part of my website has a web directory of its own, on top of the big one with everything else in it.
> I'm not alone in this, either.
> We all need to do it just to keep track of stuff somewhat, and it's still overwhelming.
> But we can!
> That's what links are for. That's how the web works, by design.
> 
> The age of big, impersonal directories has passed, but web curation is more important than ever.
> The big search engines have betrayed people.
> There's a new generation, but it will need time to catch up.
> And it's not easy to make a search engine.
> A web directory can be as simple as one web page divided into sections. In fact an awesome list or blogroll is little more than that. Yet they hold the web together.
> And nobody needs permission to make their own.
>
> Sub Pages
>
> * [Highlights](https://felix.plesoianu.ro/links/directory.html?page=highlights)

* [WebSeitz/wiki](http://webseitz.fluxent.com/wiki/)
> This is the publicly-readable WikiLog Digital Garden (20k pages, starting from 2002) of Bill Seitz (a Product Manager and CTO).

* [Hack Your Life With A Private Wiki Notebook, Getting Things Done, And Other Systems](http://webseitz.fluxent.com/wiki/HackYourLifeWithAPrivateWikiNotebookGettingThingsDoneAndOtherSystems)
> Hack Your Life with a Private Wiki Notebook: Mash Up "Getting Things Done" and Other Systems

* [Things and Stuff Wiki](https://wiki.thingsandstuff.org/)

* [Maggie Appleton - A Brief History & Ethos of the Digital Garden - A newly revived philosophy for publishing personal knowledge on the web](https://maggieappleton.com/garden-history)
> My small collection highlighted a number of sites that are taking a new approach to the way we publish personal knowledge on the web.

* [Maggie Appleton - Nerding hard on digital gardens, personal wikis, and experimental knowledge systems with @_jonesian today](https://x.com/Mappletons/status/1250532315459194880)

* [Tom Critchlow. This is my personal digital garden. A wild garden, loosely tended. There's drafts, ideas, partials, fragments and ideas](https://tomcritchlow.com/wiki/)

* [Why a Digital Garden?](https://web.archive.org/web/20230620093928/https://jessmahler.com/why-a-digital-garden/) 

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
> Most of all, it's not a blog.  Blogs (and social media) tend to peg each post to a point in time, so that they age like milk and not like wine.  That's the "stream" in [The Garden and the Stream](https://edstrom.dev/nbgks/the-garden-and-the-stream).  I always saw more sense in the "garden" a.k.a. evergreen/[long content](https://gwern.net/about#long-content), where you continually reuse, refine and exitend your pages.
> 
> If there's any guiding principle, it's the notion of a slipbox as described by [Book: How to Take Smart Notes](https://edstrom.dev/tdzkq/book-how-to-take-smart-notes), though as of [2023-11-23 Thu] I think future-me wouldn't call this a good slipbox just yet.
> 
> It may make sense to realize the notes existed **before** the website, they're **not written for it**.  I was writing them anyway, for my own purposes. 

* [Anthony Thyssen](https://antofthy.gitlab.io/)

* [Bezoar.org](https://bezoar.org/)

* [some files ... - every.sdf.org](https://every.sdf.org/)
> 
> [ . . . ]
> 
> 18 directories, 106 files
> 
> tree v2.1.0 © 1996 - 2022 by Steve Baker and Thomas Moore
> 
> HTML output hacked and copyleft © 1998 by Francesc Rocher
> 
> JSON output hacked and copyleft © 2014 by Florian Sesser
> 
> Charsets / OS/2 support © 2001 by Kyosuke Tokoro 
> 
> From [ABOUT_THIS_SITE](https://every.sdf.org/ABOUT_THIS_SITE/)
> 
> about this site...
> 
> This site is primarily a repository of plain text files ([7bit US ASCII](https://en.wikipedia.org/wiki/ASCII)) that I have either written, collected or converted.
> They are mostly set at a fixed column width and may not play nicely with your modern browser or smartphone.
> All files with a **.txt** suffix are **ASCII**.
> While the site is designed mainly for my own use, I am happy to share it.
> Please feel free to peruse and/or download anything you find of interest.
> 
> The site is automagically generated in html/css by tree-1.8.0 and is hosted by the [SDF Public Access UNIX System](https://sdf.org/).
> 
> Please note that things around here tend to get added, removed, renamed and/or relocated not infrequently so directly linking to an individual file is probably not a good idea.
> Best to download a copy for yourself or request a permanent(ish) link.
> 
> And any file with my email address at the bottom is something I have scribbled.
> Therefore, if you have questions or comments, you can contact me at:
> 
> every@ma.sdf.org

* [Stupid Unix Tricks - Jeffrey Paul](https://sneak.berlin/20191011/stupid-unix-tricks/)

* [Hacks Repo - Jeffrey Paul](https://git.eeqj.de/sneak/hacks)
> 
> From [https://sneak.berlin/20191011/stupid-unix-tricks/](https://sneak.berlin/20191011/stupid-unix-tricks/) :
> I have a git repository called hacks into which I commit any non-secret code, scripts, snippets, or supporting tooling that isn't big or important or generic enough to warrant its own repo.
> This is a good way to get all the little junk you work on up onto a website without creating a billion repositories.

* [Jeffrey Paul - Berlin, Deutschland](https://sneak.berlin)

* [Linux Cheat Sheets (cheatsheets) - Zintis Perkons](https://www.zintis.net/)

* [James' Coffee Blog](https://jamesg.blog/)

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

* [Claus Aßmann at sendmail.org](https://www.sendmail.org/~ca/)
> You're probably looking for some stuff about sendmail?
> Here it is:
>
> * [What's new?](https://www.sendmail.org/~ca/email/new.html)
> * [**Index (List of links)**](https://www.sendmail.org/~ca/email/misc.html)
> * [Avoiding UBE - aka Using check_* in sendmail 8.8](https://www.sendmail.org/~ca/email/check.html)
> * [cf/README - aka SENDMAIL CONFIGURATION FILES](https://www.sendmail.org/~ca/email/doc8.10/cf.README)

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

* [Time Management Tips etc. - time-management-tips-etc -- Wouter van Oortmerssen](https://strlen.com/time-management-tips-etc/)

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

## TeX and LaTeX

* [Document Preparation using LaTeX 2e - by Phil Spector](https://www.stat.berkeley.edu/~spector/latex2e.pdf)
> Statistical Computing Facility, Department of Statistics, University of California, Berkeley

* [Getting Started - LaTeX - Research Guides at Florida Institute of Technology](https://libguides.lib.fit.edu/latex2e)

* [The Not So Short Introduction to LaTeX 2e Or LaTeX 2e in 95 minutes](https://gking.harvard.edu/files/lshort2.pdf) 
> by Tobias Oetiker, Hubert Partl, Irene Hyna and Elisabeth Schlegl

* [Introduction to LaTeX](https://epfllibrary.github.io/latex-course/aio.html)

* [An introduction to creating documents in LaTeX](https://opensource.com/article/17/6/introduction-latex)
> Learn to typeset documents in the LaTeX text markup language.

* [Create beautiful PDFs in LaTeX](https://opensource.com/article/22/8/pdf-latex)
> Use the LaTeX markup language to compose documents.

* [Manual, LaTeX Reference, Tutorial - LaTeX Suite Quick Start](https://vim-latex.sourceforge.net/documentation/latex-suite-quickstart/)
> A (very) quick introduction to Latex-Suite
> 
> Latex-Suite is a comprehensive set of scripts to aid in editing, compiling and viewing LaTeX documents.
> A thorough explanation of the full capabilities of Latex-Suite is described in the user manual.
> This guide on the other hand, provides a quick 30-45 minute running start to some of the more commonly used functionalities of Latex-Suite. 

* [Producing Beautiful Documents with TeX and LaTeX](http://cda.psych.uiuc.edu/latex_class_2014/latex_presentation.pdf) 
> An Extremely Brief Introduction - by Lawrence Hubert, University of Illinois

* [Latex-Suite - Beginner's Tutorial](https://vim-latex.sourceforge.net/index.php?subject=manual&title=Tutorial#tutorial)

* [Latex-Suite - User's Manual](https://vim-latex.sourceforge.net/index.php?subject=manual&title=Manual#user-manual)

* [How to Produce Professional Documents with LaTeX](http://michaelelliotking.com/articles/learn-latex)
> A simple guide to learning LaTeX for formatting your professional documents

* [texlogsieve: (yet another program to) filter and summarize LaTeX log files - Package Documentation](http://mirrors.ctan.org/support/texlogsieve/texlogsieve.pdf)

* [texlogsieve: (yet another program to) filter and summarize LaTeX log files - Source](https://gitlab.com/lago/texlogsieve)
> Nelson Lago

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

## Networking

* [IP Primer BCNE book - by Jon Fullmer - Brocade_IP_Primer_eBook.pdf](https://www.jonfullmer.com/Brocade_IP_Primer_eBook.pdf)
> Brocade IP Primer, First Edition
> 
> Everything you need to obtain a solid foundation in networking technologies and design concepts

---

## Unix and Linux

* [Unix Toolbox](https://cb.vu/unixtoolbox.html)
> This document is a collection of Unix/Linux/BSD commands and tasks which are useful for IT work or for advanced users.
> This is a practical guide with concise explanations, however the reader is supposed to know what s/he is doing.
> Whether you're interested in setting up a secure VPN connection, managing your own hosting environment, working with graphics tools, or implementing robust security measures, this guide provides essential commands and best practices for your needs.
>
> [ . . . l
> 
> On a duplex printer the page will create a small book ready to bind.
> This **XHTML** page can be converted into a nice **PDF** document with a **CSS3** compliant application (see the [script example](https://cb.vu/unixtoolbox.html#bourneexample)).

* [Rosetta Stone for Unix - Map Commands to Other Versions of UNIX - aka The Ultimate Unix Cheat Sheet - aka A Sysadmin's Unixersal Translator - or - What do they call that in this world?](http://bhami.com/rosetta.html)

* [UNIX History (huge chart)](https://www.levenez.com/unix/)

* [Unix Text Processing (Hayden Books)](https://www.oreilly.com/openbook/utp/)
> Unix Text Processing, by Dale Dougherty and Tim O'Reilly, was published by Hayden Books in 1987, back when O'Reilly & Associates wrote technical documentation for hire. Hayden later took the book out of print, but Dale and Tim retained the copyright and have decided to make it available through our web site under Creative Commons' Attribution License. 

* [Sculpting text with regex, grep, sed, awk, emacs and vim](https://matt.might.net/articles/sculpting-text/)

* [Manipulating Data on Linux - by Harry Mangalam](http://moo.nac.uci.edu/~hjm/ManipulatingDataOnLinux.html)
> Version 1.24, Sept 27, 2012

* [unixdigest.com](https://unixdigest.com/)
> Articles (occasional rants) and tutorials about open source, BSD, GNU/Linux, system administration, programming, and other stuff - the pragmatic way.

* [DragonFly BSD Digest](https://www.dragonflydigest.com/)
> A running description of activity related to DragonFly BSD.

* [SDF - Wiki -- aka SDF Tutorial Wiki](https://wiki.sdf.org/)
> SDF Public Access UNIX System - Est. 1987
>
> Welcome to SDF User Contributed Tutorials
> 
> sdf.org; Public Access UNIX System; A non-commercial Internet community
> 
> This is a shared, member contributed, set of tutorials for existing and potential SDF users who are interested in the Internet, the UNIX operating system, and programming languages.
> The purpose of this wiki is to help new users learn about the SDF Public Access UNIX System and UNIX through practical and useful examples.
> 
> Initially, this was a subset of the information from the HTML tutorials at [sdf.org -> tutorials](http://sdf.org/?tutorials).

* [SDF, UNIX and Internet tutorials - SDF Public Access UNIX System - Free Shell Account and Shell Access](https://sdf.org/?tutorials)
>  Two Tutorial Projects
> 
> There are currently two overlapping tutorial projects:
> * The newer [SDF Tutorial wiki](https://wiki.sdf.org/), available at *wiki.sdf.org*.
> It contains ported versions of all (or nearly all) of the HTML tutorials listed below, plus new content.
> It also includes Search functionality, and a standardized page format.
> * The traditional [HTML tutorials](https://sdf.org/?tutorials#HTML_Tutorials), which are linked below.
> These contain many basic and advanced tutorials created and updated by SDF users over the years.

---

## Sysadmin

* [Softpanorama](https://softpanorama.org/)
> (slightly skeptical) Educational society promoting "Back to basics" movement against IT overcomplexity and  bastardization of classic Unix
> 
> May the source be with you, but remember the KISS principle ;-)
> 
> 32 years of Softpanorama educational society which [was started in September of 1989](https://softpanorama.org/Bulletin/index.shtml) as a monthly floppy based bulletin for PC programmers and was dissolved in September 2021.
> Web site will exist till June 2024.
> From now on the content is static.   
>
> [ . . . ]
>
> [The Last but not Least](https://softpanorama.org/Bulletin/Humor/last_but_not_least.shtml): Technology is dominated by two types of people: those who understand what they do not manage and those who manage what they do not understand
> ~Archibald Putt. Ph.D
>
> [ . . . ]
> 
> This site is perfectly usable without Javascript.
> 
> Last modified: September 08, 2021
>
> * [The Last but not Least](https://softpanorama.org/Bulletin/Humor/last_but_not_least.shtml)
> 
> Please ask yourself five questions:
> * Does the surfing become the activity that consumes significant amount of time spent on the computer?
> * Does it replace reading books? 
> * Do you typically read no more than one or two pages of a Web page before you "bounce" out to another page/site?
> * Do you save some articles which impressed you, and never ever re-read saved material? 
> * Are you browsing the Web during lunch breaks, or meals in general? 
>
> If you, like me, answer all five questions positively, you might wish to consider scaling down your browsing activities ;-).
> Of course, this is easier said then done.
>
> ~ Dr. Nikolai Bezroukov
> 
> [ . . . ]
> 
> [Nikolai Bezroukov - from Wikipedia](https://en.wikipedia.org/wiki/Nikolai_Bezroukov)
> Nikolai Bezroukov is a Senior Internet Security Analyst at BASF Corporation, Professor of Computer Science at Fairleigh Dickinson University (NJ) and Webmaster of [www.softpanorama.org](https://www.softpanorama.org/) - Open Source Software University - a volunteer technical site for the United Nations SDNP program that helps with Internet connectivity and distributes Linux to developing countries.
> 
> He authored one of the first classification system for computer viruses and an influential Russian language book on the subject -- Computer Virology in 1991. 
>
> [ . . . ]
> 
> * [Informing yourself to death](https://softpanorama.org/Social/Overload/Computer_obsession/obsession_with_internet_and_social_sites.shtml)
> 
> Obsession with Internet Browsing and Social Sites 
> 
> "On-line service is not as reliable as cocaine or alcohol, but in the contemporary world, *it is a fairly reliable way of shifting consciousness*...
> Compulsive gamblers are also drawn to the tug of war between mastery and luck.
> When this attraction becomes an obsession, *the computer junkie resembles the intemperate gambler*...
> 
> Unlike stamp collecting or reading, *computers are a psycho-stimulant, and a certain segment of the population can develop addictive behavior in response to that stimulant.*"
> 
> ~ Dr. Shaffer (Harvard), The Addiction Letter, August, 1995
>
> [ . . . ]
>
> According to [Wikipedia - Internet addiction disorder](https://en.wikipedia.org/wiki/Internet_addiction_disorder):
>
> Information addiction is a condition whereby *connected users experience a hit of pleasure, stimulation and escape* and technology affects attention span, creativity and focus which has been referred to as pseudo-attention deficit disorder.
> 
> While *it is certainly possible for information addiction exist without computer* (bibliophils, overeager library users, etc. are an example), computer make it mass problem.
> One of the most common case is related to compulsive "sitting" on Internet many hours a day and abandoning all other tasks and responsibilities.
> 
> Some improperly call it [Internet addiction disorder](https://en.wikipedia.org/wiki/Internet_addiction_disorder), which more properly should be called **compulsive behavior** (or bad habit), not an addiction.

* [Data Center Management and Best Practices](http://veggiechinese.net/data_center_management/sydes_yardley_datacenter_management.pdf)

---

## HPC (High Performance Computing) 

* [An Introduction to the HPC Computing Facility - by Harry Mangalam](https://web.archive.org/web/20201031155718/https://hpc.oit.uci.edu/HPC_USER_HOWTO.html)

* [HPC at UCI/RCIC (University of California - Irvine, Research Cyber Infrastructure Center](https://web.archive.org/web/20200307233451/https://hpc.oit.uci.edu/)
> High Performance Computing Cluster

---

## Shell

* [pure-sh-bible](https://github.com/dylanaraps/pure-sh-bible)
> A collection of pure POSIX sh alternatives to external processes. 

---

## XTerm

* [XTerm - Terminal emulator for the X Window System](http://invisible-island.net/xterm/).
> [XTerm FAQ](https://invisible-island.net/xterm/xterm.faq.html):
> 
> As a stylistic convention, the capitalized form is "XTerm", which corresponds to the X resource class name.
> Similarly, uxterm becomes "UXTerm".

* [xtermcontrol - Dynamically Control Xterm Properties](https://thrysoee.dk/xtermcontrol/)
> Xtermcontrol enables dynamic control of [xterm](http://invisible-island.net/xterm/) properties.
> It makes it easy to change colors, title, font and geometry of a running xterm, as well as to report the current settings of these properties.
> Window manipulations de-/iconify, raise/lower, maximize/restore and reset are also supported.
> 
> To complete the feature set; xtermcontrol lets advanced users issue any xterm control sequence of their choosing.
> 
> The [Make Test Video](https://thrysoee.dk/xtermcontrol/#make_test_video) showcase most of xtermcontrol's options.

* [CuteXTerm - Sensible defaults for xterm in the 21st century](https://github.com/csdvrx/CuteXterm) 
> What is CuteXTerm?
> 
> CuteXTerm is a set of sensible defaults to make the terminal experience on Linux as good as possible, by adapting xterm to the 21st century.
> 
> To be precise, CuteXTerm is a set of software (tabbed), fonts (iosevka), and configuration defaults (Xresources, xinitrc, terminfo, application desktop file, shell commands) that together make xterm cute and functional.

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

* [Just another website - Felix Pleşoianu](https://felix.plesoianu.ro/web/site.html)
> Minimal stylesheet with only three lines.
> 
> This is just another website.
> Okay, it's only one page, but single-page sites are all the rage right now.
> Pardon, single-page apps.
> You get the idea.
> 
> This site is an experiment.
> It's similar to others floating around the web (see at the end for a list of references).
>Its real goal is to make you think.
> 
> Think about how much you can do with very little.
> Like the design of this page?
> It's literally a five-line stylesheet.
> By way of contrast, [my homepage](https://felix.plesoianu.ro/) has twenty-five.
> Radical simplicity matters. 

* [No CSS Club](https://nocss.club/)

* [Plain old webpages still matter - Posted Nov 3 2017](https://felix.plesoianu.ro/web/files/plain-old-webpages.txt)

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

## Finance

* [finiki, the Canadian financial wiki](https://www.finiki.org/)

---

## Parenting

* [Parenting for Humans - Emma Svanberg (author)](https://guardianbookshop.com/parenting-for-humans-9781785044120/)
> How to Parent the Child You Have, As the Person You Are

---

## Mental Health

* [Therapy Worksheets](https://www.therapistaid.com/therapy-worksheets)

---

## Footnotes

[1] From [Plain Text - brajeshwar.com](https://brajeshwar.com/2022/plain-text/#fn:plaintext):
> Plain Text is a loose term for data that represent only characters of readable material but not its graphical representation nor other objects.  It may also include a limited number of "whitespace" characters that affect simple arrangement of text, such as spaces, line breaks, or tabulation characters.  Plain text is different from formatted text, where style information is included; from structured text, where structural parts of the document such as paragraphs, sections, and the like are identified; and from binary files in which some portions must be interpreted as binary objects. 
