---
layout: post
title: "My GTD Workflow [WIP]"
date: 2023-09-17 11:32:16 +0000
categories: gtd productivity howto reference timemanagement lifemanagement
            selfmanagement 
---

OS: FreeBSD 14.0   
Shell: csh   

----

* vi   
* TeX, LaTeX, PDF
* my website

* Graphviz
* Zim

* Paper notebook, pen, pencil

**CRON**    

* taskwarrior
* remind
  * xmessage(1) - with `remind -c`
  * xmessage(1) - with `remind /path/to/.reminders`:w
  * mail(1) (mailx(1)) - weekly reminder (`remind -c+1`)
* recursive stickies    
Based on 
  [Recursive Notes (Recursive Post-It Notes or Recursive Stickies)](https://mitxela.com/projects/recursive)    
  Info: [Part 1](https://mitxela.com/projects/recursive)
  > The idea of using this recursive project-management tool as a means to finish the outstanding tasks on said tool has not escaped me.
  > There is something infinitely appealing about recursion.

  [Part 2](https://mitxela.com/projects/recursive_2)        
  > I had, half-heartedly, been using the recursive notes program to manage various projects, but it wasn't until I added the tree outline with search feature that this properly became viable.
  > There was a very clear change between forcing myself to use it for the novelty, and suddenly finding that the notes program was no longer in the way of my thinking.
  > Naturally, the thing I've been using it most for is to manage improvements to the recursive notes program.
  > But also, I've been using it to manage other projects and for the most part, it works!
  > One of the most notable things is that I often run into glitches or minor inconveniences, which usually leads me to either patch it right away, or at the very least, make a recursive note about it.
  
  Demo: [https://mitxela.com/other/recursive/recursive.htm](https://mitxela.com/other/recursive/recursive.htm)

* today.pl
* edit.sh - private notes


----

## **CALENDAR**

* From
[Plain Text Journaling](https://peppe.rs/posts/plain_text_journaling/):
> ```
> $ vi ~/journalfile.txt
> ```
> 
> Every month must start with a calendar of course, fill that in with:
>
> ``` 
> :read !cal
> ``` 

```
$ cat ~/journalfile.txt
   September 2023     
Su Mo Tu We Th Fr Sa  
                1  2  
 3  4  5  6  7  8  9  
10 11 12 13 14 15 16  
17 18 19 20 21 22 23  
24 25 26 27 28 29 30  
```      

```
* todo
x done
- note
o event
> moved
```


```
$ vi ~/journalfile.txt
```

Based on some [examples](https://git.peppe.rs/cli/journal/plain/examples/):


{% raw %}

```
$ cat ~/journalfile.txt

   September 2023     
Su Mo Tu We Th Fr Sa  
                1  2  
 3  4  5  6  7  8  9  
10 11 12 13 14 15 16  
17 18 19 20 21 22 23  
24 25 26 27 28 29 30  

WEEK 1 -------------

o store visit
> make apple pie
x return cookbook


WEEK 2 -------------

> peel apples
x buy apples
x wash them


WEEK 3 -------------

- weather: sunny
> store visit 
> make apple pie
x return cookbook


WEEK 4 -------------

* shopping trip
* buy cookbook


WEEK 5 -------------

- weather: sunny
x make apple pie
```

{% endraw %}


* [Calendar.txt (Calendar.txt syntax) - Keep your calendar in a plain text file](https://terokarvinen.com/2021/calendar-txt/)
> Calendar.txt is versionable, supports all operating systems and easily syncs with Android mobile phone.

* [Today - If you do this and only this, today will be a good day](https://johnhenrymuller.com/today)

* [Calendar - A simple printable calendar with the full year on a single page](https://neatnik.net/calendar/)
> If you print this page, you'll get a nifty calendar that displays all of the year's dates on a single page.
> It will automatically fit on a single sheet of paper of any size.
> For best results, adjust your print settings to landscape orientation and disable the header and footer.
> 
> Take in the year all at once.
> Fold it up and carry it with you. Jot down your notes on it.
> Plan things out and observe the passage of time.
>
> [Source on GitHub](https://github.com/neatnik/calendar)

https://github.com/jukil/plain-text-life

https://github.com/jukil/plain-text-life/blob/master/today.txt

https://journaltxt.github.io/

https://standardnotes.com/

https://markwhen.com/

https://github.com/mark-when

https://github.com/mark-when/calendar

https://github.com/mundimark/awesome-txt

https://scottnesbitt.net/

https://opensourcemusings.com/


**TESTING**

* timebox [https://github.com/susam/timebox](https://github.com/susam/timebox)

----


## **LIFE MANAGEMENT** 

[This Easy Life Management System Will Make You Happier, Freer, and Twice As Productive](https://stephenguise.com/this-easy-life-management-system-will-make-you-happier-freer-and-twice-as-productive/)

----

## References
(Retreived on Sep 17, 2023)

* [Simple Project Management using Index Cards - Reference as a photo/infographics in a PDF](https://www.moehrbetter.com/uploads/8/9/0/3/890360/index_card_system.pdf)
> **ONE CARD PER PROJECT**   
> I write the name of the project at the top in Sharpie, with key to-dos and reminders underneath.
> Typically its just the Next Action.
> I keep a stack of blank cards on my desk, and make a new card any time a new project shows up.
> I've been grabbing a blank card instead of my usual post-it note (stickie).
> It takes the same time, and now it's a live card.
> 
> **I currently have 32 projects.**   
> I have instant access to any of them, it's easy to group, prioritize, overview, add notes, and it takes up minimal space.
> It's a super light-weight and flexible system.
>
> **ON DECK**    
> The projects I will pick from first when the daily stuff is done, or when there is down time.
> 
> **DONE**    
> Handy for billing, month-end reports, or just because some things that are "done" can come back.
> 
> **LATER**   
> Things I know I want to do soon but not urgent yet.
> It just keeps them in the wings.
> Easy to add an idea, or move up in priority. 
> 
> **WAITING FOR**    
I put active project cards here when I'm waiting for someone else to do something before I can keep going.
> I put the card sideways into a little slot I cut in a scrap of wood.
> It's out of the way, and easy to move to TODAY or ON DECK if I get what I was waiting for.
> They are also a handy reminder to followup if needed.
> Because they are sideways, I tend not to see them unless I look right at them.
> 
> **TODAY**    
> I usually pick these cards the night before, and they can change any time.
> There are easy to swap in or out or reprioritize.
> 
> **TRANSPORT**  
> If I needed to work at a different location, I would make five coloured separator cards, one for each status (Today, Waiting For, On Deck, Later, and Done).
> Then I would gather them in one stack, and quickly spread them back out at my new location.
> 
> NOTE: I have lots of supporting paper documents in manilla folders, computer files in folders, emails, cloud storage, web apps, and tons of reference and archive materials. The cards do not replace all that.
> 
> **I ONLY USE THESE CARDS TO EASILY MANAGE WHAT TO WORK ON NEXT.**
> 
> This was inspired by the paper "flight progress strips" used by the London Air Traffic Control Centre.
> The paper strips provide essential speed, flexibility, organization, and visual feedback that is simply more difficult when using just their sophisticated computer systems.
> 
> Scott Moehring, www.moehrbetter.com

* [GTD Advanced Workflow Diagram](https://www.moehrbetter.com/gtd-advanced-workflow-diagram.html)

* [GTD Advanced Workflow Diagram - PDF](https://www.moehrbetter.com/uploads/8/9/0/3/890360/gtd_workflow_advanced.pdf)

* [The Productivity Manifesto](https://nathanbarry.com/wp-content/uploads/The-Productivity-Manifesto.pdf)

* [Plain Text Journaling](https://peppe.rs/posts/plain_text_journaling/)

* [Plaintext Productivity](https://plaintext-productivity.net/)

* [Plaintext Productivity - Discussion on Hacker News](https://news.ycombinator.com/item?id=30745524)

* [The Plain Text Project - All Articles - Articles Archive](https://plaintextproject.online/articles.html)

* [Recursive Notes (Recursive Post-It Notes or Recursive Stickies) - 27 Mar 2021 - Progress: Demo](https://mitxela.com/projects/recursive)

* [Recursive Notes (Recursive Post-It Notes or Recursive Stickies) Part 2 - 2 Apr 2023 - Progress: Demo](https://mitxela.com/projects/recursive_2)

* [recursive -- recursive post-it notes experiment - source code on GitHub](https://github.com/mitxela/recursive)

* [lftm -- A low-friction task management system - Like a productivity app, without the app](https://github.com/CoralineAda/lftm)

* [The Ultimate Productivity Suite](https://www.stevefenton.co.uk/blog/2021/09/the-ultimate-productivity-suite/)

* [The Ultimate Productivity Suite -- Printable Single-Page Productivity Worksheet](https://www.stevefenton.co.uk/downloads/the-productivity-worksheet.pdf)

* [The Ultimate Productivity Suite Book - The Productivity Workbook in PDF](https://www.stevefenton.co.uk/downloads/the-productivity-workbook-full.pdf)  

* [The PARA Method: The Simple System for Organizing Your Digital Life in Seconds](https://fortelabs.com/blog/para/)

* [This Easy Life Management System Will Make You Happier, Freer, and Twice As Productive](https://stephenguise.com/this-easy-life-management-system-will-make-you-happier-freer-and-twice-as-productive/)

* [ADHD Productivity Fundamentals](https://0xff.nu/adhd-productivity-fundamentals)

* [Getting things done (in small increments)](https://dubroy.com/blog/getting-things-done-in-small-increments/)

* [List one task, do it, cross it out](https://www.oliverburkeman.com/onething)

* [List one task, do it, cross it out - Discussion on Hacker News](https://news.ycombinator.com/item?id=36253882)

* [Third Time: a better way to work](https://www.lesswrong.com/posts/RWu8eZqbwgB9zaerh/third-time-a-better-way-to-work)

* [Third Time: a better way to work - 74 comments](https://www.lesswrong.com/posts/RWu8eZqbwgB9zaerh/third-time-a-better-way-to-work#comments)

* [The Flowtime Technique (Abandoning Pomodoros Part 2)](https://medium.com/@UrgentPigeon/the-flowtime-technique-7685101bd191)

* [The Flowtime Technique Cheat Sheet](https://medium.com/@UrgentPigeon/the-flowtime-technique-cheat-sheet-30168b2e31d9#.5kzhko7ab)

* [How To Be Productive Working From Home](https://www.to-done.com/2005/08/how-to-be-productive-working-from-home/)

* [My Personal Kanban](http://greggigon.github.io/my-personal-kanban/)

* [Personal Kanban 101](https://www.personalkanban.com/personal-kanban-101)

* [Kanban - a Trello clone in Rails and Backbone.js](https://github.com/hauntedhost/kanban)

----

