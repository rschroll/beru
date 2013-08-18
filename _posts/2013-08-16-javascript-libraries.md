---
layout: post
title: Javascript Libraries
---
Up to this point, I've been calling everything that goes into a `.qml` file "QML".  I guess that's not actually correct&mdash;QML is just the declarative code.  The procedural code for event handlers is actually Javascript.

And since it's Javascript, you can [import existing libraries](https://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-imports.html) into your QML (or maybe it's Javascript) code.  The QML engine will execute it just as any browser engine would.

[Well, almost.](http://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-hostenvironment.html#javascript-environment-restrictions)


For some reason, the QML engine puts restrictions on modifications to the global object.  For those of us who aren't Javascript wizards, this doesn't seem like a big deal.  But people who write Javascript libraries often use the global object to work around Javascript's lack of (built-in) namespaces.  These tricks will keep libraries from working with QML.  Since QML actually does [sensible namespacing of Javascript](https://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-imports.html), there's no need for these things, so you can just take them out.

How much of a hassle that is will depend on the details of your library.  In my case, I'm integrating the [JSZip library](http://stuk.github.io/jszip/), and the modifications were [pretty minimal](https://github.com/rschroll/beru/commit/00af6321cce62b8f84291fbf3b8e5bcafdb09ead).  Instead of attaching objects to the root object to pass them from one script file to another, I just used `Qt.include()` to include one script file in the other.

May all your integrations go so smoothly.
