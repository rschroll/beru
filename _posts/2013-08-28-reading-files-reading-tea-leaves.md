---
layout: post
title: Reading files, reading tea leaves
---
On reddit, [silxx pointed out](http://www.reddit.com/r/ubuntuappshowdown/comments/1l67be/app_update_beru_actually_kinda_usable_now/) that apps running on a phone won't have full access to the filesystem.  This is sort of important, so naturally it seems to be undocumented.

I asked about this at UDS, and it seems there will be a way for apps to get access to local files.  However, nobody seems quite sure about what that way will be.  The current situation seems to be that you must include a [security manifest](https://wiki.ubuntu.com/SecurityTeam/Specifications/ApplicationConfinement/Manifest) with your app, which is used to generate an AppArmor profile that will restrict file system access.  How much access can you for?  Presumably this is detailed in the submission process, which [will be arriving in the next week or two](http://developer.ubuntu.com/showdown/), as it has been for the last three weeks.

The future, though, is apparently a "Content Hub", presumably [this thing](https://code.launchpad.net/~phablet-team/content-hub/trunk), where you can ask for content from other programs.  Does the file system count as another program?  How do I use it?  How do I test it?  Is it even ready for use?  The only documentation I've found is [this brief high-level overview](http://bazaar.launchpad.net/~phablet-team/content-hub/trunk/view/head:/doc/Mainpage.md) and some uncommented code samples.  I'm hoping that this is still in the future, and I can worry only about the security manifest for the App Showdown.  But no one has been able or willing to tell me something definite.


As an aside, the overview of the content hub says

> As we cannot assume that two apps that want to exchange content are running at the same time, a system-level component needs to mediate and control the content exchange operation, making sure that neither app instance assumes the existence of the other one.

I'm no expert, but I believe a system-level component to allow applications to exchange data, even when they aren't running at the same time, is called a "file system".

In a way, this sort of explains why I was having so much trouble reading files before:  You aren't supposed to do that.  Your app shouldn't be messing about the file system.  Just sit in your own little silo and don't worry about your neighbors.  Here's a handy database for you to store all of your data where no one else can mess with it.

This bothers me, because it feels like a betrayal of the [Unix philosphy](http://en.wikipedia.org/wiki/Unix_philosophy).

> * Write programs that do one thing and do it well.
> * Write programs to work together.
> * Write programs to handle text streams, because that is a universal interface.

Unix (and I'm considering Linux a Unix here) is wonderful precisely because it has a bunch of small parts all jostling together and interacting through the file system.  You want tool A to operate on the output of process B?  Sure thing.  They both speak text; they both converse with the file system.  A doesn't have to know anything about B, nor does B have to prepare data specifically for A.  They just do their thing, and you, the user, get to yoke them together into fantastic unexpected unholy messes that the creators of A and B would surely be shocked by.  It's wonderful.

But the approach with Ubuntu Touch fights against this philosophy.  It makes writing text files hard and writing to your own private database easy.  So you no longer produce text streams that other people can consume; you just stuff it out of the way in `~/.local/share/Qt Project/QtQmlViewer/QML/OfflineStorage/Databases/e470c9d4cff56f12aca36f7a88a2c98a.sqlite` where no one else with bother it.

And since no one will, we won't have programs that work together.  Okay, there is the content hub to allow them to exchange data.  But these needs both programs to plan to exchange a certain kind of data.  If one doesn't anticipate that some data will be wanted, you're out of luck.

Even I, champion of the text file, am taking the easy route and using the local storage database.  But this means I'm locking away potentially useful data.  One of the things I keep track of is when you last read a book.  This might be interesting to a app tracking time use.  If I kept this in a text file on a mutually-accessible file system, that time-use app could just read the text file and use the data without my permission.  But instead, I've hidden it inside a database in an obscure directory that the other app may not even be able to read.  Or: I'm making thumbnails of book cover for use in Beru.  Wouldn't it be nice if I made those available to the file view to use as icons?  Sorry, stuffed into a database; you can't have it.

And this attacks that first point of the philosophy.  If it's hard to work with other programs, you tend to try to do a bunch of things yourself.  And this leads to a program that does a bunch of things passably, but none of them well.  And worse, your data gets locked up, and you get locked in.  This other program might be really good at one thing, but if moving your data over there and back is a pain, you'll stick with the mediocre solution that does everything.

This trend didn't start with Ubuntu Touch, I should note.  I first noticed it in the default photo apps for Gnome.  It used to be gThumb, admittedly imperfect, but it did keep everything in the file system.  Events were folders and metadata was kept in hidden files along side the photos.  This meant that it was easy to transfer parts of your library to another machine.  Want to move your vacation pictures from your laptop to your desktop?  Just `rsync` that directory over, and all the tags and labels come with.  It also meant that you weren't locked into gThumb.  Even your file manager acted as a basic library viewer, since events were just directories.

But eventually we moved to Shotwell.  It's definitely better in many ways, but all the metadata is kept in a database.  Want to sync over your vacation pictures?  [Too bad](http://redmine.yorba.org/issues/1292).  Want to use your file manager to see all the pictures from an event?  Sorry, they're all in folders by day.  And when someone builds to Shotwell-killer, they're going to have to figure out how to read Shotwell's database.

Note that Shotwell works just fine&mdash;as long as you use it as the developers intend.  It's only when you want to do something they didn't anticipate (sync between machines, browse photos with Nautilus, write a shell script to find out how the amount of blue in your photos changes with events) that you run into problems.

And now I realize that Ubuntu Touch is designed to encounter these problems.  Bummer.
