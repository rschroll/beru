---
layout: post
title: Using U1DB procedurally
---
QML offers easy database through the [LocalStorage](http://qt-project.org/doc/qt-5.0/qtquick/qmlmodule-qtquick-localstorage2-qtquick-localstorage-2.html) object, but if you want to be fully buzzword-compliant, you should be using [U1DB](https://one.ubuntu.com/developer/data/u1db/index), "a database API for synchronized databases of JSON documents."  This means that things saved to a U1DB on one machine can propagate to all your other machines.  For Beru, this means we can save your place in a book on your phone, and have your tablet automatically open the book at the same place later.  Nifty!

There's [QML bindings to U1DB](http://developer.ubuntu.com/api/devel/ubuntu-13.10/qml/u1db-qt5/overview.html), which have a [brief tutorial](http://developer.ubuntu.com/api/devel/ubuntu-13.10/qml/u1db-qt5/tutorial.html) and [seven somewhat redundant examples](http://bazaar.launchpad.net/~uonedb-qt/u1db-qt/trunk/files/head:/examples/).  Dustin Galgarret has [distilled these down nicely](http://wordchainapp.tumblr.com/post/60178716314/using-u1db-to-store-data-in-word-chain).  All of these, though, use a declarative approach.  This works well if you have a fixed document that your program is accessing, but we want to have a document per book.  Happily, there is also a procedural interface to U1DB.  It doesn't appear to be documented anywhere, but between the [C++ docs](http://developer.ubuntu.com/api/devel/ubuntu-13.10/qml/u1db-qt5/database.html) and [source](http://bazaar.launchpad.net/~uonedb-qt/u1db-qt/trunk/files/head:/src/), it wasn't too hard to figure out.


An important thing to keep in mind is that U1DB isn't a SQL database.  Instead of worrying about rows and columns, you're worrying about documents, specifically JSON documents.  There are (will be?) ways to query these documents like you might a SQL database, but for the basic use I present we won't need them.  We start off by creating a Database declaratively:

{% highlight qml %}
import U1db 1.0 as U1db

U1db.Database {
    id: myDatabase
    path: "filename"
}
{% endhighlight %}

The path gives the filename where the database will be persisted.  If you just give a relative filename, it'll be stored somewhere nice and safe.  [Don't worry your pretty little head about where.]({{ site.baseurl }}{% post_url 2013-08-28-reading-files-reading-tea-leaves %})  I think you can give it an absolute filename instead, but you'll run into filesystem access issues that way.

To save a document to the database, you use `myDatabase.putDoc()`.  This takes two arguments, the document as a javascript object and the name as which it should be saved.  U1DB will turn the object into a JSON string for storage.  To get it back out, use `myDatabase.getDoc()`, which takes the name of the document as an argument and returns the document as a javascript argument.  If the document doesn't exist, you get `undefined`.  You also get error messages vomited to stdout, because your users will want to know about this.

Note that putting a document in the database works like SQL's REPLACE, not UPDATE.  So if you want to update a document, you have to get it, update it, and then put it back.  Here's some simple code that allows for the saving settings for books, each in its own document.

{% highlight qml %}
function getBookSettings(bookid, key) {
    var settings = myDatabase.getDoc(bookid)
    if (settings == undefined)
        return undefined
    return settings[key]
}

function setBookSettings(bookid, key, value) {
    var settings = myDatabase.getDoc(bookid)
    if (settings == undefined)
        settings = {}
    settings[key] = value
    myDatabase.putDoc(settings, bookid)
}
{% endhighlight %}

The process of putting a document in the database seems to take ~100 ms or so, and it happens in the main thread.  This isn't much, but it can be enough to disrupt animations or other visuals.  In Beru's case, we want to write the position every time a page turns, but we're also doing an the page turn animation at the same time.  This isn't a good combination, so I've [delayed the database writes a bit](https://github.com/rschroll/beru/commit/4f2b317920df4f8030803b2b602ae007417dd6e5).  (I was worried that the problem was opening the document each time, but testing with a declarative approach in which the document is already open showed the same delay.)  A better solution would be to make a cache that sits in front of the U1DB, collecting writes and submitting them to the database occasionally.  But [I haven't done this yet](https://github.com/rschroll/beru/issues/13).
