Working habits
==============
:tags: gtd

Inarguably `David Allen's Getting Things Done <https://en.wikipedia.org/wiki/Getting_Things_Done>`_ had the great influence on me in developing an efficient working routine.  I have implemented my own system based on the book which works well for me most of the times.  Interestingly, GTD also taught me what I should *not* do, and when things go less great I am noticing it in a short time:

* *Maybe this should be a whole project rather than a task?*
* *Is this item is really actionable?*
* *Was there any progress on this project recently?*
* ...

When these questions arise, it's an indication that something needs to be changed.  Actually, most of the time they signal that some *thinking* is needed before doing.

A key aspect of getting things done is a distraction free environment.  You can have the best task system ever, if the phone always rings, message notifications pop up, projects will never move forward.  I'd already recognized some points to improve in my working habits during my PhD, but I've been trying to shape my working environment more consciously since I started working in industry.

Here are some tools I use, techniques I implemented during the last years to support a good GTD work flow.  Most of the my work happens before the computer, so some of the points following are rather specific.

So here are my tips (for myself and you):

* Avoid distractions
* Be asynchronous
* Be responsive
* Be distributed

Let's see each point in detail.

Avoid distractions
------------------

As stated earlier this is the most important point.  Distractions destroy productivity.

Solid black desktop
~~~~~~~~~~~~~~~~~~~

I used to tinker a lot with desktop widgets, I loved to put email notifications, clocks, cool backgrounds, nice window decorations, etc. on my desktop.  Now they are all gone, they're good for nothing but distractions.  My desktop has solid black color, no icons or anything at all.

Tiling is great
~~~~~~~~~~~~~~~

I'm using a tiling window manager (`XMonad <http://xmonad.org>`_) which helps me to keep my applications organized.  I can only see the windows I need for what I'm working on.  My task bar is very small and only shows the most essential information.

At most two screens
~~~~~~~~~~~~~~~~~~~

These days it's common to have a workstation with two, three or even more screens.  I used to love screens a lot myself: the more the better, I thought.  It turns out that more screens just provide more space for distractions.

    *On this screen I will always keep my mail client open.*

I used to think.  Well, that's basically the same thing as having an annoying "You've got mail" notification on the desktop. Very annoying.

At work, my workstation has two screens, which is sufficient for me. Two screen provides reasonable arrangements for most of my work flows.  For example I can keep:

* code and documentation,
* code and testing/debugging outputs,
* browser and mail client

comfortably next to each other.  At home I use my laptop without external screens.  Thanks to my window manager I can switch almost instantaneously between virtual desktops, so I don't feel limited by its relatively small, 12.5" screen.

Be asynchronous
---------------

Most of these ideas I learned from a series of blog posts explaining `How GitHub Works <https://zachholman.com/posts/how-github-works/>`_.

Prefer email to phone
~~~~~~~~~~~~~~~~~~~~~

I prefer email to phone.  Receiving an email is not a distraction for me (see my comment on email notifications above) while a phone call is.  I can read and answer emails when I want, at the time and location where I feel like dealing with them.

Of course there are good reasons to call: the feedback is immediate, the discussion is more personal, conveying a message may be easier.  Still, most people prefer to call because they fear that the other person might not read their emails or forget to answer.  Indeed, most people haven't got the slightest clue how to deal with their email.  The result is: emails get lost and forgotten so people think *Maybe I should just call instead...*

Calls and email can co-exist very naturally: calls can be organized over email.  Fix a time then discuss what's needed.  In fact, this way the phone call effectively turns into a meeting.  More on meetings in the next section.

Also email is only good as a communication tool if emails get answered, that is if the use of email comes with certain responsiveness.  I'll return to this point too later.

Prefer documentation to meetings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Just Google the terms "why meetings are bad" or "how to have good meetings" and you'll see my point.  The bottom line is that meetings are super expensive and very inefficient.

When I need to distribute knowledge I prefer to write documentation.  No, not that kind of documentation everybody hates writing.  I write a couple of lines on our company wiki or issue tracker, send a link around and ask people to read and ask questions or, even better, directly edit it if something is not clear.

Short essays, structured documents such as `RFCs <https://en.wikipedia.org/wiki/Request_for_Comments>`_ or `PEPs <https://www.python.org/dev/peps/>`_ are great to convey a proposal or an idea.  These documents can be distributed, discussed and enhanced over email and no boring meetings are required.  They don't have to be super formal to be useful: the time spent on just gathering the words together helps to get out something solid out of the thinking process.


Be responsive
-------------

Asynchronous communication as mentioned before does not work without trust.  People will bother you on the phone (or through other synchronous channels) if they fear that you won't take the time to read your e-mails or review the documents you received.  Trust can be build by being *responsive*.  If people develop trust in me and learn that they will get a response from me in time, it helps them to adapt their work flows to mine.

I try to answer my e-mails in a 'reasonable' time.  It depends on the context what this means:

* work related mails I try to answer within a day.
* a mail from a friend a subject 'how is it going' will be answered in a couple of days.

It happens that an email stays unanswered for a longer period of time, but most of the time it's because I didn't take the time to do it (which effectively means, because I was lazy) not because it was lost or forgotten.  I use the 'Inbox Zero' strategy (the term coined by Merlin Mann) to handle my mails using a super simple system named 'Trusted Trio' adopted from `Lifehacker <http://lifehacker.com/182318/empty-your-inbox-with-the-trusted-trio>`_.

Be distributed
--------------

Stuff gets done at physically different locations.  For me these locations are: work, home and when I'm on the go.  For example, it can happen that in the office during the day I take some notes that I need in the evening at home to complete a certain task.  This means that my notes need to be distributed among all my places of work and they need to be accessible *without too much effort*.  In GTD terms: my reference material needs to be accessible from different contexts.

More specifically:

* It's a commonplace, but I can access my e-mails from anywhere.
* I synchronize my browser bookmarks and history using Firefox, so I can save interesting sites for reading them later, somewhere else.
* My configuration files are stored `on GitHub <https://github.com/wagdav/rcfiles>`_ so I can access them from all my work stations.
* My notes are in a text file in a Dropbox folder.
* My task list is kept in sync by `Taskwarrior <https://taskwarrior.org>`_.

I'd like to improve on my current setup to make my personal data, such as pictures, documents, etc. more accessible when I'm not home (only for myself in a secure manner
of course).  Maybe I write a post about this some other time.

Summary
-------

I try to shape my working habits to get my stuff done in the most efficient manner.  I identified four principles (no distractions, asynchronous communication, responsiveness and distribution) which can help me to achieve this.
