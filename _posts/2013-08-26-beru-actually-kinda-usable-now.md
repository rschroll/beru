---
layout: post
title: "Beru: Actually kinda usable now"
---
Over the last week, I've made significant progress on Beru, both visible and invisible.  It should be usable by people other than the creator now, so please [give it a try](https://github.com/rschroll/beru).  There are still many rough corners to be sanded down, but it shouldn't be completely broken.

One of the big improvements is that Beru now stores a library of the books on your device.  This means that we don't need to parse the Epub file each time we need info on it, which in turn means that the list of books can have information more useful than the filename:


<img class="center" src="{{ site.baseurl }}/assets/booklist-08-26.png" alt="Screenshot" width="420" height="646" />

Combined with new support for command line arguments, this means that Beru can be used with files outside of `~/Books`.  If you open a file with Beru, it'll be added to your library for future reference.

The viewer itself has also gained some options.  There's now limited choices for colors, fonts, and margins.  This may be expanded some, but I do want to keep Beru *basic*, and not overdose on options.

<img class="center" src="{{ site.baseurl }}/assets/options-08-26.png" alt="Screenshot" width="420" height="646" />

Behind the scenes, I've replaced several Javascript bits with C++ code.  This should improve both speed and stability.  But there's no interesting screenshot for this.

One thing that's very definitely missing is icons.  I need icons for the toolbar at the bottom and for books that don't have covers.  This isn't my strong suit, so if you'd like to help, please get in touch!
