---
layout: post
title: A HTTP server in QML
date: 2013-08-16 23:00:00
---
Monocle, the Epub render I'm using, expects the books to be coming from a server.  While you can [work around this](http://rschroll.github.io/efm/), it's ugly, hacky, and fragile.  (I should know; I wrote the work-around.)  So my plan is to put a simple HTTP server in the app to serve up the components of the Epub.

In Python (oh, dear sweet Python, how I miss thee) it is [dead simple](https://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-imports.html) to fire up a HTTP server.  In QML, not so much.  So I was pleasantly surprised to find [QHttpServer](https://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-imports.html), a HTTP server written in Qt.  With my [previous experience]({{ site.baseurl }}{% post_url 2013-08-14-reading-files-with-a-c++-plugin-in-qml %}), it was rather straightforward to add the QML bindings.


Thus, if you check out [my branch](https://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-imports.html), you can write a HTTP server in QML:

{% highlight qml %}
import QtQuick 2.0
import HttpServer 1.0

Item {
    width: 300; height: 200

    HttpServer {
        id: server
        Component.onCompleted: listen("127.0.0.1", 5000)
        
        onNewRequest: { // request, response
            response.writeHead(200)
            response.write("<h1>Hello, world!</h1>")
            response.end()
        }
    }

    Text {
        anchors.centerIn: parent
        text: "Serving at <a href='http://localhost:5000'>localhost:5000</a>"
        onLinkActivated: Qt.openUrlExternally(link)
    }
}
{% endhighlight %}

One of the interesting things about QHttpServer is that it's completely event-driven.  Unlike Python's BaseHttpServer, you don't need to put it in its own thread.  Instead, it just pops to life in the main thread whenever a request comes in.  That's pretty cool.

Don't worry, Python, I still love you plenty.
