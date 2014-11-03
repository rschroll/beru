---
layout: post
title: The October surprises
---
As mentioned in the [previous episode]({{ site.baseurl }}{% post_url 2014-10-27-sprinted %}), I got to spend last week at Canonical's devices sprint in Tyson's Corner, VA.  It was a week of surprises (mostly good!), so I thought I'd share some of them here.


Surprise #1: The Invitation
---------------------------
About a month ago, I got an email from [Alan Pope](http://popey.com) with the subject line, *Washington Sprint Invite*.  I immediately knew what it was: I live near Washington, DC, and they were inviting me to a local get-together.  *Could be interesting*, I thought, but two things pecked at the back of my brain.  First, why was Alan organizing a local DC sprint from England?  Second, how did they know I lived near DC?

So I actually read the email and discovered how wrong I was&mdash;this was a large gathering of Canonical employees and a few of us community members, and they were willing to fly me from anywhere on the globe to attend.  It was pure coincidence that I lived an hour away.

Surprise #2: Everyone Was So Helpful
------------------------------------
No, I wasn't expecting a bunch of surly Canonicalites, but I wasn't so sure that my problems would be so important to anyone else.  Most of the community attendees were contributors to the [Core Apps](https://wiki.ubuntu.com/Touch/CoreApps) projects.  These are crucial for the success of the phone, so I knew their needs would be taken care of.  But I'm off doing my own thing, on which the phone does not depend, so obviously my problems are less important.

But that's not how anyone treated me.  [Manuel de la Peña](https://plus.google.com/+ManueldelaPe%C3%B1a), for example, spent the better part of an hour tracking down an obscure bug in how [DownloadManager handles redirects](https://bugs.launchpad.net/ubuntu-download-manager/+bug/1384421).  Alan Pope kept me supplied with devices for testing, even as I kept breaking them.  And the whole SDK team listened politely as I complained about the product in which they've invested more than a year, even though I was doing things completely wrong.  So to everyone who gave me a hand, many thanks!

Surprise #3: People Recognized Me
---------------------------------
Not by appearance, this being the internet, but I lost track of the number of times someone said, "Robert Schroll?  Aren't you the person who wrote Beru?"  "...wrote a crosswords app?"  "...wrote the QML HTTP Server?"  "...answered my question on Ask Ubuntu?"

Honestly, I was completely surprised by this.  Sure, I've contributed in some small ways, but nothing great or spectacular.  All these people are doing a lot more important work&mdash;why would they notice my work?  And yet they did.

This was probably the biggest rush of the whole experience.  Sometimes when I'm sending code out onto the internet, I wonder if it's actually doing any good.  After this week, I'll wonder no more.  Also, I'm going to do a better job of thanking those whose code has helped me.  They deserve the same rush!

Surprise #4: The Ubuntu Phone Is Really Happening
-------------------------------------------------
This title is rather unfair, since we've been told about this for over a year now.  But, having seen the evaporation of Ubuntu TV, Ubuntu for Android, the Ubuntu Edge, and a number of Dell and HP offerings, I'm a bit skeptical of hardware announcements.

At the sprint, I got a glimpse into what's coming up in the next few months, and it's very exciting.  I won't steal Canonical's thunder with specifics, but there is:

* Acutal physical hardware from an OEM running Ubuntu Touch that's being used day-to-day by Canonical people.  This isn't a bread-board prototype; it looks ready to ship.
* An advertising and social media blitz being set up to teach people about the Ubuntu phone.
* A definite plan for the sale of Ubuntu devices in the next few months.
* Real collaboration and integration going on with a major carrier.

These are exciting times, sports fans.  Keep an eye out for some exciting announcements soon!

Surprise #5: Desktop Integration Hasn't Been Solved
---------------------------------------------------
One of the promises of this new era for Ubuntu is that the line between the phone and the desktop will be softened, if not completely erased.  Applications will be able to run on a number of form factors, adapting themselves as they go.  And the operating system itself will adapt as you plug in keyboards or external monitors.  Your phone could be the brains of your desktop.

As I've been trying to get Beru to run on desktops as well as devices, I've noticed a number of gaps.  The toolkit doesn't support common desktop behaviors.  There's no story for how click apps will interact with a user's existing files.  There's no way to deal with different versions of the OS.  I'd get frustrated, since this stuff had obviously been worked out but not communicated to me.  Perhaps these weren't important enough issues to address in detail.

Except it *hasn't* been worked out.  We don't know how the SDK components will behave on the desktop or what needs to be added to it.  Most apps are missing designs for the desktop mode.  Nobody knows exactly what Unity 8 will look like on the desktop or how GTK's new behaviors, notably client-side decorations, will be integrated.  Or even if they will be integrated.  These issues, and many more, were fiercely debated in a number of meetings.

I'm of two minds about this.  On the one hand, it's rather unnerving to see how much work remains to be done.  The current plan is to have Unity 8 running on desktops by default on 15.10.  I think that's quite ambitious.  On the other hand, it's comforting to know that the developers are aware of these issues.  The lack of solutions isn't permanent; it just reflects the limited time and need to focus on the phone for now.  I just hope the solutions arrive in time.

I think there were about 250 people at the sprint.  Most, but not all, are working on the Ubuntu phone.  Compared to other free software projects I'm involved with, that's huge.  (Generally, two orders of magnitude larger!)  But compared to the likes of Apple or Google, it's tiny.  Ubuntu's advantage is that it's not restricted to just those 250 people&mdash;anyone can contribute.  I was told several times to hop in with patches or branches to fix problems I see, and that goes for everyone.  The desktop story hasn't been completed, but that just means that we get to write it!

* * *

There you have it.  The whole experience was very intense, but well worth it.  I went in worrying that there wouldn't be a week's worth of work for me to do, but I came out with more on my plate than I went in with.  (That's a good thing, honest!)

If you want to get a taste of what other people thought about the sprint, check out the blog posts by [Alan Pope](http://popey.com/blog/2014/10/24/sprinting-in-dc/), [Daniel Holbach](https://daniel.holba.ch/blog/2014/10/washington-sprint/), [Victor Thompson](http://www.viclog.com/entry/ubuntu-app-developer-sprint-in-washington-dc), and [Ni](http://www.theorangenotebook.com/2014/10/sprinting-in-dc-monday.html)[cho](http://www.theorangenotebook.com/2014/10/sprinting-in-dc-tuesday.html)[las](http://www.theorangenotebook.com/2014/10/sprinting-in-dc-wednesday.html) [Ska](http://www.theorangenotebook.com/2014/10/sprinting-in-dc-thursday.html)[ggs](http://www.theorangenotebook.com/2014/10/sprinting-in-dc-friday.html).

And stay tuned for version 1.0 of Beru, hopefully later this week.
