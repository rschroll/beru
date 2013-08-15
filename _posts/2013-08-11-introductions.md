---
layout: post
title: Introductions
---
Well, here we go.

My plan is to use the wonderful [Monocle](http://monocle.inventivelabs.com.au/) library to display the epubs.  Monocle is a javascript library that takes the information in the epub file and displays it in a HTML viewer.  Thus, if I create an app with a WebView, I can stick Monocle in that to render the book.


Monocle is designed to be used from a server using pre-parsed ebook files, so I have two tasks to get basic functionality:
1. Opening and parsing the epub file.
2. Serving the epub components to Monocle.

The first isn't as bad as it sounds: epub files are just glorified zip files with various XML files within.  This is why I love developing with [Python and GTK](http://web.archive.org/web/20120814135258/http://developer.ubuntu.com/get-started/).  Python's standard library has support for [handling zip files](http://docs.python.org/2/library/zipfile), [dealing with XML](http://docs.python.org/2/library/xml.html), and [writing HTTP servers](http://docs.python.org/2/library/simplehttpserver.html).  I just have to glue this bits together and....

What's that?  We're not using Python anymore?  We're using [QML](http://developer.ubuntu.com/get-started/)?

Lovely.
