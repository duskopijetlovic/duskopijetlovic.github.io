---
layout: post
title: "My Plaintext Todo System"
date: 2025-12-21 15:38:58 -0700 
categories: plaintext
---

Word cloud: plaintext, markup, markdown, vi, traditionalvi, vim, emacs,
            orgmode, interstitial journal, commonplace books, blog, journal, 
            diary, notebook, digital garden, memex method, todo, organizer, 
            mind-dump, exocortex, organzation system, task management system,
            OBTF (One Big Text File)

---

## Three Parts
* List 
* Calendar - scheduling
* Reminders

NOTE: For me, the List will be the base of my new system, so I replaced *List* with *System*.

### System 
* The System includes: Todo list, journal/diary, log, references, etc. 
  - Physical Component
    - Index cards - mostly outside
    - Stickies (post-it notes) - mostly in office
  - Digital Component
    - Plain text
    - Tagging
    - One sentence -> One line [<sup>[1](#footnotes)</sup>]
    - For TODO -> 1 line/task; that is: A single line represents a single task
    - Other types of entries can have multiple lines 
    - A blank line can be used in multiline entries [<sup>[2](#footnotes)</sup>]
    - Timestamp (optional) - for *some* lines, thoughts, paragraphs
      - If you want to automate timestamp addition: Use `notes.sh` shell script

*New* item (idea, thought, scheduling item) **immediately** goes into the system.

### Additional Questions
* Markup or not markup? (Todo.txt, Markdown, Emacs OrgMode, ...?)
* Indexing (document search app, full-text search database engine), e.g. Xapian, Recoll? (Or: not needed because of UNIX tools?)

**^^^** Decided to use my *variation* of a *lightweight markup*. **^^^**

## Objectives
* Life
* Brain dump - Clear clutter - No need to remember things - Big picture 
* Simple
* Plan - Future 
* Projects - Break into manageable steps 
  - Personal
  - Work


## Why? - Complete this section [:todo:]

* Fix my anxiety about:
  - perfectionism
  - melancholy
  - insecurity - e.g. about using my own programs or shell scripts
  - depression 
  - procrastination
  - planning
  - confronting others 
* Capture everything
* Help with thinking - Write stuff down 
* Simplify
* Stop chasing the Holy Grail of organizational system or tool

## How?

* Important - *Start* - NOW
  - Unceremoniously, without fanfare 
* Baby steps - Start small [<sup>[3](#footnotes)</sup>]
  - `LIFE.TXT` file
  - `today.txt` file
  - `calendar.txt` file
* Metadata in each file
  - Tags (Item Types, Keywords): `+Project` `@Context` `(A|B|C|D)` `:writing:` 
* No apps
* Only UNIX tools


## Visual Separation of Paragraphs in Plain Text is Hard

Typically hard to implement in plain text systems: paragraph separation.

**See also:** a dinkus, an asterism, greppability, typographical device, zareba, fleuron, dingbat, visual separation, visual separator, visual divider, semantic marker, delimiter, paragraph divider, paragraph separator, paragraph segmentation, paragraph mark, record header, ornamental section break, space break, scene break, thought breaker, placeholder.


Chosen: **dinkus** - horizontal row of three spaced asterisks, centered on its own line:

```
                 * * *
```


### Other Markers Considered

* A variation of asterism:

```
                   *  
                  * *
```


* My own/customized paragraph separator - the following sequence: 

```
-----=====*****=====-----
```

* A blank line before and after the dinkus:

```

                 * * *

```

* No space between asterisks:

```
                 ***
```

* A blank line before and after it:

```

                 ***

```


* Horizontal row of three spaced colons, three non-spaced colons, without and with a blank line before and after:

```
                 :::
```

```

                 :::

```


```
                : : :
```

```

                : : :

```

* The same but with dashes (`---`). 

  - Decided to use the following sequence as a paragraph separator (in multiline entries): `-----=====*****=====-----` 


## The System Structure

## Directory Tree (Directory Structure)

```
life/
 . LIFE.TXT
 . stacks/
    . today.txt
    . calendar.txt
 . tools/
```

## Inbox

Inbox is one file, `LIFE.TXT`.
It keeps *everything* in it (braindump) so you are not affraid of losing stuff.
You add your todo items, ideas, thoughts, code snippets, etc. 
In short, you enter or copy and paste random stuff in there whenever you come across something that you feel needs to be stored in it.

The `today.txt` file is either:
* [The Plain Text Life project - A template to organize life in plain text files](https://github.com/jukil/plain-text-life/blob/master/today.txt), or
* [If you do this and only this, today will be a good day](https://johnhenrymuller.com/today)

The `calendar.txt` file:

```
______Calendar

# In vi :r!remind -s /path/to/your/.reminders (ran on Dec 29, 2025):
2025/12/07 * * 15 630 10:30-10:45am Monthly Review
2025/12/11 * * 10 600 10:00-10:10am Call Jim
---- snip ----
2025/12/29 * * * * today

# In vi :r!cal (ran on Dec 29, 2025):
   December 2025
Su Mo Tu We Th Fr Sa
    1  2  3  4  5  6
 7  8  9 10 11 12 13
14 15 16 17 18 19 20
21 22 23 24 25 26 27
28 29 30 31

# After manually editing output of remind(1):
January 2026
2026-01-14 Wed 10:00-11:30am | Group meeting
2026-01-20 Tue 3:00-4:00pm   | Group video call with ABC Corp
2026-01-27 Tue 7:00-7:15pm   | XYZ yearly subscription renewal (real due date: Jan 29)

# For the current day, one line can be split - similar to Semantic Line Break.
# For example, if today's date is Jan 12, 2026: 
2026-01-12 Mon **today**
               11-11:45am Mtg w/ Joe,
               2-2:30pm Mtg w/ Alice,
               Mtg w/ Alan,            # If time has not been scheduled
               Email for times for next meeting :joe:alice:,
               Fred :email:
```


The `stacks` directory is for lists that stay approximately constant in size.

The `tools` directory contains any tools relevant to working in this repository.
For example, you could have a script for adding one-line timestamped notes. 


## File Format Rules - Syntax 

Aka: Metadata (or Customized Markup or Keywords)

Based on:

* [Todo.txt Format](https://github.com/todotxt/todo.txt)
* [Markdown syntax](http://daringfireball.net/projects/markdown/syntax)
* [Emacs Org Mode Markup - for Org Mode Tag](https://orgmode.org/manual/Tags.html)
* [Plain Text Life project](https://github.com/jukil/plain-text-life)

My variant (my customizations):
* 1 line/task (A single line represents a single task) - REQUIRED **only** for TODO items
* Other types of entries can have multiple lines 
* One sentence -> One line
* A blank line can be used in multiline entries
* Paragraph separator: ```-----=====*****=====-----```
* Tags are enclosed in colons (aka a word surrounded by colons) [<sup>[4](#footnotes)</sup>] 
* (Experimental) Title - enclosed in between `<><>` and `<><>` : ```<><> My Title <><>```

Some examples:

```
<><> My Title <><>

# Heading

## Sub-heading

- list item

-------------------------
:todo: to mark a line as a todo item
:done: to mark a line as done
:thought: to mark a thought 
:experience: to mark an experience
:reflection: to mark a reflection
:idea: to mark an idea
:feeling: to mark a feeling
:note: to mark a useful information to remember 
etc.
-------------------------
@context to indicate the context of a line or a paragraph
+project to indicate the project to which an item belongs to
(A) (B) (C) to indicate the priority of a line or a paragraph
-------------------------
x (A) 2025-05-20 2025-04-30 measure space for :+storagelShelves:@storage:diy:due:2026-05-30: 
-------------------------
```

### Examples of Processing 

* For ‘next_actions’ list, grep (verb, meaning: use the `grep(1)` utility) for `:todo:` items.
* For ‘what_done’ list, grep for `:done:` items.
* For ‘checklist_daily' or ‘checklist_weekly', grep for `:checklist`: items. [<sup>[5](#footnotes)</sup>]

---

## Tools

## UNIX native tools

* Write a shell script - to use a text editor (preference: traditional `vi(1)`)
* `script(1)`
* Here-Document - aka Heredoc [<sup>[6](#footnotes)</sup>]

---

## (Optional) Test Emacs Org Mode - with Evil Mode and Doom Emacs

### Install Emacs and Doom Emacs 

NOTE: 
Doom includes Evil mode.

```
$ sudo pkg install emacs
$ git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
fatal: destination path ~/.emacs.d already exists and is not an empty directory.

$ mv ~/.emacs.d ~/.emacs.d.OLD    # Or: rm -rvf ~/.emacs.d
$ ~/.emacs.d/doom-emacs/bin/doom install
```

Installation completed in around 20 minutes.

From Doom's installation message:
> Don't forget to run `doom sync` and restart Emacs after modifying `init.el` or `packages.el` in `~/.config/doom`.
> This is never necessary for `config.el`.
>
> [ . . . ]
>
> Access Doom's documentation from within Emacs via `SPC h d h` (when in *Evil* mode, which is *default*) or `C-h d h` (for non-Evil users) - or `M-x doom/help`.

Running Emacs should start Doom in Evil mode; that is, with *vi* key bindings.

```
$ emacs
```

TIPS:
* If it doesn't run Doom, try fixing it by running: 

   ```
   $ ~/.emacs.d/bin/doom sync
   ```

* Use `M-x` at first. 
That (usually) means, `Alt + x` on your keyboard.
In Emacs, keybindings with `M` mean the `Meta` key, and the `C` key means `Control/Command`.

  What key is the `Meta` key (by default):
  * Unix/BSD/FreeBSD -> `Esc``x` or `Alt`+`x`
  * Linux -> `Alt`
  * Mac -> `⌥ option` key or `alt option` key
  * Microsoft Windows -> `Alt`

  On keyboards with two keys labeled `Alt` (usually to either side of the space bar), the `Alt` on the *left* side is *generally* set to work as a Meta key.

* Using Org Mode.
When you open an .org file with Doom Emacs or Emacs, it will set the editor to org mode. 

Also see:

* [My simple, effective org mode setup - Karel Van Ooteghem](https://karelvo.com/posts/orgmode/)
* [An opiniated guide to using Org Mode in Emacs](https://iamapt.com/blog/org-emacs-doom/)
* [Doom Emacs - Getting Started guide](https://github.com/doomemacs/doomemacs/blob/master/docs/getting_started.org)
* [Quickstart - Org mode](https://orgmode.org/quickstart.html)
* [Org syntax](https://orgmode.org/worg/org-syntax.html)
* [Org-mode Tutorial / Cheat Sheet - Common tasks in org-mode](https://emacsclub.github.io/html/org_tutorial.html)
* [Org-Mode Cheatsheet Card (Org-Mode Reference Card)](https://orgmode.org/orgcard.pdf)
* [Chemacs2 - Emacs version switcher, improved](https://github.com/plexus/chemacs2)
* [Doom Emacs or Spacemacs? Use both with Chemacs2](https://www.youtube.com/watch?v=hHdM2wVM1PI)

---

## (Optional) Extending the System?
* Visualization - graphviz?
* Prioritization (4 Quadrants - The Eisenhower Matrix) 
    * Do First, Schedule, Delegate, Eliminate
* Emacs Org Mode - To ease Org Mode start: [<sup>[7](#footnotes)</sup>]
  - [Evil - an **e**xtensible **vi l**ayer for Emacs](https://github.com/emacs-evil/evil)
  - [Evil Collection - A set of keybindings for evil-mode](https://github.com/emacs-evil/evil-collection)
  - [Quickstart - Org mode](https://orgmode.org/quickstart.html)
  - [EmacsWiki - Evil](https://www.emacswiki.org/emacs/Evil)
> There's a [four-minute Evil demo](http://youtu.be/Uz_0i27wYbg) on YouTube, created by Bailey Ling.
> The captions in the corner of the frame show the keystrokes which Bailey is entering.
* [Doom Emacs](https://github.com/doomemacs/doomemacs)
* [Spacemacs: Emacs advanced Kit focused on Evil (Evil mode)](https://www.spacemacs.org/)

---

## Visualization: Move to a separate blog post [:todo:]

### Text2MindMap 

* [Text2MindMap - Online tool for making mindmaps by writing indented lists](https://github.com/tobloef/text2mindmap)

```
$ git clone https://github.com/tobloef/text2mindmap.git
```

```
SYSTEM
	List
		Physical
			IndexCards
			Stickies
		Digital
			Plaintext
			Tagging
			Timestamp
```

With your web browser, navigate to `/path/to/text2mindmap/index.html`.


### Graphviz

```
graph {
  rankdir=LR;
  
  SYSTEM -- list;
  list -- physical;
  list -- digital;

  physical -- stickies;
  physical -- indexcards;

  digital -- plaintext;
  digital -- tagging;
  digital -- timestamp
}
```

* [Viz.js - Graphviz in your browser](https://github.com/mdaines/viz-js) 

* [Viz.js - Online demo and playground](https://viz-js.com/)


## Tools

### Scratch Pad in a Web Browser

Enter this into your browser's address bar:

```
data:text/html, <html contenteditable> <head><title>MyScratchPad</title></head>
```

In Mozilla Firefox:  Bookmarks > Bookmark Current Tab

Enter a name for it, and click on Save.


### Writer - Distraction free writing tool in a Web Browser - By Marek Gibney

[https://github.com/no-gravity/writer](https://github.com/no-gravity/writer)

You can try it here: [https://www.gibney.org/writer](https://www.gibney.org/writer)

### Stopwatch - A minimalistic stopwatch - By Marek Gibney

[https://github.com/no-gravity/stopwatch](https://github.com/no-gravity/stopwatch)

Demo: [https://www.gibney.de/yeah_it_s_a_stopwatch](https://www.gibney.de/yeah_it_s_a_stopwatch)


### markdown-preview - Quick, temporary HTML preview of markdown text in your browser

[https://github.com/seanh/markdown-preview](https://github.com/seanh/markdown-preview)

> `markdown-preview` reads text from the primary X selection.
> `markdown-preview filename` reads text from a file.
> The text is passed through markdown, markdown's HTML output is written to a temporary file, then the temporary file is opened in your browser.
> Markdown's output is wrapped in the HTML template at `~/.markdown-preview-template.html`, `%m` in the template will will be replaced with markdown's output.
>
> Bind `markdown-preview` to a keyboard shortcut to get one-click preview of markdown text.
> Simply select the text you want to preview in your editor and hit your keyboard shortcut!

---

## Resources and References

* [I tried every todo app and ended up with a .txt file (al3rez.com) - Hacker News](https://news.ycombinator.com/item?id=44864134)

* [Show HN: Notes.cx – A simple, anonymous online notepad with Markdown support (notes.cx)](https://news.ycombinator.com/item?id=27994692)
>
> brightbeige:
> 
> You can use your browser as an offline (temporary) text editor, which I find useful with screen sharing.
> 
> Enter this into your browser's address bar:
>
> ```
> data:text/html, <html contenteditable>
> ```
>
> and with focus:
>
> ```
> data:text/html, <html style=" max-width: 64ch;margin: auto;font-size: calc(1rem + 1vw);line-height: 1.4;font-family: monospace;padding: calc(1rem + 4vw);"><body contenteditable><script>document.addEventListener("DOMContentLoaded", () => {document.body.focus()})</script>
> ```
>
> dugmartin:
> 
> I have this as a bookmarklet and I use it frequently when pairing for ephemeral notes:
> 
> ```
> data:text/html, <html contenteditable><head><title>ScratchPad</title><style>body{font-family:monospace}</style></head>
> ```
>
> I like having the title so I can see it in the tab and the font setting makes cutting/pasting code look better.

* [Awfice - the world smallest office suite](https://github.com/zserge/awfice)
> Awfice is a collection of tiny office suite apps:
>
> * a word processor, a spreadsheet, a drawing app and a presentation maker
> * each less than 1KB of plain JavaScript
> * each is literally just one line of code
> * packaged as data URLs, so you can use them right away, without downloading or installing
> * you can also use them offline
> * but they can't store their state, so whatever you type there would be lost on page refresh
> * which can be also sold as a "good for your privacy" feature
> * this project is only a half-joke, I actually use a few Awfice apps as quick scratchpads.
> * the only way to save your job is to save a HTML or send it to the printer/print to PDF.

* [Notepad - An offline capable Notepad PWA (Progressive Web App) - Source code on GitHub](https://github.com/amitmerchant1990/notepad)

* [Notepad - Online Demo - Offline capable](https://notepad.js.org/)

* [Klipped - a simple, privacy-oriented scratchpad - PWA (Progressive Web App)](https://klipped.app/)
> The minimalist plain text app for any device with a browser.
> 
> It's like the back of your hand.
> Write ideas down.
> Paste snippets of text.
> Delete when you're done.
>
> Klipped.app is a minimalist plain text scratchpad designed with privacy in mind.
> 
> All data is stored in local browser storage (local to your device), and has no adverts, profiling or tracking analytics.
> The simple plain text app.
> 
> It's a virtual post-it note.
> Store your ideas, or paste content from your clipboard.
> Delete the text when you're done.
> No clutter of files being saved, and no need to worry about saving your text - it will be there next time you open the app.
>
> Also available for iPad, iPhone and MacOS.
> See [klipped.com](https://klipped.com/) for more information.
 
* [My productivity app is a never-ending .txt file (2020) (jeffhuang.com) - Hacker News](https://news.ycombinator.com/item?id=46236037)

* [My productivity app is a never-ending .txt file](https://jeffhuang.com/productivity_text_file/)
> Over 14 years of todos recorded in text
> 
> * Record - *notes*, a *to do* list, a *what done* list
> * Email - a simple flagging system (e.g.: red - something to deal with, etc.) 
> * Daily routine
> 
> Tagging
>
> Shortcuts and Features:
> I use a consistent writing style so things are easily searchable, with a few shorthands.
> When I search for "meet with", it shows that I have had over 3,000 scheduled meetings.
> I have some tags like #idea for new ideas to revisit when I want project ideas, #annual for things to put on my next annual report, #nextui for things to add the next time I run my next UI course. 
> 
> I usually keep an empty line between tasks completed and upcoming tasks. When a task is completed, I move the empty line.
> Any leftover tasks from the current day can go back into the calendar for when I may want to tackle it again, but that is rare because tasks were already sized into what I can do on that day.
> I can calculate aggregate statistics using the search box, or list all the lines containing a tag, and other operations using my text editor.
> I use Ultraedit because I'm familiar with it, but any text editor would have similar capabilities. 
>
> [ . . . ]
> 
> So my **daily routine** looks like:
>
> 1. look at the daily todo list I wrote last night to find out what I'm doing today
> 2. do scheduled things on that list during the day
> 3. when I have free (unscheduled) time, do the floating tasks on my list and work on Red-flagged emails
> 
>     at the end of the day
> 
> 4. do a quick review of Orange/Yellow emails to see if they need any handling
> 5. copy the next day's calendar items to the bottom of the text file 
>
> This process has a few nice properties:
> 
> * It's easy to immediately see what to do when I wake up
> * I don't need to remember in my head the things to do later (following up on emails, future tasks)
> * It's easy to recall what happened in the past and see how much I can actually accomplish in a day
> * There's no running "todo" list with items that keep pushed back day after day
> * I use Remote Desktop so everything is accessible from every device 
>
> My daily workload is completely under my control the night before; whenever I feel overwhelmed with my long-term commitments, I reduce it by aggressively unflagging emails, removing items from my calendar that I am no longer excited about doing, and reducing how much work I assign myself in the future.
> 
> It does mean sometimes I miss some questions or don't pursue an interesting research question, but helps me maintain a manageable workload. 

* [Org-Mode Is One of the Most Reasonable Markup Languages to Use for Text - Hacker News](https://news.ycombinator.com/item?id=15321850)

* [How to Use Tags - Karl Voit](https://karl-voit.at/2022/01/29/How-to-Use-Tags/)

* [etmtk - Event and Task Manager in Tk](https://people.duke.edu/~dgraham/etmtk/)
> Manage events and tasks using simple text files.
>
> [Sample entries](https://people.duke.edu/~dgraham/etmtk/#sample-entries)
>
> Items in *etm* begin with a type character such as an asterisk (event) and continue on one or more lines either until the end of the file is reached or another line is found that begins with a type character.
> The beginning type character for each item is followed by the item summary and then, perhaps, by one or more `@key value` pairs.
> The order in which such pairs are entered does not matter.

* [etmtk - Event and Task Manager in Tk - Source code on GitHub](https://github.com/dagraham/etm-tk)

* [My simple, effective Org Mode setup - Karel Van Ooteghem](https://karelvo.com/posts/orgmode/)
> With comment:
>
> A nice, simple workflow.
> 
> Update:
> Karel now syncs it via Git, and [Plain Org](https://xenodium.com/plain-org-for-ios) for iPhone/iOS.
>
> 
> **Framework: DOOM Emacs**
>
> I (obviously) use [Emacs](https://www.gnu.org/software/emacs/) on my Linux workstation.
> Important note: as I never used it before, I did spend quite some time learning the ropes.
> 
> What really helped was the amazing [Doom Emacs](https://github.com/doomemacs/doomemacs) config and accompanying [evil mode (i.e. vi keybindings](https://github.com/emacs-evil/evil).
> That allegedly also saved me from [carpal tunnel syndrome](https://www.emacswiki.org/emacs/RepeatedStrainInjury).
> 
> I did not look into [Spacemacs](https://www.spacemacs.org/) or [NΛNO (Nano Emacs)](https://github.com/rougier/nano-emacs), which also get a lot of praise, but Doom just works for me.

* [Chemacs2 - Emacs version switcher, improved](https://github.com/plexus/chemacs2)

* [The Collector's Fallacy](https://zettelkasten.de/posts/collectors-fallacy/)

* [My Collector's Fallacy Confession](https://zettelkasten.de/posts/collectors-fallacy-confession/)

* [Stop Relying on a Source and Have Faith in Your own Thoughts](https://zettelkasten.de/posts/dont-rely-on-source-have-faith-in-yourself/)
> The desire to have all of the information of a text available made me collect files and papers and books: I had fallen for the [Collector's Fallacy](https://zettelkasten.de/posts/collectors-fallacy/).
> 
> Only later did I find out that this approach doesn't help at all.
> So I listened to other people's advice and began to take notes in my own voice, hoping it'd help.
> It did.
> Then, I learned why: because there's no way to simply pull out an author's intent.
> Through reading you have to make sense of things yourself, thereby creating information.
> 
> It's impossible to collect information by collecting original sources.
> Everything runs through our brain's filter and is subject to our interpretation.
>
> [ . . . ]
> 
> **Your own Voice Counts**
> 
> [ . . . ]
>
> **The Brain Filters Potential Information**
>
> [ . . . ]
> 
> **Texts by Themselves are Worthless - it's Your job to Create Information from a Source**
> 

* [Doom Emacs or Spacemacs? Use both with Chemacs2](https://www.youtube.com/watch?v=hHdM2wVM1PI)

* [Plain Org for iOS](https://xenodium.com/plain-org-for-ios)
> Why?
> 
> Org mode on Emacs is wonderful.
> I'm a big fan and use it regularly on my laptop.
> As an iPhone user, I wanted quick access to my org files while on the go... so I built Plain Org for iOS. 
>
> What is Org?
>
> [Org](https://orgmode.org/) is a powerful *plain text markup* similar to Markdown.
> It supports a wide range of features and is compatible with any text editor (Emacs, Vim, VSCode, etc.).

* [The Plain Text Project (plaintextproject.online) - Hacker News - Dec 2, 2019](https://news.ycombinator.com/item?id=21685660)
>
> bloak [on Dec 3, 2019](https://news.ycombinator.com/item?id=21691555):
> 
> Assume "plain text" means something like traditional printed text.
> This has three features which don't seem to be implemented on computers in a sensible standardised way:
> 
> * Spaces.
> In traditional printed text there is space between words but there are no leading spaces, double spaces or trailing spaces, so the ASCII space character is not an adequate representation.
> 
> * Paragraphs.
> In traditional printed text you can start a new paragraph but you can't have an empty paragraph so '\n' is not an adequate representation.
> Then there's the problem that some systems use '\r' or "\r\n" instead of '\n'.
> Then there's the problem that Emacs's "long lines" mode and Git's --word-diff don't work properly.
> (Almost certainly patch tools and "git rebase" don't work either.)
> 
> * Emphasis.
> In traditional printed text words and phrases can be printed in italics for emphasis.
> There are several ways this can be indicated in a computer file, but do editors and diff tools handle them nicely?
> I think not.
> Also, it's not completely clear how this should work.
> For example, I don't think <em></em> should be allowed, but are <em>a</em><em>b</em> and <em>ab</em> the same thing, or different things?
> You wouldn't be able to tell them apart in traditional printed text, but in traditional printed text you can't tell whether a space, a full stop or a dash is printed in italics, or not, either, so it's clear, I think, that we need to somewhat extend the concept of emphasis from what's available in print, but how far do you extend it?
> (What about nested emphasis?)
> 
> marcthe12 on Dec 3, 2019
> That I believe in stuff like Markdown. You usually need like 3 or 4 options.

* [Tags (Org Mode Compact Guide)](https://orgmode.org/guide/Tags.html#Tags)
> An excellent way to implement *labels* and *contexts* for *cross-correlating* information is to assign *tags* to headlines.
> Org mode has extensive support for tags.
> 
> *Every headline* can contain a *list of tags*; they occur at the *end* of the headline.
> Tags are normal words containing letters, numbers, ‘_’, ‘@’, ‘#’, and ‘%’.
> Tags *must* be *preceded* and *followed* by *a single colon*, e.g., ‘:work:’.
> *Several tags can be specified*, as in ‘:work:urgent:’.
> Tags by default are in **bold face** with the same color as the headline. 

* [Tagging #1 - Tony Ballantyne](https://tonyballantyne.com/2017/08/16/tagging-1/)
> A Simplified Tag System
> 
> It's possible to spend more time thinking of tags to apply to a note than it takes to write the note in the first place.
> One way around this is to adopt a standard system (there are many of these listed on the internet).
> I use a 1,2,3,4 system as follows:
>
> 1. What area of my life does the note refer to: Personal, Writing, Work, Tech?
> 2. What's the form of the note: idea, letter, reference, blog, interview?
> 3. What project does the note relate to: novel, how writers write, 99 java problems, emacs, six tips?
> 4. What's the note's GTD status: TODO, NEXT, DONE, WORKING?
>
> To give an example, the note this blog post is based on is tagged as follows:
>
> 1tech, 1writing, 2blog, 3onwriting, 3emacs, 4next
> 
> In other words, this note relates both to tech and writing, it's for my blog, it's to do with my onwriting and emacs projects, and it's marked next according to GTD.

* [Tagging #2: Applications that use Tagging](https://tonyballantyne.com/2017/08/23/tagging-2-applications-that-use-tagging/)

* [Tagging #3: My Tagging System](https://tonyballantyne.com/2017/10/14/tagging-3-my-tagging-system/)

* [Todos and Agenda Views - Tony Ballantyne Tech](https://tech.tonyballantyne.com/2022/05/12/todos-and-agenda-views/)
> On my original Emacs Writing Set Up I had this many states:
> 
> ```
> (setq org-todo-keywords
>     (quote ((sequence "TODO(t!)"  "NEXT(n!)" "|" "DONE(d!)")
>         (sequence "REPEAT(r)"  "WAIT(w!)"  "|"  "PAUSED(p@/!)" "CANCELLED(c@/!)" )
>         (sequence "IDEA(i!)" "MAYBE(y!)" "STAGED(s!)" "WORKING(k!)" "|" "USED(u!/@)"))))
> ```
> 
> Now I only have three: TODO, IN PROGRESS and DONE
>
> This is in line with my philosophy that productivity systems are great procrastinators.
> Thinking of new tagging systems and states for tasks is very absorbing.
> You can spend hours moving notes around and not doing any work.
>
> Now I [capture all my notes as TODOs](https://tech.tonyballantyne.com/2022/03/19/capturing-and-refiling-notes/), I change their state to IN PROGRESS and DONE as projects advance. 

* [Behind the Scenes of A Fire Upon the Deep - by Vernor Vinge - A Primitive Form of Story Documentation](https://3e.org/vvannot/0-READ-ME-FIRST.html) 
> Since 1979 I've used the convention that lines beginning with "^" should not normally be printed.
> This makes it easy for me to "comment my text".
> Over the years, as storage capacities increased, I found that even this extremely crude tactic could be very helpful in story development.
> About one fourth of my Fire Upon the Deep manuscript is such hidden commentary.
> These comments served a variety of purposes, and I used various tag words to discriminate between these purposes (see the table below).
> Besides formal tags, I had a large number of key words to identify different aspects of the story.
> I used various tools -- mainly `grep` -- to follow the key words around the manuscript.
> Note that this technique is not hypertext (... well, maybe it could be called a "manual form" of hypertext, with `grep` being used to dynamically compute links :-). 
>
> . . .
>
> Editor's Note: Read the file [exnotes.rtf](https://3e.org/vvannot/EXNOTES.html) to read details of the internal formatter notation used by the author.
> This notation was converted by our software to the final document you received, so it is not visible to you.
> 
> I use tags a lot.
> In a sense almost anything could become a tag (and a target for `grep`), but the most formalized tags and their meanings are as follows.
> (Clarinet has associated these tags with hypertext icons.) 
>
> ---- snip ----   
> CHK The comment involves something that I should verify.  
> CHRON A timestamp on the writing or reworking of this area.  
> DONE The action suggested in the comment has been done.   
> ---- snip ----   
> ID The comment is an idea related to this story.   
> IDEA The comment is an idea unrelated to this story.   
> ---- snip ----   

* [A Zoology of Annotations](https://3e.org/vvannot/EXNOTES.html)
> I delimit italicized text with underscores.
> (I don't have any page-long italicized passages, so any such are probably due to loss of "underscore-parity".)
> (The Clarinet edition supports italicized fonts, so this convention will probably be transparent to you.)
> Embedded comments have "^ " as the first non-whitespace on the line.
> Commands to my formatter (inherited from Kernighan and Plauger's Software Tools, Addison-Wesley, 1976!) use a similar convention:
> 
> ^bp page break   
> ^ls n linespacing   
> ^he s define page header   
> ^fo s define page footer  
> etc. 
>
> My formatter prints the pair ampersand numbersign ( "&# " ) as a single numbersign ( "# " ).
> Thus, I use "&#&#&#" as a section break.
> When a numbersign ( "#" ) is not preceded by an ampersand, it is supposed to be a single space.
> (I use this character to force vertical whitespace and as part of the indent for paragraphs.)
> Where the first alpha characters on a line are "NOTE", you are normally seeing a note to the copyeditor.
> (I use this mostly to flag the beginning of monospace font (eg, Courier) for the Net messages.) 

* [Designing better file organization around tags, not hierarchies](https://www.nayuki.io/page/designing-better-file-organization-around-tags-not-hierarchies)

* [TagSpaces - Organize your files and folders with tags](https://www.tagspaces.org/)
> A powerful, file-based workspace - no cloud required.
> Organize your digital life - privately.
> Files, tags, notes, tasks, maps and kanban boards, all in one place.

* [TagSpaces - on GitHub](https://github.com/tagspaces/tagspaces)
> TagSpaces is an offline, open source, document manager with tagging support.

* [Structuring and Formatting Your Plain Text Files (Without a Markup Language)](https://plaintextproject.online/articles/2020/04/14/structure.html)

* [Typographic and formatting conventions for plain text](https://graphicdesign.stackexchange.com/questions/74940/typographic-and-formatting-conventions-for-plain-text)

* [The origins of XXX as FIXME](https://www.snellman.net/blog/archive/2017-04-17-xxx-fixme/)

* [ Package of troff macros that first appeared in 2BSD, with a copyright date of 1978 - Lines with XXX appearing in them](https://github.com/dspinellis/unix-history-repo/commit/b41454192b6489951f36873ca3a792e9b1a73c92)
> ```
> ..
> .de (t			\" XXX temp ref to (z
> .(z \\$1 \\$2
> ..
> .de )t			\" XXX temp ref to )t
> .)z \\$1 \\$2
> ..
> ```

* [first listing - dspinellis/unix-history-repo@9e295a2 - GitHub -- the first /* XXX */ commit from Nov 9, 1981](https://github.com/dspinellis/unix-history-repo/commit/9e295a2f65c046125ece0ad68f142f59df4c3400)

* [Key words for use in RFCs to Indicate Requirement Levels](https://www.ietf.org/rfc/rfc2119.txt)
> ``` 
> Abstract
> 
>    In many standards track documents several words are used to signify
>    the requirements in the specification.  These words are often
>    capitalized.  This document defines these words as they should be
>    interpreted in IETF documents.  Authors who follow these guidelines
>    should incorporate this phrase near the beginning of their document:
> 
>       The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
>       NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and
>       "OPTIONAL" in this document are to be interpreted as described in
>       RFC 2119.
> 
>    Note that the force of these words is modified by the requirement
>    level of the document in which they are used.
> ```

* [UNIX for Beginners - Bell Labs Technical Memorandum 74-1273-18 by Brian W. Kernighan published ond October 29, 1974](https://web.archive.org/web/20130108163017if_/http://miffy.tom-yam.or.jp:80/2238/ref/beg.pdf)
> *Start each sentence on a new line.*

* [Semantic Line Breaks Specification (SemBr)](https://sembr.org/)

* [Semantic Linefeeds](https://rhodesmill.org/brandon/2012/one-sentence-per-line/)

* [semantic-linebreaker - Web-based utility to help applying semantic linebreaks to any text](https://github.com/waldyrious/semantic-linebreaker)

* [Try semantic-linebreaker here](https://waldyrious.net/semantic-linebreaker/)

* [How to format man pages - aka How should a formatted man page look?](https://tldp.org/HOWTO/Man-Page/q3.html)

* [Don't Make a Blog, Make a Brain Dump](https://btxx.org/posts/dump/)

* [Plain Text Journaling](https://oppi.li/posts/plain_text_journaling/)
> I cobbled together a journaling system with {neo,}vim, coreutils and dateutils.
> This system is loosely based on Ryder Caroll's Bullet Journal method.

* [ADHD Productivity Fundamentals](https://0xff.nu/adhd-productivity-fundamentals/)
> * Write Everything Down
> * Use Lists
> * Schedule It
> * Use the Proper Tool for the Job
> * Simplify
>   * Remove clutter - Something not getting used and won't be used? Get rid of it.
>   * Reduce choice - You most likely don't need ten different ways (or apps) to do the same thing.
>   * Remove noise - Remove things (apps/objects) that maliciously fight for your attention.

* [How I use minimalism to help with my ADHD](https://jennhasadhd.com/2021/08/01/how-i-use-minimalism-to-help-with-my-adhd/)

* [journ - command-line journal - EvanHahn](https://github.com/EvanHahn/journ)

* [Living in a Single Text File](https://www.williamhern.com/living-in-a-single-text-file.html)

* [Geek to Live: Reader-written todo.txt manager - by Gina Trapani - archived on 2006-07-01](https://web.archive.org/web/20060701121920/https://lifehacker.com/software/top/geek-to-live--readerwritten-todotxt-manager-173018.php)

* [Todo.txt File - Document known conventions for key:value - aka Known conventions for key:value](https://github.com/too-much-todotxt/spec/issues/23)

* [How I Organize My Todo.txt File - Plaintext Productivity](https://plaintext-productivity.net/1-03-how-i-organize-my-todo-txt-file.html)
> I think a successful adoption of Todo.txt depends not only on the software implementations you choose, but also on how well you use the features the Todo.txt file format offers you.
> Todo.txt allows you to organize your tasks using **projects** ("+ProjectName"), **priorities** (A-Z), and **contexts** ("@Context").
>
> I did not like using Todo.txt until I set a few rules for myself as to how I would use those three features.
> Once I set these rules for myself - especially how I would use priorities - Todo.txt went from being a nice idea to the most quick and powerful to-do organizer I ever used.

* [Todo.txt More: Efficiently managing your todo list and your time](https://proycon.anaproy.nl/posts/todo/)
> Todo.txt has a simple tag syntax, tags starting with + are projects, tags starting with @ indicate contexts, and I add # for other kinds of tags (hashtags).
> 
> [ . . . ]
>
> todo.txt-more adds hashtags (starting with #) and will colour them differently (todo.sh format), context (@) and projects (+) will also get a distinctive colour.

* [todotxt-more - Extensions for todo.txt: interactive rofi/fzf control, sync github issues, better colors, time tracking... and more! - on sourcehut git](https://git.sr.ht/~proycon/todotxt-more)
> todo.txt-more adds hashtags (starting with #) and will colour them differently (todo.sh format), context (@) and projects (+) will also get a distinctive colour.

* [Getting Organized with Todo.txt](https://ronaldsvilcins.com/2024/03/15/getting-organized-with-todo-txt/)
> **Make it Yours**
> 
> The best part is how I can change Todo.txt to fit how I work.
> There are tons of add-ons made by other Todo.txt fans that do awesome things!
>
> [ . . . ]
> 
> My Todo.txt Journey
>
> * The File: I started by making a “todo.txt” file in a text editor.
> * **Baby Steps**: I added simple tasks, just to get the hang of it.
> * Exploring Tools: Then I tried a Todo.txt app on my phone – it was even easier!
> * Leveling Up: Now I experiment with little add-ons to make my system even better.
>
> Transform Your To-Do List
>
> If you're tired of complicated task managers, Todo.txt might be just what you need.
> It helped me get focused, and I bet it can do the same for you!

* [awesome-todo.txt - awesome todo.txt related projects, tools, and articles](https://github.com/too-much-todotxt/awesome-todo.txt) 

* [todoreport - tool that reads Todo.txt files and displays them, grouped and sorted as specified on the command line](https://git.sr.ht/~sschwarzer/todo-txt/tree/main/item/README.md)
 
* [TodoTxtJs - A Typescript/Javascript web app implementation of TodoTxt](https://github.com/MartinSGill/TodoTxtJs)

* [TodoTxtJs - Live Demo](http://todo.martinsgill.co.uk/)

* [My Todo.txt Workflow, including Unison, Todour and Android](https://raymii.org/s/articles/My_Todo.txt_Workflow.html)

* [task file - Fernando Serboncini](https://fserb.com/write/code/task/)
> There are a few common things I end up doing in all my projects, independent of the programming language I use.
> One of them is a *text file* with *notes, TODOs, and design ideas*.
> The other is a `task` file.
>
> A `task` file is shell script with a *collection of commands* that I use to build, test, sync and do whatever else is needed for the project.
> Think of it as a mix of an annotated bash history of the project and a *Makefile*.
>
> [ . . . ]
> 
> *Final thoughts*
> 
> `task` has completely changed how I self-document my projects.
> Doing a quick search on my computer, there are 43 task files.
> It makes it easier for me to go back to projects that I haven't touched in a while.
> 
> More importantly, it's extremely lightweight, it has no external dependencies, and it's fairly accessible to anyone that knows a bit of bash.

* [Task Files](https://quexxon.net/articles/task-files/)
> Task Files - Quexxon-12
>
> In a recent chat with Andy Chu, creator of [Oils](https://oils.pub/), he mentioned his use of "task files" for most shell usage.
> I hadn't encountered that term before.
> The concept is simple - you type a set of shell functions in a single file and make them invocable interactively.
> Here's a simple example:
> 
> ``` 
> #!/bin/sh
> # tasks.sh
> 
> run_tests() {
>   # ...
> }
> 
> build() {
>   # ...
> }
> 
> deploy() {
>   # ...
> }
> 
> "$@"
> ``` 
> 
> To invoke the `build` command, for example, run `./tasks.sh` build. [*] 
> 
> Task files are a useful pattern which has been broadly documented (a web search for *task files* will surface numerous references going back many years), but the technique is new to me, and that means it will be new to others as well.
> So I'd like to record my initial perspectives and lessons learned - which might be better conceived as a set of aspirations.
> I'll also share some work-in-progress tooling to facilitate documentation and discoverability of tasks.
>
> [ . . . ]
>
> [ . . . ]
>
> Anecdotally, a coworker was recently tasked with combing through a large dataset to find all unique instances of a value.
> They were going to search through each file by hand!
> They didn't know that `find . -type f -name '*.json' -print0 | xargs -0 -- jq .someValue | sort | uniq` was an option.
> In the few seconds that it took to type and copy/paste the command, my coworker was spared hours(?) of tedious, error-prone, and unnecessary drudgery.
> It's okay to not know something - it's not okay to know and not share it.
> This is not to suggest that the time-saving tool would have existed prior to the need for it but rather that task files can be mechanism for building a culture of knowledge sharing (e.g., a known, living collection of data analysis tools).
> 
> [ . . . ]
> 
> Footnote:
> [*] If you're new to shell scripting, the last line of the script is the key.
> 
> The special variable $@ expands to the positional parameters provided by the user when the script is executed.
> 
> The surrounding double quotes are critical to prevent [field splitting](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_19_06_05) (also known as word splitting).
> 
> By passing a function name as the first positional parameter, we can effectively invoke the function from the outside.

* [One year of keeping a tada list (ducktyped.org) - Hacker News](https://news.ycombinator.com/item?id=46354282)

* [One year of keeping a tada list - Sometimes called a to-done list](https://www.ducktyped.org/p/one-year-of-keeping-a-tada-list)

* [Managing tasks with Org mode and iCalendar - lwn.net guest article](https://lwn.net/Articles/825837/)

* [[x]it! - A plain-text file format for todos and check lists](https://xit.jotaen.net/)

* [[x]it! - Syntax Guide](https://xit.jotaen.net/syntax-guide)

* [[x]it! - The Specification](https://github.com/jotaen/xit/blob/main/Specification.md)

* [[x]it! - on Hacker News - Show HN: A plain-text file format for todos and check lists](https://news.ycombinator.com/item?id=30879327)

* [Margin - Lightweight markup designed for an open mind]
> The plain text language for list-making, note-taking, and to-dos.
> Thinkers determine their own organizational models.
> Infinitely extensible, inherently readable.

* [Tools for plain-text thinking - archived on 2021-10-19](https://web.archive.org/web/20211019141725/https://short.therealadam.com/2020/05/12/tools-for-plaintext.html)
> The mark of a nicely designed plain text format is that it works equally well in a well-crafted app, a text editor, and on a sheet of paper.
> Margin meets that criteria.

* [Margin - Source code on GitHub](https://github.com/gamburg/margin)

* [Try out Margin](https://margin.love/parser/)

* [Learn Margin](https://margin.love/#/?id=philosophy)

* [nb - a command line and local web note-taking, bookmarking, archiving, and knowledge base application](https://xwmx.github.io/nb/)
> nb creates notes in text-based formats like Markdown, Org, LaTeX, and AsciiDoc, can work with files in any format, can import and export notes to many document formats, and can create private, password-protected encrypted notes and bookmarks.
> With nb, you can write notes using Vim, Emacs, VS Code, Sublime Text, and any other text editor you like, as well as terminal and GUI web browsers.
> nb works in any standard Linux / Unix environment, including macOS and Windows via WSL, MSYS, and Cygwin.
> Optional dependencies can be installed to enhance functionality, but nb works great without them.
>
> [ . . . ]
> 
> nb uses Git in the background to automatically record changes and sync notebooks with remote repositories.
> nb can also be configured to sync notebooks using a general purpose syncing utility like Dropbox so notes can be edited in other apps on any device.

* [nb - Source code on GitHub - CLI and local web plain text note-taking, bookmarking, and archiving with linking, tagging, filtering, search, Git versioning & syncing, Pandoc conversion, + more, in a single portable script](https://github.com/xwmx/nb)

* [clikan - a super simple personal kanban board that runs in a CLI](https://github.com/kitplummer/clikan)

* [Ephe - Ephemeral Markdown Paper](https://github.com/unvalley/ephe)
> An Ephemeral Markdown Paper for today. Less but handy features for plain Markdown lovers]
> 
> Traditional todo apps can be overwhelming.
> Ephe is designed to organize your tasks with plain Markdown.
> Ephe gives you just one clean page to focus your day.

* [Ephe guide](https://github.com/unvalley/ephe/blob/main/.github/guide.md) 

* [Ephe - Online Demo](https://ephe.app/landing)

* [MDwiki - 100% static single file CMS/Wiki done purely with client-side Javascript and HTML5](https://github.com/Dynalon/mdwiki) 
> CMS/Wiki system using Javascript for 100% client side single page application using Markdown. 

* [MDwiki - more info and documentation](http://www.mdwiki.info/)

* [Text2MindMap - Online tool for making mindmaps by writing indented lists](https://github.com/tobloef/text2mindmap)

* [Text2MindMap - Online Demo](tobloef.com/text2mindmap/)

* [Markant - An online Markdown editor](https://github.com/tobloef/markant)

* [Markant - Online Demo](https://tobloef.com/markant/)

* [bigpicture.js - a Javascript library that allows infinite panning and infinite zooming in HTML pages](https://github.com/josephernest/bigpicture.js)
>
> [Live demo](https://josephernest.github.io/bigpicture.js/index.html)
> 
> "What is BigPicture?
>
> BigPicture is like an infinite notepad, in which you can pan (north/south/east/west), but also in which you can ZOOM ! (Nearly) infinitely many times.
>
> USAGE  
> #####   
> Search: F3 or CTRL+F  
> Pan: click and drag  
> Move text: CTRL+click and drag  
> Zoom In : PageDown  or CTRL+ or mousewheel or double-click  
> Zoom Out: PageUp  or CTRL- or mousewheel or CTRL+double-click  
> Biggest picture: F2 (try it twice!)  
> Easy write in one click: click anywhere and write!  
> No need to go into a Toolbox and choose to create a new Textbox... Just click anywhere and write!  
> Don't forget to zoom out... to see the BigPicture"  
>
> [Tutorial](https://josephernest.github.io/bigpicture.js/bigpicture-tutorial.html)
>
> Here is the bigger project: [https://bigpictu.re/demo](https://bigpictu.re/demo)
>
> A collaborative version - Collaborative **whiteboard** based on bigpicture.js: [github.com/josephernest/AReallyBigPage](https://github.com/josephernest/AReallyBigPage)

* [A template to organize life in plain text files - Plain Text Life project](https://github.com/jukil/plain-text-life)
> Welcome to the Plain Text Life project.
> This project consists of only two elements:
> 
> 1. The README you are reading right now,
> 2. The [today.txt](https://github.com/jukil/plain-text-life/blob/master/today.txt) template that assists you organising your everyday life in plain text files.
> Create one copy of [today.txt](https://github.com/jukil/plain-text-life/blob/master/today.txt) for each day and use it as your journal/diary, to set your goal of today, to structure your morning, get done with your chores as quickly as possible, and to spend free time on the things you love.
> 
> This template keeps your life structured in an easy to manage system and thereby frees up time and mental capacity for the things that really matter in life such as relationships and personal growth.
> By using this template, you can de-clutter your life from using countless apps, and systems.
> Instead you can choose to use plain text files that will always work, will always remain readable by any computer and thus never become inaccessible.
> 
> [ . . . ]
> 
> **Working with your plain text files**   
> Start a software that indexes all your plain text files.
> On Linux I recommend [Recoll](https://www.recoll.org/pages/download.html).
> Search for keywords or tags that you remember and quickly find the right file you were looking for.

* [If you do this and only this, today will be a good day](https://johnhenrymuller.com/today)
> A new approach
> 
> At the beginning of this year I tried something new.
> It's a simple idea. But so far, it is working.
>
> The very first thing each morning (after coffee but before email) I write three sentences in plain text then save this document to my desktop.
> I call it today.txt.
>
> It is the only file I keep on my desktop to ensure it stays in my purview.
> The format is simple and looks something like this ...
>
> ```
> If nothing else, today I am going to ___________.
> 
> I am going to do this by ______ then _____ then ______.
> 
> If I do this and only this, today will be a good day.
> ```

* [notes - nickjj - A zero dependency POSIX compliant shell script that makes it really simple to manage your text notes](https://github.com/nickjj/notes/)
> Instead of trying to impose a whole bunch of rules and syntax requirements, this tool does its best to get out of your way.
> 
> It tries to do everything possible so that if you're working in a terminal, you can save whatever text you want into a file.
> This could come from typing a sentence out, pasting something from your clipboard or saving the output of a program.

* [notes - nickjj - actual script ](https://github.com/nickjj/notes/blob/master/notes)

* [Plan (.plan) files by John Carmack](https://github.com/ESWAT/john-carmack-plan-archive) 
> Mirror of the John Carmack .plan Archive on [floodyberry.com](http://floodyberry.com/carmack/plan.html).
> These are the exports of ZIP files for his .plan files, organized by day and year.

* [.plan - A personal notebook - By Steve Losh](https://hg.stevelosh.com/.plan/)
>This is my personal notebook where I dump thoughts and notes for my future self.

For more about *.plan files*, see the man page for:

* [finger(1) -- user information lookup program](https://man.freebsd.org/cgi/man.cgi?query=finger&apropos=0&sektion=0&manpath=FreeBSD+15.0-RELEASE+and+Ports&arch=default&format=html)

* [FreeBSD man pages (FreeBSD Manual Pages)](https://man.freebsd.org/cgi/man.cgi)

* [diaryman - Lazy (wo)man's CLI diary manager](https://github.com/Aperocky/diaryman)
> Diary Manager for lazy software engineers who use vim.
> 
> `diaryman` automatically creates a file in specified diary directory if it doesn't exist: `$DIARY_DIR/$year/$month/$day.md` and opens it with vim in edit mode.
> If the file already exist, it will just open it, this allow multiple edits throughout the day.
>
>It also allow you to make up for diaries missed by appending a date behind the diary, e.g. `diary 2020-01-01` will open the diary on that date.

* [A Plain Text Personal Organizer](https://web.archive.org/web/20120205111929/http://danlucraft.com/blog/2008/04/plain-text-organizer/)
> 01 April 2008 - Daniel Lucraft
>
> The 'One Big Text File' (OBTF) meme went around the internet a few years ago.
> The idea is you record all your notes, ideas, contacts and diary entries in one mammoth text file.
> The virtue is simplicity, but there are many drawbacks.
>In this article I show how to avoid those drawbacks by running your entire life out of *'One Big Text Directory'*.
> 
> [ . . . ]
>
> **New Plan**
>
> My plan:
>   * add version control,
>   * move to a directory structure.   
>   
> This solves all the problems of synchronization and backups in one go.
> You can keep as many files as you like with no problems and there is a complete history of your files which is essential if you are a packrat like me.
> 
> I have a copy of this repo on four machines: my server at Slicehost, my work machine, my home desktop and my laptop.
> I don't have to worry about merging because git takes care of it almost automatically.
>
> [ . . . ]
> 
> The Organizer Structure
> 
> Once the version control repositories were set up, the directory has to be laid out into a structure that contains everything you would put in a personal organizer.
> 
> And I do mean *everything*.
> I don't want to have any residual paper organizers or use any form of software where I cannot conveniently archive my data.
> This really does have to be a monolithic, *complete* system.
> 
> Note that I do keep one of those achingly hip Moleskine notebooks in my pocket for when I am not near a computer.
> This is the only paper organizer I have and everything in it gets transcribed into this organizer **as soon as I have a chance**.
> 
> [ . . . ]
> 
> **Projects**
> 
> Each file in this directory contains my notes about a project.
> A project must be fairly involved to get in here, otherwise I just keep a small set of notes in stacks/projects.
> 
> The files have a rough formatting style, but I let them vary.
> Each one contains a what, why, when, how section that helps me work out why I am doing the project.
> They may also contain plan, todo, ideas and log sections if warranted.
> My Phd project had all of these (when I was still studying).
>
> **The Database**
> 
> The db directory is my Wiki.
> Each entry has its own file, named in CamelCase.
> I've got my address book, phone numbers, web links, wish lists, favourite quotes, software tips, recipes and more in here.
> 
> At the moment there is no tool for automatically linking between files, but I expect one day (as it becomes larger) to write a small server for attractively displaying the files as HTML.
> I am trying to use Markdown for all my entries in here in preparation for that.
> 
> **The Checklists and Tools Directories**
> 
> The checklists directory contains a couple of checklists for different situations.
> The daily checklist is my scaffold for daily working, the weekly checklist reminds me to create next actions for all my projects and review the week ahead and so on.
> 
> The tools directory contains any tools relevant to working in this repository.
> For instance there is a script for setting up aliases that make searching my address book easy.
>
> [ . . . ]
> 
> **Drawbacks**
> 
> . . . 
> 
> * You might think there's quite a lot to keep track of.
> But I'm not religious about it, and I don't have to update this every day.
> Each file is so simple that it takes only five minutes to work through my checklist and update my logs etc. 

* [Reducing Friction in Your Todo Lists](https://web.archive.org/web/20101019070824/http://www.celsius1414.com/reducing_friction)
> Here's a brief outline on how it all fit together.
> 
> * All todo items get funneled to this file.
> * Someday+Maybe gets its own .txt file.
> * Waiting items are prefixed with zzz so they both stand out visually and sort to the bottom, out of the way.
> * Date-sensitive items get initial date (a la 08-16) in todo.txt along with todos or events in iCal.
> * iCal items have alarms attached, most of which are set to go off at 7AM the day of, so that I get a list first thing in the morning, but not the constant interruption all day.
> * Email, RSS, and IM notifications are turned off, both popups and sound as possible; new items are noticed whenever Dock is revealed or command-tab app-switching occurs, or when I have a moment to spare -- in other words when I'm available.
> * Dock is hidden; keyboard app-switching and document opening as much as possible (using combination of Quicksilver and Tiger Spotlight).
> * Most programs are hidden out of the way until needed and brought to the fore by a Quicksilver-issued command.
> * Carrying an HPDA for various uses (including reference), but mostly for todo items and notes that are funneled into the master todo.txt at the earliest convenience.
> * Meeting and project notes I'm still putting into VoodooPad.
> * Grayed out the interface as much as possible to reduce visual noise -- important items in color and current work stand out much better.
>
> The idea here is to reduce friction - getting items into and out of the queue as easily as possible.
> I have a bunch of different tools (Terminal, TextWrangler, Quicksilver, etc.) to put info in and to manipulate it once it's there.
> 
> Thanks to the fuzzy nature of the tagging, I can randomly access all of my, for example, cooking todos with a simple keyword search for "cooking" - without worrying about navigating to a particular section of an outliner document, or trying to remember if my todo item to buy a salad spinner is in "to_buy.txt" file or "cooking.oo3" or "personal.xls".
> Like Spotlight, this is not a permanent hierarchical system requiring rigid maintenance and adherence.
> It is random-access, with both flexibility and solidity as need be.

* [vimliner - The simplest outliner for VIM](https://github.com/rogerkeays/vimliner)

* [Vimliner: The Smallest, Fastest Outliner for VIM](https://rogerkeays.com/vimliner)
> 
> ... a single-file script to turn Vim into a fast and simple outliner.
> It is fully functional, and is only 21 lines of code.
> 
> You just use <TAB> to open and close the folds, and navigate through your outline.

* [Vimliner - Vimliner Outliner on vim.org - Scripts: The smallest, fastest outliner for vim - One file install](https://www.vim.org/scripts/script.php?script_id=5343)

* [Vimjournal - A simple text format and utilities for organising large amounts of information](https://github.com/rogerkeays/vimjournal)
> *Vimjournal* is a simple text format and utilities for organising large amounts of information.
> Although you can use any text editor with *vimjournal*, it provides syntax highlighting and shortcut keys for VIM to make editing logs easier.
> 
> A vimjournal log is an append-only text file normally ending in .log.
> 
> There are two types: *compact* and *expanded*.
> 
> Compact logs contain *one record per line*.
> For example, a time log:
> 
> ```
> 20200709_1423 =| remove use of unsafe reflection: --add-opens is better /code =jamaica @lao-home:thakhek
> 20200709_1555 -| debug jshell compatibility problems: broken state /debug =jamaica @lao-home:thakhek
> 20200709_1624 =| update known issues: jshell, shell parameters /write =jamaica @lao-home:thakhek
> 20200709_1650 =| run unchecked test builds: all passed /test =jamaica @lao-home:thakhek
> 20200709_1856 +| run along the river /run @riverside:thakhek
> 20200709_1945 -| look for my lost plastic waterbottle: left it at the riverside mamak /hunt /walk @riverside:thakhek
> ```
>
> Expanded logs have *unstructured text* after the *record header*.
> For example, a code snippets log:
> 
> ```
> 20200603_1337 -| create a virtual property in kotlin /kotlin >sorting by rating =vimjournal @lobby
> 
> // behaves as a function
> class X {
>     val priority: Int
>         get() { 1 }
> }
> 
> 20200605_1740 =| calculate a modulus in bash /bash >sorting flashcards @lobby
> 
> i=21
> echo $((i % 5))   # 1
> 
> 20200617_1054 +| mount iso image /linux >downloading dos games =library @lobby
> 
> mount -o loop -t iso9660 ./MyImage.iso /tmp/disk/
> ```
>
> [ . . . ]
>
> **Log Format**
> 
> The basic format of the records are:
> 
> ```
> YYYYMMDD_HHMM [value]| [title] [tags]
> [content]
> ```
> 
> The **start** of a new record indicates the **end** of the last one.

* [vimoutliner - Work fast, think well](https://github.com/vimoutliner/vimoutliner)
> VimOutliner is an outline processor with many of the same features as Grandview, More, Thinktank, Ecco, etc.
> Features include tree expand/collapse, tree promotion/demotion, level sensitive colors, interoutline linking, and body text.
>
> [ . . . ]
> 
> **Usage**
> 
> VimOutliner has been reported to help with the following tasks:
> 
> ```
> - Project management
> - Password wallet
> - To-do lists
> - Account and cash book
> - 'Plot device' for writing novels
> - Inventory control
> - Hierarchical database
> - Web site management
> ```

* [txt2tags - ONE source, MULTI targets](https://txt2tags.org/)
* [Markup & Markdown Madness!](https://markupmadness.github.io/)
* [Journal.TXT - Single-Text File Journals - The Human Multi-Document Format for Writers - Write your journal in a single-text file](https://journaltxt.github.io/)
* [journal - journaling system cobbled together with nix, vim, coreutils - oppi.li](https://tangled.org/oppi.li/journal)
* [pim.pl - The PIM script enables you to keep a contact list, your calendar, a word list, notebook, and a quote database using freely available programs](https://web.archive.org/web/20061021062215/http://www.macdevcenter.com/mac/2004/07/06/examples/pim.pl)
> The script pim.pl is a simple example of how you can combine these tools (the remind(1) program, PostScript, Perl) to create a useful program.
> The PIM script (pim.pl) enables you to keep a contact list, your calendar, a word list, notebook, and a quote database using freely available programs.
>
> To run the program, download the script, `cd` to the directory that holds the script, edit the constants at the top of the file, and type:
>
> ```
> % perl pim.pl 
> ```

* [Remind - A Sophisticated Reminder Service - Unix Gems for Mac OS X - Page 2 of 4](https://web.archive.org/web/20160423232804/http://www.macdevcenter.com/pub/a/mac/2004/07/06/unix_gems.html?page=2)

* [Remind - A Sophisticated Reminder Service - Unix Gems for Mac OS X - Page 3 of 4](https://web.archive.org/web/20071218190210/http://www.macdevcenter.com/pub/a/mac/2004/07/06/unix_gems.html?page=3)

* [txt-agenda - A POSIX compliant shell script for tracking dates and deadlines in text files](https://github.com/shushcat/txt-agenda)

* [my project schedule](https://tex.stackexchange.com/questions/579648/my-project-schedule)

* [revisit - a TODO list for the future](https://github.com/leahneukirchen/revisit)
> Many "Getting Things Done"-related systems have a review phase where you look at all the open tasks and decide whether they are still relevant.
> However, if you work on many projects, a fixed review interval can be limiting, especially if tasks are spread out across a more wide timeframe (e.g. quarterly software releases or gardening projects).
>
> Further, these future tasks often don't have a fixed deadline, so putting them into a calendar creates clutter and makes regular rescheduling difficult.
> 
> To not forget these future tasks, I wrote a little tool called revisit.
> It does a very simple thing: it searches the files passed for time intervals in a format specified below and shows the intervals that have passed.
You can then decide to review these tasks, and if they are meant to be repeated in the future, reschedule them easily starting from today.
> `revisit` will show all lines past their interval, and also by how many days they are delayed, so you can easily focus on the tasks that need most attention right now.
 

See also - Related to shell scripting and using UNIX tools:

* [Note Taking in 2021 (dornea.nu) - Hacker News](https://news.ycombinator.com/item?id=27513008):
Comment by gofreddygo on [June 17, 2021](https://news.ycombinator.com/item?id=27536377):
> 
> When not near a keyboard, use paper.
> When near one, use plain text.
> 
> For your sanity, keep *metadata* embedded in each file.
> I keep `k:v` pairs.
> One per line. e.g "topic: D3", "subject: scales", "context: Side Project".
> 
> Use `grep`, `awk`.
> Slice, group, dice, join, merge, backup as and how you want.
> A bash-like shell is the only dependency.
> Check into git regularly.
> 
> Some scripts I use:
>
> ```
> ## group by topic. search for lines that start with "topic". print topic and the file name
> grep -i "^topic" *.txt | awk -F ":" '{printf "%-25s%s\n",$3,$1}' | sort
> 
> ## find all files containing the "topic" tag 
> grep -i "^topic" *.txt | awk -F ":" '{printf "%-25s%s\n",$3,$1}' | sort 
> 
> ## find all files NOT containing "topic". useful for cleaning up 
> grep -iL "^topic" *.txt
> 
> ## find first 10 files not containing "topic" and open each in vi sequentially
> for f in $(grep -ilL "^topic" *.txt | head); do vi $f; done
> ```

* [Notetime: Minimalistic notes where everything is timestamped (notetimeapp.com) - Hacker News](https://news.ycombinator.com/item?id=43434152)
> Check comments.

* [Ask HN: Favorite note-taking software? - Hacker News](https://news.ycombinator.com/item?id=17532094)
> Check comments.

* [t - simple notes manager](http://www.git.stargrave.org/?p=t.git;a=blob;f=t)






* [PTPL (Plain Text; Paper, Less) - Ellane W](https://ellanew.com/)
> Future-proof knowledge management and productivity through intentional, responsible use of digital and analog tools.

* [This Is Why You Might Want to Keep Multiple Daily Notes as Well as an OBTF](https://ellanew.com/2025/03/10/ptpl-147-multiple-daily-notes-and-obtf)

* [I'm Using One Big Text File in Obsidian as a Digital Bullet Journal](https://www.blog.plaintextpaperless.com/p/ptpl091-from-bullet-journal-to-one-big-text-file)
> I've been applying Bullet Journal principles, marking each entry with one of the following (ignore the actual bullets at the start of each line):
>
> * N. This is a note; something I want to remember
> * T. This is a task; something I want to do in the future
> * E. This is an event; something that happened today
>
> [ . . . ]
> 
> Here are some additional bullets (once again, ignore the actual bullets at the start of each line):
> 
> * C. This is a communication note, like an email, social media post, text message
> * R. This is a reference note, like the hex code for non-repro blue #a4dded
> * -> This task or note has been migrated to somewhere else; eg. paper notebook, task manager, its own file
> * <. An event that's been scheduled into my paper future log, or digital calendar
> * X. This task has been completed
> * xx. This task is now irrelevant
>
> Another reason for placing a period after bullets is to make it easier to search for specific note types.
> I don't type in capitals, so I'm rarely if ever going to find N. used for anything other than a bullet. 
>
> I'd wanted to use > instead of an arrow -> for migrated entries, but that one's already taken by Markdown.
> Rather than escaping it as/>, which requires typing an extra symbol anyway, I settled on the arrow.
> Setting up text replacement on the iPhone keyboard has made it fast to type.

* [Classifying Notes in an OBTF, Inspired By the Dash-Plus System](https://ellanew.com/2024/11/18/ptpl-31-classifying-obtf-notes-dash-plus-inspired)
> 
> Key
>
> ```
> - [ ] Task, incomplete  
> - [x] Task, complete  
> -> Forwarded
> <- Delegated
> - Note
> /c. Communication
> /e. Event
> /f. French
> /i. Idea
> /j. Journal entry
> /r. Reference
> /w. Waiting
> /x. No longer relevant
> ```

* [Ellane W - Linktree](https://linktr.ee/miscellaneplans)

* [Ellane W - Grab some productivity freebies](https://link.eandrpublications.com.au/gumroad)

* [Ellane W - PKM.social - a Mastodon instance that is open to anyone who is interested in PKM (Personal Knowledge Management)](https://pkm.social/@ellane/)

* [Ellane W - PKM.social - I am renaming my One Big Text File. It’s no longer an #OBTF, it's a One Note Inbox.](https://pkm.social/@ellane/115607409551791270)
> I am renaming my One Big Text File.
> It's no longer an #OBTF, it's a One Note Inbox.
> #1N Much more descriptive of how I actually use it, and it fits in nicely with my One Page Notebook. 

* [One big text file](https://derctuo.github.io/notes/one-big-text-file.html)
> Here's an interesting idea for how to do Derctuo: a giant WYSIWYG document whose source format is a plain text file including data, code, text, and formatting in a single document, potentially of 128 mebibytes or more; but with computational output rigidly segregated to a cache management system.

* [The append-and-review note](https://karpathy.bearblog.dev/the-append-and-review-note/)
> When I note something down, I feel that I can immediately move on, wipe my working memory, and focus fully on something else at that time.
> I have confidence that I'll be able to revisit that idea later during review and process it when I have more time.

* [Here's an Elephant to Help You Find "Good Enough" When Everything Feels Too Much - Ellane W - Plain Text. Paper, Less.](https://ellanew.com/2025/12/22/ptpl-187-good-enough-plain-text-elephant)
> On personal manifestos and plain text systems that don't punish you.
>
> I'm going to share with you one idea and one link that can help you figure out what "good enough" can look like when your mind and your schedule are too full to get everything done.
> Plain text related, naturally, but both can apply to any well-balanced life.
> What's your personal manifesto?
>
> Speaking of life in general, do you know why you do what you do?
> And what you truly value?

* [t - A command-line todo list manager for people that want to finish tasks, not organize them](https://hg.stevelosh.com/t/)

* [todo - By Zach Holman](https://github.com/holman/dotfiles/blob/master/bin/todo) [<sup>[8](#footnotes)</sup>]
>
> ```
> #!/bin/sh
> touch ~/Desktop/"$(echo $@)"
> ```

Alternatively:

* [todo - By Zach Holman](https://github.com/holman/dotfiles/commit/d774e970a88a04aca8024178849301af6d6ac5c3)
>
> ```
> #!/bin/sh
> set -e
> touch ~/Desktop/"$(echo $@)"
> ```

* [Take notes on the command line Rosetta Code](https://rosettacode.org/wiki/Take_notes_on_the_command_line)
> Invoking NOTES without commandline arguments displays the current contents of the local NOTES.TXT if it exists.
> If NOTES has arguments, the current date and time are appended to the local NOTES.TXT followed by a newline.
> Then all the arguments, joined with spaces, prepended with a tab, and appended with a trailing newline, are written to NOTES.TXT.
> If NOTES.TXT doesn't already exist in the current directory then a new NOTES.TXT file should be created. 

* [edit.sh - Keep encrypted journal](https://web.archive.org/web/20150215201454/http://imbezol.org/scripts.php)
> [edit.sh](https://web.archive.org/web/20150215201454/http://imbezol.org/edit.sh) is a yet another script I wrote.
> This one serves a more personal function.
> It allows me to write in a journal whenever I want and spill out my most personal information without having to worry that anyone will ever be able to read it. :)
> If you want to use it you'll need to create a gpg key and set the correct email address at the top of the script.
> You could stick in your own favorite editor command instead of aterm -e nano if you like.
> I just chose nano instead of my traditional vim choice because it's nice and simple to write in and I can remove the aterm bit and use it from an ssh shell.
> Basic use: "./edit.sh" will open the editor with a new filename of journal-<date>-<time>, you edit away, then it encrypts the result.
> "./edit.sh <filename>" will open an existing text file, let you edit, then encrypt when you're done.
> "./edit.sh <filename>.gpg" will decrypt an existing encrypted file (after getting you to enter the appropriate password), let you edit away, then encrypt when you're done.
> You could even modify it to open a high level editor like openoffice if you like and work in an .sxw file format.. it doesn't have to be text. 

* [Keeping a Journal - Zach Holman](https://zachholman.com/posts/keeping-a-journal/)

* [list.md - The Anatomy of a Good List](https://gist.github.com/breadchris/683202bffd4463e517335ab3f1c905be)
> Seven Qualities of a Good List
> [ . . . ]

* [tt (nimTodo) a simple command line todo manager - a small, fast, cli todo organizer, written in Nim](https://github.com/enthus1ast/nimTodo)
> A tool that `grep`s through files of a directory and list lines that contains "TODO" "DOING" "DONE" "DISCARD" with colors.
> 
> Then ask the user which file to open.
> 
> Read the "motivation" section why i wrote this and why this tool is the backbone of my todo management.

* [How to prioritize your project ideas](https://thecreativeindependent.com/tips/tips-for-how-to-prioritize-your-project-ideas/) 

* [Personal Values and Project Ideas - PDF](https://www.dropbox.com/scl/fi/xrmqheghbio7szcvep8pq/Personal-Values-and-Project-Ideas.pdf?rlkey=piyzbowhxzcchjbjk1dnc63g9&e=1&dl=0)
> What's in here?
> 
> Tools for refining personal values and prioritizing project ideas
>
> Pages 2&3 are a worksheet that will help you refine a value to be more
nuanced and specific to you.
> Try it out if this kind of thing is new to you, or if you want to be really hardcore about it :).
> 
> Page 4 is a project idea template.
> Print out several copies of it and write down all your project ideas on it.
> The up arrows are for indicating your personal values.
> I recommend coloring it in with a highlighter or marker, and then once that draws, draw the icon for that value on it.
> 
> Page 5 is a template for a menu of days.
> These describe the kind of days you typically have, and how they relate to your personal values.
> This lets you understand how your values show up in your daily life.
>
> Page 6 is a template for reflecting on how your menu of days shows up (or not) in reality.

* [4todo - A Better Way to Prioritize Your Tasks](https://4to.do/)
> Built on the Eisenhower Matrix.
> 
> A Decision System that shows you what to do now and what to next.
> 
> Works in your browser.
> Free to use.
> No credit card required.
>
> A Tip from the Developer
> 
> Check Quadrant 2 every day, not just Quadrant 1.
> When something there really matters, drag it into Quadrant 1 and do it.
>
> **FAQ**
> 
> . . .
> 
> *What's the Eisenhower Matrix?* 
> 
> The Eisenhower Matrix is a time management method created by President Dwight D. Eisenhower.
> It helps you decide what to focus on by dividing tasks into four categories:
> 
> ```
> +----------------------------+--------------+
> | Quadrant                   | Action       |
> +----------------------------+--------------+
> | Urgent & Important         | Do it now    |
> +----------------------------+--------------+
> | Important & Not Urgent     | Plan it      |
> +----------------------------+--------------+
> | Urgent & Not Important     | Delegate it  |
> +----------------------------+--------------+
> | Not Urgent & Not Important | Eliminate it |
> +----------------------------+--------------+
> ```
>
> The core idea is to focus on what truly matters instead of reacting to what only seems urgent.
> 
> 4todo is built around this framework, helping you organize tasks by priority and work with more *intention* every day.

* [boom - Motherf**king TEXT SNIPPETS! On the COMMAND LINE!](https://github.com/holman/boom)

* [boom - Text Snippets. Boom. - Zach Holman](https://zachholman.com/2010/11/text-snippets-boom/)
> Yesterday I released boom, an open source library that manages text snippets on your command line.

* [boom - motherf**king text snippets on the command line - Zach Holman](https://zachholman.com/boom/)

* [How to: Achieve a text-only work-flow, for academics](https://donlelek.github.io/2015-03-09-text-only-workflow/)

* [The Plain Text Life: Note Taking, Writing and Life Organization Using Plain Text Files](https://markwk.com/plain-text-life.html)
> "Writing is thinking.
> To write well is to think clearly.
> That's why it's so hard."
>  - David McCullough
>
> [ . . . ]
> 
> A Few Key Practical Organizational Principles
>
> In a previous section, we left a question on the table, How to stay organized with plain text files?
> This question might be shortened to just: How to stay organized?
>
> Personally, I've invested a lot of thought, testing, and writings to personal organization, and it's been an important aspect of a productive and creative professional life.
> For me, the core of my productivity and note-taking systems have come from Getting Things Done (GTD), The Organized Mind, Wikipedia and, most recently, the Zettelkasten Method, which I covered in A Book Review of How To Take Smart Notes by Sönke Ahrens.
>
> [ . . . ]
> 
> The How: Best Practices for Naming, Tagging and Linking Files
>
> The core organizational idea behind my plain text files-based notes, organization or writing system is this: uniquely named plain text files; files connected together using manual tagging and links between files; and files grouped into a few targeted directories by either project or purpose.
>
> The only requirements of my notes and writing system are: 1. notes must have a permanent and unique identifier, and 2. they must be capable of being connected to other notes.
> The unique ID is generated by a date timestamp, which by the passage of time means it won't be repeated.
> Connections are provided through manual links between notes and by adding tags.
>
> [ . . . ]
>
> My objective is to create a **latticework of notes**, much like how our brains work.
> What I'm building is a curated network of linked information.
> As such, we need consciously built connections for this to work.
>
> There are a couple of practical ways to create connections between notes.
> If you are using a Zettelkasten tool like The Archive, you can use *wiki-style* links with **double brackets**.
> You can also use a *full-qualified* link **to the file on your file system**.
> Personally, I use both methods.
> In both cases I've literally connected pieces of information into a network that makes it easy to "dance" through referenced notes and related topics smoothly.
> 
> [ . . . ]
>
> Conclusion: Building a **Latticework of Notes**
>
> My goal was not to replace Evernote but to evolve my system.
> My objective was to reconsider my organization, writing, and how I capture, process and use bits of information productively, creatively and meaningfully.

* [Mike Grindle - notes.txt](https://web.archive.org/web/20240808021520/https://mikegrindle.com/notes.txt)

* [My One Big Text File - Mike Grindle - Feb 1, 2024](https://web.archive.org/web/20250131145909/https://mikegrindle.com/posts/obtf)
> (with emphasis)
> 
> *What is OBTF?*
> 
> Using OBTF is not a new idea.
> It was relatively popular among niche blogosphere circles in the mid-2000s.
> As far as I can tell from the surviving posts, the concept can be traced back to some observations by tech journalist Danny O'Brien regarding how technologists work.
> 
> In any case, the premise behind OBTF is simple.
> It is the idea of keeping everything - or nearly everything - in one .txt (or .md) file.
> You might use it to store to-do lists, URLs, meeting notes, a reading log, a calendar, blog entries, essays, or pretty much anything else.
> However, I wouldn't suggest using it to store sensitive information like passwords, your darkest secrets or bank details.
> 
> Now, you might ask why anyone would remove all the categorization benefits of having separate files and folders.
> And wouldn't the result be an unwieldy mess?
> Well, in my experience, finding things in OBTF is blazingly fast.
> 
> To be clear, I don't scroll through my OBTF looking for things.
> That really would be hell.
> I don't even touch a keypad or a mouse.
> Instead, I use **tags** and **search**.
> The latter of which can be done using hotkeys found on pretty much any modern text editor.
>
> [ . . . ]
> 
> Again, if the system sounds imperfect, that's because it is.
> The appeal is not perfect "knowledge management."
> It's about removing any friction from my workflow.
> 
> OBTF lets me throw in knowledge, forget about it, and maybe retrieve it later.> It's kind of like a notebook in that sense.
> And as far as I'm aware, no one has yet proven there to be a better system than a notebook.
> So, why not replicate that?
>
> [ . . . ]
>
> *Final thoughts*
> 
> I have an inkling that very few people who read this will attempt to implement their own OBTF.
> This is okay.
> Despite my personal love for the idea, I don't want your big takeaway to be that using a big text file is the future.
> It isn't.
> 
> What I will say is that whatever works, works.
> And it doesn't need to be fancy.
>
> Of course, you can keep your notes, ideas, and writing in a cutting-edge PKM program if that works for you.
> You can also use a notebook, index cards, a big f'n text file, a blog, or just keep a bunch of files in a folder.
> The truth is that the medium and the tools don't matter.
> What matters is that you get that stuff in your head down.
> Tomorrow's revelation might just be the fleeting thought you had today.

* [Emacs: Org Mode Markup - aka Org-Mode as Markdown - xahlee.info](http://xahlee.info/emacs/emacs/emacs_org_markup.html)

* [Two thoughts on "Emacs #3: More on org-mode"](https://changelog.complete.org/archives/9877-emacs-3-more-on-org-mode#comments)
> 
> akater:
> What is the semantics of NEXT keyword?
> I've seen it in several setups but don't get it. 
>
> Reply - John Goerzen:
> It's nothing special to the software, only to me.
> The rough meanings I have assigned for myself are:
> 
> * TODO - working on it now
> * NEXT - I'll work on it very soon (next actions)
> * STARTED - I omit this in some of my setups, but it's an item I've begun work on
> * WAIT - I can't do it right now because of something (waiting for a reply from someone, for someone else to do something, etc.)
> * OTHERS - Someone else is doing it, but I'm keeping track of it
> * DONE / CANCELED - I did it, or I decided I won't do it

* [OBTF Follow-up - Mike Grindle - Feb 26, 2024](https://web.archive.org/web/20250130125638/https://mikegrindle.com/posts/obtf-follow-up)
>
> [ . . . ]
> 
> Finally, I'd reiterate that I certainly didn't come up with the OBTF idea.
> I just took the bits that work for me.
> I wrote about it because I found it interesting, not because I think it's the "best" system.
> The best note-taking system is the one that works for you.
> Actually, despite what people say, you don't need a system at all, and they can waste your time if you're not careful.

* [plancli - File based project planning on the command line](https://github.com/no-gravity/plancli)
> Every project I work on has a plan/ directory in which I do the whole project management.
> 
> I started this simply in vim by creating files like productchart/plan/1000-tests_for_the_comparison_pages.txt to create a task to write "Tests for the comparison pages" of the [Product Chart](https://www.productchart.com/) project.
> 
> *My comment:* The expected format for the ETA input is either hours and minutes (like "2h30m"), just hours (like "2h"), or just minutes (like "30m").
>
> The 1000 is the priority of the task.
> 
> It makes handling tasks nicely easy, as I have the project directory open in vim anyhow.
> So when I open the plan/ dir, I see a sorted list of tasks.
> I can search like in every other vim buffer.
> I can look into a task like into each other file.
> I can edit them right away in vim too.
> And I can fire off terminal commands like grep to search inside the tasks etc.
> Also versioning is handled automatically as the project is in git anyhow.
> 
> Over time, I wrote a bunch of python scripts to make handling the tasks easier.
> I might publish them here over time.
> For now, here is the script which creates a new task. 

* [Writer - The distraction free writing tool I use for all my writing - Marek Gibney](https://github.com/no-gravity/writer)
> 
> You can try it here: [https://www.gibney.org/writer](https://www.gibney.org/writer)
> 
> It is simply a centered textarea on an empty html page.
> 
> This creates a couple of nice features for free:
> 
> * Hit F11 and the whole screen is just the writer.
> * The font size can be change with ctrl+ and ctrl-
> * The textarea can be resized with the mouse and by moving its lower right corner.
> While resizing it, it stays centered.
> 
> Load and Save buttons will appear when you move the mouse to the upper left corner of the screen.
> 
> Currently, loading and saving is a but cumbersome as it uses the download/upload functionality of the browser.
> It could be made more convenient by using the filesystem access api: [https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API)

* [My OBTF Workflow & Bash Script - Mike Grindle - Jul 26, 2024](https://web.archive.org/web/20250201080237/https://mikegrindle.com/posts/obtf-workflow) 

* [One Big Text File (OBTF) Journal in Markdown](https://github.com/CLSherrod/OBTF)

* [My Big-Arse Text File - a Poor Man's Wiki+Blog+PIM](http://www.matthewcornell.org/blog/2005/8/21/my-big-arse-text-file-a-poor-mans-wikiblogpim.html)

* [Life inside one big text file](http://www.43folders.com/2005/08/17/life-inside-one-big-text-file)
>
> 
> [ . . . ]
> 
> [Commented by meatpeople](https://web.archive.org/web/20110712142852/http://www.43folders.com/node/47312/317522#comment-317522):
> 
> The top of the file is the TODO list, in descending order.
> After that is a calendar, which is a descending order list of dates/thing to do on it entries.
> After that is a log, where I jot daily (or fairly regular) notes about what I'm doing.

* [Living in text files](https://web.archive.org/web/20120111013044/http://www.oreillynet.com/mac/blog/2005/08/living_in_text_files.html)

* [Todo.txt - Future-proof task tracking in a file you control](http://todotxt.org/)
> If you want to get it done, first write it down.

* [todo.txt format - A complete primer on the whys and hows of todo.txt](https://github.com/todotxt/todo.txt)

* [An example of Todo.txt file](http://todotxt.org/todo.txt)

* [todo.txt-cli - A simple and extensible shell script for managing your todo.txt file](https://github.com/todotxt/todo.txt-cli)

* [todoTxtWebUi - A web UI to use with a todo.txt file](https://github.com/bicarbon8/todoTxtWebUi)
> A web UI to use with a todo.txt file.
> This project is an extention to the [http://todotxt.org/](http://todotxt.org/) (previously [http://www.todotxt.com](http://www.todotxt.com)) project providing a rich web user interface for interacting with one's todo.txt file.
> The requirements of this project are that it only use HTML, Javascript and CSS to accomplish all functionality in a Webkit compatible browser.
> There must be no back-end server code, no local executables and no browser plugins utilized in supporting the functionality of this project.
>

* [todoTxtWebUi - Demo online](https://bicarbon8.github.io/todoTxtWebUi/)

* [shortlist-it - a tool to assist in the decision-making process by adding ranking criteria that can be tracked over time](https://github.com/bicarbon8/shortlist-it)

* [shortlist-it - Online demo](https://bicarbon8.github.io/shortlist)

* [Todour - An application for handling todo.txt files on the Mac and Windows, by Sverrir Valgeirsson - Blog post about it](https://nerdur.com/todour-pl/)

* [Todour - Manual (User guide)](https://sverrirvalgeirsson.github.io/Todour/)

* [Todour - An experimental web version (not interoperable with the desktop version in any meaningful way)](https://todour.com/)
> Simple, powerful task management with todo.txt compatibility

* [Todour - The source code for the desktop version can be found on GitHub](https://github.com/SverrirValgeirsson/Todour) 

or 

* [You can check out the excellent fork by GateanDC - GitHub](https://github.com/GaetanDC/Todour/)

* [Todo list system - How I use the TODO.txt system to get things done](https://www.mearso.co.uk/blog/todo-system.html)

* [Todo.txt with a few tweaks](https://www.neilvandyke.org/todotxt/)

* [A Fresh Take on Contexts - Simplicity Bliss]
> Explaination on why the original idea of contexts is a bit old-fashioned now.

* [Programmers Notebook](http://c2.com/cgi/wiki?ProgrammersNotebook)
> Best Practices (excerpts)
> 
> * Start slowly; some log is better than no log.
> * Don't postpone writing something down.
>   Somebody else will come along, and you'll forget your bright idea.
> * Put a date on every entry.
> * Different kinds of entries, each with a special symbol in the margin: remarks, questions, definitions, to do items, [MetaRemarks](https://wiki.c2.com/?MetaRemarks).

* [To Do List](https://wiki.c2.com/?ToDoList)

* [Finding my balance: An evolved and simplified task management system](https://pankajpipada.com/posts/2023-07-30-taskmgmt/)

* [Refining the Flow: A Streamlined Markdown/Git-Based Task Management System for Solo Developers](https://pankajpipada.com/posts/2024-08-13-taskmgmt-2/)

* [LogBook](https://wiki.c2.com/?LogBook)

* [Electronic Log Book](https://wiki.c2.com/?ElectronicLogBook)

* [Let Your Logs Become Your Plans](https://wiki.c2.com/?LetYourLogsBecomeYourPlans)

* [Fixme Comment (This is related to tagging)](https://wiki.c2.com/?FixmeComment)
> I find a large fraction of the comments I put in code these days (in C, Java and Python) are 'FIXME', 'TODO', or 'XXX' comments.
> I try to make my code self-evident at a low level - I do have ModuleComments and DesignNotes - but making a note of a tangential issue often seems more appropriate than solving it when it turns up.

* [ToDo.txt - 43 Folders Wiki](https://web.archive.org/web/20120123121718/http://wiki.43folders.com/index.php/ToDo.txt)
> Testimonials and Usage
> 
> Before keeping most things on paper, I'd have a "Notes.txt" file on my desktop screen.
> It functioned as scratch paper, annotated bookmarks, clipboard, words of wisdom, and pretty much anything else that was plaintext. I'd start over about every three months, generally discarding whatever was in it (since anything important found its way elsewhere). - Steve 
>
> [ . . . ]
> 
> TODO text file 
> 
> [ . . . ]
> 
> Vim helps a lot to make this a worthwhile method.
> I couldn't imagine doing it in notepad.
> 
> * vim has multi-level undo, so if I make a mistake, I can type 'u' to undo as necessary
> * copying and pasting text into named buffers makes it easy to reorganise the file
> * moving within the file is very fast, e.g. I just press '}' to jump to the next paragraph (which is usually the same as the next project, or the next day). 
> 
> Here's the structure of the file which I use.
> 
> At the top, current goals or high priority focus issues.
> That keeps me reminded of what's most important at any time (because this file can get rather big.
> 
> Second, several weeks of daily action items.
> One paragraph per day, for example:
>
> ```
> 2006-08-05
> c - buy label printing device
> - update 43folders wiki "TODO text file"
> 
> 2006-08-06
  > - buy 6 batteries for label printer
> ```
>
> The first action item of 2006-08-05 is marked with a 'c' for "complete".
> I have a very small number of additional codes, including 'x' for cancelled, and 'w' for work-in-progress.
> It's naturally very important to not mark something as complete unless it actually is complete.
> 
> Third, several paragraphs of project actions: 
>
> ```
> Replace Mailbox
>   - investigate mailboxes for sale
>   - find installer (yellow pages?)
>   - contact installer, schedule replacement day/time
>   - mailbox replaced
>   - sell old mailbox
> ```
>
> The project actions are ordered so the next action comes first, or in order of priority.
> 
> As I decide to do a certain action on a particular day the project actions are moved to the daily paragraphs, and checked off as completed when done. 

* [Notes from Danny O'Brien's NotCon Recap of Life Hacks - Cory Doctorow - June 6, 2004](https://craphound.com/lifehacks2.txt)

* [The Memex Method - When your commonplace book is a public database - Cory Doctorow](https://pluralistic.net/2021/05/09/the-memex-method/) 

* [Recoll - Full-text search for your desktop](https://www.recoll.org/)
> Recoll finds documents based on their contents as well as their file names.
> * Versions are available for Linux, MS Windows and MacOS.
> * It can search most document formats.
> * You may need external applications for text extraction.
> * It can reach any storage place: files, archive members, email attachments, transparently handling decompression.
> * One click will open the document inside a native editor or display an even quicker text preview.
> * A [WEB front-end](https://framagit.org/medoc92/recollwebui/) with preview and download features can replace or supplement the GUI for remote use.
> * The software is free on Linux, open source, and licensed under the GPL.
> * Detailed features and application requirements for supported document types.
>
> Recoll will index an MS-Word document stored as an attachment to an e-mail message inside a Thunderbird folder archived in a Zip file (and more...).
> It will also help you search for it with a friendly and powerful interface, and let you open a copy of a PDF at the right page with two clicks.
> There is little that will remain hidden on your disk.
> 
> [ . . . ]
> 
> Recoll is based on the very capable [Xapian](https://xapian.org/) search engine library, for which it provides a powerful text extraction layer and a complete, yet easy to use, Qt graphical interface.

* [Xapian - an Open Source Search Engine Library](https://xapian.org/)

* [20 years of Getting Things Done](https://gagor.pro/2025/11/20-years-of-getting-things-done/)

* [Getting Things Done for Leaders -- No-bullshit practical workshop -- Tomasz Gągor](https://gagor.pro/2025/11/20-years-of-getting-things-done/slides/slides.pdf)

* [Harmony Toolbox](https://harmonytoolbox.com/)

* [A receipt printer cured my procrastination](https://www.laurieherault.com/articles/a-thermal-receipt-printer-cured-my-procrastination)
> How I can focus on my to-do list by understanding the science of video games

* [TRMNL - E-ink dashboard to stay focused](https://usetrmnl.com/)
> TRMNL was founded with a simple but powerful vision: to help people stay focused and calm in an increasingly distracting world.
> We believe technology should enhance your life without demanding your attention.
> Our e-ink dashboard is designed to provide information you need at a glance, without the endless notifications from traditional screens.

* [Viz.js - Graphviz in your browser](https://github.com/mdaines/viz-js) 

* [Viz.js - Online demo and playground](https://viz-js.com/)

* [TRMNL OG - E-ink dashboard - 7.5" e-ink display with 4 grayscale and fast refresh](https://shop.usetrmnl.com/products/trmnl)

* [Slides and supplemental info from my August 3rd 2016 NYC Vim talk](https://github.com/changemewtf/no_plugins)

* [no_plugins.vim - GitHub](https://github.com/changemewtf/no_plugins/blob/master/no_plugins.vim)

* [How to Do 90% of What Plugins Do (With Just Vim) - Video](https://www.youtube.com/watch?v=XA2WjJbmmoM)

* [Todo.txt For Emacs (todotxt.el) - aka a Todo.txt client for Emacs](https://github.com/rpdillon/todotxt.el)

* [Emacs Major Mode for TODO.TXT files](https://github.com/avillafiorita/todotxt-mode)

* [emacs-evil - evil: The extensible vi layer for Emacs](https://github.com/emacs-evil/evil)
> Evil is an **e**xtensible **vi l**ayer for [Emacs](https://www.gnu.org/software/emacs/).
> It emulates the main features of [Vim](https://www.vim.org/), and provides facilities for writing custom extensions.
> Also see our page on [EmacsWiki - Evil](https://www.emacswiki.org/emacs/Evil)

* [Evil Collection - A set of keybindings for evil-mode](https://github.com/emacs-evil/evil-collection)
> This is a collection of [Evil](https://github.com/emacs-evil/evil) bindings for *the parts of Emacs* that Evil does not cover properly by default, such as `help-mode`, `M-x` calendar, Eshell and more.

* [EmacsWiki - Evil](https://www.emacswiki.org/emacs/Evil)
> There's a [four-minute Evil demo](http://youtu.be/Uz_0i27wYbg) on YouTube, created by Bailey Ling.
> The captions in the corner of the frame show the keystrokes which Bailey is entering.

* [Quickstart - Org mode](https://orgmode.org/quickstart.html)

* [Emacs as my leader: evil-mode - By Bailey Ling](https://www.youtube.com/watch?v=Uz_0i27wYbg)
> A quick demo of using Vim inside Emacs, made possible by the excellent package evil-mode.
> The captions in the corner of the frame show the keystrokes which Bailey is entering. 
>
> The bootstrap can be found at 
>
> [https://github.com/bling/emacs-evil-bootstrap](https://github.com/bling/emacs-evil-bootstrap)

* [Emacs Org-mode - a system for note-taking and project planning - Video](https://www.youtube.com/watch?v=oJTwQvgfgMM)

* [Emacs #1: Ditching a bunch of stuff and moving to Emacs and org-mode](https://changelog.complete.org/archives/9861-emacs-1-ditching-a-bunch-of-stuff-and-moving-to-emacs-and-org-mode)
> Capturing
> 
> If you've ever read productivity guides based on GTD, one of the things they stress is effortless capture of items.
> The idea is that when something pops into your head, get it down into a trusted system quickly so you can get on with what you were doing.
> Org-mode has a capture system for just this.
> I can press C-c c from anywhere in Emacs, and up pops a spot to type my note.
> But, critically, automatically embedded in that note is a link back to what I was doing when I pressed C-c c.o
> If I was editing a file, it'll have a link back to that file and the line I was on.
> If I was viewing an email, it'll link back to that email (by Message-Id, no less, so it finds it in any folder).
> Same for participating in a chat, or even viewing another org-mode entry.
> 
> So I can make a note that will remind me in a week to reply to a certain email, and when I click the link in that note, it'll bring up the email in my mail reader - even if I subsequently archived it out of my inbox.
> 
> YES, this is what I was looking for!

* [Emacs #2: Introducing org-mode](https://changelog.complete.org/archives/9865-emacs-2-introducing-org-mode)

* [A list of all articles in this series - Emacs and org-mode - Five articles](https://changelog.complete.org/archives/tag/emacs2018) 

* [Printable Org-Mode reference card (cheatsheet) - orgcard.pdf](https://orgmode.org/orgcard.pdf)

* [An opiniated guide to using Org Mode in Emacs](https://iamapt.com/blog/org-emacs-doom/)

* [Spacemacs: Emacs advanced Kit focused on Evil (Evil mode)](https://www.spacemacs.org/)
> A community-driven Emacs distribution
> The best editor is neither Emacs nor Vim, it's Emacs and Vim!

* [Spacemacs - Source coed on GitHub - The best editor is neither Emacs nor Vim, it's Emacs *and* Vim!](https://github.com/syl20bnr/spacemacs)
> Quick Start
>
> If you don't have an existing Emacs setup and want to run Spacemacs as your configuration, and if you have all prerequisites installed, you can install Spacemacs with one line.

* [Evil - an **e**xtensible **vi l**ayer for Emacs](https://github.com/emacs-evil/evil)

* [Doom Emacs](https://github.com/doomemacs/doomemacs)

* [NΛNO: Nano Emacs - GNU Emacs made Simple](https://github.com/rougier/nano-emacs)

* [Elegant Emacs - A very minimal but elegant Emacs](https://github.com/rougier/elegant-emacs)
> Unmaintained - early prototype for Nano Emacs

* [The absolute minimum you need to know about Emacs - Org mode beginning at the basics](https://orgmode.org/worg/org-tutorials/org4beginners.html) 

* [org-notifications - Desktop notifications for your org-agenda/org-mode items](https://github.com/doppelc/org-notifications)
> With it, you can, for example, use Emacs and its OrgMode just for editing your todo list, close it after writing todo, and then will this tool (org-notifications) to pop up notifications.

* [subtask - Todo list manager with subtasks](https://github.com/vhp/subtask)

* [ Terminal Velocity - a fast, cross-platform note-taking application for the UNIX terminal](https://vhp.github.io/terminal_velocity/)
> A fast note-taking app for the UNIX terminal
> Terminal Velocity is a fast, cross-platform note-taking application for the UNIX terminal, it's a clone of the OS X app Notational Velocity that runs in a terminal and uses your $EDITOR.

* [ Terminal Velocity - Source code on GitHub](https://github.com/vhp/terminal_velocity)
> Terminal Velocity is currently in maintenance mode.
> Python pip installs are still supported and the software is stable for day to day use with python 2.
> The software is being moved into maintenance mode because both authors no longer use terminal_velocity.
> Life happens and finding the time to maintain it is difficult.
> We hope you understand.

* [next-action: Next-action: determine the next action to work on from a list of actions in a todo.txt file](https://github.com/fniessink/next-action)

* [Syncthing](https://syncthing.net/)

* [Nextcloud](https://nextcloud.com/)

* [Nextcloud Server - Source code on GitHub](https://github.com/nextcloud/server)

* [Johnny.Decimal - A system to organise your life](https://johnnydecimal.com/)
> Johnny.Decimal is designed to help you find things quickly, with more confidence, and less stress.
> 
> You assign a unique ID to everything in your life.

* [Plain text planning calendar](https://web.archive.org/web/20190529014944/http://demeyere.com/2016/plaintext-planning-calendar)

* [Calendar.txt - Keep your calendar in a plain text file](https://terokarvinen.com/2021/calendar-txt/) 
> Calendar.txt is versionable, supports all operating systems. 
>
> How do I use calendar.txt?
> Open [calendar.txt](https://terokarvinen.com/2021/calendar-txt/calendar-txt-until-2033.txt) in any text editor and start filling in your events.
>
> [ . . . ]
>
> Download ready made calendar
>
> [Download calendar.txt template](https://terokarvinen.com/2021/calendar-txt/calendar-txt-until-2033.txt).
> It has ready made calendar events until 2033.
> Feel free to copy just the part you need, such as half a year.
>
> [ . . . ]
> 
> Here is the [short go program to generate calendar.txt templates](https://terokarvinen.com/2021/calendar-txt/calendartxt-generator-0.0.1.zip).

* [showcal - a calendar/task/appointment manager ("bash script"). It is simple and portable](https://github.com/viviparous/showcal)

* [Calendar (neatnik.net) - Hacker News](https://news.ycombinator.com/item?id=46408613)

* [Calendar - neatnik.net](https://neatnik.net/calendar/)
>  Hello!
> If you print this page, you'll get a nifty calendar that displays all of the year’s dates on a single page.
> It will automatically fit on a single sheet of paper of any size.
> For best results, adjust your print settings to landscape orientation and disable the header and footer.
>  
> Take in the year all at once.
> Fold it up and carry it with you.
> Jot down your notes on it.
> Plan things out and observe the passage of time.
> Above all else, be kind to others.

* [Calendar - neatnik.net - Source code - The entire year on a page - SourceTube - Version control for the omg.lol community](https://source.tube/neatnik/calendar)

* [How I fell in love with calendar.txt](https://ploum.net/2025-09-03-calendar-txt.html)

----

## Footnotes

**[1]** Also known as *Semantic Linefeeds (Semantic Linebreaks)*

Origin: Brian W. Kernighan published "UNIX for Beginners" [[PDF](https://web.archive.org/web/20130108163017if_/http://miffy.tom-yam.or.jp:80/2238/ref/beg.pdf)] as Bell Labs Technical Memorandum 74-1273-18 on 29 October 1974.
 
My emphasis
>
> *Hints for Preparing Documents*
> 
> Most documents go through several versions (always more than you expected) before they are finally finished.
> Accordingly, you should do whatever possible to make the job of changing them easy.
>
> First, when you do the purely mechanical operations of typing, type so subsequent editing will be easy.
> *Start each sentence on a new line.*
> Make lines short, and break lines at natural places, such as after commas and semicolons, rather than randomly.
> Since most people change documents by rewriting phrases and adding, deleting and rearranging sentences, these precautions simplify any editing you have to do later.
>   Brian W. Kernighan, 1974

**[2]** A blank line contains zero or more non-printing characters, such as space or tab, followed by a new line.

**[3]** If or when you are ready to make this system more extensive:

## Directory Tree (Directory Structure)

```
life/
 . LIFE.TXT 
 . stacks/
    . calendar.txt
    . family
    . finance
    . goals
    . plans
    . someday
    . today.txt
 . logs/
    . completed_projects
    . journal
    . today_logs
    . what_done 
 . projects/
 . db/
    . glossary
    . shell_tips
    . people_book
    . recipes
    . ...
 . lists/
    . checklist_daily
    . checklist_weekly
    . context_list
    . project_list
    . tag_list
    . todo_list
    . worry_list
 . tools/
    . notes.sh
```

```
______Calendar

# From :r!remind -n /path/to/your/.reminders (ran on Dec 29, 2025):
2026/01/02 11:00am Dentist in 4 days' time 
2026/02/21 10:00am Oil change appointment in 54 days' time 
---- snip ----
2026/11/12 Bill's birthday

# From :r!remind -s /path/to/your/.reminders (ran on Dec 29, 2025):
2025/12/07 * * 15 630 10:30-10:45am Monthly Review
2025/12/11 * * 10 600 10:00-10:10am Call Jim
---- snip ----
2025/12/29 * * * * today

# From :r!cal (ran on Dec 29, 2025):
   December 2025
Su Mo Tu We Th Fr Sa
    1  2  3  4  5  6
 7  8  9 10 11 12 13
14 15 16 17 18 19 20
21 22 23 24 25 26 27
28 29 30 31

# From dategen.py:
#   https://terokarvinen.com/2024/format-date-calendar-txt/
January 2026
2026-01-01 Thu
2026-01-02 Fri
2026-01-03 Sat
2026-01-04 Sun
2026-01-05 Mon
2026-01-06 Tue
2026-01-07 Wed
2026-01-08 Thu
2026-01-09 Fri
2026-01-10 Sat
2026-01-11 Sun
2026-01-12 Mon
2026-01-13 Tue
2026-01-14 Wed 10:00-11:30am | Group meeting
2026-01-15 Thu
2026-01-16 Fri
2026-01-17 Sat
2026-01-18 Sun
2026-01-19 Mon
2026-01-20 Tue 3:00-4:00pm   | Group video call with ABC Corp
2026-01-21 Wed
2026-01-22 Thu
2026-01-23 Fri
2026-01-24 Sat
2026-01-25 Sun
2026-01-26 Mon
2026-01-27 Tue 7:00-7:15pm   | XYZ yearly subscription renewal
2026-01-28 Wed
2026-01-29 Thu
2026-01-30 Fri
2026-01-31 Sat

# From :r!remind -c /path/to/your/.reminders (ran on Dec 29, 2025):
+----------------------------------------------------------------------------+
|                               December 2025                                |
+----------+----------+----------+----------+----------+----------+----------+
|  Sunday  |  Monday  | Tuesday  |Wednesday | Thursday |  Friday  | Saturday |
+----------+----------+----------+----------+----------+----------+----------+
|          |1         |2         |3         |4         |5         |6         |
|          |          |          |          |          |          |          |
---- snip ----
+----------+----------+----------+----------+----------+----------+----------+
|28        |29 ****** |30        |31        |          |          |          |
|          |today     |          |          |          |          |          |
|          |          |          |          |          |          |          |
+----------+----------+----------+----------+----------+----------+----------+
```

Current month:

```
:r!remind -c /mnt/usbflashdrive/mydotfiles/.reminders | sed 's/\xe2\x80\x8e//g'
```


Current week:

```
:r!remind -c+1 /mnt/usbflashdrive/mydotfiles/.reminders | sed 's/\xe2\x80\x8e//g'
```

Check if there are reminders for today:

``` 
:r!remind /mnt/usbflashdrive/mydotfiles/.reminders
``` 

Output next occurrence of reminders in simple format:

```
:r!remind -n /mnt/usbflashdrive/mydotfiles/.reminders | sort
```

Produce 'simple calendar' for the current month:

```
:r!remind -s /mnt/usbflashdrive/mydotfiles/.reminders
```

Produce 'simple calendar' for the current *and* next month:

```
:r!remind -s2 /mnt/usbflashdrive/mydotfiles/.reminders
```

* For the current month, every day has an entry for easy visual review.
* For months in the future only days with events are visible.
* You can have event lines that are later than one year in the future.


**[4]** Same as in Emacs Org Mode Markup:

[Tags - The Org Manual - (Emacs Org Mode Markup - for Org Mode Tag)](https://orgmode.org/manual/Tags.html) 
> Tags must be preceded and followed by a single colon, e.g., `:work:`.
> Several tags can be specified, as in ':work:urgent:'.

**[5]** For example, you could have a `checklist_daily` as a staging structure for your daily work, while a `checklist_weekly` would remind you to create next actions for all your projects and review the week ahead and so on.

**[6]** Here-Document: handling tabs or spaces, leading tabs, and variable substitution 

```
<<EOF: Doesn't ignore leading tabs or spaces.
The content within the heredoc is treated as-is, without any modifications.

<<'EOF' (Single-quoted heredoc): The single quotes around EOF prevent any variable substitution or command execution within the heredoc.

<<-EOF (Indented heredoc): The hyphen (-) after << allows for leading tabs to be ignored in the heredoc.
It strips leading tabs from each line before processing.
```

**[7]** Additional resources for optionally extending the system:

* [Emacs as my leader: evil-mode - By Bailey Ling](https://www.youtube.com/watch?v=Uz_0i27wYbg)
> A quick demo of using Vim inside Emacs, made possible by the excellent package evil-mode.
> The captions in the corner of the frame show the keystrokes which Bailey is entering. 
>
> The bootstrap can be found at 
>
> [https://github.com/bling/emacs-evil-bootstrap](https://github.com/bling/emacs-evil-bootstrap)

* [Emacs Org-mode - a system for note-taking and project planning - Video](https://www.youtube.com/watch?v=oJTwQvgfgMM)

* [Emacs #1: Ditching a bunch of stuff and moving to Emacs and org-mode](https://changelog.complete.org/archives/9861-emacs-1-ditching-a-bunch-of-stuff-and-moving-to-emacs-and-org-mode)
> Capturing
> 
> If you've ever read productivity guides based on GTD, one of the things they stress is effortless capture of items.
> The idea is that when something pops into your head, get it down into a trusted system quickly so you can get on with what you were doing.
> Org-mode has a capture system for just this.
> I can press C-c c from anywhere in Emacs, and up pops a spot to type my note.
> But, critically, automatically embedded in that note is a link back to what I was doing when I pressed C-c c.o
> If I was editing a file, it'll have a link back to that file and the line I was on.
> If I was viewing an email, it'll link back to that email (by Message-Id, no less, so it finds it in any folder).
> Same for participating in a chat, or even viewing another org-mode entry.
> 
> So I can make a note that will remind me in a week to reply to a certain email, and when I click the link in that note, it'll bring up the email in my mail reader - even if I subsequently archived it out of my inbox.
> 
> YES, this is what I was looking for!

* [Emacs #2: Introducing org-mode](https://changelog.complete.org/archives/9865-emacs-2-introducing-org-mode)

* [A list of all articles in this series - Emacs and org-mode - Five articles](https://changelog.complete.org/archives/tag/emacs2018) 

* [Printable Org-Mode reference card (cheatsheet) - orgcard.pdf](https://orgmode.org/orgcard.pdf)

* [An opiniated guide to using Org Mode in Emacs](https://iamapt.com/blog/org-emacs-doom/)

* [Spacemacs: Emacs advanced Kit focused on Evil (Evil mode)](https://www.spacemacs.org/)
> A community-driven Emacs distribution
> The best editor is neither Emacs nor Vim, it's Emacs and Vim!

* [Spacemacs - Source coed on GitHub - The best editor is neither Emacs nor Vim, it's Emacs *and* Vim!](https://github.com/syl20bnr/spacemacs)
> Quick Start
>
> If you don't have an existing Emacs setup and want to run Spacemacs as your configuration, and if you have all prerequisites installed, you can install Spacemacs with one line.

* [Evil - an **e**xtensible **vi l**ayer for Emacs](https://github.com/emacs-evil/evil)

* [Doom Emacs](https://github.com/doomemacs/doomemacs)

* [NΛNO: Nano Emacs - GNU Emacs made Simple](https://github.com/rougier/nano-emacs)

* [Elegant Emacs - A very minimal but elegant Emacs](https://github.com/rougier/elegant-emacs)
> Unmaintained - early prototype for Nano Emacs

* [The absolute minimum you need to know about Emacs - Org mode beginning at the basics](https://orgmode.org/worg/org-tutorials/org4beginners.html) 

* [org-notifications - Desktop notifications for your org-agenda/org-mode items](https://github.com/doppelc/org-notifications)
> With it, you can, for example, use Emacs and its OrgMode just for editing your todo list, close it after writing todo, and then will this tool (org-notifications) to pop up notifications.

* [subtask - Todo list manager with subtasks](https://github.com/vhp/subtask)

* [ Terminal Velocity - a fast, cross-platform note-taking application for the UNIX terminal](https://vhp.github.io/terminal_velocity/)
> A fast note-taking app for the UNIX terminal
> Terminal Velocity is a fast, cross-platform note-taking application for the UNIX terminal, it's a clone of the OS X app Notational Velocity that runs in a terminal and uses your $EDITOR.

* [ Terminal Velocity - Source code on GitHub](https://github.com/vhp/terminal_velocity)
> Terminal Velocity is currently in maintenance mode.
> Python pip installs are still supported and the software is stable for day to day use with python 2.
> The software is being moved into maintenance mode because both authors no longer use terminal_velocity.
> Life happens and finding the time to maintain it is difficult.
> We hope you understand.

* [next-action: Next-action: determine the next action to work on from a list of actions in a todo.txt file](https://github.com/fniessink/next-action)

* [Syncthing](https://syncthing.net/)

* [Nextcloud](https://nextcloud.com/)

* [Nextcloud Server - Source code on GitHub](https://github.com/nextcloud/server)

* [Johnny.Decimal - A system to organise your life](https://johnnydecimal.com/)
> Johnny.Decimal is designed to help you find things quickly, with more confidence, and less stress.
> 
> You assign a unique ID to everything in your life.

* [Plain text planning calendar](https://web.archive.org/web/20190529014944/http://demeyere.com/2016/plaintext-planning-calendar)

* [Calendar.txt - Keep your calendar in a plain text file](https://terokarvinen.com/2021/calendar-txt/) 
> Calendar.txt is versionable, supports all operating systems. 
>
> How do I use calendar.txt?
> Open [calendar.txt](https://terokarvinen.com/2021/calendar-txt/calendar-txt-until-2033.txt) in any text editor and start filling in your events.
>
> [ . . . ]
>
> Download ready made calendar
>
> [Download calendar.txt template](https://terokarvinen.com/2021/calendar-txt/calendar-txt-until-2033.txt).
> It has ready made calendar events until 2033.
> Feel free to copy just the part you need, such as half a year.
>
> [ . . . ]
> 
> Here is the [short go program to generate calendar.txt templates](https://terokarvinen.com/2021/calendar-txt/calendartxt-generator-0.0.1.zip).

* [showcal - a calendar/task/appointment manager ("bash script"). It is simple and portable](https://github.com/viviparous/showcal)

* [Calendar (neatnik.net) - Hacker News](https://news.ycombinator.com/item?id=46408613)

* [Calendar - neatnik.net](https://neatnik.net/calendar/)
>  Hello!
> If you print this page, you'll get a nifty calendar that displays all of the year’s dates on a single page.
> It will automatically fit on a single sheet of paper of any size.
> For best results, adjust your print settings to landscape orientation and disable the header and footer.
>  
> Take in the year all at once.
> Fold it up and carry it with you.
> Jot down your notes on it.
> Plan things out and observe the passage of time.
> Above all else, be kind to others.

* [Calendar - neatnik.net - Source code - The entire year on a page - SourceTube - Version control for the omg.lol community](https://source.tube/neatnik/calendar)

* [How I fell in love with calendar.txt](https://ploum.net/2025-09-03-calendar-txt.html)


**[8]** Full shell script - `todo` - By Zach Holman:

```
#!/bin/sh
#
# Creates something for me to do.
#
# I've used literally every todo list, app, program, script, everything. Even
# the ones you are building and haven't released yet.
#
# I've found that they're all nice in their nice ways, but I still don't use
# them, thus defeating the purpose of a todo list.
#
# All `todo` does is put a file on my Desktop with the filename given. That's
# it. I aggressively prune my desktop of old tasks and keep one or two on there
# at a time. Once I've finished a todo, I just delete the file. That's it.
#
# Millions of dollars later and `touch` wins.
set -e

# Run our new web 2.0 todo list application and raise millions of VC dollars.
touch ~/Desktop/"$(echo $@)"
```

---

## Appendix

### Todo.txt format rules - Description (ASCII plain text) 

```
           Description; tags (optional) can be placed anywhere in here
                                         ^
                                         |
+----------------------------------------------------------------------------------+
|                                                                                  |
x (A) 2016-05-20 2016-04-30 measure space for +chapelShelving @chapel due:2016-05-30
|  |      |          |      |_______________| |_____________| |_____| |____________|
|  |      |          |              |                |           |          |
|  |      |          |              v                v           v          v
|  |      |          |         Task text       Project Tag    Context  Special key/value
|  |      |          |                                          Tag        pair
|  |      |          |
|  |      |          +─ Optional: Creation Date (must be specified if Completion Date is)
|  |      +─ Optional: Completion Date
|  +─ Optional: Marks priority
+─ Optional: Marks completion
```

### Todo.txt format rules - Description (SVG image)

From 
[https://raw.githubusercontent.com/todotxt/todo.txt/refs/heads/master/description.svg](https://raw.githubusercontent.com/todotxt/todo.txt/refs/heads/master/description.svg)

![Todo.txt format rules - Description (SVG image)](/assets/img/todotxt_format_rules_description.svg "Todo.txt format rules - Description (SVG image)")

---

## My Org Mode Cheatsheet

### Preamble
```
#+title: The Glories of Org
#+author: A. Org Writer
```

### Headings

```
* Welcome to Org-mode
** Sub-heading
etc.
```

Pressing `<TAB>` on headings will minimize/maximize them.
Pressing tab multiple times in a row on headings with subheadings will maximize each subheading by depth corresponding to the number of times you pressed <TAB>.

---


//TODO: https://www.snellman.net/blog/archive/2017-04-17-xxx-fixme/
