---
layout: post
title: Reading files with a C++ plugin in QML
---
In the [previous post]({% post_url 2013-08-12-opening-a-file-in-qml %}), we saw the difficulty in reading a file with QML.  Most resources helpfully point out that you can do this in C++.  Because if there's one thing every programmer hopes for, it's to use C++ more often.

There seem to be two ways you can do this: you can write your program in C++, with a `main.cpp` and everything, and then load the QML to be the GUI, or you can write a plugin in C++ that you can call from your QML program.  Since I'm one of those [rare programmers](http://yosefk.com/c++fqa/) that doesn't love C++, we're going to go the second way.


I don't know how to write such an extension or how to integrate it into a QML program, but Ubuntu thoughtfully bundles an example, the *QML Extension Library + Tabbed Touch UI*, in the templates that should show me what to do.  Let's select that and ... boy there are a bunch of files.  Let's take a look at the README.

There's no README.

Well, let's start opening files and reading the comments.

There's no comments.

Okay, let's just build and run the thing to see what it does.  Then maybe I can work backwards to figure out which files are doing what.  Let's hit that green arrow and....

<div style="text-align: center"><img src="{{ site.url }}/assets/plugin-run.png" alt="Run dialog with no executable specified" height="303" width="388" /></div>

...

New plan&mdash;we're going to ignore the templates and look at the Qt documentation.

Somehow, I found a tutorial on writing [QML extensions with C++](http://qt-project.org/doc/qt-5.1/qtqml/qml-extending-tutorial-index.html).  (I say "somehow" because I had a heck of a time finding it a second time.  It's not linked from the [examples and tutorials page](http://qt-project.org/doc/qt-5.1/qtdoc/qtexamplesandtutorials.html) as one might expect.)  This is for Qt5.1, but it also works for Qt5.0, as we have in Ubuntu.  (The equivalent [Qt5.0 example](http://qt-project.org/doc/qt-5.0/qtqml/qtqml-modules-cppplugins.html) is the first time I've ever see *Mad-Libs* documentation.  They give you the text with blanks for you to fill in the code.  Thanks.  That's ever so useful.)  Against all odds, [chapter 6](http://qt-project.org/doc/qt-5.1/qtqml/tutorials-extending-chapter6-plugins.html) of the tutorial is actually very helpful, showing both how to create a plugin and how to use it from QML.  I'll basically repeat that information below, as I describe how to write a C++ plugin to read files.

### The Object Class

It seems that you can only import objects, and not functions, into QML. You need to create a `.h` and a `.cpp` file for this class.  The header file is basically the same as it would be for a normal Qt object, except that methods need to be prefixed with `Q_INVOKABLE` to be made visible to QML.

<div class="highlightname">filereader.h</div>
{% highlight c++ %}
#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>

class FileReader : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QByteArray read(const QString &filename);
};

#endif // FILEREADER_H
{% endhighlight %}

The source file is unchanged from what it would be otherwise.

<div class="highlightname">filereader.cpp</div>
{% highlight c++ %}
#include "filereader.h"
#include <QFile>

QByteArray FileReader::read(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
        return QByteArray();

    return file.readAll();
}
{% endhighlight %}

### The Plugin Class

You need to make another class to represent the plugin itself.  The header file is just boilerplate.

<div class="highlightname">filereaderplugin.h</div>
{% highlight c++ %}
#ifndef FILEREADERPLUGIN_H
#define FILEREADERPLUGIN_H

#include <QQmlExtensionPlugin>

class FileReaderPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.github.rschroll.FileReader")

public:
    void registerTypes(const char *uri);
};

#endif // FILEREADERPLUGIN_H
{% endhighlight %}

I have no idea what `Q_PLUGIN_METADATA` is needed for.  The examples all use this Java-esque reversed domain name thing, so I made one up here.  No problems so far.

<div class="highlightname">filereaderplugin.cpp</div>
{% highlight c++ %}
#include "filereaderplugin.h"
#include "filereader.h"
#include <qqml.h>

void FileReaderPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<FileReader>(uri, 1, 0, "FileReader");
}
{% endhighlight %}
The important thing here is the call to `qmlRegisterType`, which makes a specific class, in this case `FileReader`, available to QML.  The second and third arguments specify the major and minor version numbers of the plugin, and the last argument is the name under which the class is available to QML.  If you're exposing multiple classes to QML, you'll need a `qmlRegisterType` for each.

### Building

Qt uses the qmake build system, which is controlled by `.pro` files.  I don't claim to understand it, but this works for me.

<div class="highlightname">filereader.pro</div>
{% highlight make %}
TEMPLATE = lib
CONFIG += plugin
QT += qml quick

DESTDIR = File
TARGET = filereaderplugin

OBJECTS_DIR = tmp
MOC_DIR = tmp

HEADERS += filereader.h filereaderplugin.h

SOURCES += filereader.cpp filereaderplugin.cpp

OTHER_FILES += app.qml
{% endhighlight %}

`DESTDIR` specifies a directory into which the library files go, and `TARGET` gives the name of those files.  Temporary build fiels are put into `OBJECTS_DIR` and `MOC_DIR`.  `OTHER_FILES` is just to let Qt Creator know to consider that file as part of the project.

Now you can build your plugin with

{% highlight bash %}
$ qmake
$ make
{% endhighlight %}

and you should get a folder named `File` with `libfilereaderplugin.so` in it.  To this directory, you need to add a file named `qml` with these contents:

<div class="highlightname">File/qmldir</div>
{% highlight html %}
module File
plugin filereaderplugin
{% endhighlight %}

The first line must give the name of the directory, as specified in `DESTDIR`, while the second line must give the name of the library file as specified in `TARGET`.  This is not built automatically because requiring humans to add boilerplate by hand is a key to reliable software development.

*\(Actually, you can specify additional options in the `qmldir` file.  The library files can be put in another directory, specified by the `plugin` line, for example.\)*

### Using in QML

Now, you can import the plugin with `import File 1.0` and have a `FileReader` class with a `read` method for your use.  Here's an example QML file.

<div class="highlightname">app.qml</div>
{% highlight qml %}
import QtQuick 2.0
import File 1.0

Item {
    width: 300; height: 200

    FileReader {
        id: filereader
    }

    Text {
        anchors.centerIn: parent
        text: "Click to read file into console"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: console.log(filereader.read('app.qml'))
    }
}
{% endhighlight %}

Run the program with

{% highlight bash %}
$ qmlscene -I . app.qml
{% endhighlight %}

The `-I .` argument tells it to look in the current directory for extensions to be included.  Note that you specify the directory that is the parent of the directory containing the `qmldir` file.

### Use with Qt Creator

If you open the `filereader.pro` file with Qt Creator, it will open the whole project for you.  It will give you a configuration screen; just accept the defaults.  Qt Creator likes to use "shadow builds", wherein the build happens in a completely separate directory.  I can see places where this would be useful, but here it would interfere with the QML file finding the libraries.  Disable them by clicking on the *Project* tab and delecting *Shadow build* under *General*.

Now if you click the run arrow, everything should build, but you'll get that dialog I showed at the beginning of this post.  For *Command*, enter `qmlscene`.  For *Arguments*, `-I . app.qml`.  With a bit of luck, everything will just work.

### Opening binary files

Those of you with a good memory may remember the reason we're doing all of this work is that we can't [open binary files]({% post_url 2013-08-12-opening-a-file-in-qml %}) with directly with QML.  But if we try opening a binary file with `FileReader`, we find that it gets corrupted.

*Argh!* It seems that QML doesn't have an equivalent type for `QByteArray`, so it gets converted into a string when it becomes enters QML space.  I'm guessing that it becomes Unicode with a UTF-8 encoding or something, but that's not what we want.  I suspect there's no way around this.  We saw before that QML doesn't have an arraybuffer type, so there's probably nothing that can represent an arbitrary sequence of bytes.  The only thing we can do is to base64 encode the file before returning it to QML.  It's straightforward to add a `read_b64` method to `FileReader`.

Here's a [tarball]({{ site.url }}/assets/filereader.tar.gz) with the whole project, including the base64 encoding.  Enjoy!
