---
layout: post
title: New name, same acronym
---
With the release of version 1.1, Beru is now the Basic *Ebook* Reader for Ubuntu.  The reason is just one of several improvements since the previous release.  Let's dive in.


Updated UI
----------
Gone are those pop-up menus and toolbars.  Beru has been updated to mesh with the current aesthetic of the Ubuntu phone.  The Library now uses "Sections" to display the various search options.  <img class="center" src="{{ site.baseurl }}/assets/sections.png" alt="Color gamut" width="480" height="184" />  It also has pull-to-refresh capability.  Long-pressing a book now brings up a dialog with information about that book and an option to delete it (if Beru can).

The book view is more radically changed.  The toolbar has been replaced with a bottom edge components.  Drag up from the bottom to reveal buttons to navigate, change the settings, or return to the Library.  Drag a bit further and the table of contents appears.
<video class="center" src="{{ site.baseurl }}/assets/contents.ogv" controls width="240" height="400">
Your browser doesn't support this video.  Just imagine something awesome!
</video>

Preliminary CBZ and PDF Support
-------------------------------
Beru's new name comes due to its preliminary support for CBZ comic book archives and PDF files.  I had been considering this for some time, but thought it would require a completely new display system for each file type.  But a few weeks ago, I realized that I could reuse the existing system by making these files act like epub files full of images.  And it works.

Sort of.  The user experience isn't so great right now.  There's no way to zoom in to read small text, so this probably won't be usable with many files.  There also seem to be performance bottlenecks with the larger files, as CBZs and some PDFs tend to be.  Please treat this as a beta release of this capability and report problems as you find them.

Content Hub Support
-------------------
Beru now supports content hub imports: both push imports (instigated by other apps) and pull imports (started by Beru).  If you download an Epub for PDF file with the browser, you will be offered the opportunity to open the file with Beru.  Thanks to this ability, I've been able to remove the built-in browser, which has been the source of [many](https://github.com/rschroll/beru/issues/80) [head](https://github.com/rschroll/beru/issues/50)[aches](https://github.com/rschroll/beru/issues/59).

Unfortunately, you *cannot* download CBZ files to Beru.  And while the file manager will offer to let you open PDFs with Beru, it recognizes neither Epub or CBZ files.  However, if you open the file manager from the "Import from Content Hub" option in Beru, you can select *any* type of file to pass to Beru.  Confused yet?

This mess is thanks to the, er, heterodox way of describing content within the content hub.  The content hub defines a set of content types (including "Documents" and "Ebooks"), but doesn't actually specify what times of files fall in each type.  That's left up to each individual app, and naturally each app does it differently.  The webbrowser recognizes an Epub file as an Ebook; the file manager doesn't.  There's no way for Beru to say, "Hey, everyone!  Those CBZ files -- pass them my way."  Instead, we have to patch every app that might deal with such file to tell it to consider a CBZ file to be of type Ebook.  Right now, "every app" is just the browser and the file manager, but when Ubuntu takes over the world and gets download managers, remote storage clients, alternate file managers, etc., this is going to be a pain for developers and a confusion for users.

The situation is even more confusing because the content hub as two types of transfers: push transfers initiated by the source and pull transfers initiated by the recipient.  Apps are under no restriction to use the same mapping of file type to content type for push and pull transfers.  And in fact the file manager doesn't.  It won't consider an Epub or CBZ file to be of type "Documents" when doing a push export, but it's happy to return these types (or any type) when doing a pull export of "Documents".  Understanding why you can open some files in some ways but not others is difficult enough when you know the underlying infrastructure.  Do we really expect regular users to understand this?

I think the content hub developers are aware of these problems, since they're planning on adding support for [MIME types](https://bugs.launchpad.net/content-hub/+bug/1324985), which we use to avoid these problems on the desktop.  But there's been no action on that bug for over ten months, so who knows how long we'll have to wait for that.

Open App Store
--------------
Using the content hub will allow users to avoid the difficulty of placing files within Beru's silo to access them, but it doesn't address the use case that I really care about: Being able to just drag files to the phone and have Beru automatically pick them up.  That just isn't possible within the security model of the official app store.

As before, I've prepared a separate version of Beru that operates without some of these restrictions.  It is actually more restricted than it used to be.  Now, it only has read access to your home directory, while it used to have write access as well.  Instead of putting a click package on this website, I've put this version into Michael Zanetti's [OpenStore](http://notyetthere.org/openstore-tweakgeek-and-more/).  With this version, you can specify which directory Beru should watch to detect new ebooks.

Desktop Version
---------------
One thing that's missing from this release is a version for the Desktop in my [PPA]({{ site.baseurl }}/install.html#ppa).  The immediate reason is that Beru 1.1 uses a newer version of the Ubuntu toolkit that isn't available on my 14.04 desktop.  But my experience with the Ubuntu toolkit is that the promise of "convergence" has been largely unfulfilled.  While Beru can run on the desktop, it's not a very nice experience.  It doesn't feel like a desktop app; it feels like a touch app that you can't actually touch.

Recent changes seem to be moving away from convergence.  We used to have a standard toolbar at the bottom of pages that I thought would eventually turn into a standard toolbar on the desktop.  That's gone, replaced by a "do-what-you-want" bottom edge that's not going to transfer well to the desktop at all.  I'm sure you could add a lot of conditional code to make something that works on the desktop.  But if you're going to do all that work, why not [work in a toolkit](https://github.com/rschroll/berg) suited to the desktop?

This isn't to say I've given up on running Beru on the desktop.  The existing code for handling desktop use remains in place.  But for now, this won't be a focus of my development.  (By coincidence, the toolkit folk just announced that their development for 15.10 will [focus on convergence](https://developer.ubuntu.com/en/blog/2015/04/15/retrospective-and-roadmap-ui-toolkit/).  We'll see if that comes to anything.)

Coming Up
---------
As I mentioned before, support for CBZ and PDF files isn't that great right now.  I'd like to improve that in coming versions.  Since I don't have many CBZ files to test, and won't be reading them during my normal use, I'd especially like to hear from people who do use them.

Beru should support content hub exports, so it doesn't trap your books in its silo.  But I haven't had a chance to look at that at all.

Finally, I've been noticing that Beru seems slow.  It takes forever to open.  Books take a while to load.  The library scrolling is janky.  Page turns often stutter.  Some of this can be improved.  Other parts may have to be disguised.  I'm not looking forward to figuring this stuff out, so if you have experience optimizing QML apps, please get in touch.
