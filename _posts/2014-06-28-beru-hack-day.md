---
layout: post
title: Beru Hack Day
---
What's been happening with Beru lately?  Honestly, not that much.  There have been a number of small bugs languishing, but I haven't found the time to track them down and fix them.  Meanwhile, updates to the Ubuntu QML toolkit have caused a number of small new bugs to appear.  In short, we're in a sorry state.

Luckily, the Ubuntu folks have announced another edition of the [App Hack Days](http://developer.ubuntu.com/2014/06/bring-your-apps-to-hack-days/).  On these days, developers are invited to focus their attention on fixing bugs for a specific app.  In the past, these have only been for the core apps, but this time community apps were invited to join in.  So this coming Thursday, July 3<sup>rd</sup>, will be the Beru Hack Day.


What's this mean?  A bunch of people will hang out together on [#ubuntu-app-devel](http://webchat.freenode.net/?channels=%23ubuntu-app-devel&uio=d4) from [0900](http://www.timeanddate.com/worldclock/fixedtime.html?iso=20140703T0900) to [2100 UTC](http://www.timeanddate.com/worldclock/fixedtime.html?iso=20140703T2100), working on bugs and helping each other out.  I'll be there (handle "rschroll") from [1400](http://www.timeanddate.com/worldclock/fixedtime.html?iso=20140703T1400) onwards, picking brains and doing my best to answer questions.  Please stop by to ask questions, offer your thoughts, or join in the fun.

I've selected [a number of bugs](https://github.com/rschroll/beru/issues?labels=hackdays-1407&page=1&state=open) that I'd like to attack during this day.  Some of them ([#43](https://github.com/rschroll/beru/issues/43), [#48](https://github.com/rschroll/beru/issues/48), [#50](https://github.com/rschroll/beru/issues/50)) don't require much knowledge of the code base and should be relatively easy to fix for someone with some knowledge of the SDK.  Others ([#38](https://github.com/rschroll/beru/issues/38), [#49](https://github.com/rschroll/beru/issues/49)) will take a bit of planning, but should benefit from expert advice.  And some ([#47](https://github.com/rschroll/beru/issues/47)) are just plain weird.  I've also tagged some bugs that could use some help from people with [actual devices](https://github.com/rschroll/beru/issues?labels=device&page=1&state=open).

Contrarian that I am, Beru is developed with git on [Github](https://github.com/rschroll/beru), rather than with bzr on Launchpad.  If this doesn't phase you, please fork Beru, make your changes, and then create a pull request.  But if you don't feel like learning another VCS, feel free to [download the source](https://github.com/rschroll/beru/archive/master.zip) and send me patches by email (rschroll at gmail).  That's just as easy for me to deal with.

I don't know that we can get through all those bugs I've tags for the hack day.  But if we do, we'd almost be to the point that I'm willing to call 1.0.  So please come out and join the fun!
