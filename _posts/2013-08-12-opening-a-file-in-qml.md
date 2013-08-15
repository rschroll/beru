---
layout: post
title: Opening a file in QML
---
I've download an [entirely new development environment](http://developer.ubuntu.com/get-started/#step-get-toolkit) (lots of fun over a 3G cellular connection!) and I'm ready to learn QML.  The most basic thing I have to work out is how to open a file for reading.  Let's find out how.

That's odd&mdash;there's nothing about opening files in the [Ubuntu SDK](http://developer.ubuntu.com/api/devel/ubuntu-13.10/qml/ui-toolkit/overview-ubuntu-sdk.html).  Let's check the [QML docs](http://developer.ubuntu.com/get-started/).  Nothing there.  Let's ask Google.  [Here we go](http://stackoverflow.com/questions/7773994/how-the-heck-do-i-read-in-file-contents-in-qml):

> QML has no built-in file I/O.


*[Wat](https://www.destroyallsoftware.com/talks/wat)?*

A poster points out that this isn't entirely true.  If you just want to read a file, you can [use XMLHttpRequest](http://www.mobilephonedevelopment.com/qt-qml-tips/#File%20Access).  Let's go ahead and try it:

{% highlight qml %}
var request = new XMLHttpRequest()
request.open('GET', 'test.txt', false)
console.log(request.send())
{% endhighlight %}

Since the request is just going to the filesystem, there's no need to make an asynchronous request, so we can avoid messing with callbacks.

{% highlight html %}
Error: Synchronous XMLHttpRequest calls are not supported
{% endhighlight %}

Or not.

To be fair, the [QML docs](http://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-qmlglobalobject.html) do point out that synchronous requests are not supported.  But other than that, it supports the W3C standard.

*\[Aside: Take a look at the breadcrumbs at the top of that [doc page](http://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-qmlglobalobject.html).  I bet you think if you click on the "qtqml" link one level back, you'll get taken to the QML docs for Qt5.0.  Of course not, you silly goose&mdash;you get taken to the top level of the Qt5.1 docs!  This makes navigating the site* extra *fun.\]*

Okay, we'll do it with a callback.  In anticipation of opening epub files, we'll set the `responseType` so that we can load a binary file.

{% highlight qml %}
var request = new XMLHttpRequest()
request.open('GET', 'test.txt')
request.responseType = 'arraybuffer'
request.onload = function (event) {
    console.log(request.response)
}
request.send()
{% endhighlight %}

This doesn't work either.  The function is never called, so we switch back to the older `onreadystatechange` event.  But `response` stays undefined.  It's looking like XMLHttpRequest2 isn't actually supported, despite the docs referencing it.  Back to version 1 we go, which means that we won't be able to use an array buffer.

{% highlight qml %}
var request = new XMLHttpRequest()
request.open('GET', 'test.txt')
request.overrideMimeType('text/plain; charset=x-user-defined')
request.onreadystatechange = function(event) {
    if (request.readyState == XMLHttpRequest.DONE) {
        console.log(request.responseText)
    }
}
request.send()
{% endhighlight %}

{% highlight html %}
TypeError: Object [object Object] has no method 'overrideMimeType'
{% endhighlight %}

*Gah!*  Oh, and don't bother to check `status`.  That's 0 regardless of success or failure.  So I guess that list of exceptions to the standard in the docs wasn't meant to be exhaustive.  Luckily, some kind soul submitted a [bug](https://bugreports.qt-project.org/browse/QTBUG-21909) against this documentation.  Two years ago.  I'm sure it'll be fixed Real Soon Now.

### Summing up

If you want to open a text file in QML, you can, but you need to handle it in a callback set on an XMLHttpRequest.  As best I can tell, this is the simplest way to do it:

<div class="highlightname">Reading a text file with QML</div>
{% highlight qml %}
var request = new XMLHttpRequest()
request.open('GET', 'test.txt')
request.onreadystatechange = function(event) {
    if (request.readyState == XMLHttpRequest.DONE) {
        process_file(request.responseText)
    }
}
request.send()
{% endhighlight %}

In comparison:

<div class="highlightname">Reading a text file with Python</div>
{% highlight python %}
with file('test.txt', 'r') as f:
    process_file(f.read())
{% endhighlight %}

I'm reminded of [INTERCAL](http://catb.org/esr/intercal/paper.html).

> For example, the easiest way to store the value of 65536 in a 32-bit INTERCAL variable is:
>> DO:1<-#0$#256
> If that's the easiest way, imagine the power at your fingertips if you're trying to be deliberately obscure!

For completeness, let's also give listings for binary files.

<div class="highlightname">Reading a binary file with Python</div>
{% highlight python %}
with file('test.txt', 'rb') as f:
    process_file(f.read())
{% endhighlight %}

<div class="highlightname">Reading a binary file with QML</div>
{% highlight qml %}
// Hah!
{% endhighlight %}

I guess this is that convergence thing everyone keeps talking about.
