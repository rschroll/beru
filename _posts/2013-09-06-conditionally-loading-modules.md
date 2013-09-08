---
layout: post
title: Conditionally loading modules
---
Beru will include a browser to allow users to download Epub files from the web.  This could be done with the standard WebView element, but [Ubuntu.Components.Extra.Browser](http://bazaar.launchpad.net/~phablet-team/webbrowser-app/trunk/files/head:/src/Ubuntu/Components/Extras/Browser/) provides a UbuntuWebView element, which is the same one used in the standard browser app.  For consistency, I'd like to use this one.  But this is only packaged for [Ubuntu 13.10](http://packages.ubuntu.com/search?keywords=webbrowser-app+&searchon=sourcenames).  It'd be nice to try to load the UbuntuWebView, but fall back to the standard one if it's not there.


In Python, this is a breeze:

{% highlight python %}
try:
    import Module
except ImportError:
    import BackupModule as Module
{% endhighlight %}

QML has no similar structure, but [Stuart Langridge](http://www.kryogenix.org/) came up with a clever solution using QML's [Loader](http://qt-project.org/doc/qt-5.0/qtquick/qml-qtquick2-loader.html) element.  This is supposed to be used to load bits of QML on demand, but it does offer error detection.  So we can (mis)use it to try to load the UbuntuWebView, and load a standard WebView in its place if something goes wrong.

We start by creating a QML file that tries to create an UbuntuWebView:

<div class="highlightname">components/UbuntuWebView.qml</div>
{% highlight qml %}
import Ubuntu.Components.Extras.Browser 0.1

UbuntuWebView {}
{% endhighlight %}

Then where you'd want the WebView, you put a Loader:

<div class="highlightname">page.qml</div>
{% highlight qml %}
Loader {
    id: webViewLoader
    anchors.fill: parent

    source: "components/UbuntuWebView.qml"

    onStatusChanged: {
        if (status == Loader.Error)
            sourceComponent = basicWebView
        else if (status == Loader.Ready)
            load()
    }

    Component {
        id: basicWebView
        WebView {}
    }

    function load() {
        // The WebView is available as 'item'
    }
}
{% endhighlight %}

This tries to load the UbuntuWebView, but if this results in an error, it's caught in `onStatusChanged`, where a standard WebView is used as a replacement.  One difficulty is setting the properties of the WebView.  You could do this declaratively, but you'd have to repeat these properties in the declaration of the UbuntuWebView and the standard one.  Instead, I do it procedurally in the `load()` function called when the Loader has finished.  Whichever WebView got loaded is available as the `item` property of the Loader.

It's not the cleanest code, but it works well.
