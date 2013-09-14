---
layout: post
title: This damn fool just might pull it off!
---
Well, take a look at this:

<img class="center" src="{{ site.baseurl }}/assets/device-app-screen.png" alt="Screenshot" width="450" height="431" />


Yes indeed, that's Beru running on an actual Ubuntu Touch device.  (And boy that icon doesn't work!)

<img class="center" src="{{ site.baseurl }}/assets/device-landscape.png" alt="Screenshot" width="600" height="360" />

These screenshots are courtesy of His Holiness Alan Pope, who has a bunch more [on Google+](https://plus.google.com/109365858706205035322/posts/isvcWn6wZoh).  Thanks to his troubleshooting, there are new versions for testing ([amd64]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.1.2_amd64.click), [arm]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.1.2_arm.click)).  It looks like permissions are working, automatic orientation is working, and (most excitingly) page turning by swiping is working!  The big problem is that the U1DB to save your location in the book isn't doing that.  I've filed [a bug](https://github.com/rschroll/beru/issues/19) with my current understanding, but any and all assistance in getting this taken care of will be appreciated.

And I'm sure there's many other bugs hiding in the corners, so everyone who can poke around and try to break things is valuable.  Comments and bugs can go here or on [Github](https://github.com/rschroll/beru/issues).
