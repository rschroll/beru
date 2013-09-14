---
layout: post
title: Call for testing
---
There's been a number of improvements to Beru since last we met, but I'll highlight two here.

First, following the suggestion of Stuart Langridge, all of an author's books are grouped together when you sort the library view by author.  Authors with only one book get an entry that opens that book, while authors with multiple books get an entry that opens a sub-list with all of their books.  On narrow screens, there's a nifty slide animation between the two lists; on wide screens, you can see them side by side:


<img class="center" src="{{ site.baseurl }}/assets/screenshot-09-12.png" alt="Screenshot" width="664" height="646" />

Second, Beru can now be built into a "click" package, the new format for distributing programs for Ubuntu Touch.  It doesn't really support compiled code, so you just package your `.so` files and hope for the best.  I'd try to explain, but Michael Zanetti has already [done so superbly](http://notyetthere.org/?p=316).  I'll just add that this is the place to [request access to the filesystem]({{ site.baseurl }}{% post_url 2013-08-28-reading-files-reading-tea-leaves %}).  In the JSON file with the apparmor settings, you can add a `read_path` and a `write_path` setting.  Each of these is a list of directories you wish to read from or write to.  Note that you refer to the home directory as `@{HOME}`, not `~` or `$HOME` or any other standard syntax; otherwise you end up with errors about being click being unable to parse your manifest.  But only on install, which is obviously a better time to check such things than when you're building them.

(Fun family game: Try to come up with a less Googlable name for a package format than "click".  It keeps the kids entertained for hours!)

Anyway, Beru is basically ready for the masses now.  All it needs is testing, particularly on a real Ubuntu Touch device.  That's where you come in.  Whether you have a phone-like device or not, please download Beru, run it, and let me know what works or doesn't.  You can either clone the [git repository]() or you can install it as a click package:

* [<del>amd64 click package</del>]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.1_amd64.click) [v0.1.2 amd64 click package]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.1.2_amd64.click)
* [<del>arm click package</del>]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.1_arm.click) [v0.1.2 arm click package]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.1.2_arm.click)

(Be sure to choose the right architecture.)  You can install the click package with `sudo click install --force-missing-framework --user=$USER *.click`.

Any testing you can do is greatly appreciated, but if you're looking for something specific to try, here's some things to focus on:
* Can you get a listing of the books in `~/Books/` and open files there?  Can you save files there from the "Get Books" tab?  (This is testing the filesystem permissions.)
* Does your place in a book get saved between invokations of Beru?  In my testing, this was *not* working.  (There may be an issue with the default location of U1DB databases.)
* Does a (rather ugly) Beru icon show up in your Dash?  I'm not getting this to work, but I've heard that this may be a general problem with click packages.
* Can you turn pages by sliding your finger across the page, or only by tapping the page?  (You should be able to drag the pages to turn them, which would be a nice effect, but in my desktop testing, this [isn't working](http://askubuntu.com/questions/335667/receiving-drag-events-in-a-webview-in-a-qml-application).  But I've seen one mailing list thread that suggests this could be a problem with click handling specifically in WebKit/QML.  If you want to see how it should behave, open a book with Beru and then open [localhost:5000](http://localhost:5000) in your webbrowser.)
* Try uncommenting the line `automaticOrientation: true` in `main.qml`, and see if Beru behaves sensibly when you change from portrait to landscape.  This is something I can't test on the desktop.

Please report your finding here or [on Github](https://github.com/rschroll/beru/issues).  Thanks for your help!
