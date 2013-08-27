---
layout: post
title: Various and Sundry
---
I've learned a number of small things in the recent days.  None of them is interesting enough to fly solo, so I'm combining them into a single post.  Maybe one will tickle your fancy.


### Quazip
I've moved from JSZip to [QuaZIP](http://quazip.sourceforge.net/), for better performance and stability in opening zip files.  (Side effects include exposure to C++.)  Here's how you open a file in a zip file in QuaZIP.

{% highlight c++ %}
QuaZip* zip = new QuaZip("file.zip");
if (!zip->open(QuaZip::mdUnzip))
    return;

zip->setCurrentFile("file_within_zip.ext");
QuaZipFile zfile(zip);
if (!zfile.open(QIODevice::ReadOnly))
    return;

QByteArray data = zfile.readAll();
{% endhighlight %}

That's ... not what I would have expected.  Note that a `QuaZipFile` acts as a `QIODevice`, so you can use it as a stream source, for example.  However, only one `QuaZipFile` can be opened at a time per `QuaZip`.  You can open a second and read from that just fine, but you'll no longer be able to read from the first.

### QString vs. QByteArray
If you pass a `QByteArray` from a C++ plugin to QML, it will be treated as something of type `QVariant`.  It will not act stringy in QML, even though it often does in C++.  (Arguably, QML is doing this correctly; as we've learned from [Python](http://www.diveinto.org/python3/strings.html), you should always know whether your dealing with a string or bytes.)

This distinction persists even after you stuff the data into a text column in a database and pull it back out again.  So make sure your plugins return `QString`s if you actually want strings.

### Mimetypes and WebKit
If you don't set the `Content-Type` header when serving Javascript files to WebKit, you'll all manner of subtle and indecipherable Javascript errors.  Because that's so much better than nothing working and a clear error message.

And why does it care, anyway?

### Arguments to qmlscene
The Ubuntu SDK provides an [Arguments class](http://developer.ubuntu.com/api/ubuntu-12.10/qml/mobile/qml-ubuntu-components0-arguments.html) to give you access to the command line arguments.  But when you run your program with `qmlscene`, you end up with the arguments intended for `qmlscene` as well.  And in some cases `qmlscene` will try to interpret the arguments meant for your program.

I have trouble believing that this is how it's supposed to work, but [my question about this](http://askubuntu.com/questions/336083/how-to-use-arguments-in-qml-without-getting-qmlscene-arguments) remains unanswered.
