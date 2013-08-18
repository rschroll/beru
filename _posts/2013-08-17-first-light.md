---
layout: post
title: First Light
---
Well, I've gotten Monocle integrated, so Beru will actually work as an Epub viewer.  Go [check it out](https://github.com/rschroll/beru) and see if it works for you.  If it does, and especially [if it doesn't](https://github.com/rschroll/beru/issues), I'd like to hear.

It's ugly and clunky and even a bit crashy at times, but it does actually work.  There's a lot of work to be done to make it truly usable, but it doesn't seem so impossible now.


<img class="center" src="{{ site.baseurl }}/assets/screenshot-08-17.png" alt="Screenshot" width="420" height="646" />

One surprise in the implementation is that it would be very hard to do the parsing of the Epub file in QML.  The control files within the Epub are all XML files, and most Javascript engines come with DOM parsing and traversal libraries.  But the QML engine only supports [a portion](http://qt-project.org/forums/viewthread/9047) of the standard DOM methods, and then only in objects returned by XMLHttpRequest.  So instead, I moved the Epub parsing into the WebView.  This lets me use all the DOM methods I'm used to, with the caveat that it's going to be more difficult to get information about the Epub, like the title and author for the book list, back out to the QML level.  We're already using the document title as a side band to pass information this direction; I anticipate a lot more of this.
